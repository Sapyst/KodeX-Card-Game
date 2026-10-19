# Sopro do Pajé

| Campo | Valor |
|---|---|
| Cultura | indígena brasileira |
| Tipo | Selo |
| Custo | 2 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Quando o oponente jogar um Rito: anula esse Rito e você compra 1 carta.

## Contexto mitológico
O pajé (do tupi *payé*) é o xamã dos povos tupi-guarani; o *caraíba* (*karaí*) era o pajé-profeta andarilho, que ia de aldeia em aldeia anunciando a Terra sem Males. Jean de Léry (*Viagem à Terra do Brasil*, 1578, cap. XVI) descreve a cena central da pajelança: o caraíba, com um canudo de petim (tabaco) aceso, **sopra a fumaça** sobre os homens dizendo "recebei o espírito de força", e sopra também sobre doentes e lugares para expulsar o mal. Métraux (*A religião dos Tupinambás*, 1928) e Hélène Clastres (*Terra sem Mal*, 1975) analisam o sopro de fumaça como o gesto xamânico tupi por excelência: cura, purifica e desfaz feitiços alheios.

Em pajelanças amazônicas atuais e em rituais de muitos povos (Guarani, Tenetehara, Sateré-Mawé), o sopro de tabaco segue sendo o modo de "desmanchar" o que outro pajé fez. A carta é isso: o feitiço inimigo chega, o pajé sopra, e o feitiço se desfaz no ar.

## Papel no jogo
O único Selo de anulação do deck. Dispara no primeiro Rito que o oponente jogar no turno dele — então vale mais contra decks pesados em Ritos (dano direto, remoção) e menos contra decks de criaturas. Como dispara no primeiro Rito, o oponente pode "gastá-lo" com um Rito barato; a compra de carta compensa a troca. Protege Jaci, Tupã e Cobra-Grande de remoção.

## Balanço
Orçamento P = 2·2+1 = 5 pts, +1 grátis de Selo = 6. Gasto (tabela §10): anular Rito inimigo (3) + comprar 1 (1,5) = 4,5. Dentro (P−1,5; não está abaixo de P−2). A folga é deliberada: `counter` anula qualquer Rito, inclusive os de custo 4+, e todo deck tem 8 Ritos, então o gatilho é quase certo. _(Revisão: conta confirmada; único `counter` do deck, 1 cópia ≤ 3.)_

## Dados
```json
{
  "id": "ind_sopro_do_paje",
  "nome": "Sopro do Pajé",
  "cultura": "indigena",
  "tipo": "selo",
  "custo": 2,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "enemy_plays_rite", "acoes": [
      { "op": "counter" },
      { "op": "draw", "n": 1 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1boy, solo, elderly indigenous shaman, wrinkled dark skin, white hair, feather headdress, necklaces of seeds and teeth, red and black body paint, holding a long smoking tobacco tube, blowing a thick cloud of white smoke forward, smoke dissolving a dark purple curse shape, intense gaze, inside a dim thatched hut at night, hammock, clay pots, small fire, firelight, green and orange, glowing embers, smoke swirls, dark atmosphere, deep shadows, woven mats, feather fan, dim light, wrinkled hands, upper body
```

## Prompt Krea 2
Atributos obrigatórios: pajé idoso ~70 anos · canudo de tabaco nas duas mãos · sopro de fumaça branca desfazendo forma roxa · faixa de algodão no peito · fogueira na oca
```krea
An elderly Indigenous Brazilian man about 70 years old, a pajé shaman with wrinkled dark brown skin and short white hair, seated inside a dim thatched house at night. He wears a woven cotton sash across his chest, a straw skirt, a headband of red and yellow feathers and necklaces of seeds and animal teeth. With both hands he holds a long tobacco tube to his lips and blows a thick cloud of white smoke forward. The smoke meets a dark purple curse shape floating in the air and breaks it into fading wisps. A small fire on the earthen floor is the strong light, beside a hammock and clay pots.
```
