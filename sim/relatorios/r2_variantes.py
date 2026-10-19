"""Harness de variantes (Analista, rodada 2).

Copia uma pasta de cartas para sim/relatorios/tmp_<x>/<variante>/, aplica edições no JSON
(e na linha "Cópias no deck") e mede a variante contra os outros 5 decks oficiais + espelho.

  python3 relatorios/r2_variantes.py hind|brux|alt [n]
"""
import sys, os, re, json, shutil, glob
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from cards import carregar_pasta
from r2_metricas import rodar

AQUI = os.path.dirname(os.path.abspath(__file__))
CARTAS = os.path.normpath(os.path.join(AQUI, '..', '..', 'cartas'))
DECKS = ['indigena', 'cristianismo', 'taoismo', 'hinduismo', 'bruxaria', 'alta_magia']


def editar(pasta, arquivo, fn_json=None, copias=None):
    p = os.path.join(pasta, arquivo)
    txt = open(p, encoding='utf-8').read()
    if fn_json:
        m = re.search(r"```json\n(.*?)\n```", txt, re.S)
        d = json.loads(m.group(1))
        fn_json(d)
        txt = txt[:m.start(1)] + json.dumps(d, ensure_ascii=False, indent=2) + txt[m.end(1):]
    if copias is not None:
        txt = re.sub(r"(Cópias no deck\s*\|\s*)(\d+)", lambda mm: mm.group(1) + str(copias), txt)
    open(p, 'w', encoding='utf-8').write(txt)


def variante(base, nome, edits, raiz):
    dst = os.path.join(raiz, nome)
    if os.path.exists(dst):
        shutil.rmtree(dst)
    shutil.copytree(os.path.join(CARTAS, base), dst)
    for e in edits:
        editar(dst, *e)
    carregar_pasta(dst)  # valida (32 cartas etc.)
    return dst


def medir(pasta_var, base, n, seed=11, bot="heur"):
    linha = {}
    soma_wr = 0; soma_atk = 0; soma_rod = 0; soma_me = 0; soma_mc = 0; k = 0
    for d in DECKS:
        if d == base:
            continue
        r = rodar(pasta_var, os.path.join(CARTAS, d), n, seed, bot, quiet=True)
        linha[d] = (100 * (r["taxa_a"] + r["emp"] / 2), r["rodadas"], r["ataque_0"], r["ataque_1"])
        soma_wr += linha[d][0]; soma_atk += r["ataque_0"]; soma_rod += r["rodadas"]; k += 1
        soma_me += r["mortes_efeito_causadas_0"]; soma_mc += r["mortes_combate_causadas_0"]
    esp = rodar(pasta_var, pasta_var, n, seed, bot, quiet=True)
    return {"media": soma_wr / k, "por_deck": linha, "atk_med": soma_atk / k, "rod_med": soma_rod / k,
            "me": soma_me / k, "mc": soma_mc / k,
            "esp_rod": esp["rodadas"], "esp_primeiro": 100 * esp["primeiro"], "esp": esp}


def imprimir(nome, m):
    pd = "  ".join(f"{d[:4]} {v[0]:4.1f}" for d, v in m["por_deck"].items())
    print(f"{nome:<34} média {m['media']:5.1f} | {pd} | dano-atq {m['atk_med']:4.1f} mortes efeito {m['me']:3.1f} combate {m['mc']:3.1f} rod {m['rod_med']:4.1f} | esp rod {m['esp_rod']:4.1f} 1º {m['esp_primeiro']:4.1f}%")


# ----------------- edições -----------------
def krishna_other(d):
    d["efeitos"][0]["acoes"][0]["alvo"] = "other_ally_entities"

def krishna_34(d):
    d["atk"] = 3

def durga_sem_impeto(d):
    d["keywords"] = ["guarda"]; d["vida"] = 6

def hanuman_sem_impeto(d):
    d["keywords"] = []; d["vida"] = 4

