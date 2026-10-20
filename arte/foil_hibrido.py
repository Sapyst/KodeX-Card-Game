"""Lendárias foil difíceis: composição NOVA com Krea 2 sem LoRA (segue bem os objetos descritos) + redesenho S.A.R.S
dark fantasy por cima (img2img 0.45) para unificar o estilo com as outras foils. Nada vem da arte normal da carta.
Saídas: arte/<deck>/_foil_novo/<id>_k1|k2.png (Krea) e <id>_x1|x2.png (final). Uso: python foil_hibrido.py id1,id2"""
import hashlib, json, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pipeline_pixel as PP
from PIL import Image
AQUI = os.path.dirname(os.path.abspath(__file__))
ESTILO = ("Dark fantasy painterly illustration, epic and mythological, dramatic chiaroscuro lighting, glowing magical light, "
          "rich deep colors, highly detailed. ")
P = {
 "ind_jaci": "Jaci, the Tupi moon goddess of the Brazilian Amazon: a serene Indigenous Brazilian woman with brown skin, long straight black hair with bangs, a white feather headdress and white body paint dots, wearing simple white cotton garments. She stands perfectly centered and facing the viewer, symmetrical, on the dark still water of an Amazon river among giant round Victoria amazonica water lilies. A huge full moon rises directly behind her head like a halo, and silver light glows between her open hands. Starry night sky, fireflies, silver reflections on the water.",
 "cri_elias": "An old Hebrew prophet with a long white beard and a rough sheepskin mantle stands inside a war chariot made entirely of fire, with blazing wheels, pulled by two horses made of living flames. The chariot rises into the night sky inside a spiraling whirlwind, above a dark desert and the river Jordan. He looks upward, one hand raised. No helmet, no horns.",
 "cri_sao_miguel_arcanjo": "Archangel Michael, a stern adult warrior with short hair, golden armor and a red cape, huge white feathered wings and a golden halo. His right hand raises a flaming sword; his left hand holds golden balance scales. His armored foot presses down on the head of a defeated black dragon lying on the rocks. Storm clouds split by rays of heavenly light. No horns.",
 "tao_xiwangmu": "Xiwangmu, the Queen Mother of the West, a regal Chinese goddess around fifty years old, wearing an ornate golden phoenix crown and layered golden and crimson Han dynasty robes. She holds a single pink peach of immortality in her open palm, and a small blue bird perches on her other hand. She stands on a jade terrace of the Kunlun mountains among blossoming peach trees above a sea of clouds. She has no wings.",
 "tao_imperador_de_jade": "The Jade Emperor, a Chinese celestial emperor with a long black beard and a serene face, seated on a jade throne in a palace above the clouds. He wears a traditional Chinese mian crown: a flat black rectangular board lying horizontally on top of a black cap, with twelve strings of small jade beads hanging from its front and back edges like a curtain in front of his face. The crown is flat, not spiky. He wears a yellow imperial robe embroidered with golden dragons and holds a long narrow white jade tablet (hu) upright with both hands in front of his chest.",
 "hin_kali": "The Hindu goddess Kali with dark blue skin and exactly four arms, a fierce face with her red tongue sticking out and a third eye on her forehead, wild long black hair. She wears a necklace of small skulls around her neck, a fully covering red sari and gold jewelry. Upper hands hold a curved sword and a trident; lower hands make protective gestures. She stands on a cremation ground at night with fires and smoke.",
 "hin_shiva_nataraja": "Shiva Nataraja, the Hindu god as Lord of the Dance, with blue skin and exactly four arms, dancing with his left leg raised across his body inside a large ring of fire. His upper right hand holds a small damaru, a little two-headed hand drum made of wood and leather; his upper left hand holds a flame. His lower hands make a protective gesture and point to his raised foot. He has a third eye, matted hair with a crescent moon, a cobra around his neck, a tiger-skin loincloth and gold jewelry. Under his right foot lies a small dwarf demon.",
 "bru_hecate": "Hecate, the Greek goddess of witchcraft, shown as three women standing back to back so that she faces three directions, each in dark purple and black robes with a silver crescent moon crown. Each woman holds a burning wooden torch. Large iron keys hang from their belts. Two black dogs sit at their feet. They have stern adult faces and no crosses or Christian symbols. They stand exactly where three dirt roads meet at a crossroads at night under a full moon, with mist. No swords.",
}
dados = json.load(open(os.path.join(AQUI, "foil_lendarias.json"), encoding="utf-8"))
NEG = PP.ANIME_NEG.replace("huge eyes, ", "") + ", nudity, cleavage, revealing clothes, abstract, cubism"
for cid in sys.argv[1].split(","):
    deck = dados[cid]["deck"]
    pasta = os.path.join(AQUI, deck, "_foil_novo")
    for k in [int(x) for x in os.environ.get("KS", "1,2").split(",")]:
        kpath = os.path.join(pasta, f"{cid}_k{k}.png")
        if not os.path.exists(kpath):
            seed = int(hashlib.sha1(f"{cid}#krea#{k}".encode()).hexdigest()[:8], 16) % 2_000_000_000
            PP.krea2(ESTILO + P[cid], seed, kpath, lora=None)
        xpath = os.path.join(pasta, f"{cid}_x{k}.png")
        if os.path.exists(xpath):
            continue
        src = Image.open(kpath).convert("RGB").resize((840, 1120), Image.LANCZOS)
        nome = PP._upload(src, f"hib_{cid}_{k}.png")
        tags = "dark fantasy, mythological, legendary, painterly, dramatic lighting, glowing magical light, intricate details, " + dados[cid]["tags"]
        wf = {"1": {"class_type": "CheckpointLoaderSimple", "inputs": {"ckpt_name": "S.A.R.S.safetensors"}},
              "2": {"class_type": "CLIPSetLastLayer", "inputs": {"stop_at_clip_layer": -2, "clip": ["1", 1]}},
              "3": {"class_type": "CLIPTextEncode", "inputs": {"text": PP.ANIME_POS + tags, "clip": ["2", 0]}},
              "4": {"class_type": "CLIPTextEncode", "inputs": {"text": NEG + (", " + dados[cid].get("neg", "") if dados[cid].get("neg") else ""), "clip": ["2", 0]}},
              "9": {"class_type": "LoadImage", "inputs": {"image": nome}},
              "10": {"class_type": "VAEEncode", "inputs": {"pixels": ["9", 0], "vae": ["1", 2]}},
              "6": {"class_type": "KSampler", "inputs": {"seed": 777 + k, "steps": 28, "cfg": 5.0, "sampler_name": "euler_ancestral", "scheduler": "normal",
                    "denoise": float(os.environ.get("DEN", "0.45")), "model": ["1", 0], "positive": ["3", 0], "negative": ["4", 0], "latent_image": ["10", 0]}},
              "7": {"class_type": "VAEDecode", "inputs": {"samples": ["6", 0], "vae": ["1", 2]}},
              "8": {"class_type": "SaveImage", "inputs": {"filename_prefix": "gk_foil_hib", "images": ["7", 0]}}}
        PP._rodar(wf, xpath)
        Image.open(xpath).convert("RGB").resize((768, 1024), Image.LANCZOS).save(xpath)
        print(cid, k, flush=True)
print("fim")
