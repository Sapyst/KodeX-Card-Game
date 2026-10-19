# Sansão

| Campo | Valor |
|---|---|
| Cultura | cristianismo |
| Tipo | Entidade |
| Custo | 4 Fé |
| ATK / Vida | 3 / 3 |
| Palavras-chave | Último Sopro |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Último Sopro: causa 2 de dano a todas as Entidades inimigas.

## Contexto mitológico
Sansão, da tribo de Dã, é nazireu desde o ventre: não corta o cabelo, não bebe vinho, e nele "o espírito do Senhor" desce como força bruta (Jz 13–16). Despedaça um leão com as mãos, mata mil filisteus com a mandíbula fresca de um jumento em Ramat-Leí (Jz 15,15-17), arranca as portas de Gaza e as carrega montanha acima. Traído por Dalila, que lhe corta as sete tranças, é cegado e posto a girar a mó na prisão.

O fim é o episódio que a carta captura. Levado ao templo de Dagon para divertir os filisteus reunidos — "havia ali cerca de três mil homens e mulheres" —, Sansão pede ao menino que o guia que o encoste nas colunas centrais e ora: "Que eu morra com os filisteus!" Empurra as colunas e o telhado desaba sobre todos; "os que matou ao morrer foram mais do que os que matara em vida" (Jz 16,30).

É o **Último Sopro** em área mais literal de todo o jogo: quando Sansão cai, o templo cai com ele sobre todas as Entidades inimigas.

## Papel no jogo
Ameaça que o oponente não quer matar nem deixar viva. Como 3/3 troca com a maioria dos custos 3–4, e ao morrer limpa tokens e fere o resto, abrindo espaço para Davi e Judite fecharem. A melhor oferenda do deck para o **Leviatã**: Sacrifício conta como morte (regras §2), então o templo cai sobre os inimigos no mesmo turno em que o monstro entra. Tumba Vazia e Talita Cumi o trazem de volta para uma segunda derrubada. **Não** há sinergia com o Juízo Final: quando Sansão cai ali, as inimigas já se foram e o Último Sopro não acerta ninguém. Ruim contra `bounce` e `silence`, que negam o Último Sopro.

## Balanço
Orçamento P = 2·C+1 = 9 pts. Gasto: ATK 3 + Vida 3 + 2 de dano a todas as inimigas (1,5 × 2) = 3 → 9. Dentro.

## Dados
```json
{
  "id": "cri_sansao",
  "nome": "Sansão",
  "cultura": "cristianismo",
  "tipo": "entidade",
  "custo": 4,
  "atk": 3,
  "vida": 3,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_death", "acoes": [ { "op": "damage", "alvo": "all_enemy_entities", "n": 2 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1boy, solo, muscular man, very long dark hair, long braids, thick dark beard, blindfold, broken chains on wrists, loincloth, standing between two massive stone pillars, both palms pressed against the pillars, arms spread wide, pushing pillars apart, straining, cracks in pillars, falling stones, dark pagan temple hall, torches, dust, holy light from above, gold and white, warm firelight, strong rim lighting, full body
```

## Prompt Krea 2
Atributos obrigatórios: cego com venda sobre os olhos vazados · sete tranças longas · grilhões partidos nos pulsos · palmas empurrando duas colunas · túnica marrom rasgada
```krea
A very tall, muscular Middle Eastern Hebrew man about 35 years old, Samson, with a thick dark beard and seven long dark braids. He is blind: a wide dark linen bandage is wrapped tightly across his eyes and covers both eye sockets completely, so no eyes are visible at all, only the cloth band from temple to temple. His nose, mouth and beard are normal. He has two normal arms and two hands, palms pressed flat against two massive stone pillars, arms spread wide, pushing them apart. Broken iron shackles with short chains hang from both wrists. A torn knee-length brown tunic covers his chest, with a leather belt. Cracking pillars and falling stones in a dark pagan temple lit by torches.
```
