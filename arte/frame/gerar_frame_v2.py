"""Frame v2 do Gods Kodex — segue o mapa do autor (arte/frame/mapa_frame.png).
Traço vetorial liso (supersample 2×), resolução final 720×1008 (5:7 = 63×88 mm).

  verde   → pílula do NOME (prata = comum, ouro = lendária, arco-íris = especial)
  magenta → pílula do EFEITO/HABILIDADE + dano (Atk x) quando houver
  azul    → pílula da DEFESA (Def x = Vida) ou extra (Usos x); some se a carta não tem
  branco  → descrição
  listra preta de fora a fora → padrão de formas da cultura (normal) ou holográfico arco-íris (especial)

Uso: /mnt/d/Comfy-Desktop/venv/bin/python gerar_frame_v2.py
Saídas em saida_v2/: frame_<cultura>_<raridade>.png (janela de arte transparente), previa_*.png, layout_v2.json
"""
import glob, json, os, re
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

AQUI = os.path.dirname(os.path.abspath(__file__))
RAIZ = os.path.dirname(os.path.dirname(AQUI))
OUT = os.path.join(AQUI, "saida_v2")
FONTE_TITULO = os.path.join(RAIZ, "arte", "fontes", "MatchaStyle.ttf")
FONTE_TEXTO = "/usr/share/fonts/noto/NotoSans-SemiCondensedMedium.ttf"
FONTE_TEXTO_B = "/usr/share/fonts/noto/NotoSans-SemiCondensedSemiBold.ttf"

W, H, SS = 720, 1008, 2
R_CARTA = 26
BORDA = 16            # contorno escuro externo
ANEL1 = 28            # fim do anel claro externo (16..28)
LISTRA = 44           # fim da listra decorada (28..44)
PAINEL = 48           # início do painel interno
ART = (82, 80, 637, 820)            # 555×740 = 3:4 exato
NOME = (180, 60, 760, 110)          # pílula verde: só a curva da esquerda aparece; a ponta direita fica toda sob a moldura
CUSTO = (104, 92, 40)               # número de Fé direto sobre o canto (centro x, y, tamanho-base) — sem círculo
EMBLEMA = (640, 85, 18)             # dentro da ponta direita da pílula do nome
EFEITO = (52, 804, 412, 838)        # pílula magenta
DEFESA = (278, 938, 760, 980)       # pílula azul: POR CIMA da moldura, cortada reta no contorno escuro externo (x=704)
TEXTO = (66, 848, 654, 936)         # descrição (até 4 linhas)

ITALICO = 0.55                      # inclinação das pontas das pílulas (estilo itálico do mapa)
ESCURO = (24, 21, 28)
CLARO = (246, 242, 234)

CULT = {
    "indigena":     dict(base=(120, 52, 30), forma=[(232, 150, 60), (40, 26, 20), (90, 150, 70)], pilula=(150, 70, 36),
                         painel=(250, 241, 228), padrao="marajoara", nome="Indígena"),
    "cristianismo": dict(base=(40, 60, 120), forma=[(236, 200, 110), (250, 246, 236), (150, 40, 50)], pilula=(54, 74, 140),
                         painel=(250, 248, 242), padrao="quadrifolio", nome="Cristianismo"),
    "taoismo":      dict(base=(28, 110, 96), forma=[(220, 240, 230), (90, 180, 150), (200, 60, 48)], pilula=(26, 96, 84),
                         painel=(242, 248, 244), padrao="seigaiha", nome="Taoismo"),
    "hinduismo":    dict(base=(196, 96, 20), forma=[(255, 214, 120), (40, 52, 130), (230, 60, 110)], pilula=(40, 52, 130),
                         painel=(252, 244, 230), padrao="shippo", nome="Hinduísmo"),
    "bruxaria":     dict(base=(70, 40, 96), forma=[(170, 120, 210), (100, 180, 100), (30, 20, 40)], pilula=(78, 44, 108),
                         painel=(245, 241, 248), padrao="marmore", nome="Bruxaria"),
    "alta_magia":   dict(base=(26, 22, 30), forma=[(224, 182, 80), (150, 40, 40), (70, 60, 76)], pilula=(30, 26, 36),
                         painel=(246, 243, 236), padrao="asanoha", nome="Alta magia"),
}
TIPO_NOME = {"entidade": "Entidade", "selo": "Selo", "rito": "Rito", "reliquia": "Relíquia"}


