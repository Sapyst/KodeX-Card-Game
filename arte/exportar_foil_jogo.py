"""Exporta as lendárias foil para o jogo: quadro parado do frame full-art (PT e EN) → godot/assets/carta_foil/<id>.webp e
carta_foil_en/<id>.webp (300×420). O brilho foil animado é desenhado pelo jogo por cima."""
import json, os, subprocess
from PIL import Image
AQUI = os.path.dirname(os.path.abspath(__file__)); RAIZ = os.path.dirname(AQUI)
dados = json.load(open(os.path.join(AQUI, "foil_lendarias.json"), encoding="utf-8"))
for idioma, pasta in (("pt", "carta_foil"), ("en", "carta_foil_en"), ("es", "carta_foil_es")):
    out = os.path.join(RAIZ, "godot", "assets", pasta); os.makedirs(out, exist_ok=True)
    for cid, d in dados.items():
        env = dict(os.environ, CUSTO_ESTILO="A", QUADROS="1", IDIOMA=idioma)
        subprocess.run(["/mnt/d/Comfy-Desktop/venv/bin/python", os.path.join(AQUI, "frame", "lendaria_fullart.py"),
                        os.path.join(AQUI, "foil", cid + ".png"), cid, d["deck"]], env=env, check=True, capture_output=True)
        q = os.path.join(AQUI, "_foil_teste", "lend_" + cid + ("" if idioma == "pt" else "_" + idioma), "q_000.png")
        Image.open(q).convert("RGBA").resize((300, 420), Image.LANCZOS).save(os.path.join(out, cid + ".webp"), "WEBP", quality=88)
        print(idioma, cid, flush=True)
