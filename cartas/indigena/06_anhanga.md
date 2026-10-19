# Anhangá

| Campo | Valor |
|---|---|
| Cultura | indígena brasileira |
| Tipo | Entidade |
| Custo | 4 Fé |
| ATK / Vida | 3 / 3 |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Sempre que outra Entidade aliada morrer, invoca um Veado Branco 1/2.

## Contexto mitológico
Para os Tupinambá do século XVI, *Anhanga* era o espírito errante dos mortos, o terror das noites: Anchieta (1560) e Cardim (c. 1584) o descrevem como o ser que "anda pelo mato" e de quem todos têm medo; os jesuítas o traduziram como "diabo", o que distorceu a figura. Métraux (*A religião dos Tupinambás*, 1928) a devolve ao lugar: um espectro ligado aos mortos e à floresta, não um princípio do mal.

No folclore amazônico posterior, recolhido por Couto de Magalhães (*O Selvagem*, 1876) e Cascudo (*Dicionário do Folclore Brasileiro*), o Anhangá é o **protetor dos animais de caça**, que aparece como um **veado branco de olhos de fogo**. Quem persegue uma fêmea com filhote ou caça demais é levado pelo Anhangá a visões e alucinações, e às vezes mata o próprio parente pensando ser a caça.

Na carta, Anhangá é a resposta da mata à morte: quando uma aliada cai, ele faz surgir o veado branco — a caça que não pode ser caçada.

## Papel no jogo
Motor de tokens em deck que espera perder peças pequenas: cada Queixada, Aruanã ou Saci que morre vira um Veado Branco 1/2, que mantém o campo cheio para Terra sem Males e para a aura do Cocar. Combina com Kuarup e Dádiva de Mani (as mortes não são perda total). Como não tem Guarda, costuma ser atacado por último — que é o que ele quer. Fraco se o campo já estiver lotado (sem slot, não há token).

## Balanço
Orçamento P = 2·4+1 = 9 pts. Gasto (tabela §10): ATK 3 + Vida 3 + `ally_dies` → token Veado Branco 1/2 (a + v = 3; gatilho repetível: valor cheio) = 9. Dentro. _(Revisão: conta confirmada. Nota: Sacrifício contaria como morte e dispararia o Veado, mas o deck não tem Sacrifício.)_

## Dados
```json
{
  "id": "ind_anhanga",
  "nome": "Anhangá",
  "cultura": "indigena",
  "tipo": "entidade",
  "custo": 4,
  "atk": 3,
  "vida": 3,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "ally_dies", "acoes": [ { "op": "summon", "atk": 1, "vida": 2, "nome": "Veado Branco", "n": 1 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, spectral white stag, glowing white fur, large antlers, eyes of fire, ghostly aura, translucent body, wisps of white mist rising from the ground, standing still facing viewer, protective, dark amazon forest at night, dead tree, fallen leaves, animal bones on the ground, giant ferns, moonlight, green and orange, orange glowing eyes, pale blue glow, rim lighting, fireflies, fog, deep shadows, mist on the ground, night sky, ethereal, full body
```

## Prompt Krea 2
Atributos obrigatórios: veado branco espectral · olhos de fogo laranja · translúcido com névoa branca · ossos de caça a seus pés
```krea
A spectral white deer stag, a forest spirit, standing still and facing the viewer as a guardian. Its fur is pure glowing white and its body is slightly translucent, with small branching antlers, four slender legs and a short tail. Its two eyes burn with orange fire. White mist rises from the ground around its hooves, and old animal bones lie half hidden among fallen leaves at its feet beside a dead tree. Dark Amazon forest at night, lit by the stag's own pale glow and a strong cold moonbeam falling from above.
```
