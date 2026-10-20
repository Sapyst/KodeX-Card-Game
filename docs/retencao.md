# KodeX — Retenção: perfil, coleção, moedas, torneio arcade e boosters

Decisões fechadas com o autor (2026-10-20). Números são o ponto de partida; o balanço pode mudar depois de jogar.

## Perfil
- Nome do jogador + foto opcional (upload do celular), com **recorte 3:4** dentro de uma moldura bonita (arrastar e
  aproximar com pinça; a moldura limita a área). A foto fica **só no aparelho** (`user://`), nunca vai para servidor.
- **Auto-save** local de tudo: perfil, moedas, coleção, decks, progresso do torneio da história.

## Coleção inicial e decks
- O jogador começa **só com os 32 de Alta Magia** (deck padrão). As outras tradições vêm de boosters e prêmios.
- Pode montar **vários decks** (32 cartas, mesmas regras de cópias: Lendária 1, demais até 2). Uma carta só pode estar
  em quantos decks tiver cópias dela (não dá para "repetir" a mesma cópia em dois decks).

## Moedas
| Evento | Moedas |
|---|---|
| Começo do jogo | 200 (2 boosters) |
| Partida arcade avulsa vencida | 15 |
| Torneio arcade: campeão | 150 |
| Torneio arcade: vice | 70 |
| Torneio arcade: semifinal | 30 |
| Carta repetida trocada | comum 20 · lendária 60 |
| Booster (3 cartas) | custa 100 |

## Torneio arcade (sem lore)
- **8 participantes em chave eliminatória**: o jogador + 7 NPCs (personagens e decks sorteados), 3 rodadas.
- Duelos NPC × NPC resolvidos na hora pelo simulador; o placar aparece na chave. Quem sobrar no fim leva o prêmio.

## Boosters
- 3 cartas aleatórias de todas as tradições (Conjunto do Abismo e Choronzon **não** saem em booster).
- **Pelo menos 1 Entidade** garantida em cada booster.
- Lendária: **5% por carta**.
- Abertura: o pacote aparece; o dedo **corta a ponta de cima** onde passar; 3 cartas saem de dentro, viradas, e
  **viram uma a uma** revelando. Referências de design: pacotes metálicos holográficos em pixel art.
- Carta repetida: o jogador escolhe **trocar por moedas** ou **guardar** (para montar mais de um deck).

## Arte: normal × especial (foil)
- Cartas normais: **Krea 2 + LoRA Chaotic Shapes** (arte atual).
- Versão **especial/rara**: arte **S.A.R.S dark fantasy** (sem Chaotic Shapes), no frame **especial** (arco-íris), com
  **efeito foil holográfico animado** (faixa de luz varrendo, arco-íris sobre os claros, estrelinhas). Sai em boosters.
- Protótipo: `arte/foil_teste.py` (Boitatá: `arte/indigena/_sars_teste/ind_boitata_v2_0.png`).
- **Lendária especial: frame full-art aprovado** (`arte/frame/lendaria_fullart.py`, estilo de custo "A"):
  arte cobrindo a carta inteira; borda de foil escuro com arco-íris animado; degradê escuro só no topo e na base;
  custo em número grande com filete separando do nome; nome, tipo, palavras-chave, ATK e DEF em Source Serif 4
  Display (serifa grossa, licença OFL) com preenchimento foil; descrição em Source Serif 4 branca.
  Tudo centrado pelo desenho real das letras (bbox). O frame **normal** continua o mesmo.

## Coleção / Codex no jogo (feito na v0.3.0)
- Menu **Coleção**: abas por tradição, grade de cartas, página de lore (título, resumo, curiosidade) em PT/EN.
- Lore em `godot/dados/codex/<deck>.json` (173 entradas, escritas por agentes a partir das fichas + fontes na web).
- Artes provisórias aparecem marcadas **"REVISÃO"** (`godot/dados/arte_revisao.json`).

## Foil: decisões (2026-10-20)
- Chance de foil: **1 em 50 cartas** (2% por carta). Só vem foil a carta que já tem arte S.A.R.S aprovada.
- Primeiro as **12 lendárias** (geradas e revisadas por agentes); as outras entram aos poucos.
- Lendária foil: frame full-art. Comum foil: frame original com pílula arco-íris + brilho holográfico.

## Fases (um release por fase)
1. Perfil (nome + foto com recorte 3:4), auto-save, moedas (inclusive por partida arcade), montar decks, coleção possuída.
2. Loja e abertura de booster com corte (tudo bem animado).
3. Torneio arcade de 8.
