"""Monta as cartas finais: arte aprovada (arte/<deck>/<id>.png) dentro do frame v2 (arte/frame/gerar_frame_v2.py).

Nada é sobrescrito: cada montagem vai para cartas_finais/<versao>/<deck>/<id>.png, e a pasta da versão recebe uma cópia
do gerador do frame e da configuração usada (_backup/), para dar para voltar exatamente àquela versão.
As artes originais em arte/<deck>/ são só lidas.

Uso: /mnt/d/Comfy-Desktop/venv/bin/python montar_cartas.py --versao v1 [--deck indigena] [--id ind_x] [--refazer]
"""
import argparse, glob, json, os, shutil, sys, time

AQUI = os.path.dirname(os.path.abspath(__file__))
RAIZ = os.path.dirname(AQUI)
sys.path.insert(0, os.path.join(AQUI, "frame"))
import gerar_frame_v2 as F2
from PIL import Image, ImageDraw

DECKS = ["indigena", "cristianismo", "taoismo", "hinduismo", "bruxaria", "alta_magia", "abismo"]
PALETA_DO_DECK = {"abismo": "alta_magia"}        # o Conjunto do Abismo usa a moldura da alta magia
_cache: dict = {}


def moldura(cult, raridade, defesa):
    """O frame só depende de cultura × raridade × pílula de defesa: gera uma vez (~4 s) e reaproveita."""
    k = (cult, raridade, defesa)
    if k not in _cache:
        _cache[k] = F2.para_imagem(F2.frame(cult, raridade, 0.0, defesa=defesa))
    return _cache[k]


def montar(c, cult, arte):
    tipo = c["tipo"]
    raridade = "lendaria" if c.get("lendaria") and c.get("cultura") != "abismo" else "comum"
    tem_defesa = tipo == "entidade" or (tipo == "reliquia" and c.get("usos"))
    im = Image.new("RGBA", (F2.W, F2.H), (0, 0, 0, 0))
    x0, y0, x1, y1 = F2.ART
    im.alpha_composite(Image.open(arte).convert("RGBA").resize((x1 - x0, y1 - y0), Image.LANCZOS), (x0, y0))
    im.alpha_composite(moldura(cult, raridade, bool(tem_defesa)))
    F2.escrever(im, c, cult, raridade)
    if tem_defesa:
        d = ImageDraw.Draw(im)
        y0d, y1d = F2.DEFESA[1], F2.DEFESA[3]
        rot = f"Def {c['vida']}" if tipo == "entidade" else f"Usos {c['usos']}"
        F2.texto_contorno(d, (F2.W - F2.PAINEL - 22, (y0d + y1d) / 2 + 2), rot, F2.fonte(F2.FONTE_TITULO, 34), (255, 255, 255), esp=3, anchor="rm")
    return im


def backup(pasta_versao):
    b = os.path.join(pasta_versao, "_backup")
    if os.path.exists(b):
        return
    os.makedirs(b)
    for f in ("gerar_frame_v2.py", "mapa_frame.png"):
        src = os.path.join(AQUI, "frame", f)
        if os.path.exists(src):
            shutil.copy2(src, b)
    shutil.copy2(__file__, b)
    json.dump({"criado": time.strftime("%Y-%m-%d %H:%M"), "tamanho": [F2.W, F2.H], "arte": F2.ART, "nome": F2.NOME,
               "efeito": F2.EFEITO, "defesa": F2.DEFESA, "texto": F2.TEXTO, "custo": F2.CUSTO, "paleta_do_deck": PALETA_DO_DECK},
              open(os.path.join(b, "config.json"), "w"), indent=1)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--versao", default="v1"); ap.add_argument("--deck"); ap.add_argument("--id")
    ap.add_argument("--refazer", action="store_true")
    a = ap.parse_args()
    pasta = os.path.join(RAIZ, "cartas_finais", a.versao)
    os.makedirs(pasta, exist_ok=True)
    backup(pasta)
    feitas = puladas = sem_arte = 0
    faltando = []
    for deck in ([a.deck] if a.deck else DECKS):
        cult = PALETA_DO_DECK.get(deck, deck)
        for f in sorted(glob.glob(os.path.join(RAIZ, "cartas", deck, "[0-9][0-9]_*.md"))):
            c = F2.ler_carta(f)
            if a.id and c["id"] != a.id:
                continue
            arte = os.path.join(RAIZ, "arte", deck, c["id"] + ".png")
            dest = os.path.join(pasta, deck, c["id"] + ".png")
            if not os.path.exists(arte):
                sem_arte += 1; faltando.append(c["id"]); continue
            if os.path.exists(dest) and not a.refazer:
                puladas += 1; continue
            os.makedirs(os.path.dirname(dest), exist_ok=True)
            montar(c, cult, arte).save(dest)
            feitas += 1
            print(f"[{deck}] {c['id']}", flush=True)
    print(f"feitas={feitas} puladas={puladas} sem_arte={sem_arte} -> {pasta}")
    if faltando:
        print("sem arte aprovada ainda:", " ".join(faltando))


if __name__ == "__main__":
    main()
