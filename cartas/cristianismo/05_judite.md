# Judite

| Campo | Valor |
|---|---|
| Cultura | cristianismo |
| Tipo | Entidade |
| Custo | 3 Fé |
| ATK / Vida | 2 / 1 |
| Palavras-chave | Despertar |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Despertar: destrói uma Entidade inimiga de custo 3 ou menos.

## Contexto mitológico
O Livro de Judite (deuterocanônico, séc. II a.C.) conta como a cidade de Betúlia, sitiada pelo general assírio Holofernes, está a dias de se render por sede. Judite, viúva rica e piedosa, repreende os anciãos pela falta de fé, veste-se com esmero e vai ao acampamento inimigo com a sua criada. Holofernes, encantado, oferece um banquete; embriagado, adormece, e Judite "golpeou-lhe duas vezes o pescoço com toda a força e cortou-lhe a cabeça" (Jt 13,8). A cabeça, exposta nas muralhas, desbarata o exército.

Judite é modelo de vitória pela astúcia e pela fé, não pela força — o cântico final o resume: "o Senhor Todo-Poderoso os frustrou pela mão de uma mulher" (Jt 16,5). A cena foi pintada por Caravaggio, Artemisia Gentileschi, Botticelli, Klimt — quase sempre o instante da espada ou a cabeça no cesto.

Na carta, é remoção **condicional**: o golpe acerta um comandante dormindo, não um exército — por isso destrói apenas Entidades de custo igual ou inferior ao dela.

## Papel no jogo
A resposta barata do deck a ameaças pequenas e médias: Entidades de custo ≤ 3 com habilidades irritantes (auras, Furtivo após atacar, geradores de token). Depois do Despertar, fica um 2/1 frágil — a astúcia já foi gasta; revivê-la para o campo não repete o golpe (reviver não dispara Despertar), só devolver à mão e reinvocar. Inútil contra campo vazio ou só com Entidades grandes; aí guarde-a até surgir alvo.

## Balanço
Orçamento P = 2·C+1 = 7 pts. Gasto: ATK 2 + Vida 1 + destruir Entidade escolhida com `target_cost_max` ≤ 3 (3,5) = 6,5. Dentro (P−0,5).
Rodada 1 de balanceamento: era 2/2 (7,5 com a tabela §10 nova).

## Dados
```json
{
  "id": "cri_judite",
  "nome": "Judite",
  "cultura": "cristianismo",
  "tipo": "entidade",
  "custo": 3,
  "atk": 2,
  "vida": 1,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "cond": { "tipo": "target_cost_max", "n": 3 },
      "acoes": [ { "op": "destroy", "alvo": "enemy_entity" } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1girl, solo, mature woman, long dark hair, modest dark blue dress, long sleeves, gold headband, veil, holding sword pointed down in right hand, holding closed cloth sack in left hand, calm determined expression, standing at entrance of military tent at night, red tent drapes, overturned wine cup, distant city walls, campfire light, holy light on her face, gold and white, dramatic rim lighting, full body, clean floor
```

## Prompt Krea 2
Atributos obrigatórios: véu escuro e diadema de ouro · vestido azul de mangas longas · espada assíria erguida com as duas mãos · tenda militar vermelha · taça de vinho caída
```krea
An adult Middle Eastern Hebrew woman about 30 years old, Judith of Bethulia, with long dark braided hair under a fine dark veil and a thin gold headband. She wears a long-sleeved deep blue linen dress belted with gold that covers her chest and arms completely, and gold earrings. Both of her hands grip the hilt of a heavy curved Assyrian sword raised high over her right shoulder, ready for one decisive downward strike, and her face is calm and resolute. She stands inside a dark military tent with red drapes, an overturned bronze wine cup on the rug at her feet. Warm flickering light from a single oil lamp.
```
