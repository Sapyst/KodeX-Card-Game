class_name MenuOnline
extends RefCounted
## Tela Online (fluxo.gd, estado "online"): buscar partida (prioridade: mesmo país até 5 s → mesmo continente até 15 s →
## o mundo todo), aceitar/recusar a partida encontrada (12 s), sala com código de 4 letras para jogar com um amigo e
## voltar a uma partida que ficou aberta (app fechou no meio). Usa o deck em uso. Servidor: servidor/src/multi.js.

const TEMPO_ACEITAR := 12.0

var f
var fase := ""                 # "" | "buscando" | "encontrada" | "sala" | "conectando"
var partida: Dictionary = {}
var codigo := ""
var aceitei := false
var _t0 := 0                   # ms em que a fase começou (busca: tempo de espera; encontrada: prazo)
var _ger := 0                  # geração: trocar de fase cancela os laços antigos
var _teste := OS.get_environment("GD_ONLINE_TESTE")


func _init(menu) -> void:
	f = menu


func _deck() -> Array:
	if OS.get_environment("GD_DECK_ONLINE") != "":       # teste: deck temático de uma tradição
		return Sessao.montar_deck(OS.get_environment("GD_DECK_ONLINE"))
	return Sessao.deck_ativo_ids()


func _pronto() -> bool:
	if not Nuvem.ativo():
		f.mp.avisar(Sessao.t("Sem conexão com o servidor do jogo."))
		return false
	if _deck().size() != Sessao.DECK_TAM:
		f.mp.avisar(Sessao.t("Monte um deck com 32 cartas primeiro."))
		return false
	return true


func _mudar(nova: String) -> void:
	fase = nova
	_t0 = Time.get_ticks_msec()
	f._ir("online")


func segundos() -> float:
	return (Time.get_ticks_msec() - _t0) / 1000.0


# ---------------- botões ----------------
func botoes() -> void:
	match fase:
		"":
			f._botao(Rect2(80, 160, 200, 34), "Buscar partida", buscar, {"ouro": true})
			f._botao(Rect2(80, 210, 200, 28), "Criar sala com código", criar_sala)
			f._botao(Rect2(80, 246, 200, 28), "Entrar com código", entrar_sala)
			if Sessao.online_salvo() != "":
				f._botao(Rect2(80, 292, 200, 28), "Voltar à partida", retomar)
			f._botao(Rect2(110, 560, 140, 26), "Voltar", func() -> void: f._ir("titulo"))
		"buscando", "sala", "conectando":
			f._botao(Rect2(110, 400, 140, 26), "Cancelar", cancelar)
		"encontrada":
			if not aceitei:
				f._botao(Rect2(50, 330, 120, 30), "Aceitar", aceitar, {"ouro": true})
				f._botao(Rect2(190, 330, 120, 30), "Recusar", recusar)


