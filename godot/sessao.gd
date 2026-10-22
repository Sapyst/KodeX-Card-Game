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

var dificuldade := 1                 # IA do oponente: 0 Aprendiz · 1 Mestre · 2 Arquimago
const ESTILOS_IA := {"indigena": "agressivo", "hinduismo": "agressivo", "cristianismo": "controle",
	"alta_magia": "controle", "taoismo": "selos", "bruxaria": "selos"}
const MOEDAS_DIFICULDADE := [10, 15, 25]
const DIFICULDADE_TORNEIO := [0, 1, 1, 2, 2, 2]  # lutas 1 a 6 da história
const DIFICULDADE_TA := [0, 1, 2]                # quartas, semifinal, final do Torneio de 8


func estilo_ia(op: String) -> String:
	return ESTILOS_IA.get(op, "equilibrado")


# torneio
var torneio_ordem: Array = []        # 6 oponentes; o último é sempre alta_magia
var torneio_idx := 0


# ================= idioma (pt / en) =================
var idioma := "pt"
var _ui_en: Dictionary = {}
const CONFIG := "user://config.cfg"


func _ready() -> void:
	RegistroErros.aparar()                                 # relatório de erros local (Opções > Relatório de erros)
	OS.add_logger(RegistroErros.new())
	if OS.get_environment("GD_ERRO_TESTE") != "":
		push_error("erro de teste do relatório")
	rng.randomize()
	if FileAccess.file_exists("res://dados/ui_en.json"):
		_ui_en = JSON.parse_string(FileAccess.get_file_as_string("res://dados/ui_en.json"))
	var cfg := ConfigFile.new()
	if cfg.load(CONFIG) == OK:
		idioma = str(cfg.get_value("geral", "idioma", ""))
		vibracao = bool(cfg.get_value("geral", "vibracao", true))
		texto_grande = bool(cfg.get_value("geral", "texto_grande", false))
		tempo_turno = bool(cfg.get_value("geral", "tempo_turno", true))
		daltonico = bool(cfg.get_value("geral", "daltonico", false))
		animacao_rapida = bool(cfg.get_value("geral", "animacao_rapida", false))
	if idioma == "":
		idioma = "pt" if OS.get_locale_language() == "pt" else "en"     # 1ª vez: idioma do celular
	if OS.get_environment("GD_IDIOMA") != "":
		idioma = OS.get_environment("GD_IDIOMA")
	carregar_dados()
	carregar_perfil()
	if OS.get_environment("GD_PRINTS") != "":            # teste: prints da viewport inteira em qualquer cena (s desde o início)
		for k in OS.get_environment("GD_PRINTS").split(","):
			var tt := float(k)
			get_tree().create_timer(tt, true, false, true).timeout.connect(func() -> void:
				get_viewport().get_texture().get_image().save_png(OS.get_environment("GD_PRINTS_DIR") + "/p_%05.2f.png" % tt))
	if OS.get_environment("GD_ACESS") != "":             # teste: "texto,dalt"
		texto_grande = OS.get_environment("GD_ACESS").contains("texto")
		daltonico = OS.get_environment("GD_ACESS").contains("dalt")
	if OS.get_environment("GD_VERSO") != "":             # teste: equipa um verso e dá Koins
		perfil["versos"] = [OS.get_environment("GD_VERSO"), "codice"]
		perfil["verso"] = OS.get_environment("GD_VERSO")
		_gravar("koins", 420)
	if OS.get_environment("GD_MODO_TESTE") == "peregrinacao":  # teste: regras extras da Peregrinação
		preparar_modo("peregrinacao", deck_tematico("indigena"), "hinduismo", deck_tematico("hinduismo"), 2,
			{"cornucopia": [12, 18], "bencaos": ["fe1", "compra1", "impeto1", "selo-1", "vida1"], "mao_garantida": ["hin_kali"]})
	if OS.get_environment("GD_MODO_TESTE") == "choronzon":
		var dk: Array = montar_deck("misto")
		var ab: Array = db["decks"].get("abismo", [])
		for k in mini(ab.size(), 4):
			dk[dk.size() - 1 - k] = ab[k]
		preparar_modo("choronzon", deck_tematico("cristianismo"), "choronzon", dk, 2, {"cornucopia": [15, 30]})
	if OS.get_environment("GD_ENIGMA") != "":            # teste: abre a mesa direto no enigma de índice N
		var lista: Array = JSON.parse_string(FileAccess.get_file_as_string("res://dados/enigmas.json"))
		var e: Dictionary = lista[int(OS.get_environment("GD_ENIGMA"))]
		preparar_modo("enigma", [], "alta_magia", [], 1, {"enigma": e, "enigma_id": e["id"]})
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


