extends Node
## Autoload "Sessao": o que a próxima partida usa (decks, oponente, modo) e o progresso do torneio.

const DECKS := ["indigena", "cristianismo", "taoismo", "hinduismo", "bruxaria", "alta_magia"]
const NOME_DECK := {"indigena": "Indígena", "cristianismo": "Cristianismo", "taoismo": "Taoismo",
	"hinduismo": "Hinduísmo", "bruxaria": "Bruxaria", "alta_magia": "Alta magia", "misto": "Misto"}

var db: Dictionary = {}
var lore: Dictionary = {}
var rng := RandomNumberGenerator.new()

var modo := ""                       # "torneio" | "arcade" | "" (teste por variável de ambiente)
var deck_jogador_nome := "indigena"
var deck_jogador: Array = []         # ids das 32 cartas
var deck_oponente: Array = []
var oponente := "cristianismo"        # chave do personagem (= deck dele)
var resultado := ""                  # "vitoria" | "derrota" | "empate" — preenchido pela mesa

# torneio
var torneio_ordem: Array = []        # 6 oponentes; o último é sempre alta_magia
var torneio_idx := 0


# ================= idioma (pt / en) =================
var idioma := "pt"
var _ui_en: Dictionary = {}
const CONFIG := "user://config.cfg"


func _ready() -> void:
	rng.randomize()
	if FileAccess.file_exists("res://dados/ui_en.json"):
		_ui_en = JSON.parse_string(FileAccess.get_file_as_string("res://dados/ui_en.json"))
	var cfg := ConfigFile.new()
	if cfg.load(CONFIG) == OK:
		idioma = str(cfg.get_value("geral", "idioma", ""))
	if idioma == "":
		idioma = "pt" if OS.get_locale_language() == "pt" else "en"     # 1ª vez: idioma do celular
	if OS.get_environment("GD_IDIOMA") != "":
		idioma = OS.get_environment("GD_IDIOMA")
	carregar_dados()


## Recarrega cartas e lore no idioma atual (nomes e textos das cartas vêm de cartas_en.json no inglês).
func carregar_dados() -> void:
	db = JSON.parse_string(FileAccess.get_file_as_string("res://dados/cartas.json"))
	var arq_lore := "res://dados/lore_en.json" if idioma == "en" else "res://dados/lore.json"
	if FileAccess.file_exists(arq_lore):
		lore = JSON.parse_string(FileAccess.get_file_as_string(arq_lore))
	if idioma == "en" and FileAccess.file_exists("res://dados/cartas_en.json"):
		var en: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://dados/cartas_en.json"))["cartas"]
		for cid in db["cartas"]:
			if en.has(cid):
				db["cartas"][cid]["nome"] = en[cid]["nome"]
				db["cartas"][cid]["texto"] = en[cid]["texto"]


func trocar_idioma() -> void:
	idioma = "en" if idioma == "pt" else "pt"
	var cfg := ConfigFile.new()
	cfg.load(CONFIG)
	cfg.set_value("geral", "idioma", idioma)
	cfg.save(CONFIG)
	carregar_dados()


## Tradução de texto de interface. Os textos ficam em português no código; aqui viram inglês quando preciso.
## Aceita números variáveis ("DANO 3" → chave "DANO %d") e prefixos ("BUSCA ENTIDADE" → "SEARCH " + resto).
func t(s: String) -> String:
	if idioma != "en" or s == "":
		return s
	if _ui_en.has(s):
		return _ui_en[s]
	var re := RegEx.create_from_string("-?\\d+")
	var nums := re.search_all(s)
	if not nums.is_empty():
		var chave := re.sub(s, "%d", true)
		if _ui_en.has(chave):
			var args: Array = []
			for m in nums:
				args.append(int(m.get_string()))
			return (_ui_en[chave] as String) % args
	for pre in ["BUSCA ", "INVOCA ", "ALVO: ", "SELO: "]:
		if s.begins_with(pre):
			return _ui_en[pre] + t(s.substr(pre.length()))
	return s


