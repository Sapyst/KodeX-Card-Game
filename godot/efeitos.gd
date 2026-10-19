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
var nuvens: Array[Dictionary] = []     # baforadas de poeira no chão (camada baixa)
var fala := {}                         # balão do oponente: {quem, texto, cor, retrato, t}
var dica := ""                         # instrução fixa enquanto o jogador escolhe um alvo ("TOQUE UM ALVO")
var dica_y := 291.0
# escolhas grandes (alvo por toque / galeria do cemitério)
var alvos: Array = []                  # Cartas candidatas: brilho dourado pulsando + seta quicando em cima
var faixa_alvo := {}                   # {titulo, sub, y}: faixa que atravessa a mesa durante a escolha de alvo
var galeria := {}                      # {titulo, sub}: tela escura com as cartas grandes (escolha["tex"])
var t_escolha := 0.0                   # s desde que a escolha abriu (animações de entrada)
var escolhida := -1
var vitrine := {}
# tutorial
var tutor := {}                        # {nome, cor, texto, t, toque}: painel do Silas no topo, texto digitando
var guia := {}                         # {de, para, t}: dedo fantasma mostrando o gesto (loop de 1,6 s)
var foco: Array = []                   # Rect2 pulsando em dourado (o que o Silas está mostrando)                      # carta montada mostrada grande: {tex, de, t, dur, cor}                    # item da galeria tocado (pulso de confirmação)


func _ready() -> void:
	z_index = 900
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR          # cartas montadas reduzidas (zoom, galeria) sem serrilhado
	var mat := CanvasItemMaterial.new()
	mat.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	material = mat


func poeira(p: Vector2, n: int = 12) -> void:
	for i in n:
		var a := randf_range(PI * 0.9, PI * 2.1)
		particulas.append({"p": p + Vector2(randf_range(-20, 20), randf_range(-2, 2)), "v": Vector2.from_angle(a) * randf_range(20, 55),
			"cor": Color("#c9b994") if i % 2 else Color("#8c7a6a"), "vida": randf_range(0.25, 0.45), "max": 0.45, "g": 40.0, "tam": 1})


## Onda de poeira no chão ao redor de onde a carta caiu: ~30 baforadas saem em elipse (perspectiva da mesa,
## altura 0,5× a largura), crescem de 2 a 7 px e somem em 0,45–0,8 s; um segundo anel mais lento e mais fraco.
func onda_poeira(c: Vector2, raio: float, forca: float = 1.0) -> void:
	var n := int(30 * forca)
	for anel in 2:
		for i in n:
			var a := TAU * i / n + randf_range(-0.08, 0.08)
			var dirv := Vector2(cos(a), sin(a) * 0.5)
			var vel := (90.0 if anel == 0 else 45.0) * randf_range(0.8, 1.2) * forca
			nuvens.append({"p": c + dirv * raio * 0.55, "v": dirv * vel, "r": randf_range(2.0, 3.5),
				"rmax": randf_range(5.0, 8.0) * (1.0 if anel == 0 else 0.8), "vida": randf_range(0.45, 0.8), "t": 0.0,
				"cor": [Color("#c9b994"), Color("#a8987a"), Color("#8c7a6a")][randi() % 3], "a0": 0.55 if anel == 0 else 0.35})


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
	for nv in nuvens:
		nv["t"] += delta
		nv["p"] += (nv["v"] as Vector2) * delta
		nv["v"] *= 0.90
	nuvens = nuvens.filter(func(nv: Dictionary) -> bool: return nv["t"] < nv["vida"])
	for p in popups:
		p["p"] += Vector2(0, -28) * delta
		p["vida"] -= delta
	popups = popups.filter(func(p: Dictionary) -> bool: return p["vida"] > 0.0)
	for a in aneis:
		a["r"] = lerpf(a["r"], a["rmax"], 0.25)
		a["vida"] -= delta
	aneis = aneis.filter(func(a: Dictionary) -> bool: return a["vida"] > 0.0)
	clarao.a = maxf(0.0, clarao.a - delta * 1.4)
	t_escolha += delta
	if not tutor.is_empty():
		tutor["t"] += delta
	if not guia.is_empty():
		guia["t"] += delta
	if not vitrine.is_empty():
		vitrine["t"] += delta
	if faixa != "":
		faixa_t += delta
	queue_redraw()


