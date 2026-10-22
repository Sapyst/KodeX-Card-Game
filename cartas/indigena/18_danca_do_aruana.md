# Dança do Aruanã

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
Invoque dois Aruanãs 1/1. Cure 2 da sua Cornucópia.

## Contexto mitológico
Os Karajá — que se chamam **Iny**, "nós" — vivem nas margens do rio Araguaia e na Ilha do Bananal (TO, GO, MT, PA). Sua cerimônia mais visível é a dos **Aruanãs** (*Ijasó*), espíritos do fundo do rio que vêm à aldeia na época das cheias. São personificados por dançarinos mascarados, **sempre em pares**, cobertos de saias de palha de buriti que escondem o corpo inteiro, com máscaras altas de penas e pintura. Cantam em falsete para que a voz não pareça humana, e dançam da casa dos homens até as mulheres, que os recebem com comida.

Paul Ehrenreich (*Beiträge zur Völkerkunde Brasiliens*, 1891) foi o primeiro a descrever o ritual; Manuel Ferreira Lima Filho (*Hetohoky: um rito Karajá*, 1994) o situa no ciclo ritual Iny, ao lado do Hetohoky, a festa de iniciação dos meninos. O nome Aruanã é o mesmo de um peixe do Araguaia (*Osteoglossum*); as máscaras são guardadas na casa dos homens (*Hetohoky*) e são proibidas às mulheres e crianças, que as recebem como espíritos, não como vizinhos fantasiados. Do mesmo povo são as *ritxoko*, bonecas de cerâmica que muitas vezes representam os Aruanãs dançando — esse saber foi registrado como patrimônio cultural brasileiro pelo Iphan em 2012, e é uma das portas pelas quais a dança se tornou conhecida fora da aldeia.

A carta traz os dançarinos em par — dois espíritos que chegam juntos, como mandam as cheias.

## Papel no jogo
Dois corpos por 2 Fé e a aldeia respira (cura 2 na Cornucópia). Enchem o campo para Terra sem Males (+1/+1 em cada), para a aura do Cocar e para o Anhangá (cada Aruanã que morre vira um Veado Branco). São também os alvos que o inimigo tem de atacar quando não há Guarda — e cada ataque dispara Boitatá, Arapuca e Mundéu. Precisa de dois slots livres; com o campo cheio é carta morta.

## Balanço
Orçamento P = 2·2+1 = 5 pts. Gasto (tabela §10): 2 tokens Aruanã 1/1 (2 × (1+1) = 4) + curar 2 de Cornucópia (1) = 5. Dentro.
Rodada 1 de balanceamento: era só os dois tokens (4/5; 39 % no espelho, a carta mais fraca do deck). A cura cabe na identidade e leva a carta a P.

## Dados
```json
{
  "id": "ind_danca_do_aruana",
  "nome": "Dança do Aruanã",
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
      { "op": "summon", "atk": 1, "vida": 1, "nome": "Aruanã", "n": 2 },
      { "op": "heal", "alvo": "ally_cornucopia", "n": 2 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
2others, duo, two masked dancers, tall cone-shaped straw masks, whole body covered by long straw fringe costume, no visible skin, no crowns, feathers on mask tips, dancing side by side, village plaza at night, sandy ground by a river, palm-thatched huts, bonfire, firelight, green and orange, sparks, stars, solemn ritual, full body, clean silhouette, readable shape, high contrast, dramatic lighting, deep shadows, rim lighting, moody atmosphere
```

## Prompt Krea 2
Atributos obrigatórios: dois dançarinos mascarados (um à frente, outro menor atrás) · corpo todo coberto por franja de palha de buriti · máscara alta trançada com coroa de penas vermelhas e amarelas · fogueira à beira do rio
```krea
Two Karaja Aruana masked dancers in a village plaza at night, the main dancer in front and a smaller one behind, both mid-step. Each dancer is completely hidden inside a dense cone-shaped costume of pale buriti palm straw fringe that hangs from the mask down to the ground and covers the whole body; no arms, no hands, no chest and no thighs are visible, only bare feet and ankles show below the straw. On top, each wears a tall cylindrical woven mask with two round shell-disc eyes and a crown of red and yellow feathers. A bonfire beside them on a sandy riverbank, thatched huts and stars behind.
```
