# Conjuração dos Elementais

| Campo | Valor |
|---|---|
| Cultura | alta magia |
| Tipo | Rito |
| Custo | 2 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 2 |

## Texto da carta
Invoque dois Elementais 1/1 (se houver slots livres).

## Contexto mitológico
Paracelso descreveu, no *Liber de nymphis, sylphis, pygmaeis et salamandris* (publicado em 1566, vinte e cinco anos após sua morte), os quatro povos elementais: **gnomos** (pigmeus) na terra, que atravessam a rocha como nós o ar; **ondinas** (ninfas) na água; **silfos** no ar; **salamandras** no fogo. Não são demônios nem anjos — são criaturas de Deus, com corpo e sem alma, que vivem no seu elemento e às vezes aparecem aos homens.

A magia cerimonial dos séculos XIX e XX os organizou nos quatro quadrantes: a Golden Dawn consagra as quatro Armas Elementais e abre as Tábuas de Vigia enochianas de cada elemento; Lévi, no *Ritual* cap. IV, dá as conjurações dos quatro ("Conjuração do Fogo", "da Água", "do Ar", "da Terra") e os sinais de domínio de cada um. O mago que os conjura ganha servos — muitos e pequenos.

A carta é a conjuração dos quatro feita na pressa: três corpos frágeis que servem, bloqueiam e, sobretudo, podem ser oferecidos aos espíritos maiores.

## Papel no jogo
Gera fodder de Sacrifício em massa e bloqueadores de emergência (duas cópias: é o Rito de **invocação** do deck, metade da identidade): dois 1/1 no turno 2 alimentam Astaroth e Dantalion nos turnos seguintes, ou absorvem dois ataques. Com Babalon em campo, cada Elemental que morre a engorda. Cuidado com os slots — o campo tem 4; não jogue com três Entidades já em mesa.

## Balanço
Orçamento P = 2·2+1 = 5 pts. Gasto: dois tokens 1/1 (1+1 = 2 cada) = 4. Dentro (P−1).
Rodada 1 de balanceamento: era custo 3 com três Elementais (6/7; 54 % na mão). O fodder do pacto precisa existir no turno 2–3, não no 3–4.

## Dados
```json
{
  "id": "alt_conjuracao_elementais",
  "nome": "Conjuração dos Elementais",
  "cultura": "alta_magia",
  "tipo": "rito",
  "custo": 2,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [ { "op": "summon", "atk": 1, "vida": 1, "nome": "Elemental", "n": 2 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1boy, solo, magician, hooded dark robe with golden trim, human face, arms raised, ritual dagger in the right hand, standing inside a chalk circle, two small elemental spirits at his sides, small fire spirit on the left, small wind spirit on the right, spirits emerging from swirling smoke, ritual chamber, candles, incense burner, heavy curtains, stone floor, black and gold, red candlelight, glowing sigils, embers, dramatic shadows, full body
```

## Prompt Krea 2
Atributos obrigatórios: mago inglês adulto de manto escuro com capuz e barra dourada · braços erguidos, adaga ritual na mão direita · dentro de um círculo de giz · dois elementais pequenos: um de fogo à esquerda, um de vento à direita
```krea
A pale English adult magician in his forties with a short dark beard stands inside a chalk circle on a stone floor, wearing a dark hooded robe with a golden border, hood down. He has two normal arms and raises both of them high; in his right hand he holds a short black-handled ritual dagger. At his left side a small fire elemental, a flickering figure of living flame the size of a cat, rises from swirling smoke. At his right side a small wind elemental, a pale swirl of air with a faint face, rises from the smoke too. Candles and an incense burner around the circle; the fire elemental gives the brightest light.
```
