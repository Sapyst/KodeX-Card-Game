# Mau-Olhado

| Campo | Valor |
|---|---|
| Cultura | bruxaria |
| Tipo | Selo |
| Custo | 1 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 2 |

## Texto da carta
Quando o oponente jogar uma Entidade, ela fica congelada e recebe -1/-1.

## Contexto mitológico
O mau-olhado (*fascinatio*, *malocchio*, *ayin ha-ra*) é a crença mediterrânea e oriental de que um olhar — em especial o olhar da inveja — pode ferir, secar o leite da vaca, murchar a criança, quebrar a sorte. Plutarco dedica-lhe um debate inteiro (*Quaestiones Convivales* V.7), tentando explicar como partículas saídas dos olhos atingem a vítima; Plínio (*História Natural* VII.16–18) fala de famílias africanas que matavam com o olhar e com o elogio. É um poder tão difundido que raramente é "bruxaria" formal: qualquer um pode ter o olho-gordo sem saber.

Os teólogos da caça às bruxas, porém, o absorveram: o *Malleus Maleficarum* (I, q.2) pergunta se as bruxas podem fascinar com os olhos e responde que o demônio age por meio delas; o olhar fixo da acusada no tribunal era prova. Contra o mau-olhado existe a maior família de amuletos do mundo: o olho azul turco, o *cornicello* napolitano, a mão de figa, a fita vermelha, a cuspida tripla, o alho atrás da porta — e os Selos do deck.

Aqui o Mau-Olhado é o mais barato dos malefícios armados: o oponente põe sua Entidade na mesa cheio de esperança e ela já chega torta, menor, incapaz de atacar na próxima volta.

## Papel no jogo
Selo de abertura por 1 Fé que pune a invocação seguinte: tokens 1/1 morrem na hora; uma 3/3 vira 2/2 congelada, e o freeze compra um turno inteiro contra Ímpeto. Duas cópias porque é o malefício que define o deck. Combina com Circe (porco 1/1 + Mau-Olhado = morto) e com Hécate (depois do −2/−2 em área, pouco sobra). O oponente pode "testar" com uma Entidade barata — aceitável: ele gastou o turno dele.

## Balanço
Orçamento P = 2·1+1 + 1 (Selo) = 4 pts. Gasto: freeze na Entidade invocada (1,5, tabela §10) + −1/−1 permanente (1+1 = 2) = 3,5. Dentro (0,5 de folga).

## Dados
```json
{
  "id": "bru_mau_olhado",
  "nome": "Mau-Olhado",
  "cultura": "bruxaria",
  "tipo": "selo",
  "custo": 1,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "enemy_plays_entity", "acoes": [
      { "op": "freeze", "alvo": "triggering" },
      { "op": "buff", "alvo": "triggering", "atk": -1, "vida": -1, "perm": true } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, no girl, giant floating eye in the night sky, single huge veined eyeball, purple iris, slit pupil, staring down, dark smoke and shadow tendrils around the eye, small white goat below covered in frost, ice crystals, frozen breath, withered grass, dark village street, cobblestones, garlic and red ribbon on a doorway, closed shutters, fog, purple and green, eerie glow, moonlight, rim lighting, ominous, dark atmosphere
```

## Prompt Krea 2
Atributos obrigatórios: olho gigante flutuando no céu · íris roxa e pupila em fenda · tentáculos de sombra · cabrita branca congelada · porta com alho e fita vermelha
```krea
A single gigantic veined eyeball floats in the night sky above a narrow village street, staring straight down. It has a glowing purple iris and a dark slit pupil, and tendrils of black smoke trail from its edges. Below it, on the cobblestones, a small white goat stands frozen stiff, its coat covered in frost and ice crystals, its breath a frozen cloud. Withered grass lines the street. On a closed wooden door nearby hang a braid of garlic and a red ribbon as protection. The houses have their shutters closed. The purple glow of the eye is the strong light source, casting a cold beam onto the goat.
```
