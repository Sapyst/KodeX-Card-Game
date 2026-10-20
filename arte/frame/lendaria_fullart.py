"""Frame LENDÁRIO full-art (protótipo): a arte cobre quase a carta toda; borda de foil escuro com reflexo arco-íris;
degradê escuro só onde há texto; nome, tipo, custo, ATK e DEF em serifa grossa (Source Serif 4 Display Black) com
preenchimento foil; descrição em serifa regular branca. Gera quadros animados (o foil corre e um reflexo varre).
Uso: python lendaria_fullart.py <arte.png> <id> <deck>  → arte/_foil_teste/lend_<id>.mp4/.gif/_previa.png"""
import glob, os, subprocess, sys
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageChops

AQUI = os.path.dirname(os.path.abspath(__file__))
RAIZ = os.path.dirname(os.path.dirname(AQUI))
sys.path.insert(0, AQUI)
import gerar_frame_v2 as F2

W, H, BORDA, RAIO = 720, 1008, 18, 30
SERIF_BLACK = "/usr/share/fonts/adobe-source-serif/SourceSerif4Display-Black.otf"
SERIF_BOLD = "/usr/share/fonts/adobe-source-serif/SourceSerif4Display-Bold.otf"
SERIF = "/usr/share/fonts/adobe-source-serif/SourceSerif4-Regular.otf"
SERIF_IT = "/usr/share/fonts/adobe-source-serif/SourceSerif4-It.otf"
N = 48
ESTILO = os.environ.get("CUSTO_ESTILO", "A")
TIPO = {"entidade": "ENTIDADE", "selo": "SELO", "rito": "RITO", "reliquia": "RELÍQUIA"}
CULT = {"indigena": "INDÍGENA", "cristianismo": "CRISTIANISMO", "taoismo": "TAOISMO", "hinduismo": "HINDUÍSMO",
        "bruxaria": "BRUXARIA", "alta_magia": "ALTA MAGIA"}
KW = {"guarda": "GUARDA", "impeto": "ÍMPETO", "furtivo": "FURTIVO", "renascer": "RENASCER"}


def f(p, s):
    return ImageFont.truetype(p, s)


def hsv(h, s, v):
    i = np.floor(h * 6).astype(int) % 6
    fr = h * 6 - np.floor(h * 6)
    p, q, t = v * (1 - s), v * (1 - fr * s), v * (1 - (1 - fr) * s)
    return np.dstack([np.choose(i, [v, q, p, p, t, v]), np.choose(i, [t, v, v, q, p, p]), np.choose(i, [p, p, t, v, v, q])])


def foil(u, escuro):
    """Textura foil 720×1008: arco-íris em faixas diagonais + reflexo varrendo. `escuro`: foil preto (borda)."""
    yy, xx = np.mgrid[0:H, 0:W].astype(np.float32)
    hue = (0.8 * xx / W + 0.55 * yy / H + u + 0.05 * np.sin(yy / 41 + u * 6.28) + 0.04 * np.sin(xx / 29)) % 1
    d = (xx / W * 0.75 + yy / H * 0.65) - (u * 2.3 - 0.6)
    faixa = np.exp(-(d / 0.09) ** 2)
    metal = 0.5 + 0.5 * np.sin((xx * 0.6 + yy) / 9.0)            # micro-ondulação metálica
    if escuro:
        v = 0.13 + 0.22 * faixa + 0.07 * metal
        s = 0.55 + 0.25 * (1 - faixa)
    else:
        v = 0.78 + 0.22 * faixa
        s = 0.42 - 0.25 * faixa
    rgb = hsv(hue, s, v)
    rgb += faixa[..., None] * (0.25 if escuro else 0.35)
    return Image.fromarray((np.clip(rgb, 0, 1) * 255).astype(np.uint8))


