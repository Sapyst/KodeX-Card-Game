# Descida do Avatar

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
Reviva uma Entidade do seu cemitério para o campo.

## Contexto mitológico
*Avatara* significa literalmente "descida": o deus que desce ao mundo numa forma — peixe, tartaruga, javali, homem-leão, anão, guerreiro, príncipe, pastor — para restaurar o que se perdeu. O princípio está formulado na Bhagavad Gita (4.7–8), na voz de Krishna: "Sempre que o dharma declina e o adharma se levanta, ó Bharata, eu me manifesto. Para proteger os bons, destruir os maus e restabelecer o dharma, eu nasço era após era."

A lista dos dez avatares (Dashavatara) se fixa nos Puranas — Bhagavata 1.3 enumera mais de vinte manifestações antes de dizer que "as encarnações do Senhor são incontáveis, como os riachos que nascem de um lago inesgotável". Cada descida tem uma missão e um fim: Rama volta a Vaikuntha depois de reinar, Krishna deixa o corpo depois de Kurukshetra; e a seguinte descida está sempre prometida. O que morre não acaba — é chamado de volta quando é preciso.

O Rito é essa promessa cumprida: o avatar que caiu desce de novo, inteiro, com a mesma tarefa.

## Papel no jogo
O coração do ciclo de renascimento: devolve ao campo qualquer Entidade do cemitério — Hanuman, para atacar de novo no turno seguinte; Shiva ou Kali, por 3 Fé em vez de 6–7, como corpo grande de volta à mesa. O avatar desce **sem o Despertar** (reviver para o campo não o dispara, regras §8): o que volta é o corpo, a palavra-chave (Ímpeto de Shiva, Renascer de Rama) e os gatilhos contínuos (o `enemy_dies` de Kali). Com Krishna em campo, o revivido ataca na hora. Fraca cedo no jogo, com cemitério vazio.

## Balanço
Orçamento P = 2·3+1 = 7 pts. Gasto: reviver Entidade para o campo = 3 + custo dela ÷ 2 — pior caso Shiva (custo 7): 3 + 3,5 = 6,5; caso típico Hanuman (custo 4): 5. Dentro.

## Dados
```json
{
  "id": "hin_descida_do_avatar",
  "nome": "Descida do Avatar",
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
      { "op": "revive", "alvo": "ally_graveyard_entity", "para": "field" } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1boy, solo, adult man, realistic proportions, blue skin, four arms, upper right hand holding golden discus, upper left hand holding conch shell, lower right hand holding mace, lower left hand holding lotus, tall golden crown, gold ornaments, yellow silk dhoti, serene expression, descending from the sky, floating, column of golden light, parting clouds, halo, sacred river below, saffron and blue, god rays, rim lighting, full body
```

## Prompt Krea 2
Atributos obrigatórios: homem adulto de pele azul · exatamente quatro braços com disco, concha, maça e lótus · coroa alta dourada · descendo do céu numa coluna de luz
```krea
Vishnu descending as an avatar, a tall adult man with traditional blue skin, a serene face and realistic adult proportions. He has exactly four arms: the upper right hand holds a golden discus, the upper left holds a white conch shell, the lower right holds a golden mace, the lower left holds a pink lotus. He has two normal legs. He wears a tall golden crown, gold necklaces with a red jewel on his chest, and a yellow silk dhoti. He descends slowly from the sky inside a column of golden light that parts dark clouds, his feet above a sacred river far below.
```
