import random, sys
# uso: jobs.py nivelA nivelB n  → n partidas, metade com A no lado 0
a, b, n = sys.argv[1], sys.argv[2], int(sys.argv[3])
D = ["indigena", "cristianismo", "taoismo", "hinduismo", "bruxaria", "alta_magia"]
r = random.Random(42)
for k in range(n):
    da, db = r.choice(D), r.choice(D)
    seed = 1000 + k
    if k % 2 == 0:
        print(seed, a, b, da, db)
    else:
        print(seed, b, a, db, da)
