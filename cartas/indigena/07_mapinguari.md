# Mapinguari

| Campo | Valor |
|---|---|
| Cultura | indígena brasileira |
| Tipo | Entidade |
| Custo | 5 Fé |
| ATK / Vida | 4 / 5 |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Sempre que um atacante a ferir, ele sofre 2 de dano.

## Contexto mitológico
O Mapinguari é o gigante da floresta amazônica (Acre, Amazonas, Pará, Rondônia): peludo, com um olho só no meio da testa, **a boca aberta no ventre** e um couro tão duro que flechas e balas não entram — só o umbigo é vulnerável. Solta um grito que ensurdece e um cheiro que derruba. Cascudo (*Dicionário do Folclore Brasileiro*) o registra como um dos poucos "monstros" propriamente ditos do folclore de origem indígena; em muitas versões é um antigo pajé que buscou a imortalidade e virou bicho.

Os seringueiros e os povos do Juruá e do Purus o descrevem com detalhe suficiente para que o zoólogo David Oren (*Goeldiana Zoologia*, 1993; *Edentata*, 2001) tenha proposto que a lenda guarde a memória da preguiça-gigante terrestre (*Mylodon*), extinta há milhares de anos — uma hipótese sem prova, mas que diz muito sobre como o Mapinguari é descrito: lento, enorme, imbatível de frente.

A carta traduz o couro impenetrável e o grito: quem o fere sofre.

## Papel no jogo
O corpo grande do meio do jogo. Sem Guarda, mas ninguém quer atacá-lo: um 3/3 que o ataca leva 4 + 2 = 6. O grito só responde a **ataques**: dano de Ritos ou habilidades não tem atacante, e a ação é pulada (regra de resolução da DSL). Com Muiraquitã fica 4/8 com Renascer — um muro que volta. Vulnerável a `bounce`, `silence` e a `destroy`, e a Ritos de dano, que o ferem sem disparar o grito.

## Balanço
Orçamento P = 2·5+1 = 11 pts. Gasto (tabela §10): ATK 4 + Vida 5 + `on_damaged` 2 de dano ao atacante (gatilho repetível: valor cheio, 2) = 11. Dentro. _(Revisão: conta confirmada.)_

## Dados
```json
{
  "id": "ind_mapinguari",
  "nome": "Mapinguari",
  "cultura": "indigena",
  "tipo": "entidade",
  "custo": 5,
  "atk": 4,
  "vida": 5,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_damaged", "acoes": [ { "op": "damage", "alvo": "attacker", "n": 2 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, giant shaggy sloth monster, matted brown fur, cyclops, one single huge eye in the middle of forehead, second mouth on belly, big toothy mouth on stomach, long curved claws, broken arrows stuck in fur, roaring, arms raised, dense amazon jungle, night, green and orange, glowing eye, firelight from below, rim lighting, fog, deep shadows, menacing, full body, clean silhouette, readable shape, high contrast, dramatic lighting, moody atmosphere
```

## Prompt Krea 2
Atributos obrigatórios: gigante peludo tipo preguiça-gigante · um único olho no meio da testa · boca enorme no ventre · garras longas · flechas quebradas no couro
```krea
Front view of a towering shaggy Amazon giant shaped like an upright ground sloth with matted reddish-brown fur, facing the viewer. His small head is a cyclops head: one single large round glowing yellow eye in the middle of the forehead, no second eye, no nose, no mouth on the face. In the middle of his belly the fur parts around a huge open vertical mouth with rows of sharp teeth and a red tongue, roaring; this belly mouth is the largest detail of the image. Two thick arms with long curved claws, two short heavy legs. Broken arrows stuck in his hide. Dense jungle at night, a campfire lighting his belly from below.
```
