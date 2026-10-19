# Rodada 1 — análise de duelos (Analista)

Motor: `sim/engine.py` + `HeurBot`, 2000 duelos por confronto, seeds 11 e 12. Arquivos desta rodada em `sim/relatorios/`:
`r1_matriz.json` (seed 11), `r1_matriz_seed12.json`, `espelhos/<deck>.json|txt`, `log_*.txt` (primeiro duelo de 5 confrontos com `--log`), `r1_metricas.py` + `r1_metricas_saida.txt` (400 duelos por par com log, parseados para as métricas pedidas nas `_revisao.md`).

Metas da dupla (lembrete): média de cada deck em 42–58 %; confronto individual em 30–70 %; carta no espelho dentro de [deck−12, deck+12]; "ficou na mão" ≤ 35 %; quem começa ≤ 55 %; duração 7–14 rodadas.

---

## 1. Matriz (seed 11; seed 12 entre parênteses)

Linha vence coluna, em %.

| | alta_magia | bruxaria | cristianismo | hinduismo | indigena | taoismo | **média** |
|---|---|---|---|---|---|---|---|
| **alta_magia** | — | 26,8 (28,4) | 19,7 (20,5) | 4,6 (4,3) | 30,4 (32,0) | 15,6 (16,6) | **19,4 (20,4)** |
| **bruxaria** | 73,2 (71,5) | — | 33,4 (31,6) | 17,7 (18,3) | 55,2 (57,2) | 54,6 (53,3) | **46,8 (46,4)** |
| **cristianismo** | 80,3 (79,5) | 66,6 (68,4) | — | 27,5 (29,6) | 76,3 (75,8) | 60,8 (59,7) | **62,3 (62,6)** |
| **hinduismo** | 95,4 (95,7) | 82,3 (81,7) | 72,5 (70,3) | — | 83,2 (82,0) | 82,5 (83,2) | **83,2 (82,6)** |
| **indigena** | 69,6 (68,0) | 44,8 (42,8) | 23,6 (24,2) | 16,8 (17,9) | — | 41,9 (42,8) | **39,4 (39,1)** |
| **taoismo** | 84,5 (83,5) | 45,4 (46,7) | 39,2 (40,3) | 17,4 (16,8) | 58,1 (57,2) | — | **48,9 (48,9)** |

**Estabilidade:** nenhuma célula varia mais de 2,1 pp entre as seeds; médias por deck variam ≤ 1 pp. Com n = 2000 o erro-padrão de uma célula é ~1,1 pp — as cifras são confiáveis até ±2 pp.

**Contra as metas:** 2 decks na faixa 42–58 (taoismo, bruxaria); hinduismo e cristianismo acima, indígena e alta magia abaixo. **11 dos 15 confrontos** estão fora de 30–70 (todos os de hinduismo; todos os de alta magia menos vs. indígena; cristianismo × indígena; taoismo × alta magia; bruxaria × alta magia). Empates: 0 %.

### Duração e vantagem de quem começa (seed 11)

| Confronto | rodadas | 1º vence | | Confronto | rodadas | 1º vence |
|---|---|---|---|---|---|---|
| alta × bruxaria | 12,3 | 50,9 % | | cristianismo × indígena | **15,2** | 47,8 % |
| alta × cristianismo | 13,8 | 51,9 % | | cristianismo × taoismo | **14,4** | 48,6 % |
| alta × hinduismo | 8,3 | 52,2 % | | hinduismo × indígena | 10,5 | 53,6 % |
| alta × indígena | 12,7 | 55,7 % | | hinduismo × taoismo | 9,5 | 55,4 % |
| alta × taoismo | 11,8 | 53,8 % | | indígena × taoismo | 13,7 | 51,5 % |
| bruxaria × cristianismo | 13,5 | 47,3 % | | **espelhos:** indígena | **14,7** | 51,7 % |
| bruxaria × hinduismo | 9,6 | 52,0 % | | cristianismo | **16,2** | 46,2 % |
| bruxaria × indígena | 12,9 | 49,4 % | | taoismo | 12,9 | 51,9 % |
| bruxaria × taoismo | 12,0 | 50,5 % | | hinduismo | 8,1 | **66,2 %** |
| cristianismo × hinduismo | 10,8 | 52,8 % | | bruxaria | 11,6 | 48,1 % |
| | | | | alta_magia | 13,1 | **60,0 %** |

