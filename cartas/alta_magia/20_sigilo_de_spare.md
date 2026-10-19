# Sigilo de Spare

| Campo | Valor |
|---|---|
| Cultura | alta magia |
| Tipo | Selo |
| Custo | 1 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
No fim do turno do oponente, ele descarta 1 carta aleatória da mão e você compra 1 carta.

## Contexto mitológico
Austin Osman Spare (1886–1956), artista londrino que a imprensa chamou de "o novo Beardsley" aos dezoito anos, abandonou as galerias para desenvolver uma magia pessoal, descrita em *The Book of Pleasure (Self-Love): The Psychology of Ecstasy* (1913). Seu método — a **sigilização** — tornou-se a técnica mais influente da magia moderna: escreve-se o desejo numa frase, eliminam-se as letras repetidas, condensam-se as restantes num glifo abstrato, carrega-se o glifo num momento de exaustão ou êxtase (o "vazio", a *death posture*) e, essencial, **esquece-se o desejo**, para que trabalhe no subconsciente sem a interferência da mente consciente. O sigilo não age na hora: fica guardado e dispara sozinho, mais tarde, quando a mente desatenta lhe dá passagem.

Spare rejeitava a parafernália cerimonial de Crowley — que o admitiu na A∴A∴ como *Probationer* em 1909 e o perdeu logo depois; Spare ridicularizou os rituais e Crowley chamou-o de "Black Brother". Para Spare, o grimório inteiro cabe num traço. O "alfabeto do desejo", a cosmologia Zos/Kia (o corpo-mente e o vazio) e os "atavismos" herdados da bruxa Mrs. Paterson completam o sistema, mais tarde adotado pela magia do caos dos anos 1970 (Carroll, *Liber Null*).

A carta deixou de ser Rito para ser **Selo** justamente por isso: um sigilo é traçado, carregado e esquecido — fica virado para baixo até o momento em que o oponente baixa a guarda (fim do turno dele) e então algo sai da mente dele sem que saiba o quê. O esquecimento é dele; a lembrança (a carta comprada) é sua.

## Papel no jogo
Descarte barato e atrasado: colocado no turno 1 ou 2, dispara no fim do turno seguinte do oponente, quando a mão dele ainda está cheia e cada carta vale mais. Reduz a chance de ele ter a resposta na mão quando o pacto (Astaroth, Dantalion) chegar. Aleatório, então não é confiável — por isso só uma cópia. Ocupa um dos 2 slots de Selo por um turno: não o coloque se precisar de Pentagrama Flamejante e Selo de Salomão ao mesmo tempo.

## Balanço
Orçamento P = 2·1+1 = 3 pts + 1 (Selo) = 4. Gasto: oponente descarta 1 carta aleatória (2) + comprar 1 (1,5) = 3,5. Dentro.

## Dados
```json
{
  "id": "alt_sigilo_de_spare",
  "nome": "Sigilo de Spare",
  "cultura": "alta_magia",
  "tipo": "selo",
  "custo": 1,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "enemy_end_turn", "acoes": [
      { "op": "discard", "alvo": "enemy_hand_random", "n": 1 },
      { "op": "draw", "n": 1 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, object focus, close-up, single scrap of parchment pinned to a wooden wall, one abstract symbol of tangled black ink lines, symbol glowing faintly red, torn paper scraps drifting down, playing cards falling from a table edge, dead candle, dusty victorian study, cobwebs, ink stains, wooden panel wall, black and gold, dim red candlelight, dust particles, dramatic shadows, dark scene
```

## Prompt Krea 2
Atributos obrigatórios: um único pedaço de pergaminho pregado numa parede de madeira · glifo abstrato de linhas de tinta preta emaranhadas, brilho vermelho fraco · cartas de baralho caindo da mesa · vela apagada
```krea
A single torn scrap of old parchment is pinned with a nail to a dark wooden wall in a dusty Victorian study. On it is one abstract sigil made of tangled, looping black ink lines, glowing faintly red as if quietly charged. Below it, a few playing cards slide off the edge of a wooden table and fall through the air, and small torn paper scraps drift down. A candle on the table has just gone out, a thin thread of smoke rising from the wick. Cobwebs and ink stains. The dim red glow of the sigil is the main light.
```
