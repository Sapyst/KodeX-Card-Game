# Gabriel, o Mensageiro

| Campo | Valor |
|---|---|
| Cultura | cristianismo |
| Tipo | Entidade |
| Custo | 3 Fé |
| ATK / Vida | 2 / 3 |
| Palavras-chave | Despertar |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Despertar: Compre um Rito do seu deck.

## Contexto mitológico
Gabriel ("Fortaleza de Deus") é, com Miguel e Rafael, um dos três anjos nomeados na Bíblia. Aparece primeiro a Daniel, para explicar a visão do carneiro e do bode (Dn 8,16) e a profecia das setenta semanas (Dn 9,21). No Novo Testamento é o anúncio feito pessoa: aparece a Zacarias no Templo para anunciar João Batista (Lc 1,11-20) e a Maria em Nazaré para anunciar o nascimento de Jesus (Lc 1,26-38) — "Ave, cheia de graça".

Na tradição ele é o arauto celeste por excelência: o Islã o tem como transmissor do Corão, e na iconografia cristã surge ajoelhado com um lírio ou um cetro, a boca aberta na palavra. Pseudo-Dionísio o coloca entre os arcanjos, o coro dos que levam mensagens de grande peso.

A carta traduz isso em **busca**: quando Gabriel chega, a palavra certa chega com ele — um Rito do deck para a mão.

## Papel no jogo
A única busca do deck, de propósito. Puxa a resposta que falta: Talita Cumi para reviver, Exorcismo para tirar um bloqueio, Juízo Final para virar a mesa. Corpo honesto de 2/3 que ainda segura o campo. Jogado cedo, dá consistência; jogado tarde, com o deck fino, vale menos. Vulnerável a Selos inimigos de `enemy_plays_entity`, que o punem antes de a busca render.

## Balanço
Orçamento P = 2·C+1 = 7 pts. Gasto: ATK 2 + Vida 3 + buscar carta por tipo 2 = 7. Dentro.

## Dados
```json
{
  "id": "cri_gabriel",
  "nome": "Gabriel, o Mensageiro",
  "cultura": "cristianismo",
  "tipo": "entidade",
  "custo": 3,
  "atk": 2,
  "vida": 3,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [ { "op": "search", "tipo": "rito" } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1other, solo, archangel, androgynous, long golden curly hair, serene expression, large white and gold wings, golden halo, white robe with gold trim, kneeling on one knee, holding white lily, long golden trumpet on back, one hand raised in greeting, mouth open speaking, glowing scroll unrolling from his hand, messenger, humble stone room, small arched window, dawn sky, ray of holy light, gold and white, stained glass light, soft rim lighting, floating golden particles, full body
```

## Prompt Krea 2
Atributos obrigatórios: lírio branco na mão esquerda · mão direita em bênção · ajoelhado num joelho · asas brancas e douradas · auréola dourada
```krea
A tall adult archangel, Gabriel, with a serene youthful androgynous face, olive skin and long curly golden hair, kneeling on one knee in the pose of the Annunciation. Two large wings of white and gold feathers rise from his back. He has two normal arms and two hands: his left hand holds a tall white lily stem, his right hand is raised with two fingers extended in blessing, and his lips are parted as if speaking. He wears a long white robe with a gold-embroidered border under a pale blue mantle, and a golden halo circles his head. A humble stone room with a small arched window, and a strong ray of dawn light falling across him.
```
