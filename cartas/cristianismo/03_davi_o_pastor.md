# Davi, o Pastor

| Campo | Valor |
|---|---|
| Cultura | cristianismo |
| Tipo | Entidade |
| Custo | 2 Fé |
| ATK / Vida | 1 / 2 |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Sempre que esta atacar, cause 2 de dano a uma Entidade inimiga.

## Contexto mitológico
Davi, o caçula de Jessé, pastoreia ovelhas em Belém quando Samuel o unge rei em segredo (1Sm 16,1-13). Pouco depois, no vale de Elá, o gigante filisteu Golias desafia Israel por quarenta dias. Davi recusa a armadura de Saul, escolhe cinco pedras lisas no riacho e, com a funda, acerta a testa do gigante antes de decapitá-lo com a própria espada dele (1Sm 17,40-51). "Tu vens a mim com espada e lança; eu venho a ti em nome do Senhor."

Antes de ser rei, poeta dos Salmos e ancestral do Messias, Davi é o menino que acerta a pedra *antes* do combate corpo a corpo. É esse gesto que a carta traduz: ao declarar o ataque, uma pedra sai da funda e fere alguém à escolha — não necessariamente quem ele vai enfrentar. O corpo é de menino (1 ATK); a pedra é que mata (2 de dano).

Escolhi a versão "pastor" (e não o rei) porque é o Davi dos ícones e da escultura: jovem, sem armadura, com a funda na mão.

## Papel no jogo
Agressor barato que ajuda a fechar contas: os 2 de dano "da funda" matam um token ou um inimigo ferido antes mesmo do combate, e podem ir num alvo diferente do que ele enfrenta. Com a Funda de Davi ganha Ímpeto e mais ATK — a dupla temática é a melhor abertura ofensiva do deck. Morre fácil para qualquer troca igual, o que é aceitável: Talita Cumi o traz de volta por pouco.

## Balanço
Orçamento P = 2·C+1 = 5 pts. Gasto: ATK 1 + Vida 2 + `on_attack` 2 de dano a Entidade escolhida (gatilho repetível, valor cheio) 2 = 5. Dentro. Nota para o simulador: se a pedra matar o próprio alvo do ataque antes do combate, Davi não sofre dano de volta — conferir se isso o torna remoção gratuita repetida.

## Dados
```json
{
  "id": "cri_davi_o_pastor",
  "nome": "Davi, o Pastor",
  "cultura": "cristianismo",
  "tipo": "entidade",
  "custo": 2,
  "atk": 1,
  "vida": 2,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_attack", "acoes": [ { "op": "damage", "alvo": "enemy_entity", "n": 2 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1boy, solo, young shepherd boy, teenage, curly brown hair, short wool tunic, leather belt, shepherd's pouch, barefoot, holding leather sling, whirling sling overhead, about to throw, dynamic throwing pose, determined expression, faint golden halo, rocky dry valley, judean desert, dry grass, river stones, distant enemy camp lights, few sheep in background, dusk sky, warm golden light, holy light, gold and white, rim lighting, full body
```

## Prompt Krea 2
Atributos obrigatórios: menino de 12 anos ruivo · funda girando acima da cabeça · túnica curta de lã · bolsa de pastor no quadril · descalço
```krea
A Middle Eastern Hebrew shepherd boy about 12 years old, young David, with curly reddish-brown hair and sun-tanned skin, caught in a strong attacking throw. He has realistic child proportions. His right hand whirls a leather sling above his head with a smooth river stone held in its pouch, and his left arm points forward at the unseen target. He wears a short undyed wool tunic with a leather belt and a small leather shepherd's pouch at his hip, and he is barefoot on rocky ground. The dry Valley of Elah at dusk, round stones in a dry stream bed, a few sheep far behind him, warm golden sunset light from the side.
```
