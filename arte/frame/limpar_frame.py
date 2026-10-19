"""Isola a carta (frente ou verso) e re-pixeliza numa grade limpa.
Uso (python do ComfyUI, que tem Pillow/numpy):
  /mnt/d/Comfy-Desktop/venv/bin/python limpar_frame.py frame_original.png frame        (frente: janelas viram transparentes)
  /mnt/d/Comfy-Desktop/venv/bin/python limpar_frame.py verso_original.png verso --sem-janelas
Opcionais: --largura N (pixels de arte na horizontal, padrão 136) --cores N (padrão 48).
Saídas: <nome>_nativo.png (1 px = 1 pixel de arte), <nome>_x6.png (ampliado sem suavizar),
        <nome>_mascara_arte.png (só frente; branco = onde entra a ilustração)."""
import sys
from collections import deque
import numpy as np
from PIL import Image

import argparse
ap = argparse.ArgumentParser()
ap.add_argument("entrada", nargs="?", default="frame_original.png")
ap.add_argument("nome", nargs="?", default="frame")
ap.add_argument("--largura", type=int, default=136)
ap.add_argument("--cores", type=int, default=48)
ap.add_argument("--sem-janelas", action="store_true")
args = ap.parse_args()
W, N_CORES, NOME = args.largura, args.cores, args.nome
ESCALA = 6
JANELA = np.array([53, 62, 69])  # cinza dos espaços vazios (círculo, escudos, gema)


def kmeans(px, k, iters=25, seed=0):
    rng = np.random.default_rng(seed)
    c = px[rng.choice(len(px), k, replace=False)].astype(float)
    for _ in range(iters):
        d = ((px[:, None, :] - c[None]) ** 2).sum(2)
        lab = d.argmin(1)
        for i in range(k):
            m = px[lab == i]
            if len(m):
                c[i] = m.mean(0)
    return c.round().astype(np.uint8), lab


def inundar(cor_ok, sementes):
    h, w = cor_ok.shape
    vis = np.zeros_like(cor_ok)
    q = deque(s for s in sementes if cor_ok[s])
    for s in q:
        vis[s] = True
    while q:
        y, x = q.popleft()
        for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            ny, nx = y + dy, x + dx
            if 0 <= ny < h and 0 <= nx < w and cor_ok[ny, nx] and not vis[ny, nx]:
                vis[ny, nx] = True
                q.append((ny, nx))
    return vis


orig = Image.open(args.entrada).convert("RGB")
oa = np.asarray(orig).astype(int)
FUNDO = oa[5, 5]  # cor do fundo da tela, lida do canto
dif = np.abs(oa - FUNDO).sum(2) > 40
if orig.width > orig.height * 1.3:  # captura larga: ignora a marca d'água no canto direito
    dif[:, int(orig.width * 0.83):] = False
ys, xs = np.where(dif)
src = orig.crop((xs.min(), ys.min(), xs.max() + 1, ys.max() + 1))
H = round(W * src.size[1] / src.size[0])
peq = np.asarray(src.resize((W, H), Image.BOX)).astype(int)

dist = lambda a, cor: np.abs(a - cor).sum(2)
borda = [(y, x) for y in range(H) for x in (0, W - 1)] + [(y, x) for x in range(W) for y in (0, H - 1)]
fundo = inundar(dist(peq, FUNDO) < 22, borda)
# sementes nas janelas: centro do círculo, dos dois escudos e da gema (frações do cartão)
sem = [(int(H * fy), int(W * fx)) for fy, fx in ((0.24, 0.5), (0.915, 0.12), (0.915, 0.88), (0.925, 0.5))]
janela = np.zeros_like(fundo)
if not args.sem_janelas:
    for sy, sx in sem:  # cada janela inunda a partir da própria cor (o tom varia com a ampliação)
        if dist(peq[sy:sy + 1, sx:sx + 1], JANELA)[0, 0] < 60:
            janela |= inundar(dist(peq, peq[sy, sx]) < 24, [(sy, sx)])

# franja: pixels escuros encostados no fundo transparente também saem (2 passadas)
for _ in range(2):
    viz = np.zeros_like(fundo)
    viz[1:] |= fundo[:-1]; viz[:-1] |= fundo[1:]; viz[:, 1:] |= fundo[:, :-1]; viz[:, :-1] |= fundo[:, 1:]
    fundo |= viz & (dist(peq, FUNDO) < 40)
opaco = ~(fundo | janela)
pal, lab = kmeans(peq[opaco].reshape(-1, 3), N_CORES)
out = np.zeros((H, W, 4), np.uint8)
out[opaco, :3] = pal[lab]
out[opaco, 3] = 255

Image.fromarray(out, "RGBA").save(f"{NOME}_nativo.png")
Image.fromarray(out, "RGBA").resize((W * ESCALA, H * ESCALA), Image.NEAREST).save(f"{NOME}_x{ESCALA}.png")
if not args.sem_janelas:
    Image.fromarray((janela * 255).astype(np.uint8)).resize((W * ESCALA, H * ESCALA), Image.NEAREST).save(f"{NOME}_mascara_arte.png")
print(f"{NOME}: recorte {src.size}, nativo {W}x{H}, x{ESCALA} = {W*ESCALA}x{H*ESCALA}, cores {N_CORES}, janela {janela.sum()} px, fundo {fundo.sum()} px")
