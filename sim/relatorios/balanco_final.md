# Gods Kodex — Balanço final (3 rodadas Analista × Balanceador)

Estado: seis decks de 32 cartas, motor `sim/` (58 testes), HeurBot. Veredito do Analista (`r3_analise.md`): **pronto para playtest humano**. Todas as metas primárias fecham em quatro seeds independentes (11–14): média de cada deck em 42–58, todos os 15 confrontos em 30–70, nenhuma carta fora de ±12 no espelho pela WR comprada, nenhuma carta com "ficou na mão" > 35 %.

Validação final: `python3 sim/validar.py cartas/<cultura>` → `OK` nas seis pastas; `python3 -m unittest discover -s tests` → 58 `OK`.

Relatórios do processo: `r1_analise.md` → `r1_mudancas.md` → `r2_analise.md` → `r2_mudancas.md` → `r3_analise.md` → este arquivo. Dados: `r1_pos_motor.json`, `r1_pos_mudancas.json`, `r2_pos_mudancas_s11|s12.json`, `r3_matriz_seed13|14.json`, `espelhos_r1/`, `espelhos_r2_pos/`, `espelhos_r3/`, `r3_final/` (verificação do Shiva 5/5).

---

## 1. O processo em três rodadas

**Rodada 1 — bugs de motor, tabela §10 e as Lendárias.** A primeira matriz (`r1_analise`) deu hinduismo 83 %, alta magia 19 %, 11 dos 15 confrontos fora de 30–70. O Analista achou um bug (`on_damaged` feria o próprio atacante: Curupira e Mapinguari se matavam) e duas divergências texto × motor (Azoth dava Fé agora; Furtivo não escapava de `triggering`), e apontou duas causas sistêmicas: `destroy` barato na tabela (4 pts: todas as cartas "Despertar: destrói" lideravam seus decks) e revive para o campo repetindo o Despertar (Tumba/Talita → Miguel, Pílula/Pássaro → Xiwangmu, Caldeirão → Hécate). As duas viraram **regra** (§4). Com o motor corrigido, o Balanceador recontou as 11 cartas com `destroy` (sete estouravam) e aplicou 14 das 24 propostas, recusando as motivadas pelos laços de revive que a regra nova já desfazia. Alta magia subiu de 20 para 37 % (quatro compras a menos: fadiga de 54 % para 8 % das partidas); o hinduismo caiu só de 84 para 80 % mesmo com seis cortes — sinal de que a força não estava em carta nenhuma.

**Rodada 2 — o diagnóstico estrutural e a métrica certa.** O Analista mediu 40 variantes do hinduismo em cópias: tirar Ímpeto **fortalecia** o deck (+4 pp); a aura de Krishna valia 0; nenhuma carta isolada valia mais de 2 pp; mas o deck tinha 17 cartas que ferem ou destroem Entidades (os outros 1–11) e as quatro Relíquias davam +16 de stats. Um `DefBot` que bloqueia mostrou que o 80 % não era artefato do bot. Entregou também a métrica **WR comprada** (WR da partida em que a carta chegou à mão), que tirou o viés de sobrevivência: Hécate caía de 70 para 57 %, Shiva de 72 para 55 — Lendárias caras eram sintoma de partida longa, não causa de vitória. Três pacotes testados antes de tocar no oficial: **H1** (13 cartas do hinduismo, 1 ponto em cada, Ímpeto preservado), **CB3** (bruxaria: ferramentas dos familiares, não as Lendárias) e **CA3** (alta magia: corpo e Fé). O Balanceador aplicou os três com dois desvios de forma (Pashupatastra em custo 3 por regra de §10; Garrafa sem cura por identidade), portou a métrica para o `duel.py`, e — com o hinduismo em 58,5 / 57,2 no teto — acrescentou a metade leve do pacote H2 (Tandava área 3 → 2). Resultado: seis médias em 42–58 e zero confrontos fora nas seeds 11 e 12, reproduzindo a previsão do Analista dentro de ±1,6 pp.

