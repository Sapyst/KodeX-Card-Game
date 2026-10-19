# Rodada 2 — mudanças de carta (Balanceador)

Entrada: `r2_analise.md` (Analista) com três pacotes medidos em cópias (`tmp_hind/`, `tmp_brux/`, `tmp_alt/`, `tmp_matriz/`): **H1** (hinduismo, 13 cartas), **CB3** (bruxaria, 5) e **CA3** (alta magia, 5), mais a métrica nova **WR comprada**. As cópias só traziam o JSON; tabela, Texto, Papel e Balanço foram escritos nas cartas oficiais.

Arquivos desta rodada em `sim/relatorios/`: `r2_pos_mudancas_s11.json|txt`, `r2_pos_mudancas_s12.json|txt` (final), `*_passe1.*` (H1 + CB3 + CA3 antes do Tandava), `espelhos_r2_pos/<deck>.json|txt` (seis espelhos; `hinduismo_passe1.json` antes do Tandava).

Validação: `validar.py` → `OK` nas seis pastas; `unittest` → 58 `OK`; textos ≤ 25 palavras; 14/6/8/4, curva 4/6/3/1, cópias, Lendárias ≤ P+2, dano direto ≤ 8 (hinduismo 5), `counter` ≤ 3, `destroy` com custo mínimo 3 — tudo mantido; nenhuma carta nova nem troca com `_reserva/`.

---

## 1. Mudanças aplicadas

Convenção: P = 2·C+1 (+1 Selo/Relíquia; +2·N Sacrifício; Lendária até P+2); faixa aceita [P−2, P].

### 1.1 Hinduismo — pacote H1 + Tandava (14 cartas, 17 cópias; Ímpeto intocado)

| # | Carta | Antes | Depois | Conta §10 | Medido isolado (Analista) |
|---|---|---|---|---|---|
| H-1 | **Garuda** ×2 (2) | 1/2 Ímpeto, Despertar: 1 aleatório | **1/2 Ímpeto** | 1+2+1 = 4 / 5 | −1,4 |
| H-2 | **Incêndio de Lanka** (Selo) | custo 2; 2 área + 1 direto | **custo 1; 1 área** + 1 direto | 1,5+2 = 3,5 / 4 | −0,8 |
| H-3 | **Kali** (L, 6) | 4/4; Despertar 2 área | **4/5; Despertar 1 área** | 4+5+1,5+3 = 13,5 / 15 (P+0,5) | −1,8 |
| H-4 | **Vajra** (Rel 2) | +2/+1, 2 dano | **+2/+0**, 2 dano | 2+2 = 4 / 6 (P−2) | pacote P5 −5,0 |
| H-5 | **Sudarshana Chakra** (Rel 3) | 2 dano por ataque | **1** dano por ataque | 2+1+1+2 = 6 / 8 (P−2) | idem |
| H-6 | **Gandiva** (Rel 3) | +3/+2 | **+3/+1** | 3+1+3 = 7 / 8 | idem |
| H-7 | **Trishula** (Rel 4) | +3/+2 | **+3/+1** | 3+1+2+3 = 9 / 10 | idem |
| H-8 | **Lei do Karma** (Selo 2) | 4 dano + compra | **3** dano + compra | 3+1,5 = 4,5 / 6 | −0,5 |
| H-9 | **Chamas de Agni** (Selo 1) | 2 à Entidade + 1 direto | **1** à Entidade + 1 direto | 1+2 = 3 / 4 | −0,9 |
| H-10 | **Brahmastra** (Rito) | custo 4; destroy + 2 área | **custo 3; só destroy** | 5 / 7 (P−2) | −0,8 |
| H-11' | **Pashupatastra** (Selo) | custo 3; destroy atacante + 2 área | custo **3**; destroy atacante **+ compre 1** | 5+1,5 = 6,5 / 8 | Analista: custo 2 só destroy (−1,3). **Desvio**: §10 exige custo mín. 3 para `destroy`; a área virou compra para não cair abaixo de P−2 |
| H-12 | **Hanuman** ×2 (4) | 3/3 | **3/2** | 3+2+1+2 = 8 / 9 | −2,9 |
| H-13 | **Krishna** (5) | 4/4 aura Ímpeto | **3/4** aura Ímpeto | 3+4+3 = 10 / 11 | −0,7 |
| H2a | **Tandava** (Rito 5) | 3 área + 3 direto | **2 área** + 3 direto | 3+6 = 9 / 11 (P−2) | −1,4 — **2º passe**: com H1 o deck mediu 58,5 / 57,2; aplicada a metade leve de H2 (Durga 4/4 fica em reserva) |

