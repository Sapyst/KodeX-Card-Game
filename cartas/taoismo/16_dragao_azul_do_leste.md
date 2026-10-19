# Dragão Azul do Leste

| Campo | Valor |
|---|---|
| Cultura | taoismo |
| Tipo | Selo |
| Custo | 2 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
No fim do turno do oponente: todas as suas Entidades ganham +1/+1 permanente.

## Contexto mitológico
Qinglong (青龍), o Dragão Azul (ou Verde-Azulado) do Leste, é o primeiro dos Quatro Símbolos (*Sixiang*), as quatro criaturas que dividem o céu chinês em quadrantes de sete mansões lunares cada. O *Liji* ("Quli") prescreve a formação de marcha: "à frente o Pássaro Vermelho, atrás a Tartaruga Negra, à esquerda o Dragão Azul, à direita o Tigre Branco" — isto é, os estandartes do exército repetem o mapa do céu. O *Shiji* ("Tianguan shu", de Sima Qian) e o *Huainanzi* ("Tianwen") fixam as correspondências: leste, primavera, madeira, a cor azul-verde, o yang que nasce.

O dragão do leste é por isso o símbolo do crescimento: a seiva que sobe, a chuva de primavera, o imperador (que se senta voltado para o sul, com o leste à esquerda, o lado do dragão). Nos tijolos de tumbas Han e nos espelhos TLV, Qinglong aparece sinuoso e com chifres, o corpo em S. No taoismo religioso os quatro são guardiões do altar e das portas do templo, e Qinglong guarda a entrada do leste junto com Baihu.

Como Selo-guardião, o Dragão Azul não ataca: faz a primavera chegar. Quando o turno inimigo termina, tudo que é seu cresceu.

## Papel no jogo
O Selo mais seguro do deck: `enemy_end_turn` sempre acontece, então ele resolve no turno seguinte ao que foi colocado, com a mesa que você tiver. Com três ou quatro Imortais em campo é +3/+3 ou +4/+4 em estatísticas permanentes por 2 Fé. O timing é a arte: colocar quando a mesa está cheia, não vazia. Não protege contra nada no turno inimigo — é um Selo de yang, de crescimento; o Tigre é o de punição.

## Balanço
Orçamento P = 2·C+1 = 5 pts, +1 grátis de Selo = 6. Gasto: +1 ATK e +1 Vida permanentes em todas as aliadas = (1 + 1) × 3 = 6. Dentro.

## Dados
```json
{
  "id": "tao_dragao_azul_do_leste",
  "nome": "Dragão Azul do Leste",
  "cultura": "taoismo",
  "tipo": "selo",
  "custo": 2,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "enemy_end_turn", "acoes": [ { "op": "buff", "alvo": "all_ally_entities", "atk": 1, "vida": 1, "perm": true } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, azure dragon, chinese dragon, serpentine body, blue-green scales, antlers, flowing mane, long whiskers, coiling in s shape, rising from clouds, spring rain, blooming trees, misty mountains, dawn, eastern horizon, glowing green aura, jade green and vermilion, mist, ink wash feel, teal glow, glowing eyes, pearl in claw, pine trees, wet rocks, full body
```

## Prompt Krea 2
Atributos obrigatórios: dragão chinês serpentino azul-esverdeado · chifres de cervo · corpo em S · pérola na garra · chuva de primavera ao amanhecer
```krea
A Chinese azure dragon, the Blue Dragon of the East, with no people present. Its long serpentine body is covered in blue-green scales and coils in an S shape as it rises from clouds. It has deer-like antlers, a flowing mane, long whiskers and four legs with clawed feet; one front claw holds a glowing pearl. It guards a misty mountain valley with blooming trees and pines under a gentle spring rain, lit by the dawn glow on the eastern horizon and a teal aura.
```
