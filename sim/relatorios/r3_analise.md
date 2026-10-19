# Rodada 3 — análise final (Analista)

Estado: cartas após `r2_mudancas.md` (H1 + Tandava, CB3 sem Garrafa, CA3). Motor inalterado desde a rodada 2 (58 testes OK). Arquivos: `r3_matriz_seed13|14.json|txt`, `espelhos_r3/<deck>_s13|s14.*`, `r3_experimentos.py` → `r3_exp_primeiro.txt`, `r3_exp_cristao.txt` (cópias em `tmp_hind/r3_K1_*`, `tmp_cri/`; nada oficial tocado).

## Veredito: **pronto para playtest humano.**

Todas as metas primárias fecham em quatro seeds independentes (11–14): médias das seis em 46–56, zero confrontos fora de 30–70, nenhuma carta com "na mão" > 35 % fora de partidas curtas do hinduismo, nenhuma carta fora de ±12 na WR comprada. Ficam de fora só duas metas secundárias, ambas ligadas a identidade e sem solução por número (§2).

## 1. Confirmação com seeds novas (13 / 14, n = 2000)

| Deck | s11 | s12 | **s13** | **s14** |
|---|---|---|---|---|
| cristianismo | 55,0 | 55,2 | 55,6 | 54,5 |
| hinduismo | 56,5 | 54,9 | 55,1 | 55,2 |
| bruxaria | 48,3 | 48,4 | 48,3 | 47,9 |
| alta_magia | 46,2 | 47,8 | 47,8 | 47,8 |
| taoismo | 46,2 | 47,0 | 46,9 | 47,6 |
| indígena | 47,8 | 46,7 | 46,4 | 47,0 |

Matriz s13 (s14): alta × hind **34,1 (35,6)** é o confronto mais extremo; cristianismo × indígena 65,7 (62,7) o segundo. Nenhuma célula varia mais de 3,6 pp entre as quatro seeds (bruxaria × hinduismo 40,8–44,4 é a mais ruidosa — ruído, não efeito). Espelhos s13/s14: 1º vence 46,7–65,0; cartas com WR jogada fora de ±12 no espelho: **só Shiva** (70,4 jogada / 60,3 comprada); Hécate 69,6 jogada mas ~51 comprada; Dantalion 65,4 jogada / ~52 comprada — as duas últimas são sobrevivência, não força.

Fora das metas secundárias (nas duas seeds — não é ruído):
- **Quem começa > 55 %**: hinduismo × taoismo 59,5/59,6, × alta 57,4/59,1, × indígena 54,9/56,1; espelho hinduismo 62,6/65,0; espelho alta 57,2/56,2.
- **Duração > 14**: cristianismo × indígena 16,2/15,8, × taoismo 14,8, × alta 14,6/14,8, × bruxaria 14,1/14,0; espelho cristão 17,1; espelho indígena 14,9.

## 2. Pontos secundários — medidos, com veredito

### (a) Vantagem do 1º jogador nos confrontos do hinduismo (`r3_exp_primeiro.txt`, n = 1000)

| Variante | WR médio hind | 1º vence médio (5 cruzados) | espelho 1º | efeito colateral |
|---|---|---|---|---|
| oficial | 56,3 | 54,7 | 63,4 | — |
| Krishna aura → `other_ally_entities` (10/11) | 54,3 | **54,2** | 62,2 | −2 pp de WR, 1º vence igual |
| regra: 2º jogador **+2** Fé temporária no 1º turno | 54,7 | **49,1** | 57,1 | cristianismo cai a 46,0 % de 1º vence (× bruxaria **43,5**), taoismo 47,7 (× bruxaria **42,9**) |

**Krishna não é a causa** (−0,5 pp no 1º vence): o viés vem do Ímpeto distribuído (Garuda, Jatayu, Hanuman, Durga, Shiva) — quem começa bate primeiro num campo vazio. A regra +2 Fé corrige o hinduismo (54,7 → 49,1) mas **inverte o viés nos outros decks** (2º jogador vence 53–57 % contra bruxaria/indígena): troca um desvio de 5 pp em 3 confrontos por um desvio de 4–7 pp em 6. **Não recomendo nem uma nem outra.** Fica como observação para o playtest: humanos jogam o 1º turno mais devagar que o bot, e o espelho hinduismo (63 %) é o único caso acima de 60.

### (b) Duração do cristianismo (`r3_exp_cristao.txt`, n = 1000)

| Variante (conta) | WR médio | rodadas médias (5 cruzados) | espelho |
|---|---|---|---|
| oficial | 54,4 | 14,4 | 17,1 |
| Pães sem cura (3/5) | 53,7 | 14,3 | 17,1 |
| Pães cura 1 (3,5/5) | 54,1 | 14,4 | 17,0 |
| Cova dos Leões cura 2 (3/4) | 52,9 | 14,3 | 17,1 |
| Pães sem cura + Cova 2 | 52,3 | 14,3 | 17,1 |
| diagnóstico: Graal sem cura de Cornucópia | 53,8 | 14,3 | 16,8 |

