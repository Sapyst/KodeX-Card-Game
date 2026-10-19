# Bagua de Fuxi

> **Fora do deck** desde a revisão (ver `../_revisao.md`): com 26 cartas distintas a busca perdeu função; o slot virou a segunda cópia de Taiji. Orçamento 4/5 — candidata a voltar se o deck precisar de consistência.

| Campo | Valor |
|---|---|
| Cultura | taoismo |
| Tipo | Rito |
| Custo | 2 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Busque no seu deck 1 Entidade e 1 Selo e coloque-os na mão. Embaralhe.

## Contexto mitológico
Fuxi (伏羲), primeiro dos Três Augustos, é o inventor da escrita simbólica: "olhou para cima e contemplou as imagens no céu, olhou para baixo e observou os padrões da terra, viu as marcas dos pássaros e dos animais... e então criou os Oito Trigramas, para penetrar a virtude dos espíritos luminosos e classificar a natureza das dez mil coisas" (*Yijing*, "Xici" II.2). Os oito trigramas (*bagua*) — três linhas cada, inteiras (yang) ou partidas (yin) — são Céu, Terra, Trovão, Vento, Água, Fogo, Montanha e Lago; combinados dois a dois, dão os 64 hexagramas do *Yijing*. Fuxi teria também inventado as redes de pesca, a caça e o casamento. Nas lajes das tumbas Han ele aparece com a irmã-esposa Nüwa, ambos de cauda de serpente entrelaçada, ele com o esquadro, ela com o compasso.

O arranjo "do Céu Anterior" (*xiantian*) dos trigramas é atribuído a Fuxi; o "do Céu Posterior", ao rei Wen. Um e outro são a base do *fengshui*, do calendário e do espelho *bagua* que se pendura sobre a porta para refletir influências ruins. Consultar os trigramas (com varetas de milefólio ou moedas) é perguntar ao cosmo o que vem.

A carta é a consulta: você olha o deck e traz o que o oráculo apontou — um Imortal e um talismã.

## Papel no jogo
Consistência para um deck de singletons: busca o Imortal que falta para a sinergia (Lü Dongbin, quase sempre) e o Selo certo para a situação (Fulu de Selamento contra deck de Ritos, Tigre Branco contra agressão). Duas cartas por 2 Fé sem perder qualidade. Lento no turno 2 (nada em campo), excelente no turno 4–5 com Fé sobrando.

## Balanço
Orçamento P = 2·C+1 = 5 pts. Gasto: buscar carta de um tipo (2) + buscar carta de um tipo (2) = 4. Dentro.

## Dados
```json
{
  "id": "tao_bagua_de_fuxi",
  "nome": "Bagua de Fuxi",
  "cultura": "taoismo",
  "tipo": "rito",
  "custo": 2,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [
      { "op": "search", "tipo": "entidade" },
      { "op": "search", "tipo": "selo" } ] }
  ],
  "usos": null
}
```

## Prompt de arte
_(pendente)_
