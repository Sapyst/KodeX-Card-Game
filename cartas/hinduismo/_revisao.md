# Revisão do deck Hinduísmo

Revisão de design e de pesquisa feita sobre as 29 cartas (32 no deck) com a tabela §10 atualizada de `docs/regras.md`, a DSL de `docs/dsl_efeitos.md` (alvos `defender`/`other_ally_entities`, regras de resolução) e o `docs/template_carta.md`. `validar.py` → `OK` ao final.

## Convenções usadas na conta

- **P = 2·C+1**; Selo e Relíquia +1 grátis; Lendária até P+2; nada mais passa de P; abaixo de P−2 fortalece.
- **Efeito repetível a cada ataque, sem Usos** (`on_attack`, `equipped_attacks`): valor unitário **× 2** — equivale a Usos 3 × 0,7 da tabela (uma portadora raramente ataca mais de três vezes antes de morrer ou de o jogo acabar). É a leitura de "gatilho repetível vale cheio" aplicada a algo sem limite de cargas.
- **`enemy_dies` de Kali**: × 3, porque o próprio Despertar dela (2 em todas) costuma gerar 1–2 mortes antes de qualquer combate.
- **`set_stats`**: valor = diferença para o corpo médio 2/3 (não para o pior caso).
- **Aura `static` em todas as aliadas** (buff ou palavra-chave): 3 pts, inclui a fonte.

## Tabela carta → o que mudou e por quê

