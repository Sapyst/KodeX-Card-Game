#!/bin/bash
# Desliga o servidor do KodeX no PC (serviço, túnel e Worker). O jogo segue offline até ligar de novo.
systemctl --user stop kodex-servidor 2>/dev/null
for p in $(pgrep -f "vigia.sh"); do kill "$p"; done
for p in $(pgrep -f "cloudflared tunnel --no-autoupdate --url http://127.0.0.1:8787"); do kill "$p"; done
for p in $(pgrep -f "wrangler dev --port 8787"); do kill "$p"; done
for p in $(pgrep -f "workerd serve"); do kill "$p"; done
echo "desligado"