**Rodada 3 — confirmação e fechamento.** Seeds novas (13, 14) confirmaram tudo (variação ≤ 3,6 pp por célula entre quatro seeds). Os dois critérios secundários que ficaram fora foram medidos a fundo e **deixados como traço de identidade**: a vantagem de quem começa nos confrontos do hinduismo (57–60 %; espelho 63 %) vem do Ímpeto distribuído, e a única regra que a corrige (+2 Fé ao 2º jogador) inverte o viés nos outros decks; a duração dos confrontos do cristianismo (14–16 rodadas; espelho 17) vem de Guarda + Renascer + revive contra um bot que só ataca quando mata, e cortar cura não muda nada (−0,1 rodada). Única mudança de carta: Shiva Nataraja 5/6 → 5/5, a única carta ainda destoante no espelho depois de o resto do deck baixar. Verificação (seed 13, n = 2000): espelho hinduismo 8,8 rodadas, Shiva 69 % jogada / 60 % comprada; hinduismo × alta magia 65,9 / 34,1 — o confronto mais apertado continua acima de 30.

---

## 2. Matriz final (seeds 13 / 14, n = 2000 por confronto; linha vence coluna)

| | alta_magia | bruxaria | cristianismo | hinduismo | indigena | taoismo | **média** |
|---|---|---|---|---|---|---|---|
| **alta_magia** | — | 50,2 (49,6) | 51,3 (51,1) | 34,1 (35,6) | 52,9 (53,2) | 50,3 (49,5) | **47,8** (47,8) |
| **bruxaria** | 49,8 (50,4) | — | 40,6 (41,5) | 44,4 (40,8) | 51,0 (50,9) | 55,6 (55,5) | **48,3** (47,9) |
| **cristianismo** | 48,7 (48,9) | 59,5 (58,5) | — | 51,6 (50,4) | 65,7 (62,7) | 52,4 (52,0) | **55,6** (54,5) |
| **hinduismo** | 65,9 (64,3) | 55,6 (59,2) | 48,4 (49,6) | — | 50,7 (48,6) | 54,9 (54,2) | **55,1** (55,2) |
| **indigena** | 47,1 (46,8) | 49,0 (49,0) | 34,3 (37,2) | 49,3 (51,4) | — | 52,1 (50,3) | **46,4** (47,0) |
| **taoismo** | 49,6 (50,4) | 44,4 (44,5) | 47,5 (47,9) | 45,1 (45,8) | 47,9 (49,6) | — | **46,9** (47,6) |

(Matriz medida com Shiva 5/6; com 5/5 o Analista estima −1 a −2 pp no hinduismo; a verificação pontual em `r3_final/` confirmou hinduismo × alta 65,9 e espelho inalterado.)

Trajetória das médias (seed 11): 

| Deck | r1 análise | pós-motor | pós-r1 | pós-r2 | **r3 (s13/s14)** |
|---|---|---|---|---|---|
| hinduismo | 83,2 | 84,2 | 79,6 | 56,5 | **55,1 / 55,2** |
| cristianismo | 62,3 | 58,0 | 53,0 | 55,0 | **55,6 / 54,5** |
| taoismo | 48,9 | 46,8 | 44,6 | 46,2 | **46,9 / 47,6** |
| bruxaria | 46,8 | 46,5 | 40,9 | 48,3 | **48,3 / 47,9** |
| indígena | 39,4 | 44,6 | 45,0 | 47,8 | **46,4 / 47,0** |
| alta magia | 19,4 | 19,9 | 36,8 | 46,2 | **47,8 / 47,8** |
| confrontos fora de 30–70 | 11 | 9 | 5 | 0 | **0 / 0** |

