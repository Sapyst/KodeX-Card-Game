# Baba Yaga

| Campo | Valor |
|---|---|
| Cultura | bruxaria |
| Tipo | Entidade |
| Custo | 5 Fé |
| ATK / Vida | 3 / 5 |
| Palavras-chave | Sacrifício 1 |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Sacrifício 1. Despertar: devore uma Entidade inimiga à escolha (destrua-a).

## Contexto mitológico
Baba Yaga é a velha da floresta dos contos russos e eslavos: nariz que toca o teto, perna de osso, dentes de ferro. Mora numa *izbá* que gira sobre pés de galinha e só se abre quando se diz "cabaninha, cabaninha, fica de costas para a floresta e de frente para mim"; a cerca é de ossos humanos e os postes têm caveiras cujos olhos brilham à noite. Voa num pilão, remando com o socador e apagando o rastro com a vassoura. Fareja o visitante — "cheira a russo aqui!" — e come quem não cumpre suas tarefas.

No conto "Vasilisa, a Bela" (Afanasiev, nº 104), a menina mandada pela madrasta a buscar fogo é posta a separar milho de joio e papoula de terra; cumpre tudo com a ajuda da boneca da mãe morta, e Baba Yaga, descobrindo que ela é protegida por uma bênção, expulsa-a — mas dá-lhe a caveira de fogo que, em casa, incinera a madrasta e as irmãs. Vladimir Propp (*As raízes históricas do conto maravilhoso*, 1946) lê Baba Yaga como a guardiã da fronteira entre o mundo dos vivos e o reino dos mortos: a cabana é a porta, as tarefas são o rito de iniciação, e ela é ao mesmo tempo devoradora e doadora.

Na carta ela é as duas coisas. Chega exigindo um sacrifício — alguém tem que entrar na cabana — e, uma vez na mesa, come o inimigo que escolher.

## Papel no jogo
A primeira Entidade de pacto do deck: paga-se com um Sapo (que ainda dispara o Último Sopro) ou uma Strix — ou com um Gato, lembrando que Sacrifício **não** aciona Renascer e o Gato não volta —, e ganha-se uma 3/5 que remove a melhor Entidade inimiga ao entrar. É a resposta pesada do turno 5. Com Pacto na Encruzilhada sai no turno 4. Depois de entrar é um corpo grande que exige que o oponente gaste remoção. Risco: sem familiar em campo ela fica presa na mão — por isso o deck tem tantos corpos baratos.

## Balanço
Orçamento P = 2·5+1 + 2·1 (Sacrifício 1) = 13 pts. Gasto: ATK 3 + Vida 5 + Despertar: destruir Entidade inimiga escolhida (5 pts) = 13. Dentro.
Rodada 1 de balanceamento: era 4/5 (14 com `destroy` a 5 pts; 63 % no espelho).

## Dados
```json
{
  "id": "bru_baba_yaga",
  "nome": "Baba Yaga",
  "cultura": "bruxaria",
  "tipo": "entidade",
  "custo": 5,
  "atk": 3,
  "vida": 5,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 1,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [ { "op": "destroy", "alvo": "enemy_entity" } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1girl, solo, very old crone, hag, deeply wrinkled face, long hooked nose, wild grey hair, headscarf, iron teeth, patched peasant dress, sitting inside a giant wooden mortar, mortar flying in the air, holding a large pestle like an oar, swooping over a dark pine forest, wooden hut standing on two giant chicken legs below, fence of bones with glowing skulls, full moon, purple and green, moonlight, glowing eyes, rim lighting, dark atmosphere, dynamic pose, full body
```

## Prompt Krea 2
Atributos obrigatórios: anciã eslava muito velha · perna esquerda de osso (canela e pé de esqueleto) · nariz longo e adunco e dentes de ferro · lenço e vestido camponês remendado · pilão grande na mão
```krea
Baba Yaga, a very old Slavic Russian woman about 90 years old, with deeply wrinkled pale skin, a very long hooked nose and wild grey hair under a faded red headscarf, grins to show a row of grey iron metal teeth. She stands in a pine forest in a patched brown peasant dress that covers her chest and ends at the knees. Her right leg is a normal human leg with a bare foot. Her left leg has no flesh below the knee: the left shin and left foot are a bare yellowed skeleton, visible bones only. She has two normal arms; both hands grip one single large wooden pestle. Behind her stands a small wooden hut on two giant chicken legs. A full moon lights the scene.
```
