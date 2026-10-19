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


func _ready() -> void:
	# voltando de uma partida?
	if Sessao.resultado != "" and Sessao.modo == "torneio":
		_pos_luta_torneio()
	elif Sessao.resultado != "" and Sessao.modo == "arcade":
		_pos_luta_arcade()
	else:
		_ir("titulo")
	var auto := OS.get_environment("GD_FLUXO_AUTO")      # teste automático: toca sozinho
	if auto != "":
		_autoplay()


func _process(delta: float) -> void:
	tempo += delta
	if not falas.is_empty():
		fala_vis = minf(fala_vis + delta * 45.0, (falas[0]["texto"] as String).length())
	queue_redraw()


# ================= estados =================
func _ir(novo: String) -> void:
	estado = novo
	botoes.clear()
	match novo:
		"titulo":
			_botao(Rect2(90, 400, 180, 30), "Torneio", func() -> void: _falar_lista(Sessao.lore.get("prologo", []), "Narrador", OURO[0], "", func() -> void: _ir("escolha_deck")))
			_botao(Rect2(90, 442, 180, 30), "Arcade", func() -> void: _ir("arcade"))
		"escolha_deck":
			for i in 6:
				var d: String = Sessao.DECKS[i]
				var r := Rect2(20 + (i % 2) * 168, 96 + (i / 2) * 170, 152, 158)
				_botao(r, Sessao.NOME_DECK[d], func() -> void: _comecar_torneio(d), {"deck": d})
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
	lista.append({"quem": "Luta %d de 6" % (Sessao.torneio_idx + 1), "texto": "%s, %s, entra na arena com o deck de %s." % [p.get("nome", op), p.get("titulo", ""), Sessao.NOME_DECK[op]], "cor": OURO[0], "retrato": ""})
	for t in p.get("intro", []):
		lista.append({"quem": p.get("nome", op), "texto": t, "cor": Color(p.get("cor", "#e2b85a")), "retrato": op})
	if p.has("resposta_jogador"):
		lista.append({"quem": "Você", "texto": p["resposta_jogador"], "cor": CREME, "retrato": ""})
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
			for t in Sessao.lore.get("epilogo_vitoria", ["Você venceu o torneio."]):
				lista.append({"quem": "Narrador", "texto": t, "cor": OURO[0], "retrato": ""})
			_falar(lista, func() -> void: Sessao.modo = ""; _ir("titulo"))
		else:
			_falar(lista, func() -> void: Sessao.preparar_luta_torneio(); _pre_luta_torneio())
	else:
		for t in p.get("ao_vencer", []):
			lista.append({"quem": p.get("nome", op), "texto": t, "cor": cor, "retrato": op})
		for t in Sessao.lore.get("epilogo_derrota", ["O Códice escapa das suas mãos."]):
			lista.append({"quem": "Narrador", "texto": t, "cor": OURO[0], "retrato": ""})
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
	lista.append({"quem": "Arcade", "texto": "Vitória!" if Sessao.resultado == "vitoria" else ("Derrota." if Sessao.resultado == "derrota" else "Empate."), "cor": OURO[0], "retrato": ""})
	Sessao.resultado = ""
	_falar(lista, func() -> void: _ir("arcade"))


func _ciclar(campo: String) -> void:
	var lista: Array = OPC[campo]
	arcade[campo] = lista[(lista.find(arcade[campo]) + 1) % lista.size()]


func _jogar() -> void:
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
	botoes.clear()
	falas = lista.duplicate()
	fala_vis = 0.0
	depois_falas = depois


func _avancar_fala() -> void:
	var total := (falas[0]["texto"] as String).length()
	if fala_vis < total:
		fala_vis = total; return
	falas.pop_front()
	fala_vis = 0.0
	if falas.is_empty():
		depois_falas.call()


# ================= entrada =================
func _unhandled_input(ev: InputEvent) -> void:
	var toque: bool = (ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT) or (ev is InputEventScreenTouch and ev.pressed)
	if not toque:
		return
	var p: Vector2 = get_canvas_transform().affine_inverse() * (ev.position as Vector2)
	tocar(p)


func tocar(p: Vector2) -> void:
	if estado == "falas":
		_avancar_fala(); return
	for b in botoes:
		if (b["rect"] as Rect2).has_point(p):
			(b["acao"] as Callable).call(); return


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
			_texto_central(Vector2(180, 52), "Escolha o seu deck", OURO[0])
			_texto_central(Vector2(180, 66), "seis tradições, um Códice", Color("#b8a888"))
		"arcade":
			_texto_central(Vector2(180, 90), "Arcade", OURO[0], 3)
			_texto_central(Vector2(180, 118), "toque nas opções para trocar", Color("#b8a888"))
		"derrota":
			_texto_central(Vector2(180, 300), "Derrota", Color("#e86a6a"), 3)
	for b in botoes:
		_desenhar_botao(b)
	if estado == "falas" and not falas.is_empty():
		_desenhar_fala(falas[0])


func _fundo() -> void:
	draw_rect(Rect2(0, 0, W, H), Color("#0d0b12"))
	var c := Vector2(180, 300)
	for i in range(1, 9):
		var a := 0.05 + 0.03 * sin(tempo * 1.3 + i)
		draw_arc(c, 40.0 * i, 0, TAU, 64, Color(OURO[1], a), 1.0)
	for k in 12:
		var ang := TAU * k / 12.0 + tempo * 0.05
		draw_line(c + Vector2.from_angle(ang) * 60, c + Vector2.from_angle(ang) * 340, Color(OURO[1], 0.04), 1.0)
	# luz de vela de cima (tremula)
	var l := 0.10 + 0.02 * sin(tempo * 7.0) + 0.015 * sin(tempo * 13.0)
	for i in 6:
		draw_circle(Vector2(180, -40), 120.0 + i * 50.0, Color(1.0, 0.75, 0.45, l / (i + 2)))


