# Rodada 2 — análise de duelos (Analista)

Entrada: cartas oficiais após `r1_mudancas.md` (14 propostas aplicadas + recontagem `destroy` = 5) e motor corrigido (bug `on_damaged`, `gain_fe perm` só na máxima, Furtivo escapa de `triggering`, **revive para o campo não dispara Despertar**). `unittest` → 58 OK.

Arquivos desta rodada em `sim/relatorios/`:
- `r2_matriz.json|_seed12.json` (+ `.txt`), `espelhos_r2/<deck>.json|txt` — estado atual.
- `r2_metricas.py` — métricas direto no motor: **WR quando comprada** (sem viés de sobrevivência), rodada da 1ª jogada, dano à Cornucópia por fonte, fadiga, **Entidades inimigas mortas por efeito × em combate**, contadores (Boitatá, Despertares que matam). Saídas `r2_m_*.txt`. Inclui o `DefBot` (dúvida 1).
- `r2_variantes.py` — harness que copia um deck para `tmp_hind/`, `tmp_brux/`, `tmp_alt/`, edita o JSON das cópias e mede contra os 5 decks oficiais + espelho. Saídas `r2_var_*.txt`. **Nenhuma carta oficial foi tocada.**
- `tmp_matriz/` + `r2_matriz_prevista.json|_seed12.json` — matriz completa com os três pacotes propostos aplicados ao mesmo tempo.

---

## 1. Estado atual (seed 11; seed 12 entre parênteses)

| | alta_magia | bruxaria | cristianismo | hinduismo | indigena | taoismo | **média** |
|---|---|---|---|---|---|---|---|
| **alta_magia** | — | 48,1 (48,9) | 43,9 (42,9) | 11,3 (11,8) | 42,8 (43,2) | 37,9 (38,6) | **36,8 (37,1)** |
| **bruxaria** | 51,8 | — | 36,9 (36,1) | 18,8 (19,0) | 44,1 (45,4) | 53,1 (51,1) | **40,9 (40,5)** |
| **cristianismo** | 56,1 | 63,1 | — | 27,9 (30,2) | 64,6 (63,2) | 53,2 (51,5) | **53,0 (53,2)** |
| **hinduismo** | 88,6 | 81,2 | 72,1 (69,8) | — | 75,5 (73,9) | 80,4 (79,5) | **79,6 (78,5)** |
| **indigena** | 57,2 | 55,9 | 35,4 | 24,4 (26,1) | — | 52,2 (50,8) | **45,0 (45,3)** |
| **taoismo** | 62,2 | 46,9 | 46,8 | 19,6 (20,4) | 47,8 | — | **44,6 (45,4)** |

Reproduz `r1_mudancas.md` §3; seed 12 difere ≤ 2,3 pp por célula (dúvida 10: as diferenças de 1–2 pp de Kali/Boitatá/Mundéu estão dentro do ruído e não devem ser lidas como efeito). 5 confrontos fora de 30–70, todos do hinduismo. Quem começa: ≤ 57 % em todos os cruzados; espelhos hinduismo 65 %, alta magia 55,6 %. Duração fora de 7–14: espelho cristão 17,1, cristianismo × indígena 15,9, × taoismo 14,9, × alta 14,7, espelho indígena 14,8.

### Espelhos atuais — cartas fora da faixa (A+B, ≥ 100 partidas)

| Deck | Carta | WR jogada | **WR comprada** (nova métrica) | na mão |
|---|---|---|---|---|
| hinduismo | Shiva Nataraja | 68,1 | 55,4 | 15 % |
| hinduismo | Relíquias ×4, Tandava, Descida, Pashupatastra, Vishvarupa | 43–58 | 45–52 | **36–49 %** |
| bruxaria | Hécate | 70,0 | **56,9** | 18 % |
| bruxaria | Baba Yaga | 62,2 | **54,5** | 14 % |
| bruxaria | A Morrigan / Cerridwen | 61,6 / 60,1 | **61,8 / 62,6** | 5 % |
| alta_magia | Dantalion | 62,7 | 43,9 (vs taoismo) · 15,4 (vs hinduismo) | 19 % |
| cristianismo | Miguel / Elias | 58,9 / 58,7 | 76,5 / 76,1 (vs indígena; deck 62,5) | 2 % |
| indígena | Dança do Aruanã | 40,1 | 34,8 (vs cri; deck 37,5) | 15 % |