def hanuman_32(d):
    d["vida"] = 2

def jatayu_sem_impeto(d):
    d["keywords"] = []; d["vida"] = 2

def om_cura(d):
    d["efeitos"][0]["acoes"] = [{"op": "draw", "n": 1}, {"op": "heal", "alvo": "ally_cornucopia", "n": 2}]

def yajna_1fe(d):
    d["efeitos"][0]["acoes"][1]["n"] = 1

def garuda_sem_impeto(d):
    d["keywords"] = []; d["atk"] = 2  # 2/2 + ping = 4,8

def sudarshana_sem_impeto(d):
    d["efeitos"][0]["acoes"] = [a for a in d["efeitos"][0]["acoes"] if a["op"] != "give_keyword"]
    d["efeitos"][0]["acoes"][0]["vida"] = 2  # +2/+2, 2 dano por ataque = 8/8

def narasimha_23(d):
    d["atk"] = 2; d["vida"] = 3

# remoção
def garuda_sem_ping(d):
    d["efeitos"] = []  # 1/2 Ímpeto = 4/5

def yajna_sem_dano(d):
    d["efeitos"][0]["acoes"] = [{"op": "gain_fe", "n": 2, "perm": False}, {"op": "draw", "n": 1}]  # 3+1,5 = 4,5/5

def karma_3(d):
    d["efeitos"][0]["acoes"][0]["n"] = 3  # 3+1,5 = 4,5/6

def lanka_1(d):
    d["efeitos"][0]["acoes"][0]["n"] = 1  # 1,5+2 = 3,5/6

def agni_1(d):
    d["efeitos"][0]["acoes"][0]["n"] = 1  # 1+2 = 3/4

def kali_area1(d):
    d["efeitos"][0]["acoes"][0]["n"] = 1; d["vida"] = 5  # 4+5+1,5+3 = 13,5/15

def pashupat_sem_area(d):
    d["efeitos"][0]["acoes"] = d["efeitos"][0]["acoes"][:1]; d["custo"] = 2  # 5/6

def gandiva_sem_area(d):
    d["efeitos"] = d["efeitos"][:1]; d["efeitos"][0]["acoes"][0]["vida"] = 3  # +3/+3 = 6/8

def trishula_sem_sopro(d):
    d["efeitos"] = d["efeitos"][:2]; d["efeitos"][0]["acoes"][0]["vida"] = 3  # +3/+3 +1 por ataque = 8/10

def sudarshana_1(d):
    d["efeitos"][1]["acoes"][0]["n"] = 1; d["efeitos"][0]["acoes"][0]["vida"] = 2  # +2/+2 Ímpeto, 1 por ataque = 7/8

def brahmastra_sem_area(d):
    d["efeitos"][0]["acoes"] = d["efeitos"][0]["acoes"][:1]; d["custo"] = 3  # 5/7

def tandava_area2(d):
    d["efeitos"][0]["acoes"][0]["n"] = 2  # 3+6 = 9/11

def shiva_sem_impeto(d):
    d["keywords"] = []; d["vida"] = 7  # 5+7+5 = 17

# bruxaria
def maleficio_32(d):
    d["efeitos"][0]["acoes"][0]["atk"] = -3

def vassoura_12(d):
    d["efeitos"][0]["acoes"][0]["vida"] = 2

def saba_lebre_12(d):
    d["efeitos"][0]["acoes"][1]["vida"] = 2

def livro_usos4(d):
    d["usos"] = 4

def strega_strix_12(d):
    d["vida"] = 2; d["efeitos"][0]["acoes"][0]["vida"] = 2

def benandante_33(d):
    d["atk"] = 3

def gato_12(d):
    d["vida"] = 2

# alta magia
def azoth_fe_temp(d):
    d["efeitos"][0]["acoes"].append({"op": "gain_fe", "n": 1, "perm": False})

