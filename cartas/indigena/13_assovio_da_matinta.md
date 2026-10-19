# Assovio da Matinta

| Campo | Valor |
|---|---|
| Cultura | indígena brasileira |
| Tipo | Selo |
| Custo | 1 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
No fim do turno do oponente: ele descarta 1 carta aleatória e sua Cornucópia sofre 1 de dano.

## Contexto mitológico
A Matinta Perera (Matintaperera, Matinta-Pereira) é figura do Pará e do baixo Amazonas: uma velha que, à noite, se transforma num pássaro e pousa nos telhados assobiando um silvo agudo e repetido — *matinta-perê, matinta-perê* — até que alguém da casa prometa fumo. Na manhã seguinte uma velha da vizinhança aparece para cobrar o tabaco prometido; quem não dá sofre uma desgraça. Cascudo (*Dicionário do Folclore Brasileiro*) e Barbosa Rodrigues (*Poranduba Amazonense*, 1890) registram o mito, aparentado ao Saci do Norte, que também é pássaro e também se chama matinta.

O nome e o pássaro são indígenas — o assobio é o da *Tapera naevia*, o saci ou peitica, ave cujo canto noturno é mau agouro em toda a Amazônia. A velha-feiticeira é acréscimo colonial. A carta fica com o núcleo: o assobio que tira o sono e a cobrança inevitável.

## Papel no jogo
Pressão fora do combate, coisa rara no deck: no fim do turno do oponente, ele perde uma carta da mão e 1 ponto de Cornucópia. Melhor cedo (turno 1–2), quando o oponente ainda tem mão cheia, ou contra decks de controle que não atacam e não disparam Arapuca/Mundéu. É o único dano direto do deck junto com Fogo de Monan. Dispara só uma vez e vai ao cemitério.

## Balanço
Orçamento P = 2·1+1 = 3 pts, +1 grátis de Selo = 4. Gasto (tabela §10): oponente descarta 1 aleatória (2) + 1 de dano direto à Cornucópia (2) = 4. Dentro. _(Revisão: conta confirmada. Dano direto do deck: 1 aqui + 1 em Fogo de Monan = 2 ≤ 8.)_

## Dados
```json
{
  "id": "ind_assovio_da_matinta",
  "nome": "Assovio da Matinta",
  "cultura": "indigena",
  "tipo": "selo",
  "custo": 1,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "enemy_end_turn", "acoes": [
      { "op": "discard", "alvo": "enemy_hand_random", "n": 1 },
      { "op": "damage", "alvo": "enemy_cornucopia", "n": 1 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, small slender brown bird, striped cuckoo, streaked brown plumage, raised spiky crest, long tail, beak open whistling, perched on a palm-thatched roof, indigenous village of palm thatch huts, no bricks, no chimney, night, thin crescent moon, one warm lit doorway, green and orange, pale moonlight, fog, bad omen, eerie, deep shadows, full body, clean silhouette, readable shape, high contrast, dramatic lighting, rim lighting
```

## Prompt Krea 2
Atributos obrigatórios: pássaro saci (Tapera naevia) estriado de marrom · crista eriçada · bico aberto assobiando · sobre telhado de palha · lua crescente
```krea
A small slender striped cuckoo, the Tapera naevia bird, with streaked brown and buff plumage, a raised rufous spiky crest and a long tail, perched alone on the ridge of a palm-thatched roof. Its beak is open in a sharp, piercing whistle. Below lies a sleeping Indigenous village of palm-thatch huts on sandy ground, with one doorway glowing warm with firelight. A thin crescent moon hangs in a foggy night sky, and pale moonlight outlines the bird's silhouette as the strong light. The mood is an eerie omen of bad luck.
```