**Leitura da métrica nova (dúvida 4).** "WR comprada" = WR da partida em que a carta chegou à mão, jogada ou não — sem viés de "a partida durou até eu poder jogá-la". Hécate cai de 70 → 57, Baba Yaga 62 → 54,5, Shiva 62 → 55 (espelho), Dantalion 56 → 44 contra taoismo. Ou seja: **as Lendárias caras não são o que decide a partida; são sintoma de partida longa**. As cartas que de fato puxam a bruxaria são **Cerridwen e Morrigan** (62 % comprada), e no hinduismo nenhuma carta isolada passa de 55 % comprada no espelho — a força é do conjunto (§2).

---

## 2. Hinduismo: o que é (e o que não é) estrutural — medido

Todas as medições com `r2_variantes.py` (cópias em `tmp_hind/`, n = 600 por confronto contra os 5 decks oficiais, seed 11; "média" = WR médio contra os cinco; oficial = **77,6**).

### 2.1 Ímpeto **não** é o problema

| Variante (conta §10) | média | Δ |
|---|---|---|
| K1 Krishna aura só em `other_ally_entities` (11/11) | 77,4 | −0,2 |
| K2 Krishna 3/4 (10/11) | 76,9 | −0,7 |
| P7 Krishna 4/4 **sem aura** (8/11) | 77,5 | −0,1 |
| D1 Durga 4/6 sem Ímpeto (11/11) | 78,3 | +0,7 |
| H1 Hanuman 3/4 sem Ímpeto (9/9) | 78,2 | +0,6 |
| J1 Jatayu 1/2 sem Ímpeto (4,5/5) | 78,0 | +0,4 |
| G1 Garuda 2/2 sem Ímpeto (4,8/5) | 79,9 | +2,3 |
| S1 Sudarshana +2/+2 sem Ímpeto (8/8) | 79,1 | +1,5 |
| R13 Shiva 5/7 sem Ímpeto (17/17) | 77,2 | −0,4 |
| **X1 nenhum Ímpeto no deck** (Krishna vira "compre 2") | **81,8** | **+4,2** |
| O1 Om "cura 2 + compre 1" (sem Fé temporária) | 77,7 | +0,1 |
| Y1 Yajna 2 dano + 1 Fé | 77,9 | +0,3 |

Tirar Ímpeto trocando por +1 Vida **fortalece** o deck: para o HeurBot (que só ataca quando a troca é boa) 1 ponto de Vida vale mais que atacar um turno antes. A aura de Krishna vale ~0 pp. Om e Yajna também são neutros. O espelho sem Ímpeto sobe de 8,7 para 11,5 rodadas e quem começa cai de 64 → 56 % — Ímpeto explica a **corrida** e o viés de quem começa, não o 80 %.

### 2.2 Remoção: cada peça vale ≤ 2 pp, a soma vale 6

