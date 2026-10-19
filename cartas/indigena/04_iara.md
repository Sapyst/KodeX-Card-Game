# Iara

| Campo | Valor |
|---|---|
| Cultura | indígena brasileira |
| Tipo | Entidade |
| Custo | 3 Fé |
| ATK / Vida | 2 / 3 |
| Palavras-chave | Despertar |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Despertar: devolve uma Entidade inimiga à mão do dono.

## Contexto mitológico
A Iara (Uiara, Mãe-d'água) é a sereia dos rios amazônicos: mulher de cabelos longos e cauda de peixe que canta nas tardes e atrai pescadores para o fundo, de onde não voltam — ou voltam "encantados", sem juízo. A forma atual é do século XIX; antes dela, Fernão Cardim (c. 1584) e Gabriel Soares de Sousa (1587) descreviam o **Ipupiara**, "morador do fundo", monstro masculino que abraçava e esmagava os banhistas. Barbosa Rodrigues (*Poranduba Amazonense*, 1890) e Cascudo (*Geografia dos Mitos Brasileiros*) acompanham a transformação do monstro em sereia sob influência romântica.

Numa versão popular amazônica, muito repetida em coletâneas do século XX, a Iara era uma guerreira indígena, a melhor da aldeia; os irmãos, com inveja, tentaram matá-la, ela os matou primeiro e foi lançada ao rio pelo pai, onde os peixes a transformaram. Daí o canto: vingança e saudade, não maldade. O nome vem do tupi *y* (água) + *îara* (senhora): "senhora das águas".

A carta não a faz matar — ela **atrai para longe**: a Entidade inimiga volta à mão, encantada, e o oponente perde o tempo investido nela.

## Papel no jogo
A única "remoção" do deck que não é fogo. Devolver à mão é mais forte quanto mais caro o alvo, e desfaz Relíquias equipadas e buffs permanentes (Terra sem Males do adversário). Use no turno em que o inimigo invoca sua carta grande; o corpo 2/3 segura a linha depois. Ruim contra decks de criaturas baratas e tokens, que simplesmente voltam.

## Balanço
Orçamento P = 2·3+1 = 7 pts. Gasto (tabela §10): ATK 2 + Vida 3 + Despertar devolver Entidade inimiga à mão (2) = 7. Dentro. _(Revisão: conta confirmada.)_

## Dados
```json
{
  "id": "ind_iara",
  "nome": "Iara",
  "cultura": "indigena",
  "tipo": "entidade",
  "custo": 3,
  "atk": 2,
  "vida": 3,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [ { "op": "bounce", "alvo": "enemy_entity" } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1girl, solo, river mermaid, mature indigenous woman, dark skin, very long black hair, fish tail with green scales, shell and seed necklace, half submerged, singing, hand outstretched beckoning toward viewer, hypnotic gaze, calm amazon river at dusk, giant water lily pads, flooded forest trees, ripples, reflections on water, jungle, teal and orange, moonlight on water, green and orange, soft glow, mist over water, fireflies, deep shadows, full body
```

## Prompt Krea 2
Atributos obrigatórios: mulher indígena adulta · cauda de peixe de escamas verdes no lugar das pernas · top de conchas cobrindo o peito · mão direita estendida chamando · vitórias-régias
```krea
An adult Indigenous Brazilian woman about 30 years old, a river mermaid with realistic adult proportions, dark brown skin and very long straight black hair spreading on the water. Below the waist her body becomes one long fish tail covered in dark green scales, ending in a wide fin, in place of legs. She has two normal arms and two hands. She wears a woven top of river shells and palm fiber that fully covers her chest, and a necklace of seeds. Half submerged among giant water lily pads, she sings with her right hand stretched out, beckoning the viewer toward the deep. Calm Amazon river at dusk, a bright rising moon reflected on the water.
```
