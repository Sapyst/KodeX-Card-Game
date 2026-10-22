"""Gera dados/progressao.json (missões, nível, maestria, conquistas e títulos). O servidor lê o mesmo arquivo pelo
servidor/gerar_dados.py. Para mudar um número: edite aqui, rode `python3 servidor/gerar_progressao.py` e o gerar_dados.py."""
import json, os

TR = {"indigena": ["Indígena", "Indigenous"], "cristianismo": ["Cristianismo", "Christianity"], "taoismo": ["Taoísmo", "Taoism"],
      "hinduismo": ["Hinduísmo", "Hinduism"], "bruxaria": ["Bruxaria", "Witchcraft"], "alta_magia": ["Alta Magia", "High Magic"]}


def M(i, c, a, pt, en, moedas=0, booster=0, koins=0):
    d = {"id": i, "cont": c, "alvo": a, "pt": pt, "en": en}
    if moedas: d["moedas"] = moedas
    if booster: d["booster"] = booster
    if koins: d["koins"] = koins
    return d


def C(i, c, a, pt, en, moedas=0, koins=0, titulo=""):
    d = {"id": i, "cont": c, "alvo": a, "pt": pt, "en": en, "moedas": moedas}
    if koins: d["koins"] = koins
    if titulo: d["titulo"] = titulo
    return d


diarias = [
    M("vencer_2", "vitorias", 2, "Vença 2 partidas", "Win 2 matches", 30),
    M("jogar_3", "partidas", 3, "Jogue 3 partidas", "Play 3 matches", 20),
    M("entidades_10", "entidades", 10, "Invoque 10 Entidades", "Summon 10 Entities", 20),
    M("ritos_5", "ritos", 5, "Lance 5 Ritos", "Cast 5 Rites", 25),
    M("selos_3", "selos", 3, "Coloque 3 Selos", "Set 3 Seals", 25),
    M("reliquias_3", "reliquias", 3, "Equipe 3 Relíquias", "Equip 3 Relics", 25),
    M("dano_20", "dano", 20, "Cause 20 de dano na Cornucópia inimiga", "Deal 20 damage to the enemy Cornucopia", 25),
    M("destruir_8", "mortes", 8, "Destrua 8 Entidades inimigas", "Destroy 8 enemy Entities", 25),
    M("golpes_5", "golpes", 5, "Dê 5 golpes diretos na Cornucópia", "Land 5 direct hits on the Cornucopia", 20),
    M("online_1", "online_partidas", 1, "Jogue 1 partida online", "Play 1 online match", 30),
    M("solo_1", "solo_vitorias", 1, "Vença 1 partida de um modo Solo", "Win 1 match in a Solo mode", 30),
] + [M("vit_" + k, "vit_" + k, 1, "Vença com um deck de " + v[0], "Win with a " + v[1] + " deck", 40) for k, v in TR.items()]

semanais = [
    M("s_vencer_10", "vitorias", 10, "Vença 10 partidas", "Win 10 matches", booster=1),
    M("s_jogar_20", "partidas", 20, "Jogue 20 partidas", "Play 20 matches", 100),
    M("s_lendarias_5", "lendarias", 5, "Jogue 5 cartas Lendárias", "Play 5 Legendary cards", 80, koins=10),
    M("s_destruir_40", "mortes", 40, "Destrua 40 Entidades inimigas", "Destroy 40 enemy Entities", 100),
    M("s_online_5", "online_vitorias", 5, "Vença 5 partidas online", "Win 5 online matches", 150),
    M("s_missoes_10", "missoes", 10, "Complete 10 missões diárias", "Complete 10 daily missions", booster=1),
    M("s_dano_100", "dano", 100, "Cause 100 de dano na Cornucópia inimiga", "Deal 100 damage to the enemy Cornucopia", 100),
]