Vantagem de quem começa está ≤ 56 % em todos os confrontos cruzados (o +1 Fé do 2º jogador funciona). Fora da meta só nos espelhos de hinduismo (66 %: quem bate primeiro num campo vazio ganha a corrida) e alta magia (60 %). Duração: hinduismo encurta tudo para 8–10 rodadas; os espelhos de cristianismo e indígena e cristianismo × indígena/taoismo passam de 14 (muros de Guarda + cura + revive; 50–56 % dessas partidas passam de 14 rodadas).

### Espelhos — cartas fora da faixa (≥ 100 partidas jogadas; A e B somados)

| Deck | Carta | WR jogada | na mão | Nota |
|---|---|---|---|---|
| hinduismo | **Shiva Nataraja** | **71,9 %** | 18 % | fora de ±12 |
| hinduismo | Vajra / Gandiva / Sudarshana / Trishula | 53–59 % | **35–46 %** | partidas de 8 rodadas; 1 Relíquia por corpo e corpos morrem |
| hinduismo | Descida do Avatar / Vishvarupa / Tandava / Pashupatastra / Véu de Maya | 43–54 % | **36–52 %** | idem; Vishvarupa também sofre de artefato do bot (§4) |
| bruxaria | **Hécate** | **70,5 %** | 19 % | fora de ±12 |
| bruxaria | **Baba Yaga** | **62,9 %** | 14 % | fora de ±12 |
| bruxaria | A Morrigan / Cerridwen / Caldeirão | 60–61 % | — | no limite |
| alta_magia | **Dantalion** | **64,3 %** | 21 % | fora de ±12 |
| alta_magia | **Conjuração dos Elementais** | 41,9 % | **54 %** | em parte artefato do bot (§4) |
| cristianismo | São Miguel | 60,8 % | 2 % | no limite; Elias 58,5 %, Leviatã 56,5 % |
| indígena | **Dança do Aruanã** | **39,4 %** | 17 % | mais fraca do deck |
| taoismo | Xiwangmu | 58,5 % | — | nenhuma fora; Li Tieguai/Han Xiangzi 44 % |

---

## 2. Diagnóstico por deck

**Hinduismo (83 %).** Ganha a corrida: Garuda ×2 (2/1 Ímpeto, Despertar limpa um 1-de-Vida), Jatayu e Hanuman batem na Cornucópia desde a rodada 2 enquanto Yajna, Vajra (3 de dano por 2 Fé), Brahmastra (destrói + 2 em área: 1,6 mortes por jogada) e Kali esvaziam o campo inimigo. Dano de **ataque** à Cornucópia por partida: 14–17 contra 4–6 do adversário (`r1_metricas`); dano por efeito é só 1–2 (o teto de 5 de dano direto não é o problema). Tandava fecha quando a Cornucópia está em 3 (ver `log_hin_alt.txt`, `log_hin_tao.txt`: vitória na rodada 7–8 com 5–6 ataques livres à Cornucópia). Hanuman chega em média a ATK 5–6 (2–3 ataques); Shiva 6/6 Ímpeto + destroy é a carta mais forte do jogo (72 % no espelho, 86 % global). Krishna/Durga/Rama ficam em 50–52 % no espelho — não são o problema. Nada no deck fica na mão por ser ruim: ficam porque o jogo acaba antes.

**Cristianismo (62 %).** Atrito com Lendárias recicladas. Elias (2 em área + Renascer) e São Miguel (6/6 Guarda + destroy) têm 78–81 % global e 58–61 % no espelho; Tumba Vazia e Talita Cumi revivem **para o campo com Despertar** — contra indígena 0,44 Lendária revivida por partida (Miguel destrói de novo; Elias queima de novo). Leviatã (6/7 por 6 com Sacrifício) 76 % global. Juízo Final mata 1,4 inimigas por 1,0 própria e ainda devolve 1 à mão. Dano de ataque 15/partida contra 6,7 do indígena: as Guardas (Anjo, Serafim, Miguel, Arca) travam o atacante e o deck cristão ganha a troca lenta. Perde só para hinduismo (27 %), por não aguentar a corrida das rodadas 2–5. Davi + Funda: 0,2–0,3 mortes por jogada de Davi — irrelevante.

