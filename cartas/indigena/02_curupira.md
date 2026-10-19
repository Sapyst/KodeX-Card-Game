# Curupira

| Campo | Valor |
|---|---|
| Cultura | indígena brasileira |
| Tipo | Entidade |
| Custo | 2 Fé |
| ATK / Vida | 1 / 2 |
| Palavras-chave | Guarda |
| Lendária | não |
| Cópias no deck | 2 |

## Texto da carta
Guarda. Sempre que sofrer dano, causa 1 de dano ao atacante.

## Contexto mitológico
O Curupira é o ser do folclore brasileiro com o registro escrito mais antigo: José de Anchieta, na carta de São Vicente de 1560, descreve os *curupiras* que "acometem os índios no mato" e para os quais se deixam penas e flechas nos caminhos. Gabriel Soares de Sousa (*Tratado Descritivo do Brasil*, 1587) repete o relato. Cascudo (*Dicionário do Folclore Brasileiro*) o acompanha de norte a sul: anão de cabelos vermelhos, dentes verdes ou azuis, e sobretudo os **pés virados para trás**, que fazem o rastro apontar para onde ele não está.

É o guardião da floresta e da caça. Pune o caçador que mata por prazer, que fere a fêmea prenhe ou o filhote, que derruba árvore sem necessidade — confundindo-o até que se perca, ou surrando-o. Quem pede licença e deixa fumo é poupado. Entre os Dessana e Tukano do Rio Negro existe o paralelo **Boraró**, também de pés para trás (Reichel-Dolmatoff, *Amazonian Cosmos*, 1971).

Na carta, o papel de guardião é **Guarda** (os inimigos têm de passar por ele) e a surra que ele dá a quem o fere é o dano devolvido a cada vez que sofre dano.

## Papel no jogo
Primeira linha de defesa: obriga o inimigo a atacá-lo e, cada vez que isso acontece, devolve 1 de dano além do seu ATK — um 2/2 inimigo que o ataca leva 2 e mata um Curupira que já custou ao oponente tempo. Protege Saci e os tokens de Caipora até Boitatá chegar. Alvo natural do Muiraquitã (+3 Vida e Renascer) e do Maracá (+1/+2). Perde para Ritos de dano, que o matam sem disparar o contragolpe de ataque.

## Balanço
Orçamento P = 2·2+1 = 5 pts. Gasto (tabela §10): ATK 1 + Vida 2 + Guarda 1 + `on_damaged` 1 de dano ao atacante (gatilho repetível: valor cheio, 1) = 5. Dentro. _(Revisão: conta confirmada.)_

## Dados
```json
{
  "id": "ind_curupira",
  "nome": "Curupira",
  "cultura": "indigena",
  "tipo": "entidade",
  "custo": 2,
  "atk": 1,
  "vida": 2,
  "lendaria": false,
  "keywords": ["guarda"],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_damaged", "acoes": [ { "op": "damage", "alvo": "attacker", "n": 1 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1boy, solo, centered, small indigenous boy, 10 years old, flame-red spiky hair, dark skin, black body paint, loincloth, bare legs, bare feet, feet pointing backward, toes pointing away from viewer, looking back at viewer, wide defensive stance, arms spread blocking the path, fierce glowing eyes, dirt trail in amazon rainforest at night, moonlight, green and orange, fireflies, rim lighting, full body
```

## Prompt Krea 2
Atributos obrigatórios: menino indígena ~11 anos · pés virados para trás (calcanhares à frente) · cabelo vermelho em chamas · postura de bloqueio de frente · tacape curto
```krea
A small Indigenous Brazilian boy about 11 years old with dark brown skin and flame-red spiky hair, standing in three-quarter view on a muddy jungle trail so his feet are clearly visible. His feet are reversed: both feet are attached backwards at the ankles, his heels point forward in the direction he faces and his toes point behind him. His knees are normal. He has two normal arms and two hands; his right hand holds one short wooden club, his left hand is open and raised to block the path. He wears a short palm-fiber skirt and a cotton sash across his chest. Backward-pointing footprints in the mud. Night rainforest, strong moonlight on his feet.
```