## Opções (user://config.cfg): vibração ligada/desligada e animações normais/rápidas (a mesa roda 1,5× mais rápido).
var vibracao := true
var animacao_rapida := false
var texto_grande := false              # acessibilidade: textos longos em 2× (Fonte57.grande)
var tempo_turno := true                # limite de 75 s por turno contra a IA (online é sempre ligado)
var daltonico := false                 # acessibilidade: cores de destaque trocadas por pares azul/laranja + ícones
const VEL_RAPIDA := 1.5


func _gravar_opcao(chave: String, v) -> void:
	var cfg := ConfigFile.new()
	cfg.load(CONFIG)
	cfg.set_value("geral", chave, v)
	cfg.save(CONFIG)


func alternar_vibracao() -> void:
	vibracao = not vibracao
	_gravar_opcao("vibracao", vibracao)
	if vibracao:
		vibrar(40, 0.6)


func alternar_tempo_turno() -> void:
	tempo_turno = not tempo_turno
	_gravar_opcao("tempo_turno", tempo_turno)


func alternar_texto() -> void:
	texto_grande = not texto_grande
	_gravar_opcao("texto_grande", texto_grande)


func alternar_daltonico() -> void:
	daltonico = not daltonico
	_gravar_opcao("daltonico", daltonico)


func alternar_animacao() -> void:
	animacao_rapida = not animacao_rapida
	_gravar_opcao("animacao_rapida", animacao_rapida)


func velocidade_mesa() -> float:
	return VEL_RAPIDA if animacao_rapida else 1.0


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
	if deck == "choronzon":
		return {"nome": "Choronzon", "titulo": "o Habitante do Abismo" if idioma == "pt" else "the Dweller in the Abyss", "cor": "#c070ff"}
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
	salvar_torneio()
	preparar_luta_torneio()


func torneio_ativo() -> bool:
	return not torneio_ordem.is_empty() and torneio_idx < torneio_ordem.size()


## O Torneio da história fica no save: fechar o app no meio não volta para a luta 1.
func salvar_torneio() -> void:
	if torneio_ativo():
		perfil["torneio"] = {"ordem": torneio_ordem, "idx": torneio_idx, "deck": deck_jogador_nome}
	else:
		perfil.erase("torneio")
	salvar()


func encerrar_torneio() -> void:
	torneio_ordem = []
	torneio_idx = 0
	salvar_torneio()


func preparar_luta_torneio() -> void:
	oponente = torneio_ordem[torneio_idx]
	dificuldade = DIFICULDADE_TORNEIO[mini(torneio_idx, 5)]
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


func preparar_arcade(meu_deck: String, opon: String, deck_opon: String, nivel := 1) -> void:
	modo = "arcade"
	dificuldade = clampi(nivel, 0, 2)
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


# ================= modos solo (docs/modos_solo.md) =================
## Regras extras que a mesa lê no começo da partida: cornucopia [jog, opon], mao_garantida (ids na mão inicial do
## oponente), bencaos (Peregrinação), sigilo_a_cada (Choronzon), semente (Desafio do dia).
var extras: Dictionary = {}
var moedas_vistas := -1                  # o que o contador do Início já mostrou (moedas voando ao voltar ao menu)
var koins_vistos := -1


func preparar_modo(m: String, meu: Array, opon: String, deck_op: Array, nivel: int, ext := {}) -> void:
	modo = m
	deck_jogador = meu.duplicate()
	deck_jogador_nome = tradicao_do_deck(deck_jogador)
	oponente = opon
	deck_oponente = deck_op.duplicate()
	dificuldade = clampi(nivel, 0, 2)
	extras = ext.duplicate(true)
	resultado = ""


func deck_tematico(trad: String) -> Array:
	return (db["decks"][trad] as Array).duplicate()


# ================= vibração (resposta tátil no celular) =================
var _sem_vibrar := OS.get_environment("GD_AUTO") != "" or OS.get_environment("GD_DEMO") != ""


## Vibração curta (ms, força 0..1). Não vibra em teste automático (GD_AUTO) nem na demo (GD_DEMO).
func vibrar(ms: int, forca: float = 0.5) -> void:
	if _sem_vibrar or not vibracao:
		return
	Input.vibrate_handheld(ms, clampf(forca, 0.0, 1.0))


## n pulsos de `ms` separados por `pausa` s (recusa, vitória).
func vibrar_pulsos(n: int, ms: int, forca: float = 0.5, pausa: float = 0.07) -> void:
	for k in n:
		vibrar(ms, forca)
		await get_tree().create_timer(pausa + ms / 1000.0).timeout



