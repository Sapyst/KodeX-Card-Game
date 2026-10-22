# Circe

| Campo | Valor |
|---|---|
| Cultura | bruxaria |
| Tipo | Entidade |
| Custo | 4 Fé |
| ATK / Vida | 3 / 3 |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Despertar: Uma Entidade inimiga passa a ser 1/1.

## Contexto mitológico
Circe (*Kirke*), filha de Hélio e da oceânide Perse, vive na ilha de Eeia entre lobos e leões que já foram homens. Em *Odisseia* X, os companheiros de Odisseu bebem de sua taça de queijo, farinha, mel e "drogas funestas" (*pharmaka lygra*), ela os toca com a varinha e eles ganham cabeça, voz e cerdas de porco — mas conservam a mente humana. Odisseu resiste graças à erva *moly* dada por Hermes, obriga-a a desfazer o encanto e fica um ano em sua cama; é ela quem lhe ensina o caminho ao Hades e o modo de passar pelas Sereias e por Cila.

Homero chama-a *polypharmakos*, "de muitas drogas", e *deinē theos audēessa*, "deusa terrível de voz humana": é uma deusa, não uma mortal, e a primeira feiticeira da literatura ocidental. Ovídio amplia o repertório (*Metamorfoses* XIV): transforma o rei Pico em pica-pau por rejeitá-la e envenena a fonte onde Cila se banha. Apolônio de Rodes (*Argonáuticas* IV) faz dela a tia que purifica Medeia e Jasão do sangue de Apsirto — a feiticeira mais velha recebendo a mais nova.

Na carta Circe faz o que sempre fez: não mata o herói inimigo, torna-o um porco. A Entidade continua lá, ocupando o slot, com toda a sua glória reduzida a 1/1.

## Papel no jogo
Resposta ao "grandão" adversário sem gastar um `destroy`: a Entidade grande fica 1/1, ainda ocupando um slot do oponente (o que atrapalha o campo dele) e virando presa fácil para qualquer familiar. Sinergia com Mau-Olhado (−1/−1 depois do porco = morte) e com o Sapo. Como 3/3 de custo 4 ela é frágil para o custo; usar o Despertar bem é tudo. Perde valor contra campos de muitos tokens.

## Balanço
Orçamento P = 2·4+1 = 9 pts. Gasto: ATK 3 + Vida 3 + Despertar: `set_stats` inimigo → 1/1 (3 pts, convenção do deck) = 9. Dentro.

## Dados
```json
{
  "id": "bru_circe",
  "nome": "Circe",
  "cultura": "bruxaria",
  "tipo": "entidade",
  "custo": 4,
  "atk": 3,
  "vida": 3,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [ { "op": "set_stats", "alvo": "enemy_entity", "atk": 1, "vida": 1 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1girl, solo, sorceress goddess, adult woman, long auburn hair, golden circlet, long purple greek chiton covering her legs, gold jewelry, cruel smile, golden goblet held up in one hand, slender wand pointing down in the other hand, small pink pig at her feet looking up in fear, wolf and lion lying behind her, marble columns, night sea behind, glowing wand tip, purple and green, moonlight, candlelight, rim lighting, elegant, full body
```

## Prompt Krea 2
Atributos obrigatórios: deusa grega adulta de cabelo ruivo · quíton roxo longo e diadema de ouro · taça dourada erguida na mão direita · varinha fina na mão esquerda · porquinho rosa aos pés
```krea
Circe, a tall adult Greek goddess about 30 years old, with olive skin, long auburn hair and a cruel calm smile, stands on a marble terrace of her island palace. She wears a long purple Greek chiton that covers her chest and falls to her feet, a golden circlet and gold armbands. She has two normal arms. In her raised right hand she holds a golden goblet with a glowing drink; in her left hand a slender wooden wand points down, its tip glowing. A small pink pig sits at her feet looking up at her in fear. Marble columns and a dark night sea are behind her. The glowing wand tip and the moon are the light sources.
```
