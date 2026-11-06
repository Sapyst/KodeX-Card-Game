# Levantamento — código, netcode e QoL (06/11/2026)

Revisão só de leitura da v0.20.10-alpha. Nada foi alterado. Cada item cita arquivo:linha para conferência.
Marcados com ✔ os que confirmei pessoalmente lendo o código; os demais vieram da revisão por agentes e
precisam de uma conferida rápida antes de corrigir.

Esforço: **P** até 1 h · **M** meio dia · **G** 1 dia ou mais.

---

## 1. Bugs graves (corrigir primeiro)

| # | Bug | Onde | Esforço |
|---|-----|------|---------|
| ✔ 1.1 | **Online: resultado do juiz sobrescrito.** Com juiz o cliente nunca chama `GET /v1/partida` durante o jogo (só WebSocket), então `contato0/1` ficam no horário do início. Depois de 2 min, "Voltar à partida" (`menu_online.gd:297`) ou o pedido de revanche (`mesa.gd:4325`) caem no bloco de queda de `multi.js:86-90`, gravam `vencedor = quem chamou` e ainda marcam o outro como abandono na moderação. `gravarResultado` (`sala.js:190`) só escreve se `vencedor < 0`, então o resultado real é descartado. | `multi.js:86` pular o bloco quando `p.juiz`; a sala é a fonte de verdade | P |
| ✔ 1.2 | **4 Relíquias "quando a portadora morrer" nunca disparam.** `morrer()` chama `_destruir` → `resetar()` → `reliquia = {}` antes de `disparar_efeitos_reliquia`, cuja guarda `is_same(port.reliquia, rel)` sai. Afeta Trishula, Sigillum Dei Aemeth, Maracá do Pajé, Caldeirão de Renascimento. **O juiz tem o mesmo bug** (`regras.js:768-770`, `destruirVisual` → `resetar`). | `motor_efeitos.gd:549-563` + `regras.js:766-772`: disparar antes de resetar ou ignorar a guarda em `equipped_dies` | P (dois lados) |
| 1.3 | **Alvo "escolhido" de gatilhos resolve sozinho para o humano.** `ctx.interativo` só é setado em jogar Entidade/Rito/Relíquia; `on_attack`, `on_death`, `end_turn`, Selos e `revive/bounce` caem em `ia_alvo`. ~14 cartas (Davi, Arjuna, Funda, Sudarshana, Anel de Salomão, He Xiangu, Sapo Familiar, Tumba Vazia, Pássaro Vermelho, Roda do Samsara, Solve et Coagula, Véu de Maya…). | `motor_efeitos.gd:306-324`; online exige o juiz pedir `esc` nos mesmos pontos | M (dois lados) |
| 1.4 | **`set_stats` apaga o bônus da Relíquia sem tirá-la** (Vishvarupa/Circe numa portadora equipada: faixa continua, +ATK sumiu). | `motor_efeitos.gd:784-788`, `carta.gd:575-578` | P |
| 1.5 | **Mercador da Peregrinação não avança a parada** → trocas infinitas. | `modos_solo.gd:235-237` | P |
| 1.6 | **Prêmio do Torneio de 8 se perde** se o app fechar durante a animação da chave (`ta_pagar` só dentro do timer). | `torneio_arcade.gd:827-838`, `fluxo.gd:698-712` | P |
| 1.7 | **Presente de versão (+30 Koins/+50 ouro) pode se perder**: abrir o pergaminho pela bolinha grava `versao_vista` sem premiar. | `fluxo.gd:752-777`, `sessao.gd:905-907` | P |
| 1.8 | **Voltar do Android na busca online** deixa laços rodando; partida pode começar sozinha do Início. | `menu_online.gd:65-68,150-155,196-215`, `fluxo.gd:1775` | P |
| 1.9 | **Deck incompleto entra em partida** em Desafios lendários, Choronzon e Torneio de 8 continuado. | `modos_solo.gd:508,622`, `sessao.gd:1139` | P |
| 1.10 | **Bênçãos dos modos solo somem** no primeiro `resetar`/`definir` (bounce, Renascer, reembaralhar). | `mesa.gd:3811-3817`, `carta.gd:548,585` | P |

## 2. Bugs menores e robustez