# ---------------- grade e SDF (em px finais, amostrada a SS×) ----------------
def grade():
    yy, xx = np.mgrid[0:H * SS, 0:W * SS].astype(np.float32)
    return (xx + 0.5) / SS, (yy + 0.5) / SS


X, Y = grade()


def sd_rect(x0, y0, x1, y1, r):
    cx, cy, hx, hy = (x0 + x1) / 2, (y0 + y1) / 2, (x1 - x0) / 2, (y1 - y0) / 2
    qx, qy = np.abs(X - cx) - (hx - r), np.abs(Y - cy) - (hy - r)
    return np.hypot(np.maximum(qx, 0), np.maximum(qy, 0)) + np.minimum(np.maximum(qx, qy), 0) - r


def cob(sd):
    """Cobertura antiserrilhada a partir da distância (1 dentro, 0 fora, rampa de 1 px final)."""
    return np.clip(0.5 - sd * SS / 2, 0, 1)


def pinta(img, mask, cor, alfa=1.0):
    m = (mask * alfa)[..., None]
    img[..., :3] = img[..., :3] * (1 - m) + np.asarray(cor, np.float32)[..., :3] / 255 * m if np.ndim(cor) == 1 else \
        img[..., :3] * (1 - m) + cor * m
    img[..., 3:] = np.maximum(img[..., 3:], m)


def hsv(h, s, v):
    h = (h % 1.0) * 6; i = np.floor(h).astype(int) % 6; f = h - np.floor(h)
    p, q, t = v * (1 - s), v * (1 - s * f), v * (1 - s * (1 - f))
    r = np.choose(i, [v, q, p, p, t, v]); g = np.choose(i, [t, v, v, q, p, p]); b = np.choose(i, [p, p, t, v, v, q])
    return np.stack([r, g, b], -1).astype(np.float32)


def c3(rgb):
    return np.asarray(rgb, np.float32) / 255