func _draw() -> void:
	# espaços válidos (pulsando) enquanto arrasta
	var pulso := 0.45 + 0.35 * sin(tempo * 9.0)
	for r in destaques:
		draw_rect(r, Color(1.0, 0.85, 0.4, pulso), false, 2.0)
		draw_rect(r.grow(2), Color(1.0, 0.85, 0.4, pulso * 0.45), false, 2.0)
		draw_rect(r.grow(4), Color(1.0, 0.85, 0.4, pulso * 0.18), false, 2.0)
	for nv in nuvens:
		var u: float = nv["t"] / nv["vida"]
		var r: float = lerpf(nv["r"], nv["rmax"], 1.0 - pow(1.0 - u, 2.0))
		draw_circle((nv["p"] as Vector2).round(), r, Color(nv["cor"], nv["a0"] * (1.0 - u)))
	for a in aneis:
		draw_arc(a["p"], a["r"], 0, TAU, 32, Color(a["cor"], a["vida"] / 0.3), 1.0)
	for p in particulas:
		var al := clampf(p["vida"] / p["max"] * 1.5, 0, 1)
		var t: int = p["tam"]
		draw_rect(Rect2((p["p"] as Vector2).round(), Vector2(t, t)), Color(p["cor"], al))
	for p in popups:
		var al := clampf(p["vida"] / 0.4, 0, 1)
		var esc: int = p["esc"]
		PixelFonte.centrado(self, (p["p"] as Vector2).round(), Sessao.t(p["texto"]), Color(p["cor"], al), esc, Color(0.08, 0.04, 0.06, al))
	if not alvos.is_empty():
		_desenhar_alvos()
	if not faixa_alvo.is_empty():
		_desenhar_faixa_alvo()
	if not galeria.is_empty():
		_desenhar_galeria()
	if dica != "":
		var w := PixelFonte.largura(Sessao.t(dica), 1) + 10
		var rd := Rect2(180 - w / 2.0, dica_y - 6, w, 12)
		draw_rect(rd.grow(1), Color("#140c10"))
		draw_rect(rd, Color("#24161f"))
		draw_rect(Rect2(rd.position, Vector2(rd.size.x, 1)), Color(1.0, 0.85, 0.4, pulso))
		PixelFonte.centrado(self, rd.get_center() + Vector2(0, 1), Sessao.t(dica), Color("#ffe39a"))
	# botões de escolha (face, PULAR); itens com "tex" são cartas da galeria
	for b in escolha:
		if b.has("tex"):
			continue
		var r: Rect2 = b["rect"]
		draw_rect(r.grow(1), Color("#140c10"))
		draw_rect(r, Color("#3d1f33"))
		draw_rect(Rect2(r.position, Vector2(r.size.x, 1)), Color("#e2b85a"))
		draw_rect(Rect2(r.position + Vector2(0, r.size.y - 1), Vector2(r.size.x, 1)), Color("#9c7430"))
		PixelFonte.centrado(self, r.get_center() + Vector2(0, 1), Sessao.t(str(b["texto"])), Color("#ffe39a"), 1)
	if not vitrine.is_empty():
		_desenhar_vitrine()
	if zoom != null and is_instance_valid(zoom):
		_desenhar_zoom()
	if not fala.is_empty():
		_desenhar_fala_oponente()
	if clarao.a > 0.0:
		draw_rect(Rect2(-400, -400, 1200, 1500), clarao)
	if faixa != "":
		_desenhar_faixa()
	for r in foco:
		var pf := 0.55 + 0.45 * sin(tempo * 6.0)
		draw_rect((r as Rect2).grow(2), Color(1.0, 0.85, 0.4, pf), false, 2.0)
		draw_rect((r as Rect2).grow(5), Color(1.0, 0.85, 0.4, pf * 0.4), false, 2.0)
	if not guia.is_empty():
		_desenhar_guia()
	if not tutor.is_empty():
		_desenhar_tutor()
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
		PixelFonte.centrado(self, c + Vector2(0, salto), Sessao.t(faixa), cor_txt, esc, Color("#140c10"))
		if not vit:                                   # rachaduras na faixa
			for k in 5:
				var x0 := 60 + k * 55
				draw_line(Vector2(x0, y + 2), Vector2(x0 + 6, y + h * 0.5), Color("#0a080c"), 1.0)
				draw_line(Vector2(x0 + 6, y + h * 0.5), Vector2(x0 - 2, y + h - 2), Color("#0a080c"), 1.0)


