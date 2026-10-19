class_name Efeitos
extends Node2D
## Camada de efeitos (não recebe luz): partículas de pixel, números de dano, anéis, clarão de tela, faixas de vitória/derrota
## e o cursor da demonstração. Tudo em px nativos (360×640).

var particulas: Array[Dictionary] = []
var popups: Array[Dictionary] = []
var aneis: Array[Dictionary] = []
var clarao := Color(0, 0, 0, 0)
var faixa := ""                        # "VITÓRIA" / "DERROTA" / ""
var faixa_t := 0.0
var cursor := Vector2(-100, -100)
var cursor_apertado := false
var destaques: Array[Rect2] = []       # espaços válidos piscando durante o arraste
var escolha: Array[Dictionary] = []    # botões CIMA/BAIXO: {rect, texto, valor}
var zoom: Carta = null                 # carta segurada sem mover: painel com os dados completos
var tempo := 0.0
var fala := {}                         # balão do oponente: {quem, texto, cor, retrato, t}


func _ready() -> void:
	z_index = 900
	var mat := CanvasItemMaterial.new()
	mat.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	material = mat


func poeira(p: Vector2, n: int = 12) -> void:
	for i in n:
		var a := randf_range(PI * 0.9, PI * 2.1)
		particulas.append({"p": p + Vector2(randf_range(-20, 20), randf_range(-2, 2)), "v": Vector2.from_angle(a) * randf_range(20, 55),
			"cor": Color("#c9b994") if i % 2 else Color("#8c7a6a"), "vida": randf_range(0.25, 0.45), "max": 0.45, "g": 40.0, "tam": 1})


func faiscas(p: Vector2, n: int = 16, cor := Color("#ffe39a")) -> void:
	for i in n:
		var a := randf() * TAU
		particulas.append({"p": p, "v": Vector2.from_angle(a) * randf_range(60, 140), "cor": cor if i % 3 else Color.WHITE,
			"vida": randf_range(0.2, 0.4), "max": 0.4, "g": 120.0, "tam": 1 + int(i % 4 == 0)})


func estilhacar(centro: Vector2, cores: Array, larg: int, alt: int) -> void:
	## a carta se desfaz em ~70 fragmentos de 2×2 px nas cores dela, voando para fora e caindo
	for i in 70:
		var off := Vector2(randf_range(-larg / 2.0, larg / 2.0), randf_range(-alt / 2.0, alt / 2.0))
		particulas.append({"p": centro + off, "v": off.normalized() * randf_range(30, 110) + Vector2(0, -40),
			"cor": cores[i % cores.size()], "vida": randf_range(0.45, 0.9), "max": 0.9, "g": 220.0, "tam": 2})


func confete(n: int = 80) -> void:
	var cores := [Color("#ffe39a"), Color("#ff6a8a"), Color("#7aa8ff"), Color("#8ae38a"), Color("#e2b85a"), Color.WHITE]
	for i in n:
		particulas.append({"p": Vector2(randf_range(20, 340), -10), "v": Vector2(randf_range(-30, 30), randf_range(40, 120)),
			"cor": cores[i % cores.size()], "vida": randf_range(1.8, 3.2), "max": 3.2, "g": 25.0, "tam": 2})


func cinzas(n: int = 60) -> void:
	for i in n:
		particulas.append({"p": Vector2(randf_range(0, 360), randf_range(-40, 640)), "v": Vector2(randf_range(-8, 8), randf_range(10, 30)),
			"cor": Color("#6a6470") if i % 2 else Color("#3a3640"), "vida": randf_range(2.0, 3.5), "max": 3.5, "g": 0.0, "tam": 1})


func numero(p: Vector2, texto: String, cor: Color, esc: int = 2) -> void:
	popups.append({"p": p, "texto": texto, "cor": cor, "vida": 0.9, "esc": esc})


func anel(p: Vector2, cor: Color, r_max: float = 30.0) -> void:
	aneis.append({"p": p, "r": 2.0, "rmax": r_max, "cor": cor, "vida": 0.3})


func flash(cor: Color, alfa: float = 0.35) -> void:
	clarao = Color(cor.r, cor.g, cor.b, alfa)


func falar(quem: String, texto: String, cor: Color, retrato: String) -> void:
	fala = {"quem": quem, "texto": texto, "cor": cor, "retrato": retrato, "t": 0.0}


