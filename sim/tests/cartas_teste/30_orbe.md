# Orbe Faiscante

| Campo | Valor |
|---|---|
| Cultura | teste (sintética) |
| Tipo | Relíquia |
| Custo | 1 Fé |
| ATK / Vida | — |
| Palavras-chave | Usos 2 |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Usos 2. Quando a portadora ataca, 1 de dano a uma Entidade inimiga aleatória.

## Contexto mitológico
Carta sintética criada para testar o motor de simulação. Não pertence a nenhuma tradição; serve para cobrir o vocabulário da DSL (`docs/dsl_efeitos.md`).

## Papel no jogo
Cobertura de teste: damage, equipped_attacks.

## Balanço
Orçamento P = 2·C+1 = 3 pts. Carta de teste; balanço aproximado.

## Dados
```json
{
  "id": "tst_orbe",
  "nome": "Orbe Faiscante",
  "cultura": "teste",
  "tipo": "reliquia",
  "custo": 1,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    {
      "gatilho": "equipped_attacks",
      "acoes": [
        {
          "op": "damage",
          "alvo": "enemy_entity_random",
          "n": 1
        }
      ]
    }
  ],
  "usos": 2
}
```

## Prompt de arte
_(não se aplica)_