Metas secundárias (ambas aceitas como identidade, ver §1 e §6): quem começa > 55 % em hinduismo × taoismo (59,5), × alta (57–59), × indígena (55–56), espelho hinduismo 63 %, espelho alta 56–57 %; duração > 14 rodadas em cristianismo × indígena (16), × taoismo (14,8), × alta (14,6–14,8), × bruxaria (14,0), espelho cristão 17,1, espelho indígena 14,9.

---

## 3. Cartas por deck — 5 maiores e 5 menores WR comprada (s13 + s14, do `r3_analise` §3)

"Comprada" = WR da partida em que a carta chegou à mão, jogada ou não (sem viés de sobrevivência). "Jogada" entre parênteses quando diverge.

| Deck (média) | Maiores | Menores |
|---|---|---|
| **hinduismo** (55,2) | Shiva **63,3** (67,0) · Ganesha 57,6 · Durga 56,1 · Kali 56,0 · Véu de Maya 55,9 | Sudarshana 50,5 (53,7) · Chamas de Agni 50,7 · Vishvarupa 51,4 (46,3) · Gandiva 51,7 · Lanka 52,0 |
| **cristianismo** (55,0) | Elias **68,1** (71,3) · Miguel **67,7** (71,6) · Sansão 63,3 · Gabriel 60,9 · Multiplicação dos Pães 60,9 | Anjo da Guarda 55,5 · Santo Graal 55,8 · Talita Cumi 56,0 · Davi 56,5 · Funda 56,6 |
| **bruxaria** (48,1) | Morrigan 57,4 · Cerridwen 57,1 · Medeia 53,2 · Circe 53,2 · Bruxa de Endor 52,7 | Boneco de Cera 46,2 (43,2) · Pacto 46,7 · Mau-Olhado 47,6 · Sapo 47,6 (43,5) · Poção 47,7 |
| **indígena** (46,7) | Tupã 53,3 · Cobra-Grande 50,3 · Jaci 48,7 · Visão do Caapi 48,4 · Iara 48,0 | Ibirapema 44,3 · Matinta 45,0 · Saci 45,2 (41,7) · Dança do Aruanã 45,3 (38,1) · Muiraquitã 45,4 |
| **alta_magia** (47,8) | Dantalion 51,8 (62,9) · Andras 50,8 · Ritual Menor 50,7 · Paimon 50,3 · Conjuração 49,9 | Sigillum 47,8 · Astaroth 47,9 · Orobas 48,0 · Azoth 48,3 · Pentagrama 48,3 |
| **taoismo** (47,3) | Xiwangmu 52,7 · Imperador de Jade 52,0 · Guan Yu 51,8 · Zhang Guolao 51,3 · Nezha 51,1 | Dragão Azul 45,4 · Espelho de Bronze 46,4 · Cao Guojiu 47,0 · Li Tieguai 47,0 · Han Xiangzi 47,4 |

Em quatro decks a amplitude é ≤ 8 pp (deck coeso). Cristianismo e hinduismo têm as Lendárias 12–13 pp acima da média do deck — o "momento uau" previsto pela regra Lendária ≤ P+2. No espelho, nenhuma carta sai de ±12 (Shiva 60, Miguel/Elias 57–58).

---

## 4. Todas as mudanças de carta (original → final)

Conta §10 final entre colchetes; P = 2·C+1 (+1 Selo/Relíquia, +2·N Sacrifício, Lendária até P+2).

### Hinduismo (18 cartas distintas alteradas)

