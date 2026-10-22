# Pássaro Vermelho do Sul

| Campo | Valor |
|---|---|
| Cultura | taoismo |
| Tipo | Selo |
| Custo | 2 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Quando uma Entidade aliada morrer, devolva uma Entidade do seu cemitério para o campo. Cure 2 da sua Cornucópia.

## Contexto mitológico
Zhuque (朱雀), o Pássaro Vermelho do Sul, governa o verão, o fogo e o meio-dia. Nas fontes Han (*Shiji*, "Tianguan shu"; *Huainanzi*) é a figura das sete mansões meridionais (de Jing, em Gêmeos, a Zhen, em Corvus; Antares, muitas vezes citada por engano, pertence à mansão Xin do Dragão Azul); nas tumbas aparece como ave de longa cauda e crista, asas abertas, entre chamas. Não é a fênix (*fenghuang*), ave de bom augúrio ligada à imperatriz, mas as duas se confundem desde cedo, e a confusão trouxe para Zhuque a ideia que o Ocidente associa à fênix: o fogo que consome e devolve.

No taoismo ritual, Zhuque guarda o sul do altar e a porta pela qual entram os espíritos convidados; nos textos de *neidan* o pássaro vermelho é o fogo do coração (*xinhuo*) que aquece o caldeirão. O sul é, na geomancia (*fengshui*), a frente ideal de uma casa — o lado da vida.

Como Selo-guardião, o Pássaro Vermelho responde à morte com fogo de verão: quando algo seu cai, algo seu renasce.

## Papel no jogo
A segurança contra remoção: o oponente mata um Imortal no turno dele e o vê voltar — no motor, `_morrer` põe a carta no cemitério **antes** de disparar `ally_dies` (README do sim, regra 18b), então o Selo pode reviver exatamente quem acabou de cair, ou um morto anterior, à escolha — sem Despertar (reviver para o campo não o dispara, regras §8): volta o corpo, a Guarda, a aura, não o golpe de entrada. Se a morta tinha Renascer ela foi para a mão, não para o cemitério, e o Selo revive outra. Só dispara em morte no turno do oponente (regra 15), inclusive por Rito inimigo; precisa de slot livre. Cedo demais é carta parada.

## Balanço
Orçamento P = 2·C+1 = 5 pts, +1 grátis de Selo = 6. Gasto: revive para o campo (3 + custo ÷ 2; alvo típico 2–3 → 4–4,5) + curar 2 de Cornucópia (1) = 5–5,5. Dentro.

## Dados
```json
{
  "id": "tao_passaro_vermelho_do_sul",
  "nome": "Pássaro Vermelho do Sul",
  "cultura": "taoismo",
  "tipo": "selo",
  "custo": 2,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "ally_dies", "acoes": [
      { "op": "revive", "alvo": "ally_graveyard_entity", "para": "field" },
      { "op": "heal", "alvo": "ally_cornucopia", "n": 2 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, vermilion bird, phoenix-like bird, crimson plumage, long tail feathers, crest, wings spread, rising from flames, fire, rebirth, southern sky, sunset, clouds, pagoda silhouette, red and gold, jade green and vermilion, embers, ink wash feel, fiery backlight, glowing eyes, sparks flying, feathers trailing light, wind, dark clouds, full body
```

## Prompt Krea 2
Atributos obrigatórios: ave vermelha de cauda longa e crista · asas abertas · renascendo das chamas · plumagem carmesim e dourada
```krea
A great vermilion bird, the Red Bird of the South, with no people present. It has crimson and gold plumage, a crest on its head, very long trailing tail feathers and wings spread wide. It rises out of a column of flames as if reborn from the fire, sparks and glowing feathers trailing behind it. A dark pagoda silhouette stands below against a southern sunset sky with dark clouds, lit by the strong fiery backlight of the flames.
```
