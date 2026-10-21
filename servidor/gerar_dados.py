"""Gera src/dados.js a partir do jogo: cartas (cultura, tipo, custo, lendária), foils existentes, decks iniciais,
preços dos versos e versões publicadas (godot/dados/novidades.json). Rodar sempre que as cartas ou versões mudarem."""
import json, os, re
RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
G = os.path.join(RAIZ, "godot")
db = json.load(open(os.path.join(G, "dados", "cartas.json"), encoding="utf-8"))
cartas = {k: {"c": v["cultura"], "t": v["tipo"], "u": int(v["custo"]), "l": bool(v["lendaria"])} for k, v in db["cartas"].items()}
foils = sorted(f[:-5] for f in os.listdir(os.path.join(G, "assets", "carta_foil")) if f.endswith(".webp"))
cos = open(os.path.join(G, "cosmeticos.gd"), encoding="utf-8").read()
versos = {m.group(1): int(m.group(2)) for m in re.finditer(r'"id": "(\w+)", "nome": \[[^\]]*\], "preco": (\d+)', cos)}
versoes = [e["versao"] for e in json.load(open(os.path.join(G, "dados", "novidades.json"), encoding="utf-8"))]
out = {"cartas": cartas, "foils": foils, "deck_inicial": db["decks"]["alta_magia"], "versos": versos, "versoes": versoes}
open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "src", "dados.js"), "w", encoding="utf-8").write(
    "// gerado por gerar_dados.py — não editar à mão\nexport default " + json.dumps(out, ensure_ascii=False) + ";\n")
print(len(cartas), "cartas,", len(foils), "foils,", len(versos), "versos,", len(versoes), "versões")
