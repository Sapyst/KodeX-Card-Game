#!/bin/bash
# Desliga o túnel e o servidor do KodeX no PC. O jogo volta a funcionar offline até ligar de novo.
for p in $(pgrep -f "cloudflared tunnel --url http://127.0.0.1:8787"); do kill "$p"; done
for p in $(pgrep -f "wrangler dev --port 8787"); do kill "$p"; done
for p in $(pgrep -f "workerd serve"); do kill "$p"; done
echo "desligado"