# ================= perfil, coleção, moedas e decks (auto-save cifrado em user://perfil.dat) =================
## O save é cifrado (AES-256 do Godot, com conferência de integridade): editar o arquivo invalida a leitura.
## Guarda sempre o save anterior (.bak) para não perder o progresso se a gravação for interrompida.
## Isto só afasta curiosos: a chave vive dentro do jogo. A proteção de verdade virá com a economia no servidor (Fase B).
const SAVE := "user://perfil.dat"
const SAVE_BAK := "user://perfil.dat.bak"
const SAVE_ANTIGO := "user://perfil.json"          # até a v0.7.8 o save era JSON aberto: migra uma vez e apaga
const FOTO := "user://foto.png"
const MOEDAS_INICIO := 200
const MOEDAS_ARCADE := 15
func moedas_arcade() -> int:
	return MOEDAS_DIFICULDADE[clampi(dificuldade, 0, 2)]

const MOEDAS_DIA := 50                             # presente diário (vira à 00:00 de Nova York)
## Koins: moeda dos cosméticos. 10 por dia (acumula até 3 dias), 100 por semana (vira na sexta), +30 a cada versão nova.
const KOINS_DIA := 10
const KOINS_SEMANA := 100
const KOINS_VERSAO := 30
const MOEDAS_VERSAO := 50
const ACUMULO_DIAS := 3                            # dias sem abrir o jogo acumulam até 3 presentes
const DECK_TAM := 32
const PROTEGIDOS := ["moedas", "boosters_gratis", "essencia", "koins"]  # valores guardados disfarçados na memória (contra editores de memória)
var perfil: Dictionary = {}
var _prot := {}                                    # chave → [valor XOR máscara, máscara, conferência]
signal perfil_mudou


func _chave() -> String:
	# montada em partes para não aparecer como texto corrido dentro do executável
	var p := PackedStringArray(["k0", "d3", "X", "-s4p", "yst", "-c0d", "1c3"])
	return ("".join(p) + str(0x5f3759df)).sha256_text()


func _perfil_novo() -> Dictionary:
	var colecao := {}
	for cid in db["decks"]["alta_magia"]:
		colecao[cid] = int(colecao.get(cid, 0)) + 1
	return {"versao": 2, "nome": "", "tem_foto": false, "moedas": MOEDAS_INICIO, "colecao": colecao, "foils": {},
		"decks": [{"nome": "Alta Magia", "cartas": (db["decks"]["alta_magia"] as Array).duplicate()}], "deck_ativo": 0,
		"versao_vista": str(ProjectSettings.get_setting("application/config/version", "")),
		"versao_premiada": str(ProjectSettings.get_setting("application/config/version", ""))}


func _ler_cifrado(caminho: String):
	if not FileAccess.file_exists(caminho):
		return null
	var f := FileAccess.open_encrypted_with_pass(caminho, FileAccess.READ, _chave())
	if f == null:                                  # adulterado ou corrompido: a conferência do Godot falha
		return null
	var d = JSON.parse_string(f.get_as_text())
	f.close()
	return d if d is Dictionary else null


func carregar_perfil() -> void:
	perfil = {}
	if OS.get_environment("GD_PERFIL_NOVO") == "":
		var d = _ler_cifrado(SAVE)
		if d == null:
			d = _ler_cifrado(SAVE_BAK)
			if d != null:                                  # principal ruim, cópia boa: descarta o ruim (não vira .bak)
				DirAccess.remove_absolute(SAVE)
		if d == null and not FileAccess.file_exists(SAVE) and not FileAccess.file_exists(SAVE_BAK) \
				and FileAccess.file_exists(SAVE_ANTIGO):
			d = JSON.parse_string(FileAccess.get_file_as_string(SAVE_ANTIGO))   # migração do save aberto antigo
		elif d == null and FileAccess.file_exists(SAVE):
			DirAccess.rename_absolute(SAVE, SAVE + ".invalido")              # guarda o arquivo ruim, não sobrescreve às cegas
		if d is Dictionary:
			perfil = d
	if perfil.is_empty():
		perfil = _perfil_novo()
	# JSON devolve números como float: normaliza contagens
	for cid in perfil["colecao"]:
		perfil["colecao"][cid] = int(perfil["colecao"][cid])
	for k in PROTEGIDOS:                               # tira do dicionário e guarda disfarçado
		_gravar(k, int(perfil.get(k, 0)))
		perfil.erase(k)
	if perfil.has("tarcade"):                          # JSON devolve floats: a chave usa índices inteiros
		var d: Dictionary = perfil["tarcade"]
		for r in (d["rodadas"] as Array).size():
			d["rodadas"][r] = (d["rodadas"][r] as Array).map(func(v) -> int: return int(v))
		d["rodada"] = int(d["rodada"])
	perfil["deck_ativo"] = int(perfil["deck_ativo"])
	if perfil.has("torneio"):
		torneio_ordem = (perfil["torneio"]["ordem"] as Array).duplicate()
		torneio_idx = int(perfil["torneio"]["idx"])
		deck_jogador_nome = str(perfil["torneio"].get("deck", deck_jogador_nome))
	if FileAccess.file_exists(SAVE_ANTIGO):
		salvar()
		DirAccess.remove_absolute(SAVE_ANTIGO)