| Variante | média | Δ | | Variante | média | Δ |
|---|---|---|---|---|---|---|
| R1 Garuda sem ping | 76,2 | −1,4 | | R8 Gandiva sem área | 77,2 | −0,4 |
| R2 Yajna sem dano (2 Fé + compra) | 79,8 | **+2,2** | | R9 Trishula sem Último Sopro | 77,7 | +0,1 |
| R3 Lei do Karma 3 | 77,1 | −0,5 | | R10 Sudarshana 1/ataque | 78,3 | +0,7 |
| R4 Lanka área 1 | 76,8 | −0,8 | | R11 Brahmastra só destroy, c3 | 76,8 | −0,8 |
| R5 Agni 1 | 76,7 | −0,9 | | R12 Tandava área 2 | 76,2 | −1,4 |
| R6 Kali área 1 (4/5) | 75,8 | −1,8 | | N1 Narasimha 2/3 | 78,1 | +0,5 |
| R7 Pashupatastra só destroy, c2 | 76,3 | −1,3 | | X3 só os 4 Selos punitivos | 74,1 | −3,5 |
| **RB = 10 cortes de remoção** | **71,8** | **−5,8** | | RC = RB + K1 + D1 + H1 | 68,9 | −8,7 |

(Yajna "sem dano" com compra ficou **mais forte**: a compra vale mais que 2 de dano. Não mexer em Yajna.)

### 2.3 Sensibilidade a stats — onde a força mora

| Variante | média | Δ |
|---|---|---|
| **P5 as 4 Relíquias −1 Vida** (4 cartas, 4 cópias) | **72,6** | **−5,0** |
| P8 corpos: Hanuman 3/2, Durga 4/4, Rama 3/3, Krishna 3/4 | 71,1 | −6,5 |
| P3 −1 Vida em todas as 12 Entidades (diagnóstico) | 60,7 | −16,9 |
| P4 −1 ATK em todas as 12 Entidades (diagnóstico) | 58,9 | −18,7 |

**Diagnóstico.** O hinduismo não tem a melhor densidade de stats (ATK+Vida / Fé das Entidades: 1,50, a **menor** dos seis; os outros 1,57–1,62). O que ele tem é **tudo proativo**: 17 das 32 cartas ferem ou destroem Entidades (indígena 11, cristianismo 10, bruxaria 3, taoismo 2, alta 1), só 2 cartas de cura/revive (os outros 3–10), 10 keywords nas Entidades (os outros 5–8) e as quatro Relíquias dão +16 de stats por 12 Fé (as outras +9 a +11). Cada corpo chega a uma mesa já limpa e com Relíquia; a tabela §10 cobra o mesmo por 1 ponto de dano a Entidade e por 1 ponto de cura, mas o HeurBot (e provavelmente um humano razoável) extrai muito mais do primeiro. **Não há uma carta a cortar: há um deck a aparar em 10–13 lugares, 1 ponto em cada.**

### 2.4 Dúvida 1 — bot que bloqueia

`DefBot` (`r2_metricas.py`): sob pressão (Cornucópia ≤ 9, inimigo com Ímpeto ou Cornucópia menor que a do oponente) soma +3 a qualquer Entidade na prioridade de jogada (joga corpo antes de Rito/Selo) e **não faz ataques que não matam** (guarda o corpo intacto como bloqueador). Com DefBot dos dois lados, hinduismo × taoismo 80,2 (heur 79,4), × alta 87,1 (86,6), × cristianismo 72,2, × indígena 75,1, × bruxaria 80,2 — **igual**. Dano de ataque do hinduismo à Cornucópia inalterado (12,8–16,8/partida). Nesta regra a defesa não é um ataque: é ter corpo em campo, e o hinduismo remove os corpos. **O 80 % não é artefato do bot.**

### 2.5 Pacote proposto (testado; n = 1000, seeds 11 e 12; vs 5 decks oficiais)

| Pacote | média s11 | média s12 | dano-ataque | espelho rod / 1º |
|---|---|---|---|---|
| oficial | 77,6 | — | 15,0 | 8,7 / 64 % |
| **H0** = 11 cartas de remoção + Relíquias (abaixo) | 65,0 | 64,7 | 12,8 | 8,8 / 65–63 % |
| **H1** = H0 + Hanuman 3/2 + Krishna 3/4 — **recomendado** | **58,6** | **57,7** | 12,0 | 8,9 / 64–59 % |
| H2 = H1 + Tandava área 2 + Durga 4/4 | 55,3 | 53,9 | 11,5 | 8,8 / 63–59 % |

