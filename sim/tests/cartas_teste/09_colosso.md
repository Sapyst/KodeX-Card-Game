# Colosso Adormecido

| Campo | Valor |
|---|---|
| Cultura | teste (sintética) |
| Tipo | Entidade |
| Custo | 5 Fé |
| ATK / Vida | 4 / 5 |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
No início do seu turno, cura 2 em si mesmo.

## Contexto mitológico
Carta sintética criada para testar o motor de simulação. Não pertence a nenhuma tradição; serve para cobrir o vocabulário da DSL (`docs/dsl_efeitos.md`).

## Papel no jogo
Cobertura de teste: heal, start_turn.

## Balanço
Orçamento P = 2·C+1 = 11 pts. Carta de teste; balanço aproximado.

## Dados
```json
{
  "id": "tst_colosso",
  "nome": "Colosso Adormecido",
  "cultura": "teste",
  "tipo": "entidade",
  "custo": 5,
  "atk": 4,
  "vida": 5,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    {
      "gatilho": "start_turn",
      "acoes": [
        {
          "op": "heal",
          "alvo": "self",
          "n": 2
        }
      ]
    }
  ],
  "usos": null
}
```

## Prompt de arte
_(não se aplica)_
