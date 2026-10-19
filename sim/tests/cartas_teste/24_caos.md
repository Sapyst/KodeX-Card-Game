# Possessão

| Campo | Valor |
|---|---|
| Cultura | teste (sintética) |
| Tipo | Rito |
| Custo | 3 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Rouba uma Entidade inimiga até o fim do turno.

## Contexto mitológico
Carta sintética criada para testar o motor de simulação. Não pertence a nenhuma tradição; serve para cobrir o vocabulário da DSL (`docs/dsl_efeitos.md`).

## Papel no jogo
Cobertura de teste: on_play, swap_control.

## Balanço
Orçamento P = 2·C+1 = 7 pts. Carta de teste; balanço aproximado.

## Dados
```json
{
  "id": "tst_caos",
  "nome": "Possessão",
  "cultura": "teste",
  "tipo": "rito",
  "custo": 3,
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
          "op": "swap_control",
          "alvo": "enemy_entity",
          "perm": false
        }
      ]
    }
  ],
  "usos": null
}
```

## Prompt de arte
_(não se aplica)_
