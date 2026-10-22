# Edward Kelley, o Vidente

| Campo | Valor |
|---|---|
| Cultura | alta magia |
| Tipo | Entidade |
| Custo | 2 Fé |
| ATK / Vida | 1 / 1 |
| Palavras-chave | Furtivo, Despertar |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Furtivo. Despertar: Compre uma Relíquia do seu deck.

## Contexto mitológico
Edward Kelley (1555–1597) foi o *skryer* — vidente — de John Dee de 1582 a 1589. Dee, matemático e astrólogo de Elizabeth I, não via nada no cristal; Kelley via. Sentado diante da pedra de visão, descrevia anjos, tábuas de letras e cenas que Dee anotava palavra por palavra em latim e inglês. Dessas sessões saiu o sistema enochiano inteiro: as 48 Chaves, as Tábuas de Vigia, os 30 Aethyrs. Casaubon publicou os diários em 1659 como *A True & Faithful Relation*, para desacreditar Dee — e acabou criando o cânone.

A lenda pinta Kelley como vigarista: teria tido as orelhas cortadas por falsificação (daí o gorro), e chegou à casa de Dee com um pó vermelho e um livro cifrado desenterrados em Glastonbury, com os quais prometia transmutar ouro. Na Boêmia, Rodolfo II o fez cavaleiro e depois o prendeu para arrancar o segredo; morreu em 1597 das feridas de uma tentativa de fuga pela muralha do castelo.

Na carta, Kelley é o vidente que **acha coisas**: furtivo (ninguém o mira até ele agir), sem força (0 de ATK — ele nunca foi mago, era o olho), e ao entrar busca uma Relíquia — o pó vermelho, a pedra, o sigilo.

## Papel no jogo
Tutor de Relíquias: puxa Pedra de Visão (compra), Sigillum Dei Aemeth (muralha) ou Anel de Salomão (silêncio). Furtivo protege-o de remoção até que ataque — enquanto não ataca é um corpo quase imune que serve de Sacrifício garantido para Dantalion ou Astaroth; com a Pedra de Visão vira 2/3 e passa a ameaçar. Ruim como bloqueador: 1/1.

## Balanço
Orçamento P = 2·2+1 = 5 pts. Gasto: ATK 1 + Vida 1 + Furtivo (1) + Despertar buscar Relíquia (2) = 5. Dentro.
Rodada 1 de balanceamento: era 0/2 — nunca atacava num deck com 1,6–7,5 de dano de ataque por partida.

## Dados
```json
{
  "id": "alt_edward_kelley",
  "nome": "Edward Kelley, o Vidente",
  "cultura": "alta_magia",
  "tipo": "entidade",
  "custo": 2,
  "atk": 1,
  "vida": 1,
  "lendaria": false,
  "keywords": ["furtivo"],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [ { "op": "search", "tipo": "reliquia" } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1boy, solo, human elizabethan scholar, ordinary man, long dark beard, black skull cap covering his ears, white ruff collar, dark scholar robe, sitting at a desk, leaning forward, gazing into a crystal ball, hands cupped around the crystal, crystal on a pale wax disc, swirling visions inside the crystal, pale blue glow lighting his face, half in shadow, candlelit study, bookshelves, scattered papers, inkwell, black and gold, red candlelight, upper body
```

## Prompt Krea 2
Atributos obrigatórios: homem inglês elisabetano de ~30 anos, barba escura · orelhas cobertas por touca preta justa (orelhas cortadas, segundo a lenda) · gola de rufo branca e toga escura · mãos em concha ao redor da bola de cristal · rosto meio na sombra (Furtivo)
```krea
A young pale English Elizabethan man about 30 years old, Edward Kelley, with a dark pointed beard, no grey hair, and a thin face. He wears a tight black linen coif, a cap tied with strings under his chin, that covers the top and both sides of his head and completely covers both ears; no ears are visible, only black cloth over the sides of his head. He wears a white starched ruff collar and a dark brown scholar's robe. He sits at a wooden desk, leaning forward, his right hand and left hand both cupped around a clear crystal ball resting on a pale wax disc. Pale blue visions swirl inside the crystal and light his face from below; the rest of him fades into deep shadow. Candlelit study behind.
```