**Zero efeito na duração** (−0,1 rodada), só perda de WR. A partida longa não vem de 2–4 pontos de cura: vem da estrutura — Guardas (Anjo ×2, Serafim, Miguel, Arca) + Renascer ×3 + Tumba/Talita contra um bot que só ataca quando mata. É a identidade "atrito" do `_deck.md`. **Não recomendo**; aceitar 14–16 rodadas nos confrontos do cristianismo como traço do deck (ainda ≤ 10 min de jogo humano? — é o que o playtest deve medir, com relógio).

## 3. Tabela para o GDD — 5 maiores e 5 menores WR comprada por deck (s13 + s14 agregadas, 4000 partidas por confronto × 5)

"Comprada" = WR da partida em que a carta chegou à mão (sem viés de sobrevivência). "Jogada" entre parênteses.

| Deck (média) | Maiores | Menores |
|---|---|---|
| **hinduismo** (55,2) | Shiva **63,3** (67,0) · Ganesha 57,6 · Durga 56,1 · Kali 56,0 · Véu de Maya 55,9 | Sudarshana 50,5 (53,7) · Chamas de Agni 50,7 · Vishvarupa 51,4 (46,3) · Gandiva 51,7 · Lanka 52,0 |
| **cristianismo** (55,0) | Elias **68,1** (71,3) · Miguel **67,7** (71,6) · Sansão 63,3 · Gabriel 60,9 · Multiplicação dos Pães 60,9 | Anjo da Guarda 55,5 · Santo Graal 55,8 · Talita Cumi 56,0 · Davi 56,5 · Funda 56,6 |
| **bruxaria** (48,1) | Morrigan 57,4 · Cerridwen 57,1 · Medeia 53,2 · Circe 53,2 · Bruxa de Endor 52,7 | Boneco de Cera 46,2 (43,2) · Pacto 46,7 · Mau-Olhado 47,6 · Sapo 47,6 (43,5) · Poção 47,7 |
| **indígena** (46,7) | Tupã 53,3 · Cobra-Grande 50,3 · Jaci 48,7 · Visão do Caapi 48,4 · Iara 48,0 | Ibirapema 44,3 · Matinta 45,0 · Saci 45,2 (41,7) · Dança do Aruanã 45,3 (38,1) · Muiraquitã 45,4 |
| **alta_magia** (47,8) | Dantalion 51,8 (62,9) · Andras 50,8 · Ritual Menor 50,7 · Paimon 50,3 · Conjuração 49,9 | Sigillum 47,8 · Astaroth 47,9 · Orobas 48,0 · Azoth 48,3 · Pentagrama 48,3 |
| **taoismo** (47,3) | Xiwangmu 52,7 · Imperador de Jade 52,0 · Guan Yu 51,8 · Zhang Guolao 51,3 · Nezha 51,1 | Dragão Azul 45,4 · Espelho de Bronze 46,4 · Cao Guojiu 47,0 · Li Tieguai 47,0 · Han Xiangzi 47,4 |

Leitura: em quatro decks a amplitude comprada é ≤ 8 pp (deck coeso). Cristianismo e hinduismo têm as Lendárias 12–13 pp acima da média do deck — "momento uau" previsto pela regra Lendária ≤ P+2 — mas Elias/Miguel em 68 % global são o ponto a vigiar no playtest (no espelho estão em 58–59, dentro de ±12).

## 4. Mudanças finais recomendadas (máx. 6 — proponho 2 de carta e 2 de ferramenta)

| # | O quê | Conta §10 | Por quê / efeito esperado | Conf. |
|---|---|---|---|---|
| 1 | **Shiva Nataraja** 5/6 → **5/5** (Ímpeto, destroy) — `12_shiva_nataraja.md` | 5+5+1+5 = 16 / 17 (P+1) | única carta fora de ±12 jogada no espelho (70,4) e 60,3 comprada; o resto do deck baixou e ela destoa. −1 a −2 pp no hinduismo (55 → ~54). **Opcional**: pode ficar como o "uau" do deck se o playtest não reclamar | média |
| 2 | **Nada mais em carta.** Dança do Aruanã (38 jogada / 45 comprada), Conjuração (28 % na mão) e Vishvarupa (46 jogada) são artefatos conhecidos do HeurBot (`summon` valorado 2,0; `set_stats` na maior aliada) — não ajustar por eles | — | — | — |
| 3 | **Bot**: `set_stats` em aliada → escolher a de menor ATK+Vida que pode atacar; Ritos só de `summon` → 1,0 × n tokens | — | melhora a leitura de Vishvarupa/Conjuração/Dança antes do próximo ciclo; rodar matriz antes/depois | alta |
| 4 | **Playtest**: medir com relógio a duração real dos confrontos do cristianismo (14–17 rodadas no bot) e a sensação de "quem começa" no hinduismo (espelho 63 %) — as duas metas secundárias que o número não fecha sem ferir identidade | — | — | — |

Não recomendadas (medidas): Krishna `other_ally_entities` (sem efeito no 1º vence, −2 WR); regra +2 Fé ao 2º jogador (inverte o viés nos outros decks); Multiplicação dos Pães / Cova dos Leões reduzidas (zero efeito na duração, −1 a −2 WR); Garrafa + cura (recusada pelo Balanceador por identidade, +0,4 ≈ ruído — concordo).
