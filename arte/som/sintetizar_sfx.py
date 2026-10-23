"""Efeitos sonoros do KodeX sintetizados por código (sem IA, sem samples), a partir de docs/audio/catalogo_animacoes.md.
Cada som = soma de camadas simples: ruído filtrado com envelope, varreduras de seno, sinos FM inarmônicos, grãos de
estalo, coro com formantes e um reverb curto de convolução. Saída: godot/audio/sfx/<id>[_<variação>].ogg (44,1 kHz,
estéreo, pico −1 dBFS) + arte/som/sfx_previa.wav (todos em sequência, para ouvir de uma vez).

Uso: /mnt/d/Comfy-Desktop/venv/bin/python arte/som/sintetizar_sfx.py [id ...]
"""
import os, subprocess, sys
import numpy as np
from scipy import signal
from scipy.io import wavfile

AQUI = os.path.dirname(os.path.abspath(__file__))
RAIZ = os.path.dirname(os.path.dirname(AQUI))
OUT = os.path.join(RAIZ, "godot", "audio", "sfx")
SR = 44100
rng = np.random.default_rng(2026)


# ---------------------------------------------------------------- blocos básicos
def t_(dur):
    return np.arange(int(SR * dur)) / SR


def ruido(dur, cor="branco"):
    n = int(SR * dur)
    x = rng.standard_normal(n)
    if cor == "rosa":                       # 1/f aproximado (filtro de Paul Kellet)
        b = [0.049922035, -0.095993537, 0.050612699, -0.004408786]
        a = [1, -2.494956002, 2.017265875, -0.522189400]
        x = signal.lfilter(b, a, x) * 6
    elif cor == "marrom":
        x = np.cumsum(x) * 0.02
        x = x - signal.lfilter([1], [1, -0.995], x) * 0.005
        x -= np.mean(x)
    return x / (np.max(np.abs(x)) + 1e-9)


def filtro(x, tipo, f, ordem=2):
    ny = SR / 2
    if tipo == "faixa":
        b, a = signal.butter(ordem, [max(20, f[0]) / ny, min(f[1], ny * 0.98) / ny], "band")
    else:
        b, a = signal.butter(ordem, min(f, ny * 0.98) / ny, "low" if tipo == "baixa" else "high")
    return signal.lfilter(b, a, x)


def filtro_varre(x, f0, f1, q=2.0, tipo="faixa"):
    """Filtro de estado variável com frequência varrendo de f0 a f1 (exponencial) ao longo do som."""
    n = len(x)
    fc = f0 * (f1 / f0) ** (np.arange(n) / max(1, n - 1))
    g = np.tan(np.pi * np.clip(fc, 20, SR * 0.45) / SR)
    k = 1 / q
    ic1 = ic2 = 0.0
    out = np.zeros(n)
    for i in range(n):
        v3 = x[i] - ic2
        v1 = (g[i] * v3 + ic1) / (1 + g[i] * (g[i] + k))
        v2 = ic2 + g[i] * v1
        ic1 = 2 * v1 - ic1
        ic2 = 2 * v2 - ic2
        out[i] = v1 if tipo == "faixa" else (v2 if tipo == "baixa" else x[i] - k * v1 - v2)
    return out


def env(n_ou_dur, ataque=0.005, decai=0.1, sustenta=0.0, curva=4.0):
    """Envelope ataque linear + decaimento exponencial (curva = quão rápido cai)."""
    n = n_ou_dur if isinstance(n_ou_dur, int) else int(SR * n_ou_dur)
    t = np.arange(n) / SR
    e = np.where(t < ataque, t / max(ataque, 1e-6), 1.0)
    pos = np.clip(t - ataque - sustenta, 0, None)
    e = e * np.exp(-curva * pos / max(decai, 1e-4))
    return e


def seno_varre(dur, f0, f1, curva="exp"):
    t = t_(dur)
    if curva == "exp":
        f = f0 * (f1 / f0) ** (t / dur)
    else:
        f = f0 + (f1 - f0) * t / dur
    return np.sin(2 * np.pi * np.cumsum(f) / SR)


def sino(dur, f, razoes=(1, 2.76, 5.4, 8.93), amps=(1, 0.5, 0.25, 0.12), decai=1.0, brilho=1.0):
    """Sino/tigela: parciais inarmônicas, as agudas decaem mais rápido."""
    t = t_(dur)
    x = np.zeros_like(t)
    for r, a in zip(razoes, amps):
        x += a * np.sin(2 * np.pi * f * r * t + rng.uniform(0, 6.28)) * np.exp(-t * (1.5 + r * 0.8 / brilho) / decai)
    return x * env(len(t), 0.002, dur, curva=0.01)


def fm(dur, fc, razao, indice, decai=0.5):
    t = t_(dur)
    i = indice * np.exp(-t * 3 / decai)
    return np.sin(2 * np.pi * fc * t + i * np.sin(2 * np.pi * fc * razao * t)) * np.exp(-t / decai)


def tic(f=3000, dur=0.012, q=4):
    x = ruido(dur) * env(int(SR * dur), 0.0005, dur * 0.5, curva=6)
    return filtro(x, "faixa", (f / (1 + 1 / q), f * (1 + 1 / q)))


def coro(dur, notas, formantes=(700, 1200, 2600), ataque=0.25):
    """'Aaah' sintético: serras levemente desafinadas por nota, passadas por 3 formantes de vogal."""
    t = t_(dur)
    x = np.zeros_like(t)
    for f in notas:
        for d in (-0.006, 0, 0.007):
            ff = f * (1 + d) * (1 + 0.004 * np.sin(2 * np.pi * 5.2 * t + rng.uniform(0, 6)))
            fase = np.cumsum(ff) / SR
            x += 2 * (fase % 1) - 1
    y = sum(filtro(x, "faixa", (fo * 0.85, fo * 1.15)) * g for fo, g in zip(formantes, (1, 0.6, 0.25)))
    return y * env(len(t), ataque, dur * 0.6, sustenta=dur * 0.3, curva=3)


