# Sudarshana Chakra

| Campo | Valor |
|---|---|
| Cultura | hinduísmo |
| Tipo | Relíquia |
| Custo | 3 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
A portadora ganha +2/+1 e Ímpeto. Sempre que ela atacar, cause 1 de dano a uma Entidade inimiga.

## Contexto mitológico
O Sudarshana Chakra ("disco de boa visão") é a arma de Vishnu: um disco de 108 dentes serrilhados que gira no indicador de sua mão direita, dispara à velocidade do pensamento, destrói o alvo e volta à mão. Nos bronzes e pinturas, aparece com chamas ao redor e, em templos do sul, é adorado como uma divindade própria (Chakrattalvar).

O Mahabharata (Adi Parva) conta que Agni o entregou a Krishna no incêndio de Khandava, ao mesmo tempo em que dava o Gandiva a Arjuna; o Bhagavata (8.9) narra o uso mais célebre: durante a distribuição da amrita, o asura Rahu se disfarça de deva e bebe; Surya e Chandra o denunciam, e Vishnu lhe corta a cabeça com o disco — a cabeça, já imortal, persegue sol e lua para sempre (os eclipses). No Sabha Parva, Krishna decapita o rei Shishupala no sacrifício Rajasuya, depois de perdoar cem ofensas prometidas à mãe dele. No Shiva Purana, Vishnu recebe o disco de Shiva como prêmio de devoção, depois de oferecer o próprio olho no lugar de um lótus que faltava.

Na carta, o disco gira no dedo da portadora: quem a empunha avança na hora (Ímpeto) e, em cada investida, o disco voa e corta mais alguém.

## Papel no jogo
A Relíquia mais agressiva do deck: dá Ímpeto a quem não tem (Rama, Narasimha, Arjuna, Kali) e transforma cada ataque em dois — o golpe principal e 1 de dano em outro alvo (um token, ou o corpo que Garuda e Lanka já feriram). Sobre Hanuman, cada turno termina um corpo a menos. Equipada num corpo recém-invocado, cria um turno de ataque surpresa. Fraca: a portadora vira alvo prioritário e leva o disco com ela ao morrer.

## Balanço
Orçamento P = 2·3+1 = 7 pts (+1 Relíquia = 8). Gasto: +2 ATK 2 + +1 Vida 1 + Ímpeto 1 + 1 de dano a Entidade escolhida a cada ataque (repetível, sem Usos: 1 × 2 = 2) = 6. Dentro (P−2).
Rodada 2 de balanceamento (pacote H1 do Analista): dano por ataque 2 → 1 (parte do pacote de Relíquias).
Revisão: era +2/+2 com 3 de dano por ataque contado uma vez só (3); como repetível cheio valia 11. Caiu para +2/+1 e 2 de dano.

## Dados
```json
{
  "id": "hin_sudarshana_chakra",
  "nome": "Sudarshana Chakra",
  "cultura": "hinduismo",
  "tipo": "reliquia",
  "custo": 3,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_equip", "acoes": [
      { "op": "buff", "alvo": "equipped", "atk": 2, "vida": 1, "perm": true },
      { "op": "give_keyword", "alvo": "equipped", "keyword": "impeto" } ] },
    { "gatilho": "equipped_attacks", "acoes": [
      { "op": "damage", "alvo": "enemy_entity", "n": 1 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, object focus, close-up, golden spinning discus, flat disc facing viewer, round disc with serrated teeth around the edge, ornate golden hub, many spokes, ring of fire on the rim, spinning, motion lines, sparks flying, floating in the air, divine weapon, large in frame, dark night sky, temple spire silhouette, saffron and blue, orange fire glow, golden light, embers, rim lighting, high contrast, centered composition
```

## Prompt Krea 2
Atributos obrigatórios: disco dourado de borda serrilhada · cubo central ornamentado · anel de fogo na borda · girando no ar
```krea
The Sudarshana Chakra, Vishnu's spinning discus, shown alone as an object with no people. It is a flat round golden disc facing the viewer, its outer edge lined with many sharp serrated teeth, with an ornate golden hub and many fine spokes. A ring of fire burns around its rim as it spins, throwing sparks and embers outward in a circle. It floats in the air, large in the frame, against a dark night sky with the silhouette of a temple spire below. The orange fire on its rim is the strongest light.
```
