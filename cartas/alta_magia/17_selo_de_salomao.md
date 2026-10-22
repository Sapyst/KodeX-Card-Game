# Selo de Salomão

| Campo | Valor |
|---|---|
| Cultura | alta magia |
| Tipo | Selo |
| Custo | 3 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Quando o oponente jogar uma Entidade, anule-a (ela vai ao cemitério). Compre 1 carta.

## Contexto mitológico
O Selo de Salomão é o sinal gravado no anel que, segundo o *Testamento de Salomão* (séc. I–III d.C.), o arcanjo Miguel entregou ao rei para que ele **comandasse os demônios** e os pusesse a trabalhar na construção do Templo. Na tradição islâmica e na magia medieval o selo é o hexagrama — duas triângulos entrelaçados, fogo e água, acima e abaixo — e é com ele que Salomão aprisiona os espíritos no Vaso de Latão, que lança ao lago (Lemegeton, "Observações").

O Lemegeton descreve o Anel e o Pentáculo de Salomão como os instrumentos que o mago deve exibir ao espírito: o Pentáculo, gravado em metal e vestido ao peito, obriga o espírito a assumir forma humana e a obedecer; o Anel, de prata, protege do hálito venenoso de Astaroth e Beleth. Agrippa (III.11) e Reuchlin (*De verbo mirifico*, 1494) explicam os nomes divinos que vão gravados nesses selos — o Tetragrammaton e suas permutações — e por que o espírito não resiste a eles.

A carta é o selo que aprisiona: a Entidade inimiga é invocada e, antes de pisar o campo, cai no vaso. O "compre 1" é o que Salomão ganhava — mais um servo para o Templo.

## Papel no jogo
Resposta dura a Lendárias e a Entidades caras: o oponente paga 6–8 Fé e perde a carta. Custa 3, então é um Selo do meio de jogo — coloque-o quando o oponente estiver com Fé para invocar algo grande. Como dispara na primeira Entidade invocada, decks de muitas criaturas baratas o gastam fácil; contra esses, prefira Andras e o Ritual Menor do Pentagrama. **Uma cópia só** (revisão): com Pentagrama Flamejante ×2, o deck fica com 3 contadores, o teto de sanidade; Vassago busca esta cópia quando ela é a resposta certa.

## Balanço
Orçamento P = 2·3+1 = 7 pts + 1 (Selo) = 8. Gasto: anular Entidade inimiga (destruir Entidade escolhida = 5, +1 porque também nega o Despertar e qualquer custo de Sacrifício já pago = 6) + comprar 1 (1,5) = 7,5. Dentro (P−0,5). _(Rodada 1: reconta com `destroy` a 5 pts; antes 6,5. Sem mudança na carta.)_

## Dados
```json
{
  "id": "alt_selo_de_salomao",
  "nome": "Selo de Salomão",
  "cultura": "alta_magia",
  "tipo": "selo",
  "custo": 3,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "enemy_plays_entity", "acoes": [ { "op": "counter" }, { "op": "draw", "n": 1 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, object focus, sealed brass jar, brass vessel, glowing hexagram seal on the lid, ghostly demon being sucked into the jar, screaming spectral demon face, demon body stretched into smoke, smoke spiraling down into the jar, chains of light wrapped around the jar, trap, dark ritual chamber, stone floor, candles, black and gold, red candlelight, dramatic shadows, high contrast, dark scene
```

## Prompt Krea 2
Atributos obrigatórios: vaso de latão com tampa gravada com hexagrama brilhante · espírito fantasmagórico sendo sugado para dentro como fumaça · correntes de luz envolvendo o vaso
```krea
A sealed brass vessel, round and heavy, stands on a stone floor in a dark ritual chamber. Its lid is engraved with a six-pointed hexagram, two interlaced triangles, glowing bright gold. A ghostly demon spirit with a screaming face is being pulled down into the vessel, its body stretched into a spiral of grey smoke that pours into the opening. Bands and chains of golden light wrap around the vessel, closing like a trap. A few candles stand around it. The golden glow of the hexagram is the strongest light, lighting the smoke from below.
```