**Taoismo (49 %).** O único deck "no meio", mas por compensação: esmaga alta magia (84 %) e indígena (58 %), perde para hinduismo (17 %) e cristianismo (39 %). Perde para hinduismo porque os Imortais 1/x morrem para Garuda/Yajna antes de o Lü Dongbin/Imperador ligar a aura (ataques à Cornucópia sofridos: 4,3/partida; dano de ataque próprio 4,4). Xiwangmu 58,5 % no espelho; Pílula ×2 revive Lendária (Xiwangmu, que revive outra) em 0,23–0,34 partida — o laço que a revisão temia existe mas ainda não domina. He Xiangu 1/3 (47 %) e os dois Fulu (52 %, 13 % na mão) estão bem. Não mexer agora: deve subir sozinho quando hinduismo e cristianismo caírem.

**Bruxaria (47 %).** Mesma compensação: 73 % contra alta magia, 55 % contra indígena e taoismo, 33 % contra cristianismo, 18 % contra hinduismo. O que puxa são as Entidades caras: Hécate (−2/−2 em área mata 1,4 inimigas por jogada e deixa o resto inútil: 70,5 % espelho), Baba Yaga (destroy: 63 %), Morrigan, Cerridwen e o Caldeirão (revive Hécate/Baba Yaga **com Despertar**: 0,1–0,14 Lendária/partida). Os familiares baratos e os malefícios (Sapo 43 %, Boneco 43 %, Malefício 45 %, Gato 45 %) estão abaixo do deck — a identidade "encolher o oponente" rende menos que "corpo grande com Despertar". Sem Guarda, perde a corrida contra Ímpeto.

**Indígena (39 %).** Dois problemas, um deles **bug do motor** (§4.1): Curupira e Mapinguari se ferem a si mesmos quando atacam (589–724 disparos de `on_damaged` por 400 partidas, boa parte autoinfligida). O outro é estrutural: deck de muro sem fecho — dano de ataque à Cornucópia 4,5–8 por partida (contra 11–17 dos adversários), porque o HeurBot nunca ataca em troca ruim e as Guardas do oponente travam Caipora/Saci/tokens. Tupã mata ~1 inimiga por jogada e Cobra-Grande chega a ATK 8–12 em jogos longos, mas tarde demais. As armadilhas funcionam (Arapuca/Mundéu disparam em 84–87 % das vezes em que são postas; ~1,2 disparos/partida), Boitatá `ally_attacked` dispara 0,15 vez/partida (≈ 0, como previsto: é um 3/4 Guarda sem texto), Anhangá gera ~1,3 Veados por jogada. Jaci não domina: partidas com Jaci são 1–2 rodadas mais longas e o WR com ela em campo é igual ou menor que o do deck. Dança do Aruanã (39 %) é a carta mais fraca do jogo fora da alta magia.

**Alta magia (19 %).** Três causas somadas. (1) **Auto-fadiga**: o deck compra demais para partidas de 12–14 rodadas — sofre fadiga em 34–54 % das partidas contra decks lentos (80 % no espelho), 3–6,5 de dano de fadiga por partida. (2) **Sem dano**: 1,6–7,5 de dano de ataque por partida; Kelley 0/2, Homúnculo 1/2, Orobas 1/4 não ameaçam, e Abrahadabra (3) é o único fecho. (3) **Pactos não acontecem**: Astaroth/Dantalion/Paimon/Babalon ficam na mão 28–34 % (57 % contra hinduismo) porque o fodder morre antes do Sacrifício. Dantalion (64 % espelho) rouba a Lendária inimiga em 21–27 % das jogadas e Selo de Salomão anula uma Lendária em 23–38 % dos disparos — abaixo dos limiares da revisão (30 % / 50 %); Babalon dispara 1,7–6,0 vezes por partida (média ~3,5: manter 4/6). Conjuração dos Elementais fica na mão 54 % em parte por prioridade do bot (§4.4).

---

