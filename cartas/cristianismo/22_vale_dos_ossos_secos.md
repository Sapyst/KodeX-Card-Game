# Vale dos Ossos Secos

| Campo | Valor |
|---|---|
| Cultura | cristianismo |
| Tipo | Rito |
| Custo | 3 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Invoque dois Ossos Erguidos 1/1. Reviva uma Entidade aleatória do seu cemitério para a mão.

## Contexto mitológico
"A mão do Senhor veio sobre mim e me levou em espírito e me pôs no meio de um vale, que estava cheio de ossos; eram muitíssimos sobre a superfície do vale, e estavam sequíssimos" (Ez 37,1-2). Deus pergunta ao profeta se aqueles ossos podem viver e manda que ele profetize sobre eles. "Houve um ruído, e eis um rebuliço, e os ossos se achegaram, cada osso ao seu osso"; vêm nervos, carne, pele — e então o sopro dos quatro ventos, "e viveram e se puseram em pé, um exército muito grande" (Ez 37,7-10).

A visão é dirigida aos exilados na Babilônia — "estes ossos são toda a casa de Israel" — e promete o retorno à terra como ressurreição nacional. A tradição cristã a leu como profecia da ressurreição dos corpos; o painel da sinagoga de Dura-Europos (séc. III) e as *Homilias de Gregório de Nazianzo* (Paris gr. 510, séc. IX) mostram os esqueletos se recompondo e se levantando do chão. É uma das imagens mais poderosas da Bíblia sobre a vida que volta ao que está morto há muito tempo.

Como **Rito**, são dois movimentos: os ossos se levantam como exército (tokens) e o sopro traz de volta algo do cemitério — aleatório, porque o vento sopra onde quer.

## Papel no jogo
Recupera campo e mão num só gasto. Os dois 1/1 são bloqueadores descartáveis, alimentam Tumba Vazia ao morrer no turno do oponente e são a oferenda ideal para o Sacrifício do Leviatã; a Entidade revivida para a mão é jogada de novo no turno seguinte, com Despertar. Melhor no meio do jogo, com dois ou três corpos no cemitério e slots livres. Precisa de slots: com o campo cheio, só o revive acontece.

## Balanço
Orçamento P = 2·C+1 = 7 pts. Gasto: invocar 2 tokens 1/1 (1+1) × 2 = 4 + reviver para a mão 2 × aleatório 0,8 = 1,6 → 5,6. Dentro.

## Dados
```json
{
  "id": "cri_vale_dos_ossos_secos",
  "nome": "Vale dos Ossos Secos",
  "cultura": "cristianismo",
  "tipo": "rito",
  "custo": 3,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [
      { "op": "summon", "atk": 1, "vida": 1, "nome": "Osso Erguido", "n": 2 },
      { "op": "revive", "alvo": "ally_graveyard_entity_random", "para": "hand" } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, skeleton standing up from the ground, undead, glowing eye sockets, bones reassembling, bones flying together, flesh and sinews growing back on skeleton, two skeletons rising, vast valley filled with dry bones, scattered skulls and ribcages, cracked dry earth, stones, dead tree, desert valley at dusk, four winds blowing, swirling dust and wind streaks, dark clouds parting, breath of life as glowing golden wind, holy light, gold and white, bone white and gold against dark earth, rim lighting, eerie yet hopeful, wide shot, full body
```

## Prompt Krea 2
Atributos obrigatórios: esqueleto se levantando · ossos se juntando no ar · tendões e carne se formando · segundo esqueleto ao fundo · vento dourado dos quatro cantos
```krea
A figure halfway between a skeleton and a living man rising to its feet in a vast desert valley of dry bones. Its skull and ribcage are still bare bone, but its arms and legs are already wrapped in visible stylized dark red muscle strands and bright golden tendons, with patches of smooth tan skin forming over the shoulders and thighs, clean and bloodless. Loose bones fly through the air and lock into place on its body. Two arms and two legs, one hand pushing off the cracked earth. Behind it, a second bare skeleton is half risen. Scattered skulls on the valley floor. A golden wind sweeps in from four directions in swirling streaks under dark dusk clouds.
```