# ---------------- padrões das listras (coordenadas globais da carta → contínuos) ----------------
def padrao(nome, pal):
    """Devolve imagem RGB float (H*SS, W*SS, 3) com o padrão da cultura."""
    base = np.broadcast_to(c3(pal["base"]), X.shape + (3,)).copy()
    f0, f1, f2 = (c3(c) for c in pal["forma"])
    out = base
    if nome == "seigaiha":                       # ondas de arcos concêntricos (taoismo)
        s = 16.0
        row = np.floor(Y / (s * 0.5))
        xs = X / s + (row % 2) * 0.5
        cx = np.floor(xs) + 0.5
        dx, dy = (xs - cx) * s, (Y - (row + 1) * s * 0.5)
        d = np.hypot(dx, dy)
        ring = (np.floor(d / 3.2) % 2 == 0) & (d < s * 0.5)
        out = np.where(ring[..., None], f0, np.where((d < s * 0.5)[..., None], f1, base))
    elif nome == "shippo":                       # círculos entrelaçados (hinduísmo)
        s = 14.0
        u, v = X / s, Y / s
        d1 = np.hypot(u - np.round(u), v - np.round(v))
        d2 = np.hypot(u - np.floor(u) - 0.5, v - np.floor(v) - 0.5)
        linha = (np.abs(d1 - 0.5) < 0.08) | (np.abs(d2 - 0.5) < 0.08)
        miolo = d1 < 0.14
        out = np.where(linha[..., None], f0, np.where(miolo[..., None], f2, base))
    elif nome == "marajoara":                    # losangos e zigue-zague (grafismo indígena)
        s = 12.0
        u, v = (X / s) % 2, (Y / s) % 2
        dz = np.abs(u - 1) + np.abs(v - 1)
        zz = np.abs(((X + Y * 0.0) / 6) % 2 - 1) * 6
        losango = (dz > 0.55) & (dz < 0.8)
        centro = dz < 0.25
        out = np.where(losango[..., None], f0, np.where(centro[..., None], f2, base))
        out = np.where((np.abs(zz - 3) < 0.6)[..., None] & (dz > 0.9)[..., None], f1, out)
    elif nome == "quadrifolio":                  # quadrifólio gótico + pontos dourados
        s = 16.0
        u, v = (X % s) - s / 2, (Y % s) - s / 2
        petal = np.minimum.reduce([np.hypot(u - 3, v), np.hypot(u + 3, v), np.hypot(u, v - 3), np.hypot(u, v + 3)])
        aro = np.abs(petal - 3) < 0.9
        ponto = np.hypot(u, v) < 1.4
        out = np.where(aro[..., None], f0, np.where(ponto[..., None], f2, base))
    elif nome == "marmore":                      # marmorizado (bruxaria) — curvas de nível de um campo suave
        f = (np.sin(X / 23 + np.sin(Y / 31) * 2.2) + np.sin(Y / 19 + np.sin(X / 27) * 2.0) + 0.5 * np.sin((X + Y) / 13))
        faixa = (np.floor(f * 2.2) % 2 == 0)
        out = np.where(faixa[..., None], f0 * 0.55 + base * 0.45, base)
        out = np.where((np.abs((f * 2.2) % 1 - 0.5) < 0.07)[..., None], f1, out)
    elif nome == "asanoha":                      # estrela de cânhamo (geometria sagrada)
        s = 18.0
        u, v = (X % s) / s - 0.5, (Y % s) / s - 0.5
        ang = np.arctan2(v, u)
        k = np.abs(np.sin(ang * 3))
        r = np.hypot(u, v)
        raio = (np.abs(np.sin(ang * 6)) < 0.12) & (r < 0.5)
        hexa = np.abs(np.maximum(np.abs(u) * 0.866 + np.abs(v) * 0.5, np.abs(v)) - 0.42) < 0.03
        out = np.where((raio | hexa)[..., None], f0, base)
        out = np.where((r < 0.06)[..., None], f1, out)
    return out


def holografico(fase=0.0, sat=0.75):
    diag = (X * 0.8 + Y * 0.5) / 260 + fase
    ondas = 0.08 * np.sin(X / 9 + Y / 13) + 0.05 * np.sin(Y / 5)
    return hsv(diag + ondas, sat, 1.0)


# ---------------- montagem ----------------
def painel_marmore(pal):
    """Padrão do painel bege: marmorizado claro (curvas suaves), meio opaco, diferente da listra."""
    f = (np.sin(X / 41 + np.sin(Y / 57) * 2.4) + np.sin(Y / 37 + np.sin(X / 49) * 2.1) + 0.6 * np.sin((X - Y) / 29))
    v = (f * 1.6) % 2
    faixa = np.clip(1 - np.abs(v - 1) * 3.2, 0, 1)            # faixas com borda suave
    claro = c3(pal["painel"])
    tom = claro * 0.80 + c3(pal["base"]) * 0.20
    return claro * (1 - faixa[..., None] * 0.6) + tom * (faixa[..., None] * 0.6)


