#!/bin/bash
# Liga o servidor do KodeX NO PC e o expõe pela internet com um túnel da Cloudflare (sem conta).
# 1) wrangler dev (Worker + D1 local, dados em .wrangler/) em 127.0.0.1:8787 — SEM modo de teste;
# 2) cloudflared cria https://<aleatório>.trycloudflare.com → 127.0.0.1:8787 (só o servidor do jogo, nada mais do PC);
# 3) grava o endereço em ../servidor.json e publica esse arquivo no GitHub (o jogo lê ao abrir).
# Email de verdade: crie servidor/.dev.vars com RESEND_KEY=... e REMETENTE=... (o arquivo fica fora do git).
# Uso: ./ligar.sh   ·   Desligar: ./desligar.sh
set -e
cd "$(dirname "$0")"
mkdir -p logs
CF="$HOME/.local/bin/cloudflared"
if ! curl -s -m 2 127.0.0.1:8787/v1/saude >/dev/null; then
  setsid nohup npx wrangler dev --port 8787 --ip 127.0.0.1 > logs/servidor.log 2>&1 < /dev/null &
  for i in $(seq 1 60); do curl -s -m 2 127.0.0.1:8787/v1/saude >/dev/null && break; sleep 1; done
fi
curl -s -m 2 127.0.0.1:8787/v1/saude >/dev/null || { echo "o servidor não subiu (veja logs/servidor.log)"; exit 1; }
pkill -f "cloudflared tunnel --url http://127.0.0.1:8787" || true
setsid nohup "$CF" tunnel --no-autoupdate --url http://127.0.0.1:8787 > logs/tunel.log 2>&1 < /dev/null &
URL=""
for i in $(seq 1 60); do
  URL=$(grep -oE "https://[a-z0-9-]+\.trycloudflare\.com" logs/tunel.log | head -1 || true)
  [ -n "$URL" ] && break; sleep 1
done
[ -n "$URL" ] || { echo "o túnel não abriu (veja logs/tunel.log)"; exit 1; }
for i in $(seq 1 30); do curl -s -m 5 "$URL/v1/saude" | grep -q '"ok":true' && break; sleep 2; done
echo "{\"url\": \"$URL\"}" > ../servidor.json
cd ..
git add servidor.json
git commit -q -m "servidor.json: endereço atual do servidor do jogo" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" || true
git push -q || echo "aviso: não consegui publicar servidor.json"
echo "servidor no ar: $URL"
