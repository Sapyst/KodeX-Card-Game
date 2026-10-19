# Jatayu

| Campo | Valor |
|---|---|
| Cultura | hinduísmo |
| Tipo | Entidade |
| Custo | 2 Fé |
| ATK / Vida | 1 / 1 |
| Palavras-chave | Ímpeto, Último Sopro |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Ímpeto. Último Sopro: compre 1 carta.

## Contexto mitológico
Jatayu é o rei dos abutres do Ramayana, velho amigo do rei Dasharatha, pai de Rama. No Aranya Kanda, quando Ravana sobrevoa a floresta de Dandaka levando Sita raptada em seu carro voador, Jatayu é o único a enfrentá-lo: ataca o carro, quebra o arco e mata as mulas, e por um instante força o rei de Lanka a descer. Ravana então saca a espada e corta-lhe as asas.

Rama e Lakshmana encontram o pássaro agonizando. Antes de morrer, Jatayu conta o que viu — quem levou Sita e para que lado — e é esse último sopro que dá rumo à busca de Rama. Rama realiza para ele os ritos funerários como faria para o próprio pai.

A carta traduz a história literalmente: um corpo frágil que ataca de imediato e, ao morrer, entrega informação ao jogador.

## Papel no jogo
Ataque de turno 2 com baixo compromisso: troca com um corpo pequeno ou força o oponente a gastar uma ação, e repõe a carta ao morrer. É o alvo preferido para "morrer de propósito" na Roda do Samsara e um portador aceitável de Vajra quando se quer só o dano do raio. Fraco contra Guarda grande.

## Balanço
Orçamento P = 2·2+1 = 5 pts. Gasto: ATK 1 + Vida 1 + Ímpeto 1 + comprar 1 carta 1,5 = 4,5. Dentro.

## Dados
```json
{
  "id": "hin_jatayu",
  "nome": "Jatayu",
  "cultura": "hinduismo",
  "tipo": "entidade",
  "custo": 2,
  "atk": 1,
  "vida": 1,
  "lendaria": false,
  "keywords": ["impeto"],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_death", "acoes": [ { "op": "draw", "n": 1 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, giant old vulture, king of vultures, ragged grey and brown feathers, bald wrinkled head, hooked beak, white neck ruff, small golden crown, wings spread wide, huge wingspan, swooping attack, talons forward, falling feathers, fierce eyes, dense forest canopy below, dusk sky, dark storm clouds, saffron and blue, orange sunset glow, rim lighting, dramatic shadows, low angle, full body
```

## Prompt Krea 2
Atributos obrigatórios: abutre velho e enorme · penas cinzentas esfarrapadas · cabeça calva enrugada · pequena coroa dourada · ataque em mergulho com garras
```krea
Jatayu, an enormous old vulture king, a real bird with no human features. His head and neck are bald, wrinkled and pale pink, framed by a ruff of white feathers, with a heavy hooked beak and fierce amber eyes. His ragged grey and brown feathers are worn with age, and a small simple golden crown sits on his head. His two huge wings are spread fully open as he swoops down to attack, both talons thrust forward, loose feathers falling around him. Below him is the dark canopy of a dense forest. Behind him a low orange sunset glows under black storm clouds.
```
