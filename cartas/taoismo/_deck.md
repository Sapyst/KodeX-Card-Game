# Deck Taoismo (`tao`) — identidade e lista

## Identidade mecânica

**Equilíbrio e imortalidade.** O deck quase não causa dano direto (zero à Cornucópia inimiga): ele ganha prolongando a vida das próprias Entidades e encurtando a utilidade das inimigas. O yin-yang aparece como buff/debuff simétrico (Taiji dá +2/+2 a um lado e −2/−2 ao outro; o Dragão Azul cresce, o Tigre Branco pune); o **qi** é Fé temporária que circula (Circulação do Qi, Han Xiangzi); o **elixir** é Renascer e revive (Li Tieguai, Nezha, Pêssego da Imortalidade, Pílula de Ouro, Zhongli Quan, Xiwangmu, Pássaro Vermelho — o revive para o campo devolve corpos, não Despertares). Os **talismãs Fulu** são o Selo de controle (anular Rito) e os **Quatro Símbolos** são Selos-guardiões, um por direção, cada um com um gatilho diferente — escolha deliberada: guardiões passivos do altar, não seres que se invocam. O **espelho** desmascara (silêncio). A Lendária maior, o Imperador de Jade, não ataca a Cornucópia: ele é uma aura.

**Oito Imortais.** As oito figuras são Entidades baratas (custo 1–3), uma cópia cada, que valem mais em grupo: Lü Dongbin é aura de ATK, Lan Caihe e Han Xiangzi disparam com `ally_count_min`, He Xiangu cura todo turno, Cao Guojiu segura a linha com Guarda, Zhongli Quan e Li Tieguai trazem corpos de volta. O plano típico: turnos 1–3 enfileiram Imortais; turno 4 Taiji ou Nezha; turnos 5–7 Erlang, Guan Yu, Xiwangmu reciclando quem morreu; turno 7 o Imperador de Jade transforma uma mesa de 1/2 em uma mesa de 2/3. Fraquezas: dano em área (uma mesa de corpos pequenos morre junto), silêncio (as auras somem) e devolver à mão (Despertares gastos). Pontos fortes: atrito longo e recuperação.

**Três camadas de fonte.** O deck lê "taoismo" de forma ampla e cada carta diz de onde vem: filosofia (Daodejing, Zhuangzi, Yijing → Taiji, Circulação do Qi), religião organizada (Baopuzi, Mestres Celestiais, Quanzhen → Fulu, Pílula de Ouro, Espelho, os Imortais patriarcas) e mitologia popular absorvida pelo taoismo religioso (Fengshen Yanyi, Jornada ao Oeste, culto dos Oito Imortais → Nezha, Erlang, Guan Yu, Imperador de Jade, Banquete).

## Convenções de valor usadas no Balanço (complementam `regras.md` §10)

- Aura `static` e buff/cura "em todas as aliadas": **valor unitário × 3** (§10). As duas auras do deck usam `other_ally_entities` (a fonte não se buffa): Lü Dongbin +1 ATK = 3; Imperador de Jade +1/+1 = 6.
- Efeito recorrente (`end_turn`, `equipped_attacks`, gatilhos `ally_*`/`enemy_*`): **valor cheio do efeito, uma vez**, sem ×0,7 e sem ×2 — a regra de §10 para gatilho repetível, a mesma usada em Orobas (alta magia), Jaci (indígena) e Funda de Davi (cristianismo). _(A versão anterior deste deck contava ×2; a revisão desfez.)_
- `silence` 2 · `freeze` 1,5 · `give_keyword` = valor da palavra-chave · token = ATK + Vida + keywords (§10).
- Revive para o campo: 3 + custo do alvo ÷ 2; alvo típico neste deck custa 2–3 → **4–4,5 pts**; pior caso (Guan Yu, Erlang, custo 5) 5,5. Revive para o campo **não** dispara o Despertar do revivido (regras §8, rodada 1): volta o corpo, as palavras-chave e os gatilhos contínuos (auras, `end_turn`). Para repetir um Despertar, reviva para a mão (Zhongli Quan) e reinvoque.
- `ally_count_min n` conta todo o campo, inclusive a própria carta (o Despertar resolve com ela em campo; motor `_cond_ok`).
- Condicional ×0,7; Selo e Relíquia têm +1 pt grátis.

## Comportamentos do motor que importam a este deck

