"""Logo KodeX v2 (referência do autor): "Kode" em serifa dourada pixel art com contorno preto e sombra azulada,
e um X grande de pincel seco preto em pixel art, inclinado, sobre o "e", com respingos.
Tudo desenhado numa grade pequena (1 px = 1 "pixel" da arte) e ampliado com vizinho mais próximo.
Saídas em arte/logo/v2/: logo_kodex_v2.png (transparente, ×10), logo_kodex_v2_4k.png (×20), previas."""
import math, os, random
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter

AQUI = os.path.dirname(os.path.abspath(__file__))
FONTE = os.environ.get("FONTE", "/usr/share/fonts/adobe-source-serif/SourceSerifPro-Black.otf")
GW, GH = 260, 140                       # grade da arte
rng = random.Random(23)

PRETO = (12, 10, 14)
SOMBRA = (78, 78, 108)
OURO = [(255, 240, 150), (247, 214, 74), (232, 186, 40), (196, 146, 26), (150, 104, 18)]
FAIXA_CLARA = (255, 226, 110)


def texto():
    """'Kode' rasterizado na grade, com degradê de ouro em faixas (luz em cima, faixa clara no meio, escuro embaixo)."""
    m = Image.new("L", (GW, GH), 0)
    d = ImageDraw.Draw(m)
    f = ImageFont.truetype(FONTE, int(os.environ.get('TAM', '48')))
    x0, y0 = 22, 22
    d.text((x0, y0), "Kode", font=f, fill=255)
    a = (np.asarray(m) > 110)
    ys, xs = np.nonzero(a)
    topo, base = ys.min(), ys.max()
    # topo da altura-x (o "o") para as faixas: K e d sobem acima dela
    cor = np.zeros((GH, GW, 3), np.uint8)
    for y in range(GH):
        for x in range(GW):
            if not a[y, x]:
                continue
            t = (y - topo) / max(1, base - topo)
            if t < 0.12:
                c = OURO[0]
            elif t < 0.42:
                c = OURO[1]
            elif t < 0.52:
                c = FAIXA_CLARA                 # faixa de brilho atravessando as letras
            elif t < 0.72:
                c = OURO[2]
            elif t < 0.88:
                c = OURO[3]
            else:
                c = OURO[4]
            if y > 0 and not a[y - 1, x]:
                c = OURO[0]                     # borda de cima pega luz
            elif x > 0 and not a[y, x - 1] and t < 0.6:
                c = tuple(min(255, v + 18) for v in c)
            cor[y, x] = c
    return a, cor


def pincel(alfa, cor, p0, p1, larg_max, seed, claro):
    """Traço de pincel: largura cresce do começo fino até ~60% e afina na ponta; bordas com falhas (cerdas);
    um filete de cinza escuro perto do eixo dá o brilho seco do pincel."""
    r = random.Random(seed)
    p0 = np.array(p0, float); p1 = np.array(p1, float)
    v = p1 - p0; L = np.linalg.norm(v); u = v / L; n = np.array([-u[1], u[0]])
    passos = int(L * 3)
    for i in range(passos):
        t = i / passos
        w = larg_max * (math.sin(min(1.0, t / 0.62) * math.pi / 2) if t < 0.62 else 1.0 - (t - 0.62) / 0.38 * 0.92)
        w = max(0.6, w)
        c = p0 + v * t
        for k in np.linspace(-w, w, int(w * 4) + 1):
            if abs(k) > w - 1.2 and r.random() < 0.35:
                continue                        # cerdas falhando na borda
            q = c + n * k
            x, y = int(round(q[0])), int(round(q[1]))
            if 0 <= x < GW and 0 <= y < GH:
                alfa[y, x] = True
                eixo = abs(k + w * 0.25) < max(0.8, w * 0.18)
                cor[y, x] = claro if eixo and 0.1 < t < 0.85 else PRETO


def x_tinta(cx, cy):
    """X centrado em (cx, cy): o traço longo e fino desce da direita para a esquerda; o curto e grosso desce
    da esquerda para a direita. Posicionado pelo fim do texto: cobre só a metade direita do "e"."""
    alfa = np.zeros((GH, GW), bool)
    cor = np.zeros((GH, GW, 3), np.uint8)
    # traço longo: de cima-direita até embaixo-esquerda (fino nas pontas)
    pincel(alfa, cor, (cx + 34, cy - 48), (cx - 34, cy + 47), 5.0, 1, (52, 52, 66))
    # traço curto e grosso: de cima-esquerda para baixo-direita
    pincel(alfa, cor, (cx - 21, cy - 27), (cx + 21, cy + 37), 9.0, 2, (60, 60, 76))
    # respingos
    for _ in range(90):
        ang = rng.uniform(0, math.tau)
        dist = rng.uniform(26, 50)
        x = int(cx + math.cos(ang) * dist * 1.05)
        y = int(cy + math.sin(ang) * dist * 0.95)
        tam = rng.choice([1, 1, 1, 1, 2])
        for dx in range(tam):
            for dy in range(tam):
                if 0 <= x + dx < GW and 0 <= y + dy < GH:
                    alfa[y + dy, x + dx] = True
                    cor[y + dy, x + dx] = PRETO
    return alfa, cor


