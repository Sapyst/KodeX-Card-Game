# Sangue nos Umbrais

| Campo | Valor |
|---|---|
| Cultura | cristianismo |
| Tipo | Selo |
| Custo | 3 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Quando uma Entidade inimiga atacar, destrua-a. Cure 4 da sua Cornucópia.

## Contexto mitológico
Na noite da décima praga, cada família israelita marca os umbrais da porta com o sangue do cordeiro. "O Senhor passará para ferir o Egito; e, vendo o sangue na verga e nos dois umbrais, passará adiante daquela porta e não deixará o Destruidor entrar nas vossas casas para ferir" (Ex 12,23). À meia-noite morrem todos os primogênitos do Egito, "desde o primogênito do Faraó até o do cativo no cárcere" (Ex 12,29) — e a Páscoa (*pessach*, "passar por cima") nasce dessa noite. O rito é fixado ali mesmo: cordeiro sem defeito, sangue no umbral, pães sem fermento, ervas amargas, e a ordem de contar a história aos filhos (Ex 12,24-27).

O Destruidor (*mashḥit*) volta em outros textos: a peste depois do recenseamento de Davi, detida pela mão de Deus na eira de Araúna (2Sm 24,16); os 185 mil assírios de Senaquerib mortos numa noite diante de Jerusalém (2Rs 19,35; Is 37,36). Nunca é nomeado; é "o anjo do Senhor" na sua face de juiz, e a tradição cristã o funde com Miguel ou o deixa sem rosto — a figura encapuzada com a espada erguida das gravuras de Doré. Mas em Ex 12 o que o texto celebra não é o anjo: é a **marca**. A casa marcada é poupada; a casa que não tem a marca é ferida.

Por isso a carta é um **Selo**, e não uma Entidade: ela não é o anjo, é o sangue na porta. A casa está marcada em silêncio (carta virada para baixo), e quem avança contra ela encontra o juízo que passava ao largo dos protegidos. A cura da Cornucópia é a manhã seguinte: a casa amanhece de pé.

## Papel no jogo
A remoção mais dura do deck fora de Miguel, e a mais "justa": só atinge quem atacou. Coloque-o quando o oponente tiver uma Entidade grande pronta para atacar; ele perde a ameaça e você recupera 4 de Cornucópia. Entidades com Ímpeto que atacam no turno de entrada caem nele sem dar tempo de reação, e Entidades com **Furtivo** também — ao atacar, deixam de ser intocáveis, e `attacker` é um alvo legítimo. Atenção: o gatilho é `enemy_attacks`, que dispara só em ataques a **Entidades**; se o seu campo estiver vazio e o oponente bater direto na Cornucópia (`enemy_attacks_cornucopia`), o Selo não dispara. Mantenha ao menos um Anjo da Guarda em campo para "oferecer" o alvo. Fraco contra oponentes passivos que preferem equipar e esperar.

## Balanço
Orçamento P = 2·C+1 = 7 pts, +1 grátis de Selo = 8. Gasto: destruir Entidade inimiga (alvo `attacker`, contado como escolhido) 5 + curar 4 Cornucópia (2 × "curar 2 = 1") 2 = 7. Dentro (faixa 6–8). _(Rodada 1: reconta com `destroy` a 5 pts; antes 6. Sem mudança na carta.)_

## Dados
```json
{
  "id": "cri_sangue_nos_umbrais",
  "nome": "Sangue nos Umbrais",
  "cultura": "cristianismo",
  "tipo": "selo",
  "custo": 3,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "enemy_attacks", "acoes": [
      { "op": "destroy", "alvo": "attacker" },
      { "op": "heal", "alvo": "ally_cornucopia", "n": 4 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, scenery, wooden door of a humble mud brick house, dark red blood marks on the lintel above the door, red marks on both doorposts, hyssop branch on ground, night street of ancient egypt, narrow alley, palm tree silhouette, full moon, dark mist on ground, faceless shadow of destroying angel with sword passing in the distance, warm lamplight from inside the door, ominous, hidden trap, deep blue night and warm gold, rim lighting
```

## Prompt Krea 2
Atributos obrigatórios: porta de casa de adobe · marcas vermelhas no lintel e nos dois umbrais · ramo de hissopo na tigela · sombra sem rosto do Destruidor · lua cheia
```krea
The wooden door of a humble mud-brick house on a narrow street of ancient Egypt at midnight. Dark red marks of lamb's blood are painted with a brush across the lintel above the door and down both doorposts, and a bundle of green hyssop rests in a clay bowl at the threshold. Warm lamplight glows through the cracks around the closed door. Far down the street, the tall faceless shadow of the destroying angel, holding a long sword, glides past through low mist, its whole shape made of darkness. A full moon and palm tree silhouettes above. The marked door is the focus of the scene.
```
