# Tempestade

| Campo | Valor |
|---|---|
| Cultura | teste (sintética) |
| Tipo | Rito |
| Custo | 3 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Causa 2 de dano a todas as Entidades inimigas; o oponente descarta 1 carta aleatória.

## Contexto mitológico
Carta sintética criada para testar o motor de simulação. Não pertence a nenhuma tradição; serve para cobrir o vocabulário da DSL (`docs/dsl_efeitos.md`).

## Papel no jogo
Cobertura de teste: damage, discard, on_play.

## Balanço
Orçamento P = 2·C+1 = 7 pts. Carta de teste; balanço aproximado.

## Dados
```json
{
  "id": "tst_tempestade",
  "nome": "Tempestade",
  "cultura": "teste",
  "tipo": "rito",
  "custo": 3,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    {
      "gatilho": "on_play",
      "acoes": [
        {
          "op": "damage",
          "alvo": "all_enemy_entities",
          "n": 2
        },
        {
          "op": "discard",
          "alvo": "enemy_hand_random",
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
