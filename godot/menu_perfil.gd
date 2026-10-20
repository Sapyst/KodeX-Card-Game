class_name MenuPerfil
extends RefCounted
## Telas da Fase 1 dentro do menu (fluxo.gd): barra de perfil no título, perfil (nome + foto), recorte 3:4 da foto,
## lista de decks e editor de deck. Desenha no próprio menu (chamado dentro de fluxo._draw). px nativos 360×640.

const MOLDURA := Rect2(60, 104, 240, 320)          # janela de recorte 3:4
const MINI := Rect2(14, 8, 21, 28)                # foto na barra de perfil do título
const GW := 60.0                                  # grade do editor de deck: carta 60×84, 5 colunas
const GH := 84.0
const GPASSO := 96.0
const GTOPO := 110.0
const GBASE := 560.0

var f                                             # o menu
var nome_edit: LineEdit
var foto_tex: Texture2D = null
var seletor: FileDialog
# recorte
var img: Image = null
var img_tex: Texture2D = null
var esc := 1.0
var pos := Vector2.ZERO
var toques := {}                                  # índice do dedo → posição (pinça)
var _dist_ini := 0.0
var _esc_ini := 1.0
# decks
var deck_idx := 0
var aba_deck := "cartas"                          # "cartas" (coleção: toque adiciona) | "deck" (toque remove)
var filtro := "alta_magia"
var rolagem := 0.0
var vel := 0.0
var _ids: Array = []
var editando := "perfil"                          # o que o campo de texto invisível está editando: "perfil" | "deck"
var aviso := ""
var aviso_t := 0.0


func _init(menu) -> void:
	f = menu
	nome_edit = LineEdit.new()
	nome_edit.max_length = 16
	nome_edit.modulate = Color(1, 1, 1, 0)        # invisível: o texto é desenhado com a fonte pixel do jogo
	nome_edit.visible = false
	nome_edit.text_changed.connect(func(t: String) -> void:
		if editando == "deck":
			Sessao.perfil["decks"][deck_idx]["nome"] = t
		else:
			Sessao.perfil["nome"] = t
		Sessao.salvar())
	nome_edit.text_submitted.connect(func(_t: String) -> void: nome_edit.release_focus())
	f.add_child(nome_edit)
	seletor = FileDialog.new()
	seletor.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	seletor.access = FileDialog.ACCESS_FILESYSTEM
	seletor.use_native_dialog = true
	seletor.filters = PackedStringArray(["*.png, *.jpg, *.jpeg, *.webp ; Imagens"])
	seletor.file_selected.connect(abrir_foto)
	f.add_child(seletor)
	_carregar_foto()


func _carregar_foto() -> void:
	foto_tex = null
	if Sessao.perfil.get("tem_foto", false) and FileAccess.file_exists(Sessao.FOTO):
		var im := Image.load_from_file(Sessao.FOTO)
		if im:
			foto_tex = ImageTexture.create_from_image(im)


func avisar(s: String) -> void:
	aviso = s
	aviso_t = 2.2


func atualizar(delta: float, segurando: bool) -> void:
	aviso_t = maxf(0.0, aviso_t - delta)
	if f.estado == "deck_edit" and not segurando:
		if absf(vel) > 1.0:
			rolagem = limitar(rolagem + vel * delta)
			vel *= pow(0.04, delta)
		else:
			vel = 0.0


# ---------------- desenho comum ----------------
## Moldura dourada da foto: aro de 3 px, cantos com losangos e um brilho percorrendo a borda.
func moldura_foto(r: Rect2, tex: Texture2D, grande := true) -> void:
	f.draw_rect(r.grow(4 if grande else 2), f.ESCURO)
	f.draw_rect(r.grow(3 if grande else 1), f.OURO[2])
	f.draw_rect(r.grow(2 if grande else 1), f.OURO[1], false, 1.0)
	f.draw_rect(r, Color("#1a1218"))
	if tex:
		f.draw_texture_rect(tex, r, false)
	else:
		# silhueta: cabeça e ombros
		var c := r.get_center()
		var k := r.size.x / 240.0
		f.draw_circle(c + Vector2(0, -34 * k), 38 * k, Color("#3a2c36"))
		f.draw_colored_polygon(PackedVector2Array([c + Vector2(-80, 120) * k, c + Vector2(-62, 30) * k, c + Vector2(0, 14) * k,
			c + Vector2(62, 30) * k, c + Vector2(80, 120) * k]), Color("#3a2c36"))
	if grande:
		for cc in [r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]:
			f.draw_colored_polygon(PackedVector2Array([cc + Vector2(0, -6), cc + Vector2(6, 0), cc + Vector2(0, 6), cc + Vector2(-6, 0)]), f.OURO[0])
			f.draw_colored_polygon(PackedVector2Array([cc + Vector2(0, -3), cc + Vector2(3, 0), cc + Vector2(0, 3), cc + Vector2(-3, 0)]), f.ESCURO)


