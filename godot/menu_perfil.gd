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
const GBASE := 532.0
const ALVO_TIPOS := {"entidade": 14, "selo": 6, "rito": 8, "reliquia": 4}   # regras.md: distribuição de um deck
const CURVA_ENT := [[1, 2, 4], [3, 4, 6], [5, 6, 3], [7, 8, 1]]             # Entidades: [custo de, até, quantas]

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
		if editando == "busca":
			f.col.definir_busca(t)
			return
		if editando == "codigo_conta":
			if t.strip_edges().length() >= 8:
				nome_edit.release_focus()
				nome_edit.visible = false
				f.entrar_conta(t.strip_edges())
			return
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


const AVATARES := ["alta_magia", "taoismo", "bruxaria", "indigena"]


## Retratos que se liberam vencendo personagens (dados/avatares.json). Vazio até os NPCs existirem.
static func liberaveis() -> Array:
	var d = JSON.parse_string(FileAccess.get_file_as_string("res://dados/avatares.json"))
	var l: Array = d.get("liberaveis", []) if d is Dictionary else []
	if OS.get_environment("GD_AVATAR_TESTE_LIB") != "":       # teste: vencer o Aditya libera o retrato dele
		l = l + [{"id": "hinduismo", "nome": ["Aditya Rao", "Aditya Rao"], "como": {"vencer": "hinduismo"}}]
	return l


## Todos os retratos da tela de escolha: os padrão + os liberáveis (os ainda trancados aparecem com cadeado).
static func lista_avatares() -> Array:
	var out: Array = AVATARES.duplicate()
	for a in liberaveis():
		if not (a["id"] in out):
			out.append(a["id"])
	return out


static func avatar_liberado(id: String) -> bool:
	return id in AVATARES or id in (Sessao.perfil.get("avatares", []) as Array)


static func como_liberar(id: String) -> String:
	for a in liberaveis():
		if a["id"] == id:
			var quem := str(Sessao.personagem(str(a["como"].get("vencer", ""))).get("nome", a["nome"][0]))
			return Sessao.t("Vença %s") % quem
	return ""


## Imagem padrão: o retrato do personagem (recortado do topo, 3:4) sobre o fundo na cor da tradição.
static func imagem_avatar(id: String) -> Image:
	var tex := Carta.textura("retrato", id, "png")
	var out := Image.create(300, 400, false, Image.FORMAT_RGBA8)
	var cor: Color = Color(Sessao.personagem(id).get("cor", "#3a3050")).darkened(0.35)
	out.fill(cor)
	for y in 400:                                         # degradê escuro para baixo
		out.fill_rect(Rect2i(0, y, 300, 1), cor.darkened(0.55 * float(y) / 400.0))
	if tex:
		var im := tex.get_image()
		im.convert(Image.FORMAT_RGBA8)
		var w := im.get_width()
		var lado := int(w * 0.86)
		var reg := im.get_region(Rect2i(int(w * 0.07), 0, lado, mini(int(lado * 4.0 / 3.0), im.get_height())))
		reg.resize(300, int(300.0 * reg.get_height() / reg.get_width()), Image.INTERPOLATE_LANCZOS)
		out.blend_rect(reg, Rect2i(0, 0, reg.get_width(), mini(reg.get_height(), 400)), Vector2i(0, 0))
	return out


func aplicar_avatar(id: String) -> void:
	if not avatar_liberado(id):
		avisar(como_liberar(id))
		return
	imagem_avatar(id).save_png(Sessao.FOTO)
	Sessao.perfil["tem_foto"] = true
	Sessao.perfil["avatar"] = id
	Sessao.salvar()
	_carregar_foto()
	f.vibrar(18, 0.6)
	f._ir("perfil")


var _tex_avatar := {}


func botao_avatar(b: Dictionary, r: Rect2, pressao: float) -> void:
	var id: String = b["avatar"]
	if not avatar_liberado(id):                          # trancado: silhueta escura, cadeado e como liberar
		var rr0 := Rect2(r.position + Vector2(0, pressao), r.size)
		moldura_foto(rr0, null)
		var cc := rr0.get_center()
		f.draw_rect(Rect2(cc + Vector2(-7, -2), Vector2(14, 11)), f.OURO[2])
		f.draw_arc(cc + Vector2(0, -3), 5.0, PI, TAU, 10, f.OURO[2], 2.0)
		var txt := como_liberar(id)
		var linhas := Fonte57.quebrar(txt, int(rr0.size.x + 30))
		for k in linhas.size():
			f._texto_central(Vector2(cc.x, rr0.end.y + 10 + k * 11), linhas[k], Color(0.72, 0.66, 0.6))
		return
	if not _tex_avatar.has(id):
		_tex_avatar[id] = ImageTexture.create_from_image(imagem_avatar(id))
	var sel: bool = str(Sessao.perfil.get("avatar", "")) == id
	var rr := Rect2(r.position + Vector2(0, pressao), r.size)
	moldura_foto(rr, _tex_avatar[id])
	if sel:
		var pul := 0.6 + 0.4 * sin(f.tempo * 4.0)
		f.draw_rect(rr.grow(6), Color(1.0, 0.85, 0.4, 0.5 * pul), false, 2.0)
	PixelFonte.centrado(f, Vector2(rr.get_center().x, rr.end.y + 10), PixelFonte.normalizar(str(Sessao.personagem(id).get("nome", id)).split(" ")[0]), f.OURO[0] if sel else f.CREME, 1, f.ESCURO)


func desenhar_avatares() -> void:
	f._cabecalho(Sessao.t("Sua imagem"), Sessao.t("escolha uma ou envie uma foto"))
	_desenhar_aviso()


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
	if f.estado == "perfil" and not segurando:              # inércia do histórico no perfil
		if absf(vel_hist) > 1.0:
			rol_hist = limitar_hist(rol_hist + vel_hist * delta)
			vel_hist *= pow(0.04, delta)
		else:
			vel_hist = 0.0
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