func nome_deck(d: String) -> String:
	return t(NOME_DECK.get(d, d))


func personagem(deck: String) -> Dictionary:
	return lore.get("personagens", {}).get(deck, {"nome": NOME_DECK.get(deck, deck), "titulo": "", "cor": "#e2b85a"})


## Deck temático (o de 32 da tradição) ou "misto": 32 cartas de todas as tradições com a mesma proporção
## 14 Entidades / 6 Selos / 8 Ritos / 4 Relíquias, no máximo 2 cópias e Lendária só 1 cópia (Conjunto do Abismo fora).
func montar_deck(tipo: String) -> Array:
	if tipo != "misto":
		return (db["decks"][tipo] as Array).duplicate()
	var por_tipo := {"entidade": [], "selo": [], "rito": [], "reliquia": []}
	for cid in db["cartas"]:
		var c: Dictionary = db["cartas"][cid]
		if c["cultura"] == "abismo":
			continue
		por_tipo[c["tipo"]].append(cid)
	var cota := {"entidade": 14, "selo": 6, "rito": 8, "reliquia": 4}
	var deck: Array = []
	for t in cota:
		var pool: Array = por_tipo[t].duplicate()
		var conta := {}
		var lend := 0
		while deck.filter(func(x: String) -> bool: return db["cartas"][x]["tipo"] == t).size() < cota[t] and not pool.is_empty():
			var cid: String = pool[rng.randi_range(0, pool.size() - 1)]
			var c: Dictionary = db["cartas"][cid]
			var limite := 1 if c["lendaria"] else 2
			if c["lendaria"] and lend >= 2:
				pool.erase(cid); continue
			if int(conta.get(cid, 0)) >= limite:
				pool.erase(cid); continue
			conta[cid] = int(conta.get(cid, 0)) + 1
			if c["lendaria"]:
				lend += 1
			deck.append(cid)
	return deck


func novo_torneio(deck_escolhido: String) -> void:
	modo = "torneio"
	deck_jogador_nome = deck_escolhido
	var campeoes := DECKS.slice(0, 5)
	campeoes.shuffle()
	torneio_ordem = campeoes + ["alta_magia"]
	torneio_idx = 0
	preparar_luta_torneio()


func preparar_luta_torneio() -> void:
	oponente = torneio_ordem[torneio_idx]
	deck_jogador = montar_deck(deck_jogador_nome)
	deck_oponente = montar_deck(oponente)
	resultado = ""


func preparar_arcade(meu_deck: String, opon: String, deck_opon: String) -> void:
	modo = "arcade"
	deck_jogador_nome = DECKS[rng.randi_range(0, 5)] if meu_deck == "aleatorio" else meu_deck
	oponente = DECKS[rng.randi_range(0, 5)] if opon == "aleatorio" else opon
	var d_op := deck_opon
	if d_op == "do_personagem":
		d_op = oponente
	elif d_op == "tematico_aleatorio":
		d_op = DECKS[rng.randi_range(0, 5)]
	deck_jogador = montar_deck(deck_jogador_nome)
	deck_oponente = montar_deck(d_op)
	resultado = ""


# ================= vibração (resposta tátil no celular) =================
var _sem_vibrar := OS.get_environment("GD_AUTO") != "" or OS.get_environment("GD_DEMO") != ""


## Vibração curta (ms, força 0..1). Não vibra em teste automático (GD_AUTO) nem na demo (GD_DEMO).
func vibrar(ms: int, forca: float = 0.5) -> void:
	if _sem_vibrar:
		return
	Input.vibrate_handheld(ms, clampf(forca, 0.0, 1.0))


## n pulsos de `ms` separados por `pausa` s (recusa, vitória).
func vibrar_pulsos(n: int, ms: int, forca: float = 0.5, pausa: float = 0.07) -> void:
	for k in n:
		vibrar(ms, forca)
		await get_tree().create_timer(pausa + ms / 1000.0).timeout
