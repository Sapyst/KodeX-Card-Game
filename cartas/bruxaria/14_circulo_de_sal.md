# Círculo de Sal

| Campo | Valor |
|---|---|
| Cultura | bruxaria |
| Tipo | Selo |
| Custo | 2 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 2 |

## Texto da carta
Quando atacarem uma Entidade sua, devolva o atacante para a mão do dono. O oponente descarta 1 carta aleatória. Compre 1 carta.

## Contexto mitológico
O sal é o purificador universal da magia popular europeia: jogado por cima do ombro esquerdo contra o azar de derrubá-lo, posto no berço e no bolso do recém-nascido antes do batismo, misturado à água benta na liturgia (que o exorciza expressamente, "para que o inimigo fuja de onde for aspergido"), espalhado na soleira para que a bruxa não entre. É o que não apodrece e por isso o que o apodrecido — o morto, o demônio, o malefício — não cruza.

O círculo traçado no chão como barreira vem da alta magia (a *Clavicula Salomonis* o quer de nove pés, com nomes divinos escritos), mas a versão da bruxaria popular e da Wicca é mais simples: uma linha de sal, uma vassoura passada em volta, e quem está dentro está em outro lugar. Gardner e Valiente fizeram do círculo de nove pés "o espaço entre os mundos" onde o coven trabalha. No desenho de Guazzo e nas confissões, a bruxa também traça círculos para proteger-se do que ela mesma invoca.

Na carta o círculo não fere: **repele**. O atacante bate no sal, volta para onde veio — a mão do dono — e algo se perde no caminho enquanto a bruxa ganha o que tinha ido buscar.

## Papel no jogo
Resposta de tempo contra a Entidade grande do oponente: ela ataca, volta à mão (perde buffs, Relíquia, posição), ele precisa pagar o custo todo de novo, descartou uma carta e você comprou uma. Duas cópias para que o deck segure o campo enquanto junta familiares. É a única "defesa" do deck sem Guarda. Fraco contra enxames de tokens baratos (devolver um 1/1 não vale 2 Fé). Só dispara em ataque a **Entidade** (`enemy_attacks`); com o campo da bruxa vazio o inimigo ataca a Cornucópia e o Círculo fica dormindo — manter sempre um familiar na mesa.

## Balanço
Orçamento P = 2·2+1 + 1 (Selo) = 6 pts. Gasto: devolver atacante à mão (2) + oponente descarta 1 aleatória (2) + comprar 1 (1,5) = 5,5. Dentro.

## Dados
```json
{
  "id": "bru_circulo_de_sal",
  "nome": "Círculo de Sal",
  "cultura": "bruxaria",
  "tipo": "selo",
  "custo": 2,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "enemy_attacks", "acoes": [
      { "op": "bounce", "alvo": "attacker" },
      { "op": "discard", "alvo": "enemy_hand_random", "n": 1 },
      { "op": "draw", "n": 1 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, high angle, wide circle of white salt poured on a dark wooden floor, glowing salt ring, pale blue barrier light rising from the ring, sparks, shadowy black clawed hand reaching in and recoiling from the barrier, dark smoke, candles at the edge of the circle, scattered salt grains, no cauldron, dark cottage interior, wooden beams, herbs hanging, purple and green, candlelight, moonlight through the window, rim lighting, magic trap, dark atmosphere
```

## Prompt Krea 2
Atributos obrigatórios: círculo de sal branco brilhante no chão · barreira de luz azul-pálida · mão de garras de sombra recuando · velas na borda · interior de cabana escura
```krea
Seen from a high angle, a wide circle of white salt is poured on the dark wooden floor of a witch's cottage. The salt ring glows white, and a wall of pale blue light rises from it like a barrier. A shadowy black clawed hand reaches in from the darkness outside the circle and recoils from the light in a burst of sparks. Five small candles stand along the edge of the circle, and loose salt grains are scattered across the floorboards. Wooden beams and hanging herbs are above. The space inside the circle is empty. The blue barrier light is the strong light source, with moonlight falling through a small window.
```