def reverb(x, tam=0.8, mistura=0.25, brilho=6000):
    ir = ruido(tam) * np.exp(-6 * t_(tam) / tam)
    ir = filtro(ir, "baixa", brilho)
    ir[: int(SR * 0.012)] = 0                      # pré-atraso
    wet = signal.fftconvolve(x, ir)
    wet = np.concatenate([wet, np.zeros(len(x) + len(ir) - len(wet))])
    seco = np.concatenate([x, np.zeros(len(ir))])
    wet = wet / (np.max(np.abs(wet)) + 1e-9) * (np.max(np.abs(x)) + 1e-9)
    return seco * (1 - mistura) + wet * mistura


def mix(*partes):
    """partes = (sinal, início_s, ganho). Devolve a soma."""
    n = max(int(SR * ini) + len(s) for s, ini, g in partes)
    y = np.zeros(n)
    for s, ini, g in partes:
        i = int(SR * ini)
        y[i:i + len(s)] += s * g
    return y


def estereo(x, pan=0.0, largura=0.0):
    """pan −1..1; largura: atraso de até 0,6 ms entre canais (sensação de espaço)."""
    l = x * np.sqrt((1 - pan) / 2) * 1.414
    r = x * np.sqrt((1 + pan) / 2) * 1.414
    if largura > 0:
        d = int(SR * 0.0006 * largura)
        r = np.concatenate([np.zeros(d), r[:-d]]) if d > 0 else r
    return np.stack([l, r], 1)


def chuva_tics(n, ini, passo, f=(2200, 5000), jitter=0.008, ganho_fim=0.6):
    partes = []
    for k in range(n):
        g = 1 - (1 - ganho_fim) * k / max(1, n - 1)
        partes.append((tic(rng.uniform(*f) * (1 - 0.3 * k / n), rng.uniform(0.006, 0.012)), ini + k * passo + rng.uniform(0, jitter), g * rng.uniform(0.6, 1)))
    return mix(*partes)


def fwip(dur=0.15, f0=1500, f1=6000, ganho=1.0):
    return filtro_varre(ruido(dur), f0, f1, q=1.5) * env(int(SR * dur), 0.005, dur * 0.6, curva=5) * ganho


def baque(f0=200, f1=90, dur=0.09, sub=0.0):
    x = seno_varre(dur, f0, f1) * env(int(SR * dur), 0.001, dur * 0.7, curva=5)
    if sub:
        x = x + sub * seno_varre(dur * 2, 70, 40) [: len(x)] * env(len(x), 0.002, dur, curva=3)
    return x


# ---------------------------------------------------------------- os sons (id → lista de variações)
def s_carta_comprar(v):
    p = 1 + (v - 2) * 0.04
    return mix((tic(4500 * p, 0.008), 0, 0.7), (fwip(0.22, 1500 * p, 5500 * p), 0.01, 0.8),
               (tic(3200 * p, 0.01), 0.18, 0.35))


def s_deck_cascata(v):
    return mix((chuva_tics(32, 0.42, 0.03, f=(2000, 5000)), 0, 0.8), (fwip(0.4, 800, 2500), 0.0, 0.3))


def s_embaralhar_corte(v):
    p = 1 + (v - 2) * 0.05
    return mix((filtro(ruido(0.15), "faixa", (1000 * p, 5000 * p)) * env(int(SR * 0.15), 0.01, 0.08), 0, 0.6),
               (baque(300 * p, 150, 0.04), 0.2, 0.7), (tic(3000 * p, 0.01), 0.2, 0.5))


def s_carta_cair_campo(v):
    pesos = {1: (0.6, 0), 2: (0.85, 0.3), 3: (1.0, 0.7)}[v]      # leve, médio, pesado
    g, sub = pesos
    po = filtro(ruido(0.45, "marrom"), "baixa", 800) * env(int(SR * 0.45), 0.01, 0.3, curva=3)
    return mix((filtro_varre(ruido(0.16), 3000, 800, q=1.2) * env(int(SR * 0.16), 0.03, 0.1), 0, 0.35),
               (baque(200, 80, 0.07, sub), 0.16, g), (tic(2500, 0.012), 0.16, 0.5 * g), (po, 0.17, 0.25))


def s_selo_colocar(v):
    x = mix((fwip(0.14, 1200, 3000, 0.4), 0, 1), (baque(260, 140, 0.05), 0.12, 0.6), (tic(1500, 0.01, 8), 0.12, 0.4))
    return filtro(x, "baixa", 2500)


def s_ataque_investida(v):
    up = filtro_varre(ruido(0.14), 300, 1200, q=1) * env(int(SR * 0.14), 0.1, 0.04)
    return mix((up, 0, 0.25), (fwip(0.12, 800, 4000), 0.13, 0.9))


def s_ataque_impacto(v):
    nivel = (v - 1) // 2          # 0 leve, 1 médio, 2 pesado
    var = v % 2
    p = 1 + var * 0.05
    partes = [(ruido(0.003), 0, 1.0), (baque(160 * p, 90, 0.08), 0, 0.9),
              (filtro(ruido(0.06), "faixa", (1000, 3000)) * env(int(SR * 0.06), 0.001, 0.03), 0, 0.5)]
    if nivel >= 1:
        partes.append((seno_varre(0.18, 70, 45) * env(int(SR * 0.18), 0.002, 0.12), 0, 0.7))
    if nivel == 2:
        partes.append((fm(0.5, 420 * p, 1.41, 5, 0.25), 0.005, 0.35))
    x = mix(*partes)
    return reverb(x, 0.4, 0.15) if nivel == 2 else x


