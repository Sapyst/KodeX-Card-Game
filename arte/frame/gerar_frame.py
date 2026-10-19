"""Frame frontal das cartas do Gods Kodex, 100% por código (SDF), em pixel art nativa 240×336 (×3 = 720×1008).
Proporção 5:7 = carta de impressão 63×88 mm (720×1008 ≈ 290 dpi). Janela de arte 168×224 = 3:4 exato (arte inteira).

Camadas exportadas para o Godot (números e textos NÃO vão assados — Labels por cima):
  saida/frame_<cultura>_<tipo>[_lendaria].png  moldura com a janela de arte transparente (nativo e _x3)
  saida/gema_fe.png, saida/atk.png, saida/vida.png, saida/usos.png, saida/emblema_<cultura>.png
  saida/layout.json                             retângulos de cada área (px nativos)
  saida/previa_*.png                            cartas montadas com arte real + texto (só para conferir)

Uso: /mnt/d/Comfy-Desktop/venv/bin/python gerar_frame.py
"""
import glob, json, math, os, random, re
from PIL import Image
import fonte_tecnica as F

# ---- complementos da fonte: maiúsculas acentuadas (acento 2 linhas ACIMA da letra) e sinais extras ----
for _min, (_base, _acento) in F.ACC.items():
    _mai = _min.upper()
    if _mai != _min and _base.upper() in F.G and _mai not in F.G:
        F.G[_mai] = _acento + F.G[_base.upper()]            # 9 linhas: as 2 primeiras ficam acima da linha de topo
F.G["Í"] = ["00010", "00100"] + F.G["I"]
F.G[">"] = ["00000", "00100", "00010", "11111", "00010", "00100", "00000"]
F.G["→"] = F.G[">"]
F.G["—"] = ["000000", "000000", "000000", "111111", "000000", "000000", "000000"]
F.G["–"] = ["0000", "0000", "0000", "1111", "0000", "0000", "0000"]
F.G[";"] = ["00", "00", "01", "00", "00", "01", "10"]
F.G['"'] = ["101", "101", "000", "000", "000", "000", "000"]
F.G["*"] = ["00000", "00100", "10101", "01110", "10101", "00100", "00000"]
F.G["−"] = F.G["-"]
F.G["Ð"] = ["01110", "01001", "01001", "11101", "01001", "01001", "01110"]
F.G["·"] = ["0", "0", "0", "1", "0", "0", "0"]
F.G["'"] = ["1", "1", "0", "0", "0", "0", "0"]


def _draw(img, x, y, s, col, shadow=None):
    """Como F.draw, mas glifos com mais de 7 linhas sobem (acento de maiúscula fica acima do topo)."""
    for c in s:
        g = F.G.get(c, F.G["?"]); off = len(g) - 7
        for yy, row in enumerate(g):
            for xx, v in enumerate(row):
                if v == "1":
                    if shadow: img.putpixel((x + xx + 1, y + yy - off + 1), shadow)
                    img.putpixel((x + xx, y + yy - off), col)
        x += len(g[0]) + F.ADV
    return x


F.draw = _draw

AQUI = os.path.dirname(os.path.abspath(__file__))
RAIZ = os.path.dirname(os.path.dirname(AQUI))
OUT = os.path.join(AQUI, "saida")
W, H = 240, 336
ESC = 3
OUTL = (14, 10, 12)

# ---------------- layout (px nativos) ----------------
CARD_R = 10
BAND = 7                                   # espessura da moldura externa
ART = (36, 26, 204, 250)                   # x0, y0, x1, y1 (exclusivo) — 168×224 = 3:4 exato, sem cortar a arte
TIPO = (10, 253, 230, 265)                 # faixa de tipo
TEXTO = (12, 267, 228, 311)                # caixa de texto (pergaminho) — 4 linhas de 9 px (o texto mais longo tem 4)
STATUS = (8, 312, 232, 328)                # faixa de status embaixo: ATK à esquerda, Vida à direita, raridade no meio
NOME = (46, 6, 194, 22)                    # placa do nome
GEMA = (21, 21, 17)                        # centro x, y, raio
EMBLEMA = (219, 21, 13)
ATK_IC = (18, 320)                         # centro do ícone de espada
ATK_ROT = (27, 317)                        # topo-esquerda do rótulo "ATK"
ATK_NUM = (53, 320)                        # centro do número de ATK
VIDA_IC = (222, 320)                       # centro do ícone de coração
VIDA_ROT = (213, 317)                      # topo-DIREITA do rótulo "VIDA"/"USOS"
VIDA_NUM = (178, 320)                      # centro do número de Vida (ou Usos, nas Relíquias)
RARO_C = (120, 320)

