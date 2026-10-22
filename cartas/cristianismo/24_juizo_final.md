# Juízo Final

| Campo | Valor |
|---|---|
| Cultura | cristianismo |
| Tipo | Rito |
| Custo | 4 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Destrua todas as Entidades, suas e inimigas. Depois, devolva uma Entidade aleatória do seu cemitério para a mão.

## Contexto mitológico
"Quando o Filho do Homem vier na sua glória... todas as nações serão reunidas diante dele, e ele separará uns dos outros, como o pastor separa as ovelhas dos cabritos" (Mt 25,31-33). O Apocalipse descreve a cena final: "Vi um grande trono branco... e vi os mortos, grandes e pequenos, em pé diante do trono; e abriram-se livros" (Ap 20,11-12). Daniel já tinha visto o Ancião de dias sentado, "o seu trono eram chamas de fogo", e os livros abertos (Dn 7,9-10). O Juízo é universal: ninguém fica de pé por conta própria — todos passam pelo mesmo tribunal.

É o tema mais monumental da arte cristã: os tímpanos românicos de Autun e Conques, o *Dies irae* da liturgia dos defuntos, o políptico de Beaune, a parede inteira da Capela Sistina de Michelangelo com os eleitos subindo à esquerda e os condenados caindo à direita, Caronte à proa. Em todas elas, os anjos tocam as trombetas e os mortos saem dos túmulos — porque o Juízo pressupõe a ressurreição: "os que estão nos sepulcros ouvirão a sua voz e sairão" (Jo 5,28-29; cf. Dn 12,2).

Daí o desenho da carta em dois tempos. Primeiro ela **destrói tudo**, dos dois lados. Depois, **alguém se levanta**: uma Entidade do seu cemitério volta à mão — aleatória, porque não cabe a quem joga escolher quem é chamado. O deck cristão é feito de quem volta — Lázaro, Jonas e Elias renascem na mão por conta própria; Talita Cumi reabre os túmulos no turno seguinte. O tribunal é o mesmo para todos; a diferença é quem se levanta depois.

## Papel no jogo
A carta de reset do deck, e a razão de ser de todo o Renascer. Jogue com o campo inimigo mais valioso que o seu — ou com o seu campo feito de Renascidos, Anjos da Guarda (curam 2 ao cair) e Leviatã (cura 4). As Entidades com Renascer voltam à mão, e o Rito ainda devolve uma aleatória do cemitério; no turno seguinte Talita Cumi reconstrói o resto enquanto o oponente recomeça do zero. **Cuidado**: Tumba Vazia **não** dispara aqui — Selos só disparam no turno do oponente, e o Juízo é jogado no seu. O Último Sopro de Sansão também não rende nada: as inimigas já se foram quando ele cai. Perigosa com um Miguel seu em campo; segure-a até ter a sequência pronta.

## Balanço
Orçamento P = 2·C+1 = 9 pts. Gasto: destruir Entidade (5) × 2 inimigas esperadas em campo = 10, × 0,7 por ser simétrico (destrói as suas também) = 7; + reviver Entidade do cemitério para a mão 2 × aleatório 0,8 = 1,6 → **8,6**. Dentro (faixa 7–9). _(Rodada 1: reconta com `destroy` a 5 pts; antes 7,2. Sem mudança na carta.)_

## Dados
```json
{
  "id": "cri_juizo_final",
  "nome": "Juízo Final",
  "cultura": "cristianismo",
  "tipo": "rito",
  "custo": 4,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [
      { "op": "destroy", "alvo": "all_entities" },
      { "op": "revive", "alvo": "ally_graveyard_entity_random", "para": "hand" } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1other, solo, angel blowing long golden trumpet, large white wings, golden halo, white robe, flying high in stormy sky, view from below, open graves in dark earth below him, cracked tombstones, small human silhouettes rising from graves, sky splitting open, blinding light from above, golden clouds, fire on horizon, cosmic scale, apocalypse, solemn, holy light, gold and white, dramatic rim lighting, wide shot, outdoors
```

## Prompt Krea 2
Atributos obrigatórios: trombeta dourada longa nas duas mãos · asas brancas abertas · túnica branca com borda dourada · túmulos se abrindo embaixo · céu rasgado de luz
```krea
A tall adult angel with a solemn androgynous face, olive skin and long golden hair, flying high in a stormy sky and blowing a long straight golden trumpet held in both hands. Two great white feathered wings spread wide, and a golden halo circles his head. He wears a long white robe with a gold border that whips in the wind. Seen from below; beneath him the dark earth cracks open, stone tombs split, and small human silhouettes in white shrouds rise from the graves. The sky tears open above into blinding white light, with a line of fire on the horizon.
```
