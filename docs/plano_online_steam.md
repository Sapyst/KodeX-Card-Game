# Online: hoje (alpha) e na Steam (13/11/2026)

## Hoje: tudo pela Cloudflare
O jogo roda no Android (APK) e no navegador (site). Os dois só se encontram por um servidor no meio: celular e navegador
não abrem conexão direta um com o outro sem peças extras (WebRTC no Android exige plugin; uma parte das redes ainda
precisa de um servidor de retransmissão pago). Por isso, enquanto o jogo estiver em alpha:

| Modo | Onde | Juiz | Ranking | Moedas | Limite |
|---|---|---|---|---|---|
| Buscar partida (ranqueada) | Cloudflare | sala (Durable Object) | sim | 20 / 5 / 10 | 30 por dia |
| Sala com código (casual, com amigo) | Cloudflare | sala (Durable Object) | não | não | — |
| Contra bot | no aparelho | — | não | teto do bot | — |

A casual usa o mesmo juiz: com a sala dormindo entre as jogadas, uma partida casual custa frações de centavo, e o jogo
segue sem trapaça possível (ninguém vê a mão do outro).

## Na Steam: casual por P2P, ranqueada continua no juiz
- **Casual com amigo**: conexão pela Steam (Steamworks Networking / Datagram Relay, grátis para quem publica). Um dos
  dois aparelhos (quem cria a sala) faz o papel de juiz: roda o motor, guarda os decks e manda a cada lado só o que ele
  pode ver — o mesmo formato de mensagens da sala de hoje (`a`, `r`, `eu`, `fim`, `pedido`, `presenca`). Quem cria a
  sala poderia espiar a mão do amigo com um jogo modificado; entre amigos, sem ranking nem prêmio, isso é aceitável.
- **Ranqueada**: continua na Cloudflare. A conta da Steam entra com o bilhete de autenticação (`GetAuthTicketForWebApi`),
  conferido pelo servidor — uma conta por cópia do jogo, o que afasta contas falsas.
- O que precisa para isso: o motor do juiz em GDScript (hoje ele existe em `servidor/src/motor/regras.js`, espelho do
  jogo) ou rodar o juiz do jogo dentro do anfitrião; trocar o transporte em `rede_partida.gd` (WebSocket → Steam) sem
  mudar o resto da mesa.

## Custo (Cloudflare, preços conferidos em 13/11/2026)
Plano grátis até ~100 jogadores online/dia; plano pago de US$ 5/mês até ~2 mil/dia; ~10 mil/dia ≈ US$ 60–90/mês com
as otimizações da v0.20.27 (antes ≈ US$ 600). Detalhes em `levantamento_2026-11-07.md` → Andamento.
