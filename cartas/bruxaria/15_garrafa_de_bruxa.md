# Garrafa de Bruxa

| Campo | Valor |
|---|---|
| Cultura | bruxaria |
| Tipo | Selo |
| Custo | 2 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Quando o oponente jogar um Rito, anule-o; o oponente descarta 1 carta aleatória.

## Contexto mitológico
A garrafa de bruxa (*witch bottle*) é um dos poucos objetos de magia popular que a arqueologia encontra em quantidade: jarras de grés de barba (tipo *Bellarmine*, importadas da Renânia), do séc. XVII em diante, enterradas de boca para baixo sob a lareira ou a soleira de casas inglesas, cheias de urina, pregos e alfinetes dobrados, cabelo, unhas, às vezes um coração de pano espetado. Ralph Merrifield (*The Archaeology of Ritual and Magic*, 1987) catalogou dezenas; a garrafa de Greenwich (2004) chegou lacrada e com conteúdo intacto. A prática atravessou o Atlântico e seguiu até o séc. XX.

A lógica é a da magia simpática em espelho: a urina e o cabelo da vítima enfeitiçada fazem da garrafa um "corpo" dela; os pregos e espinhos, quando a garrafa é aquecida, atormentam a bruxa que lançou o malefício, obrigando-a a desfazê-lo — ou devolvem o feitiço à sua origem. Joseph Blagrave (*Astrological Practice of Physick*, 1671) dá a receita; os *cunning folk* a vendiam como contra-feitiço padrão.

Na carta a garrafa faz o que fazia: o feitiço lançado contra a bruxa não chega — e volta, levando algo de quem o lançou.

## Papel no jogo
Única anulação do deck: protege Hécate e a Morrigan de um Rito de remoção, ou nega um Rito de cura/buff adversário no momento errado. O descarte adicional castiga o oponente por tentar. Boa para pôr virada no turno em que se invoca a Lendária. Como todo *counter*, é inútil contra decks pobres em Ritos; aí fica no campo ocupando um slot de Selo.

## Balanço
Orçamento P = 2·2+1 + 1 (Selo) = 6 pts. Gasto: anular Rito inimigo (3) + oponente descarta 1 aleatória (2) = 5. Dentro (P−1).
Rodada 2 de balanceamento: o Analista propôs acrescentar "cura 2 na Cornucópia" (6/6). **Recusado**: a identidade do deck é não curar a Cornucópia (nenhum `heal` nela, `_deck.md`), e o ganho medido foi +0,4 pp — ruído. A folga de 1 pt fica.

## Dados
```json
{
  "id": "bru_garrafa_de_bruxa",
  "nome": "Garrafa de Bruxa",
  "cultura": "bruxaria",
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
      { "op": "discard", "alvo": "enemy_hand_random", "n": 1 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, object focus, single brown stoneware jug, bellarmine bottle, grim bearded man face molded on the bottle neck, salt glaze, round belly, cork sealed with red wax, bent iron nails and pins spilling from a crack, strands of hair, bottle half buried under a brick hearth, red curse energy striking the bottle and bouncing back, faint purple runes on the floor, embers, soot, cobwebs, purple and green, red glow, candlelight, rim lighting, ominous, dark atmosphere
```

## Prompt Krea 2
Atributos obrigatórios: jarra de grés marrom tipo Bellarmine · rosto de barbudo moldado no gargalo · rolha com lacre vermelho · pregos e alfinetes tortos saindo por uma rachadura · meio enterrada sob a lareira
```krea
A single brown salt-glazed stoneware jug of the seventeenth-century Bellarmine type is half buried upside down in the earth beneath a brick hearth. A grim bearded man's face is molded in relief on its narrow neck, and its belly is round and speckled. The cork is sealed with red wax. Through a crack in its side spill bent iron nails, bent brass pins and a few strands of hair. A crackling streak of red curse energy strikes the jug from above and bounces back the way it came. Embers glow in the hearth and soot covers the bricks. The red curse light is the strong light source, flashing across the glaze.
```
