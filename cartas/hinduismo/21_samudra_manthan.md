# Samudra Manthan

| Campo | Valor |
|---|---|
| Cultura | hinduísmo |
| Tipo | Rito |
| Custo | 3 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Compre 2 cartas. Ganhe 2 de Fé neste turno. Cure 2 da sua Cornucópia.

## Contexto mitológico
O Samudra Manthan, batimento do oceano de leite, é um dos episódios mais contados dos Puranas (Bhagavata 8.6–12, Vishnu Purana 1.9, Mahabharata Adi Parva). Os devas, enfraquecidos por uma maldição, aceitam o conselho de Vishnu: unir-se aos asuras para bater o oceano cósmico e extrair dele a amrita, o néctar da imortalidade. Arrancam o monte Mandara para servir de batedor, Vishnu toma a forma da tartaruga Kurma para sustentá-lo, e a serpente Vasuki vira a corda — devas na cauda, asuras na cabeça, engolindo o veneno que ela exala.

Do oceano batido sai primeiro o Halahala, veneno capaz de destruir os mundos; Shiva o bebe e Parvati o detém na garganta, que fica azul (Neelakantha). Depois emergem os catorze tesouros: a vaca Kamadhenu, o cavalo Uchchaihshravas, o elefante Airavata, a joia Kaustubha, a árvore Parijata, as apsaras, a deusa Lakshmi — que escolhe Vishnu —, a lua, o arco Sharanga, a concha e, por fim, o médico Dhanvantari com o pote de amrita. Os asuras o arrebatam; Vishnu, como a encantadora Mohini, os distrai e serve o néctar só aos devas.

O Rito é o batimento em si: esforço (a Fé) que devolve tesouros (cartas) e um pouco do néctar (cura).

## Papel no jogo
A única carta de cura do deck, e ela é antes de tudo um motor de cartas: compra 2, devolve 2 de Fé no mesmo turno e cura 2 — de graça, se o jogador tem o que jogar com a Fé devolvida. Reabastece a mão depois de um turno de trocas agressivas. Melhor no turno 3–5, quando a Fé devolvida ainda paga um Garuda ou um Yajna. Fraco: não afeta a mesa diretamente.

## Balanço
Orçamento P = 2·3+1 = 7 pts. Gasto: comprar 2 cartas (2 × 1,5 = 3) + 2 de Fé temporária (2 × 1,5 = 3) + curar 2 de Cornucópia 1 = 7. Dentro.

## Dados
```json
{
  "id": "hin_samudra_manthan",
  "nome": "Samudra Manthan",
  "cultura": "hinduismo",
  "tipo": "rito",
  "custo": 3,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [
      { "op": "draw", "n": 2 },
      { "op": "gain_fe", "n": 2, "perm": false },
      { "op": "heal", "alvo": "ally_cornucopia", "n": 2 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, wide shot, tall rocky mountain rising from the ocean, giant serpent coiled around the mountain, serpent wrapped many times, serpent stretched taut to both sides, giant turtle beneath the mountain, churning milky white ocean, swirling foam, whirlpool, splashing waves, golden pot of nectar rising from the waves, night sky, full moon, stars, saffron and blue, golden glow, moonlight, rim lighting, epic scale, dramatic lighting
```

## Prompt Krea 2
Atributos obrigatórios: montanha no oceano de leite · serpente Vasuki enrolada nela · tartaruga gigante sob a montanha · pote dourado de amrita emergindo
```krea
The churning of the ocean of milk, a wide view with no people. A tall rocky mountain rises from a milky white ocean. A giant serpent is coiled many times around the mountain, its body stretched taut to both sides out of the frame. A giant turtle with a domed shell supports the base of the mountain under the water. The milky ocean swirls in foam and whirlpools. In the center front, a round golden pot of nectar rises out of the waves, glowing brightly, the focal point. A full moon shines in the night sky above.
```