Na matriz prevista completa (com bruxaria e alta magia também corrigidas) H1 dá **56,9 (55,6)** — ver §5. H0 fica no limite (65) e H2 derruba o hinduismo abaixo do indígena (45 %); H1 é o meio.

---

## 3. Propostas (todas testadas; contas §10 dentro de [P−2, P])

### 3.1 Hinduismo — pacote H1 (13 cartas, 16 cópias; Ímpeto intocado em todas as 7 fontes)

| # | Carta (arquivo) | Mudança | Conta nova | Medido isolado |
|---|---|---|---|---|
| H-1 | Garuda ×2 (`02_garuda.md`) | remover o ping do Despertar (fica 1/2 Ímpeto) | 1+2+1 = 4 / 5 | −1,4 |
| H-2 | Incêndio de Lanka (`17_incendio_de_lanka.md`) | **custo 2→1**, área 2→1 (mantém 1 direto) | 1,5+2 = 3,5 / 4 (Selo +1) | −0,8 |
| H-3 | Kali (`11_kali.md`) | Vida 4→**5**, área do Despertar 2→**1** | 4+5+1,5+3 = 13,5 / 15 | −1,8 |
| H-4 | Vajra (`26_vajra.md`) | +2/+1 → **+2/+0** (mantém 2 dano) | 2+2 = 4 / 6 (P−2) | (P5) |
| H-5 | Sudarshana Chakra (`27_sudarshana_chakra.md`) | dano por ataque 2→**1** | 2+1+1+2 = 6 / 8 | +0,7 isolado; parte do P5 |
| H-6 | Gandiva (`28_gandiva.md`) | +3/+2 → **+3/+1** | 4+3 = 7 / 8 | (P5) |
| H-7 | Trishula (`29_trishula.md`) | +3/+2 → **+3/+1** | 4+2+3 = 9 / 10 | (P5) |
| H-8 | Lei do Karma (`15_lei_do_karma.md`) | dano 4→**3** | 3+1,5 = 4,5 / 6 | −0,5 |
| H-9 | Chamas de Agni (`13_chamas_de_agni.md`) | dano à Entidade 2→**1** | 1+2 = 3 / 4 | −0,9 |
| H-10 | Brahmastra (`22_brahmastra.md`) | **custo 4→3**, remover a área (só destrói) | 5 / 7 (P−2) | −0,8 |
| H-11 | Pashupatastra (`18_pashupatastra.md`) | **custo 3→2**, remover a área (só destrói o atacante) | 5 / 6 | −1,3 |
| H-12 | Hanuman ×2 (`06_hanuman.md`) | 3/3 → **3/2** | 3+2+1+2 = 8 / 9 | −2,9 |
| H-13 | Krishna (`09_krishna.md`) | 4/4 → **3/4** (aura mantida) | 3+4+3 = 10 / 11 | −0,7 |

Sanidade mantida: 14/6/8/4, curva 4/6/3/1, dano direto 5 (Agni 1, Lanka 1, Tandava 3), `destroy` 4 cópias, Lendárias ≤ P+2. P5 isolado (H-4..H-7) = −5,0; H-1..H-11 juntos (H0) = −12,6; H1 = −19,0 / −19,9.

**Não propor** (medido neutro ou contraproducente): Om, Yajna, aura de Krishna, Ímpeto de qualquer corpo, Narasimha 2/3 (dúvida 8: 2/3 dá +0,5; o 3/2 não "passou do ponto", só ficou neutro — manter), Shiva (já em P+2; sem Ímpeto não muda nada). Se a rodada 3 pedir mais 2–3 pp: Tandava área 3→2 (9/11, −1,4) e Durga 4/4 (10/11) — o H2 testado.

### 3.2 Bruxaria — pacote CB3 (5 cartas, 7 cópias; sem tocar em Hécate/Baba Yaga)

