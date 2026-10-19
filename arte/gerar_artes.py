#!/usr/bin/env python3
"""Gera a arte pixel art de cada carta no ComfyUI local, lendo o bloco ```prompt da seção
'## Prompt de arte' de cada cartas/<cultura>/NN_*.md. Saída: arte/<cultura>/<id>.png.

Uso: python3 gerar_artes.py [--cultura indigena] [--id ind_boitata] [--force] [--dry] [--seed-offset N]
"""
import argparse, glob, hashlib, json, os, re, sys, time, urllib.parse, urllib.request

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
API = "http://127.0.0.1:8188"
W, H = 768, 1024
CKPT = "Illustrious/pixelPerfect_v20.safetensors"
PREFIXO = ("pixel art, masterpiece, best quality, detailed pixel art, 16-bit, limited palette, "
           "mature, adult proportions, realistic body proportions, tall figure, small head, "
           "vertical composition, dark background, ")
NEGATIVO = ("chibi, super deformed, big head, oversized head, huge eyes, childlike proportions, toddler, cute, kawaii, loli, shota, lowres, blurry, text, watermark, signature, jpeg artifacts, worst quality, bad anatomy, "
            "smooth shading, 3d render, frame, border, card, letters, multiple views")


def ler_carta(path):
    md = open(path, encoding="utf-8").read()
    mj = re.search(r"```json\s*(\{.*?\})\s*```", md, re.S)
    mp = re.search(r"## Prompt de arte.*?```prompt\s*(.*?)```", md, re.S)
    if not mj:
        return None, None, "sem json"
    try:
        c = json.loads(mj.group(1))
    except json.JSONDecodeError as e:
        return None, None, f"json inválido: {e}"
    if not mp:
        return c, None, "sem bloco ```prompt"
    prompt = " ".join(mp.group(1).split())
    return c, prompt, None


def seed_de(cid, offset):
    return int(hashlib.sha1(cid.encode()).hexdigest()[:8], 16) % (2**31) + offset


def workflow(prompt, seed, prefixo_arquivo):
    return {
        "1": {"class_type": "CheckpointLoaderSimple", "inputs": {"ckpt_name": CKPT}},
        "2": {"class_type": "CLIPTextEncode", "inputs": {"text": PREFIXO + prompt, "clip": ["1", 1]}},
        "3": {"class_type": "CLIPTextEncode", "inputs": {"text": NEGATIVO, "clip": ["1", 1]}},
        "4": {"class_type": "EmptyLatentImage", "inputs": {"width": W, "height": H, "batch_size": 1}},
        "5": {"class_type": "KSampler", "inputs": {"seed": seed, "steps": 28, "cfg": 6.0,
               "sampler_name": "euler_ancestral", "scheduler": "normal", "denoise": 1.0,
               "model": ["1", 0], "positive": ["2", 0], "negative": ["3", 0], "latent_image": ["4", 0]}},
        "6": {"class_type": "VAEDecode", "inputs": {"samples": ["5", 0], "vae": ["1", 2]}},
        "7": {"class_type": "SaveImage", "inputs": {"filename_prefix": prefixo_arquivo, "images": ["6", 0]}},
    }


def gerar(prompt, seed, cid, destino):
    req = urllib.request.Request(API + "/prompt", data=json.dumps({"prompt": workflow(prompt, seed, "gk_" + cid)}).encode(),
                                 headers={"Content-Type": "application/json"})
    try:
        pid = json.load(urllib.request.urlopen(req))["prompt_id"]
    except urllib.error.HTTPError as e:
        return f"erro ao submeter: {e.read().decode()[:300]}"
    t0 = time.time()
    while time.time() - t0 < 600:
        time.sleep(2)
        h = json.load(urllib.request.urlopen(API + "/history/" + pid))
        if pid not in h:
            continue
        if h[pid].get("status", {}).get("status_str") == "error":
            return "erro na execução: " + json.dumps(h[pid]["status"])[:300]
        for node in h[pid]["outputs"].values():
            for im in node.get("images", []):
                q = urllib.parse.urlencode({"filename": im["filename"], "subfolder": im["subfolder"], "type": im["type"]})
                data = urllib.request.urlopen(API + "/view?" + q).read()
                os.makedirs(os.path.dirname(destino), exist_ok=True)
                open(destino, "wb").write(data)
                return None
    return "timeout"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--cultura")
    ap.add_argument("--id")
    ap.add_argument("--force", action="store_true")
    ap.add_argument("--dry", action="store_true")
    ap.add_argument("--seed-offset", type=int, default=0)
    a = ap.parse_args()
    padrao = os.path.join(RAIZ, "cartas", a.cultura or "*", "[0-9][0-9]_*.md")
    arquivos = sorted(glob.glob(padrao))
    feitos = pulados = erros = 0
    log = []
    for f in arquivos:
        cultura = os.path.basename(os.path.dirname(f))
        c, prompt, err = ler_carta(f)
        if err:
            print(f"PULA {f}: {err}"); erros += 1; log.append({"arquivo": f, "erro": err}); continue
        cid = c["id"]
        if a.id and cid != a.id:
            continue
        destino = os.path.join(RAIZ, "arte", cultura, cid + ".png")
        if os.path.exists(destino) and not a.force:
            pulados += 1; continue
        seed = seed_de(cid, a.seed_offset)
        print(f"[{cultura}] {cid} seed={seed}", flush=True)
        if a.dry:
            print("   ", PREFIXO + prompt); continue
        t0 = time.time()
        e = gerar(prompt, seed, cid, destino)
        if e:
            print("   ERRO", e); erros += 1; log.append({"id": cid, "erro": e})
        else:
            feitos += 1; print(f"    ok {time.time()-t0:.0f}s -> {destino}", flush=True)
            log.append({"id": cid, "seed": seed, "png": destino, "prompt": PREFIXO + prompt})
    os.makedirs(os.path.join(RAIZ, "arte"), exist_ok=True)
    with open(os.path.join(RAIZ, "arte", "_log_geracao.jsonl"), "a", encoding="utf-8") as fp:
        for l in log:
            fp.write(json.dumps(l, ensure_ascii=False) + "\n")
    print(f"feitos={feitos} pulados={pulados} erros={erros}")
    sys.exit(1 if erros else 0)


if __name__ == "__main__":
    main()
