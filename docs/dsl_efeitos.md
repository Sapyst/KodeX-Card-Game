# DSL de efeitos (v0.1)

Toda carta carrega, além do texto, um bloco ```json com sua forma legível por máquina.
O simulador (`sim/`) lê **só** o JSON. Se um efeito não cabe no vocabulário abaixo,
**simplifique a carta** até caber — não invente campos. Vocabulário fechado.

## Esqueleto

```json
{
  "id": "ind_boitata",
  "nome": "Boitatá",
  "cultura": "indigena",
  "tipo": "entidade",
  "custo": 4,
  "atk": 3,
  "vida": 4,
  "lendaria": false,
  "keywords": ["guarda"],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "ally_attacked", "acoes": [ { "op": "damage", "alvo": "attacker", "n": 1 } ] }
  ],
  "usos": null
}
```

- `id`: `<prefixo>_<slug>` em minúsculas sem acento. Prefixos: `ind` `cri` `tao` `hin` `bru` `alt` (`aby` para o Conjunto do Abismo).
- `tipo`: `entidade` | `selo` | `rito` | `reliquia`.
- `atk`/`vida`: só Entidade (demais: `null`).
- `keywords`: subconjunto de `impeto` `guarda` `renascer` `furtivo`.
- `sacrificio`: 0–2 (só Entidade).
- `usos`: só Relíquia com cargas (inteiro) senão `null`. Semântica: cada disparo de um efeito com gatilho `equipped_attacks` (ou `start_turn`/`end_turn` quando houver) gasta 1 uso; ao gastar o último, a Relíquia vai ao cemitério (buffs de `on_equip` somem com ela). `on_equip` e `static` não gastam uso.
- `efeitos`: lista de `{gatilho, acoes[], cond?}`. Rito: exatamente 1 efeito com gatilho `on_play`. Selo: exatamente 1 efeito com gatilho da lista de Selos. Relíquia: gatilhos `on_equip` / `static` / `equipped_attacks` / `equipped_dies`. Entidade: 0–2 efeitos.

## Gatilhos

Entidade:
`on_play` (Despertar) · `on_death` (Último Sopro) · `on_attack` (ao declarar ataque) · `on_damaged` · `ally_attacked` (outra aliada foi atacada) · `start_turn` · `end_turn` · `ally_dies` · `enemy_dies` · `static` (aura contínua enquanto em campo)

Selo (disparam no turno do oponente):
`enemy_attacks` · `enemy_attacks_cornucopia` · `enemy_plays_entity` · `enemy_plays_rite` · `enemy_plays_reliquia` · `ally_dies` · `ally_damaged` · `enemy_end_turn`

Rito: `on_play`.
Relíquia: `on_equip` · `static` · `equipped_attacks` · `equipped_dies`.

## Condição (`cond`, opcional)

```json
{ "tipo": "ally_count_min", "n": 2 }
```
Tipos: `ally_count_min` · `ally_count_max` · `enemy_count_min` · `enemy_count_max` · `hand_min` · `hand_max` · `cornucopia_below` (própria, n) · `enemy_cornucopia_below` · `graveyard_entities_min` · `fe_max_min` (Fé máxima ≥ n) · `target_cost_max` (para `counter`/`destroy`: só se custo do alvo ≤ n).

## Alvos (`alvo`)

`self` · `attacker` · `defender` (a Entidade que está sendo atacada: a aliada em `ally_attacked`/`enemy_attacks`/`ally_damaged`, a inimiga em `on_attack`/`equipped_attacks`) · `triggering` (a carta que disparou o gatilho) · `equipped` (Entidade que porta a Relíquia) · `other_ally_entities` (todas as aliadas exceto a fonte; válido em `static`)
`enemy_entity` (escolhido pelo jogador; bot escolhe o melhor) · `enemy_entity_random` · `all_enemy_entities`
`ally_entity` · `ally_entity_random` · `all_ally_entities` · `all_entities`
`enemy_cornucopia` · `ally_cornucopia` · `enemy_hand_random` · `ally_graveyard_entity` (escolhida) · `ally_graveyard_entity_random`

## Ações (`op`)

| op | campos | efeito |
|---|---|---|
| `damage` | alvo, n | causa n de dano |
| `heal` | alvo, n | cura n (Entidade ou Cornucópia; não passa do máximo) |
| `draw` | n | compra n |
| `search` | filtro: `tipo` e/ou `custo_max` e/ou `keyword` | busca 1 carta do deck que case, para a mão; embaralha |
| `buff` | alvo, atk, vida, `perm` (bool; false = até fim do turno) | +atk/+vida (podem ser negativos; vida ≤ 0 mata) |
| `destroy` | alvo | manda ao cemitério |
| `bounce` | alvo | devolve à mão do dono |
| `summon` | atk, vida, nome, `keywords?`, `n?` | invoca token(s) se houver slot |
| `revive` | alvo (`ally_graveyard_entity*`), `para`: `hand` ou `field` | revive |
| `discard` | alvo `enemy_hand_random`, n | descarta |
| `gain_fe` | n, `perm` (bool; false = temporária) | ganha Fé |
| `silence` | alvo | remove keywords e efeitos |
| `freeze` | alvo | não ataca no próximo turno dela |
| `counter` | — | (só Selo com `enemy_plays_*`) anula a carta gatilho; vai ao cemitério sem efeito |
| `give_keyword` | alvo, keyword | concede palavra-chave |
| `set_stats` | alvo, atk, vida | define ATK/Vida |
| `copy_stats` | alvo | self fica com ATK/Vida do alvo |
| `swap_control` | alvo | rouba a Entidade até o fim do turno (`perm`: false) ou permanente |
| `win` | — | vitória imediata (**só Choronzon**) |

Aura `static` só aceita `buff` com alvo `all_ally_entities`/`other_ally_entities`/`all_enemy_entities`, ou `give_keyword` em `all_ally_entities`/`other_ally_entities`; some quando a fonte sai do campo.
`summon` aceita `keywords` (lista) e `n` (quantidade, padrão 1).

Regras de resolução (o motor segue estas):
- Alvo que não existe no momento (ex.: `attacker` quando o dano veio de um Rito; `defender` num ataque à Cornucópia) → a **ação é pulada**, as demais do efeito resolvem.
- Em `on_death`/`equipped_dies`, a Entidade morta já está no cemitério quando o efeito resolve (um `revive` pode trazê-la de volta).
- Buffs de `on_equip` somem quando a Relíquia sai (inclusive por Usos esgotados). Buffs de ações normais com `perm: true` ficam.
- `enemy_attacks_cornucopia` é um gatilho separado de `enemy_attacks` (este dispara só em ataque a Entidade).
- `revive` com `para: field` **não** dispara `on_play` (Despertar) nem `enemy_plays_entity`.
- `gain_fe` com `perm: true` sobe só a Fé **máxima** (a Fé atual vem no próximo turno); `perm: false` dá Fé agora, até o fim do turno.
- Furtivo também escapa de efeitos inimigos que o apontem por `triggering` (ex.: Selo `enemy_plays_entity` → `destroy triggering`).
- O contragolpe do defensor num ataque não tem `attacker`: uma Entidade com "ao sofrer dano, fere o atacante" não se fere ao atacar.

## Exemplos

Rito "Oferenda de Mandioca" (custo 1): cura 2 na Cornucópia e compra 1.
```json
{ "efeitos": [ { "gatilho": "on_play", "acoes": [
  { "op": "heal", "alvo": "ally_cornucopia", "n": 2 },
  { "op": "draw", "n": 1 } ] } ] }
```

Selo "Armadilha do Caipora" (custo 2): quando inimigo ataca, atacante leva 3.
```json
{ "efeitos": [ { "gatilho": "enemy_attacks", "acoes": [
  { "op": "damage", "alvo": "attacker", "n": 3 } ] } ] }
```

Relíquia "Lança de Longino" (custo 3): +2 ATK; quando a portadora ataca, 1 de dano à Cornucópia inimiga.
```json
{ "efeitos": [
  { "gatilho": "on_equip", "acoes": [ { "op": "buff", "alvo": "equipped", "atk": 2, "vida": 0, "perm": true } ] },
  { "gatilho": "equipped_attacks", "acoes": [ { "op": "damage", "alvo": "enemy_cornucopia", "n": 1 } ] } ] }
```