def s_golpe_direto(v):
    nivel = v                                # 1 / 2 / 3
    tensao = filtro_varre(ruido(0.2), 200, 900, q=2) * env(int(SR * 0.2), 0.18, 0.02)
    boom = seno_varre(0.35, 85, 45) * env(int(SR * 0.35), 0.002, 0.25, curva=3)
    crack = filtro(ruido(0.15), "faixa", (300, 600)) * env(int(SR * 0.15), 0.001, 0.08)
    vida = mix(*[(sino(0.35, 1500 * (0.85 ** k), decai=0.25), 0.3 + k * 0.09, 0.25) for k in range(nivel)])
    return reverb(mix((tensao, 0, 0.3), (fwip(0.1, 800, 4000), 0.17, 0.6), (boom, 0.25, 0.6 + 0.2 * nivel),
                      (crack, 0.25, 0.6), (vida, 0, 1)), 0.6, 0.18)


def s_cornucopia_dano(v):
    oco = baque(130, 100, 0.12)
    notas = mix(*[(sino(0.35, 1200 * (0.78 ** k), decai=0.22), k * 0.07, 0.35) for k in range(v)])
    return mix((oco, 0, 0.8), (notas, 0.02, 1))


def s_cornucopia_cura(v):
    return mix(*[(sino(0.5, f, decai=0.4), k * 0.07, 0.35) for k, f in enumerate((660, 830, 990))])


def s_entidade_morte(v):
    trad = ["madeira", "vidro", "porcelana", "bronze", "ossos", "cristal", "abismo"][v - 1]
    faixa = {"madeira": (600, 1600), "vidro": (3000, 8000), "porcelana": (2000, 5000), "bronze": (800, 2500),
             "ossos": (900, 2200), "cristal": (4000, 9000), "abismo": (200, 900)}[trad]
    graos = []
    for k in range(22):
        ini = 0.1 + (rng.random() ** 2) * 0.4
        if trad == "bronze":
            g = fm(0.12, rng.uniform(*faixa), 1.41, 3, 0.05)
        elif trad in ("vidro", "cristal"):
            g = sino(0.15, rng.uniform(*faixa) / 3, decai=0.08)
        else:
            g = tic(rng.uniform(*faixa), rng.uniform(0.005, 0.015), q=6 if trad == "madeira" else 3)
        graos.append((g, ini, rng.uniform(0.3, 0.8) * (1 - (ini - 0.1) / 0.5)))
    puff = filtro(ruido(0.1), "baixa", 1500) * env(int(SR * 0.1), 0.005, 0.05)
    drop = seno_varre(0.3, 120, 50) * env(int(SR * 0.3), 0.005, 0.2)
    x = mix((puff, 0.05, 0.5), (drop, 0.05, 0.6), *graos)
    if trad == "abismo":
        x = reverb(mix((x, 0, 1), (filtro(ruido(0.6, "marrom"), "baixa", 300) * env(int(SR * 0.6), 0.1, 0.4), 0, 0.5)), 1.0, 0.3, 2500)
    return x


def s_turno_inicio(v):
    meu = v == 1
    f = 330 if meu else 247
    g = sino(1.3, f, razoes=(1, 2.0, 2.76, 4.07, 5.4), amps=(1, 0.4, 0.35, 0.18, 0.1), decai=1.1)
    if not meu:
        return reverb(filtro(g, "baixa", 1500), 0.8, 0.2)
    arp = mix(*[(sino(0.4, fr, decai=0.3) * 0.5, 0.12 + k * 0.08, 0.3) for k, fr in enumerate((1320, 1660, 1980))])
    return reverb(mix((g, 0, 0.8), (arp, 0, 1)), 0.8, 0.2)


def s_efeito_dano(v):
    tipo = ["comum", "fogo", "trovao", "sagrado", "sombrio"][v - 1]
    if tipo == "fogo":
        corpo = filtro(ruido(0.35), "faixa", (300, 3000)) * env(int(SR * 0.35), 0.01, 0.25)
        crep = chuva_tics(8, 0.05, 0.03, f=(1500, 4000), jitter=0.02)
        return mix((baque(150, 70, 0.08), 0, 0.6), (corpo, 0, 0.5), (crep, 0, 0.5))
    if tipo == "trovao":
        rachar = filtro(ruido(0.08), "alta", 2000) * env(int(SR * 0.08), 0.001, 0.03)
        ronco = filtro(ruido(0.7, "marrom"), "baixa", 400) * env(int(SR * 0.7), 0.02, 0.5, curva=2.5)
        return reverb(mix((rachar, 0, 0.8), (ronco, 0.03, 1)), 0.9, 0.2)
    if tipo == "sagrado":
        luz = sino(0.6, 1760, decai=0.4) + sino(0.6, 2640, decai=0.3) * 0.5
        return reverb(mix((baque(180, 90, 0.07), 0, 0.6), (luz, 0, 0.4), (fwip(0.15, 3000, 8000), 0, 0.3)), 1.0, 0.3)
    if tipo == "sombrio":
        drone = filtro(seno_varre(0.5, 90, 60) + 0.5 * ruido(0.5, "marrom"), "baixa", 700) * env(int(SR * 0.5), 0.02, 0.3)
        return reverb(mix((baque(140, 60, 0.1), 0, 0.7), (drone, 0, 0.6)), 1.0, 0.3, 2500)
    return mix((tic(2500, 0.01), 0, 0.6), (baque(170, 90, 0.07), 0, 0.8), (filtro(ruido(0.12), "faixa", (800, 2500)) * env(int(SR * 0.12), 0.002, 0.06), 0, 0.4))


