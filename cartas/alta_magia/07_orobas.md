# Orobas, o Príncipe Fiel

| Campo | Valor |
|---|---|
| Cultura | alta magia |
| Tipo | Entidade |
| Custo | 3 Fé |
| ATK / Vida | 1 / 4 |
| Palavras-chave | Guarda |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Guarda. No início do seu turno, cure 2 de Vida desta.

## Contexto mitológico
Orobas é o 55º espírito da *Ars Goetia*, um Príncipe que aparece primeiro como cavalo e, a pedido do mago, toma forma humana. Revela passado, presente e futuro, concede dignidades e o favor de amigos e inimigos, e — o traço que o distingue de quase todos os outros — **é fiel ao exorcista e não permite que ele seja tentado por espírito algum**. Governa 20 legiões. Weyer (*Pseudomonarchia*, 1577) já o descreve assim, e Collin de Plancy o desenhou como cavalo de pé, ereto, no *Dictionnaire Infernal* (1863).

Num catálogo onde Andras mata o mago distraído e Furfur mente fora do triângulo, Orobas é a exceção: o espírito que protege. Por isso é um dos mais evocados na prática moderna como "guardião" — o cavalo que fica diante da porta.

A carta é a muralha barata do deck: Guarda (os inimigos têm de atacá-lo primeiro), pouca força, muita vida, e no início de cada turno se recompõe — a lealdade que não se gasta.

## Papel no jogo
"Cola" defensiva do meio de jogo: segura agressão enquanto o mago acumula Fé para o pacto. Combina com Sigillum Dei Aemeth (+0/+3, mais Guarda) para virar uma parede que se cura de 2 por turno, e com Pedra de Visão para comprar sem risco. Ruim contra Ritos de destruição direta e contra silêncio.

## Balanço
Orçamento P = 2·3+1 = 7 pts. Gasto: ATK 1 + Vida 4 + Guarda (1) + curar 2 em si a cada início de turno (1) = 7. Dentro.

## Dados
```json
{
  "id": "alt_orobas",
  "nome": "Orobas, o Príncipe Fiel",
  "cultura": "alta_magia",
  "tipo": "entidade",
  "custo": 3,
  "atk": 1,
  "vida": 4,
  "lendaria": false,
  "keywords": ["guarda"],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "start_turn", "acoes": [ { "op": "heal", "alvo": "self", "n": 2 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, demonic horse, black horse, standing upright on its hind legs, noble posture, flowing dark mane, glowing golden eyes, hooves planted firmly, standing guard, in front of a tall closed door, facing viewer, protective stance, faint golden healing aura, golden sparks around its body, stone archway, iron candle sconces, heavy dark curtains, stone floor, faded chalk circle, black and gold, red candlelight, glowing sigils on the door, incense smoke, flickering flames, dramatic shadows, victorian interior, gothic architecture, full body
```

## Prompt Krea 2
Atributos obrigatórios: cavalo negro em pé sobre as patas traseiras, ereto como um homem · de frente, guardando uma porta fechada (Guarda) · olhos dourados · aura dourada de cura
```krea
Orobas, a great black horse that stands fully upright on its two hind legs like a man, tall and noble, with a long flowing black mane and calm glowing golden eyes. It has a true horse's head and horse body, four legs with hooves: the two hind hooves planted firmly on the stone floor, the two front legs held bent in front of its chest in a guarding stance. It faces the viewer directly, blocking a tall closed wooden door carved with faintly glowing sigils. A soft golden healing aura and small golden sparks surround its body. Gothic stone archway, iron candle sconces on each side, warm golden glow from the aura.
```
