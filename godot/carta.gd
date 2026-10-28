class_name Carta
extends Node2D
## Carta de exemplo em pixel art (render nativo 360×640). Face 64×90 (5:7) + 2 px de espessura em cor de papel.
## A sombra aponta para longe da luz principal (passada pela mesa em `luz`).

const LARG := 64
const ALT := 90
const ESPESSURA := 2

# paleta
const PAPEL := Color("#e8dcc0")        # borda lateral (grossura da carta) — nunca preta
const PAPEL_ESC := Color("#b9a582")
const VERSO_FUNDO := Color("#2a2040")
const VERSO_MEIO := Color("#3b2d5e")
const OURO := Color("#e2b85a")
const OURO_ESC := Color("#9c7430")
const CONTORNO := Color("#3a2a24")     # contorno marrom escuro, não preto puro

var virada_para_cima := false
var levantada := 0.0                    # 0..1: altura da carta (sombra maior e mais longe)
var luz := Vector2(180, -60)            # posição global da luz principal
var empilhada := false                  # no monte: só a borda conta, sem sombra própria
var giro := 1.0                         # 1 → 0 → 1 ao virar (independente da escala, que pode estar animando)
var inclinacao := 0.0                   # cisalhamento ao arrastar (simula a carta tombando na direção do movimento)
var brilho := 0.0                       # 0..1: clarão branco por cima (golpe, destruição)
var bob := Vector2.ZERO                 # deslocamento leve de animação ociosa (respirar/flutuar), em px
var tipo := "entidade"                  # entidade | selo | rito
var atk := 0
var defe := 0
var dano := 0
var dono := 0                           # 0 = jogador, 1 = oponente
var id := ""
var nome := ""
var _nome_cache_de := ""
var _nome_cache := PackedStringArray()
var custo := 0
var keywords: Array = []
var texto := ""
var cultura := ""
var lendaria := false
var cansada := false                    # entrou neste turno (sem Ímpeto): não ataca
var atacou := false
var apagada := false                    # na mão, sem Fé para jogar
# ---- estado de regras (motor_efeitos.gd) ----
var dados: Dictionary = {}              # ficha da carta (cartas.json) ou do token
var dono_real := 0                      # dono original (mão/cemitério); `dono` = quem controla (lado do campo)
var atk_base := 0
var vida_base := 0
var buff_atk := 0
var buff_vida := 0
var temp_atk := 0
var temp_vida := 0
var aura_atk := 0
var aura_vida := 0
var rel_atk := 0
var rel_vida := 0
var aura_keywords: Array = []
var efeitos: Array = []
var silenciada := false
var congelada := false                  # não atacará no próximo turno do controlador
var sem_ataque := false                 # congelada neste turno
var ja_atacou := false                  # já atacou alguma vez (Furtivo some)
var destaque := 0                       # 1 = dá para jogar (mão, dourado) · 2 = pronta para atacar (campo, laranja)
var aura_arcoiris := false              # fortalecida em campo: brilho arco-íris no chão, por baixo da carta
var _t_aura := 0.0
var reliquia: Dictionary = {}           # {dados, nome, usos, portadora, dono}
var token := false
var em_campo := false
var roubada_temp := false
var turno_posto := -1                   # Selo: turno em que foi posto
var sem_renascer := false


# ---- marcas visuais de efeito (0,6 s por cima da carta) e pulso dos números quando mudam ----
const DUR_MARCA := {"buff": 0.7, "debuff": 0.7, "cura": 0.7, "dano": 0.4, "gelo": 0.6, "mudo": 0.6, "reliquia": 0.8}
var _marcas: Array[Dictionary] = []      # {tipo, t}
var _atk_visto := -999
var _def_visto := -999
var _pulso_atk := 0.0                    # 1 → 0 em 0,35 s quando o ATK mostrado muda
var _pulso_def := 0.0
var rachadura := 0.0                     # 0..1: rachaduras crescendo do centro (antes de estilhaçar)
var _m := Transform2D.IDENTITY           # transformação corrente da face (giro, inclinação, bob)
const NOME_LARG := 39.0                 # largura útil do nome na pílula (x0+19 … x0+58, pílula até x0+61)
const RAIO := 3.0                        # cantos arredondados da carta (px do layout)

var _fx: Node2D                          # camada sem luz da mesa (cores fiéis): efeito de Guarda
const SHADER_PLANO := preload("res://perspectiva_carta.gdshader")
const SHADER_PLANO_FX := preload("res://perspectiva_carta_fx.gdshader")
static var PERSP := [0.0, 1.0, 0.85]   # [K, A, escorço] da mesa (mesa.gd define antes de criar as cartas)
var plano_alvo := 0.0                    # 1 = deitada na mesa (campo, Selos, deck): a mesa decide a cada quadro
var plano := 0.0
var _mat_plano: ShaderMaterial
var _mat_fx: ShaderMaterial


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_mat_plano = ShaderMaterial.new()
	_mat_plano.shader = SHADER_PLANO
	material = _mat_plano
	_mat_fx = ShaderMaterial.new()
	_mat_fx.shader = SHADER_PLANO_FX
	for m in [_mat_plano, _mat_fx]:
		m.set_shader_parameter("k", PERSP[0])
		m.set_shader_parameter("a", PERSP[1])
		m.set_shader_parameter("escorco", PERSP[2])
	_fx = Node2D.new()
	_fx.material = _mat_fx
	_fx.draw.connect(_desenhar_fx)
	add_child(_fx)


## Efeito recebido (buff, debuff, cura, dano, gelo, mudo, relíquia): brilho que varre a carta e contorno na cor.
func marcar(tipo: String) -> void:
	_marcas.append({"tipo": tipo, "t": 0.0})