func moeda(c: Vector2) -> void:
	f.draw_circle(c, 5.0, Color("#7a5418"))
	f.draw_circle(c, 4.0, Color("#e2b85a"))
	f.draw_circle(c + Vector2(-1, -1), 2.0, Color("#ffe39a"))
	f.draw_rect(Rect2(c + Vector2(-0.5, -2), Vector2(1, 4)), Color("#9c7430"))


## Barra no topo do título: foto, nome e moedas. Tocar abre o perfil.
func barra_titulo() -> void:
	moldura_foto(MINI, foto_tex, false)
	var nome := str(Sessao.perfil.get("nome", ""))
	Fonte57.desenhar(f, Vector2(42, 12), nome if nome != "" else Sessao.t("Jogador"), f.OURO[0], f.ESCURO)
	Fonte57.desenhar(f, Vector2(42, 24), Sessao.t("ver perfil"), Color(0.72, 0.66, 0.53, 0.8), f.ESCURO)
	var m := str(Sessao.moedas())
	var w := Fonte57.largura(m)
	moeda(Vector2(338 - w - 10, 18))
	Fonte57.desenhar(f, Vector2(340 - w, 15), m, f.OURO[0], f.ESCURO)


## Texto 2× centrado + cursor de digitação: barra vertical "|" de 2×16 px piscando (0,5 s aceso / 0,5 s apagado)
## logo depois da última letra; o cursor não desloca o centro do texto.
func _texto2x_cursor(c: Vector2, s: String, cor: Color, focado: bool) -> void:
	_texto2x(c, s, cor)
	if focado and fmod(f.tempo, 1.0) < 0.5:
		var x := c.x + Fonte57.largura(s) + 3.0 if s != "" else c.x
		f.draw_rect(Rect2(x, c.y - 8, 2, 16), cor)


## Contador "7/16" (fica vermelho no limite).
func _contador(pos: Vector2, n: int) -> void:
	var s := "%d/%d" % [n, nome_edit.max_length]
	var cor := Color("#ff9a8a") if n >= nome_edit.max_length else Color(0.72, 0.66, 0.53)
	Fonte57.desenhar(f, pos - Vector2(Fonte57.largura(s), 0), s, cor, f.ESCURO)


func _texto2x(c: Vector2, s: String, cor: Color) -> void:
	var w := Fonte57.largura(s) * 2
	f.draw_set_transform(c - Vector2(w / 2.0, 7), 0.0, Vector2(2, 2))
	Fonte57.desenhar(f, Vector2.ZERO, s, cor, f.ESCURO)
	f.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


# ---------------- perfil ----------------
func campo_nome() -> Rect2:
	return Rect2(50, 318, 260, 34)


func entrar_perfil() -> void:
	editando = "perfil"
	nome_edit.text = str(Sessao.perfil.get("nome", ""))
	var r := campo_nome()
	nome_edit.position = r.position
	nome_edit.size = r.size
	nome_edit.visible = true


func sair_texto() -> void:
	nome_edit.release_focus()
	nome_edit.visible = false


