# Raio Divino

| Campo | Valor |
|---|---|
| Cultura | teste (sintética) |
| Tipo | Rito |
| Custo | 2 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Causa 4 de dano a uma Entidade inimiga.

## Contexto mitológico
Carta sintética criada para testar o motor de simulação. Não pertence a nenhuma tradição; serve para cobrir o vocabulário da DSL (`docs/dsl_efeitos.md`).

## Papel no jogo
Cobertura de teste: damage, on_play.

## Balanço
Orçamento P = 2·C+1 = 5 pts. Carta de teste; balanço aproximado.

## Dados
```json
{
  "id": "tst_raio",
  "nome": "Raio Divino",
  "cultura": "teste",
  "tipo": "rito",
  "custo": 2,
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
          "alvo": "enemy_entity",
          "n": 4
        }
      ]
    }
  ],
  "usos": null
}
```

## Prompt de arte
_(não se aplica)_