### 1.2 Bruxaria — pacote CB3 menos B-5 (4 cartas, 6 cópias)

| # | Carta | Antes | Depois | Conta §10 | Medido |
|---|---|---|---|---|---|
| B-1 | **Malefício** ×2 (Rito 3) | −2/−2 + silêncio | **−3/−2** + silêncio | 5+2 = 7 / 7 | +1,2 |
| B-2 | **Vassoura** ×2 (Rel 1) | +1/+1, Ímpeto | **+1/+2**, Ímpeto | 3+1 = 4 / 4 | +2,3 |
| B-3 | **Sabá de Walpurgis** (Rito 4) | Lebre 1/1 | Lebre **1/2** | 6+3 = 9 / 9 | +0,3 |
| B-4 | **Livro das Sombras** (Rel 2) | Usos 3 | **Usos 4** | 1,4 + 1,5×4×0,7 = 5,6 / 6 | +0,3 |
| B-5 | Garrafa de Bruxa | — | **recusada** (+ cura 2) | fica 5 / 6 | identidade "bruxaria não cura a Cornucópia" (`_deck.md`); medido +0,4 pp (ruído) |

### 1.3 Alta magia — pacote CA3 (5 cartas, 7 cópias)

| # | Carta | Antes | Depois | Conta §10 | Medido |
|---|---|---|---|---|---|
| A-1 | **Azoth** ×2 (Rito 3) | +1 Fé máx., compre 1 | +1 Fé máx., **+1 Fé neste turno**, compre 1 | 4+1,5+1,5 = 7 / 7 | +2,0 (devolve na carta o que o motor tirou na rodada 1) |
| A-2 | **Anel de Salomão** (Rel 2) | +1/+1, Ímpeto, silêncio ao atacar | **+1/+2** | 3+1+2 = 6 / 6 | +1,3 |
| A-3 | **Babalon** (L, 6, Sac 1) | 4/6 | **5/6** | 5+6+3 gatilhos×2 = 17 / 17 (P+2; ~3,5 gatilhos medidos/partida) | +1,6 |
| A-4 | **Pedra de Visão** ×2 (Rel 1) | +1/+2 | **+1/+3** | 1+3 = 4 / 4 | +3,8 |
| A-5 | **Pentagrama Flamejante** ×2 (Selo 2) | counter + compre 1 | counter + compre 1 **+ cura 2** | 3+1,5+1 = 5,5 / 6 | +0,8 |

### 1.4 Sem mudança (conforme o Analista)

Cristianismo, indígena, taoismo intocados. Benandante 3/3 e Gato Preto 1/2 (medidos +3,5 / +2,7) **não** aplicados: estouram P. Abrahadabra com compra, Orobas 2/4, Homúnculo 1/3 recusados pelo Analista.

### 1.5 `_deck.md`

Hinduismo (Lanka custo 1, Brahmastra 3, gatilhos `on_play` sem Garuda, Lendárias Kali +0,5 · Shiva +2, identidade), bruxaria (Malefício, Sabá, Vassoura, Livro), alta magia (Babalon 5/6, Azoth) — listas, contagens e curvas conferidas; `## Histórico de balanceamento` com a rodada 2 nos três.

---

## 2. Motor: métrica "WR comprada" no `duel.py`

Portada de `r2_metricas.py` para `duel.py` (`Agregador.registrar` / `_carta_dict` / `rodar_todos`): para cada carta, `partidas_comprada` (partidas em que chegou à mão, jogada ou não) e `vitorias_comprada`; derivado `win_rate_comprada`. Campos **adicionados** ao JSON (nenhum existente mudou); nova coluna "WR comprada" na tabela por lado e `comprada=` no ranking. `README.md` do sim documenta a coluna. 58 testes OK; a saída do deck de teste reproduz os números anteriores.

---

## 3. Matriz antes × depois (n = 2000)

### Antes (fim da rodada 1, seed 11)

| | alta_magia | bruxaria | cristianismo | hinduismo | indigena | taoismo | **média** |
|---|---|---|---|---|---|---|---|
| **alta_magia** | — | 48,1 | 43,9 | 11,3 | 42,8 | 37,9 | **36,8** |
| **bruxaria** | 51,8 | — | 36,9 | 18,8 | 44,1 | 53,1 | **40,9** |
| **cristianismo** | 56,1 | 63,1 | — | 27,9 | 64,6 | 53,2 | **53,0** |
| **hinduismo** | 88,6 | 81,2 | 72,1 | — | 75,5 | 80,4 | **79,6** |
| **indigena** | 57,2 | 55,9 | 35,4 | 24,4 | — | 52,2 | **45,0** |
| **taoismo** | 62,2 | 46,9 | 46,8 | 19,6 | 47,8 | — | **44,6** |

