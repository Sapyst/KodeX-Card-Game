# Abrahadabra

| Campo | Valor |
|---|---|
| Cultura | alta magia |
| Tipo | Rito |
| Custo | 3 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Cause 3 de dano à Cornucópia inimiga.

## Contexto mitológico
*Abrahadabra* é a Palavra do Aeon na Thelema. Abre o terceiro capítulo do *Liber AL vel Legis* (Cairo, abril de 1904): "Abrahadabra! a recompensa de Ra Hoor Khut" (AL III.1). Crowley a formou a partir do antigo *Abracadabra* dos amuletos (atestado em Sereno Samônico, séc. III) trocando o C pelo H — a letra de Hórus, o deus-criança do novo Aeon. A palavra tem **onze letras**, número da magia e da união do microcosmo (5) com o macrocosmo (6), e soma **418** na gematria hebraica — valor também de *Cheth* escrito por extenso (חית), da Casa de Boleskine na contagem de Crowley, e o título de *The Vision and the Voice* (Liber 418). Crowley o chama "o número da Grande Obra realizada".

Crowley a chama "a Palavra da Grande Obra realizada", a fórmula de Ra-Hoor-Khuit, o Hórus guerreiro da Estela da Revelação: "Eu sou o deus da Guerra e da Vingança" (AL III.3). Diferente das fórmulas de proteção e invocação do resto do grimório, é uma palavra de **culminação e golpe**: pronuncia-se quando a Obra está feita.

A carta é a palavra dita contra o inimigo: dano direto à Cornucópia, ignorando o campo — e a recompensa de Ra-Hoor-Khuit em forma de carta.

## Papel no jogo
Único dano direto do deck e seu finalizador: quando Babalon ou o Anjo seguraram o jogo e a Cornucópia inimiga está em 3 ou menos, Abrahadabra fecha sem precisar passar pelos bloqueadores. Antes disso é um Rito de 3 de dano que não mexe no tabuleiro — segure-o. Por 3 Fé cabe no mesmo turno de um Vassago ou de um Selo. Uma cópia, conforme a regra de que dano direto é raro e caro.

## Balanço
Orçamento P = 2·3+1 = 7 pts. Gasto: 3 de dano direto à Cornucópia (2 × 3 = 6) = 6. Dentro (P−1). Respeita o máximo de 3 de dano direto por carta.
Rodada 1 de balanceamento: era custo 4 com "compre 1" (7,5/9). O deck sofria fadiga em 34–54 % das partidas e tinha um único fecho: o fecho chega um turno antes e compra uma carta a menos.

## Dados
```json
{
  "id": "alt_abrahadabra",
  "nome": "Abrahadabra",
  "cultura": "alta_magia",
  "tipo": "rito",
  "custo": 3,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [
      { "op": "damage", "alvo": "enemy_cornucopia", "n": 3 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1boy, solo, magician, hooded red and black robe, one wand raised, shouting a word of power, mouth open, blast of golden fire from the wand tip, fire toward viewer, hawk silhouette inside the flames, candles knocked over, dark ritual chamber, stone pillars, heavy curtains, black and gold, red candlelight, golden flames, embers, sparks, dramatic shadows, upper body
```

## Prompt Krea 2
Atributos obrigatórios: mago adulto de manto vermelho e preto com capuz · varinha erguida na mão direita · boca aberta gritando a palavra de poder · jato de fogo dourado com silhueta de falcão (Hórus)
```krea
A pale English adult magician in his thirties with a shaved head and intense eyes, wearing a red and black hooded robe with the hood down. He has two normal arms. He raises a short wooden wand high in his right hand and shouts a word of power, mouth wide open, his left hand clenched into a fist. A blast of golden fire bursts from the wand's tip toward the viewer, and inside the flames the silhouette of a hawk with open wings takes shape. Candles are knocked over around him in a dark ritual chamber with stone pillars. The golden fire is the only strong light.
```