## Koin: moeda dos cosméticos (losango roxo com K), desenhada em qualquer CanvasItem.
static func icone_koin(ci: CanvasItem, c: Vector2, r := 5.0) -> void:
	var pts := PackedVector2Array([c + Vector2(0, -r - 1), c + Vector2(r, 0), c + Vector2(0, r + 1), c + Vector2(-r, 0)])
	ci.draw_colored_polygon(pts, Color("#3a1a5a"))
	var pts2 := PackedVector2Array([c + Vector2(0, -r + 0.5), c + Vector2(r - 1.5, 0), c + Vector2(0, r - 0.5), c + Vector2(-r + 1.5, 0)])
	ci.draw_colored_polygon(pts2, Color("#b070ff"))
	ci.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -r + 0.5), c + Vector2(r - 1.5, 0), c]), Color("#e0c0ff"))
	ci.draw_rect(Rect2(c + Vector2(-1.5, -2.5), Vector2(1, 5)), Color("#2a0a40"))
	ci.draw_line(c + Vector2(-0.5, 0), c + Vector2(1.5, -2.5), Color("#2a0a40"), 1.0)
	ci.draw_line(c + Vector2(-0.5, 0), c + Vector2(1.5, 2.5), Color("#2a0a40"), 1.0)


## Barra no topo do título: foto, nome e moedas. Tocar abre o perfil.
func barra_titulo() -> void:
	moldura_foto(MINI, foto_tex, false)
	var nome := str(Sessao.perfil.get("nome", ""))
	Fonte57.desenhar(f, Vector2(42, 12), nome if nome != "" else Sessao.t("Jogador"), f.OURO[0], f.ESCURO)
	var tit := str(Sessao.perfil.get("titulo", ""))           # nível e título em uso embaixo do nome
	var linha := (Sessao.t("Nv") + " %d" % Progresso.nivel()) + ("  ·  " + Progresso.nome_titulo(tit) if tit != "" else "")
	Fonte57.desenhar(f, Vector2(42, 24), linha, Color("#e0c88a") if tit != "" else Color(0.72, 0.66, 0.53, 0.8), f.ESCURO)
	var m := str(f.moedas_vis)                   # o contador sobe conforme as moedas voando chegam (fluxo.gd)
	var w := Fonte57.largura(m)
	moeda(pos_moeda())
	var pulo_m: float = f.pulo_contador[0]
	Fonte57.desenhar(f, Vector2(340 - w, 15 - roundf(pulo_m * 2)), m, f.OURO[0].lerp(Color.WHITE, pulo_m), f.ESCURO)
	var k := str(f.koins_vis)
	var pulo_k: float = f.pulo_contador[1]
	icone_koin(f, pos_koin())
	Fonte57.desenhar(f, pos_koin() + Vector2(8, -3 - roundf(pulo_k * 2)), k, Color("#e0c0ff").lerp(Color.WHITE, pulo_k), f.ESCURO)


## Onde ficam o ícone da moeda e o do Koin na barra do Início (destino das moedas voando).
func pos_moeda() -> Vector2:
	return Vector2(338 - Fonte57.largura(str(f.moedas_vis)) - 10, 18)


func pos_koin() -> Vector2:
	var w := Fonte57.largura(str(f.moedas_vis))
	return Vector2(338 - w - 24 - Fonte57.largura(str(f.koins_vis)) - 10, 18)


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
	nome_edit.visible = f.criando_perfil and not OS.has_feature("web")   # nome só na criação; web: caixa do jogo
	rol_hist = 0.0
	vel_hist = 0.0


func sair_texto() -> void:
	nome_edit.release_focus()
	nome_edit.visible = false


func desenhar_perfil() -> void:
	if not f.criando_perfil:
		_desenhar_perfil_pronto()
		return
	if f.criando_perfil:
		f._cabecalho(Sessao.t("Crie seu perfil"), Sessao.t("é assim que os outros jogadores vão ver você"))
	else:
		f._cabecalho(Sessao.t("Seu perfil"), Sessao.t("quem joga online com você vê nome e foto"))
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
	if f.criando_perfil:                                # tela de criação: só foto e nome
		for k in Fonte57.quebrar(Sessao.t("Escolha bem: o nome não pode ser trocado depois. A foto pode."), 300).size():
			f._texto_central(Vector2(180, 380 + k * 12), Fonte57.quebrar(Sessao.t("Escolha bem: o nome não pode ser trocado depois. A foto pode."), 300)[k], Color(0.62, 0.57, 0.62))
		_desenhar_aviso()
		return
	var tm := "%d %s" % [Sessao.moedas(), Sessao.t("moedas")]
	var wm := Fonte57.largura(tm)
	moeda(Vector2(180 - (wm + 14) / 2.0 + 5, 377))
	Fonte57.desenhar(f, Vector2(180 - (wm + 14) / 2.0 + 14, 374), tm, f.OURO[0], f.ESCURO)
	var n_cartas := 0
	for cid in Sessao.perfil["colecao"]:
		n_cartas += int(Sessao.perfil["colecao"][cid])
	f._texto_central(Vector2(180, 392), Sessao.t("%d cartas na coleção") % n_cartas, Color(0.81, 0.88, 1.0, 0.8))
	_desenhar_aviso()


# ---------------- perfil (depois de criado) ----------------
## Página bordada: foto no canto (lápis para trocar), nome fixo, nível, moedas, coleção e Kode à direita; placar contra
## a IA e contra jogadores; e o histórico rolando embaixo (toque numa partida abre o jogada a jogada).
const P_FOTO := Rect2(24, 104, 90, 120)
const P_LINHA := 38.0                     # passo das linhas do histórico (34 px + 4 de vão)
const P_LISTA_TOPO := 304.0
var rol_hist := 0.0
var vel_hist := 0.0


func p_pagina() -> Rect2:
	return Rect2(10, 90, 340, f.alt_util - 146)


