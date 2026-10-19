# Revisão 1 — deck indígena brasileiro (`ind`)

Revisão sênior de design e pesquisa, feita **depois** da atualização da tabela §10 de `docs/regras.md` (Freeze 1,5 · Silence 2 · cura/buff em todas = unitário×3 · aura `static` +1 em todas = 3 · Relíquia com Usos = efeito×N×0,7 · gatilhos repetíveis valem cheio · Sacrifício conta como morte mas não aciona Renascer) e da extensão da DSL (`defender`, `other_ally_entities`, `summon` com `keywords`/`n`, regras de resolução).

Resultado: **nenhuma carta acima do orçamento**, nenhuma troca de tipo, nenhuma troca de custo; 1 ajuste de número (Cocar), 2 ajustes de texto de regra (Arapuca, Mundéu), 7 correções de pesquisa/fonte. `validar.py` → `OK`.

## 1. Carta a carta

Convenção da coluna "Orçamento": gasto / P (Selo e Relíquia já com o +1 grátis; Lendária com teto P+2).

| NN | Carta | Tipo ok? | Orçamento (§10 oficial) | O que mudou e por quê |
|---|---|---|---|---|
| 01 | Saci-Pererê | Entidade ✓ | 4,5 / 5 | Balanço reescrito com Freeze = 1,5 oficial (antes "valor atribuído"). Contexto: frase sobre as camadas africanas/ibéricas reescrita em tom mais cuidadoso. |
| 02 | Curupira | Entidade ✓ | 5 / 5 | ok (balanço só reformulado: gatilho repetível = valor cheio). |
| 03 | Caipora | Entidade ✓ | 7 / 7 | ok. |
| 04 | Iara | Entidade ✓ | 7 / 7 | Contexto: a versão "guerreira invejada pelos irmãos" é popular/literária, não de fonte do séc. XVI — passou a ser atribuída como tal; etimologia *y* + *îara* acrescentada. |
| 05 | Boitatá | Entidade ✓ | 9 / 9 | Contexto: versão gaúcha ganhou fonte (Simões Lopes Neto, *Lendas do Sul*, 1913). Papel no jogo reescrito: Guarda + `ally_attacked` só rende quando há **outra** guardiã em campo — o texto antigo deixava isso confuso. |
| 06 | Anhangá | Entidade ✓ | 9 / 9 | ok; nota sobre Sacrifício (conta como morte → dispararia o Veado; o deck não tem Sacrifício). |
| 07 | Mapinguari | Entidade ✓ | 11 / 11 | **Papel no jogo corrigido**: dizia que Ritos de dano disparavam o grito — pela regra de resolução da DSL, `attacker` inexistente → ação pulada. Fonte Oren corrigida (*Goeldiana Zoologia* 1993 / *Edentata* 2001; "Edentata 1993" não existe). |
| 08 | Cobra-Grande | Entidade ✓ | 13 / 13 | ok. |
| 09 | Jaci, a Lua | Entidade ✓ (L) | 15 / 13 (+2, teto) | Balanço refeito com "cura em todas = unitário×3" (antes usava ×1,5 "como dano em área" — chegava ao mesmo 3 por coincidência). Contexto: lenda da vitória-régia marcada como literária tardia; "Barbosa Rodrigues traz Jaci na lenda de Mani" removido (não confirmado) → "variantes populares". |
| 10 | Tupã, o Trovão | Entidade ✓ (L) | 17 / 15 (+2, teto) | ok. |
| 11 | Arapuca | Selo ✓ | 4 / 4 | **Texto da carta**: "atacar" → "atacar **uma Entidade sua**" (gatilho `enemy_attacks` não dispara em ataque à Cornucópia; o Papel no jogo afirmava o contrário — corrigido). |
| 12 | Mundéu | Selo ✓ | 5 / 6 | Mesma precisão de texto que a Arapuca. |
| 13 | Assovio da Matinta | Selo ✓ | 4 / 4 | ok. |
| 14 | Sopro do Pajé | Selo ✓ | 4,5 / 6 | ok (P−1,5; não está abaixo de P−2). Folga mantida de propósito: `counter` anula Ritos de qualquer custo. |
| 15 | Cauim | Rito ✓ | 2,5 / 3 | ok. |
| 16 | Visão do Caapi | Rito ✓ | 4,5 / 5 | ok. |
| 17 | Fogo de Monan | Rito ✓ | 5 / 5 | ok. |
| 18 | Dança do Aruanã | Rito ✓ | 4 / 5 | **Erro de pesquisa**: dizia que o ritual Aruanã foi registrado pelo Iphan. O registro de 2012 é do saber das **ritxoko** (bonecas Karajá), não da dança. Reescrito. |
| 19 | Dádiva de Mani | Rito ✓ | 6,5 / 7 | Atribuição a Barbosa Rodrigues da variante com Jaci removida (não confirmada); acrescentada nota sobre marcas da catequese na versão de Couto de Magalhães. |
| 20 | Kuarup | Rito ✓ | 5,5–8 / 9 | Mito de origem precisado: o tabu quebrado é o de quem tinha tido relações na véspera assistir (Villas Bôas/Agostinho), não "olhar" genérico. |
| 21 | Terra sem Males | Rito ✓ | 8 / 9 | Balanço refeito com "buff em todas = unitário×3" (6) + cura 4 (2) = 8. Antes contava 3 ou 4 corpos à mão. |
| 22 | Ibirapema | Relíquia ✓ | 3 / 4 | "Passava de pai para filho" (não confirmado) substituído pela descrição documentada em Staden (*Iwera Pemme*: unção, entrega pelas mulheres, reclusão e novo nome). |
| 23 | Muiraquitã | Relíquia ✓ | 5 / 6 | ok. |
| 24 | Maracá do Pajé | Relíquia ✓ | 5 / 6 | Afirmação "flauta e chocalho são os primeiros objetos que Ñamandu cria" (não confirmada em *Ayvu Rapyta*) substituída por *mbaraka*/*takuapu* na *opy*, que é o uso documentado. |
| 25 | Cocar do Morubixaba | Relíquia ✓ | **7 / 8** (era 6) | Com aura oficial = 3, ficava em 6 = exatamente P−2. **+2 Vida → +3 Vida** no texto, JSON e Papel (Mapinguari com Cocar: 5/8 Guarda). |

Tipos: a natureza mítica bate com o tipo em todas as 25 — objetos são Relíquias, ritos/eventos são Ritos, armadilhas e feitiços reativos são Selos, seres são Entidades. Distribuição 14/6/8/4 e curva 4/6/3/1 intactas.

JSON × texto: conferidos um a um (números, alvos, gatilhos, keywords, `perm`); só o Cocar mudou (vida 2 → 3). Todos os textos ≤ 21 palavras.

## 2. Erros de pesquisa encontrados

1. **Dança do Aruanã** — "ritual registrado pelo Iphan": falso; o registro (2012) é das bonecas *ritxoko* Karajá.
2. **Mapinguari** — fonte "Oren, *Edentata* (1993)": a hipótese da preguiça-gigante saiu em *Goeldiana Zoologia* (1993); em *Edentata* só em 2001. Corrigido na carta e no `_estudo.md`.
3. **Kuarup** — tabu de Mavutsinim simplificado para "proibição de olhar"; o mito fala de quem tinha tido relações sexuais na véspera.
4. **Jaci / Dádiva de Mani** — variante "Jaci umedece a cova de Mani" atribuída a Barbosa Rodrigues sem confirmação; passou a "variantes populares".
5. **Maracá do Pajé** — "flauta e chocalho são os primeiros objetos criados por Ñamandu" não confirmado em Cadogan; substituído pelo uso documentado de *mbaraka* e *takuapu*.
6. **Ibirapema** — "passava de pai para filho" sem fonte; substituído pela cerimônia descrita por Staden.
7. **Iara** — versão da guerreira apresentada como "versões amazônicas" sem marcar que é popular/literária; marcada.

Nenhuma figura de origem ibérica ou africana rotulada como indígena (Cuca, Mula-sem-cabeça etc. já estavam fora, com justificativa no `_estudo.md`). O Saci é o caso misto e o contexto já o trata como tal. Nenhum ser de religião viva/secreta (Jurupari, Omama, xapiri, Yebá Buró) virou criatura — mantido.

## 3. Sanidade do deck

| Checagem | Resultado |
|---|---|
| Dano direto à Cornucópia (soma) | 2 (Matinta 1 ×1, Monan 1 ×1) ≤ 8 ✓ |
| `counter` | 1 cópia ≤ 3 ✓ |
| `destroy` escolhido | 0 ≤ 4 ✓ |
| Combo de 2 cartas que ganha no T3–4 | Nenhuma. O deck não alcança a Cornucópia por ataque enquanto o inimigo tiver campo; Ímpeto só via Ibirapema (1 cópia), e Terra sem Males é T4+ sem Ímpeto repetível. |
| Gatilho de cada Selo acontece na maioria das partidas? | Arapuca/Mundéu (`enemy_attacks`): sim, desde que haja corpo aliado em campo — o deck tem 14 Entidades + tokens. Matinta (`enemy_end_turn`): sempre. Sopro (`enemy_plays_rite`): todo deck tem 8 Ritos. ✓ |

## 4. Três pontos para o simulador observar

1. **Tupã Despertar 2 em área + Fogo de Monan 2 em área**: juntas são 4 de dano em todas as inimigas ao longo da partida; podem varrer decks de tokens (bruxaria/alta magia se tiverem enxames) e cada morte alimenta a Cobra-Grande (+1/+1 por inimiga morta, inclusive tokens). Medir a taxa de vitória contra decks de campo largo e o tamanho médio da Cobra no T8.
2. **Jaci `end_turn` cura 2 em todas**: incondicional e todo turno. Com Boitatá/Mapinguari/Cobra em campo, as trocas por ataque podem ficar impossíveis para o oponente sem `silence`/`bounce`/`destroy`. Se a taxa de partidas acima de 12 turnos subir com Jaci em campo, trocar para cura 1 ou condicionar (`ally_count_min 2`).
3. **Guarda × `ally_attacked` (Boitatá) e `enemy_attacks` (Arapuca/Mundéu)**: o deck depende de o oponente **atacar Entidades**. Contra decks que vão à Cornucópia por Ritos/habilidades, ou que esperam o campo indígena esvaziar, Boitatá vira um 3/4 sem texto e os Selos de armadilha ficam presos no slot. Vigiar a taxa de disparo de Arapuca/Mundéu por partida (esperado ≥ 1) e a frequência com que Boitatá dispara `ally_attacked` sozinho em campo (esperado ≈ 0, por desenho).

Ponto extra, menor: **Anhangá + tokens** gera um Veado Branco a cada morte, inclusive de Veados — cadeia infinita de 1/2 enquanto houver slot. É só 1 corpo por morte e exige que o oponente mate; registrar quantos Veados nascem por partida para saber se o valor 3 (cheio) está justo.
