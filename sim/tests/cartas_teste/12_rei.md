# Rei dos Céus

| Campo | Valor |
|---|---|
| Cultura | teste (sintética) |
| Tipo | Entidade |
| Custo | 7 Fé |
| ATK / Vida | 6 / 7 |
| Palavras-chave | Impeto |
| Lendária | sim |
| Cópias no deck | 1 |

## Texto da carta
Lendária. Ímpeto. Despertar: destrói uma Entidade inimiga.

## Contexto mitológico
Carta sintética criada para testar o motor de simulação. Não pertence a nenhuma tradição; serve para cobrir o vocabulário da DSL (`docs/dsl_efeitos.md`).

## Papel no jogo
Cobertura de teste: destroy, on_play.

## Balanço
Orçamento P = 2·C+1 = 15 pts. Carta de teste; balanço aproximado.

## Dados
```json
{
  "id": "tst_rei",
  "nome": "Rei dos Céus",
  "cultura": "teste",
  "tipo": "entidade",
  "custo": 7,
  "atk": 6,
  "vida": 7,
  "lendaria": true,
  "keywords": [
    "impeto"
  ],
  "sacrificio": 0,
  "efeitos": [
    {
      "gatilho": "on_play",
      "acoes": [
        {
          "op": "destroy",
          "alvo": "enemy_entity"
        }
      ]
    }
  ],
  "usos": null
}
```

## Prompt de arte
_(não se aplica)_