## Auto-save: grava o perfil inteiro a cada mudança (arquivo temporário + renomeia, com o anterior em .bak).
func salvar() -> void:
	var copia := perfil.duplicate(true)
	for k in PROTEGIDOS:
		copia[k] = _ler(k)
	var tmp := SAVE + ".tmp"
	var f := FileAccess.open_encrypted_with_pass(tmp, FileAccess.WRITE, _chave())
	if f == null:
		return
	f.store_string(JSON.stringify(copia))
	f.close()
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(SAVE_BAK)
		DirAccess.rename_absolute(SAVE, SAVE_BAK)
	DirAccess.rename_absolute(tmp, SAVE)
	perfil_mudou.emit()
	if not _sem_nuvem and Nuvem.ativo():
		Nuvem.livres_mudaram()


var _sem_nuvem := false


## Grava só no aparelho (sem avisar o servidor): usado ao adotar o perfil que veio dele.
func salvar_so_local() -> void:
	_sem_nuvem = true
	salvar()
	_sem_nuvem = false


## Campos que o servidor controla (economia e progresso que dá prêmio). `tudo` = entrar numa conta de outro aparelho:
## traz também nome, decks e opções.
const CAMPOS_SERVIDOR := ["colecao", "foils", "versos", "resgates", "sem_lendaria", "lendarios", "enigmas", "diario_dia",
	"versao_premiada", "choronzon_vencido", "titulos", "novas", "prog_pagos"]
const CAMPOS_LIVRES := ["nome", "decks", "deck_ativo", "verso", "pacote", "tarcade", "torneio", "versao_vista", "pere",
	"torneio_vencido", "historico", "estat", "prog", "titulo", "pere_fim", "avatares"]


func adotar_servidor(srv: Dictionary, tudo := false) -> void:
	for k in CAMPOS_SERVIDOR + (CAMPOS_LIVRES if tudo else ["verso"]):
		if srv.has(k):
			perfil[k] = srv[k]
		elif k in CAMPOS_SERVIDOR:
			perfil.erase(k)
	for cid in perfil.get("colecao", {}):
		perfil["colecao"][cid] = int(perfil["colecao"][cid])
	for cid in perfil.get("foils", {}):
		perfil["foils"][cid] = int(perfil["foils"][cid])
	for k in PROTEGIDOS:
		_gravar(k, int(srv.get(k, 0)))
	if tudo:
		perfil["deck_ativo"] = int(perfil.get("deck_ativo", 0))
	salvar_so_local()


## Histórico do perfil: últimas 30 partidas (com log) e contadores por tipo de adversário, modo e adversário.
## Partida online (lista "partida" do servidor: pid, eu, semente, primeiro, adversario, deck_eu, deck_op).
func preparar_online(info: Dictionary, retomar := false) -> void:
	modo = "online"
	deck_jogador = (info.get("deck_eu", []) as Array).duplicate()
	deck_jogador_nome = tradicao_do_deck(deck_jogador)
	deck_oponente = (info.get("deck_op", []) as Array).duplicate()
	oponente = tradicao_do_deck(deck_oponente)
	dificuldade = 1
	extras = {"online": info.duplicate()}
	extras["online"]["retomar"] = retomar
	resultado = ""
	online_salvo(str(info.get("pid", "")))


## Partida contra bot (busca online sem ninguém): IA Mestre com o deck temático e o nome do personagem + " - Bot".
## Conta como online nas missões, paga o prêmio online (teto do dia no servidor) e entra no histórico como bot.
func preparar_bot(op: String, meu: Array) -> void:
	modo = "bot"
	oponente = op
	deck_jogador = meu.duplicate()
	deck_jogador_nome = tradicao_do_deck(deck_jogador)
	deck_oponente = montar_deck(op)
	dificuldade = 1
	extras = {}
	resultado = ""


## Foto do perfil para o adversário online: JPEG 60×80 em base64 (~3 KB). "" = sem foto (ele vê a silhueta).
func foto_online() -> String:
	if not perfil.get("tem_foto", false) or not FileAccess.file_exists(FOTO):
		return ""
	var im := Image.load_from_file(FOTO)
	if im == null:
		return ""
	im.resize(60, 80, Image.INTERPOLATE_LANCZOS)
	return Marshalls.raw_to_base64(im.save_jpg_to_buffer(0.75))


