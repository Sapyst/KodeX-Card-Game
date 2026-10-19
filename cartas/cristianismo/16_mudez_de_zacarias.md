# Mudez de Zacarias

| Campo | Valor |
|---|---|
| Cultura | cristianismo |
| Tipo | Selo |
| Custo | 2 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Quando o oponente jogar um Rito, anule-o. Compre 1 carta.

## Contexto mitológico
Zacarias, sacerdote da classe de Abias, está oferecendo incenso no Santuário quando Gabriel aparece à direita do altar e anuncia que sua mulher Isabel, estéril e idosa, terá um filho chamado João. Zacarias duvida: "Como saberei disso? Sou velho e minha mulher é de idade avançada." A resposta é a sentença: "Ficarás mudo e não poderás falar até ao dia em que isto acontecer, porque não acreditaste nas minhas palavras" (Lc 1,18-20).

O povo espera do lado de fora e, quando ele sai sem conseguir falar, entende que teve uma visão. Nove meses depois, na circuncisão do menino, Zacarias escreve numa tabuinha "João é o seu nome" — "e imediatamente a sua boca se abriu, a sua língua se soltou, e falava bendizendo a Deus" (Lc 1,63-64): o *Benedictus*. A iconografia o mostra com a tabuinha na mão, dedo nos lábios.

Como **Selo**, a palavra do oponente é silenciada antes de produzir efeito; e, como Zacarias, você ganha algo no silêncio — uma carta.

## Papel no jogo
A única anulação do deck. Protege os Renascidos e as Lendárias de Ritos de remoção, área ou roubo. Como todo `counter`, exige adivinhar que o oponente vai jogar um Rito — mas o deck cristão perde pouco por esperar, e a compra extra compensa o tempo. Coloque-o quando o oponente estiver com Fé para a carta grande dele. Inútil contra decks de poucos Ritos (que invocam e equipam).

## Balanço
Orçamento P = 2·C+1 = 5 pts, +1 grátis de Selo = 6. Gasto: anular Rito inimigo 3 + comprar 1 carta 1,5 = 4,5. Dentro.

## Dados
```json
{
  "id": "cri_mudez_de_zacarias",
  "nome": "Mudez de Zacarias",
  "cultura": "cristianismo",
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
1boy, solo, old priest, long grey beard, priestly robe, blue and white vestments, turban, finger pressed to lips, silence gesture, holding wax writing tablet in other hand, wide shocked eyes, speechless, standing beside golden incense altar, smoke rising, temple sanctuary interior, dark stone columns, menorah, bright blinding light at right of the altar, hidden angelic presence as pure light, holy light, gold and white, stained glass light, incense smoke, rim lighting, dark and solemn, full body
```

## Prompt Krea 2
Atributos obrigatórios: idoso de barba grisalha · dedo indicador sobre os lábios (mudo) · tabuinha de cera na mão esquerda · vestes sacerdotais brancas e turbante · altar de incenso dourado
```krea
An elderly Middle Eastern Hebrew priest about 70 years old, Zechariah, with a long grey beard, standing beside a golden incense altar with thick smoke rising from a bowl of burning incense on top, no candles. He has been struck mute: his lips are pressed shut and the index finger of his right hand is laid vertically across his closed lips, touching them, in the gesture of silence. His left hand holds a small blank wooden writing tablet coated with wax, with nothing written on it. He wears white linen priestly vestments with a blue sash and a white turban. A dark Temple sanctuary, a pillar of white-gold light beside the altar, his eyes wide with awe.
```
