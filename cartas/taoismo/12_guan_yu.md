# Guan Yu, Imperador Guan

| Campo | Valor |
|---|---|
| Cultura | taoismo |
| Tipo | Entidade |
| Custo | 5 Fé |
| ATK / Vida | 4 / 5 |
| Palavras-chave | Guarda, Despertar |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Guarda. Despertar: uma Entidade aliada ganha +1 ATK permanente.

## Contexto mitológico
Guan Yu (關羽, m. 220) foi general de Liu Bei no fim dos Han, um dos três irmãos do Juramento do Jardim dos Pessegueiros no *Sanguo yanyi* (Romance dos Três Reinos, séc. XIV): rosto vermelho, barba de dois chi, a Alabarda do Dragão Verde na mão e o cavalo Lebre Vermelha. Capturado por Sun Quan e executado, a lealdade ao irmão até a morte fez dele, ao longo de mil anos, mais do que um herói: um deus.

A divinização é tripla. Os budistas o fazem Sangharama, guardião dos monastérios; os confucianos, modelo de retidão (*yi*); o taoismo religioso o incorpora como deus da guerra e exorcista e, em 1614, o imperador Ming Wanli lhe dá o título de *Guansheng Dijun*, "Imperador Guan, Sábio Santo". Templos de Guandi existem em toda a diáspora chinesa; comerciantes o veneram como deus da riqueza (ele teria inventado o livro-caixa), policiais e tríades juram sobre sua imagem. Fontes: *Sanguo zhi* (histórico), *Sanguo yanyi*, *Guandi shengji tuzhi* (Qing).

A carta é o general leal que se põe à frente (Guarda) e, ao chegar, arma um companheiro — o irmão de armas que ganha +1 ATK.

## Papel no jogo
Muralha do deck no turno 5: Guarda com 5 de Vida protege Lü Dongbin, He Xiangu e o Imperador de Jade que vem depois. O +1 ATK permanente vai de preferência para Nezha ou para um Imortal que vai atacar várias vezes. Fraco contra devolver à mão (perde o Despertar gasto) e contra silêncio, que tira a Guarda e expõe a linha.

## Balanço
Orçamento P = 2·C+1 = 11 pts. Gasto: ATK 4 + Vida 5 + Guarda (1) + Despertar "+1 ATK permanente em aliada" (1) = 11. Dentro.

## Dados
```json
{
  "id": "tao_guan_yu",
  "nome": "Guan Yu, Imperador Guan",
  "cultura": "taoismo",
  "tipo": "entidade",
  "custo": 5,
  "atk": 4,
  "vida": 5,
  "lendaria": false,
  "keywords": ["guarda"],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [ { "op": "buff", "alvo": "ally_entity", "atk": 1, "vida": 0, "perm": true } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1boy, solo, tall general, red face, dark red skin, very long black beard, green hanfu, green robe over armor, green headscarf, holding guandao, long-handled glaive, crescent blade on long pole, green dragon crescent blade, glaive planted upright beside him, defensive stance, standing guard, stern expression, temple hall, red pillars, incense smoke, candles, red tassel on blade, jade green and vermilion, ink wash feel, warm candlelight, full body
```

## Prompt Krea 2
Atributos obrigatórios: rosto vermelho · barba preta muito longa · guandao (alabarda lua crescente) plantada em pé · túnica verde sobre armadura · lenço verde na cabeça
```krea
A tall adult Chinese general about 45 years old with a deep red face, a stern expression and a very long black beard reaching his chest. He wears a green robe over dark armor and a green headscarf. He has two normal arms and two hands. His right hand holds a guandao planted upright on the ground beside him: a long pole with a large curved crescent blade at the top and a red tassel. His left hand strokes his beard. He stands guard facing the viewer in a temple hall with red pillars and incense smoke, lit by warm candlelight.
```
