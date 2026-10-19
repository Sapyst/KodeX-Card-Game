"""Gera as artes das cartas com Krea 2 Turbo + LoRA Chaotic Shapes, a partir do bloco ```krea da seção
'## Prompt Krea 2' de cada ficha. Duas candidatas por carta (seeds derivadas do id) em arte/<deck>/_krea/<id>_a|b.png.
Pula o que já existe. A escolhida vai depois para arte/<deck>/<id>.png (revisão).

Uso: /mnt/d/Comfy-Desktop/venv/bin/python gerar_krea.py [--deck indigena] [--id ind_x] [--n 2] [--forcar]
"""
import argparse, glob, hashlib, json, os, re, sys, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pipeline_pixel as PP

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DECKS = ["indigena", "cristianismo", "taoismo", "hinduismo", "bruxaria", "alta_magia", "abismo"]
SUFIXOS = "abcdefgh"


def ler(f):
    md = open(f, encoding="utf-8").read()
    c = json.loads(re.search(r"```json\s*(\{.*?\})\s*```", md, re.S).group(1))
    m = re.search(r"## Prompt Krea 2.*?```krea\s*(.*?)```", md, re.S)
    return c, (" ".join(m.group(1).split()) if m else None)


def seed(cid, k):
    return int(hashlib.sha1(f"{cid}#{k}".encode()).hexdigest()[:8], 16) % 2_000_000_000


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--deck"); ap.add_argument("--id"); ap.add_argument("--n", type=int, default=2)
    ap.add_argument("--forcar", action="store_true"); ap.add_argument("--offset", type=int, default=0)
    a = ap.parse_args()
    log = open(os.path.join(RAIZ, "arte", "_krea_log.jsonl"), "a", encoding="utf-8")
    feitos = pulados = sem_prompt = 0
    for deck in ([a.deck] if a.deck else DECKS):
        for f in sorted(glob.glob(os.path.join(RAIZ, "cartas", deck, "[0-9][0-9]_*.md"))):
            c, prompt = ler(f)
            cid = c["id"]
            if a.id and cid != a.id:
                continue
            if not prompt:
                sem_prompt += 1; print("SEM PROMPT", cid, flush=True); continue
            for k in range(a.offset, a.offset + a.n):
                dest = os.path.join(RAIZ, "arte", deck, "_krea", f"{cid}_{SUFIXOS[k]}.png")
                if os.path.exists(dest) and not a.forcar:
                    pulados += 1; continue
                os.makedirs(os.path.dirname(dest), exist_ok=True)
                t0 = time.time()
                try:
                    PP.krea2(prompt, seed(cid, k), dest)
                except Exception as e:                              # segue para a próxima carta
                    print("ERRO", cid, e, flush=True); continue
                feitos += 1
                log.write(json.dumps({"id": cid, "deck": deck, "cand": SUFIXOS[k], "seed": seed(cid, k), "s": round(time.time() - t0)}) + "\n")
                log.flush()
                print(f"[{deck}] {cid}_{SUFIXOS[k]} {time.time() - t0:.0f}s", flush=True)
    print(f"feitos={feitos} pulados={pulados} sem_prompt={sem_prompt}")


if __name__ == "__main__":
    main()
