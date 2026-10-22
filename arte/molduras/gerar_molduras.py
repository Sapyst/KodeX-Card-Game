"""Molduras de perfil do KodeX (item 46): arco gótico ogival com o retrato dentro, gema na chave do arco, medalhão com o
símbolo da tradição no meio da base, barra de vida (Cornucópia) logo abaixo, plaquinha entalhada com o nome e fita com
o nível. Tudo pixel art em px NATIVOS (a tela do jogo é 360×640); o retrato é ilustração lisa por baixo.

Técnica (skill pixel-ui-procedural): cada pixel pergunta a distância assinada ao contorno da janela (SDF do arco =
interseção de dois discos + retângulo). Faixas por distância: contorno escuro, aro de metal com bisel e canaleta interna.
O bisel sai da normal do SDF (gradiente) × perfil abaulado do aro × luz vinda de cima-esquerda, quantizado em 5 tons.

Uso: /mnt/d/Comfy-Desktop/venv/bin/python gerar_molduras.py   → saida/folha_molduras.png (+ peças nativas em saida/)
"""
import math, os, sys
import numpy as np
from PIL import Image
AQUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, AQUI)
import fontes_pixel as FP

RAIZ = FP.RAIZ
OUT = os.path.join(AQUI, "saida")
ESCURO = (20, 12, 16)
LUZ = np.array([-0.55, -0.83])                      # luz vindo de cima-esquerda (y para baixo)

# 5 tons do escuro ao claro + cor da gema (3 tons) por material
MATERIAIS = {
    "bronze": dict(tons=[(70, 38, 22), (122, 70, 38), (176, 112, 62), (222, 160, 102), (255, 222, 170)],
                   gema=[(40, 70, 40), (70, 140, 80), (170, 230, 160)], nome="Bronze"),
    "prata": dict(tons=[(52, 54, 66), (98, 102, 120), (152, 158, 176), (204, 210, 224), (250, 252, 255)],
                  gema=[(24, 40, 110), (60, 100, 210), (170, 210, 255)], nome="Prata"),
    "ouro": dict(tons=[(92, 54, 20), (156, 100, 34), (220, 160, 60), (255, 212, 110), (255, 244, 196)],
                 gema=[(100, 14, 30), (196, 40, 60), (255, 150, 160)], nome="Ouro"),
    "jade": dict(tons=[(14, 56, 44), (28, 100, 78), (58, 158, 120), (128, 214, 176), (214, 255, 234)],
                 gema=[(120, 20, 20), (210, 60, 48), (255, 170, 140)], nome="Jade"),
    "obsidiana": dict(tons=[(20, 10, 30), (44, 22, 66), (84, 46, 120), (150, 96, 206), (226, 190, 255)],
                      gema=[(80, 0, 60), (200, 40, 160), (255, 160, 240)], nome="Obsidiana"),
}

# símbolos das tradições (9×9, cabem no disco do medalhão): '#' cor clara, '+' cor média
SIMBOLOS = {
    "indigena": [          # pena de cocar
        "......###", ".....#++#", "....#++#.", "...#++#..", "..#++#...", "..#+#....", ".#.##....", "#........", ".........",
    ],
    "cristianismo": [      # cruz de pontas abertas
        "...###...", "....#....", "#...#...#", "#########", "#...#...#", "....#....", "....#....", "....#....", "...###...",
    ],
    "taoismo": ['..#####..', '.##...##.', '###.#..##', '###.....#', '####....#', '######..#', '####.#.##', '.#######.', '..#####..'],     # yin-yang
    "hinduismo": [         # lótus
        ".........", "....#....", "...#+#...", "#..#+#..#", "##.#+#.##", ".##+++##.", "..#+++#..", ".#######.", ".........",
    ],
    "bruxaria": [          # lua crescente e estrela
        "..###....", ".##......", "##....#..", "##...###.", "##....#..", "##.......", ".##......", "..###....", ".........",
    ],
    "alta_magia": [        # hexagrama
        "....#....", "...#.#...", "#########", ".#.....#.", "..#...#..", ".#.....#.", "#########", "...#.#...", "....#....",
    ],
    "abismo": [            # olho de pupila fendida
        ".........", "..#####..", ".#..#..#.", "#..+#+..#", "#..+#+..#", "#..+#+..#", ".#..#..#.", "..#####..", ".........",
    ],
}
COR_TRAD = {  # disco do medalhão (fundo escuro, claro, símbolo)
    "indigena": [(64, 26, 14), (150, 66, 34), (255, 196, 110)], "cristianismo": [(20, 30, 70), (50, 76, 150), (255, 230, 150)],
    "taoismo": [(10, 50, 44), (30, 120, 104), (230, 250, 240)], "hinduismo": [(110, 44, 8), (214, 110, 26), (255, 230, 150)],
    "bruxaria": [(34, 18, 50), (84, 48, 116), (200, 160, 240)], "alta_magia": [(14, 12, 18), (50, 40, 60), (236, 196, 96)],
    "abismo": [(16, 4, 24), (60, 20, 80), (230, 120, 255)],
}
MADEIRA = [(90, 56, 38), (74, 45, 31), (51, 31, 22), (107, 70, 48)]


