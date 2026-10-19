# Zhang Guolao

| Campo | Valor |
|---|---|
| Cultura | taoismo |
| Tipo | Entidade |
| Custo | 3 Fé |
| ATK / Vida | 2 / 3 |
| Palavras-chave | Despertar |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Despertar: devolva uma Entidade inimiga à mão do dono.

## Contexto mitológico
Zhang Guolao (張果老, "o Velho Zhang Guo") é o único dos Oito Imortais com registro em história oficial: o *Jiu Tang shu* e o *Xin Tang shu* trazem a biografia de Zhang Guo, eremita dos montes Zhongtiao (Shanxi) que dizia ter sido ministro do imperador mítico Yao e que o imperador Xuanzong (r. 712–756) mandou buscar à corte, onde ele fez prodígios e recusou a mão de uma princesa.

Seu emblema é a mula branca que monta ao contrário, de costas para a estrada, percorrendo milhares de li por dia. Ao descansar, dobra a mula como se fosse papel e a guarda numa caixinha; quando precisa viajar, borrifa água e a mula se desdobra inteira. Carrega o *yugu*, tambor de bambu em forma de peixe, com que acompanha canções taoistas. Fontes: *Minghuang zalu* (Tang), *Taiping Guangji*, *Dongyou Ji*. É padroeiro dos anciãos e invocado por casais que querem filhos.

A dobra da mula virou mecânica: ao chegar, Zhang Guolao "dobra" uma Entidade inimiga e a devolve à mão — ela existe, mas terá de ser paga de novo.

## Papel no jogo
Resposta de tempo: devolve à mão a ameaça que o oponente acabou de pagar caro, ou a que recebeu buffs (eles somem) e Relíquia (que vai ao cemitério com a saída da portadora). Num deck sem remoção dura, é a melhor ferramenta contra Entidades de custo 5+. Pior uso: devolver um corpo barato com Despertar forte, que volta e repete o efeito.

## Balanço
Orçamento P = 2·C+1 = 7 pts. Gasto: ATK 2 + Vida 3 + Despertar "devolver Entidade inimiga à mão" (2) = 7. Dentro.

## Dados
```json
{
  "id": "tao_zhang_guolao",
  "nome": "Zhang Guolao",
  "cultura": "taoismo",
  "tipo": "entidade",
  "custo": 3,
  "atk": 2,
  "vida": 3,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [ { "op": "bounce", "alvo": "enemy_entity" } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1boy, solo, old man, long white beard, small black cap, grey robe, riding white mule, sitting backwards on mule, facing the mule's tail, mule head behind him, white donkey, four legs visible, bamboo fish drum on back, smiling, relaxed, mule walking on clouds, mountain road, sea of clouds, crescent moon, night sky, jade green and vermilion, mist, ink wash feel, soft moonlight, side view, full body
```

## Prompt Krea 2
Atributos obrigatórios: montado de costas na mula branca · olhando para a cauda da mula · tambor de bambu em forma de peixe · barba branca longa · gorro preto
```krea
An elderly Chinese man about 75 years old, long white beard, small black cap, smiling, grey cotton robe. He sits backwards on a white mule: the mule's head points to the left of the image while the old man faces the right, looking toward the mule's tail. His back faces the mule's head and his chest faces the mule's tail. The mule has four legs and long ears. Two normal arms and two hands; both hands hold a wooden drum carved in the shape of a fish in his lap. Side view, on clouds along a mountain road at night, lit by a crescent moon.
```