## Painel 328×N no meio da tela: nome (2×), tipo · custo · ATK/Def, palavras-chave e o texto quebrado em 79 colunas.
func _desenhar_zoom() -> void:
	var c := zoom
	var tex := Carta.textura("carta_en" if Sessao.idioma == "en" else "carta", c.id, "webp") if c.id != "" else null
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
			PixelFonte.centrado(self, Vector2(180, 100), Sessao.t(s), Color("#ffd0d0"), 2)
		return
	var tipo_txt: String = Sessao.t({"entidade": "ENTIDADE", "selo": "SELO", "rito": "RITO", "reliquia": "RELIQUIA"}.get(c.tipo, c.tipo.to_upper()))
	var linha2 := "%s  -  CUSTO %d" % [tipo_txt, c.custo]
	if c.tipo == "entidade":
		linha2 += "  -  ATK %d  DEF %d" % [c.atk, maxi(c.vida(), 0)]
	if c.lendaria:
		linha2 += "  -  LENDARIA"
	var kws := ""
	for k in c.keywords:
		kws += Sessao.t({"guarda": "GUARDA", "impeto": "IMPETO", "furtivo": "FURTIVO", "renascer": "RENASCER"}.get(k, "")) + " "
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


static func _ease_back(u: float) -> float:
	var c := 1.70158
	return 1.0 + (c + 1.0) * pow(u - 1.0, 3.0) + c * pow(u - 1.0, 2.0)


## Seta dourada apontando para baixo (11×7 px) com contorno escuro.
func _seta(p: Vector2, cor: Color) -> void:
	draw_rect(Rect2(p + Vector2(-4, -17), Vector2(8, 10)), Color("#140c10"))
	draw_colored_polygon(PackedVector2Array([p + Vector2(-11, -9), p + Vector2(11, -9), p + Vector2(0, 4)]), Color("#140c10"))
	draw_rect(Rect2(p + Vector2(-2, -16), Vector2(4, 9)), cor)
	draw_colored_polygon(PackedVector2Array([p + Vector2(-8, -8), p + Vector2(8, -8), p + Vector2(0, 1)]), cor)
	draw_rect(Rect2(p + Vector2(-2, -16), Vector2(1, 8)), Color(1, 1, 1, cor.a * 0.8))


## Candidatas a alvo: 4 faixas de brilho dourado pulsando (2 px cada), cantos de mira que se fecham e uma seta quicando.
func _desenhar_alvos() -> void:
	var u := clampf(t_escolha / 0.25, 0, 1)
	var pulso := 0.65 + 0.35 * sin(tempo * 7.0)
	for k in alvos.size():
		var c = alvos[k]
		if not is_instance_valid(c):
			continue
		var cc: Carta = c
		var sz := Vector2(Carta.LARG, Carta.ALT + Carta.ESPESSURA) * cc.scale.x
		var r := Rect2(cc.global_position - sz / 2, sz)
		draw_rect(r.grow(1), Color(1.0, 0.95, 0.7, pulso * u), false, 2.0)
		for i in 5:
			draw_rect(r.grow(3 + i * 3), Color(1.0, 0.78, 0.3, (0.7 - i * 0.13) * pulso * u), false, 3.0)
		# mira: cantos em L que entram de 10 px para 3 px
		var g := lerpf(10.0, 3.0, _ease_back(u)) + 1.5 * sin(tempo * 7.0)
		var rr := r.grow(g)
		var cor := Color(1.0, 0.95, 0.75, u)
		for cx in [rr.position.x, rr.end.x]:
			for cy in [rr.position.y, rr.end.y]:
				var sx := 1.0 if cx == rr.position.x else -1.0
				var sy := 1.0 if cy == rr.position.y else -1.0
				draw_rect(Rect2(Vector2(cx, cy) - Vector2(1, 1), Vector2(sx * 7, 2)).abs(), cor)
				draw_rect(Rect2(Vector2(cx, cy) - Vector2(1, 1), Vector2(2, sy * 7)).abs(), cor)
		var bob := absf(sin(tempo * 5.0 + k * 0.7)) * -4.0
		_seta(Vector2(r.get_center().x, rr.position.y - 6 + bob - (1.0 - u) * 12), Color(1.0, 0.85, 0.4, u))


## Faixa que atravessa a mesa: título 2× + o efeito; entra abrindo do centro (0,2 s).
func _desenhar_faixa_alvo() -> void:
	var u := clampf(t_escolha / 0.2, 0, 1)
	var y: float = faixa_alvo["y"]
	var w := 380.0 * (1.0 - pow(1.0 - u, 3.0))
	var r := Rect2(180 - w / 2, y - 15, w, 30)
	draw_rect(r, Color(0.09, 0.05, 0.08, 0.94))
	var brilho := 0.75 + 0.25 * sin(tempo * 4.0)
	draw_rect(Rect2(r.position, Vector2(r.size.x, 2)), Color(0.89, 0.72, 0.35, brilho))
	draw_rect(Rect2(r.position + Vector2(0, r.size.y - 2), Vector2(r.size.x, 2)), Color(0.61, 0.45, 0.19, brilho))
	if u < 1.0:
		return
	PixelFonte.centrado(self, Vector2(180, y - 5), Sessao.t(faixa_alvo["titulo"]), Color("#ffe39a"), 2, Color("#140c10"))
	PixelFonte.centrado(self, Vector2(180, y + 8), faixa_alvo["sub"], Color("#cfe0ff"), 1)