### Depois (final; seed 11, seed 12 entre parênteses)

| | alta_magia | bruxaria | cristianismo | hinduismo | indigena | taoismo | **média** |
|---|---|---|---|---|---|---|---|
| **alta_magia** | — | 47,4 (50,1) | 51,7 (50,2) | 31,9 (35,0) | 51,8 (54,6) | 48,1 (49,2) | **46,2** (47,8) |
| **bruxaria** | 52,6 (49,9) | — | 40,6 (38,6) | 39,4 (44,0) | 49,2 (52,4) | 59,9 (56,8) | **48,3** (48,4) |
| **cristianismo** | 48,3 (49,8) | 59,5 (61,4) | — | 49,5 (50,2) | 64,6 (63,2) | 53,2 (51,5) | **55,0** (55,2) |
| **hinduismo** | 68,0 (65,0) | 60,7 (56,0) | 50,4 (49,8) | — | 47,4 (47,1) | 55,8 (56,8) | **56,5** (54,9) |
| **indigena** | 48,1 (45,4) | 50,8 (47,5) | 35,4 (36,8) | 52,6 (52,8) | — | 52,2 (50,8) | **47,8** (46,7) |
| **taoismo** | 51,8 (50,8) | 40,2 (43,2) | 46,8 (48,5) | 44,2 (43,2) | 47,8 (49,1) | — | **46,2** (47,0) |

(1º passe, sem Tandava: hinduismo **58,5 / 57,2**, alta × hinduismo 30,9 / 34,2 — por isso o 2º passe.)

Previsão do Analista (`tmp_matriz/`, H1+CB3+CA3): hinduismo 56,9/55,6, cristianismo 54,8, bruxaria 48,6, indígena 47,5/46,4, alta 46,5/47,9, taoismo 45,8/46,8. **O oficial reproduz a previsão dentro de ±1,6 pp** em todas as médias; as diferenças cabem nos dois desvios (Pashupatastra custo 3, Garrafa sem cura) e no Tandava.

### Metas

| Meta | Antes | Depois | |
|---|---|---|---|
| Média de cada deck em 42–58 | 3/6 | **6/6** nas duas seeds (extremos: hinduismo 56,5/54,9; taoismo 46,2/47,0) | atingida |
| Confrontos em 30–70 | 10/15 | **15/15** nas duas seeds (mais apertado: alta × hinduismo 31,9/35,0) | atingida |
| Carta no espelho em [deck−12, deck+12] pela WR comprada | — | **nenhuma fora** nos seis espelhos (máx. Shiva 60,1; mín. Sudarshana 46,8) | atingida |
| "Ficou na mão" ≤ 35 % | 0 cartas acima | **0 cartas acima** (máx.: Abrahadabra 25 %, Ritual Menor 24 %) | atingida |
| Quem começa ≤ 55 % | 3 confrontos acima | **3 acima**: alta × hinduismo 58,0, hinduismo × taoismo 58,8, hinduismo × indígena 55,5; espelho hinduismo 63,0 % | não atingida (Ímpeto preservado — decisão de identidade) |
| Duração 7–14 rodadas | 4 fora | **4 fora**, todos do cristianismo: × indígena 15,9, × taoismo 14,9, × alta 14,7, × bruxaria 14,0; espelho cristão 17,1 | não atingida |

### Espelhos (seed 11)

| Deck | rodadas | 1º vence | maiores WR comprada | menores |
|---|---|---|---|---|
| hinduismo | 8,9 | 63,0 % | Shiva 60,1 · Ganesha 56,6 · Véu de Maya 52,9 | Trishula 48,0 · Gandiva 46,9 · Sudarshana 46,8 |
| cristianismo | 17,1 | 47,7 % | Miguel 57,4 · Elias 57,4 · Multiplicação 53,9 | Graal 48,8 · Portão do Éden 48,6 · Davi 48,5 |
| bruxaria | 12,0 | 48,8 % | Morrigan 59,4 · Cerridwen 58,6 · Medeia 54,8 | Poção 49,2 · Mau-Olhado 49,0 · Pacto 47,8 |
| alta_magia | 13,3 | 56,1 % | Dantalion 52,7 · Ritual Menor 52,0 · Andras 51,0 | Solve 49,5 · Sigillum 49,4 · Orobas 49,4 |
| indigena | 14,8 | 49,7 % | Tupã 57,5 · Cobra-Grande 55,1 · Jaci 54,0 | Ibirapema 49,0 · Saci 48,6 · Dança do Aruanã 48,4 |
| taoismo | 12,9 | 53,3 % | Xiwangmu 56,6 · Imperador 55,6 · Zhang Guolao 55,2 | Espelho 48,8 · Li Tieguai 48,7 · Dragão Azul 47,5 |