func _titulo() -> void:
	# cartas-lendárias em leque atrás do título
	var ids := ["ind_tupa", "cri_sao_miguel_arcanjo", "hin_shiva_nataraja", "bru_hecate", "tao_imperador_de_jade"]
	for i in ids.size():
		var tex := Carta.textura("arte", ids[i], "png")
		if tex:
			var ang := deg_to_rad((i - 2) * 9.0)
			var pos := Vector2(180 + (i - 2) * 46, 250 + absf(i - 2) * 8)
			draw_set_transform(pos, ang, Vector2(1.6, 1.6))
			draw_rect(Rect2(-25, -33, 50, 66), ESCURO)
			draw_texture_rect(tex, Rect2(-24, -32, 48, 64), false)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	PixelFonte.centrado(self, Vector2(180, 110), "GODS KODEX", OURO[0], 6, ESCURO)
	_texto_central(Vector2(180, 146), "o torneio do Códice", Color("#d8c8a8"))


func _desenhar_botao(b: Dictionary) -> void:
	var r: Rect2 = b["rect"]
	draw_rect(r.grow(1), Color("#100c0e"))
	draw_rect(r, Color("#241a20"))
	draw_rect(Rect2(r.position, Vector2(r.size.x, 1)), Color("#b0a8a0"))
	draw_rect(Rect2(r.position + Vector2(0, r.size.y - 1), Vector2(r.size.x, 1)), Color("#5a5050"))
	if b.has("deck"):
		var d: String = b["deck"]
		var tex := Carta.textura("arte", LEND_DO_DECK[d], "png")
		if tex:
			draw_texture_rect(tex, Rect2(r.position + Vector2((r.size.x - 96) / 2, 8), Vector2(96, 128)), false)
		_texto_central(Vector2(r.get_center().x, r.end.y - 12), b["texto"], OURO[0])
		return
	if b.has("campo"):
		var campo: String = b["campo"]
		var rotulo: String = {"oponente": "Oponente", "meu_deck": "Seu deck", "deck_dele": "Deck do oponente"}[campo]
		Fonte57.desenhar(self, r.position + Vector2(10, 6), rotulo, Color("#b8a888"))
		var v: String = arcade[campo]
		var txt := _nome_opcao(campo, v)
		Fonte57.desenhar(self, r.position + Vector2(10, 22), "‹  " + txt + "  ›", OURO[0], ESCURO)
		return
	_texto_central(r.get_center() + Vector2(0, 1), b["texto"], OURO[0])


func _nome_opcao(campo: String, v: String) -> String:
	if v == "aleatorio":
		return "Aleatório"
	if v == "misto":
		return "Misto (todas as tradições)"
	if v == "do_personagem":
		return "O dele (temático)"
	if v == "tematico_aleatorio":
		return "Temático aleatório"
	if campo == "oponente":
		var p := Sessao.personagem(v)
		return "%s (%s)" % [p.get("nome", v), Sessao.NOME_DECK[v]]
	return Sessao.NOME_DECK.get(v, v)


func _desenhar_fala(f: Dictionary) -> void:
	var cor: Color = f["cor"]
	var retrato: String = f["retrato"]
	if retrato != "":
		# personagem recortado, em pé sobre a caixa de fala (até 300 px de altura), com sombra no chão e leve respiração
		var tex := Carta.textura("retrato", retrato, "png")
		if tex:
			var h := 300.0
			var w := h * tex.get_width() / tex.get_height()
			var resp := sin(tempo * 1.8) * 1.5
			var pos := Vector2(180 - w / 2.0, 510 - h + resp)
			draw_texture_rect(tex, Rect2(pos + Vector2(6, 4), Vector2(w, h)), false, Color(0, 0, 0, 0.35))
			draw_texture_rect(tex, Rect2(pos, Vector2(w, h)), false)
	var caixa := Rect2(12, 510, 336, 112)
	draw_rect(caixa.grow(2), ESCURO)
	draw_rect(caixa, Color("#1c141a"))
	draw_rect(Rect2(caixa.position, Vector2(caixa.size.x, 1)), cor)
	draw_rect(Rect2(caixa.position + Vector2(0, caixa.size.y - 1), Vector2(caixa.size.x, 1)), cor.darkened(0.5))
	# placa do nome
	var nome: String = f["quem"]
	var wn := Fonte57.largura(nome) + 14
	draw_rect(Rect2(caixa.position + Vector2(10, -9), Vector2(wn, 13)).grow(1), ESCURO)
	draw_rect(Rect2(caixa.position + Vector2(10, -9), Vector2(wn, 13)), cor.darkened(0.45))
	Fonte57.desenhar(self, caixa.position + Vector2(17, -6), nome, Color.WHITE, ESCURO)
	var texto: String = (f["texto"] as String).substr(0, int(fala_vis))
	var y := caixa.position.y + 12
	for ln in Fonte57.quebrar(texto, int(caixa.size.x) - 24):
		Fonte57.desenhar(self, Vector2(caixa.position.x + 12, y), ln, CREME, ESCURO)
		y += 11
	if fala_vis >= (f["texto"] as String).length():
		var dy := 2.0 if fmod(tempo, 0.6) < 0.3 else 0.0
		draw_rect(Rect2(caixa.end + Vector2(-16, -12 + dy), Vector2(5, 3)), cor)


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
