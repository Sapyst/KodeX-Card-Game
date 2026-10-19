# Revisão do deck Taoismo — design e pesquisa

Revisão sênior sobre a versão escrita com a tabela §10 atualizada. Resultado: `validar.py` → `OK` (26 arquivos, 32 cartas, 14/6/8/4, curva 4/6/3/1, 2 Lendárias; 2 avisos esperados) e `cards.carregar_pasta` sem erro. Três cartas saíram do deck e ficaram em `_reserva/` (válidas, com nota de topo); as restantes foram renumeradas 01–26.

## Decisões de consolidação (29 → 26 distintas)

A faixa de custo 1–2 das Entidades é **inteiramente** de Imortais (Lan Caihe, He Xiangu, Han Xiangzi, Li Tieguai = os 4 slots da curva). Logo He Xiangu ×2 ou Li Tieguai ×2 — as sugestões do `_deck.md` anterior — estouram a curva 4/6/3/1 (5 ou 6 na faixa) sem que se possa cortar outra carta da faixa (todas são Imortais). Mover Li Tieguai para custo 3 empurraria a faixa 3–4 a 7 e obrigaria a cortar Nezha ou Zhong Kui. Por isso as Entidades ficaram como estavam (14 distintas) e a consolidação foi feita em Selos, Ritos e Relíquias:

| Saiu (→ `_reserva/`) | Entrou como ×2 | Por quê |
|---|---|---|
| Fulu de Imobilização (Selo 1) | Fulu de Selamento | sugestão original; dois counters ainda ≤ 3; Imobilização era o Selo mais genérico (freeze + −1/−1) e o único fora do conjunto Fulu-anulação / Quatro Símbolos |
| Bagua de Fuxi (Rito 2) | Taiji | com 26 distintas a busca de "1 Entidade + 1 Selo" perde função; 4 pts em P = 5; Taiji é a carta-emblema e a resposta a corpos grandes que o deck não tinha em dose suficiente |
| Caldeirão dos Nove Tripés (Relíquia 3) | Espelho de Bronze | pela regra oficial (gatilho repetível = valor cheio) vale 6 em P+1 = 8; Guarda + cura recorrente era mais "muro"; Espelho acrescenta interação (silêncio) e Furtivo para proteger Lü Dongbin |

Pêssego da Imortalidade ficou ×2 (ver "Renascer" abaixo). Se o simulador pedir controle de tempo, Imobilização volta no lugar do 2º Selamento; se pedir consistência, Bagua no lugar do 2º Taiji.

## Tabela carta → mudança

