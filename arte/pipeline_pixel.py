"""Pipeline anti-chibi: (1) ilustração no Z-Image Turbo (anatomia adulta, entende frases) → (2) pixelização por código
(grade 192×256, paleta de N cores, ampliação ×4 sem suavizar) → (3) opcional: img2img leve no pixelPerfect para
"assentar" o estilo pixel (denoise baixo não deixa o modelo redesenhar o corpo, então o chibi não volta).

Uso: python3 pipeline_pixel.py <saida_dir> <id> "<prompt em frases>" ["<tags pixel>"] [--seed N] [--cores 32] [--denoise 0.3]
Saídas: <id>_1_zimage.png, <id>_2_pixel.png, <id>_3_pixel_refinado.png (768×1024)."""
import argparse, io, json, os, time, urllib.parse, urllib.request, uuid
import numpy as np
from PIL import Image, ImageEnhance

API = "http://127.0.0.1:8188"
W, H = 768, 1024
ESTILO_Z = (" Dark fantasy digital painting, grim and epic, moody chiaroscuro, deep black shadows, strong rim light, "
            "rich saturated accent colors against darkness, gritty detailed textures, cinematic, menacing atmosphere. "
            "Bold readable shapes and a strong clear silhouette. Realistic human anatomy and proportions, normal-sized head, "
            "no chibi, no cartoon, no anime. Single subject, full body visible, vertical composition, no text, no frame.")
ESTILOS_Z = {
    "sombrio": ESTILO_Z,
    "anime": (" Dark anime illustration, mature seinen anime style, clean confident line art, cel shading with flat color areas "
              "and hard-edged shadows, deep black shadows, glowing accent lights, grim gothic atmosphere, dramatic key visual. "
              "Adult realistic anatomy and proportions, small head relative to body, sharp mature face, no chibi, no super deformed, "
              "no cute. Single subject, full body visible, vertical composition, dark background, no text, no frame."),
}
ANIME_POS = ("masterpiece, best quality, very aesthetic, absurdres, dark fantasy, seinen, mature, adult proportions, "
             "realistic proportions, cel shading, flat color, strong lineart, dramatic lighting, deep shadows, dark background, ")
ANIME_NEG = ("chibi, super deformed, big head, oversized head, huge eyes, childlike proportions, toddler, cute, kawaii, loli, shota, "
             "lowres, bad anatomy, bad hands, text, watermark, signature, jpeg artifacts, worst quality, low quality, "
             "frame, border, letters, multiple views, 3d, realistic photo")
PREFIXO_PX = ("pixel art, masterpiece, best quality, detailed pixel art, 16-bit, limited palette, mature, adult proportions, "
              "realistic body proportions, ")
NEG_PX = ("chibi, super deformed, big head, oversized head, huge eyes, childlike proportions, toddler, cute, kawaii, "
          "lowres, blurry, text, watermark, signature, jpeg artifacts, worst quality, bad anatomy, smooth shading, 3d render, "
          "frame, border, letters")


def _post(caminho, corpo, tipo="application/json"):
    req = urllib.request.Request(API + caminho, data=corpo, headers={"Content-Type": tipo})
    return json.load(urllib.request.urlopen(req))


def _rodar(wf, destino):
    pid = _post("/prompt", json.dumps({"prompt": wf}).encode())["prompt_id"]
    while True:
        time.sleep(2)
        h = json.load(urllib.request.urlopen(API + "/history/" + pid))
        if pid in h:
            st = h[pid].get("status", {})
            if st.get("status_str") == "error":
                raise RuntimeError(json.dumps(st)[:600])
            for n in h[pid]["outputs"].values():
                for im in n.get("images", []):
                    q = urllib.parse.urlencode({"filename": im["filename"], "subfolder": im["subfolder"], "type": im["type"]})
                    open(destino, "wb").write(urllib.request.urlopen(API + "/view?" + q).read())
                    return


def _upload(img, nome):
    buf = io.BytesIO(); img.save(buf, "PNG"); b = uuid.uuid4().hex
    corpo = (f"--{b}\r\nContent-Disposition: form-data; name=\"image\"; filename=\"{nome}\"\r\nContent-Type: image/png\r\n\r\n").encode() \
        + buf.getvalue() + f"\r\n--{b}\r\nContent-Disposition: form-data; name=\"overwrite\"\r\n\r\ntrue\r\n--{b}--\r\n".encode()
    return _post("/upload/image", corpo, f"multipart/form-data; boundary={b}")["name"]