- 2.1 Voltar do Android pula a criação do perfil (nome vazio no online) — `fluxo.gd:527-540`.
- 2.2 Compra dupla de booster durante a espera do servidor — `booster.gd:53-75`.
- 2.3 Save antigo sem `"foils"` quebra a Coleção; `adotar_servidor` apaga chaves que o servidor não mandou — `sessao.gd:535-548,600`.
- 2.4 `perfil.json` antigo apagado sem ter sido migrado quando o save novo está corrompido — `sessao.gd:528-555`.
- 2.5 Missões diárias farmáveis offline mudando o relógio — `progresso.gd:60-64,336`.
- 2.6 Excluir o deck em uso torna "EM USO" o vizinho, mesmo deck livre — `menu_perfil.gd:1234`.
- 2.7 Congelada no próprio turno (Ímpeto/Krishna) mostra gelo mas ataca — `motor_efeitos.gd:771`, `carta.gd:194`.
- 2.8 Limite de 7 na mão ignorado por bounce/revive até o fim do turno do dono — `mesa.gd:2167`.
- 2.9 `_encerrar` não solta `await alvo_tocado`/`escolhido` (trava latente se a mesa for reaproveitada) — `mesa.gd:1976`.
- 2.10 Keyword dada por `on_equip` não sai com a Relíquia (latente) — `motor_efeitos.gd:777`.
- 2.11 Revive/token sem espaço: nada acontece e nada avisa — `motor_efeitos.gd:859,877`.
- 2.12 Status da conta escondido atrás do botão "Sincronizar conta" — `fluxo.gd:2174` × `510`.
- 2.13 Contagem "até amanhã" falsa sem hora sincronizada — `menu_progresso.gd:496`.

## 3. Netcode

### Como está (bom)
Um WebSocket por jogador até o Durable Object da sala; o celular manda intenções de 40–80 bytes e **anima na hora** (predição local); só espera o juiz em compras, sorteios e retrato do turno, que o juiz já empurra no mesmo tick. Sequência por jogador, idempotência por `n`, reenvio desde `desde` ao reconectar. O caminho quente não precisa mudar; os problemas estão nas bordas.

### Melhorias (impacto × esforço)
| # | O quê | Onde | Esf. |
|---|-------|------|------|
| 3.1 | **Espera de 100–115 s por oponente morto.** Servidor `PRAZO_ACAO = 100` vs 75 no cliente, alarme fixo de 15 s. → 80 s e alarme = `min(15 s, prazo restante)`. | `sala.js:53,239-242` | P |
| 3.2 | **"SEM SINAL" nunca aparece**: `op_ausente` existe mas nunca é atualizado; a sala não manda presença. → `{t:"presenca"}` no alarme e em `webSocketClose`. | `rede_partida.gd:29`, `sala.js:309` | P |
| 3.3 | **Cliente nunca manda `ping`**: socket morto em segundo plano/troca wifi→4G só é detectado quando o TCP expira (30–60 s+). → ping a cada 10 s, sem pong em 5 s fecha e reabre. | `rede_partida.gd:63`, `sala.js:304` | P |
| 3.4 | **Rejeição do juiz sem rollback** → dessincronia silenciosa até o próximo `r:turno`. → em `{t:"erro"}` disparar o caminho de retomar (já existe). | `rede_partida.gd:101`, `sala.js:221-229` | M |
| 3.5 | **Relógio do oponente é cosmético**: reinicia 75 s quando eu começo a aplicar o turno dele; `pedido` do servidor chega e é ignorado. → mandar `desde/prazo` no `pedido` e usar. | `mesa.gd:4138`, `rede_partida.gd:95`, `sala.js:184` | M |
| 3.6 | Mulligan 40 s no servidor vs 25 s no cliente → 28–30 s. | `sala.js:55`, `mesa.gd:4627` | P |
| 3.7 | `aceitar` regrava **todas** as entradas a cada jogada (O(n)). → `put("e"+idx)`. | `sala.js:208` | P |
| 3.8 | Eco `eu` carrega a mão inteira e o cliente não usa. | `sala.js:163` | P |
| 3.9 | Reconexão fixa a cada 1,5 s = 2 SELECTs no D1 por tentativa. → backoff 1,5→3→6→10 s. | `rede_partida.gd:76`, `index.js:347-353` | P |
| 3.10 | `alarm()` sem try/finally: uma exceção quebra a cadeia e a sala nunca mais força nada. | `sala.js:202` | P |
| 3.11 | Retomar sem timeout (`_retomando` eterno se não vier `pronto`). | `rede_partida.gd:42-44` | P |
| 3.12 | Dois aparelhos da mesma conta na mesma sala → `n` conflitante. | `sala.js getWebSockets("j"+j)` | P |
| 3.13 | Revanche: `POST /revanche` pode chegar antes de `gravarResultado` (409). | `multi.js:550` | P |
| 3.14 | `revelacao(tipo)` fora de ordem devolve a errada e só avisa. | `rede_partida.gd:179` | P |
| 3.15 | Matchmaking por long-poll em D1 (40–60 queries/10 s por jogador na fila). → DO "Lobby" com WS. Só se a fila crescer. | `multi.js:443-455` | G |