func p_lista_base() -> float:
	return p_pagina().end.y - 30.0             # 30 px de rodapé dentro da página (contagem) cobrem a sobra


func rect_editar_foto() -> Rect2:
	return Rect2(P_FOTO.end.x - 18, P_FOTO.end.y - 18, 30, 30)


func botoes_perfil() -> void:
	f._botao(P_FOTO, "", func() -> void: f._ir("avatar"), {"desenho": func(_b: Dictionary, _r: Rect2, _p: float) -> void: pass})
	f._botao(rect_editar_foto(), "", func() -> void: f._ir("avatar"), {"desenho": _botao_lapis})
	f._botao(Rect2(110, f.alt_util - 46, 140, 28), "Voltar", func() -> void: f._ir("titulo"))


func limitar_hist(alvo: float) -> float:
	var n: int = (Sessao.perfil.get("historico", []) as Array).size()
	return clampf(alvo, 0.0, maxf(0.0, n * P_LINHA - 4.0 - (p_lista_base() - P_LISTA_TOPO)))


func na_lista(p: Vector2) -> bool:
	return p.y > P_LISTA_TOPO and p.y < p_lista_base() and p.x > 16 and p.x < 344


## Toque (sem arrastar) numa linha do histórico: abre o log daquela partida.
func tocar_hist(p: Vector2) -> void:
	if not na_lista(p):
		return
	var k := int((p.y - P_LISTA_TOPO + rol_hist) / P_LINHA)
	var h: Array = Sessao.perfil.get("historico", [])
	if k >= 0 and k < h.size() and fmod(p.y - P_LISTA_TOPO + rol_hist, P_LINHA) < 34.0:
		f.vibrar(10, 0.35)
		f.hist.abrir_log(k)


func _desenhar_perfil_pronto() -> void:
	f._cabecalho(Sessao.t("Seu perfil"), Sessao.t("quem joga online com você vê nome e foto"))
	var pg := p_pagina()
	var fundo := Color("#150e16")
	f.draw_rect(Rect2(pg.position + Vector2(3, 4), pg.size), Color(0, 0, 0, 0.45))
	f.draw_rect(pg, fundo)
	# histórico (desenhado antes: o que passa da janela é coberto pela própria página logo depois)
	var h: Array = Sessao.perfil.get("historico", [])
	var base := p_lista_base()
	for k in h.size():
		var y := P_LISTA_TOPO + k * P_LINHA - rol_hist
		if y + 34 < P_LISTA_TOPO - 2 or y + 34 > pg.end.y - 3:   # nunca passa da página; o resto o rodapé cobre
			continue
		f.hist.botao_linha({"hist_k": k}, Rect2(22, y, 316, 34), 0.0)
	f.draw_rect(Rect2(pg.position.x, pg.position.y, pg.size.x, P_LISTA_TOPO - pg.position.y), fundo)
	f.draw_rect(Rect2(pg.position.x, base, pg.size.x, pg.end.y - base), fundo)
	for k in 6:                                          # esmaece 6 px nas bordas da janela
		var a := 0.7 * (1.0 - k / 6.0)
		f.draw_rect(Rect2(pg.position.x + 4, P_LISTA_TOPO + k, pg.size.x - 8, 1), Color(fundo, a))
		f.draw_rect(Rect2(pg.position.x + 4, base - 1 - k, pg.size.x - 8, 1), Color(fundo, a))
	if h.is_empty():
		f._texto_central(Vector2(180, P_LISTA_TOPO + 30), Sessao.t("Nenhuma partida ainda."), Color(0.62, 0.57, 0.62))
	else:
		f._texto_central(Vector2(180, base + 13), Sessao.t("%d partidas") % h.size() + ("  ·  " + Sessao.t("arraste para ver mais") if limitar_hist(1e9) > 0.0 else ""),
			Color(0.62, 0.57, 0.62))
		if limitar_hist(1e9) > 0.0:
			f.col._barra_rolagem(f, rol_hist, h.size() * P_LINHA - 4.0, P_LISTA_TOPO, base)
	_bordado(pg)
	# foto + lápis
	moldura_foto(P_FOTO, foto_tex)
	# dados à direita da foto
	var x := 132.0
	var nome := str(Sessao.perfil.get("nome", ""))
	var esc := 2 if Fonte57.largura(nome) * 2 <= 206 else 1
	Fonte57.desenhar(f, Vector2(x, 104), nome, f.OURO[0], f.ESCURO, esc)
	var y := 104.0 + 12 * esc + 6
	var tit := str(Sessao.perfil.get("titulo", ""))
	Fonte57.desenhar(f, Vector2(x, y), (Sessao.t("Nv") + " %d" % Progresso.nivel()) + ("  ·  " + Progresso.nome_titulo(tit) if tit != "" else ""),
		Color("#e0c88a"), f.ESCURO)
	y += 18
	moeda(Vector2(x + 5, y + 5))
	var tm := str(Sessao.moedas())
	Fonte57.desenhar(f, Vector2(x + 14, y), tm, f.OURO[0], f.ESCURO)
	var xk := x + 14 + Fonte57.largura(tm) + 16
	icone_koin(f, Vector2(xk + 5, y + 5))
	Fonte57.desenhar(f, Vector2(xk + 14, y), str(Sessao.koins()), Color("#e0c0ff"), f.ESCURO)
	y += 16
	var n_cartas := 0
	for cid in Sessao.perfil["colecao"]:
		n_cartas += int(Sessao.perfil["colecao"][cid])
	Fonte57.desenhar(f, Vector2(x, y), Sessao.t("%d cartas na coleção") % n_cartas, Color(0.81, 0.88, 1.0, 0.85), f.ESCURO)
	y += 16
	Fonte57.desenhar(f, Vector2(x, y), (Sessao.t("Kode") + ": " + Nuvem.kode) if Nuvem.kode != "" else Sessao.t("Convidado (sem Kode)"),
		Color(0.72, 0.66, 0.6), f.ESCURO)
	# placar
	var contra: Dictionary = (Sessao.perfil.get("estat", {}) as Dictionary).get("contra", {})
	_caixa_placar(Rect2(22, 238, 154, 44), Sessao.t("CONTRA A IA"), contra.get("ia", {}), f.CREME)
	_caixa_placar(Rect2(184, 238, 154, 44), Sessao.t("CONTRA JOGADORES"), contra.get("jogador", {}), Color("#9ad0ff"))
	PixelFonte.desenhar(f, Vector2(24, 290), Sessao.t("ÚLTIMAS PARTIDAS"), f.OURO[0])
	if not h.is_empty():
		var dica := Sessao.t("toque para ver a partida")
		Fonte57.desenhar(f, Vector2(338 - Fonte57.largura(dica), 288), dica, Color(0.62, 0.57, 0.62))
	_desenhar_aviso()


