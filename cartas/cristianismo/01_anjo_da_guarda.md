# Anjo da Guarda

| Campo | Valor |
|---|---|
| Cultura | cristianismo |
| Tipo | Entidade |
| Custo | 2 Fé |
| ATK / Vida | 1 / 2 |
| Palavras-chave | Guarda, Último Sopro |
| Lendária | não |
| Cópias no deck | 2 |

## Texto da carta
Guarda. Último Sopro: cura 2 da sua Cornucópia.

## Contexto mitológico
A ideia de um anjo designado a cada pessoa vem do Salmo 91,11 ("ele ordenou aos seus anjos que te guardem em todos os teus caminhos") e de Mt 18,10, onde os pequeninos têm "seus anjos nos céus" diante do Pai. A Carta aos Hebreus chama os anjos de "espíritos enviados em serviço" (Hb 1,14), e o Livro de Tobias mostra o modelo completo: Rafael, disfarçado de viajante, acompanha o jovem Tobias por todo o caminho.

A devoção aos anjos da guarda ganhou festa própria no calendário romano com Paulo V (1608), fixada em 2 de outubro por Clemente X. Na iconografia popular, o anjo caminha ao lado de uma criança, mão no ombro, cobrindo-a com a asa — é essa imagem, simples e protetora, que a carta evoca.

Virou Entidade barata com **Guarda** porque é literalmente quem se põe entre o perigo e o protegido. O Último Sopro que cura a Cornucópia é o anjo que, ao cair, ainda deixa uma bênção na casa que guardava.

## Papel no jogo
Abertura defensiva do deck: desde o turno 2 obriga o inimigo a atacá-lo antes das outras Entidades, protegendo Davi, Jonas e Lázaro. Como morre barato, alimenta Tumba Vazia e Talita Cumi (revive um Guarda por quase nada). Duas cópias porque Guarda é a espinha da identidade. Fraco contra Ritos de área, que o removem sem disparar ataques.

## Balanço
Orçamento P = 2·C+1 = 5 pts. Gasto: ATK 1 + Vida 2 + Guarda 1 + Último Sopro curar 2 Cornucópia 1 = 5. Dentro.

## Dados
```json
{
  "id": "cri_anjo_da_guarda",
  "nome": "Anjo da Guarda",
  "cultura": "cristianismo",
  "tipo": "entidade",
  "custo": 2,
  "atk": 1,
  "vida": 2,
  "lendaria": false,
  "keywords": ["guarda"],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_death", "acoes": [ { "op": "heal", "alvo": "ally_cornucopia", "n": 2 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1other, solo, guardian angel, two large white feathered wings, golden halo, long white robe, long golden hair, gentle face, eyes open, standing beside small sleeping child in bed, child under blanket, hand on child's shoulder, one wing curved around the child as shield, protective stance, facing viewer, dark stone bedroom at night, small window, moonlight, warm candlelight, soft holy light, gold and white, rim lighting, full body
```

## Prompt Krea 2
Atributos obrigatórios: duas asas brancas emplumadas · auréola dourada · túnica branca longa · mão no ombro da criança · asa curvada como escudo
```krea
A tall adult guardian angel with a calm youthful androgynous face, olive Mediterranean skin and shoulder-length golden hair, kneeling on one knee beside a low bed, facing the viewer. Two large white feathered wings grow from his back; his left wing curves forward like a shield over the bed. A Middle Eastern child about 7 years old sleeps on his back with his head on the pillow, uncovered dark hair, the blanket pulled up to his chest and both arms under the blanket. The angel's right arm reaches down and his right hand rests flat on the child's shoulder, below the child's head, not touching the head. The angel's left hand is raised open toward the viewer. Exactly two arms on the angel, no other hands in the scene. Long white linen robe with a golden belt, thin golden halo. A stone bedroom at night, cold moonlight from a small window.
```