func desenhar() -> void:
	f._cabecalho("Online", Sessao.t("jogue com outras pessoas"))
	var dk := _deck()
	f._texto_central(Vector2(180, 100), Sessao.t("Deck em uso") + ": " + (Sessao.nome_deck(Sessao.tradicao_do_deck(dk)) if dk.size() == Sessao.DECK_TAM else Sessao.t("incompleto")), Color(0.72, 0.66, 0.6))
	if not Nuvem.ativo():
		f._texto_central(Vector2(180, 118), Sessao.t("sem conexão com o servidor"), Color("#ff9a8a"))
	match fase:
		"":
			f._texto_central(Vector2(180, 336), Sessao.t("Com um amigo: um cria a sala e passa o código."), Color(0.72, 0.66, 0.6))
			f._texto_central(Vector2(180, 350), Sessao.t("Cada turno tem 75 segundos."), Color(0.72, 0.66, 0.6))
		"buscando":
			var s := segundos()
			f._texto_central(Vector2(180, 200), Sessao.t("Buscando adversário") + "." .repeat(1 + int(s * 2) % 3), f.OURO[0], 2)
			f._texto_central(Vector2(180, 236), "%d s" % int(s), f.CREME)
			var onde := Sessao.t("no seu país") if s < 5 else (Sessao.t("no seu continente") if s < 15 else Sessao.t("no mundo todo"))
			f._texto_central(Vector2(180, 256), Sessao.t("procurando") + " " + onde, Color("#9ad0ff"))
		"encontrada":
			f._texto_central(Vector2(180, 200), Sessao.t("Partida encontrada!"), f.OURO[0], 2)
			f._texto_central(Vector2(180, 236), Sessao.t("contra") + " " + str(partida.get("adversario", "?")), f.CREME)
			var resta := maxf(0.0, TEMPO_ACEITAR - segundos())
			f._texto_central(Vector2(180, 262), "%d s" % ceili(resta), Color(1.0, 0.7, 0.4))
			if aceitei:
				f._texto_central(Vector2(180, 340), Sessao.t("Esperando o adversário aceitar..."), Color("#9ad0ff"))
		"sala":
			f._texto_central(Vector2(180, 180), Sessao.t("Código da sala"), Color(0.72, 0.66, 0.6))
			PixelFonte.centrado(f, Vector2(180, 226), codigo, f.OURO[0], 5, f.ESCURO)
			f._texto_central(Vector2(180, 276), Sessao.t("Passe este código para o seu amigo."), f.CREME)
			f._texto_central(Vector2(180, 296), Sessao.t("Esperando") + "." .repeat(1 + int(segundos() * 2) % 3), Color("#9ad0ff"))
		"conectando":
			f._texto_central(Vector2(180, 220), Sessao.t("Conectando..."), Color("#9ad0ff"))


# ---------------- busca ----------------
func buscar() -> void:
	if not _pronto():
		return
	_ger += 1
	var g := _ger
	aceitei = false
	_mudar("buscando")
	var r: Dictionary = await Nuvem.mp("POST", "/v1/mm/buscar", {"deck": _deck(), "nome": str(Sessao.perfil.get("nome", ""))}, 10.0)
	if g != _ger:
		return
	if not r.get("ok", false):
		f.mp.avisar(Sessao.t(str(r.get("erro", "sem conexão"))))
		_mudar("")
		return
	await _laco_busca(g)


func _laco_busca(g: int) -> void:
	while g == _ger:
		var e: Dictionary = await Nuvem.mp("GET", "/v1/mm/estado", {}, 30.0)
		if g != _ger:
			return
		if e.is_empty():
			await f.get_tree().create_timer(1.5).timeout
			continue
		match str(e.get("estado", "")):
			"fora":
				_mudar("")
				return
			"encontrada":
				partida = e.get("partida", {})
				if str(partida.get("estado", "")) == "jogando":
					_comecar(partida)
					return
				if str(partida.get("estado", "")) == "aceitar":
					aceitei = false
					_mudar("encontrada")
					Sessao.vibrar_pulsos(2, 40, 0.8)
					_prazo(g + 1)
					_ger += 1                      # a busca para; a fase "encontrada" segue com a nova geração
					if _teste != "":
						await f.get_tree().create_timer(2.0).timeout
						aceitar()
					return


## Tempo para aceitar: passou sem resposta = a partida cai e você sai da fila.
func _prazo(g: int) -> void:
	await f.get_tree().create_timer(TEMPO_ACEITAR + 0.5).timeout
	if g == _ger and fase == "encontrada" and not aceitei:
		_ger += 1
		f.mp.avisar(Sessao.t("Tempo esgotado: a partida foi cancelada."))
		_mudar("")


