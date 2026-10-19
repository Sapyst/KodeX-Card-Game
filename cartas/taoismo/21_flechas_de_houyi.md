# Flechas de Houyi

| Campo | Valor |
|---|---|
| Cultura | taoismo |
| Tipo | Rito |
| Custo | 2 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Cause 3 de dano a uma Entidade inimiga. Compre 1 carta.

## Contexto mitológico
No tempo do imperador Yao, os dez sóis — filhos de Di Jun e Xihe, que deviam revezar-se um por dia no alto da amoreira Fusang — subiram todos ao céu de uma vez. As colheitas queimaram, as pedras derreteram, monstros saíram dos pântanos. Yao ordenou ao arqueiro Yi (后羿, Houyi, "o senhor Yi") que resolvesse: ele retesou o arco vermelho e derrubou nove sóis, que caíram como corvos de três patas mortos, deixando só o que ainda nos aquece; depois matou o Chiselado-de-Dentes, as Nove Crianças, o Grande Javali e a serpente Xiushe (a Bashe do *Shanhaijing*). Fonte: *Huainanzi*, "Benjing xun"; *Shanhaijing* ("Haiwai dong" e "Dahuang nan"); *Chuci*, "Tianwen".

Houyi é o herói que acerta o que está em excesso. Sua história continua com Xiwangmu, que lhe dá o elixir da imortalidade, e com Chang'e, que o engole e sobe à lua (*Huainanzi*, "Lanming xun") — a Rainha Mãe e a Pílula de Ouro, cartas deste mesmo deck.

Como Rito — o disparo, não o arco: é o ato de Houyi que vira carta, por isso não é Relíquia —, as flechas fazem o que fizeram no mito: tiram do céu o que estava demais, sem destruir o mundo. É a única carta de dano puro do deck.

## Papel no jogo
Remoção pontual e única: 3 de dano acaba com a maior parte dos corpos de custo até 3 e termina o serviço em Entidades grandes feridas em combate. O compre 1 evita que seja carta a menos. Um deck de equilíbrio precisa de ao menos uma resposta direta a um corpo problemático (Guarda inimiga, portadora de Relíquia), e é isto. Não atinge a Cornucópia.

## Balanço
Orçamento P = 2·C+1 = 5 pts. Gasto: 3 de dano a Entidade escolhida (3) + comprar 1 (1,5) = 4,5. Dentro.

## Dados
```json
{
  "id": "tao_flechas_de_houyi",
  "nome": "Flechas de Houyi",
  "cultura": "taoismo",
  "tipo": "rito",
  "custo": 2,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [
      { "op": "damage", "alvo": "enemy_entity", "n": 3 },
      { "op": "draw", "n": 1 } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1boy, solo, archer hero, muscular, human face, tanned skin, topknot, fur cape, red bow, drawing bow, aiming upward, arrow of light, ten suns in sky, multiple blazing suns, three-legged black crow falling, scorched cracked earth, heat haze, jade green and vermilion, embers, ink wash feel, orange glow, dramatic backlighting, low angle, side view, full body
```

## Prompt Krea 2
Atributos obrigatórios: arco vermelho retesado para o alto · flecha de luz · dez sóis no céu · corvo de três patas caindo · capa de pele
```krea
A muscular adult Chinese archer about 35 years old, tanned skin, black hair in a topknot, brown leather tunic, fur cape. Side view, low angle. He aims straight up at the sky: his left arm is stretched upward holding a large red bow vertical, and his right hand pulls the bowstring back to his cheek. One glowing arrow of light sits on the string, pointing upward. Two normal arms and two hands. The sky holds ten blazing suns. One black crow with exactly three legs falls downward from a sun, wings limp and struck. Scorched cracked earth, intense orange glow.
```
