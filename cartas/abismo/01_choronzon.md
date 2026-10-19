# Choronzon, Habitante do Abismo

| Campo | Valor |
|---|---|
| Cultura | abismo (módulo especial — Conjunto do Abismo) |
| Tipo | Entidade |
| Custo | — (não pode ser invocado pagando Fé) |
| ATK / Vida | 3 / 3 |
| Palavras-chave | — |
| Lendária | sim |
| Cópias no deck | 1 |

## Texto da carta
Só pode ser invocado pelo efeito de Sigilo 333. Quando Choronzon entra em campo, você vence o jogo.

## Contexto mitológico
Choronzon aparece primeiro nos diários enochianos de John Dee e Edward Kelley (1580s) como *Coronzon*, nome que os anjos dão ao "grande inimigo" — o diabo expulso do Éden. Fica adormecido por três séculos até Aleister Crowley, que o transforma na figura central da travessia do Abismo: o vazio entre os sefirot inferiores e os três supernos da Árvore da Vida, onde a personalidade se dissolve.

Em dezembro de 1909, no deserto perto de Bou Saâda (Argélia), Crowley e Victor Neuburg invocam o 10º Aethyr, ZAX. Neuburg permanece dentro de um círculo traçado na areia; Crowley entra no triângulo da arte. Segundo *The Vision and the Voice*, Choronzon se manifesta trocando de forma — uma mulher que Neuburg amara, uma serpente, o próprio Crowley, um velho — tenta persuadir o escriba a sair do círculo, apaga parte da linha com areia e o ataca. É repelido com a adaga ritual e o nome de Deus.

Seu número é **333**: dispersão, a mente que se despedaça, "o único verdadeiro inimigo". Não é um demônio que se derrota — é o que acontece a quem o invoca sem estar pronto. Por isso a carta não ataca nem defende: se chegou à mesa, o jogo acabou.

## Papel no jogo
Condição de vitória alternativa (o "Exódia" do Gods Kodex). Fora do balanceamento por decisão de design: o custo está em juntar as 4 cartas do Conjunto do Abismo e pagar 7 Fé em turnos separados enquanto o oponente vê as peças no campo.

## Balanço
Fora do orçamento por definição. Contra-jogo: destruir a portadora do Triângulo da Arte (a Relíquia vai ao cemitério) ou forçar o disparo do Círculo de Proteção antes do Sigilo.

## Dados
```json
{ "id": "aby_choronzon", "nome": "Choronzon, Habitante do Abismo", "cultura": "abismo", "tipo": "entidade",
  "custo": 99, "atk": 3, "vida": 3, "lendaria": true, "keywords": [], "sacrificio": 0,
  "efeitos": [ { "gatilho": "on_play", "acoes": [ { "op": "win" } ] } ], "usos": null }
```

## Prompt de arte
```prompt
1other, shapeshifting demon, unstable body made of swirling sand, multiple faces merging, woman face, serpent body, old man face, dissolving into sand, standing inside a glowing triangle drawn on desert sand, desert night, starry sky, sand yellow and void black, eerie pale light, full body
```

## Prompt Krea 2
Atributos obrigatórios: demônio mutante de corpo de areia em redemoinho, em pé dentro de um triângulo brilhante · exatamente três rostos fundindo-se na cabeça: mulher, velho e serpente · manto esfarrapado de areia · deserto noturno estrelado
```krea
Choronzon, a shapeshifting demon of the Abyss, stands inside a glowing three-sided triangle drawn on desert sand; the triangle has exactly three straight sides and three corners. Its tall, roughly human body is made of swirling sand and black dust, wrapped in a ragged robe of sand that covers the whole body. It has one neck carrying exactly three heads side by side and no others: on the left the face of a young woman with long black hair, in the middle the face of an old man with a long white beard, on the right the scaly head of a serpent with a forked tongue. There is no fourth face and no second old man. It has exactly two arms whose hands crumble into sand. Desert night, starry sky, pale glow of the triangle lighting it from below.
```
