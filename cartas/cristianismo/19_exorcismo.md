# Exorcismo

| Campo | Valor |
|---|---|
| Cultura | cristianismo |
| Tipo | Rito |
| Custo | 2 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Devolva uma Entidade inimiga para a mão do dono. Cure 4 de Vida de uma Entidade aliada.

## Contexto mitológico
Expulsar espíritos impuros é a ação mais frequente de Jesus nos evangelhos sinóticos: na sinagoga de Cafarnaum (Mc 1,21-28), o menino epiléptico que os discípulos não conseguem curar (Mc 9,14-29), a filha da sirofenícia (Mc 7,24-30). O caso mais vívido é o geraseno: um homem que vive entre os túmulos, que ninguém consegue acorrentar, e cujo espírito responde "Meu nome é Legião, porque somos muitos". Os espíritos pedem para entrar numa vara de dois mil porcos, que se precipita no lago (Mc 5,1-20). O homem é encontrado depois "sentado, vestido e em perfeito juízo".

A Igreja formalizou o rito: o *Rituale Romanum* de 1614 (título XI) fixa o exorcismo com estola roxa, água benta, o crucifixo e a fórmula *Exorcizo te, immundissime spiritus*. Os exorcistas eram uma das ordens menores até 1972. A iconografia medieval mostra o demônio saindo pela boca do possesso como uma figura negra e pequena.

A carta separa os dois movimentos do rito: o espírito é **expulso** (a Entidade inimiga volta para a mão — não morre, só sai), e o possesso é **restaurado** (uma aliada é curada).

## Papel no jogo
Remoção "mansa" e flexível: devolve à mão uma Entidade grande (o oponente perde a Fé gasta e, se for Sacrifício, o sacrifício), um token (que some), ou uma Entidade com Relíquia (a Relíquia vai ao cemitério). A cura de 4 recupera uma aliada depois de uma troca. Jogue em cima de Entidades de custo alto para máximo retorno de tempo; evite em cima de Entidades com Despertar forte, que vão reentrar e dispará-lo de novo.

## Balanço
Orçamento P = 2·C+1 = 5 pts. Gasto: devolver Entidade inimiga à mão 2 + curar 4 (2 × "curar 2 = 1") = 2 → 4. Dentro.

## Dados
```json
{
  "id": "cri_exorcismo",
  "nome": "Exorcismo",
  "cultura": "cristianismo",
  "tipo": "rito",
  "custo": 2,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [
      { "op": "bounce", "alvo": "enemy_entity" },
      { "op": "heal", "alvo": "ally_entity", "n": 4 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1boy, solo, human catholic priest, normal human face, short grey hair, black cassock, purple stole, holding golden cross raised forward, holy water bottle in other hand, stern face, commanding gesture, possessed man kneeling before him, small black horned demon fleeing from the man as dark smoke, swirling dark smoke, candlelit stone room, candles, overturned chair, bright holy light bursting from the cross, purple and gold, dramatic rim lighting, full body
```

## Prompt Krea 2
Atributos obrigatórios: batina preta · estola roxa · cruz dourada lisa erguida na mão direita · frasco de água benta na esquerda · demônio negro saindo como fumaça
```krea
An adult European Catholic priest about 50 years old, with short grey hair and a clean-shaven, ordinary human face, performing an exorcism. He wears a black cassock with a purple stole around his neck. His right arm thrusts a plain golden cross forward, glowing with white light, and his left hand holds a small glass vial of holy water. In front of him, a man in plain brown clothes kneels on the floor, and a small black horned shadow-demon is being driven out of him as a cloud of dark smoke, fleeing from the light. A candlelit stone room with an overturned wooden chair.
```
