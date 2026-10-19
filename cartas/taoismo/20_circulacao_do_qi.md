# Circulação do Qi

| Campo | Valor |
|---|---|
| Cultura | taoismo |
| Tipo | Rito |
| Custo | 1 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 2 |

## Texto da carta
Ganhe 1 Fé temporária. Compre 1 carta.

## Contexto mitológico
*Qi* (氣) é o sopro: o ar que se respira, o vapor que sobe do arroz (a etimologia do caractere), a energia que anima o corpo e o cosmo. O *Daodejing* pede para "concentrar o sopro e tornar-se macio como um recém-nascido" (cap. 10) e descreve as dez mil coisas "carregando o yin, abraçando o yang, harmonizadas pelo sopro do vazio" (cap. 42). O *Zhuangzi* (cap. 6) diz que "o homem verdadeiro respira pelos calcanhares; o homem comum, pela garganta". Daí nasce toda a ginástica taoista: *daoyin* (guiar e esticar), *tuna* (expirar o velho, inspirar o novo), a respiração embrionária (*taixi*) descrita por Ge Hong no *Baopuzi* (cap. 8), em que o adepto respira tão devagar que uma pluma diante do nariz não se move.

Na alquimia interna o qi circula pela "órbita microcósmica": sobe pela coluna (canal *du*), desce pela frente (canal *ren*), passando pelos três campos de cinábrio (*dantian*). Fazer o sopro circular é não perder nada: tudo o que entra volta a servir.

A carta é esse circuito em miniatura: a Fé gasta volta no mesmo turno, e a carta que se gasta é reposta. Nada se perde, nada se cria — circula.

## Papel no jogo
Cantrip neutro em Fé: custa 1, devolve 1, troca-se por outra carta. Serve para afinar a mão (achar Lü Dongbin ou a Pílula de Ouro), para ativar Han Xiangzi sem perder tempo e para esvaziar o deck com segurança — cuidado com o fim do deck (2 de dano por carta não comprada). Duas cópias porque o deck quer ver muitas cartas: os Imortais são singletons.

## Balanço
Orçamento P = 2·C+1 = 3 pts. Gasto: +1 Fé temporária (1,5) + comprar 1 (1,5) = 3. Dentro.

## Dados
```json
{
  "id": "tao_circulacao_do_qi",
  "nome": "Circulação do Qi",
  "cultura": "taoismo",
  "tipo": "rito",
  "custo": 1,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [
      { "op": "gain_fe", "n": 1, "perm": false },
      { "op": "draw", "n": 1 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1boy, solo, taoist monk, meditating, lotus position, eyes closed, calm, deep breathing, glowing energy circuit, luminous ring of light flowing around torso, swirling qi, glowing orb at belly, mountaintop, pine trees, sea of clouds, dawn, jade green and vermilion, mist, ink wash feel, soft teal glow, grey robe, topknot, incense, white hair, wisps of light, full body
```

## Prompt Krea 2
Atributos obrigatórios: monge em posição de lótus · círculo de luz percorrendo coluna e frente do tronco · orbe brilhando no ventre · túnica cinza · cabelos brancos em coque
```krea
An elderly Chinese Taoist monk about 70 years old, white hair in a topknot with a wooden pin, eyes closed, calm face. He wears a grey cotton Taoist robe that covers his body. He sits in lotus position with his hands resting together at his belly. He has two normal arms and two hands. A luminous ring of light circulates around his torso, rising up his spine and descending down his front, and a glowing orb shines at his lower belly as the focal point. He meditates on a mountaintop with pines above a sea of clouds at dawn, lit by a soft teal glow.
```