func _caixa_placar(r: Rect2, titulo: String, l: Dictionary, cor: Color) -> void:
	f.draw_rect(r, Color("#1f1520"))
	f.draw_rect(r, Color(f.OURO[2], 0.7), false, 1.0)
	PixelFonte.centrado(f, Vector2(r.get_center().x, r.position.y + 9), titulo, Color(cor, 0.85))
	var v := int(l.get("v", 0))
	var d := int(l.get("d", 0))
	var e := int(l.get("e", 0))
	var tot := v + d + e
	var txt := "%dV  %dD  %dE" % [v, d, e]
	f._texto_central(Vector2(r.get_center().x, r.position.y + 22), txt, cor)
	var pct := Sessao.t("%d%% de vitórias") % roundi(100.0 * v / tot) if tot > 0 else Sessao.t("sem partidas")
	f._texto_central(Vector2(r.get_center().x, r.position.y + 34), pct, Color(0.72, 0.66, 0.6))


## Bordado da página: aro dourado, ponto corrido (traços de 4 px a cada 7 px) por dentro, ponto-cruz nos cantos e
## losangos no meio de cada lado.
func _bordado(r: Rect2) -> void:
	f.draw_rect(r, f.OURO[2], false, 1.0)
	var i := r.grow(-5)
	var cor := Color(f.OURO[1], 0.75)
	var x := i.position.x + 9
	while x + 4 <= i.end.x - 9:
		f.draw_line(Vector2(x, i.position.y), Vector2(x + 4, i.position.y), cor, 1.0)
		f.draw_line(Vector2(x, i.end.y), Vector2(x + 4, i.end.y), cor, 1.0)
		x += 7
	var y := i.position.y + 9
	while y + 4 <= i.end.y - 9:
		f.draw_line(Vector2(i.position.x, y), Vector2(i.position.x, y + 4), cor, 1.0)
		f.draw_line(Vector2(i.end.x, y), Vector2(i.end.x, y + 4), cor, 1.0)
		y += 7
	for c in [i.position, Vector2(i.end.x, i.position.y), i.end, Vector2(i.position.x, i.end.y)]:
		f.draw_line(c + Vector2(-4, -4), c + Vector2(4, 4), f.OURO[0], 1.5)
		f.draw_line(c + Vector2(-4, 4), c + Vector2(4, -4), f.OURO[0], 1.5)
	for c in [Vector2(r.get_center().x, i.position.y), Vector2(r.get_center().x, i.end.y), Vector2(i.position.x, r.get_center().y), Vector2(i.end.x, r.get_center().y)]:
		f.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -4), c + Vector2(4, 0), c + Vector2(0, 4), c + Vector2(-4, 0)]), f.OURO[0])
		f.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -2), c + Vector2(2, 0), c + Vector2(0, 2), c + Vector2(-2, 0)]), Color("#150e16"))


## Botão redondo com lápis: troca a foto.
func _botao_lapis(_b: Dictionary, r: Rect2, pressao: float) -> void:
	var c := r.get_center() + Vector2(0, pressao)
	f.draw_circle(c + Vector2(1, 2), 15, Color(0, 0, 0, 0.5))
	f.draw_circle(c, 15, f.OURO[0])
	f.draw_circle(c, 13, Color("#2a1a24").darkened(pressao * 0.3))
	var dir := Vector2(1, -1).normalized()
	var n := Vector2(dir.y, -dir.x)
	var a := c - dir * 6
	var b := c + dir * 5
	f.draw_colored_polygon(PackedVector2Array([a + n * 2.5, b + n * 2.5, b - n * 2.5, a - n * 2.5]), f.OURO[0])
	f.draw_colored_polygon(PackedVector2Array([a + n * 2.5, a - n * 2.5, a - dir * 4]), Color("#f0dcb0"))
	f.draw_colored_polygon(PackedVector2Array([b + n * 2.5, b - n * 2.5, b - n * 2.5 + dir * 2.5, b + n * 2.5 + dir * 2.5]), Color("#d06a6a"))


func _desenhar_aviso() -> void:
	if aviso_t <= 0.0:
		return
	var a := clampf(aviso_t / 0.3, 0, 1)
	var w := Fonte57.largura(aviso) + 16
	var r := Rect2(180 - w / 2.0, 574, w, 18)
	f.draw_rect(r.grow(1), Color(f.ESCURO, a))
	f.draw_rect(r, Color(0.35, 0.1, 0.1, 0.95 * a))
	Fonte57.desenhar(f, r.position + Vector2(8, 5), aviso, Color(1, 0.9, 0.85, a), f.ESCURO)


## Escolher foto: navegador → <input type=file> via JavaScript; Android/PC → seletor nativo do sistema.
## A imagem é lida como bytes (funciona com caminhos content:// do Android) e decodificada pelo formato real.
func escolher_foto() -> void:
	if OS.get_environment("GD_FOTO_TESTE") != "":
		abrir_foto(OS.get_environment("GD_FOTO_TESTE"))
		return
	if OS.has_feature("web"):
		_escolher_web()
		return
	if DisplayServer.has_feature(DisplayServer.FEATURE_NATIVE_DIALOG_FILE):
		DisplayServer.file_dialog_show(Sessao.t("Escolher foto"), "", "", false, DisplayServer.FILE_DIALOG_MODE_OPEN_FILE,
			PackedStringArray(["*.png, *.jpg, *.jpeg, *.webp;Imagens;image/*"]), _ao_escolher_nativo)
		return
	seletor.popup_centered()


