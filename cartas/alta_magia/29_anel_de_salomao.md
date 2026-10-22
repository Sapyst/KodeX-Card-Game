# Anel de Salomão

| Campo | Valor |
|---|---|
| Cultura | alta magia |
| Tipo | Relíquia |
| Custo | 2 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
A portadora ganha +1/+2 e Ímpeto. Sempre que ela atacar, silencie uma Entidade inimiga.

## Contexto mitológico
O Anel de Salomão é a relíquia fundadora da magia cerimonial. No *Testamento de Salomão* (texto grego dos séc. I–III d.C.), o rei reza pelo seu operário atormentado por um demônio, e o arcanjo Miguel desce com um anel gravado com um selo: com ele Salomão convoca Ornias, Belzebu, Asmodeu e dezenas de outros, **interroga cada um sobre seu nome, seu ofício e o anjo que o frustra**, e os põe a carregar pedra para o Templo. É a origem de toda a literatura dos catálogos de espíritos — inclusive da Goetia.

No Lemegeton, o Anel é de prata e serve para proteger o mago do hálito de Astaroth e de Beleth: "segure-o diante do rosto". Agrippa (*De occulta philosophia* I.47) discute anéis mágicos como receptáculos de virtudes planetárias; a tradição árabe faz do anel o instrumento com que Salomão comandava os djinn e o vento. Perdê-lo — como numa lenda em que um demônio o lança ao mar — é perder o reino.

A carta é o anel no dedo: quem o usa ganha a autoridade do rei (+1/+1 e Ímpeto) e, ao avançar, cala um espírito — tira-lhe o nome, o ofício, as palavras-chave.

## Papel no jogo
Silêncio repetível: cada ataque da portadora remove as habilidades de uma Entidade inimiga — Guarda, Furtivo, Último Sopro, auras — preparando o alvo para Dantalion roubar ou para Andras matar. Ímpeto deixa a portadora atacar no turno em que entra; em Vassago ou Marbas, dá um corpo que ataca e controla ao mesmo tempo. Morre com a portadora; equipe em quem o oponente não vai alcançar fácil.

## Balanço
Orçamento P = 2·2+1 = 5 pts + 1 (Relíquia) = 6. Gasto: +1 ATK / +2 Vida permanentes (3) + Ímpeto (1) + silenciar Entidade inimiga ao atacar (2, repetível mas exige ataque) = 6. Dentro.
Rodada 2 de balanceamento (pacote CA3 do Analista): +1/+1 → +1/+2 (+1,3 pp medido); a portadora precisa sobreviver ao primeiro ataque para silenciar de novo.

## Dados
```json
{
  "id": "alt_anel_de_salomao",
  "nome": "Anel de Salomão",
  "cultura": "alta_magia",
  "tipo": "reliquia",
  "custo": 2,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_equip", "acoes": [
      { "op": "buff", "alvo": "equipped", "atk": 1, "vida": 2, "perm": true },
      { "op": "give_keyword", "alvo": "equipped", "keyword": "impeto" } ] },
    { "gatilho": "equipped_attacks", "acoes": [ { "op": "silence", "alvo": "enemy_entity" } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, object focus, close-up, single silver ring, signet ring, ring floating above a dark stone altar, hexagram engraved on the bezel, hexagram glowing, rings of light circling the ring, ghostly demon face behind the ring, demon mouth sealed shut, spectral face fading, velvet cloth on the altar, candles, dark chamber, black and gold, red candlelight, dust particles, dramatic shadows, high contrast, dark scene
```

## Prompt Krea 2
Atributos obrigatórios: um único anel-sinete de prata flutuando sobre altar de pedra · hexagrama gravado brilhando no engaste · anéis de luz girando ao redor · rosto espectral de demônio ao fundo, de boca selada
```krea
A single heavy silver signet ring floats above a dark stone altar covered with a deep red velvet cloth. The flat bezel of the ring is engraved with a six-pointed hexagram that glows bright white-gold. Thin circles of light orbit the ring like halos. Behind it, faint and fading, hangs the ghostly face of a demon whose mouth is sealed shut, silenced. Two candles stand at the edges of the altar in a dark chamber. The hexagram's glow is the strongest light, reflecting along the polished silver band.
```
