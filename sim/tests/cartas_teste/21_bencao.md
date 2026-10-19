# Bênção da Guerra

| Campo | Valor |
|---|---|
| Cultura | teste (sintética) |
| Tipo | Rito |
| Custo | 1 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Uma Entidade aliada ganha +2 ATK até o fim do turno e Ímpeto.

## Contexto mitológico
Carta sintética criada para testar o motor de simulação. Não pertence a nenhuma tradição; serve para cobrir o vocabulário da DSL (`docs/dsl_efeitos.md`).

## Papel no jogo
Cobertura de teste: buff, give_keyword, on_play.

## Balanço
Orçamento P = 2·C+1 = 3 pts. Carta de teste; balanço aproximado.

## Dados
```json
{
  "id": "tst_bencao",
  "nome": "Bênção da Guerra",
  "cultura": "teste",
  "tipo": "rito",
  "custo": 1,
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
          "op": "buff",
          "alvo": "ally_entity",
          "atk": 2,
          "vida": 0,
          "perm": false
        },
        {
          "op": "give_keyword",
          "alvo": "ally_entity",
          "keyword": "impeto"
        }
      ]
    }
  ],
  "usos": null
}
```

## Prompt de arte
_(não se aplica)_