- Em `ally_dies` a carta morta **já está no cemitério** quando o Selo dispara (`_morrer` → `cemiterio.append` → `_disparar_selos`; README do sim, regra 18b). O Pássaro Vermelho pode, portanto, reviver exatamente quem acabou de morrer. Se a morta tinha Renascer, foi para a mão e o Selo revive outra.
- Selos de `ally_dies`/`ally_damaged` só disparam no turno do oponente (regra 15): Pássaro Vermelho e Tartaruga Negra não reagem a trocas feitas no seu próprio ataque.
- A cura da Tartaruga Negra resolve em `_pos_dano`, antes de `_processar_mortes`: salva quem levou dano letal se a cura cobrir o excesso.
- Dois Selos com o mesmo gatilho disparam ambos (regra 12): dois Fulu de Selamento em campo gastam-se no mesmo Rito.
- `silence` apaga keywords concedidas (Renascer do Pêssego, Furtivo do Espelho, Guarda da Tartaruga) mas mantém buffs permanentes e a Relíquia (regra 24).
- Nenhuma Relíquia usa **Usos**: as duas são permanentes (buff `on_equip` + keyword).
- Não há `buff` simétrico num só alvo-par: o Taiji usa duas ações separadas. Não há "ganhar Fé no turno do oponente" útil para Selos, então o qi fica em Entidades e Ritos.

## Lista das 32 cartas

| # | Carta | Tipo | Custo | Cópias | Resumo |
|---|---|---|---|---|---|
| 01 | Lan Caihe | Entidade 1/1 | 1 | ×1 | Despertar: com 2+ Entidades, compra 1 |
| 02 | He Xiangu | Entidade 1/3 | 2 | ×1 | Fim do turno: cura 2 em uma aliada |
| 03 | Han Xiangzi | Entidade 1/2 | 2 | ×1 | Despertar: com 2+ Entidades, +2 Fé temporária |
| 04 | Li Tieguai | Entidade 1/2 | 2 | ×1 | Renascer |
| 05 | Zhongli Quan | Entidade 2/3 | 3 | ×1 | Despertar: revive do cemitério para a mão |
| 06 | Lü Dongbin | Entidade 2/2 | 3 | ×1 | Aura: outras aliadas +1 ATK |
| 07 | Zhang Guolao | Entidade 2/3 | 3 | ×1 | Despertar: devolve Entidade inimiga à mão |
| 08 | Cao Guojiu | Entidade 1/4 | 3 | ×1 | Guarda; Despertar: cura 2 em uma aliada |
| 09 | Nezha | Entidade 3/3 | 4 | ×1 | Ímpeto, Renascer |
| 10 | Zhong Kui | Entidade 3/4 | 4 | ×1 | Despertar: silencia Entidade inimiga |
| 11 | Erlang Shen | Entidade 3/5 | 5 | ×1 | Despertar: invoca Cão Celestial 2/1 |
| 12 | Guan Yu, Imperador Guan | Entidade 4/5 | 5 | ×1 | Guarda; Despertar: aliada +1 ATK |
| 13 | Xiwangmu, Rainha Mãe do Oeste | Entidade 4/5 · **Lendária** | 6 | ×1 | Despertar: revive para o campo |
| 14 | Imperador de Jade | Entidade 5/6 · **Lendária** | 7 | ×1 | Aura: outras aliadas +1/+1 |
| 15 | Fulu de Selamento | Selo | 2 | ×2 | Anula Rito inimigo; compra 1 |
| 16 | Dragão Azul do Leste | Selo | 2 | ×1 | Fim do turno inimigo: aliadas +1/+1 |
| 17 | Tigre Branco do Oeste | Selo | 2 | ×1 | Inimiga ataca: 4 de dano e −1 ATK nela |
| 18 | Pássaro Vermelho do Sul | Selo | 2 | ×1 | Aliada morre: revive para o campo; cura 2 Cornucópia |
| 19 | Tartaruga Negra do Norte | Selo | 1 | ×1 | Aliada sofre dano: cura 4, +0/+1 e Guarda |
| 20 | Circulação do Qi | Rito | 1 | ×2 | +1 Fé temporária; compra 1 |
| 21 | Flechas de Houyi | Rito | 2 | ×1 | 3 de dano a Entidade inimiga; compra 1 |
| 22 | Pílula de Ouro | Rito | 3 | ×2 | Revive para o campo; compra 1 |
| 23 | Banquete dos Pêssegos | Rito | 3 | ×1 | Aliadas +1/+1; cura 2 Cornucópia |
| 24 | Taiji | Rito | 4 | ×2 | Aliada +2/+2; inimiga −2/−2 |
| 25 | Pêssego da Imortalidade | Relíquia | 2 | ×2 | +1/+2; portadora ganha Renascer |
| 26 | Espelho de Bronze | Relíquia | 2 | ×2 | +1/+1, Furtivo; silencia Entidade inimiga |

