# Chamas de Agni

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
Quando o oponente invocar uma Entidade, ela sofre 1 de dano e a Cornucópia inimiga sofre 1.

## Contexto mitológico
Agni é o fogo e o deus do fogo, uma das três divindades centrais do Rigveda ao lado de Indra e Soma: o primeiro hino do primeiro livro (RV 1.1) começa com seu nome — "Agni eu invoco, o sacerdote posto à frente". Ele é a boca dos deuses: tudo o que se verte no fogo do sacrifício — manteiga clarificada, grãos, soma — é Agni quem leva ao céu. Tem duas cabeças (o fogo doméstico e o fogo sacrificial), sete línguas de chama, cabelos em brasa, e cavalga um carneiro.

Agni é também o fogo que purifica e o que consome: é ele quem, faminto, pede a Krishna e Arjuna que lhe deem a floresta de Khandava para devorar (Mahabharata, Adi Parva) e, em troca, lhes entrega o Gandiva e o Sudarshana Chakra. É Agni quem recebe Sita na prova do fogo e a devolve intacta. Em todo rito hindu de passagem — nascimento, casamento, cremação — o fogo está presente como testemunha.

O Selo é o fogo que recebe o que chega: quem entra no campo do inimigo passa pelas chamas antes de se firmar.

## Papel no jogo
Selo barato de pressão: o oponente invoca e seu novo corpo já chega ferido (mata um 1 de Vida; deixa um 2 de Vida ao alcance de Garuda), enquanto a Cornucópia perde mais 1. Colocado no turno 1 ou 2, custa quase nada e pune a primeira invocação adversária. Fraco contra Entidades grandes (1 de dano não muda a conta de um 5/6) e inútil se o oponente já não joga Entidades.

## Balanço
Orçamento P = 2·1+1 = 3 pts (+1 Selo = 4). Gasto: 1 de dano a Entidade (alvo gatilho) 1 + 1 de dano direto à Cornucópia 2 = 3. Dentro (P−1).
Rodada 2 de balanceamento (pacote H1 do Analista): dano à Entidade 2 → 1 (−0,9 pp medido).

## Dados
```json
{
  "id": "hin_chamas_de_agni",
  "nome": "Chamas de Agni",
  "cultura": "hinduismo",
  "tipo": "selo",
  "custo": 1,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "enemy_plays_entity", "acoes": [
      { "op": "damage", "alvo": "triggering", "n": 1 },
      { "op": "damage", "alvo": "enemy_cornucopia", "n": 1 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, sacred fire trap, flames erupting from hidden square brick altar, seven tongues of fire, living flames, fire swirling, faint face formed in the flames, fire reaching outward, burst of fire, glowing cracks in the floor, dark temple courtyard, stone floor, marigold petals scattered, ambush, hidden, trap, smoke, embers, saffron and blue, orange firelight, deep shadows, dark tone, ominous, high contrast, dramatic lighting, centered composition
```

## Prompt Krea 2
Atributos obrigatórios: altar de tijolos escondido · sete línguas de fogo · rosto tênue nas chamas · pétalas de cravo-de-defunto · pátio escuro de templo
```krea
A sacred fire trap with no people. In a dark temple courtyard of worn stone, a square fire pit is sunk into the floor: its brick rim is flush with the paving stones, with no walls rising above the floor, only a thin square outline of bricks visible in the ground, half hidden by petals. Out of this hole erupt exactly seven separate tall tongues of flame, seven and no more, curling outward like grasping fingers made of fire. In the middle of the central flame a faint calm face is clearly visible, formed of fire. Glowing cracks spread across the stone floor toward the viewer, and orange marigold petals lie scattered around the pit. Smoke and embers rise into the black night. The fire is the only light, bright orange and gold, throwing long shadows across carved pillars.
```
