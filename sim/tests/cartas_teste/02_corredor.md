# Corredor do Vento

| Campo | Valor |
|---|---|
| Cultura | teste (sintética) |
| Tipo | Entidade |
| Custo | 2 Fé |
| ATK / Vida | 1 / 1 |
| Palavras-chave | Impeto |
| Lendária | não |
| Cópias no deck | 2 |

## Texto da carta
Ímpeto. Ao atacar, causa 1 de dano à Cornucópia inimiga.

## Contexto mitológico
Carta sintética criada para testar o motor de simulação. Não pertence a nenhuma tradição; serve para cobrir o vocabulário da DSL (`docs/dsl_efeitos.md`).

## Papel no jogo
Cobertura de teste: damage, on_attack.

## Balanço
Orçamento P = 2·C+1 = 5 pts. Carta de teste; balanço aproximado.

## Dados
```json
{
  "id": "tst_corredor",
  "nome": "Corredor do Vento",
  "cultura": "teste",
  "tipo": "entidade",
  "custo": 2,
  "atk": 1,
  "vida": 1,
  "lendaria": false,
  "keywords": [
    "impeto"
  ],
  "sacrificio": 0,
  "efeitos": [
    {
      "gatilho": "on_attack",
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