class Tela:
    """Tela em px nativos desenhada já ampliada (cada px nativo = S×S px) para o retrato liso caber por baixo."""
    def __init__(self, w, h, s):
        self.w, self.h, self.s = w, h, s
        self.im = Image.new("RGBA", (w * s, h * s), (0, 0, 0, 0))
        self.a = np.array(self.im)

    def px(self, x, y, cor, alfa=255):
        if 0 <= x < self.w and 0 <= y < self.h:
            s = self.s
            bloco = self.a[y * s:(y + 1) * s, x * s:(x + 1) * s]
            if alfa >= 255 or bloco[0, 0, 3] == 0:
                bloco[:] = (*cor, alfa)
            else:
                k = alfa / 255
                bloco[..., :3] = (bloco[..., :3] * (1 - k) + np.array(cor) * k).astype(np.uint8)

    def colar(self, img, x, y):
        self.im = Image.fromarray(self.a); self.im.alpha_composite(img, (x * self.s, y * self.s)); self.a = np.array(self.im)

    def imagem(self):
        return Image.fromarray(self.a)


def sd_arco(x, y, cx, larg, y_mola, y_base, d):
    """Distância assinada (negativa dentro) à janela em arco ogival: largura larg, mola do arco em y_mola, base y_base.
    d = afastamento dos centros dos arcos (0 = semicírculo; larg/2 = arco equilátero)."""
    r = larg / 2 + d
    topo = max(math.hypot(x - (cx + d), y - y_mola) - r, math.hypot(x - (cx - d), y - y_mola) - r)
    sa = max(topo, y - y_mola)
    sr = max(abs(x - cx) - larg / 2, y - y_base, y_mola - y)
    return min(sa, sr)


def tom(tons, v):
    return tons[max(0, min(len(tons) - 1, int(v * len(tons))))]


