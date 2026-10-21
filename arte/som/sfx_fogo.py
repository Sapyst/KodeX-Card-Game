"""Efeito sonoro de FOGO sintetizado por código (sem samples): ignição (baque grave + sopro subindo),
corpo do fogo (rugido de ruído grave tremulando) e estalos (crepitar da madeira), com cauda que apaga.
Saídas em arte/som/: fogo.wav (44,1 kHz, 16 bits, estéreo), fogo.ogg e fogo_espectro.png."""
import os
import numpy as np
from scipy import signal
from scipy.io import wavfile

AQUI = os.path.dirname(os.path.abspath(__file__))
SR = 44100
DUR = 2.4
rng = np.random.default_rng(7)
N = int(SR * DUR)
t = np.arange(N) / SR


def passa_baixa(x, fc, ordem=2):
    b, a = signal.butter(ordem, fc / (SR / 2), "low")
    return signal.lfilter(b, a, x)


def passa_alta(x, fc, ordem=2):
    b, a = signal.butter(ordem, fc / (SR / 2), "high")
    return signal.lfilter(b, a, x)


def passa_faixa(x, f1, f2, ordem=2):
    b, a = signal.butter(ordem, [f1 / (SR / 2), f2 / (SR / 2)], "band")
    return signal.lfilter(b, a, x)


def ruido_marrom(n):
    x = np.cumsum(rng.standard_normal(n))
    x = passa_alta(x, 20)
    return x / (np.abs(x).max() + 1e-9)


def envelope(pontos):
    """pontos [(tempo, nível)] → curva linear em t."""
    ts, vs = zip(*pontos)
    return np.interp(t, ts, vs)


def canal(semente):
    global rng
    rng = np.random.default_rng(semente)
    # 1) ignição: baque grave 70→38 Hz + sopro de ruído com filtro subindo 250 → 3500 Hz
    fase = 2 * np.pi * np.cumsum(38 + 32 * np.exp(-t / 0.08)) / SR
    baque = np.sin(fase) * np.exp(-t / 0.12) * (t < 0.6)
    sopro_bruto = rng.standard_normal(N)
    fc = 200 + 1300 * np.clip(t / 0.3, 0, 1)        # fuuush: abre só até 1,5 kHz (mais quente)
    g = 1 - np.exp(-2 * np.pi * fc / SR)          # passa-baixa de um polo com corte variando amostra a amostra
    sopro = np.zeros(N)
    y = 0.0
    for i in range(int(0.75 * SR)):
        y += g[i] * (sopro_bruto[i] - y)
        sopro[i] = y
    sopro = passa_baixa(passa_alta(sopro, 120), 2200, 2)   # corta o chiado agudo do sopro
    sopro *= envelope([(0, 0), (0.08, 1), (0.22, 0.5), (0.5, 0), (DUR, 0)])   # sopro curto e discreto
    # 2) corpo: rugido grave (marrom, < 700 Hz) com tremulação 4–9 Hz + chiado agudo leve
    trem = passa_baixa(rng.standard_normal(N), 7) * 6 + 1
    trem = np.clip(trem / np.abs(trem).max() * 0.5 + 0.75, 0.25, 1.3)
    rugido = passa_baixa(ruido_marrom(N), 500, 2) * trem
    chiado = passa_baixa(passa_alta(rng.standard_normal(N), 300, 1), 1200, 1) * 0.12 * trem
    corpo_env = envelope([(0, 0), (0.12, 0.6), (0.35, 1.0), (1.5, 0.85), (DUR, 0)])
    corpo = (rugido / (np.abs(rugido).max() + 1e-9) * 0.75 + chiado) * corpo_env
    # 3) estalos: eventos de Poisson (até ~28/s no auge), cada um ruído curto filtrado com decaimento exponencial
    estalos = np.zeros(N)
    taxa = envelope([(0, 0), (0.25, 10), (0.5, 28), (1.6, 22), (DUR, 2)])
    for i in range(0, N, 64):
        if rng.random() < taxa[i] * 64 / SR:
            grande = rng.random() < 0.18
            dur = int(SR * (rng.uniform(0.012, 0.04) if grande else rng.uniform(0.002, 0.012)))
            dur = min(dur, N - i)
            if dur < 8:
                continue
            ev = rng.standard_normal(dur) * np.exp(-np.arange(dur) / (dur / 6))
            if grande:                                # estalo de lenha: mais grave e encorpado
                ev = passa_baixa(ev, rng.uniform(1800, 3200), 1) * rng.uniform(0.7, 1.0)
            else:                                     # faísca: clique curto, brilhante mas largo
                ev = passa_baixa(ev, rng.uniform(5000, 9000), 1) * rng.uniform(0.2, 0.55)
            estalos[i:i + dur] += ev
    estalos /= (np.abs(estalos).max() + 1e-9)
    mix = baque * 0.9 + sopro / (np.abs(sopro).max() + 1e-9) * 0.12 + corpo * 0.8 + estalos * 0.75
    return mix


def main():
    esq, dir_ = canal(7), canal(8)                # canais com sementes diferentes = fogo largo no estéreo
    st = np.stack([esq * 0.85 + dir_ * 0.15, dir_ * 0.85 + esq * 0.15], axis=1)
    st *= 10 ** (-1 / 20) / np.abs(st).max()       # pico em −1 dBFS
    fade = np.ones(N); fade[-int(0.05 * SR):] = np.linspace(1, 0, int(0.05 * SR))
    st *= fade[:, None]
    wav = os.path.join(AQUI, "fogo.wav")
    wavfile.write(wav, SR, (st * 32767).astype(np.int16))
    os.system(f'ffmpeg -loglevel error -y -i "{wav}" -c:a libvorbis -q:a 6 "{os.path.join(AQUI, "fogo.ogg")}"')
    # espectrograma para conferência visual
    from PIL import Image
    f, tt, S = signal.spectrogram(st[:, 0], SR, nperseg=1024, noverlap=768)
    S = 10 * np.log10(S + 1e-12)
    S = np.clip((S - S.max() + 80) / 80, 0, 1)[::-1]
    Image.fromarray((S * 255).astype(np.uint8)).resize((900, 400)).save(os.path.join(AQUI, "fogo_espectro.png"))
    print("ok", wav)


if __name__ == "__main__":
    main()
