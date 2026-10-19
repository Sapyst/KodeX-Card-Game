# Garuda

| Campo | Valor |
|---|---|
| Cultura | hinduísmo |
| Tipo | Entidade |
| Custo | 2 Fé |
| ATK / Vida | 1 / 2 |
| Palavras-chave | Ímpeto |
| Lendária | não |
| Cópias no deck | 2 |

## Texto da carta
Ímpeto.

## Contexto mitológico
Garuda é o rei das aves e a montaria (vahana) de Vishnu: corpo de homem, asas, bico e garras de águia, dourado como o sol. Sua história está no Astika Parva do Mahabharata (Adi Parva): nasce de Vinata, que fora escravizada pela irmã Kadru, mãe das nagas (serpentes). Para libertar a mãe, Garuda aceita o preço exigido pelas serpentes — a amrita dos deuses — e sobe ao céu, derrota Indra e os devas em pleno voo e traz o néctar, sem beber uma gota. Vishnu, impressionado com a força e com a renúncia, oferece-lhe a imortalidade e o lugar de sua montaria; Indra, derrotado, recupera a amrita e sela com Garuda um pacto: as serpentes serão para sempre seu alimento.

Por isso Garuda é o inimigo arquetípico das nagas e símbolo de velocidade e ataque certeiro. O Garuda Purana leva seu nome; sua imagem está nos estandartes de Vishnu e, até hoje, nos brasões da Indonésia e da Tailândia.

Na carta, o mergulho de Garuda sobre as serpentes vira Ímpeto e uma bicada em quem estiver no caminho no instante em que ele pousa.

## Papel no jogo
A montaria de Vishnu: um corpo de turno 2 que ataca na hora e existe para carregar uma arma. Portador ideal de Vajra ou Sudarshana Chakra (já tem Ímpeto, então o Chakra vale pelo dano): com Vajra vira um 3/2 que já feriu o bloqueador. Sozinho bate só por 1 — é a montaria, não o golpe. Com 2 de Vida sobrevive a um ping e alimenta a Roda do Samsara quando cai.

## Balanço
Orçamento P = 2·2+1 = 5 pts. Gasto: ATK 1 + Vida 2 + Ímpeto 1 = 4. Dentro (P−1).
Rodada 2 de balanceamento (pacote H1 do Analista): saiu o ping do Despertar (−1,4 pp medido). O deck tinha 17 cartas que ferem ou destroem Entidades; o aparo é de 1 ponto em muitas, não de uma carta.
Rodada 1 de balanceamento: era 2/1 — duas cópias com Ímpeto batendo por 2 num campo vazio nas rodadas 2–4 eram metade do chip inicial do deck (dano de ataque à Cornucópia 14–17 por partida).
Revisão: o ping era `on_attack` (repetível a cada ataque → 0,8 × 2 = 1,6, total 5,6, acima de P); passou a Despertar.

## Dados
```json
{
  "id": "hin_garuda",
  "nome": "Garuda",
  "cultura": "hinduismo",
  "tipo": "entidade",
  "custo": 2,
  "atk": 1,
  "vida": 2,
  "lendaria": false,
  "keywords": ["impeto"],
  "sacrificio": 0,
  "efeitos": [],
  "usos": null
}
```

## Prompt de arte
```prompt
1boy, solo, bird man, eagle head, golden beak, golden feathers, huge outstretched wings, muscular human body, bare chest, eagle talons, jeweled crown, gold ornaments, red loincloth, diving down from the sky, dynamic pose, attacking, talons forward, serpent in talons, speed lines, wind, mountain peaks below, sunset clouds, saffron and blue, golden light, sun behind, rim lighting, full body
```

## Prompt Krea 2
Atributos obrigatórios: cabeça de águia com bico dourado · corpo humano musculoso com duas asas enormes · garras de águia nos pés · serpente naga presa nas garras · coroa e dhoti vermelho
```krea
Garuda, the king of birds, an adult divine being with the head of an eagle, a hooked golden beak and fierce yellow eyes, on a strong muscular human body with golden-brown skin. Two enormous wings with golden and red feathers grow from his shoulders and spread wide. He has two human arms and two hands, and his legs end in large eagle talons. He wears a tall jeweled golden crown, gold armlets and a red silk dhoti wrapped around his waist and thighs. He dives down from the sky talons first, gripping a writhing dark green serpent in his claws. Mountain peaks lie far below, and the setting sun blazes behind him.
```