def anel_12(d):
    d["efeitos"][0]["acoes"][0]["vida"] = 2

def babalon_56(d):
    d["atk"] = 5

def orobas_24(d):
    d["atk"] = 2

def homunculo_13(d):
    d["vida"] = 3

def abrahadabra_draw(d):
    d["efeitos"][0]["acoes"].append({"op": "draw", "n": 1})


VARIANTES = {
    "hind": ("hinduismo", "tmp_hind", {
        "oficial": [],
        "K1 Krishna aura other_ally": [("09_krishna.md", krishna_other)],
        "K2 Krishna 3/4": [("09_krishna.md", krishna_34)],
        "D1 Durga 4/6 sem Impeto": [("10_durga.md", durga_sem_impeto)],
        "H1 Hanuman 3/4 sem Impeto": [("06_hanuman.md", hanuman_sem_impeto)],
        "H2 Hanuman 3/2": [("06_hanuman.md", hanuman_32)],
        "J1 Jatayu 1/2 sem Impeto": [("03_jatayu.md", jatayu_sem_impeto)],
        "G1 Garuda 2/2 sem Impeto": [("02_garuda.md", garuda_sem_impeto)],
        "O1 Om cura2+compra (sem Fe)": [("19_om.md", om_cura)],
        "Y1 Yajna 2dano+1Fe": [("20_yajna.md", yajna_1fe)],
        "S1 Sudarshana +2/+2 sem Impeto": [("27_sudarshana_chakra.md", sudarshana_sem_impeto)],
        "N1 Narasimha 2/3": [("07_narasimha.md", narasimha_23)],
    }),
    "brux": ("bruxaria", "tmp_brux", {
        "oficial": [],
        "M1 Maleficio -3/-2": [("21_maleficio.md", maleficio_32)],
        "V1 Vassoura +1/+2": [("23_vassoura.md", vassoura_12)],
        "S1 Saba Lebre 1/2": [("22_saba_de_walpurgis.md", saba_lebre_12)],
        "L1 Livro Usos 4": [("24_livro_das_sombras.md", livro_usos4)],
        "T1 Strega 2/2 + Strix 1/2": [("04_strega_de_benevento.md", strega_strix_12)],
        "B1 Benandante 3/3 (7,5/7)": [("05_benandante.md", benandante_33)],
        "G1 Gato 1/2 (6/5)": [("02_gato_preto.md", gato_12)],
    }),
    "alt": ("alta_magia", "tmp_alt", {
        "oficial": [],
        "Z1 Azoth +1 Fe temp": [("23_azoth.md", azoth_fe_temp)],
        "A1 Anel +1/+2": [("29_anel_de_salomao.md", anel_12)],
        "B1 Babalon 5/6": [("13_babalon.md", babalon_56)],
        "O1 Orobas 2/4 (8/7)": [("07_orobas.md", orobas_24)],
        "H1 Homunculo 1/3 (5,5/5)": [("01_homunculo.md", homunculo_13)],
        "R1 Abrahadabra c3 + compra (7,5/7)": [("28_abrahadabra.md", abrahadabra_draw)],
    }),
}


def main():
    qual = sys.argv[1]
    n = int(sys.argv[2]) if len(sys.argv) > 2 else 600
    extra = sys.argv[3] if len(sys.argv) > 3 else None
    base, raiz_nome, vars_ = VARIANTES[qual]
    raiz = os.path.join(AQUI, raiz_nome)
    os.makedirs(raiz, exist_ok=True)
    sel = vars_
    if extra == "combos":
        sel = COMBOS[qual]
    elif extra == "remocao":
        sel = REMOCAO
    elif extra == "estrutural":
        sel = ESTRUTURAL
    elif extra == "pacotes":
        sel = PACOTES[qual]
    elif extra == "final":
        sel = FINAL[qual]
        seeds = (11, 12)
        for nome, edits in sel.items():
            pasta = variante(base, re.sub(r"[^A-Za-z0-9]+", "_", nome).strip("_"), edits, raiz)
            for s in seeds:
                m = medir(pasta, base, n, seed=s)
                imprimir(f"{nome} [seed {s}]", m)
                sys.stdout.flush()
        return
    for nome, edits in sel.items():
        pasta = variante(base, re.sub(r"[^A-Za-z0-9]+", "_", nome).strip("_"), edits, raiz)
        m = medir(pasta, base, n)
        imprimir(nome, m)
        sys.stdout.flush()