| Carta | Original | Final | Rodada |
|---|---|---|---|
| Shiva Nataraja (L, 7) | 6/6 Ímpeto, Despertar: destrói | **5/5** Ímpeto, destrói [16/17] | r1 (5/6), r3 (5/5) |
| Kali (L, 6) | 4/5; Despertar: 2 em área; +1 ATK por inimiga morta | **4/5; Despertar: 1 em área**; +1 ATK por inimiga morta [13,5/15] | r1 (4/4), r2 (4/5, área 1) |
| Garuda ×2 (2) | 2/1 Ímpeto; Despertar: 1 a inimiga aleatória | **1/2 Ímpeto** (sem Despertar) [4/5] | r1 (1/2), r2 (sem ping) |
| Hanuman ×2 (4) | 3/3 Ímpeto; +1 ATK ao atacar | **3/2** Ímpeto; +1 ATK ao atacar [8/9] | r2 |
| Krishna (5) | 4/4; aura: aliadas têm Ímpeto | **3/4**; aura [10/11] | r2 |
| Narasimha (4) | 3/3; Despertar: destrói custo ≤ 3 | **3/2**; destrói custo ≤ 3 [8,5/9] | r1 |
| Brahmastra (Rito) | custo 3; destrói + 2 em área | **custo 3; só destrói** [5/7] | r1 (custo 4), r2 (custo 3 sem área) |
| Tandava (Rito 5) | 3 em área + 3 direto | **2 em área** + 3 direto [9/11] | r2 |
| Pashupatastra (Selo 3) | atacante destruído + 2 em área | atacante destruído **+ compre 1** [6,5/8] | r2 |
| Lei do Karma (Selo 2) | 4 ao atacante + compra | **3** ao atacante + compra [4,5/6] | r2 |
| Chamas de Agni (Selo 1) | 2 à Entidade invocada + 1 direto | **1** à Entidade + 1 direto [3/4] | r2 |
| Incêndio de Lanka (Selo) | custo 2; 2 em área + 1 direto | **custo 1; 1 em área** + 1 direto [3,5/4] | r2 |
| Vajra (Rel 2) | +2/+1; 3 de dano ao equipar | **+2/+0; 2 de dano** [4/6] | r1 (2 dano), r2 (+2/+0) |
| Sudarshana Chakra (Rel 3) | +2/+1 Ímpeto; 2 de dano por ataque | +2/+1 Ímpeto; **1** por ataque [6/8] | r2 |
| Gandiva (Rel 3) | +3/+2; 1 em área por ataque | **+3/+1**; 1 em área por ataque [7/8] | r2 |
| Trishula (Rel 4) | +3/+2; 1 por ataque; 2 em área ao morrer | **+3/+1**; idem [9/10] | r2 |
| Descida do Avatar (Rito 3) | texto | texto: revive sem Despertar (regra) | r1 |
| Dano direto do deck | 5 | 5 (Agni 1, Lanka 1, Tandava 3) | — |

### Cristianismo (3 cartas alteradas; 4 textos)

| Carta | Original | Final | Rodada |
|---|---|---|---|
| São Miguel Arcanjo (L, 7) | 6/6 Guarda; Despertar: destrói | **5/6** Guarda; destrói [17/17] | r1 |
| Elias (L, 6) | 4/6 Renascer; Despertar: 2 em área | **4/5** Renascer; 2 em área [14/15] | r1 |
| Judite (3) | 2/2; Despertar: destrói custo ≤ 3 | **2/1**; destrói custo ≤ 3 [6,5/7] | r1 |
| Tumba Vazia ×2, Talita Cumi ×2 | texto "volta com Despertar" | texto: revive sem Despertar (regra); custo mantido | r1 |
| Juízo Final, Sangue nos Umbrais | Balanço com `destroy` 4 | reconta com 5 (8,6/9 e 7/8), sem mudança | r1 |

### Bruxaria (7 cartas alteradas)

| Carta | Original | Final | Rodada |
|---|---|---|---|
| Hécate (L, 7, Sac 1) | 6/7; Despertar: inimigas −2/−2 | **5/7**; −2/−2 [18/19] | r1 |
| Baba Yaga (5, Sac 1) | 4/5; Despertar: destrói | **3/5**; destrói [13/13] | r1 |
| Boneco de Cera (Selo 3) | 3 ao atacante e −2/−2 | **4** ao atacante e −2/−2 [8/8] | r1 |
| Malefício ×2 (Rito 3) | −2/−2 e silêncio | **−3/−2** e silêncio [7/7] | r2 |
| Vassoura ×2 (Rel 1) | +1/+1, Ímpeto | **+1/+2**, Ímpeto [4/4] | r2 |
| Sabá de Walpurgis (Rito 4) | aliadas +1/+1; Lebre 1/1 | aliadas +1/+1; **Lebre 1/2** [9/9] | r2 |
| Livro das Sombras (Rel 2) | Usos 3 | **Usos 4** [5,6/6] | r2 |
| Caldeirão de Renascimento | texto | texto: revive sem Despertar (regra) | r1 |

