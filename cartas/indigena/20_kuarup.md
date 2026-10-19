# Kuarup

| Campo | Valor |
|---|---|
| Cultura | indígena brasileira |
| Tipo | Rito |
| Custo | 4 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Traz uma Entidade do seu cemitério de volta ao campo. Compre 1 carta.

## Contexto mitológico
O Kuarup (*Kwarìp*, em kamayurá) é a grande festa funerária dos povos do Alto Xingu (MT) — Kamayurá, Kuikuro, Kalapalo, Waurá, Mehinako, Yawalapiti e outros — em homenagem aos mortos ilustres do ano. Troncos da árvore kuarup são cortados, fincados no centro da aldeia, pintados e enfeitados com cocares, braçadeiras e colares: cada tronco **é** um morto, que volta por uma noite. As famílias choram diante dos troncos; ao amanhecer, há lutas de *huka-huka* entre as aldeias convidadas e, ao fim, os troncos são lançados no rio e o luto termina.

O mito de origem, recolhido por Pedro Agostinho (*Kwarìp: mito e ritual no Alto Xingu*, 1974) e pelos irmãos Villas Bôas (*Xingu: os índios, seus mitos*, 1970), conta que o criador **Mavutsinim** tentou ressuscitar os mortos cortando troncos e cantando para eles; os troncos já começavam a virar gente quando um homem que tinha dormido com a mulher na véspera desobedeceu à proibição de assistir — e eles voltaram a ser madeira. Desde então os mortos não voltam — mas o Kuarup os traz de volta por uma noite.

A carta realiza o que Mavutsinim não conseguiu: a Entidade volta ao campo.

## Papel no jogo
O revive pesado do deck: por 4 Fé, Boitatá, Mapinguari ou mesmo Jaci voltam direto ao campo (sem Despertar — reviver para o campo não o dispara, regras §8; a aura de Jaci volta, a Vitória-régia não), e você repõe a carta. É o que torna as trocas do deck favoráveis — o inimigo gasta remoção em Boitatá, e ele volta. Precisa de um slot livre e de uma Entidade boa no cemitério; nos primeiros turnos é carta morta.

## Balanço
Orçamento P = 2·4+1 = 9 pts. Gasto (tabela §10): reviver para o campo = 3 + custo da Entidade ÷ 2 (Saci 4 · Boitatá, alvo típico, 5 · Jaci 6 · Tupã 6,5) + comprar 1 (1,5) = 5,5 a 8. Dentro em todos os casos (pior caso, Tupã, = P−1). _(Revisão: conta confirmada. Reviver Jaci/Tupã dispara o Despertar de novo — observar no simulador.)_

## Dados
```json
{
  "id": "ind_kuarup",
  "nome": "Kuarup",
  "cultura": "indigena",
  "tipo": "rito",
  "custo": 4,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [
      { "op": "revive", "alvo": "ally_graveyard_entity", "para": "field" },
      { "op": "draw", "n": 1 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, row of upright wooden log posts in a village plaza, logs painted with red and black geometric patterns, feather headdress and cotton bands tied on each log, central log glowing with blue spirit light, faint spirit rising from it, no crosses, no skulls, bonfire, night, thatched longhouses, sandy ground, stars, firelight, green and orange, solemn ritual, wide shot, clean silhouette, readable shape, high contrast, dramatic lighting, deep shadows, rim lighting, moody atmosphere, soft glow, sharp focus
```

## Prompt Krea 2
Atributos obrigatórios: fileira de troncos kuarup pintados de vermelho e preto · cocares e braçadeiras nos troncos · tronco central com luz azul de espírito · fogueira na praça
```krea
A row of upright kuarup wooden log posts planted in the center of a Xingu village plaza at night. Each log is painted with red urucum and black geometric patterns and dressed with a feather headdress, cotton armbands and a belt of beads. The central log glows from within with pale blue spirit light, and a faint luminous human shape rises from it. A large bonfire lights the logs warmly from the side, with round thatched Xingu houses and a starry sky behind. A solemn wide view, with the glowing central log as the focal point.
```
