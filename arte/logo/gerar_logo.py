"""Logo KodeX: "ΚΟΔΕ" em letras gregas (lê-se KODE) gravadas em ouro + um X grande de pincel/tinta (o "versus").
Saídas (fundo transparente): logo_kodex.png (1600 px), logo_kodex_jogo.png (640 px, para o menu), previa_*.png.
Uso: /mnt/d/Comfy-Desktop/venv/bin/python gerar_logo.py"""
import math, os, random
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageChops

AQUI = os.path.dirname(os.path.abspath(__file__))
FONTE = "/usr/share/fonts/noto/NotoSerifDisplay-Black.ttf"
W, H = 1900, 700
rng = random.Random(7)


# Letras gregas desenhadas à mão em pixel art (16×22 px cada), estilo inscrição: hastes grossas, serifas em cunha,
# o Δ como triângulo aberto e o Ο como elipse alta. "#" = ouro; o sombreado vem da posição (luz em cima).
GLIFOS = {
 "Κ": [
  "#####......####.",
  ".###......###...",
  ".###.....###....",
  ".###....###.....",
  ".###...###......",
  ".###..###.......",
  ".###.###........",
  ".######.........",
  ".#######........",
  ".###.####.......",
  ".###..####......",
  ".###...####.....",
  ".###....####....",
  ".###.....####...",
  ".###......####..",
  ".###.......####.",
  "#####.....######",
 ],
 "Ο": [
  ".....######.....",
  "...###....###...",
  "..###......###..",
  ".###........###.",
  ".###........###.",
  "###..........###",
  "###..........###",
  "###..........###",
  "###..........###",
  "###..........###",
  "###..........###",
  "###..........###",
  ".###........###.",
  ".###........###.",
  "..###......###..",
  "...###....###...",
  ".....######.....",
 ],
 "Δ": [
  ".......##.......",
  ".......###......",
  "......####......",
  "......#####.....",
  ".....###.###....",
  ".....###.###....",
  "....###...###...",
  "....###...###...",
  "...###.....###..",
  "...###.....###..",
  "..###.......###.",
  "..###.......###.",
  ".###.........###",
  ".###.........###",
  "###...........##",
  "################",
  "################",
 ],
 "Ε": [
  "###############.",
  ".###.........##.",
  ".###..........#.",
  ".###............",
  ".###............",
  ".###............",
  ".###............",
  ".##########.....",
  ".###............",
  ".###............",
  ".###............",
  ".###............",
  ".###..........#.",
  ".###.........##.",
  ".###........###.",
  "################",
  "################",
 ],
}
OURO_PX = [(255, 241, 176), (246, 212, 120), (226, 172, 74), (180, 120, 44), (122, 74, 28)]


def texto_grego():
    """ΚΟΔΕ em pixel art (sem contorno), ampliado ×ESC com vizinho mais próximo. Sombreado em 5 tons de ouro:
    claro em cima e na borda superior-esquerda de cada traço, escuro embaixo e na borda inferior-direita."""
    gw, gh, esp = 16, 17, 3
    txt = "ΚΟΔΕ"
    larg = len(txt) * gw + (len(txt) - 1) * esp
    px = Image.new("RGBA", (larg, gh), (0, 0, 0, 0))
    p = px.load()
    for k, ch in enumerate(txt):
        g = GLIFOS[ch]
        x0 = k * (gw + esp)
        on = lambda x, y: 0 <= y < gh and 0 <= x < gw and g[y][x] == "#"
        for y in range(gh):
            for x in range(gw):
                if not on(x, y):
                    continue
                t = y / (gh - 1)
                nivel = 1 if t < 0.3 else 2 if t < 0.7 else 3
                if not on(x, y - 1) or not on(x - 1, y):
                    nivel -= 1                       # borda de cima/esquerda pega luz
                if not on(x, y + 1) or not on(x + 1, y):
                    nivel += 1                       # borda de baixo/direita na sombra
                p[x0 + x, y] = OURO_PX[max(0, min(4, nivel))] + (255,)
    esc = 18
    big = px.resize((larg * esc, gh * esc), Image.NEAREST)
    out = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ox, oy = 60, (H - big.height) // 2 + 20
    # sombra projetada suave (não é contorno): o mesmo desenho, escuro, deslocado 1 px de arte para baixo-direita
    sombra = Image.new("RGBA", big.size, (20, 8, 6, 150)); sombra.putalpha(big.split()[3].point(lambda v: 150 if v else 0))
    out.alpha_composite(sombra, (ox + esc, oy + esc))
    out.alpha_composite(big, (ox, oy))
    return out, (ox, oy, ox + big.width, oy + big.height)


