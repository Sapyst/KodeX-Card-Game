# Revisão do deck Cristianismo (`cri`)

Revisão sênior de design e pesquisa, feita após a atualização da tabela §10 de `docs/regras.md` e da DSL (`defender`, `other_ally_entities`, `summon n/keywords`, semântica de `usos`, Sacrifício = morte sem Renascer). Todas as 28 cartas tiveram o orçamento refeito; `validar.py` → OK.

## Carta a carta

| # | Carta | Conta nova (P / gasto) | O que mudou e por quê |
|---|---|---|---|
| 01 | Anjo da Guarda | 5 / 5 | ok |
| 02 | Jonas | 5 / 5 | Papel: removida a ideia de "segundo Renascer" com o Véu (keywords não acumulam) e de sacrificá-lo ao Leviatã (Sacrifício não aciona Renascer). |
| 03 | Davi, o Pastor | 5 / 5 | Balanço reescrito citando `on_attack` como gatilho repetível (valor cheio); nota para o simulador sobre matar o alvo antes do combate. |
| 04 | Lázaro de Betânia | 7 / 7 | Papel: removido "Véu = volta duas vezes"; apontada a sinergia correta (Arca; Tumba Vazia só depois de gastar Renascer). |
| 05 | Judite | 7 / 6,8 | Pesquisa: a citação "não foi a tua força..." não existe no texto; trocada por Jt 16,5 ("pela mão de uma mulher"). |
| 06 | Gabriel | 7 / 7 | ok |
| 07 | Rafael | 7 / 7 | Pesquisa: anotado que Jo 5,4 é versículo ausente dos manuscritos mais antigos. |
| 08 | Sansão | 9 / 9 | Papel: removida a falsa sinergia com Juízo Final (inimigas já destruídas quando o Último Sopro resolve); adicionada a sinergia real com o Sacrifício do Leviatã (conta como morte). |
| 09 | Serafim | 11 / 11 | Balanço: Silence agora tabelado (2), conta igual. |
| 10 | Leviatã | 13+2 / 15 | Pesquisa: "quarenta versículos" → "mais de trinta" (Jó 40,25–41,26). Papel: oferendas corretas (Osso Erguido, Anjo ferido, Sansão), Jonas/Lázaro **não** (sem Renascer no Sacrifício); Tumba Vazia não dispara no sacrifício. |
| 11 | Elias | 13+2 / 15 (Lendária +2) | Papel: removido "Renascer extra com o Véu". |
| 12 | São Miguel Arcanjo | 15+2 / 17 (Lendária +2) | Pesquisa: psicostasia atribuída à iconografia (apoiada na LA), não à LA diretamente. |
| 13 | Cova dos Leões | 3+1 / 4 | JSON: alvo `triggering` → `defender` (a DSL nomeia `defender` como a aliada em `ally_damaged`). |
| 14 | Tumba Vazia | 5+1 / 4,8 (pior caso 6,5) | Balanço refeito com média real das Entidades (51/14); removido o ×0,7 duplicado. Papel: só dispara no turno do oponente (não com Juízo Final nem Sacrifício). Mantida em 2 Fé, com ponto de observação. |
| 15 | Portão do Éden | 5+1 / 4,5 | Pesquisa: em Milton quem guarda o Éden é **Gabriel** (IV); Uriel é regente do Sol (III). Balanço: Freeze tabelado (1,5). Papel: nota sobre Furtivo × `triggering`. |
| 16 | Mudez de Zacarias | 5+1 / 4,5 | ok |
| 17 | **Sangue nos Umbrais** (ex-Anjo Exterminador) | 7+1 / 6 | **Tipo**: o Anjo Exterminador é um *ser* (→ Entidade); a mecânica é proteção/juízo passivo (→ Selo). Resolvido renomeando a carta para a **marca** de Ex 12,23 — arquivo, id e nome; contexto reescrito; nota de que `enemy_attacks` não dispara em ataque à Cornucópia. Mecânica inalterada. |
| 18 | Multiplicação dos Pães | 5 / 4 | ok |
| 19 | Exorcismo | 5 / 4 | ok |
| 20 | Praga dos Gafanhotos | 5 / 5 | ok |
| 21 | Talita Cumi | 7 / 4,8 (pior caso 6,5) | Balanço com média real; linha Miguel marcada para o simulador. |
| 22 | Vale dos Ossos Secos | 7 / 5,6 | Pesquisa: referência duvidosa ao Livro de Horas de Jean de Berry trocada por Paris gr. 510 (Homilias de Gregório). Papel: tokens como oferenda do Leviatã. |
| 23 | Granizo e Fogo | 7 / 6,5 | ok |
| 24 | Juízo Final | 9 / **7,2** | **Orçamento**: destroy 4 × 2 inimigas × 0,7 simétrico = 5,6, abaixo de P−2. Fortalecida (não barateada): "+ uma Entidade aleatória do seu cemitério volta à mão" (2 × 0,8 = 1,6). Tema: o Juízo pressupõe a ressurreição (Jo 5,28-29; Dn 12,2). Papel: Tumba Vazia não dispara; Sansão não rende. |
| 25 | Funda de Davi | 3+1 / 4 | Balanço: `equipped_attacks` repetível sem Usos = valor cheio; nota Davi+Funda. |
| 26 | Véu de Verônica | 5+1 / 5 | Papel: Renascer **não** acumula em quem já tem; alvos corretos (Sansão, Judite, Serafim, Miguel). |
| 27 | Santo Graal | 5+1 / 5 | Balanço explicitado (cura por ataque repetível = valor cheio). |
| 28 | Arca da Aliança | 7+1 / 7 | Balanço: aura `static` +1 ATK tabelada (3). |