## Partida online em andamento (para voltar a ela se o app fechar). "" = nenhuma. Fica só neste aparelho.
func online_salvo(pid = null) -> String:
	var cfg := ConfigFile.new()
	cfg.load("user://online.cfg")
	if pid != null:
		cfg.set_value("partida", "pid", str(pid))
		cfg.save("user://online.cfg")
	return str(cfg.get_value("partida", "pid", ""))


func registrar_partida(reg: Dictionary) -> Array:
	var h: Array = perfil.get("historico", [])
	h.push_front(reg)
	if h.size() > 30:
		h.resize(30)
	perfil["historico"] = h
	var e: Dictionary = perfil.get("estat", {})
	var r: String = {"vitoria": "v", "derrota": "d"}.get(reg["resultado"], "e")
	for chave in [["contra", reg["contra"]], ["modos", reg["modo"]], ["adversarios", reg["adversario"]]]:
		var grupo: Dictionary = e.get(chave[0], {})
		var linha: Dictionary = grupo.get(chave[1], {"v": 0, "d": 0, "e": 0})
		linha[r] = int(linha.get(r, 0)) + 1
		grupo[chave[1]] = linha
		e[chave[0]] = grupo
	perfil["estat"] = e
	salvar()
	return Progresso.partida(reg)


## Repete no servidor uma operação feita no aparelho; o perfil que volta corrige qualquer diferença.
func _espelhar(tipo: String, dados: Dictionary) -> void:
	if Nuvem.ativo():
		Nuvem.op(tipo, dados, true)


## Prêmio de partida/modo: credita na hora (offline também) e manda ao servidor, que confere o teto do dia e devolve
## o perfil certo (se passar do teto, o valor volta ao que o servidor diz).
func premio(motivo: String, dados: Dictionary, moedas_local: int, boosters_local := 0) -> void:
	_gravar("moedas", moedas() + moedas_local)
	if boosters_local > 0:
		_gravar("boosters_gratis", boosters_gratis() + boosters_local)
	salvar()
	if Nuvem.ativo():
		var d := dados.duplicate()
		d["motivo"] = motivo
		Nuvem.op("premio", d, true)

## Valor disfarçado: na memória fica só (valor XOR máscara aleatória) + uma conferência. Procurar "250" num editor de
## memória não acha nada; se alguém mexer mesmo assim, a conferência falha e o valor volta ao último salvo.
func _gravar(k: String, n: int) -> void:
	var m := rng.randi() | (rng.randi() << 31)
	_prot[k] = [n ^ m, m, (n ^ 0x2D5A3C1B) + m * 7]


func _ler(k: String) -> int:
	if not _prot.has(k):
		return 0
	var v: Array = _prot[k]
	var n: int = v[0] ^ v[1]
	if (n ^ 0x2D5A3C1B) + int(v[1]) * 7 != int(v[2]):
		var salvo = _ler_cifrado(SAVE)
		n = int(salvo.get(k, 0)) if salvo is Dictionary else 0
		_gravar(k, n)
	return n


func moedas() -> int:
	return _ler("moedas")


func ganhar_moedas(n: int) -> void:
	_gravar("moedas", moedas() + n)
	salvar()


func gastar_moedas(n: int) -> bool:
	if moedas() < n:
		return false
	_gravar("moedas", moedas() - n)
	salvar()
	return true


# ================= presente diário e booster semanal (hora do servidor, ver relogio.gd) =================
## perfil["resgates"] = {dia, semana}: últimos números de dia/semana (Brasília) já pagos.
## Só calcula com hora confiável; sem internet não paga (e nada se perde: acumula até ACUMULO_DIAS).
func recompensas_pendentes() -> Dictionary:
	if not Relogio.sincronizado():
		return {}
	var r: Dictionary = perfil.get("resgates", {})
	var d := Relogio.dia()
	var s := Relogio.semana()
	var dias := clampi(d - int(r.get("dia", d - 1)), 0, ACUMULO_DIAS)
	var bo := 1 if s > int(r.get("semana", s - 1)) else 0
	var sx := Relogio.semana_sexta()
	var ks := KOINS_SEMANA if sx > int(r.get("sexta", sx - 1)) else 0
	return {"dias": dias, "moedas": dias * MOEDAS_DIA, "booster": bo, "koins": dias * KOINS_DIA + ks, "koins_semana": ks}


