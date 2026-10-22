# Saci-Pererê

| Campo | Valor |
|---|---|
| Cultura | indígena brasileira |
| Tipo | Entidade |
| Custo | 2 Fé |
| ATK / Vida | 1 / 1 |
| Palavras-chave | Furtivo, Despertar |
| Lendária | não |
| Cópias no deck | 2 |

## Texto da carta
Furtivo. Despertar: Congele uma Entidade inimiga.

## Contexto mitológico
O Saci é o mais popular dos seres do folclore brasileiro e um dos de origem mais discutida. O registro mais antigo, no Norte, é o de um pássaro — a *matintaperera*, cujo assobio anuncia azar — e o nome vem do tupi *çaa cy perereg*, "olho furado que pula". Câmara Cascudo (*Dicionário do Folclore Brasileiro*) mostra a figura descendo rumo ao Sul e ganhando, pelo caminho, a perna única, a carapuça vermelha e o cachimbo, elementos que o inquérito de Monteiro Lobato (*O Saci-Pererê: resultado de um inquérito*, 1918) já encontrava consolidados em São Paulo.

Apesar das camadas africanas (a figura do menino negro e o cachimbo, trazidos pelos povos escravizados) e ibéricas (a carapuça vermelha do trasgo português), o núcleo é indígena: o Saci viaja dentro do redemoinho de vento, trança as crinas dos cavalos, esconde objetos, faz o viajante perder o caminho. Não é maligno; é travesso, e a travessura serve à mata — ele atrapalha quem entra nela sem cuidado.

Na carta, o redemoinho invisível vira **Furtivo** (não pode ser alvo até atacar) e a travessura vira o Despertar que "prende" uma Entidade inimiga por um turno — o cavalo de crina trançada que não sai do lugar.

## Papel no jogo
Jogada de tempo barata: entra no turno 2, trava o melhor atacante inimigo por um turno e, Furtivo, não pode ser removido por Ritos antes de atacar. Serve para ganhar o turno em que Boitatá ou Caipora entram cansados. Como 1/1, morre para qualquer bloqueio; o valor está no Despertar, não no corpo. Fraco contra decks que ignoram criaturas e vão direto à Cornucópia.

## Balanço
Orçamento P = 2·2+1 = 5 pts. Gasto (tabela §10): ATK 1 + Vida 1 + Furtivo 1 + Despertar Freeze em inimigo (1,5) = 4,5. Dentro (P−0,5). _(Revisão: conta refeita com o valor oficial de Freeze = 1,5; resultado igual.)_

## Dados
```json
{
  "id": "ind_saci_perere",
  "nome": "Saci-Pererê",
  "cultura": "indigena",
  "tipo": "entidade",
  "custo": 2,
  "atk": 1,
  "vida": 1,
  "lendaria": false,
  "keywords": ["furtivo"],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [ { "op": "freeze", "alvo": "enemy_entity" } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1boy, solo, profile, side view, dark-skinned brazilian boy, 10 years old, hopping on one single bare leg, only one leg, single leg standing, red pointed cap, smoking clay pipe, shirtless, tattered shorts, inside spinning dust whirlwind, tornado of dry autumn leaves, night rainforest clearing, moonlight, green and orange, glowing pipe ember, rim lighting, full body
```

## Prompt Krea 2
Atributos obrigatórios: menino negro ~11 anos · perna esquerda amputada no quadril, apoiado só na direita · carapuça vermelha · cachimbo de barro aceso na mão direita · redemoinho de folhas
```krea
A Black Afro-Brazilian boy about 11 years old with realistic child proportions, caught mid-hop in profile. His left leg is amputated at the hip and completely missing; he stands on his right leg alone, one single bare foot touching the ground. He has two normal arms and two hands. He wears a bright red pointed knitted cap and ragged brown knee-length shorts. In his right hand he holds a small clay pipe with a glowing orange ember, and thin smoke curls from it. A spinning whirlwind of dust and dry leaves wraps around him in a night rainforest clearing, lit by a strong full moon behind him.
```