REMOCAO = {
    "oficial": [],
    "R1 Garuda 1/2 sem ping": [("02_garuda.md", garuda_sem_ping)],
    "R2 Yajna 2Fe+compra, sem dano": [("20_yajna.md", yajna_sem_dano)],
    "R3 Lei do Karma 3": [("15_lei_do_karma.md", karma_3)],
    "R4 Lanka area 1": [("17_incendio_de_lanka.md", lanka_1)],
    "R5 Agni 1": [("13_chamas_de_agni.md", agni_1)],
    "R6 Kali area 1 (4/5)": [("11_kali.md", kali_area1)],
    "R7 Pashupatastra so destroy, c2": [("18_pashupatastra.md", pashupat_sem_area)],
    "R8 Gandiva +3/+3 sem area": [("28_gandiva.md", gandiva_sem_area)],
    "R9 Trishula sem Ultimo Sopro": [("29_trishula.md", trishula_sem_sopro)],
    "R10 Sudarshana 1 por ataque": [("27_sudarshana_chakra.md", sudarshana_1)],
    "R11 Brahmastra so destroy, c3": [("22_brahmastra.md", brahmastra_sem_area)],
    "R12 Tandava area 2": [("25_tandava.md", tandava_area2)],
    "R13 Shiva 5/7 sem Impeto": [("12_shiva_nataraja.md", shiva_sem_impeto)],
    "RA R1+R2+R4+R6+R8+R9": [("02_garuda.md", garuda_sem_ping), ("20_yajna.md", yajna_sem_dano), ("17_incendio_de_lanka.md", lanka_1), ("11_kali.md", kali_area1), ("28_gandiva.md", gandiva_sem_area), ("29_trishula.md", trishula_sem_sopro)],
    "RB RA+R3+R5+R10+R11": [("02_garuda.md", garuda_sem_ping), ("20_yajna.md", yajna_sem_dano), ("17_incendio_de_lanka.md", lanka_1), ("11_kali.md", kali_area1), ("28_gandiva.md", gandiva_sem_area), ("29_trishula.md", trishula_sem_sopro), ("15_lei_do_karma.md", karma_3), ("13_chamas_de_agni.md", agni_1), ("27_sudarshana_chakra.md", sudarshana_1), ("22_brahmastra.md", brahmastra_sem_area)],
    "RC RB+K1+D1+H1": [("02_garuda.md", garuda_sem_ping), ("20_yajna.md", yajna_sem_dano), ("17_incendio_de_lanka.md", lanka_1), ("11_kali.md", kali_area1), ("28_gandiva.md", gandiva_sem_area), ("29_trishula.md", trishula_sem_sopro), ("15_lei_do_karma.md", karma_3), ("13_chamas_de_agni.md", agni_1), ("27_sudarshana_chakra.md", sudarshana_1), ("22_brahmastra.md", brahmastra_sem_area), ("09_krishna.md", krishna_other), ("10_durga.md", durga_sem_impeto), ("06_hanuman.md", hanuman_sem_impeto)],
}

SEM_IMPETO = [("02_garuda.md", garuda_sem_impeto), ("03_jatayu.md", jatayu_sem_impeto), ("06_hanuman.md", hanuman_sem_impeto),
              ("10_durga.md", durga_sem_impeto), ("12_shiva_nataraja.md", shiva_sem_impeto), ("27_sudarshana_chakra.md", sudarshana_sem_impeto),
              ("09_krishna.md", lambda d: d.__setitem__("efeitos", [{"gatilho": "on_play", "acoes": [{"op": "draw", "n": 2}]}]))]  # Krishna 4/4 compra 2 = 11