| # | Carta | Orçamento (P → gasto) | O que mudou e por quê |
|---|---|---|---|
| 01 | Lan Caihe | 3 → 3,05 | ok |
| 02 | He Xiangu | 5 → 5 | **1/2 → 1/3.** A conta anterior inventava "recorrente ×2" (não existe em §10; Orobas, Jaci e Funda de Davi usam valor cheio ×1). Refeita, 1/2 dava 4 (P−1); o corpo subiu para 1/3 para fechar e sobreviver ao primeiro golpe. Novo aviso esperado do validador |
| 03 | Han Xiangzi | 5 → 5,1 | ok |
| 04 | Li Tieguai | 5 → 5 | ok |
| 05 | Zhongli Quan | 7 → 7 | ok |
| 06 | Lü Dongbin | 7 → 7 (aura +1 ATK = 3) | **Pesquisa:** o Sonho do Painço é em **Handan**, não em Chang'an (*Zhenzhong ji*; peça de Ma Zhiyuan), e o sonhador original é Lu Sheng — a atribuição a Lü é Yuan. "Venceu um dragão no Lago Dongting" não tem lastro: substituído pela lenda atestada da espada voadora contra o mestre chan Huanglong e pelas três aparições na Torre de Yueyang. "Tintureiros" → fabricantes de tinta de escrever |
| 07 | Zhang Guolao | 7 → 7 | ok |
| 08 | Cao Guojiu | 7 → 7 | ok |
| 09 | Nezha | 9 → 9 | contexto: uma frase situando a origem (Nalakuvara budista → mitologia popular Ming → taoismo religioso), para a distinção filosófico × religioso × popular |
| 10 | Zhong Kui | 9 → 9 | ok |
| 11 | Erlang Shen | 11 → 11 | ok |
| 12 | Guan Yu | 11 → 11 | ok |
| 13 | Xiwangmu | 13 (+2 = 15) → 13,5–14,5 | **Renascer removido.** Com Renascer: 15,5 no caso típico e 16,5 revivendo custo 5 — acima do teto de Lendária. Sem ele cabe mesmo no pior caso e sai uma das fontes de recursão. Flavor mantido: ela é quem dá o pêssego, não quem o come. **Pesquisa:** no *Han Wudi neizhuan* ela traz sete pêssegos, come três e dá **quatro** (não "dá sete") |
| 14 | Imperador de Jade | 15 (+2 = 17) → 17 | ok — aura +1/+1 em todas = 6 pts, Lendária exatamente no teto |
| 15 | Fulu de Selamento | 5 (+1) → 4,5 | **×1 → ×2.** Nota de motor: dois Selos com o mesmo gatilho disparam juntos (não pôr os dois ao mesmo tempo) |
| 16 | Dragão Azul do Leste | 5 (+1) → 6 | ok (renumerado 17 → 16) |
| 17 | Tigre Branco do Oeste | 5 (+1) → 5 | ok (18 → 17) |
| 18 | Pássaro Vermelho do Sul | 5 (+1) → 5–5,5 | **Pesquisa:** Antares (mansão Xin) pertence ao Dragão Azul, não ao Pássaro Vermelho; corrigido para as mansões Jing–Zhen. **Motor:** o texto dizia que a morta "ainda não está no cemitério" ao disparar — é o contrário (`_morrer` → `cemiterio.append` → `_disparar_selos`; README regra 18b): o Selo pode reviver quem acabou de morrer, com Despertar. Só dispara em morte no turno do oponente (regra 15). (19 → 18) |
| 19 | Tartaruga Negra do Norte | 3 (+1) → 4 | typo "o cascos" (20 → 19) |
| 20 | Circulação do Qi | 3 → 3 | ok (21 → 20) |
| 21 | Flechas de Houyi | 5 → 4,5 | pesquisa: a serpente do *Huainanzi* é Xiushe (Bashe é o nome do *Shanhaijing*); justificado por que é Rito e não Relíquia (é o disparo, não o arco) (23 → 21) |
| 22 | Pílula de Ouro | 7 → 5,5–7 | ok (24 → 22) |
| 23 | Banquete dos Pêssegos | 7 → 7 | ok (25 → 23) |
| 24 | Taiji | 9 → 8 | **×1 → ×2** (26 → 24) |
| 25 | Pêssego da Imortalidade | 5 (+1) → 5 | pesquisa: Han Wudi (quatro pêssegos, não sete); Dushuo é citado no *Lunheng* como do *Shanhaijing* mas não está no texto atual. Regra: silêncio não tira a Relíquia, só o Renascer concedido (27 → 25) |
| 26 | Espelho de Bronze | 5 (+1) → 5 | **×1 → ×2** (28 → 26) |
| — | Fulu de Imobilização | 3 (+1) → 3,5 | → `_reserva/` |
| — | Bagua de Fuxi | 5 → 4 | → `_reserva/` |
| — | Caldeirão dos Nove Tripés | 7 (+1) → 6 | → `_reserva/`; balanço refeito pela regra oficial (era 7 com o ×2 inventado) |

Tipos: todos conferidos — seres → Entidade; Fulu (talismã) e Quatro Símbolos (guardiões passivos, escolha deliberada mantida) → Selo; Qi (prática), Banquete (festa), Pílula (consumível, como Poção de Beladona na bruxaria), Flechas (o ato), Taiji (princípio aplicado) → Rito; Pêssego e Espelho (objetos portados) → Relíquia. Nenhuma troca necessária.

JSON × texto: 26/26 iguais (ops, alvos, números, cópias, stats da tabela); textos entre 1 e 20 palavras.

## Erros de pesquisa encontrados (e corrigidos)