## Galeria: escurece a tela e mostra as cartas candidatas grandes (96×134), entrando de baixo uma a uma.
func _desenhar_galeria() -> void:
	var u := clampf(t_escolha / 0.2, 0, 1)
	draw_rect(Rect2(-400, -400, 1200, 1500), Color(0.03, 0.02, 0.05, 0.78 * u))
	var topo := 9999.0
	for b in escolha:
		if b.has("tex"):
			topo = minf(topo, (b["rect"] as Rect2).position.y)
	var ty := topo - 28 - (1.0 - u) * 10
	PixelFonte.centrado(self, Vector2(180, ty), Sessao.t(galeria["titulo"]), Color(1.0, 0.89, 0.6, u), 2, Color("#140c10"))
	PixelFonte.centrado(self, Vector2(180, ty + 13), Sessao.t(galeria["sub"]), Color(0.81, 0.88, 1.0, u), 1)
	var pulso := 0.6 + 0.4 * sin(tempo * 5.0)
	for b in escolha:
		if not b.has("tex"):
			continue
		var i: int = b["valor"]
		var e := clampf((t_escolha - 0.08 - i * 0.07) / 0.32, 0, 1)
		if e <= 0.0:
			continue
		var r: Rect2 = b["rect"]
		var off := Vector2(0, (1.0 - _ease_back(e)) * 70 + sin(tempo * 2.2 + i) * 1.5)
		var esc := 1.0
		if escolhida == i:
			esc = 1.0 + 0.12 * sin(clampf(t_escolha * 3.0, 0, 1) * PI)
		elif escolhida >= 0:
			off.y += 6
		var rr := Rect2(r.get_center() + off - r.size * esc / 2, r.size * esc)
		var al := e if escolhida < 0 or escolhida == i else 0.35
		draw_rect(rr.grow(4), Color(1.0, 0.82, 0.35, 0.25 * pulso * al), false, 4.0)
		draw_rect(rr.grow(1), Color(1.0, 0.85, 0.4, (0.5 + 0.5 * pulso) * al), false, 2.0)
		draw_texture_rect(b["tex"], rr, false, Color(1, 1, 1, al))
		if b.has("rotulo"):
			PixelFonte.centrado(self, Vector2(rr.get_center().x, rr.end.y + 7), b["rotulo"], Color(1.0, 0.89, 0.6, al), 1, Color("#140c10"))


## Vitrine: a carta montada sai da posição da carta na mesa (escala 0,25), cresce até 160×224 no centro com
## ease-out-back (0,24 s), fica com raios girando atrás e volta encolhendo (0,18 s) no fim de `dur`.
func _desenhar_vitrine() -> void:
	var v := vitrine
	var t: float = v["t"]
	var dur: float = v["dur"]
	var ent := clampf(t / 0.24, 0, 1)
	var sai := clampf((t - (dur - 0.18)) / 0.18, 0, 1)
	var k := _ease_back(ent) * (1.0 - sai * sai)
	var centro: Vector2 = (v["de"] as Vector2).lerp(Vector2(180, 290), minf(1.0, ent * 1.2)).lerp(v["de"], sai)
	var tam := Vector2(160, 224) * lerpf(0.25, 1.0, k)
	var cor: Color = v["cor"]
	var fundo := (1.0 - sai) * minf(1.0, t / 0.15)
	draw_rect(Rect2(-400, -400, 1200, 1500), Color(0.03, 0.02, 0.05, 0.45 * fundo))
	for i in 12:
		var a := t * 0.8 + TAU * i / 12.0
		draw_colored_polygon(PackedVector2Array([centro, centro + Vector2.from_angle(a - 0.09) * 230, centro + Vector2.from_angle(a + 0.09) * 230]),
			Color(cor, 0.13 * fundo))
	var r := Rect2(centro - tam / 2, tam)
	draw_rect(r.grow(3), Color(cor, 0.35 * fundo), false, 3.0)
	draw_rect(r.grow(1), Color("#140c10"))
	draw_texture_rect(v["tex"], r, false)


