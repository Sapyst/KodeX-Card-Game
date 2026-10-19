"""Gera as imagens que o jogo usa, em tamanho de celular:
  godot/assets/arte/<id>.png   48×64 (janela 3:4 da carta na mesa, px nativos 360×640)
  godot/assets/carta/<id>.webp 300×420 (carta inteira no zoom, frame do mapa; vem de cartas_finais/<versao>)
  godot/assets/retrato/<deck>.png  retratos dos personagens do torneio (se existirem em arte/personagens/)
Uso: /mnt/d/Comfy-Desktop/venv/bin/python godot/preparar_assets.py [--versao v1]"""
import argparse, glob, os
from PIL import Image, ImageEnhance, ImageFilter

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ap = argparse.ArgumentParser(); ap.add_argument("--versao", default="v1"); a = ap.parse_args()
out_arte = os.path.join(RAIZ, "godot", "assets", "arte"); out_carta = os.path.join(RAIZ, "godot", "assets", "carta")
out_ret = os.path.join(RAIZ, "godot", "assets", "retrato")
for d in (out_arte, out_carta, out_ret):
    os.makedirs(d, exist_ok=True)
n1 = n2 = n3 = 0
for f in glob.glob(os.path.join(RAIZ, "arte", "*", "*.png")):
    deck = os.path.basename(os.path.dirname(f))
    if deck.startswith("_") or deck == "frame" or os.path.basename(f).startswith("_"):
        continue
    im = Image.open(f).convert("RGB")
    p = im.resize((96, 128), Image.LANCZOS).resize((48, 64), Image.LANCZOS)
    p = ImageEnhance.Contrast(ImageEnhance.Color(p).enhance(1.15)).enhance(1.08).filter(ImageFilter.UnsharpMask(1, 60, 1))
    p.save(os.path.join(out_arte, os.path.basename(f))); n1 += 1
for f in glob.glob(os.path.join(RAIZ, "cartas_finais", a.versao, "*", "*.png")):
    Image.open(f).convert("RGB").resize((300, 420), Image.LANCZOS).save(
        os.path.join(out_carta, os.path.basename(f)[:-4] + ".webp"), "WEBP", quality=84, method=6); n2 += 1
for f in glob.glob(os.path.join(RAIZ, "arte", "personagens", "*.png")):
    r = Image.open(f).convert("RGBA")                     # recortado (fundo transparente): mantém a proporção, 400 px de altura
    r = r.resize((round(r.width * 400 / r.height), 400), Image.LANCZOS)
    r.save(os.path.join(out_ret, os.path.basename(f))); n3 += 1
print(f"arte={n1} carta={n2} retrato={n3}")