def s_efeito_cura(v):
    tipo = ["comum", "celestial", "natureza", "agua"][v - 1]
    if tipo == "celestial":                     # anjos: coro + sinos agudos + brilho
        c = coro(1.3, (523, 659, 784))
        sinos = mix(*[(sino(0.9, fr, decai=0.7), k * 0.12, 0.25) for k, fr in enumerate((1568, 2093, 2637, 3136))])
        return reverb(mix((c, 0, 0.6), (sinos, 0.1, 1), (fwip(0.4, 4000, 10000, 0.15), 0.05, 1)), 1.4, 0.35, 9000)
    if tipo == "natureza":                     # maracá + flauta
        maraca = chuva_tics(14, 0, 0.018, f=(4000, 8000), jitter=0.006)
        t = t_(0.7)
        flauta = (np.sin(2 * np.pi * 880 * t) + 0.3 * np.sin(2 * np.pi * 1760 * t)) * env(len(t), 0.08, 0.4, sustenta=0.15)
        flauta += 0.08 * filtro(ruido(0.7), "faixa", (800, 2000)) * env(len(t), 0.05, 0.4)
        return reverb(mix((maraca, 0, 0.5), (flauta, 0.12, 0.35)), 0.7, 0.2)
    if tipo == "agua":
        gota = seno_varre(0.08, 900, 1800) * env(int(SR * 0.08), 0.001, 0.04)
        return reverb(mix((gota, 0, 0.6), (sino(0.8, 1320, decai=0.6), 0.06, 0.4), (sino(0.8, 1980, decai=0.5), 0.14, 0.25)), 0.9, 0.3)
    arp = mix(*[(sino(0.6, fr, decai=0.45), k * 0.07, 0.3) for k, fr in enumerate((523, 659, 784, 1047))])
    return reverb(arp, 0.7, 0.25)


def s_efeito_buff(v):
    sobe = seno_varre(0.3, 400, 900) * env(int(SR * 0.3), 0.02, 0.2)
    return reverb(mix((sobe, 0, 0.25), (sino(0.5, 1175, decai=0.35), 0.18, 0.4), (fwip(0.2, 2000, 7000, 0.2), 0, 1)), 0.6, 0.2)


def s_vitrine_carta(v):
    ameaca = v == 2
    base = 220 if ameaca else 440
    swell = filtro_varre(ruido(0.3), 400, 3000, q=2) * env(int(SR * 0.3), 0.22, 0.08)
    shing = sino(0.6, base * 3 if not ameaca else base * 2, decai=0.5)
    pad = coro(0.8, (base, base * (1.19 if ameaca else 1.26), base * 1.5), ataque=0.15)
    return reverb(mix((swell, 0, 0.3), (shing, 0.22, 0.35), (pad, 0.1, 0.25)), 0.9, 0.25)


def s_selo_revelar(v):
    lacre = mix((tic(1800, 0.02, 3), 0, 0.8), (baque(400, 200, 0.03), 0, 0.5))
    acorde = mix(*[(sino(1.2, f, decai=0.9), 0.05 + k * 0.03, 0.25) for k, f in enumerate((440, 523, 659))])
    swell = filtro_varre(ruido(0.4), 300, 2500, q=2) * env(int(SR * 0.4), 0.3, 0.1)
    pulsos = mix((sino(0.3, 1760, decai=0.2), 0.45, 0.2), (sino(0.3, 1760, decai=0.2), 0.75, 0.15))
    return reverb(mix((lacre, 0, 1), (swell, 0, 0.3), (acorde, 0, 1), (pulsos, 0, 1)), 1.0, 0.3)


def s_rito_lancar(v):
    sobe = filtro_varre(ruido(0.3), 300, 3000, q=2) * env(int(SR * 0.3), 0.25, 0.05)
    pulsos = mix(*[(sino(0.25, 880 * (1.12 ** k), decai=0.18), 0.3 + k * 0.2, 0.25 + 0.08 * k) for k in range(3)])
    solta = fwip(0.3, 1500, 9000, 0.6)
    brilho = chuva_tics(10, 0, 0.03, f=(5000, 9000), jitter=0.02, ganho_fim=0.2)
    return reverb(mix((sobe, 0, 0.35), (pulsos, 0, 1), (solta, 0.9, 1), (brilho, 1.0, 0.4)), 0.9, 0.25)


def s_lendaria_entrada(v):
    minha = v == 1
    boom = seno_varre(0.6, 60, 40) * env(int(SR * 0.6), 0.003, 0.5, curva=2.5)
    prato = filtro(ruido(1.2), "alta", 3000) * env(int(SR * 1.2), 0.002, 0.9, curva=3)
    notas = (262, 330, 392, 523) if minha else (220, 262, 330, 440)
    t = t_(1.5)
    metais = np.zeros_like(t)
    for f in notas:
        fase = np.cumsum(np.full_like(t, f * (1 + 0.003 * rng.standard_normal()))) / SR
        metais += 2 * (fase % 1) - 1
    metais = filtro_varre(metais, 500, 2500, q=0.8, tipo="baixa") * env(len(t), 0.06, 0.8, sustenta=0.3, curva=3)
    c = coro(1.5, [n * 2 for n in notas[:3]], ataque=0.3)
    return reverb(mix((boom, 0.4, 0.9), (prato, 0.4, 0.25), (metais, 0.42, 0.35), (c, 0.5, 0.2),
                      (sino(1.4, notas[-1] * 4, decai=1.0), 0.45, 0.2)), 1.6, 0.3)


