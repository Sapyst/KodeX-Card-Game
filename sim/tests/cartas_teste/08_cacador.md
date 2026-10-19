# Caçador de Gelo

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
Ao atacar, congela o alvo.

## Contexto mitológico
Carta sintética criada para testar o motor de simulação. Não pertence a nenhuma tradição; serve para cobrir o vocabulário da DSL (`docs/dsl_efeitos.md`).

## Papel no jogo
Cobertura de teste: freeze, on_attack.

## Balanço
Orçamento P = 2·C+1 = 9 pts. Carta de teste; balanço aproximado.

## Dados
```json
{
  "id": "tst_cacador",
  "nome": "Caçador de Gelo",
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
      "gatilho": "on_attack",
      "acoes": [
        {
          "op": "freeze",
          "alvo": "triggering"
        }
      ]
    }
  ],
  "usos": null
}
```

## Prompt de arte
_(não se aplica)_