| # | Carta | Mudança | Conta | Medido isolado |
|---|---|---|---|---|
| B-1 | Malefício ×2 (`21_maleficio.md`) | −2/−2 → **−3/−2** (+ silêncio) | 5+2 = 7 / 7 | +1,2 |
| B-2 | Vassoura ×2 (`23_vassoura.md`) | +1/+1 → **+1/+2**, Ímpeto | 3+1 = 4 / 4 | +2,3 |
| B-3 | Sabá de Walpurgis (`22_saba_de_walpurgis.md`) | Lebre 1/1 → **1/2** | 6+3 = 9 / 9 | +0,3 |
| B-4 | Livro das Sombras (`24_livro_das_sombras.md`) | Usos 3→**4** | 1,4 + 1,5×4×0,7 = 5,6 / 6 | +0,3 |
| B-5 | Garrafa de Bruxa (`15_garrafa_de_bruxa.md`) | + "cura 2 na Cornucópia" | 3+2+1 = 6 / 6 | — |
| | **CB3** | | | **46,1 / 47,5** (oficial 41,3); matriz prevista **48,6 / 48,5** |

Medidos mas **fora do orçamento** (para o Balanceador decidir se arredonda): Benandante 3/3 (7,5/7) +3,5 pp; Gato Preto 1/2 (6/5) +2,7. Strega 2/2 + Strix 1/2 (7/7) deu −1,1 — não. Dúvida 3: familiares têm WR comprada igual ao do deck (36–38 contra cristianismo, deck 37) — não são fracos, são neutros; o deck sobe por **Vassoura/Malefício** (ferramentas dos familiares) e por deixar de apanhar do hinduismo (19 → 39–43 % com H1).

### 3.3 Alta magia — pacote CA3 (5 cartas, 7 cópias)

| # | Carta | Mudança | Conta | Medido isolado |
|---|---|---|---|---|
| A-1 | Azoth ×2 (`23_azoth.md`) | + "**+1 Fé temporária**" (texto: "+1 Fé máxima, +1 Fé neste turno, compre 1") | 4+1,5+1,5 = 7 / 7 | +2,0 |
| A-2 | Anel de Salomão (`29_anel_de_salomao.md`) | +1/+1 → **+1/+2** | 2+1+1+2 = 6 / 6 | +1,3 |
| A-3 | Babalon (`13_babalon.md`) | 4/6 → **5/6** | 5+6+4 = 15 / 17 (tabela); gatilhos medidos 1,7–6/partida | +1,6 |
| A-4 | Pedra de Visão ×2 (`31_pedra_de_visao.md`) | +1/+2 → **+1/+3** | 4 / 4 | +3,8 |
| A-5 | Pentagrama Flamejante ×2 (`15_pentagrama_flamejante.md`) | + "cura 2 na Cornucópia" | 3+1,5+1 = 5,5 / 6 | +0,8 |
| | **CA3** | | | **44,3 / 45,6** (oficial 36,4); matriz prevista **46,5 / 47,9** |

Medidos e **recusados**: Abrahadabra custo 3 **com** compra (7,5/7) deu **−2,1** (o bot segura mais); Orobas 2/4 (8/7) e Homúnculo 1/3 (5,5/5) estouram. A-1 reverte na carta o que o motor tirou (Azoth custava 2 na prática na rodada 1) e fecha a conta exata.

Dúvida 2 (alta × hinduismo 11 %): fadiga **caiu** de 54 % para 8 % das partidas (0,5 de dano) — contra hinduismo não é fadiga, é a corrida: 3,1 de dano de ataque contra 16,5, e os pactos ficam na mão (Astaroth 51 %, Dantalion 48 %, Babalon 48 % — contra taoismo 26/21/21 %). Contra decks lentos ainda há fadiga em 28 % das partidas (2,3 de dano) — aceitável com CA3 (compra não aumentou). Abrahadabra na mão 31–51 %: é o bot (joga Entidades antes; rodada média da 1ª jogada 9–11), não o custo. Com H1 o confronto vai a **33,9 / 35,6**.

