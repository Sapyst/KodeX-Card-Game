# Hanuman

| Campo | Valor |
|---|---|
| Cultura | hinduísmo |
| Tipo | Entidade |
| Custo | 4 Fé |
| ATK / Vida | 3 / 2 |
| Palavras-chave | Ímpeto |
| Lendária | não |
| Cópias no deck | 2 |

## Texto da carta
Ímpeto. Sempre que esta atacar, ganha +1 ATK.

## Contexto mitológico
Hanuman é o vanara (homem-macaco) filho do deus do vento Vayu — por isso Anjaneya, Pavanaputra, Maruti — e o devoto perfeito de Rama. No Sundara Kanda do Ramayana, quando os aliados de Rama chegam à beira do oceano sem saber como alcançar Lanka, Hanuman cresce até o tamanho de uma montanha e salta os cem *yojanas* de mar num único impulso. Em Lanka, encolhe ao tamanho de um gato para procurar Sita, encontra-a no bosque de ashoka, deixa-se capturar para falar com Ravana e, quando os rakshasas incendeiam sua cauda, usa o fogo para queimar a cidade inteira antes de voltar.

Na guerra (Yuddha Kanda), quando Lakshmana cai ferido e só a erva Sanjivani do Himalaia pode salvá-lo, Hanuman, sem conseguir identificar a planta, arranca a montanha inteira e a traz na palma da mão. É um dos sete imortais (chiranjivi) e, segundo a tradição, está presente onde quer que se recite o nome de Rama. O Hanuman Chalisa de Tulsidas (séc. XVI) é um dos hinos mais recitados da Índia.

A carta é o salto para Lanka: ataca no turno em que entra e cresce a cada investida — Hanuman nunca é menor do que a tarefa exige.

## Papel no jogo
O atacante principal do deck. O bônus chega ao declarar o ataque, antes do golpe: entra como 3/2 mas bate por 4 no turno em que entra, 5 no seguinte, depois 6 — o oponente é obrigado a responder ou perde a corrida em três turnos. Portador perfeito de Trishula (+3/+2 e dano extra a cada ataque) e de Gandiva. Com duas cópias e Descida do Avatar, volta do cemitério atacando. Fraco contra Selos de contra-ataque e contra Guarda alta — 2 de Vida morre para qualquer corpo de 2 ATK; ele precisa matar o que ataca.

## Balanço
Orçamento P = 2·4+1 = 9 pts. Gasto: ATK 3 + Vida 2 + Ímpeto 1 + (+1 ATK permanente a cada ataque, repetível, sem Usos: 1 × 2 = 2) = 8. Dentro (P−1).
Rodada 2 de balanceamento (pacote H1 do Analista): Vida 3 → 2 (−2,9 pp medido, o maior corte isolado do pacote; o atacante principal passa a precisar de proteção).
Revisão: era 4/3 (total 10 com o crescimento precificado como repetível; antes estava contado como 1 pt único). Corpo caiu para 3/3 — na prática ele ainda bate por 4 na entrada.

## Dados
```json
{
  "id": "hin_hanuman",
  "nome": "Hanuman",
  "cultura": "hinduismo",
  "tipo": "entidade",
  "custo": 4,
  "atk": 3,
  "vida": 2,
  "lendaria": false,
  "keywords": ["impeto"],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_attack", "acoes": [ { "op": "buff", "alvo": "self", "atk": 1, "vida": 0, "perm": true } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1boy, solo, monkey man, monkey face, red face, long tail, muscular, golden crown, gold ornaments, red loincloth, golden mace, holding mace, leaping through the air, flying, dynamic pose, determined expression, carrying a mountain on one palm, mountain with glowing green herbs, ocean far below, night sky, clouds, saffron and blue, moonlight, golden rim lighting, wind, full body
```

## Prompt Krea 2
Atributos obrigatórios: rosto de macaco e pelo dourado · cauda longa · maça dourada na mão direita · montanha na palma esquerda · salto sobre o oceano
```krea
Hanuman, the divine monkey hero, an adult vanara with a monkey face of reddish skin, golden-brown fur over a powerful muscular human-shaped body, and a long tail curling behind him. He has two arms and two legs. He wears a golden crown, gold armlets and a short red dhoti. His right hand grips a heavy golden mace on his shoulder. His left palm raised high carries a whole small mountain covered in glowing green herbs. He leaps through the night sky in a great bounding arc, legs stretched, determined face. Far below is a dark ocean. A full moon shines behind him and rims him with light.
```
