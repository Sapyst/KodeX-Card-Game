"""Artes da versão FOIL (rara) com S.A.R.S dark fantasy, sem Chaotic Shapes, a partir do prompt Krea da ficha.
Candidatas em arte/<deck>/_sars_foil/<id>_a|b|c.png. Uso: python gerar_sars_foil.py --ids a,b,c [--n 3]"""
import argparse, glob, json, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pipeline_pixel as PP
from gerar_krea import ler, seed, SUFIXOS, RAIZ, DECKS

BASE = ("dark fantasy, mythological, legendary, epic, ancient, highly detailed, painterly, dramatic lighting, volumetric light, "
        "mist, glowing magical light, intricate details, fully clothed, single subject, full body, ")
PP.ANIME_NEG = PP.ANIME_NEG.replace("huge eyes, ", "") + ", nudity, cleavage, revealing clothes"

ap = argparse.ArgumentParser(); ap.add_argument("--ids", required=True); ap.add_argument("--n", type=int, default=3)
a = ap.parse_args()
alvo = set(a.ids.split(","))
for deck in DECKS:
    for f in sorted(glob.glob(os.path.join(RAIZ, "cartas", deck, "[0-9][0-9]_*.md"))):
        c, prompt = ler(f)
        if c["id"] not in alvo or not prompt:
            continue
        for k in range(a.n):
            dest = os.path.join(RAIZ, "arte", deck, "_sars_foil", f"{c['id']}_{SUFIXOS[k]}.png")
            if os.path.exists(dest):
                continue
            os.makedirs(os.path.dirname(dest), exist_ok=True)
            PP.sars(BASE + prompt, seed(c["id"] + "#sars", k), dest)
            print(c["id"], SUFIXOS[k], flush=True)
print("fim")