func desenhar_perfil() -> void:
	f._cabecalho(Sessao.t("Seu perfil"), Sessao.t("nome e foto ficam só neste aparelho"))
	moldura_foto(Rect2(120, 98, 120, 160), foto_tex)
	var r := campo_nome()
	var dentro: Rect2 = f._painel(r, nome_edit.has_focus(), 0.0)
	var nome := str(Sessao.perfil.get("nome", ""))
	if nome == "" and not nome_edit.has_focus():
		_texto2x(dentro.get_center(), Sessao.t("seu nome"), Color(0.5, 0.45, 0.5))
	else:
		_texto2x_cursor(dentro.get_center(), nome, f.OURO[0], nome_edit.has_focus())
	Fonte57.desenhar(f, Vector2(50, 304), Sessao.t("Nome"), Color("#b8a888"))
	_contador(Vector2(310, 304), nome.length())
	var tm := "%d %s" % [Sessao.moedas(), Sessao.t("moedas")]
	var wm := Fonte57.largura(tm)
	moeda(Vector2(180 - (wm + 14) / 2.0 + 5, 377))
	Fonte57.desenhar(f, Vector2(180 - (wm + 14) / 2.0 + 14, 374), tm, f.OURO[0], f.ESCURO)
	var n_cartas := 0
	for cid in Sessao.perfil["colecao"]:
		n_cartas += int(Sessao.perfil["colecao"][cid])
	f._texto_central(Vector2(180, 392), Sessao.t("%d cartas na coleção") % n_cartas, Color(0.81, 0.88, 1.0, 0.8))
	_desenhar_aviso()


func _desenhar_aviso() -> void:
	if aviso_t <= 0.0:
		return
	var a := clampf(aviso_t / 0.3, 0, 1)
	var w := Fonte57.largura(aviso) + 16
	var r := Rect2(180 - w / 2.0, 574, w, 18)
	f.draw_rect(r.grow(1), Color(f.ESCURO, a))
	f.draw_rect(r, Color(0.35, 0.1, 0.1, 0.95 * a))
	Fonte57.desenhar(f, r.position + Vector2(8, 5), aviso, Color(1, 0.9, 0.85, a), f.ESCURO)


func escolher_foto() -> void:
	if OS.get_environment("GD_FOTO_TESTE") != "":
		abrir_foto(OS.get_environment("GD_FOTO_TESTE"))
		return
	seletor.popup_centered()


func abrir_foto(caminho: String) -> void:
	var im := Image.load_from_file(caminho)
	if im == null or im.is_empty():
		avisar(Sessao.t("Não consegui abrir essa imagem."))
		return
	if maxi(im.get_width(), im.get_height()) > 2048:             # fotos grandes de celular: reduz antes de recortar
		var k := 2048.0 / maxi(im.get_width(), im.get_height())
		im.resize(int(im.get_width() * k), int(im.get_height() * k), Image.INTERPOLATE_LANCZOS)
	img = im
	img_tex = ImageTexture.create_from_image(im)
	esc = _esc_min()
	pos = MOLDURA.get_center() - Vector2(img.get_width(), img.get_height()) * esc / 2
	sair_texto()
	f._ir("recorte")


# ---------------- recorte 3:4 ----------------
func _esc_min() -> float:
	return maxf(MOLDURA.size.x / img.get_width(), MOLDURA.size.y / img.get_height())


## A foto sempre cobre a janela inteira: escala mínima e posição presas às bordas.
func _prender() -> void:
	esc = clampf(esc, _esc_min(), _esc_min() * 6.0)
	var tam := Vector2(img.get_width(), img.get_height()) * esc
	pos.x = clampf(pos.x, MOLDURA.end.x - tam.x, MOLDURA.position.x)
	pos.y = clampf(pos.y, MOLDURA.end.y - tam.y, MOLDURA.position.y)


func zoom(fator: float, centro := MOLDURA.get_center()) -> void:
	var antes := esc
	esc *= fator
	_prender()
	pos = centro - (centro - pos) * (esc / antes)
	_prender()


func toque_recorte(idx: int, p: Vector2, pressed: bool) -> void:
	if pressed:
		toques[idx] = p
	else:
		toques.erase(idx)
	if toques.size() == 2:
		var v: Array = toques.values()
		_dist_ini = (v[0] as Vector2).distance_to(v[1])
		_esc_ini = esc


func arrastar_recorte(idx: int, p: Vector2) -> void:
	if not toques.has(idx):
		return
	if toques.size() == 1:
		pos += p - toques[idx]
		_prender()
	elif toques.size() == 2:
		toques[idx] = p
		var v: Array = toques.values()
		var d := (v[0] as Vector2).distance_to(v[1])
		if _dist_ini > 10:
			var alvo := _esc_ini * d / _dist_ini
			zoom(alvo / esc, ((v[0] as Vector2) + (v[1] as Vector2)) / 2)
		return
	toques[idx] = p


