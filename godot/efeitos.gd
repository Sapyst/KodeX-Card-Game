class_name Efeitos
extends Node2D
## Camada de efeitos (não recebe luz): partículas de pixel, números de dano, anéis, clarão de tela, faixas de vitória/derrota
## e o cursor da demonstração. Tudo em px nativos (360×640).

var particulas: Array[Dictionary] = []
var popups: Array[Dictionary] = []
var aneis: Array[Dictionary] = []
var cortes: Array[Dictionary] = []      # rasgos de golpe: {p, dir, cor, t, dur, larg}
var fantasmas: Array[Dictionary] = []   # rastro da carta em investida: {p, rot, tam, cor, t}
var feixes: Array[Dictionary] = []      # raio de efeito viajando da fonte ao alvo: {de, para, cor, t, dur}
var choques: Array[Dictionary] = []     # onda de choque elíptica no chão: {p, r, cor, t, dur}
var clarao := Color(0, 0, 0, 0)
var faixa := ""                        # "VITÓRIA" / "DERROTA" / ""
var faixa_t := 0.0
var fim := {}                           # retrato de quem venceu subindo ao centro: {tex, nome, sub, vitoria, de, perdedor}
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


## Faíscas: riscos luminosos (comprimento ∝ velocidade, 0,035 s de rastro) com arrasto de 4%/quadro e gravidade
## 120 px/s². `dir` ≠ 0 concentra o leque num cone de ±0,7 rad naquela direção (golpe saindo pelo outro lado do alvo).
func faiscas(p: Vector2, n: int = 16, cor := Color("#ffe39a"), dir := Vector2.ZERO) -> void:
	for i in n:
		var a := randf() * TAU if dir == Vector2.ZERO else dir.angle() + randf_range(-0.7, 0.7)
		var vel := randf_range(60, 140) * (1.6 if dir != Vector2.ZERO else 1.0)
		particulas.append({"p": p, "v": Vector2.from_angle(a) * vel, "cor": cor if i % 3 else Color.WHITE,
			"vida": randf_range(0.2, 0.4), "max": 0.4, "g": 120.0, "tam": 1 + int(i % 4 == 0), "risco": true})


## Partículas que sobem (buff, cura) ou escorrem (debuff) de dentro de um retângulo: 1–2 px, 0,5–0,9 s, sem gravidade.
func motes(r: Rect2, cor: Color, sobe := true, n := 14) -> void:
	for i in n:
		var pp := Vector2(randf_range(r.position.x, r.end.x), randf_range(r.position.y, r.end.y))
		var vy := randf_range(-38, -18) if sobe else randf_range(14, 30)
		particulas.append({"p": pp, "v": Vector2(randf_range(-6, 6), vy), "cor": cor if i % 3 else Color.WHITE,
			"vida": randf_range(0.5, 0.9), "max": 0.9, "g": 0.0 if sobe else 30.0, "tam": 1 + int(i % 3 == 0), "brilho": true})


## Rasgo de golpe: lâmina crescente de 2·larg px cruzando `p` perpendicular a `dir`, abre em 0,08 s e some até 0,3 s.
func corte(p: Vector2, dir: Vector2, cor := Color("#fff4d0"), larg := 26.0) -> void:
	cortes.append({"p": p, "dir": dir.normalized(), "cor": cor, "t": 0.0, "dur": 0.3, "larg": larg})


## Rastro da investida: silhueta da carta (tam em px de tela) que esmaece em 0,16 s.
func fantasma(p: Vector2, rot: float, tam: Vector2, cor := Color(1.0, 0.9, 0.7)) -> void:
	fantasmas.append({"p": p, "rot": rot, "tam": tam, "cor": cor, "t": 0.0})


## Raio de efeito: a cabeça viaja de `de` a `para` em `dur` s com cauda de 40% do caminho; brilho de 3 camadas.
func feixe(de: Vector2, para: Vector2, cor: Color, dur := 0.16) -> void:
	feixes.append({"de": de, "para": para, "cor": cor, "t": 0.0, "dur": dur})


## Onda de choque no chão: elipse (altura 0,5× a largura, perspectiva da mesa) que cresce até r em 0,32 s.
func choque(p: Vector2, cor: Color, r := 40.0) -> void:
	choques.append({"p": p, "r": r, "cor": cor, "t": 0.0, "dur": 0.32})


func estilhacar(centro: Vector2, cores: Array, larg: int, alt: int) -> void:
	## a carta se desfaz em 36 cacos de 3–6 px que giram (±9 rad/s) voando para fora e caindo, mais 30 grãos de 1–2 px
	for i in 36:
		var off := Vector2(randf_range(-larg / 2.0, larg / 2.0), randf_range(-alt / 2.0, alt / 2.0))
		particulas.append({"p": centro + off, "v": off.normalized() * randf_range(40, 120) + Vector2(0, -50),
			"cor": cores[i % cores.size()], "vida": randf_range(0.55, 1.0), "max": 1.0, "g": 260.0,
			"tam": randi_range(3, 6), "caco": true, "rot": randf() * TAU, "vr": randf_range(-9, 9)})
	for i in 30:
		var off := Vector2(randf_range(-larg / 2.0, larg / 2.0), randf_range(-alt / 2.0, alt / 2.0))
		particulas.append({"p": centro + off, "v": off.normalized() * randf_range(30, 110) + Vector2(0, -40),
			"cor": cores[i % cores.size()], "vida": randf_range(0.45, 0.9), "max": 0.9, "g": 220.0, "tam": 1 + i % 2})


