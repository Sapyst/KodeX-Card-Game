# Funda de Davi

| Campo | Valor |
|---|---|
| Cultura | cristianismo |
| Tipo | Relíquia |
| Custo | 1 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
A portadora ganha +2 ATK e Ímpeto. Sempre que ela atacar, cause 1 de dano a uma Entidade inimiga.

## Contexto mitológico
"Tomou o seu cajado na mão, escolheu para si cinco pedras lisas do ribeiro e pô-las no alforje de pastor que trazia, e, com a funda na mão, foi-se aproximando do filisteu" (1Sm 17,40). Golias zomba do menino sem armadura; Davi responde que vem "em nome do Senhor dos Exércitos". "Davi meteu a mão no alforje, tomou dali uma pedra, atirou-a com a funda e feriu o filisteu na testa; a pedra cravou-se-lhe na testa, e ele caiu com o rosto em terra" (1Sm 17,49). Só então Davi corre, toma a espada do gigante e lhe corta a cabeça.

A funda de pastor — duas cordas e uma bolsa de couro — era arma séria no Antigo Oriente; os fundeiros de Benjamim "acertavam um fio de cabelo" (Jz 20,16), e o vento da pedra girada é o som da coragem do pequeno contra o grande. Na escultura ela está na mão esquerda do *David* de Michelangelo, descansando no ombro, e na mão do *David* de Bernini no instante do arremesso.

A carta dá à portadora a vantagem de Davi: ela ataca **antes** de ser atacada (Ímpeto), bate mais forte, e a pedra fere alguém à escolha ao ser arremessada.

## Papel no jogo
A abertura ofensiva do deck, por 1 Fé. Numa Entidade recém-invocada permite atacar no mesmo turno — útil em Judite (destrói e já bate) e em Lázaro ou Jonas (Renascer protege o investimento). O 1 de dano por ataque, somado aos 2 do próprio Davi se ele for a portadora, retira bloqueadores de Vida baixa. Morre com a portadora, então prefira corpos com Renascer ou Guarda. Fraca em Entidades que não vão atacar (Anjo da Guarda).

## Balanço
Orçamento P = 2·C+1 = 3 pts, +1 grátis de Relíquia = 4. Gasto: +2 ATK permanente 2 + Ímpeto 1 + 1 de dano a Entidade escolhida por ataque (gatilho repetível, valor cheio, sem Usos) 1 = 4. Dentro. Ponto de observação: em Davi, soma 3 de dano direcionado por ataque (2 dele + 1 da Funda) num corpo 3/2 com Ímpeto por 3 Fé totais.

## Dados
```json
{
  "id": "cri_funda_de_davi",
  "nome": "Funda de Davi",
  "cultura": "cristianismo",
  "tipo": "reliquia",
  "custo": 1,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_equip", "acoes": [
      { "op": "buff", "alvo": "equipped", "atk": 2, "vida": 0, "perm": true },
      { "op": "give_keyword", "alvo": "equipped", "keyword": "impeto" } ] },
    { "gatilho": "equipped_attacks", "acoes": [
      { "op": "damage", "alvo": "enemy_entity", "n": 1 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, object focus, centered composition, still life, leather shepherd's sling, weapon, two long braided leather cords, small leather pouch in the middle, smooth round river stone in the pouch, sling hanging in mid-air, five smooth stones on the ground, shepherd's leather bag, dry riverbed, judean valley at dusk, glowing stone, golden particles, holy light on the stone, warm golden light, rim lighting, simple, dark background
```

## Prompt Krea 2
Atributos obrigatórios: duas cordas de couro trançado · bolsa de couro no centro · pedra lisa brilhando · cinco pedras no total · alforje de pastor
```krea
A shepherd's leather sling hanging in mid-air as a sacred relic: two long braided leather cords joined by a small cupped leather pouch in the middle, holding one smooth round river stone that glows with golden light. Below it, four more smooth stones lie on the dry riverbed, five stones in total, beside a worn leather shepherd's bag. The Valley of Elah fades into dusk behind. A warm beam of golden light falls on the glowing stone, and small golden sparks float around the sling. The sling is the only subject, centered in the image.
```
