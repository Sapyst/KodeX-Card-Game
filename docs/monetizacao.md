# KodeX — Monetização (plano, 13/11/2026)

Nada daqui está no jogo ainda. A cobrança só entra quando o KodeX for publicado (Play Store e/ou Steam); no alpha
(APK fora da loja + site) não se cobra nada.

**Preço-base em dólar (EUA).** Os outros países recebem preço localizado pela tabela de preço regional da loja. No
Brasil o preço sai **~35–40% do dólar convertido**, alinhado ao poder de compra. Câmbio usado nas contas:
**US$ 1 = R$ 5,50**; atualizar quando for definir os preços de verdade.

## 1. Regras de base

1. **Booster nunca é vendido por dinheiro.** Booster é sorteio. Comprado com dinheiro real conta como caixa de
   recompensa ("loot box"). A Lei 15.211/2025 (ECA Digital, em vigor desde março/2026) proíbe isso em jogos voltados
   a menores ou que eles provavelmente acessem. Bélgica e Holanda têm regra parecida. **Confirmar com advogado antes de
   lançar.** Isso vale também para o caminho indireto: comprar moedas com dinheiro e trocar por booster.
2. **O dinheiro compra só o que não tem sorteio:**
   - Essência, que cria a carta escolhida;
   - cosméticos (versos, molduras, emotes);
   - conveniência (mais moedas por dia, que o jogador escolhe em que gastar).
3. **Nenhuma carta é exclusiva de quem paga.** Tudo sai jogando de graça; quem paga só chega mais rápido. Isso protege
   a ranqueada.
4. **Sem punição por faltar um dia:** a semana conta com 6 de 7 dias coletados.
5. **Moedas e boosters de loja nunca entram no Pacto como compra**: o booster da semana completa é prêmio por
   jogar, não item comprado.

## 2. O que já existe de graça (servidor/src/index.js, `R`)

| Item | Valor |
|---|---|
| Presente diário | 50 moedas + 10 Koins por dia, acumula até 3 dias |
| Bônus semanal | 100 Koins |
| Booster | 100 moedas (3 cartas, ≥ 1 Entidade) |
| Vitória online ranqueada | 20 moedas (derrota 5, empate 10) |
| Essência ao desfazer | C 5 · R 10 · SR 40 · UR 100 |
| Essência para criar | C 40 · R 100 · SR 400 (UR não se cria) |
| Versos (Koins) | 150 / 300 / 800 |

Quem só pega o presente: **~15 boosters/mês** e **~700 Koins/mês**.

## 3. Produtos

Nas colunas, o primeiro valor é o preço; o segundo, quanto ele vale em dólar depois de convertido.

### 3.1 Pacto do Mês (assinatura de 30 dias)

| | EUA (base) | Brasil |
|---|---|---|
| Preço | **US$ 4,99** | **R$ 9,90** (≈ US$ 1,80, 36%) |

| | Grátis | Com o Pacto |
|---|---|---|
| Moedas por dia | 50 | 50 + **25** |
| Essência por dia | — | **+5** |
| Koins por dia | 10 | 10 + **5** |
| Semana completa (6 de 7 dias) | — | **+1 booster** (prêmio por jogar) |
| Na assinatura | — | verso exclusivo do mês + **150 Essência** |

- **No mês:** grátis ~15 boosters; com o Pacto, ~26 boosters em moedas e prêmios, **~300 Essência** (3 R ou quase
  1 SR) e +150 Koins. Cerca de 70% a mais.
- **Coleta:** os bônus só caem para quem abre o jogo no dia, junto com o presente diário que já existe (mesma tela,
  segunda linha).
- **Verso do mês:** depois sai da vitrine do Pacto e volta para a loja de Koins em 6 meses. Exclusivo para sempre gera
  medo de perder.

### 3.2 Passe de temporada (a cada ~6 semanas)

| | EUA (base) | Brasil |
|---|---|---|
| Preço | **US$ 9,99** | **R$ 14,90** (≈ US$ 2,70, 27%) |

