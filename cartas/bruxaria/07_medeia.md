# Medeia, a Envenenadora

| Campo | Valor |
|---|---|
| Cultura | bruxaria |
| Tipo | Entidade |
| Custo | 4 Fé |
| ATK / Vida | 3 / 4 |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Despertar: uma Entidade inimiga à escolha perde 2 ATK permanentemente.

## Contexto mitológico
Medeia, princesa da Cólquida, é neta de Hélio, sobrinha de Circe e sacerdotisa de Hécate. Em Apolônio de Rodes (*Argonáuticas* III) ela se apaixona por Jasão e lhe dá o unguento de Prometeu, que o torna invulnerável ao fogo dos touros de bronze; no livro IV é ela quem adormece com cantos e drogas o dragão guardião do Velo de Ouro e quem arma a emboscada em que Jasão mata seu irmão Apsirto. Em Apolodoro (*Biblioteca* I.9.24) e Ovídio (*Tristia* III.9) a versão é mais crua: Medeia mesma esquarteja o irmão e espalha os pedaços para atrasar a perseguição do pai. É a feiticeira que trai a casa pelo estrangeiro — e será traída por ele.

Ovídio (*Metamorfoses* VII) dá o auge de seu poder: para rejuvenescer Éson, pai de Jasão, Medeia ferve num caldeirão de bronze raízes colhidas sob a lua, pedras do Oriente, areia do Oceano, geada, asas de coruja, entranhas de lobo, pele de cobra, fígado de cervo e cabeça de corvo de nove gerações; corta a garganta do velho, drena-lhe o sangue e o enche com a poção, e ele acorda jovem. Depois convence as filhas de Pélias a fazerem o mesmo com o pai — e deixa o caldeirão sem o remédio. Em Eurípides (*Medeia*, 431 a.C.), abandonada por Jasão em Corinto, ela manda à nova noiva Glauce um vestido e um diadema untados de veneno que a queimam viva junto com o rei Creonte, mata os próprios filhos e foge no carro de serpentes de Hélio.

Na carta Medeia é a envenenadora: o inimigo que ela toca não morre de imediato, mas perde a força do braço — como o vestido que consome Glauce ou o unguento que Jasão não devia ter recebido.

## Papel no jogo
Corpo sólido de 3/4 com um debuff permanente que transforma um atacante médio (3 ATK) em um corpo inofensivo, ou tira o perigo de um grande. Diferente de Circe, deixa a Vida intacta: boa contra Entidades de ATK alto e Vida baixa. Combina com Benandante (congela, depois enfraquece) e com o Boneco de Cera (um atacante fraco ainda devolve dano). Fraca contra campos de muitos tokens e Entidades que valem pelo efeito.

## Balanço
Orçamento P = 2·4+1 = 9 pts. Gasto: ATK 3 + Vida 4 + Despertar: −2 ATK permanente a inimigo escolhido (2 pts) = 9. Dentro.

## Dados
```json
{
  "id": "bru_medeia",
  "nome": "Medeia, a Envenenadora",
  "cultura": "bruxaria",
  "tipo": "entidade",
  "custo": 4,
  "atk": 3,
  "vida": 4,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [ { "op": "buff", "alvo": "enemy_entity", "atk": -2, "vida": 0, "perm": true } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1girl, solo, adult woman, tall sorceress, realistic proportions, long black hair, gold diadem, dark green robe, gold bracelets, cold stare, outstretched hand holding a small glass vial, green poison dripping from the vial, bundle of dark herbs in other hand, huge serpent dragon coiled asleep behind her, golden fleece hanging on an oak branch, night grove, fog, purple and green, green poison glow, moonlight, rim lighting, menacing, full body
```

## Prompt Krea 2
Atributos obrigatórios: mulher da Cólquida (georgiana) alta · túnica verde-escura e diadema de ouro · frasco de veneno verde na mão direita · ervas escuras na mão esquerda · dragão-serpente adormecido
```krea
Medea, a tall adult woman from ancient Colchis in the Caucasus, about 30 years old, with fair olive skin, dark eyes, long black hair and a cold stare, stands in a dark sacred oak grove. She wears a long dark green robe that covers her chest and arms and a gold diadem. Her right arm is stretched toward the viewer and her right hand holds a small glass vial dripping glowing green poison. Her left hand holds a bundle of dark herbs. Behind her, small in the dark, a huge serpent dragon lies coiled and asleep, and a golden fleece hangs on an oak branch. The green poison glow is the strong light source, lighting her face from below.
```
