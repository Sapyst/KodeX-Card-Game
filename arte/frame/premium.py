"""Variante PREMIUM (carta especial): sai do pixel art de propósito — foil holográfico arco-íris no metal da moldura,
neon arco-íris contornando a carta e a janela, brilho diagonal suave na arte. Trabalha na resolução final (×3).
No jogo isso vira shader animado (o matiz desliza com o tempo); aqui é um quadro parado para avaliar o visual.
Uso: /mnt/d/Comfy-Desktop/venv/bin/python premium.py"""
import glob, os
import numpy as np
from PIL import Image, ImageFilter
import gerar_frame as G

S = G.ESC


def hsv(h, s, v):
    h = (h % 1.0) * 6; i = np.floor(h).astype(int) % 6; f = h - np.floor(h)
    p, q, t = v * (1 - s), v * (1 - s * f), v * (1 - s * (1 - f))
    r = np.choose(i, [v, q, p, p, t, v]); g = np.choose(i, [t, v, v, q, p, p]); b = np.choose(i, [p, p, t, v, v, q])
    return np.stack([r, g, b], -1)


def sd_box_np(X, Y, x0, y0, x1, y1, r):
    cx, cy = (x0 + x1 - 1) / 2, (y0 + y1 - 1) / 2; hx, hy = (x1 - x0 - 1) / 2, (y1 - y0 - 1) / 2
    qx, qy = np.abs(X - cx) - (hx - r), np.abs(Y - cy) - (hy - r)
    return np.hypot(np.maximum(qx, 0), np.maximum(qy, 0)) + np.minimum(np.maximum(qx, qy), 0) - r


def premium(carta_nativa, fase=0.0, janela=True):
    W, H = G.W * S, G.H * S
    base = np.asarray(carta_nativa.resize((W, H), Image.NEAREST)).astype(float) / 255
    rgb, alpha = base[..., :3], base[..., 3:]
    yy, xx = np.mgrid[0:H, 0:W]
    X, Y = (xx + 0.5) / S - 0.5, (yy + 0.5) / S - 0.5                # coordenadas em px nativos
    d_card = sd_box_np(X, Y, 0, 0, G.W, G.H, G.CARD_R); prof = -d_card
    x0, y0, x1, y1 = G.ART
    dentro_arte = (X >= x0 - 0.5) & (X < x1 - 0.5) & (Y >= y0 - 0.5) & (Y < y1 - 0.5)
    d_art = sd_box_np(X, Y, x0 - 1, y0 - 1, x1 + 1, y1 + 1, 2)
    ang = (np.arctan2(Y - G.H / 2, X - G.W / 2) / (2 * np.pi)) + fase

    # 1) foil holográfico no metal: banda externa, aro da janela, placa do nome
    nx0, ny0, nx1, ny1 = G.NOME
    if not janela:                                   # full art: não há janela, a arte ocupa todo o miolo
        dentro_arte = prof > G.BAND
        d_art = np.full_like(d_art, 99.0)
    metal = ((prof > 0) & (prof <= G.BAND)) | ((d_art > -0.5) & (d_art <= 4.5) & ~dentro_arte) | \
            ((X >= nx0) & (X < nx1) & (Y >= ny0) & (Y < ny1))
    diag = (X * 0.9 + Y * 0.55) / 70 + fase * 2
    foil = hsv(diag, 0.65, 1.0)
    lum = rgb.mean(-1, keepdims=True)
    tingido = np.clip(lum * 0.55 + foil * (0.35 + lum * 0.6), 0, 1)       # mantém o relevo do metal, troca a cor
    m = metal[..., None] * 0.78
    rgb = rgb * (1 - m) + tingido * m

    # 2) brilho diagonal na arte (faixa clara + leve arco-íris), bem sutil
    faixa = np.exp(-(((X - x0) - (Y - y0) * 0.55 - 70 - fase * 200) / 14) ** 2) * dentro_arte
    if not janela:                                   # holo leve espalhado pela arte toda (estilo full art)
        holo = hsv(diag * 1.6 + 0.2, 0.9, 1.0) * (0.05 + 0.05 * np.sin(X * 0.35 + Y * 0.2)[..., None])
        rgb = np.clip(rgb + holo * dentro_arte[..., None], 0, 1)
    rgb = np.clip(rgb + faixa[..., None] * (0.10 + 0.08 * hsv(diag + 0.3, 0.8, 1.0)), 0, 1)

    # 3) neon arco-íris: linha fina no meio da banda externa e em volta da janela + halo (glow)
    nucleo = np.exp(-((prof - G.BAND / 2) / 0.45) ** 2) * (prof > 0) + \
             np.exp(-((d_art - 2.0) / 0.45) ** 2) * (~dentro_arte)
    cor = hsv(ang * 2, 1.0, 1.0)
    luz_rgb = (nucleo[..., None] * cor * 255).astype(np.uint8)
    img = Image.fromarray(luz_rgb)
    halo = np.asarray(img.filter(ImageFilter.GaussianBlur(14))).astype(float) / 255 * 3.0 + \
           np.asarray(img.filter(ImageFilter.GaussianBlur(3))).astype(float) / 255 * 1.4
    rgb = 1 - (1 - rgb) * (1 - np.clip(halo, 0, 1))                       # screen
    rgb = np.clip(rgb * (1 - nucleo[..., None]) + nucleo[..., None] * (0.8 * cor + 0.2), 0, 1)    # núcleo saturado, um toque de branco

    out = np.concatenate([rgb, alpha], -1)
    # o halo vaza um pouco para fora da carta (fica bonito sobre fundo escuro)
    vaz = np.clip(halo.max(-1, keepdims=True) * 0.9, 0, 1) * (alpha == 0)
    out[..., :3] = np.where(alpha == 0, np.clip(halo, 0, 1), out[..., :3])
    out[..., 3:] = np.maximum(alpha, vaz)
    return Image.fromarray((out * 255).astype(np.uint8), "RGBA")