def mascara_texto(xy, txt, fonte, anchor="la"):
    m = Image.new("L", (W, H), 0)
    ImageDraw.Draw(m).text(xy, txt, font=fonte, fill=255, anchor=anchor)
    return m


def texto_foil(im, tex_claro, xy, txt, fonte, anchor="la", contorno=4):
    """Texto com preenchimento foil (arco-íris metálico claro), contorno escuro e sombra."""
    m = mascara_texto(xy, txt, fonte, anchor)
    borda = m.filter(ImageFilter.MaxFilter(contorno * 2 + 1))
    sombra = borda.filter(ImageFilter.GaussianBlur(6))
    im.paste(Image.new("RGB", (W, H), (0, 0, 0)), (4, 6), sombra.point(lambda v: int(v * 0.8)))
    im.paste(Image.new("RGB", (W, H), (10, 8, 14)), (0, 0), borda)
    im.paste(tex_claro, (0, 0), m)


def texto_foil_em(im, tex_claro, centro, txt, fonte, lado="m", contorno=4):
    """Posiciona pelo desenho real das letras (bbox), não pela métrica da fonte: o meio vertical do texto fica
    exatamente em centro.y; lado = "l" (borda esquerda em x), "m" (centro em x) ou "r" (borda direita em x)."""
    x0, y0, x1, y1 = ImageDraw.Draw(Image.new("L", (1, 1))).textbbox((0, 0), txt, font=fonte, anchor="la")
    cx, cy = centro
    px = cx - x0 if lado == "l" else (cx - x1 if lado == "r" else cx - (x0 + x1) / 2)
    py = cy - (y0 + y1) / 2
    texto_foil(im, tex_claro, (px, py), txt, fonte, "la", contorno)


def ceu(cid):
    """Estrelas, brilhos e poeira de luz fixos por carta (semente do id), para animar em loop sobre a arte."""
    r = np.random.default_rng(int.from_bytes(cid.encode(), "little") % (2 ** 32))
    est = [(r.uniform(BORDA + 8, W - BORDA - 8), BORDA + 10 + (H * 0.62) * r.uniform(0, 1) ** 1.7, r.uniform(0.8, 2.2),
            r.uniform(0, 1), int(r.integers(1, 3))) for _ in range(85)]
    bri = [(r.uniform(BORDA + 30, W - BORDA - 30), BORDA + 30 + (H * 0.55) * r.uniform(0, 1) ** 1.3, r.uniform(7, 15),
            r.uniform(0, 1)) for _ in range(9)]
    poe = [(r.uniform(BORDA + 10, W - BORDA - 10), r.uniform(0, 1), r.uniform(1.2, 2.6), r.uniform(0, 1)) for _ in range(28)]
    return est, bri, poe


def desenhar_ceu(im, u, est, bri, poe):
    """Camada aditiva: 85 estrelas piscando (mais no alto), 9 brilhos de 4 pontas, 28 partículas de luz subindo."""
    cam = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(cam)
    for x, y, t, fase, vel in est:
        a = 0.25 + 0.75 * max(0.0, np.sin(2 * np.pi * (u * vel + fase))) ** 2
        cor = (225, 235, 255, int(255 * a))
        d.ellipse((x - t, y - t, x + t, y + t), fill=cor)
    for x, y, tam, fase in bri:
        a = max(0.0, np.sin(2 * np.pi * (u + fase))) ** 6
        if a < 0.04:
            continue
        L = tam * (0.5 + 0.7 * a)
        cor = (255, 250, 230, int(255 * a))
        d.line((x - L, y, x + L, y), fill=cor, width=2)
        d.line((x, y - L, x, y + L), fill=cor, width=2)
        d.line((x - L * 0.4, y - L * 0.4, x + L * 0.4, y + L * 0.4), fill=(255, 250, 230, int(160 * a)), width=1)
        d.line((x - L * 0.4, y + L * 0.4, x + L * 0.4, y - L * 0.4), fill=(255, 250, 230, int(160 * a)), width=1)
        d.ellipse((x - 3, y - 3, x + 3, y + 3), fill=(255, 255, 255, int(255 * a)))
    for x, y0, t, fase in poe:
        y = H - BORDA - ((y0 + u) % 1.0) * (H - 2 * BORDA)               # sobe a tela inteira uma vez por loop
        a = 0.5 * np.sin(np.pi * ((y0 + u) % 1.0))
        xx = x + 6 * np.sin(2 * np.pi * (u + fase))
        d.ellipse((xx - t, y - t, xx + t, y + t), fill=(255, 220, 140, int(255 * a)))
    brilho = cam.filter(ImageFilter.GaussianBlur(3))
    base = im.convert("RGBA")
    base.alpha_composite(brilho)
    base.alpha_composite(cam)
    return base.convert("RGB")


