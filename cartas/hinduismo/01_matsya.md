# Matsya, o Peixe

| Campo | Valor |
|---|---|
| Cultura | hinduísmo |
| Tipo | Entidade |
| Custo | 1 Fé |
| ATK / Vida | 0 / 1 |
| Palavras-chave | Despertar |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Despertar: busque uma Relíquia do seu deck para a mão.

## Contexto mitológico
Matsya ("peixe") é o primeiro dos dez avatares de Vishnu. Na versão mais antiga (Shatapatha Brahmana 1.8.1), um peixinho pede proteção a Manu, o primeiro homem; Manu o cria num pote, depois num tanque, depois no mar, e o peixe, já imenso, avisa-o do dilúvio que vem e lhe manda construir uma barca. Quando as águas sobem, Manu amarra a barca ao chifre do peixe, que a reboca até a montanha do norte — e a humanidade recomeça dali.

O Bhagavata Purana (8.24) amplia a história: o asura Hayagriva rouba os Vedas da boca de Brahma adormecido, e Vishnu, na forma de Matsya, os recupera do fundo do oceano e os devolve ao criador. É esse segundo motivo — o peixe que *resgata o que é precioso do fundo* — que define a carta.

No deck, Matsya é o avatar mais humilde e o primeiro a descer: corpo mínimo, mas traz do fundo do deck a arma divina de que o jogador precisa.

## Papel no jogo
Abertura de turno 1: não combate, mas garante que Vajra, Sudarshana Chakra, Gandiva ou Trishula apareçam cedo — o deck vive de equipar suas armas em corpos com Ímpeto (Garuda, Hanuman). Também serve de corpo barato para receber Vishvarupa (vira 6/6 com Ímpeto) ou de portador descartável para uma Relíquia equipada no turno 2. Ruim em mão tardia, quando as Relíquias já saíram.

## Balanço
Orçamento P = 2·1+1 = 3 pts. Gasto: ATK 0 + Vida 1 + buscar carta de um tipo (search) = 2 pts → total 3. Dentro.

## Dados
```json
{
  "id": "hin_matsya",
  "nome": "Matsya, o Peixe",
  "cultura": "hinduismo",
  "tipo": "entidade",
  "custo": 1,
  "atk": 0,
  "vida": 1,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [ { "op": "search", "tipo": "reliquia" } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, animal focus, colossal golden fish, giant carp, fish only, horned fish, single horn on head, small golden crown, shining golden scales, long flowing fins, flowing tail, glowing eyes, golden scroll in mouth, swimming upward, side view, deep dark ocean, underwater, rays of light from above, bubbles, floating lotus petals, saffron and blue, glowing scales, rim lighting, majestic, full body
```

## Prompt Krea 2
Atributos obrigatórios: peixe gigante dourado · um único chifre na cabeça · pergaminho dos Vedas na boca · fundo do oceano com raios de luz
```krea
A colossal golden fish, the Matsya avatar, a huge carp-like fish with no human parts. A single straight horn grows from the top of his head, exactly one horn, and a small golden crown sits behind it. His scales shine like hammered gold, his long fins and tail flow like silk. He holds a rolled palm-leaf scroll of the Vedas tied with red cord gently in his mouth. He swims upward out of the black depths of a deep ocean, seen from the side, bubbles trailing behind him. One strong shaft of pale divine light falls from the surface far above and lights his golden body.
```