## Pede a hora ao servidor de novo (nunca confia em tempo contado localmente para pagar) e paga o que estiver pendente.
## Devolve {"moedas", "booster", "dias"} pagos, {} sem nada a pagar, ou {"offline": true} sem conexão.
func resgatar() -> Dictionary:
	if Nuvem.ativo():                              # online: o servidor paga pela hora dele
		var rs: Dictionary = await Nuvem.op("resgatar")
		if rs.is_empty():
			return {"offline": true}
		return {} if int(rs.get("dias", 0)) == 0 and int(rs.get("booster", 0)) == 0 and int(rs.get("koins", 0)) == 0 else rs
	if not await Relogio.sincronizar():
		return {"offline": true}
	var p := recompensas_pendentes()
	if p.is_empty() or (p["dias"] == 0 and p["booster"] == 0 and p["koins"] == 0):
		return {}
	var r0: Dictionary = perfil.get("resgates", {})
	var seq := int(r0.get("seq", 0))
	if int(p["dias"]) > 0:                         # dias seguidos (igual ao servidor): a cada 7, +1 booster e +20 Koins
		seq = seq + 1 if Relogio.dia() - int(r0.get("dia", Relogio.dia() - 1)) == 1 else 1
		if seq % 7 == 0:
			p["booster"] = int(p["booster"]) + 1
			p["koins"] = int(p["koins"]) + 20
			p["bonus_seq"] = true
	p["seq"] = seq
	perfil["resgates"] = {"dia": Relogio.dia(), "semana": Relogio.semana(), "sexta": Relogio.semana_sexta(), "seq": seq,
		"max": maxi(int(r0.get("max", 0)), seq)}
	_gravar("moedas", moedas() + int(p["moedas"]))
	_gravar("boosters_gratis", boosters_gratis() + int(p["booster"]))
	_gravar("koins", koins() + int(p["koins"]))
	salvar()
	return p


func copias(cid: String) -> int:
	return int(perfil["colecao"].get(cid, 0))


func adicionar_carta(cid: String, n := 1, foil := false) -> void:
	if copias(cid) == 0:
		marcar_nova(cid)
	perfil["colecao"][cid] = copias(cid) + n
	if foil:
		perfil["foils"][cid] = int(perfil["foils"].get(cid, 0)) + n
	salvar()


## Quantas cópias de `cid` estão em uso nos decks (menos o deck `exceto`).
func copias_em_uso(cid: String, exceto := -1) -> int:
	var n := 0
	for i in perfil["decks"].size():
		if i != exceto and not deck_livre(i):           # deck livre não usa cópias da coleção
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
	if deck_livre(idx):
		return true
	return deck.count(cid) + copias_em_uso(cid, idx) < copias(cid)


## Deck livre (Modo livre): monta com qualquer carta, mesmo sem tê-la; só vale no Modo livre.
func deck_livre(idx: int) -> bool:
	return idx >= 0 and idx < perfil["decks"].size() and bool(perfil["decks"][idx].get("livre", false))


func deck_valido(idx: int, aceita_livre := false) -> bool:
	return idx >= 0 and idx < perfil["decks"].size() and (perfil["decks"][idx]["cartas"] as Array).size() == DECK_TAM \
		and (aceita_livre or not deck_livre(idx))


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
const CHANCE_TRADICAO := 0.7
const GARANTIA_LENDARIA := 10
## Essência: desfazer uma cópia REPETIDA (sobra fora dos decks) dá Essência; criar uma carta específica custa Essência.
const ESSENCIA_DESFAZ := {"C": 5, "R": 10, "SR": 40, "UR": 100}
const ESSENCIA_CRIA := {"C": 40, "R": 100, "SR": 400}


func essencia() -> int:
	return _ler("essencia")


func koins() -> int:
	return _ler("koins")


# ---------- cosméticos (cosmeticos.gd): perfil["versos"] = ids comprados, perfil["verso"] = equipado ----------
func verso_equipado() -> String:
	return str(perfil.get("verso", "classico"))


func tem_verso(id: String) -> bool:
	return id == "classico" or id in (perfil.get("versos", []) as Array)


func comprar_verso(id: String) -> bool:
	if tem_verso(id) or not gastar_koins(int(Cosmeticos.item(id)["preco"])):
		return false
	var l: Array = perfil.get("versos", [])
	l.append(id)
	perfil["versos"] = l
	perfil["verso"] = id
	salvar()
	_espelhar("verso", {"verso": id})
	return true


func equipar_verso(id: String) -> void:
	if tem_verso(id):
		perfil["verso"] = id
		salvar()


func gastar_koins(n: int) -> bool:
	if koins() < n:
		return false
	_gravar("koins", koins() - n)
	salvar()
	return true


## Presente de versão nova: +30 Koins e +50 de ouro, uma vez por versão (quem acabou de criar o perfil não recebe).
func premiar_versao() -> bool:
	var v := str(ProjectSettings.get_setting("application/config/version", ""))
	if str(perfil.get("versao_premiada", "")) == v or str(perfil.get("versao_vista", "")) == v:
		return false
	perfil["versao_premiada"] = v
	_gravar("koins", koins() + KOINS_VERSAO)
	_gravar("moedas", moedas() + MOEDAS_VERSAO)
	salvar()
	_espelhar("versao", {"versao": v})
	return true


