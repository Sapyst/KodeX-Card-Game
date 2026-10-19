# A Bruxa de Endor

| Campo | Valor |
|---|---|
| Cultura | bruxaria |
| Tipo | Entidade |
| Custo | 4 Fé |
| ATK / Vida | 2 / 4 |
| Palavras-chave | Furtivo |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Furtivo. Despertar: devolva uma Entidade do seu cemitério à sua mão.

## Contexto mitológico
Em 1 Samuel 28, na véspera da batalha de Gilboa contra os filisteus, o rei Saul — que havia expulsado de Israel os necromantes e adivinhos — disfarça-se e vai de noite a Endor consultar "uma mulher que tem um *ôb*" (um espírito familiar, ou o próprio ofício de evocar os mortos). Ela teme uma armadilha; ele jura por Yahweh que nada lhe acontecerá. Ela faz subir da terra um ancião envolto num manto: é Samuel, que pergunta por que o perturbaram e anuncia que Saul e seus filhos morrerão no dia seguinte. A mulher, vendo o rei prostrado, mata um bezerro e assa pães para que ele coma antes de partir.

É o único relato detalhado de necromancia na Bíblia hebraica, e por isso foi debatido por quinze séculos: Justino e Orígenes acharam que era Samuel de verdade; Tertuliano e Agostinho, que era um demônio disfarçado; a tradição rabínica (*Hagigá* 4b; *Levítico Rabá* 26) ensina que os mortos evocados sobem de cabeça para baixo — menos Samuel, que subiu em pé por respeito ao rei, e assustado porque pensou que era o Juízo Final. O *Malleus Maleficarum* a cita para provar que os demônios podem fingir ressuscitar os mortos. A "Pitonisa de Endor" tornou-se o protótipo da necromante no imaginário cristão — mas o texto a mostra competente, cautelosa e, no fim, compassiva.

Na carta ela faz exatamente o que fez por Saul: traz de volta quem já estava no chão.

## Papel no jogo
Recuperação sem Cornucópia: devolve à mão o familiar certo (um Sapo para sacrificar de novo, a Strega para outra Strix) ou a Entidade grande que morreu cedo. Furtivo a protege de remoção até ela atacar, então ela pode ficar atrás como "banco" de 4 de Vida e portadora segura de uma Relíquia. Combina com o Caldeirão de Renascimento (um revive ao campo, outro à mão). Ruim se o cemitério estiver vazio no turno 4 — guardá-la para o meio do jogo.

## Balanço
Orçamento P = 2·4+1 = 9 pts. Gasto: ATK 2 + Vida 4 + Furtivo 1 + Despertar: reviver Entidade do cemitério para a mão (2 pts) = 9. Dentro.

## Dados
```json
{
  "id": "bru_bruxa_de_endor",
  "nome": "A Bruxa de Endor",
  "cultura": "bruxaria",
  "tipo": "entidade",
  "custo": 4,
  "atk": 2,
  "vida": 4,
  "lendaria": false,
  "keywords": ["furtivo"],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [ { "op": "revive", "alvo": "ally_graveyard_entity", "para": "hand" } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1girl, solo, mature woman, necromancer witch, hooded dark cloak, grey streaked hair, wrinkles, kneeling on the floor, both arms raised, translucent ghost of an old bearded man in a long robe rising from the ground in front of her, ghost larger than her, pale blue spectral glow, swirling spirit mist, dark cave dwelling, small fire pit, clay pots, purple and green, candlelight, rim lighting, eerie, dark atmosphere, full body
```

## Prompt Krea 2
Atributos obrigatórios: idosa hebreia de manto escuro com capuz · ajoelhada, braços erguidos · fantasma translúcido de ancião de barba e manto · brilho azul espectral · habitação em caverna
```krea
An elderly Middle Eastern Hebrew woman about 65 years old, clearly female, with a soft smooth wrinkled tan face, no beard, no facial hair and a bare chin, kneels on the earthen floor of a dark cave dwelling. Her long grey-streaked hair falls from under a faded headscarf, and she wears a long hooded dark brown wool robe that covers her body. She has two normal arms, and both are raised toward the space in front of her. Rising from the ground before her is the translucent pale blue ghost of an old bearded man in a long mantle, taller than she is. Clay pots stand by the wall and a small fire pit smolders. The blue ghost light lights her face.
```