def moldura_externa(img, pal, raridade, fase):
    """Contorno escuro + anel claro + listra decorada + filetes. Fica POR CIMA das pílulas."""
    ext = np.zeros_like(img)
    fora = cob(-(sd_rect(LISTRA, LISTRA, W - LISTRA, H - LISTRA, R_CARTA - LISTRA + 12) + 1.0))   # tudo de x=43 para fora
    carta = cob(sd_rect(0, 0, W, H, R_CARTA))
    pinta(ext, carta * fora, ESCURO)
    pinta(ext, cob(sd_rect(BORDA, BORDA, W - BORDA, H - BORDA, R_CARTA - BORDA + 4)) * fora, CLARO)
    listra = cob(sd_rect(ANEL1, ANEL1, W - ANEL1, H - ANEL1, R_CARTA - ANEL1 + 10)) * fora
    if raridade == "especial":
        cor_listra = holografico(fase) * 0.82 + padrao(pal["padrao"], pal) * 0.18
    else:
        cor_listra = padrao(pal["padrao"], pal)
    pinta(ext, listra, cor_listra)
    for d in (ANEL1, LISTRA):
        sd = sd_rect(d, d, W - d, H - d, R_CARTA - d + 10)
        pinta(ext, cob(np.abs(sd) - 1.2), ESCURO)
    m = ext[..., 3:]
    img[..., :3] = img[..., :3] * (1 - m) + ext[..., :3] * m
    img[..., 3:] = np.maximum(img[..., 3:] * (1 - m), m) if False else img[..., 3:] * (1 - m) + m


def frame(cult, raridade="comum", fase=0.0, defesa=False):
    """raridade: comum (prata) | lendaria (ouro) | especial (arco-íris na listra e no nome)."""
    pal = CULT[cult]
    img = np.zeros((H * SS, W * SS, 4), np.float32)
    pinta(img, cob(sd_rect(0, 0, W, H, R_CARTA)), CLARO)
    pmask = cob(sd_rect(PAINEL, PAINEL, W - PAINEL, H - PAINEL, 12))
    pinta(img, pmask, painel_marmore(pal))
    x0, y0, x1, y1 = ART
    sombra = np.clip(1 - np.maximum(sd_rect(x0 + 3, y0 + 5, x1 + 3, y1 + 5, 8), 0) / 10, 0, 1) * 0.35
    pinta(img, sombra, (0, 0, 0))
    pinta(img, cob(sd_rect(x0 - 3, y0 - 3, x1 + 3, y1 + 3, 8)), ESCURO)
    buraco = cob(sd_rect(x0, y0, x1, y1, 5))
    img[..., 3] *= (1 - buraco)
    pilula_nome(img, pal, raridade, fase)
    pilula(img, EFEITO, pal["pilula"])
    moldura_externa(img, pal, raridade, fase)
    if defesa:
        pilula(img, DEFESA, pal["pilula"], corte_x=W - BORDA)
    emblema(img, pal)
    return img


def sd_pilula(x0, y0, x1, y1, dx=0.0, dy=0.0):
    """Pílula com as pontas inclinadas (itálico): cisalha X conforme a altura."""
    r = (y1 - y0) / 2; cy = (y0 + y1) / 2 + dy
    xs = X - dx + (Y - cy) * ITALICO
    hx = (x1 - x0) / 2; cx = (x0 + x1) / 2
    qx, qy = np.abs(xs - cx) - (hx - r), np.abs(Y - cy) - (r - r)
    return np.hypot(np.maximum(qx, 0), np.maximum(qy, 0)) + np.minimum(np.maximum(qx, qy), 0) - r


def pilula(img, box, cor, cor_img=None, corte_x=None):
    x0, y0, x1, y1 = box
    corte = 1.0 if corte_x is None else cob(X - corte_x)
    pinta(img, cob(sd_pilula(x0, y0, x1, y1, 2, 4)) * corte, (0, 0, 0), 0.25)      # sombra
    sd = sd_pilula(x0, y0, x1, y1)
    if corte_x is not None:
        sd = np.maximum(sd, X - corte_x)
    pinta(img, cob(sd - 2.5), ESCURO)                                      # contorno 2,5 px
    if cor_img is not None:
        pinta(img, cob(sd), cor_img)
    else:
        pinta(img, cob(sd), cor)
        brilho = np.clip(1 - (Y - y0) / (y1 - y0) * 2.2, 0, 1) * 0.18
        pinta(img, cob(sd + 3) * brilho, (255, 255, 255))


