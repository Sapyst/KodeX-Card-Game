"""Gera dados/progressao.json (missões, nível, maestria, conquistas e títulos). O servidor lê o mesmo arquivo pelo
servidor/gerar_dados.py. Para mudar um número: edite aqui, rode `python3 servidor/gerar_progressao.py` e o gerar_dados.py."""
import json, os

TR = {"indigena": ["Indígena", "Indigenous", "Indígena"], "cristianismo": ["Cristianismo", "Christianity", "Cristianismo"],
      "taoismo": ["Taoísmo", "Taoism", "Taoísmo"], "hinduismo": ["Hinduísmo", "Hinduism", "Hinduismo"],
      "bruxaria": ["Bruxaria", "Witchcraft", "Brujería"], "alta_magia": ["Alta Magia", "High Magic", "Alta Magia"]}


# Textos nos 3 idiomas: `t` = (pt, en, es). O JSON sai com as chaves "pt", "en" e "es" em cada missão/conquista.
def M(i, c, a, t, moedas=0, booster=0, koins=0):
    d = {"id": i, "cont": c, "alvo": a, "pt": t[0], "en": t[1], "es": t[2]}
    if moedas: d["moedas"] = moedas
    if booster: d["booster"] = booster
    if koins: d["koins"] = koins
    return d


def C(i, c, a, t, moedas=0, koins=0, titulo=""):
    d = {"id": i, "cont": c, "alvo": a, "pt": t[0], "en": t[1], "es": t[2], "moedas": moedas}
    if koins: d["koins"] = koins
    if titulo: d["titulo"] = titulo
    return d


diarias = [
    M("vencer_2", "vitorias", 2, ("Vença 2 partidas", "Win 2 matches", "Gana 2 partidas"), 30),
    M("jogar_3", "partidas", 3, ("Jogue 3 partidas", "Play 3 matches", "Juega 3 partidas"), 20),
    M("entidades_10", "entidades", 10, ("Invoque 10 Entidades", "Summon 10 Entities", "Invoca 10 Entidades"), 20),
    M("ritos_5", "ritos", 5, ("Lance 5 Ritos", "Cast 5 Rites", "Lanza 5 Ritos"), 25),
    M("selos_3", "selos", 3, ("Coloque 3 Selos", "Set 3 Seals", "Coloca 3 Sellos"), 25),
    M("reliquias_3", "reliquias", 3, ("Equipe 3 Relíquias", "Equip 3 Relics", "Equipa 3 Reliquias"), 25),
    M("dano_20", "dano", 20, ("Cause 20 de dano à Cornucópia inimiga", "Deal 20 damage to the enemy Cornucopia",
                             "Inflige 20 de daño a la Cornucopia enemiga"), 25),
    M("destruir_8", "mortes", 8, ("Destrua 8 Entidades inimigas", "Destroy 8 enemy Entities", "Destruye 8 Entidades enemigas"), 25),
    M("golpes_5", "golpes", 5, ("Acerte 5 golpes diretos", "Land 5 direct hits", "Asesta 5 golpes directos"), 20),
    M("online_1", "online_partidas", 1, ("Jogue 1 partida online", "Play 1 online match", "Juega 1 partida en línea"), 30),
    M("solo_1", "solo_vitorias", 1, ("Vença 1 partida num modo Solo", "Win 1 match in a Solo mode", "Gana 1 partida en un modo Solo"), 30),
] + [M("vit_" + k, "vit_" + k, 1, ("Vença com um deck de " + v[0], "Win with a " + v[1] + " deck", "Gana con un mazo de " + v[2]), 40)
     for k, v in TR.items()]