func _process(d: float) -> void:
	for mk in _marcas:
		mk["t"] += d
	_marcas = _marcas.filter(func(mk: Dictionary) -> bool: return mk["t"] < DUR_MARCA.get(mk["tipo"], 0.6))
	_pulso_atk = maxf(0.0, _pulso_atk - d / 0.35)
	_pulso_def = maxf(0.0, _pulso_def - d / 0.35)
	if virada_para_cima and tipo == "entidade":
		var v := maxi(defe - dano, 0)
		if _atk_visto != -999 and atk != _atk_visto:
			_pulso_atk = 1.0
		if _def_visto != -999 and v != _def_visto:
			_pulso_def = 1.0
		_atk_visto = atk
		_def_visto = v
	var alvo := plano_alvo * (1.0 - clampf(levantada * 1.5, 0.0, 1.0))
	if absf(plano - alvo) > 0.001:
		plano = move_toward(plano, alvo, d * 5.0)        # deita/levanta em 0,2 s
		_mat_plano.set_shader_parameter("plano", plano)
		_mat_fx.set_shader_parameter("plano", plano)
	queue_redraw()
	if _fx:
		_fx.queue_redraw()


func _desenhar_fx() -> void:
	if em_campo and virada_para_cima and tipo == "entidade" and tem("guarda"):
		_fx.draw_set_transform_matrix(Transform2D(0.0, Vector2(maxf(absf(giro), 0.02), 1.0), inclinacao, bob))
		_guarda(-LARG / 2, -ALT / 2)


func _draw() -> void:
	var x0 := -LARG / 2
	var y0 := -ALT / 2
	if not empilhada:
		_sombra(x0, y0)
	if aura_arcoiris:
		_aura(x0, y0)
	_m = Transform2D(0.0, Vector2(maxf(absf(giro), 0.02), 1.0), inclinacao, bob)
	draw_set_transform_matrix(_m)
	var face := Rect2(x0, y0, LARG, ALT)
	# espessura: faixa de papel aparecendo embaixo e à direita (luz vem de cima), com os cantos acompanhando o raio
	rr(self, Rect2(x0 + 1, y0 + 2, LARG, ALT + ESPESSURA - 1), RAIO, PAPEL_ESC)
	rr(self, Rect2(x0, y0 + 1, LARG, ALT + ESPESSURA - 1), RAIO, PAPEL)
	if virada_para_cima:
		_frente(x0, y0)
	else:
		_verso(x0, y0)
	if destaque > 0:
		var tt := Time.get_ticks_msec() / 1000.0
		var pulso := 0.55 + 0.45 * sin(tt * TAU / 1.1)
		# modo daltônico: "pronta para atacar" vira azul-ciano (dourado × laranja se confundem) e os dois ganham ícone
		var cor := Color(1.0, 0.85, 0.4) if destaque == 1 else (Color(0.3, 0.78, 1.0) if Sessao.daltonico else Color(1.0, 0.5, 0.2))
		var r := Rect2(x0, y0, LARG, ALT + ESPESSURA)
		rr_linha(self, r.grow(1), RAIO + 1, Color(cor.lightened(0.3), 0.6 + 0.4 * pulso), 1.6)
		rr_linha(self, r.grow(3), RAIO + 3, Color(cor, 0.55 * pulso), 2.0)
		rr_linha(self, r.grow(5.5), RAIO + 5.5, Color(cor, 0.22 * pulso), 2.5)
		if Sessao.daltonico:
			var ic := Vector2(x0 + LARG - 7, y0 - 6)
			draw_circle(ic, 6.0, Color("#140c10"))
			draw_circle(ic, 5.0, cor)
			if destaque == 1:                       # seta para cima: dá para jogar
				draw_colored_polygon(PackedVector2Array([ic + Vector2(0, -3), ic + Vector2(3, 1), ic + Vector2(-3, 1)]), Color("#140c10"))
				draw_rect(Rect2(ic + Vector2(-1, 1), Vector2(2, 2)), Color("#140c10"))
			else:                                   # espada: pode atacar
				draw_line(ic + Vector2(-3, 3), ic + Vector2(3, -3), Color("#140c10"), 1.5)
				draw_line(ic + Vector2(-3, -1), ic + Vector2(-1, 1), Color("#140c10"), 1.0)
	var dormindo := cansada and not tem("impeto")
	if virada_para_cima and (dormindo or atacou) and levantada < 0.05:     # no ar (atacando) fica acesa
		rr(self, face, RAIO, Color(0.05, 0.03, 0.1, 0.35))
		if dormindo:                                # dois "Z" subindo e sumindo em ciclo de 1,6 s
			var tz := Time.get_ticks_msec() / 1000.0
			for k in 2:
				var u := fmod(tz / 1.6 + k * 0.5, 1.0)
				var al := sin(u * PI)
				PixelFonte.desenhar(self, Vector2(x0 + LARG - 16 + 5 * u + 3 * k, y0 + 22 - 10 * u), "Z", Color(0.81, 0.88, 1.0, al), 1, Color(0.08, 0.06, 0.14, al))
	if virada_para_cima and em_campo:
		if congelada or sem_ataque:
			_gelo(x0, y0)
		if silenciada:
			_mudo(x0, y0)
	if not reliquia.is_empty():
		_faixa_reliquia(x0, y0)
	if apagada:
		rr(self, face, RAIO, Color(0.05, 0.03, 0.08, 0.5))
	for mk in _marcas:
		_desenhar_marca(x0, y0, mk)
	if rachadura > 0.0:
		_rachar(x0, y0)
	if brilho > 0.0:
		rr(self, face, RAIO, Color(1, 1, 1, brilho))