func _ao_escolher_nativo(ok: bool, caminhos: PackedStringArray, _filtro: int) -> void:
	if ok and not caminhos.is_empty():
		abrir_foto.call_deferred(caminhos[0])


var _cb_web: JavaScriptObject = null


func _escolher_web() -> void:
	armar_upload_web()                       # fallback (navegadores que aceitam click() fora do gesto)
	JavaScriptBridge.eval("if(window.kodexInput){window.kodexInput.click();}", true)


## Safari/iPhone só abre o seletor de arquivo se input.click() acontecer DENTRO do gesto do usuário. O Godot recebe
## o toque depois que o navegador já o processou, então armamos um ouvinte no "pointerup"/"touchend" do próprio
## documento quando o dedo ENCOSTA no botão: o click() roda quando o dedo sai, ainda dentro do gesto.
## O input fica DENTRO da página (o Safari ignora click() em elemento solto) e aceita só JPEG/PNG/WebP: assim o
## iPhone converte as fotos HEIC para JPEG na hora de escolher (o Godot não abre HEIC).
## Nome, busca e códigos na web: abrem a caixa de digitação do próprio jogo (com um <input> HTML embutido, ver
## fluxo.pedir_texto), chamada no toque — o foco que abre o teclado do iPhone fica armado para quando o dedo sair.
func armar_nome_web(qual: String) -> void:
	if not OS.has_feature("web"):
		return
	editando = qual
	var atual: String = str(Sessao.perfil.get("nome", "")) if qual == "perfil" else (f.col.busca if qual == "busca" else ("" if qual in ["codigo", "codigo_conta"] else str(Sessao.perfil["decks"][deck_idx]["nome"])))
	var titulo: String = Sessao.t("Seu nome") if qual == "perfil" else (Sessao.t("Buscar carta") if qual == "busca" else (Sessao.t("Cole o código do deck") if qual == "codigo" else (Sessao.t("Código da conta (8 letras)") if qual == "codigo_conta" else Sessao.t("Nome do deck"))))
	var maximo := 400 if qual == "codigo" else (8 if qual == "codigo_conta" else nome_edit.max_length)
	var r: String = await f.pedir_texto(titulo, false, maximo, atual)
	if f.cancelou:
		return
	_ao_nome_web([r])


func _ao_nome_web(args: Array) -> void:
	if editando == "codigo":
		importar_codigo(str(args[0]))
		return
	if editando == "codigo_conta":
		f.entrar_conta(str(args[0]).strip_edges())
		return
	var v := str(args[0]).strip_edges().substr(0, nome_edit.max_length)
	if editando == "busca":
		f.col.definir_busca(v)
		f._ir("colecao")
		return
	if editando == "deck":
		if v != "":
			Sessao.perfil["decks"][deck_idx]["nome"] = v
	else:
		Sessao.perfil["nome"] = v
		nome_edit.text = v
	Sessao.salvar()


func armar_upload_web() -> void:
	if not OS.has_feature("web"):
		return
	if _cb_web == null:
		_cb_web = JavaScriptBridge.create_callback(_ao_arquivo_web)
		JavaScriptBridge.get_interface("window").kodexFoto = _cb_web
	JavaScriptBridge.eval("""(function(){
		var i=window.kodexInput;
		if(!i){i=document.createElement('input');i.type='file';i.id='kodexFotoInput';i.accept='image/jpeg,image/png,image/webp';
			i.style.position='fixed';i.style.left='-1000px';i.style.top='0';i.style.opacity='0';
			document.body.appendChild(i);window.kodexInput=i;
			i.addEventListener('change',function(e){var f=e.target.files[0];if(!f)return;var r=new FileReader();
				r.onload=function(){window.kodexFoto(r.result)};r.readAsDataURL(f);i.value='';});}
		var abrir=function(){document.removeEventListener('pointerup',abrir,true);document.removeEventListener('touchend',abrir,true);
			window.kodexArmado=false;i.click();};
		if(!window.kodexArmado){window.kodexArmado=true;
			document.addEventListener('pointerup',abrir,true);document.addEventListener('touchend',abrir,true);}
	})()""", true)


func _ao_arquivo_web(args: Array) -> void:
	var dados := str(args[0])
	if dados.begins_with("data:image/heic") or dados.begins_with("data:image/heif"):
		avisar(Sessao.t("Formato HEIC não suportado. Use JPEG ou PNG."))
		return
	var virgula := dados.find(",")
	if virgula < 0:
		avisar(Sessao.t("Não consegui abrir essa imagem."))
		return
	_abrir_bytes(Marshalls.base64_to_raw(dados.substr(virgula + 1)))


func abrir_foto(caminho: String) -> void:
	var bytes := FileAccess.get_file_as_bytes(caminho)
	if bytes.is_empty():
		var direto := Image.load_from_file(caminho)
		if direto != null and not direto.is_empty():
			_usar_imagem(direto)
			return
		avisar(Sessao.t("Não consegui abrir essa imagem."))
		return
	_abrir_bytes(bytes)


## Decodifica pelos primeiros bytes (PNG, JPEG, WebP); se não reconhecer, tenta os três.
func _abrir_bytes(b: PackedByteArray) -> void:
	var im := Image.new()
	var err := ERR_FILE_UNRECOGNIZED
	if b.size() > 12:
		if b[0] == 0x89 and b[1] == 0x50:
			err = im.load_png_from_buffer(b)
		elif b[0] == 0xFF and b[1] == 0xD8:
			err = im.load_jpg_from_buffer(b)
		elif b[0] == 0x52 and b[8] == 0x57:
			err = im.load_webp_from_buffer(b)
	if err != OK:
		for tentativa in [im.load_jpg_from_buffer, im.load_png_from_buffer, im.load_webp_from_buffer]:
			if (tentativa as Callable).call(b) == OK:
				err = OK
				break
	if err != OK or im.is_empty():
		avisar(Sessao.t("Não consegui abrir essa imagem."))
		return
	_usar_imagem(im)