# 8 diárias a mais (levantamento de nov/2026, bloco 10), no fim da lista: a ordem importa para o sorteio do dia.
diarias += [
    M("lendarias_2", "lendarias", 2, ("Jogue 2 Lendárias", "Play 2 Legendaries", "Juega 2 Legendarias"), 30),
    M("rapido_1", "rapido", 1, ("Vença em até 10 turnos", "Win within 10 turns", "Gana en 10 turnos o menos"), 35),
    M("intocavel_1", "intocavel", 1, ("Vença sem sofrer dano na Cornucópia", "Win without taking Cornucopia damage",
                                      "Gana sin recibir daño en la Cornucopia"), 40),
    M("arquimago_1", "arquimago_vitorias", 1, ("Vença um Arquimago", "Beat an Archmage", "Vence a un Archimago"), 40),
    M("online_vit_1", "online_vitorias", 1, ("Vença 1 partida online", "Win 1 online match", "Gana 1 partida en línea"), 40),
    M("maratona_1", "maratona", 1, ("Jogue uma partida de 40 turnos ou mais", "Play a match of 40 turns or more",
                                    "Juega una partida de 40 turnos o más"), 30),
    M("entidades_15", "entidades", 15, ("Invoque 15 Entidades", "Summon 15 Entities", "Invoca 15 Entidades"), 30),
    M("dano_35", "dano", 35, ("Cause 35 de dano à Cornucópia inimiga", "Deal 35 damage to the enemy Cornucopia",
                              "Inflige 35 de daño a la Cornucopia enemiga"), 35),
]

semanais = [
    M("s_vencer_10", "vitorias", 10, ("Vença 10 partidas", "Win 10 matches", "Gana 10 partidas"), booster=1),
    M("s_jogar_20", "partidas", 20, ("Jogue 20 partidas", "Play 20 matches", "Juega 20 partidas"), 100),
    M("s_lendarias_5", "lendarias", 5, ("Jogue 5 cartas Lendárias", "Play 5 Legendary cards", "Juega 5 cartas Legendarias"), 80, koins=10),
    M("s_destruir_40", "mortes", 40, ("Destrua 40 Entidades inimigas", "Destroy 40 enemy Entities", "Destruye 40 Entidades enemigas"), 100),
    M("s_online_5", "online_vitorias", 5, ("Vença 5 partidas online", "Win 5 online matches", "Gana 5 partidas en línea"), 150),
    M("s_missoes_10", "missoes", 10, ("Complete 10 missões diárias", "Complete 10 daily missions", "Completa 10 misiones diarias"), booster=1),
    M("s_dano_100", "dano", 100, ("Cause 100 de dano à Cornucópia inimiga", "Deal 100 damage to the enemy Cornucopia",
                                  "Inflige 100 de daño a la Cornucopia enemiga"), 100),
]

