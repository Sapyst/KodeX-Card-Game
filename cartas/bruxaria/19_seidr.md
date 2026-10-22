# Seiðr

| Campo | Valor |
|---|---|
| Cultura | bruxaria |
| Tipo | Rito |
| Custo | 1 Fé |
| ATK / Vida | — |
| Palavras-chave | — |
| Lendária | não |
| Cópias no deck | 1 |

## Texto da carta
Compre uma Entidade do seu deck.

## Contexto mitológico
*Seiðr* é a magia nórdica de transe, adivinhação e manipulação da sorte — a mais próxima de uma "bruxaria" no mundo escandinavo pré-cristão. Snorri Sturluson conta, na *Ynglinga saga* (cap. 4), que foi **Freyja** quem ensinou o *seiðr* aos Æsir, como era costume entre os Vanir; e que Odin o praticava, embora a arte carregasse tal *ergi* (desonra, falta de virilidade) que os homens a deixavam às sacerdotisas (cap. 7). Freyja, senhora do amor, da guerra e da metade dos mortos em batalha, é assim a padroeira da feiticeira nórdica.

A descrição mais rica é a da *völva* Þorbjörg lítilvölva em *Eiríks saga rauða* (cap. 4): convidada a uma fazenda da Groenlândia durante uma fome, chega com manto azul de pedrarias, gorro de pele de cordeiro negro, luvas de gato e um cajado de latão; senta-se numa plataforma alta (*seiðhjallr*), uma mulher canta o *varðlokkur* para atrair os espíritos, e a vidente então responde a cada pergunta sobre o futuro. Cajados de ferro encontrados em túmulos femininos (Fyrkat, Oseberg) são tomados como os *seiðstafr* dessas mulheres. As bruxas dos processos escandinavos tardios herdarão o vocabulário.

Na carta o *seiðr* é adivinhação pura: a bruxa olha o fio do destino do deck e puxa a Entidade de que precisa.

## Papel no jogo
O tutor do deck: por 1 Fé, pega Hécate para o turno 7, Baba Yaga quando há familiares sobrando, Cerridwen quando a mão está vazia ou um Sapo quando falta um corpo para o Sacrifício. Uma cópia só — mais do que isso tornaria o deck previsível. É deliberadamente 1 pt abaixo do orçamento pela tabela, porque escolher a carta certa vale mais do que comprar uma qualquer.

## Balanço
Orçamento P = 2·1+1 = 3 pts. Gasto: buscar carta de um tipo do deck (2) = 2. Dentro (1 pt de folga, intencional: tutor é forte na prática).

## Dados
```json
{
  "id": "bru_seidr",
  "nome": "Seiðr",
  "cultura": "bruxaria",
  "tipo": "rito",
  "custo": 1,
  "atk": null,
  "vida": null,
  "lendaria": false,
  "keywords": [],
  "sacrificio": 0,
  "efeitos": [
    { "gatilho": "on_play", "acoes": [ { "op": "search", "tipo": "entidade" } ] }
  ],
  "usos": null
}
```

## Prompt de arte
```prompt
1girl, solo, norse seeress, mature woman, long blonde braided hair, blue cloak studded with stones, black lambskin hood, cat fur gloves, glass bead necklace, holding a tall brass staff, seated on a high wooden platform, eyes closed in trance, glowing thread of fate floating in the air before her, viking longhouse interior, central fire pit, smoke, carved wooden pillars, hanging furs, shadows, purple and green, firelight, candlelight, rim lighting, mystical, full body
```

## Prompt Krea 2
Atributos obrigatórios: völva nórdica madura · manto azul com pedras e gorro de pele de cordeiro preto · luvas de pele de gato · cajado de latão · sentada em plataforma alta em transe
```krea
A mature adult Norse seeress about 50 years old, clearly female, with fair skin, a smooth face with no beard and no facial hair, and long blonde braided hair, sits on a tall wooden platform raised high above the floor of a dark Viking longhouse. Her eyes are closed in trance. She wears a long blue cloak studded with small stones over a wool dress that covers her chest, a hood made of BLACK lambskin fur, and gloves of grey furry cat skin on both hands. She has two normal arms. Her right gloved hand grips a tall brass staff; her left gloved hand rests open on her knee. A glowing golden thread floats before her. The central fire pit below lights her.
```