### Segurança leve
Forjar ações: coberto (juiz valida mão, Fé, alvos). Mão do oponente: coberta. Falta: limite de tamanho de mensagem no WS (`sala.js:294`), throttle de emote (1/s), cortar após N erros, `?auth=` na URL do WS vai para logs de proxy (mandar no primeiro frame).

## 4. Incongruências e duplicações
- Quatro caminhos para dano na Cornucópia (só `dano_cornucopia` tem som/tremor coerentes) — `motor_efeitos.gd:515`, `mesa.gd:1550,2022,2051`.
- Dois predicados de ataque (`motor.pode_atacar` × `mesa._pode_atacar`) — `motor_efeitos.gd:75`, `mesa.gd:2761`.
- Dano de combate não chama `marcar("dano")`; dano de efeito chama — feedback diferente.
- `_canon_estado` e `_canon_publico` duplicam o bloco da Entidade (toda flag nova vai em 3 lugares, contando o juiz).
- Arcade "Seu deck" lido uma vez em `_ready`; `usar_deck` não atualiza — `fluxo.gd:271`.
- "Desistir" do Torneio de 8 não confirma; Peregrinação e Recomeçar confirmam.
- Booster: "Concluir" pergunta sobre trocar repetidas; "Abrir outro" troca sem perguntar — `fluxo.gd:596-612`.
- Tela "Histórico" (totais por modo, mais enfrentado) ficou inalcançável depois do perfil novo — `historico.gd:361-386`.
- Moedas mostradas diferentes por tela (Início ouro+Koins, Loja só ouro, Cosméticos só Koins, Coleção só Essência).
- Essência não é explicada em lugar nenhum.
- Pagamento do Arcade no menu, bot/online na mesa: fechar na tela de resultado perde o prêmio arcade.
- Hash de fim de turno é código morto (`mesa.gd:4064,4149`).

## 5. Localização
- Todas as 761 chaves `Sessao.t()` existem no JSON. Faltam só **erros do servidor** mostrados com `Sessao.t(e)`: "muitas contas criadas hoje nesta conexão", "muitas tentativas…", "conta suspensa", "versões diferentes do jogo", "partida não encontrada", "partida encerrada", "Koins insuficientes" (sem ponto), "essência insuficiente", "não dá para criar/desfazer/trocar", "já tem".
- `CAMINHOS` da Peregrinação sem ES — `modos_solo.gd:23-28`.
- ES = PT em "Cada turno tem 75 segundos." e "Taoismo" (ES: Taoísmo).
- Abas truncadas a 3 letras viram "Hig", "Wit", "Chr" em EN — usar siglas fixas.
- Números de XP fixos no texto em vez de vir de `progressao.json` — `menu_progresso.gd:560`.

## 6. Desempenho (celular fraco)
- `Carta._process` → `queue_redraw()` em toda carta, todo quadro, inclusive as ~64 do deck viradas; `_verso` ≈ 200 `draw_rect`. → flag suja + não processar `empilhada`. **M**
- `mesa._process`: `placar.queue_redraw()` e `pilha_cem.queue_redraw()` todo quadro; `_ret_layout` mede texto 2× por lado por quadro. **P**
- `efeitos._process`: seis `Array.filter` alocando por quadro. **P**
- IA Arquimago: 24 permutações × 5⁴ folhas com `duplicate()`+`sort_custom`, refeito até 60× por turno, síncrono → engasgo por ação. → memoizar por estado. **M**
- `_desenhar_tabuleiro`: ~51 mil `draw_rect` por redraw. → cozinhar numa textura. **P**
- Menores: `RandomNumberGenerator.new()` por quadro em `_rachar`; `tocar_som` faz `load()` por chamada; popups medem texto por quadro.

