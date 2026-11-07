# Levantamento 2 — online, efeitos, telas e QoL (07/11/2026)

Continuação de `levantamento_2026-11.md` (13 blocos feitos, v0.20.11 → v0.20.23). Só itens novos.
Esforço: P (horas), M (meio dia a 1 dia), G (mais).

## 0. Bug urgente
- **Opções não são lidas ao abrir o jogo.** Em `godot/sessao.gd:106-120`, texto grande, tempo por turno, daltônico, velocidade, confirmar FIM e RÁPIDO ficaram recuados dentro de `if OS.get_environment("GD_CANHOTO") != ""`. Fora do teste, tudo volta ao padrão a cada reinício. Entrou na v0.20.20 (faf5ba0). Tirar um nível de recuo. **P**

## 1. Online
Arquitetura boa (juiz no Durable Object, economia no servidor, conta anônima com segredo de 256 bits). Aguenta ~100 jogadores/dia jogando online e ~1.000–1.500/dia no resto, no plano grátis.

### Precisa agora
1. **Vitória forjada**: `POST /v1/partida/<pid>/fim` e `/acao` seguem abertos em partida com juiz (`servidor/src/multi.js:220-255`); quem chama primeiro decide o vencedor, paga prêmio e conta no ranking. Recusar quando a partida tem juiz. **P** (conferido)
2. **Deck online sem regra de cópias**: `deckValido` só confere 32 ids existentes (`multi.js:46`). Aplicar a regra de `aplicarLivres` (`index.js:286-290`). **P** (conferido)
3. **Conta nova com perfil forjado**: `importarLocal` aceita 5000 moedas, 2000 Koins/Essência, 10 boosters, coleção completa (`index.js:404-422`); o próprio jogo cria conta nova levando o perfil local ao receber 401 (`nuvem.gd:89-94`). Desligar a importação ou zerar a economia importada. **P** (conferido)
4. **UPDATE das fotos regrava partidas antigas a cada partida nova** (`multi.js:52`): acrescentar `AND foto0 IS NOT NULL` + índice em `criado`. Pode esgotar as 100 mil escritas/dia do D1 com ~3 mil partidas guardadas (inferência; conferir `meta.rows_written`). **P**
5. **Leituras sem índice** (ranking varre `partidas` 3×, `sala/entrar` por `codigo`, `/v1/perfil` em `emails`/`kodes`, cron em `perfis`) e tabelas que só crescem (`partidas`, `acoes`, `limites`, `fila`, `codigos`, `erros`). Índices + limpeza no cron. **P**
6. **Backup**: o último é de 22/10; `vigia.sh` exporta só o banco local. `schema.sql` desatualizado (sem `diario` e `titulo`). Export remoto semanal + `wrangler d1 migrations`. **P**
7. **Sem observabilidade**: ligar `[observability]` no `wrangler.toml` e `console.error` nos 500. **P**
8. **Sem limite por conta**: um script em loop esgota as 100 mil requisições/dia da conta inteira. Rate limit por id. **M**

### Quando crescer
9. Durable Objects no grátis: ~170–190 partidas/dia. Ping com `setWebSocketAutoResponse` deixa a sala hibernar; menos escritas por entrada. Plano pago de 5 dólares/mês resolve. **P**
10. `/v1/op` e `/v1/livre` em paralelo regravam o perfil inteiro sem versão: booster pode sumir. `UPDATE … WHERE rev=?`. **M**
11. `servidor.json` no GitHub é ponto único de falha e de confiança: URL fixa no APK, arquivo só como troca, domínios conhecidos. **P**
12. Sem versão mínima de cliente; deploy de `regras.js` muda partidas em andamento. Versão no pedido + "atualize". **M**
13. Prêmios autodeclarados (~1.500 moedas e ~10 boosters/dia forjáveis abaixo do sinal da moderação). Aceito pelo design. **G**
14. Menores: storage da sala nunca apagado; `/v1/apagar` não apaga `diario`, `sinais`, `notas`, `vistos` (LGPD); 20 contas/IP atrapalha CGNAT; 3.15 (lobby WS) sobe junto com o item 5.

