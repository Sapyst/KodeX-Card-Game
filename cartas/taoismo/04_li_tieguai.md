# Li Tieguai

| Campo | Valor |
|---|---|
| Cultura | taoismo |
| Tipo | Entidade |
| Custo | 2 Fé |
| ATK / Vida | 1 / 2 |
| Palavras-chave | Renascer |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Renascer.

## Contexto mitológico
Li Tieguai (李鐵拐, "Li da Muleta de Ferro") é o Imortal mendigo: coxo, sujo, apoiado numa muleta de ferro, com uma cabaça de remédios pendurada da qual sai fumaça — às vezes com sua própria alma desenhada nela. Sua história é a mais clara parábola de renascimento do grupo. Li era um asceta belo e sério que dominou a arte de deixar o corpo em espírito. Um dia partiu para visitar Laozi no Monte Hua e mandou o discípulo vigiar o corpo por sete dias, com ordem de cremá-lo se não voltasse. No sexto dia o discípulo soube que a mãe estava morrendo, cremou o corpo e partiu. Quando a alma de Li voltou, só encontrou cinzas — e o cadáver de um mendigo coxo que acabara de morrer de fome ali perto. Entrou nele.

A fonte canônica é o *Dongyou Ji* (Ming) e o *Liexian quanzhuan*; a tradição popular o liga a Li Xuan ou Li Ningyang. A ideia de fundo é a das almas *hun* e *po* (Liji, Zuo zhuan): a vida é a união das duas; a morte, a separação; o imortal é quem controla a saída e a volta. Li Tieguai é padroeiro dos farmacêuticos e dos doentes.

A mecânica foi imediata: Renascer. Ele morre e volta à mão — noutro corpo, mas o mesmo Imortal.

## Papel no jogo
Corpo barato que o oponente não quer matar: ao morrer volta à mão e repete Despertares alheios (nenhum próprio, mas ocupa de novo o slot e conta de novo para `ally_count_min`). Escudo ideal para absorver o primeiro ataque enquanto Lü Dongbin e He Xiangu ficam atrás. Perde força contra silêncio, que remove o Renascer.

## Balanço
Orçamento P = 2·C+1 = 5 pts. Gasto: ATK 1 + Vida 2 + Renascer (2) = 5. Dentro.

## Dados
```json
{
  "id": "tao_li_tieguai",
  "nome": "Li Tieguai",
  "cultura": "taoismo",
  "tipo": "entidade",
  "custo": 2,
  "atk": 1,
  "vida": 2,
  "lendaria": false,
  "keywords": ["renascer"],
  "sacrificio": 0,
  "efeitos": [],
  "usos": null
}
```

## Prompt de arte
```prompt
1boy, solo, old beggar, lame leg, iron crutch, leaning on crutch, ragged robe, unkempt beard, wild hair, gold headband, bare chest, barefoot, double gourd on belt, smoke rising from gourd, tiny glowing spirit figure in the smoke, grinning, dirty, mountain cave entrance, dark rocks, twisted pine, night, jade green and vermilion, mist, ink wash feel, glowing ember light, green smoke glow, full body
```

## Prompt Krea 2
Atributos obrigatórios: perna esquerda aleijada e dobrada · muleta de ferro · cabaça dupla fumegante · mendigo velho de barba desgrenhada · faixa dourada na cabeça
```krea
An elderly Chinese beggar man about 60 years old, unkempt grey beard and wild hair held by a thin gold headband, grinning. He is lame: his left leg is withered and bent at the knee, his left foot hangs above the ground and does not touch it. He stands on his right leg alone and leans his full weight on a black iron crutch under his left arm. He has two normal arms and two hands. He wears a torn brown hemp robe. A double gourd hangs at his belt, green smoke rising from it with a tiny glowing spirit figure in the smoke. Mountain cave entrance at night, lit by the green ember glow of the gourd.
```
