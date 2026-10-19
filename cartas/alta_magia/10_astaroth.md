# Astaroth, o Duque Revelador

| Campo | Valor |
|---|---|
| Cultura | alta magia |
| Tipo | Entidade |
| Custo | 4 Fé |
| ATK / Vida | 3 / 5 |
| Palavras-chave | Sacrifício 1, Despertar |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Sacrifício 1. Despertar: compre 2 cartas.

## Contexto mitológico
Astaroth é o 29º espírito da *Ars Goetia*, um Grande Duque que aparece como um anjo "danoso" montado num dragão infernal, com uma víbora na mão direita. O mago não deve deixá-lo aproximar-se, por causa do hálito pestilento — deve segurar o Anel mágico diante do rosto. Ele responde com verdade sobre passado, presente e futuro, **revela todos os segredos**, conta de bom grado como os anjos caíram (e como ele próprio caiu) e ensina as ciências liberais. Governa 40 legiões.

O nome é a forma masculinizada de Astarte, a deusa fenícia (Ashtoreth na Bíblia), via os demonólogos medievais; o *Grimorium Verum* e o *Grimório do Papa Honório* o colocam na tríade suprema ao lado de Lúcifer e Belzebu. Collin de Plancy o desenhou nu sobre um dragão magro, com a serpente na mão e uma coroa.

A carta é o pacto do conhecimento: você entrega uma criatura (Sacrifício 1) e Astaroth revela — compra 2 cartas. O corpo grande e o hálito venenoso ficam nos 3/5.

## Papel no jogo
Primeira grande jogada de "pacto" do deck, já no turno 4 (ou 3 com Azoth): sacrifica um Homúnculo (que ainda compra 1) e Astaroth compra mais 2 — três cartas por um corpo 3/5. É a vantagem de cartas que o deck de controle precisa para ter sempre a resposta. Exige Entidade em campo; se o oponente limpou a mesa, fica preso na mão.

## Balanço
Orçamento P = 2·4+1 = 9 pts; Sacrifício 1 = −2 de custo → orçamento efetivo 11. Gasto: ATK 3 + Vida 5 + comprar 2 (3) = 11. Dentro.

## Dados
```json
{
  "id": "alt_astaroth",
  "nome": "Astaroth, o Duque Revelador",
  "cultura": "alta_magia",
  "tipo": "entidade",
  "custo": 4,
  "atk": 3,
  "vida": 5,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 1,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [ { "op": "draw", "n": 2 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1other, solo, angel rider, gaunt ugly human face, golden crown on the rider's head, dark feathered wings, rider seated on the back of a black dragon, dragon below the rider, red glowing veins on the dragon, green viper in the rider's right hand, snake raised toward viewer, left hand open, green pestilent breath, dark ritual hall, cracked stone floor, candles, black and gold, red candlelight, dramatic shadows, full body
```

## Prompt Krea 2
Atributos obrigatórios: anjo caído de rosto magro e feio, coroa de ouro · asas escuras de penas · túnica escura que cobre o corpo · víbora verde na mão direita · montado num dragão negro magro com veias vermelhas · hálito verde pestilento
```krea
Astaroth, a fallen angel in the form of a gaunt adult man with a sunken, ugly, sickly face and a golden crown. He has two dark feathered wings and two normal arms. He wears a long dark torn tunic that covers his body. In his right hand he holds up a live green viper toward the viewer; his left hand rests open on his knee. He sits astride a lean black dragon with glowing red veins, the dragon's head low and snarling beneath him. A faint green pestilent mist leaks from his mouth. A dark ritual hall with cracked stone floor, lit by red light from the dragon's veins.
```
