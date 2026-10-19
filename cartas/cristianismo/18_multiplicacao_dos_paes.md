# Multiplicação dos Pães

| Campo | Valor |
|---|---|
| Cultura | cristianismo |
| Tipo | Rito |
| Custo | 2 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Compre 2 cartas. Cure 2 da sua Cornucópia.

## Contexto mitológico
É o único milagre narrado pelos quatro evangelhos (Mt 14,13-21; Mc 6,30-44; Lc 9,10-17; Jo 6,1-14). Uma multidão segue Jesus a um lugar deserto; ao entardecer os discípulos querem despedi-la para que compre comida. Há só cinco pães de cevada e dois peixes — em João, trazidos por um menino. Jesus manda sentar o povo na relva em grupos, ergue os olhos, abençoa, parte e distribui. "Todos comeram e ficaram saciados, e recolheram doze cestos cheios dos pedaços que sobraram" — para cerca de cinco mil homens, sem contar mulheres e crianças.

O episódio ecoa o maná do deserto (Ex 16) e os vinte pães de Eliseu para cem homens (2Rs 4,42-44), e a Igreja primitiva o leu como figura da Eucaristia: os afrescos das catacumbas e os mosaicos de Tabgha, na Galileia, mostram os pães e os peixes num cesto. A carta mostra os doze cestos de sobra — a abundância que fica depois que todos comeram.

Como **Rito**, é abundância em duas moedas: cartas na mão e Vida na Cornucópia.

## Papel no jogo
A principal compra do deck. Dois por 2 Fé, com uma cura pequena de bônus, recarrega a mão depois de uma troca de Ritos e procura as peças de ressurreição. Jogue quando a mão estiver com ≤ 3 cartas; não deixe para quando a mão estiver em 7 (o excesso é descartado). Sem sinergia especial além de alimentar Gabriel-busca e manter Talita Cumi disponível.

## Balanço
Orçamento P = 2·C+1 = 5 pts. Gasto: comprar 2 cartas (1,5 × 2) = 3 + curar 2 Cornucópia 1 = 4. Dentro.

## Dados
```json
{
  "id": "cri_multiplicacao_dos_paes",
  "nome": "Multiplicação dos Pães",
  "cultura": "cristianismo",
  "tipo": "rito",
  "custo": 2,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [
      { "op": "draw", "n": 2 },
      { "op": "heal", "alvo": "ally_cornucopia", "n": 2 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, object focus, centered composition, still life, close-up, large wicker basket overflowing with round barley bread loaves, two fish lying on top of the bread, fish scales glinting, more baskets of bread around it, loaves glowing softly, green grassy hillside, wild flowers, sea of galilee at sunset in background, distant crowd silhouettes seated on grass, miracle of abundance, holy light from above, golden particles, gold and white, warm golden hour light, soft rim lighting
```

## Prompt Krea 2
Atributos obrigatórios: cesto de vime transbordando · pães redondos de cevada · dois peixes sobre os pães · doze cestos no total · mar da Galileia ao pôr do sol
```krea
A large wicker basket overflowing with round flat barley loaves sits on a green grassy hillside, with two silver fish lying on top of the bread, at the very moment of the miracle of multiplication. The loaves glow softly and new loaves keep appearing at the rim and spilling over. Eleven more full baskets stand in a curving row behind it, twelve baskets in total. Beyond them the Sea of Galilee shines at sunset, and a distant crowd sits in small groups on the grass as tiny silhouettes. Warm golden light falls from the sky onto the central basket.
```