func _process(delta: float) -> void:
	tempo += delta
	if not fala.is_empty():
		fala["t"] += delta
		if fala["t"] > 3.2:
			fala = {}
	for p in particulas:
		p["v"] += Vector2(0, p["g"]) * delta
		p["p"] += p["v"] * delta
		p["vida"] -= delta
	particulas = particulas.filter(func(p: Dictionary) -> bool: return p["vida"] > 0.0)
	for p in popups:
		p["p"] += Vector2(0, -28) * delta
		p["vida"] -= delta
	popups = popups.filter(func(p: Dictionary) -> bool: return p["vida"] > 0.0)
	for a in aneis:
		a["r"] = lerpf(a["r"], a["rmax"], 0.25)
		a["vida"] -= delta
	aneis = aneis.filter(func(a: Dictionary) -> bool: return a["vida"] > 0.0)
	clarao.a = maxf(0.0, clarao.a - delta * 1.4)
	if faixa != "":
		faixa_t += delta
	queue_redraw()


func _draw() -> void:
	# espaços válidos (pulsando) enquanto arrasta
	var pulso := 0.45 + 0.35 * sin(tempo * 9.0)
	for r in destaques:
		draw_rect(r, Color(1.0, 0.85, 0.4, pulso), false, 1.0)
		draw_rect(r.grow(1), Color(1.0, 0.85, 0.4, pulso * 0.4), false, 1.0)
	for a in aneis:
		draw_arc(a["p"], a["r"], 0, TAU, 32, Color(a["cor"], a["vida"] / 0.3), 1.0)
	for p in particulas:
		var al := clampf(p["vida"] / p["max"] * 1.5, 0, 1)
		var t: int = p["tam"]
		draw_rect(Rect2((p["p"] as Vector2).round(), Vector2(t, t)), Color(p["cor"], al))
	for p in popups:
		var al := clampf(p["vida"] / 0.4, 0, 1)
		var esc: int = p["esc"]
		PixelFonte.centrado(self, (p["p"] as Vector2).round(), p["texto"], Color(p["cor"], al), esc, Color(0.08, 0.04, 0.06, al))
	# botões de escolha da face
	for b in escolha:
		var r: Rect2 = b["rect"]
		draw_rect(r.grow(1), Color("#140c10"))
		draw_rect(r, Color("#3d1f33"))
		draw_rect(Rect2(r.position, Vector2(r.size.x, 1)), Color("#e2b85a"))
		draw_rect(Rect2(r.position + Vector2(0, r.size.y - 1), Vector2(r.size.x, 1)), Color("#9c7430"))
		PixelFonte.centrado(self, r.get_center() + Vector2(0, 1), b["texto"], Color("#ffe39a"), 1)
	if zoom != null and is_instance_valid(zoom):
		_desenhar_zoom()
	if not fala.is_empty():
		_desenhar_fala_oponente()
	if clarao.a > 0.0:
		draw_rect(Rect2(-400, -400, 1200, 1500), clarao)
	if faixa != "":
		_desenhar_faixa()
	if cursor.x > -50:
		var c := cursor.round()
		draw_circle(c, 5.0 if cursor_apertado else 6.0, Color(1, 1, 1, 0.35))
		draw_arc(c, 6.0, 0, TAU, 20, Color(1, 1, 1, 0.9), 1.0)


func _desenhar_faixa() -> void:
	var vit := faixa == "VITÓRIA"
	var ent := clampf(faixa_t / 0.35, 0, 1)
	var c := Vector2(180, 300)
	if vit:
		# raios dourados girando atrás da faixa
		for k in 16:
			var a := faixa_t * 0.6 + TAU * k / 16.0
			var pts := PackedVector2Array([c, c + Vector2.from_angle(a - 0.08) * 420 * ent, c + Vector2.from_angle(a + 0.08) * 420 * ent])
			draw_colored_polygon(pts, Color(1.0, 0.86, 0.45, 0.16))
	else:
		draw_rect(Rect2(-400, -400, 1200, 1500), Color(0.05, 0.03, 0.08, 0.45 * ent))
	var h := 34.0 * ent
	var cor_fundo := Color("#3d1f33") if vit else Color("#1a1620")
	var cor_borda := Color("#e2b85a") if vit else Color("#6a6470")
	var y := c.y - h / 2 + (0.0 if vit else (1.0 - ent) * -40.0)
	draw_rect(Rect2(-10, y, 380, h), cor_fundo)
	draw_rect(Rect2(-10, y, 380, 2), cor_borda)
	draw_rect(Rect2(-10, y + h - 2, 380, 2), cor_borda)
	if ent >= 1.0:
		var esc := 4
		var salto := 0.0 if not vit else absf(sin(faixa_t * 4.0)) * -2.0
		var cor_txt := Color("#ffe39a") if vit else Color("#b8b0c0")
		PixelFonte.centrado(self, c + Vector2(0, salto), faixa, cor_txt, esc, Color("#140c10"))
		if not vit:                                   # rachaduras na faixa
			for k in 5:
				var x0 := 60 + k * 55
				draw_line(Vector2(x0, y + 2), Vector2(x0 + 6, y + h * 0.5), Color("#0a080c"), 1.0)
				draw_line(Vector2(x0 + 6, y + h * 0.5), Vector2(x0 - 2, y + h - 2), Color("#0a080c"), 1.0)


