# Cao Guojiu

| Campo | Valor |
|---|---|
| Cultura | taoismo |
| Tipo | Entidade |
| Custo | 3 Fé |
| ATK / Vida | 1 / 4 |
| Palavras-chave | Guarda, Despertar |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Guarda. Despertar: Cure 2 de Vida de uma Entidade aliada.

## Contexto mitológico
Cao Guojiu (曹國舅, "Tio Imperial Cao") é o aristocrata dos Oito Imortais — o único retratado com roupa de corte, chapéu oficial e um tablete de jade (*hu*) nas mãos. A lenda o faz irmão da imperatriz Cao, consorte do imperador Song Renzong (r. 1022–1063), ligando-o a uma família histórica, a do general Cao Bin. O irmão mais novo, protegido pelo parentesco, cometia crimes impunemente; Cao Guojiu, envergonhado, tentou corrigi-lo, fracassou, distribuiu sua fortuna e se retirou para as montanhas.

Ali Zhongli Quan e Lü Dongbin o encontram e perguntam o que ele cultiva. "O Dao." "Onde está o Dao?" Ele aponta para o céu. "E onde está o céu?" Ele aponta para o coração. Os dois riem e o aceitam. O tablete de jade, passaporte que abria qualquer porta da corte, vira nas mãos dele instrumento de purificação do ar; nas versões populares é trocado por castanholas, e ele se torna padroeiro dos atores. Fontes: *Dongyou Ji*; *Liexian quanzhuan*; *Song shi* para a família Cao.

A carta é o cortesão que se põe à frente: Guarda, corpo resistente, e ao chegar cuida de quem já estava lutando.

## Papel no jogo
Primeira linha de defesa barata: com Guarda e 4 de Vida, segura dois ataques de Entidades pequenas e obriga o oponente a gastar nela em vez de em Lü Dongbin ou He Xiangu. A cura de Despertar repara a troca do turno anterior. Fraco contra ataques grandes (1 ATK não troca com nada) e contra Furtivo, que ignora Guarda por não ser combate.

## Balanço
Orçamento P = 2·C+1 = 7 pts. Gasto: ATK 1 + Vida 4 + Guarda (1) + Despertar "cura 2 em aliada" (1) = 7. Dentro.

## Dados
```json
{
  "id": "tao_cao_guojiu",
  "nome": "Cao Guojiu",
  "cultura": "taoismo",
  "tipo": "entidade",
  "custo": 3,
  "atk": 1,
  "vida": 4,
  "lendaria": false,
  "keywords": ["guarda"],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [ { "op": "heal", "alvo": "ally_entity", "n": 2 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1boy, solo, court official, red official robe, black futou hat, black winged official hat, long horizontal hat wings, visible face, calm eyes, long black beard, holding pair of jade tablets, jade castanets raised before chest, defensive stance, feet planted, facing viewer, soft green protective glow, palace gate, red pillars, hanging lanterns, stone steps, jade green and vermilion, mist, ink wash feel, warm lantern light, full body
```

## Prompt Krea 2
Atributos obrigatórios: chapéu oficial preto de abas horizontais longas · túnica vermelha de corte · tábua de jade nas duas mãos · barba preta longa · postura de guarda frontal
```krea
An adult Chinese court official about 40 years old, calm eyes, long black beard. He wears a red official court robe with a jade belt and a black futou hat with two long thin horizontal wings sticking out to the left and right. He has two normal arms and two hands; both hands hold a pair of pale green jade tablets upright in front of his chest like a shield. Defensive stance, feet planted apart, facing the viewer directly. A soft green protective glow surrounds him. He stands before a palace gate with red pillars and stone steps, lit by warm hanging lanterns.
```
