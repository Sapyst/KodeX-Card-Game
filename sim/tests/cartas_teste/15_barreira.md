# Barreira Sagrada

| Campo | Valor |
|---|---|
| Cultura | teste (sintética) |
| Tipo | Selo |
| Custo | 1 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Quando uma Entidade inimiga atacar sua Cornucópia, cure 3 na Cornucópia e cause 1 ao atacante.

## Contexto mitológico
Carta sintética criada para testar o motor de simulação. Não pertence a nenhuma tradição; serve para cobrir o vocabulário da DSL (`docs/dsl_efeitos.md`).

## Papel no jogo
Cobertura de teste: damage, enemy_attacks_cornucopia, heal.

## Balanço
Orçamento P = 2·C+1 = 3 pts. Carta de teste; balanço aproximado.

## Dados
```json
{
  "id": "tst_barreira",
  "nome": "Barreira Sagrada",
  "cultura": "teste",
  "tipo": "selo",
  "custo": 1,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    {
      "gatilho": "enemy_attacks_cornucopia",
      "acoes": [
        {
          "op": "heal",
          "alvo": "ally_cornucopia",
          "n": 3
        },
        {
          "op": "damage",
          "alvo": "attacker",
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