### 3.4 Sem mudança (confirmado por medição)

- **Cristianismo** (dúvida 5): entra em 53,0 → 54,8 previsto. Miguel destrói 0,68/partida contra indígena (0,95 por jogada; antes do fix de revive era mais). Lentidão: espelho 17,1 e × indígena 15,9 continuam > 14 na matriz prevista. Candidatas **para a rodada 3**, só se a duração for prioridade: Multiplicação dos Pães sem a cura (3/5 → P−2) ou Cova dos Leões cura 4→2. Não mexer agora: o deck acabou de entrar na faixa.
- **Indígena** (dúvida 6): Boitatá `on_damaged` dispara **2,48×/partida** (era 0,15 com `ally_attacked`); dano de ataque à Cornucópia 9,2 contra cristianismo (era 6,7; meta ≥ 9 atingida); × cristianismo 24 → 35–37 %. Com H1 sobe para 47,5 / 46,4 sem mais nada. Dança do Aruanã continua a carta mais fraca (39–40 %); Terra sem Males/Cocar (#22/#23) ficam como reserva se cair abaixo de 45.
- **Taoismo** (dúvida 7): Pílula 52,8 % comprada no espelho, Pássaro 50,7, Xiwangmu 56,2 — a regra nova não as enfraqueceu demais; Imperador de Jade é a melhor (58,9). Previsto 45,8 / 46,8. Observar: é o deck mais perto do piso depois dos pacotes (perde 10 pp contra alta magia corrigida).
- Dúvida 9 — Andras ≤ 3: acerta o `destroy` em 0,31/partida (~60 % das jogadas), na mão 9–10 %, 3/2 ok.

---

## 4. Matriz prevista com H1 + CB3 + CA3 (seed 11; seed 12 entre parênteses; `tmp_matriz/`)

| | alta_magia | bruxaria | cristianismo | hinduismo | indigena | taoismo | **média** |
|---|---|---|---|---|---|---|---|
| **alta_magia** | — | 47,0 (49,9) | 51,7 (50,2) | **33,9 (35,6)** | 51,8 (54,6) | 48,1 (49,2) | **46,5 (47,9)** |
| **bruxaria** | 53,0 | — | 41,0 (39,2) | 39,0 (43,1) | 49,8 (53,0) | 60,1 (57,0) | **48,6 (48,5)** |
| **cristianismo** | 48,3 | 59,0 (60,8) | — | 48,6 (48,5) | 64,6 (63,2) | 53,2 (51,5) | **54,8 (54,8)** |
| **hinduismo** | 66,1 (64,3) | 61,1 (56,9) | 51,3 | — | 48,4 (48,0) | 57,6 (57,4) | **56,9 (55,6)** |
| **indigena** | 48,1 (45,4) | 50,2 (47,0) | 35,4 (36,8) | 51,6 (52,0) | — | 52,2 (50,8) | **47,5 (46,4)** |
| **taoismo** | 51,8 (50,8) | 40,0 (43,0) | 46,8 (48,5) | 42,4 (42,6) | 47,8 (49,1) | — | **45,8 (46,8)** |

- **Médias: as seis em 42–58** nas duas seeds (antes: 3 de 6). **Confrontos fora de 30–70: 0** (antes 5); os mais extremos: alta × hinduismo 33,9/35,6 e indígena × cristianismo 35,4/36,8.
- Quem começa: todos os cruzados ≤ 58,8 % (hinduismo × taoismo 56,6/58,8 é o maior). Espelho hinduismo H1 ainda 59–64 % (meta ≤ 55 não atingida — é o Ímpeto, que decidimos preservar).
- Duração: 10,6–15,9; fora de 7–14 só os confrontos do cristianismo (× indígena 15,9, × taoismo 14,9, × alta 14,7) — dúvida 5.
- Cartas na matriz prevista fora de deck±8 (global, com confundimento de força do deck): Miguel 72, Elias 70, Leviatã 67 (cristianismo 54,8); Hécate 65,5, Baba Yaga 61, Morrigan 60, Cerridwen 59 (bruxaria 48,6); Dantalion 62, Babalon 56 (alta 46,5); Shiva 68 (hinduismo 57); Dança do Aruanã 39 (indígena 47,5). Nenhuma carta com "na mão" > 35 %. No espelho H1, Shiva passa a destoar mais (73 jogada / 65 comprada) porque o resto do deck baixou: se a rodada 3 quiser aparar, Shiva 5/5 Ímpeto destroy (16/17) é o único corte que sobra nele.

---

## 5. Motor e bot

- Correções da rodada 1 confirmadas: Curupira/Mapinguari não se ferem (Boitatá/Curupira/Mapinguari `on_damaged` 1,6–2,5×/partida, todos na direção certa nos logs); Azoth sobe só a máxima (`fe` 0→0 no teste); Portão do Éden não atinge Gato Preto; `revive` para o campo sem Despertar (Miguel/Hécate/Xiwangmu revividos não repetem). Testes 58 OK.
- Nenhum bug novo encontrado nos logs desta rodada.
- Limitações de bot que continuam distorcendo cifras (não mudar cartas por elas): Vishvarupa (`set_stats` escolhe a maior aliada → 46 % global, 40 % na mão); Ritos só de `summon` valem 2,0 (Conjuração 28–37 % na mão, Dança do Aruanã); Abrahadabra segurada até a rodada 9–11. Sugestões de ajuste do bot ficam como estavam no `r1_analise` §4.4; se forem feitas, rodar a matriz antes e depois.
- Métrica nova entregue (dúvida 4): "WR quando comprada" em `r2_metricas.py`; recomendo que o `duel.py` passe a imprimi-la ao lado de "WR jogada" na rodada 3 (é 10 linhas no `Agregador`: contar `j.compradas` por partida).

---

## 6. O que medir na rodada 3 (depois de aplicar H1 + CB3 + CA3)

1. Matriz seeds 11 e 12: confirmar as seis médias em 42–58 e zero confrontos fora de 30–70 (previsto: hinduismo 56–57, cristianismo 55, bruxaria 48–49, indígena 46–48, alta 46–48, taoismo 46–47). Se o hinduismo ficar > 58, aplicar H2 (Tandava área 2, Durga 4/4); se < 50, reverter H-12 (Hanuman 3/3).
2. Hinduismo: dano de ataque à Cornucópia (previsto 12,0; meta ≤ 11 ainda não atingida — aceitar ou H2); espelho 1º vence (59–64 %, único critério que fica fora: custo do Ímpeto preservado); Shiva no espelho (73/65 — ver §4).
3. Alta magia: fadiga ≤ 15 % contra decks lentos (hoje 28 % contra taoismo); "na mão" de Astaroth/Dantalion/Babalon ≤ 20 % (hoje 21–26 % contra taoismo, 48–51 % contra hinduismo — deve cair com H1); Dantalion WR comprada vs jogada.
4. Cristianismo: duração (espelho 17,1; × indígena 15,9) — decidir se a meta 7–14 vale um corte de cura (Multiplicação dos Pães / Cova dos Leões).
5. Taoismo: é o deck mais perto de 42 na previsão; se cair abaixo, Bagua de Fuxi no lugar do 2º Taiji (consistência) é a troca prevista em `_reserva/`.
6. Bruxaria: WR comprada de Cerridwen/Morrigan (62 %) — são as cartas que de fato puxam; se o deck passar de 55, cortar aí (Cerridwen "compre 1" ou Morrigan 5/4), não em Hécate.
7. Repetir `r2_variantes.py ... final` com as cartas oficiais já alteradas para confirmar que a cópia e o oficial coincidem (sanidade do harness).
