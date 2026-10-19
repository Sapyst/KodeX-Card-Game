# Ritual Menor do Pentagrama

| Campo | Valor |
|---|---|
| Cultura | alta magia |
| Tipo | Rito |
| Custo | 4 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Devolva todas as Entidades inimigas à mão do dono.

## Contexto mitológico
O Ritual Menor de Banimento do Pentagrama (LBRP, *Lesser Banishing Ritual of the Pentagram*) é o rito fundamental da Golden Dawn, ensinado ao Neófito no grau 0=0 e praticado diariamente por todos os graus. O mago faz a **Cruz Cabalística** (toca testa, peito, ombros com as palavras *Ateh, Malkuth, ve-Geburah, ve-Gedulah, le-Olam, Amen*), traça com a adaga um pentagrama flamejante em cada quadrante vibrando um nome divino (YHVH ao leste, Adonai ao sul, Eheieh ao oeste, AGLA ao norte), une-os num círculo e invoca os quatro arcanjos — "diante de mim Rafael, atrás de mim Gabriel, à minha direita Miguel, à minha esquerda Uriel" — fechando com a Cruz de novo.

Seu efeito, segundo Regardie (*The Golden Dawn*, vol. I), é **limpar o espaço de toda influência que não foi convidada**: espíritos, impressões astrais, o próprio ruído mental. Crowley o manteve na A∴A∴ (*Liber O*) e o recomendava antes e depois de qualquer operação; é o rito que Neuburg deveria ter feito melhor no deserto.

A carta é o banimento completo: tudo o que o oponente invocou é expulso do círculo — não destruído, devolvido à mão, porque o LBRP não mata, só manda embora.

## Papel no jogo
Reset de tabuleiro do deck de controle: o oponente investiu quatro turnos de Fé em criaturas e precisa pagar tudo de novo, enquanto você mantém as suas. Devastador contra decks que buffaram Entidades (o buff se perde) e contra tokens (desaparecem — tokens devolvidos à mão deixam de existir). Fraco contra decks de poucas Entidades grandes com Despertar forte, que voltam e repetem o efeito.

## Balanço
Orçamento P = 2·4+1 = 9 pts. Gasto: devolver Entidade inimiga à mão (2) × até 4 Entidades = 8 no máximo, 4–6 no caso típico. Dentro.

## Dados
```json
{
  "id": "alt_ritual_menor_pentagrama",
  "nome": "Ritual Menor do Pentagrama",
  "cultura": "alta_magia",
  "tipo": "rito",
  "custo": 4,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [ { "op": "bounce", "alvo": "all_enemy_entities" } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1boy, solo, magician, hooded black robe, human face, ritual dagger in the right hand, arm extended forward, tracing a glowing pentagram in the air, five-pointed star of light, shadowy spirits blown outward away from him, spirits dissolving into smoke, strong wind, robe billowing, chalk circle on stone floor, four candles at the circle edges, ritual chamber, black and gold, red candlelight, dynamic pose, dramatic shadows, full body
```

## Prompt Krea 2
Atributos obrigatórios: mago inglês adulto de manto preto · braço direito estendido com adaga ritual traçando pentagrama de luz no ar · espíritos sombrios sendo soprados para longe · vento forte, manto esvoaçando
```krea
A pale English magician in his early thirties, young face, clean-shaven, short dark hair, hood down, wearing a long black robe. He has two normal arms. He stands inside a chalk circle with exactly four candles. His right arm is extended straight forward and his right hand firmly grips a ritual dagger by its handle; the dagger's point touches a large five-pointed star of white-gold light floating in the air in front of him, one point up, and a bright line of light trails from the dagger point into the star, as if he is drawing it. His left hand is open and empty, held low at his side. A strong wind bursts from the star: his robe billows, candle flames lean, and shadowy spirit shapes blow away into smoke.
```
