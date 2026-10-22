# Véu de Maya

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
Quando o oponente jogar um Rito, anule-o e devolva uma Entidade inimiga para a mão do dono.

## Contexto mitológico
Maya é o poder de ilusão que faz o Uno aparecer como múltiplo e o eterno como passageiro. No Rigveda a palavra ainda designa a "arte", o poder mágico dos deuses (e dos asuras) de criar formas. No Shvetashvatara Upanishad (4.10) ela já é o véu: "saiba que a natureza (prakriti) é maya, e o grande Senhor é o mestre da maya". Nos Puranas, Maya é a Shakti de Vishnu, a energia com que ele projeta e recolhe os mundos; na Bhagavad Gita (7.14), Krishna a chama de "minha maya divina, feita dos três gunas, difícil de transpor".

As histórias de maya são as mais lembradas dos Puranas: Vishnu como Mohini, a encantadora que faz os asuras entregarem a amrita; o sábio Narada que pede a Krishna para ver a maya e vive uma vida inteira num rio em alguns instantes; Krishna multiplicando-se para dançar com cada gopi ao mesmo tempo. O que o inimigo vê não é o que está lá.

O Selo é o véu caindo sobre a mesa do adversário: a magia que ele lançou não acontece, e a criatura que ele pensava ter em campo some.

## Papel no jogo
O único Selo de proteção do deck, e mesmo ele é ofensivo: anula o Rito inimigo (uma remoção sobre Hanuman, uma cura, uma compra) e ainda tira do campo uma Entidade adversária, abrindo caminho para os atacantes. Colocado com Krishna ou Shiva na mesa, protege o investimento. Fraco contra decks com poucos Ritos e quando o oponente só joga Ritos baratos.

## Balanço
Orçamento P = 2·2+1 = 5 pts (+1 Selo = 6). Gasto: anular Rito inimigo 3 + devolver Entidade inimiga à mão 2 = 5. Dentro.

## Dados
```json
{
  "id": "hin_veu_de_maya",
  "nome": "Véu de Maya",
  "cultura": "hinduismo",
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
      { "op": "bounce", "alvo": "enemy_entity" } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, object focus, shimmering translucent silk veil, veil billowing in the air, veil woven with stars, flowing fabric, ghostly silhouette dissolving behind the veil, fading into sparkles, swirling illusion, mirage, glittering particles, distorted reflections, dark palace hall, carved pillars, reflecting pool, floating lotus, saffron and blue, iridescent shimmer, soft blue haze, dim light, dark tone, mysterious, ominous, dramatic lighting, centered composition
```

## Prompt Krea 2
Atributos obrigatórios: véu de seda translúcido com estrelas · silhueta fantasma se dissolvendo atrás · brilho iridescente · salão de palácio com espelho d'água
```krea
A shimmering translucent silk veil billows in the air in a dark palace hall, with no people. The veil is woven with tiny glowing stars and ripples like water. Behind it a ghostly shadowy silhouette dissolves into glittering particles and fades away. Distorted reflections bend in the air around the veil like a mirage. Below it lies a still reflecting pool with one floating lotus, and carved pillars stand in the gloom. A cold blue moonlight falls through a high window onto the veil, making its edges glow with iridescent color.
```
