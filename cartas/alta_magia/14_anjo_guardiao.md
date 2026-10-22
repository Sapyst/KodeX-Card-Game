# Anjo Guardião Sagrado

| Campo | Valor |
|---|---|
| Cultura | alta magia |
| Tipo | Entidade |
| Custo | 7 Fé |
| ATK / Vida | 4 / 8 |
| Palavras-chave | Guarda, Renascer, Despertar, Lendária |
| Lendária | sim |
| Cópias no deck | 1 |

## Texto da carta
Guarda. Renascer. Despertar: Cure 4 da sua Cornucópia.

## Contexto mitológico
O Anjo Guardião Sagrado é o objetivo de toda a alta magia a partir de Abramelin. *O Livro da Magia Sagrada de Abramelin o Mago*, atribuído a Abraão de Worms (c. 1458; mss. alemães dos séc. XVII–XVIII, versão francesa traduzida por Mathers em 1898), prescreve uma operação de seis meses (dezoito, nos mss. alemães) de oração, jejum e reclusão num oratório com janela para o oriente. Ao fim, o Anjo aparece ao mago, e só então — com a autoridade do Anjo — ele convoca os quatro príncipes infernais e seus servos e os obriga a jurar obediência; a partir daí os quadrados mágicos do livro funcionam.

Crowley fez do "Conhecimento e Conversação do Anjo Guardião Sagrado" o centro da sua magia: "o único ritual supremo", escreve em *Magick in Theory and Practice*; o *Liber Samekh* (adaptado do Rito do Sem-Cabeça dos papiros gregos) é sua versão do método. Para ele, Aiwass — a inteligência que ditou o *Liber AL* — era seu Anjo. Na Árvore da Vida, o encontro com o Anjo é o grau de Adeptus Minor em Tiphareth, a etapa antes do Abismo: é o que protege o mago para que, mais tarde, possa atravessar Daath sem ser dissolvido por Choronzon.

A carta é a proteção absoluta: Guarda (nada passa por ele), Renascer (o Anjo sempre volta à mão do mago), e ao chegar cura a Cornucópia — o primeiro efeito do Conhecimento é a paz.

## Papel no jogo
Lendária defensiva e condição de estabilização: no turno 7 entra, cura 4, e qualquer ataque inimigo tem de passar por 8 de Vida. Se morre, volta à mão e pode ser invocado de novo (curando 4 de novo). Com Sigillum Dei Aemeth vira 4/11. É a resposta do deck a decks agressivos que sobreviveram aos Selos; a Babalon fecha o jogo enquanto o Anjo o segura. Caro: exige que o deck tenha controlado o tabuleiro até o turno 7.

## Balanço
Orçamento P = 2·7+1 = 15 pts; Lendária até +2 → 17. Gasto: ATK 4 + Vida 8 + Guarda (1) + Renascer (2) + curar 4 de Cornucópia (2) = 17. Lendária, no limite do +2.

## Dados
```json
{
  "id": "alt_anjo_guardiao",
  "nome": "Anjo Guardião Sagrado",
  "cultura": "alta_magia",
  "tipo": "entidade",
  "custo": 7,
  "atk": 4,
  "vida": 8,
  "lendaria": true,
  "keywords": ["guarda", "renascer"],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [ { "op": "heal", "alvo": "ally_cornucopia", "n": 4 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1other, solo, angel made of golden light, radiant humanoid silhouette, faceless, great wings of light, arms spread wide, protective stance, standing in front of a small altar, shielding it, body glowing from within, rays of golden light, healing glow, candles on the altar, oratory, tall window facing east, dawn light through the window, stone floor, black and gold, golden light, dust particles, soft shadows, gothic architecture, warm glow, high contrast, serene atmosphere, full body
```

## Prompt Krea 2
Atributos obrigatórios: anjo alto feito de luz dourada, rosto oculto pelo brilho · túnica branca longa · grandes asas de luz abertas · braços abertos de frente, protegendo o altar (Guarda) · luz do amanhecer pela janela do leste
```krea
The Holy Guardian Angel, a tall radiant figure with adult human proportions, its face hidden by a soft blaze of golden light. It wears a long flowing white robe and has two arms and two great wings made of golden light. It stands facing the viewer in front of a small stone altar with candles, arms spread wide and wings open in a protective, shielding stance, guarding the altar behind it. Warm rays of golden healing light radiate from its body. The scene is a small stone oratory with a tall gothic window facing east, where the first light of dawn breaks behind the angel.
```
