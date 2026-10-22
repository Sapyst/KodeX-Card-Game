# Caldeirão de Renascimento

| Campo | Valor |
|---|---|
| Cultura | bruxaria |
| Tipo | Relíquia |
| Custo | 3 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
A portadora ganha +1/+2. Quando ela morrer, devolva uma Entidade do seu cemitério para o campo.

## Contexto mitológico
O caldeirão é o objeto da bruxa por excelência — Cerridwen o ferve um ano e um dia pela inspiração (*Hanes Taliesin*), Medeia rejuvenesce Éson nele e mata Pélias por ele (Ovídio, *Metamorfoses* VII), as Três Irmãs de *Macbeth* (IV.1) jogam nele "olho de salamandra e dedo de rã" para ver o futuro. Mas o caldeirão deste nome específico vem do segundo ramo do *Mabinogion*, *Branwen ferch Llŷr*: o *Pair Dadeni*, "Caldeirão de Renascimento", trazido da Irlanda por um gigante que saía de um lago com a mulher, e dado por Bendigeidfran (Brân, o Abençoado) ao rei irlandês Matholwch como presente de casamento com sua irmã Branwen.

A propriedade do *Pair Dadeni* é precisa: o guerreiro morto que nele é mergulhado levanta no dia seguinte tão bom quanto antes — mas sem fala. Quando a guerra entre Gales e Irlanda estoura, os irlandeses enchem o caldeirão de mortos a cada noite, até que Efnisien, o meio-irmão de Brân que causou tudo, se deita entre os cadáveres, é jogado dentro vivo e se estica até rachar o caldeirão e o próprio coração. O caldeirão de Gundestrup (séc. I a.C.), com sua placa de um deus mergulhando guerreiros numa cuba, é frequentemente lido como a versão continental da mesma ideia.

Na carta o caldeirão é equipado numa bruxa ou familiar: enquanto ela vive, protege-a; quando ela cai, a cuba devolve alguém ao campo — mudo, mas inteiro.

## Papel no jogo
Segurança contra a remoção: equipado em Baba Yaga ou Cerridwen, garante que a morte delas devolva ao campo a melhor Entidade do cemitério — inclusive a própria portadora, que pela regra de resolução já está no cemitério quando `equipped_dies` resolve. A revivida volta **sem Despertar** (reviver para o campo não o dispara, regras §8): Baba Yaga volta como 3/5, Hécate como 5/7 — o corpo, sem o pacto de novo. Equipado num familiar que vai ser sacrificado para Hécate, transforma o Sacrifício em um revive gratuito — a jogada mais "pacto" do deck. O +1/+2 ainda dá corpo a quem o carrega. Caro para o turno em que sai; melhor a partir do meio do jogo, com cemitério cheio.

## Balanço
Orçamento P = 2·3+1 + 1 (Relíquia) = 8 pts. Gasto: +1 ATK / +2 Vida permanentes (3) + reviver Entidade do cemitério para o campo (3 + custo médio 4 ÷ 2 = 5) = 8. Dentro.
Rodada 1 de balanceamento: o Analista propôs reviver para a mão (+2/+3). Recusado: a regra nova de Despertar já tira o laço "Hécate/Baba Yaga voltam com Despertar sem Sacrifício"; a carta fica como está e é observada na rodada 2.

## Dados
```json
{
  "id": "bru_caldeirao_de_renascimento",
  "nome": "Caldeirão de Renascimento",
  "cultura": "bruxaria",
  "tipo": "reliquia",
  "custo": 3,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_equip", "acoes": [ { "op": "buff", "alvo": "equipped", "atk": 1, "vida": 2, "perm": true } ] },
    { "gatilho": "equipped_dies", "acoes": [ { "op": "revive", "alvo": "ally_graveyard_entity", "para": "field" } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1boy, solo, dead celtic warrior rising from a huge black iron cauldron, pale skin, glowing green eyes, bronze helmet, chainmail, holding a spear, closed mouth, stiff pose, green glowing liquid pouring over the cauldron rim, swirling green steam, cauldron decorated with embossed figures, fire under the cauldron, lakeshore at night, reeds, still water, mist, stars, purple and green, green glow, moonlight, rim lighting, dark atmosphere, full body
```

## Prompt Krea 2
Atributos obrigatórios: caldeirão de ferro preto enorme · figuras de guerreiros em relevo · líquido verde brilhante transbordando · lança e elmo de bronze apoiados nele · margem de lago à noite
```krea
A single huge black iron cauldron stands on the shore of a dark lake at night, seen from slightly below. Its round sides are embossed with rows of small Celtic warrior figures carrying spears and shields. It is filled to the brim with a glowing green liquid that overflows and pours down its sides, and thick green steam swirls up from it. A bronze Celtic helmet and a long spear lean against its rim. A fire burns beneath it on a ring of stones. Reeds, still black water and mist surround it. The green glow from the cauldron is the strong light source, with stars above.
```
