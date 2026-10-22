# Caipora

| Campo | Valor |
|---|---|
| Cultura | indígena brasileira |
| Tipo | Entidade |
| Custo | 3 Fé |
| ATK / Vida | 2 / 2 |
| Palavras-chave | Despertar |
| Lendária | não |
| Cópias no deck | 2 |

## Texto da carta
Despertar: Invoque um Queixada 1/2.

## Contexto mitológico
*Caa-pora*, "habitante do mato" em tupi. Cascudo (*Dicionário do Folclore Brasileiro*) registra a Caipora (ou Caapora) como senhora dos animais da floresta: ora uma mulher peluda, ora um menino, quase sempre **montada num porco-do-mato** — o queixada ou o caititu — e cercada pela vara inteira. Cobra fumo dos caçadores; quem lhe deixa um rolo de tabaco num toco caça bem, quem não deixa volta de mãos vazias ou com febre.

Couto de Magalhães (*O Selvagem*, 1876) e, mais tarde, a tradição amazônica fundiram a Caipora com o Curupira; no Nordeste e no Sudeste ela permanece figura própria, mais ligada aos bichos do que às árvores. É a padroeira da caça justa: protege o animal e, ao mesmo tempo, o caçador que respeita as regras.

A carta a traz montada: ao entrar em campo, chega com o Queixada — um token que representa a vara que a acompanha.

## Papel no jogo
Dois corpos por 3 Fé: a Caipora 2/2 e o Queixada 1/2 ocupam dois slots e dão massa para Terra sem Males (+1/+1 em todos) e para a aura do Cocar. O token é o que o inimigo mata primeiro, poupando a Caipora. Combina com Anhangá (se o Queixada morre, nasce um Veado Branco) e com Boitatá (o atacante do Queixada leva 1). Atenção aos 4 slots: com Caipora ×2 e Jaci o campo lota rápido.

## Balanço
Orçamento P = 2·3+1 = 7 pts. Gasto (tabela §10): ATK 2 + Vida 2 + Despertar token Queixada 1/2 (a + v = 3) = 7. Dentro. _(Revisão: conta confirmada.)_

## Dados
```json
{
  "id": "ind_caipora",
  "nome": "Caipora",
  "cultura": "indigena",
  "tipo": "entidade",
  "custo": 3,
  "atk": 2,
  "vida": 2,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [ { "op": "summon", "atk": 1, "vida": 2, "nome": "Queixada", "n": 1 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1girl, riding on the back of a colossal wild boar, sitting astride large peccary, mature indigenous woman, realistic human face, small realistic eyes, serious grim expression, weathered dark brown skin, long wild black hair, modest indigenous leather tunic, seed necklace, holding smoking tobacco roll, massive dark bristly wild boar with sharp white tusks, boar charging forward toward viewer, night amazon rainforest, moonlight, green and orange, dramatic rim lighting, full body, non-anime
```

## Prompt Krea 2
Atributos obrigatórios: mulher indígena adulta · montada num queixada enorme · túnica de algodão cobrindo o peito · rolo de fumo aceso na mão direita
```krea
An adult Indigenous Brazilian woman about 40 years old with realistic adult proportions, weathered brown skin, long wild black hair and a stern face, riding astride a huge dark bristly white-lipped peccary that charges toward the viewer with its white tusks bared. She wears a knee-length woven brown cotton tunic that covers her chest, a red seed necklace and a feather band on her upper arm. Her left hand grips the peccary's bristly neck; her right hand raises a rolled tobacco leaf trailing smoke. Night Amazon rainforest, a strong moonbeam breaking through the canopy onto the rider and her mount.
```
