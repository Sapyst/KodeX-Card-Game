# Rodada 1 — mudanças de carta (Balanceador)

Entrada: `r1_analise.md` (Analista, 24 propostas) + mudanças de motor já feitas (bug `on_damaged`, `gain_fe perm` só na máxima, Furtivo × `triggering`, **revive para o campo não dispara Despertar**) + tabela §10 nova (`destroy` escolhido = **5**; com `target_cost_max` ≤ 3 = **3,5**).

Arquivos desta rodada em `sim/relatorios/`: `r1_pos_motor.json|txt` (linha de base real, seed 11, n = 2000), `r1_pos_mudancas_passe1.json|txt` (depois das 20 mudanças do 1º passe), `r1_pos_mudancas.json|txt` (final, com Kali), `espelhos_r1/<deck>.json|txt` (espelhos dos 5 decks mexidos; `hinduismo_passe1.json` é o espelho antes de Kali).

Validação: `validar.py` → `OK` nas seis pastas (avisos pré-existentes de Hécate, Babalon, Lan Caihe, He Xiangu); `unittest` → 58 testes `OK`. Restrições: 14/6/8/4, curva 4/6/3/1, cópias, Lendárias ≤ P+2, dano direto ≤ 8, `counter` ≤ 3 — todas mantidas; nenhuma carta nova, nenhuma troca com `_reserva/`.

---

## 1. Linha de base real (pós-motor) × análise do Analista

A matriz pós-correções do motor difere da do `r1_analise.md` §1 em três pontos, todos explicáveis pelas mudanças de motor:

| Deck | `r1_analise` | pós-motor | Δ | Causa |
|---|---|---|---|---|
| hinduismo | 83,2 | **84,2** | +1,0 | os adversários perderam os laços de revive (cristianismo, taoismo) |
| cristianismo | 62,3 | **58,0** | −4,3 | Tumba Vazia / Talita Cumi não repetem mais Miguel/Elias |
| taoismo | 48,9 | **46,8** | −2,1 | Pílula ×2 / Pássaro Vermelho / Xiwangmu não repetem Despertar |
| bruxaria | 46,8 | **46,5** | −0,3 | Caldeirão sem laço (efeito pequeno: 0,1 revive/partida) |
| indígena | 39,4 | **44,6** | +5,2 | bug `on_damaged` (Curupira/Mapinguari deixaram de se ferir) — o Analista previu +3 a +6 |
| alta magia | 19,4 | **19,9** | +0,5 | Azoth custa o que diz (ligeiro nerf) compensado pelo resto |

Confrontos fora de 30–70: 11 → **9** (indígena × bruxaria e indígena × taoismo entraram na faixa).

---

## 2. Mudanças aplicadas

Convenção: P = 2·C+1 (+1 Selo/Relíquia; +2·N Sacrifício; Lendária até P+2). "Conta §10" com a tabela nova.

### 2.1 Recontagem obrigatória — cartas com `destroy` (§10: 5 pts; condicionado ≤ 3: 3,5)