conquistas = [
    C("primeira_vitoria", "vitorias", 1, ("Vença sua primeira partida", "Win your first match", "Gana tu primera partida"), 25),
    C("vitorias_10", "vitorias", 10, ("Vença 10 partidas", "Win 10 matches", "Gana 10 partidas"), 50),
    C("vitorias_50", "vitorias", 50, ("Vença 50 partidas", "Win 50 matches", "Gana 50 partidas"), 100),
    C("vitorias_100", "vitorias", 100, ("Vença 100 partidas", "Win 100 matches", "Gana 100 partidas"), 200, titulo="veterano"),
    C("partidas_25", "partidas", 25, ("Jogue 25 partidas", "Play 25 matches", "Juega 25 partidas"), 50),
    C("sequencia_3", "seq_max", 3, ("Vença 3 seguidas", "Win 3 in a row", "Gana 3 seguidas"), 40),
    C("sequencia_7", "seq_max", 7, ("Vença 7 seguidas", "Win 7 in a row", "Gana 7 seguidas"), 120, titulo="imparavel"),
    C("intocavel", "intocavel", 1, ("Vença sem perder Cornucópia", "Win without losing any Cornucopia", "Gana sin perder Cornucopia"), 80),
    C("por_um_fio", "por_um_fio", 1, ("Vença com 1 de Cornucópia", "Win with 1 Cornucopia left", "Gana con 1 de Cornucopia"), 60),
    C("relampago", "rapido", 1, ("Vença até o turno 10", "Win by turn 10", "Gana a más tardar en el turno 10"), 60),
    C("maratona", "maratona", 1, ("Jogue uma partida de 40 turnos", "Play a 40-turn match", "Juega una partida de 40 turnos"), 40),
    C("empate", "empates", 1, ("Empate uma partida", "Tie a match", "Empata una partida"), 30),
    C("entidades_100", "entidades", 100, ("Invoque 100 Entidades", "Summon 100 Entities", "Invoca 100 Entidades"), 50),
    C("ritos_100", "ritos", 100, ("Lance 100 Ritos", "Cast 100 Rites", "Lanza 100 Ritos"), 50),
    C("selos_50", "selos", 50, ("Coloque 50 Selos", "Set 50 Seals", "Coloca 50 Sellos"), 50),
    C("reliquias_50", "reliquias", 50, ("Equipe 50 Relíquias", "Equip 50 Relics", "Equipa 50 Reliquias"), 50),
    C("lendarias_10", "lendarias", 10, ("Jogue 10 Lendárias", "Play 10 Legendaries", "Juega 10 Legendarias"), 60),
    C("destruidor_100", "mortes", 100, ("Destrua 100 Entidades inimigas", "Destroy 100 enemy Entities", "Destruye 100 Entidades enemigas"), 80),
    C("dano_500", "dano", 500, ("Cause 500 de dano à Cornucópia", "Deal 500 Cornucopia damage", "Inflige 500 de daño a la Cornucopia"), 80),
    C("golpes_50", "golpes", 50, ("Acerte 50 golpes diretos", "Land 50 direct hits", "Asesta 50 golpes directos"), 50),
] + [C("discipulo_" + k, "vit_" + k, 10, ("Vença 10 vezes com " + v[0], "Win 10 times with " + v[1], "Gana 10 veces con " + v[2]), 40)
     for k, v in TR.items()] + [
    C("seis_tradicoes", "tradicoes_vencidas", 6, ("Vença com as 6 Tradições", "Win with all 6 Traditions", "Gana con las 6 Tradiciones"), 100,
      titulo="peregrino_das_seis"),
    C("vence_arquimago", "arquimago_vitorias", 1, ("Vença o Arquimago", "Beat the Archmage", "Vence al Archimago"), 60),
    C("arquimago_10", "arquimago_vitorias", 10, ("Vença o Arquimago 10 vezes", "Beat the Archmage 10 times", "Vence al Archimago 10 veces"), 150,
      titulo="mata_arquimago"),
    C("online_primeira", "online_vitorias", 1, ("Vença sua primeira partida online", "Win your first online match",
                                                "Gana tu primera partida en línea"), 40),
    C("online_10", "online_vitorias", 10, ("Vença 10 partidas online", "Win 10 online matches", "Gana 10 partidas en línea"), 120),
    C("online_25", "online_partidas", 25, ("Jogue 25 partidas online", "Play 25 online matches", "Juega 25 partidas en línea"), 80),
    C("boosters_10", "boosters", 10, ("Abra 10 boosters", "Open 10 boosters", "Abre 10 sobres"), 40),
    C("boosters_50", "boosters", 50, ("Abra 50 boosters", "Open 50 boosters", "Abre 50 sobres"), 100),
    C("primeira_foil", "foils", 1, ("Consiga 1 carta foil", "Get 1 foil card", "Consigue 1 carta foil"), 50),
    C("foils_5", "foils", 5, ("Consiga 5 cartas foil", "Get 5 foil cards", "Consigue 5 cartas foil"), 120),
    C("colecionador_100", "cartas_distintas", 100, ("Tenha 100 cartas diferentes", "Own 100 different cards", "Reúne 100 cartas distintas"), 80),
    C("colecao_tradicao", "tradicoes_completas", 2, ("Complete outra Tradição além da inicial", "Complete another Tradition besides your starter",
                                                     "Completa otra Tradición además de la inicial"), 150),
    C("colecao_toda", "tradicoes_completas", 6, ("Complete as 6 Tradições", "Complete all 6 Traditions", "Completa las 6 Tradiciones"), 500,
      titulo="guardiao_do_codice"),
    C("enigmas_6", "enigmas", 6, ("Resolva 6 Enigmas", "Solve 6 Enigmas", "Resuelve 6 Enigmas"), 80),
    C("enigmas_todos", "enigmas", 12, ("Resolva os 12 Enigmas", "Solve all 12 Enigmas", "Resuelve los 12 Enigmas"), 200, titulo="decifrador"),
    C("torneio", "torneio_vencido", 1, ("Vença o Torneio", "Win the Tournament", "Gana el Torneo"), 100),
    C("choronzon", "choronzon_vencido", 1, ("Sele o Abismo (vença Choronzon)", "Seal the Abyss (beat Choronzon)",
                                            "Sella el Abismo (vence a Choronzon)"), 100),
    C("peregrinacao", "pere_fim", 1, ("Complete uma Peregrinação", "Complete a Pilgrimage", "Completa una Peregrinación"), 150),
    C("nivel_10", "nivel", 10, ("Chegue ao nível 10", "Reach level 10", "Llega al nivel 10"), 50),
    C("nivel_25", "nivel", 25, ("Chegue ao nível 25", "Reach level 25", "Llega al nivel 25"), 150),
    C("dias_7", "dias_max", 7, ("Entre 7 dias seguidos", "Log in 7 days in a row", "Entra 7 días seguidos"), 50),
    C("dias_30", "dias_max", 30, ("Entre 30 dias seguidos", "Log in 30 days in a row", "Entra 30 días seguidos"), 200, titulo="devoto"),
    C("missoes_50", "missoes", 50, ("Complete 50 missões diárias", "Complete 50 daily missions", "Completa 50 misiones diarias"), 100),
    C("maestria_max", "maestria_max", 5, ("Chegue à maestria 5 numa Tradição", "Reach Mastery 5 in a Tradition",
                                          "Alcanza maestría 5 en una Tradición"), 150),
]
conquistas.append(C("portador", "lendarios_inv", 12, ("Vença com cada uma das 12 Lendárias (Desafios lendários invertidos)",
                                                    "Win with each of the 12 Legendaries (inverted Legendary challenges)",
                                                    "Gana con cada una de las 12 Legendarias (Desafíos legendarios invertidos)"), 150, titulo="portador"))
