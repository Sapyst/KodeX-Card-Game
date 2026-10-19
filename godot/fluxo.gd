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
var arcade := {"oponente": "aleatorio", "meu_deck": "indigena", "deck_dele": "do_personagem"}
const OPC := {
	"oponente": ["aleatorio", "indigena", "cristianismo", "taoismo", "hinduismo", "bruxaria", "alta_magia"],
	"meu_deck": ["indigena", "cristianismo", "taoismo", "hinduismo", "bruxaria", "alta_magia", "misto", "aleatorio"],
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


var logo_no: Node2D
var logo_tex: Texture2D


func _ready() -> void:
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
	else:
		_ir("titulo")
	if OS.get_environment("GD_FLUXO_TELA") != "":            # teste: abre direto numa tela
		_ir(OS.get_environment("GD_FLUXO_TELA"))
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
	match novo:
		"titulo":
			_botao(Rect2(90, 388, 180, 30), "Torneio", func() -> void: _falar_lista(Sessao.lore.get("prologo", []), Sessao.t("Narrador"), OURO[0], "", func() -> void: _ir("escolha_deck")))
			_botao(Rect2(90, 426, 180, 30), "Arcade", func() -> void: _ir("arcade"))
			_botao(Rect2(90, 464, 180, 30), "Tutorial", _comecar_tutorial)
			_botao(Rect2(120, 512, 120, 24), "Idioma", func() -> void: Sessao.trocar_idioma(); _ir("titulo"), {"idioma": true})
		"escolha_deck":
			for i in 6:
				var d: String = Sessao.DECKS[i]
				var r := Rect2(16 + (i % 2) * 168, 88 + (i / 2) * 178, 160, 168)
				_botao(r, Sessao.nome_deck(d), func() -> void: _comecar_torneio(d), {"deck": d})
		"arcade":
			_botao(Rect2(20, 150, 320, 40), "", func() -> void: _ciclar("oponente"), {"campo": "oponente"})
			_botao(Rect2(20, 220, 320, 40), "", func() -> void: _ciclar("meu_deck"), {"campo": "meu_deck"})
			_botao(Rect2(20, 290, 320, 40), "", func() -> void: _ciclar("deck_dele"), {"campo": "deck_dele"})
			_botao(Rect2(90, 380, 180, 32), "Jogar", _comecar_arcade)
			_botao(Rect2(90, 424, 180, 26), "Voltar", func() -> void: _ir("titulo"))
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
	Sessao.resultado = ""
	_falar(lista, func() -> void: _ir("arcade"))


func _ciclar(campo: String) -> void:
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
	var botao_ev: bool = (ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT) or ev is InputEventScreenTouch
	if botao_ev:
		var p: Vector2 = get_canvas_transform().affine_inverse() * (ev.position as Vector2) - position
		if ev.pressed:
			apertar(p)
		else:
			soltar_toque(p)
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
		"escolha_deck":
			_cabecalho(Sessao.t("Escolha o seu deck"), Sessao.t("seis tradições, um Códice"))
		"arcade":
			_cabecalho("Arcade", Sessao.t("toque nas opções para trocar"))
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
	# versão no canto inferior direito (vem de application/config/version)
	var ver := "v" + str(ProjectSettings.get_setting("application/config/version", ""))
	PixelFonte.desenhar(self, Vector2(354 - PixelFonte.largura(ver.to_upper()), 628), ver.to_upper(), Color(0.89, 0.72, 0.35, 0.6))
	# cartas lendárias em leque, abrindo e respirando
	var ids := ["ind_tupa", "cri_sao_miguel_arcanjo", "hin_shiva_nataraja", "bru_hecate", "tao_imperador_de_jade"]
	var e := _entrada(2)
	for i in ids.size():
		var tex := Carta.textura("arte", ids[i], "png")
		if tex:
			var ang := deg_to_rad((i - 2) * 9.0 * e)
			var resp := sin(tempo * 1.4 + i * 0.9) * 2.0
			var pos := Vector2(180 + (i - 2) * 46 * e, 262 + absf(i - 2) * 8 * e + resp + (1.0 - e) * 40)
			draw_set_transform(pos, ang, Vector2(1.6, 1.6))
			draw_rect(Rect2(-27, -35, 54, 70), ESCURO)
			draw_rect(Rect2(-26, -34, 52, 68), OURO[2])
			draw_rect(Rect2(-25, -33, 50, 66), ESCURO)
			draw_texture_rect(tex, Rect2(-24, -32, 48, 64), false, Color(1, 1, 1, e))
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	_texto_central(Vector2(180, 182), Sessao.t("o torneio do Códice"), Color(0.85, 0.78, 0.66, _entrada(4)))


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
func _autoplay() -> void:
	var alvo := OS.get_environment("GD_FLUXO_AUTO")
	await get_tree().create_timer(1.2).timeout
	if estado == "titulo":
		tocar(botoes[0]["rect"].get_center() if alvo == "torneio" else botoes[1]["rect"].get_center())
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
			tocar(botoes[0]["rect"].get_center())
			await get_tree().create_timer(0.6).timeout
			tocar(botoes[3]["rect"].get_center())


## Logo: entra crescendo (0,45 s, ease-out-back) e depois “respira” ±1,5% ; o X pulsa levemente.
func _desenhar_logo() -> void:
	if estado != "titulo" or logo_tex == null:
		return
	var u := clampf(t_estado / 0.45, 0, 1)
	var c1 := 1.70158
	var e := 1.0 + (c1 + 1.0) * pow(u - 1.0, 3) + c1 * pow(u - 1.0, 2)
	var esc := e * (1.0 + 0.015 * sin(tempo * 1.6))
	var w := 300.0 * esc
	var h := w * logo_tex.get_height() / logo_tex.get_width()
	logo_no.draw_texture_rect(logo_tex, Rect2(Vector2(180 - w / 2.0, 108 - h / 2.0), Vector2(w, h)), false, Color(1, 1, 1, u))