func pode_desfazer(cid: String) -> bool:
	return copias(cid) > 1 and copias(cid) - 1 >= copias_em_uso(cid)


## Desfaz uma cópia repetida: primeiro uma normal; a foil só se não sobrar cópia normal.
func desfazer_carta(cid: String) -> int:
	if not pode_desfazer(cid):
		return 0
	var foils_n := int(perfil["foils"].get(cid, 0))
	var foil := copias(cid) - foils_n <= 0
	var ganho: int = ESSENCIA_DESFAZ[raridade(cid, foil)]
	perfil["colecao"][cid] = copias(cid) - 1
	if foil:
		perfil["foils"][cid] = int(perfil["foils"][cid]) - 1
	_gravar("essencia", essencia() + ganho)
	salvar()
	_espelhar("desfazer", {"carta": cid})
	return ganho


func custo_criar(cid: String) -> int:
	return ESSENCIA_CRIA[raridade(cid, false)]


## Cria uma cópia (até ter o máximo de um deck: Lendária 1, demais 2). Abismo não se cria.
func pode_criar(cid: String) -> bool:
	var c: Dictionary = db["cartas"][cid]
	return c["cultura"] != "abismo" and copias(cid) < (1 if c["lendaria"] else 2) and essencia() >= custo_criar(cid)


func criar_carta(cid: String) -> bool:
	if not pode_criar(cid):
		return false
	_gravar("essencia", essencia() - custo_criar(cid))
	adicionar_carta(cid)
	_espelhar("criar", {"carta": cid})
	return true


func marcar_nova(cid: String) -> void:
	var nv: Dictionary = perfil.get("novas", {})
	nv[cid] = true
	perfil["novas"] = nv


func eh_nova(cid: String) -> bool:
	return (perfil.get("novas", {}) as Dictionary).has(cid)


func vista(cid: String) -> void:
	if eh_nova(cid):
		(perfil["novas"] as Dictionary).erase(cid)
		salvar()
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
func boosters_gratis() -> int:
	return _ler("boosters_gratis")


func usar_booster_gratis() -> bool:
	if boosters_gratis() <= 0:
		return false
	_gravar("boosters_gratis", boosters_gratis() - 1)
	salvar()
	return true


func comprar_booster(gratis := false, trad := "") -> Array:
	if not gratis and not gastar_moedas(BOOSTER_PRECO):
		return []
	if trad == "":
		trad = str(perfil.get("pacote", ""))
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
	# pacote de uma tradição: cada carta tem 70% de chance de sair dela (o resto, de todas)
	var da_trad := func(lista: Array) -> Array:
		if trad == "" or rng.randf() >= CHANCE_TRADICAO:
			return lista
		var f: Array = lista.filter(func(cid: String) -> bool: return db["cartas"][cid]["cultura"] == trad)
		return f if not f.is_empty() else lista
	for k in 3:
		var r := rng.randf()
		if r < CHANCE_FOIL and not foils.is_empty():
			var lf: Array = da_trad.call(foils)
			saida.append({"id": lf[rng.randi_range(0, lf.size() - 1)], "foil": true})
		elif r < CHANCE_FOIL + CHANCE_LENDARIA:
			var ll: Array = da_trad.call(lendarias)
			saida.append({"id": ll[rng.randi_range(0, ll.size() - 1)], "foil": false})
		else:
			var lc: Array = da_trad.call(comuns)
			saida.append({"id": lc[rng.randi_range(0, lc.size() - 1)], "foil": false})
	# garantia: no máximo GARANTIA_LENDARIA boosters seguidos sem Lendária (o 10º traz uma na última carta)
	var tem_lend := saida.any(func(e: Dictionary) -> bool: return db["cartas"][e["id"]]["lendaria"])
	if not tem_lend and int(perfil.get("sem_lendaria", 0)) >= GARANTIA_LENDARIA - 1:
		var ll2: Array = da_trad.call(lendarias)
		saida[2] = {"id": ll2[rng.randi_range(0, ll2.size() - 1)], "foil": false}
		tem_lend = true
	perfil["sem_lendaria"] = 0 if tem_lend else int(perfil.get("sem_lendaria", 0)) + 1
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
		if e["nova"]:
			marcar_nova(e["id"])
		perfil["colecao"][e["id"]] = copias(e["id"]) + 1
		if e["foil"]:
			perfil["foils"][e["id"]] = int(perfil["foils"].get(e["id"], 0)) + 1
	salvar()
	Progresso.contar("boosters")
	return saida


## Troca uma cópia repetida por moedas (só se sobrar cópia para os decks que já a usam).
func trocar_repetida(cid: String, foil: bool) -> bool:
	if copias(cid) <= 1 or copias(cid) - 1 < copias_em_uso(cid):
		return false
	perfil["colecao"][cid] = copias(cid) - 1
	if foil:
		perfil["foils"][cid] = maxi(0, int(perfil["foils"].get(cid, 0)) - 1)
	_gravar("moedas", moedas() + valor_troca(cid, foil))
	salvar()
	_espelhar("trocar", {"carta": cid, "foil": foil})
	return true



