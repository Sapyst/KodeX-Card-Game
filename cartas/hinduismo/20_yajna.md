# Yajna, o Fogo Sacrificial

| Campo | Valor |
|---|---|
| Cultura | hinduísmo |
| Tipo | Rito |
| Custo | 2 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Cause 2 de dano a uma Entidade inimiga e ganhe 2 de Fé temporária.

## Contexto mitológico
O yajna é o sacrifício védico: o rito central da religião mais antiga da Índia, descrito e regulado nos quatro Vedas e nos Brahmanas. Sacerdotes acendem o fogo em altares de tijolo dispostos segundo a geometria dos Shulba Sutras, recitam hinos e vertem oblações — ghee (manteiga clarificada), grãos, leite, soma — nas chamas, enquanto Agni, o fogo, as leva aos deuses. O universo mesmo, diz o Rigveda (10.90, Purusha Sukta), nasceu de um sacrifício primordial; e os deuses dependem das oferendas dos homens tanto quanto os homens das chuvas dos deuses.

A Bhagavad Gita (3.9–16) reinterpreta o yajna: toda ação feita como oferenda, sem apego ao fruto, é sacrifício; e em 4.24–33 Krishna enumera os sacrifícios do saber, da respiração, da ascese, concluindo que "o sacrifício do conhecimento é superior ao de bens materiais". Em muitas histórias, o yajna é também arma: Dasharatha realiza um para ter filhos, Draupadi nasce do fogo de um yajna, e o yajna interrompido de Daksha custa a vida de Sati.

O Rito traz as duas faces: o fogo que fere e a energia que o sacrifício devolve a quem o oferece.

## Papel no jogo
Remoção barata que se paga sozinha: 2 de dano terminam um corpo ferido ou matam um 2 de Vida, e a Fé temporária volta inteira — na prática, um Rito gratuito que custa só a carta. Combina com o ping de Garuda e Arjuna para matar um 3 de Vida no mesmo turno. Fraco contra corpos grandes, onde 2 de dano é pouco.

## Balanço
Orçamento P = 2·2+1 = 5 pts. Gasto: 2 de dano a Entidade escolhida 2 + 2 de Fé temporária (2 × 1,5 = 3) = 5. Dentro.

## Dados
```json
{
  "id": "hin_yajna",
  "nome": "Yajna, o Fogo Sacrificial",
  "cultura": "hinduismo",
  "tipo": "rito",
  "custo": 2,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [
      { "op": "damage", "alvo": "enemy_entity", "n": 2 },
      { "op": "gain_fe", "n": 2, "perm": false } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, sacrificial fire, square brick fire altar, roaring flames rising high, brass ladle pouring ghee into the fire, offerings of grain and flowers, marigold garlands, brass vessels, oil lamps, fire bolt shooting forward, fire tongues, heat haze, flames lashing out, temple courtyard at night, carved stone pillars, smoke, embers, sparks, saffron and blue, gold ornaments, strong firelight, rim lighting, dramatic shadows, high contrast, centered composition
```

## Prompt Krea 2
Atributos obrigatórios: altar de fogo quadrado de tijolos · concha de latão vertendo ghee · oferendas de grãos e cravos · jato de fogo projetado à frente
```krea
A Vedic sacrificial fire on a square brick altar in a temple courtyard at night, with no people. A long brass ladle is tilted over the altar, pouring a stream of golden ghee into the flames. Offerings of rice grains, marigold garlands and brass vessels surround the altar. The flames roar high, and one bright bolt of fire shoots forward out of the altar toward the viewer like a thrown spear. Carved stone pillars stand in the dark around it, smoke and sparks rise upward. The firelight is the only light, strong and orange.
```