def moldura(t, ox, oy, mat, trad, retrato=None, larg=38, alt=50, aro=7, gema=True):
    """Desenha a moldura com a janela (larg × alt px nativos) começando em (ox, oy) = canto da janela.
    Devolve dict com o centro da base (para o medalhão) e o retângulo externo."""
    tons = MATERIAIS[mat]["tons"]
    cx = ox + larg / 2
    flecha = 15                                           # altura do arco acima da mola
    y_mola = oy + flecha
    y_base = oy + alt
    dd = larg * 0.28
    # retrato: janela inteira coberta, recortada pelo arco
    if retrato is not None:
        s = t.s
        r = retrato.copy()
        k = max(larg * s / r.width, alt * s / r.height)
        r = r.resize((max(1, round(r.width * k)), max(1, round(r.height * k))), Image.LANCZOS)
        r = r.crop(((r.width - larg * s) // 2, 0, (r.width - larg * s) // 2 + larg * s, alt * s))
        fundo = Image.new("RGBA", r.size, (*COR_TRAD[trad][0], 255))
        grad = np.zeros((alt * s, larg * s, 4), np.uint8)
        yy = np.linspace(0, 1, alt * s)[:, None]
        grad[..., :3] = (np.array(COR_TRAD[trad][1]) * (1 - yy[..., None] * 0.9) + np.array(COR_TRAD[trad][0]) * yy[..., None] * 0.9).astype(np.uint8)
        grad[..., 3] = 255
        fundo = Image.fromarray(grad); fundo.alpha_composite(r)
        m = np.zeros((alt * s, larg * s), np.uint8)
        for yy_ in range(alt):
            for xx_ in range(larg):
                if sd_arco(ox + xx_ + 0.5, oy + yy_ + 0.5, cx, larg, y_mola, y_base, dd) < 0:
                    m[yy_ * s:(yy_ + 1) * s, xx_ * s:(xx_ + 1) * s] = 255
        fundo.putalpha(Image.fromarray(m))
        t.colar(fundo, ox, oy)
    # sombra interna sobre o retrato (2 px, mais forte em cima/esquerda)
    for y in range(oy - aro - 6, y_base + aro + 2):
        for x in range(int(ox - aro - 2), int(ox + larg + aro + 2)):
            sd = sd_arco(x + 0.5, y + 0.5, cx, larg, y_mola, y_base, dd)
            if -2.5 < sd <= 0:
                gx = sd_arco(x + 1.5, y + 0.5, cx, larg, y_mola, y_base, dd) - sd_arco(x - 0.5, y + 0.5, cx, larg, y_mola, y_base, dd)
                gy = sd_arco(x + 0.5, y + 1.5, cx, larg, y_mola, y_base, dd) - sd_arco(x + 0.5, y - 0.5, cx, larg, y_mola, y_base, dd)
                face_luz = max(0.0, -(gx * LUZ[0] + gy * LUZ[1]))      # borda virada para a luz recebe mais sombra
                t.px(x, y, (8, 4, 8), int(150 * (1 + sd / 2.5) * (0.5 + 0.5 * face_luz)))
            elif 0 < sd <= aro:
                if sd > aro - 1:                                        # contorno externo
                    t.px(x, y, ESCURO); continue
                if sd <= 1:                                             # canaleta interna escura
                    t.px(x, y, tons[0]); continue
                gx = sd_arco(x + 1.5, y + 0.5, cx, larg, y_mola, y_base, dd) - sd_arco(x - 0.5, y + 0.5, cx, larg, y_mola, y_base, dd)
                gy = sd_arco(x + 0.5, y + 1.5, cx, larg, y_mola, y_base, dd) - sd_arco(x + 0.5, y - 0.5, cx, larg, y_mola, y_base, dd)
                n = np.array([gx, gy]); n = n / (np.linalg.norm(n) + 1e-6)
                u = (sd - 1) / (aro - 2)                                # 0 = lado de dentro, 1 = lado de fora
                if 0.42 < u < 0.58 and aro >= 7:                        # filete gravado no meio do aro
                    luz = 0.5 + 0.5 * float(-n @ LUZ) * 0.6
                    t.px(x, y, tom(tons, 0.15 + 0.35 * luz)); continue
                normal = -math.cos(math.pi * u) * n                     # aro abaulado: metade de dentro olha para a janela
                luz = 0.52 + 0.62 * float(normal @ -LUZ)
                t.px(x, y, tom(tons, luz))
    r_arco = larg / 2 + dd
    topo_y = oy - (math.sqrt(r_arco ** 2 - dd ** 2) - flecha) - aro
    # folhas góticas (crockets) subindo pelo extradorso do arco: 3 de cada lado, cada uma uma bolota com a ponta
    # enrolada para cima, na direção da chave
    a_mola, a_topo = math.pi, math.atan2(-math.sqrt(r_arco ** 2 - dd ** 2), -dd) + 2 * math.pi   # π → ~1,4π (sobe pela esquerda)
    for lado in (-1, 1):
        ccx = cx + dd if lado < 0 else cx - dd
        for k in (0.30, 0.56, 0.80):
            a = a_mola + (a_topo - a_mola) * k if lado < 0 else math.pi - (a_mola + (a_topo - a_mola) * k)
            rr = r_arco + aro + 0.4
            fx, fy = ccx + rr * math.cos(a), y_mola + rr * math.sin(a)
            folha(t, fx, fy, lado, tons)
    # rodapé: a base da moldura alarga 2 px de cada lado, com bisel horizontal (luz em cima)
    rodape(t, ox - aro - 2, y_base + aro - 5, larg + 2 * aro + 4, 5, tons)
    # bolotas na mola do arco e nas pontas do rodapé
    for bx, by in ((ox - aro + 0.5, y_mola), (ox + larg + aro - 0.5, y_mola)):
        esfera(t, bx, by, 2.6, tons)
    for bx in (ox - aro - 1.5, ox + larg + aro + 1.5):
        esfera(t, bx, y_base + aro - 3.5, 2.2, tons)
    # chave do arco: pináculo de metal + gema facetada com garras
    if gema:
        pinaculo(t, cx, topo_y - 3, tons)
        gema_facetada(t, cx, topo_y + 2, MATERIAIS[mat]["gema"], tons)
    return {"base": (cx, y_base + aro - 1), "ext": (ox - aro, topo_y, larg + 2 * aro, y_base + aro - topo_y)}


def folha(t, x, y, lado, tons):
    """Folha gótica 5×5: bolota sombreada com a ponta enrolada para dentro/para cima (lado -1 = esquerda)."""
    x, y = int(round(x)), int(round(y))
    forma = ["..##.", ".#OO#", "#OOO#", "#OO#.", ".##.."]
    for yy, row in enumerate(forma):
        for xx, ch in enumerate(row):
            xr = xx if lado < 0 else 4 - xx
            if ch == "#":
                t.px(x - 2 + xr, y - 2 + yy, ESCURO)
            elif ch == "O":
                luz = 0.85 if (yy <= 2 and xr <= 2) else (0.55 if yy <= 2 or xr <= 2 else 0.3)
                t.px(x - 2 + xr, y - 2 + yy, tom(tons, luz))


def pinaculo(t, cx, y, tons):
    """Ponta do arco: lança de 3 px de largura subindo 6 px, com luz à esquerda."""
    cx = int(round(cx)); y = int(round(y))
    for yy in range(-6, 2):
        w = 0 if yy < -4 else (1 if yy < 0 else 2)
        for xx in range(-w - 1, w + 2):
            if abs(xx) == w + 1:
                t.px(cx + xx, y + yy, ESCURO)
            else:
                t.px(cx + xx, y + yy, tom(tons, 0.9 if xx < 0 else (0.6 if xx == 0 else 0.3)))
    t.px(cx, y - 7, ESCURO)


def rodape(t, x0, y0, w, h, tons):
    x0, y0 = int(round(x0)), int(round(y0))
    for yy in range(h):
        for xx in range(w):
            if yy == 0 or yy == h - 1 or xx == 0 or xx == w - 1:
                t.px(x0 + xx, y0 + yy, ESCURO)
            else:
                t.px(x0 + xx, y0 + yy, tom(tons, 0.92 if yy == 1 else (0.6 if yy == 2 else 0.28)))


def esfera(t, cx, cy, r, tons):
    for y in range(int(cy - r - 1), int(cy + r + 2)):
        for x in range(int(cx - r - 1), int(cx + r + 2)):
            d = math.hypot(x + 0.5 - cx, y + 0.5 - cy)
            if d <= r + 0.6:
                if d > r - 0.4:
                    t.px(x, y, ESCURO); continue
                nx, ny = (x + 0.5 - cx) / r, (y + 0.5 - cy) / r
                t.px(x, y, tom(tons, 0.55 - 0.65 * (nx * LUZ[0] + ny * LUZ[1]) * -1 * -1 + (0.35 if nx < -0.2 and ny < -0.2 else 0)))


def gema_facetada(t, cx, cy, cores, tons):
    """Losango 9×11 com facetas: garras de metal em volta, faceta clara em cima-esquerda, escura embaixo-direita."""
    cx = int(round(cx)); cy = int(round(cy))
    for y in range(-6, 7):
        for x in range(-5, 6):
            d = abs(x) / 5 + abs(y) / 6
            if d <= 1.15:
                if d > 1.0:
                    t.px(cx + x, cy + y, ESCURO); continue
                if d > 0.8:
                    t.px(cx + x, cy + y, tom(tons, 0.55 - 0.35 * (x + y) / 6)); continue      # garra de metal
                if x <= 0 and y <= 0:
                    c = cores[2] if (x > -2 and y > -3) else cores[1]
                elif x > 0 and y > 0:
                    c = cores[0]
                else:
                    c = cores[1]
                t.px(cx + x, cy + y, c)
    t.px(cx - 1, cy - 2, (255, 255, 255))


def medalhao(t, cx, cy, trad, tons, r=9):
    cx = int(round(cx)); cy = int(round(cy))
    esc, med, sim = COR_TRAD[trad]
    for y in range(-r - 1, r + 2):
        for x in range(-r - 1, r + 2):
            d = math.hypot(x + 0.5 - 0.5, y + 0.5 - 0.5)
            if d > r + 0.5:
                continue
            if d > r - 0.5:
                t.px(cx + x, cy + y, ESCURO); continue
            if d > r - 3:                                   # aro de 2 px com bisel
                n = np.array([x, y]) / (d + 1e-6)
                u = (d - (r - 3)) / 2.5
                normal = -math.cos(math.pi * u) * n
                t.px(cx + x, cy + y, tom(tons, 0.52 + 0.62 * float(normal @ -LUZ))); continue
            if d > r - 3.6:
                t.px(cx + x, cy + y, ESCURO); continue
            k = min(1.0, math.hypot(x + 2, y + 2) / (r - 2))           # disco com luz deslocada para cima-esquerda
            c = tuple(int(med[i] * (1 - k) + esc[i] * k) for i in range(3))
            t.px(cx + x, cy + y, c)
    g = SIMBOLOS[trad]
    sx, sy = cx - len(g[0]) // 2, cy - len(g) // 2
    for yy, row in enumerate(g):
        for xx, ch in enumerate(row):
            if ch == "#":
                t.px(sx + xx + 1, sy + yy + 1, esc)                  # sombra do relevo
    for yy, row in enumerate(g):
        for xx, ch in enumerate(row):
            if ch == "#":
                t.px(sx + xx, sy + yy, sim)
            elif ch == "+":
                t.px(sx + xx, sy + yy, tuple(int(sim[i] * 0.55 + med[i] * 0.45) for i in range(3)))


def barra_vida(t, cx, y, larg, vida, vida_max, tons):
    """Barra de Cornucópia: pontas em ponta de lança, moldura de metal com bisel, calha escura, preenchimento vermelho
    com brilho em cima, marcas a cada 5 pontos e o número no centro com contorno."""
    h = 11
    x0 = int(round(cx - larg / 2))
    for yy in range(h):
        for xx in range(larg):
            # distância à forma: retângulo com pontas em losango (4 px)
            dy = abs(yy + 0.5 - h / 2)
            borda_x = min(xx + 0.5, larg - xx - 0.5)
            dentro = borda_x - dy * 0.8
            if dentro < 0:
                continue
            if dentro < 1 or yy == 0 or yy == h - 1:
                t.px(x0 + xx, y + yy, ESCURO); continue
            if dentro < 2.6 or yy == 1 or yy == h - 2:              # metal 1 px
                t.px(x0 + xx, y + yy, tom(tons, 0.85 if yy <= 2 else (0.25 if yy >= h - 3 else 0.55))); continue
            t.px(x0 + xx, y + yy, (26, 12, 16))
    # preenchimento
    ini, fim = x0 + 4, x0 + larg - 4
    cheio = ini + round((fim - ini) * max(0, vida) / vida_max)
    for xx in range(ini, cheio):
        for yy in range(2, h - 2):
            c = (255, 132, 112) if yy == 2 else ((222, 52, 52) if yy < 6 else ((168, 28, 36) if yy < 8 else (110, 14, 24)))
            t.px(xx, y + yy, c)
    s = str(vida)
    w = FP.largura(s)
    xs, ys = int(round(cx - w / 2)), y + 2
    for k in range(1, vida_max // 5):                              # marcas a cada 5 (menos atrás do número)
        xm = ini + round((fim - ini) * k * 5 / vida_max)
        if xs - 4 <= xm <= xs + w + 3:
            continue
        for yy in range(3, h - 3):
            t.px(xm, y + yy, (60, 8, 14) if xm < cheio else (50, 34, 40))
    for xx in range(xs - 3, xs + w + 3):                           # cartucho escuro atrás do número
        for yy in range(1, h - 1):
            if (xx in (xs - 3, xs + w + 2)) and yy in (1, h - 2):
                continue
            t.px(xx, y + yy, ESCURO if xx in (xs - 3, xs + w + 2) or yy in (1, h - 2) else (40, 14, 20))
    FP.desenhar(t.px, xs, ys, s, (255, 246, 230), sombra=(0, 0, 0))


def plaquinha(t, cx, y, nome):
    """Plaquinha de madeira com o nome entalhado (mesmo desenho da mesa: veio, luz em cima, sombra embaixo, 2 pregos)."""
    w = FP.largura(nome) + 20
    x0 = int(round(cx - w / 2))
    for yy in range(-1, 13):
        for xx in range(-1, w + 1):
            if yy in (-1, 12) or xx in (-1, w):
                t.px(x0 + xx, y + yy, ESCURO); continue
            c = MADEIRA[0]
            if yy in (3, 6, 9) and 2 <= xx < w - 2:
                c = MADEIRA[1]
            if yy == 0:
                c = tuple(min(255, int(v * 1.25)) for v in MADEIRA[3])
            if yy == 11:
                c = tuple(int(v * 0.7) for v in MADEIRA[2])
            t.px(x0 + xx, y + yy, c)
    for px_ in (x0 + 3, x0 + w - 4):
        t.px(px_, y + 5, (226, 184, 90)); t.px(px_ + 1, y + 5, (156, 116, 48)); t.px(px_, y + 6, (156, 116, 48)); t.px(px_ + 1, y + 6, (110, 80, 30))
    xs = int(round(cx - FP.largura(nome) / 2))
    FP.desenhar(t.px, xs, y + 3, nome, tuple(min(255, int(v * 1.35)) for v in MADEIRA[3]))   # borda do corte pegando luz
    FP.desenhar(t.px, xs, y + 2, nome, (36, 19, 12))                                         # fundo do entalhe


def fita_nivel(t, cx, y, texto, tons):
    """Fita com o nível: faixa escura com cauda bifurcada dos dois lados, filete do metal e texto na fonte 3×5."""
    w = FP.largura(texto, FP.F35) + 12
    x0 = int(round(cx - w / 2))
    for yy in range(9):                                             # caudas: 5 px, um degrau abaixo, corte em V
        for f in range(1, 6):
            if abs(yy - 4) <= 3 and not (f >= 3 and abs(yy - 4) < f - 2):
                borda = abs(yy - 4) == 3 or f == 5 or (f >= 3 and abs(yy - 4) == f - 2)
                c = ESCURO if borda else (64, 18, 32)
                t.px(x0 - f, y + yy + 2, c); t.px(x0 + w - 1 + f, y + yy + 2, c)
    for yy in range(9):
        for xx in range(w):
            if yy in (0, 8) or xx in (0, w - 1):
                t.px(x0 + xx, y + yy, ESCURO)
            elif yy == 1:
                t.px(x0 + xx, y + yy, tons[3])
            elif yy == 7:
                t.px(x0 + xx, y + yy, tons[1])
            else:
                t.px(x0 + xx, y + yy, (96, 30, 48))
    FP.desenhar(t.px, x0 + 6, y + 2, texto, tons[4], FP.F35, sombra=ESCURO)


def composicao(t, ox, oy, mat, trad, retrato, nome, nivel, vida, vida_max=15, rotulo_nivel="NV"):
    info = moldura(t, ox, oy, mat, trad, retrato)
    bx, by = info["base"]
    larg_ext = info["ext"][2]
    barra_vida(t, bx, int(by) + 8, larg_ext + 10, vida, vida_max, MATERIAIS[mat]["tons"])
    medalhao(t, bx, by, trad, MATERIAIS[mat]["tons"])
    plaquinha(t, bx, int(by) + 21, nome)
    fita_nivel(t, bx, int(by) + 35, f"{rotulo_nivel} {nivel}", MATERIAIS[mat]["tons"])
    return info


def retrato(trad):
    p = os.path.join(RAIZ, "godot", "assets", "retrato", trad + ".png")
    return Image.open(p).convert("RGBA") if os.path.exists(p) else None


def main():
    os.makedirs(OUT, exist_ok=True)
    S = 4
    casos = [("bronze", "indigena", "Moema Arani", 3, 15), ("prata", "cristianismo", "Frei Bento", 12, 11),
             ("ouro", "hinduismo", "Aditya Rao", 25, 7), ("jade", "taoismo", "Lin Yuehua", 40, 15),
             ("obsidiana", "alta_magia", "Silas Ashcombe", 50, 3)]
    W, H = 92 * len(casos) + 8, 160
    t = Tela(W, H, S)
    t.a[..., :3] = (34, 22, 30); t.a[..., 3] = 255
    for i, (mat, trad, nome, nv, vida) in enumerate(casos):
        composicao(t, 8 + i * 92 + 27, 34, mat, trad, retrato(trad), nome, nv, vida)
        FP.desenhar(t.px, 8 + i * 92 + 46 - FP.largura(MATERIAIS[mat]["nome"]) // 2, 150, MATERIAIS[mat]["nome"], (200, 190, 200))
    t.imagem().save(os.path.join(OUT, "folha_molduras.png"))
    # símbolos das tradições
    t2 = Tela(7 * 24 + 4, 28, S)
    t2.a[..., :3] = (34, 22, 30); t2.a[..., 3] = 255
    for i, trad in enumerate(SIMBOLOS):
        medalhao(t2, 14 + i * 24, 13, trad, MATERIAIS["ouro"]["tons"])
    t2.imagem().save(os.path.join(OUT, "folha_simbolos.png"))
    print("ok", OUT)


if __name__ == "__main__":
    main()