def carta_fullart(c, arte_path, cult):
    """Full art: a arte cobre a carta inteira (3:4 sobre 5:7 corta ~7 px de cada lado), painéis translúcidos por cima."""
    W, H, B = G.W, G.H, G.BAND
    tipo = c["tipo"]; lend = c.get("lendaria", False)
    base = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    a = Image.open(arte_path).convert("RGBA")
    ih = H - 2 * B; iw = round(a.width * ih / a.height)
    a = a.resize((iw, ih), Image.LANCZOS)
    base.alpha_composite(a.crop(((iw - (W - 2 * B)) // 2, 0, (iw - (W - 2 * B)) // 2 + W - 2 * B, ih)), (B, B))
    # moldura sem o fundo do miolo
    mold = Image.new("RGBA", (W, H), (0, 0, 0, 0)); G.moldura(mold, cult, lend); mp = mold.load()
    for y in range(H):
        for x in range(W):
            if -G.sd_box(x, y, 0, 0, W, H, G.CARD_R) > B:
                mp[x, y] = (0, 0, 0, 0)
    base.alpha_composite(mold)
    # painéis translúcidos (tipo, texto, status)
    pain = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    G.placa(pain, G.TIPO, G.TIPOS[tipo]["cor"], r=2, rebites=False); G.losango_tipo(pain, tipo)
    G.pergaminho(pain); G.faixa_status(pain, cult, tipo, lend); G.raridade(pain, lend)
    pp = pain.load()
    for y in range(H):
        for x in range(W):
            r, g, b, al = pp[x, y]
            if al and (r, g, b) != G.OUTL:
                pp[x, y] = (r, g, b, 200)
    base.alpha_composite(pain)
    metal = G.OURO if lend else G.CULT[cult]["metal"]
    G.placa(base, G.NOME, metal, r=4)
    if lend:
        G.coroa(base)
    G.numero_grande(base, G.colar_badge(base, G.gema_fe(), G.GEMA[:2]), str(c["custo"]))
    G.colar_badge(base, G.emblema(cult), G.EMBLEMA[:2])
    G.texto_central(base, G.NOME, c["nome"].upper().split(",")[0], (255, 246, 220), G.OUTL)
    rot = G.TIPOS[tipo]["rotulo"] + (" - LENDÁRIA" if lend else "")
    G.F.draw(base, G.TIPO[0] + 15, (G.TIPO[1] + G.TIPO[3]) // 2 - 3, rot, (255, 246, 230), G.OUTL)
    if tipo == "entidade":
        G.numero_grande(base, G.ATK_NUM, str(c["atk"])); G.numero_grande(base, G.VIDA_NUM, str(c["vida"]))
    G.texto_carta(base, c["texto"])
    return base


def main():
    escolhas = [("indigena", "ind_jaci"), ("cristianismo", "cri_elias"), ("taoismo", "tao_xiwangmu"), ("indigena", "ind_saci_perere")]
    lado = []
    for cult, cid in escolhas:
        arq = next(f for f in glob.glob(os.path.join(G.RAIZ, "cartas", cult, "[0-9][0-9]_*.md")) if G.ler_carta(f)["id"] == cid)
        c = G.ler_carta(arq)
        nat = G.carta(c, os.path.join(G.RAIZ, "arte", cult, cid + ".png"), cult); G.texto_carta(nat, c["texto"])
        pr = premium(nat, fase=0.08 * len(lado))
        pr.save(os.path.join(G.OUT, f"premium_{cid}.png"))
        lado.append((nat.resize((G.W * S, G.H * S), Image.NEAREST), pr))
    # comparação: normal × premium (2 cartas) e folha das 4 premium
    gap = 40
    comp = Image.new("RGBA", (G.W * S * 2 + gap * 3, G.H * S + gap * 2), (16, 14, 20, 255))
    comp.alpha_composite(lado[0][0], (gap, gap)); comp.alpha_composite(lado[0][1], (G.W * S + gap * 2, gap))
    comp.save(os.path.join(G.OUT, "premium_comparacao.png"))
    folha = Image.new("RGBA", (G.W * S * 4 + gap * 5, G.H * S + gap * 2), (16, 14, 20, 255))
    for i, (_, pr) in enumerate(lado):
        folha.alpha_composite(pr, (gap + i * (G.W * S + gap), gap))
    folha.resize((folha.width // 2, folha.height // 2), Image.LANCZOS).save(os.path.join(G.OUT, "premium_folha.png"))
    # full art holográfica
    fa = []
    for cult, cid in (("indigena", "ind_jaci"), ("taoismo", "tao_xiwangmu"), ("cristianismo", "cri_elias")):
        arq = next(f for f in glob.glob(os.path.join(G.RAIZ, "cartas", cult, "[0-9][0-9]_*.md")) if G.ler_carta(f)["id"] == cid)
        c = G.ler_carta(arq)
        im = premium(carta_fullart(c, os.path.join(G.RAIZ, "arte", cult, cid + ".png"), cult), fase=0.1 * len(fa), janela=False)
        im.save(os.path.join(G.OUT, f"fullart_{cid}.png")); fa.append(im)
    folha = Image.new("RGBA", (G.W * S * 3 + gap * 4, G.H * S + gap * 2), (16, 14, 20, 255))
    for i, im in enumerate(fa):
        folha.alpha_composite(im, (gap + i * (G.W * S + gap), gap))
    folha.resize((folha.width // 2, folha.height // 2), Image.LANCZOS).save(os.path.join(G.OUT, "fullart_folha.png"))
    print("ok")


if __name__ == "__main__":
    main()