### Alta magia (10 cartas alteradas)

| Carta | Original | Final | Rodada |
|---|---|---|---|
| Babalon (L, 6, Sac 1) | 4/6; +1/+1 por morte | **5/6**; +1/+1 por morte [17/17] | r2 |
| Paimon (6) | Sacrifício 1; Despertar: 2 Espíritos 1/1 + compre 1 | **sem Sacrifício**; 2 Espíritos 1/1 [13/13] | r1 |
| Andras (4) | 3/3; Despertar: destrói custo ≤ 2 | **3/2; destrói custo ≤ 3** [8,5/9] | r1 |
| Edward Kelley (2) | 0/2 Furtivo; busca Relíquia | **1/1** Furtivo; busca Relíquia [5/5] | r1 |
| Abrahadabra (Rito) | custo 4; 3 direto + compre 1 | **custo 3; 3 direto** [6/7] | r1 |
| Azoth ×2 (Rito 3) | +1 Fé máx.; compre 1 | +1 Fé máx.; **+1 Fé neste turno**; compre 1 [7/7] | r2 |
| Conjuração dos Elementais ×2 (Rito) | custo 3; três 1/1 | **custo 2; dois 1/1** [4/5] | r1 |
| Pedra de Visão ×2 (Rel 1) | +0/+2; compre 1 | **+1/+3** [4/4] | r1 (+1/+2), r2 (+1/+3) |
| Anel de Salomão (Rel 2) | +1/+1 Ímpeto; silencia ao atacar | **+1/+2** Ímpeto; silencia [6/6] | r2 |
| Pentagrama Flamejante ×2 (Selo 2) | anula Rito + compre 1 | anula Rito + compre 1 **+ cura 2** [5,5/6] | r2 |
| Selo de Salomão | Balanço com `destroy` 4 | reconta com 5 (7,5/8), sem mudança | r1 |

### Indígena (3 cartas alteradas)

| Carta | Original | Final | Rodada |
|---|---|---|---|
| Boitatá ×2 (4) | Guarda; `ally_attacked` → 1 ao atacante | Guarda; **`on_damaged`** → 1 ao atacante [9/9] | r1 |
| Dança do Aruanã (Rito 2) | dois Aruanãs 1/1 | dois Aruanãs 1/1 **+ cura 2 Cornucópia** [5/5] | r1 |
| Mundéu ×2 (Selo 2) | 4 ao atacante; cura 2 | 4 ao atacante; **cura 4** [6/6] | r1 |
| Kuarup | texto | texto: revive sem Despertar (regra) | r1 |

### Taoismo — nenhuma carta alterada

Só textos (Pílula de Ouro, Pássaro Vermelho do Sul, Xiwangmu, convenção em `_deck.md`): revive para o campo devolve corpo, não Despertar. Reservas (`_reserva/`) não usadas.

**Propostas recusadas pelo Balanceador** (com justificativa nos relatórios): Tumba Vazia custo 3 e Caldeirão para a mão (r1: a regra de Despertar já desfez os laços); Garrafa + cura 2 (r2: identidade "bruxaria não cura Cornucópia", +0,4 pp); Pashupatastra custo 2 (r2: §10 exige custo mínimo 3 para `destroy`). **Adiadas e depois descartadas pela medição**: Leviatã 6/6, Terra sem Males cura 6, Cocar +4, Durga 4/4, Krishna aura `other_ally`, Multiplicação dos Pães / Cova dos Leões reduzidas, Benandante 3/3 e Gato 1/2 (estouram P).

