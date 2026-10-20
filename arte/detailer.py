"""Detailer: recorta uma região da arte, amplia para 1024, redesenha com S.A.R.S (img2img) e cola de volta com borda
suave. Uso: python detailer.py <arte.png> <saida.png> x0,y0,x1,y1 "<tags>" [denoise] [seed]"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pipeline_pixel as PP
from PIL import Image, ImageDraw, ImageFilter
src, dst, caixa, tags = sys.argv[1], sys.argv[2], [int(v) for v in sys.argv[3].split(",")], sys.argv[4]
den = float(sys.argv[5]) if len(sys.argv) > 5 else 0.5
seed = int(sys.argv[6]) if len(sys.argv) > 6 else 4242
im = Image.open(src).convert("RGB")
x0, y0, x1, y1 = caixa
reg = im.crop(caixa)
w, h = reg.size
k = 1024 / max(w, h)
gw, gh = (round(w * k / 8) * 8, round(h * k / 8) * 8)
nome = PP._upload(reg.resize((gw, gh), Image.LANCZOS), "detailer.png")
neg = PP.ANIME_NEG.replace("huge eyes, ", "") + ", blurry, lowres, deformed hand, extra fingers, fused fingers, nude, nipples"
wf = {"1": {"class_type": "CheckpointLoaderSimple", "inputs": {"ckpt_name": "S.A.R.S.safetensors"}},
      "2": {"class_type": "CLIPSetLastLayer", "inputs": {"stop_at_clip_layer": -2, "clip": ["1", 1]}},
      "3": {"class_type": "CLIPTextEncode", "inputs": {"text": PP.ANIME_POS + tags, "clip": ["2", 0]}},
      "4": {"class_type": "CLIPTextEncode", "inputs": {"text": neg, "clip": ["2", 0]}},
      "9": {"class_type": "LoadImage", "inputs": {"image": nome}},
      "10": {"class_type": "VAEEncode", "inputs": {"pixels": ["9", 0], "vae": ["1", 2]}},
      "6": {"class_type": "KSampler", "inputs": {"seed": seed, "steps": 30, "cfg": 5.5, "sampler_name": "euler_ancestral", "scheduler": "normal",
            "denoise": den, "model": ["1", 0], "positive": ["3", 0], "negative": ["4", 0], "latent_image": ["10", 0]}},
      "7": {"class_type": "VAEDecode", "inputs": {"samples": ["6", 0], "vae": ["1", 2]}},
      "8": {"class_type": "SaveImage", "inputs": {"filename_prefix": "gk_detailer", "images": ["7", 0]}}}
tmp = dst + ".reg.png"
PP._rodar(wf, tmp)
novo = Image.open(tmp).convert("RGB").resize((w, h), Image.LANCZOS)
mask = Image.new("L", (w, h), 0)
m = int(min(w, h) * 0.12)
ImageDraw.Draw(mask).rounded_rectangle((m, m, w - m, h - m), m, fill=255)
mask = mask.filter(ImageFilter.GaussianBlur(m * 0.6))
im.paste(novo, (x0, y0), mask)
im.save(dst)
os.remove(tmp)
print("ok", dst)
