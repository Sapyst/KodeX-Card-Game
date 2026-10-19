# Xamã Curador

| Campo | Valor |
|---|---|
| Cultura | teste (sintética) |
| Tipo | Entidade |
| Custo | 3 Fé |
| ATK / Vida | 2 / 3 |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Despertar: cura 2 em uma Entidade aliada. Último Sopro: compre 1.

## Contexto mitológico
Carta sintética criada para testar o motor de simulação. Não pertence a nenhuma tradição; serve para cobrir o vocabulário da DSL (`docs/dsl_efeitos.md`).

## Papel no jogo
Cobertura de teste: draw, heal, on_death, on_play.

## Balanço
Orçamento P = 2·C+1 = 7 pts. Carta de teste; balanço aproximado.

## Dados
```json
{
  "id": "tst_xama",
  "nome": "Xamã Curador",
  "cultura": "teste",
  "tipo": "entidade",
  "custo": 3,
  "atk": 2,
  "vida": 3,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    {
      "gatilho": "on_play",
      "acoes": [
        {
          "op": "heal",
          "alvo": "ally_entity",
          "n": 2
        }
      ]
    },
    {
      "gatilho": "on_death",
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
