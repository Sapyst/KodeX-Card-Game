"""Versos (fundos) de carta feitos por código, pixel art 128×180 (o dobro do verso nativo 64×90 da mesa).
Cada desenho é uma função de pixel (numpy) com paleta curta; saída em arte/versos/proc_<nome>.png e uma folha de prévia
ampliada 3× (NEAREST) em arte/versos/_previa_proc.png.
Uso: /mnt/d/Comfy-Desktop/venv/bin/python arte/versos/gerar_versos.py"""
import math, os, random
import numpy as np
from PIL import Image, ImageDraw

AQUI = os.path.dirname(os.path.abspath(__file__))
W, H = 128, 180
OURO = [(255, 227, 154), (226, 184, 90), (156, 116, 48), (96, 66, 24)]
ESCURO = (20, 12, 16)


def grade():
    y, x = np.mgrid[0:H, 0:W].astype(np.float32)
    return x, y


def moldura(img: np.ndarray, cor_fundo_borda, ouro=OURO, cantos=True):
    """Contorno escuro 1 px, faixa da cor da borda 3 px, filete dourado com luz em cima/esquerda e cantos recortados."""
    img[0, :] = img[-1, :] = ESCURO
    img[:, 0] = img[:, -1] = ESCURO
    img[1:4, 1:-1] = cor_fundo_borda
    img[-4:-1, 1:-1] = cor_fundo_borda
    img[1:-1, 1:4] = cor_fundo_borda
    img[1:-1, -4:-1] = cor_fundo_borda
    img[4, 5:-5] = ouro[0]; img[-5, 5:-5] = ouro[2]
    img[5:-5, 4] = ouro[1]; img[5:-5, -5] = ouro[2]
    if cantos:                                      # cantos em degrau (2 px) para a moldura parecer de metal
        for (cy, cx, dy, dx) in ((5, 5, 1, 1), (5, W - 6, 1, -1), (H - 6, 5, -1, 1), (H - 6, W - 6, -1, -1)):
            img[cy, cx] = ouro[1]
            img[cy + dy, cx] = ouro[0] if dy > 0 else ouro[2]
            img[cy, cx + dx] = ouro[0] if dx > 0 else ouro[2]


def codice():
    """Couro bordô com grão, filigrana dourada nos cantos e o selo do Códice (olho dentro do losango) no centro."""
    x, y = grade()
    rng = np.random.default_rng(3)
    grao = rng.random((H, W))
    base = np.array([74, 22, 30], np.float32)
    claro = np.array([104, 34, 42], np.float32)
    v = np.clip(0.35 + 0.4 * np.sin(x * 0.21 + y * 0.07) * np.sin(y * 0.17) + (grao - 0.5) * 0.5, 0, 1)
    img = (base + (claro - base) * v[..., None]).astype(np.uint8)
    # vinheta
    d = np.sqrt(((x - W / 2) / (W / 2)) ** 2 + ((y - H / 2) / (H / 2)) ** 2)
    img = (img * np.clip(1.15 - 0.45 * d, 0.55, 1.0)[..., None]).astype(np.uint8)
    moldura(img, (52, 14, 20))
    im = Image.fromarray(img)
    dr = ImageDraw.Draw(im)
    # filigrana dos cantos, sempre DENTRO do filete dourado (que fica a 4 px da borda): esquadro em L a 8 px, arco de
    # quarto de círculo voltado para dentro e uma voluta pequena; nada passa de x/y = 7
    for sx, sy in ((1, 1), (-1, 1), (1, -1), (-1, -1)):
        ox = 8 if sx > 0 else W - 9
        oy = 8 if sy > 0 else H - 9
        dr.line([(ox, oy), (ox + sx * 20, oy)], fill=OURO[1], width=1)
        dr.line([(ox, oy), (ox, oy + sy * 20)], fill=OURO[1], width=1)
        arco = [(ox + sx * 11 * math.sin(t / 20 * math.pi / 2), oy + sy * 11 * math.cos(t / 20 * math.pi / 2)) for t in range(21)]
        dr.line(arco, fill=OURO[2], width=1)
        volta = [(ox + sx * (5 + 3 * math.cos(t / 16 * math.tau)), oy + sy * (5 + 3 * math.sin(t / 16 * math.tau))) for t in range(17)]
        dr.line(volta, fill=OURO[0], width=1)
        dr.point((ox + sx * 5, oy + sy * 5), fill=OURO[0])
        dr.point((ox + sx * 22, oy), fill=OURO[0])
        dr.point((ox, oy + sy * 22), fill=OURO[0])
    cx, cy = W // 2, H // 2
    # losango duplo + olho
    for r, cor in ((34, OURO[3]), (32, OURO[1]), (27, OURO[2])):
        dr.polygon([(cx, cy - r), (cx + r * 0.72, cy), (cx, cy + r), (cx - r * 0.72, cy)], outline=cor)
    dr.ellipse((cx - 14, cy - 7, cx + 14, cy + 7), outline=OURO[0])
    dr.ellipse((cx - 5, cy - 5, cx + 5, cy + 5), fill=OURO[1], outline=OURO[3])
    dr.ellipse((cx - 2, cy - 2, cx + 2, cy + 2), fill=ESCURO)
    dr.point((cx + 1, cy - 1), fill=OURO[0])
    for k in range(12):                              # cílios/raios curtos em volta do olho
        a = k / 12 * math.tau
        dr.line([(cx + math.cos(a) * 18, cy + math.sin(a) * 11), (cx + math.cos(a) * 22, cy + math.sin(a) * 14)], fill=OURO[2])
    # linhas de costura do couro
    for yy in range(14, H - 14, 4):
        dr.point((9, yy), fill=(140, 70, 60)); dr.point((W - 10, yy), fill=(140, 70, 60))
    return im


