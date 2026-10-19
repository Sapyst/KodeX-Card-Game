# Tartaruga Negra do Norte

| Campo | Valor |
|---|---|
| Cultura | taoismo |
| Tipo | Selo |
| Custo | 1 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Quando uma Entidade aliada sofrer dano: cure 4 de Vida dela; ela ganha +0/+1 permanente e Guarda.

## Contexto mitológico
Xuanwu (玄武), a Tartaruga Negra — literalmente "Guerreiro Sombrio" —, é o Símbolo do norte, do inverno e da água: uma tartaruga enlaçada por uma serpente, imagem já presente nos espelhos e tijolos Han e explicada por comentadores como a união do yin (a tartaruga, que se fecha) com o yang (a serpente, que se enrola). O norte é a direção da morte e do frio, mas também da longevidade, pois a tartaruga vive mil anos e carrega nas costas o mapa do mundo — os cascos usados nos oráculos Shang eram lidos como céu e terra. O *Liji* põe Xuanwu na retaguarda do exército: quem protege as costas.

A partir dos Song a Tartaruga Negra ganha corpo humano: torna-se **Zhenwu**, o Guerreiro Perfeito (ou Xuantian Shangdi, "Imperador Supremo do Céu Sombrio"), deus descalço de cabelo solto e espada, pisando a tartaruga e a serpente — que seriam, numa versão, os seus próprios estômago e intestinos purgados ao alcançar a imortalidade. O imperador Ming Yongle, que atribuiu a ele a vitória que lhe deu o trono, ergueu os templos do Monte Wudang. Fontes: *Beiyou ji* (Jornada ao Norte, Ming); *Xuantian shangdi qisheng lu*.

Como Selo, é a retaguarda: quando alguém seu é ferido, o casco se fecha em volta — cura, mais Vida, e a obrigação de os inimigos baterem ali.

## Papel no jogo
Selo de 1 Fé que vira uma troca ruim em troca boa: o Imortal atacado sobrevive (cura 4 e +1 Vida) e passa a ter Guarda, protegendo Lü Dongbin e He Xiangu. Também dispara com dano de Ritos inimigos. Útil cedo (turno 1–2 sobrando 1 Fé). No motor a cura resolve em `_pos_dano`, antes de as mortes serem apuradas, então pode salvar quem levou dano letal — desde que a cura cubra o excesso. Dá Guarda a quem talvez você não quisesse na frente.

## Balanço
Orçamento P = 2·C+1 = 3 pts, +1 grátis de Selo = 4. Gasto: curar 4 (2) + +1 Vida permanente (1) + Guarda (1) = 4. Dentro.

## Dados
```json
{
  "id": "tao_tartaruga_negra_do_norte",
  "nome": "Tartaruga Negra do Norte",
  "cultura": "taoismo",
  "tipo": "selo",
  "custo": 1,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "ally_damaged", "acoes": [
      { "op": "heal", "alvo": "defender", "n": 4 },
      { "op": "buff", "alvo": "defender", "atk": 0, "vida": 1, "perm": true },
      { "op": "give_keyword", "alvo": "defender", "keyword": "guarda" } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, black tortoise, giant dark tortoise, black snake coiled around tortoise shell, snake wrapped around body, snake head raised facing tortoise head, two creatures entwined, patterned dark shell, defensive, shell glowing faintly, frozen northern river, snow, ice, winter night, jade green and vermilion, mist, ink wash feel, cold blue light, glowing eyes, falling snow, dark mountains, full body
```

## Prompt Krea 2
Atributos obrigatórios: tartaruga negra gigante · serpente preta enrolada no casco · cabeças frente a frente · rio congelado no inverno
```krea
A giant black tortoise, the Black Tortoise of the North, with no people present. One black snake is coiled around its patterned dark shell, wrapped twice around its body, and the snake's head is raised facing the tortoise's head. The tortoise stands firm in a defensive, closed posture, its shell glowing faintly. They rest on a frozen northern river with snow and ice and dark mountains, on a winter night with falling snow, lit by a cold blue light from the shell.
```
