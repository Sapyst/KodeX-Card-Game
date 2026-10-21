class_name Pergaminho
extends Node2D
## Pergaminho que abre por cima de qualquer tela (novidades, presente diário, política de privacidade).
## Sequência (aprovada no Guild Dungeon, ver skill pixel-ui-procedural): rolo lacrado surge (0,30 s, ease-out-back)
## → selo de cera racha e cai (0,22 s) → o papel desenrola do centro (0,45 s, ease-out cúbico) → leitura com rolagem
## por arraste e inércia (os rolos "giram" junto) → fecha com ease-in (0,28 s) e some (0,12 s).
## O papel tem textura procedural (manchas, fibras, borda rasgada e queimada) e cresce com o texto: o conteúdo inteiro é
## desenhado uma vez num SubViewport e depois só recortado — rolar não redesenha letra por letra.
## Tudo em px nativos (360 de largura); a altura acompanha a tela útil do menu (fluxo.alt_util).

const PW := 288                       # largura do papel
const PX := 36.0                      # x do papel na tela
const M := 20                         # margem do texto dentro do papel
const TW := PW - 2 * M                # largura útil do texto
const TILE := 256                     # altura do ladrilho de textura (repete sem emenda)
const RW := 306.0                     # largura do rolo
const RH := 12.0                      # altura do rolo aberto (fechado engorda +6: papel enrolado tem volume)
const TINTA := Color8(60, 36, 22)
const TINTA_TIT := Color8(112, 36, 22)
const TINTA_DATA := Color8(132, 98, 62)
const CERA := Color8(160, 30, 34)
const T_SURGE := 0.30
const T_RACHA := 0.22
const T_ABRE := 0.45
const T_FECHA := 0.28
const T_SOME := 0.12

static var _papel: ImageTexture
signal fechou

var f                                 # o menu (fluxo.gd)
var fase := ""                        # "" fechado | surge | racha | abre | aberto | fecha | some
var t := 0.0
var abertura := 0.0                   # 0..1 (altura visível do papel)
var rolagem := 0.0
var vel := 0.0
var altura := 0.0                     # altura total do conteúdo
var vh := 0.0                         # altura da janela de leitura
var _blocos: Array = []
var _desenho: Array = []              # [tipo, pos, texto, extra]
var _ao_fechar := Callable()
var _sv: SubViewport
var _tela: Node2D
var _dedo := false
var _ini := Vector2.ZERO
var _ult := Vector2.ZERO
var _moveu := false
var _botao_aperto := false


func _init(menu) -> void:
	f = menu
	top_level = true
	z_index = 100
	_sv = SubViewport.new()
	_sv.transparent_bg = true
	_sv.disable_3d = true
	_sv.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	_sv.render_target_update_mode = SubViewport.UPDATE_DISABLED
	_tela = Node2D.new()
	_tela.draw.connect(_desenhar_conteudo)
	_sv.add_child(_tela)
	add_child(_sv)


func aberto() -> bool:
	return fase != ""


## blocos: [[tipo, texto, (extra)], ...]. Tipos: titulo, versao (texto, data), item, txt, sub, centro, destaque
## (texto grande + ícone "moeda"/"booster"), espaco, divisor.
func abrir(blocos: Array, ao_fechar := Callable()) -> void:
	_blocos = blocos
	_ao_fechar = ao_fechar
	if _papel == null:
		_papel = _gerar_papel()
	_montar()
	fase = "surge"
	t = 0.0
	abertura = 0.0
	rolagem = 0.0
	vel = 0.0
	f.vibrar(14, 0.4)


func fechar() -> void:
	if fase in ["abre", "aberto"]:
		fase = "fecha"
		t = 0.0
		f.vibrar(10, 0.3)


func _cy() -> float:
	return f.alt_util / 2.0 - 12.0


func _rh() -> float:
	return RH + 6.0 * (1.0 - abertura)


func _y_rolos() -> Vector2:              # centros do rolo de cima e de baixo
	var h := vh * abertura
	return Vector2(_cy() - h / 2.0 - _rh() / 2.0, _cy() + h / 2.0 + _rh() / 2.0)


func _rect_botao() -> Rect2:
	return Rect2(130, _y_rolos().y + _rh() / 2.0 + 12.0, 100, 24)