# ---------------- paletas por cultura ----------------
# metal: luz/médio/sombra da moldura; base: fundo da carta (2 tons); acento: detalhe do padrão; disco: fundo do emblema
CULT = {
    "indigena":     dict(metal=[(226, 170, 96), (170, 108, 52), (98, 58, 30)], base=[(58, 40, 28), (46, 31, 22)],
                         acento=(92, 160, 74), disco=(40, 92, 52), padrao="zigue"),
    "cristianismo": dict(metal=[(255, 236, 168), (214, 172, 82), (132, 96, 40)], base=[(222, 214, 196), (190, 180, 160)],
                         acento=(120, 150, 210), disco=(236, 228, 210), padrao="pontos"),
    "taoismo":      dict(metal=[(150, 214, 170), (70, 150, 110), (30, 82, 62)], base=[(36, 58, 50), (28, 46, 40)],
                         acento=(206, 62, 48), disco=(196, 54, 42), padrao="grega"),
    "hinduismo":    dict(metal=[(255, 206, 110), (224, 140, 40), (140, 70, 24)], base=[(36, 46, 96), (28, 36, 78)],
                         acento=(240, 120, 60), disco=(40, 60, 140), padrao="petalas"),
    "bruxaria":     dict(metal=[(196, 170, 220), (124, 92, 160), (66, 44, 92)], base=[(38, 30, 46), (30, 24, 36)],
                         acento=(120, 200, 110), disco=(54, 86, 52), padrao="lua"),
    "alta_magia":   dict(metal=[(246, 214, 120), (190, 146, 58), (110, 78, 30)], base=[(24, 22, 26), (18, 16, 20)],
                         acento=(200, 56, 48), disco=(30, 26, 34), padrao="runas"),
}
OURO = [(255, 240, 160), (230, 184, 70), (150, 100, 30)]
PAPEL = [(236, 220, 182), (222, 202, 160), (196, 170, 124)]
TINTA = (52, 32, 22)
TIPOS = {  # cor da faixa e do losango de tipo
    "entidade": dict(cor=[(196, 96, 72), (150, 62, 48), (92, 34, 30)], rotulo="ENTIDADE"),
    "selo":     dict(cor=[(150, 120, 196), (98, 74, 146), (56, 40, 92)], rotulo="SELO"),
    "rito":     dict(cor=[(120, 190, 140), (70, 136, 96), (36, 82, 56)], rotulo="RITO"),
    "reliquia": dict(cor=[(236, 196, 104), (184, 136, 52), (110, 76, 28)], rotulo="RELÍQUIA"),
}


# ---------------- primitivas SDF ----------------
def sd_box(x, y, x0, y0, x1, y1, rt, rb=None):
    """Distância com sinal ao retângulo [x0,x1)×[y0,y1) com raio rt nos cantos de cima e rb nos de baixo."""
    rb = rt if rb is None else rb
    cx, cy = (x0 + x1 - 1) / 2, (y0 + y1 - 1) / 2
    hx, hy = (x1 - x0 - 1) / 2, (y1 - y0 - 1) / 2
    r = rt if y < cy else rb
    qx, qy = abs(x - cx) - (hx - r), abs(y - cy) - (hy - r)
    return math.hypot(max(qx, 0), max(qy, 0)) + min(max(qx, qy), 0) - r


def sd_circle(x, y, cx, cy, r):
    return math.hypot(x - cx, y - cy) - r


def sd_hex(x, y, cx, cy, r):
    """Hexágono de ponta para cima."""
    px, py = abs(x - cx), abs(y - cy)
    k = (-0.8660254, 0.5, 0.57735)
    d = 2 * min(k[0] * py + k[1] * px, 0)   # gira 90° (ponta para cima) trocando px/py
    px2, py2 = py - d * k[0], px - d * k[1]
    px2 -= max(min(px2, k[2] * r), -k[2] * r)
    return math.hypot(px2, py2 - r) * (1 if py2 - r > 0 else -1)


def mix(a, b, t):
    return tuple(int(round(a[i] + (b[i] - a[i]) * t)) for i in range(3))


def ruido(x, y, s=0):
    return ((x * 73856093) ^ (y * 19349663) ^ (s * 83492791)) % 1000 / 1000


def luz(x, y, x0, y0, x1, y1):
    """0 = canto de cima/esquerda (luz), 1 = baixo/direita (sombra)."""
    return ((x - x0) / max(x1 - x0, 1) + (y - y0) / max(y1 - y0, 1)) / 2


def put(p, x, y, c, a=255):
    if 0 <= x < W and 0 <= y < H:
        p[x, y] = tuple(c) + (a,)


