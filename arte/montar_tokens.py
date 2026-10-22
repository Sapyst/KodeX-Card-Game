"""Monta os tokens (Entidades invocadas por efeito) no frame da tradição de origem, PT e EN:
cartas_finais/v1/tokens/<id>.png e cartas_finais/v1_en/tokens/<id>.png. Arte: arte/tokens/<id>.png.
Uso: /mnt/d/Comfy-Desktop/venv/bin/python montar_tokens.py [--idioma en]"""
import argparse, json, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import montar_cartas as M

ap = argparse.ArgumentParser(); ap.add_argument("--idioma", default="pt", choices=["pt", "en", "es"]); a = ap.parse_args()
dados = os.path.join(M.RAIZ, "godot", "dados")
toks = json.load(open(os.path.join(dados, "tokens.json"), encoding="utf-8"))
cartas = json.load(open(os.path.join(dados, "cartas.json"), encoding="utf-8"))["cartas"]
en = json.load(open(os.path.join(dados, f"cartas_{a.idioma}.json"), encoding="utf-8"))["cartas"] if a.idioma != "pt" else {}
M.modo_idioma(a.idioma)
M.IDIOMA[0] = a.idioma
FRASE = {"pt": ("Guarda. ", "Token invocado por {}."), "en": ("Guard. ", "Token summoned by {}."), "es": ("Guardia. ", "Ficha invocada por {}.")}


def acha(o, nome):
    if isinstance(o, dict):
        if o.get("nome") == nome and "atk" in o:
            return o
        return next((r for v in o.values() if (r := acha(v, nome))), None)
    if isinstance(o, list):
        return next((r for v in o if (r := acha(v, nome))), None)
    return None


pasta = os.path.join(M.RAIZ, "cartas_finais", "v1" if a.idioma == "pt" else "v1_" + a.idioma, "tokens")
os.makedirs(pasta, exist_ok=True)
for nome, t in toks.items():
    fonte, acao = next((cid, r) for cid, c in cartas.items() if (r := acha(c.get("efeitos", []), nome)))
    kws = acao.get("keywords") or []
    g, fr = FRASE[a.idioma]
    txt = (g if "guarda" in kws else "") + fr.format(en.get(fonte, {}).get("nome", cartas[fonte]["nome"]))
    nm = t.get(a.idioma, nome) if a.idioma != "pt" else nome
    c = {"id": t["id"], "nome": nm, "tipo": "entidade", "cultura": t["cultura"], "custo": 0, "atk": acao["atk"],
         "vida": acao["vida"], "keywords": kws, "texto": txt}
    arte = os.path.join(M.RAIZ, "arte", "tokens", t["id"] + ".png")
    if not os.path.exists(arte):
        print("sem arte", t["id"]); continue
    M.montar(c, t["cultura"], arte).save(os.path.join(pasta, t["id"] + ".png"))
    print(t["id"], "<-", fonte)