HERDEIRO = {"indigena": ["Herdeiro da Mata", "Heir of the Forest", "Heredero de la Selva"],
            "cristianismo": ["Herdeiro da Luz", "Heir of the Light", "Heredero de la Luz"],
            "taoismo": ["Herdeiro do Caminho", "Heir of the Way", "Heredero del Camino"],
            "hinduismo": ["Herdeiro do Ciclo", "Heir of the Cycle", "Heredero del Ciclo"],
            "bruxaria": ["Herdeiro do Caldeirão", "Heir of the Cauldron", "Heredero del Caldero"],
            "alta_magia": ["Herdeiro do Templo", "Heir of the Temple", "Heredero del Templo"]}
# Coleção por tradição (cont "completa_<trad>": 1 quando todas as cartas dela estão na coleção) e estrelas de maestria
# das cartas (cont "estrelas_<n>": quantas cartas já foram jogadas ao menos ESTRELAS[n] vezes).
conquistas += [C("completa_" + k, "completa_" + k, 1, ("Complete a coleção de " + v[0], "Complete the " + v[1] + " collection",
                                                        "Completa la colección de " + v[2]), 150, titulo="herdeiro_" + k)
               for k, v in TR.items()]
conquistas += [
    C("estrela_bronze_10", "estrelas_1", 10, ("Tenha 10 cartas com estrela de bronze", "Have 10 cards with a bronze star",
                                             "Ten 10 cartas con estrella de bronce"), 60),
    C("estrela_bronze_50", "estrelas_1", 50, ("Tenha 50 cartas com estrela de bronze", "Have 50 cards with a bronze star",
                                             "Ten 50 cartas con estrella de bronce"), 150, titulo="constelado"),
    C("estrela_prata_10", "estrelas_2", 10, ("Tenha 10 cartas com estrela de prata", "Have 10 cards with a silver star",
                                            "Ten 10 cartas con estrella de plata"), 120, titulo="mao_firme"),
    C("estrela_ouro_1", "estrelas_3", 1, ("Tenha 1 carta com estrela de ouro", "Have 1 card with a gold star",
                                         "Ten 1 carta con estrella de oro"), 100),
    C("estrela_ouro_10", "estrelas_3", 10, ("Tenha 10 cartas com estrela de ouro", "Have 10 cards with a gold star",
                                           "Ten 10 cartas con estrella de oro"), 300, titulo="lenda_viva"),
    C("maestria_10", "maestria_max", 10, ("Chegue à maestria 10 numa Tradição", "Reach Mastery 10 in a Tradition",
                                          "Alcanza maestría 10 en una Tradición"), 250),
]
assert len(conquistas) == 63, len(conquistas)

