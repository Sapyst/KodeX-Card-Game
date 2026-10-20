"""Foil por img2img: parte da arte Krea aprovada (que já tem os atributos certos) e redesenha em S.A.R.S dark fantasy,
mantendo a composição. Saídas: arte/<deck>/_sars_foil/<id>_i1.png (denoise 0.5) e _i2.png (0.6).
Uso: python gerar_sars_img2img.py --ids a,b,c"""
import argparse, glob, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pipeline_pixel as PP
from gerar_krea import ler, RAIZ, DECKS
from PIL import Image

BASE = ("dark fantasy, mythological, legendary, epic, ancient, highly detailed, painterly, dramatic lighting, volumetric light, "
        "mist, glowing magical light, sparks, intricate details, fully clothed, ")
NEG = PP.ANIME_NEG.replace("huge eyes, ", "") + ", nudity, cleavage, revealing clothes, abstract, cubism, geometric shapes"
ap = argparse.ArgumentParser(); ap.add_argument("--ids", required=True); ap.add_argument("--rodada", type=int, default=1)
a = ap.parse_args()
# rodada 2: redesenho mais leve (0.38/0.44) e reforço do que o img2img costuma trocar por objeto genérico
REFORCO = {
 "ind_tupa": "(standing on storm clouds:1.3), (wooden tacape war club:1.2), (lightning bolts held in left hand:1.3), (scarlet macaw feather headdress, red blue yellow:1.2)",
 "cri_elias": "(sheepskin mantle:1.3), (chariot of fire:1.3), (two horses made of fire:1.3)",
 "cri_sao_miguel_arcanjo": "(foot on the dragon's head:1.4), golden scales in left hand",
 "tao_xiwangmu": "(pink peach in her open palm:1.4), (mature queen, middle-aged woman:1.3), (phoenix crown:1.2), blue bird",
 "tao_imperador_de_jade": "(mian crown with flat board and bead strings:1.4), (jade tablet held with both hands:1.3), (dragon embroidered robe:1.2), jade throne",
 "hin_shiva_nataraja": "(blue skin:1.5), (damaru drum in upper right hand:1.4), (third eye on forehead:1.3), four arms, dancing in ring of fire",
 "bru_hecate": "(crossroads, three roads meeting:1.3), (iron key on belt:1.4), three faces",
}
NIVEIS = ((1, 0.5), (2, 0.6)) if a.rodada == 1 else ((3, 0.38), (4, 0.44))
alvo = set(a.ids.split(","))
for deck in DECKS:
    for f in sorted(glob.glob(os.path.join(RAIZ, "cartas", deck, "[0-9][0-9]_*.md"))):
        c, prompt = ler(f)
        if c["id"] not in alvo:
            continue
        src = Image.open(os.path.join(RAIZ, "arte", deck, c["id"] + ".png")).convert("RGB").resize((840, 1120), Image.LANCZOS)
        nome = PP._upload(src, f"foil_base_{c['id']}.png")
        for k, den in NIVEIS:
            dest = os.path.join(RAIZ, "arte", deck, "_sars_foil", f"{c['id']}_i{k}.png")
            if os.path.exists(dest):
                continue
            os.makedirs(os.path.dirname(dest), exist_ok=True)
            wf = {
                "1": {"class_type": "CheckpointLoaderSimple", "inputs": {"ckpt_name": "S.A.R.S.safetensors"}},
                "2": {"class_type": "CLIPSetLastLayer", "inputs": {"stop_at_clip_layer": -2, "clip": ["1", 1]}},
                "3": {"class_type": "CLIPTextEncode", "inputs": {"text": PP.ANIME_POS + BASE + (REFORCO.get(c["id"], "") + ", " if a.rodada > 1 else "") + prompt, "clip": ["2", 0]}},
                "4": {"class_type": "CLIPTextEncode", "inputs": {"text": NEG, "clip": ["2", 0]}},
                "9": {"class_type": "LoadImage", "inputs": {"image": nome}},
                "10": {"class_type": "VAEEncode", "inputs": {"pixels": ["9", 0], "vae": ["1", 2]}},
                "6": {"class_type": "KSampler", "inputs": {"seed": 3301 + k, "steps": 28, "cfg": 5.0, "sampler_name": "euler_ancestral",
                      "scheduler": "normal", "denoise": den, "model": ["1", 0], "positive": ["3", 0], "negative": ["4", 0], "latent_image": ["10", 0]}},
                "7": {"class_type": "VAEDecode", "inputs": {"samples": ["6", 0], "vae": ["1", 2]}},
                "8": {"class_type": "SaveImage", "inputs": {"filename_prefix": "gk_foil_i2i", "images": ["7", 0]}}}
            PP._rodar(wf, dest)
            Image.open(dest).convert("RGB").resize((768, 1024), Image.LANCZOS).save(dest)
            print(c["id"], k, flush=True)
print("fim")