func aceitar() -> void:
	var g := _ger
	aceitei = true
	f._ir("online")
	var r: Dictionary = await Nuvem.mp("POST", "/v1/mm/responder", {"pid": partida.get("pid", ""), "aceitar": true}, 10.0)
	var p: Dictionary = r.get("partida", {})
	while g == _ger:
		var est := str(p.get("estado", "cancelada" if not r.get("ok", false) else "aceitar"))
		if est == "jogando":
			_comecar(p)
			return
		if est == "cancelada":                     # o outro recusou ou deixou passar: você volta para a fila
			f.mp.avisar(Sessao.t("O adversário não aceitou. Buscando de novo..."))
			aceitei = false
			_ger += 1
			var g2 := _ger
			_mudar("buscando")
			await _laco_busca(g2)
			return
		var r2: Dictionary = await Nuvem.mp("GET", "/v1/partida/%s?estado=aceitar" % str(partida.get("pid", "")), {}, 25.0)
		if r2.is_empty():
			await f.get_tree().create_timer(1.0).timeout
		else:
			r = r2
			p = r2.get("partida", p)


func recusar() -> void:
	_ger += 1
	Nuvem.mp("POST", "/v1/mm/responder", {"pid": partida.get("pid", ""), "aceitar": false})
	_mudar("")


func cancelar() -> void:
	_ger += 1
	if fase == "buscando":
		Nuvem.mp("POST", "/v1/mm/cancelar", {})
	_mudar("")


# ---------------- sala com código ----------------
func criar_sala() -> void:
	if not _pronto():
		return
	_ger += 1
	var g := _ger
	_mudar("conectando")
	var r: Dictionary = await Nuvem.mp("POST", "/v1/sala/criar", {"deck": _deck(), "nome": str(Sessao.perfil.get("nome", ""))}, 10.0)
	if g != _ger:
		return
	if not r.get("ok", false):
		f.mp.avisar(Sessao.t(str(r.get("erro", "sem conexão"))))
		_mudar("")
		return
	codigo = str(r["codigo"])
	partida = r["partida"]
	_mudar("sala")
	if _teste.begins_with("sala"):                   # teste: deixa o código num arquivo para a outra instância
		var arq := FileAccess.open(_teste.get_slice(":", 1), FileAccess.WRITE)
		arq.store_string(codigo)
		arq.close()
	while g == _ger:
		var r2: Dictionary = await Nuvem.mp("GET", "/v1/partida/%s?estado=sala" % str(partida["pid"]), {}, 25.0)
		if g != _ger:
			return
		if r2.is_empty():
			await f.get_tree().create_timer(1.0).timeout
			continue
		var p: Dictionary = r2.get("partida", {})
		if str(p.get("estado", "")) == "jogando":
			_comecar(p)
			return
		if str(p.get("estado", "")) != "sala":
			f.mp.avisar(Sessao.t("A sala expirou."))
			_mudar("")
			return


func entrar_sala(cod := "") -> void:
	if not _pronto():
		return
	if cod == "":
		cod = await f.pedir_texto(Sessao.t("Código da sala (4 letras)"), false, 4)
	if cod == "":
		return
	_ger += 1
	var g := _ger
	_mudar("conectando")
	var r: Dictionary = await Nuvem.mp("POST", "/v1/sala/entrar", {"codigo": cod.to_upper(), "deck": _deck(), "nome": str(Sessao.perfil.get("nome", ""))}, 10.0)
	if g != _ger:
		return
	if not r.get("ok", false):
		f.mp.avisar(Sessao.t(str(r.get("erro", "sem conexão"))))
		_mudar("")
		return
	_comecar(r["partida"])


# ---------------- voltar a uma partida aberta ----------------
func retomar() -> void:
	var pid := Sessao.online_salvo()
	_ger += 1
	_mudar("conectando")
	var r: Dictionary = await Nuvem.mp("GET", "/v1/partida/%s" % pid, {}, 10.0)
	var p: Dictionary = r.get("partida", {})
	if str(p.get("estado", "")) == "jogando":
		Sessao.preparar_online(p, true)
		f._jogar()
		return
	Sessao.online_salvo("")
	f.mp.avisar(Sessao.t("Essa partida já terminou."))
	_mudar("")


func _comecar(p: Dictionary) -> void:
	_ger += 1
	fase = ""
	Sessao.preparar_online(p)
	f._jogar()
