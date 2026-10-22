# Mundéu

| Campo | Valor |
|---|---|
| Cultura | indígena brasileira |
| Tipo | Selo |
| Custo | 2 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 2 |

## Texto da carta
Quando atacarem uma Entidade sua, o atacante sofre 4 de dano. Cure 4 da sua Cornucópia.

## Contexto mitológico
O mundéu (do tupi *mundé*, "armadilha") é a armadilha de peso usada para caça grande — anta, veado, porco-do-mato, onça. Um tronco pesado fica suspenso sobre a trilha por uma forquilha ligada a um gatilho de isca ou de passagem; quando o animal toca o gatilho, o tronco cai e o esmaga. Soares de Sousa (*Tratado Descritivo do Brasil*, 1587) e, séculos depois, Cascudo (*Dicionário do Folclore Brasileiro*) descrevem o mundéu como a técnica indígena de caça mais eficiente para animais que o arco não derruba de um tiro.

Diferente da arapuca, o mundéu mata. E a caça apanhada no mundéu é a que alimenta a aldeia — a anta ou o queixada rendem o moquém da festa. Na lógica dos guardiões da mata do deck, o mundéu é o castigo definitivo do invasor, e também sua utilidade: o que entra à força vira comida.

## Papel no jogo
O Selo de dano do deck: 4 ao atacante mata a maioria das criaturas de custo até 4 no momento em que avançam, e ainda cura 4 na Cornucópia ("a caça alimenta a aldeia"). Combina com Boitatá e Curupira — o atacante leva o contragolpe e o tronco. Com duas cópias, o oponente aprende a temer qualquer Selo virado para baixo do deck indígena, o que por si só segura ataques. Ruim contra criaturas com mais de 4 de Vida (só fere) e inútil contra decks que não atacam. Como a Arapuca, só dispara em ataque a uma Entidade sua — não em ataque direto à Cornucópia.

## Balanço
Orçamento P = 2·2+1 = 5 pts, +1 grátis de Selo = 6. Gasto (tabela §10): 4 de dano a Entidade (4) + curar 4 de Cornucópia (2) = 6. Dentro.
Rodada 1 de balanceamento: cura era 2 (5/6). É o Selo que mais dispara (84 %); sobe para P.

## Dados
```json
{
  "id": "ind_mundeu",
  "nome": "Mundéu",
  "cultura": "indigena",
  "tipo": "selo",
  "custo": 2,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "enemy_attacks", "acoes": [
      { "op": "damage", "alvo": "attacker", "n": 4 },
      { "op": "heal", "alvo": "ally_cornucopia", "n": 4 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, object focus, deadfall trap, heavy horizontal log hanging above a jungle trail, log held up by a forked stick, trigger vine stretched across the path, log about to fall, glowing eyes of a beast in the dark beyond, muddy trail, giant roots, night, moonlight shaft, green and orange, dim firelight, deep shadows, ominous, ambush, dramatic low angle, clean silhouette, readable shape, high contrast, dramatic lighting, rim lighting, moody atmosphere, soft glow, sharp focus
```

## Prompt Krea 2
Atributos obrigatórios: tronco pesado suspenso sobre a trilha · forquilha de sustentação · cipó-gatilho atravessado · olhos de bicho chegando no escuro
```krea
A deadfall trap set across a narrow muddy jungle trail at night: a heavy horizontal tree trunk hangs above the path, held up by a single forked wooden stick, with a taut vine trigger stretched low across the trail. The log looks ready to fall at any moment. Beyond the trap, deep in the darkness, a small pair of glowing animal eyes approaches along the trail. Giant buttress roots and hanging lianas frame the scene. Seen from a dramatic low angle, with one strong shaft of moonlight cutting down across the suspended log.
```
