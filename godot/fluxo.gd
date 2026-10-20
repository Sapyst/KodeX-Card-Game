extends Node2D
## Telas fora da mesa (360×640 nativos): título, prólogo, escolha de deck, diálogos do torneio, arcade e resultado.
## Toda a UI é desenhada por código no mesmo estilo pixel da mesa.

const W := 360
const H := 640
const ESCURO := Color("#140c10")
const OURO := [Color("#ffe39a"), Color("#e2b85a"), Color("#9c7430")]
const CREME := Color("#f2e6c8")
const LEND_DO_DECK := {"indigena": "ind_tupa", "cristianismo": "cri_sao_miguel_arcanjo", "taoismo": "tao_imperador_de_jade",
	"hinduismo": "hin_shiva_nataraja", "bruxaria": "bru_hecate", "alta_magia": "alt_anjo_guardiao"}

var estado := "titulo"
var t_estado := 0.0                        # segundos desde a última troca de tela (animações de entrada)
var apertado := -1                         # índice do botão sob o dedo (efeito de pressão)
var transicao := 0.0                       # 0..1 cortina escura entre telas
var brasas: Array[Dictionary] = []         # partículas do fundo
var ultimo_falante := ""
var t_falante := 0.0
var botoes: Array[Dictionary] = []          # {rect, texto, acao, ativo}
var falas: Array = []                      # fila de {quem, texto, cor, retrato}
var fala_vis := 0.0                        # caracteres visíveis (máquina de escrever, 45/s)
var depois_falas: Callable
var tempo := 0.0
var arcade := {"oponente": "aleatorio", "meu_deck": "0", "deck_dele": "do_personagem"}
const OPC := {
	"oponente": ["aleatorio", "indigena", "cristianismo", "taoismo", "hinduismo", "bruxaria", "alta_magia"],
	"deck_dele": ["do_personagem", "tematico_aleatorio", "misto"],
}


## A arte é desenhada em 360×640; em telas mais altas o conteúdo é centralizado verticalmente,
## nunca acima da área segura (câmera/notch) nem abaixo da barra de gestos.
func _enquadrar() -> void:
	var vs := get_viewport_rect().size
	var topo := 0.0
	var base := 0.0
	var win := Vector2(DisplayServer.window_get_size())
	if win.y > 0:
		var seg := DisplayServer.get_display_safe_area()
		var k := vs.y / win.y
		topo = seg.position.y * k
		base = maxf(0.0, (win.y - seg.end.y) * k)
	var livre := vs.y - topo - base
	position = Vector2(roundf((vs.x - W) / 2.0), roundf(topo + maxf(0.0, (livre - H) / 2.0)))


var col: Colecao
var mp: MenuPerfil
var visor: Visor
var mpr: MenuPrincipal
var bo: Booster
var ta: TorneioArcade
var _rolando := false                 # dedo encostado na Coleção (arrastando a grade)
var _rol_ini := Vector2.ZERO
var _rol_ult := Vector2.ZERO
var _rol_moveu := false
var logo_no: Node2D
var logo_tex: Texture2D


func _ready() -> void:
	if OS.get_environment("GD_NOME_TESTE") != "":
		Sessao.perfil["nome"] = OS.get_environment("GD_NOME_TESTE")
	col = Colecao.new(self)
	mp = MenuPerfil.new(self)
	mpr = MenuPrincipal.new(self)
	visor = Visor.new()
	visor.f = self
	add_child(visor)
	bo = Booster.new(self)
	ta = TorneioArcade.new(self)
	arcade["meu_deck"] = str(int(Sessao.perfil["deck_ativo"]))
	# logo KodeX desenhado num nó próprio com filtro linear (o resto da UI é pixel, filtro nearest)
	logo_tex = load("res://assets/logo.png") if ResourceLoader.exists("res://assets/logo.png") else null
	logo_no = Node2D.new()
	logo_no.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	logo_no.z_index = 5
	logo_no.draw.connect(_desenhar_logo)
	add_child(logo_no)
	_enquadrar()
	get_viewport().size_changed.connect(_enquadrar)
	# voltando de uma partida?
	if Sessao.resultado != "" and Sessao.modo == "torneio":
		_pos_luta_torneio()
	elif Sessao.resultado != "" and Sessao.modo == "arcade":
		_pos_luta_arcade()
	elif Sessao.resultado != "" and Sessao.modo == "arcade_t":
		ta.pos_partida()
	elif str(Sessao.perfil.get("nome", "")) == "":
		_ir("perfil")                                       # primeira vez: cria o perfil
	else:
		_ir("titulo")
	if OS.get_environment("GD_FLUXO_TELA") != "":            # teste: abre direto numa tela
		if OS.get_environment("GD_FLUXO_TELA") == "deck_edit":
			mp.abrir_deck(0)
		else:
			_ir(OS.get_environment("GD_FLUXO_TELA"))
	if OS.get_environment("GD_TA_TESTE") != "":               # teste: "VD" = vence as quartas e perde a semi, "VVV" = campeão
		Sessao.novo_torneio_arcade()
		_ir("chave")
		var seq := OS.get_environment("GD_TA_TESTE")
		for k in seq.length():
			var v := seq[k] == "V"
			get_tree().create_timer(0.8 + k * 5.5).timeout.connect(func() -> void:
				Sessao.resultado = "vitoria" if v else "derrota"
				ta.pos_partida())
	if OS.get_environment("GD_BOOSTER_AUTO") != "":           # teste: compra e abre um booster sozinho
		_ir("loja")
		get_tree().create_timer(0.6).timeout.connect(bo.comprar)
	if OS.get_environment("GD_TESTE_RECORTE") != "":          # teste: abre a foto, aproxima, arrasta e confirma
		_teste_recorte()
	if OS.get_environment("GD_FOIL_TESTE") != "":            # teste: dá uma foil ao perfil
		Sessao.perfil["colecao"][OS.get_environment("GD_FOIL_TESTE")] = 1
		Sessao.perfil["foils"][OS.get_environment("GD_FOIL_TESTE")] = 1
	if OS.get_environment("GD_TESTE_NOME") != "":             # teste: campo de nome com foco (cursor e contador)
		_ir("perfil")
		Sessao.perfil["nome"] = OS.get_environment("GD_TESTE_NOME")
		mp.nome_edit.text = Sessao.perfil["nome"]
		mp.nome_edit.grab_focus()
	if OS.get_environment("GD_TESTE_VISOR") != "":            # teste: abre, sobe a lore, volta, fecha puxando
		mp.abrir_deck(0)
		_teste_visor()
	if OS.get_environment("GD_COL_CARTA") != "":              # teste: abre a página de lore de uma carta
		col.abrir_aba(OS.get_environment("GD_COL_ABA") if OS.get_environment("GD_COL_ABA") != "" else "alta_magia")
		col.abrir_carta(OS.get_environment("GD_COL_CARTA"))
		_ir("lore")
	var auto := OS.get_environment("GD_FLUXO_AUTO")      # teste automático: toca sozinho
	if auto != "":
		_autoplay()


