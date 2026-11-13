#!/usr/bin/env bash
# Backup do banco online (D1 na Cloudflare) para servidor/backups/ (fora do git), guardando os 8 mais recentes.
# Uso: bash backup.sh          (precisa do login do wrangler neste PC)
# A Cloudflare também guarda o banco sozinha (Time Travel: volta a qualquer minuto dos últimos 7 dias no plano grátis,
# 30 no pago):  npx wrangler d1 time-travel restore kodex --timestamp=2026-11-13T12:00:00Z
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p backups
arq="backups/kodex-$(date +%Y-%m-%d_%H%M).sql"
npx wrangler d1 export kodex --remote --output "$arq"
gzip -9 "$arq"
echo "backup: $arq.gz ($(du -h "$arq.gz" | cut -f1))"
ls -1t backups/kodex-*.sql.gz 2>/dev/null | tail -n +9 | xargs -r rm --
