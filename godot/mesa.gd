extends Node2D
## Mesa em pixel art (render nativo 360×640, ampliado ×2): entrada com a câmera girando e zoom, velas acendendo,
## deck caindo em cascata, dois embaralhamentos riffle, cortes, batida, monte vai para o deck e compra da mão inicial.

const CENTRO := Vector2(180, 320)
const N_CARTAS := 32
const MAO_INICIAL := 4

# falsa perspectiva: a mesa encolhe para cima (fundo = 84% da largura da frente)
const TOPO_Y := 34.0
const BASE_Y := 606.0
const ESC_TOPO := 0.84

# espaços em coordenadas "planas" da mesa
const ENT_OPON := [Vector2(68, 200), Vector2(143, 200), Vector2(218, 200), Vector2(293, 200)]
const SELO_OPON := [Vector2(143, 110), Vector2(218, 110)]
const ENT_JOG := [Vector2(68, 382), Vector2(143, 382), Vector2(218, 382), Vector2(293, 382)]
const SELO_JOG := [Vector2(143, 474), Vector2(218, 474)]
const DECK_JOG := Vector2(306, 474)
const CEMIT_JOG := Vector2(55, 474)
const DECK_OPON := Vector2(55, 110)
const CEMIT_OPON := Vector2(306, 110)
const LINHA_Y := 291.0
const ESC_CAMPO := 0.84
const LUZ_PRINCIPAL := Vector2(180, -34)

# paleta
const PEDRA := [Color("#16121c"), Color("#1c1724"), Color("#0e0b13")]
const MADEIRA := [Color("#5a3826"), Color("#4a2d1f"), Color("#331f16"), Color("#6b4630")]
const VELUDO := [Color("#3d1f33"), Color("#33192b"), Color("#26111f")]
const OURO := [Color("#ffe39a"), Color("#e2b85a"), Color("#9c7430")]
const ESCURO := Color("#140c10")

const DIGITOS := {
	"0": ["111", "101", "101", "101", "111"], "1": ["010", "110", "010", "010", "111"], "2": ["111", "001", "111", "100", "111"],
	"3": ["111", "001", "011", "001", "111"], "4": ["101", "101", "111", "001", "001"], "5": ["111", "100", "111", "001", "111"],
	"6": ["111", "100", "111", "101", "111"], "7": ["111", "001", "010", "010", "010"], "8": ["111", "101", "111", "101", "111"],
	"9": ["111", "101", "111", "001", "111"], "/": ["001", "001", "010", "100", "100"],
}

var camera: Camera2D
var ambiente: CanvasModulate
var tabuleiro: Node2D
var camada_cartas: Node2D
var luzes: Array[PointLight2D] = []
var luz_base: Array[float] = []
var luz_pos0: Array[Vector2] = []
var deck_jog: Array[Carta] = []
var deck_opon: Array[Carta] = []
var mao_jog: Array[Carta] = []
var mao_opon: Array[Carta] = []
var rng := RandomNumberGenerator.new()
var ruido := FastNoiseLite.new()
var tempo := 0.0
var efeitos: Efeitos
var placar: Node2D
var cornucopia := [15, 15]
var placar_pulo := [0.0, 0.0]
var campo_ent := [[null, null, null, null], [null, null, null, null]]
var campo_selo := [[null, null], [null, null]]
var cemiterio := [0, 0]
var tremor := 0.0
var segurando: Carta = null
var origem := ""                      # "mao" | "campo"
var origem_idx := -1
var ponteiro := Vector2.ZERO
var ocupado := false                  # animação em curso: ignora toques
signal escolhido(valor: bool)
signal fim_turno_pedido
var modo_partida := OS.get_environment("GD_DEMO") == ""
var auto_jogador := OS.get_environment("GD_AUTO") != ""
var db: Dictionary = {}
var fe := [0, 0]
var fe_max := [0, 0]
var ativo := 0
var turno_n := 0
var selo_no_turno := false
var acabou := false
var botao_fim := Rect2(296, 318, 50, 14)
var segurando_t := 0.0
var segurando_ini := Vector2.ZERO


func _ready() -> void:
	rng.seed = 7
	ruido.frequency = 3.0
	ambiente = CanvasModulate.new()
	ambiente.color = Color.BLACK
	add_child(ambiente)
	tabuleiro = Node2D.new()
	tabuleiro.draw.connect(_desenhar_tabuleiro)
	add_child(tabuleiro)
	_criar_luzes()
	camada_cartas = Node2D.new()
	add_child(camada_cartas)
	if modo_partida:
		db = JSON.parse_string(FileAccess.get_file_as_string("res://dados/cartas.json"))
	placar = Node2D.new()
	placar.z_index = 50
	placar.draw.connect(_desenhar_placar)
	add_child(placar)
	efeitos = Efeitos.new()
	add_child(efeitos)
	camera = Camera2D.new()
	camera.position = CENTRO
	camera.ignore_rotation = false
	add_child(camera)
	camera.make_current()
	await _intro()
	await _cascata_deck()
	await _riffle()
	await _riffle()
	await _cortes()
	await _bater_monte()
	await _ir_para_deck()
	await _comprar_mao()
	print("PRONTO: mão inicial comprada")
	if modo_partida:
		await _partida()
		Sessao.resultado = "vitoria" if cornucopia[1] <= 0 else ("derrota" if cornucopia[0] <= 0 else "empate")
		if Sessao.modo != "" and OS.get_environment("GD_SAIR_NO_FIM") == "":
			await get_tree().create_timer(1.5).timeout
			get_tree().change_scene_to_file("res://fluxo.tscn")
			return
		if OS.get_environment("GD_SAIR_NO_FIM") != "":
			await get_tree().create_timer(4.0).timeout
			get_tree().quit()
	if OS.get_environment("GD_DEMO") != "":
		await _demo()
		print("DEMO: fim")


# ---------------- perspectiva ----------------
func escala_em(y: float) -> float:
	return lerpf(ESC_TOPO, 1.0, clampf((y - TOPO_Y) / (BASE_Y - TOPO_Y), 0.0, 1.0))


func proj(p: Vector2) -> Vector2:
	return Vector2(CENTRO.x + (p.x - CENTRO.x) * escala_em(p.y), p.y).round()


func quad(c: Vector2, hw: float, hh: float) -> PackedVector2Array:
	return PackedVector2Array([proj(c + Vector2(-hw, -hh)), proj(c + Vector2(hw, -hh)), proj(c + Vector2(hw, hh)), proj(c + Vector2(-hw, hh))])


# ---------------- luz de velas ----------------
func _textura_luz(tam: int) -> GradientTexture2D:
	var g := Gradient.new()
	g.set_color(0, Color(1, 1, 1, 1))
	g.set_color(1, Color(1, 1, 1, 0))
	g.add_point(0.35, Color(1, 1, 1, 0.55))
	var t := GradientTexture2D.new()
	t.gradient = g
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(1.0, 0.5)
	t.width = tam
	t.height = tam
	return t


func _criar_luzes() -> void:
	## Sem velas visíveis: só o reflexo delas. Uma luz grande central vindo de cima, duas laterais e um preenchimento
	## fraco perto da mão. Todas tremulam (energia e posição) como chama de vela.
	var tex := _textura_luz(256)
	var defs := [
		[Vector2(180, -40), 5.8, 1.35, Color(1.0, 0.80, 0.55)],     # central, de cima
		[Vector2(-46, 300), 3.8, 0.75, Color(1.0, 0.70, 0.42)],     # lateral esquerda
		[Vector2(406, 300), 3.8, 0.75, Color(1.0, 0.70, 0.42)],     # lateral direita
		[Vector2(180, 640), 3.0, 0.50, Color(1.0, 0.85, 0.70)],     # preenchimento da mão
	]
	for d in defs:
		var l := PointLight2D.new()
		l.texture = tex
		l.position = d[0]
		l.texture_scale = d[1]
		l.color = d[3]
		l.energy = 0.0
		l.set_meta("liga", 0.0)
		add_child(l)
		luzes.append(l)
		luz_base.append(d[2])
		luz_pos0.append(d[0])


func _process(delta: float) -> void:
	tempo += delta
	# tremulação de vela: duas frequências de ruído somadas (lenta + rápida) na energia e um balanço de 2–3 px
	for i in luzes.size():
		var l: PointLight2D = luzes[i]
		var lento := ruido.get_noise_1d(tempo * 2.0 + i * 37.0)
		var rapido := ruido.get_noise_1d(tempo * 11.0 + i * 91.0)
		l.energy = luz_base[i] * (0.88 + 0.08 * lento + 0.05 * rapido) * float(l.get_meta("liga", 0.0))
		l.position = luz_pos0[i] + Vector2(lento * 3.0, rapido * 2.0)
	# tremor de câmera
	tremor = maxf(0.0, tremor - delta * 14.0)
	camera.offset = Vector2(randf_range(-tremor, tremor), randf_range(-tremor, tremor)).round()
	# animação ociosa: mão respira (1 px), cartas do campo flutuam (1 px), alternando a fase
	for k in mao_jog.size():
		var c: Carta = mao_jog[k]
		if c != segurando:
			c.bob = Vector2(0, sin(tempo * 2.2 + k * 1.3) * 1.2)
	for dono in 2:
		for i in 4:
			var c = campo_ent[dono][i]
			if c != null and c != segurando:
				(c as Carta).bob = Vector2(0, sin(tempo * 1.6 + i * 1.9 + dono) * 0.9)
	if modo_partida:
		_atualizar_zoom(delta)
	# carta segurada: segue o dedo com atraso, inclina conforme a velocidade
	if segurando != null:
		var alvo := ponteiro + Vector2(0, -14)
		var novo := segurando.position.lerp(alvo, 0.35)
		var vel := novo - segurando.position
		segurando.position = novo
		segurando.inclinacao = lerpf(segurando.inclinacao, clampf(-vel.x * 0.045, -0.4, 0.4), 0.3)
		segurando.rotation = lerpf(segurando.rotation, clampf(vel.x * 0.012, -0.2, 0.2), 0.25)
	for d in 2:
		placar_pulo[d] = maxf(0.0, placar_pulo[d] - delta * 3.0)
	placar.queue_redraw()