| # | Carta | Conta oficial (antes → depois) | O que mudou | Por quê |
|---|---|---|---|---|
| 01 | Matsya | 3/3 | ok (texto do Papel atualizado: Vishvarupa agora é 6/6 com Ímpeto) | — |
| 02 | Garuda ×2 | 5,6 → **4,8** / P 5 | Ping de 1 aleatório saiu de `on_attack` e virou **Despertar** | `on_attack` é repetível (0,8 × 2 = 1,6) e estourava P. Como Despertar mantém o papel de "limpa token antes do combate" e lê a história (o mergulho de Garuda ao pousar). |
| 03 | Jatayu | 4,5 / P 5 | ok | — |
| 04 | Ganesha | 7 / P 7 | ok | — |
| 05 | Arjuna | 8 → **7** / P 7 | Corpo **3/2 → 2/2** | Ping escolhido a cada ataque vale 1 × 2 = 2. O deck quer Arjuna como portador de Gandiva (vira 5/4 e chove flechas), não como corpo. |
| 06 | Hanuman ×2 | 10 → **9** / P 9 | Corpo **4/3 → 3/3** | +1 ATK permanente a cada ataque é repetível (1 × 2 = 2), não 1 pt único. O bônus chega ao declarar o ataque, antes do dano: ele ainda bate por 4 na entrada, 5, 6… |
| 07 | Narasimha | 8,8 / P 9 | ok; **nota para o simulador** adicionada no Balanço | A `cond` `target_cost_max` no motor avalia `triggering`, que em `on_play` é o próprio Narasimha (custo 4): a condição nunca seria verdadeira e o `destroy` nunca dispararia. A DSL diz que a condição é sobre o alvo. Afeta também Judite (cristianismo) e Andras (alta magia). |
| 08 | Rama | 9 / P 9 | ok; contexto corrigido | Ramcharitmanas é em **awadhi**, não "hindi medieval"; acrescentado séc. XVI. |
| 09 | Krishna | 11 / P 11 | ok; Balanço reescrito nos termos da tabela (aura em todas = 3) | A aura inclui o próprio Krishna (regra 22 do motor): ele ataca no turno em que entra; o Papel agora diz isso. |
| 10 | Durga | 11 / P 11 | ok; contexto corrigido | O Devi Mahatmya não fala em "nove noites e décimo dia" — isso é a tradição do Navaratri/Vijayadashami; o texto agora separa texto e festival, e cita as metamorfoses de Mahishasura (DM 3). |
| 11 | Kali (L) | 16 → **15** / P 13+2 | Corpo **5/5 → 4/5** | `enemy_dies` repetível vale cheio (× 3 = 3), não 1,5. Ela cresce rápido de qualquer modo. |
| 12 | Shiva Nataraja (L) | 17 / P 15+2 | ok | — |
| 13 | Chamas de Agni | 4 / P 3+1 | ok | 1 de dano direto; entra no teto do deck. |
| 14 | Roda do Samsara | 3,5 / P 3+1 | ok | A Entidade que acabou de morrer já está no cemitério e pode ser ela a voltar (regra do motor). |
| 15 | Lei do Karma | 5,5 / P 5+1 | ok | — |
| 16 | Véu de Maya | 5 / P 5+1 | ok | — |
| 17 | Incêndio de Lanka | 5 / P 5+1 | ok | 1 de dano direto; Selo dispara uma vez. Tipo mantido como Selo: é uma reação (Ravana acende o fogo; a ação do oponente dispara a armadilha). |
| 18 | Pashupatastra | 7 / P 7+1 | ok | Tipo mantido como Selo: astra não é objeto (é mantra), e a história é a de uma arma guardada e nunca disparada — o Selo virado para baixo. As Relíquias ficam com as ayudhas físicas. |
| 19 | Om ×2 | 3 / P 3 | ok | — |
| 20 | Yajna | 5 / P 5 | ok | — |
| 21 | Samudra Manthan | 7 / P 7 | ok | — |
| 22 | Brahmastra | 7 / P 7 | ok | — |
| 23 | Descida do Avatar | 5–6,5 / P 7 | ok | Pior caso (Shiva) 6,5 ≤ 7. |
| 24 | Vishvarupa | 5 → **8** / P 9 | **5/5 → 6/6 e Ímpeto** | Pelo corpo médio 2/3, "5/5" valia só +3/+2 = 5, abaixo de P−2. Agora +4/+3 = 7 + Ímpeto 1 = 8. Lê a história: depois da visão, Arjuna pega o arco. JSON ganhou o `give_keyword`. |
| 25 | Tandava | 10,5 / P 11 | ok | 3 de dano direto (máximo por carta). |
| 26 | Vajra | 6 / P 5+1 | ok | — |
| 27 | Sudarshana Chakra | 11 → **8** / P 7+1 | **+2/+2 → +2/+1**; dano por ataque **3 → 2** | 3 de dano repetível valia 6, não 3. |
| 28 | Gandiva | 11 → **8** / P 7+1 | "1 à Cornucópia e 1 a uma Entidade por ataque" → **1 de dano a todas as Entidades inimigas por ataque** | Dano direto repetível é ilimitado e estourava o teto do deck (≤ 8); como repetível cheio a carta valia 11. Virou dano em área (1,5 × 2 = 3), que é a imagem do Arjuna de Virata derrotando um exército sozinho. Contexto: retirada a frase sobre "peso de um ou cem elefantes" (não está no Mahabharata). |
| 29 | Trishula | 12 → **10** / P 9+1 | Dano por ataque **2 → 1**; Último Sopro (2 a todas) mantido | 2 repetível valia 4; com 1 (2) + Último Sopro (3) + +3/+2 (5) fecha em 10. |

Tipos (14/6/8/4) conferidos: nenhuma troca necessária. Todos os textos ≤ 25 palavras; JSON e texto conferidos carta a carta (Vishvarupa, Sudarshana, Gandiva, Trishula, Garuda, Arjuna, Hanuman, Kali alterados em ambos).

## Sanidade do deck

- **Dano direto à Cornucópia** (soma nominal nas 32 cartas): Chamas de Agni 1 + Incêndio de Lanka 1 + Tandava 3 = **5 ≤ 8**. Antes, Gandiva adicionava 1 por ataque sem limite (3–4 por partida na prática) — removido.
- **`destroy`**: Narasimha, Shiva, Brahmastra, Pashupatastra = **4 cópias** (todas ×1). Confirmado.
- **Combos de 2 cartas no turno 3–4**: não há. O melhor início (Matsya T1 → Vajra; Garuda T2; Vajra + Garuda T3 = 4/2 Ímpeto) soma ~7 de dano até o T3 só contra campo vazio; Hanuman T4 bate por 4. Qualquer bloqueador interrompe (dano direto por ataque exige campo inimigo vazio). Krishna + corpos baratos não acelera nada: Garuda, Jatayu e Hanuman já têm Ímpeto; a aura serve a Rama, Arjuna, Narasimha, Kali e Shiva, todos de custo ≥ 3.
- **Hanuman + Relíquia**: Hanuman 3/3 + Trishula (T4 + T8 em Fé) só fecha no turno 7–8; Hanuman + Vajra no T6 é um 5/4 que bate por 6 — forte, mas uma carta de remoção resolve.