- **Trilha grátis e trilha paga** de 30 níveis cada, avançando com as missões diárias e semanais que já existem (XP de
  `progressao.json`).
- **Trilha grátis:** moedas, Koins e 3 boosters.
- **Trilha paga:**
  - 2 versos e 1 moldura de temporada;
  - 1 emote;
  - **600 Essência** no total;
  - o título da temporada.
- **Sem venda de níveis.** Comprar nível acelera o passe e esvazia o sentido de jogar.

### 3.3 Pacotes de Koins (cosméticos)

Os valores entre parênteses mostram quantos versos de 150 cada pacote compra.

| Pacote | EUA | Brasil |
|---|---|---|
| 300 Koins (2 versos de 150) | US$ 1,99 | R$ 4,90 |
| 1.000 Koins (+10% de bônus) | US$ 4,99 | R$ 11,90 |
| 2.500 Koins (+25% de bônus) | US$ 9,99 | R$ 22,90 |

- O ganho grátis de Koins (~700/mês) continua.
- **Depende de arte nova:** molduras e emotes estão parados por falta de arte (9.2 do levantamento de nov/2026).

### 3.4 Vídeo por recompensa (opcional, só Android)

- **Recompensa:** +20 moedas por vídeo, até 3 por dia.
- **Nunca** vídeo forçado entre partidas.
- Renda pequena, mas vem de quem nunca paga.

## 4. Estimativa com 10 mil jogadores por dia

**Suposições:**
- 3% pagam o Pacto e 3% compram o passe por temporada (jogo grátis costuma ficar entre 2 e 5%);
- loja do Google com 15% de taxa (assinatura sempre 15%; compra avulsa 15% até US$ 1 mi/ano);
- valores em US$ por mês, já sem a taxa da loja.

| Fonte | Cenário A: 70% Brasil, 30% EUA/Europa | Cenário B: 100% Brasil |
|---|---|---|
| Pacto | ~US$ 700 | ~US$ 460 |
| Passe (por mês, temporada de 6 semanas) | ~US$ 890 | ~US$ 490 |
| Koins + vídeos | ~US$ 200–400 | ~US$ 150–250 |
| **Total** | **~US$ 1.800–2.000** | **~US$ 1.100–1.200** |
| Servidor (Cloudflare) | US$ 30–45 | US$ 30–45 |

Ainda sai imposto sobre a receita (Simples/MEI, ~6%) e, na Steam, a taxa é de 30%. A conversão real pode ser metade
disso: tratar como teto otimista.

## 5. Antes de cobrar qualquer coisa

Com dinheiro envolvido, cada brecha na economia vira prejuízo direto.

1. **Prêmios declarados pelo próprio jogo** (item 13 do levantamento de 07/11): hoje dá para forjar ~1.500 moedas e
   ~10 boosters por dia. A economia tem que ser decidida pelo servidor (o juiz já sabe quem venceu).
2. **Conta nova com perfil forjado** (item 3 do mesmo levantamento): o servidor aceita até 5.000 moedas e 10 boosters
   vindos do aparelho.
3. **Perfil com versão** (1.10): dois pedidos ao mesmo tempo podem apagar uma compra.
4. **Compra conferida no servidor:** o recibo do Google Play (Play Developer API) ou da Steam (`ISteamMicroTxn`) é
   validado no Worker antes de creditar. Assinatura renovada ou cancelada chega pelo aviso do Google
   (Real-time Developer Notifications).
5. **Reembolso:** quando o Google avisa de um reembolso (Voided Purchases API), o servidor tira de volta a Essência e os
   Koins comprados; se já foram gastos, o saldo fica negativo.
6. **Chances visíveis:** a loja já mostra as chances do booster (exigência do Google para itens sorteados); manter
   mesmo sem venda direta.
7. **Classificação indicativa e política de dados:** revisar com o modelo de cobrança definido.

## 6. Recompensas: muito mais variedade, quase tudo de graça