RB_EDITS = [("02_garuda.md", garuda_sem_ping), ("20_yajna.md", yajna_sem_dano), ("17_incendio_de_lanka.md", lanka_1), ("11_kali.md", kali_area1),
            ("28_gandiva.md", gandiva_sem_area), ("29_trishula.md", trishula_sem_sopro), ("15_lei_do_karma.md", karma_3), ("13_chamas_de_agni.md", agni_1),
            ("27_sudarshana_chakra.md", sudarshana_1), ("22_brahmastra.md", brahmastra_sem_area)]
SELOS = [("15_lei_do_karma.md", karma_3), ("13_chamas_de_agni.md", agni_1), ("17_incendio_de_lanka.md", lanka_1), ("18_pashupatastra.md", pashupat_sem_area)]

def _garuda_sem_impeto_sem_ping(d):
    d["keywords"] = []; d["efeitos"] = []; d["atk"] = 2; d["vida"] = 2  # 2/2 por 2 = 4/5

ESTRUTURAL = {
    "X1 nenhum Impeto (Krishna compra 2)": SEM_IMPETO,
    "X2 X1 + RB (remocao)": SEM_IMPETO[2:] + [("02_garuda.md", _garuda_sem_impeto_sem_ping)] + [e for e in RB_EDITS if e[0] not in ("02_garuda.md", "27_sudarshana_chakra.md")] + [("27_sudarshana_chakra.md", lambda d: (sudarshana_sem_impeto(d), sudarshana_1(d)))],
    "X3 so Selos punitivos fracos": SELOS,
    "X4 X3 + sem Impeto": SELOS + SEM_IMPETO,
}

def _menos_vida(d):
    if d["tipo"] == "entidade" and d["vida"] > 1: d["vida"] -= 1
def _menos_atk(d):
    if d["tipo"] == "entidade" and d["atk"] > 0: d["atk"] -= 1
def _rel_menos_vida(d):
    a = d["efeitos"][0]["acoes"][0]
    if a.get("vida", 0) > 0: a["vida"] -= 1
def krishna_sem_aura(d):
    d["efeitos"] = []  # 4/4 por 5 = 8/11: mede o valor da aura
def hanuman_32_(d): d["vida"] = 2
def durga_44(d): d["vida"] = 4      # 4/4 Ímpeto Guarda = 10/11
def rama_33(d): d["vida"] = 3       # 3/3 Renascer = 8/9
def krishna_34_(d): d["atk"] = 3

HIN_ENT = ["01_matsya.md", "02_garuda.md", "03_jatayu.md", "04_ganesha.md", "05_arjuna.md", "06_hanuman.md", "07_narasimha.md", "08_rama.md",
           "09_krishna.md", "10_durga.md", "11_kali.md", "12_shiva_nataraja.md"]
HIN_REL = ["26_vajra.md", "27_sudarshana_chakra.md", "28_gandiva.md", "29_trishula.md"]
REL_MENOS = [(f, _rel_menos_vida) for f in HIN_REL]
CORPOS = [("06_hanuman.md", hanuman_32_), ("10_durga.md", durga_44), ("08_rama.md", rama_33), ("09_krishna.md", krishna_34_)]

# bruxaria extra
def garrafa_cura(d):
    d["efeitos"][0]["acoes"].append({"op": "heal", "alvo": "ally_cornucopia", "n": 2})  # 5+1 = 6/6
# alta extra
def pedra_13(d):
    d["efeitos"][0]["acoes"][0]["vida"] = 3  # +1/+3 = 4/4
