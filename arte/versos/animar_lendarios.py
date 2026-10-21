"""Efeitos animados por cima dos versos lendários (os mesmos efeitos vão para o jogo, desenhados por cima da textura).
Loop de 2 s a 18 qps (36 quadros), em pixel art 128×180, exportado ampliado 3× como MP4 (e GIF) para prévia.
Efeitos: varredura (faixa de brilho diagonal), brilhos (faíscas em + piscando), aura (halo pulsando no centro),
anel (brilho que corre num círculo de raio R, com rastro) e motes (partículas de luz subindo).
Uso: /mnt/d/Comfy-Desktop/venv/bin/python arte/versos/animar_lendarios.py <verso.png> <saida_sem_ext> <efeitos> [raio cx cy]
     efeitos separados por vírgula, ex.: varredura,brilhos,anel"""
import math, os, random, subprocess, sys
import numpy as np
from PIL import Image

QPS, N = 18, 36


def somar(arr, x, y, cor, a):
    x, y = int(round(x)), int(round(y))
    if 0 <= x < arr.shape[1] and 0 <= y < arr.shape[0]:
        arr[y, x] = arr[y, x] * (1 - a) + np.array(cor, np.float32) * a


def quadro(base: np.ndarray, t: float, efeitos: list, raio: float, rng_pos, centro=None) -> np.ndarray:
    a = base.astype(np.float32).copy()
    H, W = a.shape[:2]
    cx, cy = centro if centro else (W / 2 - 0.5, H / 2 - 0.5)
    y, x = np.mgrid[0:H, 0:W].astype(np.float32)
    u = t / (N / QPS)                                   # 0..1 no loop
    if "aura" in efeitos:
        r = np.sqrt((x - cx) ** 2 + (y - cy) ** 2)
        puls = 0.5 + 0.5 * math.sin(u * math.tau)
        g = np.clip(1 - r / (38 + 6 * puls), 0, 1) ** 2 * (0.22 + 0.12 * puls)
        a += (np.array([255, 230, 170], np.float32) - a) * g[..., None]
    if "varredura" in efeitos:
        pos = -60 + u * (W + H + 120)
        d = np.abs((x + y * 0.6) - pos)
        g = np.clip(1 - d / 9, 0, 1) * 0.35
        a += (np.array([255, 248, 220], np.float32) - a) * g[..., None]
    if "anel" in efeitos:
        for k in range(10):                             # cabeça + rastro de 9 pontos
            ang = u * math.tau - k * 0.07
            px, py = cx + math.cos(ang) * raio, cy + math.sin(ang) * raio
            al = (1 - k / 10) * 0.9
            somar(a, px, py, (255, 250, 210), al)
            if k == 0:
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    somar(a, px + dx, py + dy, (255, 220, 120), 0.6)
    if "brilhos" in efeitos:
        for (px, py, fase) in rng_pos["brilhos"]:
            v = max(0.0, math.sin((u + fase) * math.tau * 2))
            if v > 0.05:
                somar(a, px, py, (255, 255, 235), v)
                tam = 1 + int(v * 2.5)
                for k in range(1, tam + 1):
                    for dx, dy in ((k, 0), (-k, 0), (0, k), (0, -k)):
                        somar(a, px + dx, py + dy, (255, 230, 150), v * (1 - k / (tam + 1)))
    if "motes" in efeitos:
        for (px0, fase, vel) in rng_pos["motes"]:
            v = (u * vel + fase) % 1.0
            py = H - 8 - v * (H - 16)
            px = px0 + math.sin(v * math.tau * 2 + fase * 9) * 3
            al = math.sin(v * math.pi) * 0.85
            somar(a, px, py, (230, 200, 255), al)
            somar(a, px, py + 1, (180, 140, 255), al * 0.5)
    return np.clip(a, 0, 255).astype(np.uint8)


def main():
    src, saida, efeitos = sys.argv[1], sys.argv[2], sys.argv[3].split(",")
    raio = float(sys.argv[4]) if len(sys.argv) > 4 else 40.0
    centro = (float(sys.argv[5]), float(sys.argv[6])) if len(sys.argv) > 6 else None
    base = np.asarray(Image.open(src).convert("RGB"))
    H, W = base.shape[:2]
    r = random.Random(7)
    pos = {"brilhos": [(r.randrange(10, W - 10), r.randrange(12, H - 12), r.random()) for _ in range(12)],
           "motes": [(r.randrange(14, W - 14), r.random(), r.choice([1, 1, 2])) for _ in range(22)]}
    pasta = saida + "_quadros"
    os.makedirs(pasta, exist_ok=True)
    quadros = []
    for k in range(N):
        im = Image.fromarray(quadro(base, k / QPS, efeitos, raio, pos, centro)).resize((W * 3, H * 3), Image.NEAREST)
        im.save(os.path.join(pasta, f"q{k:03d}.png"))
        quadros.append(im)
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-stream_loop", "2", "-framerate", str(QPS), "-i",
                    os.path.join(pasta, "q%03d.png"), "-pix_fmt", "yuv420p", "-movflags", "faststart", saida + ".mp4"], check=True)
    quadros[0].save(saida + ".gif", save_all=True, append_images=quadros[1:], duration=int(1000 / QPS), loop=0)
    print("ok", saida)


if __name__ == "__main__":
    main()
