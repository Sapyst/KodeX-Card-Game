"""Retratos dos 6 personagens do torneio (Krea 2 puro, SEM o LoRA Chaotic Shapes — pedido do autor) a partir de godot/dados/lore.json."""
import json, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pipeline_pixel as PP
RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
lore = json.load(open(os.path.join(RAIZ, "godot", "dados", "lore.json"), encoding="utf-8"))
for deck, p in lore["personagens"].items():
    for suf, seed in (("a", 1111), ("b", 2222)):
        dest = os.path.join(RAIZ, "arte", "personagens", "_candidatas", f"{deck}_{suf}.png")
        if not os.path.exists(dest):
            PP.krea2(p["retrato_prompt"] + " Half-body portrait, facing the viewer, looking at the viewer. Dark fantasy illustration, detailed digital painting.", seed, dest, lora=None)
        print("ok", deck, suf, flush=True)
