"""Ícone do app no estilo da logo v2: "K" em serifa dourada pixel art (mesmo degradê, contorno preto e sombra azulada)
com o X de pincel seco preto da v1 cruzando à direita, aro claro de pergaminho em volta do X para ler no fundo escuro.
Saídas em godot/: icon.png (192, completo com fundo e moldura), icon_432.png (primeiro plano adaptativo, conteúdo
dentro dos 66% centrais) e icon_fundo_432.png (fundo adaptativo: roxo escuro com luz de vela)."""
import os
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import gerar_logo_v2 as L

AQUI = os.path.dirname(os.path.abspath(__file__))
GODOT = os.path.join(AQUI, "..", "..", "..", "godot")
G = 48                                   # grade do K (1 px = 1 pixel da arte)


def k_pixel():
    m = Image.new("L", (G, G), 0)
    d = ImageDraw.Draw(m)
    f = ImageFont.truetype(L.FONTE, 40)
    d.text((5, -6), "K", font=f, fill=255)
    a = np.asarray(m) > 110
    ys, xs = np.nonzero(a)
    topo, base = ys.min(), ys.max()
    cor = np.zeros((G, G, 3), np.uint8)
    for y, x in zip(ys, xs):
        t = (y - topo) / max(1, base - topo)
        c = L.OURO[0] if t < 0.12 else L.OURO[1] if t < 0.42 else L.FAIXA_CLARA if t < 0.52 else \
            L.OURO[2] if t < 0.72 else L.OURO[3] if t < 0.88 else L.OURO[4]
        if y > 0 and not a[y - 1, x]:
            c = L.OURO[0]
        cor[y, x] = c
    img = np.zeros((G, G, 4), np.uint8)
    contorno = np.asarray(Image.fromarray(a.astype(np.uint8) * 255).filter(ImageFilter.MaxFilter(3))) > 0
    som = np.zeros_like(contorno); som[2:, 1:] = contorno[:-2, :-1]
    img[som, :3] = L.SOMBRA; img[som, 3] = 255
    img[contorno, :3] = L.PRETO; img[contorno, 3] = 255
    img[a, :3] = cor[a]; img[a, 3] = 255
    im = Image.fromarray(img, "RGBA")
    return im.crop(im.getbbox())


def x_com_aro(alt: int, aro: int):
    xh = L.x_v1_hd()
    xh = xh.resize((int(xh.width * alt / xh.height), alt), Image.LANCZOS)
    al = xh.split()[3].point(lambda v: 255 if v > 60 else 0).filter(ImageFilter.MaxFilter(2 * aro + 1))
    out = Image.new("RGBA", (xh.width + 4 * aro, xh.height + 4 * aro), (0, 0, 0, 0))
    rim = Image.new("RGBA", xh.size, (232, 220, 196, 0)); rim.putalpha(al.filter(ImageFilter.GaussianBlur(0.6)))
    out.alpha_composite(rim, (2 * aro, 2 * aro))
    out.alpha_composite(xh, (2 * aro, 2 * aro))
    return out.crop(out.getbbox())


def primeiro_plano(lado: int) -> Image.Image:
    """K + X num quadrado `lado` (transparente)."""
    k = k_pixel()
    esc = max(1, int(lado * 0.62 / k.height))
    kk = k.resize((k.width * esc, k.height * esc), Image.NEAREST)
    x = x_com_aro(int(lado * 0.70), max(2, lado // 64))
    tela = Image.new("RGBA", (lado, lado), (0, 0, 0, 0))
    kx = (lado - kk.width) // 2 - int(lado * 0.17)
    ky = (lado - kk.height) // 2
    tela.alpha_composite(kk, (kx, ky))
    tela.alpha_composite(x, (kx + kk.width - x.width // 2 + int(lado * 0.13), ky + kk.height // 2 - x.height // 2 + int(lado * 0.04)))
    return tela


def fundo(lado: int) -> Image.Image:
    y, x = np.mgrid[0:lado, 0:lado].astype(np.float32) / lado
    d = np.sqrt((x - 0.5) ** 2 + (y - 0.38) ** 2)
    luz = np.clip(1.0 - d * 1.6, 0, 1) ** 1.6
    base = np.array([13, 11, 18], np.float32)
    vela = np.array([70, 44, 34], np.float32)
    rgb = base + (vela - base) * luz[..., None]
    return Image.fromarray(np.dstack([rgb, np.full((lado, lado), 255, np.float32)]).astype(np.uint8), "RGBA")


def main():
    # ícone completo 192: fundo + moldura dourada arredondada + K/X
    lado = 192
    ic = fundo(lado)
    d = ImageDraw.Draw(ic)
    d.rounded_rectangle((8, 8, lado - 9, lado - 9), radius=22, outline=(226, 184, 90, 255), width=6)
    d.rounded_rectangle((14, 14, lado - 15, lado - 15), radius=17, outline=(20, 14, 16, 255), width=2)
    ic.alpha_composite(primeiro_plano(150), (21, 21))
    ic.save(os.path.join(GODOT, "icon.png"))
    # adaptativo: conteúdo nos 66% centrais (288 de 432); fundo separado
    fg = Image.new("RGBA", (432, 432), (0, 0, 0, 0))
    fg.alpha_composite(primeiro_plano(288), (72, 72))
    fg.save(os.path.join(GODOT, "icon_432.png"))
    fundo(432).save(os.path.join(GODOT, "icon_fundo_432.png"))
    # prévia: ícone + máscara redonda do Android
    p = Image.new("RGBA", (192 * 2 + 30, 192), (40, 40, 40, 255))
    p.alpha_composite(ic, (0, 0))
    ad = fundo(432); ad.alpha_composite(fg)
    ad = ad.resize((192, 192), Image.LANCZOS)
    mask = Image.new("L", (192, 192), 0); ImageDraw.Draw(mask).ellipse((0, 0, 191, 191), fill=255)
    p.paste(ad, (222, 0), mask)
    p.save(os.path.join(AQUI, "previa_icone.png"))
    print("ok")


if __name__ == "__main__":
    main()