## 3. Mudanças propostas (priorizadas)

Convenção: P = 2·C+1 (+1 Selo/Relíquia; +2·N Sacrifício; Lendária até P+2). "Conta nova" = gasto / P. Distribuição 14/6/8/4 e curva 4/6/3/1 não mudam em nenhuma proposta.

| # | Deck / carta (arquivo) | Mudança | Conta nova | Efeito esperado | Conf. |
|---|---|---|---|---|---|
| 0 | **motor** `engine.py` l.496 | corrigir `on_damaged` do atacante (ver §4.1) — **não** mexer em Curupira/Mapinguari | — | indígena +3 a +6 pp | alta |
| 1 | hinduismo **Shiva Nataraja** (`12_shiva_nataraja.md`) | ATK 6→5 | 5+6+Ímpeto 1+destroy 4 = 16 / 15 (+1, teto +2) | tira 1 de dano por ataque da melhor carta do jogo; WR espelho 72→~62 | alta |
| 2 | hinduismo **Brahmastra** (`22_brahmastra.md`) | custo 3→4 | 4+3 = 7 / 9 (P−2, limite) — alternativa: custo 3 e área 2→1 (5,5 / 7) | atrasa a limpeza de campo da rodada 3 para a 4; menos ataques livres à Cornucópia | alta |
| 3 | hinduismo **Garuda** ×2 (`02_garuda.md`) | 2/1 → 1/2 | 1+2+Ímpeto 1+0,8 = 4,8 / 5 | metade do chip das rodadas 2–4 (Garuda é 1,0–1,2 jogadas/partida); mantém Ímpeto e o ping | média |
| 4 | hinduismo **Vajra** (`26_vajra.md`) | dano ao equipar 3→2 | 2+1+2 = 5 / 6 | 3 de dano por 2 Fé + corpo é a remoção barata que esvazia o campo cedo | média |
| 5 | cristianismo **São Miguel** (`12_sao_miguel_arcanjo.md`) | ATK 6→5 | 5+6+Guarda 1+destroy 4 = 16 / 15 (+1) | WR global 81→~72 | alta |
| 6 | cristianismo **Elias** (`11_elias.md`) | Vida 6→5 | 4+5+Renascer 2+área 3 = 14 / 13 (+1) | morre para 5 de dano; ainda volta à mão | alta |
| 7 | cristianismo **Tumba Vazia** ×2 (`14_tumba_vazia.md`) | custo 2→3 | 4,8–6,5 / 8 (P=7+1) | reviver Miguel/Elias/Leviatã para o campo custa um turno (ponto 1 da `_revisao` cristã) | média |
| 8 | bruxaria **Hécate** (`12_hecate.md`) | 6/7 → 5/6, mantém −2/−2 em área | 5+6+6 = 17 / 17 (P=15+2 Sac; sem usar o +2) | identidade (encolher) preservada; corpo deixa de ser também o maior do jogo | alta |
| 9 | bruxaria **Baba Yaga** (`09_baba_yaga.md`) | 4/5 → 3/5 | 3+5+4 = 12 / 13 | WR espelho 63→~56 | média |
| 10 | bruxaria **Caldeirão de Renascimento** (`25_caldeirao_de_renascimento.md`) | revive `para: field` → `para: hand`; +1/+2 → +2/+3 | 5+2 = 7 / 8 | acaba o laço "Hécate/Baba Yaga morrem e voltam com Despertar sem Sacrifício" (ponto 1 da `_revisao` bruxa) | média |
| 11 | alta magia **Paimon** (`12_paimon.md`) | remover **Sacrifício 1** e "compre 1" | 4+5+2 tokens 4 = 13 / 13 | o Rei entra sem fodder (fica na mão 30 %); menos uma compra (fadiga) | média |
| 12 | alta magia **Abrahadabra** (`28_abrahadabra.md`) | custo 4→3, remover "compre 1" | 3 direto 6 / 7 | fecho um turno antes; menos uma compra | média |
| 13 | alta magia **Pedra de Visão** ×2 (`31_pedra_de_visao.md`) | "+0/+2, compre 1" → "+1/+2" (sem compra) | 3 / 4 | duas compras a menos no deck (fadiga) e +2 ATK na mesa | média |
| 14 | alta magia **Andras** (`08_andras.md`) | `target_cost_max` 2→3 | 3+3+4×0,7 = 8,8 / 9 (igual) | remove Caipora/Vassago/Benandante/Lázaro; grátis na tabela | alta |
| 15 | indígena **Boitatá** ×2 (`05_boitata.md`) | gatilho `ally_attacked` → `on_damaged` (1 ao atacante) | 3+4+Guarda 1+1 = 9 / 9 | o texto passa a disparar (hoje 0,15×/partida); depende do #0 | média |
| 16 | indígena **Dança do Aruanã** (`18_danca_do_aruana.md`) | + "cura 2 na Cornucópia" | 4+1 = 5 / 5 | sai de 39 % no espelho; cabe na identidade de cura | média |
| 17 | indígena **Mundéu** ×2 (`12_mundeu.md`) | cura 2→4 | 4+2 = 6 / 6 | Selo que mais dispara (84 %) fica em P | média |
| 18 | alta magia **Conjuração dos Elementais** ×2 (`25_conjuracao_elementais.md`) | custo 3→2, "três" → "dois Elementais 1/1" | 4 / 5 | fodder barato para o pacto na rodada 2–3; ver artefato do bot §4.4 antes de confiar no WR | baixa |
| 19 | alta magia **Edward Kelley** (`03_edward_kelley.md`) | 0/2 → 1/1 (mantém Furtivo e busca) | 1+1+1+2 = 5 / 5 | o deck precisa de ATK; Kelley 0/2 nunca ataca | baixa |
| 20 | hinduismo **Kali** (`11_kali.md`) | Vida 5→4 | 4+4+3+3 = 14 / 13 (+1) | só se #1–#4 não bastarem (54 % espelho) | baixa |
| 21 | cristianismo **Leviatã** (`10_leviata.md`) | Vida 7→6 | 6+6+2 = 14 / 15 | só se cristianismo seguir > 58 após #5–#7 | baixa |
| 22 | indígena **Terra sem Males** (`21_terra_sem_males.md`) | cura 4→6 | 6+3 = 9 / 9 | fecho do deck em P | baixa |
| 23 | indígena **Cocar do Morubixaba** (`25_cocar_do_morubixaba.md`) | Vida +3→+4 | 4+1+3 = 8 / 8 | 42 % global; Relíquia em P | baixa |
| 24 | bruxaria **Boneco de Cera** (`16_boneco_de_cera.md`) | dano 3→4 | 4+4 = 8 / 8 | 43 % no espelho; Selo em P | baixa |