## Dedo fantasma: encosta em `de` (anel fechando), arrasta até `para` com rastro de 6 pontos e solta; repete a cada 1,6 s.
func _desenhar_guia() -> void:
	var de: Vector2 = guia["de"]
	var para: Vector2 = guia["para"]
	var u := fmod(guia["t"], 1.6) / 1.6
	var mov := clampf((u - 0.15) / 0.6, 0, 1)
	mov = mov * mov * (3.0 - 2.0 * mov)
	var p := de.lerp(para, mov) + Vector2(0, -sin(mov * PI) * 14)
	var al := 1.0 - clampf((u - 0.85) / 0.15, 0, 1)
	draw_arc(para, 9.0 + sin(tempo * 6.0) * 1.5, 0, TAU, 24, Color(1.0, 0.85, 0.4, 0.8), 2.0)
	for k in 6:
		var mk := clampf(mov - k * 0.05, 0, 1)
		var q := de.lerp(para, mk) + Vector2(0, -sin(mk * PI) * 14)
		draw_rect(Rect2(q.round() - Vector2.ONE, Vector2(2, 2)), Color(1, 1, 1, 0.5 * al * (1.0 - k / 6.0)))
	if u < 0.15:
		draw_arc(de, lerpf(14.0, 6.0, u / 0.15), 0, TAU, 20, Color(1, 1, 1, 0.8), 1.0)
	draw_circle(p.round(), 6.0, Color("#140c10", 0.8 * al))
	draw_circle(p.round(), 5.0, Color(1, 1, 1, 0.9 * al))
	draw_circle(p.round() + Vector2(-1, -1), 2.0, Color(1.0, 0.85, 0.4, al))


## Painel do Silas: retrato (busto) 44×58, nome na cor dele, texto digitando a 45 letras/s e "toque para continuar".
func _desenhar_tutor() -> void:
	var tu := tutor
	var texto: String = tu["texto"]
	var linhas := Fonte57.quebrar(texto, 284)
	var tem_toque: bool = tu["toque"] != ""
	var h := maxf(66.0, 22.0 + linhas.size() * 10 + (10 if tem_toque else 2))
	var ent := clampf(tu["t"] / 0.18, 0, 1)
	var r := Rect2(8, 30 - (1.0 - ent) * 12, 344, h)
	var cor: Color = tu["cor"]
	draw_rect(r.grow(2), Color("#140c10", ent))
	draw_rect(r, Color(0.1, 0.07, 0.1, 0.96 * ent))
	draw_rect(Rect2(r.position, Vector2(r.size.x, 2)), Color(cor, ent))
	draw_rect(Rect2(r.position + Vector2(0, r.size.y - 1), Vector2(r.size.x, 1)), Color(0.61, 0.45, 0.19, ent))
	var rr := Rect2(r.position + Vector2(5, 5), Vector2(44, 58))
	draw_rect(rr, cor.darkened(0.7))
	var tex := Carta.textura("retrato", "alta_magia", "png")
	if tex:
		var tw := float(tex.get_width())
		var th := float(tex.get_height())
		var src := Rect2(tw * 0.2, 0, tw * 0.6, tw * 0.6 * 58.0 / 44.0)
		src.size.y = minf(src.size.y, th)
		draw_texture_rect_region(tex, rr, src, Color(1, 1, 1, ent))
	draw_rect(rr, Color(cor, ent), false, 1.0)
	Fonte57.desenhar(self, r.position + Vector2(56, 5), tu["nome"], cor, Color("#140c10"))
	var visiveis := int(tu["t"] * 45.0)
	var y := r.position.y + 18
	for ln in linhas:
		if visiveis <= 0:
			break
		var parte: String = ln.substr(0, visiveis)
		Fonte57.desenhar(self, Vector2(r.position.x + 56, y), parte, Color("#f2e6c8"), Color("#140c10"))
		visiveis -= ln.length() + 1
		y += 10
	if tem_toque and int(tu["t"] * 45.0) >= texto.length():
		var pisca := 0.5 + 0.5 * sin(tempo * 6.0)
		var s := Sessao.t(tu["toque"]).to_upper()
		var w := PixelFonte.largura(s)
		PixelFonte.desenhar(self, Vector2(r.end.x - w - 14, r.end.y - 8), s, Color(1.0, 0.85, 0.4, pisca))
		var tp := Vector2(r.end.x - 8, r.end.y - 6 + absf(sin(tempo * 5.0)) * 1.5)
		draw_colored_polygon(PackedVector2Array([tp + Vector2(-3, -2), tp + Vector2(3, -2), tp + Vector2(0, 2)]), Color(1.0, 0.85, 0.4, pisca))
