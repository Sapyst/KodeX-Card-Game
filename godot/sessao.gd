extends Node
## Autoload "Sessao": o que a próxima partida usa (decks, oponente, modo) e o progresso do torneio.

const DECKS := ["indigena", "cristianismo", "taoismo", "hinduismo", "bruxaria", "alta_magia"]
const NOME_DECK := {"indigena": "Indígena", "cristianismo": "Cristianismo", "taoismo": "Taoismo",
	"hinduismo": "Hinduísmo", "bruxaria": "Bruxaria", "alta_magia": "Alta magia", "misto": "Misto"}

var db: Dictionary = {}
var codex: Dictionary = {}           # id → {titulo_pt/en, lore_pt/en, curiosidade_pt/en} (dados/codex/*.json)
var arte_revisao: Array = []         # ids com arte provisória (marcados "em revisão" na Coleção)
var tokens: Dictionary = {}          # nome PT do token (como nas ações summon_token) → {id, en, cultura}
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
	carregar_perfil()
	if OS.get_environment("GD_TUTORIAL") != "":          # teste: abre a mesa direto no tutorial
		preparar_tutorial()


## Recarrega cartas e lore no idioma atual (nomes e textos das cartas vêm de cartas_en.json no inglês).
func carregar_dados() -> void:
	if codex.is_empty():
		for d in DECKS + ["abismo"]:
			var arq := "res://dados/codex/%s.json" % d
			if FileAccess.file_exists(arq):
				codex.merge(JSON.parse_string(FileAccess.get_file_as_string(arq)))
		if FileAccess.file_exists("res://dados/arte_revisao.json"):
			arte_revisao = JSON.parse_string(FileAccess.get_file_as_string("res://dados/arte_revisao.json"))
	if FileAccess.file_exists("res://dados/tokens.json"):
		tokens = JSON.parse_string(FileAccess.get_file_as_string("res://dados/tokens.json"))
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


func novo_torneio(_deck_escolhido := "") -> void:
	modo = "torneio"
	deck_jogador_nome = tradicao_do_deck(deck_ativo_ids())
	var campeoes := DECKS.slice(0, 5)
	campeoes.shuffle()
	torneio_ordem = campeoes + ["alta_magia"]
	torneio_idx = 0
	preparar_luta_torneio()


func preparar_luta_torneio() -> void:
	oponente = torneio_ordem[torneio_idx]
	deck_jogador = deck_ativo_ids()
	deck_oponente = montar_deck(oponente)
	resultado = ""


## Tutorial: Alta Magia × Taoísmo com as cartas na ordem do roteiro (tutorial.gd); o resto do deck completa as 32.
func preparar_tutorial() -> void:
	modo = "tutorial"
	deck_jogador_nome = "alta_magia"
	oponente = "taoismo"
	deck_jogador = _deck_ordenado("alta_magia", Tutorial.DECK_JOGADOR)
	deck_oponente = _deck_ordenado("taoismo", Tutorial.DECK_OPONENTE)
	resultado = ""


func _deck_ordenado(deck: String, fim: Array) -> Array:
	var resto: Array = (db["decks"][deck] as Array).duplicate()
	for cid in fim:
		resto.erase(cid)
	while resto.size() + fim.size() > 32:
		resto.pop_back()
	return resto + fim


func preparar_arcade(meu_deck: String, opon: String, deck_opon: String) -> void:
	modo = "arcade"
	oponente = DECKS[rng.randi_range(0, 5)] if opon == "aleatorio" else opon
	var d_op := deck_opon
	if d_op == "do_personagem":
		d_op = oponente
	elif d_op == "tematico_aleatorio":
		d_op = DECKS[rng.randi_range(0, 5)]
	var idx := int(meu_deck) if meu_deck.is_valid_int() else int(perfil["deck_ativo"])   # índice de um deck do jogador
	deck_jogador = (perfil["decks"][idx]["cartas"] as Array).duplicate() if deck_valido(idx) else deck_ativo_ids()
	deck_jogador_nome = tradicao_do_deck(deck_jogador)
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



