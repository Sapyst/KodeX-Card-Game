# Santo Graal

| Campo | Valor |
|---|---|
| Cultura | cristianismo |
| Tipo | Relíquia |
| Custo | 2 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
A portadora ganha +0/+2. Ao equipar, cure 4 da sua Cornucópia. Quando a portadora ataca, cure 2 dela.

## Contexto mitológico
O cálice da Última Ceia — "tomou um cálice, deu graças e disse: tomai-o e distribuí-o entre vós" (Lc 22,17-20) — e o *graal* da literatura arturiana são duas tradições que se fundiram. Em Chrétien de Troyes (*Perceval ou le Conte du Graal*, c. 1190) o graal é um prato fundo levado em cortejo no castelo do Rei Pescador, que sustenta o velho rei com uma só hóstia. Robert de Boron (*Joseph d'Arimathie*, c. 1200) o identifica com o cálice da Ceia, no qual José de Arimateia recolheu o sangue de Cristo, e o traz à Bretanha. Daí a *Queste del Saint Graal* (c. 1225), onde só o puro Galaaz consegue contemplá-lo, e Wolfram von Eschenbach, para quem é uma pedra caída do céu.

Em todas as versões o Graal **alimenta e cura**: a mesa do Graal se enche de iguarias, as feridas do Rei Pescador só serão sanadas quando a pergunta certa for feita, Galaaz morre em êxtase ao vê-lo. Várias igrejas reivindicam o objeto — o Santo Cáliz de Valência, o de Génova —, mas o Graal pertence mais à imaginação do que à arqueologia: ele é a fonte que nunca se esgota.

A carta é essa fonte: cura a Cornucópia ao chegar, protege a portadora e a restaura a cada ataque.

## Papel no jogo
Sustentação. Os 4 de Cornucópia ao equipar valem por si; depois disso a portadora ganha 2 de Vida e recupera 2 por ataque, o que a mantém trocando por vários turnos (ideal em Serafim, Leviatã ou Miguel). Boa contra decks agressivos que já baixaram sua Cornucópia; fraca contra remoção dura, que leva Relíquia e portadora juntas. Não cure "por cima": a Vida não passa do máximo.

## Balanço
Orçamento P = 2·C+1 = 5 pts, +1 grátis de Relíquia = 6. Gasto: +2 Vida permanente 2 + curar 4 Cornucópia (2 × "curar 2 = 1") 2 + curar 2 da portadora por ataque (gatilho repetível, valor cheio, sem Usos) 1 = 5. Dentro (faixa 4–6).

## Dados
```json
{
  "id": "cri_santo_graal",
  "nome": "Santo Graal",
  "cultura": "cristianismo",
  "tipo": "reliquia",
  "custo": 2,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_equip", "acoes": [
      { "op": "buff", "alvo": "equipped", "atk": 0, "vida": 2, "perm": true },
      { "op": "heal", "alvo": "ally_cornucopia", "n": 4 } ] },
    { "gatilho": "equipped_attacks", "acoes": [
      { "op": "heal", "alvo": "equipped", "n": 2 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, object focus, holy grail, ancient golden chalice, simple goblet with jeweled rim, chalice overflowing with liquid light, light pouring over the rim, floating above a stone altar, white cloth covering the altar, drops of glowing red wine, bleeding spear leaning nearby, ruined gothic chapel, stone floor, broken stained glass window behind, moonlight, mist, dove feathers floating, golden particles, holy light, gold and white, stained glass light, soft rim lighting, floating, healing glow, centered composition
```

## Prompt Krea 2
Atributos obrigatórios: cálice dourado simples · borda com gemas · luz líquida transbordando · altar com toalha branca · capela gótica em ruínas
```krea
An ancient golden chalice, the Holy Grail, floating just above a stone altar covered with a white cloth, centered in a ruined Gothic chapel. It is a simple wide cup on a short stem, its rim set with small red and green gemstones. Liquid golden light wells up and overflows the rim, spilling down in glowing streams, and a few red drops shine like wine. Behind it, a broken stained-glass window lets in cold moonlight and mist. White dove feathers drift in the air. The chalice is the only subject, glowing with healing light.
```
