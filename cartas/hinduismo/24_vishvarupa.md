# Vishvarupa, a Forma Universal

| Campo | Valor |
|---|---|
| Cultura | hinduísmo |
| Tipo | Rito |
| Custo | 4 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Uma Entidade aliada passa a ser 6/6 e ganha Ímpeto.

## Contexto mitológico
No capítulo 11 da Bhagavad Gita, Arjuna, depois de ouvir Krishna explicar que ele é a origem e o fim de todas as coisas, pede para ver essa forma. Krishna lhe dá um olho divino, e Arjuna vê a Vishvarupa — a forma universal: incontáveis bocas e olhos, ornamentos e armas erguidas, sóis a arder ao mesmo tempo, todos os deuses e todos os seres contidos num só corpo sem começo, meio ou fim. Vê os guerreiros dos dois exércitos — Bhishma, Drona, Karna, os Kauravas — já entrando nas bocas em chamas do deus. Aterrorizado, pergunta quem é aquele, e a resposta é o verso mais lembrado do capítulo: "Eu sou o Tempo, destruidor dos mundos, que vem consumir todos os seres" (BG 11.32).

Arjuna pede que Krishna volte à forma de quatro braços, depois à forma humana amiga; Krishna o faz e explica que nem o estudo dos Vedas nem o sacrifício mostram aquela forma — só a devoção. A Vishvarupa é a revelação de que o auriga, o amigo, o guerreiro ao lado, é o universo inteiro.

O Rito é essa revelação aplicada a quem está em campo: a criatura comum mostra, por um instante, o que de fato é — e, como Arjuna depois da visão, pega o arco e avança.

## Papel no jogo
Transformação: qualquer Entidade aliada vira 6/6 com Ímpeto, mantendo as demais palavras-chave e a Relíquia. Melhor sobre corpos pequenos com texto bom — Jatayu, Matsya (o 0/1 do turno 1 vira um 6/6 que ataca na hora), Rama (6/6 com Renascer) — ou para "curar" um Hanuman ferido a 1 de Vida, que volta a 6/6 e continua crescendo (o crescimento acumulado é zerado: a carta define os valores). Sobre Shiva seria um rebaixamento, portanto não se usa nele. Fraco em mesa vazia — exige um corpo em campo.

## Balanço
Orçamento P = 2·4+1 = 9 pts. Gasto: definir ATK 6 / Vida 6 — valor medido contra o corpo médio 2/3 (tabela §10): +4 ATK e +3 Vida permanentes = 7 + Ímpeto 1 = 8. Dentro.
Revisão: era "5/5" sem Ímpeto, avaliado pelo pior caso (0/1); pelo corpo médio valia só 5 pts, abaixo de P−2. Subiu para 6/6 e ganhou Ímpeto.

## Dados
```json
{
  "id": "hin_vishvarupa",
  "nome": "Vishvarupa, a Forma Universal",
  "cultura": "hinduismo",
  "tipo": "rito",
  "custo": 4,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [
      { "op": "set_stats", "alvo": "ally_entity", "atk": 6, "vida": 6 },
      { "op": "give_keyword", "alvo": "ally_entity", "keyword": "impeto" } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1boy, solo, cosmic giant, colossal divine figure, multiple heads, many arms, multiple arms, holding weapons, blue skin, body filled with stars and galaxies, golden crown, gold ornaments, radiant like a thousand suns, flaming mouths, glowing eyes, towering above mountains, arms spread, above the clouds, starry void, nebula, cosmic, saffron and blue, blinding golden light, rim lighting, epic scale, from below, full body
```

## Prompt Krea 2
Atributos obrigatórios: gigante cósmico de pele azul · exatamente onze cabeças em camadas · exatamente vinte braços com armas · corpo cheio de estrelas e galáxias
```krea
Vishvarupa, the universal form, a colossal cosmic god with blue skin and an adult male body towering above the clouds, seen from below. He has exactly eleven crowned heads: a bottom row of five heads, a middle row of five heads, and one single head on top, eleven heads in total, some with blazing open mouths. He has exactly twenty arms spread like the spokes of a wheel: ten separate arms on the left side and ten separate arms on the right side, evenly spaced, each arm thin and distinct, each hand holding its own short weapon or a lotus (sword, axe, mace, discus, conch, trident, bow, arrow, club, lotus on each side), no two hands holding the same object, no long staffs. His body is filled with stars, galaxies and tiny suns. He wears a yellow silk dhoti. Starry void, blinding golden light behind him.
```