func _process(delta: float) -> void:
	tempo += delta
	if logo_no:
		logo_no.queue_redraw()
	t_estado += delta
	t_falante += delta
	transicao = maxf(0.0, transicao - delta * 3.0)
	# brasas subindo do fundo (até 40 vivas)
	if brasas.size() < 40 and randf() < delta * 14.0:
		brasas.append({"p": Vector2(randf_range(0, W), H + 10), "v": Vector2(randf_range(-6, 6), randf_range(-26, -12)),
			"vida": randf_range(4.0, 9.0), "t": 0.0, "fase": randf() * TAU})
	for b in brasas:
		b["t"] += delta
		b["p"] += (b["v"] as Vector2) * delta + Vector2(sin(tempo * 1.7 + b["fase"]) * 6.0 * delta, 0)
	brasas = brasas.filter(func(b: Dictionary) -> bool: return b["t"] < b["vida"])
	mp.atualizar(delta, _rolando)
	if estado == "booster":
		bo.atualizar(delta)
	if estado == "titulo":
		mpr.atualizar(delta)
	if estado == "chave":
		ta.atualizar(delta)
	if estado == "colecao":
		col.atualizar(delta, _rolando)
	elif estado == "lore":
		col.atualizar_lore(delta, _rolando)
	if not falas.is_empty():
		fala_vis = minf(fala_vis + delta * 45.0, (falas[0]["texto"] as String).length())
	queue_redraw()


# ================= estados =================
func _ir(novo: String) -> void:
	estado = novo
	t_estado = 0.0
	apertado = -1
	transicao = 1.0
	botoes.clear()
	mp.sair_texto()
	match novo:
		"titulo":
			_botao(Rect2(8, 4, 344, 36), "", func() -> void: _ir("perfil"), {"desenho": func(_b: Dictionary, _r: Rect2, _p: float) -> void: mp.barra_titulo()})
			_botao(Rect2(60, 444, 240, 34), "", mpr.jogar, {"desenho": func(b: Dictionary, r: Rect2, pr: float) -> void: mpr.botao_jogar(b, r, pr)})
			_botao(Rect2(44, 488, 272, 28), "", func() -> void: _ir("decks"), {"desenho": func(b: Dictionary, r: Rect2, pr: float) -> void: mpr.botao_deck(b, r, pr)})
			var abas := [["inicio", "Início", func() -> void: pass], ["colecao", "Coleção", func() -> void: col.abrir_aba(col.aba); _ir("colecao")],
				["decks", "Decks", func() -> void: _ir("decks")], ["loja", "Loja", func() -> void: _ir("loja")], ["opcoes", "Opções", func() -> void: _ir("opcoes")]]
			for k in abas.size():
				_botao(Rect2(k * 72, 590, 72, 46), abas[k][1], abas[k][2], {"aba_menu": abas[k][0], "desenho": func(b: Dictionary, r: Rect2, pr: float) -> void: mpr.aba(b, r, pr)})
		"opcoes":
			_botao(Rect2(110, 150, 140, 24), "Idioma", func() -> void: Sessao.trocar_idioma(); _ir("opcoes"), {"idioma": true})
			_botao(Rect2(110, 604, 140, 26), "Voltar", func() -> void: _ir("titulo"))
		"colecao":
			if col._ids.is_empty():
				col.abrir_aba(col.aba)
			for i in Colecao.ABAS.size():
				var d: String = Colecao.ABAS[i]
				_botao(Rect2(14 + i * 48, 48, 44, 22), "", func() -> void: col.abrir_aba(d); _ir("colecao"), {"aba": d})
			_botao(Rect2(110, 604, 140, 26), "Voltar", func() -> void: _ir("titulo"))
		"lore":
			_botao(Rect2(110, 604, 140, 26), "Voltar", func() -> void: _ir("colecao"))
		"perfil":
			mp.entrar_perfil()
			_botao(Rect2(110, 266, 140, 24), "Escolher foto", mp.escolher_foto)
			_botao(Rect2(90, 420, 180, 30), "Continuar", func() -> void:
				if str(Sessao.perfil.get("nome", "")).strip_edges() == "":
					mp.avisar(Sessao.t("Escreva seu nome."))
				else:
					_ir("titulo"))
		"recorte":
			_botao(Rect2(96, 440, 40, 26), "-", func() -> void: mp.zoom(1.0 / 1.15))
			_botao(Rect2(224, 440, 40, 26), "+", func() -> void: mp.zoom(1.15))
			_botao(Rect2(90, 484, 180, 30), "Confirmar", mp.confirmar_recorte)
			_botao(Rect2(110, 524, 140, 24), "Cancelar", func() -> void: _ir("perfil"))
		"loja":
			_botao(Rect2(90, 404, 180, 30), "Comprar booster", bo.comprar)
			if Sessao.boosters_gratis() > 0:
				_botao(Rect2(90, 512, 180, 30), Sessao.t("Abrir grátis (%d)") % Sessao.boosters_gratis(), bo.comprar.bind(true))
			_botao(Rect2(110, 600, 140, 26), "Voltar", func() -> void: _ir("titulo"))
		"booster":
			if bo.etapa == "fim":
				for k in 3:
					if not bo.cartas[k]["nova"]:
						_botao(Rect2(Booster.X_CARTAS[k] - 42, Booster.Y_CARTAS + Booster.CH / 2 + 24, 84, 22), "", bo.alternar_troca.bind(k),
							{"carta": k, "desenho": func(b: Dictionary, r: Rect2, pr: float) -> void: bo.botao_troca(b, r, pr)})
				_botao(Rect2(90, 536, 180, 30), "Concluir", bo.concluir)
				if Sessao.moedas() >= Sessao.BOOSTER_PRECO:
					_botao(Rect2(110, 574, 140, 26), "Abrir outro", func() -> void: bo.concluir(); bo.comprar())
		"decks":
			for i in Sessao.perfil["decks"].size():
				_botao(Rect2(30, 92 + i * 46, 300, 40), "", mp.abrir_deck.bind(i), {"deck_idx": i, "desenho": func(b: Dictionary, r: Rect2, pr: float) -> void: mp.botao_deck(b, r, pr)})
			_botao(Rect2(90, 470, 180, 30), "Novo deck", mp.novo_deck)
			_botao(Rect2(110, 604, 140, 26), "Voltar", func() -> void: _ir("titulo"))
		"deck_edit":
			_botao(Rect2(60, 4, 240, 28), "", mp.renomear_deck, {"desenho": func(_b: Dictionary, _r: Rect2, _p: float) -> void: pass})
			_botao(Rect2(70, 54, 104, 22), "Coleção", mp.trocar_aba.bind("cartas"), {"aba_deck": "cartas"})
			_botao(Rect2(186, 54, 104, 22), "No deck", mp.trocar_aba.bind("deck"), {"aba_deck": "deck"})
			if mp.aba_deck == "cartas":
				for i in 6:
					var d: String = Sessao.DECKS[i]
					_botao(Rect2(16 + i * 55, 82, 51, 20), "", mp.trocar_filtro.bind(d), {"filtro": d})
			_botao(Rect2(16, 570, 150, 26), "Usar este deck", mp.usar_deck)
			_botao(Rect2(172, 570, 80, 26), "Excluir", mp.excluir_deck)
			_botao(Rect2(258, 570, 86, 26), "Voltar", func() -> void: _ir("decks"))
		"escolha_deck":
			for i in 6:
				var d: String = Sessao.DECKS[i]
				var r := Rect2(16 + (i % 2) * 168, 88 + (i / 2) * 178, 160, 168)
				_botao(r, Sessao.nome_deck(d), func() -> void: _comecar_torneio(d), {"deck": d})
		"arcade":
			_botao(Rect2(20, 150, 320, 40), "", func() -> void: _ciclar("oponente"), {"campo": "oponente"})
			_botao(Rect2(20, 220, 320, 40), "", func() -> void: _ciclar("meu_deck"), {"campo": "meu_deck"})
			_botao(Rect2(20, 290, 320, 40), "", func() -> void: _ciclar("deck_dele"), {"campo": "deck_dele"})
			_botao(Rect2(90, 372, 180, 30), "Jogar", _comecar_arcade)
			_botao(Rect2(90, 412, 180, 30), "Continuar torneio" if Sessao.ta_ativo() else "Torneio de 8", _torneio_arcade)
			_botao(Rect2(90, 454, 180, 26), "Voltar", func() -> void: _ir("titulo"))
		"chave":
			var d := Sessao.ta()
			if ta.anim.is_empty() and not d.is_empty():
				if d["fim"] and ta._campeao(d):
					_botao(Rect2(90, 488, 180, 30), "Abrir booster", ta.abrir_premio)
					_botao(Rect2(110, 528, 140, 24), "Concluir", ta.concluir)
				elif d["fim"]:
					_botao(Rect2(100, 586, 160, 28), "Concluir", ta.concluir)
				elif d["eliminado"]:
					_botao(Rect2(100, 574, 160, 26), "Ver o resto", ta.ver_resto)
					_botao(Rect2(120, 606, 120, 22), "Sair", ta.concluir)
				else:
					_botao(Rect2(100, 556, 160, 30), "Lutar!", ta.lutar)
					_botao(Rect2(20, 600, 120, 24), "Voltar", func() -> void: _ir("arcade"))
					_botao(Rect2(220, 600, 120, 24), "Desistir", ta.concluir)
		"falas":
			pass