# Títulos: id -> [pt, en, es] (mesmo formato de par de antes, com o ES como 3º elemento).
titulos = {"iniciado": ["Iniciado", "Initiate", "Iniciado"], "adepto": ["Adepto", "Adept", "Adepto"],
           "hierofante": ["Hierofante", "Hierophant", "Hierofante"], "magus": ["Magus", "Magus", "Magus"],
           "mestre_do_codice": ["Mestre do Códice", "Master of the Codex", "Maestro del Códice"],
           "veterano": ["Veterano", "Veteran", "Veterano"], "imparavel": ["Imparável", "Unstoppable", "Imparable"],
           "peregrino_das_seis": ["Peregrino das Seis", "Pilgrim of the Six", "Peregrino de las Seis"],
           "mata_arquimago": ["Mata-Arquimago", "Archmage Slayer", "Azote del Archimago"],
           "guardiao_do_codice": ["Guardião do Códice", "Keeper of the Codex", "Guardián del Códice"],
           "decifrador": ["Decifrador", "Decipherer", "Descifrador"], "devoto": ["Devoto", "Devotee", "Devoto"],
           "selador_do_abismo": ["Selador do Abismo", "Sealer of the Abyss", "Sellador del Abismo"]}
MESTRE = {"indigena": ["Mestre Indígena", "Indigenous Master", "Maestro Indígena"],
          "cristianismo": ["Mestre do Cristianismo", "Master of Christianity", "Maestro del Cristianismo"],
          "taoismo": ["Mestre do Taoísmo", "Master of Taoism", "Maestro del Taoísmo"],
          "hinduismo": ["Mestre do Hinduísmo", "Master of Hinduism", "Maestro del Hinduismo"],
          "bruxaria": ["Mestre da Bruxaria", "Master of Witchcraft", "Maestro de la Brujería"],
          "alta_magia": ["Mestre da Alta Magia", "Master of High Magic", "Maestro de la Alta Magia"]}
ARAUTO = {"indigena": ["Arauto da Mata", "Herald of the Forest", "Heraldo de la Selva"],
          "cristianismo": ["Arauto da Luz", "Herald of the Light", "Heraldo de la Luz"],
          "taoismo": ["Arauto do Caminho", "Herald of the Way", "Heraldo del Camino"],
          "hinduismo": ["Arauto do Ciclo", "Herald of the Cycle", "Heraldo del Ciclo"],
          "bruxaria": ["Arauto do Caldeirão", "Herald of the Cauldron", "Heraldo del Caldero"],
          "alta_magia": ["Arauto do Templo", "Herald of the Temple", "Heraldo del Templo"]}
for k in TR:
    titulos["mestre_" + k] = MESTRE[k]
    titulos["arauto_" + k] = ARAUTO[k]
    titulos["herdeiro_" + k] = HERDEIRO[k]
# Títulos de nível (a cada 5 a partir do 15, nos níveis que ainda não tinham) e das estrelas das cartas
NIVEL_TIT = {"15": ("teurgo", ["Teurgo", "Theurgist", "Teurgo"]), "25": ("taumaturgo", ["Taumaturgo", "Thaumaturge", "Taumaturgo"]),
             "35": ("arcanista", ["Arcanista", "Arcanist", "Arcanista"]), "40": ("oraculo", ["Oráculo", "Oracle", "Oráculo"]),
             "45": ("sabio", ["Sábio", "Sage", "Sabio"]), "60": ("arconte", ["Arconte", "Archon", "Arconte"]),
             "70": ("demiurgo", ["Demiurgo", "Demiurge", "Demiurgo"]), "80": ("ascendido", ["Ascendido", "Ascended", "Ascendido"]),
             "90": ("eterno", ["Eterno", "Eternal", "Eterno"]), "100": ("avatar", ["Avatar", "Avatar", "Avatar"])}
for n, (i, t) in NIVEL_TIT.items():
    titulos[i] = t
