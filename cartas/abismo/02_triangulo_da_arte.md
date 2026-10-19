# Triângulo da Arte

| Campo | Valor |
|---|---|
| Cultura | abismo (módulo especial — Conjunto do Abismo) |
| Tipo | Relíquia |
| Custo | 2 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | sim |
| Cópias no deck | 1 |

## Texto da carta
Equipe numa Entidade aliada: +0/+2. Conta como "Triângulo" para Sigilo 333.

## Contexto mitológico
O Triângulo da Arte (ou Triângulo de Salomão) é o espaço, fora do círculo do mago, onde o espírito evocado é obrigado a se manifestar. Na *Goetia* (Lemegeton, séc. XVII) ele é desenhado a dois pés do círculo, com os nomes Tetragrammaton, Primeumaton e Anaphaxeton nos lados e "Michael" dividido nos vértices; dentro dele fica o espelho negro ou o incensório.

Na operação de Bou Saâda, Crowley fez o inverso do protocolo: entrou ele mesmo no triângulo, oferecendo o próprio corpo como receptáculo para Choronzon, enquanto Neuburg guardava o círculo. Daí a carta ser uma Relíquia **equipada** numa Entidade: alguém tem que ficar dentro do triângulo.

## Papel no jogo
Peça 1 do ritual. A Entidade que a carrega vira alvo prioritário do oponente — proteger a portadora é parte do jogo do Conjunto.

## Balanço
P = 5 (+1 Relíquia) = 6. Gasto: +2 Vida = 2. Deliberadamente fraca: o valor é ser peça do ritual.

## Dados
```json
{ "id": "aby_triangulo", "nome": "Triângulo da Arte", "cultura": "abismo", "tipo": "reliquia", "custo": 2,
  "atk": null, "vida": null, "lendaria": true, "keywords": [], "sacrificio": 0,
  "efeitos": [ { "gatilho": "on_equip", "acoes": [ { "op": "buff", "alvo": "equipped", "atk": 0, "vida": 2, "perm": true } ] } ], "usos": null }
```

## Prompt de arte
```prompt
no humans, object focus, glowing triangle drawn on desert sand, hebrew letters along the edges, black scrying mirror in the center, smoking incense burner, candles, desert night, starry sky, sand yellow and void black, eerie pale glow, from above
```

## Prompt Krea 2
Atributos obrigatórios: triângulo brilhante desenhado na areia do deserto · letras hebraicas ao longo dos lados · espelho negro de vidência no centro · incensário fumegante · vista de cima
```krea
Seen from above: a large triangle drawn in the sand of a desert at night, its lines glowing pale white. Small Hebrew letters run along its three sides. In the center lies a round black scrying mirror, and beside it a small brass incense burner sends up a thin twisting column of smoke. Three short candles stand at the corners of the triangle. The desert around it is dark, with a starry sky reflected in the black mirror. The pale glow of the triangle's lines is the main light, sharp against the sand.
```
