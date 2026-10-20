"""Teste de carta FOIL: arte (S.A.R.S) no frame especial (arco-íris), com brilho holográfico animado por cima.
Saídas em _foil_teste/: quadros, foil.mp4, foil.gif e uma prévia parada. Uso: python foil_teste.py <arte.png> <id> <deck>"""
import colorsys, glob, os, subprocess, sys
import numpy as np
from PIL import Image, ImageDraw, ImageFilter
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import montar_cartas as M
F2 = M.F2

arte, cid, deck = sys.argv[1], sys.argv[2], sys.argv[3]
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "_foil_teste")
os.makedirs(OUT, exist_ok=True)
for f in glob.glob(os.path.join(OUT, "q_*.png")):
    os.remove(f)
ficha = next(f for f in glob.glob(os.path.join(M.RAIZ, "cartas", deck, "[0-9][0-9]_*.md")) if f'"id": "{cid}"' in open(f, encoding="utf-8").read())
c = F2.ler_carta(ficha)
N = 48                                   # 48 quadros a 24 qps = 2 s em loop
rng = np.random.default_rng(5)
glints = [(rng.uniform(0.08, 0.92), rng.uniform(0.06, 0.94), rng.uniform(0, 1), rng.uniform(4, 11)) for _ in range(34)]


def hsv_np(h, s, v):
    i = np.floor(h * 6).astype(int) % 6
    f = h * 6 - np.floor(h * 6)
    p, q, t = v * (1 - s), v * (1 - f * s), v * (1 - (1 - f) * s)
    r = np.choose(i, [v, q, p, p, t, v]); g = np.choose(i, [t, v, v, q, p, p]); b = np.choose(i, [p, p, t, v, v, q])
    return np.dstack([r, g, b])


tem_def = c["tipo"] == "entidade"
for k in range(N):
    u = k / N
    im = Image.new("RGBA", (F2.W, F2.H), (0, 0, 0, 0))
    x0, y0, x1, y1 = F2.ART
    im.alpha_composite(Image.open(arte).convert("RGBA").resize((x1 - x0, y1 - y0), Image.LANCZOS), (x0, y0))
    im.alpha_composite(F2.para_imagem(F2.frame(deck, "especial", u, defesa=tem_def)))
    F2.escrever(im, c, deck, "especial")
    if tem_def:
        d = ImageDraw.Draw(im)
        F2.texto_contorno(d, (F2.W - F2.PAINEL - 22, (F2.DEFESA[1] + F2.DEFESA[3]) / 2 + 2), f"Def {c['vida']}",
                          F2.fonte(F2.FONTE_TITULO, 34), (255, 255, 255), esp=3, anchor="rm")
    base = np.asarray(im.convert("RGB")).astype(np.float32) / 255
    H, W = base.shape[:2]
    yy, xx = np.mgrid[0:H, 0:W].astype(np.float32)
    # arco-íris holográfico: faixas diagonais que correm com o tempo, ondulando de leve
    hue = (0.9 * xx / W + 0.6 * yy / H + u + 0.04 * np.sin(yy / 37.0 + u * 6.28) + 0.03 * np.sin(xx / 23.0)) % 1.0
    arco = hsv_np(hue, 0.55, 1.0)
    # faixa de luz (reflexo) varrendo na diagonal
    dist = (xx / W * 0.7 + yy / H * 0.7) - (u * 2.2 - 0.5)
    faixa = np.exp(-(dist / 0.11) ** 2)
    lum = base.mean(axis=2)
    grao = (rng.random((H, W)) > 0.985).astype(np.float32) * 0.6        # purpurina fina
    forca = (0.17 + 0.6 * faixa) * (0.35 + 0.65 * lum ** 1.3) + grao * faixa
    camada = arco * forca[..., None]
    out = 1 - (1 - base) * (1 - camada)                                  # modo "tela" (screen)
    out = np.clip(out + faixa[..., None] * 0.10, 0, 1)
    img = Image.fromarray((out * 255).astype(np.uint8))
    d = ImageDraw.Draw(img)
    for (gx, gy, fase, tam) in glints:                                    # estrelinhas piscando
        a = max(0.0, np.sin((u + fase) * 2 * np.pi)) ** 6
        if a < 0.05:
            continue
        cx, cy, t = gx * W, gy * H, tam * (0.6 + 0.6 * a)
        cor = tuple(int(255 * v) for v in colorsys.hsv_to_rgb((fase + u) % 1, 0.25, 1.0))
        d.line((cx - t, cy, cx + t, cy), fill=cor, width=2)
        d.line((cx, cy - t, cx, cy + t), fill=cor, width=2)
        d.ellipse((cx - 2, cy - 2, cx + 2, cy + 2), fill=(255, 255, 255))
    img.save(os.path.join(OUT, f"q_{k:03d}.png"))
    print(k, flush=True)
subprocess.run(["ffmpeg", "-loglevel", "error", "-y", "-framerate", "24", "-i", os.path.join(OUT, "q_%03d.png"), "-vf",
                "scale=540:756:flags=lanczos", "-c:v", "libx264", "-crf", "20", "-pix_fmt", "yuv420p", "-movflags", "faststart",
                os.path.join(OUT, f"{cid}_foil.mp4")], check=True)
subprocess.run(["ffmpeg", "-loglevel", "error", "-y", "-framerate", "24", "-i", os.path.join(OUT, "q_%03d.png"), "-vf",
                "scale=360:504:flags=lanczos,split[a][b];[a]palettegen=max_colors=200[p];[b][p]paletteuse", os.path.join(OUT, f"{cid}_foil.gif")], check=True)
Image.open(os.path.join(OUT, "q_016.png")).save(os.path.join(OUT, f"{cid}_foil_previa.png"))
print("ok")
