# Hécate, Senhora das Encruzilhadas

| Campo | Valor |
|---|---|
| Cultura | bruxaria |
| Tipo | Entidade |
| Custo | 7 Fé |
| ATK / Vida | 5 / 7 |
| Palavras-chave | Sacrifício 1, Lendária |
| Lendária | sim |
| Cópias no deck | 1 |

## Texto da carta
Sacrifício 1. Despertar: todas as Entidades inimigas perdem 2 ATK e 2 Vida permanentemente.

## Contexto mitológico
Hécate (*Hekátē*) é a deusa grega das encruzilhadas, da noite, dos fantasmas, dos cães e da magia. Hesíodo lhe dedica o hino mais longo da *Teogonia* (411–452): filha dos titãs Perses e Astéria, Zeus a honrou acima de todos e lhe deu parte na terra, no mar e no céu estrelado; concede vitória nas assembleias, na guerra, nos jogos, na pesca e na criação de gado, e é a ama de todos os jovens. No *Hino Homérico a Deméter* é ela quem, com a tocha na mão, ouve o grito de Perséfone raptada e acompanha a mãe na busca — por isso é companheira da rainha do Hades.

Com o tempo Hécate desce: vira *Trioditis* (*Trivia*, em latim), a das três estradas, representada com três corpos ou três cabeças voltadas para cada caminho (o *hekataion*). Nas noites de lua nova os atenienses deixavam nas encruzilhadas as *deipna*, ceias de ovos, peixe e alho para ela e para os mortos sem repouso que a seguem (Aristófanes, *Pluto* 594–597); cães negros lhe eram sacrificados e seu cortejo é anunciado pelo uivo deles (Teócrito, *Idílio* 2.35–36; Apolônio, *Argonáuticas* III.1216–1217). É a deusa de Medeia e de Circe; os *Papiros Mágicos Gregos* (PGM IV.2708–2784) a invocam com Selene e Perséfone para feitiços de amor e de dano. Ovídio a chama *triformis* (*Metamorfoses* VII.94) e *triceps*, de três cabeças (VII.194), na invocação de Medeia.

Na bruxaria moderna Hécate é a Anciã, a senhora da Lua escura e das chaves. No jogo ela chega exigindo a oferenda da encruzilhada — um familiar sacrificado — e sua presença basta para que tudo o que o oponente tem em campo definhe.

## Papel no jogo
O momento "uau" do deck: 5/7 por 7 Fé que faz todas as Entidades inimigas perderem 2/2 de uma vez — tokens 1/1 e 2/2 somem, as médias viram pequenas, a grande fica no tamanho dela. O Sacrifício é pago com qualquer familiar (o Sapo ainda dá −1/−1 a mais a um alvo escolhido). Com Pacto na Encruzilhada ela sai no turno 6. Depois disso, Sabá nos familiares e Morrigan fecham a partida. Contra-jogo do oponente: remoção dura (destroy/bounce), ou matar os familiares antes para que ela não possa ser invocada.

## Balanço
Orçamento P = 2·7+1 + 2·1 (Sacrifício 1) = 17 pts; Lendária pode ir até 19. Gasto: ATK 5 + Vida 7 + Despertar: −2/−2 permanente a todas as inimigas (4 pontos de debuff em área × 1,5, por analogia com dano em área = 6 pts) = 18. Lendária +1.
Rodada 1 de balanceamento: era 6/7 (70,5 % no espelho, 1,4 mortes por jogada). O Analista propôs 5/6; apliquei só −1 ATK porque a regra nova de Despertar já desfez o laço Caldeirão → Hécate de volta com outro −2/−2, e o deck está em 46 %. A bruxa encolhe o oponente — não precisa também bater como Leviatã. Nota: a tabela §10 não precifica debuff em área; se o simulador preferir o espelho de "buff em todas as aliadas" (×3 → 12 pts), a carta estoura e deve virar −1/−1 ou perder corpo.

## Dados
```json
{
  "id": "bru_hecate",
  "nome": "Hécate, Senhora das Encruzilhadas",
  "cultura": "bruxaria",
  "tipo": "entidade",
  "custo": 7,
  "atk": 5,
  "vida": 7,
  "lendaria": true,
  "keywords": [],
  "sacrificio": 1,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [ { "op": "buff", "alvo": "all_enemy_entities", "atk": -2, "vida": -2, "perm": true } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1girl, solo, goddess with three faces, three heads on one body, one face front one face left one face right, adult woman, tall imposing, long dark hair, black and purple robes, silver crescent crown, holding a burning torch in each hand, iron key on her belt, two black dogs at her feet, standing where three dirt roads meet, offering bowl on the ground, dead trees, dark moon, mist, purple and green, torch firelight, rim lighting, imposing, full body
```

## Prompt Krea 2
Atributos obrigatórios: deusa grega de três cabeças num só corpo (três faces: frente, esquerda, direita) · uma tocha acesa em cada mão · túnica preta e roxa e coroa crescente de prata · chave de ferro no cinto · cão preto na encruzilhada
```krea
Hecate, a tall imposing adult Greek goddess, stands where three dirt roads meet at night. She has one single body with exactly three heads joined at the neck: one face looks straight forward, one face looks to her left and one face looks to her right. Each of the three faces is a calm adult woman with olive skin and long dark hair. She has exactly two normal arms, and each hand holds a burning torch. She wears long black and purple robes that cover her chest, a silver crescent moon crown on the middle head and a large iron key on her belt. A small black dog sits at her feet. The two torches are the strong light source.
```