1. **Lü Dongbin / Sonho do Painço em Chang'an** → Handan; o conto Tang (*Zhenzhong ji*) não é sobre Lü — a transferência é do teatro Yuan.
2. **Lü Dongbin "venceu um dragão no Dongting"** → sem fonte; trocado pela espada voadora contra Huanglong e pela Torre de Yueyang.
3. **Xiwangmu / Pêssego / `_estudo.md` §11: "dá sete pêssegos"** → traz sete, come três, dá quatro (*Han Wudi neizhuan*). Corrigido nos três lugares.
4. **Pássaro Vermelho: "coração é Antares"** → Antares é da mansão Xin, no Dragão Azul do Leste.
5. **Pêssego: Dushuo "no *Shanhaijing*"** → trecho só sobrevive citado no *Lunheng*.
6. **Flechas: "serpente Bashe"** no *Huainanzi* → Xiushe (Bashe é do *Shanhaijing*).
7. **`_deck.md` sobre o motor:** afirmava que em `ally_dies` a carta ainda não está no cemitério — o código faz o oposto. Corrigido em `_deck.md` e na carta.
8. Convenção de balanço "recorrente ×2" sem base em §10 e divergente dos outros decks → desfeita (afetou He Xiangu e Caldeirão).

Sem erro: pinyin consistente (Lü, Xiwangmu, Zhongli Quan, Qinglong/Baihu/Zhuque/Xuanwu); datas (Wanli 1614, Zhenzong 1012/1017, Huizong 1115, Zhang Daoling 142, Han Yu 768–824, Renzong 1022–1063); capítulos citados (FSYY 12–14, JAO 4–7, Baopuzi 4/8/17/19, Xici I.11/II.2, Liji "Quli", Zuo zhuan Xuan 3).

## Sanidade do deck

Dano direto à Cornucópia inimiga **0** · `destroy` **0** · `counter` **2** · `silence` 3 · `bounce` 1 · recursão 9/32 (Renascer ×4 cartas, revive-campo ×4, revive-mão ×1) — mesma ordem do deck cristão. Selos: seis gatilhos reais, os Quatro Símbolos com quatro gatilhos distintos.

## Três pontos para o simulador observar

1. **Pássaro Vermelho + Pílula ×2 + Xiwangmu: o laço de Despertar.** Cada revive para o campo repete o Despertar (Zhong Kui silencia de novo, Erlang traz outro cão, Zhongli devolve mais um à mão). Observar o WR-jogada do Pássaro Vermelho e da Pílula contra decks sem silêncio/bounce; se a mesa vira um muro que não se limpa, o primeiro corte é Pílula ×2 → ×1 (Bagua volta) antes de mexer no Pêssego.
2. **Dependência de Lü Dongbin e do Imperador de Jade (auras `other_ally_entities`).** Lü é 2/2 por 3 e morre para qualquer 2-ATK; o deck inteiro é calibrado com a aura ligada. Observar "ficou na mão" e WR das Entidades 1/x quando Lü não aparece — se o deck despenca sem ele, a resposta é Bagua de volta (busca), não buff nos corpos.
3. **He Xiangu 1/3 e a cura recorrente valendo 1 pt.** É a aposta mais frágil da conta oficial: 2 de cura por turno durante 4–5 turnos vale muito mais que 1 pt em jogos longos. Se o WR-jogada dela ficar bem acima do do deck, voltar a 1/2; o mesmo sinal, nos outros decks, pede rever o preço do gatilho repetível em §10. Observar também os dois Fulu de Selamento: se ficarem no campo sem disparar (oponente evita Ritos), Imobilização volta no lugar do segundo.

## Linha de base (smoke test, não calibração)

`duel.py ../cartas/taoismo ../cartas/cristianismo --n 300 --seed 7` roda sem exceção: taoismo 39,3% × cristianismo 60,7%, 14,4 rodadas em média. Nenhuma carta com "ficou na mão" acima de 13% (Banquete 12,7%, Tigre 12,6%, Dragão 11,6% — Selos e buff de área esperam mesa, como previsto). Um só confronto, com bot heurístico: é o ponto de partida da fase de simulação, não um veredito sobre o deck.