def animagine(tags, seed, destino):
    wf = {
        "1": {"class_type": "CheckpointLoaderSimple", "inputs": {"ckpt_name": "Animagine_XL_3.1.safetensors"}},
        "2": {"class_type": "CLIPTextEncode", "inputs": {"text": ANIME_POS + tags, "clip": ["1", 1]}},
        "3": {"class_type": "CLIPTextEncode", "inputs": {"text": ANIME_NEG, "clip": ["1", 1]}},
        "4": {"class_type": "EmptyLatentImage", "inputs": {"width": W, "height": H, "batch_size": 1}},
        "5": {"class_type": "KSampler", "inputs": {"seed": seed, "steps": 28, "cfg": 7.0, "sampler_name": "euler_ancestral",
               "scheduler": "normal", "denoise": 1.0, "model": ["1", 0], "positive": ["2", 0], "negative": ["3", 0], "latent_image": ["4", 0]}},
        "6": {"class_type": "VAEDecode", "inputs": {"samples": ["5", 0], "vae": ["1", 2]}},
        "7": {"class_type": "SaveImage", "inputs": {"filename_prefix": "gk_pipe_anime", "images": ["6", 0]}},
    }
    _rodar(wf, destino)


def sars(tags, seed, destino):
    """S.A.R.S (Illustrious, civitai 2961732): 832×1216 (perto de 3:4 — recortado/redimensionado depois para 768×1024),
    Euler A, 25 passos, CFG 5, clip skip 2 (recomendação do autor)."""
    wf = {
        "1": {"class_type": "CheckpointLoaderSimple", "inputs": {"ckpt_name": "S.A.R.S.safetensors"}},
        "2": {"class_type": "CLIPSetLastLayer", "inputs": {"stop_at_clip_layer": -2, "clip": ["1", 1]}},
        "3": {"class_type": "CLIPTextEncode", "inputs": {"text": ANIME_POS + tags, "clip": ["2", 0]}},
        "4": {"class_type": "CLIPTextEncode", "inputs": {"text": ANIME_NEG, "clip": ["2", 0]}},
        "5": {"class_type": "EmptyLatentImage", "inputs": {"width": 840, "height": 1120, "batch_size": 1}},
        "6": {"class_type": "KSampler", "inputs": {"seed": seed, "steps": 25, "cfg": 5.0, "sampler_name": "euler_ancestral",
               "scheduler": "normal", "denoise": 1.0, "model": ["1", 0], "positive": ["3", 0], "negative": ["4", 0], "latent_image": ["5", 0]}},
        "7": {"class_type": "VAEDecode", "inputs": {"samples": ["6", 0], "vae": ["1", 2]}},
        "8": {"class_type": "SaveImage", "inputs": {"filename_prefix": "gk_pipe_sars", "images": ["7", 0]}},
    }
    _rodar(wf, destino)
    Image.open(destino).convert("RGB").resize((W, H), Image.LANCZOS).save(destino)


GATILHO_CHAOTIC = ("Abstract composition. Cubism art style, ChaLOSTIC, The illustration has a stylized, geometric, "
                   "and somewhat abstract art style, abstract, ")


def krea2(prompt, seed, destino, lora="Chaotic_Shapes_krea2.safetensors", forca=1.0):
    """Krea 2 Turbo NVFP4 (workflow oficial Comfy-Org): 8 passos, CFG 1, Euler/simple, negativo zerado.
    Com o LoRA Chaotic Shapes, o gatilho completo do autor vai na frente do prompt."""
    texto = (GATILHO_CHAOTIC if lora and "Chaotic" in lora else "") + prompt + " Dark, moody, deep shadows. Single subject, full body, no text, no frame."
    wf = {
        "1": {"class_type": "UNETLoader", "inputs": {"unet_name": "krea2_turbo_nvfp4.safetensors", "weight_dtype": "default"}},
        "2": {"class_type": "CLIPLoader", "inputs": {"clip_name": "qwen3vl_4b_bf16.safetensors", "type": "krea2", "device": "default"}},
        "3": {"class_type": "VAELoader", "inputs": {"vae_name": "qwen_image_vae.safetensors"}},
        "5": {"class_type": "CLIPTextEncode", "inputs": {"text": texto, "clip": ["2", 0]}},
        "6": {"class_type": "ConditioningZeroOut", "inputs": {"conditioning": ["5", 0]}},
        "7": {"class_type": "EmptyLatentImage", "inputs": {"width": W, "height": H, "batch_size": 1}},
        "8": {"class_type": "KSampler", "inputs": {"seed": seed, "steps": 8, "cfg": 1.0, "sampler_name": "euler", "scheduler": "simple",
               "denoise": 1.0, "model": ["4", 0] if lora else ["1", 0], "positive": ["5", 0], "negative": ["6", 0], "latent_image": ["7", 0]}},
        "9": {"class_type": "VAEDecode", "inputs": {"samples": ["8", 0], "vae": ["3", 0]}},
        "10": {"class_type": "SaveImage", "inputs": {"filename_prefix": "gk_pipe_krea2", "images": ["9", 0]}},
    }
    if lora:
        wf["4"] = {"class_type": "LoraLoaderModelOnly", "inputs": {"lora_name": lora, "strength_model": forca, "model": ["1", 0]}}
    _rodar(wf, destino)