## 7. Qualidade de vida — mesa
1. Palavras-chave sem explicação no toque longo (Despertar, Último Sopro, Sacrifício, Usos nem aparecem) — `efeitos.gd _painel_carta`. **P**
2. Contadores escondidos: cartas no deck (fadiga!), mão do oponente, número do turno. **P**
3. FIM TURNO com Fé/ataques sobrando: pedir 2º toque ("FÉ 3 · 1 ATAQUE"), desligável. **P**
4. Prévia só para ataque de Entidade; nada para Rito de dano, golpe de Rito, Relíquia. **M**
5. Segurar 0,4 s parado abre o zoom e cancela o arraste — quem hesita perde a jogada. → 0,7 s ou só no leque. **P**
6. Histórico de 6 jogadas sem turno; toque longo abrir o log inteiro. **P**
7. Velocidade 1×/1,5×/2× e RÁPIDO que lembra a escolha (hoje reseta por turno). **P**
8. "DE NOVO" no resumo offline (mesmo oponente/nível). **P**
9. Tempo por turno contra IA: 45/75/120/sem limite. **P**
10. Desistir dizendo o que se perde (Peregrinação acaba, tentativa do dia). **P**
11. Buff temporário indistinguível do permanente nas medalhas. **P**
12. Reembaralhar: dizer quantas cartas voltam; tempo esgotado responde "NÃO (-2)" sem aviso. **P**
13. Turno do oponente longo: vitrine 1,0 s por carta → 0,6 s quando já vista. **P**
14. Recusa muda ao atacar área vazia com defensores; "SEM ESPAÇO" em revive/token; "aguarde" ao tocar FIM durante animação. **P**
15. Mostrar "ALVO: X" quando a escolha for automática (enquanto 1.3 não for feito). **P**

## 8. Qualidade de vida — menus
1. **Montar deck é lento** (toque → visor → + ADICIONAR → fechar). → toque adiciona/tira, toque longo abre o visor. **P**
2. Editor de deck sem filtros de tipo/custo/busca (a Coleção já tem) nem ordenação. **P**
3. Contador por tipo sem o alvo (ENT 11/14 · SELO 6/6 …). **P**
4. "Texto grande" não alcança botões, missões, histórico, subtítulos do Solo, prévia na mesa. **M**
5. Alvos de toque pequenos (filtros 18 px, abas 22 px, "trocar" 16 px) → mínimo 32 px. **P**
6. Opções: toggles refazem a tela inteira (botões caem de novo); idioma cicla em vez de tocar na sigla; agrupar Jogo/Acessibilidade/Conta. **P**
7. Sem feedback de espera em rede (booster, presente, Kode): estado "aguardando" com botão desabilitado (resolve 2.2). **P**
8. "NOVA" só some tocando carta por carta; limpar ao rolar para a tela. **P**
9. Tutorial não é oferecido na 1ª vez; não cobre mulligan, cemitério, fadiga. → caixa "Primeira vez?" + Lição 2 opcional. **P/M**
10. Primeira derrota sem orientação: "Ver a dica" com base em `estat`. **P**
11. Importar código sem prévia (quantas faltam, lista). **P**
12. Deck ativo não visível/trocável em Online e Solo. **P**
13. Perfil: permitir 1 troca de nome ou confirmar antes de "Começar". **P**
14. Trazer de volta os totais por modo e "mais enfrentado" para a página do perfil. **P**

## 9. Progressão, economia e online
1. Títulos só aparecem no próprio perfil: mandar junto ao nome e mostrar na moldura da mesa. **P**
2. Koins sem destino após 9 versos (~20 semanas): molduras de retrato por tradição (200), emotes extras (150). **M**
3. Missões: progresso no resumo da partida ("Lance 5 Ritos 3/5") + 8 diárias com verbos novos. **P**
4. Sequência de dias ("DIA 4/7") sob o botão de presente; aviso no 6º dia. **P**
5. Maestria no resumo mesmo sem subir nível ("+30 Taoismo 420/600"). **P**
6. Repetida: 3º destino "Essência +n" no booster. **P**
7. Online: fila visível ("3 na fila"), bot aos 10 s se fila vazia, botão fixo "Jogar contra bot". **P**
8. Sala por código: botão Copiar/Compartilhar. **P**
9. "Desafiar" na linha do histórico online (convite pelo correio existente) — primeiro passo para amigos. **G**
10. Ranking semanal de vitórias online (top 50 + posição), prêmio só cosmético. **M**
11. Canhoto: espelhar FIM TURNO, menu/emote, deck/cemitério. **M**
12. Daltonismo fora da mesa: letra junto da cor no histórico, raridade, missões. **P**
13. Volume em 3 níveis e vibração forte/leve. **P**

