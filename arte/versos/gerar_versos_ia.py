"""Versos de carta gerados por IA local (Krea 2 Turbo, sem LoRA, via ComfyUI em localhost:8188), 2 sementes por tema
em arte/versos/_ia/<tema>_<k>.png (768×1024). Depois cada um é recortado na proporção do verso (64:90), reduzido para
pixel art 128×180 (LANCZOS → 40 cores sem pontilhado) e ganha a moldura dourada dos versos (gerar_versos.moldura).
Saídas: arte/versos/ia_<tema>_<k>.png e a folha arte/versos/_previa_ia.png.
Uso: /mnt/d/Comfy-Desktop/venv/bin/python arte/versos/gerar_versos_ia.py [--so-pos]"""
import os, sys
import numpy as np
from PIL import Image, ImageDraw

AQUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.dirname(AQUI))
sys.path.insert(0, AQUI)
import gerar_versos as GV

BASE = ("Ornate trading card back design, perfectly symmetrical, centered emblem, flat front view, intricate decorative "
        "pattern filling the whole card, rich detail, no text, no letters, no numbers. ")
TEMAS = {
    "arvore": BASE + "A golden Tree of Life at the center, its branches and roots curling into a perfect circle, tiny glowing "
              "leaves, deep emerald green background with fine gold filigree vines.",
    "ouroboros": BASE + "A golden ouroboros serpent eating its own tail forming a perfect ring at the center, scales engraved, "
                 "alchemical sun and moon symbols inside the ring, black background with gold geometric lines. Legendary, "
                 "luxurious, glowing gold.",
    "vitral": BASE + "A gothic stained glass rose window, radial symmetry, deep cobalt blue, ruby red and amber glass pieces "
              "separated by dark lead lines, light shining through.",
    "dragao": BASE + "A coiled jade green Chinese dragon around a glowing white pearl at the center, symmetrical golden "
              "auspicious clouds, deep red lacquer background.",
    "lotus": BASE + "A radiant lotus flower of white and gold light blooming at the center of a cosmic nebula, mandala rings of "
             "light, deep purple and violet space with stars. Legendary, divine, glowing.",
}
SEMENTES = [101, 202]


def gerar():
    import pipeline_pixel as PP
    os.makedirs(os.path.join(AQUI, "_ia"), exist_ok=True)
    for tema, prompt in TEMAS.items():
        for k, s in enumerate(SEMENTES):
            dest = os.path.join(AQUI, "_ia", f"{tema}_{k}.png")
            if os.path.exists(dest):
                continue
            PP.krea2(prompt, s, dest, lora=None)
            print("ok", tema, k, flush=True)


def pixelizar(src: str) -> Image.Image:
    im = Image.open(src).convert("RGB")
    w, h = im.size
    alvo_w = int(h * GV.W / GV.H)
    x0 = (w - alvo_w) // 2
    im = im.crop((x0, 0, x0 + alvo_w, h))
    p = im.resize((GV.W * 2, GV.H * 2), Image.LANCZOS).resize((GV.W, GV.H), Image.LANCZOS)
    p = p.quantize(colors=40, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE).convert("RGB")
    arr = np.asarray(p).copy()
    GV.moldura(arr, tuple(int(v * 0.6) for v in arr[6:12, 6:12].reshape(-1, 3).mean(0)))
    return Image.fromarray(arr)


def pos():
    feitos = []
    for tema in TEMAS:
        for k in range(len(SEMENTES)):
            src = os.path.join(AQUI, "_ia", f"{tema}_{k}.png")
            if os.path.exists(src):
                im = pixelizar(src)
                im.save(os.path.join(AQUI, f"ia_{tema}_{k}.png"))
                feitos.append((f"{tema}_{k}", im))
    esc = 2
    cols = 5
    linhas = (len(feitos) + cols - 1) // cols
    folha = Image.new("RGB", (cols * (GV.W * esc + 20) + 20, linhas * (GV.H * esc + 40) + 20), (13, 11, 18))
    d = ImageDraw.Draw(folha)
    for i, (nome, im) in enumerate(feitos):
        x0 = 20 + (i % cols) * (GV.W * esc + 20)
        y0 = 20 + (i // cols) * (GV.H * esc + 40)
        folha.paste(im.resize((GV.W * esc, GV.H * esc), Image.NEAREST), (x0, y0))
        d.text((x0, y0 + GV.H * esc + 6), nome, fill=(226, 184, 90))
    folha.save(os.path.join(AQUI, "_previa_ia.png"))
    print("pos ok", len(feitos))


if __name__ == "__main__":
    if "--so-pos" not in sys.argv:
        gerar()
    pos()