---

## 5. Decisões de regra tomadas pelo balanceamento

Registradas em `docs/regras.md`, `docs/dsl_efeitos.md` e `sim/README.md`; o motor as implementa e os testes as cobrem.

1. **Reviver para o campo não dispara Despertar** (`regras.md` §8; `revive para: field` não dispara `on_play` nem `enemy_plays_entity`). Motivo: Tumba Vazia/Talita Cumi → Miguel destruía de novo; Pílula/Pássaro → Xiwangmu revivia outra; Caldeirão → Hécate dava outro −2/−2; Descida do Avatar → Shiva por 3 Fé. A regra tirou 4 pp do cristianismo e 2 do taoismo sem tocar em carta e mudou a leitura de "descida renovada" do hinduismo (o avatar volta como corpo). Reviver para a **mão** e reinvocar continua disparando Despertar (Zhongli Quan, Bruxa de Endor).
2. **`destroy` escolhido vale 5 pts** (era 4); com `target_cost_max` ≤ 3 vale 3,5 fixo (não 4 × 0,7); custo mínimo da carta 3. Motivo: todas as cartas "Despertar: destrói" lideravam seus decks. Sete cartas estouraram e perderam 1 de corpo (Shiva, Miguel, Baba Yaga, Narasimha, Judite, Andras) ou subiram de custo (Brahmastra, depois reequilibrada). `attacker` em Selo é contado como escolhido (Sangue nos Umbrais, Pashupatastra).
3. **`gain_fe perm: true` sobe só a Fé máxima** (a Fé atual vem no próximo turno). Motivo: Azoth custava 2 na prática. Na rodada 2 a carta ganhou "+1 Fé neste turno" explícito no texto — a mecânica ficou no texto, não escondida no motor.
4. **Furtivo escapa de efeitos inimigos que o apontem por `triggering`** (Selo `enemy_plays_entity` → `destroy/damage triggering`). Motivo: Portão do Éden matava Gato Preto Furtivo ao entrar; o texto da palavra-chave diz "não pode ser alvo de Selos". `all_*` continua atingindo Furtivos (não é alvo).
5. **O contragolpe do defensor num ataque não tem `attacker`**: uma Entidade com "ao sofrer dano, fere o atacante" (`on_damaged → damage attacker`) não se fere ao atacar. Motivo: bug — Curupira e Mapinguari se matavam ao atacar (589–724 disparos autoinfligidos por 400 partidas). Indígena subiu 5 pp só com isso; Boitatá passou a usar o mesmo gatilho.

Convenções de orçamento consolidadas nas rodadas (em `_deck.md`): gatilho repetível sem Usos a cada ataque = unitário × 2; `enemy_dies`/`ally_dies` em Lendária = 3 disparos típicos; debuff em área = 1,5 por ponto (analogia com dano em área); Selo/Relíquia +1 grátis substitui o ×0,7 de condicional; faixa aceita [P−2, P], Lendária até P+2.

---

## 6. Limitações conhecidas do HeurBot (não mudar cartas por elas)

