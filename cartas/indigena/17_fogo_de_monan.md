# Fogo de Monan

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
Cause 2 de dano a todas as Entidades inimigas e 1 à Cornucópia inimiga.

## Contexto mitológico
Monan é o criador primordial dos Tupinambá segundo André Thevet (*Cosmographie Universelle*, 1575, livro XXI), que recolheu o relato dos pajés da Guanabara. Monan — "o antigo", "o que fez" — criou o céu, a terra, os animais e os primeiros homens, e vivia entre eles. Mas os homens se tornaram ingratos e esqueceram quem os fizera; então Monan mandou **Tatá**, o fogo do céu, que queimou toda a superfície da terra e a deixou com os vales e serras que tem hoje.

Só um homem se salvou: **Irin-Magé**, "o que vê", que foi levado ao céu e de lá implorou a Monan que apagasse o fogo. Monan fez cair uma chuva tão grande que ela apagou as chamas e, correndo pelas cavidades abertas pelo fogo, formou o mar — por isso a água do mar é salgada: é cinza. Métraux (*A religião dos Tupinambás*, 1928) analisa o mito como a versão tupi do dilúvio, ligada ao mesmo medo da destruição do mundo que, séculos depois, Nimuendajú encontrou entre os Apapocuva-Guarani.

A carta é o fogo que limpa: queima o campo inimigo e alcança, de leve, a própria casa do adversário.

## Papel no jogo
A limpeza em área do deck antes de Tupã: 2 de dano em todas as inimigas mata tokens, criaturas de 2 de Vida e tudo o que Curupira e Boitatá já arranharam — e cada morte alimenta a Cobra-Grande. O 1 de dano direto à Cornucópia é bônus. Use quando o oponente encher o campo de criaturas pequenas; contra uma única criatura grande, é fraco. Único "fogo" do deck além do Boitatá, de propósito: a identidade é defender, não queimar.

## Balanço
Orçamento P = 2·2+1 = 5 pts. Gasto (tabela §10): 2 de dano a todas as inimigas (1,5 por ponto × 2 = 3) + 1 de dano direto à Cornucópia (2) = 5. Dentro. _(Revisão: conta confirmada.)_

## Dados
```json
{
  "id": "ind_fogo_de_monan",
  "nome": "Fogo de Monan",
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
      { "op": "damage", "alvo": "all_enemy_entities", "n": 2 },
      { "op": "damage", "alvo": "enemy_cornucopia", "n": 1 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, rain of fire from the sky, giant column of flame falling from storm clouds onto a rainforest, fireballs falling, burning jungle canopy, silhouetted trees, scorched ground, no buildings, no tower, dark storm clouds, red sky, orange and black, green and orange, embers, ash falling, smoke, catastrophe, wide shot, clean silhouette, readable shape, high contrast, dramatic lighting, deep shadows, rim lighting, moody atmosphere, soft glow
```

## Prompt Krea 2
Atributos obrigatórios: coluna de fogo caindo do céu · bolas de fogo · floresta queimando em silhueta · cinzas e fumaça
```krea
The fire of Monan falling from the sky: a giant column of flame pours down from black storm clouds onto an endless rainforest, and blazing fireballs streak toward the ground. The jungle canopy burns, tall trees stand as black silhouettes against the red-orange glow, and ash and embers drift through thick smoke over scorched hills. The land is wild and untouched, only forest, rivers and mountains. A wide view of the catastrophe, with the falling column of fire as the single overwhelming light source.
```