def pentagrama_cura(d):
    d["efeitos"][0]["acoes"].append({"op": "heal", "alvo": "ally_cornucopia", "n": 2})  # 3+1,5+1 = 5,5/6

PACOTES = {
    "hind": {
        "P3 -1 Vida em todas as Entidades": [(f, _menos_vida) for f in HIN_ENT],
        "P4 -1 ATK em todas as Entidades": [(f, _menos_atk) for f in HIN_ENT],
        "P5 Reliquias -1 Vida": REL_MENOS,
        "P7 Krishna 4/4 sem aura": [("09_krishna.md", krishna_sem_aura)],
        "P8 corpos: Hanuman3/2 Durga4/4 Rama3/3 Krishna3/4": CORPOS,
        "P1 RB + Reliquias -1 Vida": RB_EDITS[:8] + [("27_sudarshana_chakra.md", lambda d: (sudarshana_1(d), _rel_menos_vida(d)))] + [RB_EDITS[9]] + [(f, _rel_menos_vida) for f in HIN_REL if f != "27_sudarshana_chakra.md"],
        "P2 P1 + corpos": RB_EDITS[:8] + [("27_sudarshana_chakra.md", lambda d: (sudarshana_1(d), _rel_menos_vida(d)))] + [RB_EDITS[9]] + [(f, _rel_menos_vida) for f in HIN_REL if f != "27_sudarshana_chakra.md"] + CORPOS,
    },
    "brux": {
        "CB3 CB2 + Garrafa cura 2": [("21_maleficio.md", maleficio_32), ("23_vassoura.md", vassoura_12), ("22_saba_de_walpurgis.md", saba_lebre_12), ("24_livro_das_sombras.md", livro_usos4), ("15_garrafa_de_bruxa.md", garrafa_cura)],
    },
    "alt": {
        "P1 Pedra +1/+3": [("31_pedra_de_visao.md", pedra_13)],
        "F1 Pentagrama + cura 2": [("15_pentagrama_flamejante.md", pentagrama_cura)],
        "CA3 Z1+A1+B1+P1+F1": [("23_azoth.md", azoth_fe_temp), ("29_anel_de_salomao.md", anel_12), ("13_babalon.md", babalon_56), ("31_pedra_de_visao.md", pedra_13), ("15_pentagrama_flamejante.md", pentagrama_cura)],
    },
}

# ---- pacote final hinduismo (todas as contas dentro de [P-2, P]) ----
def f_lanka(d):      # custo 1: área 1 + 1 direto = 1,5+2 = 3,5 / 4
    d["custo"] = 1; d["efeitos"][0]["acoes"][0]["n"] = 1
def f_kali(d):       # 4/5, área 1: 4+5+1,5+3 = 13,5 / 15
    d["vida"] = 5; d["efeitos"][0]["acoes"][0]["n"] = 1
def f_vajra(d):      # +2/+0, 2 dano = 4 / 6
    d["efeitos"][0]["acoes"][0]["vida"] = 0; d["efeitos"][0]["acoes"][1]["n"] = 2
def f_sudarshana(d): # +2/+1 Ímpeto, 1 por ataque = 2+1+1+2 = 6 / 8
    d["efeitos"][1]["acoes"][0]["n"] = 1
def f_gandiva(d):    # +3/+1, área 1 por ataque = 4+3 = 7 / 8
    d["efeitos"][0]["acoes"][0]["vida"] = 1
def f_trishula(d):   # +3/+1, 1 por ataque, Sopro 2 área = 4+2+3 = 9 / 10
    d["efeitos"][0]["acoes"][0]["vida"] = 1
def f_brahmastra(d): # custo 3, só destrói = 5 / 7
    d["custo"] = 3; d["efeitos"][0]["acoes"] = d["efeitos"][0]["acoes"][:1]
def f_pashupat(d):   # custo 2, só destrói o atacante = 5 / 6
    d["custo"] = 2; d["efeitos"][0]["acoes"] = d["efeitos"][0]["acoes"][:1]
