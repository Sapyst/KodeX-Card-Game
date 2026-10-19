# Gods Kodex — Regras base (v0.1)

Jogo de cartas 1×1, mobile (Godot, retrato). Partidas de 5–10 min.
Estas regras são o **contrato** que todas as cartas seguem. Mudanças aqui exigem revisar as cartas.

## 1. Preparação

| Item | Valor |
|---|---|
| Deck | exatamente **32 cartas** |
| Cópias | máx. **2** por carta; **Lendárias** máx. **1** |
| Mão inicial | **4** cartas (mulligan: pode trocar até 2 uma vez) |
| Cornucópia (vida) | **15** por jogador |
| Mão máxima | 7 (excedente descartado ao comprar) |
| Primeiro jogador | sorteio; **não compra** no turno 1 |
| Segundo jogador | compra normalmente e ganha **+1 Fé temporária** no seu primeiro turno |

## 2. Fé (recurso)

- Fé máxima começa em **0** e sobe **+1 no início de cada turno seu**, até **8**.
- A Fé restaura totalmente no início do seu turno. Fé não gasta se perde.
- Fé temporária (de efeitos) dura só o turno em que foi ganha.
- Toda carta tem **Custo** em Fé; pagar o custo é obrigatório para jogá-la.
- Algumas Entidades grandes têm **Sacrifício N**: além do custo, sacrifique N Entidades aliadas. Sacrificar **conta como morte** (dispara Último Sopro e `ally_dies`), mas **não** aciona Renascer.

## 3. Campo

Cada jogador tem:
- **4 slots de Entidade** (campo cheio → não pode invocar).
- **2 slots de Selo** (cartas viradas para baixo).
- Relíquias **equipam** uma Entidade aliada (máx. 1 por Entidade) e não ocupam slot.
- **Cemitério** (descarte, público) e **Deck** (face para baixo).

## 4. Tipos de carta (distribuição fixa por deck)

| Tipo | Qtd. no deck | O que é |
|---|---|---|
| **Entidade** | **14** | deuses, espíritos, heróis, criaturas. Custo, ATK, Vida, habilidade. |
| **Selo** | **6** | carta virada para baixo, dispara com gatilho no turno do oponente (armadilha). |
| **Rito** | **8** | efeito imediato (magia / utilidade): buscar, reviver, curar, dano, presentear… |
| **Relíquia** | **4** | item mítico equipado numa Entidade. Dá ATK/Vida/efeito; morre com ela ou tem **Usos**. |

Curva de custo das 14 Entidades: custo 1–2 → **4** cartas · 3–4 → **6** · 5–6 → **3** · 7–8 → **1** (a Lendária).
Cada deck tem **1 ou 2 Lendárias** (figuras maiores do panteão), custo 6–8, 1 cópia.
Os 32 slots já contam as cópias duplicadas: ~20–24 cartas distintas por deck.

## 5. Turno

1. **Início**: Fé máx +1 e restaura; compra 1 carta; efeitos "início do turno".
2. **Ação** (qualquer ordem, quantas vezes a Fé permitir):
   - Invocar Entidades (entram **cansadas**: não atacam neste turno, salvo **Ímpeto**).
   - Jogar Ritos (efeito, depois cemitério).
   - Equipar Relíquias.
   - Colocar **1 Selo por turno** virado para baixo (paga o custo ao colocar).
   - Atacar com cada Entidade pronta, **1 ataque por Entidade por turno**.
3. **Fim**: efeitos "fim do turno"; mão > 7 descarta.

## 6. Combate

- Uma Entidade ataca **uma Entidade inimiga** à escolha. Se houver inimigo com **Guarda**, deve atacá-lo.
- Dano é **simultâneo**: cada uma perde Vida igual ao ATK da outra. Vida persiste entre turnos (não cura sozinha). Vida ≤ 0 → vai ao cemitério.
- **Dano direto à Cornucópia por ataque só é permitido se o oponente não tiver nenhuma Entidade em campo.**
- Ritos/habilidades que dizem "dano à Cornucópia inimiga" ignoram essa regra, mas são raros e caros (máx. 3 de dano por carta).
- Dano à Cornucópia não é curado por efeitos de cura em Entidades, salvo quando a carta diz "Cornucópia".

## 7. Selos (cartas viradas para baixo)