def pilula_nome(img, pal, raridade, fase):
    x0, y0, x1, y1 = NOME
    t = np.clip((Y - y0) / (y1 - y0), 0, 1)[..., None]
    if raridade == "lendaria":                       # ouro: degradê + reflexo diagonal
        topo, meio, fundo = c3((255, 240, 170)), c3((226, 176, 60)), c3((150, 98, 24))
    elif raridade == "especial":
        topo = meio = fundo = None
    else:                                            # prata
        topo, meio, fundo = c3((250, 250, 252)), c3((196, 200, 210)), c3((120, 124, 138))
    if topo is None:
        cor = holografico(fase, sat=0.6) * 0.85 + 0.15
    else:
        cor = np.where(t < 0.5, topo * (1 - t * 2) + meio * (t * 2), meio * (1 - (t - 0.5) * 2) + fundo * ((t - 0.5) * 2))
        reflexo = np.exp(-(((X - x0) - (Y - y0) * 1.2 - 140) / 22) ** 2)[..., None] * 0.45
        cor = np.clip(cor + reflexo, 0, 1)
    pilula(img, NOME, None, cor_img=cor)


def circulo_custo(img, pal):
    cx, cy, r = CUSTO
    d = np.hypot(X - cx, Y - cy) - r
    pinta(img, cob(np.hypot(X - cx - 2, Y - cy - 4) - r), (0, 0, 0), 0.3)
    pinta(img, cob(d), ESCURO)
    t = np.clip((Y - (cy - r)) / (2 * r), 0, 1)[..., None]
    azul = c3((120, 180, 255)) * (1 - t) + c3((30, 60, 160)) * t
    pinta(img, cob(d + 4), azul)
    pinta(img, cob(np.hypot(X - cx + 10, Y - cy + 14) - 9) * 0.35, (255, 255, 255))


def emblema(img, pal):
    cx, cy, r = EMBLEMA
    d = np.hypot(X - cx, Y - cy) - r
    pinta(img, cob(d), ESCURO)
    pinta(img, cob(d + 2.5), pal["base"])
    pinta(img, cob(np.abs(d + 6) - 1.2), pal["forma"][0])


def para_imagem(img):
    a = (np.clip(img, 0, 1) * 255).astype(np.uint8)
    return Image.fromarray(a, "RGBA").resize((W, H), Image.LANCZOS)


# ---------------- texto ----------------
def fonte(caminho, tam):
    return ImageFont.truetype(caminho, tam)


def texto_contorno(d, xy, s, f, cor, contorno=ESCURO, esp=3, anchor="lm"):
    for dx in range(-esp, esp + 1):
        for dy in range(-esp, esp + 1):
            if dx * dx + dy * dy <= esp * esp:
                d.text((xy[0] + dx, xy[1] + dy), s, font=f, fill=contorno, anchor=anchor)
    d.text(xy, s, font=f, fill=cor, anchor=anchor)


def ajustar(d, s, caminho, tam, larg):
    while tam > 10:
        f = fonte(caminho, tam)
        if d.textlength(s, font=f) <= larg:
            return f
        tam -= 1
    return fonte(caminho, tam)


def quebrar(d, s, f, larg):
    linhas, atual = [], ""
    for p in s.split():
        t = (atual + " " + p).strip()
        if d.textlength(t, font=f) <= larg:
            atual = t
        else:
            linhas.append(atual); atual = p
    if atual:
        linhas.append(atual)
    return linhas


KEYS = ["Lendária", "Último Sopro", "Despertar", "Renascer", "Guarda", "Furtivo", "Ímpeto", "Sacrifício"]


def nome_efeito(c):
    """Pílula magenta: a palavra-chave principal da carta (ou o gatilho do Selo)."""
    txt = c.get("texto", "")
    for k in KEYS[1:]:
        if k in txt:
            return k
    if c["tipo"] == "selo":
        return "Armadilha"
    return TIPO_NOME[c["tipo"]]


