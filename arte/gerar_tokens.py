"""Artes dos tokens (Entidades invocadas por efeito), mesmo setup das cartas: Krea 2 Turbo + Chaotic Shapes.
Lê godot/dados/tokens.json; candidatas em arte/tokens/_krea/<id>_a|b|c.png. Uso: python gerar_tokens.py [--n 3]"""
import argparse, json, os, sys, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pipeline_pixel as PP
from gerar_krea import seed, SUFIXOS, RAIZ

ap = argparse.ArgumentParser(); ap.add_argument("--n", type=int, default=3); a = ap.parse_args()
toks = json.load(open(os.path.join(RAIZ, "godot", "dados", "tokens.json"), encoding="utf-8"))
for nome, t in toks.items():
    for k in range(a.n):
        dest = os.path.join(RAIZ, "arte", "tokens", "_krea", f"{t['id']}_{SUFIXOS[k]}.png")
        if os.path.exists(dest):
            continue
        os.makedirs(os.path.dirname(dest), exist_ok=True)
        t0 = time.time()
        PP.krea2(t["prompt"], seed(t["id"], k), dest)
        print(f"{t['id']}_{SUFIXOS[k]} {time.time() - t0:.0f}s", flush=True)
print("fim")
