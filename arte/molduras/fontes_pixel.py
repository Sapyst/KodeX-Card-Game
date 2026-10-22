"""Lê as fontes pixel do jogo direto dos scripts Godot (godot/fonte57.gd e godot/pixel_fonte.gd) para desenhar
texto idêntico ao do jogo nas prévias (Pillow / numpy)."""
import os, re
RAIZ = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def _ler(arq):
    s = open(os.path.join(RAIZ, "godot", arq), encoding="utf-8").read()
    g = {}
    for m in re.finditer(r'"((?:\\"|[^"])+)":\s*\[([^\]]*)\]', s[s.index("const G"):]):
        ch = m.group(1).encode().decode("unicode_escape").encode("latin-1").decode("utf-8") if "\\" in m.group(1) else m.group(1)
        linhas = re.findall(r'"([01]+)"', m.group(2))
        if linhas:
            g[ch] = linhas
    return g


F57 = _ler("fonte57.gd")
F35 = _ler("pixel_fonte.gd")


def largura(s, fonte=F57):
    w = 0
    for ch in s:
        w += len(fonte.get(ch, fonte["?"])[0]) + 1
    return max(w - 1, 0)


def desenhar(px, x, y, s, cor, fonte=F57, sombra=None):
    """px: função px(x, y, cor). Glifos com mais de 7 (ou 5) linhas sobem (acento de maiúscula)."""
    base = 7 if fonte is F57 else 5
    for ch in s:
        g = fonte.get(ch, fonte["?"])
        off = len(g) - base
        for yy, row in enumerate(g):
            for xx, b in enumerate(row):
                if b == "1":
                    if sombra:
                        px(x + xx + 1, y + yy - off + 1, sombra)
                    px(x + xx, y + yy - off, cor)
        x += len(g[0]) + 1