- **Nunca ataca em troca ruim** (morre sem matar) e **só ataca a Cornucópia com o campo inimigo vazio** (regra). Consequências: muros de Guarda + cura travam o jogo (confrontos do cristianismo em 14–17 rodadas; espelho indígena 15); decks de Ímpeto ganham por chip antes de o muro existir (quem começa 57–63 % nos confrontos do hinduismo). Um `DefBot` que bloqueia sob pressão não mudou as cifras do hinduismo — na regra atual a defesa é ter corpo, e o hinduismo remove corpos. Um humano pode trocar pior de propósito para proteger a Cornucópia; é o que o playtest deve testar.
- **`set_stats` em aliada** (Vishvarupa) escolhe a maior aliada (Durga 4/5 vira 6/6): Vishvarupa aparece como a pior carta do hinduismo (46 % jogada, 51 comprada) por artefato. Sugestão: escolher a de menor ATK+Vida que pode atacar.
- **Ritos só de `summon` valem 2,0 na pontuação**, abaixo de qualquer Entidade: Conjuração dos Elementais (28 % na mão) e Dança do Aruanã (38 % jogada / 45 comprada) ficam na mão por prioridade, não por fraqueza. Sugestão: 1,0 × tokens invocáveis.
- **Segura fecho direto** (Abrahadabra jogada na rodada 9–11, 25 % na mão): o bot prefere Entidades a dano direto; um humano fecha antes.
- **Mulligan** devolve só custo ≥ 4; **descarte** da mão cheia é a carta mais cara; **busca** é a carta mais cara jogável no próximo turno. Todos razoáveis, nenhum ótimo.
- Qualquer ajuste de bot deve ser medido com a matriz antes e depois (seeds 11–14) para separar efeito de bot de efeito de carta.

---

## 7. O que observar no playtest humano

1. **Duração com relógio.** O bot dá 9–17 rodadas; a meta de produto é 5–10 min. Medir especialmente cristianismo × indígena, cristianismo × taoismo e o espelho cristão (as partidas mais longas). Se passarem de 10 min, a alavanca é o **atrito** do cristianismo (Guarda ×5, Renascer ×3, revive ×4), não a cura — cortar cura foi medido e não encurta nada.
2. **Quem começa no hinduismo.** 57–63 % no bot. O humano que começa com Garuda + Vajra no turno 2 sente a corrida? O que vai do outro lado consegue bloquear trocando pior? Se o espelho humano passar de 60 %, a opção medida é aceitar (identidade) ou revisitar o +1 Fé do 2º jogador só para o 1º turno (a regra +2 inverteu o viés nos outros decks no bot).
3. **Elias e Miguel** (68 % de WR comprada global, 57–58 no espelho): o "uau" do cristianismo. Se o jogador adversário sentir que a partida acaba quando um deles entra, o próximo corte é no corpo (Elias 4/4 ou Miguel 5/5), nunca no Despertar.
4. **Shiva 5/5**: a mudança da rodada 3 foi feita com o bot; no bot ela quase não muda nada (60 % comprada antes e depois). Perguntar se um 5/5 por 7 Fé ainda parece Lendária; se não, voltar a 5/6 (17/17) é legítimo.
5. **Alta magia na mão de um humano.** O deck é o mais dependente de sequência (fodder → pacto → Dantalion rouba). O bot joga os pactos tarde (Dantalion 21 % na mão, Astaroth/Babalon 48 % contra hinduismo). Humano deve fazer melhor; se o deck passar de 55 %, Dantalion (63 % jogada) é o primeiro a olhar.
6. **Cartas que o bot subestima**: Vishvarupa, Conjuração dos Elementais, Dança do Aruanã, Abrahadabra (§6). Se no playtest parecerem fortes, está tudo bem — eram artefato; se parecerem fracas também ao humano, aí sim mexer.
7. **Taoismo** é o deck mais perto do piso (46–48 %) e perde 10 pp para a bruxaria. Se humanos confirmarem, a troca prevista é Bagua de Fuxi (`_reserva/`) no lugar do 2º Taiji; Pílula de Ouro ×2 fica (52 % comprada no espelho).
8. **Textos de Despertar**: conferir se os jogadores entendem que "reviver para o campo" não repete o Despertar (as cartas dizem; a regra está em §8). É a decisão de regra com mais impacto na leitura das cartas.
9. **Furtivo × Selos de entrada** e **contragolpe sem atacante**: duas regras finas; observar se há disputa de interpretação na mesa.
10. **Conjunto do Abismo** (Choronzon + 3 peças) ficou fora do balanceamento por desenho; testar à parte, em cada um dos seis decks.
