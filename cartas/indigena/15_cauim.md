# Cauim

| Campo | Valor |
|---|---|
| Cultura | indígena brasileira |
| Tipo | Rito |
| Custo | 1 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 2 |

## Texto da carta
Cure 2 da sua Cornucópia. Compre 1 carta.

## Contexto mitológico
O cauim (*kaui*) é a bebida fermentada dos povos tupi: mandioca (ou milho, caju, batata-doce) cozida, **mastigada pelas mulheres** e cuspida de volta no pote, onde a saliva inicia a fermentação; depois de dias, bebe-se morno, em cuias, até acabar. Hans Staden (1557), Jean de Léry (1578, cap. IX) e Fernão Cardim (c. 1584) descrevem com espanto as *cauinagens*: festas de aldeia inteira que duravam dias, acompanhadas de cantos e danças, obrigatórias antes da guerra, na execução de prisioneiros, em casamentos e luto.

Léry anota que o cauim "é bebido com grande regozijo" e que os Tupinambá riam dos franceses por comerem enquanto bebiam — comer e beber eram atos separados. Métraux (*A religião dos Tupinambás*, 1928) vê na cauinagem o rito social central: é o momento em que a aldeia se refaz e os espíritos dos antepassados são lembrados. Beber junto é renovar a comunidade.

A carta é a cauinagem em miniatura: a aldeia (Cornucópia) se recupera e a memória traz algo novo (uma carta).

## Papel no jogo
Carta de 1 Fé que nunca é ruim: cura 2 na Cornucópia e substitui a si mesma. Jogue no turno 1 (primeiro jogador, sem compra) ou em qualquer turno com Fé sobrando. Duas cópias para suavizar a curva e dar ao deck a vida longa de que suas Lendárias precisam. Contra decks agressivos de dano direto, a cura é o que faz chegar ao turno 7.

## Balanço
Orçamento P = 2·1+1 = 3 pts. Gasto (tabela §10): curar 2 de Cornucópia (1) + comprar 1 (1,5) = 2,5. Dentro (P−0,5). _(Revisão: conta confirmada; é o exemplo canônico da DSL.)_

## Dados
```json
{
  "id": "ind_cauim",
  "nome": "Cauim",
  "cultura": "indigena",
  "tipo": "rito",
  "custo": 1,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [
      { "op": "heal", "alvo": "ally_cornucopia", "n": 2 },
      { "op": "draw", "n": 1 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1girl, solo, indigenous woman, natural brown skin, long black hair, black and red geometric body paint stripes, bead necklaces, kneeling beside a big decorated clay pot, holding a gourd bowl of frothy white drink toward viewer, smiling, night village festival, bonfire in background, thatched longhouse, sandy ground, firelight, green and orange, warm glow, sparks, full body, clean silhouette, readable shape, high contrast, dramatic lighting, deep shadows, rim lighting, moody atmosphere
```

## Prompt Krea 2
Atributos obrigatórios: mulher indígena adulta ajoelhada · top de algodão cobrindo o peito e saia vermelha · cuia de cauim espumoso nas duas mãos · pote de barro pintado · fogueira de festa
```krea
An adult Indigenous Brazilian woman about 35 years old with realistic adult proportions, natural brown skin and long black hair, kneeling beside a large painted clay pot at a village festival at night. She wears a woven cotton top that covers her chest and a long red-dyed cotton skirt, with bead necklaces and black and red geometric paint on her forearms. With both hands she offers a round gourd bowl full of frothy white cassava drink toward the viewer, smiling warmly. Behind her a large bonfire is the strong light, with a palm-thatched longhouse and sparks rising into the night sky.
```
