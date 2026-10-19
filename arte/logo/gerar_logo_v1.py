"""Logo KodeX: "ΚΟΔΕ" em letras gregas (lê-se KODE) gravadas em ouro + um X grande de pincel/tinta (o "versus").
Saídas (fundo transparente): logo_kodex.png (1600 px), logo_kodex_jogo.png (640 px, para o menu), previa_*.png.
Uso: /mnt/d/Comfy-Desktop/venv/bin/python gerar_logo.py"""
import math, os, random
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageChops

AQUI = os.path.dirname(os.path.abspath(__file__))
FONTE = "/usr/share/fonts/noto/NotoSerifDisplay-Black.ttf"
W, H = 1600, 640
rng = random.Random(7)


def texto_grego():
    """ΚΟΔΕ em ouro com bisel, contorno escuro e sombra. Devolve a camada e a caixa ocupada."""
    f = ImageFont.truetype(FONTE, 330)
    txt = "ΚΟΔΕ"
    mask = Image.new("L", (W, H), 0)
    d = ImageDraw.Draw(mask)
    x0, y0 = 70, 120
    d.text((x0, y0), txt, font=f, fill=255)
    bb = mask.getbbox()
    a = np.asarray(mask).astype(np.float32) / 255
    # degradê de ouro vertical + bisel (luz em cima-esquerda) pela derivada da máscara suavizada
    yy = np.linspace(0, 1, H)[:, None]
    ouro = np.dstack([255 - 30 * yy, 226 - 90 * yy, 140 - 110 * yy]).repeat(W, 1) if False else None
    t = np.clip((np.arange(H)[:, None] - bb[1]) / max(bb[3] - bb[1], 1), 0, 1)
    r = 255 - 40 * t; g = 232 - 120 * t; b = 150 - 130 * t
    base = np.dstack([np.broadcast_to(r, (H, W)), np.broadcast_to(g, (H, W)), np.broadcast_to(b, (H, W))])
    blur = np.asarray(mask.filter(ImageFilter.GaussianBlur(6))).astype(np.float32) / 255
    gy, gx = np.gradient(blur)
    luz = np.clip(-(gx + gy) * 9, -1, 1)[..., None]
    cor = np.clip(base + luz * 70, 0, 255)
    # veio/grão leve
    cor *= (0.94 + 0.06 * np.random.default_rng(3).random((H, W)))[..., None]
    camada = Image.fromarray(np.dstack([cor, a * 255]).astype(np.uint8), "RGBA")
    # contorno escuro + sombra
    cont = mask.filter(ImageFilter.MaxFilter(15))
    sombra = cont.filter(ImageFilter.GaussianBlur(10))
    out = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    out.paste(Image.new("RGBA", (W, H), (0, 0, 0, 170)), (10, 14), sombra)
    out.paste(Image.new("RGBA", (W, H), (26, 14, 10, 255)), (0, 0), cont)
    out.alpha_composite(camada)
    # filete fino claro por dentro do contorno (gravação)
    return out, bb


def pincelada(img, p0, p1, larg, rng_np):
    """Pincelada seca: ~70 cerdas paralelas; cada cerda tem início/fim próprios, falhas (tinta acabando) e
    espessura variável. Entra larga e afina na ponta. Escreve alfa (0..1) em `img` (array H×W)."""
    p0 = np.array(p0, float); p1 = np.array(p1, float)
    v = p1 - p0; L = np.linalg.norm(v); u = v / L; n = np.array([-u[1], u[0]])
    for k in range(70):
        off = (k / 69 - 0.5) * 2                       # -1..1 ao longo da largura
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
    cx, cy = 1265, 336
    pincelada(a, (cx - 250, cy - 300), (cx + 245, cy + 290), 46, rng_np)
    pincelada(a, (cx + 240, cy - 295), (cx - 255, cy + 285), 40, rng_np)
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
    logo.alpha_composite(x_de_tinta())          # o X fica por trás da borda do Ε e por cima do fundo
    logo.alpha_composite(letras)
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