| Carta | Antes | Depois | Conta §10 nova | Motivo |
|---|---|---|---|---|
| **Shiva Nataraja** (hin, L, 7) | 6/6 Ímpeto, destroy | **5/6** Ímpeto, destroy | 5+6+1+5 = 17 / 17 (P+2) | estourava (18); = proposta #1 |
| **São Miguel Arcanjo** (cri, L, 7) | 6/6 Guarda, destroy | **5/6** Guarda, destroy | 5+6+1+5 = 17 / 17 (P+2) | estourava (18); = proposta #5 |
| **Baba Yaga** (bru, 5, Sac 1) | 4/5 | **3/5** | 3+5+5 = 13 / 13 | estourava (14); = proposta #9 |
| **Brahmastra** (hin, Rito) | custo 3 | **custo 4** | 5 + 2 área (3) = 8 / 9 | estourava (8/7); = proposta #2 |
| **Narasimha** (hin, 4) | 3/3, destroy ≤ 3 | **3/2**, destroy ≤ 3 | 3+2+3,5 = 8,5 / 9 | estourava (9,5): `destroy` condicionado vale 3,5 fixo, não 4×0,7 |
| **Judite** (cri, 3) | 2/2, destroy ≤ 3 | **2/1**, destroy ≤ 3 | 2+1+3,5 = 6,5 / 7 | estourava (7,5); a viúva é frágil, o golpe é único |
| **Andras** (alt, 4) | 3/3, destroy ≤ 2 | **3/2, destroy ≤ 3** | 3+2+3,5 = 8,5 / 9 | estourava (9,5 — custo ≤ 2 vale os mesmos 3,5); trocou 1 Vida por alcance (= proposta #14 modificada) |
| Pashupatastra (hin, Selo 3) | — | sem mudança | 5 (atacante) + 3 = 8 / 8 | exato em P+1 |
| Sangue nos Umbrais (cri, Selo 3) | — | sem mudança | 5 (atacante) + cura 4 (2) = 7 / 8 | dentro; Balanço atualizado |
| Juízo Final (cri, Rito 4) | — | sem mudança | 5 × 2 × 0,7 + 1,6 = 8,6 / 9 | dentro; Balanço atualizado |
| Selo de Salomão (alt, Selo 3) | — | sem mudança | (5+1) + 1,5 = 7,5 / 8 | dentro; Balanço atualizado |

### 2.2 Propostas do Analista — aplicadas

| # | Carta | Antes | Depois | Conta §10 | Motivo |
|---|---|---|---|---|---|
| 3 | **Garuda** ×2 (hin, 2) | 2/1 Ímpeto, ping | **1/2** Ímpeto, ping | 1+2+1+0,8 = 4,8 / 5 | metade do chip das rodadas 2–4 |
| 4 | **Vajra** (hin, Rel 2) | +2/+1, 3 dano | +2/+1, **2 dano** | 2+1+2 = 5 / 6 | remoção barata que esvaziava o campo cedo |
| 20 | **Kali** (hin, L, 6) | 4/5 | **4/4** | 4+4+3+3 = 14 / 15 (P+1) | **2º passe**: #1–#4 tiraram só 3,6 pp (84,2 → 80,6); era a proposta condicional do Analista para este caso |
| 6 | **Elias** (cri, L, 6) | 4/6 | **4/5** | 4+5+2+3 = 14 / 15 (P+1) | 78 % global; motivada pelo corpo, não pelo laço |
| 8' | **Hécate** (bru, L, 7, Sac 1) | 6/7 | **5/7** | 5+7+6 = 18 / 19 (P+1) | **versão mais leve** da #8 (5/6): o laço Caldeirão → Hécate já caiu com a regra nova e o deck estava em 46 %; cortar ATK preserva "encolher, não bater" |
| 24 | **Boneco de Cera** (bru, Selo 3) | 3 dano, −2/−2 | **4 dano**, −2/−2 | 4+4 = 8 / 8 | malefícios abaixo do deck (43 % espelho); compensa os cortes em Baba Yaga/Hécate dentro da identidade |
| 11 | **Paimon** (alt, 6) | Sac 1; 2 tokens + compra 1 | **sem Sacrifício; 2 tokens** | 4+5+4 = 13 / 13 | ficava na mão 30 % (57 % vs hinduismo); vira o pacto que traz o fodder dos outros; −1 compra |
| 12 | **Abrahadabra** (alt, Rito) | custo 4; 3 direto + compra 1 | **custo 3; 3 direto** | 6 / 7 | fecho um turno antes; −1 compra |
| 13 | **Pedra de Visão** ×2 (alt, Rel 1) | +0/+2, compra 1 | **+1/+2** | 1+2 = 3 / 4 | −2 compras (fadiga) e +2 ATK na mesa |
| 18 | **Conjuração dos Elementais** ×2 (alt, Rito) | custo 3, três 1/1 | **custo 2, dois 1/1** | 4 / 5 | fodder no turno 2–3; "na mão" 53 → 27 % |
| 19 | **Edward Kelley** (alt, 2) | 0/2 Furtivo, busca | **1/1** Furtivo, busca | 1+1+1+2 = 5 / 5 | o deck precisa de ATK |
| 15 | **Boitatá** ×2 (ind, 4) | Guarda; `ally_attacked` → 1 ao atacante | Guarda; **`on_damaged`** → 1 ao atacante | 3+4+1+1 = 9 / 9 | o gatilho antigo disparava 0,15×/partida (a própria Guarda o impedia) |
| 16 | **Dança do Aruanã** (ind, Rito 2) | dois 1/1 | dois 1/1 **+ cura 2 Cornucópia** | 4+1 = 5 / 5 | carta mais fraca do deck; cabe na identidade de cura |
| 17 | **Mundéu** ×2 (ind, Selo 2) | 4 dano, cura 2 | 4 dano, **cura 4** | 4+2 = 6 / 6 | Selo que mais dispara; sobe para P |

### 2.3 Propostas recusadas ou adiadas

| # | Carta | Decisão | Justificativa |
|---|---|---|---|
| 7 | Tumba Vazia ×2 custo 2 → 3 | **recusada** | proposta motivada pelo laço "Miguel morre → Tumba → destrói de novo"; a regra nova (revive não dispara Despertar) desfez o laço sem tocar na carta. Conta: 3 + 3,6/2 = 4,8 / 6, dentro. Observar na rodada 2 |
| 10 | Caldeirão: revive para a mão, +2/+3 | **recusada** | idem: motivada pelo laço Hécate/Baba Yaga de volta com Despertar. Conta 3+5 = 8 / 8 |
| 21 | Leviatã Vida 7 → 6 | **adiada** | condicional ("se cristianismo > 58 após #5–#7"); cristianismo ficou em 53,0 |
| 22 | Terra sem Males cura 4 → 6 | **adiada** | baixa prioridade; indígena deve subir com a queda do hinduismo. Candidata se continuar < 45 |
| 23 | Cocar +3 → +4 Vida | **adiada** | idem |
| — | taoismo inteiro | **sem mudança** | recomendação do Analista; só textos (ver 2.4) |
| — | Dantalion, Selo de Salomão, Babalon, Hanuman, Jaci, Om, Tandava, Juízo Final, Xiwangmu | **sem mudança** | conforme o Analista. Dantalion subiu de 39 → 55 % global com o deck; espelho 64 → 63 %, continua o ponto a vigiar quando alta magia passar de 35 % |

### 2.4 Textos atualizados pela regra nova de Despertar (sem mudança de número)

Descida do Avatar, Kali, Shiva, Narasimha (hin); Tumba Vazia, Talita Cumi, Judite, São Miguel (cri); Caldeirão de Renascimento (bru); Kuarup (ind); Pílula de Ouro, Pássaro Vermelho do Sul, Xiwangmu — contexto e papel (tao). `_deck.md` de hinduismo, cristianismo e taoismo (identidade/convenções). Cada `_deck.md` ganhou `## Histórico de balanceamento` com a rodada 1; listas, contagens e curvas conferidas (só Brahmastra 3 → 4, Conjuração 3 → 2, Abrahadabra 4 → 3, Paimon sem "Sacrifício 1" mudam na lista; ATK/Vida nas tabelas da bruxaria).

---

## 3. Matriz antes × depois (seed 11, n = 2000)

### Antes (pós-motor)

| | alta_magia | bruxaria | cristianismo | hinduismo | indigena | taoismo | **média** |
|---|---|---|---|---|---|---|---|
| **alta_magia** | — | 28,9 | 23,4 | 4,5 | 25,4 | 17,3 | **19,9** |
| **bruxaria** | 71,1 | — | 37,6 | 17,8 | 50,0 | 56,0 | **46,5** |
| **cristianismo** | 76,6 | 62,4 | — | 23,9 | 69,7 | 57,5 | **58,0** |
| **hinduismo** | 95,5 | 82,2 | 76,0 | — | 81,8 | 85,4 | **84,2** |
| **indigena** | 74,6 | 50,0 | 30,3 | 18,2 | — | 49,9 | **44,6** |
| **taoismo** | 82,7 | 44,0 | 42,5 | 14,6 | 50,1 | — | **46,8** |

### Depois (final, com Kali)

| | alta_magia | bruxaria | cristianismo | hinduismo | indigena | taoismo | **média** |
|---|---|---|---|---|---|---|---|
| **alta_magia** | — | 48,1 | 43,9 | 11,3 | 42,8 | 37,9 | **36,8** |
| **bruxaria** | 51,8 | — | 36,9 | 18,8 | 44,1 | 53,1 | **40,9** |
| **cristianismo** | 56,1 | 63,1 | — | 27,9 | 64,6 | 53,2 | **53,0** |
| **hinduismo** | 88,6 | 81,2 | 72,1 | — | 75,5 | 80,4 | **79,6** |
| **indigena** | 57,2 | 55,9 | 35,4 | 24,4 | — | 52,2 | **45,0** |
| **taoismo** | 62,2 | 46,9 | 46,8 | 19,6 | 47,8 | — | **44,6** |

(1º passe, antes de Kali: hinduismo 80,6; o resto igual ±0,2.)

**Leitura.** Decks na faixa 42–58: 3 (cristianismo, indígena, taoismo) — antes 3 (cristianismo, taoismo, bruxaria). Confrontos fora de 30–70: 9 → **5**, todos do hinduismo. Metas mínimas do Analista para a rodada: alta magia ≥ 30 **atingida** (36,8); nenhum confronto < 15 **não atingida** (alta × hinduismo ficou em 11,3; era 4,5); hinduismo ≤ 65 **não atingida** (79,6).

- **Alta magia +17 pp**: Conjuração "na mão" 53 → 27 %, Paimon 30 → 8 %, Dantalion 31 → 23 %; as seis mudanças funcionaram em conjunto. Abrahadabra agora fica na mão 28 % (antes 11 %) — sem a compra, o bot a segura como fecho; aceitável, mas medir.
- **Bruxaria −5,6 pp**: a queda é quase toda o confronto com alta magia (71 → 52) — a bruxaria vivia de bater no deck mais fraco — mais Baba Yaga/Hécate. Ficou abaixo da faixa (40,9). Não compensei nesta rodada para não mascarar o efeito das mudanças; ver dúvidas.
- **Hinduismo −4,6 pp apenas.** Cinco cortes (Shiva, Brahmastra, Garuda, Vajra, Narasimha) mais Kali tiraram 4,6 pp. Nenhuma carta do deck destoa no espelho (só Shiva, 68 %); a força é **estrutural**: Ímpeto em 5 corpos + aura de Krishna, remoção barata (Yajna 2 dano + 2 Fé por 2) e o fato de o HeurBot só bloquear quando mata. Espelho continua em 8,5 rodadas com 65 % para quem começa.
- **Duração**: alta magia × hinduismo 8,2 → 9,2; todos os confrontos de alta magia ficaram ~1 rodada mais longos (menos fadiga própria, mais mesa). Cristianismo × indígena 15,9 e espelho cristão 17,1 continuam acima de 14.

### Espelhos dos decks mexidos (WR da carta, antes → depois)

| Deck | rodadas | 1º vence | Cartas (antes → depois) |
|---|---|---|---|
| hinduismo | 8,1 → 8,5 | 66,2 → 65,0 % | Shiva **71,9 → 68,1**; Vajra 58,8 → 56,7; Kali 54,1 → 52,5; Narasimha 51,4 → 45,5; Brahmastra 47,5 → 45,0; Garuda 51,3 → 51,5; Hanuman 52,4 → 52,6 |
| cristianismo | 16,2 → 17,1 | 46,2 → 47,7 % | Miguel 60,8 → 58,9; Elias 58,6 → 58,7; Judite 49,2 → 48,8; Tumba 50,8 → 50,0; Talita 49,2 → 48,7; Leviatã 56,5 → 56,9 |
| bruxaria | 11,6 → 11,9 | 48,1 → 47,8 % | Hécate **70,5 → 70,0**; Baba Yaga **62,9 → 62,2**; Cerridwen 60,3 → 60,1; Caldeirão 60,1 → 57,0; Boneco 46,9 → 47,7 |
| alta_magia | 13,1 → 13,3 | **60,0 → 55,6 %** | Dantalion 64,3 → 62,7; Paimon 53,6 → 50,5; Conjuração 41,9 → 45,4; Pedra 50,7 → 51,8; Kelley 47,3 → 47,4; Andras 48,6 → 49,3 |
| indigena | 14,7 → 14,8 | 51,7 → 49,7 % | Dança do Aruanã 39,4 → 40,1; Boitatá 48,9 → 48,9; Mundéu 49,8 → 49,9 |

Hécate e Baba Yaga quase não se moveram no espelho: −1 ATK numa Lendária de custo 7 não muda quem ganha a partida em que ela é jogada (quem chega ao turno 7 com Sacrifício pago já está ganhando). O espelho mede *correlação com vitória*, e para cartas caras isso é sobretudo "a partida durou". Ver dúvida 4.

---

## 4. Dúvidas para o Analista medir na rodada 2

1. **Hinduismo é estrutural, não de carta.** Medir dano de ataque à Cornucópia por partida (antes 14–17; meta ≤ 11) depois dos cortes; se continuar ≥ 13, as alavancas de carta restantes são: (a) **Krishna** — a aura de Ímpeto vale 3 pts na §10 como "+1 ATK em todas"; num deck de tempo ela vale mais (proposta: 4/4 → 3/4, ou aura só em `other_ally_entities`); (b) **Yajna** 2 dano + 2 Fé temp por 2 Fé é remoção grátis (proposta: +1 Fé); (c) **Hanuman** 3/3 → 3/2 ou perder Ímpeto (contra a identidade). Prefiro que o Analista também teste um **bot que bloqueia** em troca ruim quando a Cornucópia está baixa (§4.4 do `r1_analise`): se o 80 % cair para 65 só com isso, o problema é do bot, não das cartas, e não devemos nerfar o deck para um adversário que não se defende.
2. **Alta magia × hinduismo 11,3 %** é o único confronto < 15. Separar quanto é fadiga (deve ter caído com 4 compras a menos) e quanto é corrida perdida nas rodadas 2–5. Medir: partidas com fadiga (meta ≤ 15 %), dano de fadiga (≤ 1), dano de ataque por partida (≥ 8), "na mão" de Astaroth/Dantalion/Babalon (meta ≤ 20 %; Paimon já em 8 %). Abrahadabra "na mão" 28 % — é o bot segurando o fecho ou custo ainda alto?
3. **Bruxaria 40,9 %** caiu abaixo da faixa por perder o saco de pancadas (alta magia). Se com hinduismo mais fraco ela não voltar a ≥ 42, as candidatas em identidade são os malefícios/familiares que o Analista apontou abaixo do deck: Sapo 43 %, Malefício 45 %, Gato 45 % — e não devolver corpo a Hécate/Baba Yaga. Medir WR dos familiares e taxa de pactos pagos (Baba Yaga "na mão" 18 %).
4. **Espelho como métrica para Lendárias caras**: Hécate 70 %, Shiva 68 %, Dantalion 63 % mal se mexeram com −1 ATK. Pedir ao Analista uma métrica complementar — WR da carta **condicionada à rodada em que foi jogada** (ou "WR da partida em que a carta foi comprada", que não tem viés de sobrevivência) — antes de cortar mais corpo delas.
5. **Cristianismo 53,0 %** entrou na faixa, mas à custa de 3 cortes + regra nova. Vigiar se o deck ficou *lento demais* (espelho 17,1 rodadas, × indígena 15,9): a meta de duração 7–14 falha. Candidatas para encurtar sem fortalecer: Multiplicação dos Pães / Cova dos Leões (cura) ou o Véu de Verônica. Medir Lendárias revividas para o campo por partida (meta ≤ 0,25 — agora revivem sem Despertar, então o número pode ficar alto sem ser problema; medir *destroy de Miguel por partida* em vez disso).
6. **Indígena 45,0 %** não subiu com #15–#17 (o espelho mostra Boitatá 48,9 e Mundéu 49,9: neutros). Medir a taxa de disparo do `on_damaged` de Boitatá (antes 0,15/partida com `ally_attacked`) e o dano de ataque à Cornucópia (antes 4,5–8; meta ≥ 9). Se continuar em "muro sem fecho", as adiadas #22/#23 são a próxima linha, ou dar fecho à Cobra-Grande.
7. **Taoismo 44,6 %** caiu 2 pp (perdeu contra alta magia 83 → 62). Confirmar que a regra nova de Despertar não deixou Pílula ×2 fraca demais (WR 48 → 46,5; "na mão" 7 %): se Pílula/Pássaro ficarem < deck−8 no espelho, a troca Pílula → Bagua de Fuxi (`_reserva/`) passa a ser por fraqueza, não por força.
8. **Narasimha 45,5 % no espelho** (era 51,4): o 3/2 pode ter passado do ponto. Alternativa: 2/3 (mesma conta). Medir na rodada 2.
9. **Andras com custo ≤ 3** — medir quantos alvos encontra (antes 7 % na mão) e se o 3/2 morre antes de atacar.
10. **Seeds**: rodar também seed 12 para confirmar que as diferenças de 1–2 pp (Kali, Boitatá, Mundéu) não são ruído (erro-padrão ~1,1 pp por célula).