## Erros de pesquisa encontrados e corrigidos

1. **Rama** — Ramcharitmanas descrito como "hindi medieval": é em **awadhi** (Tulsidas, séc. XVI).
2. **Durga** — "nove noites e décimo dia" atribuído ao Devi Mahatmya: é a liturgia do Navaratri, não o texto; o DM narra as metamorfoses de Mahishasura antes do golpe final. Corrigido e separado.
3. **Gandiva** — "pesa como um — ou cem — elefantes": detalhe sem base no Adi Parva; removido.
4. Transliterações conferidas e consistentes entre cartas e `_estudo.md` (Ashwatthama, Hiranyakashipu, Neelakantha, Mahishasura, Vrindavan). Fontes conferidas: Shatapatha Brahmana 1.8.1 e BhP 8.24 (Matsya); MBh Astika Parva (Garuda); Ram Aranya Kanda (Jatayu); ShP Rudra Samhita (Ganesha); MBh Vana/Virata Parva (Arjuna, Pashupatastra); Ram Sundara/Yuddha Kanda (Hanuman, Incêndio de Lanka); BhP 7 (Narasimha); DM 2–3 e 7–8 (Durga, Kali); RV 2.33 e bronzes Chola (Shiva); RV 1.1 (Agni); BU 4.4.5 e BG 2.22/2.47 (Samsara, Karma); Shvet. Up 4.10 e BG 7.14 (Maya); Mandukya Up e BG 8.13/9.17 (Om); RV 10.90 e BG 3–4 (Yajna); BhP 8.6–12 (Samudra Manthan); MBh Sauptika Parva (Brahmastra); BG 4.7–8 e BhP 1.3 (Descida); BG 11.32 (Vishvarupa); Natya Shastra e ShP (Tandava); RV 1.32 e BhP 6.9–10 (Vajra); BhP 8.9 e MBh Sabha Parva (Sudarshana); MBh Adi Parva/Khandava (Gandiva); ShP/Linga Purana (Trishula). Nenhum outro erro factual encontrado; tom respeitoso mantido (religião viva, figuras tratadas como personagens de epopeia).

## Três pontos que o simulador deve observar neste deck

1. **`target_cost_max` em `on_play` de Entidade (Narasimha).** O motor avalia a condição sobre `ctx["triggering"]`, que em `on_play` é a própria Entidade invocada; Narasimha (custo 4) nunca passaria na condição `≤ 3` e seu `destroy` nunca dispararia. A DSL define a condição sobre o alvo do `destroy`/`counter`. Até o motor filtrar os candidatos de `enemy_entity` pelo custo (ou avaliar a cond por alvo), o WR de Narasimha no relatório vai sair artificialmente baixo — não ajustar a carta por isso. O mesmo vale para Judite (cristianismo) e Andras (alta magia).
2. **Curva de dano de Hanuman e das Relíquias repetíveis.** Observar "dano méd" de Hanuman (3/3 que bate 4-5-6), Sudarshana (2 por ataque), Gandiva (1 em todas por ataque) e Trishula (1 por ataque + 2 em todas ao morrer). Se Hanuman ficar com WR jogada muito acima do deck (> +15 pontos) ou se as Relíquias somarem mais de ~6 de dano por partida cada, o multiplicador ×2 adotado para efeitos repetíveis está baixo e deve subir para ×3 — rever então Hanuman (3/2), Arjuna e as três Relíquias juntos, não uma por uma.
3. **Partidas curtas demais e o teto de dano direto.** O deck tem 5 de dano direto nominal (Agni 1, Lanka 1, Tandava 3) e muita pressão de Ímpeto. Medir a duração média contra os decks de controle (taoismo, alta magia): se ficar abaixo de ~6 rodadas em mais de metade das partidas, o problema está nos corpos com Ímpeto do turno 2–4 (Garuda ×2, Jatayu, Hanuman ×2), não no dano direto. Observar também Krishna: a aura dá Ímpeto a ele mesmo (4/4 que ataca no turno 5) — se o WR dele destoar, a correção é remover a fonte da aura (`other_ally_entities`), não mexer no corpo.
