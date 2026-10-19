# Muiraquitã

| Campo | Valor |
|---|---|
| Cultura | indígena brasileira |
| Tipo | Relíquia |
| Custo | 2 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
A portadora ganha +3 Vida e Renascer.

## Contexto mitológico
O muiraquitã é um amuleto de pedra verde — nefrita, jadeíta ou outra rocha dura — esculpido em forma de **rã**, às vezes de peixe ou tartaruga, com um furo para pendurar ao pescoço. Peças arqueológicas foram achadas em toda a bacia do Tapajós e no Marajó, e os colonizadores as encontraram em uso entre os povos do baixo Amazonas no século XVI. João Barbosa Rodrigues dedicou-lhe um livro inteiro, *O Muyrakytã e os ídolos simbólicos* (1899), reunindo as lendas e a arqueologia.

A lenda, recolhida por Barbosa Rodrigues e repetida por Cascudo (*Dicionário do Folclore Brasileiro*), liga o muiraquitã às **Icamiabas**, as "mulheres sem marido" que frei Gaspar de Carvajal (1542) descreveu como guerreiras e que a Europa chamou de Amazonas. Uma vez por ano, à luz da lua, elas recebiam homens visitantes à beira do lago Jaci-uaruá ("espelho da lua"), mergulhavam e traziam do fundo o barro verde, que moldavam em pequenos animais; ao sair da água o barro endurecia em pedra, e as Icamiabas o davam aos homens como amuleto de proteção e sorte, que depois passava de geração em geração.

Na carta, o muiraquitã protege (+3 Vida) e, como amuleto que atravessa gerações, faz a portadora voltar (Renascer).

## Papel no jogo
Relíquia defensiva que combina com tudo o que o deck quer manter vivo: Curupira vira 1/5 Guarda que volta à mão quando morre; Boitatá 3/7; Mapinguari 4/8. Renascer significa que a remoção inimiga vale metade — a Entidade volta à mão e pode ser invocada de novo (e dispara o Despertar outra vez, na Caipora e na Iara). Barata para o que faz. Morre com a portadora, mas o Renascer já cumpriu seu papel.

## Balanço
Orçamento P = 2·2+1 = 5 pts, +1 grátis de Relíquia = 6. Gasto (tabela §10): +3 Vida permanente (3) + Renascer (2) = 5. Dentro (P−1). _(Revisão: conta confirmada. Renascer devolve a portadora à mão; a Relíquia vai ao cemitério e o +3 some — não há loop.)_

## Dados
```json
{
  "id": "ind_muiraquita",
  "nome": "Muiraquitã",
  "cultura": "indigena",
  "tipo": "reliquia",
  "custo": 2,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_equip", "acoes": [
      { "op": "buff", "alvo": "equipped", "atk": 0, "vida": 3, "perm": true },
      { "op": "give_keyword", "alvo": "equipped", "keyword": "renascer" } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, object focus, close-up, small carved green jade frog amulet, stone figurine, polished nephrite, hanging on a plant-fiber cord, glowing faintly emerald, floating above moonlit lake water, ripples, water lilies, full moon reflection, night, green and orange, soft rim lighting, mystical, stone texture, centered composition, clean silhouette, readable shape, high contrast, dramatic lighting, deep shadows, rim lighting, moody atmosphere, soft glow
```

## Prompt Krea 2
Atributos obrigatórios: rã esculpida em jade verde polido · furo para cordão · pendurada em cordão de fibra · flutuando sobre lago ao luar
```krea
A small carved green jade frog amulet, a muiraquita, of polished nephrite with smooth stylized legs folded under its body and a small hole drilled through it. It hangs from a thin plant-fiber cord and floats just above the dark surface of a moonlit lake, glowing faintly emerald. Ripples spread beneath it among water lilies, and the full moon mirrored in the lake behind it is the strong light. The amulet is the single centered subject, its stone texture sharp and detailed.
```
