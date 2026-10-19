# Dantalion, das Mil Faces

| Campo | Valor |
|---|---|
| Cultura | alta magia |
| Tipo | Entidade |
| Custo | 5 Fé |
| ATK / Vida | 3 / 4 |
| Palavras-chave | Sacrifício 1, Despertar |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Sacrifício 1. Despertar: tome o controle permanente de uma Entidade inimiga.

## Contexto mitológico
Dantalion é o 71º e penúltimo espírito da *Ars Goetia*, um Grande Duque que aparece "na forma de um homem com muitas faces, todas de homens e mulheres", segurando um livro na mão direita. Ensina todas as artes e ciências e revela o conselho secreto de qualquer pessoa, "pois **conhece os pensamentos de todos os homens e mulheres e pode mudá-los à sua vontade**"; provoca amor e mostra a semelhança de qualquer pessoa em visão, em qualquer parte do mundo. Governa 36 legiões. Como Vassago, Seere e Andromalius, **não aparece em Weyer** (1577): foi acrescentado pelo compilador do Lemegeton no século XVII, o que faz dele um dos espíritos mais "jovens" do catálogo.

É o espírito da mente alheia — o único do catálogo cujo poder central é alterar a vontade de outro. Por isso virou figura recorrente na ficção ocultista moderna como "o que fala por dentro da cabeça". Sua imagem de muitas faces superpostas é das mais fortes do Lemegeton e aparece nas ilustrações do século XIX como um rosto que se desdobra em dezenas.

A carta é literal: Dantalion muda a mente de uma Entidade inimiga e ela passa para o seu lado — para sempre. O preço é o pacto (Sacrifício 1): você entrega um dos seus para ficar com um dos deles.

## Papel no jogo
A jogada de virada do deck. Sacrifica um Homúnculo ou Elemental e rouba a melhor Entidade do oponente — idealmente uma que Marbas já silenciou (sem efeitos perigosos) ou a Lendária dele. Dois corpos entram (Dantalion 3/4 + a roubada), um sai: troca de 2 por 1 em campo e remoção ao mesmo tempo. Fica fraco se o campo inimigo está vazio ou só tem tokens — aí é um 3/4 caro.

## Balanço
Orçamento P = 2·5+1 = 11 pts; Sacrifício 1 = −2 de custo → orçamento efetivo 13. Gasto: ATK 3 + Vida 4 + roubar Entidade permanente (estimado 6: destruir = 4, mais ganhar o corpo ≈ 2) = 13. Dentro.

## Dados
```json
{
  "id": "alt_dantalion",
  "nome": "Dantalion, das Mil Faces",
  "cultura": "alta_magia",
  "tipo": "entidade",
  "custo": 5,
  "atk": 3,
  "vida": 4,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 1,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [ { "op": "swap_control", "alvo": "enemy_entity", "perm": true } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1other, solo, robed demon with many faces, head made of many overlapping human faces, faces of men and women, cluster of faces, golden crown, long dark robe with golden trim, two arms, open book in the right hand, left hand reaching toward viewer, glowing fingertips, threads of light from the fingertips, hypnotic gaze, candlelit ritual chamber, heavy curtains, stone floor, black and gold, red candlelight, glowing sigils, dramatic shadows, full body
```

## Prompt Krea 2
Atributos obrigatórios: homem de manto escuro com exatamente seis faces ao redor da cabeça (homens e mulheres) · coroa de ouro · livro aberto na mão direita · mão esquerda estendida com fios de luz (controle mental)
```krea
Dantalion, a tall robed spirit with one body, two normal arms and one single head that carries exactly six human faces arranged in a full ring around it. Three faces are women, beardless, with smooth skin and long hair; three faces are men, alternating woman, man, woman around the head. From the front we see a young woman's face in the center, a bearded man's face turned to the left, an old woman's face turned to the right, and three more faces partly visible behind them. A thin golden crown sits on top. He wears a long dark robe with golden trim. His right hand holds a large open book; his left hand reaches toward the viewer, fine threads of golden light streaming from his fingertips like puppet strings. Candlelit ritual chamber with heavy curtains.
```
