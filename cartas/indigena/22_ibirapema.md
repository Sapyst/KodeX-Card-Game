# Ibirapema

| Campo | Valor |
|---|---|
| Cultura | indígena brasileira |
| Tipo | Relíquia |
| Custo | 1 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
A portadora ganha +2 ATK e Ímpeto.

## Contexto mitológico
A *ywyrapema* (ibirapema, "pau achatado") é o tacape cerimonial dos Tupinambá: uma clava de madeira dura, pesada, de cabeça larga e achatada, enfeitada com penas, pintura e cordões de algodão. Hans Staden (*Warhaftige Historia*, 1557), que quase morreu por ela, descreve-a em detalhe; Jean de Léry (1578) e Gabriel Soares de Sousa (1587) confirmam que era a arma do **sacrifício ritual do prisioneiro**, usada por um só homem, que para isso ganhava um novo nome e se tornava guerreiro pleno.

Diferente da borduna de guerra comum, a ibirapema não era apenas arma: era untada e enfeitada na véspera, em cauinagem, entregue ao executor pelas mulheres, e quem a usava ficava depois em reclusão, escarificado, para receber o novo nome. Staden a grafa *Iwera Pemme* e descreve a cerimônia inteira, do canto ao golpe. Métraux (*A religião dos Tupinambás*, 1928) a situa no centro do complexo guerreiro tupi — vingança, nome, memória. É o instrumento que transforma um homem em guerreiro no instante em que o empunha.

Na carta, dá à portadora a força do golpe (+2 ATK) e a prontidão de quem acaba de ganhar o nome (Ímpeto: ataca no turno em que entra).

## Papel no jogo
A única Relíquia ofensiva do deck. Melhor na Cobra-Grande ou no Mapinguari no turno em que entram: 7 ou 6 de ATK atacando imediatamente. Em Saci (Furtivo, Ímpeto) vira um ataque-surpresa de 3. Barata, não compete com a Fé de uma invocação grande no mesmo turno. Morre com a portadora.

## Balanço
Orçamento P = 2·1+1 = 3 pts, +1 grátis de Relíquia = 4. Gasto (tabela §10): +2 ATK permanente (2) + Ímpeto (1) = 3. Dentro (P−1). _(Revisão: conta confirmada. Ímpeto numa Relíquia de 1 Fé é o ponto a vigiar no simulador: Cobra-Grande 7 ATK atacando no turno 6 — mas só Entidades, enquanto o inimigo tiver campo.)_

## Dados
```json
{
  "id": "ind_ibirapema",
  "nome": "Ibirapema",
  "cultura": "indigena",
  "tipo": "reliquia",
  "custo": 1,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_equip", "acoes": [
      { "op": "buff", "alvo": "equipped", "atk": 2, "vida": 0, "perm": true },
      { "op": "give_keyword", "alvo": "equipped", "keyword": "impeto" } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, object focus, single wooden war club, large flat paddle-shaped club head, dark polished hardwood, red and yellow macaw feathers tied at the handle, cotton tassels, red and black painted bands, club planted upright in sand, close-up, bonfire glow behind, night, green and orange, strong rim lighting, wood grain, centered composition, clean silhouette, readable shape, high contrast, dramatic lighting, deep shadows, rim lighting, moody atmosphere, soft glow, sharp focus, vivid colors
```

## Prompt Krea 2
Atributos obrigatórios: tacape de cabeça achatada em forma de remo · madeira escura polida · mosaico de casca de ovo e urucum na cabeça · penas de arara e borlas de algodão no cabo · fincado na areia
```krea
A single Tupinamba ceremonial war club, the ibirapema, standing perfectly vertical with its handle end buried in the sand at night. The club is one straight piece of dark polished hardwood: a long round handle that widens at the top into a large flat, rounded paddle-shaped head in line with the handle, like a canoe paddle blade, not an axe and not a hatchet, with nothing sticking out sideways. The paddle head is decorated with a band of white eggshell mosaic and red urucum paint. Red and yellow macaw feathers and white cotton tassels hang from the handle. A bonfire burns behind it as rim light.
```
