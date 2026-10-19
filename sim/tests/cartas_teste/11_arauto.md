# Arauto das Hostes

| Campo | Valor |
|---|---|
| Cultura | teste (sintética) |
| Tipo | Entidade |
| Custo | 6 Fé |
| ATK / Vida | 5 / 6 |
| Palavras-chave | —, Sacrifício 1 |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Sacrifício 1. Despertar: invoca dois Acólitos 1/1.

## Contexto mitológico
Carta sintética criada para testar o motor de simulação. Não pertence a nenhuma tradição; serve para cobrir o vocabulário da DSL (`docs/dsl_efeitos.md`).

## Papel no jogo
Cobertura de teste: on_play, summon.

## Balanço
Orçamento P = 2·C+1 = 13 pts. Carta de teste; balanço aproximado.

## Dados
```json
{
  "id": "tst_arauto",
  "nome": "Arauto das Hostes",
  "cultura": "teste",
  "tipo": "entidade",
  "custo": 6,
  "atk": 5,
  "vida": 6,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 1,
  "efeitos": [
    {
      "gatilho": "on_play",
      "acoes": [
        {
          "op": "summon",
          "atk": 1,
          "vida": 1,
          "nome": "Acólito",
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
