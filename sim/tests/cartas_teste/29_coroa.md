# Coroa de Ferro

| Campo | Valor |
|---|---|
| Cultura | teste (sintética) |
| Tipo | Relíquia |
| Custo | 2 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Enquanto equipada, suas Entidades têm +1 Vida.

## Contexto mitológico
Carta sintética criada para testar o motor de simulação. Não pertence a nenhuma tradição; serve para cobrir o vocabulário da DSL (`docs/dsl_efeitos.md`).

## Papel no jogo
Cobertura de teste: buff, static.

## Balanço
Orçamento P = 2·C+1 = 5 pts. Carta de teste; balanço aproximado.

## Dados
```json
{
  "id": "tst_coroa",
  "nome": "Coroa de Ferro",
  "cultura": "teste",
  "tipo": "reliquia",
  "custo": 2,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    {
      "gatilho": "static",
      "acoes": [
        {
          "op": "buff",
          "alvo": "all_ally_entities",
          "atk": 0,
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