# ---------------- peças ----------------
def moldura(im, cult, lend):
    """Corpo da carta: contorno, banda metálica com padrão da cultura, fundo texturizado."""
    p = im.load(); pal = CULT[cult]; metal = OURO if lend else pal["metal"]
    for y in range(H):
        for x in range(W):
            d = sd_box(x, y, 0, 0, W, H, CARD_R)
            if d > 0.5:
                continue
            if d > -0.5:
                put(p, x, y, OUTL); continue
            prof = -d                                   # profundidade dentro da carta
            if prof <= BAND:
                t = luz(x, y, 0, 0, W, H)
                if prof < 1.5:                          # aresta clara/escura (bisel)
                    c = metal[0] if t < 0.5 else metal[2]
                elif prof > BAND - 1.2:                 # filete interno escuro
                    c = OUTL
                else:                                   # banda com padrão
                    c = padrao(pal["padrao"], x, y, prof, metal, pal["acento"])
                put(p, x, y, c); continue
            # fundo: 2 tons + grão
            b0, b1 = pal["base"]
            n = ruido(x // 2, y // 2, 7)
            c = b0 if n < 0.55 else b1
            if prof < BAND + 2.5:
                c = mix(c, OUTL, 0.45)                  # sombra interna da moldura
            put(p, x, y, c)


def padrao(nome, x, y, prof, metal, acento):
    """Padrão da banda, função do comprimento ao longo do contorno (along) e da posição na banda (across)."""
    # along: x nas bordas de cima/baixo, y nas laterais (perto da borda mais próxima)
    dx = min(x, W - 1 - x); dy = min(y, H - 1 - y)
    along = x if dy < dx else y
    across = prof - 1.5                                  # 0..~3
    base = metal[1]
    if across < 0.8:
        base = metal[0]
    elif across > 2.6:
        base = metal[2]
    mid = 1.0 <= across <= 2.6
    if not mid:
        return base
    a = int(along)
    if nome == "zigue" and (a + int(across * 2)) % 6 in (0, 1):
        return acento
    if nome == "pontos" and a % 8 == 0:
        return acento
    if nome == "grega" and (a % 10 in (0, 4) or (a % 10 < 5 and int(across) == 1)):
        return acento if a % 20 < 10 else metal[2]
    if nome == "petalas" and a % 9 in (3, 4, 5) and int(across) == 2 - abs(a % 9 - 4):
        return acento
    if nome == "lua" and a % 12 in (0, 1) :
        return acento if int(across) == 1 else metal[0]
    if nome == "runas" and a % 7 == 0:
        return acento
    return base


def janela_arte(im, cult, lend):
    """Abre a janela de arte (transparente, 168×224) com aro metálico TODO por fora — nenhum pixel da arte é coberto."""
    p = im.load(); metal = OURO if lend else CULT[cult]["metal"]
    x0, y0, x1, y1 = ART
    for y in range(y0 - 6, y1 + 6):
        for x in range(x0 - 6, x1 + 6):
            if x0 <= x < x1 and y0 <= y < y1:
                p[x, y] = (0, 0, 0, 0); continue
            d = sd_box(x, y, x0 - 1, y0 - 1, x1 + 1, y1 + 1, 2)     # 0 na primeira volta fora da arte
            if d > 4.5:
                continue
            if d > 3.5 or d <= -0.5:
                put(p, x, y, OUTL); continue
            t = luz(x, y, x0, y0, x1, y1)
            if d > 2.0:
                c = metal[0] if t < 0.5 else metal[2]          # bisel externo
            else:
                c = metal[2] if t < 0.5 else metal[0]          # bisel interno invertido (afunda a arte)
            if d <= 0.5:
                c = mix(c, OUTL, 0.5)
            put(p, x, y, c)
    # cantoneiras douradas nos 4 cantos da janela
    for cx, cy, sx, sy in ((x0 - 2, y0 - 2, 1, 1), (x1 + 1, y0 - 2, -1, 1), (x0 - 2, y1 + 1, 1, -1), (x1 + 1, y1 + 1, -1, -1)):
        for i in range(6):
            for j in range(6 - i):
                put(p, cx + sx * i, cy + sy * j, OURO[0] if i + j < 3 else OURO[1])
            put(p, cx + sx * i, cy + sy * (6 - i), OUTL)


def pilares(im, cult, lend):
    """Colunas ao lado da arte: pilar entalhado com o acento da cultura a cada 16 px."""
    p = im.load(); pal = CULT[cult]; metal = OURO if lend else pal["metal"]
    for xa, xb in ((BAND + 3, ART[0] - 7), (ART[2] + 7, W - BAND - 3)):
        cx = (xa + xb) / 2
        for y in range(ART[1] + 2, ART[3] - 1):
            for x in range(xa, xb):
                if x in (xa, xb - 1):
                    put(p, x, y, OUTL); continue
                t = (x - xa) / max(xb - xa - 1, 1)
                c = metal[1] if t < 0.3 else mix(metal[1], metal[2], 0.6) if t < 0.7 else metal[2]
                if x == xa + 1:
                    c = metal[0]
                put(p, x, y, mix(c, pal["base"][0], 0.6))
            k = (y - ART[1]) % 16
            if k in (0, 1) and (y - ART[1]) % 32 < 2:          # anel do pilar a cada 32 px
                for x in range(xa, xb):
                    put(p, x, y, mix(metal[0], pal["base"][0], 0.3) if k == 0 else metal[2])
            if 6 <= k <= 10 and (y - ART[1]) % 32 >= 16:    # losango do acento entre os anéis
                r = 2 - abs(k - 8)
                for x in range(int(cx) - r, int(cx) + r + 1):
                    put(p, x, y, pal["acento"] if abs(x - cx) < r else OUTL)
        for x in range(xa - 1, xb + 1):                       # capitel e base
            for y in (ART[1], ART[1] + 1, ART[3] - 2, ART[3] - 1):
                put(p, x, y, metal[0] if y in (ART[1], ART[3] - 2) else metal[2])


ESPADA = ["......##",
          ".....#o#",
          "....#o#.",
          "#..#o#..",
          ".##o#...",
          "..##....",
          ".#.##...",
          "#...#..."]
AMPULHETA = ["#######",
             "#ooooo#",
             ".#ooo#.",
             "..#o#..",
             ".#ooo#.",
             "#ooooo#",
             "#######"]
CORACAO = [".##..##.",
           "#oo##oo#",
           "#oooooo#",
           "#oooooo#",
           ".#oooo#.",
           "..#oo#..",
           "...##..."]


def icone_px(im, forma, centro, claro, escuro):
    p = im.load(); h, w = len(forma), len(forma[0])
    x0, y0 = centro[0] - w // 2, centro[1] - h // 2
    for j, row in enumerate(forma):
        for i, ch in enumerate(row):
            if ch == "#":
                put(p, x0 + i, y0 + j, OUTL)
            elif ch == "o":
                put(p, x0 + i, y0 + j, claro if (i + j) < (w + h) / 2 else escuro)


def rotulos(im, direito):
    F.draw(im, ATK_ROT[0], ATK_ROT[1], "ATK", (226, 214, 190), OUTL)
    F.draw(im, VIDA_ROT[0] - F.width(direito), VIDA_ROT[1], direito, (226, 214, 190), OUTL)


def faixa_status(im, cult, tipo, lend):
    pal = CULT[cult]; metal = OURO if lend else pal["metal"]
    escuro = [mix(pal["base"][0], (255, 255, 255), 0.18), pal["base"][0], mix(pal["base"][1], OUTL, 0.4)]
    placa(im, STATUS, escuro, r=4, rebites=False)
    p = im.load()
    for x in range(STATUS[0] + 4, STATUS[2] - 4):            # filete metálico em cima
        put(p, x, STATUS[1] + 1, metal[1])
    if tipo == "entidade":
        icone_px(im, ESPADA, ATK_IC, (236, 236, 244), (150, 150, 168))
        icone_px(im, CORACAO, VIDA_IC, (240, 90, 90), (170, 30, 40))
        rotulos(im, "VIDA")
    elif tipo == "reliquia":
        pass                                                   # ampulheta de Usos entra na carta se ela tiver usos


def placa(im, box, cores, r=3, rebites=True):
    p = im.load(); x0, y0, x1, y1 = box
    for y in range(y0, y1):
        for x in range(x0, x1):
            d = sd_box(x, y, x0, y0, x1, y1, r)
            if d > 0.5:
                continue
            if d > -0.5:
                put(p, x, y, OUTL); continue
            if y <= y0 + 1:
                c = cores[0]
            elif y >= y1 - 2:
                c = cores[2]
            else:
                c = cores[1]
                if ruido(x, y, 3) < 0.08:
                    c = mix(c, cores[2], 0.4)
            put(p, x, y, c)
    if rebites:
        for rx in (x0 + 4, x1 - 5):
            ry = (y0 + y1) // 2
            put(p, rx, ry, OURO[0]); put(p, rx + 1, ry, OURO[1]); put(p, rx, ry + 1, OURO[1]); put(p, rx + 1, ry + 1, OURO[2])


def pergaminho(im):
    p = im.load(); x0, y0, x1, y1 = TEXTO
    for y in range(y0, y1):
        for x in range(x0, x1):
            d = sd_box(x, y, x0, y0, x1, y1, 3)
            if d > 0.5:
                continue
            if d > -0.5:
                put(p, x, y, OUTL); continue
            n = ruido(x // 3, y // 3, 11)
            c = PAPEL[0] if n < 0.7 else PAPEL[1]
            if d > -2.5:
                c = PAPEL[2]
            put(p, x, y, c)
    # vinheta: filete fino a 3 px da borda, com pontas
    for x in range(x0 + 6, x1 - 6):
        if x % 2 == 0:
            put(p, x, y0 + 3, mix(PAPEL[2], TINTA, 0.3))


def gema_fe(tam=40):
    """Cristal hexagonal facetado (Fé). Centro no meio da imagem."""
    im = Image.new("RGBA", (tam, tam), (0, 0, 0, 0)); p = im.load()
    cx = cy = (tam - 1) / 2; r = GEMA[2]
    claro, medio, escuro, brilho = (120, 180, 255), (52, 104, 214), (24, 46, 120), (232, 244, 255)
    for y in range(tam):
        for x in range(tam):
            d = sd_hex(x, y, cx, cy, r)
            if d > 0.5:
                continue
            if d > -0.5:
                p[x, y] = OUTL + (255,); continue
            if d > -2.0:
                p[x, y] = (OURO[1] if luz(x, y, 0, 0, tam, tam) < 0.5 else OURO[2]) + (255,); continue
            ang = math.atan2(y - cy, x - cx)
            face = int(((ang + math.pi) / (2 * math.pi)) * 6) % 6       # 6 facetas
            c = [escuro, medio, medio, claro, claro, medio][face]
            if math.hypot(x - cx, y - cy) < r * 0.42:
                c = mix(c, claro, 0.5)                                    # mesa central
            p[x, y] = c + (255,)
    for i in range(3):
        p[int(cx) - 5 + i, int(cy) - 7 + i] = brilho + (255,)
    return im


def emblema(cult, tam=32):
    im = Image.new("RGBA", (tam, tam), (0, 0, 0, 0)); p = im.load()
    pal = CULT[cult]; cx = cy = (tam - 1) / 2; r = EMBLEMA[2]
    for y in range(tam):
        for x in range(tam):
            d = sd_circle(x, y, cx, cy, r)
            if d > 0.5:
                continue
            if d > -0.5:
                p[x, y] = OUTL + (255,); continue
            if d > -2.5:
                t = luz(x, y, 0, 0, tam, tam)
                p[x, y] = (pal["metal"][0] if t < 0.45 else pal["metal"][2]) + (255,); continue
            p[x, y] = mix(pal["disco"], OUTL, 0.25 * (1 if y > cy else 0)) + (255,)
    icone(p, cult, int(cx), int(cy), pal)
    return im


def icone(p, cult, cx, cy, pal):
    """Símbolo de cada tradição, ~13 px, desenhado com primitivas."""
    c = pal["metal"][0]; a = pal["acento"]
    def px(x, y, col=c):
        p[cx + x, cy + y] = col + (255,)
    if cult == "indigena":                 # sol com raios (Guaraci) — losango + 8 raios
        for y in range(-3, 4):
            for x in range(-3, 4):
                if abs(x) + abs(y) <= 3:
                    px(x, y, (240, 170, 70) if abs(x) + abs(y) < 3 else (200, 110, 40))
        for k in range(8):
            ang = k * math.pi / 4
            for rr in (5, 6):
                px(round(math.cos(ang) * rr), round(math.sin(ang) * rr), (240, 170, 70))
    elif cult == "cristianismo":           # cruz com halo
        for rr in range(0, 80):
            ang = rr / 80 * 2 * math.pi
            px(round(math.cos(ang) * 6), round(math.sin(ang) * 6) - 1, (230, 190, 90))
        for y in range(-6, 7):
            px(0, y, (120, 92, 50)); px(1, y, (120, 92, 50))
        for x in range(-3, 5):
            px(x, -2, (120, 92, 50)); px(x, -1, (120, 92, 50))
    elif cult == "taoismo":                # taiji
        for y in range(-6, 7):
            for x in range(-6, 7):
                if x * x + y * y <= 36:
                    branco = x > 0
                    if (x) ** 2 + (y + 3) ** 2 <= 9: branco = True
                    if (x) ** 2 + (y - 3) ** 2 <= 9: branco = False
                    if x * x + (y + 3) ** 2 <= 1: branco = False
                    if x * x + (y - 3) ** 2 <= 1: branco = True
                    px(x, y, (240, 230, 210) if branco else (20, 18, 22))
    elif cult == "hinduismo":              # lótus de 5 pétalas
        for ang_d, comp in ((-90, 6), (-140, 5), (-40, 5), (-180, 4), (0, 4)):
            ang = math.radians(ang_d)
            for t in range(comp + 1):
                for w in (-1, 0, 1):
                    if t in (0, comp) and w: continue
                    x = round(math.cos(ang) * t - math.sin(ang) * w * (1 if t < comp - 1 else 0))
                    y = round(math.sin(ang) * t + math.cos(ang) * w * (1 if t < comp - 1 else 0)) + 3
                    px(x, y, (250, 160, 190) if t < comp else (255, 220, 230))
        for x in range(-5, 6):
            px(x, 4, (60, 150, 90))
    elif cult == "bruxaria":               # lua crescente + estrela
        for y in range(-6, 7):
            for x in range(-6, 7):
                if x * x + y * y <= 36 and (x - 3) ** 2 + (y - 1) ** 2 > 22:
                    px(x - 1, y, (230, 226, 200))
        for x, y in ((4, -4), (4, -5), (4, -3), (3, -4), (5, -4)):
            px(x, y, (190, 240, 170))
    elif cult == "alta_magia":             # pentagrama
        pts = [(math.cos(math.radians(-90 + 144 * k)) * 6, math.sin(math.radians(-90 + 144 * k)) * 6 + 0.5) for k in range(6)]
        for i in range(5):
            (xa, ya), (xb, yb) = pts[i], pts[i + 1]
            n = 16
            for s in range(n + 1):
                px(round(xa + (xb - xa) * s / n), round(ya + (yb - ya) * s / n), (240, 200, 100))
        for rr in range(0, 90):
            ang = rr / 90 * 2 * math.pi
            px(round(math.cos(ang) * 7), round(math.sin(ang) * 7), (200, 56, 48))


def selo_stat(tipo, tam=32):
    """ATK = escudo pontudo laranja com lâmina; VIDA = gota vermelha; USOS = engrenagem/ampulheta dourada."""
    im = Image.new("RGBA", (tam, tam), (0, 0, 0, 0)); p = im.load(); cx = cy = (tam - 1) / 2
    if tipo == "atk":
        cores = [(255, 210, 110), (226, 140, 48), (140, 70, 24)]
        dentro = lambda x, y: abs(x - cx) <= 11 - max(0, (y - cy - 1)) * 0.9 and -11 <= y - cy <= 12
    elif tipo == "vida":
        cores = [(255, 140, 120), (206, 46, 46), (110, 20, 26)]
        dentro = lambda x, y: (math.hypot(x - cx, y - cy - 2.5) <= 10.5) or (y - cy < -2 and abs(x - cx) <= (y - cy + 13) * 0.55)
    else:
        cores = [(230, 220, 200), (160, 150, 140), (90, 84, 80)]
        dentro = lambda x, y: math.hypot(x - cx, y - cy) <= 11
    def borda(x, y):
        return any(not dentro(x + a, y + b) for a, b in ((1, 0), (-1, 0), (0, 1), (0, -1)))
    for y in range(tam):
        for x in range(tam):
            if not dentro(x, y):
                continue
            if borda(x, y):
                p[x, y] = OUTL + (255,); continue
            t = luz(x, y, 0, 0, tam, tam)
            c = cores[0] if t < 0.35 else cores[1] if t < 0.68 else cores[2]
            p[x, y] = c + (255,)
    if tipo == "atk":                     # lâmina atrás do número: só a ponta e o cabo aparecem
        for i in range(4):
            p[int(cx) + 6 + i, int(cy) - 10 - i] = (236, 236, 240, 255)
            p[int(cx) - 7 - i, int(cy) + 9 + i] = (120, 80, 40, 255)
    return im


def coroa(im):
    """Lendária: coroa dourada 25×9 sentada na borda de cima, sobre o centro da placa do nome."""
    p = im.load(); cx = (NOME[0] + NOME[2]) // 2
    forma = ["#...........#...........#",
             "##.........###.........##",
             "###...#...#####...#...###",
             "####.###.#######.###.####",
             "#########################",
             "#.#.#.#.#.#.#.#.#.#.#.#.#",
             "#########################"]
    y0 = NOME[1] - 5
    pts = {(cx - 12 + i, y0 + j) for j, row in enumerate(forma) for i, ch in enumerate(row) if ch == "#"}
    for x, y in pts:
        for a, b in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            if (x + a, y + b) not in pts:
                put(p, x + a, y + b, OUTL)
    for x, y in pts:
        j = y - y0
        put(p, x, y, OURO[0] if j < 3 else OURO[1] if j < 5 else OURO[2])
    for i, cor in ((cx - 6, (210, 50, 60)), (cx, (90, 150, 240)), (cx + 6, (210, 50, 60))):
        put(p, i, y0 + 3, cor); put(p, i, y0 + 2, mix(cor, (255, 255, 255), 0.5))


def losango_tipo(im, tipo):
    p = im.load(); cor = TIPOS[tipo]["cor"]; cx, cy = TIPO[0] + 8, (TIPO[1] + TIPO[3]) // 2
    for y in range(-4, 5):
        for x in range(-4, 5):
            s = abs(x) + abs(y)
            if s == 4:
                put(p, cx + x, cy + y, OUTL)
            elif s < 4:
                put(p, cx + x, cy + y, cor[0] if (x + y) < 0 else cor[1] if s < 2 else cor[2])


def raridade(im, lend):
    p = im.load(); cx, cy = RARO_C
    cores = OURO if lend else [(200, 196, 190), (140, 136, 132), (80, 76, 74)]
    for y in range(-4, 5):
        for x in range(-3, 4):
            s = abs(x) * 4 / 3 + abs(y)
            if s > 4.6:
                continue
            put(p, cx + x, cy + y, OUTL if s > 3.6 else cores[0] if y < 0 else cores[1] if s < 2 else cores[2])


# ---------------- montagem ----------------
def frame(cult, tipo, lend=False):
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    moldura(im, cult, lend)
    janela_arte(im, cult, lend)
    pilares(im, cult, lend)
    placa(im, TIPO, TIPOS[tipo]["cor"], r=2, rebites=False)
    losango_tipo(im, tipo)
    pergaminho(im)
    metal = OURO if lend else CULT[cult]["metal"]
    placa(im, NOME, metal, r=4)
    if lend:
        coroa(im)
    faixa_status(im, cult, tipo, lend)
    raridade(im, lend)
    return im


def colar(base, peca, centro):
    base.alpha_composite(peca, (int(centro[0] - (peca.width - 1) / 2), int(centro[1] - (peca.height - 1) / 2)))


def texto_central(im, box, s, cor, sombra=None):
    w = F.width(s); x0, y0, x1, y1 = box
    F.draw(im, x0 + (x1 - x0 - w) // 2, y0 + (y1 - y0 - 7) // 2, s, cor, sombra)


def numero_img(s, cor=(255, 255, 255)):
    """Dígitos 5×7 em escala 2 (10×14) com contorno escuro de 1 px e sombra embaixo/direita."""
    tmp = Image.new("RGBA", (F.width(s) + 2, 9), (0, 0, 0, 0))
    F.draw(tmp, 1, 1, s, cor)
    big = tmp.resize((tmp.width * 2, tmp.height * 2), Image.NEAREST)
    a = big.split()[3]
    out = Image.new("RGBA", (big.width + 3, big.height + 3), (0, 0, 0, 0))
    for dx, dy in ((0, 1), (2, 1), (1, 0), (1, 2), (2, 2), (0, 0), (2, 0), (0, 2)):
        sil = Image.new("RGBA", big.size, OUTL + (255,)); sil.putalpha(a); out.alpha_composite(sil, (dx, dy))
    out.alpha_composite(big, (1, 1))
    return out


def centro_visual(peca):
    """Centróide dos pixels opacos (centro óptico da forma: gota pesa embaixo, escudo em cima)."""
    a = peca.split()[3].load(); sx = sy = n = 0
    for y in range(peca.height):
        for x in range(peca.width):
            if a[x, y] > 128:
                sx += x; sy += y; n += 1
    return sx / n, sy / n


def numero_grande(im, centro, s, cor=(255, 255, 255)):
    """Centraliza a caixa dos pixels do número (sem a sombra) exatamente em `centro`."""
    n = numero_img(s, cor)
    bx0, by0, bx1, by1 = n.getbbox()
    w, h = bx1 - bx0 - 1, by1 - by0 - 1          # descontar 1 px de sombra embaixo/direita
    im.alpha_composite(n, (int(round(centro[0] - w / 2 - bx0)), int(round(centro[1] - h / 2 - by0))))


def colar_badge(base, peca, centro_layout):
    """Cola a peça com o centro do bitmap em centro_layout e devolve o centro VISUAL (onde vai o número)."""
    ox, oy = int(centro_layout[0] - (peca.width - 1) / 2), int(centro_layout[1] - (peca.height - 1) / 2)
    base.alpha_composite(peca, (ox, oy))
    vx, vy = centro_visual(peca)
    return ox + vx, oy + vy


def quebrar(texto, larg):
    linhas, atual = [], ""
    for pal in texto.split():
        t = (atual + " " + pal).strip()
        if F.width(t) <= larg:
            atual = t
        else:
            linhas.append(atual); atual = pal
    if atual:
        linhas.append(atual)
    return linhas


def carta(c, arte_path, cult):
    tipo = c["tipo"]; lend = c.get("lendaria", False)
    base = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    x0, y0, x1, y1 = ART
    if arte_path and os.path.exists(arte_path):
        a = Image.open(arte_path).convert("RGBA").resize((x1 - x0, y1 - y0), Image.LANCZOS)   # 3:4 → 3:4, inteira
        base.alpha_composite(a, (x0, y0))
    base.alpha_composite(frame(cult, tipo, lend))
    numero_grande(base, colar_badge(base, gema_fe(), GEMA[:2]), str(c["custo"]))
    colar_badge(base, emblema(cult), EMBLEMA[:2])
    nome = c["nome"].upper()
    if F.width(nome) > NOME[2] - NOME[0] - 14:
        nome = nome.split(",")[0]
    texto_central(base, NOME, nome, (255, 246, 220), OUTL)
    rot = TIPOS[tipo]["rotulo"] + (" - LENDÁRIA" if lend else "")
    F.draw(base, TIPO[0] + 15, (TIPO[1] + TIPO[3]) // 2 - 3, rot, (255, 246, 230), OUTL)
    if tipo == "entidade":
        numero_grande(base, ATK_NUM, str(c["atk"]))
        numero_grande(base, VIDA_NUM, str(c["vida"]))
    elif tipo == "reliquia" and c.get("usos"):
        icone_px(base, AMPULHETA, VIDA_IC, (240, 220, 160), (180, 140, 70))
        F.draw(base, VIDA_ROT[0] - F.width("USOS"), VIDA_ROT[1], "USOS", (226, 214, 190), OUTL)
        numero_grande(base, VIDA_NUM, str(c["usos"]))
    return base


def texto_carta(base, txt):
    x0, y0, x1, y1 = TEXTO
    linhas = quebrar(txt, x1 - x0 - 12)[:4]
    alt = len(linhas) * 9 - 2                       # 7 px de letra + 2 de entrelinha
    y = y0 + (y1 - y0 - alt) // 2
    for ln in linhas:
        F.draw(base, x0 + 6, y, ln, TINTA); y += 9


def ler_carta(path):
    md = open(path, encoding="utf-8").read()
    c = json.loads(re.search(r"```json\s*(\{.*?\})\s*```", md, re.S).group(1))
    m = re.search(r"## Texto da carta\s*\n(.*?)\n\s*\n", md, re.S)
    c["texto"] = " ".join(m.group(1).split()) if m else ""
    return c


def main():
    os.makedirs(OUT, exist_ok=True)
    random.seed(1)
    # camadas soltas
    gema_fe().save(f"{OUT}/gema_fe.png")
    for nome_ic, forma, cl, es in (("atk", ESPADA, (236, 236, 244), (150, 150, 168)), ("vida", CORACAO, (240, 90, 90), (170, 30, 40)),
                                   ("usos", AMPULHETA, (240, 220, 160), (180, 140, 70))):
        ic = Image.new("RGBA", (W, H), (0, 0, 0, 0)); icone_px(ic, forma, (8, 8), cl, es); ic.crop((0, 0, 16, 16)).save(f"{OUT}/icone_{nome_ic}.png")
    for cult in CULT:
        emblema(cult).save(f"{OUT}/emblema_{cult}.png")
        for tipo in TIPOS:
            for lend in ((False, True) if tipo == "entidade" else (False,)):
                im = frame(cult, tipo, lend)
                nome = f"frame_{cult}_{tipo}{'_lendaria' if lend else ''}"
                im.save(f"{OUT}/{nome}.png")
                im.resize((W * ESC, H * ESC), Image.NEAREST).save(f"{OUT}/{nome}_x{ESC}.png")
    def numero_centro(peca, c):
        vx, vy = centro_visual(peca)
        return [round(c[0] - (peca.width - 1) / 2 + vx, 1), round(c[1] - (peca.height - 1) / 2 + vy, 1)]
    json.dump({"nativo": [W, H], "escala": ESC, "arte": ART, "tipo": TIPO,
               "texto": TEXTO, "texto_margem": 6, "nome": NOME,
               "status": STATUS, "gema_centro": GEMA[:2], "emblema_centro": EMBLEMA[:2], "raridade_centro": RARO_C,
               "numero_centro": {"fe": numero_centro(gema_fe(), GEMA[:2]), "atk": ATK_NUM, "vida": VIDA_NUM, "usos": VIDA_NUM},
               "icone_centro": {"atk": ATK_IC, "vida": VIDA_IC, "usos": VIDA_IC}},
              open(f"{OUT}/layout.json", "w"), indent=1)
    # prévias: uma carta por cultura (uma Entidade comum, uma Lendária, um Selo/Rito/Relíquia)
    previas = []
    for cult in CULT:
        arquivos = sorted(glob.glob(os.path.join(RAIZ, "cartas", cult, "[0-9][0-9]_*.md")))
        cartas = [ler_carta(f) for f in arquivos]
        escolha = []
        for filtro in (lambda c: c["tipo"] == "entidade" and not c["lendaria"],
                       lambda c: c["lendaria"], lambda c: c["tipo"] != "entidade"):
            for c in cartas:
                arte = os.path.join(RAIZ, "arte", cult, c["id"] + ".png")
                if filtro(c) and c not in escolha and (os.path.exists(arte) or not any(
                        os.path.exists(os.path.join(RAIZ, "arte", cult, k["id"] + ".png")) for k in cartas)):
                    escolha.append(c); break
        for c in escolha:
            im = carta(c, os.path.join(RAIZ, "arte", cult, c["id"] + ".png"), cult)
            texto_carta(im, c["texto"])
            previas.append(im)
    cols = 6; gap = 6
    linhas = (len(previas) + cols - 1) // cols
    folha = Image.new("RGBA", (cols * (W + gap) + gap, linhas * (H + gap) + gap), (22, 20, 26, 255))
    for i, im in enumerate(previas):
        folha.alpha_composite(im, (gap + (i % cols) * (W + gap), gap + (i // cols) * (H + gap)))
    folha.resize((folha.width * 2, folha.height * 2), Image.NEAREST).save(f"{OUT}/previa_folha.png")
    previas[0].resize((W * ESC, H * ESC), Image.NEAREST).save(f"{OUT}/previa_carta_x3.png")
    print("ok:", len(previas), "prévias")


if __name__ == "__main__":
    main()
