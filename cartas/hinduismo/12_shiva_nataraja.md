# Shiva Nataraja

| Campo | Valor |
|---|---|
| Cultura | hinduísmo |
| Tipo | Entidade |
| Custo | 7 Fé |
| ATK / Vida | 5 / 5 |
| Palavras-chave | Ímpeto, Despertar, Lendária |
| Lendária | sim |
| Cópias no deck | 1 |

## Texto da carta
Ímpeto. Despertar: destrua uma Entidade inimiga.

## Contexto mitológico
Shiva é o terceiro da Trimurti, o deus que dissolve o universo no fim de cada ciclo para que ele possa ser criado de novo — destruição como transformação. Herda o Rudra do Rigveda (2.33), o arqueiro temível das montanhas, e nos Puranas e no Shvetashvatara Upanishad torna-se Mahadeva, o grande deus: asceta de Kailash coberto de cinzas, com a lua na cabeleira, o Ganges caindo pelos cabelos, a serpente Vasuki ao pescoço, o terceiro olho que incinera o que fixa, o tridente Trishula e o tambor damaru. Bebe o veneno Halahala que ameaçava os mundos no batimento do oceano e fica de garganta azul, Neelakantha.

Nataraja, "rei da dança", é sua forma mais célebre, consagrada nos bronzes Chola de Chidambaram (séc. X–XII): Shiva dança o Ananda Tandava dentro de um círculo de fogo, uma mão com o damaru (o som que cria), outra com a chama (que destrói), um pé esmagando o demônio-anão Apasmara (a ignorância), o outro erguido em libertação. Em sua forma furiosa, o Rudra Tandava, a dança desfaz o universo.

A carta é a chegada de Nataraja: ele entra dançando (Ímpeto) e a primeira coisa que seu pé toca deixa de existir.

## Papel no jogo
A Lendária de topo e o fecho do deck: destrói o maior problema do oponente e ataca por 5 no mesmo turno. Resolve qualquer Guarda e, com o campo limpo pelo Despertar de Kali ou por Tandava, pode atacar a Cornucópia direto. Com Descida do Avatar, volta do cemitério por 3 Fé — mas só como corpo: reviver para o campo não dispara Despertar (regras §8). Equipado com Trishula vira 8/6 que fere mais um alvo por ataque. Fraco: 7 Fé é turno 7; contra decks que anulam Entidades ao entrar (Selo `enemy_plays_entity` com counter) é a maior perda possível.

## Balanço
Orçamento P = 2·7+1 = 15 pts (+2 Lendária = 17). Gasto: ATK 5 + Vida 5 + Ímpeto 1 + destruir Entidade inimiga escolhida 5 = 16. Lendária +1.
Rodada 1 de balanceamento: era 6/6 (com `destroy` a 5 pts somava 18, acima do teto lendário; 87 % de WR global, 72 % no espelho).
Rodada 3 de balanceamento: 5/6 → 5/5. Depois dos pacotes da rodada 2 o resto do deck baixou e Shiva ficou como a única carta destoante no espelho (60 % de WR comprada, 68 % jogada); é o único corte que sobra nele sem tocar no Ímpeto.

## Dados
```json
{
  "id": "hin_shiva_nataraja",
  "nome": "Shiva Nataraja",
  "cultura": "hinduismo",
  "tipo": "entidade",
  "custo": 7,
  "atk": 5,
  "vida": 5,
  "lendaria": true,
  "keywords": ["impeto"],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [ { "op": "destroy", "alvo": "enemy_entity" } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1boy, solo, adult man, dancing god, blue-grey skin, four arms, third eye, long matted hair flying outward, crescent moon in hair, serpent around neck, damaru drum in upper right hand, flame in upper left hand, tiger skin loincloth, standing on right leg, left leg raised across body, dancing, ring of fire around him, circle of flames, dark cosmic void, stars, saffron and blue, fire glow, embers, rim lighting, full body
```

## Prompt Krea 2
Atributos obrigatórios: pele azul-acinzentada · exatamente quatro braços com damaru e chama · terceiro olho · em pé sobre a perna direita, esquerda erguida · anel de fogo
```krea
Manter o prompt atual e acrescentar: 'His standing foot is planted on the middle of the back of one single small dwarf lying flat on his belly on the ground, directly under that foot.' Como o modelo espelha a pose em todas as tentativas, o mais prático é espelhar na horizontal a imagem aprovada. O damaru passa para a mão esquerda de cima, o que a ficha não proíbe.
```