def s_vitoria(v):
    notas = (523, 659, 784, 1047)
    arp = mix(*[(sino(1.2, f, decai=0.9), k * 0.11, 0.3) for k, f in enumerate(notas)])
    c = coro(1.8, (523, 659, 784), ataque=0.2)
    return reverb(mix((baque(150, 70, 0.15, 0.6), 0, 0.6), (arp, 0.05, 1), (c, 0.35, 0.3),
                      (chuva_tics(20, 0.4, 0.04, f=(5000, 9000), jitter=0.03, ganho_fim=0.1), 0, 0.25)), 1.8, 0.3)


def s_derrota(v):
    notas = (392, 330, 262, 196)
    desce = mix(*[(sino(1.4, f, decai=1.1), k * 0.28, 0.3) for k, f in enumerate(notas)])
    drone = filtro(seno_varre(2.0, 98, 82) + 0.4 * ruido(2.0, "marrom"), "baixa", 500) * env(int(SR * 2.0), 0.3, 1.2, curva=2)
    return reverb(filtro(mix((desce, 0, 1), (drone, 0, 0.35)), "baixa", 3000), 1.6, 0.35, 3000)


def s_transicao_tela(v):
    return filtro_varre(ruido(0.3, "rosa"), 400, 2500, q=1.2) * env(int(SR * 0.3), 0.12, 0.12) * 0.6


def s_botao(v):
    p = (1.0, 1.12)[v - 1]
    return mix((tic(2200 * p, 0.008, 6), 0, 0.6), (seno_varre(0.04, 900 * p, 700 * p) * env(int(SR * 0.04), 0.001, 0.02), 0, 0.3))


def s_pergaminho_abrir(v):
    papel = filtro(ruido(0.35), "faixa", (1500, 6000)) * env(int(SR * 0.35), 0.05, 0.2)
    papel *= 0.6 + 0.4 * np.abs(np.sin(2 * np.pi * 22 * t_(0.35)))      # farfalhar (amplitude ondulando)
    rolo = filtro(ruido(0.3, "marrom"), "baixa", 500) * env(int(SR * 0.3), 0.05, 0.2)
    return mix((tic(1500, 0.02, 3), 0, 0.5), (papel, 0.05, 0.6), (rolo, 0.05, 0.4))


def s_moedas_voando(v):
    partes = []
    for k in range(9):
        partes.append((sino(0.25, rng.uniform(2400, 3600), razoes=(1, 2.4, 4.1), amps=(1, 0.4, 0.2), decai=0.12), k * 0.06 + rng.uniform(0, 0.02), 0.3))
    return mix(*partes)


def s_booster_comprar(v):
    moeda = sino(0.4, 2637, razoes=(1, 2.4, 4.1), amps=(1, 0.5, 0.2), decai=0.3)
    return mix((moeda, 0, 0.4), (sino(0.4, 3136, razoes=(1, 2.4), amps=(1, 0.4), decai=0.25), 0.08, 0.3), (fwip(0.2, 1000, 4000, 0.5), 0.15, 1))


def s_booster_cortar(v):
    return mix((fwip(0.18, 3000, 9000, 0.7), 0, 1), (tic(6000, 0.006), 0.17, 0.4))


def s_booster_rasgar(v):
    n = 0.45
    x = filtro(ruido(n), "faixa", (1200, 7000)) * env(int(SR * n), 0.01, 0.3)
    x *= 0.4 + 0.6 * (rng.random(len(x)) > 0.6).astype(float)                # fibras rompendo
    x = filtro(x, "baixa", 7000)
    return mix((x, 0, 0.8), (baque(220, 120, 0.05), 0.4, 0.4))


def s_booster_cartas_saem(v):
    return mix(*[(fwip(0.12, 1800, 5500, 0.6), k * 0.09, 0.7) for k in range(5)])


def s_booster_revelar(v):
    raro = v == 2
    if raro:
        return reverb(mix((sino(1.0, 1568, decai=0.8), 0, 0.35), (sino(1.0, 2093, decai=0.7), 0.06, 0.3),
                          (coro(1.0, (784, 988, 1175), ataque=0.1), 0, 0.2), (fwip(0.3, 3000, 10000, 0.3), 0, 1)), 1.2, 0.3)
    return mix((fwip(0.12, 1500, 4000, 0.5), 0, 1), (tic(3000, 0.01), 0.1, 0.4))


# ---------------------------------------------------------------- 2ª leva (P2 da mesa + zoom, cemitério, queimar)
def s_intro_camera(v):
    x = filtro_varre(ruido(2.6, "rosa"), 200, 1200, q=1.5) * env(int(SR * 2.6), 0.9, 1.2, sustenta=0.3, curva=2.5)
    return reverb(x, 0.8, 0.2)


def s_monte_bater(v):
    return mix((baque(250, 140, 0.05), 0, 0.9), (tic(2200, 0.01, 4), 0, 0.4),
               (filtro(ruido(0.06), "faixa", (600, 2000)) * env(int(SR * 0.06), 0.001, 0.03), 0, 0.3))


def s_deck_para_espaco(v):
    a = filtro_varre(ruido(0.4), 5000, 1500, q=1.5) * env(int(SR * 0.4), 0.03, 0.25)
    return mix((a, 0, 0.6), (filtro_varre(ruido(0.4), 4500, 1300, q=1.5) * env(int(SR * 0.4), 0.03, 0.25), 0.12, 0.45),
               (baque(220, 130, 0.04), 0.48, 0.6))


def s_carta_virar(v):
    p = 1 + (v - 2) * 0.06
    meio = filtro(ruido(0.07), "faixa", (2000 * p, 6000 * p)) * env(int(SR * 0.07), 0.02, 0.03)
    return mix((tic(3500 * p, 0.006), 0, 0.5), (meio, 0.01, 0.5), (tic(2800 * p, 0.008), 0.07, 0.6))


