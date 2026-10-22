# Babalon, a Mulher Escarlate

| Campo | Valor |
|---|---|
| Cultura | alta magia |
| Tipo | Entidade |
| Custo | 6 Fé |
| ATK / Vida | 5 / 6 |
| Palavras-chave | Sacrifício 1, Lendária |
| Lendária | sim |
| Cópias no deck | 1 |

## Texto da carta
Sacrifício 1. Sempre que outra Entidade morrer, esta ganha +1/+1.

## Contexto mitológico
Babalon é a deusa central da Thelema de Aleister Crowley. Nasce da leitura invertida do Apocalipse 17 — a "grande prostituta" montada na Besta de sete cabeças, com a taça cheia de abominações — e se revela a Crowley nos Aethyrs enochianos em 1909 (*The Vision and the Voice*, Liber 418), sobretudo nos Aethyrs 15º a 12º. Ali ela é a Mulher Escarlate, a Mãe das Abominações, a Cidade das Pirâmides: a porta do Abismo.

Sua Taça é o símbolo decisivo. Quem quer atravessar o Abismo entre Chesed e Binah precisa **verter nela cada gota do próprio sangue** — isto é, dissolver inteiramente o ego — para renascer como Magister Templi. Quem guarda uma gota é despedaçado por Choronzon. Babalon é, assim, a face acolhedora da mesma travessia em que Choronzon é a face que dispersa; Crowley a invoca na 12ª Aethyr com a fórmula da Taça e da Besta, e a torna par da Besta 666 (ele próprio) no sistema do novo Aeon. O nome grafado com "a" e "o" (BABALON, e não Babylon) soma 156 na gematria hebraica — o mesmo valor de *Tzion* (Sião), coincidência que Crowley explora no comentário a Liber 418; a fórmula da Taça está em *Liber Cheth vel Vallum Abiegni* (Liber 156).

A carta é a Taça que bebe: a cada morte em qualquer campo — aliada ou inimiga, sacrifício ou combate — Babalon cresce. O Sacrifício 1 é o preço de entrada: a Taça só começa a encher depois que ela está na mesa.

## Papel no jogo
Lendária de pressão do deck de controle: entra no turno 6 como 5/6 (o Sacrifício que paga a invocação ocorre antes de ela estar em campo e **não** a alimenta) e cresce com tudo o que o deck faz — Homúnculos morrendo, tokens de Paimon e dos Elementais sendo trocados, Andras matando, o oponente perdendo criaturas em combate. Depois de três ou quatro mortes é 8/9 ou 9/10 e fecha o jogo. Vulnerável a devolver à mão (perde o crescimento) e a silêncio; proteja-a com Pentagrama Flamejante.

## Balanço
Orçamento P = 2·6+1 = 13 pts; Sacrifício 1 = −2 → 15; Lendária até +2 → 17. Gasto: ATK 5 + Vida 6 = 11 + dois gatilhos repetíveis (`ally_dies`, `enemy_dies`) com +1/+1 permanente, valor cheio = 2 cada → 15 pela tabela. Como num deck de Sacrifício e tokens espera-se 3 mortes enquanto ela vive (medido: 1,7–6 gatilhos por partida, média ~3,5), o valor realista é 11 + 3×2 = 17 = teto lendário. Lendária +2.
Rodada 2 de balanceamento (pacote CA3 do Analista): volta a 5/6 (a revisão a havia baixado para 4/6 por contar 3–4 gatilhos; o Analista mediu ~3). +1,6 pp.

## Dados
```json
{
  "id": "alt_babalon",
  "nome": "Babalon, a Mulher Escarlate",
  "cultura": "alta_magia",
  "tipo": "entidade",
  "custo": 6,
  "atk": 5,
  "vida": 6,
  "lendaria": true,
  "keywords": [],
  "sacrificio": 1,
  "efeitos": [
    { "gatilho": "ally_dies", "acoes": [ { "op": "buff", "alvo": "self", "atk": 1, "vida": 1, "perm": true } ] },
    { "gatilho": "enemy_dies", "acoes": [ { "op": "buff", "alvo": "self", "atk": 1, "vida": 1, "perm": true } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1girl, solo, scarlet woman, long red hair, flowing red dress, fully clothed, golden crown, one golden chalice raised high, chalice overflowing with glowing red liquid, riding a monstrous black beast, seated on the beast's back, seven-headed beast, many dragon heads, horns, skulls at the beast's feet, triumphant expression, dark ritual hall, tall candles, black and gold, scarlet and gold, red candlelight, dramatic shadows, wide shot, full body
```

## Prompt Krea 2
Atributos obrigatórios: mulher adulta de cabelos ruivos longos, vestido escarlate que cobre peito e corpo · coroa de ouro · taça dourada erguida transbordando luz vermelha · montada numa besta negra de exatamente sete cabeças
```krea
Babalon, the Scarlet Woman, a tall adult woman with long red hair and a proud, triumphant face, wearing a golden crown. She wears a long flowing scarlet gown with long sleeves and a high neckline that fully covers her chest and body. She has two normal arms. In her raised right hand she holds a golden chalice overflowing with glowing red light. She sits sideways on the back of a monstrous black beast that has exactly seven dragon heads on seven long necks, each head with horns. A dark ritual hall with tall candles; the chalice is the brightest light, casting scarlet glow over her and the beast.
```