Pela WR comprada, nenhum deck tem carta que "decida sozinha": a amplitude máxima dentro de um deck é 13 pp (hinduismo). A WR *jogada* ainda destaca Lendárias caras (Shiva 68, Miguel 72, Hécate 64 global) — é o viés de sobrevivência que a métrica nova corrige.

### Cartas mexidas — WR global jogada (antes → depois), WR comprada, "na mão"

Hinduismo: Garuda 77 → 54 (comprada 56), Hanuman 77 → 54 (55), Krishna 76 → 54 (55), Kali 79 → 57 (57), Shiva 84 → 68 (65), Vajra 79 → 57 (55), Sudarshana 76 → 55 (52), Gandiva 78 → 57 (53), Trishula 77 → 57 (54), Lei do Karma 74 → 53 (55), Agni 73 → 51 (52), Lanka 72 → 51 (53; na mão 21 → 11 %), Pashupatastra 73 → 54 (56; na mão 24 → 18 %), Brahmastra 73 → 52 (55; na mão 11 → 15 %).
Bruxaria: Malefício 39 → 46 (48), Vassoura 43 → 50 (49), Sabá 42 → 47 (49), Livro 47 → 53 (50); Hécate 60 → 64 (52), Baba Yaga 56 → 60 (53), Cerridwen 52 → 58 (58), Morrigan 53 → 59 (58).
Alta magia: Azoth 38 → 46 (47; na mão 13 → 6 %), Anel 41 → 49 (47), Babalon 49 → 55 (48), Pedra 41 → 50 (48), Pentagrama 41 → 49 (47); Dantalion 55 → 61 (50), Abrahadabra 38 → 44 (47; na mão 29 → 25 %).

---

## 4. O que resta para a rodada 3

As quatro metas numéricas principais (médias, confrontos, espelho, na mão) estão atingidas nas duas seeds. Ficam dois critérios secundários e três pontos de observação:

1. **Quem começa > 55 % nos confrontos do hinduismo** (58–59 % contra alta magia e taoismo; espelho 63 %). O Analista mediu que é o Ímpeto (sem Ímpeto o espelho cai a 56 %), que decidimos preservar como identidade. Opções se a meta valer a identidade: Krishna aura só em `other_ally_entities` (neutro em WR, −? em 1º vence — a medir), ou aceitar ≤ 60 % para o deck de corrida. Recomendo **aceitar** e registrar em `regras.md` que o deck de agressão tem 1º-vence até 60 %.
2. **Duração dos confrontos do cristianismo** (14,0–15,9; espelho 17,1). O deck está em 55 %, dentro da faixa; os cortes candidatos do Analista são de cura (Multiplicação dos Pães sem a cura 3/5, ou Cova dos Leões cura 4 → 2). Qualquer um deles baixa o deck ~1–2 pp e encurta ~1 rodada — cabe. Decisão de prioridade (duração × identidade "atrito"), não de número.
3. **Hinduismo × alta magia 31,9 / 35,0** é o confronto mais apertado; Durga 4/4 (10/11; a outra metade de H2) é a reserva se uma seed nova o levar abaixo de 30.
4. **Bruxaria**: Cerridwen (58) e Morrigan (59) são as cartas que puxam, como o Analista previu; dentro de ±12. Se o deck passar de 55 numa seed, cortar aí (Cerridwen "compre 1", Morrigan 5/4), não em Hécate.
5. **Taoismo 46,2 / 47,0** é o deck mais perto do piso e perde 10 pp para a bruxaria (40,2/43,2). Troca prevista em `_reserva/` (Bagua de Fuxi no lugar do 2º Taiji) só se cair abaixo de 42.
6. Sanidade do harness (item 7 do Analista): o oficial reproduziu `tmp_matriz/` dentro de ±1,6 pp — confirmado sem rodar `r2_variantes.py final`, mas vale a rodada formal.
7. Bot (inalterado, `r1_analise` §4.4): Vishvarupa, Ritos só de `summon`, Abrahadabra segurada — ajustes de bot devem ser medidos antes/depois sem tocar em cartas.
