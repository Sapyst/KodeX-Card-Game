# Ressurreição

| Campo | Valor |
|---|---|
| Cultura | teste (sintética) |
| Tipo | Rito |
| Custo | 4 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Se houver Entidade no seu cemitério, traga uma de volta ao campo.

## Contexto mitológico
Carta sintética criada para testar o motor de simulação. Não pertence a nenhuma tradição; serve para cobrir o vocabulário da DSL (`docs/dsl_efeitos.md`).

## Papel no jogo
Cobertura de teste: on_play, revive.

## Balanço
Orçamento P = 2·C+1 = 9 pts. Carta de teste; balanço aproximado.

## Dados
```json
{
  "id": "tst_ressurreicao",
  "nome": "Ressurreição",
  "cultura": "teste",
  "tipo": "rito",
  "custo": 4,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    {
      "gatilho": "on_play",
      "cond": {
        "tipo": "graveyard_entities_min",
        "n": 1
      },
      "acoes": [
        {
          "op": "revive",
          "alvo": "ally_graveyard_entity",
          "para": "field"
        }
      ]
    }
  ],
  "usos": null
}
```

## Prompt de arte
_(não se aplica)_