## 10. Conteúdo barato (reaproveita o que existe)
- Desafio do dia com placar ("você 9 turnos · melhor 6 · 312 venceram"). **M**
- Enigma da semana sorteado de um pool de 20. **P**
- Arcade com modificador do dia (reusa Bênçãos). **P**
- Peregrinação do dia (semente comum, 1 tentativa, 40 moedas). **P**
- Desafios lendários invertidos (jogar *com* a Lendária; 12 vitórias = título "Portador"). **P**
- Torneio de 8 semanal com chave igual para todos. **P**

---

## Andamento
- **Bloco 1 (bugs graves)**: feito na v0.20.11-alpha (06/11/2026) — 1.1, 1.2, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 1.10 e 2.1.
- **Bloco 2 (netcode de borda)**: feito na v0.20.12-alpha (06/11/2026) — 3.1, 3.2, 3.3, 3.5, 3.6, 3.9, 3.10, 3.11, limites de mensagem/emote. Ficam: 3.4 (rollback via retomar), 3.7, 3.8, 3.12, 3.13, 3.14, 3.15.
- **Bloco 3 (alvo escolhido pelo humano, 1.3)**: feito na v0.20.13-alpha (06/11/2026), jogo e juiz; 14 cartas.
- **Bloco 4 (QoL mesa e menus)**: feito na v0.20.14-alpha (06/11/2026) — 7.1, 7.2, 7.3, 7.5, 7.7, 8.1, 8.2, 8.5, 8.7 (e 2.2). Fica 7.3 só contra IA e online igual; 8.3, 8.4, 8.6 e o resto de 7/8 para os próximos blocos.
- **Bloco 5 (desempenho)**: feito na v0.20.15-alpha (06/11/2026) — carta redesenha só quando muda (chave visual + animadas), piso em ladrilho, verso simplificado nas cobertas, pilha/retratos em cache, filtros dos efeitos só quando há algo, plano do Arquimago memoizado por estado, RNG das rachaduras reaproveitado. Medido com `GD_PERF=1` em xvfb/llvmpipe (partida IA×IA): ~85 ms → ~30 ms por quadro, pico 147 → 55 ms, objetos por quadro 65 mil → 4–8 mil. Fica: faces das cartas em textura (a fonte pixel ainda desenha glifo a glifo), popups medindo texto por quadro.
- **Bloco 6 (texto grande nos menus, 8.4)**: feito na v0.20.16-alpha (06/11/2026) — `Fonte57.fator` (×1,35 com a opção ligada) aplicado a todo texto de interface em esc 1 (largura/desenhar/quebrar), prévia da mesa em 2×, botões das Opções mais largos e Histórico com linhas afastadas. Conferido em 24 telas por print.
- **Bloco 7 (bugs menores, seção 2)**: feito na v0.20.17-alpha (06/11/2026) — 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9, 2.10, 2.11, 2.13 (2.12 já saiu com o bloco 6). Regras espelhadas no juiz (`servidor/src/motor/regras.js`): congelar na vez do dono, limite de mão ao voltar para a mão, palavra-chave da Relíquia.
- **Bloco 8 (resto do QoL, seções 7 e 8)**: feito na v0.20.18-alpha (06/11/2026) — 7.4 (Rito de dano e Relíquia), 7.6, 7.8 (Arcade e Modo livre), 7.9, 7.10, 7.11, 7.12, 7.13, 7.14, 8.6, 8.8, 8.9 (caixa "Primeira vez?"; a Lição 2 do tutorial fica para depois), 8.10, 8.11, 8.12, 8.13, 8.14. 7.15 ficou sem sentido com o 1.3 feito; 8.3 já estava feito desde o bloco 4.
- **Bloco 9 (netcode restante)**: feito na v0.20.19-alpha (06/11/2026) — 3.4 (rejeição do juiz e retrato divergente → ressincroniza pelo retomar; `GD_SEM_RESSINC=1` só marca), 3.7 (`in:NNNNNN` por entrada), 3.8 (eco sem a mão), 3.12 (um socket por lado: fecha o anterior com 4001; o celular volta ao menu), 3.13 (revanche pergunta à sala se o D1 ainda não tem o fim), 3.14 (revelação casada pelo tipo, espera até 3 s). Ficam: 3.15 (lobby por WS, só se a fila crescer) e `?auth=` no 1º frame (exige compatibilidade com clientes antigos).
- **Bloco 10 (progressão e online, seção 9)**: feito na v0.20.20-alpha (06/11/2026) — 9.1 (título na fila/partidas: `migracao_titulos.sql`), 9.3 (missões no resumo + 8 diárias novas no fim de `progressao.json`), 9.4, 9.5, 9.6 (Essência pelo `desfazer` já existente), 9.7 (`fila` no estado da busca, bot aos 10 s se vazia, botão fixo), 9.8, 9.10 (`GET /v1/mm/ranking`, últimos 7 dias, sem prêmio), 9.11 (`Sessao.canhoto`; `GD_CANHOTO=1` em teste), 9.13. 9.12 já estava coberto (letras V/D no histórico, sigla de raridade, "feita" nas missões). Ficam: 9.2 (molduras/emotes por Koins: precisa de arte), 9.9 (desafiar amigo), toda a seção 10 (conteúdo).
- **Bloco 11 (conteúdo, seção 10)**: feito na v0.20.21-alpha (06/11/2026) — Desafio do dia com placar (tabela `diario`, `migracao_diario.sql`, `GET/POST /v1/diario`), Enigma da semana (sorteio pela semana entre os 12 existentes; o pool de 20 fica para quando houver enigmas novos), Arcade com modificador do dia (Bênção por `Progresso.hoje()`), Peregrinação do dia (`pere.dia`, RNG por parada, prêmio `pere_dia`), Lendários invertidos (`lendarios_inv`, prêmio `lendario_inv`, conquista/título `portador`), Torneio da semana (`novo_torneio_arcade(semana)`, `ta_semana`).
- **Bloco 12 (incongruências e localização, seções 4 e 5)**: feito na v0.20.22-alpha (06/11/2026) — 4: fadiga via `motor.dano_cornucopia` (golpe direto mantém os efeitos próprios), `_pode_atacar` usa `motor.pode_atacar`, `marcar("dano")` no combate, `_canon_entidade` compartilhado, Arcade acompanha `usar_deck`, Desistir do Torneio de 8 confirma, `_concluir_booster` em todos os botões, `_moedas_topo` em Loja/Cosméticos/Coleção, Essência explicada no toque, prêmio do Arcade pago na mesa. O hash do fim de turno não é código morto: o adversário compara (`a.h`) e dispara a ressincronização. Histórico: os totais voltaram ao perfil (8.14). 5: erros do servidor, CAMINHOS em ES, siglas fixas, XP de `progressao.json`. Também: arte das tradições dentro dos blocos (pedido de Sapyst).
- **Bloco 13 (Lição 2 do tutorial, resto do 8.9)**: feito na v0.20.23-alpha (06/11/2026) — `Tutorial.licao = 2` (`_rodar_licao2`, FALAS2 em PT/EN/ES): mulligan forçado (`_mulligan(true)`), cemitério com foco, deck cortado para 1 carta (`_cortar_deck`), fadiga com 5 de Cornucópia, reembaralhar com 10; item "Tutorial 2" no menu Início; `GD_TUTORIAL=2` e item na bateria ("TUTORIAL 2: fim, vencedor=0").

## Ordem sugerida (blocos de ~1 dia)
1. **Correções graves**: 1.1, 1.2 (dois lados), 1.5, 1.6, 1.7, 1.8, 1.9, 1.10, 1.4 → release.
2. **Netcode borda**: 3.1, 3.2, 3.3, 3.6, 3.10, 3.11, 3.9 → release; depois 3.4 e 3.5.
3. **Alvo escolhido pelo humano** (1.3, dois lados) — o maior em regras.
4. **QoL mesa** 7.1, 7.2, 7.3, 7.5, 7.7 + **menus** 8.1, 8.2, 8.5, 8.7.
5. **Desempenho** (6) — medir no celular antes.
6. **Texto grande** nos menus (8.4) — acessibilidade é prioridade declarada.
7. Progressão/online/conteúdo conforme escolha.