# ---------------- layout e textura ----------------
func _montar() -> void:
	_desenho.clear()
	var y := 16.0
	for b in _blocos:
		var tipo: String = b[0]
		var s: String = b[1] if b.size() > 1 else ""
		match tipo:
			"titulo":
				_desenho.append(["titulo", Vector2(PW / 2.0, y + 5), s])
				_desenho.append(["ornamento", Vector2(PW / 2.0, y + 18), ""])
				y += 30
			"versao":
				y += 4
				_desenho.append(["versao", Vector2(M, y), s, b[2] if b.size() > 2 else ""])
				_desenho.append(["pontilhado", Vector2(M, y + 9), ""])
				y += 15
			"item":
				var linhas := Fonte57.quebrar(s, TW - 9)
				_desenho.append(["marca", Vector2(M + 1, y + 2), ""])
				for ln in linhas:
					_desenho.append(["texto", Vector2(M + 9, y), ln])
					y += 10
				y += 3
			"txt":
				for ln in Fonte57.quebrar(s, TW):
					_desenho.append(["texto", Vector2(M, y), ln])
					y += 10
				y += 5
			"sub":
				y += 2
				_desenho.append(["sub", Vector2(M, y), s])
				y += 11
			"centro":
				for ln in Fonte57.quebrar(s, TW):
					_desenho.append(["centro", Vector2(PW / 2.0, y), ln])
					y += 10
				y += 4
			"destaque":
				_desenho.append(["destaque", Vector2(PW / 2.0, y + 6), s, b[2] if b.size() > 2 else ""])
				y += 26
			"espaco":
				y += 8
			"divisor":
				y += 4
				_desenho.append(["ornamento", Vector2(PW / 2.0, y), ""])
				y += 10
	altura = ceilf(y + 14.0)
	vh = minf(altura, minf(f.alt_util - 170.0, 440.0))
	_sv.size = Vector2i(PW, int(altura))
	_tela.queue_redraw()
	_sv.render_target_update_mode = SubViewport.UPDATE_ONCE


func _desenhar_conteudo() -> void:
	var y := 0
	while y < altura:
		_tela.draw_texture(_papel, Vector2(0, y))
		y += TILE
	for d in _desenho:
		var p: Vector2 = d[1]
		match d[0]:
			"titulo":
				PixelFonte.centrado(_tela, p, d[2], TINTA_TIT, 2)
			"ornamento":
				_tela.draw_rect(Rect2(p.x - 70, p.y, 61, 1), Color(TINTA_TIT, 0.55))
				_tela.draw_rect(Rect2(p.x + 10, p.y, 61, 1), Color(TINTA_TIT, 0.55))
				_tela.draw_colored_polygon(PackedVector2Array([p + Vector2(0, -3), p + Vector2(3, 0.5), p + Vector2(0, 4),
					p + Vector2(-3, 0.5)]), CERA)
			"versao":
				PixelFonte.desenhar(_tela, p, d[2], TINTA_TIT, 1)
				var dt: String = d[3]
				if dt != "":
					Fonte57.desenhar(_tela, Vector2(PW - M - Fonte57.largura(dt), p.y - 1), dt, TINTA_DATA)
			"pontilhado":
				for x in range(0, TW, 3):
					_tela.draw_rect(Rect2(p.x + x, p.y, 1, 1), Color(TINTA, 0.35))
			"marca":
				_tela.draw_colored_polygon(PackedVector2Array([p + Vector2(2, 0), p + Vector2(4, 2), p + Vector2(2, 4),
					p + Vector2(0, 2)]), CERA)
			"texto":
				Fonte57.desenhar(_tela, p, d[2], TINTA)
			"sub":
				PixelFonte.desenhar(_tela, p, d[2], TINTA_TIT, 1)
			"centro":
				Fonte57.desenhar(_tela, Vector2(roundf(p.x - Fonte57.largura(d[2]) / 2.0), p.y), d[2], TINTA)
			"destaque":
				var s: String = d[2]
				var w := PixelFonte.largura(s, 2)
				var x0 := roundf(p.x - (w + 18) / 2.0)
				_icone(_tela, d[3], Vector2(x0 + 6, p.y))
				PixelFonte.desenhar(_tela, Vector2(x0 + 18, p.y - 5), s, TINTA_TIT, 2)


func _icone(ci: CanvasItem, qual: String, c: Vector2) -> void:
	match qual:
		"moeda":
			ci.draw_circle(c, 7.0, Color("#5a3a10"))
			ci.draw_circle(c, 6.0, Color("#e2b85a"))
			ci.draw_circle(c + Vector2(-1.5, -1.5), 3.0, Color("#ffe39a"))
			ci.draw_rect(Rect2(c + Vector2(-0.5, -3), Vector2(1.5, 6)), Color("#9c7430"))
		"koin":
			MenuPerfil.icone_koin(ci, c, 7.0)
		"booster":
			ci.draw_rect(Rect2(c + Vector2(-6, -8), Vector2(12, 16)), Color("#2a1a2a"))
			ci.draw_rect(Rect2(c + Vector2(-5, -7), Vector2(10, 14)), Color("#7a4ab0"))
			for k in 3:
				ci.draw_rect(Rect2(c + Vector2(-5, -5 + k * 4), Vector2(10, 1)), Color("#e2c8ff", 0.7))
			ci.draw_rect(Rect2(c + Vector2(-5, -7), Vector2(10, 2)), Color("#e2b85a"))


