"""Regenera o frame no ComfyUI (img2img com pixelPerfect) a partir da versão limpa, para ganhar nitidez.
Uso: /mnt/d/Comfy-Desktop/venv/bin/python regenerar_frame.py <base.png> <nome_saida> [denoise ...]"""
import json, sys, time, urllib.parse, urllib.request, uuid, io
from PIL import Image

API = "http://127.0.0.1:8188"
W, H = 832, 1208
POS = ("pixel art, masterpiece, best quality, detailed pixel art, 16-bit, crisp sharp pixels, clean pixel outlines, "
       "no humans, ornate trading card frame, gold and bronze filigree border, carved runes on dark wood side panels, "
       "large empty circular window framed by blue enamel ring with small gems, top crystal ornament, "
       "blank parchment ribbon banner, large blank parchment text box, two small shields in bottom corners, "
       "small round medallion at bottom center, symmetrical, front view, flat lighting")
NEG = ("lowres, blurry, soft, jpeg artifacts, worst quality, text, letters, watermark, signature, character, person, "
       "creature, landscape inside window, 3d render, smooth shading, asymmetrical, perspective, tilted")


def upload(img, nome):
    buf = io.BytesIO(); img.save(buf, "PNG")
    b = uuid.uuid4().hex
    corpo = (f"--{b}\r\nContent-Disposition: form-data; name=\"image\"; filename=\"{nome}\"\r\nContent-Type: image/png\r\n\r\n").encode() \
        + buf.getvalue() + f"\r\n--{b}\r\nContent-Disposition: form-data; name=\"overwrite\"\r\n\r\ntrue\r\n--{b}--\r\n".encode()
    req = urllib.request.Request(API + "/upload/image", data=corpo, headers={"Content-Type": f"multipart/form-data; boundary={b}"})
    return json.load(urllib.request.urlopen(req))["name"]


def wf(nome_in, denoise, seed, prefixo):
    return {
        "1": {"class_type": "CheckpointLoaderSimple", "inputs": {"ckpt_name": "Illustrious/pixelPerfect_v20.safetensors"}},
        "2": {"class_type": "CLIPTextEncode", "inputs": {"text": POS, "clip": ["1", 1]}},
        "3": {"class_type": "CLIPTextEncode", "inputs": {"text": NEG, "clip": ["1", 1]}},
        "4": {"class_type": "LoadImage", "inputs": {"image": nome_in}},
        "5": {"class_type": "VAEEncode", "inputs": {"pixels": ["4", 0], "vae": ["1", 2]}},
        "6": {"class_type": "KSampler", "inputs": {"seed": seed, "steps": 30, "cfg": 6.0, "sampler_name": "euler_ancestral",
               "scheduler": "normal", "denoise": denoise, "model": ["1", 0], "positive": ["2", 0], "negative": ["3", 0], "latent_image": ["5", 0]}},
        "7": {"class_type": "VAEDecode", "inputs": {"samples": ["6", 0], "vae": ["1", 2]}},
        "8": {"class_type": "SaveImage", "inputs": {"filename_prefix": prefixo, "images": ["7", 0]}},
    }


def rodar(w, destino):
    pid = json.load(urllib.request.urlopen(urllib.request.Request(API + "/prompt", data=json.dumps({"prompt": w}).encode(),
                                                                   headers={"Content-Type": "application/json"})))["prompt_id"]
    while True:
        time.sleep(2)
        h = json.load(urllib.request.urlopen(API + "/history/" + pid))
        if pid in h:
            for n in h[pid]["outputs"].values():
                for im in n.get("images", []):
                    q = urllib.parse.urlencode({"filename": im["filename"], "subfolder": im["subfolder"], "type": im["type"]})
                    open(destino, "wb").write(urllib.request.urlopen(API + "/view?" + q).read())
                    return


base_path, nome = sys.argv[1], sys.argv[2]
denoises = [float(x) for x in sys.argv[3:]] or [0.35, 0.45, 0.55]
base = Image.open(base_path).convert("RGBA")
fundo = Image.new("RGBA", base.size, (53, 62, 69, 255))  # janelas voltam ao cinza original
fundo.alpha_composite(base)
nome_in = upload(fundo.convert("RGB").resize((W, H), Image.NEAREST), f"gk_{nome}_base.png")
for d in denoises:
    destino = f"{nome}_regen_d{int(d*100)}.png"
    rodar(wf(nome_in, d, 777, f"gk_{nome}_regen"), destino)
    print("ok", destino, flush=True)
