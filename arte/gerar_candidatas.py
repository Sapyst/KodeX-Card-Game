"""Gera 2 candidatas (seeds diferentes) para cada carta SEM arte em arte/<deck>/<id>.png.
Saída: arte/<deck>/_candidatas/<id>_a.png e _b.png. Uso: python3 gerar_candidatas.py"""
import glob, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gerar_artes as GA
RAIZ = GA.RAIZ
for f in sorted(glob.glob(os.path.join(RAIZ, "cartas", "*", "[0-9][0-9]_*.md"))):
    deck = os.path.basename(os.path.dirname(f))
    if deck == "abismo":
        continue
    c, prompt, err = GA.ler_carta(f)
    if err or os.path.exists(os.path.join(RAIZ, "arte", deck, c["id"] + ".png")):
        continue
    for suf, off in (("a", 1000), ("b", 2000)):
        dest = os.path.join(RAIZ, "arte", deck, "_candidatas", f"{c['id']}_{suf}.png")
        if os.path.exists(dest):
            continue
        e = GA.gerar(prompt, GA.seed_de(c["id"], off), c["id"], dest)
        print(c["id"], suf, e or "ok", flush=True)