titulos.update({"portador": ["Portador", "Bearer", "Portador"], "constelado": ["Constelado", "Star-Studded", "Constelado"], "mao_firme": ["Mão Firme", "Steady Hand", "Mano Firme"],
                "lenda_viva": ["Lenda Viva", "Living Legend", "Leyenda Viva"]})

# Emotes liberados na maestria 7 de cada tradição (2 por tradição). Os 4 de sempre ficam com ids 0–3 no jogo.
EMOTES = {"indigena": [["A floresta vê tudo.", "The forest sees all.", "La selva lo ve todo."],
                       ["Pelo espírito da mata!", "By the forest spirit!", "¡Por el espíritu de la selva!"]],
          "cristianismo": [["Paz e bem.", "Peace and goodwill.", "Paz y bien."],
                           ["Que a luz te guarde.", "May the light keep you.", "Que la luz te guarde."]],
          "taoismo": [["O caminho flui.", "The Way flows.", "El camino fluye."],
                      ["Sem pressa, sem pausa.", "No haste, no rest.", "Sin prisa, sin pausa."]],
          "hinduismo": [["Namastê.", "Namaste.", "Namasté."], ["Tudo é ciclo.", "All is a cycle.", "Todo es ciclo."]],
          "bruxaria": [["Hora das bruxas!", "Witching hour!", "¡Hora de las brujas!"],
                       ["Que o caldeirão ferva!", "Let the cauldron boil!", "¡Que hierva el caldero!"]],
          "alta_magia": [["Assim seja.", "So mote it be.", "Así sea."],
                         ["Como em cima, embaixo.", "As above, so below.", "Como es arriba, es abajo."]]}

# Calendário de 28 dias: um dia marcado a cada presente diário resgatado (faltar não zera; continua de onde parou).
CALENDARIO = []
for d in range(1, 29):
    if d == 28: CALENDARIO.append({"escolha": "R", "essencia": 100})
    elif d == 21: CALENDARIO.append({"booster": 2})
    elif d == 14: CALENDARIO.append({"escolha": "R"})
    elif d == 7: CALENDARIO.append({"booster_trad": 1})
    elif d in (3, 10, 17, 24): CALENDARIO.append({"essencia": 40})
    else: CALENDARIO.append({"moedas": 30} if d % 2 else {"koins": 15})

out = {"_doc": "Gerado por dados/gerar_progressao.py. O servidor usa os mesmos números (servidor/gerar_dados.py).",
       "xp": {"vitoria": 30, "empate": 20, "derrota": 15, "online": 10, "missao": 20, "semanal": 60},
       "nivel": {"base": 100, "passo": 25, "teto": 400,
                 "titulos": {"5": "iniciado", "10": "adepto", "20": "hierofante", "30": "magus", "50": "mestre_do_codice",
                             **{n: i for n, (i, _) in NIVEL_TIT.items()}},
                 # a cada 5 níveis, além do booster: Essência, escolha de carta, moedas, (nada: nível de título) — em ciclo
                 "extra_5": [{"essencia": 100}, {"escolha": "R"}, {"moedas": 200}, {}]},
       "maestria": {"limites": [100, 300, 600, 1000, 1500, 2100, 2800, 3600, 4500, 5500],
                    "premios": [{"moedas": 50}, {"moedas": 100}, {"booster": 1}, {"koins": 30}, {"booster": 1, "titulo": "mestre_"},
                                {"booster_trad": 1}, {"emotes": 1}, {"essencia": 150}, {"escolha": "R"},
                                {"booster_trad": 2, "titulo": "arauto_"}]},
       # missões do dia: a 1ª paga moedas, a 2ª Essência e a 3ª Koins (metade do valor em moedas); a trocada herda o tipo
       "diarias_tipos": ["moedas", "essencia", "koins"],
       "estrelas": [25, 100, 250],
       "calendario": CALENDARIO, "emotes": EMOTES,
       "sequencia": {"a_cada": 7, "booster": 1, "koins": 20},
       "diarias": diarias, "semanais": semanais, "conquistas": conquistas, "titulos": titulos, "tradicoes": TR}
aqui = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "godot", "dados")
json.dump(out, open(os.path.join(aqui, "progressao.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)
print(len(diarias), "diárias,", len(semanais), "semanais,", len(conquistas), "conquistas,", len(titulos), "títulos")
