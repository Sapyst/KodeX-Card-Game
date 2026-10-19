# Armadilha de Espinhos

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
Quando uma Entidade inimiga atacar, o atacante leva 3 de dano.

## Contexto mitológico
Carta sintética criada para testar o motor de simulação. Não pertence a nenhuma tradição; serve para cobrir o vocabulário da DSL (`docs/dsl_efeitos.md`).

## Papel no jogo
Cobertura de teste: damage, enemy_attacks.

## Balanço
Orçamento P = 2·C+1 = 5 pts. Carta de teste; balanço aproximado.

## Dados
```json
{
  "id": "tst_armadilha",
  "nome": "Armadilha de Espinhos",
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
      "gatilho": "enemy_attacks",
      "acoes": [
        {
          "op": "damage",
          "alvo": "attacker",
          "n": 3
        }
      ]
    }
  ],
  "usos": null
}
```

## Prompt de arte
_(não se aplica)_
