# Elias, Carro de Fogo

| Campo | Valor |
|---|---|
| Cultura | cristianismo |
| Tipo | Entidade |
| Custo | 6 Fé |
| ATK / Vida | 4 / 5 |
| Palavras-chave | Renascer, Despertar, Lendária |
| Lendária | sim |
| Cópias no deck | 1 |

## Texto da carta
Renascer. Despertar: Cause 2 de dano a todas as Entidades inimigas.

## Contexto mitológico
Elias, o tesbita, surge sem genealogia em 1 Reis 17 anunciando seca ao rei Acab. Alimentado por corvos junto à torrente de Carit, hospeda-se com a viúva de Sarepta, cuja farinha e azeite não acabam; quando o filho dela morre, Elias se estende três vezes sobre o menino e o devolve vivo à mãe — a primeira ressurreição narrada na Bíblia (1Rs 17,17-24). No Monte Carmelo desafia 450 profetas de Baal: o fogo do Senhor desce e consome o holocausto, a lenha, as pedras e a água da vala (1Rs 18,38). Duas vezes mais, fogo do céu consome os cinquenta soldados enviados para prendê-lo (2Rs 1,10-12).

Elias não morre. "Eis que um carro de fogo com cavalos de fogo os separou, e Elias subiu ao céu num redemoinho" (2Rs 2,11). Por isso Malaquias promete sua volta "antes do grande e terrível dia do Senhor" (Ml 3,23), e por isso ele está com Moisés na Transfiguração (Mt 17,3). Na tradição judaica tem uma cadeira na circuncisão e uma taça na Páscoa; na cristã é o modelo dos eremitas e padroeiro dos carmelitas.

A carta reúne os três traços: o fogo que desce quando ele chega (**Despertar** em área), o homem que não fica morto (**Renascer**), e o peso de Lendária de quem precede o Juízo.

## Papel no jogo
Primeira Lendária: um 4/5 que limpa o campo inimigo de pequenos ao entrar e volta para a mão se morrer — para entrar de novo e queimar de novo. É a carta que pune decks de muitos corpos pequenos. Com Juízo Final, vai e volta junto com Lázaro. O Véu de Verônica não lhe dá um segundo Renascer (palavras-chave não acumulam); prefira a Arca ou o Graal nele. Cuidado: 6 Fé e um Renascer significam que ele pode ser reinvocado só no turno seguinte — o oponente tem uma janela.

## Balanço
Orçamento P = 2·C+1 = 13 pts; Lendária pode passar até +2 → 15. Gasto: ATK 4 + Vida 5 + Renascer 2 + 2 de dano a todas as inimigas (1,5 × 2) = 3 → 14. Lendária +1.
Rodada 1 de balanceamento: era 4/6 (P+2; 78 % de WR global) — com 5 de Vida morre para um golpe de 5 e ainda volta à mão.

## Dados
```json
{
  "id": "cri_elias",
  "nome": "Elias, Carro de Fogo",
  "cultura": "cristianismo",
  "tipo": "entidade",
  "custo": 6,
  "atk": 4,
  "vida": 5,
  "lendaria": true,
  "keywords": ["renascer"],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [ { "op": "damage", "alvo": "all_enemy_entities", "n": 2 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1boy, solo, old prophet, long white hair, long white beard, hairy brown mantle, standing in two-wheeled chariot of fire, flaming chariot, two horses made of fire, fire horses galloping upward, chariot rising into sky, whirlwind, arm raised to heaven, fire raining from clouds, judean hills far below, night sky, orange flames, embers, holy light, fiery orange and gold, strong rim lighting, side view, full body, wide shot
```

## Prompt Krea 2
Atributos obrigatórios: idoso de cabelo e barba brancos · manto de pele de carneiro · cinto de couro · carro de fogo de duas rodas · dois cavalos de fogo
```krea
An elderly Middle Eastern Hebrew man about 70 years old, the prophet Elijah, with long white hair and a long white beard, standing in a two-wheeled chariot made of fire that rises into the night sky. He wears a rough knee-length tunic and a hairy brown sheepskin mantle over his shoulders, with a wide leather belt around his waist. His right arm is raised to heaven and his left hand grips the chariot rail. Two horses made entirely of living flame pull the chariot upward inside a spiraling whirlwind. Fire rains down from the clouds onto the dark Judean hills far below, all lit by strong orange firelight.
```