# ---------------- mesa ----------------
func _desenhar_tabuleiro() -> void:
	var t := tabuleiro
	# piso de pedra grande (a câmera gira e se afasta)
	for gy in range(-50, 90):
		for gx in range(-50, 72):
			var c: Color = PEDRA[(gx * 7 + gy * 13) % 2]
			t.draw_rect(Rect2(gx * 16, gy * 16, 16, 16), c)
			t.draw_rect(Rect2(gx * 16, gy * 16, 16, 1), PEDRA[2])
			t.draw_rect(Rect2(gx * 16 + (8 if gy % 2 else 0), gy * 16, 1, 16), PEDRA[2])
	# tampo de madeira: tábuas convergindo (perspectiva)
	var tampo := PackedVector2Array([proj(Vector2(8, TOPO_Y)), proj(Vector2(352, TOPO_Y)), proj(Vector2(352, BASE_Y)), proj(Vector2(8, BASE_Y))])
	t.draw_colored_polygon(tampo, MADEIRA[1])
	var n_tab := 15
	for k in range(1, n_tab):
		var x := 8 + 344.0 * k / n_tab
		t.draw_line(proj(Vector2(x, TOPO_Y)), proj(Vector2(x, BASE_Y)), MADEIRA[2], 1.0)
	for k in 160:                                                   # veios
		var px := rng.randf_range(10, 350)
		var py := rng.randf_range(TOPO_Y + 4, BASE_Y - 8)
		t.draw_line(proj(Vector2(px, py)), proj(Vector2(px, py + rng.randf_range(4, 14))), MADEIRA[0] if k % 3 else MADEIRA[3], 1.0)
	# veludo da área de jogo + bordado dourado
	var vel := PackedVector2Array([proj(Vector2(22, TOPO_Y + 16)), proj(Vector2(338, TOPO_Y + 16)), proj(Vector2(338, BASE_Y - 16)), proj(Vector2(22, BASE_Y - 16))])
	t.draw_colored_polygon(vel, VELUDO[0])
	for k in 220:                                                   # textura do veludo
		var p := proj(Vector2(rng.randf_range(24, 336), rng.randf_range(TOPO_Y + 18, BASE_Y - 18)))
		t.draw_rect(Rect2(p, Vector2(1, 1)), VELUDO[1])
	t.draw_polyline(vel + PackedVector2Array([vel[0]]), OURO[2], 1.0)
	var vel2 := PackedVector2Array([proj(Vector2(25, TOPO_Y + 19)), proj(Vector2(335, TOPO_Y + 19)), proj(Vector2(335, BASE_Y - 19)), proj(Vector2(25, BASE_Y - 19))])
	t.draw_polyline(vel2 + PackedVector2Array([vel2[0]]), OURO[1], 1.0)
	# moldura dourada da mesa
	t.draw_polyline(tampo + PackedVector2Array([tampo[0]]), OURO[1], 2.0)
	t.draw_polyline(PackedVector2Array([proj(Vector2(8, BASE_Y + 1)), proj(Vector2(352, BASE_Y + 1))]), OURO[2], 1.0)
	# linha central bordada + emblema
	for x in range(30, 331, 4):
		t.draw_rect(Rect2(proj(Vector2(x, LINHA_Y)), Vector2(2, 1)), OURO[1])
	var e := proj(Vector2(180, LINHA_Y))
	_anel(e, 15, OURO[1]); _anel(e, 11, OURO[2])
	t.draw_circle(e, 10.0, VELUDO[2])
	for k in 8:
		var a := TAU * k / 8.0
		t.draw_rect(Rect2((e + Vector2.from_angle(a) * 13).round(), Vector2(1, 1)), OURO[0])
	t.draw_rect(Rect2(e + Vector2(-2, -2), Vector2(5, 5)), OURO[1])
	# espaços entalhados
	for p in ENT_OPON + ENT_JOG:
		_espaco(p, OURO[2])
	for p in SELO_OPON + SELO_JOG:
		_espaco(p, Color("#7a5aa8"))
	for p in [DECK_JOG, DECK_OPON, CEMIT_JOG, CEMIT_OPON]:
		_espaco(p, Color("#8c7a6a"))



func _anel(c: Vector2, r: float, cor: Color) -> void:
	tabuleiro.draw_arc(c, r, 0, TAU, 48, cor, 1.0)


func _espaco(c: Vector2, cor: Color) -> void:
	var hw := Carta.LARG * ESC_CAMPO / 2 + 2
	var hh := Carta.ALT * ESC_CAMPO / 2 + 2
	var q := quad(c, hw, hh)
	tabuleiro.draw_colored_polygon(q, VELUDO[2])
	# entalhe: borda escura em cima/esquerda, clara embaixo/direita
	tabuleiro.draw_line(q[0], q[1], ESCURO, 1.0)
	tabuleiro.draw_line(q[0], q[3], ESCURO, 1.0)
	tabuleiro.draw_line(q[3], q[2], cor, 1.0)
	tabuleiro.draw_line(q[1], q[2], cor, 1.0)
	for qq in q:                                                   # tachas nos cantos
		tabuleiro.draw_rect(Rect2(qq + Vector2(-1, -1), Vector2(2, 2)), cor)


func _placar(p: Vector2, s: String, cor: Color) -> void:
	tabuleiro.draw_rect(Rect2(p + Vector2(-2, -2), Vector2(8 + s.length() * 4 + 3, 9)), ESCURO)
	tabuleiro.draw_rect(Rect2(p + Vector2(0, 1), Vector2(3, 3)), cor)
	var x := p.x + 6
	for ch in s:
		var g: Array = DIGITOS.get(ch, DIGITOS["0"])
		for yy in 5:
			var row: String = g[yy]
			for xx in 3:
				if row[xx] == "1":
					tabuleiro.draw_rect(Rect2(x + xx, p.y + yy, 1, 1), Color("#f2e6c8"))
		x += 4