def mandala():
    """Mandala sagrada em coordenadas polares: pétalas de 12 e 8 pontas, anéis e pontos; azul-petróleo e ouro."""
    x, y = grade()
    cx, cy = W / 2 - 0.5, H / 2 - 0.5
    dx, dy = x - cx, y - cy
    r = np.sqrt(dx * dx + dy * dy)
    a = np.arctan2(dy, dx)
    fundo = np.array([14, 52, 60], np.float32)
    img = np.zeros((H, W, 3), np.uint8)
    img[:] = fundo
    # padrão de fundo: losangos tênues
    m = ((x + y) % 8 < 1) | ((x - y) % 8 < 1)
    img[m] = (20, 66, 74)
    pet12 = np.abs(np.cos(a * 6)) * 10 + 34
    pet8 = np.abs(np.cos(a * 4)) * 8 + 18
    def faixa(mask, cor):
        img[mask] = cor
    faixa((r > pet12 - 1.2) & (r < pet12 + 0.2), OURO[1])
    faixa((r < pet12 - 1.2) & (r > pet8 + 1), (24, 84, 92))
    faixa((r > pet8 - 1.2) & (r < pet8 + 0.2), OURO[0])
    faixa(r < pet8 - 1.2, (10, 38, 46))
    for rr, cor in ((47, OURO[2]), (50, OURO[1]), (9, OURO[1]), (5, OURO[0])):
        faixa(np.abs(r - rr) < 0.6, cor)
    faixa(r < 3, (255, 240, 200))
    # pontos no anel externo (24) e pétalas internas (8)
    im = Image.fromarray(img)
    dr = ImageDraw.Draw(im)
    for k in range(24):
        t = k / 24 * math.tau
        px, py = cx + math.cos(t) * 54, cy + math.sin(t) * 54
        dr.point((round(px), round(py)), fill=OURO[0])
    for k in range(8):
        t = k / 8 * math.tau + math.pi / 8
        px, py = cx + math.cos(t) * 13, cy + math.sin(t) * 13
        dr.ellipse((px - 1, py - 1, px + 1, py + 1), fill=OURO[1])
    arr = np.asarray(im).copy()
    moldura(arr, (8, 34, 40))
    return Image.fromarray(arr)


