# Sigillum Dei Aemeth

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
A Entidade equipada ganha +0/+3 e Guarda. Quando ela morrer, compre 1 carta.

## Contexto mitológico
O *Sigillum Dei Aemeth* — "Selo de Deus da Verdade" (*Aemeth*, אמת, "verdade" em hebraico) — é o disco de cera de nove polegadas que John Dee recebeu, letra por letra, de Edward Kelley em março de 1582, nas primeiras sessões com a pedra de visão (Sloane MS 3188, *Mysteriorum Liber Primus*). Traz um heptagrama dentro de heptágonos concêntricos, com nomes de Deus e dos sete anjos planetários dispostos em tabelas de letras e números, e um pentagrama central. Dee fez cinco: quatro sob os pés da Mesa Sagrada e um sobre ela, **debaixo da pedra de visão** — o cristal repousava sobre o selo, que o protegia e autenticava a visão.

O desenho descende do *Sigillum Dei* do *Liber Juratus Honorii* (séc. XIII), onde garante ao operador a visão de Deus em vida; Dee o reformou com a ajuda dos anjos. Três discos originais sobreviveram e estão no British Museum (o grande e dois dos pequenos), junto com o espelho de obsidiana e a bola de cristal. É o objeto mais famoso da magia enochiana e um dos poucos instrumentos mágicos históricos que se pode ver numa vitrine.

A carta é o selo sob o cristal: quem o porta fica protegido (+3 de Vida) e atrai sobre si todo ataque (Guarda); e, se cair, a verdade que ele guardava vira uma carta.

## Papel no jogo
Faz um guardião de qualquer corpo: em Orobas vira 1/7 que se cura 2 por turno; no Anjo, 4/11; num Homúnculo, um 1/5 com Guarda que compra 2 ao morrer (Último Sopro + Sigillum). É a resposta do deck a agressão quando os Selos já foram gastos. Fraco contra Ritos de destruição que ignoram Vida, e contra silêncio (perde Guarda).

## Balanço
Orçamento P = 2·2+1 = 5 pts + 1 (Relíquia) = 6. Gasto: +3 Vida permanente (3) + Guarda (1) + comprar 1 ao morrer (1,5) = 5,5. Dentro.

## Dados
```json
{
  "id": "alt_sigillum_dei_aemeth",
  "nome": "Sigillum Dei Aemeth",
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
      { "op": "buff", "alvo": "equipped", "atk": 0, "vida": 3, "perm": true },
      { "op": "give_keyword", "alvo": "equipped", "keyword": "guarda" } ] },
    { "gatilho": "equipped_dies", "acoes": [ { "op": "draw", "n": 1 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, object focus, close-up, high angle view, large flat pale beeswax disc, round wax tablet, engraved star in the center, concentric rings of carved symbols, disc lying flat on a dark wooden table, small crystal ball resting on top of the disc, soft golden glow around the disc, candles, quill, inkwell, stacked books, old study, black and gold, red candlelight, wax drippings, soft shadows, high contrast
```

## Prompt Krea 2
Atributos obrigatórios: grande disco de cera de abelha claro, plano, sobre mesa escura · estrela de sete pontas no centro e anéis concêntricos de símbolos gravados · pequena bola de cristal sobre o disco · brilho dourado suave
```krea
Seen from above at a high angle: a large flat round disc of pale beeswax lies on a dark wooden table. Its surface is carved with a seven-pointed star inside concentric seven-sided rings, all filled with small engraved letters and symbols, and a small pentagram at the very center. A small clear crystal ball rests on top of the disc. A soft golden protective glow rises from the carved lines. Around the disc, a quill, an inkwell, stacked old books and dripping candles in an old Elizabethan study. The candlelight and the golden glow are the light of the scene.
```