conquistas = [
    C("primeira_vitoria", "vitorias", 1, "Primeira vitória", "First victory", 25),
    C("vitorias_10", "vitorias", 10, "10 vitórias", "10 victories", 50),
    C("vitorias_50", "vitorias", 50, "50 vitórias", "50 victories", 100),
    C("vitorias_100", "vitorias", 100, "100 vitórias", "100 victories", 200, titulo="veterano"),
    C("partidas_25", "partidas", 25, "Jogue 25 partidas", "Play 25 matches", 50),
    C("sequencia_3", "seq_max", 3, "Vença 3 seguidas", "Win 3 in a row", 40),
    C("sequencia_7", "seq_max", 7, "Vença 7 seguidas", "Win 7 in a row", 120, titulo="imparavel"),
    C("intocavel", "intocavel", 1, "Vença sem perder Cornucópia", "Win without losing Cornucopia", 80),
    C("por_um_fio", "por_um_fio", 1, "Vença com 1 de Cornucópia", "Win with 1 Cornucopia left", 60),
    C("relampago", "rapido", 1, "Vença até o turno 10", "Win by turn 10", 60),
    C("maratona", "maratona", 1, "Jogue uma partida de 40 turnos", "Play a 40-turn match", 40),
    C("empate", "empates", 1, "Empate uma partida", "Draw a match", 30),
    C("entidades_100", "entidades", 100, "Invoque 100 Entidades", "Summon 100 Entities", 50),
    C("ritos_100", "ritos", 100, "Lance 100 Ritos", "Cast 100 Rites", 50),
    C("selos_50", "selos", 50, "Coloque 50 Selos", "Set 50 Seals", 50),
    C("reliquias_50", "reliquias", 50, "Equipe 50 Relíquias", "Equip 50 Relics", 50),
    C("lendarias_10", "lendarias", 10, "Jogue 10 Lendárias", "Play 10 Legendaries", 60),
    C("destruidor_100", "mortes", 100, "Destrua 100 Entidades inimigas", "Destroy 100 enemy Entities", 80),
    C("dano_500", "dano", 500, "Cause 500 de dano", "Deal 500 damage", 80),
    C("golpes_50", "golpes", 50, "Dê 50 golpes diretos", "Land 50 direct hits", 50),
] + [C("discipulo_" + k, "vit_" + k, 10, "10 vitórias com " + v[0], "10 wins with " + v[1], 40) for k, v in TR.items()] + [
    C("seis_tradicoes", "tradicoes_vencidas", 6, "Vença com as 6 tradições", "Win with all 6 traditions", 100, titulo="peregrino_das_seis"),
    C("vence_arquimago", "arquimago_vitorias", 1, "Vença o Arquimago", "Beat the Archmage", 60),
    C("arquimago_10", "arquimago_vitorias", 10, "Vença o Arquimago 10 vezes", "Beat the Archmage 10 times", 150, titulo="mata_arquimago"),
    C("online_primeira", "online_vitorias", 1, "Primeira vitória online", "First online win", 40),
    C("online_10", "online_vitorias", 10, "10 vitórias online", "10 online wins", 120),
    C("online_25", "online_partidas", 25, "Jogue 25 partidas online", "Play 25 online matches", 80),
    C("boosters_10", "boosters", 10, "Abra 10 boosters", "Open 10 boosters", 40),
    C("boosters_50", "boosters", 50, "Abra 50 boosters", "Open 50 boosters", 100),
    C("primeira_foil", "foils", 1, "Tenha uma carta foil", "Own a foil card", 50),
    C("foils_5", "foils", 5, "Tenha 5 cartas foil", "Own 5 foil cards", 120),
    C("colecionador_100", "cartas_distintas", 100, "Tenha 100 cartas diferentes", "Own 100 different cards", 80),
    C("colecao_tradicao", "tradicoes_completas", 2, "Complete outra tradição (além da inicial)", "Complete another tradition (besides the starter)", 150),
    C("colecao_toda", "tradicoes_completas", 6, "Complete as 6 tradições", "Complete all 6 traditions", 500, titulo="guardiao_do_codice"),
    C("enigmas_6", "enigmas", 6, "Resolva 6 enigmas", "Solve 6 puzzles", 80),
    C("enigmas_todos", "enigmas", 12, "Resolva todos os 12 enigmas", "Solve all 12 puzzles", 200, titulo="decifrador"),
    C("torneio", "torneio_vencido", 1, "Vença o Torneio", "Win the Tournament", 100),
    C("choronzon", "choronzon_vencido", 1, "Sele o Abismo (vença Choronzon)", "Seal the Abyss (beat Choronzon)", 100),
    C("peregrinacao", "pere_fim", 1, "Complete uma Peregrinação", "Complete a Pilgrimage", 150),
    C("nivel_10", "nivel", 10, "Chegue ao nível 10", "Reach level 10", 50),
    C("nivel_25", "nivel", 25, "Chegue ao nível 25", "Reach level 25", 150),
    C("dias_7", "dias_max", 7, "Entre 7 dias seguidos", "Log in 7 days in a row", 50),
    C("dias_30", "dias_max", 30, "Entre 30 dias seguidos", "Log in 30 days in a row", 200, titulo="devoto"),
    C("missoes_50", "missoes", 50, "Complete 50 missões diárias", "Complete 50 daily missions", 100),
    C("maestria_max", "maestria_max", 5, "Maestria 5 em uma tradição", "Mastery 5 in one tradition", 150),
]
assert len(conquistas) == 50, len(conquistas)

titulos = {"iniciado": ["Iniciado", "Initiate"], "adepto": ["Adepto", "Adept"], "hierofante": ["Hierofante", "Hierophant"],
           "magus": ["Magus", "Magus"], "mestre_do_codice": ["Mestre do Códice", "Master of the Codex"], "veterano": ["Veterano", "Veteran"],
           "imparavel": ["Imparável", "Unstoppable"], "peregrino_das_seis": ["Peregrino das Seis", "Pilgrim of the Six"],
           "mata_arquimago": ["Mata-Arquimago", "Archmage Slayer"], "guardiao_do_codice": ["Guardião do Códice", "Keeper of the Codex"],
           "decifrador": ["Decifrador", "Decipherer"], "devoto": ["Devoto", "Devotee"], "selador_do_abismo": ["Selador do Abismo", "Sealer of the Abyss"]}
for k, v in TR.items():
    titulos["mestre_" + k] = [("Mestre da " if k in ("bruxaria", "alta_magia") else "Mestre do ") + v[0], "Master of " + v[1]]

out = {"_doc": "Gerado por dados/gerar_progressao.py. O servidor usa os mesmos números (servidor/gerar_dados.py).",
       "xp": {"vitoria": 30, "empate": 20, "derrota": 15, "online": 10, "missao": 20, "semanal": 60},
       "nivel": {"base": 100, "passo": 25, "teto": 400, "titulos": {"5": "iniciado", "10": "adepto", "20": "hierofante", "30": "magus", "50": "mestre_do_codice"}},
       "maestria": {"limites": [100, 300, 600, 1000, 1500],
                    "premios": [{"moedas": 50}, {"moedas": 100}, {"booster": 1}, {"koins": 30}, {"booster": 1, "titulo": "mestre_"}]},
       "sequencia": {"a_cada": 7, "booster": 1, "koins": 20},
       "diarias": diarias, "semanais": semanais, "conquistas": conquistas, "titulos": titulos, "tradicoes": TR}
aqui = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "godot", "dados")
json.dump(out, open(os.path.join(aqui, "progressao.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)
print(len(diarias), "diárias,", len(semanais), "semanais,", len(conquistas), "conquistas,", len(titulos), "títulos")
