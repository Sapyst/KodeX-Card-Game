# Sapo Familiar

| Campo | Valor |
|---|---|
| Cultura | bruxaria |
| Tipo | Entidade |
| Custo | 1 Fé |
| ATK / Vida | 0 / 1 |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Último Sopro: Uma Entidade inimiga recebe -1/-1.

## Contexto mitológico
Nos processos de Zugarramurdi (Navarra, 1609–1610) os acusados descreviam sapos vestidos com roupinhas de pano, guardados em casa e alimentados pelas bruxas, que os levavam ao *akelarre* e deles extraíam venenos. A imagem é tão recorrente nas confissões que o inquisidor Alonso de Salazar y Frías, ao reexaminar os casos, usou a falta de qualquer sapo apreendido como um dos argumentos de que tudo era fabricado sob pressão (Henningsen, *The Witches' Advocate*, 1980).

Na Inglaterra o sapo também é familiar: nos julgamentos de Essex e Lancashire aparece ao lado do gato e da doninha, e o *Malleus Maleficarum* (parte II, questão 1) o conta entre os ingredientes dos venenos e unguentos que atribui às bruxas. Há um fundo real: a pele de muitos sapos e rãs produz bufotoxinas, e o animal era mesmo usado em preparos de veneno e de "remédio".

Na carta, o Sapo é a menor peça do deck — não ataca, só existe para ser gasto. Quando morre (ou é sacrificado para o pacto), seu veneno respinga numa Entidade inimiga: o familiar barato que paga o custo de Baba Yaga e Hécate e ainda deixa uma maldição ao partir.

## Papel no jogo
É a moeda de Sacrifício ideal: custa 1, enche um slot cedo (impedindo dano direto à Cornucópia) e, ao ser sacrificado para Baba Yaga ou Hécate, dispara o Último Sopro, encolhendo o inimigo em −1/−1 permanente — que mata um token 1/1 ou enfraquece um atacante. Também é bom alvo da Vassoura (vira 1/2 com Ímpeto) ou da Poção de Beladona quando se precisa de corpo. Ruim contra decks que ignoram Entidades pequenas e removem em área.

## Balanço
Orçamento P = 2·1+1 = 3 pts. Gasto: ATK 0 + Vida 1 + Último Sopro −1/−1 permanente a inimigo escolhido (1+1 = 2 pts; `on_death` dispara uma vez, valor cheio) = 3. Dentro.

## Dados
```json
{
  "id": "bru_sapo_familiar",
  "nome": "Sapo Familiar",
  "cultura": "bruxaria",
  "tipo": "entidade",
  "custo": 1,
  "atk": 0,
  "vida": 1,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_death", "acoes": [ { "op": "buff", "alvo": "enemy_entity", "atk": -1, "vida": -1, "perm": true } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, animal focus, single large warty brown toad, realistic toad anatomy, wide flat body, four short legs, webbed feet, no hat, no mushroom, tiny tattered cloth vest on its back, bulging glowing green eyes, puffed throat sac, green poison dripping from warts, slimy skin, sitting on a low wooden stool, dark witch's cottage interior, clay bowl of milk on the floor, dried herbs hanging, single candle beside it, cobwebs, purple and green, green poison glow, candlelight, rim lighting, dark atmosphere, full body
```

## Prompt Krea 2
Atributos obrigatórios: sapo grande marrom verrugoso · coletinho de pano esfarrapado · olhos verdes brilhantes · veneno verde pingando · banquinho de madeira
```krea
A single large warty brown common toad sits on a low wooden stool inside a dark witch's cottage. It has a realistic toad body, wide and flat, with exactly four short legs and webbed feet. It wears a tiny tattered vest of brown cloth on its back. Its bulging eyes glow bright green and its throat sac is puffed out. Thick green poison drips from the warts on its back onto the stool. A clay bowl of milk sits on the floor beside the stool. Bundles of dried herbs hang from the beams. A single candle on the floor is the strong light source, casting a warm glow on the toad and a green shimmer on the poison.
```