## Painel 328×N no meio da tela: nome (2×), tipo · custo · ATK/Def, palavras-chave e o texto quebrado em 79 colunas.
func _desenhar_zoom() -> void:
	var c := zoom
	var tex := Carta.textura("carta", c.id, "webp") if c.id != "" else null
	if tex:
		# carta inteira no frame do mapa (300×420), centrada; fundo escurecido atrás
		draw_rect(Rect2(-400, -400, 1200, 1500), Color(0.04, 0.02, 0.06, 0.55))
		var r := Rect2(30, 110, 300, 420)
		draw_rect(r.grow(2), Color("#140c10"))
		draw_texture_rect(tex, r, false)
		if c.tipo == "entidade" and c.dano > 0:
			var s := "VIDA ATUAL %d" % maxi(c.vida(), 0)
			var w := PixelFonte.largura(s, 2) + 12
			draw_rect(Rect2(180 - w / 2.0, 92, w, 16), Color("#5a1a1a"))
			PixelFonte.centrado(self, Vector2(180, 100), s, Color("#ffd0d0"), 2)
		return
	var tipo_txt: String = {"entidade": "ENTIDADE", "selo": "SELO", "rito": "RITO", "reliquia": "RELIQUIA"}.get(c.tipo, c.tipo.to_upper())
	var linha2 := "%s  -  CUSTO %d" % [tipo_txt, c.custo]
	if c.tipo == "entidade":
		linha2 += "  -  ATK %d  DEF %d" % [c.atk, maxi(c.vida(), 0)]
	if c.lendaria:
		linha2 += "  -  LENDARIA"
	var kws := ""
	for k in c.keywords:
		kws += {"guarda": "GUARDA ", "impeto": "IMPETO ", "furtivo": "FURTIVO ", "renascer": "RENASCER "}.get(k, "")
	var linhas := PixelFonte.quebrar(c.texto, 79)
	var h := 12 + 12 + 8 + (8 if kws != "" else 0) + linhas.size() * 7 + 8
	var y0 := 250.0 - h / 2.0 if c.global_position.y > 320 else 390.0 - h / 2.0
	var r := Rect2(16, y0, 328, h)
	draw_rect(r.grow(2), Color("#140c10"))
	draw_rect(r, Color("#24161f"))
	draw_rect(Rect2(r.position, Vector2(r.size.x, 1)), Color("#e2b85a"))
	draw_rect(Rect2(r.position + Vector2(0, r.size.y - 1), Vector2(r.size.x, 1)), Color("#9c7430"))
	var y := y0 + 6
	PixelFonte.desenhar(self, Vector2(24, y), c.nome, Color("#ffe39a"), 2)
	y += 14
	PixelFonte.desenhar(self, Vector2(24, y), linha2, Color("#cfe0ff"))
	y += 9
	if kws != "":
		PixelFonte.desenhar(self, Vector2(24, y), kws.strip_edges(), Color("#ffd9a0"))
		y += 8
	for ln in linhas:
		PixelFonte.desenhar(self, Vector2(24, y), ln, Color("#f2e6c8"))
		y += 7


## Balão no topo, abaixo da mão do oponente: retrato 36×48 + nome + texto (Fonte57), entra deslizando 0,2 s.
func _desenhar_fala_oponente() -> void:
	var t: float = fala["t"]
	var desl := (1.0 - clampf(t / 0.2, 0, 1)) * -30.0 + (clampf((t - 2.9) / 0.3, 0, 1) * -30.0)
	var cor: Color = fala["cor"]
	var r := Rect2(14, 62 + desl, 332, 54)
	draw_rect(r.grow(2), Color("#140c10"))
	draw_rect(r, Color("#1c141a"))
	draw_rect(Rect2(r.position, Vector2(r.size.x, 1)), cor)
	var tex := Carta.textura("retrato", fala["retrato"], "png")
	var rr := Rect2(r.position + Vector2(4, 3), Vector2(36, 48))
	draw_rect(rr, cor.darkened(0.6))
	if tex:
		# só o rosto/busto: recorte dos 30% de cima do personagem
		var tw := float(tex.get_width())
		var th := float(tex.get_height())
		var src := Rect2(tw * 0.18, 0, tw * 0.64, tw * 0.64 * 48.0 / 36.0)
		src.size.y = minf(src.size.y, th)
		draw_texture_rect_region(tex, rr, src)
	Fonte57.desenhar(self, r.position + Vector2(46, 5), fala["quem"], cor, Color("#140c10"))
	var y := r.position.y + 18
	for ln in Fonte57.quebrar(fala["texto"], 280):
		Fonte57.desenhar(self, Vector2(r.position.x + 46, y), ln, Color("#f2e6c8"), Color("#140c10"))
		y += 10