## Ladrilho de papel PW×TILE que repete na vertical sem emenda: ruídos "seamless" do FastNoiseLite para manchas e
## fibras; borda esquerda/direita rasgada com ruído 1D amostrado num círculo (periódico em TILE); faixas por distância
## à borda: queimado < 1,2 px, borda < 2,6 px, depois papel com escurecimento até 14 px para dentro.
static func _gerar_papel() -> ImageTexture:
	var n_grao := FastNoiseLite.new()
	n_grao.seed = 11
	n_grao.frequency = 0.09
	var n_mancha := FastNoiseLite.new()
	n_mancha.seed = 47
	n_mancha.frequency = 0.012
	n_mancha.fractal_octaves = 3
	var grao := n_grao.get_seamless_image(PW, TILE).get_data()
	var mancha := n_mancha.get_seamless_image(PW, TILE).get_data()
	var n_borda := FastNoiseLite.new()
	n_borda.seed = 5
	n_borda.frequency = 0.9
	var esq := PackedFloat32Array()
	var dir := PackedFloat32Array()
	for y in TILE:
		var a := TAU * y / TILE
		var q := Vector2(cos(a), sin(a)) * 6.0
		esq.append(2.0 + 2.2 * (n_borda.get_noise_2d(q.x, q.y) + 1.0) + (0.8 if (y * 7) % 5 == 0 else 0.0))
		dir.append(2.0 + 2.2 * (n_borda.get_noise_2d(q.x + 40.0, q.y - 17.0) + 1.0) + (0.8 if (y * 11) % 7 == 0 else 0.0))
	var px := PackedByteArray()
	px.resize(PW * TILE * 4)
	var papel := Color8(232, 210, 166)
	var mancha_cor := Color8(204, 172, 122)
	var borda := Color8(186, 146, 96)
	var queimado := Color8(120, 78, 42)
	for y in TILE:
		for x in PW:
			var i := y * PW + x
			var d := minf(x - esq[y], PW - 1 - x - dir[y])
			var c: Color
			var al := 255
			if d < 0.0:
				al = 0
				c = Color.BLACK
			elif d < 1.2:
				c = queimado
			elif d < 2.6:
				c = borda
			else:
				var m := mancha[i] / 255.0
				c = papel.lerp(mancha_cor, clampf((m - 0.52) * 2.6, 0.0, 0.75))
				c = c * (0.955 + 0.09 * grao[i] / 255.0)
				if d < 14.0:
					c = c.lerp(borda, 0.28 * (1.0 - d / 14.0))
				if (x * 13 + y * 7) % 97 == 0:          # fibras soltas
					c = c.darkened(0.06)
			px[i * 4] = int(clampf(c.r, 0, 1) * 255)
			px[i * 4 + 1] = int(clampf(c.g, 0, 1) * 255)
			px[i * 4 + 2] = int(clampf(c.b, 0, 1) * 255)
			px[i * 4 + 3] = al
	return ImageTexture.create_from_image(Image.create_from_data(PW, TILE, false, Image.FORMAT_RGBA8, px))


# ---------------- animação ----------------
var _us := 0


func _process(_delta: float) -> void:
	# tempo real (não o do motor): o pergaminho anima mesmo com a mesa pausada (Engine.time_scale = 0)
	var agora := Time.get_ticks_usec()
	var delta := clampf((agora - _us) / 1000000.0, 0.0, 0.1) if _us > 0 else 0.0
	_us = agora
	position = f.pos_base
	if fase == "":
		return
	t += delta
	match fase:
		"surge":
			if t >= T_SURGE:
				fase = "racha"; t = 0.0
				f.vibrar(20, 0.5)
		"racha":
			if t >= T_RACHA:
				fase = "abre"; t = 0.0
		"abre":
			var u := clampf(t / T_ABRE, 0.0, 1.0)
			abertura = 1.0 - pow(1.0 - u, 3.0)
			if u >= 1.0:
				fase = "aberto"
		"aberto":
			if not _dedo and absf(vel) > 1.0:
				rolagem = _limitar(rolagem + vel * delta)
				vel *= pow(0.04, delta)
		"fecha":
			var u := clampf(t / T_FECHA, 0.0, 1.0)
			abertura = 1.0 - u * u
			if u >= 1.0:
				fase = "some"; t = 0.0
		"some":
			if t >= T_SOME:
				fase = ""
				abertura = 0.0
				var cb := _ao_fechar
				_ao_fechar = Callable()
				fechou.emit()
				if cb.is_valid():
					cb.call()
	queue_redraw()


