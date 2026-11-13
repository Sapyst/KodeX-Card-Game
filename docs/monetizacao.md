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

## 6. Ordem sugerida

1. Itens 1–3 da seção 5 (já estão no levantamento; servem também sem cobrança).
2. Pacto do Mês: é o mais simples (um produto, sem arte nova além do verso do mês).
3. Arte de molduras e emotes → pacotes de Koins.
4. Passe de temporada, quando houver missões e arte para 30 níveis.