func confete(n: int = 80) -> void:
	var cores := [Color("#ffe39a"), Color("#ff6a8a"), Color("#7aa8ff"), Color("#8ae38a"), Color("#e2b85a"), Color.WHITE]
	for i in n:
		particulas.append({"p": Vector2(randf_range(20, 340), -10), "v": Vector2(randf_range(-30, 30), randf_range(40, 120)),
			"cor": cores[i % cores.size()], "vida": randf_range(1.8, 3.2), "max": 3.2, "g": 25.0, "tam": 2})


func cinzas(n: int = 60) -> void:
	for i in n:
		particulas.append({"p": Vector2(randf_range(0, 360), randf_range(-40, 640)), "v": Vector2(randf_range(-8, 8), randf_range(10, 30)),
			"cor": Color("#6a6470") if i % 2 else Color("#3a3640"), "vida": randf_range(2.0, 3.5), "max": 3.5, "g": 0.0, "tam": 1})


## Texto flutuante: entra com pulo (escala 1,7 → 1 em 0,16 s, ease-out-back), sobe 22 px desacelerando e some
## nos últimos 0,35 s. Números de dano ("-N") tremem 1,5 px no primeiro 0,1 s. Nunca sai da tela (margem 6 px).
func numero(p: Vector2, texto: String, cor: Color, esc: int = 2) -> void:
	popups.append({"p": p, "texto": texto, "cor": cor, "vida": 1.0, "esc": esc, "t": 0.0, "dano": texto.begins_with("-")})