func _comecar_torneio(deck: String) -> void:
	Sessao.novo_torneio(deck)
	_pre_luta_torneio()


func _pre_luta_torneio() -> void:
	var op := Sessao.oponente
	var p := Sessao.personagem(op)
	var lista: Array = []
	lista.append({"quem": Sessao.t("Luta %d de 6") % (Sessao.torneio_idx + 1), "texto": Sessao.t("%s, %s, entra na arena com o deck de %s.") % [p.get("nome", op), p.get("titulo", ""), Sessao.nome_deck(op)], "cor": OURO[0], "retrato": ""})
	for t in p.get("intro", []):
		lista.append({"quem": p.get("nome", op), "texto": t, "cor": Color(p.get("cor", "#e2b85a")), "retrato": op})
	if p.has("resposta_jogador"):
		lista.append({"quem": Sessao.t("Você"), "texto": p["resposta_jogador"], "cor": CREME, "retrato": ""})
	_falar(lista, func() -> void: _jogar())


func _pos_luta_torneio() -> void:
	var op := Sessao.oponente
	var p := Sessao.personagem(op)
	var lista: Array = []
	var cor := Color(p.get("cor", "#e2b85a"))
	if Sessao.resultado == "vitoria":
		for t in p.get("ao_perder", []):
			lista.append({"quem": p.get("nome", op), "texto": t, "cor": cor, "retrato": op})
		Sessao.torneio_idx += 1
		Sessao.resultado = ""
		if Sessao.torneio_idx >= Sessao.torneio_ordem.size():
			for t in Sessao.lore.get("epilogo_vitoria", [Sessao.t("Você venceu o torneio.")]):
				lista.append({"quem": Sessao.t("Narrador"), "texto": t, "cor": OURO[0], "retrato": ""})
			_falar(lista, func() -> void: Sessao.modo = ""; _ir("titulo"))
		else:
			_falar(lista, func() -> void: Sessao.preparar_luta_torneio(); _pre_luta_torneio())
	else:
		for t in p.get("ao_vencer", []):
			lista.append({"quem": p.get("nome", op), "texto": t, "cor": cor, "retrato": op})
		for t in Sessao.lore.get("epilogo_derrota", [Sessao.t("O Códice escapa das suas mãos.")]):
			lista.append({"quem": Sessao.t("Narrador"), "texto": t, "cor": OURO[0], "retrato": ""})
		Sessao.resultado = ""
		_falar(lista, func() -> void: _ir("derrota"); _botoes_derrota())


func _botoes_derrota() -> void:
	botoes.clear()
	_botao(Rect2(90, 380, 180, 30), "Tentar de novo", func() -> void: Sessao.preparar_luta_torneio(); _jogar())
	_botao(Rect2(90, 422, 180, 30), "Menu", func() -> void: Sessao.modo = ""; _ir("titulo"))


func _comecar_arcade() -> void:
	if not Sessao.deck_valido(int(arcade["meu_deck"])):
		_ciclar("meu_deck")
	if not Sessao.deck_valido(int(arcade["meu_deck"])):
		return
	Sessao.preparar_arcade(arcade["meu_deck"], arcade["oponente"], arcade["deck_dele"])
	var op := Sessao.oponente
	var p := Sessao.personagem(op)
	var lista: Array = []
	for t in p.get("arcade_intro", p.get("intro", []).slice(0, 2)):
		lista.append({"quem": p.get("nome", op), "texto": t, "cor": Color(p.get("cor", "#e2b85a")), "retrato": op})
	_falar(lista, func() -> void: _jogar())