def pincelada(img, p0, p1, larg, rng_np):
    """Pincelada seca: ~70 cerdas paralelas; cada cerda tem início/fim próprios, falhas (tinta acabando) e
    espessura variável. Entra larga e afina na ponta. Escreve alfa (0..1) em `img` (array H×W)."""
    p0 = np.array(p0, float); p1 = np.array(p1, float)
    v = p1 - p0; L = np.linalg.norm(v); u = v / L; n = np.array([-u[1], u[0]])
    for k in range(110):
        off = (k / 109 - 0.5) * 2                       # -1..1 ao longo da largura
        ini = rng_np.uniform(0, 0.08) + abs(off) ** 3 * 0.10
        fim = rng_np.uniform(0.80, 1.0) - abs(off) ** 2 * 0.25
        carga = rng_np.uniform(0.55, 1.0)
        fase = rng_np.uniform(0, 10)
        for i in range(int(L / 1.5)):
            t = i / (L / 1.5)
            if t < ini or t > fim:
                continue
            # tinta acabando: falhas mais frequentes no fim e nas cerdas de fora
            seco = (t - 0.35) * 1.6 + abs(off) * 0.6
            if rng_np.random() < max(0.0, seco) * 0.55 + 0.03 * math.sin(t * 40 + fase) ** 2:
                continue
            afina = 1.0 - 0.55 * t                      # pincel abre no começo, afina no fim
            q = p0 + v * t + n * off * larg * afina + n * math.sin(t * 6 + fase * 0.3) * 3
            r = 1.6 + 1.4 * carga
            x0, y0 = int(q[0] - r), int(q[1] - r)
            x1, y1 = int(q[0] + r) + 1, int(q[1] + r) + 1
            if x0 < 0 or y0 < 0 or x1 >= img.shape[1] or y1 >= img.shape[0]:
                continue
            img[y0:y1, x0:x1] = np.maximum(img[y0:y1, x0:x1], carga)


def x_de_tinta():
    """X de pincel seco, vermelho-escuro quase preto, maior que as letras, invadindo um pouco o Ε, com respingos."""
    rng_np = np.random.default_rng(11)
    a = np.zeros((H, W), np.float32)
    cx, cy = 1530, 330                                         # mais à esquerda: o braço de baixo cobre parte do Ε
    def gira(px, py, ang=math.radians(-9)):                  # X torto, tombado na diagonal
        dx, dy = px - cx, py - cy
        return (cx + dx * math.cos(ang) - dy * math.sin(ang), cy + dx * math.sin(ang) + dy * math.cos(ang))
    pincelada(a, gira(cx - 255, cy - 300), gira(cx + 245, cy + 290), 78, rng_np)
    pincelada(a, gira(cx + 235, cy - 300), gira(cx - 260, cy + 285), 70, rng_np)
    m = Image.fromarray((a * 255).astype(np.uint8))
    d = ImageDraw.Draw(m)
    for _ in range(38):                                        # respingos e gotas
        ang = rng.uniform(0, math.tau); dist = rng.uniform(170, 330)
        r = rng.choice([2, 3, 3, 5, 7, 10])
        x, y = cx + math.cos(ang) * dist, cy + math.sin(ang) * dist * 0.9
        d.ellipse((x - r, y - r, x + r, y + r), fill=int(255 * rng.uniform(0.7, 1.0)))
    m = m.filter(ImageFilter.GaussianBlur(0.8))
    a = np.asarray(m).astype(np.float32) / 255
    # cor: onde a tinta acumula (cerdas juntas) é vermelho-sangue; nas bordas e falhas, quase preto
    dens = np.asarray(m.filter(ImageFilter.GaussianBlur(5))).astype(np.float32) / 255
    r = 40 + 150 * dens ** 1.5; g = 4 + 10 * dens; b = 8 + 12 * dens
    cor = np.dstack([r, g, b])
    camada = Image.fromarray(np.dstack([np.clip(cor, 0, 255), np.clip(a * 1.15, 0, 1) * 255]).astype(np.uint8), "RGBA")
    sombra = m.filter(ImageFilter.GaussianBlur(10))
    out = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    out.paste(Image.new("RGBA", (W, H), (0, 0, 0, 120)), (8, 12), sombra)
    out.alpha_composite(camada)
    return out


def main():
    letras, bb = texto_grego()
    logo = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    logo.alpha_composite(letras)
    logo.alpha_composite(x_de_tinta())          # o X vem POR CIMA do Ε
    logo = logo.crop(logo.getbbox())
    logo.save(os.path.join(AQUI, "logo_kodex.png"))
    jogo = logo.copy(); jogo.thumbnail((640, 640), Image.LANCZOS); jogo.save(os.path.join(AQUI, "logo_kodex_jogo.png"))
    for nome, fundo in (("escuro", (13, 11, 18)), ("claro", (236, 230, 220))):
        p = Image.new("RGBA", (logo.width + 160, logo.height + 160), fundo + (255,))
        p.alpha_composite(logo, (80, 80))
        p.convert("RGB").save(os.path.join(AQUI, f"previa_{nome}.png"))
    print("ok", logo.size)


if __name__ == "__main__":
    main()
