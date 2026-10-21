#!/bin/bash
# Vigia do servidor do KodeX no PC (roda sempre; o systemd do usuário o liga ao entrar no PC).
# A cada 60 s: servidor local respondendo? senão sobe o wrangler dev. Endereço público (túnel) respondendo?
# 3 falhas seguidas → religa o túnel e publica o endereço novo em servidor.json (o jogo relê sozinho).
# Uma vez por dia: backup do banco em backups/kodex-AAAA-MM-DD.sql (guarda os últimos 14).
cd "$(dirname "$0")"
mkdir -p logs backups
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:$PATH"
CF="$HOME/.local/bin/cloudflared"
log() { echo "$(date '+%F %T') $*" >> logs/vigia.log; }

subir_servidor() {
  log "subindo servidor"
  setsid nohup npx wrangler dev --port 8787 --ip 127.0.0.1 > logs/servidor.log 2>&1 < /dev/null &
  for i in $(seq 1 60); do curl -s -m 2 127.0.0.1:8787/v1/saude >/dev/null && return 0; sleep 1; done
  return 1
}

subir_tunel() {
  for p in $(pgrep -f "cloudflared tunnel --no-autoupdate --url http://127.0.0.1:8787"); do kill "$p"; done
  log "abrindo túnel"
  setsid nohup "$CF" tunnel --no-autoupdate --url http://127.0.0.1:8787 > logs/tunel.log 2>&1 < /dev/null &
  local url=""
  for i in $(seq 1 60); do
    url=$(grep -oE "https://[a-z0-9-]+\.trycloudflare\.com" logs/tunel.log | head -1)
    [ -n "$url" ] && break; sleep 1
  done
  [ -z "$url" ] && { log "túnel não abriu"; return 1; }
  for i in $(seq 1 30); do curl -s -m 5 "$url/v1/saude" | grep -q '"ok":true' && break; sleep 2; done
  echo "{\"url\": \"$url\"}" > ../servidor.json
  ( cd .. && git commit -q servidor.json -m "servidor.json: endereço atual do servidor do jogo" \
      -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" && git push -q ) >> logs/vigia.log 2>&1 \
      && log "publicado $url" || log "não publiquei servidor.json"
}

backup() {
  local f="backups/kodex-$(date +%F).sql"
  [ -f "$f" ] && return
  npx wrangler d1 export kodex --local --output "$f" >> logs/vigia.log 2>&1 && log "backup $f"
  ls -1t backups/kodex-*.sql 2>/dev/null | tail -n +15 | xargs -r rm -f
}

falhas=0
while true; do
  curl -s -m 3 127.0.0.1:8787/v1/saude >/dev/null || subir_servidor || log "servidor não subiu"
  url=$(python3 -c "import json;print(json.load(open('../servidor.json'))['url'])" 2>/dev/null)
  if ! pgrep -f "cloudflared tunnel --no-autoupdate --url http://127.0.0.1:8787" >/dev/null; then
    subir_tunel; falhas=0
  elif curl -s -m 8 "$url/v1/saude" | grep -q '"ok":true'; then
    falhas=0
  else
    falhas=$((falhas + 1)); log "público sem resposta ($falhas)"
    [ "$falhas" -ge 3 ] && { subir_tunel; falhas=0; }
  fi
  backup
  sleep 60
done