func _usar_imagem(im: Image) -> void:
	im.convert(Image.FORMAT_RGBA8)
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


const AREA_RECORTE := Rect2(16, 88, 328, 344)      # onde a foto aparece (escurecida) em volta da moldura


## Desenha só a parte da foto que cai dentro de `area` (nada vaza por cima do cabeçalho ou dos botões).
func _foto_em(area: Rect2, mod: Color) -> void:
	var dest := Rect2(pos, Vector2(img.get_width(), img.get_height()) * esc)
	var vis := dest.intersection(area)
	if vis.size.x <= 0 or vis.size.y <= 0:
		return
	var src := Rect2((vis.position - dest.position) / esc, vis.size / esc)
	f.draw_texture_rect_region(img_tex, vis, src, mod)


func desenhar_recorte() -> void:
	var m := MOLDURA
	f.draw_rect(AREA_RECORTE.grow(2), f.ESCURO)
	f.draw_rect(AREA_RECORTE, Color(0.05, 0.04, 0.07))
	if img_tex:
		_foto_em(AREA_RECORTE, Color(0.32, 0.3, 0.34))             # fora da moldura: visível, mas apagada
		_foto_em(m, Color.WHITE)                                    # dentro: nítida
	f.draw_rect(AREA_RECORTE, Color(0.89, 0.72, 0.35, 0.35), false, 1.0)
	for k in [1, 2]:                                                # linhas de terço, bem leves
		f.draw_line(Vector2(m.position.x + m.size.x * k / 3.0, m.position.y), Vector2(m.position.x + m.size.x * k / 3.0, m.end.y), Color(1, 1, 1, 0.12))
		f.draw_line(Vector2(m.position.x, m.position.y + m.size.y * k / 3.0), Vector2(m.end.x, m.position.y + m.size.y * k / 3.0), Color(1, 1, 1, 0.12))
	_aro_recorte(m)
	f._cabecalho(Sessao.t("Ajuste a foto"), Sessao.t("arraste e use dois dedos para aproximar"))


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
## Gaveta da tela Decks: "colecao" (cartas que você tem) ou "livre" (qualquer carta do jogo, 32 por deck; só no Modo livre).
var gaveta := "colecao"
const MAX_POR_GAVETA := 8


func indices_gaveta() -> Array:
	var out: Array = []
	for i in Sessao.perfil["decks"].size():
		if Sessao.deck_livre(i) == (gaveta == "livre"):
			out.append(i)
	return out


## Cria um deck vazio na gaveta atual; devolve o índice ou -1 se a gaveta já tem 8.
func _novo_na_gaveta(nome: String) -> int:
	if indices_gaveta().size() >= MAX_POR_GAVETA:
		avisar(Sessao.t("Máximo de 8 decks nesta gaveta."))
		return -1
	var d := {"nome": nome, "cartas": []}
	if gaveta == "livre":
		d["livre"] = true
	Sessao.perfil["decks"].append(d)
	Sessao.salvar()
	return Sessao.perfil["decks"].size() - 1


func desenhar_decks() -> void:
	f._cabecalho(Sessao.t("Seus decks"), Sessao.t("qualquer carta do jogo, 32 por deck") if gaveta == "livre" else Sessao.t("toque num deck para editar"))
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
	Fonte57.desenhar(f, dentro.position + Vector2(36, 19), info + ("" if n == Sessao.DECK_TAM else "  " + Sessao.t("faltam %d") % (Sessao.DECK_TAM - n)), cor_info, f.ESCURO)
	if Sessao.deck_livre(i):
		var sl := Sessao.t("LIVRE")
		PixelFonte.desenhar(f, Vector2(dentro.end.x - PixelFonte.largura(sl) - 6, dentro.end.y - 11), sl, Color("#9ad0ff"))
	if ativo:
		var s := Sessao.t("EM USO")
		PixelFonte.desenhar(f, Vector2(dentro.end.x - PixelFonte.largura(s) - 6, dentro.position.y + 6), s, f.OURO[0])


func novo_deck() -> void:
	var nome := (Sessao.t("Livre %d") if gaveta == "livre" else Sessao.t("Deck %d")) % (indices_gaveta().size() + 1)
	var i := _novo_na_gaveta(nome)
	if i >= 0:
		abrir_deck(i)


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
		var livre := Sessao.deck_livre(deck_idx)              # deck livre: todas as cartas (menos o Abismo)
		for cid in Sessao.db["cartas"]:
			var cul := str(Sessao.db["cartas"][cid]["cultura"])
			if (Sessao.copias(cid) > 0 or (livre and cul != "abismo")) and (filtro == "" or cul == filtro):
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
				if Sessao.deck_livre(deck_idx):
					return Sessao.t("NO DECK %d") % deck.count(cid)
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
	if aba_deck == "deck":
		desenhar_curva(82)
	for k in _ids.size():
		var r := _rect(k)
		if r.end.y < GTOPO or r.position.y > GBASE:
			continue
		var cid: String = _ids[k]
		var tex := Carta.textura(Sessao.pasta("carta"), cid, "webp")
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
		elif Sessao.deck_livre(deck_idx):
			s = "x%d" % no_deck if no_deck > 0 else "+"
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


## Busca na Coleção: o campo invisível fica sobre o botão de busca (no celular abre o teclado); na web, caixa nativa.
func editar_codigo_conta() -> void:
	editando = "codigo_conta"
	if OS.has_feature("web"):
		return
	nome_edit.text = ""
	nome_edit.position = Vector2(90, 450)
	nome_edit.size = Vector2(180, 24)
	nome_edit.visible = true
	nome_edit.grab_focus()
	avisar(Sessao.t("Digite o código de 8 letras."))