func _limitar(v: float) -> float:
	return clampf(v, 0.0, maxf(0.0, altura - vh))


# ---------------- desenho ----------------
func _draw() -> void:
	if fase == "":
		return
	var vs: Vector2 = get_viewport_rect().size
	var esc := 1.0
	var alfa := 1.0
	var fundo := 1.0
	if fase == "surge":
		var u := clampf(t / T_SURGE, 0.0, 1.0)
		var s := 1.70158
		esc = 0.55 + 0.45 * (1.0 + (s + 1.0) * pow(u - 1.0, 3) + s * pow(u - 1.0, 2))     # ease-out-back
		alfa = clampf(u * 2.0, 0.0, 1.0)
		fundo = u
	elif fase == "some":
		var u := clampf(t / T_SOME, 0.0, 1.0)
		esc = 1.0 - 0.35 * u
		alfa = 1.0 - u
		fundo = 1.0 - u
	draw_rect(Rect2(-position, vs), Color(0.02, 0.01, 0.03, 0.72 * fundo))
	var c := Vector2(180, _cy())
	draw_set_transform(c - c * esc, 0.0, Vector2(esc, esc))
	var yr := _y_rolos()
	var h := vh * abertura
	if h >= 1.0:
		# recorte do centro: abrindo, aparece o meio da janela de leitura e cresce para cima e para baixo
		var src_y := rolagem + vh / 2.0 - h / 2.0
		var dst := Rect2(PX, _cy() - h / 2.0, PW, h)
		draw_texture_rect_region(_sv.get_texture(), dst, Rect2(0, src_y, PW, h), Color(1, 1, 1, alfa))
		# sombra do papel entrando nos rolos (curvatura): 5 px escurecendo
		for k in 5:
			var a := 0.20 * (1.0 - k / 5.0) * alfa
			draw_rect(Rect2(PX + 2, dst.position.y + k, PW - 4, 1), Color(0.25, 0.14, 0.06, a))
			draw_rect(Rect2(PX + 2, dst.end.y - 1 - k, PW - 4, 1), Color(0.25, 0.14, 0.06, a))
		if altura > vh + 1 and fase == "aberto":
			var bh := maxf(18.0, vh * vh / altura)
			var by := dst.position.y + (vh - bh) * rolagem / (altura - vh)
			draw_rect(Rect2(PX + PW - 9, by, 2, bh), Color(TINTA, 0.35))
	var fase_giro := rolagem + vh * abertura * 0.5
	_rolo(yr.x, fase_giro, alfa)
	_rolo(yr.y, -fase_giro, alfa)
	if fase in ["surge", "racha"]:
		_lacre(c, alfa)
	if fase in ["abre", "aberto"]:
		var rb := _rect_botao()
		var ab := clampf(abertura * 1.5 - 0.5, 0.0, 1.0)
		var off := 1.0 if _botao_aperto else 0.0
		draw_rect(rb.grow(1), Color(0.08, 0.05, 0.04, ab))
		draw_rect(Rect2(rb.position + Vector2(0, off), rb.size), Color(0.55, 0.12, 0.13, ab).darkened(0.25 if _botao_aperto else 0.0))
		draw_rect(Rect2(rb.position + Vector2(1, 1 + off), Vector2(rb.size.x - 2, 1)), Color(0.85, 0.35, 0.3, ab))
		PixelFonte.centrado(self, rb.get_center() + Vector2(0, off), Sessao.t("Fechar").to_upper(), Color(1.0, 0.9, 0.75, ab), 1)
	draw_set_transform(Vector2.ZERO)


