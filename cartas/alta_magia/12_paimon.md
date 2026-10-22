# Paimon, Rei do Oeste

| Campo | Valor |
|---|---|
| Cultura | alta magia |
| Tipo | Entidade |
| Custo | 6 Fé |
| ATK / Vida | 4 / 5 |
| Palavras-chave | Despertar |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Despertar: Invoque dois Espíritos de Paimon 1/1.

## Contexto mitológico
Paimon é o nono espírito da *Ars Goetia*, um Grande Rei "muito obediente a Lúcifer". Aparece como um homem coroado sentado num dromedário, com rosto de mulher segundo algumas versões, **precedido por uma hoste de espíritos tocando trombetas, címbalos e toda sorte de instrumentos**. Sua voz é estrondosa; o mago deve obrigá-lo a falar mais baixo. Ensina todas as artes, filosofias e ciências, revela o que é a Terra e o que a sustenta, concede dignidades e familiares. Governa 200 legiões, "parte da ordem dos Anjos, parte das Potestades". Se o mago faz oferenda ou sacrifício, vêm com ele dois reis menores, Labal e Abalim, e outros espíritos.

Está entre os poucos espíritos da Goetia a quem o próprio texto manda **fazer oferenda** — por isso é o Rei do pacto por excelência. O título "Rei do Oeste" vem da direção em que deve ser observado: Weyer (1577) manda olhar para o Ocidente, o Lemegeton para o Noroeste, "onde fica a sua casa"; Weyer já lhe dá a mesma pompa; Collin de Plancy o desenhou de turbante sobre o camelo, e a iconografia moderna o fixou assim.

A carta é a chegada do rei: a oferenda (Sacrifício 1) traz Paimon com sua hoste (dois tokens) e a ciência que ele ensina (compra 1).

## Papel no jogo
A grande invocação do deck no turno 6 (ou 5 com Azoth): o Rei chega com a hoste e preenche a mesa sozinho — Paimon 4/5 mais dois 1/1 que viram, por sua vez, Sacrifício para Babalon, Dantalion e Astaroth, ou bloqueadores descartáveis. É o único pacto do deck que **não** exige Sacrifício: é ele quem traz o fodder para os outros. Com Solve et Coagula, cada Espírito que morre devolve uma Entidade do cemitério à mão. Precisa de slots livres (campo de 4): planeje o campo antes.

## Balanço
Orçamento P = 2·6+1 = 13 pts. Gasto: ATK 4 + Vida 5 + dois tokens 1/1 (2+2 = 4) = 13. Dentro.
Rodada 1 de balanceamento: era Sacrifício 1 + "compre 1" (14,5/15). Ficava na mão 30 % das partidas (57 % contra hinduismo) porque o fodder morria antes; sem Sacrifício entra sempre, e a compra a menos alivia a autofadiga do deck.

## Dados
```json
{
  "id": "alt_paimon",
  "nome": "Paimon, Rei do Oeste",
  "cultura": "alta_magia",
  "tipo": "entidade",
  "custo": 6,
  "atk": 4,
  "vida": 5,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [
      { "op": "summon", "atk": 1, "vida": 1, "nome": "Espírito de Paimon", "n": 2 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1other, solo, demon king, androgynous face, golden crown, long black hair, dark robe with gold embroidery, riding a dromedary camel, seated on the camel, one hand raised in command, two tiny winged spirits flying beside him, small spirits blowing trumpets, entering through a great doorway, grand dark hall, tall candles, heavy curtains, stone floor, black and gold, red candlelight, dust in the air, dramatic shadows, wide shot, full body
```

## Prompt Krea 2
Atributos obrigatórios: rei de rosto feminino e corpo masculino, andrógino · coroa de ouro e túnica escura bordada a ouro · montado num dromedário (uma corcova) · mão erguida em comando · dois espíritos pequenos tocando trombetas
```krea
Paimon, a powerful androgynous ruler who looks like a beautiful young woman with broad shoulders: smooth beardless face, completely hairless chin and cheeks, red lips, long straight black hair falling over the shoulders, a tall golden crown with no cross. Dark robe heavily embroidered with gold. Right hand raised high in command, left hand holding the reins. Rides a tall dromedary camel seen in clear side profile, its single large rounded hump fully visible in front of the saddle, not covered by cloth. Beside her fly two tiny winged imps made of golden smoke, no halos, no rings above their heads, each blowing a long golden trumpet. Great doorway of a dark hall, golden light behind.
```
