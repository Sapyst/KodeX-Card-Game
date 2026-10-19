"""Recorta os retratos com BiRefNet (ComfyUI) → PNG transparente. Uso: python recortar_personagens.py <pasta_entrada> <pasta_saida>"""
import io, json, os, sys, time, urllib.parse, urllib.request, uuid
import numpy as np
from PIL import Image, ImageFilter
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pipeline_pixel as PP

def mascara(src):
    nome = PP._upload(Image.open(src).convert("RGB"), "gk_rb_in.png")
    wf = {"1": {"class_type": "LoadImage", "inputs": {"image": nome}},
          "2": {"class_type": "LoadBackgroundRemovalModel", "inputs": {"bg_removal_name": "birefnet.safetensors"}},
          "3": {"class_type": "RemoveBackground", "inputs": {"bg_removal_model": ["2", 0], "image": ["1", 0]}},
          "4": {"class_type": "MaskToImage", "inputs": {"mask": ["3", 0]}},
          "5": {"class_type": "SaveImage", "inputs": {"filename_prefix": "gk_rb_mask", "images": ["4", 0]}}}
    tmp = src + ".mask.png"
    PP._rodar(wf, tmp)
    m = Image.open(tmp).convert("L"); os.remove(tmp)
    return m

ent, sai = sys.argv[1], sys.argv[2]
os.makedirs(sai, exist_ok=True)
for f in sorted(os.listdir(ent)):
    if not f.endswith(".png") or f == "folha.png":
        continue
    im = Image.open(os.path.join(ent, f)).convert("RGB")
    m = mascara(os.path.join(ent, f)).resize(im.size, Image.LANCZOS)
    a = np.asarray(m).astype(np.float32) / 255
    a = np.clip((a - 0.08) / 0.84, 0, 1)                              # endurece a borda sem serrilhar
    rgba = np.dstack([np.asarray(im), (a * 255).astype(np.uint8)])
    out = Image.fromarray(rgba, "RGBA")
    bb = out.getbbox()
    out.crop(bb).save(os.path.join(sai, f))
    print("ok", f, bb, flush=True)