O que se ganha hoje é estreito:
- as 25 diárias pagam só moedas (20–40);
- as 51 conquistas pagam moedas, e só 8 dão título;
- as semanais pagam boosters;
- os 10 versos saem só por Koins;
- há só 4 emotes e nenhum retrato liberável.

Para o pago não parecer a única novidade, **pelo menos 2/3 de cada tipo de cosmético sai jogando**. O pago fica com
o verso do mês e a trilha paga do passe.

### 6.1 Catálogo (tipos novos em negrito)

| Tipo | Hoje | No lançamento | Arte |
|---|---|---|---|
| Moedas, Koins | sim | — | — |
| Essência como prêmio | só ao desfazer | missões, calendário, maestria | — |
| **Booster de tradição** (3 cartas de uma tradição escolhida, ≥ 1 Entidade) | — | prêmio de semanal e maestria | reaproveita o pacote |
| **Escolha de carta** (3 cartas da raridade indicada que faltam na coleção; fica com 1) | — | semanal, calendário, conquista | — |
| Títulos | 20 | **45** (+25) | — (texto) |
| Versos | 10 (Koins) | **22**: +6 de maestria, +6 de conquista | código (SDF) |
| **Moldura do retrato** (perfil, mesa e ranking) | — | **18**: 6 de tradição, 4 de ranqueada, 8 de conquista | código (SDF) |
| Emotes | 4 | **20**: +2 por tradição (12), +4 de evento | texto + ícone 16 px |
| **Tapete da mesa** | — | **7**: padrão + 6 tradições | código |
| **Efeito de vitória** (fim da partida) | — | **6**, 1 por tradição | partículas por código |
| **Estrela de maestria da carta** (canto da carta) | — | ~160 cartas × 3: bronze 25, prata 100, ouro 250 vezes jogada | código, 3 desenhos para todas |
| **Insígnia da temporada ranqueada** | — | 4 por temporada | código |
| **Página do Códex** (lore de cada Entidade, `dados/codex/`) | aberto | libera ao vencer com a Entidade em campo | — (texto já existe) |
| Retratos de personagem | 0 liberáveis | 1 por chefe de Arcade e Peregrinação | arte existente |

### 6.2 De onde sai cada coisa

**Diárias (3 por dia):** o tipo do prêmio passa a variar. Cada dia sorteia 1 diária de cada tipo.

| Tipo | Valor |
|---|---|
| Moedas | como hoje, 20–40 |
| Essência | metade do valor em moedas (10–20) |
| Koins | metade do valor em moedas (10–20) |

**Semanais (7):** além dos 2 boosters e das moedas de hoje:
- **booster de tradição** em "vença 5 com a mesma tradição";
- **escolha de carta R** em "complete 15 diárias".

**Calendário de 28 dias (grátis, separado do presente diário):** cada dia marcado ao abrir o jogo. Faltar não zera:
continua do dia em que parou e renova a cada 28 dias marcados.

| Dia | Prêmio |
|---|---|
| 3, 10, 17, 24 | 40 Essência |
| 7 | booster de tradição |
| 14 | escolha de carta R |
| 21 | 2 boosters |
| 28 | **moldura do ciclo** (a cada ciclo uma nova; o Pacto fica com o verso do mês) |
| demais | 30 moedas ou 15 Koins, alternados |

**Maestria por tradição:** hoje são 5 níveis (100–1500 pontos). Passa a 10.

| Nível | Pontos | Prêmio |
|---|---|---|
| 6 | 2.100 | tapete da tradição |
| 7 | 2.800 | 2 emotes da tradição |
| 8 | 3.600 | moldura da tradição |
| 9 | 4.500 | verso da tradição |
| 10 | 5.500 | efeito de vitória da tradição + título "Arauto de <tradição>" |

**Nível da conta:** hoje dá título nos níveis 5, 10, 20, 30 e 50. Passa a dar algo a cada 5 níveis, alternando:
- 200 moedas;
- 100 Essência;
- escolha de carta R;
- título novo.

