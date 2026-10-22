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
prog = json.load(open(os.path.join(G, "dados", "progressao.json"), encoding="utf-8"))
for grupo in ("diarias", "semanais", "conquistas"):                       # o servidor não precisa dos textos
    prog[grupo] = [{k: v for k, v in m.items() if k not in ("pt", "en")} for m in prog[grupo]]
prog.pop("titulos", None); prog.pop("_doc", None)
prog["tradicoes"] = list(prog["tradicoes"])
out = {"prog": prog, "cartas": cartas, "foils": foils, "deck_inicial": db["decks"]["alta_magia"], "versos": versos, "versoes": versoes}
open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "src", "dados.js"), "w", encoding="utf-8").write(
    "// gerado por gerar_dados.py — não editar à mão\nexport default " + json.dumps(out, ensure_ascii=False) + ";\n")
print(len(cartas), "cartas,", len(foils), "foils,", len(versos), "versos,", len(versoes), "versões")

# cartas completas (com efeitos) para o motor juiz do online (src/motor/regras.js)
cartas_motor = {k: {x: v[x] for x in ("id", "nome", "cultura", "tipo", "custo", "atk", "vida", "lendaria", "keywords", "sacrificio", "efeitos", "usos")}
                for k, v in db["cartas"].items()}
tokens = json.load(open(os.path.join(G, "dados", "tokens.json"), encoding="utf-8"))
tok = {k: {"id": v["id"], "cultura": v.get("cultura", "token")} for k, v in tokens.items()}
open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "src", "motor", "cartas.js"), "w", encoding="utf-8").write(
    "// gerado por servidor/gerar_dados.py — não editar à mão. Cartas com efeitos (as regras do juiz) e tokens.\n"
    "export const CARTAS = " + json.dumps(cartas_motor, ensure_ascii=False) + ";\nexport const TOKENS = " + json.dumps(tok, ensure_ascii=False) + ";\n")