## 2. Efeitos
Golpe, morte, Selo revelado e Lendária têm peso. Faltam origem dos efeitos e os dois grandes momentos.
1. **Raio origem → alvo só existe para dano.** Cura, buff, congelar, silenciar, destruir, devolver e dominar só mostram anel e texto no alvo. `motor_efeitos.gd:688` → `_feixe(fonte, alvo, cor)`. **P**
2. **Choronzon entra sem a entrada de Lendária** (`motor_efeitos.gd:998` → `_entrada_lendaria`). **P**
3. **Textos empilhados na troca de turno** ("CURA 2", "FIM DO TURNO", "TURNO DELE" no mesmo lugar; print conferido). Faixa de turno própria (`mesa.gd:2045`). **M**
4. Com RÁPIDO × velocidade 2×, textos vivem 0,2 s. Vida mínima ~0,6 s real (`efeitos.gd:137`). **P**
5. **Sem opção "Reduzir efeitos"**: piscada branca a cada ataque (`mesa.gd:1454`) passa de 3/s em turno rápido; tremor até ~13 px. Tremor ×0,3 e piscadas ≤ 2/s. **M**
6. Ataque do oponente sem mira prévia (0,25 s de anel/seta, `mesa.gd:1418`); Relíquia dele sem a carta grande no centro. **P**
7. Sem som: give_keyword, set_stats, dominar (Dantalion), destruir Relíquia; set_stats para baixo aparece dourado (Circe). **P**
8. Uso de Relíquia sem pulso "USOS n" (`motor_efeitos.gd:432`); sacrifício sem ligação visual com a carta que entra (`mesa.gd:2752`). **P**
9. Golpe final sem câmera lenta; tremores sobrescrevem em vez de pegar o maior (`mesa.gd:1548, 2184`); golpe direto limitar a ~6. **P**

## 3. Telas em 7 formatos (720×1280, 720×1520, 720×1600, 720×1680, 768×1024, 1024×768, 1280×720)
Nada cortado nem sobreposto; a mesa se adapta bem em todos. Tablet e paisagem (trilho lateral) corretos.
1. **Celular comprido (19,5:9 a 21:9, a maioria dos aparelhos atuais): menus ficam presos aos 640 de cima** e deixam 20–35% vazio acima da barra de abas. Afeta Início, Decks, Editor de deck, Loja, Cosméticos, Opções, Solo, Arcade, Modo livre, Desafio do dia, Peregrinação, Online, Sincronizar conta, Progresso, Lendários. Só Coleção e Perfil usam a altura. **M**
   - Botões de rodapé (Novo deck/Sugerido/Importar, Voltar, Usar este deck) devem colar na base (`alt_util`), como já fazem em 9:16.
   - Grades (editor de deck, Lendários, Enigmas, Cosméticos) crescem em linhas; listas (Solo, Opções, Online) ganham espaçamento ou centralizam.
2. A área segura (câmera/notch) não foi testada: no PC ela é a tela inteira. Conferir num celular com furo de câmera. —

Prints: `scratchpad/telas/folha_0..6.png` (sessão de 07/11; temporário).

## 4. QoL novo
1. **Partida solo não sobrevive ao app fechado**: o Android mata o app em segundo plano e a partida do Torneio/Peregrinação/Arcade some. Salvar o estado ao pausar (`NOTIFICATION_APPLICATION_PAUSED`) e oferecer "Continuar partida". **M**
2. Opção "Reduzir efeitos" (item 2.5). **M**
3. Online: aviso "atualize o jogo" quando a versão for antiga (item 1.12). **M**

## Ordem sugerida
1. Bug das opções (0) + falhas do online 1.1–1.3 → release e deploy.
2. Online 1.4–1.7 (índices, limpeza, backup, logs) → deploy.
3. Efeitos 2.1–2.4 e 2.6–2.9 → release.
4. Menus em tela comprida (3.1) → release.
5. Reduzir efeitos (2.5) + continuar partida solo (4.1).

## Andamento
- **Bloco 1 (bug das opções + trapaças do online)**: feito na v0.20.24-alpha (07/11/2026) — 0 (opções lidas fora do bloco de teste do canhoto), 1.1 (`/fim` e `/acao` recusam partida com juiz: 409), 1.2 (`deckValido` confere cópias da coleção; `DECKS_LIVRES_TESTE=1` só no `.dev.vars` para os testes com decks temáticos), 1.3 (`importarLocal` só traz campos livres; o jogo adota o perfil completo do servidor e reenvia os prêmios offline pendentes). Teste novo: `servidor/teste/seguranca_teste.mjs` (rodar com `--var DECKS_LIVRES_TESTE:0`). `progresso_teste.mjs` voltou a achar `dados.js` após a mudança de pasta.
