# Profeta Faminto

| Campo | Valor |
|---|---|
| Cultura | teste (sintética) |
| Tipo | Entidade |
| Custo | 5 Fé |
| ATK / Vida | 3 / 4 |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
No fim do seu turno, se tiver 2 ou menos cartas na mão, compre 1.

## Contexto mitológico
Carta sintética criada para testar o motor de simulação. Não pertence a nenhuma tradição; serve para cobrir o vocabulário da DSL (`docs/dsl_efeitos.md`).

## Papel no jogo
Cobertura de teste: draw, end_turn.

## Balanço
Orçamento P = 2·C+1 = 11 pts. Carta de teste; balanço aproximado.

## Dados
```json
{
  "id": "tst_profeta",
  "nome": "Profeta Faminto",
  "cultura": "teste",
  "tipo": "entidade",
  "custo": 5,
  "atk": 3,
  "vida": 4,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    {
      "gatilho": "end_turn",
      "cond": {
        "tipo": "hand_max",
        "n": 2
      },
      "acoes": [
        {
          "op": "draw",
          "n": 1
        }
      ]
    }
  ],
  "usos": null
}
```

## Prompt de arte
_(não se aplica)_
