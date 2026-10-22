#!/bin/bash
# Teste automático de equilíbrio no MOTOR REAL do jogo (Godot headless, IA Mestre × IA Mestre).
# Cada par de tradições joga N partidas (metade com cada lado começando como lado 0), em paralelo.
# Reprova (código 1) se a média de algum deck sair de 40–60 % ou se algum confronto sair de 30–70 %.
# uso: sim/balanco_auto.sh [N por confronto=40] [paralelo=16]      (~4 min com 40 e 16 núcleos)
cd "$(dirname "$0")"
N=${1:-40}; P=${2:-16}
SAI=relatorios/balanco_auto_$(date +%Y%m%d_%H%M).txt
python3 - "$N" > /tmp/kdx_jobs_$$.txt <<'E'
import sys, itertools
D = ["indigena", "cristianismo", "taoismo", "hinduismo", "bruxaria", "alta_magia"]
n = int(sys.argv[1])
for i, (a, b) in enumerate(itertools.combinations(D, 2)):
    for k in range(n):
        seed = 5000 + i * 1000 + k
        print(seed, 1, 1, *((a, b) if k % 2 == 0 else (b, a)))
E
echo "$(wc -l < /tmp/kdx_jobs_$$.txt) partidas, $P em paralelo..."
xargs -P "$P" -L 1 bash ia_godot/partida.sh < /tmp/kdx_jobs_$$.txt > "$SAI"
rm -f /tmp/kdx_jobs_$$.txt
python3 - "$SAI" <<'E'
import sys, collections, math
v = collections.Counter(); n = collections.Counter(); erros = 0; turnos = []
for l in open(sys.argv[1], encoding="utf-8"):
    p = l.split()
    if len(p) < 7 or p[5] not in ("vitória", "derrota", "empate"):
        erros += 1; continue
    a, b, r = p[3], p[4], p[5]
    par = tuple(sorted((a, b))); n[par] += 1; turnos.append(int(p[6]))
    if r == "vitória": v[(par, a)] += 1
    elif r == "derrota": v[(par, b)] += 1
    else: v[(par, a)] += 0.5; v[(par, b)] += 0.5
decks = sorted({d for par in n for d in par})
falhas = []
print(f"{'confronto':34s} {'n':>4s}  vitórias do 1º")
media = collections.defaultdict(list)
for par in sorted(n):
    wr = v[(par, par[0])] / n[par]
    ic = 1.96 * math.sqrt(0.25 / n[par])
    media[par[0]].append(wr); media[par[1]].append(1 - wr)
    marca = ""
    if wr - ic > 0.70 or wr + ic < 0.30:
        marca = "  <-- FORA de 30–70 %"; falhas.append(f"{par[0]} × {par[1]}: {100*wr:.0f} %")
    print(f"{par[0] + ' × ' + par[1]:34s} {n[par]:4d}  {100*wr:5.1f} % (±{100*ic:.0f}){marca}")
print()
for d in decks:
    m = sum(media[d]) / len(media[d])
    marca = "  <-- FORA de 40–60 %" if not 0.40 <= m <= 0.60 else ""
    if marca: falhas.append(f"média {d}: {100*m:.0f} %")
    print(f"{d:14s} média {100*m:5.1f} %{marca}")
print(f"\nturnos médios {sum(turnos)/max(1,len(turnos)):.1f} · partidas com erro {erros}")
print("REPROVADO: " + "; ".join(falhas) if falhas else "APROVADO")
sys.exit(1 if falhas or erros > len(turnos) * 0.05 else 0)
E