# ---------- formas arredondadas (nítidas na resolução real) ----------
static func pontos_rr(r: Rect2, raio: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	raio = minf(raio, minf(r.size.x, r.size.y) / 2.0)
	var cantos := [Vector2(r.end.x - raio, r.position.y + raio), Vector2(r.end.x - raio, r.end.y - raio),
		Vector2(r.position.x + raio, r.end.y - raio), Vector2(r.position.x + raio, r.position.y + raio)]
	for i in 4:
		var a0 := -PI / 2.0 + i * PI / 2.0
		for k in 5:
			pts.append(cantos[i] + Vector2.from_angle(a0 + k * PI / 8.0) * raio)
	return pts


static func rr(ci: CanvasItem, r: Rect2, raio: float, cor: Color) -> void:
	if raio <= 0.0:
		ci.draw_rect(r, cor)
	else:
		ci.draw_colored_polygon(pontos_rr(r, raio), cor)


static func rr_linha(ci: CanvasItem, r: Rect2, raio: float, cor: Color, larg := 1.0) -> void:
	var p := pontos_rr(r, raio)
	p.append(p[0])
	ci.draw_polyline(p, cor, larg, true)


## Marca de efeito: varredura de luz (sobe no que fortalece, desce no que enfraquece) + contorno na cor + véu.
func _desenhar_marca(x0: int, y0: int, mk: Dictionary) -> void:
	var tp: String = mk["tipo"]
	var u: float = mk["t"] / DUR_MARCA.get(tp, 0.6)
	var cor: Color = {"buff": Color("#ffe39a"), "debuff": Color("#c88aff"), "cura": Color("#8ae38a"), "dano": Color("#ff5a4a"),
		"gelo": Color("#bfe6ff"), "mudo": Color("#b8b4c0"), "reliquia": Color("#ffd27a")}.get(tp, Color.WHITE)
	var face := Rect2(x0, y0, LARG, ALT)
	var al := sin(clampf(u, 0.0, 1.0) * PI)
	rr(self, face, RAIO, Color(cor, 0.22 * al if tp != "dano" else 0.45 * (1.0 - u)))
	rr_linha(self, face.grow(1.5), RAIO + 1.5, Color(cor, 0.9 * al), 2.0)
	rr_linha(self, face.grow(4.0), RAIO + 4.0, Color(cor, 0.35 * al), 2.5)
	if tp in ["buff", "cura", "reliquia", "debuff", "mudo"]:
		var sobe := tp != "debuff" and tp != "mudo"
		var yc := lerpf(y0 + ALT + 10, y0 - 10, u) if sobe else lerpf(y0 - 10, y0 + ALT + 10, u)
		for k in 3:                                 # faixa de 18 px em 3 degraus de alfa
			var h := 18.0 - k * 6.0
			var faixa := Rect2(x0, yc - h / 2.0, LARG, h).intersection(face)
			if faixa.size.y > 0:
				draw_rect(faixa, Color(cor.lightened(0.5), 0.16 + 0.12 * k))
		if tp == "buff" or tp == "reliquia":       # 3 setas subindo
			for k in 3:
				var cx := x0 + 14 + k * 18
				var cy := y0 + ALT - 14 - u * 40.0 - (k % 2) * 6
				var a := al * 0.9
				draw_polyline(PackedVector2Array([Vector2(cx - 4, cy + 3), Vector2(cx, cy - 1), Vector2(cx + 4, cy + 3)]), Color(cor.lightened(0.4), a), 2.0, true)
		elif tp == "cura":                          # cruzes verdes subindo
			for k in 3:
				var c := Vector2(x0 + 14 + k * 18, y0 + ALT - 14 - u * 40.0 - (k % 2) * 6)
				draw_rect(Rect2(c - Vector2(1, 4), Vector2(2.2, 8)), Color(cor.lightened(0.4), al))
				draw_rect(Rect2(c - Vector2(4, 1), Vector2(8, 2.2)), Color(cor.lightened(0.4), al))


## 6 rachaduras em zigue-zague saindo de um ponto perto do centro (sorteio fixo pelo id), com brilho por dentro.
func _rachar(x0: int, y0: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(id + str(dono))
	var c := Vector2(x0 + LARG / 2.0 + rng.randf_range(-6, 6), y0 + ALT / 2.0 + rng.randf_range(-8, 8))
	var face := Rect2(x0 + 1, y0 + 1, LARG - 2, ALT - 2)
	for k in 6:
		var a := TAU * k / 6.0 + rng.randf_range(-0.3, 0.3)
		var pts := PackedVector2Array([c])
		var p := c
		var comp := rng.randf_range(30, 52) * rachadura
		var passos := 5
		for i in passos:
			var dirk := Vector2.from_angle(a + rng.randf_range(-0.5, 0.5))
			p = p + dirk * comp / passos
			p = Vector2(clampf(p.x, face.position.x, face.end.x), clampf(p.y, face.position.y, face.end.y))
			pts.append(p)
		draw_polyline(pts, Color(0.06, 0.03, 0.05, 0.9), 1.6, true)
		draw_polyline(pts, Color(1.0, 0.92, 0.75, 0.8), 0.6, true)


## Congelada: véu azul, borda de gelo e cristais crescendo dos 4 cantos; um brilho percorre os cristais a cada 1,5 s.
func _gelo(x0: int, y0: int) -> void:
	var face := Rect2(x0, y0, LARG, ALT)
	rr(self, face, RAIO, Color(0.55, 0.8, 1.0, 0.24))
	rr_linha(self, face.grow(-0.5), RAIO, Color("#d8f0ff"), 1.4)
	var tt := Time.get_ticks_msec() / 1000.0
	var cantos := [Vector2(x0, y0), Vector2(x0 + LARG, y0), Vector2(x0, y0 + ALT), Vector2(x0 + LARG, y0 + ALT)]
	for i in 4:
		var c: Vector2 = cantos[i]
		var sx := 1.0 if i % 2 == 0 else -1.0
		var sy := 1.0 if i < 2 else -1.0
		for k in 3:                              # 3 lascas por canto: 12, 9 e 7 px
			var comp: float = [12.0, 9.0, 7.0][k]
			var ang: float = [0.78, 0.25, 1.3][k]
			var d := Vector2(cos(ang) * sx, sin(ang) * sy)
			var n := Vector2(-d.y, d.x) * 2.2
			var poly := PackedVector2Array([c + n, c + d * comp, c - n])
			draw_colored_polygon(poly, Color(0.86, 0.95, 1.0, 0.85))
			draw_polyline(PackedVector2Array([c + n, c + d * comp, c - n]), Color("#6fa8d8"), 0.8, true)
		var brilho_k := fmod(tt / 1.5 + i * 0.25, 1.0)
		if brilho_k < 0.15:
			var sp := c + Vector2(6 * sx, 6 * sy)
			var a := sin(brilho_k / 0.15 * PI)
			draw_line(sp - Vector2(3, 0), sp + Vector2(3, 0), Color(1, 1, 1, a), 1.0)
			draw_line(sp - Vector2(0, 3), sp + Vector2(0, 3), Color(1, 1, 1, a), 1.0)


## Silenciada: arte acinzentada e uma faixa com cadeado e "MUDO" atravessando a carta.
func _mudo(x0: int, y0: int) -> void:
	draw_rect(Rect2(x0 + 8, y0 + 13, 48, 64), Color(0.42, 0.4, 0.46, 0.55))
	var r := Rect2(x0 + 4, y0 + 39, LARG - 8, 12)
	rr(self, r.grow(1), 3.0, Color("#140c10"))
	rr(self, r, 2.5, Color("#3a3640"))
	draw_rect(Rect2(r.position.x + 2, r.position.y + 1, r.size.x - 4, 1), Color("#5a5662"))
	var cad := Vector2(r.position.x + 8, r.get_center().y)        # cadeado: arco 3 px + corpo 7×5
	draw_arc(cad + Vector2(0, -1), 2.4, PI, TAU, 8, Color("#d8d4e0"), 1.2, true)
	draw_rect(Rect2(cad + Vector2(-3.5, -1), Vector2(7, 5)), Color("#d8d4e0"))
	draw_rect(Rect2(cad + Vector2(-0.5, 0.5), Vector2(1, 2)), Color("#3a3640"))
	var txt := PixelFonte.cortar(Sessao.t("MUDO"), r.size.x - 20)
	PixelFonte.centrado(self, Vector2(r.position.x + 14 + (r.size.x - 16) / 2.0, r.get_center().y), txt, Color("#e2dee8"))


func _sombra(x0: int, y0: int) -> void:
	var dir := (global_position - luz).normalized()
	var dist := 2.0 + 9.0 * levantada
	var off := (dir * dist).rotated(-global_rotation) / maxf(absf(global_scale.y), 0.01)
	var a := 0.32 - 0.12 * levantada
	var sr := Rect2(Vector2(x0, y0) + off + Vector2(-1, 0), Vector2(LARG + 2, ALT + ESPESSURA + 1))
	rr(self, sr.grow(1.5), RAIO + 1.5, Color(0.05, 0.02, 0.06, a * 0.45))       # penumbra
	rr(self, sr, RAIO, Color(0.05, 0.02, 0.06, a))


func _moldura(x0: int, y0: int, fundo: Color) -> void:
	rr(self, Rect2(x0, y0, LARG, ALT), RAIO, CONTORNO)
	rr(self, Rect2(x0 + 1, y0 + 1, LARG - 2, ALT - 2), RAIO - 1, fundo)
	# chanfro: luz no topo e à esquerda, sombra embaixo e à direita (0,8 px)
	draw_line(Vector2(x0 + RAIO, y0 + 1.6), Vector2(x0 + LARG - RAIO, y0 + 1.6), fundo.lightened(0.35), 0.9)
	draw_line(Vector2(x0 + 1.6, y0 + RAIO), Vector2(x0 + 1.6, y0 + ALT - RAIO), fundo.lightened(0.18), 0.8)
	draw_line(Vector2(x0 + RAIO, y0 + ALT - 1.6), Vector2(x0 + LARG - RAIO, y0 + ALT - 1.6), fundo.darkened(0.35), 0.9)
	draw_line(Vector2(x0 + LARG - 1.6, y0 + RAIO), Vector2(x0 + LARG - 1.6, y0 + ALT - RAIO), fundo.darkened(0.25), 0.8)


func _verso(x0: int, y0: int) -> void:
	# verso equipado na loja de cosméticos (só nas cartas do jogador; efeitos animados fora das cartas empilhadas)
	if dono_real == 0 and Cosmeticos.desenhar(self, Sessao.verso_equipado(), Rect2(x0, y0, LARG, ALT), not empilhada):
		return
	_moldura(x0, y0, VERSO_FUNDO)
	# filete dourado com cantos recortados
	draw_rect(Rect2(x0 + 4, y0 + 3, LARG - 8, 1), OURO)
	draw_rect(Rect2(x0 + 4, y0 + ALT - 4, LARG - 8, 1), OURO_ESC)
	draw_rect(Rect2(x0 + 3, y0 + 4, 1, ALT - 8), OURO)
	draw_rect(Rect2(x0 + LARG - 4, y0 + 4, 1, ALT - 8), OURO_ESC)
	# padrão de losangos pequenos
	for yy in range(y0 + 8, y0 + ALT - 8, 6):
		for xx in range(x0 + 8 + (3 if ((yy - y0) / 6) % 2 else 0), x0 + LARG - 8, 6):
			draw_rect(Rect2(xx, yy, 1, 1), VERSO_MEIO)
	# losango central
	var cx := x0 + LARG / 2
	var cy := y0 + ALT / 2
	for i in range(-14, 15):
		var w := 9 - absi(i) * 9 / 14
		draw_rect(Rect2(cx - w, cy + i, w * 2 + 1, 1), VERSO_MEIO)
		draw_rect(Rect2(cx - w, cy + i, 1, 1), OURO)
		draw_rect(Rect2(cx + w, cy + i, 1, 1), OURO_ESC)
	draw_rect(Rect2(cx - 2, cy - 2, 5, 5), OURO)
	draw_rect(Rect2(cx - 1, cy - 1, 3, 3), VERSO_FUNDO)
	draw_rect(Rect2(cx, cy, 1, 1), Color("#fff2c8"))


const COR_CULTURA := {"indigena": Color("#9a4a26"), "cristianismo": Color("#36508c"), "taoismo": Color("#1f6a5a"),
	"hinduismo": Color("#b8661c"), "bruxaria": Color("#4e2c6c"), "alta_magia": Color("#2a2430"), "abismo": Color("#3a2a18")}
static var _texturas: Dictionary = {}


## Textura do jogo (assets/arte: 48×64 na mesa; assets/carta: carta inteira no zoom). Carrega uma vez só.
static func textura(pasta: String, cid: String, ext: String) -> Texture2D:
	var k := pasta + cid
	if not _texturas.has(k):
		var caminho := "res://assets/%s/%s.%s" % [pasta, cid, ext]
		_texturas[k] = load(caminho) if ResourceLoader.exists(caminho) else null
	return _texturas[k]


func _frente(x0: int, y0: int) -> void:
	var base: Color = COR_CULTURA.get(cultura, Color("#a9a7ad"))
	_moldura(x0, y0, base)
	var janela := Rect2(x0 + 8, y0 + 13, 48, 64)                                        # janela da arte, 3:4 exato
	draw_rect(janela.grow(1.4), Color("#140c10"))
	var tex := textura("arte_hd", id, "webp") if id != "" else null      # arte 240×320: nítida na tela real
	if tex == null and id != "":
		tex = textura("arte", id, "png")
	if tex:
		draw_texture_rect(tex, janela, false)
	else:
		draw_rect(janela, Color("#6f6d76"))
	draw_rect(janela.grow(0.9), Color(OURO_ESC if not lendaria else OURO, 0.9), false, 0.7)    # filete fino em volta da arte
	draw_rect(Rect2(janela.position, Vector2(janela.size.x, 3)), Color(0, 0, 0, 0.18))          # sombra da pílula na arte
	var linhas := _linhas_nome()                                                         # pílula do nome: 1 ou 2 linhas
	var pil := Rect2(x0 + 12, y0 + 2, LARG - 15, 3 + 7 * linhas.size())   # 1,4 px de folga acima dos acentos
	rr(self, pil.grow(0.8), 3.0, Color("#140c10"))
	rr(self, pil, 2.6, Color("#e4dfd2"))
	draw_line(Vector2(pil.position.x + 2.5, pil.position.y + 0.7), Vector2(pil.end.x - 2.5, pil.position.y + 0.7), Color("#fbf8ef"), 0.8)
	for k in linhas.size():                     # nome longo: aperta na horizontal (78%, ou 65% em 3+ palavras) em vez de cortar
		var w := PixelFonte.largura(linhas[k])
		var sx := minf(1.0, NOME_LARG / maxf(w, 1.0))
		var pn := Vector2(x0 + 19, y0 + 4.6 + 7 * k)
		if sx < 1.0:
			draw_set_transform_matrix(_m * Transform2D(0.0, Vector2(sx, 1.0), 0.0, Vector2(pn.x * (1.0 - sx), 0.0)))
		PixelFonte.desenhar(self, pn, linhas[k], Color("#2a2028"))
		if sx < 1.0:
			draw_set_transform_matrix(_m)
	_medalha(Vector2(x0 + 7, y0 + 8), str(custo), Color("#2f4f9a"), Color.WHITE, "gema")             # custo
	if lendaria:
		draw_line(Vector2(x0 + RAIO + 1, y0 + 1.2), Vector2(x0 + LARG - RAIO - 1, y0 + 1.2), Color("#ffe39a"), 1.0)
		draw_line(Vector2(x0 + RAIO + 1, y0 + ALT - 1.2), Vector2(x0 + LARG - RAIO - 1, y0 + ALT - 1.2), Color("#ffe39a"), 1.0)
	if tem("guarda"):
		rr_linha(self, Rect2(x0, y0, LARG, ALT).grow(-0.5), RAIO, Color("#e2b85a"), 2.0)
	var kw := ""
	for k in keywords + aura_keywords.filter(func(k2: String) -> bool: return not (k2 in keywords)):
		kw += ({"guarda": "G", "impeto": "R", "furtivo": "S", "renascer": "B"} if Sessao.idioma == "en" else {"guarda": "G", "impeto": "I", "furtivo": "F", "renascer": "R"}).get(k, "")
	if kw != "":
		var rk := Rect2(x0 + 18, y0 + 69, PixelFonte.largura(kw) + 5, 8)
		rr(self, rk.grow(0.8), 2.4, Color("#140c10"))
		rr(self, rk, 2.0, Color("#2a2028"))
		PixelFonte.desenhar(self, rk.position + Vector2(2.5, 2), kw, Color("#ffe39a"))
	match tipo:
		"entidade":
			var base_atk: int = int(dados["atk"]) if dados.get("atk") != null else atk
			var base_def: int = int(dados["vida"]) if dados.get("vida") != null else defe
			var cor_atk := Color("#ffe39a") if atk > base_atk else (Color("#e0a8ff") if atk < base_atk else Color("#fff0d8"))
			var anel_atk := Color("#ffd04a") if atk > base_atk else (Color("#b070ff") if atk < base_atk else Color(0, 0, 0, 0))
			_medalha(Vector2(x0 + 8, y0 + ALT - 8), str(atk), Color("#8a2a1a"), cor_atk, "espada", anel_atk, _pulso_atk)
			var cor_def := Color("#ffb0b0") if dano > 0 else (Color("#ffe39a") if defe > base_def else (Color("#e0a8ff") if defe < base_def else Color("#e8f0ff")))
			var anel_def := Color("#ff6a5a") if dano > 0 else (Color("#ffd04a") if defe > base_def else (Color("#b070ff") if defe < base_def else Color(0, 0, 0, 0)))
			_medalha(Vector2(x0 + LARG - 8, y0 + ALT - 8), str(maxi(defe - dano, 0)), Color("#1f3f7a"), cor_def, "escudo", anel_def, _pulso_def)
		"selo":
			_rodape(x0, y0, Sessao.t("SELO"), Color("#c8b0f0"))
		"rito":
			_rodape(x0, y0, Sessao.t("RITO"), Color("#a8e0b8"))
		"reliquia":
			_rodape(x0, y0, Sessao.t("RELÍQUIA"), Color("#ffe39a"))


## Rótulo de tipo no rodapé (abaixo da arte, dentro da moldura).
func _rodape(x0: int, y0: int, txt: String, cor: Color) -> void:
	var t := PixelFonte.cortar(txt, LARG - 12)
	PixelFonte.centrado(self, Vector2(x0 + LARG / 2, y0 + ALT - 7), t, cor, 1, Color(0.08, 0.04, 0.06, 0.9))


## Nome da carta na pílula (12 letras de 4 px por linha): o nome curto (antes da vírgula: "Tupã, o Trovão" → "TUPÃ");
## se não couber em 1 linha, quebra por palavra em 2; só corta o que passar disso.
func _linhas_nome() -> PackedStringArray:
	if nome == "":
		return PackedStringArray()
	if _nome_cache_de == nome:
		return _nome_cache
	var n := PixelFonte.normalizar(nome.get_slice(",", 0).strip_edges())
	# quebra pela largura real (39 px); se der mais de 2 linhas, quebra de novo aceitando aperto de até 78%
	var linhas := _quebrar_nome(n, NOME_LARG)
	if linhas.size() > 2:
		linhas = _quebrar_nome(n, NOME_LARG / 0.78)
	if linhas.size() > 2:                       # ainda 3+: divide as palavras em 2 linhas equilibradas (aperto até 65%)
		var pal := n.split(" ", false)
		var melhor := PackedStringArray()
		var menor := INF
		for k in range(1, pal.size()):
			var a := " ".join(pal.slice(0, k))
			var b := " ".join(pal.slice(k))
			var w := maxf(PixelFonte.largura(a), PixelFonte.largura(b))
			if w < menor:
				menor = w
				melhor = PackedStringArray([a, b])
		linhas = melhor
	for k in linhas.size():
		while PixelFonte.largura(linhas[k]) > NOME_LARG / 0.65 and linhas[k].length() > 3:
			linhas[k] = linhas[k].substr(0, linhas[k].length() - 1)
	_nome_cache_de = nome
	_nome_cache = linhas
	return linhas


static func _quebrar_nome(n: String, larg: float) -> PackedStringArray:
	var linhas := PackedStringArray()
	var atual := ""
	for p in n.split(" ", false):
		var t := (atual + " " + p).strip_edges()
		if PixelFonte.largura(t) <= larg or atual == "":
			atual = t
		else:
			linhas.append(atual)
			atual = p
	if atual != "":
		linhas.append(atual)
	return linhas


## Texto centrado em `c` que cabe em `larg`: aperta na horizontal até 72% antes de cortar letras.
func _texto_apertado(c: Vector2, txt: String, larg: float, cor: Color) -> void:
	var t := txt.to_upper()
	if PixelFonte.largura(t) > larg / 0.72:
		t = PixelFonte.cortar(t, larg / 0.72)
	var w := float(PixelFonte.largura(t))
	var sx := minf(1.0, larg / maxf(w, 1.0))
	if sx < 1.0:
		draw_set_transform_matrix(_m * Transform2D(0.0, Vector2(sx, 1.0), 0.0, Vector2(c.x * (1.0 - sx), 0.0)))
	PixelFonte.centrado(self, c, t, cor)
	if sx < 1.0:
		draw_set_transform_matrix(_m)


## Vira no ar: escala X → 0 (troca a face) → volta, levantando junto.
func virar(duracao: float = 0.3) -> void:
	if is_inside_tree() and visible:
		Som.tocar("carta_virar", "", -3.0, duracao / 2)
	var t := create_tween()
	t.tween_property(self, "giro", 0.0, duracao / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	t.tween_callback(func() -> void: virada_para_cima = not virada_para_cima)
	t.tween_property(self, "giro", 1.0, duracao / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await t.finished


func vida() -> int:
	return defe - dano


## Contém o ponto (coordenadas globais)? Considera rotação e escala.
func contem(p_global: Vector2) -> bool:
	var l := to_local(p_global)
	return absf(l.x) <= LARG / 2.0 + 2 and absf(l.y) <= ALT / 2.0 + 2


func cores_estilhaco() -> Array:
	if not virada_para_cima:
		return [VERSO_FUNDO, VERSO_MEIO, OURO, CONTORNO, PAPEL]
	var base: Color = COR_CULTURA.get(cultura, Color("#a9a7ad"))        # cacos na cor da moldura + papel + ouro
	return [base, base.lightened(0.3), base.darkened(0.3), Color("#e4dfd2"), PAPEL, OURO_ESC]


func definir(d: Dictionary, quem: int) -> void:
	id = d["id"]; nome = d["nome"]; tipo = d["tipo"]; custo = int(d["custo"])
	atk = int(d["atk"]) if d["atk"] != null else 0
	defe = int(d["vida"]) if d["vida"] != null else 0
	keywords = d.get("keywords", []).duplicate()
	texto = d.get("texto", ""); cultura = d.get("cultura", ""); lendaria = d.get("lendaria", false)
	dono = quem; dano = 0
	dados = d
	dono_real = quem
	token = bool(d.get("token", false))
	resetar()


func tem(kw: String) -> bool:
	return kw in keywords or kw in aura_keywords


## Furtivo: não pode ser alvo de efeitos inimigos até atacar.
func protegida() -> bool:
	return tem("furtivo") and not ja_atacou


## ATK/Def mostrados = base + buffs permanentes + temporários + aura + Relíquia (Def = Vida máxima; vida() = Def − dano).
func sincronizar() -> void:
	atk = maxi(0, atk_base + buff_atk + temp_atk + aura_atk + rel_atk)
	defe = vida_base + buff_vida + temp_vida + aura_vida + rel_vida


func limpar_stats() -> void:
	buff_atk = 0; buff_vida = 0; temp_atk = 0; temp_vida = 0; rel_atk = 0; rel_vida = 0
	dano = 0
	sincronizar()


## Volta ao estado impresso (ao entrar na mão: Renascer, bounce, revive). Renascer usado não volta.
func resetar() -> void:
	if dados.is_empty():
		return
	atk_base = int(dados["atk"]) if dados.get("atk") != null else 0
	vida_base = int(dados["vida"]) if dados.get("vida") != null else 0
	keywords = (dados.get("keywords", []) as Array).duplicate()
	if sem_renascer:
		keywords.erase("renascer")
	efeitos = dados.get("efeitos", [])
	buff_atk = 0; buff_vida = 0; temp_atk = 0; temp_vida = 0; aura_atk = 0; aura_vida = 0; rel_atk = 0; rel_vida = 0
	aura_keywords = []
	dano = 0
	silenciada = false; congelada = false; sem_ataque = false; ja_atacou = false
	reliquia = {}
	roubada_temp = false
	cansada = false; atacou = false
	dono = dono_real
	sincronizar()


## Relíquia equipada: faixa dourada logo abaixo da carta, com o nome (e Usos, se tiver).
func _faixa_reliquia(x0: int, y0: int) -> void:
	var usos := (" " + str(reliquia["usos"])) if reliquia.get("usos") != null else ""
	var n := str(reliquia.get("nome", "")) + usos
	var r := Rect2(x0 + 2, y0 + ALT + ESPESSURA, LARG - 4, 9)
	var pulso := 0.5 + 0.5 * sin(Time.get_ticks_msec() / 1000.0 * TAU / 1.6)
	rr(self, r.grow(1), 3.0, Color("#140c10"))
	rr(self, r, 2.5, Color("#5a3a1a"))
	draw_line(Vector2(r.position.x + 2.5, r.position.y + 0.6), Vector2(r.end.x - 2.5, r.position.y + 0.6), Color(1.0, 0.89, 0.6, 0.6 + 0.4 * pulso), 1.0)
	var g := Vector2(r.position.x + 6, r.get_center().y)                     # gema da relíquia, pulsando
	draw_circle(g, 4.2, Color(1.0, 0.85, 0.4, 0.25 * pulso))
	draw_colored_polygon(PackedVector2Array([g + Vector2(0, -3), g + Vector2(3, 0), g + Vector2(0, 3), g + Vector2(-3, 0)]), Color("#ffd04a"))
	draw_colored_polygon(PackedVector2Array([g + Vector2(0, -3), g + Vector2(3, 0), g + Vector2(0, 0)]), Color("#fff2c0"))
	_texto_apertado(Vector2(r.position.x + 11 + (r.size.x - 13) / 2.0, r.get_center().y), n, r.size.x - 15, Color("#ffe39a"))


## Medalha numérica: gema redonda (custo), círculo com lâmina (ATK) ou escudo (Vida). Raio 7 px, cresce para caber o
## número (fonte 13 px, contorno 2 px). `anel`: aro colorido quando alterado (dourado = maior, roxo = menor);
## `pulso` 1→0: o número acabou de mudar (cresce 40% e clareia).
func _medalha(c: Vector2, s: String, fundo: Color, cor: Color, forma: String, anel := Color(0, 0, 0, 0), pulso := 0.0) -> void:
	var f := PixelFonte.fonte()
	var tam := 13
	var lw := f.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, tam).x
	var r := maxf(7.0, lw / 2.0 + 2.6)
	var fora := 2.2 + (0.0 if anel.a <= 0.0 else 0.4)                    # contorno + aro ficam dentro da carta
	c.x = clampf(c.x, -LARG / 2.0 + r + fora, LARG / 2.0 - r - fora)
	c.y = clampf(c.y, -ALT / 2.0 + r + fora - 1.0, ALT / 2.0 - r * (1.1 if forma == "escudo" else 1.0) - fora)
	var esc := 1.0 + 0.4 * pulso * pulso
	if esc != 1.0:
		draw_set_transform_matrix(_m * Transform2D(0.0, Vector2(esc, esc), 0.0, c * (1.0 - esc)))
	if anel.a > 0.0:
		draw_circle(c, r + 2.0, Color(anel, 0.55 + 0.25 * sin(Time.get_ticks_msec() / 1000.0 * TAU / 1.2)))
	match forma:
		"escudo":
			var pts := PackedVector2Array([c + Vector2(-r, -r * 0.85), c + Vector2(r, -r * 0.85), c + Vector2(r, r * 0.1),
				c + Vector2(r * 0.55, r * 0.7), c + Vector2(0, r * 1.1), c + Vector2(-r * 0.55, r * 0.7), c + Vector2(-r, r * 0.1)])
			var borda := PackedVector2Array()
			for p in pts:
				borda.append(c + (p - c) * ((r + 1.3) / r))
			draw_colored_polygon(borda, Color("#140c10"))
			draw_colored_polygon(pts, fundo)
			draw_line(c + Vector2(-r + 1.5, -r * 0.85 + 1), c + Vector2(r - 1.5, -r * 0.85 + 1), fundo.lightened(0.45), 1.0)
		_:
			draw_circle(c, r + 1.3, Color("#140c10"))
			draw_circle(c, r, fundo)
			draw_arc(c, r - 1.0, PI * 1.1, PI * 1.9, 10, fundo.lightened(0.45), 1.0, true)     # reflexo no alto
			draw_arc(c, r - 1.0, PI * 0.1, PI * 0.9, 10, fundo.darkened(0.35), 1.0, true)
			if forma == "gema":
				draw_arc(c, r + 0.3, 0, TAU, 24, Color(OURO, 0.85), 0.8, true)
	if pulso > 0.0:
		draw_circle(c, r, Color(1, 1, 1, 0.45 * pulso))
	var pos := Vector2(c.x - lw / 2.0, c.y + tam * 0.36)
	draw_string_outline(f, pos, s, HORIZONTAL_ALIGNMENT_LEFT, -1, tam, 2, Color("#140c10"))
	draw_string(f, pos, s, HORIZONTAL_ALIGNMENT_LEFT, -1, tam, cor.lerp(Color.WHITE, pulso * 0.6))
	if esc != 1.0:
		draw_set_transform_matrix(_m)


## Aura arco-íris no chão (a carta é desenhada por cima, então só a borda aparece): 5 contornos arredondados de
## 2,5 px que se afastam 2→12 px da carta, cada lado com um matiz (girando 0,4 volta/s), alfa pulsando a cada 0,8 s,
## e 6 brilhos redondos orbitando o contorno a 80 px/s.
func _aura(x0: int, y0: int) -> void:
	_t_aura += get_process_delta_time()
	var pulso := 0.8 + 0.2 * sin(_t_aura * TAU / 0.8)
	var esp := 2.0 + 1.5 * sin(_t_aura * TAU / 1.6)          # a aura "respira" 2–3,5 px
	var base := Rect2(x0, y0, LARG, ALT + ESPESSURA)
	for i in range(5, 0, -1):
		var g := esp + i * 2.2
		var al := (0.1 + 0.1 * (5 - i)) * pulso
		var pts := pontos_rr(base.grow(g), RAIO + g)
		var n := pts.size()
		for k in n:                                            # cada segmento com o matiz da sua posição no contorno
			var h := fmod(_t_aura * 0.4 + float(k) / n + i * 0.04, 1.0)
			draw_line(pts[k], pts[(k + 1) % n], Color.from_hsv(h, 0.85, 1.0, al), 2.6, true)
	var per := 2.0 * (LARG + ALT) + 40.0
	for k in 6:
		var d := fmod(_t_aura * 80.0 + k * per / 6.0, per)
		var q := _no_contorno(x0 - esp - 4, y0 - esp - 4, LARG + 2 * esp + 8, ALT + ESPESSURA + 2 * esp + 8, d)
		var cor := Color.from_hsv(fmod(_t_aura * 0.4 + k / 6.0, 1.0), 0.5, 1.0)
		draw_circle(q, 2.6, Color(cor, 0.3))
		draw_circle(q, 1.2, Color(cor.lightened(0.5), 0.95))


func _no_contorno(x: float, y: float, w: float, h: float, d: float) -> Vector2:
	if d < w: return Vector2(x + d, y)
	d -= w
	if d < h: return Vector2(x + w, y + d)
	d -= h
	if d < w: return Vector2(x + w - d, y + h)
	d -= w
	return Vector2(x, y + h - minf(d, h))


const ESCUDO := ["0111110", "1222221", "1233321", "1233321", "1223221", "0122210", "0012100", "0001000"]


## Guarda: carta mais clara (véu azul 12%), contorno azul-aço de 2 px, um reflexo de escudo atravessando a carta
## a cada 1,8 s e um escudo pixel 7×8 (×1) preso no topo, no meio.
func _guarda(x0: int, y0: int) -> void:
	var tt := Time.get_ticks_msec() / 1000.0
	var r := Rect2(x0, y0, LARG, ALT)
	rr(_fx, r, RAIO, Color(0.75, 0.88, 1.0, 0.2))
	var fase := fmod(tt / 1.8, 1.0)
	var bx := x0 - 8 + fase * (LARG + 16)
	for k in 3:                                   # reflexo inclinado: 3 degraus de 2 px de altura cada terço
		var xx := bx + k * 3
		var faixa := Rect2(xx, y0 + k * ALT / 3.0, 4, ALT / 3.0).intersection(r)
		if faixa.size.x > 0:
			_fx.draw_rect(faixa, Color(1, 1, 1, 0.22))
	var pulso := 0.7 + 0.3 * sin(tt * TAU / 1.4)
	rr_linha(_fx, r.grow(1), RAIO + 1, Color(0.7, 0.85, 1.0, pulso), 2.0)
	rr_linha(_fx, r.grow(3), RAIO + 3, Color(0.45, 0.65, 1.0, 0.55 * pulso), 2.0)
	rr_linha(_fx, r.grow(5.5), RAIO + 5.5, Color(0.45, 0.65, 1.0, 0.22 * pulso), 2.5)
	var cores := [Color(0, 0, 0, 0), Color("#1b2333"), Color("#c9d6ea"), Color("#4f7fd0")]
	var ox := x0 + LARG - 15                       # escudo 2× (14×16 px) no canto de cima à direita, acima do nome
	var oy := y0 - 14
	for yy in ESCUDO.size():
		for xx in 7:
			var v := int(ESCUDO[yy][xx])
			if v > 0:
				_fx.draw_rect(Rect2(ox + xx * 2, oy + yy * 2, 2, 2), cores[v])
