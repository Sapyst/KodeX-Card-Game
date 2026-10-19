"""Exporta as fichas cartas/<deck>/NN_*.md para godot/dados/cartas.json (o jogo lê só o JSON).
Uso: python3 godot/exportar_cartas.py"""
import glob, json, os, re

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DECKS = ["indigena", "cristianismo", "taoismo", "hinduismo", "bruxaria", "alta_magia", "abismo"]
saida = {"cartas": {}, "decks": {}}
for deck in DECKS:
    lista = []
    for f in sorted(glob.glob(os.path.join(RAIZ, "cartas", deck, "[0-9][0-9]_*.md"))):
        md = open(f, encoding="utf-8").read()
        c = json.loads(re.search(r"```json\s*(\{.*?\})\s*```", md, re.S).group(1))
        txt = re.search(r"## Texto da carta\s*\n(.*?)\n\s*\n", md, re.S)
        cop = re.search(r"\|\s*C[óo]pias no deck\s*\|\s*(\d)\s*\|", md)
        c["texto"] = " ".join(txt.group(1).split()) if txt else ""
        c["copias"] = int(cop.group(1)) if cop else 1
        c["arte"] = f"res://arte/{deck}/{c['id']}.png"
        saida["cartas"][c["id"]] = c
        lista += [c["id"]] * c["copias"]
    saida["decks"][deck] = lista
os.makedirs(os.path.join(RAIZ, "godot", "dados"), exist_ok=True)
json.dump(saida, open(os.path.join(RAIZ, "godot", "dados", "cartas.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)
print({d: len(v) for d, v in saida["decks"].items()}, "cartas:", len(saida["cartas"]))
