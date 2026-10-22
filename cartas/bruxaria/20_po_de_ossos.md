# Pó de Ossos

| Campo | Valor |
|---|---|
| Cultura | bruxaria |
| Tipo | Rito |
| Custo | 2 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Cause 2 de dano a todas as Entidades inimigas. O oponente descarta 1 carta aleatória.

## Contexto mitológico
Osso moído, cinza de pira e terra de sepultura são os ingredientes da necromancia clássica. Erictho, a bruxa tessália de Lucano (*Farsália* VI.533–569), recolhe nos campos de batalha e nas piras funerárias "as cinzas que ainda fumegam e os ossos que ainda ardem dos jovens", arranca com os dentes os pregos e as cordas dos enforcados, e com isso prepara o caldo que fará um soldado morto falar. Medeia, no caldeirão de Ovídio (*Metamorfoses* VII.264–274), junta ossos, asas de coruja e a cabeça de um corvo de nove gerações. As *defixiones* gregas e romanas eram depositadas em túmulos para que os mortos as levassem aos deuses de baixo.

Na magia popular europeia a terra de cemitério vira pó de maldição e de proteção ao mesmo tempo — polvilhado na soleira do inimigo ou carregado num saquinho contra ele — e segue, pelo Atlântico, no *goofer dust* do hoodoo norte-americano, que é já outra tradição. O **Samhain** irlandês, noite em que os *síd* se abrem e os mortos circulam entre os vivos (*Tochmarc Emire*), é a data natural para este tipo de trabalho; a Wicca o guarda como o sabá dos mortos e da Anciã.

Na carta o pó é soprado sobre o campo inimigo: tudo o que estiver vivo ali sente o frio da sepultura, e algo da mão do oponente se vai com o vento.

## Papel no jogo
A única limpeza de área do deck antes de Hécate: mata tokens e Entidades de 2 de Vida, encolhe o resto para o alcance dos familiares, e ainda tira uma carta da mão inimiga. Com a Morrigan em campo, cada inimigo que morre vira um Corvo — a jogada que enche a mesa. Depois de Mau-Olhado (−1/−1), mata Entidades de 3 de Vida. Uma cópia porque a identidade do deck é maldição seletiva, não dano em massa.

## Balanço
Orçamento P = 2·2+1 = 5 pts. Gasto: 2 de dano a todas as Entidades inimigas (2 × 1,5 = 3) + oponente descarta 1 aleatória (2) = 5. Dentro.

## Dados
```json
{
  "id": "bru_po_de_ossos",
  "nome": "Pó de Ossos",
  "cultura": "bruxaria",
  "tipo": "rito",
  "custo": 2,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [
      { "op": "damage", "alvo": "all_enemy_entities", "n": 2 },
      { "op": "discard", "alvo": "enemy_hand_random", "n": 1 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1girl, solo, hooded witch, face hidden in shadow, bony pale hands, side view, palm held to her lips, blowing a large cloud of pale grey bone dust, ash and bone fragments swirling, small skulls in the dust cloud, green ghostly glow in the dust, wind, dark graveyard at night, tilted gravestones, open burial urn, iron fence, fog, bats, purple and green, moonlight, rim lighting, ominous, dark atmosphere, upper body
```

## Prompt Krea 2
Atributos obrigatórios: bruxa idosa de capuz com o rosto na sombra · mão ossuda junto aos lábios · soprando nuvem de pó de osso cinza · pequenos crânios na poeira · cemitério à noite
```krea
An elderly European woman about 70 years old, with bony pale wrinkled hands, stands in a dark graveyard at night, seen from the side. She wears a long ragged grey hooded cloak that covers her whole body, and her face is hidden in the shadow of the hood. She has two normal arms. Her right palm is held flat near her lips and she blows a large cloud of pale grey bone dust forward; her left hand holds a small open clay burial urn. The dust swirls with ash and faint shapes of small skulls, glowing ghostly green. Tilted gravestones stand in the fog behind her. A full moon is the strong light source.
```