- Colocados face para baixo, custo pago na hora. O oponente vê que há um Selo, não qual.
- Cada Selo tem **um gatilho** (ex.: "quando uma Entidade inimiga atacar"). Dispara automaticamente na primeira vez que o gatilho ocorre **no turno do oponente**, resolve, vai ao cemitério.
- Um Selo não dispara no turno em que foi colocado.
- Se o gatilho nunca acontece, fica lá. Máx. 2 em campo.

## 8. Palavras-chave

| Palavra | Efeito |
|---|---|
| **Ímpeto** | pode atacar no turno em que entra. |
| **Guarda** | Entidades inimigas devem atacar esta antes das outras. |
| **Renascer** | quando morre, volta para a **mão** do dono (uma vez; perde Renascer). |
| **Furtivo** | não pode ser alvo de Ritos, Selos ou habilidades inimigas até atacar. |
| **Despertar** | efeito ao ser invocado **da mão**. Reviver para o campo não dispara Despertar. |
| **Último Sopro** | efeito ao morrer. |
| **Sacrifício N** | custo extra: sacrificar N Entidades aliadas para invocar. |
| **Usos N** | (Relíquia) tem N cargas; some ao gastar a última. |
| **Lendária** | 1 cópia por deck. |

## 9. Fim de jogo

- Cornucópia **0** → derrota.
- Comprar com deck vazio → **2 de dano** à Cornucópia por carta não comprada.
- **Choronzon** entrando em campo → vitória imediata de quem o invocou (ver `choronzon.md`).

## 10. Fórmula de custo (orçamento de pontos)

Usada para nascer toda carta já "no esquadro"; o simulador afina depois.

**Orçamento** de uma carta de custo C: **P = 2·C + 1** pontos.
- Entidade: ATK + Vida + valor das habilidades = P. (ex.: custo 3 → 7 pts → 3/4 sem habilidade, ou 2/3 + habilidade de 2 pts.)
- Rito / Selo / Relíquia: valor dos efeitos = P. Selos valem **+1 pt grátis** (são condicionais); Relíquias valem +1 pt grátis (dependem de Entidade viva).

**Tabela de valores** (pts):

| Efeito | Valor |
|---|---|
| 1 de dano a Entidade (alvo escolhido) | 1 |
| 1 de dano a todas as Entidades inimigas | 1,5 por ponto |
| 1 de dano direto à Cornucópia | 2 |
| Curar 2 de Vida (Entidade) ou 2 de Cornucópia | 1 |
| Comprar 1 carta | 1,5 |
| Buscar carta específica/tipo do deck | 2 |
| Reviver Entidade do cemitério para a mão | 2; para o campo: 3 + custo dela ÷ 2 |
| Destruir Entidade inimiga (escolhida) | 5 (custo mín. da carta 3); com `target_cost_max` ≤ 3: 3,5 |
| Devolver Entidade inimiga à mão | 2 |
| +1 ATK permanente / +1 Vida permanente | 1 / 1 |
| +1 Fé temporária | 1,5 |
| Oponente descarta 1 carta aleatória | 2 |
| Anular um Rito inimigo (Selo) | 3 |
| Invocar token (ATK a / Vida v) | a + v |
| Freeze (não ataca no próximo turno) | 1,5 |
| Silence | 2 |
| Aura `static` +1 ATK (ou +1 Vida) em todas as aliadas | 3 |
| Relíquia com Usos N: efeito repetível | valor do efeito × N × 0,7 |
| Cura/buff "em todas as aliadas" | valor unitário × 3 (caso típico de 3 corpos) |
| Gatilho repetível condicional (`on_damaged`, `ally_attacked`, `ally_dies`, `enemy_dies`) | valor cheio do efeito, sem ×0,7 |
| Ímpeto / Guarda / Furtivo | 1 / 1 / 1 |
| Renascer | 2 |
| Sacrifício N | **−2·N** (desconto) |
| Efeito condicional (só se X) | ×0,7 |
| Efeito aleatório (alvo aleatório) | ×0,8 |

Lendárias podem passar do orçamento em **até 2 pts** (são o momento "uau" do deck); nada mais passa.

## 11. Decks

Seis decks de 32, um por tradição: **indígena brasileira**, **cristianismo**, **taoismo**, **hinduísmo**, **bruxaria**, **alta magia**.
Deck misto é permitido (qualquer 32 cartas respeitando cópias); a identidade mecânica de cada panteão é descrita em `cartas/<cultura>/_deck.md`.
O **Conjunto do Abismo** (Choronzon + 3 peças) é um módulo de 4 cartas que substitui 4 cartas de qualquer deck — fora do balanceamento.