def x_v1(alt_px: int):
    """O X da logo v1 (pincel seco de gerar_logo.py, aprovado), recolorido: onde a tinta acumula fica preto e
    nas cerdas secas/bordas um cinza-azulado; depois reduzido para a grade da arte (alt_px de altura) em 4 tons."""
    import sys
    sys.path.insert(0, os.path.dirname(AQUI))
    import gerar_logo as V1
    xi = V1.x_de_tinta()
    a = np.asarray(xi.split()[3]).astype(np.float32) / 255
    r = np.asarray(xi.split()[0]).astype(np.float32)
    dens = np.clip((r - 40) / 150, 0, 1)                # v1: vermelho = tinta acumulada
    bb = xi.getbbox()
    x0, y0, x1, y1 = bb
    a = a[y0:y1, x0:x1]; dens = dens[y0:y1, x0:x1]
    k = alt_px / (y1 - y0)
    w, h = max(1, int((x1 - x0) * k)), alt_px
    A = np.asarray(Image.fromarray((a * 255).astype(np.uint8)).resize((w, h), Image.BOX)).astype(np.float32) / 255
    D = np.asarray(Image.fromarray((dens * 255).astype(np.uint8)).resize((w, h), Image.BOX)).astype(np.float32) / 255
    mask = A > 0.42
    tons = [(64, 64, 84), (40, 40, 54), (22, 20, 28), (10, 9, 13)]   # seco → acumulado
    idx = np.clip((D * 0.7 + A * 0.5 - 0.35) * 4.2, 0, 3).astype(int)
    cor = np.zeros((h, w, 3), np.uint8)
    for i, t in enumerate(tons):
        cor[(idx == i) & mask] = t
    return mask, cor


def compor():
    a_t, c_t = texto()
    ys, xs = np.nonzero(a_t)
    m_x, cor_x = x_v1(int(os.environ.get("ALT_X", "104")))
    hx, wx = m_x.shape
    cx = int(xs.max()) + int(os.environ.get("DX", "8"))
    cy = int((ys.min() + ys.max()) / 2) + 4
    ox, oy = cx - wx // 2, cy - hx // 2
    a_x = np.zeros((GH, GW), bool)
    c_x = np.zeros((GH, GW, 3), np.uint8)
    for y in range(hx):
        for x in range(wx):
            gy, gx = y + oy, x + ox
            if m_x[y, x] and 0 <= gy < GH and 0 <= gx < GW:
                a_x[gy, gx] = True
                c_x[gy, gx] = cor_x[y, x]
    perto_letras = np.asarray(Image.fromarray(a_t.astype(np.uint8) * 255).filter(ImageFilter.MaxFilter(5))) > 0
    traco = np.asarray(Image.fromarray(a_x.astype(np.uint8) * 255).filter(ImageFilter.MinFilter(3))) > 0
    nucleo = np.asarray(Image.fromarray(traco.astype(np.uint8) * 255).filter(ImageFilter.MaxFilter(7))) > 0
    a_x = a_x & ~(perto_letras & ~nucleo)        # respingo isolado em cima/encostado nas letras some
    img = np.zeros((GH, GW, 4), np.uint8)
    def pinta(mask, rgb):
        img[mask, :3] = rgb
        img[mask, 3] = 255
    # sombra (texto + X), 1 px direita / 2 px baixo
    som = np.zeros((GH, GW), bool)
    contorno_t = np.asarray(Image.fromarray(a_t.astype(np.uint8) * 255).filter(ImageFilter.MaxFilter(3))) > 0
    for m in (contorno_t, a_x):
        sh = np.zeros_like(m); sh[2:, 1:] = m[:-2, :-1]
        som |= sh
    pinta(som, SOMBRA)
    pinta(contorno_t, PRETO)                   # contorno preto de 1 px nas letras
    img[a_t, :3] = c_t[a_t]; img[a_t, 3] = 255
    img[a_x, :3] = c_x[a_x]; img[a_x, 3] = 255  # o X vem por cima do "e"
    out = Image.fromarray(img, "RGBA")
    return out.crop(out.getbbox())


