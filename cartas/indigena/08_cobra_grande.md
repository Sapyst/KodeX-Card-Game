# Cobra-Grande

| Campo | Valor |
|---|---|
| Cultura | indígena brasileira |
| Tipo | Entidade |
| Custo | 6 Fé |
| ATK / Vida | 5 / 6 |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Sempre que uma Entidade inimiga morrer, esta ganha +1/+1.

## Contexto mitológico
A Cobra-Grande, *Boiúna* ou *Mboiúna* ("cobra preta" em tupi), é a serpente colossal dos rios amazônicos: com os olhos acesos como faróis, vira barco iluminado, afunda canoas, abre igarapés com o corpo e vive no fundo dos lagos. Barbosa Rodrigues (*Poranduba Amazonense*, 1890) e Cascudo (*Geografia dos Mitos Brasileiros*) a situam no centro do imaginário ribeirinho do Pará e do Amazonas: toda cidade grande, dizem, tem uma Cobra-Grande dormindo embaixo da igreja.

O ciclo mais conhecido é o de **Honorato (Norato) e Maria Caninana**, gêmeos filhos de uma indígena que foi engravidada pela cobra; Maria é má e Honorato bom, e Honorato se desencanta quando um soldado tem coragem de derramar leite na sua boca de serpente e feri-lo. Raul Bopp fez do mito o poema *Cobra Norato* (1931), marco do modernismo.

A carta a mostra como a devoradora dos rios: cada Entidade inimiga que morre a alimenta — ela engole o que cai na água.

## Papel no jogo
Finalizador que cresce: entra 5/6 e, a cada inimiga que o deck mata (contragolpes de Curupira, Boitatá e Mapinguari, Fogo de Monan, bloqueios), ganha +1/+1 permanente. Em partida longa passa Tupã em corpo. Com Ibirapema (+2 ATK, Ímpeto) ataca no turno em que entra. Sem Guarda, deixa Boitatá segurar e ataca por cima. Vulnerável à Iara inimiga ou a qualquer `bounce`, que apaga o crescimento.

## Balanço
Orçamento P = 2·6+1 = 13 pts. Gasto (tabela §10): ATK 5 + Vida 6 + `enemy_dies` → +1 ATK perm (1) + +1 Vida perm (1) = 2 (gatilho repetível: valor cheio) = 13. Dentro. _(Revisão: conta confirmada.)_

## Dados
```json
{
  "id": "ind_cobra_grande",
  "nome": "Cobra-Grande",
  "cultura": "indigena",
  "tipo": "entidade",
  "custo": 6,
  "atk": 5,
  "vida": 6,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "enemy_dies", "acoes": [ { "op": "buff", "alvo": "self", "atk": 1, "vida": 1, "perm": true } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, no legs, no arms, colossal black anaconda, giant snake, long serpent body, coils rising out of a dark river, huge glowing yellow eyes, open jaws, fangs, forked tongue, small capsized canoe, splashes, amazon river at night, flooded forest, moonlit water, green and orange, eyes reflected on water, rim lighting, mist, deep shadows, menacing, full body, clean silhouette, readable shape, high contrast
```

## Prompt Krea 2
Atributos obrigatórios: sucuri negra colossal · olhos amarelos como faróis · saindo do rio em espirais · canoa virada pequena
```krea
A colossal black anaconda, the Boiuna, rising in thick coils from a dark Amazon river at night. It is a true legless snake with glossy black scales. Its two huge eyes glow yellow like ship lanterns and cast beams across the water. Its jaws are wide open, showing curved fangs and a forked tongue. In the foreground floats a small wooden canoe that is capsized: turned completely upside down, its rounded hull facing the sky and its open interior hidden underwater, a lost paddle drifting beside it. Flooded forest trees around, a pale moon behind the mist.
```
