# Visão do Caapi

| Campo | Valor |
|---|---|
| Cultura | indígena brasileira |
| Tipo | Rito |
| Custo | 2 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Compre 2 cartas. Ganhe +1 Fé neste turno.

## Contexto mitológico
*Caapi* (ou *kahpi*, em tukano) é o cipó *Banisteriopsis caapi*, base da bebida que no Brasil é mais conhecida pelo nome quéchua *ayahuasca* e que dezenas de povos amazônicos preparam há séculos: os Tukano e Dessana do Rio Negro (*kahpi*), os Huni Kuin do Acre (*nixi pae*), os Yawanawá (*uni*), entre muitos outros. Gerardo Reichel-Dolmatoff (*Amazonian Cosmos*, 1971) descreve as sessões dessana: o pajé toma o caapi e vê as "casas" dos animais, as origens do mundo e as doenças da aldeia.

Em *Antes o mundo não existia* (1980), os autores dessana Umúsin Panlõn Kumu e Tolamãn Kenhíri contam a origem mítica: o caapi nasce de uma mulher, Kahpi Mahsõ, cujo filho é despedaçado e repartido entre os grupos — cada povo tem o seu pedaço, o seu caapi. A bebida é via de conhecimento, não de lazer: dá ao pajé a visão do que está escondido e o fôlego para agir.

A carta traduz isso em termos de jogo: você vê mais (compra 2) e ganha fôlego para agir agora (+1 Fé neste turno).

## Papel no jogo
Motor de cartas do deck. Por 2 de Fé devolve 1 (ganho temporário), então custa 1 na prática e dá duas cartas — jogado no turno 3, permite ainda invocar Caipora ou colocar um Selo. Melhor no meio do jogo, quando a mão esvazia e o deck precisa achar Jaci, Tupã ou o Kuarup. Cuidado com a mão máxima de 7.

## Balanço
Orçamento P = 2·2+1 = 5 pts. Gasto (tabela §10): comprar 2 (1,5 × 2 = 3) + +1 Fé temporária (1,5) = 4,5. Dentro (P−0,5). _(Revisão: conta confirmada.)_

## Dados
```json
{
  "id": "ind_visao_do_caapi",
  "nome": "Visão do Caapi",
  "cultura": "indigena",
  "tipo": "rito",
  "custo": 2,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [
      { "op": "draw", "n": 2 },
      { "op": "gain_fe", "n": 1, "perm": false } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1boy, solo, indigenous shaman, seated cross-legged in foreground, drinking from a small clay bowl, feather headdress, body paint, glowing eyes, luminous serpents of light coiling around him, glowing geometric patterns in the air, faint jaguar face in the dark, forest at night, small fire, purple and teal glow, green and orange, mystical, trance, full body, clean silhouette, readable shape, high contrast, dramatic lighting, deep shadows, rim lighting, moody atmosphere, soft glow
```

## Prompt Krea 2
Atributos obrigatórios: pajé adulto sentado de pernas cruzadas · tigela de barro com caapi nas duas mãos · olhos brilhando · serpentes de luz e padrões geométricos · rosto de onça no escuro
```krea
An adult Indigenous Amazonian man about 45 years old, a shaman with dark brown skin, seated cross-legged at night in a forest clearing, holding a small clay bowl of dark caapi drink with both hands at his chest. His eyes are completely filled with glowing teal light, no pupils and no dark irises, two bright teal lights shining from his face with soft rays around them. Woven cotton tunic, feather headdress, seed necklace, fine black genipapo lines on his face. Luminous teal and violet serpents with geometric patterns coil around him, and one faint jaguar face emerges from the dark behind him. A small fire in front.
```