func _pos_luta_arcade() -> void:
	var op := Sessao.oponente
	var p := Sessao.personagem(op)
	var lista: Array = []
	var chave := "ao_perder" if Sessao.resultado == "vitoria" else "ao_vencer"
	for t in p.get(chave, []):
		lista.append({"quem": p.get("nome", op), "texto": t, "cor": Color(p.get("cor", "#e2b85a")), "retrato": op})
	lista.append({"quem": "Arcade", "texto": Sessao.t("Vitória!" if Sessao.resultado == "vitoria" else ("Derrota." if Sessao.resultado == "derrota" else "Empate.")), "cor": OURO[0], "retrato": ""})
	if Sessao.resultado == "vitoria":
		Sessao.ganhar_moedas(Sessao.MOEDAS_ARCADE)
		lista.append({"quem": "Arcade", "texto": Sessao.t("+%d moedas! Agora você tem %d.") % [Sessao.MOEDAS_ARCADE, Sessao.moedas()], "cor": OURO[0], "retrato": ""})
	Sessao.resultado = ""
	_falar(lista, func() -> void: _ir("arcade"))


func _ciclar(campo: String) -> void:
	if campo == "meu_deck":
		var validos: Array = []
		for i in Sessao.perfil["decks"].size():
			if Sessao.deck_valido(i):
				validos.append(str(i))
		if not validos.is_empty():
			arcade[campo] = validos[(validos.find(arcade[campo]) + 1) % validos.size()]
		return
	var lista: Array = OPC[campo]
	arcade[campo] = lista[(lista.find(arcade[campo]) + 1) % lista.size()]


func _jogar() -> void:
	vibrar(25, 0.6)
	var t := create_tween()
	t.tween_method(func(v: float) -> void: transicao = v, 0.0, 1.0, 0.35)
	await t.finished
	get_tree().change_scene_to_file("res://mesa.tscn")


# ================= falas =================
func _falar_lista(textos: Array, quem: String, cor: Color, retrato: String, depois: Callable) -> void:
	var lista: Array = []
	for t in textos:
		lista.append({"quem": quem, "texto": t, "cor": cor, "retrato": retrato})
	_falar(lista, depois)


func _falar(lista: Array, depois: Callable) -> void:
	if lista.is_empty():
		depois.call(); return
	estado = "falas"
	t_estado = 0.0
	botoes.clear()
	falas = lista.duplicate()
	ultimo_falante = ""
	fala_vis = 0.0
	depois_falas = depois


func _avancar_fala() -> void:
	var total := (falas[0]["texto"] as String).length()
	if fala_vis < total:
		fala_vis = total; return
	falas.pop_front()
	fala_vis = 0.0
	vibrar(8, 0.25)
	if falas.is_empty():
		depois_falas.call()


# ================= entrada =================
func _unhandled_input(ev: InputEvent) -> void:
	# no celular cada toque chega também como mouse emulado (device -1): sem isto o toque contava duas vezes
	if (ev is InputEventMouseButton or ev is InputEventMouseMotion) and ev.device == InputEvent.DEVICE_ID_EMULATION:
		return
	if visor.aberto():                                       # visor de carta por cima de tudo
		var pv: Vector2 = get_canvas_transform().affine_inverse() * (ev.position as Vector2) - position if "position" in ev else Vector2.ZERO
		if ev is InputEventScreenTouch or (ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT):
			if ev.pressed:
				visor.pressionar(pv)
			else:
				visor.soltar(pv)
		elif ev is InputEventScreenDrag or ev is InputEventMouseMotion:
			visor.mover(pv)
		return
	if estado == "titulo" and _entrada_leque(ev):
		return
	if estado == "recorte" and _entrada_recorte(ev):
		return
	if estado == "booster" and _entrada_booster(ev):
		return
	var botao_ev: bool = (ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT) or ev is InputEventScreenTouch
	if botao_ev:
		var p: Vector2 = get_canvas_transform().affine_inverse() * (ev.position as Vector2) - position
		if estado in ["colecao", "lore", "deck_edit"]:
			_toque_colecao(p, ev.pressed)
		if ev.pressed:
			apertar(p)
		else:
			soltar_toque(p)
	elif (ev is InputEventMouseMotion or ev is InputEventScreenDrag) and _rolando:
		var pr: Vector2 = get_canvas_transform().affine_inverse() * (ev.position as Vector2) - position
		var dy := pr.y - _rol_ult.y
		_rol_ult = pr
		if pr.distance_to(_rol_ini) > 6:
			_rol_moveu = true
			apertado = -1
		var v := -dy / maxf(get_process_delta_time(), 0.008)
		if estado == "colecao":
			col.rolagem = col.limitar(col.rolagem - dy)
			col.vel = v
		elif estado == "deck_edit":
			mp.rolagem = mp.limitar(mp.rolagem - dy)
			mp.vel = v
		else:
			col.rolagem_lore = col.limitar_lore(col.rolagem_lore - dy)
			col.vel = v
	elif (ev is InputEventMouseMotion or ev is InputEventScreenDrag) and apertado >= 0:
		var p2: Vector2 = get_canvas_transform().affine_inverse() * (ev.position as Vector2) - position
		if not (botoes[apertado]["rect"] as Rect2).grow(8).has_point(p2):
			apertado = -1                           # arrastou para fora: cancela sem disparar


## Dedo encostou: botão afunda 1 px, escurece e vibra 10 ms.
func apertar(p: Vector2) -> void:
	if transicao > 0.5:
		return
	if estado == "falas":
		_avancar_fala(); return
	for i in botoes.size():
		if (botoes[i]["rect"] as Rect2).has_point(p):
			apertado = i
			vibrar(10, 0.35)
			return


## Dedo saiu: se ainda estava em cima do mesmo botão, dispara (com 70 ms para o “afundar” aparecer).
var _soltando := {}                    # botão que acabou de ser solto (continua desenhado afundado por 70 ms)


func soltar_toque(p: Vector2) -> void:
	if apertado < 0 or apertado >= botoes.size():
		apertado = -1; return
	var b := botoes[apertado]
	apertado = -1                                # já consumido: um segundo "soltar" não dispara de novo
	if (b["rect"] as Rect2).grow(8).has_point(p):
		vibrar(18, 0.6)
		_soltando = b
		await get_tree().create_timer(0.07).timeout
		_soltando = {}
		(b["acao"] as Callable).call()
	else:
		apertado = -1


## Compatibilidade com o teste automático: toque completo (encostar + soltar).
func tocar(p: Vector2) -> void:
	apertar(p)
	await get_tree().create_timer(0.08).timeout
	soltar_toque(p)


