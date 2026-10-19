# Erlang Shen

| Campo | Valor |
|---|---|
| Cultura | taoismo |
| Tipo | Entidade |
| Custo | 5 Fé |
| ATK / Vida | 3 / 5 |
| Palavras-chave | Despertar |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Despertar: invoque Xiaotian Quan, o Cão Celestial (2/1), se houver slot livre.

## Contexto mitológico
Erlang Shen (二郎神, "o Deus Segundo Filho") é o guerreiro de três olhos do panteão popular: o terceiro olho, vertical no meio da testa, enxerga a verdade por baixo de qualquer transformação. Empunha uma lança de três pontas e dois gumes e anda com o Cão Celestial Uivante (Xiaotian Quan). Sua identidade é múltipla: em Sichuan é o filho de Li Bing, o engenheiro que domou o rio Min em Dujiangyan (séc. III a.C.), que matou um dragão de rio; no *Fengshen Yanyi* é Yang Jian, discípulo de Yuding Zhenren, mestre das 72 transformações; noutras versões é Zhao Yu, governador dos Sui.

Seu episódio mais famoso está na *Jornada ao Oeste* (cap. 6): quando o exército celeste não consegue prender Sun Wukong, o Imperador de Jade chama Erlang, seu sobrinho. Os dois duelam trocando formas — pardal, garça, peixe, serpente, templo com a cauda virada em mastro —, e é o cão de Erlang que morde a perna do Macaco e o derruba, permitindo a captura. O culto de Erlang em Guankou tem festas de sacrifício desde os Tang.

A carta é ele e o cão: um corpo grande que chega acompanhado.

## Papel no jogo
Dois corpos por uma carta no turno 5, o que para um deck de `ally_count_min` e auras é ouro: o cão 2/1 recebe o +1 ATK de Lü Dongbin e vira um 3/1 descartável. Erlang 3/5 segura trocas. Cuidado com o campo cheio (4 slots): se os Imortais já ocupam tudo, o cão não aparece — invocá-lo antes do quarto Imortal é a ordem certa.

## Balanço
Orçamento P = 2·C+1 = 11 pts. Gasto: ATK 3 + Vida 5 + Despertar "invocar token 2/1" (2 + 1 = 3) = 11. Dentro.

## Dados
```json
{
  "id": "tao_erlang_shen",
  "nome": "Erlang Shen",
  "cultura": "taoismo",
  "tipo": "entidade",
  "custo": 5,
  "atk": 3,
  "vida": 5,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [ { "op": "summon", "atk": 2, "vida": 1, "nome": "Xiaotian Quan, Cão Celestial", "n": 1 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1boy, solo, warrior god, black hair, three eyes, vertical third eye on forehead, glowing third eye, handsome face, golden chinese armor, red cape, holding three-pointed double-edged lance, black hunting dog beside him, dog sitting at his feet, confident stance, mountain gate, stone steps, pine trees, full moon, clouds, jade green and vermilion, mist, ink wash feel, cool moonlight, full body
```

## Prompt Krea 2
Atributos obrigatórios: terceiro olho vertical na testa · lança de três pontas · armadura dourada · capa vermelha · cão de caça preto aos pés
```krea
A tall adult Chinese warrior god about 30 years old, handsome face, black hair in a topknot. He has three eyes: two normal eyes and a third eye placed vertically in the center of his forehead, open and glowing. He wears golden Chinese lamellar armor and a red cape. He has two normal arms and two hands; his right hand holds a long three-pointed double-edged lance upright. One black hunting dog sits beside his left leg. Confident stance at a mountain gate with stone steps and pines, lit by a cold full moon.
```
