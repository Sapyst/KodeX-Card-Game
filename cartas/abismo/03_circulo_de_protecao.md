# Círculo de Proteção

| Campo | Valor |
|---|---|
| Cultura | abismo (módulo especial — Conjunto do Abismo) |
| Tipo | Selo |
| Custo | 2 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | sim |
| Cópias no deck | 1 |

## Texto da carta
Quando atacarem uma Entidade sua, o atacante sofre 2 de dano. Virado para baixo, conta como o Círculo do Sigilo 333.

## Contexto mitológico
O círculo mágico é a fronteira entre o operador e o que ele evoca. Na *Goetia* tem nove pés de diâmetro, com os nomes divinos e os nomes dos sefirot escritos na banda externa; na tradição da Golden Dawn é traçado com a adaga ou a varinha, sempre no sentido do sol. Sair do círculo durante a evocação é a falha clássica — e exatamente o que Choronzon tenta provocar.

Em Bou Saâda, Neuburg ficou dentro do círculo de areia com a adaga mágica. Choronzon, com conversa, apagou parte da linha com areia e se atirou sobre ele; Neuburg o repeliu e refez o círculo. A carta é um Selo porque o círculo é passivo até ser testado: só revela sua força quando algo tenta atravessá-lo.

## Papel no jogo
Peça 2 do ritual. Como qualquer Selo, o oponente sabe que há algo virado para baixo — e pode atacar de propósito com uma Entidade descartável para gastá-lo antes do Sigilo.

## Balanço
P = 5 (+1 Selo) = 6. Gasto: 2 de dano ao atacante = 2. Deliberadamente fraco.

## Dados
```json
{ "id": "aby_circulo", "nome": "Círculo de Proteção", "cultura": "abismo", "tipo": "selo", "custo": 2,
  "atk": null, "vida": null, "lendaria": true, "keywords": [], "sacrificio": 0,
  "efeitos": [ { "gatilho": "enemy_attacks", "acoes": [ { "op": "damage", "alvo": "attacker", "n": 2 } ] } ], "usos": null }
```

## Prompt de arte
```prompt
no humans, glowing magic circle drawn on desert sand, concentric rings, hebrew letters and sigils, ritual dagger stuck in the sand at the center, part of the line being erased by blowing sand, desert night, starry sky, sand yellow and void black, pale blue glow, from above
```

## Prompt Krea 2
Atributos obrigatórios: círculo mágico brilhante na areia, anéis concêntricos · letras hebraicas e sigilos · adaga ritual cravada no centro · parte da linha sendo apagada pela areia ao vento · vista de cima
```krea
Seen from above: a large magic circle drawn in desert sand at night, made of two concentric rings filled with Hebrew letters and sigils, its lines glowing pale blue. A ritual dagger with a black handle is stuck upright in the sand at the center. On one side, wind-blown sand is sliding across the circle and erasing a short section of its outer line, a hidden gap that the circle is about to close again. The rest of the desert is dark under a starry sky. The blue glow of the circle is the main light.
```
