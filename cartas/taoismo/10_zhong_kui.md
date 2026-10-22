# Zhong Kui

| Campo | Valor |
|---|---|
| Cultura | taoismo |
| Tipo | Entidade |
| Custo | 4 Fé |
| ATK / Vida | 3 / 4 |
| Palavras-chave | Despertar |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Despertar: Silencie uma Entidade inimiga (ela perde palavras-chave e efeitos).

## Contexto mitológico
Zhong Kui (鍾馗) é o caçador de fantasmas da China: homem corpulento de barba eriçada, olhos esbugalhados, túnica de letrado e botas, de espada em punho, cercado de pequenos demônios que ele escraviza ou devora. A lenda, registrada por Shen Kuo no *Mengxi bitan* (séc. XI), conta que Zhong Kui foi um candidato dos exames imperiais nos Tang, brilhante mas feio demais; recusado (ou roubado do primeiro lugar), suicidou-se nos degraus do palácio. O imperador Xuanzong, doente, sonhou com um demônio pequeno roubando-lhe a flauta de jade e a bolsa de perfume; então um gigante de boné rasgado agarrou o ladrão, arrancou-lhe os olhos e o comeu, apresentando-se como Zhong Kui. O imperador acordou curado e mandou Wu Daozi pintar o retrato.

Desde então sua imagem é colada nas portas no Ano-Novo e no quinto dia do quinto mês (Duanwu) para afastar espíritos; o *Zhong Kui quanzhuan* (Ming) estende as aventuras, incluindo o casamento que ele arranja para a irmã. Na hierarquia taoista ele recebe do Imperador de Jade o cargo de expulsar demônios em todo o império.

Virou a carta de silêncio: o exorcismo não destrói, apenas tira do inimigo tudo o que ele tinha de sobrenatural.

## Papel no jogo
Remoção "mole" que o deck precisa: cala Guarda, Renascer, auras e Despertares já em campo sem destruir (coerente com "dano direto quase zero"). Corpo 3/4 sólido para a curva de 4. Melhor alvo: Entidade inimiga com Relíquia ou com Renascer. Não resolve estatísticas puras — contra um 5/5 sem texto, é só um 3/4.

## Balanço
Orçamento P = 2·C+1 = 9 pts. Gasto: ATK 3 + Vida 4 + Despertar "silenciar Entidade inimiga" (2) = 9. Dentro.

## Dados
```json
{
  "id": "tao_zhong_kui",
  "nome": "Zhong Kui",
  "cultura": "taoismo",
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
1boy, solo, burly man, bristling black beard, bulging eyes, fierce, dark official robe, tattered cap, black boots, holding sword, raising sword, pointing at small cowering demon, small demon shrinking, exorcism, gloomy courtyard, red door, night, bats, jade green and vermilion, mist, ink wash feel, red lantern light, dramatic shadows, sword gleam, stone lion statue, full body
```

## Prompt Krea 2
Atributos obrigatórios: olhos esbugalhados · barba preta eriçada · gorro de letrado rasgado · espada erguida · pequeno demônio encolhido
```krea
A burly, heavily built adult Chinese man about 45 years old with huge bulging round eyes, a fierce scowl and a thick bristling black beard. He wears a dark green scholar-official robe, a torn black scholar cap and black boots. He has two normal arms and two hands. His right hand raises a straight sword high; his left hand points down at one small cowering grey demon at his feet. Gloomy temple courtyard at night with a red door and a stone lion, bats in the sky, lit by one red lantern.
```
