# Serafim

| Campo | Valor |
|---|---|
| Cultura | cristianismo |
| Tipo | Entidade |
| Custo | 5 Fé |
| ATK / Vida | 4 / 4 |
| Palavras-chave | Guarda, Despertar |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Guarda. Despertar: Silencie uma Entidade inimiga (ela perde palavras-chave e efeitos).

## Contexto mitológico
Os serafins ("os ardentes", de *saraf*, queimar) aparecem uma única vez na Bíblia, na visão inaugural de Isaías: "Serafins estavam acima dele; cada um tinha seis asas: com duas cobriam o rosto, com duas cobriam os pés e com duas voavam. E clamavam: Santo, Santo, Santo é o Senhor dos Exércitos" (Is 6,2-3). Quando o profeta se declara "homem de lábios impuros", um serafim voa até ele com uma brasa tirada do altar e toca-lhe a boca: "a tua iniquidade foi tirada e o teu pecado, expiado" (Is 6,6-7).

Pseudo-Dionísio (*Da Hierarquia Celeste*, cap. 7) os põe no topo da primeira tríade, mais perto do trono que qualquer outro coro, e interpreta o nome como calor perpétuo, luz que purifica. Na arte bizantina e românica aparecem como rostos envolvidos em seis asas vermelhas, muitas vezes com os olhos nas asas.

A carta junta os dois traços: a posição de **Guarda** diante do trono e o **carvão purificador** — um toque que apaga o que havia de impuro na Entidade inimiga, deixando só o corpo.

## Papel no jogo
Primeiro corpo grande do deck, com Guarda para proteger os Renascidos e um `silence` que neutraliza a Entidade inimiga mais perigosa (tira Guarda inimiga para liberar ataques, apaga auras, Último Sopro e Renascer). O 4/4 segura bem o turno 5–6 enquanto Elias e Miguel chegam. Vulnerável a remoção dura (destroy), que é o que o oponente vai guardar para ele.

## Balanço
Orçamento P = 2·C+1 = 11 pts. Gasto: ATK 4 + Vida 4 + Guarda 1 + Silence (tabela §10) 2 = 11. Dentro.

## Dados
```json
{
  "id": "cri_serafim",
  "nome": "Serafim",
  "cultura": "cristianismo",
  "tipo": "entidade",
  "custo": 5,
  "atk": 4,
  "vida": 4,
  "lendaria": false,
  "keywords": ["guarda"],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [ { "op": "silence", "alvo": "enemy_entity" } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1other, solo, seraph, six fiery wings, two wings crossed over face, two wings crossed over legs, two wings spread wide, body hidden by wings, red and gold feathers, burning feathers, golden halo, glowing ember held in golden tongs, hovering above altar, symmetrical composition, facing viewer, temple interior, incense smoke, pillars, blinding holy light from above, red and gold, embers, full body
```

## Prompt Krea 2
Atributos obrigatórios: exatamente seis asas de fogo · duas asas cobrindo o rosto · duas cobrindo os pés · tenaz de ouro com brasa · pairando sobre o altar
```krea
A seraph, a fiery angelic being, hovering upright above a stone altar and facing the viewer in a symmetrical pose. It has exactly six wings of burning red and gold feathers: the top pair crosses in front of its face and completely hides the face, so no face and no eyes are visible; the bottom pair crosses over its legs and feet and hides them; the middle pair spreads wide to the sides. Only its torso and two arms show between the wings. Its right hand holds one pair of golden tongs gripping a single glowing red-hot coal; its left hand is open and empty. A golden halo glows behind the upper wings. A dark temple with stone pillars and incense smoke.
```
