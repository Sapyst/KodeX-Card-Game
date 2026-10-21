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

## Multiplayer (src/multi.js)
Fila de busca (país → continente após 5 s → mundo após 15 s), aceitar/recusar (12 s), sala por código de 4 letras e
partida em passo travado: o servidor só guarda e repassa as ações em ordem (`acoes`, seq), com long-poll de até 20 s.
2 min sem contato de um lado = vitória do outro. Revanche: os dois pedem → nova partida com os mesmos decks.
Teste: `node teste/multi_teste.mjs` (servidor local ligado).
**Ao migrar para a Cloudflare:** o long-poll consulta o D1 a cada 0,25–0,5 s; no plano grátis (10 ms de CPU por pedido)
pode estourar. Se acontecer, trocar o long-poll por Durable Objects (uma sala por partida, WebSocket) ou encurtar a espera.
