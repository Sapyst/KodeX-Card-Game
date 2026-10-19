# Deck Cristianismo — `cri`

## Identidade mecânica

**Ressurreição e julgamento.** O deck cristão não corre: ele *persiste*. Suas Entidades voltam — por **Renascer** (Jonas, Lázaro, Elias; o Véu de Verônica o concede a quem não tem), por Ritos que revivem direto para o campo (Talita Cumi) ou pelo Selo que reabre a tumba quando um aliado cai no turno do oponente (Tumba Vazia). Quem volta ao campo volta como corpo: reviver não dispara Despertar (regras §8) — o julgamento de Miguel e o fogo de Elias acontecem uma vez por invocação da mão. Anjos com **Guarda** (Anjo da Guarda, Serafim, Miguel, Arca) seguram a linha enquanto a cura (Rafael, Santo Graal, Multiplicação dos Pães, Cova dos Leões, Leviatã) devolve Vida às Entidades e à Cornucópia. É um deck de atrito: você perde pouco de cada vez e recupera o que perdeu.

A remoção é **"justa"**: condicional ou tardia. Judite só decapita quem custa ≤ 3; Sangue nos Umbrais só fere quem atacou; Miguel é Lendária de custo 7; o Juízo Final destrói *todas* as Entidades — inclusive as suas, que voltam por Renascer e, uma delas, pelo próprio Rito (Tumba Vazia **não** dispara no seu turno). O Exorcismo não mata: devolve à mão. As pragas do Egito (Gafanhotos, Granizo e Fogo), Sansão e Elias são o dano em área, e o dano direto à Cornucópia aparece numa única carta (1 ponto). Busca: só Gabriel. O deck sofre contra agressão rápida antes do turno 3 e contra `silence` nas suas Entidades com Renascer; brilha em partidas longas e contra decks que apostam tudo em uma Entidade grande.

## Lista das 32 cartas

| # | Carta | Tipo | Custo | Cópias |
|---|---|---|---|---|
| 01 | Anjo da Guarda | Entidade | 2 | ×2 |
| 02 | Jonas | Entidade | 2 | ×1 |
| 03 | Davi, o Pastor | Entidade | 2 | ×1 |
| 04 | Lázaro de Betânia | Entidade | 3 | ×2 |
| 05 | Judite | Entidade | 3 | ×1 |
| 06 | Gabriel, o Mensageiro | Entidade | 3 | ×1 |
| 07 | Rafael, o Curador | Entidade | 3 | ×1 |
| 08 | Sansão | Entidade | 4 | ×1 |
| 09 | Serafim | Entidade | 5 | ×1 |
| 10 | Leviatã | Entidade (Sacrifício 1) | 6 | ×1 |
| 11 | Elias, Carro de Fogo | Entidade **Lendária** | 6 | ×1 |
| 12 | São Miguel Arcanjo | Entidade **Lendária** | 7 | ×1 |
| 13 | Cova dos Leões | Selo | 1 | ×1 |
| 14 | Tumba Vazia | Selo | 2 | ×2 |
| 15 | Portão do Éden | Selo | 2 | ×1 |
| 16 | Mudez de Zacarias | Selo | 2 | ×1 |
| 17 | Sangue nos Umbrais | Selo | 3 | ×1 |
| 18 | Multiplicação dos Pães | Rito | 2 | ×1 |
| 19 | Exorcismo | Rito | 2 | ×1 |
| 20 | Praga dos Gafanhotos | Rito | 2 | ×1 |
| 21 | Talita Cumi | Rito | 3 | ×2 |
| 22 | Vale dos Ossos Secos | Rito | 3 | ×1 |
| 23 | Granizo e Fogo | Rito | 3 | ×1 |
| 24 | Juízo Final | Rito | 4 | ×1 |
| 25 | Funda de Davi | Relíquia | 1 | ×1 |
| 26 | Véu de Verônica | Relíquia | 2 | ×1 |
| 27 | Santo Graal | Relíquia | 2 | ×1 |
| 28 | Arca da Aliança | Relíquia | 3 | ×1 |

28 cartas distintas, 32 no deck.

## Contagem por tipo

| Tipo | Qtd. |
|---|---|
| Entidade | 14 |
| Selo | 6 |
| Rito | 8 |
| Relíquia | 4 |

## Curva de custo das Entidades

| Faixa | Qtd. | Cartas |
|---|---|---|
| 1–2 | 4 | Anjo da Guarda ×2, Jonas, Davi |
| 3–4 | 6 | Lázaro ×2, Judite, Gabriel, Rafael, Sansão |
| 5–6 | 3 | Serafim, Leviatã, Elias (L) |
| 7–8 | 1 | São Miguel Arcanjo (L) |

Lendárias: **Elias** (6, P+1) e **São Miguel Arcanjo** (7, P+2).

## Gatilhos e ações usados (variedade)

Entidade: `on_play` ×6, `on_death` ×3, `on_attack` ×1, `static` ×0, keywords `guarda` ×3, `renascer` ×3, `sacrificio` ×1.
Selo: `ally_damaged`, `ally_dies`, `enemy_plays_entity`, `enemy_plays_rite`, `enemy_attacks`.
Relíquia: `on_equip` ×4, `equipped_attacks` ×2, `static` ×1.
Ações: damage, heal, draw, search, buff, destroy, bounce, summon, revive (hand e field), discard, silence, freeze, counter, give_keyword.

## Sanidade (revisão)

| Limite | Valor no deck |
|---|---|
| Dano direto à Cornucópia (soma) | **1** (Granizo e Fogo) ≤ 8 |
| `counter` | **1** cópia (Mudez de Zacarias) ≤ 3 |
| `destroy` com alvo escolhido | **2** cópias (Judite cond., Miguel) ≤ 4 — mais Sangue nos Umbrais (`attacker`) e Juízo Final (`all_entities`) |
| Combo de 2 cartas que ganhe no turno 3–4 | nenhum (dano direto total 1) |
| Resposta a tokens em massa | Gafanhotos (2 área), Granizo (3 área), Sansão e Elias (2 área), Juízo Final |
| Resposta a Furtivo | área (não escolhe alvo), Juízo Final, Sangue nos Umbrais (ao atacar perde Furtivo e vira `attacker`) |

Selos: todos têm gatilho que acontece de fato em partida normal. `enemy_plays_rite` (Zacarias) é o mais dependente do oponente; `enemy_attacks` (Umbrais) exige ao menos uma Entidade sua em campo.

## Histórico de balanceamento

- **Rodada 1** (ver `sim/relatorios/r1_mudancas.md`). Linha de base pós-motor: 58,0 % de média (62,3 antes da regra nova de Despertar). Mudanças: **São Miguel Arcanjo** 6/6 → **5/6** (com `destroy` a 5 pts a conta era 18, acima do teto lendário); **Elias** 4/6 → **4/5** (P+1); **Judite** 2/2 → **2/1** (`destroy` condicionado vale 3,5 fixo → 6,5/7). **Tumba Vazia** fica em 2 Fé: a proposta de subir para 3 era motivada pelo laço "Miguel morre → Tumba → destrói de novo", desfeito pela regra nova. Recontas sem mudança de carta: Juízo Final 8,6/9, Sangue nos Umbrais 7/8. Leviatã (Vida 7 → 6) fica para a rodada 2 se o deck seguir acima de 58 %. Lista das 32, distribuição e curva inalteradas.