func desenhar_recorte() -> void:
	f._cabecalho(Sessao.t("Ajuste a foto"), Sessao.t("arraste e use dois dedos para aproximar"))
	if img_tex:
		f.draw_texture_rect(img_tex, Rect2(pos, Vector2(img.get_width(), img.get_height()) * esc), false)
	# escurece fora da janela
	var m := MOLDURA
	var sombra := Color(0.03, 0.02, 0.05, 0.78)
	f.draw_rect(Rect2(-400, 84, 1200, m.position.y - 84), sombra)
	f.draw_rect(Rect2(-400, m.end.y, 1200, 1000), sombra)
	f.draw_rect(Rect2(-400, m.position.y, 400 + m.position.x, m.size.y), sombra)
	f.draw_rect(Rect2(m.end.x, m.position.y, 800, m.size.y), sombra)
	# linhas de terço, bem leves
	for k in [1, 2]:
		f.draw_line(Vector2(m.position.x + m.size.x * k / 3.0, m.position.y), Vector2(m.position.x + m.size.x * k / 3.0, m.end.y), Color(1, 1, 1, 0.12))
		f.draw_line(Vector2(m.position.x, m.position.y + m.size.y * k / 3.0), Vector2(m.end.x, m.position.y + m.size.y * k / 3.0), Color(1, 1, 1, 0.12))
	_aro_recorte(m)


func _aro_recorte(m: Rect2) -> void:
	f.draw_rect(m.grow(3), f.OURO[2], false, 2.0)
	f.draw_rect(m.grow(1), f.OURO[0], false, 1.0)
	for cc in [m.position, Vector2(m.end.x, m.position.y), m.end, Vector2(m.position.x, m.end.y)]:
		f.draw_colored_polygon(PackedVector2Array([cc + Vector2(0, -7), cc + Vector2(7, 0), cc + Vector2(0, 7), cc + Vector2(-7, 0)]), f.OURO[0])
		f.draw_colored_polygon(PackedVector2Array([cc + Vector2(0, -3), cc + Vector2(3, 0), cc + Vector2(0, 3), cc + Vector2(-3, 0)]), f.ESCURO)


func confirmar_recorte() -> void:
	var src := Rect2((MOLDURA.position - pos) / esc, MOLDURA.size / esc)
	var r := Rect2i(src.position.round(), src.size.round())
	r = r.intersection(Rect2i(0, 0, img.get_width(), img.get_height()))
	var parte := img.get_region(r)
	parte.resize(300, 400, Image.INTERPOLATE_LANCZOS)
	parte.save_png(Sessao.FOTO)
	Sessao.perfil["tem_foto"] = true
	Sessao.salvar()
	_carregar_foto()
	img = null
	img_tex = null
	f._ir("perfil")


# ---------------- decks ----------------
func desenhar_decks() -> void:
	f._cabecalho(Sessao.t("Seus decks"), Sessao.t("toque num deck para editar"))
	_desenhar_aviso()


func botao_deck(b: Dictionary, r: Rect2, pressao: float) -> void:
	var i: int = b["deck_idx"]
	var d: Dictionary = Sessao.perfil["decks"][i]
	var n := (d["cartas"] as Array).size()
	var ativo := i == int(Sessao.perfil["deck_ativo"])
	var trad := Sessao.tradicao_do_deck(d["cartas"]) if n > 0 else "alta_magia"
	var cor: Color = Carta.COR_CULTURA.get(trad, Color("#241a20"))
	var dentro: Rect2 = f._painel(r, ativo, pressao, cor.darkened(0.6))
	var lend := ""
	for cid in d["cartas"]:
		if Sessao.db["cartas"][cid]["lendaria"]:
			lend = cid
			break
	var tex := Carta.textura("arte", lend if lend != "" else (d["cartas"][0] if n > 0 else "alt_anjo_guardiao"), "png")
	var mini := Rect2(dentro.position + Vector2(4, 3), Vector2(24, 32))
	f.draw_rect(mini.grow(1), f.ESCURO)
	if tex:
		f.draw_texture_rect(tex, mini, false)
	Fonte57.desenhar(f, dentro.position + Vector2(36, 6), str(d["nome"]), f.OURO[0] if ativo else f.CREME, f.ESCURO)
	var info := "%d/%d" % [n, Sessao.DECK_TAM]
	var cor_info := Color(0.81, 0.88, 1.0) if n == Sessao.DECK_TAM else Color("#ff9a8a")
	Fonte57.desenhar(f, dentro.position + Vector2(36, 19), info + ("" if n == Sessao.DECK_TAM else "  " + Sessao.t("incompleto")), cor_info, f.ESCURO)
	if ativo:
		var s := Sessao.t("EM USO")
		PixelFonte.desenhar(f, Vector2(dentro.end.x - PixelFonte.largura(s) - 6, dentro.position.y + 6), s, f.OURO[0])


