# Roda do Samsara

| Campo | Valor |
|---|---|
| Cultura | hinduísmo |
| Tipo | Selo |
| Custo | 1 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Quando uma Entidade aliada morrer, devolva uma Entidade do seu cemitério à sua mão e compre 1 carta.

## Contexto mitológico
Samsara ("fluxo", "vagar") é o ciclo de nascimento, morte e renascimento a que todo ser está preso, movido pelo karma — o fruto inevitável das ações. A ideia aparece formulada nas Upanishads mais antigas: no Brihadaranyaka (4.4.5), "conforme age, conforme se conduz, assim o homem se torna; quem faz o bem torna-se bom, quem faz o mal torna-se mau". A Bhagavad Gita (2.22) usa a imagem que todo hindu conhece: "assim como um homem deixa as roupas gastas e veste roupas novas, a alma encarnada deixa os corpos gastos e entra em outros, novos".

A roda (chakra) é o símbolo visual do ciclo — a mesma roda que está na bandeira da Índia, herdada da iconografia budista e hindu do dharma. A morte, nessa visão, não é fim: é passagem. O objetivo último, moksha, é sair da roda; mas enquanto se está nela, o que cai volta.

O Selo é a roda girando: uma Entidade aliada morre, e outra, já morta, ganha um novo corpo na mão do jogador.

## Papel no jogo
Motor de valor para um deck que troca corpos frágeis com frequência: quando Garuda ou Jatayu morrem no turno do oponente, uma Entidade do cemitério volta à mão (pode ser a própria, ou Hanuman) e ainda se compra uma carta. Alimenta as duas cópias de Hanuman e recupera Narasimha ou Kali para serem jogados de novo. Fraco quando o oponente não ataca nem remove — fica parado.

## Balanço
Orçamento P = 2·1+1 = 3 pts (+1 Selo = 4). Gasto: reviver Entidade do cemitério para a mão 2 + comprar 1 carta 1,5 = 3,5. Dentro.

## Dados
```json
{
  "id": "hin_roda_do_samsara",
  "nome": "Roda do Samsara",
  "cultura": "hinduismo",
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
no humans, object focus, giant carved stone wheel, ancient chariot wheel, eight spokes, stone hub, wheel standing upright, wheel fills the frame, intricate carvings, glowing golden rim, ghostly soul lights circling the wheel, lotus petals swirling, falling leaves, dark temple wall, overgrown ruins, vines, night, saffron and blue, soft golden glow, faint mist, deep shadows, dark tone, mysterious, centered composition
```

## Prompt Krea 2
Atributos obrigatórios: roda de pedra com oito raios · aro dourado brilhante · luzes de almas girando · ruínas de templo cobertas de vinhas
```krea
A giant ancient carved stone wheel with exactly eight spokes and a round stone hub, standing upright and filling the frame, with no people. Intricate carvings of lotus and figures cover its spokes. Its rim glows with a soft golden light. Small pale soul lights circle slowly around the wheel, and lotus petals and dry leaves swirl in the air. It leans half hidden against a dark temple wall in overgrown ruins covered with vines and roots, as if waiting. Faint mist lies on the ground. The golden glow of the wheel is the only light in the night.
```
