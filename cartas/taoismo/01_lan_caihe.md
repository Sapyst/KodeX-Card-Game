# Lan Caihe

| Campo | Valor |
|---|---|
| Cultura | taoismo |
| Tipo | Entidade |
| Custo | 1 Fé |
| ATK / Vida | 1 / 1 |
| Palavras-chave | Despertar |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Despertar: se você controla 2 ou mais Entidades, compre 1 carta.

## Contexto mitológico
Lan Caihe (藍采和) é o mais estranho dos Oito Imortais: um andarilho de idade e sexo incertos, que canta pelas ruas batendo o pé, com um pé calçado e o outro nu, vestindo trapos no verão e deitando-se na neve no inverno sem sentir frio. Carrega uma cesta de flores e, nas versões tardias, castanholas de madeira. Quando lhe dão moedas, ele as enfia num cordão e deixa que caiam pelo caminho.

A biografia mais antiga está no *Xu xianzhuan* (Biografias Continuadas dos Imortais, Shen Fen, séc. X): Lan Caihe bebe numa taverna, ouve uma flauta, sobe num grou e some no céu, deixando para trás sapato, roupa e castanholas. O *Dongyou Ji* (Jornada ao Leste, Ming) o integra ao grupo dos Oito, e ele se torna padroeiro de floristas e jardineiros.

Virou a Entidade de custo 1 do deck porque é o Imortal "da rua", o que chega primeiro e sem peso. Sua canção reúne gente em volta: por isso ele compra uma carta quando já há companhia em campo.

## Papel no jogo
Abertura ideal no turno 1 e cantrip nos turnos seguintes, quando já há outro Imortal em campo. Corpo de 1/1 que ganha valor real com a aura de Lü Dongbin e do Imperador de Jade e que pode voltar com Zhongli Quan ou a Pílula de Ouro. Ruim contra dano em área; serve de alvo barato para a Tartaruga Negra e o Pêssego da Imortalidade.

## Balanço
Orçamento P = 2·C+1 = 3 pts. Gasto: ATK 1 + Vida 1 + Despertar condicional "compre 1" (1,5 × 0,7 = 1,05) = 3,05. Dentro (aviso esperado do validador: corpo de 2 pts em P = 3).

## Dados
```json
{
  "id": "tao_lan_caihe",
  "nome": "Lan Caihe",
  "cultura": "taoismo",
  "tipo": "entidade",
  "custo": 1,
  "atk": 1,
  "vida": 1,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "cond": { "tipo": "ally_count_min", "n": 2 }, "acoes": [ { "op": "draw", "n": 1 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1other, solo, androgynous youth, ragged blue robe, tattered chinese clothes, one bare foot, one shoe, messy hair, carrying flower basket, basket overflowing with flowers, wooden clappers, singing, open mouth, stomping foot, dancing, lively pose, misty mountain path, pine trees, distant pagoda, paper lantern glow, falling petals, jade green and vermilion, mist, ink wash feel, soft rim lighting, full body
```

## Prompt Krea 2
Atributos obrigatórios: um pé calçado e um pé descalço · cesta de flores · castanholas de madeira · túnica azul esfarrapada · jovem andrógino cantando
```krea
A slender androgynous Chinese youth about 17 years old, adult proportions, messy black hair tied loosely, mouth open singing, mid-stride with the left leg forward. The left foot is barefoot: bare skin, five naked toes, dusty sole, nothing on it. The right foot wears a tall closed black cloth boot that covers the whole foot. Mismatched feet: one barefoot, one booted. Two normal arms and two hands. A ragged, patched pale blue robe with a black sash covers the chest, hem above the ankles. The left arm holds a bamboo basket of flowers; the right hand raises wooden clappers. Full body, feet large in the foreground on a misty mountain path, lit by a paper lantern. (negativo: sandals, two shoes, matching footwear; se falhar, inpaint do pé esquerdo)
```
