# Ganesha, Removedor de Obstáculos

| Campo | Valor |
|---|---|
| Cultura | hinduísmo |
| Tipo | Entidade |
| Custo | 3 Fé |
| ATK / Vida | 2 / 3 |
| Palavras-chave | Despertar |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Despertar: devolva uma Entidade inimiga à mão do dono.

## Contexto mitológico
Ganesha (Ganapati, Vinayaka) é o deus de cabeça de elefante, filho de Parvati e Shiva, e uma das divindades mais amadas da Índia: é invocado antes de qualquer começo — uma viagem, um casamento, a primeira página de um livro. Seu epíteto mais comum é *Vighnaharta* ou *Vighneshvara*, "o que remove (e governa) os obstáculos".

O Shiva Purana (Rudra Samhita) conta a origem da cabeça: Parvati molda um menino com a pasta do próprio banho e o põe de guarda à porta. Shiva, voltando, é barrado pelo guardião desconhecido e, na luta, corta-lhe a cabeça. Diante do desespero de Parvati, Shiva manda buscar a cabeça do primeiro ser encontrado — um elefante — e a põe no corpo do menino, fazendo-o chefe (*gana-pati*) de seus séquitos. No Mahabharata (prólogo do Adi Parva), é Ganesha quem escreve o poema inteiro ditado por Vyasa, com a condição de que o sábio nunca pare de ditar.

Na carta, remover obstáculos é literal: a Entidade inimiga que trava o caminho é tirada da mesa.

## Papel no jogo
Resposta de turno 3 a uma Guarda ou a um corpo grande que o oponente pagou caro: o alvo volta para a mão, ele perde o tempo investido e o campo se abre para os atacantes com Ímpeto. Também recoloca na mão um inimigo buffado por Relíquia (a Relíquia vai ao cemitério). O corpo 2/3 segura a linha depois. Fraco contra tokens e corpos baratos — devolver custo 1 não vale 3 Fé.

## Balanço
Orçamento P = 2·3+1 = 7 pts. Gasto: ATK 2 + Vida 3 + devolver Entidade inimiga à mão 2 = 7. Dentro.

## Dados
```json
{
  "id": "hin_ganesha",
  "nome": "Ganesha, Removedor de Obstáculos",
  "cultura": "hinduismo",
  "tipo": "entidade",
  "custo": 3,
  "atk": 2,
  "vida": 3,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [ { "op": "bounce", "alvo": "enemy_entity" } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1boy, solo, elephant head, elephant-headed god, one broken tusk, curled trunk, large ears, orange skin, pot belly, four arms, multiple arms, golden crown, gold ornaments, red silk dhoti, holding axe, holding bowl of sweets, raised palm, blessing gesture, pushing aside a boulder, small mouse at his feet, temple gateway, lotus pond, oil lamps, saffron and blue, warm lamplight, rim lighting, full body
```

## Prompt Krea 2
Atributos obrigatórios: cabeça de elefante · presa direita quebrada, só a esquerda inteira · exatamente quatro braços · machado, laço, doce modak e presa quebrada nas mãos · rato pequeno aos pés
```krea
Ganesha, the elephant-headed Hindu god, an adult with a large elephant head, curled trunk and round belly on a human body with warm reddish-ochre skin. Only one tusk remains on his face: the left tusk is whole and long. His right tusk is broken off at the root and is completely missing from his face, leaving only a short flat stump. He has exactly four arms and each hand holds one object: the upper right hand holds a small axe, the upper left hand holds a looped rope noose, the lower right hand holds his broken-off tusk, the lower left hand holds a round sweet modak. He has two normal legs. He wears a red silk dhoti, a golden crown and gold ornaments. He pushes a great boulder aside with his shoulder. A small grey mouse sits at his feet under temple oil lamps.
```
