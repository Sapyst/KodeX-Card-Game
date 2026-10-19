# Contrafeitiço

| Campo | Valor |
|---|---|
| Cultura | teste (sintética) |
| Tipo | Selo |
| Custo | 2 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Quando o oponente jogar um Rito de custo 4 ou menos, anule-o.

## Contexto mitológico
Carta sintética criada para testar o motor de simulação. Não pertence a nenhuma tradição; serve para cobrir o vocabulário da DSL (`docs/dsl_efeitos.md`).

## Papel no jogo
Cobertura de teste: counter, enemy_plays_rite.

## Balanço
Orçamento P = 2·C+1 = 5 pts. Carta de teste; balanço aproximado.

## Dados
```json
{
  "id": "tst_contrafeitico",
  "nome": "Contrafeitiço",
  "cultura": "teste",
  "tipo": "selo",
  "custo": 2,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    {
      "gatilho": "enemy_plays_rite",
      "cond": {
        "tipo": "target_cost_max",
        "n": 4
      },
      "acoes": [
        {
          "op": "counter"
        }
      ]
    }
  ],
  "usos": null
}
```

## Prompt de arte
_(não se aplica)_
