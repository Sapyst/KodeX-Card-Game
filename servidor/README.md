# Servidor do KodeX (Cloudflare Worker + D1)

Fonte da verdade da economia (moedas, Koins, Essência, boosters, coleção, versos, prêmios com teto diário) e save na
nuvem com conta anônima. Sem servidor configurado, o jogo funciona offline como antes.

## No ar pelo PC (agora)
Serviço do usuário `kodex-servidor` (systemd --user) roda `vigia.sh`: sobe o Worker local, abre o túnel da Cloudflare,
publica o endereço em `servidor.json`, religa o que cair (verifica a cada 60 s) e faz backup diário em `backups/`.
```bash
systemctl --user status kodex-servidor     # ver
systemctl --user restart kodex-servidor    # religar
./desligar.sh                              # desligar tudo (e: systemctl --user disable kodex-servidor)
```
Logs em `logs/` (vigia, servidor, túnel). Email de verdade: `.dev.vars` com RESEND_KEY e REMETENTE.

## Rodar no PC (sem conta Cloudflare)
```bash
npm install
npx wrangler d1 execute kodex --local --file=schema.sql
npx wrangler dev --port 8787 --ip 127.0.0.1
```
No jogo (testes): `GD_SERVIDOR=http://127.0.0.1:8787`. Dados locais ficam em `.wrangler/` (fora do git).

## Publicar (depois de `npx wrangler login`)
```bash
npx wrangler d1 create kodex            # copie o database_id para wrangler.toml
npx wrangler d1 execute kodex --remote --file=schema.sql
npx wrangler d1 export kodex --local --output=backup.sql && npx wrangler d1 execute kodex --remote --file=backup.sql   # leva os dados do PC
npx wrangler deploy
```
Depois, publique `servidor.json` na raiz do repositório com `{"url": "https://..."}`: o jogo lê esse endereço ao abrir.

`gerar_dados.py` atualiza `src/dados.js` (cartas, foils, preços dos versos, versões) a partir do jogo.