def f_tandava(d):    # área 2 + 3 direto = 3+6 = 9 / 11
    d["efeitos"][0]["acoes"][0]["n"] = 2

H0 = [("02_garuda.md", garuda_sem_ping), ("17_incendio_de_lanka.md", f_lanka), ("11_kali.md", f_kali), ("26_vajra.md", f_vajra),
      ("27_sudarshana_chakra.md", f_sudarshana), ("28_gandiva.md", f_gandiva), ("29_trishula.md", f_trishula),
      ("15_lei_do_karma.md", karma_3), ("13_chamas_de_agni.md", agni_1), ("22_brahmastra.md", f_brahmastra), ("18_pashupatastra.md", f_pashupat)]
H1 = H0 + [("06_hanuman.md", hanuman_32_), ("09_krishna.md", krishna_34_)]
H2 = H1 + [("25_tandava.md", f_tandava), ("10_durga.md", durga_44)]
CB3 = [("21_maleficio.md", maleficio_32), ("23_vassoura.md", vassoura_12), ("22_saba_de_walpurgis.md", saba_lebre_12), ("24_livro_das_sombras.md", livro_usos4), ("15_garrafa_de_bruxa.md", garrafa_cura)]
CA3 = [("23_azoth.md", azoth_fe_temp), ("29_anel_de_salomao.md", anel_12), ("13_babalon.md", babalon_56), ("31_pedra_de_visao.md", pedra_13), ("15_pentagrama_flamejante.md", pentagrama_cura)]

FINAL = {
    "hind": {"H0 remocao+reliquias (11 cartas)": H0, "H1 H0+Hanuman3/2+Krishna3/4": H1, "H2 H1+Tandava area2+Durga4/4": H2},
    "brux": {"CB3": CB3},
    "alt": {"CA3": CA3},
}

COMBOS = {
    "hind": {
        "C1 K1+D1+O1": [("09_krishna.md", krishna_other), ("10_durga.md", durga_sem_impeto), ("19_om.md", om_cura)],
        "C2 K1+H1+O1": [("09_krishna.md", krishna_other), ("06_hanuman.md", hanuman_sem_impeto), ("19_om.md", om_cura)],
        "C3 K1+D1+J1+O1": [("09_krishna.md", krishna_other), ("10_durga.md", durga_sem_impeto), ("03_jatayu.md", jatayu_sem_impeto), ("19_om.md", om_cura)],
        "C4 K1+D1+H1+O1+Y1": [("09_krishna.md", krishna_other), ("10_durga.md", durga_sem_impeto), ("06_hanuman.md", hanuman_sem_impeto), ("19_om.md", om_cura), ("20_yajna.md", yajna_1fe)],
        "C5 K1+D1+J1+O1+N1": [("09_krishna.md", krishna_other), ("10_durga.md", durga_sem_impeto), ("03_jatayu.md", jatayu_sem_impeto), ("19_om.md", om_cura), ("07_narasimha.md", narasimha_23)],
    },
    "brux": {
        "CB1 M1+V1+S1": [("21_maleficio.md", maleficio_32), ("23_vassoura.md", vassoura_12), ("22_saba_de_walpurgis.md", saba_lebre_12)],
        "CB2 M1+V1+S1+L1": [("21_maleficio.md", maleficio_32), ("23_vassoura.md", vassoura_12), ("22_saba_de_walpurgis.md", saba_lebre_12), ("24_livro_das_sombras.md", livro_usos4)],
    },
    "alt": {
        "CA1 Z1+A1": [("23_azoth.md", azoth_fe_temp), ("29_anel_de_salomao.md", anel_12)],
        "CA2 Z1+A1+B1": [("23_azoth.md", azoth_fe_temp), ("29_anel_de_salomao.md", anel_12), ("13_babalon.md", babalon_56)],
    },
}

if __name__ == "__main__":
    main()