# ================= torneio arcade de 8 (Fase 3) =================
## perfil["tarcade"]: {participantes: [8 ids], rodadas: [[8 índices], [4], [2], [1]] (-1 = a definir),
## margem: {"r-m": cornucópia que sobrou ao vencedor}, rodada, eliminado, premio, fim}. "jogador" = você.
const PREMIO_TA := [0, 30, 70, 150]          # saiu nas quartas / semifinal / final (vice) / campeão
const NPCS_TA := ["indigena", "cristianismo", "taoismo", "hinduismo", "bruxaria", "alta_magia", "viajante"]


func ta() -> Dictionary:
	return perfil.get("tarcade", {})


func ta_ativo() -> bool:
	return not ta().is_empty() and not ta().get("fim", false)


func novo_torneio_arcade() -> void:
	var parts: Array = ["jogador"] + NPCS_TA.duplicate()
	parts.shuffle()
	var ordem: Array = []
	for i in 8:
		ordem.append(i)
	perfil["tarcade"] = {"participantes": parts, "rodadas": [ordem, [-1, -1, -1, -1], [-1, -1], [-1]], "margem": {},
		"rodada": 0, "eliminado": false, "premio": -1, "fim": false}
	salvar()


func ta_nome(pid: String) -> String:
	if pid == "jogador":
		var n := str(perfil.get("nome", ""))
		return n if n != "" else t("Você")
	if pid == "viajante":
		return t("O Viajante")
	return str(personagem(pid).get("nome", pid))


## Índice (em participantes) do adversário do jogador na rodada atual, ou -1.
func ta_adversario() -> int:
	var d := ta()
	var r: int = int(d["rodada"])
	if r > 2 or d["eliminado"]:
		return -1
	var slots: Array = d["rodadas"][r]
	var eu: int = (d["participantes"] as Array).find("jogador")
	var k := slots.find(eu)
	if k < 0:
		return -1
	return int(slots[k ^ 1])


func preparar_partida_ta() -> void:
	var d := ta()
	var adv: String = d["participantes"][ta_adversario()]
	modo = "arcade_t"
	dificuldade = DIFICULDADE_TA[clampi(int(d["rodada"]), 0, 2)]
	oponente = adv if adv != "viajante" else DECKS[rng.randi_range(0, 5)]
	deck_jogador = deck_ativo_ids()
	deck_jogador_nome = tradicao_do_deck(deck_jogador)
	deck_oponente = montar_deck("misto" if adv == "viajante" else adv)
	resultado = ""


## Resolve a rodada atual: a partida do jogador pelo `jogador_venceu` (null = jogador já eliminado) e as outras
## sorteadas (50%). Devolve [{m, vencedor, perdedor, margem}] na ordem para animar. Avança a rodada e dá o prêmio.
func ta_resolver_rodada(jogador_venceu) -> Array:
	var d := ta()
	var r: int = int(d["rodada"])
	var slots: Array = d["rodadas"][r]
	var eu: int = (d["participantes"] as Array).find("jogador")
	var res: Array = []
	for m in slots.size() / 2:
		var a: int = int(slots[2 * m])
		var b: int = int(slots[2 * m + 1])
		var venc: int
		if (a == eu or b == eu) and jogador_venceu != null:
			venc = eu if jogador_venceu else (b if a == eu else a)
		else:
			venc = a if rng.randf() < 0.5 else b
		var perd := b if venc == a else a
		d["rodadas"][r + 1][m] = venc
		var margem := rng.randi_range(1, 12)
		d["margem"]["%d-%d" % [r, m]] = margem
		res.append({"m": m, "vencedor": venc, "perdedor": perd, "margem": margem})
		if perd == eu:
			d["eliminado"] = true
			d["premio"] = PREMIO_TA[r]
	d["rodada"] = r + 1
	if r + 1 == 3:
		d["fim"] = true
		if int(d["rodadas"][3][0]) == eu:
			d["premio"] = PREMIO_TA[3]
	salvar()
	return res


## Paga o prêmio uma vez (quando o jogador sai ou vence).
func ta_pagar() -> int:
	var d := ta()
	var p := int(d.get("premio", -1))
	if p > 0 and not d.get("pago", false):
		d["pago"] = true
		premio("torneio8", {"posicao": PREMIO_TA.find(p)}, p, 1 if p >= PREMIO_TA[3] else 0)   # campeão também leva um booster
		return p
	return 0


func ta_encerrar() -> void:
	perfil.erase("tarcade")
	salvar()