func vibrar(ms: int, forca: float = 0.5) -> void:
	if OS.get_environment("GD_FLUXO_AUTO") != "":
		return
	Input.vibrate_handheld(ms, forca)


## Coleção: arrastar rola a grade/página (com inércia); toque curto numa carta abre a lore.
func _toque_colecao(p: Vector2, pressed: bool) -> void:
	if pressed:
		if estado == "deck_edit":
			_rolando = p.y > MenuPerfil.GTOPO and p.y < MenuPerfil.GBASE
		else:
			_rolando = p.y > Colecao.TOPO - 50 and p.y < Colecao.BASE
		_rol_ini = p
		_rol_ult = p
		_rol_moveu = false
		col.vel = 0.0
		return
	var era := _rolando
	_rolando = false
	if era and not _rol_moveu and estado == "deck_edit" and apertado < 0:
		mp.tocar_grade(p)
		return
	if era and not _rol_moveu and estado == "colecao" and apertado < 0:
		var cid := col.tocar(p)
		if cid != "":
			var k := col._ids.find(cid)
			visor.abrir(cid, col._rect_carta(k).intersection(Rect2(0, Colecao.TOPO, 360, Colecao.BASE - Colecao.TOPO)))


## Recorte da foto: 1 dedo arrasta, 2 dedos aproximam (pinça), roda do mouse dá zoom. Toques fora da janela vão
## para os botões (devolve false).
func _entrada_recorte(ev: InputEvent) -> bool:
	var inv := get_canvas_transform().affine_inverse()
	if ev is InputEventMouseButton and (ev.button_index == MOUSE_BUTTON_WHEEL_UP or ev.button_index == MOUSE_BUTTON_WHEEL_DOWN):
		if ev.pressed:
			mp.zoom(1.1 if ev.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0 / 1.1, inv * (ev.position as Vector2) - position)
		return true
	if ev is InputEventScreenTouch or (ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT):
		var p: Vector2 = inv * (ev.position as Vector2) - position
		var idx: int = ev.index if ev is InputEventScreenTouch else 0
		if ev.pressed:
			var em_botao := false
			for b in botoes:
				em_botao = em_botao or (b["rect"] as Rect2).grow(4).has_point(p)
			if em_botao or (not MenuPerfil.AREA_RECORTE.has_point(p) and mp.toques.is_empty()):
				return false                            # botão (Confirmar, −, +, Cancelar): segue para os botões
		elif not mp.toques.has(idx):
			return false                                # soltou um toque que não era do recorte (ex.: botão)
		mp.toque_recorte(idx, p, ev.pressed)
		return true
	if ev is InputEventScreenDrag or ev is InputEventMouseMotion:
		var p2: Vector2 = inv * (ev.position as Vector2) - position
		var idx2: int = ev.index if ev is InputEventScreenDrag else 0
		if mp.toques.has(idx2):
			mp.arrastar_recorte(idx2, p2)
			return true
	return false


func _teste_visor() -> void:
	await get_tree().create_timer(1.0).timeout
	mp.tocar_grade(mp._rect(7).get_center())
	var gesto := func(dy: float) -> void:
		visor.pressionar(Vector2(180, 300))
		for k in 12:
			visor.mover(Vector2(180, 300 + dy * k / 11.0))
			await get_tree().process_frame
		visor.soltar(Vector2(180, 300 + dy))
	await get_tree().create_timer(1.6).timeout
	await gesto.call(-120.0)
	await get_tree().create_timer(2.4).timeout
	await gesto.call(120.0)
	await get_tree().create_timer(1.4).timeout
	await gesto.call(150.0)
	await get_tree().create_timer(1.2).timeout
	visor.abrir(mp._ids[3], mp._rect(3))
	await get_tree().create_timer(1.2).timeout
	visor.pressionar(Vector2(340, 600))
	visor.soltar(Vector2(340, 600))
	await get_tree().create_timer(1.2).timeout
	get_tree().quit()


func _teste_recorte() -> void:
	await get_tree().create_timer(0.8).timeout
	mp.abrir_foto(OS.get_environment("GD_FOTO_TESTE"))
	await get_tree().create_timer(0.8).timeout
	mp.zoom(1.4)
	mp.toque_recorte(0, Vector2(180, 260), true)
	for k in 10:
		mp.arrastar_recorte(0, Vector2(180 + k * 3, 260 + k * 2))
		await get_tree().process_frame
	mp.toque_recorte(0, Vector2(210, 280), false)
	await get_tree().create_timer(1.0).timeout
	# toque real no botão Confirmar (pressiona e solta pelo caminho normal de entrada)
	var alvo := Vector2(-1, -1)
	for b in botoes:
		if b["texto"] == "Confirmar":
			alvo = (b["rect"] as Rect2).get_center()
	for pressed in [true, false]:
		var ev := InputEventScreenTouch.new()
		ev.position = get_canvas_transform() * (alvo + position)
		ev.pressed = pressed
		_unhandled_input(ev)
		await get_tree().create_timer(0.15).timeout
	print("RECORTE estado=", estado, " tem_foto=", Sessao.perfil.get("tem_foto", false))


## Booster: toques e arrastes vão para o corte/revelação, exceto quando caem num botão (repetidas, concluir).
func _entrada_booster(ev: InputEvent) -> bool:
	var inv := get_canvas_transform().affine_inverse()
	if ev is InputEventScreenTouch or (ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT):
		var p: Vector2 = inv * (ev.position as Vector2) - position
		if ev.pressed:
			for b in botoes:
				if (b["rect"] as Rect2).has_point(p):
					return false
		elif apertado >= 0:
			return false
		bo.toque(p, ev.pressed)
		return true
	if ev is InputEventScreenDrag or ev is InputEventMouseMotion:
		bo.mover(inv * (ev.position as Vector2) - position)
		return apertado < 0
	return false


## Leque de modos: arrastar na faixa das cartas rola; toque na carta do centro joga.
func _entrada_leque(ev: InputEvent) -> bool:
	var inv := get_canvas_transform().affine_inverse()
	if ev is InputEventScreenTouch or (ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT):
		var p: Vector2 = inv * (ev.position as Vector2) - position
		if ev.pressed:
			if transicao > 0.5 or not mpr.na_area(p):
				return false
			for b in botoes:
				if (b["rect"] as Rect2).has_point(p):
					return false
			mpr.pressionar(p)
			return true
		if mpr._segura:
			mpr.soltar(p)
			return true
		return false
	if (ev is InputEventScreenDrag or ev is InputEventMouseMotion) and mpr._segura:
		mpr.mover(inv * (ev.position as Vector2) - position)
		return true
	return false


