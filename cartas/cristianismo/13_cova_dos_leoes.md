# Cova dos Leões

| Campo | Valor |
|---|---|
| Cultura | cristianismo |
| Tipo | Selo |
| Custo | 1 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Quando uma Entidade aliada sofrer dano, cure 4 dela e ela ganha +1/+1 permanente.

## Contexto mitológico
Daniel, judeu exilado na Babilônia, chega a chefe dos sátrapas sob Dario, o Medo. Os rivais, não achando falha nele, armam um decreto: durante trinta dias ninguém pode fazer súplica a deus ou homem senão ao rei. Daniel continua orando três vezes ao dia, de janela aberta voltada para Jerusalém, e é lançado na cova dos leões; o rei, contrariado, sela a pedra com seu anel (Dn 6,1-18).

Ao amanhecer, Dario corre à cova e Daniel responde de dentro: "Meu Deus enviou o seu anjo e fechou a boca dos leões, e eles não me fizeram mal" (Dn 6,23). Daniel sai sem um arranhão — e os acusadores são lançados no lugar dele. É a cena mais pintada do livro (Rubens, Briton Rivière), e nas catacumbas romanas Daniel entre leões é, como Jonas, um símbolo de salvação da morte.

Como **Selo**, é a armadilha que vira o jogo do inimigo: ele fere uma aliada e descobre que ela sai da cova curada e fortalecida — Daniel "prosperou no reinado de Dario".

## Papel no jogo
O Selo mais barato do deck, colocável no turno 1. Dispara no primeiro dano que uma aliada sofrer no turno do oponente — normalmente num ataque — e devolve a Vida perdida com juros. Com Anjo da Guarda (que absorve o primeiro ataque) é quase garantido; com Lázaro ou Serafim cria um corpo permanentemente maior. Não salva uma Entidade que morre do dano (o alvo já se foi): o oponente pode ignorá-lo matando de uma vez.

## Balanço
Orçamento P = 2·C+1 = 3 pts, +1 grátis de Selo = 4. Gasto: curar 4 (2 × "curar 2 = 1") 2 + +1 ATK permanente 1 + +1 Vida permanente 1 = 4. Dentro. Alvo `defender` (a aliada ferida em `ally_damaged`, conforme a DSL); se o dano vier de um Rito de área e a aliada morrer, as ações são puladas.

## Dados
```json
{
  "id": "cri_cova_dos_leoes",
  "nome": "Cova dos Leões",
  "cultura": "cristianismo",
  "tipo": "selo",
  "custo": 1,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "ally_damaged", "acoes": [
      { "op": "heal", "alvo": "defender", "n": 4 },
      { "op": "buff", "alvo": "defender", "atk": 1, "vida": 1, "perm": true } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1boy, solo, bearded man in simple robe, kneeling, praying with hands clasped, eyes closed, calm, three large lions lying around him, maned lion, lioness, lions resting peacefully, lions with closed mouths, dark stone pit, lion's den, round opening in ceiling, single ray of holy light falling on him, dusty air, dark and gloomy, gold and white, warm golden light against deep shadow, rim lighting, full body, wide shot
```

## Prompt Krea 2
Atributos obrigatórios: ajoelhado em oração · olhos fechados e mãos juntas · três leões deitados de boca fechada · cova de pedra selada · único feixe de luz
```krea
A Middle Eastern Hebrew man about 50 years old, the prophet Daniel, with a short grey-streaked beard, kneeling in prayer at the center of a dark stone pit. He wears a long dark blue Babylonian-style robe with a woven sash and a simple head cloth. His hands are clasped at his chest and his eyes are closed in calm trust. Around him three large lions lie resting peacefully with their mouths firmly closed, one with its head lowered beside his knee. The pit is sealed above by a heavy stone with a single narrow gap, through which one beam of golden light falls on Daniel. Dust floats in the light.
```
