# Lamento dos Mortos

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
Quando uma Entidade aliada morrer no turno do oponente, devolva uma Entidade aleatória do cemitério à mão.

## Contexto mitológico
Carta sintética criada para testar o motor de simulação. Não pertence a nenhuma tradição; serve para cobrir o vocabulário da DSL (`docs/dsl_efeitos.md`).

## Papel no jogo
Cobertura de teste: ally_dies, revive.

## Balanço
Orçamento P = 2·C+1 = 5 pts. Carta de teste; balanço aproximado.

## Dados
```json
{
  "id": "tst_lamento",
  "nome": "Lamento dos Mortos",
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
      "gatilho": "ally_dies",
      "acoes": [
        {
          "op": "revive",
          "alvo": "ally_graveyard_entity_random",
          "para": "hand"
        }
      ]
    }
  ],
  "usos": null
}
```

## Prompt de arte
_(não se aplica)_
