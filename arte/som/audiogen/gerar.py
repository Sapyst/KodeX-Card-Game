"""AudioGen (Meta AudioCraft) local: gera efeitos sonoros a partir de texto.
Pasta: D:\\AI_LOCAL\\AudioGen. Uso: venv/bin/python gerar.py "descrição em inglês" saida.wav [duracao_s] [semente]"""
import os, sys
os.environ.setdefault("HF_HOME", os.path.join(os.path.dirname(os.path.abspath(__file__)), "hf"))   # modelo fica nesta pasta
import torch, numpy as np, soundfile as sf
from audiocraft.modules.transformer import set_efficient_attention_backend
set_efficient_attention_backend("torch")
from audiocraft.models import AudioGen
txt, out = sys.argv[1], sys.argv[2]
dur = float(sys.argv[3]) if len(sys.argv) > 3 else 3.0
seed = int(sys.argv[4]) if len(sys.argv) > 4 else 0
torch.manual_seed(seed)
m = AudioGen.get_pretrained("facebook/audiogen-medium")
m.set_generation_params(duration=dur)
with torch.no_grad():
    wav = m.generate([txt])[0].cpu().float().numpy()   # (canais, amostras), 16 kHz
x = wav.T
x = x / max(1e-9, np.abs(x).max()) * 0.89
sf.write(out, x, m.sample_rate)
print("ok", out, m.sample_rate, x.shape)
