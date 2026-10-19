# Vajra

| Campo | Valor |
|---|---|
| Cultura | hinduísmo |
| Tipo | Relíquia |
| Custo | 2 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Portadora: +2 ATK. Ao equipar, causa 2 de dano a uma Entidade inimiga.

## Contexto mitológico
O Vajra ("raio", "diamante") é a arma de Indra, rei dos devas e deus da tempestade — o deus mais invocado do Rigveda, com cerca de 250 hinos. O hino 1.32 é o mais célebre: Indra, embriagado de soma, ergue o vajra forjado por Tvashtar e mata Vritra, a serpente-dragão que represava as águas do mundo; os rios rompem como vacas soltas do curral e o céu e a terra tremem. O vajra é a força do trovão em forma de arma: a cabeça de raios cruzados, dura como o diamante, que nenhuma defesa resiste.

O Bhagavata Purana (6.9–10) conta a origem puranica: o asura Vritra só podia ser morto por uma arma feita dos ossos do sábio Dadhichi, que, pedido pelos deuses, abandona o corpo em meditação para que Tvashtar molde o vajra. O mesmo símbolo passou ao budismo (vajra/dorje) como emblema da indestrutibilidade.

Na carta, o raio cai no instante em que Indra o empunha: a arma é tão impacto quanto equipamento.

## Papel no jogo
A Relíquia de abertura do deck: no turno 2 ou 3, 2 de dano a um alvo (mata tokens e os corpos de 1–2 de Vida) e um portador com +2 ATK que ataca em seguida. Sobre Garuda vira um 3/2 com Ímpeto que já limpou o bloqueador pequeno; os de 3 de Vida ficam para o combate. Buscável com Matsya. Fraca sem portador em campo, e o bônus some com a morte dele — que agora não ganha Vida para resistir.

## Balanço
Orçamento P = 2·2+1 = 5 pts (+1 Relíquia = 6). Gasto: +2 ATK 2 + 2 de dano a Entidade escolhida 2 = 4. Dentro (P−2).
Rodada 2 de balanceamento (pacote H1 do Analista): saiu o +1 Vida (as quatro Relíquias −1 Vida = −5,0 pp medido em conjunto: a força do deck está em corpos que chegam à mesa com arma e sobrevivem).
Rodada 1 de balanceamento: era 3 de dano (6/6) — 3 de dano por 2 Fé mais corpo era a remoção barata que esvaziava o campo inimigo antes da rodada 4 (83,6 % de WR global).

## Dados
```json
{
  "id": "hin_vajra",
  "nome": "Vajra",
  "cultura": "hinduismo",
  "tipo": "reliquia",
  "custo": 2,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_equip", "acoes": [
      { "op": "buff", "alvo": "equipped", "atk": 2, "vida": 0, "perm": true },
      { "op": "damage", "alvo": "enemy_entity", "n": 2 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, object focus, close-up, vajra, double-ended thunderbolt scepter, curved golden prongs at both ends, central sphere grip, whole object visible, large in frame, floating horizontally, glowing diamond core, crackling lightning around it, electricity arcing, divine weapon, storm clouds, rain, dark sky, saffron and blue, electric blue lightning, golden glow, rim lighting, high contrast, centered composition
```

## Prompt Krea 2
Atributos obrigatórios: vajra dourado de duas pontas · garras curvas nas duas extremidades · núcleo de diamante · raios elétricos ao redor · céu de tempestade
```krea
The Vajra, Indra's thunderbolt weapon, shown alone as an object with no people. It is a double-ended golden scepter with a round central grip, and at each end several curved golden prongs close together into a point around a central spike. The whole object is visible, large in the frame and floating horizontally. A glowing white diamond core shines in its center, and crackling blue lightning arcs around it. Behind it is a dark storm sky with heavy rain. A bright fork of lightning behind the vajra is the strongest light.
```
