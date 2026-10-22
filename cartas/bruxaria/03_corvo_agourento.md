# Corvo Agourento

| Campo | Valor |
|---|---|
| Cultura | bruxaria |
| Tipo | Entidade |
| Custo | 2 Fé |
| ATK / Vida | 1 / 2 |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Despertar: O oponente descarta 1 carta aleatória.

## Contexto mitológico
Em toda a Europa o corvo e a gralha são aves de agouro: comem os mortos nos campos de batalha, gritam sobre as casas onde alguém vai morrer e repetem palavras humanas. Na Irlanda são a forma da Morrigan e de Badb, a "corvo-de-batalha", que pousa no ombro de Cú Chulainn morto para que seus inimigos saibam que ele já não é perigoso (*Aided Con Culainn*, "A morte de Cú Chulainn", no ciclo do Ulster). No Norte, Huginn e Muninn — Pensamento e Memória — voam o mundo todo e voltam a sussurrar no ouvido de Odin (*Grímnismál* 20).

Nos julgamentos de bruxaria o corvo aparece menos que o gato, mas o folclore o faz mensageiro e espião da bruxa: ela o manda rondar a casa do vizinho, ouvir o que se diz, pousar no telhado e "secar" a sorte de quem mora ali. É o veículo do **olho-gordo** — a inveja que, só de olhar, faz perder.

Daí a mecânica: quando o Corvo pousa, algo do oponente se perde. Não é dano, não é combate: é a carta que ele tinha na mão e já não tem.

## Papel no jogo
Disrupção barata no turno 2: 1/2 e o oponente perde uma carta aleatória — antes de ela chegar à mesa, o que é melhor do que lidar com ela depois. Casa com Pó de Ossos e Garrafa de Bruxa para esvaziar a mão inimiga no meio do jogo. O corpo 1/2 sobrevive a tokens 1/1 e serve de Sacrifício; é ruim contra oponentes que jogam toda a mão rápido (sem o que descartar).

## Balanço
Orçamento P = 2·2+1 = 5 pts. Gasto: ATK 1 + Vida 2 + Despertar: oponente descarta 1 aleatória (2 pts) = 5. Dentro.

## Dados
```json
{
  "id": "bru_corvo_agourento",
  "nome": "Corvo Agourento",
  "cultura": "bruxaria",
  "tipo": "entidade",
  "custo": 2,
  "atk": 1,
  "vida": 2,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [ { "op": "discard", "alvo": "enemy_hand_random", "n": 1 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, large black raven, glossy black feathers, spread wings, landing on a crooked chimney, head tilted, open beak, glowing purple eye, stolen shiny trinket clutched in its beak, thatched cottage roof, moss, dead tree branches, full moon, drifting clouds, mist, night sky, bats in the distance, feathers falling, purple and green, moonlight, rim lighting, ominous, dark atmosphere, detailed feathers, full body
```

## Prompt Krea 2
Atributos obrigatórios: corvo grande negro · asas abertas pousando · olho roxo brilhante · bugiganga roubada no bico · chaminé torta de cabana
```krea
A large black common raven with glossy blue-black feathers is landing on top of a crooked stone chimney of a thatched cottage. Its wings are spread wide, its head is tilted, and one eye glows purple. In its thick black beak it clutches a small shiny stolen silver ring. Loose black feathers drift down past the mossy thatched roof. Dead tree branches reach in from the side, and mist hangs over a sleeping village below. A huge full moon behind the raven is the strong light source, outlining every feather of its spread wings in pale light.
```
