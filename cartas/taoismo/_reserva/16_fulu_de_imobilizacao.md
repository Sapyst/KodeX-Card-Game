# Fulu de Imobilização

> **Fora do deck** desde a revisão (ver `../_revisao.md`): o slot virou a segunda cópia do Fulu de Selamento. Carta válida, pronta para voltar se o simulador pedir controle de tempo.

| Campo | Valor |
|---|---|
| Cultura | taoismo |
| Tipo | Selo |
| Custo | 1 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Quando o oponente invocar uma Entidade: ela recebe −1/−1 permanente e não ataca no próximo turno dela.

## Contexto mitológico
Entre os talismãs taoistas, o mais conhecido do público moderno é o que se cola na testa: no folclore Qing e no cinema de Hong Kong, o sacerdote taoista imobiliza o *jiangshi* — o cadáver rígido que saltita atrás dos vivos — pregando-lhe na testa um *fu* de papel amarelo com caracteres vermelhos. Enquanto o papel ficar no lugar, o morto não se mexe. A imagem é tardia (*Zibuyu* de Yuan Mei, *Yuewei caotang biji* de Ji Yun, séc. XVIII), mas a lógica é antiga: o talismã é uma ordem escrita do céu, e o espírito que o recebe é obrigado a cumpri-la.

Ge Hong (*Baopuzi*, cap. 17) descreve talismãs para "amarrar" tigres, lobos e espíritos das montanhas, de modo que o viajante passe ileso; os Mestres Celestiais usavam *fu* de interdição para prender demônios de doença em jarros selados. O caractere 敕 ("por ordem") e a fórmula "急急如律令" ("depressa, depressa, conforme a lei") encerram quase todos. O talismã não mata: contém. É exatamente o que esta carta faz.

Em termos de jogo é o talismã colado no inimigo que chega: ele entra mais fraco e perde o primeiro turno em que poderia agir.

## Papel no jogo
Selo barato de controle de tempo. Como a Entidade invocada já entra cansada, o congelamento tira dela também o turno seguinte — dois turnos sem atacar —, e o −1/−1 mata qualquer 1/1 ou X/1 de imediato. Ótimo contra decks de Ímpeto. Fraco se o oponente só invoca Entidades grandes (o −1/−1 incomoda pouco), e dispara no primeiro corpo que aparecer, inclusive um token.

## Balanço
Orçamento P = 2·C+1 = 3 pts, +1 grátis de Selo = 4. Gasto: freeze (1,5) + −1 ATK permanente (1) + −1 Vida permanente (1) = 3,5. Dentro.

## Dados
```json
{
  "id": "tao_fulu_de_imobilizacao",
  "nome": "Fulu de Imobilização",
  "cultura": "taoismo",
  "tipo": "selo",
  "custo": 1,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "enemy_plays_entity", "acoes": [
      { "op": "buff", "alvo": "triggering", "atk": -1, "vida": -1, "perm": true },
      { "op": "freeze", "alvo": "triggering" } ] }
  ],
  "usos": null
}
```

## Prompt de arte
_(pendente)_
