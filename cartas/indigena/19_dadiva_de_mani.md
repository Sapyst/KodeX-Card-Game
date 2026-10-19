# Dádiva de Mani

| Campo | Valor |
|---|---|
| Cultura | indígena brasileira |
| Tipo | Rito |
| Custo | 3 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Devolve uma Entidade do seu cemitério à sua mão. Sua Cornucópia cura 6. Compre 1 carta.

## Contexto mitológico
A lenda da mandioca foi recolhida por Couto de Magalhães (*O Selvagem*, 1876) entre falantes de nheengatu no Amazonas e é uma das mais contadas do país. A filha de um chefe apareceu grávida sem ter marido; o pai, furioso, só se acalmou quando um homem branco lhe apareceu em sonho dizendo que a moça era inocente. Nasceu uma menina branca, **Mani**, que andou e falou cedo e morreu com um ano, sem doença. Foi enterrada dentro da casa (*oca*), como era o costume, e a sepultura regada com as lágrimas da mãe.

Da cova nasceu uma planta desconhecida; a terra rachou e mostrou raízes grossas e brancas como o corpo da menina. Era a **mani-oca**, "casa de Mani" — a mandioca, alimento que sustenta até hoje os povos da floresta e o Brasil inteiro. Cascudo (*Dicionário do Folclore Brasileiro*) anota a lenda em todo o Norte e Nordeste e registra variantes populares em que é o orvalho da noite — Jaci, a Lua — que umedece a cova. Vale lembrar que a versão de Couto de Magalhães já traz marcas da catequese (a gravidez sem pai, o "homem branco" do sonho); o núcleo indígena é o do alimento que nasce do corpo enterrado, tema comum a muitos povos amazônicos.

A carta é a dádiva: o que foi enterrado volta transformado em alimento — a Entidade volta à mão, a aldeia se alimenta (cura 6) e algo novo brota (compra 1).

## Papel no jogo
Recuperação de meio de jogo: traz Boitatá ou Caipora de volta à mão para jogar de novo, cura 6 na Cornucópia (quase metade dela) e repõe a carta. Boa resposta a um turno ruim. Difere do Kuarup, que revive direto no campo por mais Fé — Mani é mais barata e mais flexível, Kuarup é mais rápido. Lenta contra decks agressivos se jogada sem criaturas no campo.

## Balanço
Orçamento P = 2·3+1 = 7 pts. Gasto (tabela §10): reviver Entidade do cemitério para a mão (2) + curar 6 de Cornucópia (1 por 2 pontos: 3) + comprar 1 (1,5) = 6,5. Dentro (P−0,5). _(Revisão: conta confirmada.)_

## Dados
```json
{
  "id": "ind_dadiva_de_mani",
  "nome": "Dádiva de Mani",
  "cultura": "indigena",
  "tipo": "rito",
  "custo": 3,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [
      { "op": "revive", "alvo": "ally_graveyard_entity", "para": "hand" },
      { "op": "heal", "alvo": "ally_cornucopia", "n": 6 },
      { "op": "draw", "n": 1 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, object focus, cassava plant sprouting from a small grave mound, thick white roots breaking through cracked earth, green palmate leaves, glowing dewdrops, inside a dark thatched hut, moonlight from doorway, clay pots, woven basket, earthen floor, soft silver light, gentle glow on roots, green and orange, mystical, hopeful, centered composition, clean silhouette, readable shape, high contrast, dramatic lighting, deep shadows, rim lighting, moody atmosphere, soft glow, sharp focus
```

## Prompt Krea 2
Atributos obrigatórios: pé de mandioca brotando de uma pequena cova · raízes brancas grossas rachando a terra · orvalho brilhante nas folhas · luar pela porta da oca
```krea
A young cassava plant sprouting from a small grave mound of earth on the floor inside a dark thatched Indigenous house at night. The cracked earth of the mound splits open, revealing thick white cassava roots that glow softly. Its green palmate leaves are covered in many large, sparkling drops of night dew, each droplet shining silver like a tiny star. A woven basket and a clay pot rest beside the mound. Silver moonlight streams through the open doorway and falls directly on the plant and its roots, while the rest of the house stays in deep shadow. Quiet, sacred and hopeful.
```
