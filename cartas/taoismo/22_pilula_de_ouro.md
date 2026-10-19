# Pílula de Ouro

| Campo | Valor |
|---|---|
| Cultura | taoismo |
| Tipo | Rito |
| Custo | 3 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 2 |

## Texto da carta
Reviva uma Entidade do seu cemitério para o campo. Compre 1 carta.

## Contexto mitológico
*Jindan* (金丹), a "pílula de ouro" ou "elixir dourado", é o objeto central da alquimia taoista. Na alquimia externa (*waidan*) é uma substância real: cinábrio (sulfeto de mercúrio) aquecido no caldeirão vira mercúrio, que recombinado com enxofre volta a ser cinábrio — um ciclo de morte e retorno que, repetido nove vezes (*jiuzhuan huandan*, "o elixir que retorna nove vezes"), produziria o remédio da imortalidade. Ge Hong, no *Baopuzi* (cap. 4, "Jindan"), diz que ervas e exercícios prolongam a vida, mas só o elixir dourado dá a imortalidade verdadeira: "o ouro não apodrece nem no fogo nem na terra; quem o ingere adquire a mesma natureza". O *Zhouyi cantong qi* (séc. II) codifica a receita em linguagem do *Yijing*.

A história cobrou caro: Qin Shi Huang e Han Wudi gastaram fortunas atrás do elixir; vários imperadores Tang (Xianzong, Muzong, Wuzong, Xuanzong) morreram envenenados por mercúrio. A resposta foi a alquimia interna (*neidan*, a partir dos Song): o caldeirão é o corpo, o cinábrio é a essência e o sopro, e a pílula de ouro é o "embrião imortal" gerado no campo de cinábrio inferior. Na *Jornada ao Oeste*, Sun Wukong engole todas as pílulas de Laozi e se torna indestrutível.

Como Rito, a pílula faz o que promete: quem morreu volta inteiro, e ao campo.

## Papel no jogo
O motor de reciclagem principal: revive para o campo **sem Despertar** (reviver não o dispara, regras §8) — volta o corpo e o que ele tem de contínuo: Guan Yu com Guarda, Cao Guojiu com Guarda, Lü Dongbin com a aura, Nezha com Ímpeto e Renascer — e ainda repõe a carta. Para repetir um Despertar (Zhong Kui, Erlang), o caminho é Zhongli Quan, que devolve à mão. Duas cópias porque é a carta que faz o deck ganhar jogos longos. Precisa de slot livre e de alvo no cemitério — não funciona nos turnos 1–3 na maioria das partidas.

## Balanço
Orçamento P = 2·C+1 = 7 pts. Gasto: revive para o campo (3 + custo ÷ 2; alvo típico 2–4 → 4–5; máximo Guan Yu/Erlang custo 5 → 5,5) + comprar 1 (1,5) = 5,5–7. Dentro.

## Dados
```json
{
  "id": "tao_pilula_de_ouro",
  "nome": "Pílula de Ouro",
  "cultura": "taoismo",
  "tipo": "rito",
  "custo": 3,
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
no humans, object focus, single glowing golden pill, round golden elixir floating above cauldron, bronze ding cauldron, tripod cauldron, three legs, bagua carvings on cauldron, cinnabar red flames below, golden sparks, faint spirit figure in the light, dark alchemist cave, medicine jars, red candles, jade green and vermilion, mist, ink wash feel, golden light, dramatic lighting, night
```

## Prompt Krea 2
Atributos obrigatórios: pílula dourada brilhante flutuando · caldeirão ding de bronze de três pés · gravuras de bagua · chamas vermelhas de cinábrio
```krea
A single round golden pill glows and floats above a bronze ding cauldron, with no people present. The cauldron stands on three legs and is carved with bagua trigram patterns. Cinnabar-red flames burn beneath it and golden sparks rise around the pill, inside whose light a faint spirit figure appears. The cauldron sits in a dark alchemist's cave with clay medicine jars and red candles, lit by the strong golden light of the pill.
```