def x_v1_hd():
    """O X da logo v1 (pincel seco aprovado) em alta resolução, recolorido: tinta acumulada preta, cerdas secas e
    bordas em cinza-azulado escuro. Devolve RGBA recortado no conteúdo."""
    import sys
    sys.path.insert(0, os.path.dirname(AQUI))
    import gerar_logo as V1
    V1.H, V1.X_CY = 1000, 480                  # tela maior: as pontas do X não são cortadas
    V1.W = 2300                                # espaço à direita para os respingos lançados no fim do traço
    V1.RESPINGO = "traco"
    xi = V1.x_de_tinta()
    xi = xi.crop(xi.getbbox())
    arr = np.asarray(xi).astype(np.float32)
    a = arr[..., 3] / 255
    dens = np.clip((arr[..., 0] - 40) / 150, 0, 1)      # v1: quanto mais vermelho, mais tinta acumulada
    seco = np.array([74, 74, 96], np.float32)
    cheio = np.array([10, 9, 13], np.float32)
    rgb = seco + (cheio - seco) * (dens[..., None] ** 0.6)
    out = np.dstack([rgb, a * 255]).astype(np.uint8)
    return Image.fromarray(out, "RGBA")


def compor_hd(esc: int) -> Image.Image:
    """Letras em pixel art (×esc) + X de pincel liso por cima do "e", com sombra azulada deslocada."""
    a_t, c_t = texto()
    img = np.zeros((GH, GW, 4), np.uint8)
    contorno = np.asarray(Image.fromarray(a_t.astype(np.uint8) * 255).filter(ImageFilter.MaxFilter(3))) > 0
    som = np.zeros_like(contorno); som[2:, 1:] = contorno[:-2, :-1]
    img[som, :3] = SOMBRA; img[som, 3] = 255
    img[contorno, :3] = PRETO; img[contorno, 3] = 255
    img[a_t, :3] = c_t[a_t]; img[a_t, 3] = 255
    letras = Image.fromarray(img, "RGBA")
    ys, xs = np.nonzero(a_t)
    alt_txt = (ys.max() - ys.min()) * esc
    xh = x_v1_hd()
    alvo = int(alt_txt * float(os.environ.get("X_ALT", "2.05")))
    xh = xh.resize((int(xh.width * alvo / xh.height), alvo), Image.LANCZOS)
    cx = int((xs.max() + float(os.environ.get("X_DX", "17"))) * esc)
    cy = int(((ys.min() + ys.max()) / 2 + float(os.environ.get("X_DY", "8.5"))) * esc)
    W2 = max(GW * esc, cx + xh.width // 2 + 40)
    folga = max(0, xh.height // 2 - cy + 40)                    # espaço em cima para o X não ser cortado
    H2 = max(GH * esc, cy + xh.height // 2 + 40) + folga
    tela = Image.new("RGBA", (W2, H2), (0, 0, 0, 0))
    tela.alpha_composite(letras.resize((GW * esc, GH * esc), Image.NEAREST), (0, folga))
    cy += folga
    sombra = Image.new("RGBA", xh.size, SOMBRA + (0,))
    sombra.putalpha(xh.split()[3])
    pos = (cx - xh.width // 2, cy - xh.height // 2)
    tela.alpha_composite(sombra, (pos[0] + esc, pos[1] + 2 * esc))
    tela.alpha_composite(xh, pos)
    return tela.crop(tela.getbbox())


def main():
    for esc, nome in ((10, "logo_kodex_v2.png"), (20, "logo_kodex_v2_4k.png")):
        compor_hd(esc).save(os.path.join(AQUI, nome))
    # versão para fundo escuro: contorno claro (pergaminho) de 6 px em volta do conjunto, por trás de tudo
    for nome in ("logo_kodex_v2.png", "logo_kodex_v2_4k.png"):
        im = Image.open(os.path.join(AQUI, nome))
        e = 6 if "4k" not in nome else 12
        al = im.split()[3].point(lambda v: 255 if v > 60 else 0).filter(ImageFilter.MaxFilter(2 * e + 1))
        aro = Image.new("RGBA", im.size, (232, 220, 196, 0)); aro.putalpha(al.filter(ImageFilter.GaussianBlur(1)))
        aro.alpha_composite(im)
        aro.save(os.path.join(AQUI, nome.replace(".png", "_fundo_escuro.png")))
    esc_img = Image.open(os.path.join(AQUI, "logo_kodex_v2_fundo_escuro.png"))
    p = Image.new("RGBA", (esc_img.width + 240, esc_img.height + 240), (13, 11, 18, 255))
    p.alpha_composite(esc_img, (120, 120))
    p.convert("RGB").save(os.path.join(AQUI, "previa_escuro_contorno.png"))
    grande = Image.open(os.path.join(AQUI, "logo_kodex_v2.png"))
    for nome, fundo in (("claro", (250, 250, 250)), ("escuro", (13, 11, 18))):
        p = Image.new("RGBA", (grande.width + 240, grande.height + 240), fundo + (255,))
        p.alpha_composite(grande, (120, 120))
        p.convert("RGB").save(os.path.join(AQUI, f"previa_{nome}.png"))
    print("ok", grande.size)


if __name__ == "__main__":
    main()
