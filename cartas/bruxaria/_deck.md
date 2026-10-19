# Deck Bruxaria — identidade e lista

## Identidade mecânica

**Maldições e familiares.** O deck de bruxaria não vence pela força bruta das Entidades: vence encolhendo o oponente. Quase tudo o que ele faz ao inimigo é *reduzir* — `buff` negativo permanente (Malefício, Medeia, Sapo, Hécate), `freeze` (Benandante, Mau-Olhado), `silence` (Malefício), `set_stats` (Circe transforma em porco), `discard` na mão (o olho-gordo do Corvo, Pó de Ossos, Garrafa de Bruxa). Os Selos são **malefícios armados**: a Entidade que o oponente invoca já entra congelada e diminuída; o dano feito a uma aliada volta pelo Boneco de Cera; o Rito inimigo é anulado pela Garrafa. Por outro lado, o próprio campo da bruxa é povoado de **familiares** pequenos e numerosos (Gato Preto com sete vidas, Sapo, Corvo, as Strix da Strega, as Lebres do Sabá, os Corvos da Morrigan): são pontos de ATK baratos, protegem a Cornucópia de ataque direto e — sobretudo — são **moeda de pacto**: Baba Yaga e Hécate exigem Sacrifício 1, e a morte de um familiar ainda dispara efeitos (Último Sopro do Sapo, Corvo da Morrigan — mas **não** Renascer: Sacrifício conta como morte sem acionar Renascer, então o Gato Preto sacrificado não volta).

As **poções** são Ritos baratos de buff/cura (Poção de Beladona), o **Sabá** é o único buff coletivo (`all_ally_entities`), e o **Pacto na Encruzilhada** acelera a Fé para chegar às Entidades grandes. O deck quase não cura a Cornucópia (nenhum efeito de `heal` nela) e não tem **Guarda**: a defesa é fazer o inimigo bater fraco, não absorver. Fraquezas deliberadas: pouco dano direto (sem `damage` à Cornucópia), Entidades médias de corpo modesto, dependência de ter familiares em campo para pagar o Sacrifício. Contra decks de uma Entidade grande, Circe/Baba Yaga/Malefício resolvem; contra enxames de tokens o deck sofre (só Pó de Ossos e Hécate limpam área).

## Valores extras usados no Balanço (além da tabela §10)

A tabela §10 não precifica tudo o que a DSL permite. Convenções adotadas neste deck (a serem afinadas pelo simulador):

Já oficiais na tabela §10 (usados tal qual): `freeze` 1,5 · `silence` 2 · buff "em todas as aliadas" = unitário × 3 · Relíquia com Usos = efeito × N × 0,7 · gatilhos repetíveis (`ally_dies`, `enemy_dies`, `on_damaged`, `ally_attacked`) valem cheio · `bounce` 2 · `search` 2.

| Efeito | Valor |
|---|---|
| −1 ATK permanente a inimigo escolhido / −1 Vida permanente | 1 / 1 (espelho de +1/+1) |
| −1/−1 permanente a **todas** as Entidades inimigas | 3 (1,5 por ponto, por analogia com dano em área — a tabela só precifica o buff em aliadas) |
| `set_stats` inimigo → 1/1 | 3 (menos que um `destroy` de 5: deixa corpo e não some do campo) |
| `give_keyword` | valor da palavra-chave (Ímpeto 1, Furtivo 1) |
| Buff de `on_equip` numa Relíquia **com Usos** (some quando os Usos acabam) | valor × 0,7 |
| `search` sem filtro de custo (tutor) | 2 (tabela) — cartas só com busca ficam 1 pt abaixo do orçamento de propósito: o tutor vale mais na prática |
| Selos: o "+1 grátis" substitui o ×0,7 de condicional (não se aplicam os dois) | — |
| Relíquias: "+1 grátis" idem | — |

Orçamento de Entidade com Sacrifício N: P = 2C + 1 + 2N (+2 se Lendária), como em `sim/validar.py`.

## Lista das 32 cartas

