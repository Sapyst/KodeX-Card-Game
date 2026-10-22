# Arapuca

| Campo | Valor |
|---|---|
| Cultura | indígena brasileira |
| Tipo | Selo |
| Custo | 1 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 2 |

## Texto da carta
Quando atacarem uma Entidade sua, o atacante sofre 1 de dano e fica congelado. Compre 1 carta.

## Contexto mitológico
A arapuca é a armadilha de pássaros mais difundida do Brasil, e o nome é tupi: *uirá-puca*, "coisa que prende pássaro" (Cascudo, *Dicionário do Folclore Brasileiro*). É uma pirâmide de varetas amarradas com cipó, armada sobre um gatilho com isca de milho ou fruta; quando o pássaro bica a isca, a pirâmide cai e o prende vivo, sem feri-lo.

Os cronistas do século XVI já descrevem as técnicas indígenas de captura — Gabriel Soares de Sousa (*Tratado Descritivo do Brasil*, 1587) dedica capítulos aos modos de caçar aves e caça miúda — e a arapuca passou intacta para a cultura caipira e sertaneja, com o mesmo nome e a mesma forma. É a imagem do caçador paciente que não mata: espera, prende, e decide depois.

Na carta é exatamente isso: o atacante fica preso um turno, leva o susto da queda, e você ganha tempo (uma carta) enquanto ele está na gaiola.

## Papel no jogo
Selo barato de tempo, com duas cópias para aparecer cedo. Colocado no turno 1 ou 2, pune o primeiro ataque inimigo: a criatura atacante perde seu próximo ataque, e você repõe a carta. Ideal para proteger Saci, Curupira e tokens até Boitatá chegar. Dispara só em ataque a uma Entidade sua (`enemy_attacks`); um ataque direto à Cornucópia, com o seu campo vazio, não o aciona — então sempre mantenha um corpo em campo. Fraco contra decks que não atacam (controle de Ritos), caso em que fica parado ocupando um dos 2 slots de Selo.

## Balanço
Orçamento P = 2·1+1 = 3 pts, +1 grátis de Selo = 4. Gasto (tabela §10): 1 de dano ao atacante (1) + Freeze no atacante (1,5) + comprar 1 (1,5) = 4. Dentro. _(Revisão: conta refeita com o valor oficial de Freeze = 1,5; resultado igual.)_

## Dados
```json
{
  "id": "ind_arapuca",
  "nome": "Arapuca",
  "cultura": "indigena",
  "tipo": "selo",
  "custo": 1,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "enemy_attacks", "acoes": [
      { "op": "damage", "alvo": "attacker", "n": 1 },
      { "op": "freeze", "alvo": "attacker" },
      { "op": "draw", "n": 1 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, object focus, close-up, pyramid-shaped bird trap, small pyramid of stacked wooden sticks tied with vines, propped up on a small trigger stick, corn kernels as bait underneath, on dark forest floor, dry leaves, roots, mossy stones, night, dim moonlight, green and orange, faint firelight, deep shadows, ominous, hidden trap, centered composition, clean silhouette, readable shape, high contrast, dramatic lighting, rim lighting, moody atmosphere, soft glow
```

## Prompt Krea 2
Atributos obrigatórios: armadilha piramidal de varetas amarradas com cipó · gatilho de vareta · isca de milho embaixo · escondida entre folhas
```krea
A small pyramid-shaped bird trap, an arapuca, standing alone on the dark forest floor: thin wooden sticks stacked in square layers that shrink toward the top, tied at the corners with green vine. One side rests propped on a tiny trigger stick, and a small pile of yellow corn kernels lies as bait in the shadow underneath. The trap is half hidden among dry leaves, roots and mossy stones, patient and waiting. A single thin shaft of moonlight falls through the canopy onto the trap, lighting the wood grain while the forest around it stays in shadow. The trap is the only subject in a still, empty clearing.
```