def quebrar(d, txt, fonte, larg):
    linhas, atual = [], ""
    for p in txt.split():
        t = (atual + " " + p).strip()
        if d.textlength(t, font=fonte) <= larg:
            atual = t
        else:
            linhas.append(atual); atual = p
    if atual:
        linhas.append(atual)
    return linhas


def main():
    arte, cid, deck = sys.argv[1], sys.argv[2], sys.argv[3]
    ficha = next(x for x in glob.glob(os.path.join(RAIZ, "cartas", deck, "[0-9][0-9]_*.md")) if f'"id": "{cid}"' in open(x, encoding="utf-8").read())
    c = F2.ler_carta(ficha)
    global TIPO, CULT, KW
    en_modo = os.environ.get("IDIOMA", "pt") == "en"
    if en_modo:                                       # versão em inglês: nome/texto de cartas_en.json e rótulos EN
        import json as _j
        en = _j.load(open(os.path.join(RAIZ, "godot", "dados", "cartas_en.json"), encoding="utf-8"))["cartas"].get(cid, {})
        c["nome"], c["texto"] = en.get("nome", c["nome"]), en.get("texto", c["texto"])
        TIPO = {"entidade": "ENTITY", "selo": "SEAL", "rito": "RITE", "reliquia": "RELIC"}
        CULT = {"indigena": "INDIGENOUS", "cristianismo": "CHRISTIANITY", "taoismo": "TAOISM", "hinduismo": "HINDUISM",
                "bruxaria": "WITCHCRAFT", "alta_magia": "HIGH MAGIC"}
        KW = {"guarda": "GUARD", "impeto": "RUSH", "furtivo": "STEALTH", "renascer": "REBIRTH"}
    OUT = os.path.join(RAIZ, "arte", "_foil_teste", "lend_" + cid + ("" if ESTILO == "A" else "_" + ESTILO) + ("_en" if en_modo else ""))
    os.makedirs(OUT, exist_ok=True)
    # arte cobrindo a carta inteira (corte "cover"), cantos arredondados por dentro da borda
    a = Image.open(arte).convert("RGB")
    aw, ah = W - 2 * BORDA, H - 2 * BORDA
    k = max(aw / a.width, ah / a.height)
    a = a.resize((round(a.width * k), round(a.height * k)), Image.LANCZOS)
    a = a.crop(((a.width - aw) // 2, (a.height - ah) // 2, (a.width - aw) // 2 + aw, (a.height - ah) // 2 + ah))
    mask_arte = Image.new("L", (aw, ah), 0)
    ImageDraw.Draw(mask_arte).rounded_rectangle((0, 0, aw - 1, ah - 1), RAIO - 10, fill=255)
    # degradês escuros: topo (nome) e base (tipo, texto, números)
    grad = np.zeros((H, W), np.float32)
    yy = np.arange(H, dtype=np.float32)[:, None]
    grad = np.maximum(grad, np.clip((150 - yy) / 134, 0, 1) ** 1.4 * 0.8)
    grad = np.maximum(grad, np.clip((yy - 600) / 260, 0, 1) ** 1.2 * 0.94)
    grad_img = Image.fromarray((grad * 255).astype(np.uint8))
    mask_borda = Image.new("L", (W, H), 0)
    dm = ImageDraw.Draw(mask_borda)
    dm.rounded_rectangle((0, 0, W - 1, H - 1), RAIO, fill=255)
    dm.rounded_rectangle((BORDA, BORDA, W - 1 - BORDA, H - 1 - BORDA), RAIO - 10, fill=0)
    nome_f = f(SERIF_BLACK, 50)
    tipo_f = f(SERIF_BLACK, 24)
    num_f = f(SERIF_BLACK, 92)
    rot_f = f(SERIF_BOLD, 22)
    txt_f = f(SERIF, 27)
    kws = [KW[k] for k in c.get("keywords", [])]
    est, bri, poe = ceu(cid)
    tipo_txt = "  ·  ".join([TIPO[c["tipo"]], CULT.get(deck, deck.upper()), "LEGENDARY" if en_modo else "LENDÁRIA"])
    texto = c["texto"]
    for q in range(int(os.environ.get("QUADROS", N))):
        u = q / N
        escuro = foil(u, True)
        claro = foil(u + 0.15, False)
        im = Image.new("RGB", (W, H), (0, 0, 0))
        im.paste(a, (BORDA, BORDA), mask_arte)
        im = desenhar_ceu(im, u, est, bri, poe)                    # estrelas e brilhos por cima da arte, sob o texto
        im.paste(Image.new("RGB", (W, H), (6, 4, 9)), (0, 0), grad_img)
        # borda foil escura + filetes
        im.paste(escuro, (0, 0), mask_borda)
        d = ImageDraw.Draw(im)
        d.rounded_rectangle((BORDA - 2, BORDA - 2, W - BORDA + 1, H - BORDA + 1), RAIO - 8, outline=(8, 6, 10), width=3)
        lin = Image.new("L", (W, H), 0)
        ImageDraw.Draw(lin).rounded_rectangle((BORDA + 2, BORDA + 2, W - BORDA - 3, H - BORDA - 3), RAIO - 12, outline=150, width=2)
        im.paste(claro, (0, 0), lin)
        # custo (estilo A/B/C, ver CUSTO_ESTILO)
        cx, cy = 74, 74
        x_nome = 134
        if ESTILO == "B":
            r = 50
            gema = Image.new("L", (W, H), 0)
            ImageDraw.Draw(gema).polygon([(cx, cy - r), (cx + r, cy), (cx, cy + r), (cx - r, cy)], fill=255)
            im.paste(Image.new("RGB", (W, H), (0, 0, 0)), (3, 5), gema.filter(ImageFilter.GaussianBlur(8)))
            im.paste(escuro, (0, 0), gema)
            aro = Image.new("L", (W, H), 0)
            ImageDraw.Draw(aro).polygon([(cx, cy - r), (cx + r, cy), (cx, cy + r), (cx - r, cy)], outline=255, width=4)
            im.paste(claro, (0, 0), aro)
            texto_foil_em(im, claro, (cx, cy), str(c["custo"]), f(SERIF_BLACK, 56), "m", 3)
            x_nome = 140
        elif ESTILO == "C":
            texto_foil_em(im, claro, (cx - 6, cy - 6), str(c["custo"]), num_f, "m", 4)
            texto_foil_em(im, claro, (cx - 6, cy + 44), "FÉ", rot_f, "m", 2)
            x_nome = 132
        else:
            texto_foil_em(im, claro, (cx - 10, cy), str(c["custo"]), num_f, "m", 4)
            fil = Image.new("L", (W, H), 0)
            ImageDraw.Draw(fil).line((cx + 34, cy - 34, cx + 34, cy + 34), fill=200, width=2)
            im.paste(claro, (0, 0), fil)
            x_nome = 126
        # nome
        # nome: encolhe a fonte até caber entre o custo e a borda direita (mínimo 30 px)
        tam_nome = 50
        larg_max = W - BORDA - 28 - x_nome
        medidor = ImageDraw.Draw(Image.new("L", (1, 1)))
        while tam_nome > 30 and medidor.textlength(c["nome"], font=f(SERIF_BLACK, tam_nome)) > larg_max:
            tam_nome -= 2
        texto_foil_em(im, claro, (x_nome, cy), c["nome"], f(SERIF_BLACK, tam_nome), "l", 4)
        # tipo (+ palavras-chave) em serifa grossa foil
        y_tipo = 724
        texto_foil(im, claro, (W // 2, y_tipo), tipo_txt, tipo_f, "mm", 3)
        dl = ImageDraw.Draw(im)
        dl.line((70, y_tipo + 24, W - 70, y_tipo + 24), fill=(150, 140, 160), width=1)
        # descrição branca
        y = y_tipo + 42
        corpo = texto.replace("Lendária. ", "").replace("Lendária.", "").replace("Legendary. ", "").replace("Legendary.", "")        # a linha de tipo já diz LENDÁRIA
        for kw in kws:
            corpo = corpo.replace(kw.capitalize() + ". ", "").replace(kw.capitalize() + ".", "")
            corpo = corpo.replace(kw.title() + ". ", "").replace(kw.title() + ".", "")
        if kws:
            texto_foil(im, claro, (W // 2, y + 12), "  ·  ".join(kws), f(SERIF_BLACK, 26), "mm", 3)
            y += 34
        for ln in quebrar(dl, corpo.strip(), txt_f, W - 150):
            dl.text((W // 2 + 2, y + 2), ln, font=txt_f, fill=(0, 0, 0), anchor="ma")
            dl.text((W // 2, y), ln, font=txt_f, fill=(244, 240, 232), anchor="ma")
            y += 34
        # ATK e DEF
        if c["tipo"] == "entidade":
            y_num = H - BORDA - 62                       # meio dos números: 62 px acima da borda de baixo
            texto_foil_em(im, claro, (60, y_num), "ATK", rot_f, "l", 2)
            texto_foil_em(im, claro, (116, y_num), str(c["atk"]), num_f, "l", 4)
            texto_foil_em(im, claro, (W - 60, y_num), "DEF", rot_f, "r", 2)
            texto_foil_em(im, claro, (W - 116, y_num), str(c["vida"]), num_f, "r", 4)
        # cantos de fora transparentes
        out = im.convert("RGBA")
        cant = Image.new("L", (W, H), 0)
        ImageDraw.Draw(cant).rounded_rectangle((0, 0, W - 1, H - 1), RAIO, fill=255)
        out.putalpha(cant)
        out.save(os.path.join(OUT, f"q_{q:03d}.png"))
        print(q, flush=True)
    fundo = "color=c=0x0d0b12:s=760x1048"
    subprocess.run(["ffmpeg", "-loglevel", "error", "-y", "-f", "lavfi", "-i", fundo, "-framerate", "24", "-i", os.path.join(OUT, "q_%03d.png"),
                    "-filter_complex", "[0][1]overlay=20:20:shortest=1,scale=570:786:flags=lanczos", "-c:v", "libx264", "-crf", "19",
                    "-pix_fmt", "yuv420p", "-movflags", "faststart", os.path.join(OUT, f"lend_{cid}.mp4")], check=True)
    prev = Image.new("RGBA", (W + 40, H + 40), (13, 11, 18, 255))
    n_q = int(os.environ.get("QUADROS", N))
    prev.alpha_composite(Image.open(os.path.join(OUT, "q_%03d.png" % min(12, n_q - 1))), (20, 20))
    prev.convert("RGB").save(os.path.join(OUT, f"lend_{cid}_previa.png"))
    print("ok")


if __name__ == "__main__":
    main()
