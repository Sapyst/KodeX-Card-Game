# Eco Hostil

| Campo | Valor |
|---|---|
| Cultura | teste (sintética) |
| Tipo | Selo |
| Custo | 3 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Quando o oponente invocar uma Entidade, ela leva 2 de dano.

## Contexto mitológico
Carta sintética criada para testar o motor de simulação. Não pertence a nenhuma tradição; serve para cobrir o vocabulário da DSL (`docs/dsl_efeitos.md`).

## Papel no jogo
Cobertura de teste: damage, enemy_plays_entity.

## Balanço
Orçamento P = 2·C+1 = 7 pts. Carta de teste; balanço aproximado.

## Dados
```json
{
  "id": "tst_eco",
  "nome": "Eco Hostil",
  "cultura": "teste",
  "tipo": "selo",
  "custo": 3,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    {
      "gatilho": "enemy_plays_entity",
      "acoes": [
        {
          "op": "damage",
          "alvo": "triggering",
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