Nenhuma carta ficou acima de P (Lendárias em P+2 exato) nem abaixo de P−2 depois das correções. Textos ≤ 30 palavras e iguais ao JSON em todas.

## Erros de pesquisa encontrados

1. **Milton / Uriel** (15 e `_estudo` §1.4): *Paraíso Perdido* põe Gabriel no comando da guarda do Éden (livro IV); Uriel é o regente do Sol (livro III). Corrigido nos dois lugares.
2. **Judite** (05): a frase citada entre aspas não está no livro. Substituída por Jt 16,5.
3. **Leviatã** (10): a descrição em Jó tem ~34 versículos (40,25–41,26), não "quarenta".
4. **Ezequiel 37 na arte** (22): não há base firme para o Livro de Horas de Jean de Berry; trocado por Dura-Europos + Paris gr. 510.
5. **Miguel / Legenda Áurea** (12): a pesagem das almas é iconográfica; a LA fala de Gargano, do Anticristo e das almas, não da balança. Ajustada a atribuição.
6. **Jo 5,4** (07): versículo textualmente duvidoso; anotado.

## Erros de regra encontrados (texto de apoio)

- "Segundo Renascer" via Véu em Jonas, Lázaro e Elias (02, 04, 11, 26): keywords são conjunto, não acumulam.
- Sacrificar Jonas ao Leviatã "que volta para a mão" (10): Sacrifício conta como morte mas **não** aciona Renascer.
- Tumba Vazia disparando com o próprio Juízo Final (24, `_deck`): Selos só disparam no turno do oponente.
- Sansão + Juízo Final como sinergia (08): as inimigas já se foram quando o Último Sopro resolve.

## Sanidade do deck

Dano direto total 1 (≤ 8) · `counter` 1 (≤ 3) · `destroy` escolhido 2 (≤ 4) · sem combo letal no turno 3–4 · Selos com gatilhos reais · resposta a tokens: 4 áreas + Juízo · resposta a Furtivo: áreas, Juízo, Sangue nos Umbrais (`attacker`). Tabela completa em `_deck.md`.

## 3 pontos para o simulador observar

1. **Reviver Miguel** — Talita Cumi (3 Fé) ou Tumba Vazia (2 Fé) devolvendo um 6/6 Guarda com Despertar "destrói" (pior caso 6,5 pts numa carta de 6). Se a linha dominar as partidas longas, subir Tumba Vazia para 3 Fé ou dar a Miguel `cond` no Despertar.
2. **Davi + Funda** — 3/2 Ímpeto com 3 de dano direcionado por ataque, por 3 Fé totais no turno 3; e a dúvida de motor: se `on_attack` mata o alvo antes do combate, Davi não sofre dano de volta. Medir quantas Entidades inimigas ele remove por partida.
3. **Juízo Final + Renascer** — depois da mudança (destroy all + revive aleatório para a mão), medir o saldo de corpos no turno seguinte: o deck cristão deveria ficar com 1–3 cartas a mais na mão que o oponente, não com o campo refeito de graça. Também fixar a leitura de Furtivo contra `triggering` no Portão do Éden (acerta ou pula?).
