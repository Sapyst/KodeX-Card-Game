# Banquete dos Pêssegos

| Campo | Valor |
|---|---|
| Cultura | taoismo |
| Tipo | Rito |
| Custo | 3 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Todas as suas Entidades ganham +1/+1 permanente. Cure 2 da sua Cornucópia.

## Contexto mitológico
O Pantao Hui (蟠桃會), Banquete dos Pêssegos Achatados, é a festa que Xiwangmu oferece no Palácio de Jade do Kunlun quando os pêssegos da imortalidade amadurecem. Na *Jornada ao Oeste* (cap. 5) o pomar tem três mil e seiscentas árvores: as da frente dão fruto a cada três mil anos e tornam quem os come leve e sadio; as do meio, a cada seis mil, e dão o voo e a vida eterna; as do fundo, a cada nove mil, e fazem o comensal durar tanto quanto céu e terra. Sun Wukong, nomeado guardião do pomar, come os melhores, invade o banquete antes dos convidados, bebe o vinho imperial e engole o elixir de Laozi — o que desencadeia a guerra contra o céu.

A festa é anterior ao romance: no *Han Wudi gushi* Dongfang Shuo é acusado de ter roubado três vezes os pêssegos da Rainha Mãe; no teatro Yuan e nas pinturas de aniversário (*zhushou tu*) o banquete é a cena-padrão para desejar longevidade, com os Oito Imortais chegando pelo mar para brindar. Todos os deuses recebem convite — e ser convidado é ser imortal.

Como Rito, o banquete alimenta quem está à mesa: todas as suas Entidades crescem e um pouco de vida volta à Cornucópia.

## Papel no jogo
Virada de meio de jogo para uma mesa larga: com quatro Imortais em campo, +4/+4 em estatísticas permanentes por 3 Fé, e a cura compensa o atrito de ter deixado o oponente bater na Cornucópia enquanto a mesa se formava. Combina com Lü Dongbin (que soma a aura) e precede bem o Imperador de Jade. Inútil em mesa vazia — jogar cedo é desperdício.

## Balanço
Orçamento P = 2·C+1 = 7 pts. Gasto: +1 ATK e +1 Vida permanentes em todas as aliadas = (1 + 1) × 3 = 6 + curar 2 de Cornucópia (1) = 7. Dentro.

## Dados
```json
{
  "id": "tao_banquete_dos_pessegos",
  "nome": "Banquete dos Pêssegos",
  "cultura": "taoismo",
  "tipo": "rito",
  "custo": 3,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [
      { "op": "buff", "alvo": "all_ally_entities", "atk": 1, "vida": 1, "perm": true },
      { "op": "heal", "alvo": "ally_cornucopia", "n": 2 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
no humans, banquet table, piles of glowing peaches, wine jars, jade cups, peach blossom branches, jade palace terrace, above the clouds, floating lanterns, cranes flying, celebration, feast, jade green and vermilion, mist, ink wash feel, warm golden light, pink blossoms, red tablecloth, golden plates, blooming peach trees, pink petals falling, jade pillars, sunset sky, soft glow, scenery
```

## Prompt Krea 2
Atributos obrigatórios: mesa de banquete com pêssegos brilhantes · jarros de vinho e taças de jade · terraço de palácio de jade acima das nuvens · grous voando
```krea
A celestial banquet table with no people present, set on a jade palace terrace above the clouds. On a red tablecloth stand golden plates piled with glowing pink peaches, clay wine jars and small jade cups, with peach blossom branches in a vase at the center. Jade pillars and blooming peach trees frame the table, pink petals fall, and two white cranes fly in the distance. The feast is ready for the gods, lit by warm golden light from the glowing peaches under a sunset sky.
```
