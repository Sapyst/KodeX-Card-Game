# Han Xiangzi

| Campo | Valor |
|---|---|
| Cultura | taoismo |
| Tipo | Entidade |
| Custo | 2 Fé |
| ATK / Vida | 1 / 2 |
| Palavras-chave | Despertar |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Despertar: se você controla 2 ou mais Entidades, ganhe 2 Fé temporária.

## Contexto mitológico
Han Xiangzi (韓湘子) é o músico dos Oito Imortais, sempre com uma flauta transversal (*dizi*) nas mãos. A tradição o faz sobrinho-neto de Han Yu (768–824), o grande prosador confuciano dos Tang, que desprezava o taoismo. A lenda inverte o jogo: o jovem Han Xiang, discípulo de Lü Dongbin, faz peônias florescerem no meio do inverno diante do tio, e nas pétalas aparece um dístico que o tio só entenderá anos depois, exilado, na passagem nevada de Lan — episódio que ecoa um poema real de Han Yu ao sobrinho.

As fontes são o *Qingsuo gaoyi* (Song), o *Dongyou Ji* e peças de teatro Yuan sobre a conversão de Han Yu. Em algumas versões Han Xiangzi cai do pessegueiro da imortalidade ao colhê-lo e se torna imortal na queda. É padroeiro dos músicos.

Como carta, ele toca para os companheiros: a flauta levanta o *qi* (Fé temporária) quando há plateia — isto é, quando já existem outras Entidades em campo.

## Papel no jogo
Acelerador: com outra Entidade em campo, custa 2 e devolve 2, saindo "de graça" e deixando um corpo. Permite, no turno 3, jogar Han Xiangzi + outro Imortal de custo 3, ou no turno 4 Han Xiangzi + Nezha. Sinergia direta com Lan Caihe (que também pede companhia) e com a Circulação do Qi. Sem companhia é só um 1/2 por 2.

## Balanço
Orçamento P = 2·C+1 = 5 pts. Gasto: ATK 1 + Vida 2 + Despertar condicional "+2 Fé temporária" (3 × 0,7 = 2,1) = 5,1. Dentro (arredondamento de condicional).

## Dados
```json
{
  "id": "tao_han_xiangzi",
  "nome": "Han Xiangzi",
  "cultura": "taoismo",
  "tipo": "entidade",
  "custo": 2,
  "atk": 1,
  "vida": 2,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "cond": { "tipo": "ally_count_min", "n": 2 }, "acoes": [ { "op": "gain_fe", "n": 2, "perm": false } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1boy, solo, young man, scholar, blue hanfu, white outer robe, plain robe without patterns, black hair, topknot, playing transverse bamboo flute, flute held horizontally at lips, both hands on flute, eyes closed, calm face, glowing wisps from flute, red peony in snow, snowy mountain pass, pine trees, falling snow, stone path, jade green and vermilion, mist, ink wash feel, cool blue shadows, soft golden glow, full body
```

## Prompt Krea 2
Atributos obrigatórios: flauta transversal dizi de bambu nos lábios · túnica azul de letrado · peônia vermelha na neve · coque
```krea
A young adult Chinese man about 20 years old, scholar look, calm face with eyes closed, black hair in a neat topknot. He wears a plain blue scholar hanfu under a white outer robe. He plays a horizontal bamboo transverse flute held to his lips with both hands, the flute pointing to his right. He has two normal arms and two hands. Glowing wisps of music drift from the flute. At his feet a single red peony blooms out of the snow. He stands on a snowy mountain pass with pines and falling snow, lit by one soft golden glow from the flute.
```
