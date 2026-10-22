# Strega de Benevento

| Campo | Valor |
|---|---|
| Cultura | bruxaria |
| Tipo | Entidade |
| Custo | 3 Fé |
| ATK / Vida | 2 / 3 |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Despertar: Invoque uma Strix 1/1.

## Contexto mitológico
*Strega*, bruxa em italiano, vem do latim *strix*, a coruja-das-torres. Para os romanos a *strix* era um pássaro noturno que entrava pelas janelas e sugava o sangue e as entranhas dos recém-nascidos; Ovídio dá o remédio — ramos de medronheiro e espinheiro na porta, entranhas de leitoa em troca (*Fastos* VI.131–168) — e Petrônio conta uma *striga* roubando o corpo de um menino (*Satyricon* 63). Em Apuleio (*Asno de Ouro* III.21) a bruxa Pânfila unta-se, bate os braços e vira coruja: a bruxa e a ave são a mesma coisa.

Benevento, na Campânia, é a capital italiana das streghe. Sob uma grande nogueira às margens do rio Sabato elas dançavam em volta de uma serpente ou de um bode, segundo a tradição recolhida (e combatida) pelo médico Pietro Piperno em *De nuce maga beneventana* (1635). A lenda diz que o bispo São Barbato mandou arrancar a árvore no séc. VII — e que ela voltou a crescer. O licor Strega, com a bruxa no rótulo, é a sobrevivência turística do culto.

Na carta, a strega chega com sua coruja: a mulher e o bicho que ela também é.

## Papel no jogo
Dois corpos por 3 Fé: uma 2/3 razoável e uma Strix 1/1 que serve de Sacrifício, de alvo da Vassoura ou de mais um corpo para o Sabá. É o motor de "muitos familiares pequenos" do meio do jogo; com Mau-Olhado em campo, a strega e a coruja seguram a frente enquanto o inimigo entra congelado. Sofre contra dano em área (os dois corpos morrem juntos).

## Balanço
Orçamento P = 2·3+1 = 7 pts. Gasto: ATK 2 + Vida 3 + Despertar: token 1/1 (1+1 = 2 pts) = 7. Dentro.

## Dados
```json
{
  "id": "bru_strega_de_benevento",
  "nome": "Strega de Benevento",
  "cultura": "bruxaria",
  "tipo": "entidade",
  "custo": 3,
  "atk": 2,
  "vida": 3,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [ { "op": "summon", "atk": 1, "vida": 1, "nome": "Strix", "n": 1 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1girl, solo, mature woman, italian witch, long dark wavy hair, dark red dress, black lace shawl, gold earrings, knowing smile, human arms only, no wings on her back, left arm extended forward, large barn owl perched on her forearm, white heart-shaped owl face, owl wings spread, giant gnarled walnut tree behind her, twisted roots, serpent coiled on the roots, river in the background, fireflies, night, purple and green, moonlight, rim lighting, full body
```

## Prompt Krea 2
Atributos obrigatórios: mulher italiana madura · vestido vermelho-escuro e xale de renda preta · coruja-das-torres no antebraço esquerdo · grande nogueira retorcida · serpente nas raízes
```krea
A mature adult Southern Italian woman about 45 years old, olive-skinned, with long dark wavy hair and a knowing smile, stands beneath a giant gnarled walnut tree. She wears a long dark red dress with long sleeves that covers her chest and a black lace shawl over her shoulders. She has two normal human arms and two hands. Her left arm is extended forward and a large white barn owl with a heart-shaped face is perched on her forearm, its wings half spread. Her right hand rests on the tree trunk. A small dark serpent is coiled among the twisted roots at her feet. A full moon above the branches is the strong light source.
```
