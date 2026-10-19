# Andras, o Semeador de Discórdia

| Campo | Valor |
|---|---|
| Cultura | alta magia |
| Tipo | Entidade |
| Custo | 4 Fé |
| ATK / Vida | 3 / 2 |
| Palavras-chave | Despertar |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Despertar: destrua uma Entidade inimiga de custo 3 ou menos.

## Contexto mitológico
Andras é o 63º espírito da *Ars Goetia*: um Grande Marquês que aparece com corpo de anjo e cabeça de corvo noturno (ou coruja), montado num forte lobo negro e brandindo uma espada afiada e brilhante. Seu ofício é **semear discórdias** — e a Goetia acrescenta a advertência mais dura da lista: "se o exorcista não tomar cuidado, ele o matará, e aos seus companheiros". Governa 30 legiões. Weyer (1577) repete a descrição e o aviso.

É o espírito assassino do catálogo, aquele que os grimórios recomendam evocar só com o círculo perfeitamente traçado, porque busca qualquer brecha. Collin de Plancy o desenhou exatamente assim: asas abertas, cabeça de coruja, lobo a galope, espada erguida.

A carta é a remoção pontual do deck: Andras chega e mata — mas só o pequeno (custo ≤ 2), porque a discórdia funciona nas fileiras, não contra reis. A limitação é também a mecânica do aviso: ele não serve contra o que é grande demais.

## Papel no jogo
Resposta a decks de agressão barata e média (tokens, Entidades de custo 1–3: Caipora, Vassago, Benandante, Lázaro, Lü Dongbin, Ganesha) e limpador de bloqueadores antes de um ataque. Corpo 3/2 no turno 4 — bate, mas morre fácil. Fica morto na mão contra tabuleiros só de custo alto — nesses jogos é um 3/2 vanilla; prefira Marbas.

## Balanço
Orçamento P = 2·4+1 = 9 pts. Gasto: ATK 3 + Vida 2 + destruir Entidade escolhida com `target_cost_max` ≤ 3 (3,5) = 8,5. Dentro (P−0,5).
Rodada 1 de balanceamento: era 3/3 com custo ≤ 2 (9,5 com a tabela §10 nova). Trocou 1 de Vida por alcance: custo ≤ 3 cobre a maioria dos corpos que travam o deck.

## Dados
```json
{
  "id": "alt_andras",
  "nome": "Andras, o Semeador de Discórdia",
  "cultura": "alta_magia",
  "tipo": "entidade",
  "custo": 4,
  "atk": 3,
  "vida": 2,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "cond": { "tipo": "target_cost_max", "n": 3 },
      "acoes": [ { "op": "destroy", "alvo": "enemy_entity" } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1other, solo, raven-headed demon, black raven head, long sharp black beak, bird head, black feathered wings spread, dark armor, riding a huge black wolf, mounted on the wolf's back, wolf snarling, wolf lunging forward, rider raising a gleaming sword, charging toward viewer, dark ritual hall, cracked stone floor, broken candles, black and gold, red candlelight, embers, dust, dramatic shadows, gothic architecture, full body
```

## Prompt Krea 2
Atributos obrigatórios: corpo de anjo com cabeça de corvo negro (bico longo) · asas de penas negras abertas · montado num grande lobo negro · espada brilhante erguida para golpear · armadura escura
```krea
Andras, a demon with the body of a tall adult angel and the head of a black night raven: a feathered raven head with a long sharp black beak and small gleaming eyes, set on a human neck. He has two large black feathered wings spread wide and two normal human arms. He wears dark blackened armor. He rides on the back of a huge black wolf that lunges forward snarling, and he raises a long gleaming steel sword high in his right hand, about to strike down, while his left hand grips the wolf's fur. They charge out of a ruined dark ritual hall over cracked stone. A cold flash of light runs along the sword blade.
```
