# Espelho de Bronze

| Campo | Valor |
|---|---|
| Cultura | taoismo |
| Tipo | Relíquia |
| Custo | 2 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 2 |

## Texto da carta
A portadora ganha +1/+1 e Furtivo. Ao equipar, silencie uma Entidade inimiga.

## Contexto mitológico
"As coisas velhas, de dez mil anos, são capazes de tomar forma humana para iludir os olhos dos homens — mas não conseguem alterar sua forma verdadeira dentro de um espelho." A frase é de Ge Hong, *Baopuzi*, cap. 17 ("Dengshe", "Subir montanhas e atravessar rios"), que recomenda ao taoista que entra nas montanhas levar às costas um espelho de bronze de nove polegadas ou mais: os espíritos, ao se aproximarem por trás, veem-se refletidos como são — raposa, tartaruga, árvore velha — e fogem, ou ficam paralisados de vergonha. O espelho não mata: desmascara.

O espelho de bronze polido é, desde os Zhou e sobretudo nos Han, um objeto cosmológico: o verso traz o padrão TLV (o quadrado da terra dentro do círculo do céu), os Quatro Símbolos, inscrições pedindo longevidade e, nos Tang, as Oito Trigramas. O *Gujing ji* ("Registro de um Espelho Antigo", Wang Du, Tang) narra um espelho que revela e destrói demônios por onde passa; o espelho *bagua* pendurado sobre a porta é o mesmo objeto em versão doméstica. Dianmu, a Mãe do Relâmpago, carrega dois espelhos cujos reflexos são os raios.

Como Relíquia, o espelho faz duas coisas: quem o porta não é visto pelo que é (Furtivo) e o que ele reflete perde a máscara (silêncio).

## Papel no jogo
Segundo e terceiro silêncios do deck (duas cópias desde a revisão; o Caldeirão dos Nove Tripés saiu), em Relíquia barata: desarma Guarda, Renascer ou aura inimiga e ainda deixa a portadora Furtiva até atacar — ideal para proteger Lü Dongbin ou He Xiangu de Ritos e Selos inimigos enquanto ficam atrás sem atacar. Pouco corpo (+1/+1); é carta de utilidade, não de estatísticas.

## Balanço
Orçamento P = 2·C+1 = 5 pts, +1 grátis de Relíquia = 6. Gasto: +1 ATK (1) + +1 Vida (1) + Furtivo (1) + silenciar Entidade inimiga (2) = 5. Dentro.

## Dados
```json
{
  "id": "tao_espelho_de_bronze",
  "nome": "Espelho de Bronze",
  "cultura": "taoismo",
  "tipo": "reliquia",
  "custo": 2,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_equip", "acoes": [
      { "op": "buff", "alvo": "equipped", "atk": 1, "vida": 1, "perm": true },
      { "op": "give_keyword", "alvo": "equipped", "keyword": "furtivo" },
      { "op": "silence", "alvo": "enemy_entity" } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, object focus, round chinese bronze mirror, polished reflective disc, ornate bronze rim, green patina, red tassel hanging from knob, mirror standing upright on stand, fox demon reflection inside mirror, fox spirit revealed in reflection, ghostly glow, dark forest, night, mountain path, jade green and vermilion, mist, ink wash feel, cold glint, cold moonlight, dramatic lighting
```

## Prompt Krea 2
Atributos obrigatórios: espelho redondo de bronze polido · borda ornamentada com pátina verde · borla vermelha · raposa-demônio revelada no reflexo · suporte de madeira
```krea
A round polished Chinese bronze mirror stands upright on a carved wooden stand, with no people present. Its ornate bronze rim has green patina and a red silk tassel hangs from the knob at the top. The reflective disc shows the ghostly glowing image of a fox demon revealed in the reflection, though no fox stands in front of it. The mirror rests on a mountain path in a dark forest at night, lit by a cold moonlight glint on the bronze.
```