# ================= perfil, coleção, moedas e decks (auto-save em user://perfil.json) =================
const SAVE := "user://perfil.json"
const FOTO := "user://foto.png"
const MOEDAS_INICIO := 200
const MOEDAS_ARCADE := 15
const DECK_TAM := 32
var perfil: Dictionary = {}
signal perfil_mudou


func _perfil_novo() -> Dictionary:
	var colecao := {}
	for cid in db["decks"]["alta_magia"]:
		colecao[cid] = int(colecao.get(cid, 0)) + 1
	return {"versao": 1, "nome": "", "tem_foto": false, "moedas": MOEDAS_INICIO, "colecao": colecao, "foils": {},
		"decks": [{"nome": "Alta Magia", "cartas": (db["decks"]["alta_magia"] as Array).duplicate()}], "deck_ativo": 0}


func carregar_perfil() -> void:
	perfil = {}
	if OS.get_environment("GD_PERFIL_NOVO") == "" and FileAccess.file_exists(SAVE):
		var d = JSON.parse_string(FileAccess.get_file_as_string(SAVE))
		if d is Dictionary:
			perfil = d
	if perfil.is_empty():
		perfil = _perfil_novo()
	# JSON devolve números como float: normaliza contagens
	for cid in perfil["colecao"]:
		perfil["colecao"][cid] = int(perfil["colecao"][cid])
	perfil["moedas"] = int(perfil["moedas"])
	perfil["deck_ativo"] = int(perfil["deck_ativo"])


## Auto-save: grava o perfil inteiro a cada mudança (arquivo temporário + renomeia, para não corromper).
func salvar() -> void:
	var tmp := SAVE + ".tmp"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify(perfil, " "))
	f.close()
	DirAccess.rename_absolute(tmp, SAVE)
	perfil_mudou.emit()


func moedas() -> int:
	return int(perfil.get("moedas", 0))


func ganhar_moedas(n: int) -> void:
	perfil["moedas"] = moedas() + n
	salvar()


func gastar_moedas(n: int) -> bool:
	if moedas() < n:
		return false
	perfil["moedas"] = moedas() - n
	salvar()
	return true


func copias(cid: String) -> int:
	return int(perfil["colecao"].get(cid, 0))


func adicionar_carta(cid: String, n := 1, foil := false) -> void:
	perfil["colecao"][cid] = copias(cid) + n
	if foil:
		perfil["foils"][cid] = int(perfil["foils"].get(cid, 0)) + n
	salvar()


## Quantas cópias de `cid` estão em uso nos decks (menos o deck `exceto`).
func copias_em_uso(cid: String, exceto := -1) -> int:
	var n := 0
	for i in perfil["decks"].size():
		if i != exceto:
			n += (perfil["decks"][i]["cartas"] as Array).count(cid)
	return n


## Limite por deck (Lendária 1, demais 2) e cópias que sobram fora dos outros decks.
func pode_por_no_deck(cid: String, idx: int) -> bool:
	var deck: Array = perfil["decks"][idx]["cartas"]
	if deck.size() >= DECK_TAM:
		return false
	var c: Dictionary = db["cartas"][cid]
	var limite := 1 if c["lendaria"] else 2
	if deck.count(cid) >= limite:
		return false
	return deck.count(cid) + copias_em_uso(cid, idx) < copias(cid)


func deck_valido(idx: int) -> bool:
	return idx >= 0 and idx < perfil["decks"].size() and (perfil["decks"][idx]["cartas"] as Array).size() == DECK_TAM


func deck_ativo_ids() -> Array:
	var i := int(perfil["deck_ativo"])
	if not deck_valido(i):
		for k in perfil["decks"].size():
			if deck_valido(k):
				i = k
				break
	return (perfil["decks"][i]["cartas"] as Array).duplicate()


## Tradição que mais aparece no deck (para o retrato/cor do jogador nos menus).
func tradicao_do_deck(ids: Array) -> String:
	var conta := {}
	for cid in ids:
		var cu := str(db["cartas"][cid]["cultura"])
		conta[cu] = int(conta.get(cu, 0)) + 1
	var melhor := "alta_magia"
	for k in conta:
		if int(conta[k]) > int(conta.get(melhor, 0)):
			melhor = k
	return melhor



