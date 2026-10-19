# Rafael, o Curador

| Campo | Valor |
|---|---|
| Cultura | cristianismo |
| Tipo | Entidade |
| Custo | 3 Fé |
| ATK / Vida | 2 / 3 |
| Palavras-chave | Despertar |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Despertar: cura 4 de Vida de uma Entidade aliada.

## Contexto mitológico
Rafael ("Deus cura") é o protagonista oculto do Livro de Tobias. Disfarçado como o viajante Azarias, acompanha o jovem Tobias de Nínive à Média, ensina-o a tirar o coração, o fígado e o fel de um peixe do Tigre, com a fumaça expulsa o demônio Asmodeu que matara os sete noivos de Sara, e com o fel cura a cegueira do velho Tobit (Tb 6; 8; 11). Só no fim se revela: "Eu sou Rafael, um dos sete anjos que estão diante da glória do Senhor" (Tb 12,15).

No Primeiro Livro de Enoque é ele quem acorrenta Azazel no deserto de Dudael (1En 10,4-8), e a tradição o associa também ao anjo que agita a água da piscina de Betesda (Jo 5,4 — versículo ausente dos manuscritos mais antigos, mas firme na tradição latina). Na iconografia leva um peixe, um cajado de peregrino e um frasco de remédio; é patrono dos médicos, dos viajantes e dos cegos.

A carta é cura pura: ao chegar, devolve 4 de Vida a uma Entidade ferida — o fel do peixe sobre os olhos de Tobit.

## Papel no jogo
Mantém vivas as Entidades que o deck mais quer preservar: um Lázaro ou Serafim ferido em combate volta a pleno. Como a Vida não regenera sozinha entre turnos (regras §6), Rafael é a principal forma de desfazer trocas ruins. Também cura a portadora da Arca da Aliança, que tende a absorver ataques. Sem aliado ferido, é só um 2/3 — escolha o momento.

## Balanço
Orçamento P = 2·C+1 = 7 pts. Gasto: ATK 2 + Vida 3 + curar 4 (2 × "curar 2 = 1") = 2 → 7. Dentro.

## Dados
```json
{
  "id": "cri_rafael",
  "nome": "Rafael, o Curador",
  "cultura": "cristianismo",
  "tipo": "entidade",
  "custo": 3,
  "atk": 2,
  "vida": 3,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [ { "op": "heal", "alvo": "ally_entity", "n": 4 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1other, solo, archangel disguised as traveler, young man, short brown hair, large white wings, golden halo, green travel cloak, wide brimmed pilgrim hat, wooden walking staff, large fish hanging from belt, small glass medicine flask, water gourd, one hand extended forward glowing with healing light, gentle smile, standing on dusty road, river bank, reeds, distant ancient city, twilight, warm holy light from hand, gold and white, stained glass light, rim lighting, full body
```

## Prompt Krea 2
Atributos obrigatórios: cajado de peregrino na mão direita · frasco de remédio brilhando na esquerda · peixe pendurado no cinto · manto verde de viajante · asas brancas
```krea
A tall adult archangel, Raphael, disguised as a young traveler, with a kind face, olive Mediterranean skin and short brown hair, walking forward on a dusty road. Two large white feathered wings rise from his back and a thin golden halo circles his head. He wears a green hooded travel cloak over a knee-length tunic and leather sandals. His right hand holds a tall wooden pilgrim's staff; his left hand holds a small glass flask of medicine glowing with soft green-gold healing light. A large silver fish hangs from a cord at his belt. A riverbank with tall reeds at twilight, and the warm glow of the flask lights his face.
```
