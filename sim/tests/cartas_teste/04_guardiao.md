# Guardião do Portal

| Campo | Valor |
|---|---|
| Cultura | teste (sintética) |
| Tipo | Entidade |
| Custo | 3 Fé |
| ATK / Vida | 2 / 4 |
| Palavras-chave | Guarda |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Guarda. Sempre que outra Entidade aliada for atacada, causa 1 de dano ao atacante.

## Contexto mitológico
Carta sintética criada para testar o motor de simulação. Não pertence a nenhuma tradição; serve para cobrir o vocabulário da DSL (`docs/dsl_efeitos.md`).

## Papel no jogo
Cobertura de teste: ally_attacked, damage.

## Balanço
Orçamento P = 2·C+1 = 7 pts. Carta de teste; balanço aproximado.

## Dados
```json
{
  "id": "tst_guardiao",
  "nome": "Guardião do Portal",
  "cultura": "teste",
  "tipo": "entidade",
  "custo": 3,
  "atk": 2,
  "vida": 4,
  "lendaria": false,
  "keywords": [
    "guarda"
  ],
  "sacrificio": 0,
  "efeitos": [
    {
      "gatilho": "ally_attacked",
      "acoes": [
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
