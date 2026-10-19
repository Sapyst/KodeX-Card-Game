# sim/ — motor de duelos Gods Kodex

Python puro (3.8+), sem dependências. Implementa `docs/regras.md` e todo o vocabulário de `docs/dsl_efeitos.md`
(incluindo `win`, `ritual_choronzon`, `defender`, `other_ally_entities`, `summon` com `keywords`/`n`).

| Arquivo | O que é |
|---|---|
| `cards.py` | lê `cartas/<cultura>/*.md` (bloco ```json + linha "Cópias no deck") → `Card`, `Deck` de 32 |
| `engine.py` | estado de jogo, turnos, combate, gatilhos, Selos, Relíquias, auras, DSL |
| `bots.py` | `HeurBot` (heurístico), `RandomBot`, `PassivoBot` (testes) |
| `duel.py` | CLI de N duelos / matriz completa, relatório em texto e JSON |
| `validar.py` | validador estático das cartas (já existia; não mexer) |
| `tests/test_engine.py` | 53 testes `unittest` das regras críticas |
| `tests/cartas_teste/` | 30 cartas sintéticas (`tst_*`) que formam um deck válido de 32 e cobrem a DSL |

## Como rodar

```bash
cd sim
python3 tests/test_engine.py                      # testes (ou: python3 -m unittest discover -s tests)
python3 validar.py tests/cartas_teste             # valida uma pasta de cartas

python3 duel.py ../cartas/indigena ../cartas/taoismo --n 2000 --seed 1 [--bot heur|random] [--json saida.json] [--log]
python3 duel.py --todos ../cartas --n 1000 [--json matriz.json]
```

- `--seed` torna tudo determinístico (`random.Random(seed*1_000_003 + i)` por duelo). Mesma seed, mesmos decks, mesmo bot → mesmo resultado.
- Os duelos alternam quem começa (duelo par: A começa; ímpar: B começa).
- `--log` imprime o log passo a passo do primeiro duelo (útil para auditar uma regra).
- `--todos` percorre as subpastas de `cartas/` que não começam com `_`; pastas que não carregam como deck de 32 válido são ignoradas com aviso em stderr.
- Desempenho: 2000 duelos espelho do deck de teste em ~1,6 s (meta era < 60 s).

## Como ler o relatório

Cabeçalho do confronto:
- **Vitórias A / B / Empates** — fração dos N duelos.
- **Duração média** em *rodadas* (uma rodada = um turno de cada jogador).
- **Vantagem de quem começa** — entre as partidas decididas, fração vencida por quem jogou primeiro. Em espelho, 50% = sem vantagem. No deck de teste dá ~53–55%, apesar do +1 Fé temporária do 2º jogador.

Tabela por carta (uma por lado, A e B — em espelho os dois lados aparecem separados):
- **jogadas** — vezes que a carta foi jogada da mão (tokens não contam; Choronzon via ritual conta).
- **WR jogada** — *win rate when played*: entre as partidas em que essa carta foi jogada ao menos uma vez por esse lado, fração vencida. Cartas "boas" ficam acima do WR do deck; cartas "caras demais" ficam abaixo. Mínimo de ~30 partidas para significar algo.
- **WR comprada** — *win rate when drawn*: entre as partidas em que a carta chegou à mão desse lado (jogada ou não), fração vencida. Não tem o viés de sobrevivência de "WR jogada" (uma Lendária de custo 7 só é jogada em partidas longas, que o deck já estava ganhando). É a métrica para julgar se uma carta **decide** a partida; a meta de espelho (carta em [deck−12, deck+12]) usa esta coluna. JSON: `win_rate_comprada`, `partidas_comprada`, `vitorias_comprada`.
- **dano méd** — dano total creditado à carta (combate da Entidade, `damage` de seus efeitos, dano dos tokens que ela invocou, dano da Relíquia/Selo) dividido por vezes jogada.
- **na mão** — "ficou na mão": entre as cópias que entraram na mão, fração que ainda estava na mão no fim da partida (nunca foi jogada). Alto = custo/condição ruins.

JSON (`--json`): mesmo conteúdo em `cartas[]` (`win_rate_jogada`, `dano_medio`, `taxa_ficou_na_mao`, contadores brutos), mais `taxa_a/b/empate`, `rodadas_media`, `primeiro_vence`, `meta`. No modo `--todos`: `matriz[A][B]` (linha vence coluna, empate = 0,5), `media_por_deck`, `confrontos[]` (um relatório completo por par) e `cartas[]` agregadas globalmente.

## Bots

`HeurBot` por turno: (1) se o campo inimigo está vazio e a soma de ATK pronta mata, ataca; (2) joga a carta de maior pontuação — Entidades pela curva (prefere a mais cara que cabe), Ritos só se a utilidade estimada no estado atual ≥ 1,5 (não cura sem ferido, não dá dano sem alvo, respeita `cond`), Relíquias na melhor portadora (que ainda ataca neste turno), Selo se há slot; (3) ataques: mata-e-sobrevive > mata-e-morre com troca ≥ 0 em valor > dano grátis; nunca morre sem matar. Alvos: `damage` em quem morre com o dano (senão maior ATK); `destroy`/`bounce`/`freeze`/`silence` no maior valor; `buff` em quem ainda vai atacar; `heal` no mais ferido; busca a carta mais cara jogável no próximo turno. Mulligan devolve até 2 cartas de custo ≥ 4.

`RandomBot` escolhe uniformemente entre as ações legais mais "passar". Com ele, o espelho também dá ~50% e as partidas são ~60% mais longas.

Cada ponto de decisão do motor é um método do bot: `mulligan`, `escolher_acao`, `escolher_alvo`, `escolher_busca`, `escolher_sacrificio`, `escolher_descarte`. Para um bot novo, herde `BotBase`.

## Decisões de regra (onde o texto é ambíguo)

Estrutura e recursos
1. **Rodada/turno.** `rodada` conta pares de turnos; o limite de empate é **40 rodadas** (80 turnos individuais). Na prática a fadiga decide antes. "Duração média" é em rodadas.
2. **Mão cheia ao comprar** manda a carta comprada direto ao cemitério. Renascer, `bounce`, `revive para hand` e `search` podem passar de 7; o excesso é descartado no fim do turno (bot escolhe; HeurBot descarta a mais cara).
3. **Fé temporária** soma à Fé atual sem alterar o máximo; `gain_fe perm` sobe o máximo (teto 8) e a Fé atual.
4. **Sacrifício** conta como morte: dispara `on_death`, `ally_dies`, `enemy_dies`, mas **não** aciona Renascer (a carta vai ao cemitério). O slot liberado conta para invocar (campo cheio + Sacrifício 1 → pode).
5. **Mulligan**: compra as substitutas antes de devolver as trocadas ao deck (não re-compra a mesma carta).

Combate
6. **Guarda** só restringe ataques; Furtivo **não** impede ser atacado (só protege de alvo escolhido/aleatório de Ritos, Selos e habilidades inimigas). `all_*` **não** é "alvo": atinge Furtivos.
7. Dano de combate é simultâneo: os dois `dano` são aplicados antes de qualquer `on_damaged`/`ally_damaged`.
8. Se o **atacante** sai do campo durante os gatilhos de ataque (Selo matou, por exemplo), o ataque é cancelado. Se o **defensor** some, o ataque também é cancelado (não redireciona para a Cornucópia).
9. `ally_attacked` **não** dispara em ataque à Cornucópia (só "outra Entidade aliada" atacada; o próprio defensor não recebe `ally_attacked`).
10. `enemy_attacks` dispara **só** em ataque a Entidade; ataque à Cornucópia dispara apenas `enemy_attacks_cornucopia`.
11. Entidade com ATK 0 pode declarar ataque (dispara `on_attack`); o HeurBot não o faz se ela não tem efeitos.

Selos
12. Vários Selos com o mesmo gatilho disparam **todos**, do mais antigo ao mais novo; cada um resolve e vai ao cemitério. `counter` anula a carta gatilho para os Selos seguintes também.
13. Selo com `cond` falsa **não dispara e fica em campo**.
14. Ordem na jogada: paga-se o custo, a carta sai da mão, **os Selos do oponente resolvem antes do efeito da carta**. Entidade: entra em campo → Selos (`triggering` = a Entidade, pode receber `damage`) → se anulada vai ao cemitério **sem Despertar** → senão Despertar. Rito: Selos → se não anulado, efeito (alvos escolhidos na resolução) → cemitério. Relíquia: equipa → Selos → se anulada, cemitério sem `on_equip`.
15. Selo de `ally_dies`/`ally_damaged` só dispara se a morte/dano acontecer **no turno do oponente** (regra 7 das regras), inclusive quando a causa é um efeito do próprio dono.
16. Não há gatilho para "oponente põe Selo"; pôr Selo não dispara nada.

`triggering` por gatilho
17. `on_play`/`on_death`/`start_turn`/`end_turn`/`static`: a própria Entidade. `on_attack` e `equipped_attacks`: **o alvo do ataque** (Entidade ou Cornucópia — `damage triggering` funciona nos dois); `defender` nesses gatilhos é a Entidade inimiga atacada (vazio em ataque à Cornucópia). `on_damaged`: a Entidade que causou o dano (None se foi Rito/Selo). `ally_attacked`: a aliada atacada (igual a `defender`). `ally_dies`/`enemy_dies`: a Entidade que morreu (já fora do campo — `damage`/`buff` nela são no-op; `revive` precisa de alvo de cemitério). `enemy_plays_entity`: a Entidade recém-entrada. `enemy_plays_rite`/`enemy_plays_reliquia`: a carta/Relíquia (serve a `target_cost_max`; `destroy triggering` numa Relíquia a remove). `enemy_attacks*`: o atacante. `ally_damaged`: a aliada ferida. `equipped_dies`: a portadora. `enemy_end_turn`: nenhum.
18. Alvo inexistente no momento (`attacker` quando o dano veio de Rito, `defender` em ataque à Cornucópia, `self` já fora do campo) → **pula só essa ação**; as demais ações do efeito resolvem.
18b. Em `on_death`/`equipped_dies`/`ally_dies`/`enemy_dies` a carta da Entidade morta **já está no cemitério** (ou na mão, se Renascer) quando o efeito resolve — `revive` pode trazê-la de volta.

Relíquias
19. Relíquia morre com a portadora (`equipped_dies` dispara antes de ir ao cemitério) e também vai ao cemitério se a portadora for devolvida à mão; `silence` na portadora **não** afeta a Relíquia.
20. **Usos**: cada disparo de `equipped_attacks` gasta 1 uso (mesmo com `cond` falsa); ao gastar o último a Relíquia vai ao cemitério. **Buffs de `on_equip` somem quando a Relíquia sai** (morte da portadora, Usos esgotados, `destroy`), podendo matar a portadora se a Vida cair a 0.
21. Relíquia `static` é uma aura cuja fonte é a portadora: some com ela.

Auras e stats
22. Vida é `vida_max − dano` (modelo Hearthstone): quando uma aura/buff temporário de Vida some, a Entidade pode morrer. `heal` reduz `dano`. `all_ally_entities` em aura **inclui a fonte**; `other_ally_entities` a exclui.
23. `set_stats` e `copy_stats` zeram buffs e dano e definem a base (copia ATK/Vida **atuais** do alvo, Vida mínima 1). Buffs temporários expiram no fim do turno em que foram dados, independentemente de quem controla.
24. `silence` limpa keywords e efeitos (inclusive aura própria e Último Sopro); mantém buffs permanentes e Relíquia. Furtivo some com o silêncio.
25. `freeze`: a Entidade não ataca no **próximo** turno do controlador dela (se congelada no turno dela depois de atacar, só perde o turno seguinte).
26. `swap_control`: a Entidade roubada entra **cansada** (não ataca sem Ímpeto). `perm` ausente = permanente. Roubo temporário volta no fim do turno; se o campo original estiver cheio, ela morre. Cemitério é sempre o do **dono** original. Sem slot livre, o roubo não acontece.

Outros
27. Tokens não vão ao cemitério nem à mão; `bounce` em token o remove. Dano de tokens é creditado à carta que os invocou.
28. `revive para field` **não** dispara Despertar (só a invocação da mão dispara; decisão de balanceamento da rodada 1) nem `enemy_plays_entity`. `revive` para mão não conta como "comprada" para fadiga, mas conta para "ficou na mão".
29. Rito com `cond` falsa é jogado (paga, vai ao cemitério) sem efeito; o HeurBot não o joga nesse caso.
30. **Choronzon**: `ritual_choronzon` exige Triângulo (`aby_triangulo`) equipado numa aliada, Círculo (`aby_circulo`) entre os Selos (face para baixo) e Choronzon (`aby_choronzon`) na mão; invoca ignorando custo e slots, sem disparar `enemy_plays_entity`, e o `on_play: win` encerra o jogo. Senão `draw 1`. Choronzon (custo 99) nunca é jogável pagando Fé. Os ids são constantes em `engine.CHORONZON`.
31. Mortes simultâneas resolvem na ordem: Entidades do jogador ativo, depois as do oponente; dentro de cada lado, na ordem de campo. Vitória/derrota é checada após cada ação e no início/fim do turno; as duas Cornucópias a zero ao mesmo tempo = empate.
32. `enemy_entity_random`/`ally_entity_random` usam o `Random` da partida (determinístico pela seed).

## Resultado de referência (deck sintético contra ele mesmo, HeurBot)

```
python3 duel.py tests/cartas_teste tests/cartas_teste --n 500 --seed 1
Vitórias A: 48.6%  Vitórias B: 51.4%  Empates: 0.0%
Duração média: 10.6 rodadas   Vantagem de quem começa: 54.6%
```
Com `--n 2000 --seed 7`: 48.6 / 51.4, 10.7 rodadas, 1º jogador 54.6%, 1,9 s.
Sinais do próprio deck de teste: a Lendária (Rei dos Céus, 7 Fé, 6/7 Ímpeto + destroy) tem WR 73% quando jogada e a Relíquia `Coroa de Ferro` (aura +0/+1) 44% — o relatório identifica os extremos como esperado.