def constelacao():
    """Céu noturno em degradê, estrelas sorteadas com 3 tamanhos, um triângulo de constelação e lua crescente."""
    x, y = grade()
    topo = np.array([8, 10, 34], np.float32)
    base = np.array([34, 18, 58], np.float32)
    t = (y / H)[..., None]
    img = (topo + (base - topo) * t).astype(np.uint8)
    rng = random.Random(11)
    im = Image.fromarray(img)
    dr = ImageDraw.Draw(im)
    # via láctea: faixa diagonal de poeira
    for k in range(420):
        u = rng.random()
        px = u * W
        py = H * 0.85 - u * H * 0.7 + rng.gauss(0, 9)
        c = rng.choice([(70, 60, 110), (90, 80, 140), (60, 70, 120)])
        dr.point((px, py), fill=c)
    for k in range(70):
        px, py = rng.randrange(6, W - 6), rng.randrange(6, H - 6)
        b = rng.random()
        if b > 0.93:
            dr.point((px, py), fill=(255, 250, 220))
            for ddx, ddy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                dr.point((px + ddx, py + ddy), fill=(170, 170, 210))
        else:
            dr.point((px, py), fill=(200, 200, 240) if b > 0.5 else (130, 130, 180))
    # constelação: triângulo com estrelas nos vértices e no meio
    pts = [(W // 2, 34), (26, 140), (W - 27, 140)]
    # lua crescente no centro do triângulo (baricentro); o disco vai 4 px para a direita porque o recorte tira o lado
    # direito: assim o crescente que sobra fica centrado no eixo. Desenhada ANTES das linhas (o recorte não as apaga).
    gx = sum(p[0] for p in pts) / 3
    gy = sum(p[1] for p in pts) / 3
    cx, cy = round(gx) + 4, round(gy)
    cor_ceu = tuple(int(v) for v in img[cy, cx])
    dr.ellipse((cx - 15, cy - 15, cx + 15, cy + 15), fill=(250, 236, 190))
    dr.ellipse((cx - 8, cy - 17, cx + 20, cy + 13), fill=cor_ceu)
    dr.line(pts + [pts[0]], fill=(120, 130, 200), width=1)
    for (px, py) in pts:
        dr.ellipse((px - 2, py - 2, px + 2, py + 2), fill=OURO[0])
    arr = np.asarray(im).copy()
    moldura(arr, (14, 12, 40))
    return Image.fromarray(arr)


def azulejo():
    """Azulejo português (herança luso-brasileira): ladrilhos de 32 px com quarto de círculo, flor central e cantos,
    cobalto sobre branco esmaltado; o desenho fecha quando 4 ladrilhos se encontram."""
    x, y = grade()
    tx, ty = (x - 0) % 32, (y - 2) % 32
    branco = np.array([236, 232, 220], np.float32)
    img = np.zeros((H, W, 3), np.uint8)
    img[:] = branco.astype(np.uint8)
    cob = (28, 62, 150)
    cob2 = (70, 110, 190)
    # quartos de círculo nos cantos de cada ladrilho → círculos completos nas junções
    def dist(px, py):
        return np.sqrt((tx - px) ** 2 + (ty - py) ** 2)
    for px, py in ((0, 0), (32, 0), (0, 32), (32, 32)):
        d = dist(px, py)
        img[(d > 9) & (d < 11)] = cob
        img[d < 5] = cob2
        img[(d > 13) & (d < 14)] = cob2
    dc = dist(16, 16)
    pet = np.abs(np.cos(np.arctan2(ty - 16, tx - 16) * 2)) * 6 + 3
    img[dc < pet] = cob
    img[dc < 2.2] = (220, 180, 70)
    # rejunte
    img[(tx < 0.8) | (ty < 0.8)] = (190, 186, 176)
    # leve craquelado
    rng = np.random.default_rng(5)
    ruido = rng.random((H, W)) < 0.012
    img[ruido] = (200, 196, 186)
    moldura(img, (28, 52, 120))
    return Image.fromarray(img)


def main():
    os.makedirs(AQUI, exist_ok=True)
    feitos = [("codice", codice()), ("mandala", mandala()), ("constelacao", constelacao()), ("azulejo", azulejo())]
    for nome, im in feitos:
        im.save(os.path.join(AQUI, f"proc_{nome}.png"))
    esc = 3
    folha = Image.new("RGB", (len(feitos) * (W * esc + 24) + 24, H * esc + 60), (13, 11, 18))
    d = ImageDraw.Draw(folha)
    for k, (nome, im) in enumerate(feitos):
        x0 = 24 + k * (W * esc + 24)
        folha.paste(im.resize((W * esc, H * esc), Image.NEAREST), (x0, 24))
        d.text((x0, H * esc + 32), nome, fill=(226, 184, 90))
    folha.save(os.path.join(AQUI, "_previa_proc.png"))
    print("ok", [n for n, _ in feitos])


if __name__ == "__main__":
    main()
