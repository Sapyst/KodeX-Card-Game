"""Experimentos da rodada 3 (Analista). Nada toca nas cartas nem no engine oficiais.

  python3 relatorios/r3_experimentos.py primeiro [n]   # (a) vantagem do 1º jogador: Krishna other_ally × regra "+1 Fé extra ao 2º"
  python3 relatorios/r3_experimentos.py cristao  [n]   # (b) duração do cristianismo: Pães sem cura / Cova cura 2
"""
import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import engine
from r2_metricas import rodar
import r2_variantes as V

AQUI = V.AQUI
DECKS = V.DECKS


def linha(nome, pasta, base, n, seed=11):
    out = []; s_wr = s_rod = s_pri = 0; k = 0
    for d in DECKS:
        if d == base: continue
        r = rodar(pasta, os.path.join(V.CARTAS, d), n, seed, quiet=True)
        wr = 100 * (r["taxa_a"] + r["emp"] / 2)
        out.append(f"{d[:4]} {wr:4.1f}/{r['rodadas']:4.1f}/{100*r['primeiro']:4.1f}")
        s_wr += wr; s_rod += r["rodadas"]; s_pri += 100 * r["primeiro"]; k += 1
    esp = rodar(pasta, pasta, n, seed, quiet=True)
    print(f"{nome:<40} média WR {s_wr/k:5.1f} rod {s_rod/k:4.1f} 1º {s_pri/k:4.1f} | " + "  ".join(out) + f" | espelho rod {esp['rodadas']:4.1f} 1º {100*esp['primeiro']:4.1f}")
    sys.stdout.flush()


def primeiro(n):
    print("formato por coluna: WR/rodadas/1º-vence (%)")
    raiz = os.path.join(AQUI, 'tmp_hind')
    of = os.path.join(V.CARTAS, 'hinduismo')
    linha("hind oficial", of, 'hinduismo', n)
    k1 = V.variante('hinduismo', 'r3_K1_krishna_other', [("09_krishna.md", V.krishna_other)], raiz)
    linha("hind K1 Krishna aura other_ally (10/11)", k1, 'hinduismo', n)
    # regra geral: 2º jogador ganha +2 Fé temporária no 1º turno (em vez de +1) — flag só neste processo
    orig = engine.Jogo.iniciar_turno
    def iniciar_turno_mais1(self, j):
        orig(self, j)
        if self.turno_global == 2:
            j.fe += 1
    engine.Jogo.iniciar_turno = iniciar_turno_mais1
    print("--- regra: 2º jogador +2 Fé temporária no 1º turno (motor patched só aqui) ---")
    linha("hind oficial + regra +2 Fé", of, 'hinduismo', n)
    for d in ('cristianismo', 'taoismo'):
        linha(f"{d} oficial + regra +2 Fé", os.path.join(V.CARTAS, d), d, n)
    engine.Jogo.iniciar_turno = orig


def paes_sem_cura(d):
    d["efeitos"][0]["acoes"] = [a for a in d["efeitos"][0]["acoes"] if a["op"] != "heal"]  # compre 2 = 3/5 (P-2)
def paes_cura1(d):
    for a in d["efeitos"][0]["acoes"]:
        if a["op"] == "heal": a["n"] = 1   # ... (cura 1 ≈ 0,5) = 3,5/5
def cova_cura2(d):
    d["efeitos"][0]["acoes"][0]["n"] = 2  # 1+2 = 3/4
def graal_sem_cura_corn(d):
    d["efeitos"][0]["acoes"] = [a for a in d["efeitos"][0]["acoes"] if a["op"] != "heal"]  # +0/+2, cura 2 ao atacar = 3/6 (P-3) -- só diagnóstico


def cristao(n):
    print("formato por coluna: WR/rodadas/1º-vence (%)")
    raiz = os.path.join(AQUI, 'tmp_cri'); os.makedirs(raiz, exist_ok=True)
    of = os.path.join(V.CARTAS, 'cristianismo')
    linha("cri oficial", of, 'cristianismo', n)
    for nome, edits in {
        "C1 Paes sem cura (3/5)": [("18_multiplicacao_dos_paes.md", paes_sem_cura)],
        "C2 Paes cura 1 (3,5/5)": [("18_multiplicacao_dos_paes.md", paes_cura1)],
        "C3 Cova cura 2 (3/4)": [("13_cova_dos_leoes.md", cova_cura2)],
        "C4 C1 + C3": [("18_multiplicacao_dos_paes.md", paes_sem_cura), ("13_cova_dos_leoes.md", cova_cura2)],
        "C5 diag: Graal sem cura Cornucopia": [("27_santo_graal.md", graal_sem_cura_corn)],
    }.items():
        p = V.variante('cristianismo', nome.split()[0], edits, raiz)
        linha("cri " + nome, p, 'cristianismo', n)


if __name__ == "__main__":
    n = int(sys.argv[2]) if len(sys.argv) > 2 else 800
    {"primeiro": primeiro, "cristao": cristao}[sys.argv[1]](n)