## Torneio arcade de 8: começa um novo (precisa de deck completo) ou continua o salvo.
func _torneio_arcade() -> void:
	if not Sessao.ta_ativo():
		var ok := false
		for i in Sessao.perfil["decks"].size():
			ok = ok or Sessao.deck_valido(i)
		if not ok:
			mp.avisar(Sessao.t("Monte um deck com 32 cartas primeiro."))
			return
		Sessao.novo_torneio_arcade()
	ta.faixa_t = -1.0
	_ir("chave")


## Torneio da história: usa o deck em uso do jogador (precisa estar completo).
func _torneio() -> void:
	var ok := false
	for i in Sessao.perfil["decks"].size():
		ok = ok or Sessao.deck_valido(i)
	if not ok:
		mp.avisar(Sessao.t("Monte um deck com 32 cartas primeiro."))
		return
	_falar_lista(Sessao.lore.get("prologo", []), Sessao.t("Narrador"), OURO[0], "", func() -> void: _comecar_torneio(""))


func _comecar_tutorial() -> void:
	Sessao.preparar_tutorial()
	get_tree().change_scene_to_file("res://mesa.tscn")


func _botao(r: Rect2, texto: String, acao: Callable, extra := {}) -> void:
	var b := {"rect": r, "texto": texto, "acao": acao}
	b.merge(extra)
	botoes.append(b)


# ================= desenho =================
func _draw() -> void:
	_fundo()
	match estado:
		"titulo":
			_titulo()
		"opcoes":
			_opcoes()
		"escolha_deck":
			_cabecalho(Sessao.t("Escolha o seu deck"), Sessao.t("seis tradições, um Códice"))
		"arcade":
			_cabecalho("Arcade", Sessao.t("toque nas opções para trocar"))
		"colecao":
			PixelFonte.centrado(self, Vector2(180, 24), Sessao.t("Coleção").to_upper(), OURO[0], 3, ESCURO)
			col.desenhar_grade(self)
		"lore":
			col.desenhar_lore(self)
		"chave":
			ta.desenhar()
		"loja":
			bo.desenhar_loja()
		"booster":
			bo.desenhar_booster()
		"perfil":
			mp.desenhar_perfil()
		"recorte":
			mp.desenhar_recorte()
		"decks":
			mp.desenhar_decks()
		"deck_edit":
			mp.desenhar_deck_edit()
		"derrota":
			var e := _entrada(0)
			PixelFonte.centrado(self, Vector2(180, 290 - 20 * (1.0 - e)), Sessao.t("DERROTA"), Color(0.91, 0.42, 0.42, e), 4, ESCURO)
	for i in botoes.size():
		_desenhar_botao(botoes[i], i)
	if estado == "falas" and not falas.is_empty():
		_desenhar_fala(falas[0])
	if transicao > 0.0:
		draw_rect(Rect2(-position, get_viewport_rect().size), Color(0.03, 0.02, 0.05, transicao))


## Progresso 0..1 da entrada do elemento i (atraso 0,06 s por elemento, 0,32 s de duração, ease-out).
func _entrada(i: int) -> float:
	var u := clampf((t_estado - 0.06 * i) / 0.32, 0.0, 1.0)
	return 1.0 - pow(1.0 - u, 3.0)


func _fundo() -> void:
	var vs := get_viewport_rect().size
	var tela := Rect2(-position, vs)
	draw_rect(tela, Color("#0d0b12"))
	var c := Vector2(180, 300)
	# círculo de runas girando devagar (dois anéis em sentidos opostos)
	for i in range(1, 9):
		var a := 0.04 + 0.03 * sin(tempo * 1.3 + i)
		draw_arc(c, 40.0 * i, 0, TAU, 64, Color(OURO[1], a), 1.0)
	for k in 24:
		var ang := TAU * k / 24.0 + tempo * 0.06
		var q := c + Vector2.from_angle(ang) * 160.0
		draw_rect(Rect2(q.round() - Vector2(1, 1), Vector2(2, 2)), Color(OURO[0], 0.18))
		var ang2 := TAU * k / 24.0 - tempo * 0.04
		var q2 := c + Vector2.from_angle(ang2) * 240.0
		draw_rect(Rect2(q2.round(), Vector2(1, 1)), Color(OURO[1], 0.22))
	for k in 12:
		var ang := TAU * k / 12.0 + tempo * 0.05
		draw_line(c + Vector2.from_angle(ang) * 60, c + Vector2.from_angle(ang) * 420, Color(OURO[1], 0.035), 1.0)
	# luz de vela de cima (tremula com duas frequências)
	var l := 0.10 + 0.02 * sin(tempo * 7.0) + 0.015 * sin(tempo * 13.0)
	for i in 6:
		draw_circle(Vector2(180, -40), 120.0 + i * 50.0, Color(1.0, 0.75, 0.45, l / (i + 2)))
	# brasas
	for b in brasas:
		var al := clampf(minf(b["t"] / 0.8, (b["vida"] - b["t"]) / 1.5), 0.0, 1.0)
		var cor := Color(1.0, 0.7, 0.3, 0.55 * al) if int(b["fase"] * 10) % 3 else Color(1.0, 0.9, 0.6, 0.7 * al)
		draw_rect(Rect2((b["p"] as Vector2).round(), Vector2(1, 1)), cor)
	# vinheta nas bordas da tela
	for i in 10:
		draw_rect(tela.grow(-i * 3), Color(0, 0, 0, 0.05), false, 3.0)


func _cabecalho(titulo: String, sub: String) -> void:
	var e := _entrada(0)
	PixelFonte.centrado(self, Vector2(180, 44 - 14 * (1.0 - e)), titulo.to_upper(), Color(OURO[0], e), 3, ESCURO)
	_texto_central(Vector2(180, 70), sub, Color(0.72, 0.66, 0.53, e))
	# ornamento: linha dourada com losango no centro, crescendo do meio
	var w := 120.0 * e
	draw_line(Vector2(180 - w, 80), Vector2(180 + w, 80), Color(OURO[2], e), 1.0)
	draw_colored_polygon(PackedVector2Array([Vector2(180, 77), Vector2(183, 80), Vector2(180, 83), Vector2(177, 80)]), Color(OURO[0], e))


func _titulo() -> void:
	# barra inferior: fundo e filete
	draw_rect(Rect2(-400, 586, 1200, 200), Color(0.07, 0.05, 0.08, 0.96))
	draw_rect(Rect2(-400, 586, 1200, 1), Color(0.89, 0.72, 0.35, 0.5))
	draw_rect(Rect2(0, 588, 72, 2), OURO[0])                       # aba ativa: Início
	_texto_central(Vector2(180, 126), Sessao.t("o torneio do Códice"), Color(0.85, 0.78, 0.66, _entrada(4)))
	mpr.desenhar()
	mp._desenhar_aviso()


