# Krishna, o Auriga

| Campo | Valor |
|---|---|
| Cultura | hinduísmo |
| Tipo | Entidade |
| Custo | 5 Fé |
| ATK / Vida | 3 / 4 |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Enquanto Krishna estiver em campo, suas Entidades têm Ímpeto.

## Contexto mitológico
Krishna é o oitavo avatar de Vishnu e, para muitas tradições vaishnavas, a própria divindade suprema de quem os outros avatares emanam. O Bhagavata Purana (livro 10) narra sua infância em Vrindavan — o bebê que rouba manteiga, o menino que ergue o monte Govardhana num dedo para abrigar os pastores da tempestade de Indra, o jovem flautista das gopis — e a juventude em Mathura, onde mata o tirano Kamsa.

No Mahabharata ele é o estrategista e o auriga: recusa-se a lutar na guerra de Kurukshetra, mas conduz o carro de Arjuna. Quando, no primeiro dia, o arqueiro deixa cair o Gandiva e se recusa a combater, Krishna lhe ensina a Bhagavad Gita — a ação sem apego ao fruto, o dever (dharma) de cada um, a devoção — e lhe mostra a Vishvarupa, a forma universal que contém todos os mundos. Depois disso, Arjuna pega o arco.

A carta é exatamente isso: Krishna não ataca por você, mas quem está em seu carro ataca na hora.

## Papel no jogo
A carta de tempo do deck. A aura inclui o próprio Krishna, que por isso ataca no turno em que entra; e tudo que entra depois bate no mesmo turno: Rama, Arjuna, Narasimha, Kali e Shiva perdem o turno de espera, e o oponente nunca mais tem um turno para se preparar. Turno 5 Krishna, turno 6 Kali atacando, turno 7 Shiva atacando é a sequência letal do deck. Corpo 3/4: guia, não bate. Fraco: é o alvo prioritário de remoção e não protege a si mesmo.

## Balanço
Orçamento P = 2·5+1 = 11 pts. Gasto: ATK 3 + Vida 4 + aura `static` de palavra-chave em todas as aliadas (tabela §10: aura em todas = 3; o Ímpeto vale o mesmo que +1 ATK e a aura inclui a fonte) = 10. Dentro (P−1).
Rodada 2 de balanceamento (pacote H1 do Analista): ATK 4 → 3 (−0,7 pp medido). A aura foi medida e é neutra (±0,2 pp): o auriga guia, não bate.

## Dados
```json
{
  "id": "hin_krishna",
  "nome": "Krishna, o Auriga",
  "cultura": "hinduismo",
  "tipo": "entidade",
  "custo": 5,
  "atk": 3,
  "vida": 4,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "static", "acoes": [ { "op": "give_keyword", "alvo": "all_ally_entities", "keyword": "impeto" } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1boy, solo, adult man, charioteer, blue skin, peacock feather in crown, golden crown, long black hair, yellow silk dhoti, gentle smile, holding reins, pointing forward, standing in golden war chariot, chariot wheel visible, two white horses galloping ahead, flowing manes, dust clouds, war banners, battlefield at dawn, dynamic pose, speed lines, saffron and blue, golden light, rim lighting, full body
```

## Prompt Krea 2
Atributos obrigatórios: pele azul · pena de pavão na coroa · dhoti de seda amarela · rédeas nas mãos · carro de guerra com cavalos brancos
```krea
Krishna, the divine charioteer, a tall adult man with traditional blue skin, long black hair, a gentle smile and calm eyes. A single peacock feather rises from his golden crown. He wears a yellow silk dhoti and shawl, a garland of forest flowers and gold armlets. He has two normal arms: his left hand holds the reins, his right hand points forward. He stands at the front of a golden war chariot with a large spoked wheel. The heads of white galloping horses appear at the lower edge of the frame. Dust swirls on a battlefield at dawn, and a low golden sun lights him from behind.
```
