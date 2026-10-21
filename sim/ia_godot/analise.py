import sys, math, collections
nomes = {"0": "Aprendiz", "1": "Mestre", "2": "Arquimago"}
res = collections.defaultdict(lambda: [0, 0, 0, 0])   # par (A,B) A>=B: vitórias A, vitórias B, empates, turnos
lado0 = collections.Counter(); tot = 0
for linha in open(sys.argv[1], encoding="utf-8"):
    p = linha.split()
    if len(p) < 7: continue
    seed, a0, a1, da, db, r, tur = p[:7]
    if r not in ("vitória", "derrota", "empate"): continue
    hi, lo = max(a0, a1), min(a0, a1)
    k = (hi, lo)
    if r == "empate": res[k][2] += 1
    else:
        venc = a0 if r == "vitória" else a1
        if hi == lo:
            res[k][0 if r == "vitória" else 1] += 1     # mesmo nível: conta lado 0 × lado 1
        else:
            res[k][0 if venc == hi else 1] += 1
    res[k][3] += int(tur)
    if r == "vitória": lado0["v"] += 1
    tot += 1
for k in sorted(res):
    a, b, e, t = res[k]; n = a + b + e
    p = a / max(1, a + b)
    se = math.sqrt(p * (1 - p) / max(1, a + b))
    z = (p - 0.5) / math.sqrt(0.25 / max(1, a + b))
    rot = f"{nomes[k[0]]} × {nomes[k[1]]}" if k[0] != k[1] else f"{nomes[k[0]]} × {nomes[k[1]]} (lado 0 × lado 1)"
    print(f"{rot:38s} n={n:3d}  {a:3d}-{b:3d}-{e}  vitória {100*p:5.1f}% ± {196*se:4.1f} (IC95)  z={z:+.2f}  turnos médios {t/max(1,n):.1f}")
print("total", tot, "vitórias do lado 0:", lado0["v"])