**26 cartas distintas, 32 no deck.** Ainda acima da faixa indicativa (~20–24) de `regras.md` §4 por escolha: os Oito Imortais e os Quatro Símbolos são singletons (12 cartas que não podem virar ×2 sem quebrar o conjunto). A faixa de custo 1–2 das Entidades é inteiramente de Imortais (Lan Caihe, He Xiangu, Han Xiangzi, Li Tieguai = exatamente os 4 slots), então He Xiangu ×2 ou Li Tieguai ×2 estouram a curva 4/6/3/1 — por isso a consolidação foi feita em Selos, Ritos e Relíquias.

Cartas fora do deck, preservadas em `_reserva/` (válidas, prontas para voltar): **Fulu de Imobilização** (Selo 1), **Bagua de Fuxi** (Rito 2), **Caldeirão dos Nove Tripés** (Relíquia 3). Se o simulador pedir mais controle de tempo, Imobilização entra no lugar do segundo Fulu de Selamento; se pedir consistência, Bagua no lugar do segundo Taiji.

## Contagem por tipo

| Tipo | Qtd. | Cartas |
|---|---|---|
| Entidade | **14** | 01–14, ×1 cada |
| Selo | **6** | 15 ×2, 16, 17, 18, 19 |
| Rito | **8** | 20 ×2, 21, 22 ×2, 23, 24 ×2 |
| Relíquia | **4** | 25 ×2, 26 ×2 |

## Curva de custo das Entidades

| Faixa | Esperado | Cartas |
|---|---|---|
| 1–2 | 4 | Lan Caihe (1), He Xiangu (2), Han Xiangzi (2), Li Tieguai (2) |
| 3–4 | 6 | Zhongli Quan (3), Lü Dongbin (3), Zhang Guolao (3), Cao Guojiu (3), Nezha (4), Zhong Kui (4) |
| 5–6 | 3 | Erlang Shen (5), Guan Yu (5), Xiwangmu (6, Lendária) |
| 7–8 | 1 | Imperador de Jade (7, Lendária) |

Lendárias: **2** (Xiwangmu custo 6, Imperador de Jade custo 7), 1 cópia cada.

## Contadores de sanidade

- Dano direto à Cornucópia inimiga: **0**. `destroy`: **0**. `counter`: **2** (Fulu de Selamento ×2). `silence`: 3 (Zhong Kui, Espelho ×2). `bounce`: 1 (Zhang Guolao).
- Recursão: Renascer em Li Tieguai, Nezha, Pêssego ×2 (4 cartas); revive para o campo em Pílula ×2, Pássaro Vermelho, Xiwangmu (4); revive para a mão em Zhongli Quan (1). Total 9 de 32 — mesma ordem do deck cristão (Lázaro ×2, Tumba Vazia ×2, Talita Cumi ×2, Renascer ×3).
- Gatilhos de Selo: `enemy_plays_rite` ×2, `enemy_end_turn`, `enemy_attacks`, `ally_dies`, `ally_damaged` — todos reais e distintos entre os Quatro Símbolos.

## Avisos esperados do validador

- `01_lan_caihe`: ATK+Vida = 2 com P = 3 — qualquer corpo de custo 1 com habilidade dispara o aviso; a habilidade é condicional (1,05 pt) e a conta fecha em 3,05.
- `02_he_xiangu`: ATK+Vida = 4 com P = 5 — a cura recorrente vale 1 pt pela regra oficial; conta fecha em 5.

## Histórico de balanceamento

- **Rodada 1** (ver `sim/relatorios/r1_mudancas.md`). Linha de base pós-motor: 46,8 % de média (48,9 antes da regra nova de Despertar, que enfraqueceu Pílula ×2, Pássaro Vermelho e Xiwangmu). **Nenhuma carta alterada**, por recomendação do Analista: o deck deve subir sozinho com os cortes em hinduismo (14,6 % contra ele) e cristianismo. Só textos: Pílula de Ouro, Pássaro Vermelho do Sul, Xiwangmu e a convenção de revive acima refletem que reviver para o campo não dispara Despertar. Se na rodada 2 passar de 58 %, primeiro corte é Pílula ×2 → ×1 com Bagua de Fuxi (`_reserva/`) de volta.
