# Lança Solar

| Campo | Valor |
|---|---|
| Cultura | teste (sintética) |
| Tipo | Relíquia |
| Custo | 3 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
+2 ATK. Quando a portadora ataca, 1 de dano à Cornucópia inimiga.

## Contexto mitológico
Carta sintética criada para testar o motor de simulação. Não pertence a nenhuma tradição; serve para cobrir o vocabulário da DSL (`docs/dsl_efeitos.md`).

## Papel no jogo
Cobertura de teste: buff, damage, equipped_attacks, on_equip.

## Balanço
Orçamento P = 2·C+1 = 7 pts. Carta de teste; balanço aproximado.

## Dados
```json
{
  "id": "tst_lanca",
  "nome": "Lança Solar",
  "cultura": "teste",
  "tipo": "reliquia",
  "custo": 3,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    {
      "gatilho": "on_equip",
      "acoes": [
        {
          "op": "buff",
          "alvo": "equipped",
          "atk": 2,
          "vida": 0,
          "perm": true
        }
      ]
    },
    {
      "gatilho": "equipped_attacks",
      "acoes": [
        {
          "op": "damage",
          "alvo": "enemy_cornucopia",
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