def s_carta_pegar(v):
    return mix((filtro_varre(ruido(0.1), 2000, 4000, q=2) * env(int(SR * 0.1), 0.02, 0.05), 0, 0.6), (tic(1500, 0.01, 6), 0, 0.3))


def s_carta_recusar(v):
    t = t_(0.12)
    def toque(f):
        q = np.sign(np.sin(2 * np.pi * f * t)) + np.sign(np.sin(2 * np.pi * f * 1.06 * t))
        return filtro(q, "baixa", 1200) * env(len(t), 0.003, 0.07)
    return mix((toque(220), 0, 0.4), (toque(208), 0.14, 0.4), (baque(160, 110, 0.05), 0, 0.3))


def s_carta_descartar(v):
    n = 0.4
    x = filtro(ruido(n), "faixa", (1500, 6000)) * env(int(SR * n), 0.02, 0.25)
    x *= 0.5 + 0.5 * np.sign(np.sin(2 * np.pi * 45 * t_(n)))
    brasa = chuva_tics(10, 0.15, 0.04, f=(3000, 7000), jitter=0.02, ganho_fim=0.1)
    return reverb(mix((x, 0, 0.6), (brasa, 0, 0.4), (fwip(0.25, 6000, 1500, 0.3), 0.3, 1)), 0.6, 0.2)


def s_carta_queimar(v):
    puff = filtro_varre(ruido(0.3), 300, 3000, q=1) * env(int(SR * 0.3), 0.02, 0.2)
    crep = chuva_tics(8, 0.05, 0.03, f=(1500, 4500), jitter=0.02, ganho_fim=0.2)
    return mix((baque(70, 38, 0.15), 0, 0.6), (puff, 0, 0.5), (crep, 0.05, 0.5))


def s_carta_zoom(v):
    abrir = v == 1
    w = fwip(0.15, 1200, 3500, 0.5) if abrir else fwip(0.12, 3000, 1000, 0.4)
    brilho = sino(0.25, 1200, decai=0.15) if abrir else np.zeros(1)
    return mix((w, 0, 1), (brilho, 0.06, 0.15))


def s_cemiterio_carrossel(v):
    if v == 1:                                                      # abrir: leque de fwips numa cripta
        return reverb(mix(*[(fwip(0.08, 1500 + 300 * k, 4500, 0.5), k * 0.035, 0.6) for k in range(8)]), 1.0, 0.35, 3500)
    if v == 2:                                                      # trava em cada carta ao rolar
        return mix((tic(1800, 0.012, 5), 0, 1), (np.zeros(int(SR * 0.08)), 0, 1))
    return reverb(mix(*[(fwip(0.08, 4000, 1500, 0.4), k * 0.03, 0.5) for k in range(6)]), 0.8, 0.25, 3500)


def s_token_desfazer(v):
    puff = filtro(ruido(0.25), "baixa", 1500) * env(int(SR * 0.25), 0.01, 0.15)
    return reverb(mix((puff, 0, 0.6), (sino(0.3, 1800, decai=0.2), 0.02, 0.15), (seno_varre(0.2, 600, 300) * env(int(SR * 0.2), 0.005, 0.1), 0, 0.2)), 0.7, 0.3)


def s_turno_fim_botao(v):
    if v == 1:
        return mix((baque(200, 150, 0.08), 0, 0.8), (tic(1800, 0.012, 5), 0, 0.5))
    return mix((fwip(0.18, 800, 4000, 0.5), 0, 1), (tic(2400, 0.01), 0.15, 0.3))   # RÁPIDO


def s_efeito_anunciar(v):
    return reverb(mix((fm(0.35, 1800, 1.5, 2, 0.25), 0, 0.3), (sino(0.35, 2400, decai=0.25), 0.02, 0.2)), 0.6, 0.25)


def s_efeito_destruir(v):
    drop = seno_varre(0.3, 80, 30) * env(int(SR * 0.3), 0.005, 0.25)
    rev = filtro(ruido(0.2), "faixa", (300, 1500)) * env(int(SR * 0.2), 0.18, 0.02)
    return reverb(mix((rev, 0, 0.5), (drop, 0.18, 0.9), (tic(900, 0.02, 3), 0.18, 0.4)), 0.9, 0.3, 2500)


def s_efeito_devolver(v):
    rev = filtro(ruido(0.3), "faixa", (1500, 5000)) * env(int(SR * 0.3), 0.27, 0.02)
    return mix((rev, 0, 0.6), (tic(2400, 0.01, 5), 0.3, 0.5), (sino(0.2, 1500, decai=0.1), 0.3, 0.15))


def s_efeito_reviver(v):
    sobe = filtro_varre(ruido(0.5), 200, 3000, q=2) * env(int(SR * 0.5), 0.4, 0.1)
    c = coro(0.7, (392, 494, 587), ataque=0.3)
    sinos = mix(*[(sino(0.5, f, decai=0.35), 0.3 + k * 0.07, 0.25) for k, f in enumerate((1175, 1480, 1760))])
    return reverb(mix((sobe, 0, 0.4), (c, 0, 0.3), (sinos, 0, 1), (baque(200, 90, 0.07), 0.62, 0.6)), 1.0, 0.3)


def s_efeito_silenciar(v):
    t = t_(0.4)
    tom = (np.sin(2 * np.pi * 1000 * t) + 0.5 * np.sin(2 * np.pi * 2000 * t) + 0.3 * np.sin(2 * np.pi * 3000 * t)) * env(len(t), 0.005, 0.3)
    return mix((filtro_varre(tom, 6000, 200, q=0.7, tipo="baixa"), 0, 0.5), (baque(150, 100, 0.06), 0.15, 0.4))


