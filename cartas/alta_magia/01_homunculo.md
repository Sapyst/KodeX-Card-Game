# Homúnculo

| Campo | Valor |
|---|---|
| Cultura | alta magia |
| Tipo | Entidade |
| Custo | 2 Fé |
| ATK / Vida | 1 / 2 |
| Palavras-chave | Último Sopro |
| Lendária | não |
| Cópias no deck | 2 |

## Texto da carta
Último Sopro: compre 1 carta.

## Contexto mitológico
O homúnculo ("homenzinho") é a criatura artificial da alquimia. A receita mais famosa está no *De natura rerum* (1537) atribuído a Paracelso: sêmen humano selado num vaso de vidro, posto a putrefazer quarenta dias em esterco de cavalo até começar a mexer-se, depois nutrido com o *arcanum* do sangue humano por quarenta semanas, em calor constante. Nasce um ser pequeno, transparente, "com todos os membros de uma criança nascida de mulher", que pode ser criado e educado — e que, por ter nascido da arte e não da natureza, conhece segredos ocultos aos homens.

A ideia é mais antiga: o *Asclepius* hermético já fala de estátuas animadas por espíritos atraídos com ervas e cantos, e o Talmud conta o golem de Rava. Mas foi a versão paracelsiana, difundida pelos rosacruzes e depois por Goethe (o Homunculus do *Fausto II*), que deu à criatura seu lugar na alta magia: o servo de laboratório, frágil, que vive pouco e sabe muito.

Virou a Entidade barata do deck por isso mesmo: é o corpo que o mago cria para gastar. Morre fácil — e, morrendo, ainda ensina algo (compra uma carta). É o fodder ideal para o Sacrifício dos espíritos goéticos.

## Papel no jogo
Primeiro corpo em campo e principal alimento de Sacrifício: Astaroth, Dantalion, Paimon e Babalon podem comê-lo sem perda real, porque o Último Sopro devolve uma carta. Também é o alvo preferido de Solve et Coagula (morre → volta à mão → compra de novo). Fraco em combate; não bloqueia nada relevante.

## Balanço
Orçamento P = 2·2+1 = 5 pts. Gasto: ATK 1 + Vida 2 + Último Sopro comprar 1 (1,5) = 4,5. Dentro.

## Dados
```json
{
  "id": "alt_homunculo",
  "nome": "Homúnculo",
  "cultura": "alta_magia",
  "tipo": "entidade",
  "custo": 2,
  "atk": 1,
  "vida": 2,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_death", "acoes": [ { "op": "draw", "n": 1 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1other, solo, tiny homunculus inside a glass flask, creature enclosed in glass, curled up fetal pose, pale translucent skin, oversized head, closed eyes, tiny hands pressed against the inner glass, round glass flask, sealed red wax stopper, amber liquid, bubbles, warm glow from inside the flask, flask centered, alchemist table, brass alembic, open grimoire, candles, dark laboratory, stone wall, black and gold, red candlelight, rim lighting, object focus, close-up
```

## Prompt Krea 2
Atributos obrigatórios: frasco de vidro selado com cera vermelha · homúnculo minúsculo e translúcido, do tamanho de uma mão · corpo completo de recém-nascido (dois braços, duas pernas) · laboratório alquímico à luz de vela
```krea
A tiny artificial human, a homunculus, floats curled up inside a round sealed glass flask. He looks exactly like a newborn human baby: a chubby round baby face with soft full cheeks, a big round head, a small button nose and closed sleeping eyes. He is not old, not skinny, not wrinkled, and no ribs or bones show. He has exactly two short pudgy arms and two short pudgy legs, all complete, with both tiny palms pressed against the inner glass. He is very small, filling only one third of the flask, his pale translucent skin glowing faintly. Amber liquid and rising bubbles surround him. The flask neck is sealed with a thick red wax stopper. It stands on a dark alchemist's table beside a brass alembic, lit warm gold by one candle.
```
