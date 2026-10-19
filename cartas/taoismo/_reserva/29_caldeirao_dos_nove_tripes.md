# Caldeirão dos Nove Tripés

> **Fora do deck** desde a revisão (ver `../_revisao.md`): pela regra oficial (gatilho repetível = valor cheio, sem ×2) vale 6 pts em P+1 = 8, e Guarda + cura recorrente engrossava o "muro" do deck; o slot virou a segunda cópia do Espelho de Bronze.

| Campo | Valor |
|---|---|
| Cultura | taoismo |
| Tipo | Relíquia |
| Custo | 3 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Equipe uma Entidade aliada: +1/+3 e Guarda. Sempre que a portadora atacar, cure 2 da sua Cornucópia.

## Contexto mitológico
Os Nove Tripés (九鼎, *jiuding*) são os caldeirões de bronze que Yu o Grande, domador do dilúvio e fundador da dinastia Xia, teria fundido com o metal enviado em tributo pelas nove províncias, gravando em cada um as criaturas e espíritos da sua região "para que o povo soubesse o que é divino e o que é maligno" (*Zuo zhuan*, Xuan 3). Os tripés passam de Xia a Shang e de Shang a Zhou: possuí-los é ter o Mandato do Céu. Quando um enviado de Chu pergunta "quanto pesam os tripés?", a pergunta é entendida como ambição ao trono. Perdem-se no fim dos Zhou; Qin Shi Huang manda mil homens dragar o rio Si atrás deles e não acha nada (*Shiji*, "Fengshan shu").

Para o taoismo o *ding* é também a fornalha do alquimista — o "caldeirão" onde se refina o cinábrio, e depois, na alquimia interna, o próprio ventre do adepto. O *Shiji* conta que o Imperador Amarelo fundiu um tripé ao pé do Monte Jing e, quando ficou pronto, um dragão desceu para levá-lo ao céu com setenta cortesãos. O vaso que alimenta o povo, que legitima o rei e que gera o elixir é o mesmo objeto.

Como Relíquia, o caldeirão pesa: quem o carrega fica mais sólido, atrai os ataques (Guarda) e, cada vez que avança, alimenta a Cornucópia — o tripé era, antes de tudo, a panela do sacrifício.

## Papel no jogo
Faz de qualquer Imortal um muro: He Xiangu com o caldeirão é 2/5 Guarda que ainda cura todo turno; Nezha com ele é 4/6 com Ímpeto e Renascer que devolve 2 de Cornucópia a cada ataque. Em jogos longos de atrito, a cura recorrente é o que mantém o deck à frente na corrida. Custo 3 é alto para uma Relíquia; perde-se tudo se a portadora for devolvida à mão.

## Balanço
Orçamento P = 2·C+1 = 7 pts, +1 grátis de Relíquia = 8. Gasto: +1 ATK (1) + +3 Vida (3) + Guarda (1) + "ao atacar, cura 2 de Cornucópia" (gatilho repetível: valor cheio, 1) = 6. P−2: fraca; se voltar, subir para +2/+3 ou baixar para custo 2.

## Dados
```json
{
  "id": "tao_caldeirao_dos_nove_tripes",
  "nome": "Caldeirão dos Nove Tripés",
  "cultura": "taoismo",
  "tipo": "reliquia",
  "custo": 3,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_equip", "acoes": [
      { "op": "buff", "alvo": "equipped", "atk": 1, "vida": 3, "perm": true },
      { "op": "give_keyword", "alvo": "equipped", "keyword": "guarda" } ] },
    { "gatilho": "equipped_attacks", "acoes": [ { "op": "heal", "alvo": "ally_cornucopia", "n": 2 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
_(pendente)_
