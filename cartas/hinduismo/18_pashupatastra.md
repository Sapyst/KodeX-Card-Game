# Pashupatastra

| Campo | Valor |
|---|---|
| Cultura | hinduísmo |
| Tipo | Selo |
| Custo | 3 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Quando atacarem uma Entidade sua, destrua o atacante. Compre 1 carta.

## Contexto mitológico
O Pashupatastra é a arma pessoal de Shiva em sua forma de Pashupati, "senhor das criaturas": a mais destrutiva de todas as armas divinas, capaz de aniquilar a criação inteira se disparada sem alvo à altura. Pode ser lançada pela mente, pelo olhar, pela palavra ou pelo arco, e não tem contra-arma.

O Mahabharata (Vana Parva, episódio Kairata) conta como Arjuna a obteve. Durante o exílio, ele sobe ao Himalaia e pratica ascese severa para agradar a Shiva. Um javali o ataca; Arjuna o flecha, mas um caçador kirata reivindica a presa, e os dois lutam — Arjuna, pela primeira vez na vida, é derrotado. O caçador então revela-se Shiva, que estava testando o herói. Satisfeito, concede-lhe o Pashupatastra com uma ordem: nunca usá-la contra um inimigo menor, porque ela pode destruir o mundo. Arjuna a recebe, e jamais a dispara em Kurukshetra.

Como Selo, a arma fica guardada, virada para baixo, exatamente como Arjuna a guardou — e dispara apenas quando alguém vem até ela.

## Papel no jogo
O Selo mais caro do deck: o atacante inimigo deixa de existir e você repõe a carta. Colocado no turno 3 atrás de um Garuda, transforma o ataque adversário seguinte num desastre para ele — mas só para quem atacou; o resto do campo fica. É a resposta do deck a Lendárias inimigas sem gastar um turno de ataque próprio. Fraco quando o oponente não ataca (decks de controle) — 3 Fé parados.

## Balanço
Orçamento P = 2·3+1 = 7 pts (+1 Selo = 8). Gasto: destruir Entidade (o atacante) 5 + comprar 1 (1,5) = 6,5. Dentro (P−1,5). Custo mínimo para `destroy` (3) respeitado.
Rodada 2 de balanceamento (pacote H1 do Analista): o Analista propôs custo 2 só com o destroy (5/6, −1,3 pp medido); mantive custo 3 porque a tabela §10 exige custo mínimo 3 para `destroy`, e troquei a área por "compre 1" para a carta não cair abaixo de P−2.

## Dados
```json
{
  "id": "hin_pashupatastra",
  "nome": "Pashupatastra",
  "cultura": "hinduismo",
  "tipo": "selo",
  "custo": 3,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "enemy_attacks", "acoes": [
      { "op": "destroy", "alvo": "attacker" },
      { "op": "draw", "n": 1 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, object focus, single divine arrow, long arrow, ornate golden arrowhead, feathered fletching, arrow floating horizontally, large in frame, arrow wreathed in blue-white fire, crackling blue lightning, divine weapon, hovering above stone altar, snowy mountain cave, icicles, crescent moon, dark night, trap, waiting, saffron and blue, cold glow, deep shadows, dark tone, ominous, dramatic lighting, centered composition
```

## Prompt Krea 2
Atributos obrigatórios: uma única flecha divina · envolta em fogo azul-branco e raios · pairando sobre altar de pedra · caverna nevada · lua crescente
```krea
A single long divine arrow with an ornate golden arrowhead and white feathered fletching, with no people. It floats horizontally above a low stone altar inside a snowy mountain cave, large in the frame, motionless as if waiting. Cold blue-white fire wraps the whole arrow, and thin crackling blue lightning runs along its shaft. Icicles hang from the cave mouth, and through it a crescent moon shines in a black night sky. The cold blue glow of the arrow is the strongest light, casting sharp shadows on the stone.
```