func _opcoes() -> void:
	_cabecalho(Sessao.t("Opções"), Sessao.t("idioma e informações"))
	Fonte57.desenhar(self, Vector2(110, 134), Sessao.t("Idioma"), Color("#b8a888"))
	var ver := "KodeX v" + str(ProjectSettings.get_setting("application/config/version", ""))
	_texto_central(Vector2(180, 560), ver, Color(0.89, 0.72, 0.35, 0.7))
	_texto_central(Vector2(180, 574), "Sapyst 2026", Color(0.6, 0.55, 0.6))


## Painel metálico (contorno, aro claro em cima/esquerda e escuro embaixo/direita, filete interno, fundo).
## `ouro` = botão principal. `pressao` 0..1 afunda 1 px e escurece.
func _painel(r: Rect2, ouro: bool, pressao: float, cor_fundo := Color("#241a20")) -> Rect2:
	r = Rect2(r.position + Vector2(0, roundf(pressao)), r.size)
	var aro: Array = [OURO[0], OURO[1], OURO[2]] if ouro else [Color("#c8c0b8"), Color("#8a8078"), Color("#4a4240")]
	draw_rect(Rect2(r.position + Vector2(2, 3 - pressao * 2), r.size), Color(0, 0, 0, 0.45))   # sombra
	draw_rect(r.grow(1), Color("#0c080a"))
	draw_rect(r, aro[1])
	draw_rect(Rect2(r.position, Vector2(r.size.x, 1)), aro[0])
	draw_rect(Rect2(r.position, Vector2(1, r.size.y)), aro[0])
	draw_rect(Rect2(r.position + Vector2(0, r.size.y - 1), Vector2(r.size.x, 1)), aro[2])
	draw_rect(Rect2(r.position + Vector2(r.size.x - 1, 0), Vector2(1, r.size.y)), aro[2])
	var dentro := r.grow(-2)
	draw_rect(dentro, Color("#0c080a"))
	draw_rect(dentro.grow(-1), cor_fundo.darkened(0.25 * pressao))
	draw_rect(Rect2(dentro.position + Vector2(1, 1), Vector2(dentro.size.x - 2, 1)), Color(1, 1, 1, 0.06))
	return dentro.grow(-1)


func _desenhar_botao(b: Dictionary, i: int) -> void:
	var e := _entrada(i + 1)
	if e <= 0.0:
		return
	var r: Rect2 = b["rect"]
	r.position.y += (1.0 - e) * 24.0
	var pressao := 1.0 if (i == apertado or (not _soltando.is_empty() and botoes[i] == _soltando)) else 0.0
	if b.has("deck"):
		var d: String = b["deck"]
		var cor: Color = Carta.COR_CULTURA.get(d, Color("#241a20"))
		var flutua := sin(tempo * 1.6 + i * 1.1) * 1.5 * (1.0 - pressao)
		r.position.y += flutua
		var dentro := _painel(r, true, pressao, cor.darkened(0.55))
		var tex := Carta.textura("arte", LEND_DO_DECK[d], "png")
		var arte := Rect2(dentro.position + Vector2((dentro.size.x - 96) / 2, 6), Vector2(96, 128))
		draw_rect(arte.grow(2), OURO[2])
		draw_rect(arte.grow(1), ESCURO)
		if tex:
			draw_texture_rect(tex, arte, false)
		# brilho diagonal passando pela arte a cada 3 s (atrasado por botão)
		var fase := fmod(tempo * 0.33 + i * 0.17, 1.0)
		if fase < 0.25:
			var x := arte.position.x + (fase / 0.25) * (arte.size.x + 40) - 20
			for k in 6:
				draw_line(Vector2(clampf(x + k, arte.position.x, arte.end.x), arte.position.y), Vector2(clampf(x + k - 20, arte.position.x, arte.end.x), arte.end.y), Color(1, 1, 1, 0.07), 1.0)
		_texto_central(Vector2(dentro.get_center().x, dentro.end.y - 10), b["texto"], OURO[0])
		return
	if b.has("campo"):
		var dentro := _painel(r, false, pressao)
		var campo: String = b["campo"]
		var rotulo: String = Sessao.t({"oponente": "Oponente", "meu_deck": "Seu deck", "deck_dele": "Deck do oponente"}[campo])
		Fonte57.desenhar(self, dentro.position + Vector2(8, 4), rotulo, Color("#b8a888"))
		var txt := _nome_opcao(campo, arcade[campo])
		Fonte57.desenhar(self, dentro.position + Vector2(8, 19), txt, OURO[0], ESCURO)
		# setinhas animadas indicando que dá para trocar
		var dx := 1.0 if fmod(tempo, 0.8) < 0.4 else 0.0
		Fonte57.desenhar(self, Vector2(dentro.end.x - 12 + dx, dentro.position.y + 19), ">", OURO[1])
		return
	if b.has("desenho"):
		(b["desenho"] as Callable).call(b, r, pressao)
		return
	if b.has("aba_deck") or b.has("filtro"):
		var ativa: bool = (b.has("aba_deck") and b["aba_deck"] == mp.aba_deck) or (b.has("filtro") and b["filtro"] == mp.filtro)
		var cor_f: Color = Carta.COR_CULTURA.get(b.get("filtro", ""), Color("#3d1f33"))
		var dd := _painel(r, ativa, pressao, cor_f.darkened(0.2 if ativa else 0.6))
		var rot: String = Sessao.t(b["texto"]) if b.has("aba_deck") else PixelFonte.normalizar(Sessao.nome_deck(b["filtro"])).substr(0, 3)
		if b.has("aba_deck"):
			_texto_central(dd.get_center() + Vector2(0, 1), rot, OURO[0] if ativa else Color("#b8b0c0"))
		else:
			PixelFonte.centrado(self, dd.get_center() + Vector2(0, 1), rot, OURO[0] if ativa else Color("#b8b0c0"), 1, ESCURO)
		return
	if b.has("aba"):
		var ativa: bool = b["aba"] == col.aba
		var cor_aba: Color = Color(Sessao.personagem(b["aba"]).get("cor", "#6a6070")) if b["aba"] != "abismo" else Color("#5a2a7a")
		var dch := _painel(r, ativa, pressao, cor_aba.darkened(0.25 if ativa else 0.65))
		var rotulo := PixelFonte.normalizar(Sessao.nome_deck(b["aba"]) if b["aba"] != "abismo" else Sessao.t("Abismo")).substr(0, 3)
		PixelFonte.centrado(self, dch.get_center() + Vector2(0, 1), rotulo, OURO[0] if ativa else Color("#b8b0c0"), 1, ESCURO)
		return
	if b.has("idioma"):
		var din := _painel(r, false, pressao)
		var pt := Sessao.idioma == "pt"
		Fonte57.desenhar(self, din.position + Vector2(10, 4), "PT-BR", OURO[0] if pt else Color("#6a6070"), ESCURO)
		Fonte57.desenhar(self, din.position + Vector2(din.size.x - 10 - Fonte57.largura("EN-US"), 4), "EN-US", OURO[0] if not pt else Color("#6a6070"), ESCURO)
		Fonte57.desenhar(self, din.position + Vector2(din.size.x / 2 - 2, 4), "|", Color("#6a6070"))
		return
	var principal: bool = b["texto"] in ["Torneio", "Jogar", "Tentar de novo"]
	var dentro := _painel(r, principal, pressao, Color("#3a2410") if principal else Color("#241a20"))
	_texto_central(dentro.get_center() + Vector2(0, 1), Sessao.t(b["texto"]), OURO[0] if principal else CREME)


