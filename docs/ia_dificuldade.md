# KodeX — IA: níveis, personalidades e medição (2026-10-21)

## Níveis
- **Aprendiz (0):** heurística do Mestre com erros de propósito: não vê o letal 50% das vezes, joga uma carta qualquer
  30%, ataca um alvo qualquer 30% e encerra o turno cedo 20% (depois de já ter agido).
- **Mestre (1):** heurística gulosa (port do HeurBot de `sim/bots.py`), com poucos erros de propósito: carta qualquer 12%,
  alvo qualquer 12%, encerra cedo 5% (ERROS_MESTRE).
- **Arquimago (2):** mesmas regras de todos (a vantagem de +3 vida/+1 carta foi retirada a pedido do autor: dificuldade
  nunca muda regra). Jogadas do Mestre sem erros + plano de ataques do turno inteiro em todas as ordens (P), com peso de
  ameaça (A) e controle do campo (B), olhar a resposta do oponente nos 8 melhores planos (L), mulligan (M) e letal
  somando Ritos de dano na Cornucópia.

## Personalidades (pesos em `PESOS_IA`, mesa.gd)
agressivo (Indígena, Hinduísmo) · controle (Cristianismo, Alta Magia) · selos (Taoismo, Bruxaria) · equilibrado (demais).

## Escalada
Torneio da história: lutas 1 a 6 = Aprendiz, Mestre, Mestre, Arquimago, Arquimago, Arquimago.
Torneio de 8: quartas Aprendiz, semifinal Mestre, final Arquimago. Arcade: o jogador escolhe (10/15/25 moedas).

## Medição (partidas IA × IA no motor real, sem tela, decks sorteados, metade com cada lado começando)
| Confronto | n | Vitórias do 1º | IC 95% | z |
|---|---|---|---|---|
| Mestre × Aprendiz | 120 | 79,0% | ±7,3 | +6,33 |
| Arquimago × Aprendiz (1ª versão) | 120 | 75,0% | ±7,7 | +5,48 |
| Mestre × Mestre (controle) | 120 | 54,2% | ±8,9 | +0,91 |
| Arquimago 1ª versão × Mestre | 120 | 39,2% | ±8,7 | −2,37 |
| — só o plano de ataques | 120 | 53,3% | ±8,9 | +0,73 |
| — só o "melhor conjunto de cartas" | 120 | 40,8% | ±8,8 | −2,01 |
| **Arquimago final × Mestre** | 120 | **62,5%** | ±8,7 | +2,74 |
| Arquimago final sem a vantagem × Mestre | 120 | 53,3% | ±8,9 | +0,73 |

Conclusões: a diferença Aprendiz → Mestre é grande e real. O "melhor conjunto de cartas" (mochila na Fé) piorava a IA
(gastava cartas baratas demais) e foi retirado. O plano de ataques sozinho não muda o resultado de forma mensurável;
a força do Arquimago vem da vantagem declarada. Próximo passo para um Arquimago mais esperto: busca de 1 turno com o
motor clonado (simular o turno do oponente), não só heurística.

Como repetir: `partida.sh seed ia0 ia1 deckA deckB` com `GD_AUTO=1 GD_IA_0 GD_IA_1 GD_DECK_A GD_DECK_B GD_SEED
GD_VELOCIDADE=40 GD_SAIR_NO_FIM=1` e `--headless res://mesa.tscn`; 20 em paralelo leva ~1,5 min por 120 partidas.

## Medição final (mesmas regras, 2026-10-21)
| Confronto | n | Vitórias do 1º | IC 95% | z |
|---|---|---|---|---|
| Arquimago (M,A,B,P,L) × Mestre sem erros | 200 | 54,0% | ±6,9 | +1,13 |
| cada melhoria sozinha × Mestre sem erros | 200 cada | 46–49% | ±6,9 | não significativo |
| **Arquimago × Mestre (com erros)** | 200 | **58,5%** | ±6,8 | +2,40 |
| **Mestre (com erros) × Aprendiz** | 200 | **67,5%** | ±6,5 | +4,95 |
