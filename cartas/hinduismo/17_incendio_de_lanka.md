# Incêndio de Lanka

| Campo | Valor |
|---|---|
| Cultura | hinduísmo |
| Tipo | Selo |
| Custo | 1 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
No fim do turno do oponente, cause 1 de dano a todas as Entidades inimigas e 1 à Cornucópia inimiga.

## Contexto mitológico
No Sundara Kanda do Ramayana, Hanuman, depois de encontrar Sita no bosque de ashoka e lhe entregar o anel de Rama, decide se deixar capturar para medir a força do inimigo e falar com Ravana cara a cara. Levado à corte como prisioneiro, fala como embaixador: pede ao rei de Lanka que devolva Sita e se poupe. Ravana, enfurecido, manda matá-lo; o irmão Vibhishana lembra que um mensageiro não se mata, e a pena vira humilhação — embrulhar a cauda do macaco em panos embebidos em óleo e atear fogo.

Hanuman faz a cauda crescer, e crescer, e os rakshasas gastam quase todo o pano da cidade. Então, com a cauda em chamas, ele se solta, salta de telhado em telhado e incendeia Lanka inteira — palácios, torres, mansões de ouro — poupando apenas o bosque onde está Sita e a casa de Vibhishana. Mergulha a cauda no mar para apagar o fogo e volta ao continente para contar a Rama o que viu.

O Selo é a noite do incêndio: o oponente termina o turno achando que tem a situação sob controle, e sua cidade queima.

## Papel no jogo
Dano de área barato que o oponente não vê vindo — mata tokens 1/1 e termina o serviço de Garuda e Gandiva, somando 1 à Cornucópia para a corrida do deck. Colocado um turno antes de Kali, o 1 do Selo mais o 1 do Despertar dela limpam os corpos de 2 de Vida. Por 1 Fé cabe em qualquer turno. Fraco contra um único corpo grande, e inútil se o oponente não tem Entidades (ainda causa o 1 à Cornucópia).

## Balanço
Orçamento P = 2·1+1 = 3 pts (+1 Selo = 4). Gasto: 1 de dano a todas as inimigas (1,5) + 1 de dano direto à Cornucópia 2 = 3,5. Dentro.
Rodada 2 de balanceamento (pacote H1 do Analista): era custo 2 com 2 em área (5/6); −0,8 pp medido.

## Dados
```json
{
  "id": "hin_incendio_de_lanka",
  "nome": "Incêndio de Lanka",
  "cultura": "hinduismo",
  "tipo": "selo",
  "custo": 1,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "enemy_end_turn", "acoes": [
      { "op": "damage", "alvo": "all_enemy_entities", "n": 1 },
      { "op": "damage", "alvo": "enemy_cornucopia", "n": 1 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1boy, solo, monkey man silhouette, long tail on fire, burning tail, leaping across rooftops, from behind, dynamic pose, golden city burning at night, palaces and towers in flames, golden domes, ocean in the distance, smoke, flying embers, sparks, fire spreading, ambush, chaos, saffron and blue, red fire glow, orange sky, dramatic shadows, dark tone, high contrast, wide shot, full body
```

## Prompt Krea 2
Atributos obrigatórios: silhueta de Hanuman de costas · cauda longa em chamas · saltando sobre telhados · cidade dourada de Lanka em incêndio à noite
```krea
Hanuman, the monkey hero, seen from behind as a dark silhouette with a long monkey tail, a muscular body, a golden crown and a short red dhoti. His long tail is wrapped in cloth and burning at the tip with bright fire, but he is unharmed. He has two arms and two legs. He leaps from one golden rooftop to the next across the city of Lanka at night. Below and before him, palaces, towers and golden domes are in flames, smoke and flying embers rising into an orange sky. The ocean is visible in the far distance. The red fire is the strongest light.
```