func _nome_opcao(campo: String, v: String) -> String:
	if campo == "meu_deck":
		var i := int(v)
		if i >= 0 and i < Sessao.perfil["decks"].size():
			return str(Sessao.perfil["decks"][i]["nome"])
		return "-"
	if v == "aleatorio":
		return Sessao.t("Aleatório")
	if v == "misto":
		return Sessao.t("Misto (todas as tradições)")
	if v == "do_personagem":
		return Sessao.t("O dele (temático)")
	if v == "tematico_aleatorio":
		return Sessao.t("Temático aleatório")
	if campo == "oponente":
		var p := Sessao.personagem(v)
		return "%s (%s)" % [p.get("nome", v), Sessao.nome_deck(v)]
	return Sessao.nome_deck(v)


func _desenhar_fala(f: Dictionary) -> void:
	var cor: Color = f["cor"]
	var retrato: String = f["retrato"]
	if f["quem"] != ultimo_falante:
		ultimo_falante = f["quem"]
		t_falante = 0.0
	if retrato != "":
		# personagem recortado, em pé sobre a caixa; entra deslizando 40 px e respira
		var tex := Carta.textura("retrato", retrato, "png")
		if tex:
			var e := 1.0 - pow(1.0 - clampf(t_falante / 0.3, 0, 1), 3.0)
			var h := 300.0
			var w := h * tex.get_width() / tex.get_height()
			var resp := sin(tempo * 1.8) * 1.5
			var pos := Vector2(180 - w / 2.0 + (1.0 - e) * 40.0, 506 - h + resp)
			draw_texture_rect(tex, Rect2(pos + Vector2(6, 4), Vector2(w, h)), false, Color(0, 0, 0, 0.35 * e))
			draw_texture_rect(tex, Rect2(pos, Vector2(w, h)), false, Color(1, 1, 1, e))
	var caixa := Rect2(10, 508, 340, 116)
	var dentro := _painel(caixa, true, 0.0, Color("#1c141a"))
	draw_rect(Rect2(dentro.position, Vector2(dentro.size.x, 1)), cor)
	# placa do nome
	var nome: String = f["quem"]
	var wn := Fonte57.largura(nome) + 14
	var placa := Rect2(caixa.position + Vector2(12, -10), Vector2(wn, 14))
	_painel(placa, false, 0.0, cor.darkened(0.45))
	Fonte57.desenhar(self, placa.position + Vector2(7, 4), nome, Color.WHITE, ESCURO)
	var texto: String = (f["texto"] as String).substr(0, int(fala_vis))
	var y := dentro.position.y + 10
	for ln in Fonte57.quebrar(texto, int(dentro.size.x) - 20):
		Fonte57.desenhar(self, Vector2(dentro.position.x + 10, y), ln, CREME, ESCURO)
		y += 11
	if fala_vis >= (f["texto"] as String).length():
		var dy: int = [0, 0, 1, 2, 2, 1][int(tempo * 9.0) % 6]
		var q := dentro.end + Vector2(-14, -10 + dy)
		draw_colored_polygon(PackedVector2Array([q, q + Vector2(7, 0), q + Vector2(3.5, 5)]), cor)


func _texto_central(c: Vector2, s: String, cor: Color, esc: int = 1) -> void:
	if esc == 1:
		Fonte57.desenhar(self, (c - Vector2(Fonte57.largura(s), 7) / 2).round(), s, cor, ESCURO)
	else:
		PixelFonte.centrado(self, c, s, cor, esc, ESCURO)


# ================= teste automático (GD_FLUXO_AUTO=torneio|arcade) =================
func _btn(textos: Array) -> Vector2:
	for bt in botoes:
		if bt["texto"] in textos:
			return (bt["rect"] as Rect2).get_center()
	return Vector2(-1, -1)


func _autoplay() -> void:
	var alvo := OS.get_environment("GD_FLUXO_AUTO")
	await get_tree().create_timer(1.2).timeout
	if estado == "titulo":
		if alvo == "torneio":
			_torneio()
		else:
			_ir("arcade")
	while is_inside_tree():
		await get_tree().create_timer(0.35).timeout
		if not is_inside_tree():
			return
		if estado == "falas":
			tocar(Vector2(180, 560))
		elif estado == "escolha_deck":
			await get_tree().create_timer(1.0).timeout
			tocar(botoes[3]["rect"].get_center())
		elif estado == "arcade":
			await get_tree().create_timer(1.0).timeout
			if alvo == "torneio8":
				if Sessao.has_meta("ta_feito"):
					get_tree().quit()
					return
				tocar(_btn(["Torneio de 8", "Continuar torneio"]))
			else:
				tocar(_btn(["Jogar"]))
		elif estado == "chave" and ta.anim.is_empty():
			await get_tree().create_timer(1.2).timeout
			var p := _btn(["Lutar!", "Ver o resto", "Concluir"])
			if p.x >= 0:
				if _btn(["Concluir"]) == p:
					Sessao.set_meta("ta_feito", true)
				tocar(p)


## Logo: entra crescendo (0,45 s, ease-out-back) e depois “respira” ±1,5% ; o X pulsa levemente.
func _desenhar_logo() -> void:
	if estado != "titulo" or logo_tex == null:
		return
	var u := clampf(t_estado / 0.45, 0, 1)
	var c1 := 1.70158
	var e := 1.0 + (c1 + 1.0) * pow(u - 1.0, 3) + c1 * pow(u - 1.0, 2)
	var esc := e * (1.0 + 0.015 * sin(tempo * 1.6))
	var w := 220.0 * esc
	var h := w * logo_tex.get_height() / logo_tex.get_width()
	logo_no.draw_texture_rect(logo_tex, Rect2(Vector2(180 - w / 2.0, 80 - h / 2.0), Vector2(w, h)), false, Color(1, 1, 1, u))
