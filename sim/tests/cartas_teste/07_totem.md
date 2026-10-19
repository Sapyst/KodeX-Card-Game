# Totem Ancestral

| Campo | Valor |
|---|---|
| Cultura | teste (sintética) |
| Tipo | Entidade |
| Custo | 4 Fé |
| ATK / Vida | 1 / 5 |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Suas outras Entidades têm +1 ATK.

## Contexto mitológico
Carta sintética criada para testar o motor de simulação. Não pertence a nenhuma tradição; serve para cobrir o vocabulário da DSL (`docs/dsl_efeitos.md`).

## Papel no jogo
Cobertura de teste: buff, static.

## Balanço
Orçamento P = 2·C+1 = 9 pts. Carta de teste; balanço aproximado.

## Dados
```json
{
  "id": "tst_totem",
  "nome": "Totem Ancestral",
  "cultura": "teste",
  "tipo": "entidade",
  "custo": 4,
  "atk": 1,
  "vida": 5,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    {
      "gatilho": "static",
      "acoes": [
        {
          "op": "buff",
          "alvo": "all_ally_entities",
          "atk": 1,
          "vida": 0,
          "perm": true
        }
      ]
    }
  ],
  "usos": null
}
```

## Prompt de arte
_(não se aplica)_
