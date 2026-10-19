# Lei do Karma

| Campo | Valor |
|---|---|
| Cultura | hinduísmo |
| Tipo | Selo |
| Custo | 2 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Quando uma Entidade inimiga atacar, ela sofre 3 de dano. Compre 1 carta.

## Contexto mitológico
Karma significa simplesmente "ação" — e, por extensão, a lei pela qual toda ação produz um fruto (phala) que retorna a quem a praticou, nesta vida ou em outra. Nos Vedas a palavra designa sobretudo o ato ritual; nas Upanishads passa a abarcar toda conduta e torna-se o motor do samsara. A Bhagavad Gita (2.47) dá o verso mais citado sobre o tema: "tens direito à ação, nunca a seus frutos" — o ensinamento de agir por dever, sem apego ao resultado, que Krishna chama de karma-yoga.

Não há juiz na lei do karma; ela opera como a gravidade. A violência lançada volta ao violento, com a mesma medida. É por isso que o Mahabharata inteiro pode ser lido como o desdobrar do karma de cada personagem: Bhishma preso ao próprio voto, Karna à mentira sobre seu nascimento, Duryodhana à inveja.

O Selo é a lei em ação na mesa: quem ergue a mão para ferir é ferido antes.

## Papel no jogo
O Selo de contra-ataque padrão do deck: colocado atrás de Hanuman ou Krishna, faz o oponente pensar duas vezes antes de atacar — 3 de dano mata a maioria dos corpos de custo até 3 e deixa qualquer outro ferido para o contra-golpe. A compra mantém a mão cheia. Fraco contra decks que não atacam Entidades (dano direto por Ritos) e contra atacantes com Vida alta.

## Balanço
Orçamento P = 2·2+1 = 5 pts (+1 Selo = 6). Gasto: 3 de dano ao atacante 3 + comprar 1 carta 1,5 = 4,5. Dentro (P−1,5).
Rodada 2 de balanceamento (pacote H1 do Analista): dano 4 → 3 (−0,5 pp medido).

## Dados
```json
{
  "id": "hin_lei_do_karma",
  "nome": "Lei do Karma",
  "cultura": "hinduismo",
  "tipo": "selo",
  "custo": 2,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "enemy_attacks", "acoes": [
      { "op": "damage", "alvo": "attacker", "n": 3 },
      { "op": "draw", "n": 1 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, ghostly sword, sword striking a glowing lotus mandala shield, blade shattering on impact, broken blade fragments flying back, burst of light reflecting back, sparks, shockwave, golden barrier, sacred geometry, counterattack, trap, dark temple hall, stone pillars, oil lamps, saffron and blue, golden glow, deep shadows, dark tone, ominous, high contrast, dramatic lighting, centered composition
```

## Prompt Krea 2
Atributos obrigatórios: espada fantasma se partindo · escudo mandala de lótus dourado · fragmentos da lâmina voltando · salão de templo com lamparinas
```krea
A ghostly translucent blue-white sword with no wielder floats alone in mid-air and strikes a glowing golden lotus mandala barrier in a dark temple hall. There are no people, no figures and no hands in the scene. At the point of impact the sword blade is clearly breaking: it is cracked in half, and many sharp glowing blade fragments fly backward, away from the barrier, toward the left side of the image. A bright ring-shaped shockwave and sparks burst at the impact point. The mandala of sacred geometric rings and lotus petals stays whole and unbroken. Stone pillars and small burning oil lamps stand in the shadows. The golden flash at the impact is the strongest light.
```