**Não proponho mudar agora** (observar na rodada 2): taoismo inteiro (deve subir com #1–#7; se passar de 58 %, o primeiro corte é Pílula de Ouro ×2→×1 com Bagua de volta, como a `_revisao` previu); Dantalion e Selo de Salomão (abaixo dos limiares; alta magia a 19 % não comporta nerf); Babalon 4/6 (média ~3,5 gatilhos/partida); Hanuman (52 % espelho, ATK máx. 5–6); Jaci; Om; Tandava; Juízo Final; Xiwangmu.

**Duas observações sistêmicas para o Balanceador decidir (mudam `docs/`, não cartas):**
- **`destroy` escolhido vale 4 pts na §10 e está barato**: todas as cartas com "Despertar: destrói" lideram seus decks (Shiva 72 %, Miguel 61 %, Baba Yaga 63 %; Brahmastra 1,6 mortes/jogada). Se #1, #5 e #9 não bastarem, subir para 5 pts e refazer as quatro contas de uma vez.
- **Revive para o campo repete o Despertar** (decisão 28 do README): é o que torna Tumba/Talita→Miguel, Pílula/Pássaro→Xiwangmu e Caldeirão→Hécate tão bons. A regra "revive para o campo não dispara Despertar" resolveria #7 e #10 (e o risco taoista) sem tocar em carta nenhuma — mas muda a identidade "descida renovada" do hinduismo (Descida do Avatar). Decisão de design, não de número.

---

## 4. Motor: bugs, divergências e limitações do bot

### 4.1 BUG — `on_damaged` com alvo `attacker` fere o próprio atacante
`engine.py`, `atacar()`, l.495–496:
```python
self._pos_dano(alvo, da, atacante, atacante)      # defensor ferido: attacker = atacante  ✓
self._pos_dano(atacante, dd, alvo, atacante)      # atacante ferido: attacker = ele mesmo ✗
```
Quando a Entidade com `on_damaged → damage attacker` é quem ataca, `ctx["attacker"]` é ela própria e o contragolpe a atinge (e re-dispara `on_damaged`, até a profundidade 8). Teste (`PassivoBot`, seed 1):
```
<Mapinguari 4/5 j0> ataca <Zhongli Quan 2/3 j1>
gatilho on_damaged de <Mapinguari 4/3 j0>     ← 2 de dano em si mesmo
gatilho on_damaged de <Mapinguari 4/1 j0>     ← e mais 2
morre <Zhongli Quan 2/-1 j1>
→ Mapinguari termina 4/1 (esperado 4/3)

<Curupira 1/2 j0> ataca <He Xiangu 1/3 j1>
gatilho on_damaged de <Curupira 1/1 j0>
gatilho on_damaged de <Curupira 1/0 j0>
morre <Curupira 1/0 j0>                        ← esperado: Curupira 1/1 vivo, He Xiangu 1/2
```
Texto das cartas e `regras.md` §8: "devolve dano a quem as ataca" — quem é atacado não é atacante. Correção sugerida: `self._pos_dano(atacante, dd, alvo, None)`. Afeta só Curupira ×2 e Mapinguari (únicas `on_damaged` dos 6 decks). O teste existente `test_alvo_inexistente_pula_so_a_acao` cobre só dano de Rito; falta um teste "atacante com `on_damaged` não se fere".

### 4.2 Divergência texto × motor — Azoth
Texto: "Sua Fé máxima aumenta em 1 permanentemente. Compre 1." Motor (`gain_fe perm`, decisão 3 do README): sobe a máxima **e** a Fé atual (+1 agora). Testado: fe_max 3→4, fe 0→1. Na prática Azoth custa 2. Ou o texto da carta ganha "e +1 Fé neste turno" (conta 5,5+1,5 = 7 / 7, fecha exato), ou o motor deixa de dar a Fé atual. Como está, favorece a alta magia — não é a causa do 19 %.

### 4.3 Ambiguidade — Furtivo × `triggering`
Portão do Éden (`damage triggering 3`) mata Gato Preto (Furtivo) ao ser invocado — `_alvos("triggering")` não checa `protegida`. README 6 só diz que `all_*` ignora Furtivo. Decidir e documentar (sugestão: `triggering`/`attacker`/`defender` não são "alvo escolhido" → ignoram Furtivo, como hoje). Pedido no ponto 3 da `_revisao` cristã.

### 4.4 Limitações do HeurBot que distorcem cifras (não são bugs de regra)
- **`set_stats` em aliada** (Vishvarupa): `escolher_alvo` cai em `max(candidatos, key=valor)` → escolhe a maior aliada (Durga 4/5 vira 6/6; Shiva 6/6 "vira" 6/6). Testado. Vishvarupa 43 % no espelho e 51 % na mão são artefato; **não ajustar a carta**. Sugestão: para `set_stats` com alvo aliado, escolher a de menor ATK+Vida que pode atacar.
- **Ritos só de `summon` valem 2,0** na pontuação do bot, abaixo de qualquer Entidade (2+custo), Relíquia e Selo (1,5+0,5·C); com mão cheia nunca são a melhor jogada. Explica parte dos 54 % na mão da Conjuração e dos 17 % da Dança do Aruanã. Sugestão: `summon` → 1,0 × n tokens (limitado aos slots livres).
- **Nunca ataca em troca ruim** (`_pontuar_ataque` → 0 se morre sem matar) e **só vai à Cornucópia com campo vazio** (regra). Resultado: muros de Guarda travam o jogo (espelhos de cristianismo/indígena 15–16 rodadas) e decks de agressão com Ímpeto ganham por chip antes de o muro existir. É o comportamento certo pelas regras, mas superestima Guarda + cura e subestima tokens 1/1 (que o bot não usa para trocar). Ter em mente ao ler o 83 % do hinduismo: um humano bloquearia melhor; o bot bloqueia só quando mata.
- **Mão > 7 por efeito alheio** (Ritual Menor do Pentagrama devolve 4; Renascer no turno do oponente): a mão fica em 8+ até o fim do turno do dono, e a próxima compra vai direto ao cemitério (decisão 2). Consistente com o README, só registrando.

### 4.5 Receios das `_revisao.md` que o motor **não** confirma
- `target_cost_max` em Despertar (Narasimha, Judite, Andras): `_cond_ok` reconhece `triggering is self` e filtra os candidatos (`_cost_max`). Funciona — Narasimha 78 % global / 50 % espelho, Judite 65 %/49 %.
- Duas ações com alvo escolhido no mesmo efeito (Poção de Beladona, Malefício, Vishvarupa): `_escolher` reaproveita a escolha pela chave `_esc_<alvo>`. Funciona.
- Sacrifício no próprio turno **não** dispara Solve et Coagula/Tumba Vazia (Selos só no turno do oponente). Testado.
- Davi `on_attack` mata o alvo → ataque cancelado, Davi não sofre dano (decisão 8). Acontece em 0,2–0,3 jogadas de Davi; irrelevante.

---

## 5. O que medir na rodada 2

1. **Matriz com as mesmas seeds (11 e 12)** e as metas: média de cada deck em 42–58; contar confrontos fora de 30–70 (hoje 11). Alvo mínimo da rodada: hinduismo ≤ 65, alta magia ≥ 30, nenhum confronto < 15.
2. **Hinduismo**: dano de ataque à Cornucópia por partida (hoje 14–17; alvo ≤ 11) e duração média contra taoismo/alta magia (hoje 8,3–9,5; alvo ≥ 9,5). Vantagem de quem começa no espelho (66 % → ≤ 58). WR espelho de Shiva (72 → ≤ 62), Garuda, Vajra, Brahmastra.
3. **Alta magia**: partidas com fadiga (hoje 34–54 %, 80 % no espelho; alvo ≤ 15 %), dano de fadiga sofrido por partida (3–6,5 → ≤ 1), dano de ataque por partida (1,6–7,5 → ≥ 8), "na mão" de Astaroth/Dantalion/Paimon/Babalon (28–34 % → ≤ 20 %). Reavaliar Dantalion (64 % espelho) **depois** que o deck estiver ≥ 35 %.
4. **Indígena pós-bug**: rodar o espelho e indígena × bruxaria/cristianismo antes e depois do fix do §4.1 para isolar quanto do ganho é bug e quanto é #15–#17. Taxa de disparo de Boitatá `on_damaged` (hoje `ally_attacked` 0,15/partida). Dano de ataque à Cornucópia (4,5–8 → ≥ 9).
5. **Cristianismo**: Lendárias revividas para o campo por partida (0,44 → ≤ 0,25), WR global de Miguel/Elias (81/78 → ≤ 70), duração do espelho (16,2 → ≤ 14).
6. **Bruxaria**: WR espelho de Hécate (70,5 → ≤ 62) e Baba Yaga (63 → ≤ 58); mortes por jogada de Hécate (1,4); revives do Caldeirão (devem cair a 0 para o campo).
7. **Taoismo**: se passar de 58 % na média, medir Pílula → Lendária por partida (hoje 0,23–0,34) e WR de Xiwangmu antes de cortar Pílula para ×1.
8. **Geral**: duração 7–14 em todos os confrontos (hoje 4 acima de 14, 1 abaixo de 8,3), "ficou na mão" ≤ 35 % (hoje 9 cartas hindus acima, por partidas curtas — deve cair sozinho).
9. **Motor**: incluir um teste de regressão para §4.1; decidir §4.2 (Azoth) e §4.3 (Furtivo × `triggering`); opcionalmente ajustar o bot em `set_stats` aliado e `summon` (§4.4) e rodar a matriz **antes e depois** da mudança de bot para separar efeito de bot de efeito de carta.

Todas as métricas acima saem de `python3 relatorios/r1_metricas.py 400` (seed 11) mais `duel.py --todos` e os espelhos.
