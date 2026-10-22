# Imperador de Jade

| Campo | Valor |
|---|---|
| Cultura | taoismo |
| Tipo | Entidade |
| Custo | 7 Fé |
| ATK / Vida | 5 / 6 |
| Palavras-chave | Lendária |
| Lendária | sim |
| Cópias no deck | 1 |

## Texto da carta
Suas outras Entidades têm +1/+1.

## Contexto mitológico
O Imperador de Jade (玉皇大帝, Yuhuang Dadi; também Yudi, "Augusto de Jade") é o soberano do céu na religião chinesa: não o princípio mais alto — acima dele, imóveis, estão os Três Puros —, mas o administrador, aquele que governa deuses, homens e demônios por meio de uma burocracia celeste espelhada na imperial, com ministérios, censos e relatórios anuais (o Deus da Cozinha sobe no fim do ano para contar o que viu em cada casa). Sua escritura própria, o *Gaoshang Yuhuang benxing jijing*, narra como, príncipe de um reino de luz, renunciou ao trono, cultivou o Dao por milhões de kalpas e alcançou a soberania.

O culto é relativamente tardio: o imperador Song Zhenzong, para legitimar a dinastia, anunciou revelações do Imperador de Jade e lhe deu títulos oficiais em 1012 e 1017; Huizong ampliou-os em 1115. Daí em diante ele é onipresente na literatura: na *Jornada ao Oeste* convoca exércitos contra Sun Wukong e recorre a Buda; no *Fengshen Yanyi* preside à investidura final dos 365 deuses. Seu aniversário, no nono dia do primeiro mês lunar, abre o ano religioso.

Lendária de custo 7 e o "uau" do deck — mas sem dano. Ele não luta: faz a corte inteira valer mais. Uma aura de +1/+1 em todas as aliadas é o decreto imperial.

## Papel no jogo
Fechamento: cai no turno 7 numa mesa de Imortais e transforma cada 1/2 em 2/3 (3/3 com Lü Dongbin), virando qualquer troca. Corpo 5/6 que ainda se defende sozinho. O oponente tem de matá-lo ou silenciá-lo, e Guan Yu com Guarda impede que o alcance pelo combate. Fraco se cair em campo vazio — a aura não vale nada sem corte.

## Balanço
Orçamento P = 2·C+1 = 15 pts; Lendária até +2 = 17. Gasto: ATK 5 + Vida 6 + aura +1 ATK em todas (3) + aura +1 Vida em todas (3) = 17. Lendária +2.

## Dados
```json
{
  "id": "tao_imperador_de_jade",
  "nome": "Imperador de Jade",
  "cultura": "taoismo",
  "tipo": "entidade",
  "custo": 7,
  "atk": 5,
  "vida": 6,
  "lendaria": true,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "static", "acoes": [ { "op": "buff", "alvo": "other_ally_entities", "atk": 1, "vida": 1, "perm": true } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1boy, solo, celestial emperor, old man, seated on jade throne, mian crown, flat rectangular board on top of crown, beaded tassels hanging in front of face, visible eyes, calm stern face, long black beard, golden dragon robe, holding jade tablet with both hands, majestic, radiant aura spreading outward, celestial palace hall, golden pillars, clouds, incense smoke, jade green and vermilion, mist, ink wash feel, golden light, front view, full body
```

## Prompt Krea 2
Atributos obrigatórios: coroa mian com tábua plana e franjas de contas · túnica dourada de dragão · tábua de jade nas duas mãos · trono de jade · barba preta longa
```krea
An older Chinese emperor about 60 years old, calm stern face, long black beard, seated frontally on a jade throne. He wears a mian crown: a flat rectangular board on top of his head with strings of beads hanging in front of and behind it, his eyes visible between the beads. He wears a golden robe embroidered with dragons. He has two normal arms and two hands, and both hands hold a jade tablet upright in front of his chest. A radiant aura spreads outward behind him in a celestial palace hall with golden pillars, clouds and incense smoke, lit by golden light.
```