## Rolo: cilindro de papel enrolado (sombreado por linha, com 2 vincos de espiral que correm com o giro) e pontas de
## madeira escura um pouco mais altas.
func _rolo(y: float, giro: float, alfa: float) -> void:
	var rh := _rh()
	var x0 := 180.0 - RW / 2.0
	var topo := roundf(y - rh / 2.0)
	var n := int(rh)
	draw_rect(Rect2(x0 - 1, topo - 1, RW + 2, n + 2), Color(0.16, 0.09, 0.06, alfa))
	for k in n:
		var v := float(k) / maxf(1.0, n - 1)                   # 0 em cima → 1 embaixo
		var luz := sin(PI * clampf(v * 1.15, 0.0, 1.0))         # cilindro: mais claro um pouco acima do meio
		var cor := Color8(140, 100, 62).lerp(Color8(238, 218, 176), luz * 0.92)
		var vinco := fposmod(k + giro * 0.35, 6.0)
		if vinco < 1.0:
			cor = cor.darkened(0.22)
		draw_rect(Rect2(x0, topo + k, RW, 1), Color(cor, alfa))
	# pontas de madeira
	for lado in [-1.0, 1.0]:
		var xp: float = 180.0 + lado * (RW / 2.0 + 4.0) - 4.0
		draw_rect(Rect2(xp - 1, topo - 3, 10, n + 6), Color(0.12, 0.06, 0.04, alfa))
		draw_rect(Rect2(xp, topo - 2, 8, n + 4), Color8(96, 54, 30, int(255 * alfa)))
		draw_rect(Rect2(xp + 1, topo - 1, 2, n + 2), Color8(150, 96, 56, int(255 * alfa)))
		draw_rect(Rect2(xp + 6, topo - 1, 1, n + 2), Color8(60, 32, 18, int(255 * alfa)))


## Fita vermelha + selo de cera com K. Na fase "racha" as duas metades se afastam e caem acelerando (3·u² × 30 px).
func _lacre(c: Vector2, alfa: float) -> void:
	var u := clampf(t / T_RACHA, 0.0, 1.0) if fase == "racha" else 0.0
	var a := alfa * (1.0 - u)
	var yr := _y_rolos()
	draw_rect(Rect2(c.x - 4, yr.x - _rh() / 2.0 - 2, 8, yr.y - yr.x + _rh() + 4), Color(0.50, 0.08, 0.10, a))
	draw_rect(Rect2(c.x - 4, yr.x - _rh() / 2.0 - 2, 2, yr.y - yr.x + _rh() + 4), Color(0.75, 0.22, 0.22, a))
	for lado in [-1.0, 1.0]:
		var d := Vector2(float(lado) * 6.0 * u, 30.0 * u * u)
		var cc: Vector2 = c + d
		var ini: float = PI / 2.0 if lado < 0 else -PI / 2.0
		var pts := PackedVector2Array([cc])
		for k in 13:
			pts.append(cc + Vector2.from_angle(ini + PI * k / 12.0) * 10.0)
		draw_colored_polygon(pts, Color(0.32, 0.05, 0.07, alfa * (1.0 - u * 0.6)))
		var pts2 := PackedVector2Array([cc])
		for k in 13:
			pts2.append(cc + Vector2.from_angle(ini + PI * k / 12.0) * 8.5)
		draw_colored_polygon(pts2, Color(CERA, alfa * (1.0 - u * 0.6)))
	if u == 0.0:
		PixelFonte.centrado(self, c + Vector2(0, 0), "K", Color(0.95, 0.55, 0.5, alfa), 2)
	else:
		draw_line(c + Vector2(0, -9), c + Vector2(0, 9), Color(0.15, 0.02, 0.03, a), 1.0)


# ---------------- toque ----------------
## p = posição no espaço do menu (px nativos). Devolve sempre true (o pergaminho aberto engole todos os toques).
func entrada(ev: InputEvent, p: Vector2) -> bool:
	if fase != "aberto" and fase != "abre":
		return true
	var papel := Rect2(PX, _cy() - vh / 2.0, PW, vh)
	if ev is InputEventScreenTouch or (ev is InputEventMouseButton and (ev.button_index == MOUSE_BUTTON_LEFT)):
		if ev.pressed:
			_dedo = true
			_ini = p
			_ult = p
			_moveu = false
			vel = 0.0
			_botao_aperto = _rect_botao().has_point(p)
		else:
			_dedo = false
			if _botao_aperto and _rect_botao().grow(8).has_point(p):
				fechar()
			elif not _moveu and not papel.grow(6).has_point(p) and not _rect_botao().has_point(_ini):
				fechar()                                    # toque fora do papel fecha
			_botao_aperto = false
	elif ev is InputEventMouseButton and ev.pressed and ev.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
		rolagem = _limitar(rolagem + (-24.0 if ev.button_index == MOUSE_BUTTON_WHEEL_UP else 24.0))
	elif (ev is InputEventScreenDrag or ev is InputEventMouseMotion) and _dedo:
		var dy := p.y - _ult.y
		_ult = p
		if p.distance_to(_ini) > 6:
			_moveu = true
			if not _rect_botao().has_point(p):
				_botao_aperto = false
		rolagem = _limitar(rolagem - dy)
		vel = -dy / maxf(get_process_delta_time(), 0.008)
	return true