func editar_busca() -> void:
	editando = "busca"
	if OS.has_feature("web"):
		return
	nome_edit.text = f.col.busca
	nome_edit.position = Vector2(242, 76)
	nome_edit.size = Vector2(104, 18)
	nome_edit.visible = true
	nome_edit.grab_focus()
	nome_edit.caret_column = nome_edit.text.length()


func renomear_deck() -> void:
	editando = "deck"
	if OS.has_feature("web"):
		return                                          # web: armar_nome_web() já abriu a caixa nativa no toque
	nome_edit.text = str(Sessao.perfil["decks"][deck_idx]["nome"])
	nome_edit.position = Vector2(60, 4)
	nome_edit.size = Vector2(240, 28)
	nome_edit.visible = true
	nome_edit.grab_focus()
	nome_edit.caret_column = nome_edit.text.length()


func usar_deck() -> void:
	if Sessao.deck_livre(deck_idx):
		avisar(Sessao.t("Deck livre: use no Modo livre (Solo)."))
		return
	if not Sessao.deck_valido(deck_idx):
		avisar(motivo_invalido(deck_idx))
		return
	Sessao.perfil["deck_ativo"] = deck_idx
	Sessao.salvar()
	f.vibrar(18, 0.6)
	avisar(Sessao.t("Deck em uso!"))
	f._ir("deck_edit")


## Por que o deck não vale (para o aviso): faltam cartas (os limites de cópia já são barrados ao adicionar).
func motivo_invalido(i: int) -> String:
	var n := (Sessao.perfil["decks"][i]["cartas"] as Array).size()
	if n < Sessao.DECK_TAM:
		return Sessao.t("Faltam %d cartas (o deck tem %d de 32).") % [Sessao.DECK_TAM - n, n]
	return Sessao.t("O deck precisa de exatamente 32 cartas.")


func _tipo(cid: String) -> String:
	return str(Sessao.db["cartas"][cid]["tipo"])


func _custo(cid: String) -> int:
	return int(Sessao.db["cartas"][cid]["custo"])


## Completa o deck até 32 com cópias livres da coleção (ou qualquer carta, no deck livre): primeiro a tradição que mais
## aparece no deck, respeitando 14 Entidades / 6 Selos / 8 Ritos / 4 Relíquias e a curva das Entidades
## (custo 1–2: 4 · 3–4: 6 · 5–6: 3 · 7–8: 1); o que faltar de um tipo é completado com qualquer carta.
func completar_deck(i: int, trad_pref := "") -> int:
	var deck: Array = Sessao.perfil["decks"][i]["cartas"]
	var livre := Sessao.deck_livre(i)
	var trad := trad_pref if trad_pref != "" else (Sessao.tradicao_do_deck(deck) if not deck.is_empty() else "")
	var antes := deck.size()
	var todas: Array = []
	for cid in Sessao.db["cartas"]:
		if Sessao.db["cartas"][cid]["cultura"] != "abismo" and (livre or Sessao.copias(cid) > 0):
			todas.append(cid)
	# da tradição primeiro; dentro dela, Entidades mais caras primeiro e o resto mais barato primeiro
	todas.sort_custom(func(a: String, b: String) -> bool:
		var ta: bool = trad != "" and Sessao.db["cartas"][a]["cultura"] == trad
		var tb: bool = trad != "" and Sessao.db["cartas"][b]["cultura"] == trad
		if ta != tb:
			return ta
		return _custo(a) > _custo(b) if _tipo(a) == "entidade" else _custo(a) < _custo(b))
	# 1) Entidades pela curva
	for faixa in CURVA_ENT:
		var tem := 0
		for c in deck:
			if _tipo(c) == "entidade" and _custo(c) >= int(faixa[0]) and _custo(c) <= int(faixa[1]):
				tem += 1
		for rodada in 2:                                   # 2 passadas: a 2ª põe a segunda cópia
			for cid in todas:
				if tem >= int(faixa[2]) or deck.size() >= Sessao.DECK_TAM:
					break
				if _tipo(cid) == "entidade" and _custo(cid) >= int(faixa[0]) and _custo(cid) <= int(faixa[1]) \
						and (rodada == 1 or not cid in deck) and Sessao.pode_por_no_deck(cid, i):
					deck.append(cid)
					tem += 1
	# 2) cada tipo até o alvo
	for t in ALVO_TIPOS:
		var falta: int = int(ALVO_TIPOS[t])
		for c in deck:
			if _tipo(c) == t:
				falta -= 1
		for rodada in 2:
			for cid in todas:
				if falta <= 0 or deck.size() >= Sessao.DECK_TAM:
					break
				if _tipo(cid) == t and (rodada == 1 or not cid in deck) and Sessao.pode_por_no_deck(cid, i):
					deck.append(cid)
					falta -= 1
	# 3) o que ainda faltar: qualquer carta
	for rodada in 2:
		for cid in todas:
			if deck.size() >= Sessao.DECK_TAM:
				break
			if (rodada == 1 or not cid in deck) and Sessao.pode_por_no_deck(cid, i):
				deck.append(cid)
	Sessao.salvar()
	return deck.size() - antes


func completar() -> void:
	var n := completar_deck(deck_idx)
	f.vibrar(14, 0.4)
	_montar_lista()
	f._ir("deck_edit")
	if (Sessao.perfil["decks"][deck_idx]["cartas"] as Array).size() == Sessao.DECK_TAM:
		avisar(Sessao.t("+%d cartas: deck completo.") % n)
	else:
		avisar(Sessao.t("+%d cartas. Faltam cartas na coleção para chegar a 32.") % n)