def s_efeito_congelar(v):
    gelo = mix(*[(tic(rng.uniform(4000, 10000), rng.uniform(0.004, 0.01), 3), (rng.random() ** 2) * 0.4, rng.uniform(0.2, 0.6)) for _ in range(26)])
    return reverb(mix((gelo, 0, 1), (sino(0.6, 2637, decai=0.5), 0.25, 0.2), (sino(0.6, 3520, decai=0.4), 0.3, 0.12)), 0.8, 0.3, 9000)


def s_efeito_invocar(v):
    pop = seno_varre(0.04, 200, 800) * env(int(SR * 0.04), 0.001, 0.03)
    return reverb(mix((pop, 0, 0.7), (fwip(0.15, 2000, 6000, 0.4), 0.02, 1), (sino(0.3, 1568, decai=0.2), 0.03, 0.2), (baque(200, 100, 0.05), 0.3, 0.5)), 0.6, 0.2)


def s_efeito_fe(v):
    return reverb(mix(*[(fm(0.35, f, 1.0, 1.2, 0.25), k * 0.08, 0.3) for k, f in enumerate((1760, 2217, 2640))]), 0.7, 0.3, 9000)


def s_efeito_anular(v):
    rev = filtro(ruido(0.25), "faixa", (800, 4000)) * env(int(SR * 0.25), 0.23, 0.01)
    choque = mix((baque(300, 120, 0.06), 0, 0.7), (tic(1200, 0.02, 2), 0, 0.5), (sino(0.3, 466, decai=0.2), 0, 0.2), (sino(0.3, 494, decai=0.2), 0, 0.2))
    return reverb(mix((rev, 0, 0.6), (choque, 0.25, 1)), 0.7, 0.25)


def s_efeito_renascer(v):
    arp = mix(*[(sino(0.4, f, decai=0.3), k * 0.07, 0.28) for k, f in enumerate((784, 988, 1175, 1568, 1976))])
    return reverb(mix((arp, 0, 1), (fwip(0.3, 1500, 6000, 0.4), 0.4, 1)), 0.9, 0.3)


def s_selo_cemiterio(v):
    graos = mix(*[(sino(0.12, rng.uniform(3000, 7000) / 3, decai=0.06), rng.random() * 0.25, rng.uniform(0.2, 0.5)) for _ in range(9)])
    return reverb(mix((graos, 0, 1), (filtro(ruido(0.15), "baixa", 1500) * env(int(SR * 0.15), 0.01, 0.08), 0, 0.4)), 0.6, 0.25)


def s_reliquia_equipar(v):
    clink = fm(0.25, 1800, 1.41, 3, 0.15) + 0.6 * fm(0.25, 2700, 1.41, 2, 0.12)
    return reverb(mix((fwip(0.3, 1000, 4000, 0.4), 0, 1), (clink, 0.3, 0.4), (sino(0.4, 1320, decai=0.3), 0.32, 0.15)), 0.7, 0.25)


def s_alvo_escolher(v):
    if v == 1:                                                      # abrir: suspense
        t = t_(0.35)
        pad = np.sin(2 * np.pi * 110 * t) * env(len(t), 0.15, 0.15, sustenta=0.2)
        return mix((pad, 0, 0.4), (filtro_varre(ruido(0.35), 300, 1500, q=2) * env(len(t), 0.25, 0.1), 0, 0.3))
    return mix((sino(0.2, 1320, decai=0.12), 0, 0.4), (tic(2000, 0.01), 0, 0.4))      # confirmar


def s_choronzon_ritual(v):
    t = t_(2.4)
    drone = (np.sin(2 * np.pi * 45 * t) + np.sin(2 * np.pi * 47.5 * t) + 0.6 * np.sin(2 * np.pi * 63.6 * t)) * env(len(t), 0.6, 1.2, sustenta=0.4, curva=2)
    sus = filtro(ruido(2.4), "faixa", (2500, 5000)) * env(len(t), 0.8, 1.0, sustenta=0.2) * (0.5 + 0.5 * np.sin(2 * np.pi * 3 * t))
    return reverb(mix((drone, 0, 0.7), (sus, 0, 0.15), (baque(60, 30, 0.4, 0.5), 2.0, 0.6)), 1.6, 0.4, 2500)


def s_empate(v):
    return reverb(mix(*[(sino(1.4, f, decai=1.0), k * 0.05, 0.3) for k, f in enumerate((294, 392, 440))]), 1.4, 0.35)


