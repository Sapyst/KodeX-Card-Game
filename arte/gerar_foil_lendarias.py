"""Lendárias FOIL (ultra raras): arte NOVA do zero com S.A.R.S dark fantasy (txt2img, nada da arte normal), a partir
dos prompts em tags de arte/foil_lendarias.json. 4 candidatas por carta em arte/<deck>/_foil_novo/<id>_a..d.png."""
import hashlib, json, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pipeline_pixel as PP
AQUI = os.path.dirname(os.path.abspath(__file__))
BASE = ("dark fantasy, mythological, legendary, epic, ancient, highly detailed, painterly, dramatic lighting, volumetric light, "
        "glowing magical light, intricate details, full body, ")
PP.ANIME_NEG = PP.ANIME_NEG.replace("huge eyes, ", "") + ", nudity, nipples, cleavage, revealing clothes, multiple people, crowd, abstract, cubism"
dados = json.load(open(os.path.join(AQUI, "foil_lendarias.json"), encoding="utf-8"))
ids = sys.argv[1].split(",") if len(sys.argv) > 1 else list(dados)
RODADA = int(os.environ.get("RODADA", "1"))                # rodada 2 usa sementes e letras novas (e..h)
NEG_BASE = PP.ANIME_NEG
for cid in ids:
    d = dados[cid]
    PP.ANIME_NEG = NEG_BASE + (", " + d["neg"] if d.get("neg") else "")
    for k, suf in enumerate("abcd" if RODADA == 1 else "efgh"):
        dest = os.path.join(AQUI, d["deck"], "_foil_novo", f"{cid}_{suf}.png")
        if os.path.exists(dest):
            continue
        os.makedirs(os.path.dirname(dest), exist_ok=True)
        seed = int(hashlib.sha1(f"{cid}#foil#{k + 4 * (RODADA - 1)}".encode()).hexdigest()[:8], 16) % 2_000_000_000
        PP.sars(BASE + d["tags"], seed, dest)
        print(cid, suf, flush=True)
print("fim")
