# Vassago, o Príncipe que Acha

| Campo | Valor |
|---|---|
| Cultura | alta magia |
| Tipo | Entidade |
| Custo | 3 Fé |
| ATK / Vida | 2 / 3 |
| Palavras-chave | Despertar |
| Lendária | não |
| Cópias no deck | 2 |

## Texto da carta
Despertar: busque um Selo do seu deck.

## Contexto mitológico
Vassago é o terceiro espírito da *Ars Goetia* (Lemegeton, séc. XVII), um Príncipe "da mesma natureza de Agares", de boa índole. Seu ofício é declarar coisas passadas e futuras e **descobrir tudo o que está escondido ou perdido**; governa 26 legiões. É um dos poucos espíritos da lista que o próprio texto descreve como benigno ("of a good nature"), e por isso virou favorito dos magos que querem adivinhação sem risco. Detalhe de filologia: Vassago **não consta** na *Pseudomonarchia Daemonum* de Weyer (1577), fonte dos outros 68; é um dos quatro espíritos (com Seere, Dantalion e Andromalius) acrescentados pelo compilador do Lemegeton no século XVII — provavelmente de outra lista hoje perdida.

A Goetia não lhe dá forma fixa; a iconografia posterior o mostra como um ancião sereno ou como uma figura encapuzada segurando algo que acabou de encontrar. Como todo espírito do Lemegeton, ele vem quando o mago mostra o Pentáculo de Salomão e o chama pelo selo gravado em metal.

A carta pega o ofício ao pé da letra: ao chegar, Vassago acha o que está escondido no deck — um Selo, a carta virada para baixo. É a tutoria de armadilhas do deck de controle.

## Papel no jogo
Motor dos Selos: garante Pentagrama Flamejante contra decks de Ritos, Selo de Salomão contra decks de Entidades grandes ou Solve et Coagula quando há fodder para reciclar. Corpo 2/3 razoável no turno 3, que segura um atacante pequeno e depois vira Sacrifício. Duas cópias porque é a carta que faz o resto do deck funcionar.

## Balanço
Orçamento P = 2·3+1 = 7 pts. Gasto: ATK 2 + Vida 3 + Despertar buscar Selo (2) = 7. Dentro.

## Dados
```json
{
  "id": "alt_vassago",
  "nome": "Vassago, o Príncipe que Acha",
  "cultura": "alta_magia",
  "tipo": "entidade",
  "custo": 3,
  "atk": 2,
  "vida": 3,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [ { "op": "search", "tipo": "selo" } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1boy, solo, old hooded spirit, long white beard, serene wrinkled face, dark hooded robe with golden trim, pale glowing eyes, kneeling on one knee, both hands lifting a small round golden seal, seal held at chest height, seal glowing gold, looking down at the seal, light from the seal on his face, loose flagstone beside him, chalk circle on stone floor, candles, incense burner, heavy curtains, black and gold, red candlelight, dramatic shadows, full body
```

## Prompt Krea 2
Atributos obrigatórios: espírito em forma de ancião de pele pálida, barba branca longa · manto escuro com capuz e barra dourada · ajoelhado, erguendo um pequeno selo dourado redondo · olhos de brilho pálido, expressão serena
```krea
Vassago, a benign spirit in the form of a very old pale-skinned man with a long white beard and a calm, wrinkled face. His eyes glow softly pale gold. He wears a heavy dark hooded robe with an embroidered gold border, the hood up. He kneels on one knee on a stone floor beside a lifted loose flagstone, and with both hands he raises a small round golden seal disc to his chest, looking down at it as if he has just found it. He has two normal arms and two hands. The seal glows bright gold and lights his face from below. Around him, a faded chalk circle and a few candles in a dark chamber.
```
