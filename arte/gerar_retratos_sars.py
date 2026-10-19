"""Retratos dos personagens do torneio com S.A.R.S, isolados: fundo cinza liso para recorte depois."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pipeline_pixel as PP
O = os.path.join(os.path.dirname(os.path.abspath(__file__)), "personagens", "_sars")
os.makedirs(O, exist_ok=True)
FUNDO = ", white background, simple background, plain solid white background, no scenery, no symbols in background, isolated character, cowboy shot, standing, facing viewer, looking at viewer"
T = {
 "indigena": "1girl, solo, mature woman, 32 years old, indigenous brazilian woman, brown skin, long straight black hair, blunt bangs, red urucum face paint stripes, black genipapo geometric body paint on arms, small headband of green and yellow feathers, simple brown woven cotton dress covering chest, green jade frog amulet necklace, holding gourd maraca rattle with feathers, calm serious expression",
 "cristianismo": "1boy, solo, old man, 64 years old, afro-brazilian franciscan friar, dark brown skin, short white hair, short white beard, kind smile, brown franciscan habit with hood, white rope belt, purple stole, holding plain wooden cross without figure in right hand, holding brass censer on chain in left hand",
 "taoismo": "1girl, solo, young adult woman, chinese, pale skin, black hair in high bun with jade hairpin, serene smile, dark blue embroidered hanfu robe with cloud patterns covering chest, yin yang pendant, holding white horsetail whisk in right hand, holding yellow paper talisman with red seal in left hand",
 "hinduismo": "1boy, solo, young adult man, 28 years old, indian man, brown skin, short black hair, trimmed beard, red tilak on forehead, saffron orange kurta, red shawl over shoulder, rudraksha bead necklace, holding a recurve longbow vertically in left hand, bowstring visible, quiver of arrows on back, confident grin",
 "bruxaria": "1girl, solo, old woman, 70 years old, polish grandmother, pale wrinkled skin, long grey hair in braid, sharp sly smile, black wool dress covering chest, black shawl embroidered with red roses, red coral bead necklace, black raven perched on shoulder, holding small glass witch bottle with red thread",
 "alta_magia": "1boy, solo, mature man, 55 years old, gaunt english man, pale skin, hollow cheeks, ice blue eyes, long silver hair tied back, silver goatee, high collared black ceremonial robe with crimson lining, golden triangle pendant on chain, holding black wand with silver triangle tip, holding red wax seal disc in left hand, cold menacing expression, no stars",
}
for deck, tags in T.items():
    for suf, seed in (("a", 501), ("b", 502)):
        dest = os.path.join(O, f"{deck}_{suf}.png")
        if not os.path.exists(dest):
            PP.sars(tags + FUNDO, seed, dest)
        print("ok", deck, suf, flush=True)