func anel(p: Vector2, cor: Color, r_max: float = 30.0) -> void:
	aneis.append({"p": p, "r": 2.0, "rmax": r_max, "cor": cor, "vida": 0.34})


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
		if p.has("risco"):
			p["v"] *= exp(-delta * 2.4)
		if p.has("caco"):
			p["rot"] += p["vr"] * delta
		p["p"] += p["v"] * delta
		p["vida"] -= delta
	particulas = particulas.filter(func(p: Dictionary) -> bool: return p["vida"] > 0.0)
	for nv in nuvens:
		nv["t"] += delta
		nv["p"] += (nv["v"] as Vector2) * delta
		nv["v"] *= 0.90
	nuvens = nuvens.filter(func(nv: Dictionary) -> bool: return nv["t"] < nv["vida"])
	for p in popups:
		p["t"] += delta
		p["vida"] -= delta
	popups = popups.filter(func(p: Dictionary) -> bool: return p["vida"] > 0.0)
	for a in aneis:
		a["r"] = lerpf(a["r"], a["rmax"], 1.0 - exp(-delta * 16.0))
		a["vida"] -= delta
	aneis = aneis.filter(func(a: Dictionary) -> bool: return a["vida"] > 0.0)
	for lst in [cortes, fantasmas, feixes, choques]:
		for e in lst:
			e["t"] += delta
	cortes = cortes.filter(func(e: Dictionary) -> bool: return e["t"] < e["dur"])
	fantasmas = fantasmas.filter(func(e: Dictionary) -> bool: return e["t"] < 0.16)
	feixes = feixes.filter(func(e: Dictionary) -> bool: return e["t"] < e["dur"] * 1.8)
	choques = choques.filter(func(e: Dictionary) -> bool: return e["t"] < e["dur"])
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
	for e in choques:
		var u: float = e["t"] / e["dur"]
		var r: float = e["r"] * (1.0 - pow(1.0 - u, 3.0))
		_elipse(e["p"], r, 0.5, Color(e["cor"], 0.75 * (1.0 - u)), 3.0 * (1.0 - u) + 0.6)
		_elipse(e["p"], r * 0.7, 0.5, Color(e["cor"], 0.3 * (1.0 - u)), 1.0)
	for a in aneis:
		var al: float = a["vida"] / 0.34
		draw_arc(a["p"], a["r"], 0, TAU, 40, Color(a["cor"], al), 0.6 + 2.0 * al)
		draw_arc(a["p"], a["r"] * 0.82, 0, TAU, 40, Color(a["cor"], al * 0.3), 1.0)
	for f in fantasmas:
		var al: float = 0.28 * (1.0 - f["t"] / 0.16)
		draw_set_transform(f["p"], f["rot"], Vector2.ONE)
		draw_rect(Rect2(-(f["tam"] as Vector2) / 2.0, f["tam"]), Color(f["cor"], al))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	for fx in feixes:
		_desenhar_feixe(fx)
	for p in particulas:
		var al := clampf(p["vida"] / p["max"] * 1.5, 0, 1)
		var t: int = p["tam"]
		var cor: Color = p["cor"]
		if p.has("risco"):
			var v: Vector2 = p["v"]
			var cauda: Vector2 = p["p"] - v * 0.035
			draw_line(cauda, p["p"], Color(cor, al * 0.35), t + 1.6)
			draw_line(cauda.lerp(p["p"], 0.4), p["p"], Color(cor.lightened(0.4), al), t * 0.8 + 0.4)
		elif p.has("caco"):                       # caco girando: largura varia com cos(rot) = efeito de virar no ar
			var w := t * (0.35 + 0.65 * absf(cos(p["rot"])))
			draw_set_transform(p["p"], p["rot"] * 0.5, Vector2.ONE)
			draw_rect(Rect2(-w / 2.0 - 0.5, -t / 2.0 - 0.5, w + 1, t + 1), Color(0.06, 0.03, 0.05, al * 0.8))
			draw_rect(Rect2(-w / 2.0, -t / 2.0, w, t), Color(cor, al))
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		elif p.has("brilho"):
			draw_circle(p["p"], t + 1.5, Color(cor, al * 0.25))
			draw_circle(p["p"], t * 0.6, Color(cor.lightened(0.5), al))
		else:
			draw_rect(Rect2(p["p"] as Vector2, Vector2(t, t)), Color(cor, al))
	for e in cortes:
		_desenhar_corte(e)
	var tela := _tela()
	for p in popups:
		var al := clampf(p["vida"] / 0.35, 0, 1)
		var esc: int = p["esc"]
		var t: float = p["t"]
		var u := clampf(t / 0.16, 0.0, 1.0)
		var s := 1.0 + 0.7 * (1.0 - _back(u)) if u < 1.0 else 1.0
		var pos: Vector2 = p["p"] + Vector2(0, -22.0 * (1.0 - exp(-t * 3.2)))
		if p["dano"] and t < 0.1:
			pos.x += sin(t * 140.0) * 1.5
		var txt: String = Sessao.t(p["texto"])
		# rótulos (SILÊNCIO, DANO 1, +2/+1 pequeno…) ficam sobre uma plaquinha escura; os de esc 1 crescem 1,5×
		var rotulo := esc == 1 or not txt.substr(0, 1) in ["-", "+", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
		if esc == 1:
			s *= 1.5
		var meia := PixelFonte.largura(txt, esc) * s / 2.0 + 6.0
		pos.x = clampf(pos.x, tela.position.x + meia, tela.end.x - meia)
		pos.y = clampf(pos.y, tela.position.y + 6.0 * esc, tela.end.y - 6.0 * esc)
		draw_set_transform(pos, 0.0, Vector2(s, s))
		if rotulo:
			var lw := PixelFonte.largura(txt, esc) + 8.0 * esc
			var pl := Rect2(-lw / 2.0, -5.5 * esc, lw, 11 * esc)
			Carta.rr(self, pl, 3.0 * esc, Color(0.08, 0.04, 0.06, 0.72 * al))
			Carta.rr_linha(self, pl, 3.0 * esc, Color(p["cor"], 0.5 * al), 0.6 * esc)
		PixelFonte.centrado(self, Vector2.ZERO, txt, Color(p["cor"], al), esc, Color(0.08, 0.04, 0.06, al))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
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
		PixelFonte.centrado(self, rd.get_center(), Sessao.t(dica), Color("#ffe39a"))
	# botões de escolha (face, PULAR); itens com "tex" são cartas da galeria
	for b in escolha:
		if b.has("tex"):
			continue
		var r: Rect2 = b["rect"]
		draw_rect(r.grow(1), Color("#140c10"))
		draw_rect(r, Color("#3d1f33"))
		draw_rect(Rect2(r.position, Vector2(r.size.x, 1)), Color("#e2b85a"))
		draw_rect(Rect2(r.position + Vector2(0, r.size.y - 1), Vector2(r.size.x, 1)), Color("#9c7430"))
		PixelFonte.centrado(self, r.get_center(), Sessao.t(str(b["texto"])), Color("#ffe39a"), 1)
	if not vitrine.is_empty():
		_desenhar_vitrine()
	if com_visor and Sessao.largo and (zoom == null or not is_instance_valid(zoom)):
		_desenhar_visor()
	if zoom != null and is_instance_valid(zoom):
		_desenhar_zoom()
	if not fala.is_empty():
		_desenhar_fala_oponente()
	if clarao.a > 0.0:
		draw_rect(Rect2(-400, -400, 1200, 1500), clarao)
	if faixa != "":
		_desenhar_faixa()
		if not fim.is_empty():
			_desenhar_fim()
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
			raio(self, c, a, 460 * ent, 0.08, Color(1.0, 0.86, 0.45, 0.26))
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


## Carta segurada: a carta inteira (imagem do idioma) + painel com nome, tipo · custo · ATK/DEF, palavras-chave e o
## texto de regra em letra legível (a imagem sozinha fica pequena demais no celular). Em pé: carta em cima, painel
## embaixo. Formato largo: carta à esquerda e painel à direita. "Texto grande": tudo em 2×.
func _desenhar_zoom() -> void:
	var c := zoom
	var tex := Carta.textura(Sessao.pasta("carta"), c.id, "webp") if c.id != "" else null
	if tex:
		draw_rect(Rect2(-1400, -400, 3200, 1500), Color(0.04, 0.02, 0.06, 0.62))
		var esc := Fonte57.grande()
		var r: Rect2
		var pr: Rect2
		if Sessao.largo:
			var tl := _tela()
			var pw := minf(360.0, tl.size.x - 300.0 - 60.0)
			var x0 := roundf(180.0 - (300.0 + 16.0 + pw) / 2.0)
			r = Rect2(x0, 110, 300, 420)
			pr = Rect2(x0 + 316, 150, pw, 0)
		elif esc == 2:
			r = Rect2(95, 20, 170, 238)
			pr = Rect2(12, r.end.y + 10, 336, 0)
		else:
			r = Rect2(70, 24, 220, 308)
			pr = Rect2(12, r.end.y + 10, 336, 0)
		draw_rect(r.grow(2), Color("#140c10"))
		draw_texture_rect(tex, r, false)
		_painel_carta(c, pr.position, pr.size.x, esc if not Sessao.largo else 2)
		if c.tipo == "entidade" and c.dano > 0:
			var s := Sessao.t("VIDA ATUAL %d" % maxi(c.vida(), 0))
			var w := PixelFonte.largura(s, 2) + 12
			var cy := r.position.y - 12 if r.position.y > 30 else r.position.y + 14
			draw_rect(Rect2(r.get_center().x - w / 2.0, cy - 8, w, 16), Color("#5a1a1a"))
			PixelFonte.centrado(self, Vector2(r.get_center().x, cy), s, Color("#ffd0d0"), 2)
		return
	var tipo_txt: String = Sessao.t({"entidade": "ENTIDADE", "selo": "SELO", "rito": "RITO", "reliquia": "RELÍQUIA"}.get(c.tipo, c.tipo.to_upper()))
	var linha2 := "%s  -  CUSTO %d" % [tipo_txt, c.custo]
	if c.tipo == "entidade":
		linha2 += "  -  ATK %d  DEF %d" % [c.atk, maxi(c.vida(), 0)]
	if c.lendaria:
		linha2 += "  -  LENDÁRIA"
	var kws := ""
	for k in c.keywords:
		kws += Sessao.t({"guarda": "GUARDA", "impeto": "ÍMPETO", "furtivo": "FURTIVO", "renascer": "RENASCER"}.get(k, "")) + " "
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


func _tela() -> Rect2:
	var vs := get_viewport_rect().size
	return Rect2(Vector2(180, 320) - vs / 2.0, vs)


## Painel de texto da carta em (p, largura w): nome, tipo · custo · ATK/DEF, palavras-chave e o texto de regra
## (Fonte57 em `esc`). Devolve a altura desenhada.
func _painel_carta(c: Carta, p: Vector2, w: float, esc: int) -> float:
	var kw := ""
	for k in c.keywords:
		kw += Sessao.t({"guarda": "GUARDA", "impeto": "ÍMPETO", "furtivo": "FURTIVO", "renascer": "RENASCER"}.get(k, "")) + "  "
	var info := "%s  ·  %s %d" % [Sessao.t({"entidade": "ENTIDADE", "selo": "SELO", "rito": "RITO", "reliquia": "RELÍQUIA"}.get(c.tipo, "")), Sessao.t("CUSTO"), c.custo]
	if c.tipo == "entidade":
		info += "  ·  ATK %d  DEF %d" % [c.atk, maxi(c.vida(), 0)]
	var tw := w - 20
	var nomes := Fonte57.quebrar(c.nome, int(tw), esc)
	var linhas := Fonte57.quebrar(c.texto, int(tw), esc)
	var infos := Fonte57.quebrar(info, int(tw), esc)
	var kws := Fonte57.quebrar(kw.strip_edges(), int(tw), esc) if kw != "" else PackedStringArray()
	var lh := 10 * esc
	var h := 10 + nomes.size() * (lh + 2) + 4 + (infos.size() + kws.size()) * lh + 6 + linhas.size() * lh + 8
	var r := Rect2(p, Vector2(w, h))
	draw_rect(r.grow(2), Color("#140c10"))
	draw_rect(r, Color("#24161f"))
	draw_rect(Rect2(r.position, Vector2(r.size.x, 1)), Color("#e2b85a"))
	draw_rect(Rect2(r.position + Vector2(0, r.size.y - 1), Vector2(r.size.x, 1)), Color("#9c7430"))
	var y := p.y + 8
	for ln in nomes:
		Fonte57.desenhar(self, Vector2(p.x + 10, y), ln, Color("#ffe39a"), Color("#140c10"), esc)
		y += lh + 2
	y += 4
	for ln in infos:
		Fonte57.desenhar(self, Vector2(p.x + 10, y), ln, Color("#cfe0ff"), Color("#140c10"), esc)
		y += lh
	for ln in kws:
		Fonte57.desenhar(self, Vector2(p.x + 10, y), ln, Color("#ffd9a0"), Color("#140c10"), esc)
		y += lh
	y += 6
	for ln in linhas:
		Fonte57.desenhar(self, Vector2(p.x + 10, y), ln, Color("#f2e6c8"), Color("#140c10"), esc)
		y += lh
	return h


## Formato largo: visor fixo na lateral direita com a última carta tocada (ou com o mouse em cima), legível.
var inspecionada: Carta = null
var com_visor := false                   # só a camada de cima (a do chão também é um Efeitos)


func _desenhar_visor() -> void:
	var tl := _tela()
	var x0 := 372.0
	var w := tl.end.x - 12.0 - x0
	if w < 150.0:
		return
	var c := inspecionada
	var cw := minf(200.0, w - 20.0)
	var cx := roundf(x0 + w / 2.0)
	if c == null or not is_instance_valid(c):
		var dica := Fonte57.quebrar(Sessao.t("Toque numa carta ou passe o mouse por cima para ler aqui."), int(w - 20), 2)
		for k in dica.size():
			Fonte57.desenhar(self, Vector2(roundf(cx - Fonte57.largura(dica[k], 2) / 2.0), 280 + k * 22), dica[k], Color(0.6, 0.55, 0.6), Color(0, 0, 0, 0), 2)
		return
	var tex := Carta.textura(Sessao.pasta("carta"), c.id, "webp") if c.id != "" and (c.virada_para_cima or c.dono == 0) else null
	var r := Rect2(roundf(cx - cw / 2.0), 24, cw, roundf(cw * 1.4))
	draw_rect(r.grow(2), Color("#140c10"))
	if tex:
		draw_texture_rect(tex, r, false)
		_painel_carta(c, Vector2(x0 + 4, r.end.y + 10), w - 8, 2)
	else:
		draw_rect(r, Color("#3d1f33"))
		PixelFonte.centrado(self, r.get_center(), "?", Color("#e2b85a"), 4)


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
		raio(self, centro, a, 260, 0.09, Color(cor, 0.22 * fundo))
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
	if tutor.get("grande", false):
		_desenhar_tutor_grande()
		return
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


## Silas falando (espera toque): corpo inteiro 187×260 à esquerda, com a base da arte no rodapé, respirando 1,5 px;
## a caixa de texto (encostada na base) sai de trás
## dele para a direita (0,2 s) e o texto digita a 45 letras/s numa coluna de 188 px (Fonte57, linhas de 11 px).
func _desenhar_tutor_grande() -> void:
	var tu := tutor
	var t: float = tu["t"] + 0.3
	var texto: String = tu["texto"]
	var cor: Color = tu["cor"]
	var ent := clampf(t / 0.25, 0, 1)
	ent = 1.0 - pow(1.0 - ent, 3.0)
	draw_rect(Rect2(-400, -400, 1200, 1500), Color(0.03, 0.02, 0.05, 0.55 * ent))
	var tx0 := 158.0
	var larg_txt := 188
	var linhas := Fonte57.quebrar(texto, larg_txt)
	var h := 30.0 + linhas.size() * 11 + 14
	var cy := 596.0 - h / 2                          # caixa junto dos pés do Silas, acima do degradê da base
	var abre := clampf((t - 0.12) / 0.22, 0, 1)
	abre = 1.0 - pow(1.0 - abre, 3.0)
	var bx0 := 96.0
	var bx1 := lerpf(bx0 + 20, 352.0, abre)
	var caixa := Rect2(bx0, cy - h / 2, bx1 - bx0, h)
	if abre > 0.0:
		draw_rect(caixa.grow(2), Color("#140c10"))
		draw_rect(caixa, Color(0.1, 0.07, 0.1, 0.97))
		draw_rect(Rect2(caixa.position, Vector2(caixa.size.x, 2)), cor)
		draw_rect(Rect2(caixa.position + Vector2(0, caixa.size.y - 2), Vector2(caixa.size.x, 2)), Color(0.61, 0.45, 0.19))
		draw_rect(Rect2(caixa.end.x - 2, caixa.position.y, 2, caixa.size.y), Color(0.61, 0.45, 0.19))
	# Silas na frente da caixa
	var tex := Carta.textura("retrato", "alta_magia", "png")
	if tex:
		var alt := 260.0
		var lw := alt * tex.get_width() / tex.get_height()
		var resp := sin(tempo * 1.5) * 1.5
		var pos := Vector2(70 - lw / 2 - (1.0 - ent) * 140, 646 - alt + resp)   # base da arte no rodapé
		draw_texture_rect(tex, Rect2(pos + Vector2(3, 4), Vector2(lw, alt)), false, Color(0, 0, 0, 0.45 * ent))
		draw_texture_rect(tex, Rect2(pos, Vector2(lw, alt)), false, Color(1, 1, 1, ent))
	_degrade_base(ent)
	if abre < 1.0:
		return
	# placa do nome sobre a borda de cima da caixa
	var nome: String = tu["nome"]
	var wn := Fonte57.largura(nome) + 14
	var placa := Rect2(tx0 - 4, caixa.position.y - 7, wn, 13)
	draw_rect(placa.grow(1), Color("#140c10"))
	draw_rect(placa, cor.darkened(0.45))
	draw_rect(Rect2(placa.position, Vector2(placa.size.x, 1)), cor)
	Fonte57.desenhar(self, placa.position + Vector2(7, 3), nome, Color("#ffe39a"), Color("#140c10"))
	var visiveis := int(tu["t"] * 45.0)
	var y := caixa.position.y + 14
	for ln in linhas:
		if visiveis <= 0:
			break
		Fonte57.desenhar(self, Vector2(tx0, y), ln.substr(0, visiveis), Color("#f6ecd4"), Color("#140c10"))
		visiveis -= ln.length() + 1
		y += 11
	if int(tu["t"] * 45.0) >= texto.length():
		var pisca := 0.5 + 0.5 * sin(tempo * 6.0)
		var s := Sessao.t(tu["toque"]).to_upper()
		var w := PixelFonte.largura(s)
		PixelFonte.desenhar(self, Vector2(caixa.end.x - w - 16, caixa.end.y - 10), s, Color(1.0, 0.85, 0.4, pisca))
		var tp := Vector2(caixa.end.x - 9, caixa.end.y - 8 + absf(sin(tempo * 5.0)) * 1.5)
		draw_colored_polygon(PackedVector2Array([tp + Vector2(-3, -2), tp + Vector2(3, -2), tp + Vector2(0, 2)]), Color(1.0, 0.85, 0.4, pisca))


## Degradê preto na base das falas: transparente em y 598, preto em y 640 e preto até o fim real da tela
## (celulares mais altos que 9:16 mostram mais área abaixo) — esconde o corte da arte do Silas.
func _degrade_base(al: float) -> void:
	var inv := get_canvas_transform().affine_inverse()
	var tela := get_viewport_rect().size
	var a := inv * Vector2.ZERO
	var b := inv * tela
	var x0 := minf(a.x, b.x) - 10
	var x1 := maxf(a.x, b.x) + 10
	var fundo := maxf(a.y, b.y) + 10
	var preto := Color(0.02, 0.01, 0.03, al)
	var zero := Color(0.02, 0.01, 0.03, 0.0)
	draw_polygon(PackedVector2Array([Vector2(x0, 598), Vector2(x1, 598), Vector2(x1, 640), Vector2(x0, 640)]),
		PackedColorArray([zero, zero, preto, preto]))
	draw_rect(Rect2(x0, 640, x1 - x0, maxf(0.0, fundo - 640)), preto)



## Raio de luz que esmaece até a ponta: triângulo com cor cheia na origem e transparente nas duas pontas.
static func raio(ci: CanvasItem, origem: Vector2, ang: float, comp: float, abertura: float, cor: Color) -> void:
	var fim := Color(cor, 0.0)
	ci.draw_polygon(PackedVector2Array([origem, origem + Vector2.from_angle(ang - abertura) * comp, origem + Vector2.from_angle(ang + abertura) * comp]),
		PackedColorArray([cor, fim, fim]))



## Selo de raridade: C (prata), R (azul com reflexo), SR (ouro pulsando), UR (arco-íris correndo + faíscas).
static func selo_raridade(ci: CanvasItem, centro: Vector2, sigla: String, esc: int, tempo: float) -> void:
	var w := PixelFonte.largura(sigla, esc) + 8 * esc
	var h := 5 * esc + 6
	var r := Rect2(centro - Vector2(w, h) / 2, Vector2(w, h)).abs()
	var fundo: Color = {"C": Color("#4a4a56"), "R": Color("#1e3c78"), "SR": Color("#7a5418"), "UR": Color("#3a1850")}.get(sigla, Color("#4a4a56"))
	var texto: Color = {"C": Color("#e8e8f0"), "R": Color("#bfe0ff"), "SR": Color("#ffe39a"), "UR": Color.WHITE}.get(sigla, Color.WHITE)
	if sigla == "SR":                                  # halo dourado pulsando
		var pul := 0.5 + 0.5 * sin(tempo * 4.0)
		ci.draw_rect(r.grow(3), Color(1.0, 0.82, 0.35, 0.35 * pul), false, 3.0)
	ci.draw_rect(r.grow(1), Color("#140c10"))
	ci.draw_rect(r, fundo)
	if sigla == "UR":                                  # fundo arco-íris correndo
		for x in int(r.size.x):
			ci.draw_line(Vector2(r.position.x + x, r.position.y), Vector2(r.position.x + x, r.end.y),
				Color.from_hsv(fmod(x / r.size.x + tempo * 0.6, 1.0), 0.75, 0.85))
	if sigla == "R" or sigla == "UR":                  # reflexo varrendo
		var fx := r.position.x + fmod(tempo * 0.8, 1.6) / 1.6 * (r.size.x + 20) - 10
		for k in 3:
			var xx := fx + k
			if xx > r.position.x and xx < r.end.x:
				ci.draw_line(Vector2(xx, r.position.y), Vector2(xx, r.end.y), Color(1, 1, 1, 0.45))
	ci.draw_rect(Rect2(r.position, Vector2(r.size.x, 1)), Color(1, 1, 1, 0.35))
	PixelFonte.centrado(ci, r.get_center() + Vector2(0, 0.5), sigla, texto, esc, Color("#140c10"))
	if sigla == "UR":                                  # faíscas em volta
		for k in 4:
			var u := fmod(tempo * 0.9 + k * 0.25, 1.0)
			var p := r.get_center() + Vector2(cos(k * 1.7) * (r.size.x / 2 + 4), sin(k * 2.3) * (r.size.y / 2 + 3))
			var a := sin(u * PI)
			ci.draw_line(p - Vector2(3 * a, 0), p + Vector2(3 * a, 0), Color(1, 1, 1, a))
			ci.draw_line(p - Vector2(0, 3 * a), p + Vector2(0, 3 * a), Color(1, 1, 1, a))


## Fim da partida: o retrato de quem venceu sai da moldura da mesa e sobe ao centro (0,6 s, com pulo), dobra de tamanho e
## ganha moldura: louros dourados na vitória, brilho vermelho na derrota. Embaixo da faixa, quem venceu quem.
## O retrato de quem perdeu (na mesa) fica cinza e trincado.
func _desenhar_fim() -> void:
	var u := clampf((faixa_t - 0.25) / 0.6, 0.0, 1.0)
	var e := 1.0 + 2.70158 * pow(u - 1.0, 3.0) + 1.70158 * pow(u - 1.0, 2.0)     # ease-out-back
	var vit: bool = fim["vitoria"]
	var empate: bool = fim.get("empate", false)
	var perd: Rect2 = fim.get("perdedor", Rect2())
	if perd.size.x > 0 and not empate:                   # quem perdeu: cinza e trincado
		draw_rect(perd, Color(0.12, 0.1, 0.14, 0.75 * u))
		var c0 := perd.get_center()
		for k in 4:
			var a := TAU * k / 4.0 + 0.4
			draw_line(c0, c0 + Vector2.from_angle(a) * perd.size.x * 0.6, Color(0.05, 0.03, 0.06, u), 1.0)
			draw_line(c0 + Vector2.from_angle(a) * perd.size.x * 0.3, c0 + Vector2.from_angle(a + 0.5) * perd.size.x * 0.45, Color(0.05, 0.03, 0.06, u), 1.0)
	if u <= 0.0:
		return
	var tam := Vector2(36, 48).lerp(Vector2(72, 96), e)
	var centro: Vector2 = (fim["de"] as Vector2).lerp(Vector2(180, 214), e)
	var r := Rect2((centro - tam / 2).round(), tam.round())
	var ouro := Color("#ffe39a")
	if vit:
		for k in 14:                                     # louros: duas hastes de folhas em arco por fora da moldura
			for lado in [-1, 1]:
				var a: float = PI * 0.5 + float(lado) * (0.35 + k * 0.17)
				var p := r.get_center() + Vector2(cos(a) * (r.size.x * 0.5 + 14), sin(a) * (r.size.y * 0.5 + 12))
				var folha := PackedVector2Array([p + Vector2(0, -4), p + Vector2(2.5, 0), p + Vector2(0, 4), p + Vector2(-2.5, 0)])
				var giro := Transform2D(a + PI * 0.5, Vector2.ZERO)
				for i in folha.size():
					folha[i] = p + giro * (folha[i] - p)
				if k < int(14 * u):
					draw_colored_polygon(folha, ouro if k % 2 == 0 else Color("#e2b85a"))
	else:
		var pul := 0.5 + 0.5 * sin(faixa_t * 5.0)
		draw_rect(r.grow(8), Color(0.8, 0.1, 0.1, 0.18 + 0.12 * pul))
		draw_rect(r.grow(5), Color(0.9, 0.2, 0.15, 0.25 + 0.15 * pul))
	draw_rect(r.grow(4), Color("#140c10"))
	draw_rect(r.grow(3), Color("#9c7430") if vit or empate else Color("#5a1a1a"))
	draw_rect(r.grow(2), Color("#e2b85a") if vit or empate else Color("#a03030"), false, 1.0)
	draw_rect(r, Color("#1a1218"))
	if fim.get("tex") != null:
		draw_texture_rect(fim["tex"], r, false)
	else:                                                # sem foto: silhueta
		var cs := r.get_center()
		var k2 := r.size.x / 36.0
		draw_circle(cs + Vector2(0, -7) * k2, 7.0 * k2, Color("#3a2c36"))
		draw_colored_polygon(PackedVector2Array([cs + Vector2(-13, 22) * k2, cs + Vector2(-11, 5) * k2, cs + Vector2(0, 1) * k2,
			cs + Vector2(11, 5) * k2, cs + Vector2(13, 22) * k2]), Color("#3a2c36"))
	if faixa_t > 0.85:                                   # nome e linha embaixo da faixa
		var a2 := clampf((faixa_t - 0.85) / 0.3, 0.0, 1.0)
		var nome: String = fim["nome"]
		var w := Fonte57.largura(nome) + 20
		var pr := Rect2(roundf(180 - w / 2.0), r.end.y - 5, w, 13)
		draw_rect(pr.grow(1), Color(0.08, 0.05, 0.06, a2))
		draw_rect(pr, Color(0.35, 0.22, 0.15, a2))
		draw_rect(Rect2(pr.position, Vector2(pr.size.x, 1)), Color(0.55, 0.38, 0.25, a2))
		Fonte57.desenhar(self, Vector2(roundf(180 - Fonte57.largura(nome) / 2.0), pr.position.y + 4), nome, Color(0.14, 0.07, 0.04, a2), Color(0.6, 0.45, 0.3, a2 * 0.8))
		var sub: String = fim["sub"]
		var ws := Fonte57.largura(sub) + 16
		draw_rect(Rect2(roundf(180 - ws / 2.0), 322, ws, 13), Color(0.05, 0.03, 0.06, 0.85 * a2))
		Fonte57.desenhar(self, Vector2(roundf(180 - Fonte57.largura(sub) / 2.0), 326), sub, Color(0.95, 0.88, 0.7, a2) if vit else Color(0.75, 0.7, 0.75, a2), Color(0.05, 0.03, 0.05, a2))


## ease-out-back: passa 10% do alvo e volta.
static func _back(u: float) -> float:
	var c1 := 1.70158
	return 1.0 + (c1 + 1.0) * pow(u - 1.0, 3.0) + c1 * pow(u - 1.0, 2.0)


func _elipse(c: Vector2, r: float, achat: float, cor: Color, larg: float) -> void:
	var pts := PackedVector2Array()
	for k in 41:
		var a := TAU * k / 40.0
		pts.append(c + Vector2(cos(a) * r, sin(a) * r * achat))
	draw_polyline(pts, cor, larg, true)


## Lâmina crescente: 13 pontos ao longo da perpendicular, espessura máxima 5 px no meio, abaulada 6 px para `dir`;
## abre do centro para as pontas em 0,06 s e esmaece depois. Núcleo branco + halo da cor.
func _desenhar_corte(e: Dictionary) -> void:
	var u: float = e["t"] / e["dur"]
	var abre := clampf(u / 0.28, 0.0, 1.0)
	var al := 1.0 - clampf((u - 0.28) / 0.72, 0.0, 1.0)
	var d: Vector2 = e["dir"]
	var n := Vector2(-d.y, d.x)
	var L: float = e["larg"] * abre
	var c: Vector2 = e["p"] + d * 4.0 * u
	for camada in 2:
		var esp := 5.0 if camada == 0 else 2.2
		var cor: Color = Color(e["cor"], 0.45 * al) if camada == 0 else Color(1, 1, 1, al)
		var cima := PackedVector2Array()
		var baixo := PackedVector2Array()
		for k in 13:
			var s := (k / 12.0) * 2.0 - 1.0
			var curva := (1.0 - s * s) * 6.0
			var w := (1.0 - s * s) * esp * 1.4 * (1.0 - 0.5 * u)
			var base := c + n * s * L + d * curva
			cima.append(base + d * w / 2.0)
			baixo.append(base - d * w / 2.0)
		baixo.reverse()
		var poly := cima + baixo
		if Geometry2D.triangulate_polygon(poly).size() > 0:
			draw_colored_polygon(poly, cor)


func _desenhar_feixe(fx: Dictionary) -> void:
	var u: float = fx["t"] / fx["dur"]
	var cab := clampf(u, 0.0, 1.0)
	var cauda := clampf(u - 0.4, 0.0, 1.0) if u < 1.0 else clampf(0.6 + (u - 1.0) / 0.8 * 0.4, 0.0, 1.0)
	var de: Vector2 = fx["de"]
	var para: Vector2 = fx["para"]
	var a := de.lerp(para, cauda)
	var b := de.lerp(para, cab)
	var al := 1.0 if u < 1.0 else 1.0 - (u - 1.0) / 0.8
	var cor: Color = fx["cor"]
	var tremido := Vector2(-(b - a).y, (b - a).x).normalized() * sin(fx["t"] * 90.0) * 0.8
	draw_line(a, b, Color(cor, 0.22 * al), 9.0)
	draw_line(a + tremido, b + tremido, Color(cor, 0.6 * al), 4.0)
	draw_line(a, b, Color(cor.lightened(0.7), al), 1.6)
	draw_circle(b, 4.5, Color(cor, 0.4 * al))
	draw_circle(b, 2.2, Color(1, 1, 1, al))