VAE_PIXEL = "pixelate_x8_vae.safetensors"     # Pixelate x8 VAE (civitai 1492329): cada ponto do latente vira um bloco 8×8


def limpar_grade(src, destino, cel=8):
    """Limpa o resíduo (tipo JPEG) do VAE pixel: cada célula cel×cel vira a mediana das cores dela."""
    a = np.asarray(Image.open(src).convert("RGB")).astype(np.int16)
    h, w = a.shape[0] // cel * cel, a.shape[1] // cel * cel
    blocos = a[:h, :w].reshape(h // cel, cel, w // cel, cel, 3).transpose(0, 2, 1, 3, 4).reshape(h // cel, w // cel, cel * cel, 3)
    med = np.median(blocos, axis=2).astype(np.uint8)
    Image.fromarray(med).resize((w, h), Image.NEAREST).save(destino)


def sars_pixel(tags, seed, destino):
    """S.A.R.S gerando direto com o VAE pixel (768×1024 → grade 96×128)."""
    wf = {
        "1": {"class_type": "CheckpointLoaderSimple", "inputs": {"ckpt_name": "S.A.R.S.safetensors"}},
        "2": {"class_type": "CLIPSetLastLayer", "inputs": {"stop_at_clip_layer": -2, "clip": ["1", 1]}},
        "3": {"class_type": "CLIPTextEncode", "inputs": {"text": ANIME_POS + tags, "clip": ["2", 0]}},
        "4": {"class_type": "CLIPTextEncode", "inputs": {"text": ANIME_NEG, "clip": ["2", 0]}},
        "5": {"class_type": "EmptyLatentImage", "inputs": {"width": W, "height": H, "batch_size": 1}},
        "6": {"class_type": "KSampler", "inputs": {"seed": seed, "steps": 25, "cfg": 5.0, "sampler_name": "euler_ancestral",
               "scheduler": "normal", "denoise": 1.0, "model": ["1", 0], "positive": ["3", 0], "negative": ["4", 0], "latent_image": ["5", 0]}},
        "9": {"class_type": "VAELoader", "inputs": {"vae_name": VAE_PIXEL}},
        "7": {"class_type": "VAEDecode", "inputs": {"samples": ["6", 0], "vae": ["9", 0]}},
        "8": {"class_type": "SaveImage", "inputs": {"filename_prefix": "gk_pipe_sars_px", "images": ["7", 0]}},
    }
    _rodar(wf, destino)


def converter_pixel(src, destino, ckpt="S.A.R.S.safetensors"):
    """Pixeliza uma arte pronta: codifica com o VAE do checkpoint e decodifica com o VAE pixel."""
    nome = _upload(Image.open(src).convert("RGB").resize((W, H), Image.LANCZOS), "gk_conv_in.png")
    wf = {
        "1": {"class_type": "CheckpointLoaderSimple", "inputs": {"ckpt_name": ckpt}},
        "2": {"class_type": "LoadImage", "inputs": {"image": nome}},
        "3": {"class_type": "VAEEncode", "inputs": {"pixels": ["2", 0], "vae": ["1", 2]}},
        "4": {"class_type": "VAELoader", "inputs": {"vae_name": VAE_PIXEL}},
        "5": {"class_type": "VAEDecode", "inputs": {"samples": ["3", 0], "vae": ["4", 0]}},
        "6": {"class_type": "SaveImage", "inputs": {"filename_prefix": "gk_conv_px", "images": ["5", 0]}},
    }
    _rodar(wf, destino)


def zimage(prompt, seed, destino, estilo="sombrio"):
    wf = {
        "1": {"class_type": "UNETLoader", "inputs": {"unet_name": "z_image_turbo_bf16.safetensors", "weight_dtype": "default"}},
        "2": {"class_type": "CLIPLoader", "inputs": {"clip_name": "qwen_3_4b.safetensors", "type": "lumina2", "device": "default"}},
        "3": {"class_type": "VAELoader", "inputs": {"vae_name": "ae.safetensors"}},
        "4": {"class_type": "ModelSamplingAuraFlow", "inputs": {"shift": 3.0, "model": ["1", 0]}},
        "5": {"class_type": "CLIPTextEncode", "inputs": {"text": prompt + ESTILOS_Z[estilo], "clip": ["2", 0]}},
        "6": {"class_type": "ConditioningZeroOut", "inputs": {"conditioning": ["5", 0]}},
        "7": {"class_type": "EmptySD3LatentImage", "inputs": {"width": W, "height": H, "batch_size": 1}},
        "8": {"class_type": "KSampler", "inputs": {"seed": seed, "steps": 8, "cfg": 1.0, "sampler_name": "euler", "scheduler": "simple",
               "denoise": 1.0, "model": ["4", 0], "positive": ["5", 0], "negative": ["6", 0], "latent_image": ["7", 0]}},
        "9": {"class_type": "VAEDecode", "inputs": {"samples": ["8", 0], "vae": ["3", 0]}},
        "10": {"class_type": "SaveImage", "inputs": {"filename_prefix": "gk_pipe_z", "images": ["9", 0]}},
    }
    _rodar(wf, destino)


def pixelizar(src, destino, grade=192, cores=32):
    """Reduz para grade×(grade·4/3) com média de área, reforça contraste/saturação, paleta de `cores` (k-means, sem
    pontilhado) e amplia ×(768/grade) com vizinho mais próximo."""
    im = Image.open(src).convert("RGB")
    gh = round(grade * H / W)
    peq = im.resize((grade, gh), Image.BOX)
    peq = ImageEnhance.Contrast(peq).enhance(1.12)
    peq = ImageEnhance.Color(peq).enhance(1.15)
    pal = peq.quantize(colors=cores, method=Image.Quantize.MAXCOVERAGE, kmeans=4, dither=Image.Dither.NONE).convert("RGB")
    pal.resize((W, H), Image.NEAREST).save(destino)


def refinar(src, tags, seed, denoise, destino):
    nome = _upload(Image.open(src).convert("RGB"), "gk_pipe_in.png")
    wf = {
        "1": {"class_type": "CheckpointLoaderSimple", "inputs": {"ckpt_name": "Illustrious/pixelPerfect_v20.safetensors"}},
        "2": {"class_type": "CLIPTextEncode", "inputs": {"text": PREFIXO_PX + tags, "clip": ["1", 1]}},
        "3": {"class_type": "CLIPTextEncode", "inputs": {"text": NEG_PX, "clip": ["1", 1]}},
        "4": {"class_type": "LoadImage", "inputs": {"image": nome}},
        "5": {"class_type": "VAEEncode", "inputs": {"pixels": ["4", 0], "vae": ["1", 2]}},
        "6": {"class_type": "KSampler", "inputs": {"seed": seed, "steps": 28, "cfg": 6.0, "sampler_name": "euler_ancestral",
               "scheduler": "normal", "denoise": denoise, "model": ["1", 0], "positive": ["2", 0], "negative": ["3", 0], "latent_image": ["5", 0]}},
        "7": {"class_type": "VAEDecode", "inputs": {"samples": ["6", 0], "vae": ["1", 2]}},
        "8": {"class_type": "SaveImage", "inputs": {"filename_prefix": "gk_pipe_px", "images": ["7", 0]}},
    }
    _rodar(wf, destino)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("saida"); ap.add_argument("id"); ap.add_argument("prompt"); ap.add_argument("tags", nargs="?", default="")
    ap.add_argument("--seed", type=int, default=101); ap.add_argument("--cores", type=int, default=32)
    ap.add_argument("--grade", type=int, default=192); ap.add_argument("--denoise", type=float, default=0.3)
    ap.add_argument("--modelo", default="zimage", choices=["zimage", "animagine", "sars", "krea2"]); ap.add_argument("--estilo", default="sombrio")
    a = ap.parse_args()
    os.makedirs(a.saida, exist_ok=True)
    base = os.path.join(a.saida, a.id)
    if a.modelo == "animagine":
        animagine(a.tags, a.seed, base + "_1_zimage.png")
    elif a.modelo == "sars":
        sars(a.tags, a.seed, base + "_1_zimage.png")
    elif a.modelo == "krea2":
        krea2(a.prompt, a.seed, base + "_1_zimage.png")
    else:
        zimage(a.prompt, a.seed, base + "_1_zimage.png", a.estilo)
    pixelizar(base + "_1_zimage.png", base + "_2_pixel.png", a.grade, a.cores)
    if a.tags and a.denoise > 0:
        refinar(base + "_2_pixel.png", a.tags, a.seed, a.denoise, base + "_3_pixel_refinado.png")
    print("ok", a.id)


if __name__ == "__main__":
    main()