func novo_deck() -> void:
	if Sessao.perfil["decks"].size() >= 8:
		avisar(Sessao.t("Máximo de 8 decks."))
		return
	Sessao.perfil["decks"].append({"nome": Sessao.t("Deck %d") % (Sessao.perfil["decks"].size() + 1), "cartas": []})
	Sessao.salvar()
	abrir_deck(Sessao.perfil["decks"].size() - 1)


func abrir_deck(i: int) -> void:
	deck_idx = i
	aba_deck = "cartas"
	rolagem = 0.0
	_montar_lista()
	f._ir("deck_edit")


func _montar_lista() -> void:
	_ids.clear()
	if aba_deck == "deck":
		for cid in Sessao.perfil["decks"][deck_idx]["cartas"]:
			if not cid in _ids:
				_ids.append(cid)
	else:
		for cid in Sessao.db["cartas"]:
			if Sessao.copias(cid) > 0 and (filtro == "" or str(Sessao.db["cartas"][cid]["cultura"]) == filtro):
				_ids.append(cid)
	rolagem = limitar(rolagem)


func trocar_aba(a: String) -> void:
	aba_deck = a
	rolagem = 0.0
	_montar_lista()
	f._ir("deck_edit")


func trocar_filtro(d: String) -> void:
	filtro = d
	rolagem = 0.0
	_montar_lista()
	f._ir("deck_edit")


func _altura() -> float:
	return ceil(_ids.size() / 5.0) * GPASSO + 8


func limitar(alvo: float) -> float:
	return clampf(alvo, 0.0, maxf(0.0, _altura() - (GBASE - GTOPO)))


func _rect(k: int) -> Rect2:
	return Rect2(16 + (k % 5) * (GW + 6), GTOPO + 4 + (k / 5) * GPASSO - rolagem, GW, GH)


## Toque numa carta da grade: abre o visor (alta resolução, lore no swipe) com os botões de adicionar/tirar.
func tocar_grade(p: Vector2) -> void:
	if p.y < GTOPO or p.y > GBASE:
		return
	for k in _ids.size():
		var r := _rect(k)
		if not r.has_point(p):
			continue
		var cid: String = _ids[k]
		var deck: Array = Sessao.perfil["decks"][deck_idx]["cartas"]
		f.visor.abrir(cid, r, [
			{"texto": "+ ADICIONAR", "acao": adicionar.bind(cid), "ativo": func() -> bool: return Sessao.pode_por_no_deck(cid, deck_idx)},
			{"texto": "- TIRAR", "acao": tirar.bind(cid), "ativo": func() -> bool: return deck.has(cid)}],
			func() -> String:
				var livres := Sessao.copias(cid) - Sessao.copias_em_uso(cid, deck_idx) - deck.count(cid)
				return Sessao.t("NO DECK %d  -  LIVRES %d") % [deck.count(cid), maxi(livres, 0)])
		return


func adicionar(cid: String) -> void:
	var deck: Array = Sessao.perfil["decks"][deck_idx]["cartas"]
	if Sessao.pode_por_no_deck(cid, deck_idx):
		deck.append(cid)
		Sessao.salvar()
		f.vibrar(12, 0.4)
		_montar_lista()
		return
	f.vibrar(30, 0.6)
	if deck.size() >= Sessao.DECK_TAM:
		avisar(Sessao.t("O deck já tem 32 cartas."))
	elif deck.count(cid) >= (1 if Sessao.db["cartas"][cid]["lendaria"] else 2):
		avisar(Sessao.t("Limite de cópias desta carta no deck."))
	else:
		avisar(Sessao.t("Todas as suas cópias já estão em uso."))