# ---------------- entrada ----------------
func _intro() -> void:
	camera.zoom = Vector2(0.34, 0.34)
	camera.rotation = -2.5
	var t := create_tween().set_parallel(true)
	t.tween_property(camera, "rotation", 0.0, 2.8).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	t.tween_property(camera, "zoom", Vector2(1.06, 1.06), 2.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(ambiente, "color", Color(0.40, 0.33, 0.44), 1.6).set_delay(0.2)
	t.chain().tween_property(camera, "zoom", Vector2.ONE, 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	# luz central acende devagar; laterais acendem com um estouro de chama (110%) e assentam
	_acender(0, 0.5, 1.4)
	_acender(1, 1.1, 0.5)
	_acender(2, 1.35, 0.5)
	_acender(3, 1.0, 1.2)
	await t.finished


func _acender(i: int, atraso: float, dur: float) -> void:
	await get_tree().create_timer(atraso).timeout
	var l: PointLight2D = luzes[i]
	var t := create_tween()
	t.tween_method(func(v: float) -> void: l.set_meta("liga", v), 0.0, 1.25, dur * 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_method(func(v: float) -> void: l.set_meta("liga", v), 1.25, 1.0, dur * 0.6).set_trans(Tween.TRANS_SINE)


# ---------------- utilidades de movimento ----------------
func _nova_carta(pos: Vector2, esc: float) -> Carta:
	var c := Carta.new()
	c.position = pos
	c.scale = Vector2(esc, esc)
	c.luz = LUZ_PRINCIPAL
	camada_cartas.add_child(c)
	return c


## Move em arco (Bézier quadrática): sobe `altura` px no meio do caminho e "levanta" a carta (sombra) junto.
func _arco(c: Carta, destino: Vector2, dur: float, altura: float, rot_final: float, esc_final: float,
		trans := Tween.TRANS_CUBIC, ease := Tween.EASE_IN_OUT) -> Tween:
	var ini := c.position
	var ctrl := (ini + destino) / 2 + Vector2(0, -altura)
	var rot_ini := c.rotation
	var esc_ini := c.scale.x
	var t := create_tween()
	t.tween_method(func(u: float) -> void:
		var a := ini.lerp(ctrl, u)
		var b := ctrl.lerp(destino, u)
		c.position = a.lerp(b, u)
		c.rotation = lerp_angle(rot_ini, rot_final, u)
		var s := lerpf(esc_ini, esc_final, u) * (1.0 + 0.10 * sin(u * PI) * clampf(altura / 30.0, 0, 1))
		c.scale = Vector2(s, s)
		c.levantada = sin(u * PI) * clampf(altura / 30.0, 0, 1), 0.0, 1.0, dur).set_trans(trans).set_ease(ease)
	return t


func _pos_monte(i: int) -> Vector2:
	return CENTRO + Vector2(0, -int(i / 3))          # 1 px de grossura a cada 3 cartas


func _z_monte() -> void:
	for i in deck_jog.size():
		var c: Carta = deck_jog[i]
		c.z_index = i
		c.empilhada = i > 0


# ---------------- deck: cascata ----------------
func _cascata_deck() -> void:
	for i in N_CARTAS:
		var c := _nova_carta(Vector2(CENTRO.x + rng.randf_range(-70, 70), -90), 1.0)
		c.rotation = rng.randf_range(-0.6, 0.6)
		c.z_index = i
		deck_jog.append(c)
		_arco(c, _pos_monte(i), 0.42, 40, rng.randf_range(-0.04, 0.04), 1.0, Tween.TRANS_QUAD, Tween.EASE_OUT)
		await get_tree().create_timer(0.03).timeout
	await get_tree().create_timer(0.45).timeout
	_z_monte()


func _bater_monte() -> void:
	# alinha e dá uma batidinha (escala 1 → 0,96 → 1)
	for i in deck_jog.size():
		var c: Carta = deck_jog[i]
		var t := create_tween().set_parallel(true)
		t.tween_property(c, "position", _pos_monte(i), 0.1)
		t.tween_property(c, "rotation", 0.0, 0.1)
	await get_tree().create_timer(0.12).timeout
	for c in deck_jog:
		var t := create_tween()
		t.tween_property(c, "scale", Vector2(1.0, 0.94), 0.06)
		t.tween_property(c, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(0.25).timeout


# ---------------- embaralhar ----------------
func _riffle() -> void:
	var meio := deck_jog.size() / 2 + rng.randi_range(-3, 3)
	var esq: Array[Carta] = deck_jog.slice(0, meio)
	var dir: Array[Carta] = deck_jog.slice(meio)
	# separa em duas metades que levantam e inclinam
	for i in esq.size():
		var c: Carta = esq[i]
		c.empilhada = i > 0
		_arco(c, CENTRO + Vector2(-64, -int(i / 3)), 0.3, 14, -0.16, 1.0)
	for i in dir.size():
		var c: Carta = dir[i]
		c.empilhada = i > 0
		c.z_index = i
		_arco(c, CENTRO + Vector2(64, -int(i / 3)), 0.3, 14, 0.16, 1.0)
	await get_tree().create_timer(0.38).timeout
	# intercala: cai 1–3 cartas de cada lado, de baixo para cima, em arco curto
	var nova: Array[Carta] = []
	var a := 0
	var b := 0
	while a < esq.size() or b < dir.size():
		var lado_esq := (rng.randf() < 0.5 and a < esq.size()) or b >= dir.size()
		for k in rng.randi_range(1, 3):
			if lado_esq and a < esq.size():
				nova.append(esq[a]); a += 1
			elif not lado_esq and b < dir.size():
				nova.append(dir[b]); b += 1
	for i in nova.size():
		var c: Carta = nova[i]
		c.z_index = 200 + i
		c.empilhada = false
		_arco(c, _pos_monte(i) + Vector2(rng.randi_range(-2, 2), 0), 0.16, 8, rng.randf_range(-0.05, 0.05), 1.0, Tween.TRANS_QUAD, Tween.EASE_IN)
		await get_tree().create_timer(0.022).timeout
	await get_tree().create_timer(0.2).timeout
	deck_jog = nova
	_z_monte()


func _cortes() -> void:
	# 3 cortes: um bloco de baixo sai pela direita, sobe e cai por cima do monte
	for k in 3:
		var tam := rng.randi_range(7, 12)
		var bloco: Array[Carta] = deck_jog.slice(0, tam)
		for c in bloco:
			deck_jog.erase(c)
		for i in bloco.size():
			var c: Carta = bloco[i]
			c.z_index = 300 + i
			c.empilhada = i > 0
			_arco(c, CENTRO + Vector2(58, -30 - int(i / 2)), 0.18, 10, 0.12, 1.0, Tween.TRANS_QUAD, Tween.EASE_OUT)
		for i in deck_jog.size():
			var c: Carta = deck_jog[i]
			create_tween().tween_property(c, "position", _pos_monte(i), 0.14)
		await get_tree().create_timer(0.22).timeout
		deck_jog.append_array(bloco)
		for i in bloco.size():
			var c: Carta = bloco[i]
			_arco(c, _pos_monte(deck_jog.size() - bloco.size() + i), 0.2, 6, 0.0, 1.0, Tween.TRANS_QUAD, Tween.EASE_IN)
		await get_tree().create_timer(0.26).timeout
		_z_monte()


# ---------------- monte → espaço do deck ----------------
func _ir_para_deck() -> void:
	var destino := proj(DECK_JOG)
	var esc := ESC_CAMPO * escala_em(DECK_JOG.y)
	for i in deck_jog.size():
		var c: Carta = deck_jog[i]
		_arco(c, destino + Vector2(0, -int(i / 3)), 0.5, 26, 0.0, esc)
		await get_tree().create_timer(0.008).timeout
	# deck do oponente desliza de fora da tela pelo alto-esquerdo
	var dest_o := proj(DECK_OPON)
	var esc_o := ESC_CAMPO * escala_em(DECK_OPON.y)
	for i in N_CARTAS:
		var c := _nova_carta(Vector2(-60, -80), esc_o)
		c.rotation = -0.5
		c.z_index = i
		c.empilhada = i > 0
		deck_opon.append(c)
		_arco(c, dest_o + Vector2(0, -int(i / 3)), 0.55, 30, 0.0, esc_o, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		await get_tree().create_timer(0.006).timeout
	await get_tree().create_timer(0.65).timeout
	if modo_partida:
		if Sessao.modo != "":
			_dar_ids(deck_jog, Sessao.deck_jogador, 0)
			_dar_ids(deck_opon, Sessao.deck_oponente, 1)
		else:
			_dar_dados(deck_jog, OS.get_environment("GD_DECK_A") if OS.get_environment("GD_DECK_A") != "" else "indigena", 0)
			_dar_dados(deck_opon, OS.get_environment("GD_DECK_B") if OS.get_environment("GD_DECK_B") != "" else "cristianismo", 1)


# ---------------- mão inicial ----------------
func _layout_mao(n: int, k: int) -> Array:
	var meio := (n - 1) / 2.0
	var d := k - meio
	return [Vector2(180 + d * 52, 566 + absf(d) * absf(d) * 3), deg_to_rad(d * 7.0)]


func _layout_mao_opon(n: int, k: int) -> Array:
	var meio := (n - 1) / 2.0
	var d := k - meio
	return [Vector2(180 + d * 34, 6 - absf(d) * absf(d) * 2), PI - deg_to_rad(d * 6.0)]


func _rearrumar(mao: Array[Carta], layout: Callable, esc: float) -> void:
	for k in mao.size():
		var c: Carta = mao[k]
		var lay: Array = layout.call(mao.size(), k)
		var t := create_tween().set_parallel(true)
		t.tween_property(c, "position", lay[0], 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		t.tween_property(c, "rotation", lay[1], 0.25)
		t.tween_property(c, "scale", Vector2(esc, esc), 0.25)


func _comprar_mao() -> void:
	for k in MAO_INICIAL:
		# jogador: topo levanta, viaja em arco e vira no ar
		var c: Carta = deck_jog.pop_back()
		c.empilhada = false
		c.z_index = 500 + k
		if not modo_partida:
			var ficha: Array = [["entidade", 3, 4], ["entidade", 2, 3], ["selo", 0, 0], ["rito", 0, 0]][k]
			c.tipo = ficha[0]; c.atk = ficha[1]; c.defe = ficha[2]; c.dono = 0
		mao_jog.append(c)
		var t0 := create_tween()
		t0.tween_property(c, "position:y", c.position.y - 10, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		t0.parallel().tween_property(c, "levantada", 0.6, 0.12)
		await t0.finished
		var lay: Array = _layout_mao(mao_jog.size(), mao_jog.size() - 1)
		_arco(c, lay[0], 0.42, 40, lay[1], 1.0)
		get_tree().create_timer(0.1).timeout.connect(func() -> void: c.virar(0.26))
		var anteriores: Array[Carta] = mao_jog.slice(0, mao_jog.size() - 1)
		for kk in anteriores.size():
			var a: Carta = anteriores[kk]
			var l2: Array = _layout_mao(mao_jog.size(), kk)
			var t := create_tween().set_parallel(true)
			t.tween_property(a, "position", l2[0], 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			t.tween_property(a, "rotation", l2[1], 0.3)
		# oponente: compra para cima, sem virar
		var o: Carta = deck_opon.pop_back()
		o.empilhada = false
		o.z_index = 500 + k
		mao_opon.append(o)
		var lo: Array = _layout_mao_opon(mao_opon.size(), mao_opon.size() - 1)
		_arco(o, lo[0], 0.42, 20, lo[1], 0.62)
		_rearrumar(mao_opon.slice(0, mao_opon.size() - 1), _layout_mao_opon, 0.62)
		await get_tree().create_timer(0.5).timeout
	# a mão "assenta": batida leve de escala em sequência
	for c in mao_jog:
		var t := create_tween()
		t.tween_property(c, "scale", Vector2(1.06, 1.06), 0.08)
		t.tween_property(c, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		await get_tree().create_timer(0.05).timeout
	await get_tree().create_timer(0.4).timeout


# ================= placar dinâmico =================
func _pos_placar(dono: int) -> Vector2:
	return proj(Vector2(34, LINHA_Y + 8)) if dono == 0 else proj(Vector2(34, LINHA_Y - 14))


func _desenhar_placar() -> void:
	for d in 2:
		var p := _pos_placar(d)
		var s := str(maxi(cornucopia[d], 0))
		var pulo: float = placar_pulo[d]
		var esc := 1 + int(pulo > 0.5)
		var cor := Color("#ff6a6a") if pulo > 0.0 else Color("#f2e6c8")
		placar.draw_rect(Rect2(p + Vector2(-2, -2), Vector2(9 + PixelFonte.largura(s, esc), 5 * esc + 4)), ESCURO)
		placar.draw_rect(Rect2(p + Vector2(0, 1), Vector2(3, 3)), Color("#e86a6a"))
		PixelFonte.desenhar(placar, p + Vector2(6, -(esc - 1) * 2), s, cor, esc)
		if modo_partida:
			var pf := proj(Vector2(300, LINHA_Y + 8)) if d == 0 else proj(Vector2(300, LINHA_Y - 14))
			var sf := "%d/%d" % [fe[d], fe_max[d]]
			placar.draw_rect(Rect2(pf + Vector2(-2, -2), Vector2(9 + PixelFonte.largura(sf), 9)), ESCURO)
			placar.draw_rect(Rect2(pf + Vector2(0, 1), Vector2(3, 3)), Color("#7aa8ff"))
			PixelFonte.desenhar(placar, pf + Vector2(6, 0), sf, Color("#cfe0ff"))
	if modo_partida:
		var r := botao_fim
		var vez := ativo == 0 and not acabou
		placar.draw_rect(r.grow(1), ESCURO)
		placar.draw_rect(r, Color("#5a3a1a") if vez else Color("#2a2430"))
		placar.draw_rect(Rect2(r.position, Vector2(r.size.x, 1)), OURO[1] if vez else Color("#4a4450"))
		PixelFonte.centrado(placar, r.get_center() + Vector2(0, 1), "FIM" if vez else "...", Color("#ffe39a") if vez else Color("#8a8090"))


# ================= posições do campo =================
func pos_ent(dono: int, i: int) -> Vector2:
	return proj((ENT_JOG if dono == 0 else ENT_OPON)[i])


func pos_selo(dono: int, i: int) -> Vector2:
	return proj((SELO_JOG if dono == 0 else SELO_OPON)[i])


func esc_em(p: Vector2) -> float:
	return ESC_CAMPO * escala_em(p.y)


func _rect_espaco(p: Vector2) -> Rect2:
	var e := esc_em(p)
	var sz := Vector2(Carta.LARG, Carta.ALT) * e
	return Rect2(p - sz / 2, sz).grow(3)


# ================= entrada (toque / mouse) =================
func _unhandled_input(ev: InputEvent) -> void:
	var pos_ev: Vector2 = ev.position if "position" in ev else Vector2.ZERO
	var p: Vector2 = get_canvas_transform().affine_inverse() * pos_ev
	if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT or ev is InputEventScreenTouch:
		if ev.pressed:
			pressionar(p)
		else:
			soltar(p)
	elif ev is InputEventMouseMotion or ev is InputEventScreenDrag:
		mover(p)


func pressionar(p: Vector2) -> void:
	ponteiro = p
	if not efeitos.escolha.is_empty():
		for b in efeitos.escolha:
			if (b["rect"] as Rect2).grow(3).has_point(p):
				escolhido.emit(b["valor"])
				return
		return
	if modo_partida and botao_fim.grow(4).has_point(p):
		if ativo == 0 and not ocupado and not acabou:
			fim_turno_pedido.emit()
		return
	if ocupado or segurando != null or (modo_partida and (ativo != 0 or acabou)):
		_tentar_zoom(p)
		return
	for k in range(mao_jog.size() - 1, -1, -1):
		var c: Carta = mao_jog[k]
		if c.contem(p):
			_pegar(c, "mao", k)
			return
	for i in 4:
		var c = campo_ent[0][i]
		if c != null and (c as Carta).contem(p):
			_pegar(c, "campo", i)
			return
	_tentar_zoom(p)


func mover(p: Vector2) -> void:
	ponteiro = p


func soltar(p: Vector2) -> void:
	ponteiro = p
	efeitos.zoom = null
	zoom_pendente = null
	if segurando == null:
		return
	var c := segurando
	segurando = null
	efeitos.destaques.clear()
	ocupado = true
	if origem == "mao":
		await _soltar_da_mao(c, p)
	else:
		await _soltar_do_campo(c, p)
	ocupado = false


func _pegar(c: Carta, de: String, idx: int) -> void:
	segurando_t = 0.0
	segurando_ini = ponteiro
	segurando = c
	origem = de
	origem_idx = idx
	c.z_index = 800
	var t := create_tween().set_parallel(true)
	t.tween_property(c, "scale", Vector2(1.15, 1.15), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(c, "levantada", 1.0, 0.12)
	efeitos.destaques.clear()
	if de == "mao":
		if c.tipo == "entidade":
			for i in 4:
				if campo_ent[0][i] == null:
					efeitos.destaques.append(_rect_espaco(pos_ent(0, i)))
		elif c.tipo == "selo":
			for i in 2:
				if campo_selo[0][i] == null:
					efeitos.destaques.append(_rect_espaco(pos_selo(0, i)))
		else:
			for i in 4:
				if campo_ent[1][i] != null:
					efeitos.destaques.append(_rect_espaco(pos_ent(1, i)))
	else:
		for i in 4:
			if campo_ent[0][i] == null:
				efeitos.destaques.append(_rect_espaco(pos_ent(0, i)))
			if campo_ent[1][i] != null:
				efeitos.destaques.append(_rect_espaco(pos_ent(1, i)))
		if _campo_vazio(1):
			efeitos.destaques.append(Rect2(_pos_placar(1) + Vector2(-6, -6), Vector2(30, 18)))


func _campo_vazio(dono: int) -> bool:
	for i in 4:
		if campo_ent[dono][i] != null:
			return false
	return true


func _espaco_sob(p: Vector2, posicoes: Callable, n: int, livre: Array) -> int:
	for i in n:
		if livre[i] == null and _rect_espaco(posicoes.call(i)).grow(8).has_point(p):
			return i
	return -1


func _inimigo_sob(p: Vector2) -> int:
	for i in 4:
		var c = campo_ent[1][i]
		if c != null and _rect_espaco(pos_ent(1, i)).grow(6).has_point(p):
			return i
	return -1


# ================= soltar =================
func _soltar_da_mao(c: Carta, p: Vector2) -> void:
	if modo_partida:
		await _soltar_da_mao_partida(c, p)
		return
	if c.tipo == "entidade":
		var i := _espaco_sob(p, func(i: int) -> Vector2: return pos_ent(0, i), 4, campo_ent[0])
		if i < 0:
			await _recusar(c); return
		mao_jog.erase(c)
		campo_ent[0][i] = c
		_rearrumar_mao()
		var cima: bool = await _escolher_face(c, pos_ent(0, i))
		await _cair(c, pos_ent(0, i), cima)
	elif c.tipo == "selo":
		var i := _espaco_sob(p, func(i: int) -> Vector2: return pos_selo(0, i), 2, campo_selo[0])
		if i < 0:
			await _recusar(c); return
		mao_jog.erase(c)
		campo_selo[0][i] = c
		_rearrumar_mao()
		await _cair(c, pos_selo(0, i), false)                # Selo: sempre virado para baixo
	else:
		var alvo := _inimigo_sob(p)
		if alvo < 0:
			await _recusar(c); return
		mao_jog.erase(c)
		_rearrumar_mao()
		await _lancar_rito(c, alvo)


func _soltar_do_campo(c: Carta, p: Vector2) -> void:
	var livre := _espaco_sob(p, func(i: int) -> Vector2: return pos_ent(0, i), 4, campo_ent[0])
	var inimigo := _inimigo_sob(p)
	if livre >= 0:                                                       # mudar de lugar
		campo_ent[0][origem_idx] = null
		campo_ent[0][livre] = c
		var dest := pos_ent(0, livre)
		await _arco(c, dest, 0.28, 18, 0.0, esc_em(dest)).finished
		_impacto(c, dest, 0.5)
	elif inimigo >= 0 and c.virada_para_cima:
		var motivo := _pode_atacar(c, campo_ent[1][inimigo])
		if motivo != "":
			efeitos.numero(c.position + Vector2(0, -40), motivo, Color("#ffd0a0"), 1)
			await _recusar(c); return
		await _voltar_ao_espaco(c)
		await _atacar(c, campo_ent[1][inimigo])
	elif _campo_vazio(1) and c.virada_para_cima and p.y < LINHA_Y:
		var motivo := _pode_atacar(c, null)
		if motivo != "":
			efeitos.numero(c.position + Vector2(0, -40), motivo, Color("#ffd0a0"), 1)
			await _recusar(c); return
		await _voltar_ao_espaco(c)
		await _golpe_direto(c, 1)
	else:
		await _recusar(c)


func _voltar_ao_espaco(c: Carta) -> void:
	var dest := pos_ent(0, origem_idx)
	var t := create_tween().set_parallel(true)
	t.tween_property(c, "position", dest, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(c, "scale", Vector2.ONE * esc_em(dest), 0.14)
	t.tween_property(c, "rotation", 0.0, 0.14)
	t.tween_property(c, "inclinacao", 0.0, 0.14)
	t.tween_property(c, "levantada", 0.0, 0.14)
	await t.finished
	c.z_index = 100


## Soltou em lugar inválido: sacode (6 batidas em 0,2 s) e volta para a origem como puxada por um ímã (elástico 0,5 s).
func _recusar(c: Carta) -> void:
	var base := c.position
	var t := create_tween()
	for dx in [5, -5, 4, -4, 2, 0]:
		t.tween_property(c, "position", base + Vector2(dx, 0), 0.034)
	t.parallel().tween_property(c, "inclinacao", 0.0, 0.2)
	await t.finished
	efeitos.faiscas(c.position, 6, Color("#ff8a6a"))
	var dest: Vector2
	var rot := 0.0
	var esc := 1.0
	if origem == "mao":
		var lay: Array = _layout_mao(mao_jog.size(), mao_jog.find(c))
		dest = lay[0]; rot = lay[1]
	else:
		dest = pos_ent(0, origem_idx); esc = esc_em(dest)
	var t2 := create_tween().set_parallel(true)
	t2.tween_property(c, "position", dest, 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	t2.tween_property(c, "rotation", rot, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t2.tween_property(c, "scale", Vector2(esc, esc), 0.3)
	t2.tween_property(c, "levantada", 0.0, 0.3)
	await t2.finished
	c.z_index = 500 + mao_jog.find(c) if origem == "mao" else 100


func _rearrumar_mao() -> void:
	for k in mao_jog.size():
		var c: Carta = mao_jog[k]
		c.z_index = 500 + k
		var lay: Array = _layout_mao(mao_jog.size(), k)
		var t := create_tween().set_parallel(true)
		t.tween_property(c, "position", lay[0], 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		t.tween_property(c, "rotation", lay[1], 0.3)


## A carta paira 26 px acima do espaço e aparecem os botões CIMA/BAIXO; devolve true para cima.
func _escolher_face(c: Carta, dest: Vector2) -> bool:
	var t := create_tween().set_parallel(true)
	t.tween_property(c, "position", dest + Vector2(0, -26), 0.18).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(c, "rotation", 0.0, 0.18)
	t.tween_property(c, "inclinacao", 0.0, 0.18)
	t.tween_property(c, "scale", Vector2(1.1, 1.1), 0.18)
	await t.finished
	var y := dest.y - 26 - Carta.ALT * 0.55 - 14
	efeitos.escolha = [
		{"rect": Rect2(dest.x - 38, y, 34, 11), "texto": "CIMA", "valor": true},
		{"rect": Rect2(dest.x + 4, y, 34, 11), "texto": "BAIXO", "valor": false}]
	var v: bool = await escolhido
	efeitos.escolha.clear()
	return v


## Queda no espaço: sobe 24 px e cresce (125%), cai em 0,16 s acelerando, achata no impacto e solta poeira.
func _cair(c: Carta, dest: Vector2, para_cima: bool) -> void:
	c.z_index = 700
	if c.virada_para_cima != para_cima:
		await c.virar(0.2)
	var e := esc_em(dest)
	var t := create_tween().set_parallel(true)
	t.tween_property(c, "position", dest + Vector2(0, -24), 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(c, "scale", Vector2(e, e) * 1.25, 0.12)
	t.tween_property(c, "rotation", 0.0, 0.12)
	t.tween_property(c, "inclinacao", 0.0, 0.12)
	await t.finished
	var t2 := create_tween().set_parallel(true)
	t2.tween_property(c, "position", dest, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t2.tween_property(c, "scale", Vector2(e, e), 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t2.tween_property(c, "levantada", 0.0, 0.16)
	await t2.finished
	_impacto(c, dest, 1.0)
	c.z_index = 100


func _impacto(c: Carta, dest: Vector2, forca: float) -> void:
	var e := c.scale.x
	var t := create_tween()
	t.tween_property(c, "scale", Vector2(e * 1.08, e * 0.9), 0.05)
	t.tween_property(c, "scale", Vector2(e, e), 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	efeitos.poeira(dest + Vector2(0, Carta.ALT * e / 2), int(14 * forca))
	efeitos.anel(dest, Color("#ffe39a"), 34 * forca)
	tremor = maxf(tremor, 2.0 * forca)


# ================= combate =================
func _remover_do_campo(c: Carta) -> int:
	for i in 4:
		if campo_ent[c.dono][i] == c:
			campo_ent[c.dono][i] = null
			return i
	return -1


## Ataque entre Entidades: recua 8 px (0,14 s), dispara até o alvo (0,11 s), impacto com clarão, faíscas, números de dano,
## tremor de 3 px, volta (0,3 s). Quem zerar a Vida é destruído.
func _atacar(c: Carta, alvo: Carta) -> void:
	c.atacou = true
	var ini := c.position
	var dir := (alvo.position - ini).normalized()
	c.z_index = 750
	var t := create_tween().set_parallel(true)
	t.tween_property(c, "position", ini - dir * 8, 0.14).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.tween_property(c, "scale", c.scale * 1.12, 0.14)
	t.tween_property(c, "levantada", 0.8, 0.14)
	await t.finished
	var contato := alvo.position - dir * 22
	var t2 := create_tween()
	t2.tween_property(c, "position", contato, 0.11).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	await t2.finished
	# impacto
	alvo.dano += c.atk
	c.dano += alvo.atk
	tremor = 3.5
	efeitos.flash(Color.WHITE, 0.18)
	efeitos.faiscas((contato + alvo.position) / 2, 18)
	efeitos.numero(alvo.position + Vector2(0, -20), "-%d" % c.atk, Color("#ff6a6a"))
	if alvo.atk > 0:
		efeitos.numero(c.position + Vector2(0, -20), "-%d" % alvo.atk, Color("#ff6a6a"))
	_piscar(alvo); _piscar(c)
	_sacudir(alvo, 3.0)
	var t3 := create_tween().set_parallel(true)
	t3.tween_property(c, "position", ini, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t3.tween_property(c, "scale", Vector2.ONE * esc_em(ini), 0.3)
	t3.tween_property(c, "levantada", 0.0, 0.3)
	await t3.finished
	c.z_index = 100
	if alvo.vida() <= 0:
		await _destruir(alvo)
	if c.vida() <= 0:
		await _destruir(c)


func _piscar(c: Carta) -> void:
	var t := create_tween()
	t.tween_property(c, "brilho", 0.9, 0.04)
	t.tween_property(c, "brilho", 0.0, 0.22)


func _sacudir(c: Carta, amp: float) -> void:
	var base := c.position
	var t := create_tween()
	for k in 6:
		t.tween_property(c, "position", base + Vector2(amp * (1 if k % 2 == 0 else -1) * (1.0 - k / 6.0), 0), 0.035)
	t.tween_property(c, "position", base, 0.035)


## Derrota da carta: treme, pisca 2×, estilhaça em ~70 fragmentos e reaparece pequena no cemitério do dono.
func _destruir(c: Carta) -> void:
	if c.dono == 1:
		_provocar(2)
	_remover_do_campo(c)
	if modo_partida and "renascer" in c.keywords:
		await _renascer(c)
		return
	_sacudir(c, 2.0)
	for k in 2:
		var t := create_tween()
		t.tween_property(c, "brilho", 1.0, 0.06)
		t.tween_property(c, "brilho", 0.2, 0.08)
		await t.finished
	efeitos.estilhacar(c.position, c.cores_estilhaco(), int(Carta.LARG * c.scale.x), int(Carta.ALT * c.scale.y))
	tremor = 2.5
	c.visible = false
	await get_tree().create_timer(0.35).timeout
	var cem := proj(CEMIT_JOG if c.dono == 0 else CEMIT_OPON)
	c.position = cem + Vector2(0, -cemiterio[c.dono])
	c.rotation = 0.0
	c.brilho = 0.0
	c.dano = 0
	c.empilhada = cemiterio[c.dono] > 0
	c.scale = Vector2.ZERO
	c.visible = true
	c.z_index = 40 + cemiterio[c.dono]
	cemiterio[c.dono] += 1
	if not c.virada_para_cima:
		c.virada_para_cima = true
	create_tween().tween_property(c, "scale", Vector2.ONE * esc_em(cem), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Golpe direto na Cornucópia (só com o campo inimigo vazio): recuo maior, investida até o placar, tremor de 5 px,
## clarão vermelho, número grande e o placar pulsa.
func _golpe_direto(c: Carta, alvo_dono: int) -> void:
	c.atacou = true
	var ini := c.position
	var alvo := _pos_placar(alvo_dono) + Vector2(10, 2)
	var dir := (alvo - ini).normalized()
	c.z_index = 750
	var t := create_tween().set_parallel(true)
	t.tween_property(c, "position", ini - dir * 14, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.tween_property(c, "scale", c.scale * 1.2, 0.2)
	t.tween_property(c, "levantada", 1.0, 0.2)
	t.tween_property(c, "rotation", dir.angle() + PI / 2 if dir.y < 0 else 0.0, 0.2)
	await t.finished
	var t2 := create_tween()
	t2.tween_property(c, "position", alvo + Vector2(0, 26 if alvo_dono == 1 else -26), 0.13).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	await t2.finished
	cornucopia[alvo_dono] -= c.atk
	placar_pulo[alvo_dono] = 1.0
	tremor = 5.0
	efeitos.flash(Color("#ff3030"), 0.3)
	efeitos.faiscas(alvo, 26, Color("#ff9a6a"))
	efeitos.numero(alvo + Vector2(20, -10), "-%d" % c.atk, Color("#ff5050"), 3)
	var t3 := create_tween().set_parallel(true)
	t3.tween_property(c, "position", ini, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t3.tween_property(c, "scale", Vector2.ONE * esc_em(ini), 0.35)
	t3.tween_property(c, "rotation", 0.0, 0.35)
	t3.tween_property(c, "levantada", 0.0, 0.35)
	await t3.finished
	c.z_index = 100
	if cornucopia[alvo_dono] <= 0:
		acabou = true
		if alvo_dono == 1:
			await _vitoria()
		else:
			await _derrota()


## Rito: a carta sobe ao centro do lado inimigo, brilha 3×, dispara um feixe de faíscas no alvo (3 de dano) e se desfaz.
func _lancar_rito(c: Carta, alvo_idx: int) -> void:
	var alvo: Carta = campo_ent[1][alvo_idx]
	var p := Vector2(180, LINHA_Y - 10)
	var t := create_tween().set_parallel(true)
	t.tween_property(c, "position", p, 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(c, "rotation", 0.0, 0.25)
	t.tween_property(c, "inclinacao", 0.0, 0.25)
	t.tween_property(c, "scale", Vector2(1.2, 1.2), 0.25)
	await t.finished
	for k in 3:
		var tb := create_tween()
		tb.tween_property(c, "brilho", 0.6, 0.08)
		tb.tween_property(c, "brilho", 0.0, 0.1)
		await tb.finished
	for k in 8:
		efeitos.faiscas(p.lerp(alvo.position, k / 8.0), 4, Color("#8ae3a8"))
		await get_tree().create_timer(0.025).timeout
	alvo.dano += 3
	_piscar(alvo); _sacudir(alvo, 3.0)
	tremor = 3.0
	efeitos.numero(alvo.position + Vector2(0, -20), "-3", Color("#ff6a6a"))
	efeitos.estilhacar(c.position, [Color("#8ae3a8"), Color("#d8ffe0"), Color("#4aa070")], 60, 80)
	c.queue_free()
	cemiterio[0] += 1
	await get_tree().create_timer(0.3).timeout
	if alvo.vida() <= 0:
		await _destruir(alvo)


# ================= vitória / derrota =================
func _vitoria() -> void:
	await get_tree().create_timer(0.3).timeout
	efeitos.faixa = "VITÓRIA"
	efeitos.faixa_t = 0.0
	efeitos.confete(90)
	efeitos.flash(Color("#ffe39a"), 0.4)
	for k in mao_jog.size():                                   # a mão comemora: pulinhos em sequência
		var c: Carta = mao_jog[k]
		var t := create_tween()
		t.tween_property(c, "position:y", c.position.y - 14, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		t.tween_property(c, "position:y", c.position.y, 0.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		await get_tree().create_timer(0.08).timeout
	await get_tree().create_timer(2.6).timeout


func _derrota() -> void:
	await get_tree().create_timer(0.3).timeout
	tremor = 6.0
	efeitos.flash(Color("#300010"), 0.6)
	var t := create_tween().set_parallel(true)
	t.tween_property(ambiente, "color", Color(0.24, 0.24, 0.30), 1.0)
	for i in luzes.size():
		var l: PointLight2D = luzes[i]
		t.tween_method(func(v: float) -> void: l.set_meta("liga", v), 1.0, 0.45, 1.0)
	efeitos.faixa = "DERROTA"
	efeitos.faixa_t = 0.0
	efeitos.cinzas(70)
	for c in mao_jog:                                          # a mão afunda 30 px
		create_tween().tween_property(c, "position:y", c.position.y + 30, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await get_tree().create_timer(3.0).timeout


# ================= oponente (roteiro simples) =================
func _oponente_joga(idx: int, atk: int, defe: int) -> Carta:
	var c: Carta = mao_opon.pop_back()
	c.tipo = "entidade"; c.atk = atk; c.defe = defe; c.dono = 1
	_rearrumar(mao_opon, _layout_mao_opon, 0.62)
	campo_ent[1][idx] = c
	var dest := pos_ent(1, idx)
	await _arco(c, dest + Vector2(0, -24), 0.35, 20, 0.0, esc_em(dest) * 1.25).finished
	await _cair(c, dest, true)
	return c


# ================= demonstração (GD_DEMO=1) =================
func _demo_arrastar(de: Vector2, para: Vector2, dur: float = 0.55) -> void:
	efeitos.cursor = de
	await get_tree().create_timer(0.15).timeout
	efeitos.cursor_apertado = true
	pressionar(de)
	await get_tree().create_timer(0.12).timeout
	var n := int(dur * 30)
	for k in n + 1:
		var u := float(k) / n
		var e := u * u * (3.0 - 2.0 * u)
		var pos := de.lerp(para, e) + Vector2(0, -sin(u * PI) * 18)
		efeitos.cursor = pos
		mover(pos)
		await get_tree().process_frame
	await get_tree().create_timer(0.12).timeout
	efeitos.cursor_apertado = false
	await soltar(para)


func _demo_tocar(p: Vector2) -> void:
	for k in 8:
		efeitos.cursor = efeitos.cursor.lerp(p, 0.4)
		await get_tree().process_frame
	efeitos.cursor = p
	efeitos.cursor_apertado = true
	await get_tree().create_timer(0.1).timeout
	pressionar(p)
	efeitos.cursor_apertado = false


func _demo_esperar_escolha() -> void:
	while efeitos.escolha.is_empty():
		await get_tree().process_frame
	await get_tree().create_timer(0.4).timeout


func _demo() -> void:
	await get_tree().create_timer(0.5).timeout
	await _oponente_joga(1, 2, 2)
	await _oponente_joga(2, 1, 3)
	await get_tree().create_timer(0.4).timeout
	var ent_a: Carta = mao_jog[0]
	var ent_b: Carta = mao_jog[1]
	var selo: Carta = mao_jog[2]
	var rito: Carta = mao_jog[3]
	# 1) Entidade A → espaço 2, escolhe CIMA
	_demo_arrastar(ent_a.position, pos_ent(0, 1))
	await _demo_esperar_escolha()
	await _demo_tocar((efeitos.escolha[0]["rect"] as Rect2).get_center())
	await get_tree().create_timer(0.7).timeout
	# 2) Selo → espaço de Selo (cai virado para baixo, sem perguntar)
	await _demo_arrastar(selo.position, pos_selo(0, 0))
	await get_tree().create_timer(0.5).timeout
	# 3) Entidade B solta em lugar errado → sacode e volta
	await _demo_arrastar(ent_b.position, Vector2(180, LINHA_Y + 12))
	await get_tree().create_timer(0.5).timeout
	# 4) Entidade B → espaço 3, escolhe BAIXO
	_demo_arrastar(ent_b.position, pos_ent(0, 2))
	await _demo_esperar_escolha()
	await _demo_tocar((efeitos.escolha[1]["rect"] as Rect2).get_center())
	await get_tree().create_timer(0.7).timeout
	# 5) muda A de lugar (espaço 2 → espaço 1)
	await _demo_arrastar(ent_a.position, pos_ent(0, 0))
	await get_tree().create_timer(0.5).timeout
	# 6) A ataca a Entidade 2/2 do oponente (destrói; A fica 3/2)
	await _demo_arrastar(ent_a.position, pos_ent(1, 1))
	await get_tree().create_timer(0.6).timeout
	# 7) Rito na Entidade 1/3 (3 de dano: destrói)
	await _demo_arrastar(rito.position, pos_ent(1, 2))
	await get_tree().create_timer(0.6).timeout
	# 8) campo inimigo vazio: golpe direto na Cornucópia (15 → 12)
	await _demo_arrastar(ent_a.position, Vector2(180, 150))
	await get_tree().create_timer(0.8).timeout
	efeitos.cursor = Vector2(-100, -100)
	# 9) "mais tarde…": Cornucópia inimiga em 3 → golpe final → VITÓRIA
	efeitos.numero(Vector2(180, LINHA_Y - 40), "MAIS TARDE", Color("#f2e6c8"), 2)
	await get_tree().create_timer(0.9).timeout
	cornucopia[1] = 3
	placar_pulo[1] = 0.6
	await get_tree().create_timer(0.5).timeout
	await _demo_arrastar(ent_a.position, Vector2(180, 150))
	efeitos.cursor = Vector2(-100, -100)
	await get_tree().create_timer(0.6).timeout
	# 10) recomeço rápido para mostrar a DERROTA: oponente golpeia a sua Cornucópia em 2
	efeitos.faixa = ""
	efeitos.particulas.clear()
	cornucopia[0] = 2
	placar_pulo[0] = 0.6
	for i in 4:
		var c = campo_ent[0][i]
		if c != null:
			(c as Carta).visible = false
			campo_ent[0][i] = null
	await get_tree().create_timer(0.4).timeout
	var inimiga := await _oponente_joga(0, 4, 4)
	await get_tree().create_timer(0.3).timeout
	await _golpe_direto(inimiga, 0)


# ================= partida (fase 1: regras sem efeitos de carta) =================
const MAO_MAX := 7
const FE_TETO := 8
const TURNOS_MAX := 80
var estat := [{}, {}]                 # contadores por lado (impressos no fim da partida)


func _conta(d: int, k: String) -> void:
	estat[d][k] = int(estat[d].get(k, 0)) + 1
var zoom_pendente: Carta = null
var zoom_t := 0.0
var zoom_ini := Vector2.ZERO


## Embaralha os ids do deck (Fisher–Yates com o rng da mesa) e dá a cada nó do monte uma carta real.
func _dar_dados(nos: Array[Carta], deck_nome: String, dono: int) -> void:
	_dar_ids(nos, (db["decks"][deck_nome] as Array), dono)


func _dar_ids(nos: Array[Carta], lista: Array, dono: int) -> void:
	var ids: Array = lista.duplicate()
	for i in range(ids.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp = ids[i]
		ids[i] = ids[j]
		ids[j] = tmp
	for i in nos.size():
		var c: Carta = nos[i]
		c.definir(db["cartas"][ids[i % ids.size()]], dono)


func _mao_de(d: int) -> Array[Carta]:
	return mao_jog if d == 0 else mao_opon


func _deck_de(d: int) -> Array[Carta]:
	return deck_jog if d == 0 else deck_opon


func _rearrumar_de(d: int) -> void:
	if d == 0:
		_rearrumar_mao()
	else:
		_rearrumar(mao_opon, _layout_mao_opon, 0.62)


func _espaco_livre(arr: Array) -> int:
	for i in arr.size():
		if arr[i] == null:
			return i
	return -1


func _partida() -> void:
	ativo = 0
	turno_n = 0
	while not acabou:
		turno_n += 1
		if turno_n > TURNOS_MAX:
			print("FIM DA PARTIDA: empate por limite de turnos")
			return
		await _inicio_turno(ativo)
		if acabou:
			break
		if ativo == 0 and not auto_jogador:
			_atualizar_apagadas()
			await fim_turno_pedido
		else:
			await _turno_ia(ativo)
		if acabou:
			break
		_fim_turno(ativo)
		ativo = 1 - ativo
	print("FIM DA PARTIDA: %s no turno %d (Cornucópias %d × %d)" % ["vitória" if cornucopia[1] <= 0 else "derrota", turno_n, cornucopia[0], cornucopia[1]])
	print("ESTAT jogador: ", estat[0], "  oponente: ", estat[1])


## Início do turno: Fé máx +1 (teto 8) e restaura; o 2º jogador ganha +1 Fé temporária no 1º turno dele;
## Entidades acordam; compra 1 (quem começa não compra no 1º turno).
func _inicio_turno(d: int) -> void:
	fe_max[d] = mini(FE_TETO, fe_max[d] + 1)
	fe[d] = fe_max[d]
	if d == 1 and turno_n == 2:
		fe[d] += 1
	selo_no_turno = false
	for i in 4:
		var c = campo_ent[d][i]
		if c != null:
			(c as Carta).cansada = false
			(c as Carta).atacou = false
	_atualizar_apagadas()
	efeitos.numero(Vector2(180, LINHA_Y - 4), "SEU TURNO" if d == 0 else "TURNO DELE", Color("#ffe39a") if d == 0 else Color("#cfe0ff"), 2)
	await get_tree().create_timer(0.6).timeout
	if not (d == 0 and turno_n == 1):
		await _comprar(d)
	_atualizar_apagadas()


func _fim_turno(_d: int) -> void:
	efeitos.destaques.clear()
	_atualizar_apagadas()


## Compra 1. Deck vazio = fadiga (2 de dano na Cornucópia). Mão cheia (7) = a carta comprada queima.
func _comprar(d: int) -> void:
	var deck := _deck_de(d)
	var mao := _mao_de(d)
	if deck.is_empty():
		cornucopia[d] -= 2
		placar_pulo[d] = 1.0
		tremor = 3.0
		efeitos.numero(_pos_placar(d) + Vector2(36, 2), "-2", Color("#ff5050"), 2)
		efeitos.numero(Vector2(180, LINHA_Y + (40 if d == 0 else -40)), "DECK VAZIO", Color("#ffd0a0"), 1)
		await get_tree().create_timer(0.5).timeout
		if cornucopia[d] <= 0:
			acabou = true
			if d == 1:
				await _vitoria()
			else:
				await _derrota()
		return
	var c: Carta = deck.pop_back()
	c.empilhada = false
	c.z_index = 500 + mao.size()
	if mao.size() >= MAO_MAX:
		if not c.virada_para_cima:
			await c.virar(0.2)
		efeitos.numero(c.position + Vector2(0, -40), "MAO CHEIA", Color("#ffd0a0"), 1)
		await get_tree().create_timer(0.3).timeout
		efeitos.estilhacar(c.position, c.cores_estilhaco(), int(Carta.LARG * c.scale.x), int(Carta.ALT * c.scale.y))
		c.queue_free()
		cemiterio[d] += 1
		return
	mao.append(c)
	var t0 := create_tween()
	t0.tween_property(c, "position:y", c.position.y - 10, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t0.parallel().tween_property(c, "levantada", 0.6, 0.12)
	await t0.finished
	if d == 0:
		var lay: Array = _layout_mao(mao.size(), mao.size() - 1)
		_arco(c, lay[0], 0.42, 40, lay[1], 1.0)
		get_tree().create_timer(0.1).timeout.connect(func() -> void: c.virar(0.26))
		var anteriores: Array[Carta] = mao.slice(0, mao.size() - 1)
		for kk in anteriores.size():
			var a: Carta = anteriores[kk]
			var l2: Array = _layout_mao(mao.size(), kk)
			var t := create_tween().set_parallel(true)
			t.tween_property(a, "position", l2[0], 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			t.tween_property(a, "rotation", l2[1], 0.3)
	else:
		var lo: Array = _layout_mao_opon(mao.size(), mao.size() - 1)
		_arco(c, lo[0], 0.42, 20, lo[1], 0.62)
		_rearrumar(mao.slice(0, mao.size() - 1), _layout_mao_opon, 0.62)
	await get_tree().create_timer(0.5).timeout
	_rearrumar_de(d)


# ---------- jogar cartas ----------
## "" = pode jogar; senão um motivo curto (mostrado sobre a carta).
func _motivo_jogar(c: Carta, d: int) -> String:
	if c.custo > fe[d]:
		return "SEM FE"
	if c.tipo == "entidade" and _espaco_livre(campo_ent[d]) < 0:
		return "CAMPO CHEIO"
	if c.tipo == "selo":
		if selo_no_turno:
			return "1 SELO POR TURNO"
		if _espaco_livre(campo_selo[d]) < 0:
			return "SEM ESPACO"
	return ""


func _atualizar_apagadas() -> void:
	for c in mao_jog:
		c.apagada = modo_partida and (ativo != 0 or acabou or _motivo_jogar(c, 0) != "")
		if c.custo > fe[0] or ativo != 0:
			c.apagada = true


func _pagar(d: int, custo: int) -> void:
	fe[d] -= custo
	_atualizar_apagadas()


func _soltar_da_mao_partida(c: Carta, p: Vector2) -> void:
	var motivo := _motivo_jogar(c, 0)
	if motivo != "":
		efeitos.numero(c.position + Vector2(0, -52), motivo, Color("#ffd0a0"), 1)
		await _recusar(c)
		return
	match c.tipo:
		"entidade":
			var i := _espaco_sob(p, func(k: int) -> Vector2: return pos_ent(0, k), 4, campo_ent[0])
			if i < 0:
				await _recusar(c)
				return
			await _jogar_entidade(c, 0, i)
		"selo":
			var i := _espaco_sob(p, func(k: int) -> Vector2: return pos_selo(0, k), 2, campo_selo[0])
			if i < 0:
				await _recusar(c)
				return
			await _jogar_selo(c, 0, i)
		_:
			if p.y > 520:                                       # soltou em cima da própria mão
				await _recusar(c)
				return
			await _jogar_rito(c, 0)


func _jogar_entidade(c: Carta, d: int, i: int) -> void:
	_conta(d, "entidades")
	_pagar(d, c.custo)
	_mao_de(d).erase(c)
	_rearrumar_de(d)
	campo_ent[d][i] = c
	c.apagada = false
	c.atacou = false
	c.cansada = not ("impeto" in c.keywords)
	var dest := pos_ent(d, i)
	if d == 1 or segurando == null and c.position.distance_to(dest) > 60:
		await _arco(c, dest + Vector2(0, -24), 0.35, 20, 0.0, esc_em(dest) * 1.25).finished
	await _cair(c, dest, true)
	if "impeto" in c.keywords:
		efeitos.numero(dest + Vector2(0, -34), "IMPETO", Color("#ffe39a"), 1)


func _jogar_selo(c: Carta, d: int, i: int) -> void:
	_conta(d, "selos")
	_pagar(d, c.custo)
	_mao_de(d).erase(c)
	_rearrumar_de(d)
	campo_selo[d][i] = c
	selo_no_turno = true
	c.apagada = false
	var dest := pos_selo(d, i)
	if d == 1 or c.position.distance_to(dest) > 60:
		await _arco(c, dest + Vector2(0, -24), 0.35, 20, 0.0, esc_em(dest) * 1.25).finished
	await _cair(c, dest, false)


## Rito/Relíquia (fase 1): sobe ao centro, vira, mostra o nome, brilha 3× e se desfaz; o efeito real vem na fase 2.
func _jogar_rito(c: Carta, d: int) -> void:
	_conta(d, "ritos")
	_pagar(d, c.custo)
	_mao_de(d).erase(c)
	_rearrumar_de(d)
	c.apagada = false
	c.z_index = 760
	var p := Vector2(180, LINHA_Y + (40 if d == 0 else -40))
	var t := create_tween().set_parallel(true)
	t.tween_property(c, "position", p, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(c, "rotation", 0.0, 0.3)
	t.tween_property(c, "inclinacao", 0.0, 0.3)
	t.tween_property(c, "scale", Vector2(1.2, 1.2), 0.3)
	t.tween_property(c, "levantada", 1.0, 0.3)
	await t.finished
	if not c.virada_para_cima:
		await c.virar(0.24)
	efeitos.numero(p + Vector2(0, -64), c.nome, Color("#f2e6c8"), 1)
	for k in 3:
		var tb := create_tween()
		tb.tween_property(c, "brilho", 0.6, 0.08)
		tb.tween_property(c, "brilho", 0.0, 0.12)
		await tb.finished
	var cores := [Color("#ffe39a"), Color("#fff4d0"), Color("#e2b85a")] if c.tipo == "reliquia" else [Color("#8ae3a8"), Color("#d8ffe0"), Color("#4aa070")]
	efeitos.estilhacar(c.position, cores, 70, 100)
	tremor = 2.0
	c.queue_free()
	cemiterio[d] += 1
	await get_tree().create_timer(0.3).timeout


# ---------- regras de ataque ----------
## "" = pode; senão o motivo. alvo == null → golpe direto na Cornucópia.
func _pode_atacar(c: Carta, alvo: Carta) -> String:
	if not modo_partida:
		return ""
	if not c.virada_para_cima:
		return "VIRADA"
	if c.cansada:
		return "CANSADA"
	if c.atacou:
		return "JA ATACOU"
	var inimigo := 1 - c.dono
	if alvo == null:
		return "" if _campo_vazio(inimigo) else "HA DEFENSORES"
	var guardas: Array = []
	for i in 4:
		var e = campo_ent[inimigo][i]
		if e != null and (e as Carta).virada_para_cima and "guarda" in (e as Carta).keywords:
			guardas.append(e)
	if not guardas.is_empty() and not (alvo in guardas):
		return "GUARDA"
	return ""


## Renascer: em vez de ir ao cemitério, volta para a mão do dono (uma vez — perde a palavra-chave).
func _renascer(c: Carta) -> void:
	c.keywords.erase("renascer")
	_piscar(c)
	efeitos.faiscas(c.position, 16, Color("#ffe39a"))
	efeitos.numero(c.position + Vector2(0, -34), "RENASCER", Color("#ffe39a"), 1)
	c.dano = 0
	c.cansada = false
	c.atacou = false
	await get_tree().create_timer(0.35).timeout
	var mao := _mao_de(c.dono)
	if mao.size() >= MAO_MAX:
		efeitos.estilhacar(c.position, c.cores_estilhaco(), 50, 70)
		c.queue_free()
		cemiterio[c.dono] += 1
		return
	mao.append(c)
	c.z_index = 500 + mao.size()
	if c.dono == 1 and c.virada_para_cima:
		c.virar(0.24)
	_rearrumar_de(c.dono)
	_atualizar_apagadas()
	await get_tree().create_timer(0.35).timeout


# ---------- segurar para ver a carta ----------
func _tentar_zoom(p: Vector2) -> void:
	var cands: Array = []
	for c in mao_jog:
		cands.append(c)
	for d in 2:
		for i in 4:
			if campo_ent[d][i] != null:
				cands.append(campo_ent[d][i])
	for i in 2:
		if campo_selo[0][i] != null:
			cands.append(campo_selo[0][i])
	for i in range(cands.size() - 1, -1, -1):
		var c: Carta = cands[i]
		if is_instance_valid(c) and c.contem(p) and (c.virada_para_cima or c.dono == 0):
			zoom_pendente = c
			zoom_t = 0.0
			zoom_ini = p
			return


func _atualizar_zoom(delta: float) -> void:
	if segurando != null:
		segurando_t += delta
		if segurando_t > 0.4 and ponteiro.distance_to(segurando_ini) < 5.0:
			efeitos.zoom = segurando
		elif ponteiro.distance_to(segurando_ini) >= 5.0:
			efeitos.zoom = null
	elif zoom_pendente != null:
		zoom_t += delta
		if not is_instance_valid(zoom_pendente) or ponteiro.distance_to(zoom_ini) >= 5.0:
			zoom_pendente = null
			efeitos.zoom = null
		elif zoom_t > 0.4:
			efeitos.zoom = zoom_pendente


# ---------- IA (oponente; e o jogador com GD_AUTO=1) ----------
func _turno_ia(d: int) -> void:
	ocupado = true
	await get_tree().create_timer(0.4).timeout
	# 1) joga da mais cara que cabe, até não caber mais nada
	var jogou := true
	while jogou and not acabou:
		jogou = false
		var ordem: Array = _mao_de(d).duplicate()
		ordem.sort_custom(func(a: Carta, b: Carta) -> bool: return a.custo > b.custo)
		for c in ordem:
			var carta: Carta = c
			if _motivo_jogar(carta, d) != "":
				continue
			if d == 1 and (carta.lendaria or carta.custo >= 5):
				_provocar(0)
			if carta.tipo == "entidade":
				await _jogar_entidade(carta, d, _espaco_livre(campo_ent[d]))
			elif carta.tipo == "selo":
				await _jogar_selo(carta, d, _espaco_livre(campo_selo[d]))
			else:
				await _jogar_rito(carta, d)
			jogou = true
			await get_tree().create_timer(0.35).timeout
			break
	# 2) ataques
	for i in 4:
		if acabou:
			break
		var c = campo_ent[d][i]
		if c == null:
			continue
		var plano := _ia_plano_ataque(c)
		_conta(d, "plano_" + str(plano["acao"]))
		if plano["acao"] == "direto":
			if d == 1:
				_provocar(1)
			await _golpe_direto(c, 1 - d)
			await get_tree().create_timer(0.35).timeout
		elif plano["acao"] == "carta":
			await _atacar(c, plano["alvo"])
			await get_tree().create_timer(0.35).timeout
	await get_tree().create_timer(0.3).timeout
	ocupado = false


## Mata-e-sobrevive > troca (alvo custa ≥) > direto (campo vazio); respeita Guarda e cansaço via _pode_atacar.
func _ia_plano_ataque(c: Carta) -> Dictionary:
	if _pode_atacar(c, null) == "":
		return {"acao": "direto"}
	var inimigo := 1 - c.dono
	var melhor: Carta = null
	var nota := -999.0
	for i in 4:
		var e = campo_ent[inimigo][i]
		if e == null or _pode_atacar(c, e) != "":
			continue
		var alvo: Carta = e
		var mata := alvo.vida() <= c.atk
		var sobrevive := c.vida() > alvo.atk
		var n := -999.0
		if mata and sobrevive:
			n = 100.0 + alvo.atk * 3 + alvo.custo
		elif mata and alvo.custo >= c.custo:
			n = 50.0 + alvo.custo - c.custo
		elif sobrevive and c.atk > 0:
			n = 10.0 + c.atk                                  # castiga sem perder a carta
		if n > nota:
			nota = n
			melhor = alvo
	if melhor != null:
		return {"acao": "carta", "alvo": melhor}
	return {"acao": "nada"}


var _ultima_provocacao := -100.0


## Fala curta do oponente (lore.json → provocacoes[i]): 0 = carta forte, 1 = golpe na Cornucópia, 2 = perdeu carta.
## No máximo uma a cada 6 s, para não virar ruído.
func _provocar(i: int) -> void:
	if Sessao.modo == "" or tempo - _ultima_provocacao < 6.0:
		return
	var p: Dictionary = Sessao.personagem(Sessao.oponente)
	var lista: Array = p.get("provocacoes", [])
	if i >= lista.size():
		return
	_ultima_provocacao = tempo
	efeitos.falar(p.get("nome", ""), lista[i], Color(p.get("cor", "#e2b85a")), Sessao.oponente)
