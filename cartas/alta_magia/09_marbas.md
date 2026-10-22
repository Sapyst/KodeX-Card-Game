# Marbas, o Leão das Doenças

| Campo | Valor |
|---|---|
| Cultura | alta magia |
| Tipo | Entidade |
| Custo | 4 Fé |
| ATK / Vida | 3 / 4 |
| Palavras-chave | Despertar |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Despertar: Silencie uma Entidade inimiga (ela perde palavras-chave e efeitos).

## Contexto mitológico
Marbas (ou Barbas) é o quinto espírito da *Ars Goetia*, um Grande Presidente que aparece como um grande leão e, a pedido, toma forma humana. Responde com verdade sobre coisas ocultas e secretas, **causa doenças e as cura**, dá sabedoria nas artes mecânicas e **muda homens para outras formas**. Governa 36 legiões. Weyer o lista como Marbas *alias* Barbas na *Pseudomonarchia Daemonum* (1577), com os mesmos ofícios.

Entre os 72, Marbas é o espírito do corpo: o que adoece e sara, o que desfigura e repara. Os grimórios o associam à medicina e à engenharia — ao que se pode consertar ou quebrar com conhecimento. É também um dos poucos cuja imagem animal (o leão) os ilustradores mantiveram sem monstruosidades.

A carta traduz "causar doença" e "mudar de forma" em **silêncio**: a Entidade inimiga perde o que a tornava especial — Guarda, Furtivo, Último Sopro, auras. Fica só o corpo doente.

## Papel no jogo
Remoção de habilidades: tira Guarda do bloqueador para que o Silfo passe, tira Último Sopro antes de Andras matar, tira efeitos perigosos de uma Entidade que Dantalion vai roubar (ou que Babalon vai ver morrer). Corpo 3/4 sólido no turno 4. Não resolve stats puros — contra um 5/5 sem texto é só um bloqueador.

## Balanço
Orçamento P = 2·4+1 = 9 pts. Gasto: ATK 3 + Vida 4 + silenciar Entidade escolhida (estimado 2: menos que devolver à mão, pois o corpo fica) = 9. Dentro.

## Dados
```json
{
  "id": "alt_marbas",
  "nome": "Marbas, o Leão das Doenças",
  "cultura": "alta_magia",
  "tipo": "entidade",
  "custo": 4,
  "atk": 3,
  "vida": 4,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [ { "op": "silence", "alvo": "enemy_entity" } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, giant lion, huge male lion, golden mane, stern human-like eyes, glowing eyes, mouth closed, pressing one heavy paw down, snuffing out a glowing sigil under its paw, sigil fading into grey smoke, extinguished candles, thin smoke trails, shadow on the wall shaped like a man, dark ritual chamber, stone pillars, heavy curtains, stone floor, black and gold, red candlelight, glowing sigils, incense burner, wax drippings, dust particles, dramatic shadows, victorian interior, gothic architecture, high contrast, full body
```

## Prompt Krea 2
Atributos obrigatórios: leão macho enorme, juba dourada · olhos quase humanos, sérios · pata pesada esmagando um sigilo brilhante que se apaga · velas recém-apagadas soltando fumaça
```krea
Marbas, a huge male lion with a thick golden mane and stern, almost human amber eyes, mouth closed. He is a real lion with four legs. He stands in a dark ritual chamber and presses his right front paw heavily down onto a glowing sigil carved in the stone floor; under his paw the sigil's light fades and turns into grey smoke. Around him, candles have just been snuffed out and release thin trails of smoke. On the wall behind him, his shadow is cast in the shape of a standing man. The last glow of the dying sigil lights his mane and face from below.
```
