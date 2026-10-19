# Solve et Coagula

| Campo | Valor |
|---|---|
| Cultura | alta magia |
| Tipo | Selo |
| Custo | 1 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 2 |

## Texto da carta
Quando uma Entidade aliada morrer no turno do oponente, devolva uma Entidade do seu cemitério à mão e compre 1 carta.

## Contexto mitológico
*Solve et coagula* — "dissolve e coagula" — é o lema da Grande Obra alquímica. A matéria-prima deve ser dissolvida (nigredo, putrefação, a morte do corpo) para que o espírito se separe dela e volte a fixar-se num corpo novo e purificado (albedo, rubedo). O *Rosarium Philosophorum* (1550) mostra o rei e a rainha morrendo no banho, a alma subindo e descendo, e o Rebis ressurgindo. A fórmula circula como máxima anônima nos tratados dos séculos XVI–XVII (Khunrath, Maier, o corpus de "Basílio Valentim") antes de ganhar a forma lapidar que hoje se cita.

Éliphas Lévi a tornou visível para sempre: no frontispício do *Ritual da Alta Magia* (1856), o Baphomet de Mendes ergue um braço com "Solve" e baixa o outro com "Coagula" — o equilíbrio do que se desfaz e do que se refaz. Para Lévi, é a lei de toda operação mágica: nada se cria sem antes dissolver.

A carta é a Obra em miniatura: quando algo seu morre (solve), uma Entidade do cemitério volta à mão (coagula), e você ainda aprende uma carta.

## Papel no jogo
Recicla o fodder: cada Homúnculo, Silfo ou Vassago que o oponente mata no turno dele devolve uma Entidade do cemitério (pode ser outra — um Astaroth que morreu antes) e compra 1. Combina com Último Sopro do Homúnculo (duas compras numa morte). Custa 1, então vai para baixo no turno 1 sem atrasar nada. Não dispara em mortes por Sacrifício (acontecem no seu turno).

## Balanço
Orçamento P = 2·1+1 = 3 pts + 1 (Selo) = 4. Gasto: reviver Entidade do cemitério para a mão (2) + comprar 1 (1,5) = 3,5. Dentro.

## Dados
```json
{
  "id": "alt_solve_et_coagula",
  "nome": "Solve et Coagula",
  "cultura": "alta_magia",
  "tipo": "selo",
  "custo": 1,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "ally_dies", "acoes": [
      { "op": "revive", "alvo": "ally_graveyard_entity", "para": "hand" },
      { "op": "draw", "n": 1 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, object focus, round glass alchemical vessel, vessel centered on an athanor furnace, pale body dissolving inside the glass, black liquid in the vessel, small glowing white spirit rising out of the vessel, furnace glowing red below, alchemist laboratory, retorts, copper pipes, candles, dark stone chamber, black and gold, red candlelight, embers, dramatic shadows, high contrast, dark scene, close-up
```

## Prompt Krea 2
Atributos obrigatórios: frasco alquímico de vidro redondo sobre o atanor em brasa · corpo pálido se dissolvendo em líquido negro · pequeno espírito branco luminoso subindo do frasco
```krea
A round glass alchemical vessel sits on top of an athanor, a brick alchemist's furnace glowing red-orange below. Inside the vessel, a small pale figure is dissolving into black liquid, while from the open neck of the vessel a small glowing white spirit rises upward in a thin column of light, as if being reborn. Around it stand glass retorts and copper pipes in a dark stone laboratory. The red glow of the furnace and the white light of the rising spirit are the two lights of the scene, the red below and the white above.
```
