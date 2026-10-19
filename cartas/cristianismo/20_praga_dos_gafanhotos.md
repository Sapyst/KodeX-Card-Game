# Praga dos Gafanhotos

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
Causa 2 de dano a todas as Entidades inimigas. O oponente descarta 1 carta aleatória.

## Contexto mitológico
A oitava das dez pragas do Egito. Depois do granizo que destruiu o linho e a cevada, Moisés estende o cajado e "o Senhor fez soprar um vento oriental sobre a terra todo aquele dia e toda a noite; quando amanheceu, o vento oriental tinha trazido os gafanhotos. Cobriram toda a superfície do país, de modo que a terra ficou escura; devoraram toda a erva da terra e todos os frutos das árvores que o granizo deixara, e não ficou nada verde em todo o Egito" (Ex 10,13-15). O Faraó pede perdão pela primeira vez, mas endurece de novo quando o vento oeste leva os gafanhotos ao Mar Vermelho.

O gafanhoto é, em todo o Antigo Oriente, a imagem da fome absoluta; Joel 1–2 descreve uma invasão como exército do Dia do Senhor, e Ap 9,1-11 transforma os gafanhotos em criaturas do Abismo com rei chamado Abadom. No deck, é a praga que devora não só o campo mas também o celeiro — por isso, além do dano, uma carta some da mão do oponente.

## Papel no jogo
Primeira praga: limpa tokens e Entidades de Vida ≤ 2 e leva uma carta da mão inimiga. Boa contra decks de enxame (muitos corpos pequenos) e no meio do jogo, quando o descarte ainda dói. Combina com Davi e Judite para terminar o que sobrou com Vida 1. Não afeta Entidades grandes nem o seu próprio campo.

## Balanço
Orçamento P = 2·C+1 = 5 pts. Gasto: 2 de dano a todas as inimigas (1,5 × 2) = 3 + oponente descarta 1 aleatória 2 = 5. Dentro.

## Dados
```json
{
  "id": "cri_praga_dos_gafanhotos",
  "nome": "Praga dos Gafanhotos",
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
      { "op": "damage", "alvo": "all_enemy_entities", "n": 2 },
      { "op": "discard", "alvo": "enemy_hand_random", "n": 1 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, scenery, wide shot, massive swarm of locusts filling the sky, thousands of small flying grasshoppers, dark insect cloud, one large detailed locust with wings in the foreground, devoured wheat field, bare stripped stalks, small pyramids on far horizon, nile river, stripped palm trees, dusty orange sky, sun blotted out, swirling dust, ominous, plague, holy light breaking through swarm, sickly yellow and dark brown, rim lighting
```

## Prompt Krea 2
Atributos obrigatórios: enxame que escurece o céu · um gafanhoto grande em primeiro plano · campo de trigo devorado · palmeiras desfolhadas · sol encoberto alaranjado
```krea
A vast swarm of desert locusts darkening the sky over ancient Egypt. In the foreground, one large locust in flight is shown in sharp detail, with a yellow-brown armored body, six legs and four outspread veined wings. Below, the wheat field has been completely devoured: only short bare brown stalks and stubble remain, with no ears of grain and no golden wheat anywhere. The palm trees are stripped bare, only naked trunks with no fronds and no leaves, covered in crawling locusts. Small pyramids and the Nile on the far horizon. The sun is a dim orange disk behind the swarm, and one shaft of harsh light breaks through.
```