**Conquistas:** das 51 de hoje, as 12 mais difíceis trocam moedas por cosmético:
- 6 versos;
- 6 molduras.

Entram 20 conquistas novas:
- 10 de coleção, por exemplo "complete a Bruxaria";
- 5 de estrela de ouro, por exemplo "10 cartas com estrela de ouro";
- 5 de Códex.

**Ranqueada por temporada** (6 semanas, junto com o passe):

| Vitórias na temporada | Prêmio |
|---|---|
| 10 | insígnia bronze |
| 30 | insígnia prata + 100 Essência |
| 60 | insígnia ouro + moldura da temporada |
| Top 100 do ranking | insígnia "Hierofante" + título da temporada |

**Fim de semana de evento** (1 por mês):
- Essência ×2 nas diárias;
- desafio especial que dá 1 dos 4 emotes de evento.

### 6.3 Regras

- **Todo prêmio novo é decidido pelo servidor**, como os de hoje (`premio` em `servidor/src/index.js`, motivo + teto
  diário em `limites`). Contadores de carta jogada e de Códex só contam partidas que o juiz viu (online) ou com teto
  diário (solo).
- **Sorteios grátis continuam permitidos** (booster ganho jogando, escolha de carta). A proibição é só sobre
  dinheiro → sorteio.
- **Nenhum cosmético muda o jogo.** Moldura, tapete e efeito aparecem para o adversário, mas sem informação escondida.
- **Acessibilidade:** tapete e efeito de vitória têm opção "simples" (fundo liso, sem partículas); o texto maior
  continua prioridade.

### 6.4 O que dá para fazer já, sem arte nova

1. Diárias com tipo variado (Essência e Koins).
2. Calendário de 28 dias (com a moldura do dia 28 entrando depois).
3. Booster de tradição e escolha de carta.
4. Estrela de maestria da carta (3 desenhos por código).
5. Códex que libera por vitória.
6. 25 títulos e 16 emotes novos (texto).
7. Maestria até o nível 10 e prêmio a cada 5 níveis de conta, com os cosméticos marcados como "em breve".

Depois, por código (sem IA): molduras, versos, tapetes, efeitos de vitória e insígnias.

**Andamento (v0.20.29-alpha, 13/11/2026):**
- **Feito:**
  - itens 1–4 e 7;
  - 25 títulos novos (45 no total);
  - 12 emotes de tradição (maestria 7);
  - 12 conquistas novas (coleção por tradição, estrelas, maestria 10), além da "portador", que agora está no gerador.
- **Mudanças em relação ao plano acima:**
  - maestria 6–10 hoje paga booster de tradição, 2 emotes, 150 Essência, escolha R e 2 boosters de tradição + título
    "Arauto". Tapete, moldura, verso e efeito de vitória entram quando houver a arte;
  - o dia 28 do calendário paga escolha R + 100 Essência até existir a moldura do ciclo.
- **Fica para depois:**
  - Códex que libera por vitória: travar o lore que hoje está aberto tiraria algo de quem já joga;
  - os 4 emotes de evento;
  - as conquistas de Códex.

Regras no código:
- dados em `servidor/gerar_progressao.py` (gera `godot/dados/progressao.json`; o servidor lê pelo `gerar_dados.py`);
- servidor: `creditar`, `marcarCalendario`, `abrirEscolha` e o booster `de_trad`, em `servidor/src/index.js`;
- teste em `servidor/teste/progresso_teste.mjs`.

## 7. Ordem sugerida

1. Itens 1–3 da seção 5 (já estão no levantamento; servem também sem cobrança).
2. Recompensas sem arte (seção 6.4): valem para todos e já dão motivo para jogar todo dia.
3. Pacto do Mês: é o mais simples de cobrar (um produto, sem arte nova além do verso do mês).
4. Cosméticos por código (molduras, versos, tapetes, efeitos, insígnias) → pacotes de Koins.
5. Passe de temporada, quando houver missões e arte para 30 níveis.
