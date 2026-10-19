# Zhongli Quan

| Campo | Valor |
|---|---|
| Cultura | taoismo |
| Tipo | Entidade |
| Custo | 3 Fé |
| ATK / Vida | 2 / 3 |
| Palavras-chave | Despertar |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Despertar: devolva uma Entidade do seu cemitério para a sua mão.

## Contexto mitológico
Zhongli Quan (鍾離權), também Han Zhongli, é o decano dos Oito Imortais: um homem gordo de barriga à mostra, barba longa e cabelo preso em dois coques, abanando-se com um leque de folha de palmeira ou de plumas. A tradição o faz general da dinastia Han que, derrotado em campanha contra os tibetanos, fugiu para as montanhas e ali encontrou um velho mestre que lhe ensinou a alquimia. Seu leque ressuscita os mortos e transforma pedra em ouro e prata — ouro que ele distribuía aos pobres em anos de fome.

Zhongli Quan importa sobretudo como mestre de Lü Dongbin: a linhagem "Zhong-Lü" de alquimia interna (*Zhong-Lü chuandao ji*, Song) atribui a ele e ao discípulo o diálogo fundador do *neidan*, e a escola Quanzhen o conta entre seus Cinco Patriarcas do Norte. A hagiografia dos Oito está no *Dongyou Ji* (Ming); seu nome aparece já no *Xuanhe shupu* (Song) como calígrafo imortal.

A carta usa o leque: ao entrar, Zhongli traz de volta um morto — para a mão, não para o campo, porque o leque desperta mas não planta.

## Papel no jogo
O reciclador do deck: devolve à mão o Imortal que morreu cedo (Lan Caihe, Han Xiangzi) para repetir o Despertar, ou recupera Nezha depois do segundo óbito. Jogado no turno 3 depois de uma troca ruim, estabiliza; no fim do jogo devolve Xiwangmu. Quase inútil com o cemitério vazio — então é um 2/3 por 3, dentro da curva.

## Balanço
Orçamento P = 2·C+1 = 7 pts. Gasto: ATK 2 + Vida 3 + Despertar "revive para a mão" (2) = 7. Dentro.

## Dados
```json
{
  "id": "tao_zhongli_quan",
  "nome": "Zhongli Quan",
  "cultura": "taoismo",
  "tipo": "entidade",
  "custo": 3,
  "atk": 2,
  "vida": 3,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [ { "op": "revive", "alvo": "ally_graveyard_entity", "para": "hand" } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1boy, solo, fat old man, exposed belly, long beard, two hair buns, open robe, red robe, bare feet, holding palm leaf fan, waving fan, glowing wind from fan, swirling golden light, spirit rising from the ground, cheerful expression, laughing, mountain terrace, sea of clouds below, pine trees, cliff, jade green and vermilion, mist, ink wash feel, golden light, wind swirling, golden sparks, full body
```

## Prompt Krea 2
Atributos obrigatórios: homem gordo de barriga à mostra · leque de folha de palmeira · dois coques no cabelo · barba longa · túnica vermelha aberta
```krea
A fat, cheerful elderly Chinese man about 65 years old, laughing, with a very long black beard and his hair tied in exactly two round buns on top of his head. He wears an open red robe with a green sash; his large round belly is bare and visible, the robe covers his shoulders and arms. He is barefoot. His right hand waves a large round palm-leaf fan, golden wind swirling from it; below the fan a pale spirit rises from the ground. His left hand rests on his belly. He stands on a cliff terrace above a sea of clouds with pines, lit by one swirling golden light from the fan.
```