## Deck sugerido: um deck novo da tradição, montado com as cartas que você tem (o temático dela primeiro).
func deck_sugerido(trad: String) -> void:
	var i := _novo_na_gaveta(Sessao.nome_deck(trad) + " " + (Sessao.t("livre") if gaveta == "livre" else Sessao.t("sugerido")))
	if i < 0:
		return
	var deck: Array = Sessao.perfil["decks"][i]["cartas"]
	for cid in Sessao.deck_tematico(trad):
		if Sessao.pode_por_no_deck(cid, i):
			deck.append(cid)
	completar_deck(i, trad)
	abrir_deck(i)
	var n := deck.size()
	if n < Sessao.DECK_TAM:
		avisar(Sessao.t("Montei %d de 32: as outras cópias já estão em outros decks.") % n)


# ---------- código de deck: "KDX1-" + base64 de trios (índice da carta na lista ordenada de ids: 2 bytes, cópias) ----------
static func _ids_ordenados() -> Array:
	var ids: Array = Sessao.db["cartas"].keys()
	ids.sort()
	return ids


func codigo_deck(i: int) -> String:
	var ids := _ids_ordenados()
	var conta := {}
	for cid in Sessao.perfil["decks"][i]["cartas"]:
		conta[cid] = int(conta.get(cid, 0)) + 1
	var b := PackedByteArray()
	for cid in conta:
		var k := ids.find(cid)
		if k >= 0:
			b.append(k % 256)
			b.append(k / 256)
			b.append(int(conta[cid]))
	return "KDX1-" + Marshalls.raw_to_base64(b).replace("+", "-").replace("/", "_").replace("=", "")


func copiar_codigo() -> void:
	var c := codigo_deck(deck_idx)
	DisplayServer.clipboard_set(c)
	var blocos: Array = [["titulo", Sessao.t("Código do deck")], ["centro", str(Sessao.perfil["decks"][deck_idx]["nome"])], ["espaco"]]
	for k in range(0, c.length(), 34):                     # código longo sem espaços: quebra em linhas de 34
		blocos.append(["centro", c.substr(k, 34)])
	blocos.append(["espaco"])
	blocos.append(["centro", Sessao.t("Copiado. Cole em Decks > Importar.")])
	f.perg.abrir(blocos)


## Importa um código: cria um deck novo com as cartas que você tem (as que faltam são contadas no aviso).
func importar_codigo(c: String) -> void:
	c = c.strip_edges().replace(" ", "").replace("\n", "")
	if not c.begins_with("KDX1-"):
		avisar(Sessao.t("Código inválido: copie um código KDX1 antes."))
		return
	var b64 := c.substr(5).replace("-", "+").replace("_", "/")
	while b64.length() % 4 != 0:
		b64 += "="
	var b := Marshalls.base64_to_raw(b64)
	if b.size() == 0 or b.size() % 3 != 0:
		avisar(Sessao.t("Código inválido: copie um código KDX1 antes."))
		return
	var ids := _ids_ordenados()
	var i := _novo_na_gaveta(Sessao.t("Importado"))
	if i < 0:
		return
	var deck: Array = Sessao.perfil["decks"][i]["cartas"]
	var faltou := 0
	for k in range(0, b.size(), 3):
		var idx := int(b[k]) + int(b[k + 1]) * 256
		if idx >= ids.size():
			continue
		for n in int(b[k + 2]):
			if Sessao.pode_por_no_deck(ids[idx], i):
				deck.append(ids[idx])
			else:
				faltou += 1
	Sessao.salvar()
	abrir_deck(i)
	if faltou > 0:
		avisar(Sessao.t("Importado. Faltaram %d cartas que você não tem.") % faltou)
	else:
		avisar(Sessao.t("Importado completo!"))


func colar_codigo() -> void:
	if OS.has_feature("web"):
		return                                              # web: armar_nome_web("codigo") abriu a caixa nativa no toque
	importar_codigo(DisplayServer.clipboard_get())


## Curva de Fé e contagem por tipo (aba "No deck"): barras por custo 0–8.
func desenhar_curva(y: float) -> void:
	var deck: Array = Sessao.perfil["decks"][deck_idx]["cartas"]
	var por_custo: Array = [0, 0, 0, 0, 0, 0, 0, 0, 0]
	var tipos := {"entidade": 0, "selo": 0, "rito": 0, "reliquia": 0}
	for cid in deck:
		por_custo[mini(_custo(cid), 8)] += 1
		tipos[_tipo(cid)] = int(tipos.get(_tipo(cid), 0)) + 1
	var maxv := 1
	for v in por_custo:
		maxv = maxi(maxv, int(v))
	for k in 9:
		var h := 12.0 * int(por_custo[k]) / maxv
		var x := 18.0 + k * 12.0
		f.draw_rect(Rect2(x, y + 12 - h, 8, maxf(h, 1.0)), Color("#7aa8ff") if int(por_custo[k]) > 0 else Color(1, 1, 1, 0.12))
		PixelFonte.desenhar(f, Vector2(x + 2, y + 15), str(k), Color(0.7, 0.66, 0.62))
	var lt := [["E", "entidade", 14], ["S", "selo", 6], ["R", "rito", 8], ["REL", "reliquia", 4]]
	var xx := 132.0
	for t in lt:
		var s := "%s %d/%d" % [Sessao.t(t[0]), int(tipos[t[1]]), int(t[2])]
		PixelFonte.desenhar(f, Vector2(xx, y + 7), s, f.OURO[0] if int(tipos[t[1]]) == int(t[2]) else f.CREME)
		xx += PixelFonte.largura(s) + 8


func excluir_deck() -> void:
	if Sessao.perfil["decks"].size() <= 1:
		avisar(Sessao.t("Você precisa de pelo menos um deck."))
		return
	Sessao.perfil["decks"].remove_at(deck_idx)
	Sessao.perfil["deck_ativo"] = clampi(int(Sessao.perfil["deck_ativo"]) - (1 if int(Sessao.perfil["deck_ativo"]) >= deck_idx else 0), 0, Sessao.perfil["decks"].size() - 1)
	Sessao.salvar()
	f._ir("decks")