SONS = {  # id: (função, número de variações, ganho final dB)
    "carta_comprar": (s_carta_comprar, 4, -8), "deck_cascata": (s_deck_cascata, 1, -10), "embaralhar_corte": (s_embaralhar_corte, 3, -9),
    "carta_cair_campo": (s_carta_cair_campo, 3, -6), "selo_colocar": (s_selo_colocar, 1, -8),
    "ataque_investida": (s_ataque_investida, 1, -10), "ataque_impacto": (s_ataque_impacto, 6, -4), "golpe_direto": (s_golpe_direto, 3, -4),
    "cornucopia_dano": (s_cornucopia_dano, 3, -7), "cornucopia_cura": (s_cornucopia_cura, 1, -9), "entidade_morte": (s_entidade_morte, 7, -6),
    "turno_inicio": (s_turno_inicio, 2, -9), "efeito_dano": (s_efeito_dano, 5, -6), "efeito_cura": (s_efeito_cura, 4, -7),
    "efeito_buff": (s_efeito_buff, 1, -9), "vitrine_carta": (s_vitrine_carta, 2, -9), "selo_revelar": (s_selo_revelar, 1, -6),
    "rito_lancar": (s_rito_lancar, 1, -7), "lendaria_entrada": (s_lendaria_entrada, 2, -4), "vitoria": (s_vitoria, 1, -4),
    "derrota": (s_derrota, 1, -4), "transicao_tela": (s_transicao_tela, 1, -14), "botao": (s_botao, 2, -14),
    "pergaminho_abrir": (s_pergaminho_abrir, 1, -10), "moedas_voando": (s_moedas_voando, 1, -10), "booster_comprar": (s_booster_comprar, 1, -8),
    "booster_cortar": (s_booster_cortar, 1, -9), "booster_rasgar": (s_booster_rasgar, 1, -7), "booster_cartas_saem": (s_booster_cartas_saem, 1, -9),
    "booster_revelar": (s_booster_revelar, 2, -8),
    "intro_camera": (s_intro_camera, 1, -16), "monte_bater": (s_monte_bater, 1, -10), "deck_para_espaco": (s_deck_para_espaco, 1, -11),
    "carta_virar": (s_carta_virar, 3, -12), "carta_pegar": (s_carta_pegar, 1, -14), "carta_recusar": (s_carta_recusar, 1, -12),
    "carta_descartar": (s_carta_descartar, 1, -10), "carta_queimar": (s_carta_queimar, 1, -10), "carta_zoom": (s_carta_zoom, 2, -15),
    "cemiterio_carrossel": (s_cemiterio_carrossel, 3, -12), "token_desfazer": (s_token_desfazer, 1, -10),
    "turno_fim_botao": (s_turno_fim_botao, 2, -11), "efeito_anunciar": (s_efeito_anunciar, 1, -13), "efeito_destruir": (s_efeito_destruir, 1, -7),
    "efeito_devolver": (s_efeito_devolver, 1, -9), "efeito_reviver": (s_efeito_reviver, 1, -8), "efeito_silenciar": (s_efeito_silenciar, 1, -9),
    "efeito_congelar": (s_efeito_congelar, 1, -9), "efeito_invocar": (s_efeito_invocar, 1, -8), "efeito_fe": (s_efeito_fe, 1, -11),
    "efeito_anular": (s_efeito_anular, 1, -8), "efeito_renascer": (s_efeito_renascer, 1, -9), "selo_cemiterio": (s_selo_cemiterio, 1, -10),
    "reliquia_equipar": (s_reliquia_equipar, 1, -9), "alvo_escolher": (s_alvo_escolher, 2, -11), "choronzon_ritual": (s_choronzon_ritual, 1, -5),
    "empate": (s_empate, 1, -6),
}
# nomes das variações (o jogo escolhe pelo nome; números = sorteio round-robin)
NOMES = {"carta_cair_campo": ["leve", "medio", "pesado"], "ataque_impacto": ["leve_1", "leve_2", "medio_1", "medio_2", "pesado_1", "pesado_2"],
         "golpe_direto": ["1", "2", "3"], "cornucopia_dano": ["1", "2", "3"],
         "entidade_morte": ["indigena", "cristianismo", "taoismo", "hinduismo", "bruxaria", "alta_magia", "abismo"],
         "turno_inicio": ["meu", "dele"], "efeito_dano": ["comum", "fogo", "trovao", "sagrado", "sombrio"],
         "efeito_cura": ["comum", "celestial", "natureza", "agua"], "vitrine_carta": ["comum", "ameaca"],
         "lendaria_entrada": ["minha", "dele"], "booster_revelar": ["comum", "raro"],
         "carta_zoom": ["abrir", "fechar"], "cemiterio_carrossel": ["abrir", "passo", "fechar"], "turno_fim_botao": ["fim", "rapido"],
         "alvo_escolher": ["abrir", "confirmar"]}


def finalizar(x, ganho_db):
    x = np.asarray(x, float)
    x = filtro(x, "alta", 30)                                 # tira DC/subgrave inútil
    n = int(SR * 0.004)
    x[:n] *= np.linspace(0, 1, n)                             # sem clique no começo
    fim = int(SR * 0.03)
    x[-fim:] *= np.linspace(1, 0, fim)
    x = x / (np.max(np.abs(x)) + 1e-9) * 10 ** (-1 / 20)       # pico −1 dBFS
    return x * 10 ** (ganho_db / 20 + 1 / 20 * 0)              # nível relativo do catálogo


def main():
    os.makedirs(OUT, exist_ok=True)
    so = set(sys.argv[1:])
    previa = []
    marcas = []
    for sid, (fn, nv, gdb) in SONS.items():
        if so and sid not in so:
            continue
        for v in range(1, nv + 1):
            x = finalizar(fn(v), gdb)
            st = estereo(x, 0, 0.6)
            st = st / max(1.0, np.max(np.abs(st)) / 0.89)
            nome = sid if nv == 1 else f"{sid}_{NOMES.get(sid, [str(k) for k in range(1, nv + 1)])[v - 1]}"
            wav = os.path.join(OUT, nome + ".wav")
            wavfile.write(wav, SR, (st * 32767).astype(np.int16))
            subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", wav, "-c:a", "libvorbis", "-q:a", "5",
                            os.path.join(OUT, nome + ".ogg")], check=True)
            os.remove(wav)
            marcas.append({"nome": nome, "ini": sum(len(p) for p in previa) / SR, "dur": len(st) / SR})
            previa += [st, np.zeros((int(SR * 0.45), 2))]
            print(f"{nome:34s} {len(x) / SR:5.2f} s")
    if previa:
        p = np.concatenate(previa)
        wavfile.write(os.path.join(AQUI, "sfx_previa.wav"), SR, (p * 32767).astype(np.int16))
        import json
        json.dump(marcas, open(os.path.join(AQUI, "sfx_previa.json"), "w"), indent=1)


if __name__ == "__main__":
    main()