| NN | Carta | Tipo | Custo | ATK/Vida | Cópias | Observação |
|---|---|---|---|---|---|---|
| 01 | Sapo Familiar | Entidade | 1 | 0/1 | ×1 | Último Sopro: inimigo −1/−1 |
| 02 | Gato Preto | Entidade | 2 | 1/1 | ×2 | Furtivo, Renascer |
| 03 | Corvo Agourento | Entidade | 2 | 1/2 | ×1 | Despertar: descarte |
| 04 | Strega de Benevento | Entidade | 3 | 2/3 | ×1 | Despertar: token Strix 1/1 |
| 05 | Benandante | Entidade | 3 | 2/3 | ×2 | Despertar: freeze |
| 06 | Circe | Entidade | 4 | 3/3 | ×1 | Despertar: inimigo vira 1/1 |
| 07 | Medeia, a Envenenadora | Entidade | 4 | 3/4 | ×1 | Despertar: inimigo −2 ATK |
| 08 | A Bruxa de Endor | Entidade | 4 | 2/4 | ×1 | Furtivo; revive à mão |
| 09 | Baba Yaga | Entidade | 5 | 3/5 | ×1 | Sacrifício 1; Despertar: destrói |
| 10 | Cerridwen, Senhora do Caldeirão | Entidade | 5 | 4/4 | ×1 | Despertar: compra 2 |
| 11 | A Morrigan | Entidade | 6 | 5/5 | ×1 | **Lendária**; Ímpeto; Corvos ao morrer alguém |
| 12 | Hécate, Senhora das Encruzilhadas | Entidade | 7 | 5/7 | ×1 | **Lendária**; Sacrifício 1; inimigas −2/−2 |
| 13 | Mau-Olhado | Selo | 1 | — | ×2 | enemy_plays_entity → freeze, −1/−1 |
| 14 | Círculo de Sal | Selo | 2 | — | ×2 | enemy_attacks → bounce, descarte, compra |
| 15 | Garrafa de Bruxa | Selo | 2 | — | ×1 | enemy_plays_rite → counter, descarte |
| 16 | Boneco de Cera | Selo | 3 | — | ×1 | ally_damaged → 4 dano e −2/−2 ao atacante |
| 17 | Poção de Beladona | Rito | 1 | — | ×2 | cura 2, +1/+1 |
| 18 | Pacto na Encruzilhada | Rito | 1 | — | ×1 | +2 Fé temporária |
| 19 | Seiðr | Rito | 1 | — | ×1 | busca Entidade |
| 20 | Pó de Ossos | Rito | 2 | — | ×1 | 2 dano em área, descarte |
| 21 | Malefício | Rito | 3 | — | ×2 | −3/−2 e silêncio |
| 22 | Sabá de Walpurgis | Rito | 4 | — | ×1 | aliadas +1/+1, token Lebre 1/2 |
| 23 | Vassoura | Relíquia | 1 | — | ×2 | +1/+2, Ímpeto |
| 24 | Livro das Sombras | Relíquia | 2 | — | ×1 | Usos 4; +1/+1 enquanto equipado; compra ao atacar |
| 25 | Caldeirão de Renascimento | Relíquia | 3 | — | ×1 | +1/+2; revive ao morrer |

25 cartas distintas, 32 no deck.

## Contagem por tipo

| Tipo | Contagem | Esperado |
|---|---|---|
| Entidade | 1+2+1+1+2+1+1+1+1+1+1+1 = **14** | 14 |
| Selo | 2+2+1+1 = **6** | 6 |
| Rito | 2+1+1+1+2+1 = **8** | 8 |
| Relíquia | 2+1+1 = **4** | 4 |

## Curva de custo das Entidades

| Faixa | Cartas | Qtd. | Esperado |
|---|---|---|---|
| 1–2 | Sapo, Gato ×2, Corvo | **4** | 4 |
| 3–4 | Strega, Benandante ×2, Circe, Medeia, Endor | **6** | 6 |
| 5–6 | Baba Yaga, Cerridwen, Morrigan | **3** | 3 |
| 7–8 | Hécate | **1** | 1 |

Lendárias: **2** (A Morrigan, custo 6; Hécate, custo 7), 1 cópia cada.

## Sanidade do deck (revisão)

Dano direto à Cornucópia: **0** · `counter`: 1 (Garrafa) · `destroy`: 1 (Baba Yaga) · `discard`: **5 ocorrências** (Corvo, Círculo ×2, Garrafa, Pó de Ossos) — no limite de 5; não acrescentar mais descarte.

## Linhas de jogo

- **Abertura**: Sapo/Gato no turno 1–2, Seiðr para buscar a peça certa, Mau-Olhado virado para baixo. O oponente invoca → já entra congelado e menor.
- **Meio**: Benandante congela o melhor inimigo, Strega enche o campo de familiares, Poção/Vassoura transformam um familiar em ameaça. Malefício e Circe tiram do jogo a Entidade grande do oponente sem destruí-la (silenciada, 1/1).
- **Pacto**: com 2–3 familiares em campo, sacrifica-se um Sapo (dispara o Último Sopro) ou uma Strix — não o Gato, que sacrificado não volta (Renascer não dispara em Sacrifício) — para Baba Yaga (turno 5) ou Hécate (turno 7, ou 6 com Pacto na Encruzilhada).
- **Fecho**: Sabá (4 Fé) dá +1/+1 a todo o enxame; a Morrigan com Ímpeto entra batendo e cada morte traz um Corvo.

## Histórico de balanceamento

- **Rodada 1** (ver `sim/relatorios/r1_mudancas.md`). Linha de base pós-motor: 46,5 % de média. Mudanças: **Baba Yaga** 4/5 → **3/5** (com `destroy` a 5 pts a conta era 14/13); **Hécate** 6/7 → **5/7** (P+1; o Analista propôs 5/6 — versão mais leve porque a regra nova de Despertar já desfez o laço Caldeirão → Hécate); **Boneco de Cera** 3 → **4** de dano ao atacante (8/8). **Caldeirão de Renascimento** fica como está (a proposta "reviver para a mão" era motivada pelo laço desfeito). Lista das 32, distribuição e curva inalteradas.
- **Rodada 2** (ver `sim/relatorios/r2_mudancas.md`). Linha de base: 40,9 % (40,5 na seed 12), abaixo da faixa depois de perder o saco de pancadas (alta magia). A métrica nova "WR comprada" mostrou que Hécate (57 %) e Baba Yaga (54,5 %) não decidem partidas — Cerridwen e Morrigan (62 %) sim — e que os familiares são neutros, não fracos. Pacote **CB3** sem tocar nas Lendárias: **Malefício** ×2 −2/−2 → **−3/−2** (7/7); **Vassoura** ×2 +1/+1 → **+1/+2** (4/4); **Sabá** Lebre 1/1 → **1/2** (9/9); **Livro das Sombras** Usos 3 → **4** (5,6/6). **Recusado** B-5 (Garrafa + cura 2): fere a identidade "não cura Cornucópia" e mediu +0,4 pp. Lista das 32, distribuição e curva inalteradas.
