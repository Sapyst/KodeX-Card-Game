# Portão do Éden

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
Quando o oponente invocar uma Entidade, ela sofre 3 de dano e não ataca no próximo turno dela.

## Contexto mitológico
Depois da expulsão de Adão e Eva, "o Senhor Deus pôs, ao oriente do jardim do Éden, os querubins e a espada flamejante que se revolvia, para guardar o caminho da árvore da vida" (Gn 3,24). É a primeira menção a querubins na Bíblia, e já como guardiões de um limiar — função que repetem nas figuras de ouro sobre a Arca (Ex 25,18-22) e nas quatro criaturas de quatro faces que carregam o trono móvel de Ezequiel (Ez 1; 10).

Pseudo-Dionísio os coloca no segundo lugar da hierarquia, logo abaixo dos serafins, e interpreta o nome como "plenitude de conhecimento". A tradição posterior deu nomes ao guardião do portão: em Milton (*Paraíso Perdido*, IV) é Gabriel quem comanda a guarda do Paraíso, enquanto Uriel vigia do Sol (III); a cabala e algumas leituras tardias dão a espada de fogo a Uriel. O texto bíblico, porém, fala só de querubins e de uma espada que gira sozinha, de fogo — e é com ela que a carta fica.

O **Selo** é essa espada: quem tenta entrar no jardim é ferido e detido no limiar.

## Papel no jogo
Punição de invocação: a Entidade que o oponente joga chega com 3 de dano (morre, se tiver Vida ≤ 3) e, se sobreviver, fica congelada por um turno — tempo para Judite ou Davi acabarem com ela. Bom contra decks que dependem de um corpo grande no meio do jogo; pior contra tokens e Entidades de 1–2, que o deck já lida com as pragas. É o único Selo do deck que dispara em `enemy_plays_entity`, então o oponente não consegue "testar" com uma carta pequena sem perdê-la. Contra **Furtivo** depende da leitura do motor: a Entidade "não pode ser alvo de Selos até atacar", e aqui o alvo é `triggering` no momento em que entra — o simulador deve fixar se o Selo a acerta ou é pulado.

## Balanço
Orçamento P = 2·C+1 = 5 pts, +1 grátis de Selo = 6. Gasto: 3 de dano a Entidade (3) + Freeze (tabela §10) 1,5 = 4,5. Dentro (faixa 4–6). Nota: o Freeze aqui tem valor real porque a Entidade entra cansada e perde *também* o turno seguinte — dois turnos sem atacar.

## Dados
```json
{
  "id": "cri_portao_do_eden",
  "nome": "Portão do Éden",
  "cultura": "cristianismo",
  "tipo": "selo",
  "custo": 2,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "enemy_plays_entity", "acoes": [
      { "op": "damage", "alvo": "triggering", "n": 3 },
      { "op": "freeze", "alvo": "triggering" } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, giant flaming sword floating in the air, spinning sword of fire, sword turning by itself, motion blur trail of fire, guarding gate, ancient stone gateway, closed garden gate, wall of paradise, lush garden glimpsed through gate, tree of life glowing far inside, winged guardian silhouette with four faces behind the gate, cherub shadow, dark forest outside, dry barren ground in foreground, night, fire reflecting on stones, trap, forbidden threshold, holy light, gold and white, fiery orange and gold, embers, dramatic rim lighting, scenery
```

## Prompt Krea 2
Atributos obrigatórios: espada de fogo girando sozinha · portão de pedra fechado · árvore da vida brilhando ao fundo · silhueta de querubim de quatro faces · chão árido à frente
```krea
A giant sword of fire floating upright in the air before the closed eastern gate of the Garden of Eden, spinning by itself inside a circular trail of flame. The gate is an ancient arched stone gateway set in a high wall overgrown with vines, its heavy bronze doors shut. Through a narrow gap, the glowing Tree of Life is visible far inside a lush garden. Behind the gate stands the tall dark silhouette of a cherub with four faces and large wings, mostly hidden in shadow. In the foreground lies dry, barren ground. Night, with the orange fire of the sword reflecting on the stones.
```
