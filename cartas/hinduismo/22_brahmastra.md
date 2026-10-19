# Brahmastra

| Campo | Valor |
|---|---|
| Cultura | hinduísmo |
| Tipo | Rito |
| Custo | 3 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Destrua uma Entidade inimiga.

## Contexto mitológico
O Brahmastra é a arma de Brahma, o criador — a mais temida das astras (armas invocadas por mantra) das epopeias. Não é um objeto: é um mantra que se infunde em qualquer flecha ou mesmo numa folha de grama, e que só se aprende de um mestre após longa disciplina. Uma vez disparada, não pode ser retirada; só outro Brahmastra a neutraliza, e onde ela cai a terra fica estéril por gerações.

No Ramayana, Rama a recebe do sábio Agastya e com ela, no último dia da guerra, mata Ravana — a flecha de Brahma atravessa o peito do rei de Lanka e volta à aljava. No Mahabharata, Drona a ensina a Arjuna e a Ashwatthama; Karna a aprende de Parashurama, mas é amaldiçoado a esquecê-la na hora decisiva. No fim da guerra (Sauptika Parva), Ashwatthama, derrotado, dispara o Brahmastra contra Arjuna, que responde com o seu; os sábios Narada e Vyasa interpõem-se e ordenam que ambos recolham as armas — Arjuna consegue, Ashwatthama não sabe como, e desvia a dele para o ventre das mulheres Pandava, condenando os filhos por nascer. Krishna o amaldiçoa a vagar três mil anos.

O Rito é o disparo: um alvo é apagado, e tudo ao redor sente o calor.

## Papel no jogo
A arma única: por 3 Fé, tira do jogo a maior ameaça inimiga — e só ela. Abre caminho para o ataque de Hanuman no mesmo turno a partir do turno 7 (3 + 4 Fé). Em deck com poucas respostas, é a carta que se guarda para a Lendária adversária; contra tokens, use Lanka ou Kali. Fraco: não afeta a Cornucópia, e contra campo vazio é carta morta.

## Balanço
Orçamento P = 2·3+1 = 7 pts. Gasto: destruir Entidade inimiga escolhida 5 = 5. Dentro (P−2). Custo mínimo para `destroy` (3) respeitado.
Rodada 1 de balanceamento: era custo 3 com 2 em área (8 pts em P = 7 com `destroy` a 5); subiu para 4.
Rodada 2 de balanceamento (pacote H1 do Analista): volta a custo 3 e perde a área (−0,8 pp medido): o deck precisa de menos dano em área, não de remoção mais cara.

## Dados
```json
{
  "id": "hin_brahmastra",
  "nome": "Brahmastra",
  "cultura": "hinduismo",
  "tipo": "rito",
  "custo": 3,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [
      { "op": "destroy", "alvo": "enemy_entity" } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, divine arrow of blinding fire, flaming arrow streaking across the sky, glowing arrowhead, trail of golden fire, arrow diving down, impact explosion on the ground, pillar of fire, column of smoke, shockwave, flying debris, cracked earth, scorched ground, barren battlefield, dark storm clouds, ash falling, saffron and blue, blinding white-gold light, embers, speed lines, dramatic lighting, high contrast, rim lighting, epic scale, wide shot
```

## Prompt Krea 2
Atributos obrigatórios: flecha divina em chamas descendo do céu · rastro de fogo dourado · coluna de fogo no impacto · campo de batalha estéril
```krea
A single clearly visible divine arrow streaks diagonally down from a dark stormy sky, with no people. The arrow is distinct and readable as an arrow: a long straight golden shaft, a large pointed golden arrowhead at the front leading downward, and white feathered fletching at the back, the whole arrow wrapped in white-gold flames. Behind it trails a long ribbon of golden fire across the clouds. Just below its point, on a barren battlefield, the ground erupts in a tall pillar of fire with a ring-shaped shockwave, flying rocks and cracked scorched earth spreading outward. Grey ash falls from the clouds. The arrow and the explosion are the only strong light, casting long shadows over the dead ground.
```
