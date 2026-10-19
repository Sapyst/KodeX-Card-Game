# Escudo do Mártir

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
+2 Vida. Quando a portadora morre, invoca um Espírito 1/1.

## Contexto mitológico
Carta sintética criada para testar o motor de simulação. Não pertence a nenhuma tradição; serve para cobrir o vocabulário da DSL (`docs/dsl_efeitos.md`).

## Papel no jogo
Cobertura de teste: buff, equipped_dies, on_equip, summon.

## Balanço
Orçamento P = 2·C+1 = 5 pts. Carta de teste; balanço aproximado.

## Dados
```json
{
  "id": "tst_escudo",
  "nome": "Escudo do Mártir",
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
      "gatilho": "on_equip",
      "acoes": [
        {
          "op": "buff",
          "alvo": "equipped",
          "atk": 0,
          "vida": 2,
          "perm": true
        }
      ]
    },
    {
      "gatilho": "equipped_dies",
      "acoes": [
        {
          "op": "summon",
          "atk": 1,
          "vida": 1,
          "nome": "Espírito"
        }
      ]
    }
  ],
  "usos": null
}
```

## Prompt de arte
_(não se aplica)_