# ================= boosters (Fase 2) =================
const BOOSTER_PRECO := 100
const CHANCE_FOIL := 0.02          # 1 em 50 cartas; só cartas com arte foil aprovada (assets/carta_foil)
const CHANCE_LENDARIA := 0.05
const TROCA := {"comum": 20, "lendaria": 60, "foil": 150}


func tem_foil(cid: String) -> bool:
	return ResourceLoader.exists("res://assets/carta_foil/%s.webp" % cid)


## Raridade exibida: C (comum, custo até 3), R (rara, custo 4+), SR (Lendária), UR (Lendária foil).
func raridade(cid: String, foil: bool) -> String:
	var c: Dictionary = db["cartas"][cid]
	if c["lendaria"]:
		return "UR" if foil else "SR"
	return "C" if int(c["custo"]) <= 3 else "R"


func valor_troca(cid: String, foil: bool) -> int:
	if foil:
		return TROCA["foil"]
	return TROCA["lendaria"] if db["cartas"][cid]["lendaria"] else TROCA["comum"]


## Compra e sorteia um booster: 3 cartas (Abismo fora), pelo menos 1 Entidade. As cartas já entram na coleção (e o
## save é gravado) antes da animação, para não se perderem se o app fechar. Devolve [{id, foil, nova}] ou [] sem moedas.
func comprar_booster() -> Array:
	if not gastar_moedas(BOOSTER_PRECO):
		return []
	var comuns: Array = []
	var lendarias: Array = []
	var foils: Array = []
	for cid in db["cartas"]:
		var c: Dictionary = db["cartas"][cid]
		if c["cultura"] == "abismo":
			continue
		if c["lendaria"]:
			lendarias.append(cid)
			if tem_foil(cid):
				foils.append(cid)
		else:
			comuns.append(cid)
	var saida: Array = []
	for k in 3:
		var r := rng.randf()
		if r < CHANCE_FOIL and not foils.is_empty():
			saida.append({"id": foils[rng.randi_range(0, foils.size() - 1)], "foil": true})
		elif r < CHANCE_FOIL + CHANCE_LENDARIA:
			saida.append({"id": lendarias[rng.randi_range(0, lendarias.size() - 1)], "foil": false})
		else:
			saida.append({"id": comuns[rng.randi_range(0, comuns.size() - 1)], "foil": false})
	if not saida.any(func(e: Dictionary) -> bool: return db["cartas"][e["id"]]["tipo"] == "entidade"):
		var ents := comuns.filter(func(cid: String) -> bool: return db["cartas"][cid]["tipo"] == "entidade")
		for k in range(2, -1, -1):                       # troca a última carta comum (não foil) por uma Entidade
			if not saida[k]["foil"] and not db["cartas"][saida[k]["id"]]["lendaria"]:
				saida[k] = {"id": ents[rng.randi_range(0, ents.size() - 1)], "foil": false}
				break
	if OS.get_environment("GD_BOOSTER_TESTE") != "":       # teste visual: força comum, lendária e foil
		saida = [{"id": comuns[0], "foil": false}, {"id": lendarias[1], "foil": false}, {"id": foils[0] if not foils.is_empty() else lendarias[0], "foil": not foils.is_empty()}]
	for e in saida:
		e["nova"] = copias(e["id"]) == 0
		perfil["colecao"][e["id"]] = copias(e["id"]) + 1
		if e["foil"]:
			perfil["foils"][e["id"]] = int(perfil["foils"].get(e["id"], 0)) + 1
	salvar()
	return saida


## Troca uma cópia repetida por moedas (só se sobrar cópia para os decks que já a usam).
func trocar_repetida(cid: String, foil: bool) -> bool:
	if copias(cid) <= 1 or copias(cid) - 1 < copias_em_uso(cid):
		return false
	perfil["colecao"][cid] = copias(cid) - 1
	if foil:
		perfil["foils"][cid] = maxi(0, int(perfil["foils"].get(cid, 0)) - 1)
	perfil["moedas"] = moedas() + valor_troca(cid, foil)
	salvar()
	return true
