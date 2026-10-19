# Benandante

| Campo | Valor |
|---|---|
| Cultura | bruxaria |
| Tipo | Entidade |
| Custo | 3 Fé |
| ATK / Vida | 2 / 3 |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 2 |

## Texto da carta
Despertar: congele uma Entidade inimiga à escolha (ela não ataca no próximo turno).

## Contexto mitológico
Os *benandanti* ("os que andam bem") do Friul, nordeste da Itália, são o achado de Carlo Ginzburg em *Os Andarilhos do Bem* (1966). Entre 1575 e 1675 dezenas de camponeses contaram à Inquisição de Aquileia e Concórdia a mesma história: nascidos "com a camisa" (a membrana amniótica), eram chamados quatro vezes por ano, nas noites das Têmporas, a sair do corpo em espírito — em forma de rato ou borboleta, ou montados em lebres e gatos — para lutar nos campos de Josafat contra os bruxos (*malandanti*). Os benandanti iam armados de ramos de funcho; os bruxos, de canas de sorgo. Se os benandanti vencessem, a colheita seria farta; se perdessem, viria a fome.

Eles também curavam enfeitiçados, viam os mortos em procissão e se consideravam defensores da fé. A Inquisição, sem categoria para isso, levou um século de interrogatórios para convencê-los de que eram bruxos também — e eles, aos poucos, passaram a confessar o sabá que os juízes esperavam. Ginzburg lê nos benandanti o resto vivo de um culto agrário de êxtase de tipo xamânico, parente do *táltos* húngaro e dos *kresniki* eslovenos (*História Noturna*, 1989).

Na carta o benandante é um guerreiro da bruxaria popular: entra em campo e já derruba um bruxo inimigo na batalha noturna. O derrotado não some — fica atordoado uma volta.

## Papel no jogo
Tempo e controle: 2/3 por 3 Fé que impede o melhor atacante inimigo de agir no próximo turno — tempo para posicionar Mau-Olhado, invocar Strega ou juntar os familiares do Sacrifício. Duas cópias para que o deck congele com frequência. Combina com Malefício (o alvo congelado é silenciado e reduzido antes de voltar a atacar). Mau contra Entidades que valem pelo Despertar, não pelo ataque.

## Balanço
Orçamento P = 2·3+1 = 7 pts. Gasto: ATK 2 + Vida 3 + Despertar: freeze em inimigo escolhido (1,5 pts, tabela §10) = 6,5. Dentro (0,5 de folga).

## Dados
```json
{
  "id": "bru_benandante",
  "nome": "Benandante",
  "cultura": "bruxaria",
  "tipo": "entidade",
  "custo": 3,
  "atk": 2,
  "vida": 3,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [ { "op": "freeze", "alvo": "enemy_entity" } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1boy, solo, adult peasant man, realistic proportions, short brown hair, white linen shirt, brown trousers, rope belt, barefoot, gripping a long green fennel stalk with feathery leaves and yellow flower umbels, no sword, no metal, swinging the fennel stalk like a club, battle stance, translucent ghostly body, pale spectral glow, shadowy witch figure fallen at his feet, broken sorghum cane, night wheat field, fog, stars, purple and green, moonlight, rim lighting, dynamic pose, full body
```

## Prompt Krea 2
Atributos obrigatórios: camponês adulto friulano · camisa de linho branca e calça marrom, descalço · talo de funcho com flores amarelas · corpo espectral translúcido · campo de trigo à noite
```krea
An adult Northern Italian peasant man about 30 years old, with fair skin and short brown hair, swings a long green fennel stalk like a club in a wheat field at night. He is a ghost: his entire body, face, hands, shirt and trousers are semi-transparent and glowing pale blue-white, and the wheat stalks behind him are clearly visible through his chest and legs. He wears a plain white linen shirt, brown wool trousers and a rope belt, and he is barefoot. Both hands grip the fennel stalk, whose feathery leaves and yellow flower umbels whip through the air. A broken sorghum cane lies on the ground. A cold moon lights his see-through glowing body.
```
