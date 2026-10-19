# Espírito da Vingança

| Campo | Valor |
|---|---|
| Cultura | teste (sintética) |
| Tipo | Entidade |
| Custo | 4 Fé |
| ATK / Vida | 3 / 3 |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Quando uma Entidade aliada morre e você tem outra em campo, ganha +1/+1.

## Contexto mitológico
Carta sintética criada para testar o motor de simulação. Não pertence a nenhuma tradição; serve para cobrir o vocabulário da DSL (`docs/dsl_efeitos.md`).

## Papel no jogo
Cobertura de teste: ally_dies, buff.

## Balanço
Orçamento P = 2·C+1 = 9 pts. Carta de teste; balanço aproximado.

## Dados
```json
{
  "id": "tst_vinganca",
  "nome": "Espírito da Vingança",
  "cultura": "teste",
  "tipo": "entidade",
  "custo": 4,
  "atk": 3,
  "vida": 3,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    {
      "gatilho": "ally_dies",
      "cond": {
        "tipo": "ally_count_min",
        "n": 1
      },
      "acoes": [
        {
          "op": "buff",
          "alvo": "self",
          "atk": 1,
          "vida": 1,
          "perm": true
        }
      ]
    }
  ],
  "usos": null
}
```

## Prompt de arte
_(não se aplica)_
