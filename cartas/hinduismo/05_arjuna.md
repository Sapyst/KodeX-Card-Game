# Arjuna

| Campo | Valor |
|---|---|
| Cultura | hinduísmo |
| Tipo | Entidade |
| Custo | 3 Fé |
| ATK / Vida | 2 / 2 |
| Palavras-chave | Furtivo |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Furtivo. Sempre que esta atacar, cause 1 de dano a uma Entidade inimiga.

## Contexto mitológico
Arjuna é o terceiro dos cinco Pandavas, filho de Kunti com o deus Indra, e o maior arqueiro do Mahabharata. Discípulo predileto de Drona, ganha o arco Gandiva e duas aljavas inesgotáveis no incêndio da floresta de Khandava (Adi Parva). No Vana Parva, pratica ascese no Himalaia até que Shiva, disfarçado de caçador kirata, o testa em combate e lhe concede o Pashupatastra. É a Arjuna que Krishna, seu auriga, ensina a Bhagavad Gita no campo de Kurukshetra, quando o herói hesita diante de matar parentes e mestres.

A palavra-chave Furtivo vem do Virata Parva: no último ano de exílio, os Pandavas devem viver incógnitos, e Arjuna passa esse ano na corte do rei Virata disfarçado de Brihannala, professor(a) de dança das princesas, com o Gandiva escondido numa árvore. Ninguém o reconhece — até o dia em que ele retoma o arco e, sozinho, derrota o exército Kaurava inteiro que viera roubar o gado de Virata.

A flecha extra ao atacar lembra que Arjuna raramente dispara uma seta só.

## Papel no jogo
Pode ser invocado sem medo de remoção: enquanto não atacar, Ritos e Selos inimigos não o alcançam, o que o torna o portador mais seguro do deck para Gandiva (a Relíquia equipa antes do primeiro ataque; Arjuna vira 5/4 e cada ataque dele chove flechas no campo inimigo) ou Trishula. O ping ao atacar termina um corpo ferido ou mata um token antes do combate. Com Krishna em campo ganha Ímpeto e vira ameaça imediata. Fraco: corpo 2/2 — sem Relíquia, é um arqueiro sem arco; depois do primeiro ataque, morre fácil.

## Balanço
Orçamento P = 2·3+1 = 7 pts. Gasto: ATK 2 + Vida 2 + Furtivo 1 + 1 de dano a alvo escolhido a cada ataque (repetível, sem Usos: 1 × 2 = 2) = 7. Dentro.
Revisão: era 3/2 (total 8, acima de P); o ping repetível vale cheio, então o corpo caiu para 2/2.

## Dados
```json
{
  "id": "hin_arjuna",
  "nome": "Arjuna",
  "cultura": "hinduismo",
  "tipo": "entidade",
  "custo": 3,
  "atk": 2,
  "vida": 2,
  "lendaria": false,
  "keywords": ["furtivo"],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_attack", "acoes": [ { "op": "damage", "alvo": "enemy_entity", "n": 1 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1boy, solo, archer, warrior prince, adult man, long black hair, golden crown, gold armor, muscular, holding great longbow, large curved bow, bow fully visible, drawing bowstring, arrow nocked, aiming, side view, focused expression, standing on war chariot, war banner with monkey emblem, swirling dust, battlefield at dawn, low light, saffron and blue, golden light, rim lighting, dramatic shadows, full body
```

## Prompt Krea 2
Atributos obrigatórios: arqueiro adulto indiano · arco longo Gandiva retesado com flecha · armadura dourada e coroa · meio escondido na sombra de uma árvore
```krea
Arjuna, a tall adult Indian warrior prince about thirty years old, with brown skin, long black hair and a thin moustache, realistic adult proportions. He wears gold-plated armor over a saffron tunic, a white dhoti and a golden crown. He has two normal arms and two hands. He kneels half hidden in the shadow of a large shami tree, its branches partly covering him, and draws a huge curved longbow of dark wood and gold with an arrow nocked, aiming to the side, his face calm and focused. A quiver of arrows hangs on his back. Beyond him a dusty battlefield is lit by a low red dawn sun.
```