func tirar(cid: String) -> void:
	var deck: Array = Sessao.perfil["decks"][deck_idx]["cartas"]
	if deck.has(cid):
		deck.erase(cid)
		Sessao.salvar()
		f.vibrar(10, 0.3)
		_montar_lista()


func desenhar_deck_edit() -> void:
	var d: Dictionary = Sessao.perfil["decks"][deck_idx]
	var deck: Array = d["cartas"]
	var editando_nome := nome_edit.has_focus() and editando == "deck"
	_texto2x_cursor(Vector2(180, 18), str(d["nome"]), f.OURO[0], editando_nome)
	if editando_nome:
		_contador(Vector2(352, 30), str(d["nome"]).length())
	var n := deck.size()
	var cor := Color(0.81, 0.88, 1.0) if n == Sessao.DECK_TAM else Color("#ff9a8a")
	f._texto_central(Vector2(180, 36), "%d / %d" % [n, Sessao.DECK_TAM], cor)
	# barra de progresso do deck
	f.draw_rect(Rect2(80, 44, 200, 4), Color(1, 1, 1, 0.1))
	f.draw_rect(Rect2(80, 44, 200.0 * n / Sessao.DECK_TAM, 4), cor)
	for k in _ids.size():
		var r := _rect(k)
		if r.end.y < GTOPO or r.position.y > GBASE:
			continue
		var cid: String = _ids[k]
		var tex := Carta.textura("carta_en" if Sessao.idioma == "en" else "carta", cid, "webp")
		var vis := r.intersection(Rect2(0, GTOPO, 360, GBASE - GTOPO))
		f.draw_rect(vis.grow(1), f.ESCURO)
		if tex:
			f.col._recortado(f, tex, r, GTOPO, GBASE)
		if r.end.y - 12 < GTOPO or r.end.y > GBASE:
			continue
		var no_deck := deck.count(cid)
		var s := ""
		if aba_deck == "deck":
			s = "x%d" % no_deck
		else:
			var livres := Sessao.copias(cid) - Sessao.copias_em_uso(cid, deck_idx) - no_deck
			s = "%d+%d" % [no_deck, livres] if no_deck > 0 else "x%d" % livres
			if livres <= 0 and no_deck == 0:
				f.draw_rect(vis, Color(0, 0, 0, 0.55))
		var w := PixelFonte.largura(s) + 6
		var et := Rect2(r.end.x - w - 1, r.end.y - 11, w, 10)
		f.draw_rect(et, Color(0.45, 0.32, 0.1, 0.95) if no_deck > 0 else Color(0.1, 0.07, 0.1, 0.9))
		PixelFonte.desenhar(f, et.position + Vector2(3, 3), s, f.OURO[0] if no_deck > 0 else f.CREME)
	f.col._barra_rolagem(f, rolagem, _altura(), GTOPO, GBASE)
	_desenhar_aviso()


func renomear_deck() -> void:
	editando = "deck"
	nome_edit.text = str(Sessao.perfil["decks"][deck_idx]["nome"])
	nome_edit.position = Vector2(60, 4)
	nome_edit.size = Vector2(240, 28)
	nome_edit.visible = true
	nome_edit.grab_focus()
	nome_edit.caret_column = nome_edit.text.length()


func usar_deck() -> void:
	if not Sessao.deck_valido(deck_idx):
		avisar(Sessao.t("O deck precisa de exatamente 32 cartas."))
		return
	Sessao.perfil["deck_ativo"] = deck_idx
	Sessao.salvar()
	f.vibrar(18, 0.6)
	avisar(Sessao.t("Deck em uso!"))
	f._ir("deck_edit")


func excluir_deck() -> void:
	if Sessao.perfil["decks"].size() <= 1:
		avisar(Sessao.t("Você precisa de pelo menos um deck."))
		return
	Sessao.perfil["decks"].remove_at(deck_idx)
	Sessao.perfil["deck_ativo"] = clampi(int(Sessao.perfil["deck_ativo"]) - (1 if int(Sessao.perfil["deck_ativo"]) >= deck_idx else 0), 0, Sessao.perfil["decks"].size() - 1)
	Sessao.salvar()
	f._ir("decks")