def numero_prata(im, s, centro, tam):
    """Número só com a fonte: preenchimento prata (degradê) + contorno escuro grosso + sombra, sem círculo."""
    f = fonte(FONTE_TITULO, tam)
    pad = 20
    tmp = Image.new("L", (tam * 2 + pad * 2, tam + pad * 2), 0)
    ImageDraw.Draw(tmp).text((tmp.width // 2, tmp.height // 2), s, font=f, fill=255, anchor="mm")
    contorno = tmp.filter(ImageFilter.MaxFilter(11))
    sombra = contorno.filter(ImageFilter.GaussianBlur(4))
    h = tmp.height
    grad = Image.new("RGB", tmp.size)
    gp = grad.load()
    for y in range(h):
        t = y / (h - 1)
        c = (255, 255, 255) if t < 0.45 else tuple(int(255 - (255 - v) * (t - 0.45) / 0.55) for v in (176, 182, 196))
        for x in range(tmp.width):
            gp[x, y] = c
    camada = Image.new("RGBA", tmp.size, (0, 0, 0, 0))
    camada.paste(Image.new("RGBA", tmp.size, (0, 0, 0, 150)), (3, 5), sombra)
    camada.paste(Image.new("RGBA", tmp.size, ESCURO + (255,)), (0, 0), contorno)
    camada.paste(grad, (0, 0), tmp)
    im.alpha_composite(camada, (int(centro[0] - tmp.width / 2), int(centro[1] - tmp.height / 2)))


def escrever(im, c, cult, raridade):
    d = ImageDraw.Draw(im)
    pal = CULT[cult]
    # nome
    x0, y0, x1, y1 = NOME
    larg = (EMBLEMA[0] - EMBLEMA[2] - 10) - (x0 + 22)
    f = ajustar(d, c["nome"], FONTE_TITULO, 34, larg)
    cor_nome = (40, 26, 18) if raridade != "especial" else (24, 20, 30)
    texto_contorno(d, (x0 + 22, (y0 + y1) / 2 + 2), c["nome"], f, cor_nome, contorno=(255, 255, 255), esp=2)
    numero_prata(im, str(c["custo"]), CUSTO[:2], 76)
    # efeito + dano
    x0, y0, x1, y1 = EFEITO
    fe = fonte(FONTE_TITULO, 24)
    texto_contorno(d, (x0 + 18, (y0 + y1) / 2 + 1), nome_efeito(c), fe, (255, 255, 255), esp=2)
    if c["tipo"] == "entidade":
        texto_contorno(d, (x1 - 16, (y0 + y1) / 2 + 1), f"Atk {c['atk']}", fonte(FONTE_TITULO, 28), (255, 236, 160), esp=2, anchor="rm")
    # tipo (pequeno, acima da descrição à direita)
    ft = fonte(FONTE_TEXTO_B, 15)
    # etiqueta pequena ao lado da pílula de Def: se não couber, tira a cultura e depois reduz a letra (mín. 11 px)
    tem_def = c["tipo"] == "entidade" or (c["tipo"] == "reliquia" and c.get("usos"))
    limite = (DEFESA[0] - 14 if tem_def else W - PAINEL - 16) - TEXTO[0]
    base = TIPO_NOME[c["tipo"]].upper() + ("  ·  LENDÁRIA" if c.get("lendaria") else "")
    rot = base + "  ·  " + pal["nome"].upper()
    if d.textlength(rot, font=ft) > limite:
        rot = base
    tam = 15
    while d.textlength(rot, font=ft) > limite and tam > 11:
        tam -= 1
        ft = fonte(FONTE_TEXTO_B, tam)
    d.text((TEXTO[0], DEFESA[1] + 12), rot, font=ft, fill=(120, 110, 100), anchor="lm")
    # descrição
    x0, y0, x1, y1 = TEXTO
    tem_defesa = c["tipo"] == "entidade" or (c["tipo"] == "reliquia" and c.get("usos"))
    fd = fonte(FONTE_TEXTO, 21)
    linhas = quebrar(d, c.get("texto", "").replace("—", "-").replace("–", "-"), fd, x1 - x0)
    if tem_defesa and len(linhas) == 4:                       # 4ª linha não pode invadir a pílula azul
        ult = quebrar(d, linhas[3], fd, DEFESA[0] - x0 - 12)
        linhas = linhas[:3] + ult
    alt = len(linhas) * 24
    y = y0 + max(0, (y1 - y0 + (10 if not tem_defesa else 0) - alt) // 2)
    for ln in linhas[:5]:
        d.text((x0, y), ln, font=fd, fill=(44, 36, 30)); y += 24


def carta(c, cult, raridade, arte, fase=0.0):
    pal = CULT[cult]
    tem_defesa = c["tipo"] == "entidade" or (c["tipo"] == "reliquia" and c.get("usos"))
    fr = frame(cult, raridade, fase, defesa=bool(tem_defesa))
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    if arte and os.path.exists(arte):
        x0, y0, x1, y1 = ART
        im.alpha_composite(Image.open(arte).convert("RGBA").resize((x1 - x0, y1 - y0), Image.LANCZOS), (x0, y0))
    im.alpha_composite(para_imagem(fr))
    escrever(im, c, cult, raridade)
    if tem_defesa:
        d = ImageDraw.Draw(im); x0, y0, x1, y1 = DEFESA
        rot = f"Def {c['vida']}" if c["tipo"] == "entidade" else f"Usos {c['usos']}"
        texto_contorno(d, (W - PAINEL - 22, (y0 + y1) / 2 + 2), rot, fonte(FONTE_TITULO, 34), (255, 255, 255), esp=3, anchor="rm")
    return im


def ler_carta(path):
    md = open(path, encoding="utf-8").read()
    c = json.loads(re.search(r"```json\s*(\{.*?\})\s*```", md, re.S).group(1))
    m = re.search(r"## Texto da carta\s*\n(.*?)\n\s*\n", md, re.S)
    c["texto"] = " ".join(m.group(1).split()) if m else ""
    return c


def arte_de(cult, cid):
    for p in (os.path.join(RAIZ, "arte", cult, cid + ".png"), os.path.join(RAIZ, "arte", cult, "_v1", cid + ".png")):
        if os.path.exists(p):
            return p
    return None


def main():
    os.makedirs(OUT, exist_ok=True)
    for cult in CULT:
        for rar in ("comum", "lendaria", "especial"):
            para_imagem(frame(cult, rar, defesa=True)).save(os.path.join(OUT, f"frame_{cult}_{rar}.png"))
            para_imagem(frame(cult, rar, defesa=False)).save(os.path.join(OUT, f"frame_{cult}_{rar}_sem_defesa.png"))
    json.dump({"tamanho": [W, H], "arte": ART, "nome": NOME, "custo": CUSTO, "emblema": EMBLEMA, "efeito": EFEITO,
               "defesa": DEFESA, "texto": TEXTO}, open(os.path.join(OUT, "layout_v2.json"), "w"), indent=1)
    previas = []
    for cult in CULT:
        cartas = [ler_carta(f) for f in sorted(glob.glob(os.path.join(RAIZ, "cartas", cult, "[0-9][0-9]_*.md")))]
        comum = next(c for c in cartas if c["tipo"] == "entidade" and not c["lendaria"] and arte_de(cult, c["id"]))
        lend = next(c for c in cartas if c["lendaria"] and arte_de(cult, c["id"]))
        outra = next(c for c in cartas if c["tipo"] != "entidade" and arte_de(cult, c["id"]))
        for c, rar in ((comum, "comum"), (lend, "lendaria"), (outra, "comum"), (comum, "especial")):
            previas.append(carta(c, cult, rar, arte_de(cult, c["id"]), fase=0.07 * len(previas)))
    for i, cult in enumerate(CULT):
        gap = 24
        folha = Image.new("RGBA", (W * 4 + gap * 5, H + gap * 2), (18, 16, 22, 255))
        for j in range(4):
            folha.alpha_composite(previas[i * 4 + j], (gap + j * (W + gap), gap))
        folha.resize((folha.width // 2, folha.height // 2), Image.LANCZOS).save(os.path.join(OUT, f"previa_{cult}.png"))
    previas[0].save(os.path.join(OUT, "previa_carta.png"))
    print("ok")


if __name__ == "__main__":
    main()
