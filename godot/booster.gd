class_name Booster
extends RefCounted
## Loja e abertura de booster (dentro do menu fluxo.gd), tudo desenhado por código em px nativos 360×640.
## Etapas: "entra" (pacote cai) → "cortar" (o dedo corta a ponta na linha tracejada) → "rasga" (ponta voa) →
## "saem" (3 cartas sobem de dentro, pacote sai) → "revelar" (toque vira cada carta) → "fim" (repetidas: guardar/trocar).

const PW := 120.0                 # pacote 120×184
const PH := 184.0
const CRIMP := 14.0               # faixas serrilhadas de cima e de baixo
const CW := 96.0                  # carta na revelação 96×134
const CH := 134.0
const X_CARTAS := [66.0, 180.0, 294.0]
const Y_CARTAS := 300.0

var f
var etapa := "loja"
var t := 0.0                      # s desde o início da etapa
var cartas: Array = []            # [{id, foil, nova, virada(bool), t_virou, trocar(bool)}]
var corte := PackedByteArray()    # colunas do pacote já cortadas (120)
var dedo := Vector2(-99, -99)
var cortando := false
var particulas: Array = []
var zoom := -1                    # carta ampliada (índice) ou -1
var _ultimo_dedo := Vector2.ZERO
var trilha := PackedVector2Array()  # caminho real do dedo no corte (o rasgo segue o dedo, em qualquer ângulo)
var inclina := 0.0                 # o pacote inclina para o lado em que o dedo corta
var peca := {}                     # ponta cortada voando: {pos, vel, rot, w}


func _init(menu) -> void:
	f = menu


func centro_pacote() -> Vector2:
	return Vector2(180, 300)


func y_corte_padrao() -> float:
	return centro_pacote().y - PH / 2 + CRIMP + 8


## Altura do rasgo: média do caminho do dedo (ou a linha tracejada antes de cortar).
func y_corte() -> float:
	if trilha.size() < 3:
		return y_corte_padrao()
	var soma := 0.0
	for q in trilha:
		soma += q.y
	return clampf(soma / trilha.size(), centro_pacote().y - PH / 2 + CRIMP + 2, centro_pacote().y - PH / 2 + 70)


# ---------------- ciclo ----------------
func comprar() -> void:
	var r: Array = Sessao.comprar_booster()
	if r.is_empty():
		f.mp.avisar(Sessao.t("Moedas insuficientes."))
		f.vibrar(30, 0.6)
		return
	cartas.clear()
	for e in r:
		cartas.append({"id": e["id"], "foil": e["foil"], "nova": e["nova"], "virada": false, "t_virou": 0.0, "trocar": false, "pos": Vector2.ZERO})
	corte = PackedByteArray()
	corte.resize(int(PW))
	trilha = PackedVector2Array()
	inclina = 0.0
	peca = {}
	particulas.clear()
	zoom = -1
	_mudar("entra")
	f._ir("booster")
	f.vibrar(25, 0.6)


func _mudar(e: String) -> void:
	etapa = e
	t = 0.0


func atualizar(delta: float) -> void:
	t += delta
	for p in particulas:
		p["v"] += Vector2(0, p.get("g", 160.0)) * delta
		p["p"] += p["v"] * delta
		p["vida"] -= delta
	particulas = particulas.filter(func(p: Dictionary) -> bool: return p["vida"] > 0.0)
	inclina = lerpf(inclina, 0.0, minf(1.0, delta * 6.0))
	if not peca.is_empty():                       # física da ponta: gravidade, giro
		peca["vel"] += Vector2(0, 900) * delta
		peca["pos"] += peca["vel"] * delta
		peca["rot"] += peca["w"] * delta
	match etapa:
		"entra":
			if t > 0.7:
				_mudar("cortar")
		"rasga":
			if t > 0.75:
				_mudar("saem")
		"saem":
			if t > 1.6:
				_mudar("revelar")
	if OS.get_environment("GD_BOOSTER_AUTO") != "":
		_auto(delta)


## Teste sem humano: corta, revela uma a uma e conclui.
var _auto_t := 0.0
func _auto(delta: float) -> void:
	_auto_t += delta
	if etapa == "cortar" and t > 0.8:
		var x0 := centro_pacote().x - PW / 2
		var u := clampf((t - 0.8) / 0.9, 0, 1)
		if not cortando:
			toque(Vector2(x0 - 6, y_corte_padrao() - 6), true)
		mover(Vector2(x0 - 6 + u * (PW + 12), y_corte_padrao() - 6 + u * 16 + sin(u * 9) * 2))   # corte em diagonal
	if etapa == "revelar" or etapa == "fim":
		for k in 3:
			if not cartas[k]["virada"] and t > 0.6 + k * 1.1:
				_virar(k)


# ---------------- entrada ----------------
func toque(p: Vector2, pressed) -> void:
	if pressed == null:
		return
	if etapa == "cortar":
		var x0 := centro_pacote().x - PW / 2
		if pressed and absf(p.y - y_corte_padrao()) < 44 and p.x > x0 - 40 and p.x < x0 + PW + 40:
			cortando = true
			dedo = p
			_ultimo_dedo = p
		elif not pressed:
			cortando = false
			dedo = Vector2(-99, -99)
		return
	if etapa == "revelar" or etapa == "fim":
		if not pressed:
			return
		if zoom >= 0:
			zoom = -1
			return
		for k in 3:
			if Rect2(Vector2(X_CARTAS[k], Y_CARTAS) - Vector2(CW, CH) / 2, Vector2(CW, CH)).has_point(p):
				if not cartas[k]["virada"]:
					_virar(k)
				else:
					zoom = k
				return


func mover(p: Vector2) -> void:
	if etapa != "cortar" or not cortando:
		return
	var x0 := centro_pacote().x - PW / 2
	var topo := centro_pacote().y - PH / 2
	if p.y < topo + CRIMP - 8 or p.y > topo + 80:
		return
	# marca as colunas entre a posição anterior e a atual; o rasgo guarda o caminho real do dedo
	var a := int(clampf(minf(_ultimo_dedo.x, p.x) - x0, 0, PW - 1))
	var b := int(clampf(maxf(_ultimo_dedo.x, p.x) - x0, 0, PW - 1))
	if p.x > x0 - 4 and p.x < x0 + PW + 4:
		trilha.append(Vector2(clampf(p.x, x0, x0 + PW), p.y))
	inclina = clampf(inclina + (p.x - _ultimo_dedo.x) * 0.0015, -0.08, 0.08)
	for x in range(a, b + 1):
		if corte[x] == 0:
			corte[x] = 1
			if randf() < 0.45:
				_faisca(Vector2(x0 + x, p.y), 3, Color("#ffb060"))
			if randf() < 0.2:
				_papel(Vector2(x0 + x, p.y), 1)
	_ultimo_dedo = p
	dedo = p
	if randf() < 0.3:
		f.vibrar(5, 0.2)
	var n := 0
	for v in corte:
		n += v
	if n >= int(PW * 0.85):
		for x in PW:
			corte[x] = 1
		cortando = false
		dedo = Vector2(-99, -99)
		_faisca(Vector2(centro_pacote().x, y_corte()), 40, Color("#ffe39a"))
		_faisca(Vector2(centro_pacote().x, y_corte()), 30, Color("#c8b0f0"))
		_papel(Vector2(centro_pacote().x, y_corte()), 18)
		peca = {"pos": Vector2.ZERO, "vel": Vector2(randf_range(60, 140) * (1 if inclina >= 0 else -1), -340), "rot": 0.0,
			"w": randf_range(3.0, 6.0) * (1 if inclina >= 0 else -1)}
		f.vibrar(45, 0.8)
		_mudar("rasga")


func _virar(k: int) -> void:
	var c: Dictionary = cartas[k]
	c["virada"] = true
	c["t_virou"] = t
	var lend: bool = Sessao.db["cartas"][c["id"]]["lendaria"]
	var p := Vector2(X_CARTAS[k], Y_CARTAS)
	if c["foil"]:
		for i in 5:
			_faisca(p, 22, Color.from_hsv(i / 5.0, 0.7, 1.0))
		Sessao.vibrar_pulsos(5, 30, 0.9, 0.06)
	elif lend:
		_faisca(p, 60, Color("#ffe39a"))
		Sessao.vibrar_pulsos(3, 30, 0.8, 0.07)
	else:
		_faisca(p, 18, Color.WHITE)
		f.vibrar(15, 0.4)
	if cartas.all(func(e: Dictionary) -> bool: return e["virada"]):
		etapa = "fim"
		f._ir("booster")              # recria os botões (repetidas, concluir)


func _faisca(p: Vector2, n: int, cor: Color) -> void:
	for i in n:
		var a := randf() * TAU
		particulas.append({"p": p, "v": Vector2.from_angle(a) * randf_range(40, 170) + Vector2(0, -40), "cor": cor,
			"vida": randf_range(0.4, 0.9), "max": 0.9, "g": 160.0, "tam": 1 + int(randf() < 0.3)})


## Pedacinhos de papel do rasgo (prateado/roxo, caem devagar girando).
func _papel(p: Vector2, n: int) -> void:
	for i in n:
		particulas.append({"p": p + Vector2(randf_range(-4, 4), 0), "v": Vector2(randf_range(-70, 70), randf_range(-140, -40)),
			"cor": [Color("#c8c8d4"), Color("#8a6aa8"), Color("#e2b85a")][randi() % 3], "vida": randf_range(0.6, 1.2), "max": 1.2,
			"g": 320.0, "tam": 2})


func alternar_troca(k: int) -> void:
	cartas[k]["trocar"] = not cartas[k]["trocar"]
	f.vibrar(10, 0.3)
	f._ir("booster")


func concluir() -> void:
	var ganho := 0
	for c in cartas:
		if c["trocar"] and not c["nova"]:
			if Sessao.trocar_repetida(c["id"], c["foil"]):
				ganho += Sessao.valor_troca(c["id"], c["foil"])
	if ganho > 0:
		f.mp.avisar(Sessao.t("+%d moedas pelas repetidas.") % ganho)
	etapa = "loja"
	f._ir("loja")


# ---------------- desenho ----------------
## Pacote holográfico: corpo com faixas arco-íris correndo, reflexo diagonal, serrilhado prata em cima e embaixo,
## logo KodeX, "BOOSTER" e moldura dourada. `topo_off`/`topo_rot`: deslocamento da ponta cortada.
func pacote(ci: CanvasItem, c: Vector2, rot: float, topo_off := Vector2.ZERO, topo_rot := 0.0, alfa := 1.0, separado := false) -> void:
	var x0 := c.x - PW / 2
	var y0 := c.y - PH / 2
	var yc := y_corte() - centro_pacote().y + c.y
	ci.draw_set_transform(c, rot, Vector2.ONE)
	var o := -Vector2(PW, PH) / 2
	# corpo
	var corpo_y0 := (yc - c.y) if separado else o.y + CRIMP
	ci.draw_rect(Rect2(o.x - 1, corpo_y0 - 1, PW + 2, o.y + PH - CRIMP - corpo_y0 + 2), Color(0.06, 0.04, 0.08, alfa))
	for x in int(PW):
		var h := fmod(x / PW * 0.8 + f.tempo * 0.15, 1.0)
		var cor := Color("#2a1838").lerp(Color.from_hsv(h, 0.55, 0.95), 0.32)
		ci.draw_line(Vector2(o.x + x, corpo_y0), Vector2(o.x + x, o.y + PH - CRIMP), Color(cor, alfa))
	# reflexo diagonal varrendo a cada 2,2 s
	var fase := fmod(f.tempo / 2.2, 1.0) * (PW + 120) - 60
	for k in 14:
		var xx := o.x + fase + k
		if xx > o.x and xx < o.x + PW:
			ci.draw_line(Vector2(xx, maxf(corpo_y0, o.y + CRIMP)), Vector2(xx - 40, o.y + PH - CRIMP), Color(1, 1, 1, 0.05 * alfa))
	# moldura dourada interna
	ci.draw_rect(Rect2(o.x + 7, o.y + CRIMP + 10, PW - 14, PH - 2 * CRIMP - 20), Color(0.89, 0.72, 0.35, 0.8 * alfa), false, 1.0)
	ci.draw_rect(Rect2(o.x + 9, o.y + CRIMP + 12, PW - 18, PH - 2 * CRIMP - 24), Color(0.61, 0.45, 0.19, 0.6 * alfa), false, 1.0)
	# logo e texto
	if f.logo_tex:
		var lw := 96.0
		var lh: float = lw * f.logo_tex.get_height() / f.logo_tex.get_width()
		ci.draw_texture_rect(f.logo_tex, Rect2(-lw / 2, -36 - lh / 2, lw, lh), false, Color(1, 1, 1, alfa))
	PixelFonte.centrado(ci, Vector2(0, 8), "BOOSTER", Color(1.0, 0.89, 0.6, alfa), 2, Color(0.08, 0.04, 0.06, alfa))
	PixelFonte.centrado(ci, Vector2(0, 26), Sessao.t("3 CARTAS"), Color(0.81, 0.88, 1.0, alfa), 1)
	for k in 3:                        # três losangos (as 3 cartas)
		var q := Vector2(-14 + k * 14, 44)
		ci.draw_colored_polygon(PackedVector2Array([q + Vector2(0, -4), q + Vector2(4, 0), q + Vector2(0, 4), q + Vector2(-4, 0)]), Color(1.0, 0.85, 0.4, alfa))
	# serrilhado de baixo
	_crimp(ci, o.y + PH - CRIMP, false, alfa)
	if not separado:
		_crimp(ci, o.y, true, alfa)
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if separado:                       # ponta cortada: faixa de cima + 8 px do corpo, com seu próprio movimento
		ci.draw_set_transform(c + topo_off, rot + topo_rot, Vector2.ONE)
		ci.draw_rect(Rect2(o.x, o.y + CRIMP, PW, (yc - c.y) - (o.y + CRIMP)), Color(Color("#2a1838").lerp(Color("#c8b0f0"), 0.3), alfa))
		_crimp(ci, o.y, true, alfa)
		ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _crimp(ci: CanvasItem, y: float, cima: bool, alfa: float) -> void:
	var o := -PW / 2
	ci.draw_rect(Rect2(o, y, PW, CRIMP), Color(0.62, 0.62, 0.68, alfa))
	for x in range(0, int(PW), 3):
		ci.draw_line(Vector2(o + x, y + 1), Vector2(o + x, y + CRIMP - 1), Color(0.42, 0.42, 0.48, alfa))
	ci.draw_line(Vector2(o, y + (CRIMP - 1 if cima else 0)), Vector2(o + PW, y + (CRIMP - 1 if cima else 0)), Color(0.85, 0.85, 0.9, alfa))
	var borda := y if cima else y + CRIMP
	for x in range(0, int(PW), 6):     # dentes do serrilhado
		var pts := PackedVector2Array([Vector2(o + x, borda), Vector2(o + x + 3, borda + (-3 if cima else 3)), Vector2(o + x + 6, borda)])
		ci.draw_colored_polygon(pts, Color(0.62, 0.62, 0.68, alfa))


func verso(ci: CanvasItem, r: Rect2, alfa := 1.0) -> void:
	ci.draw_rect(r.grow(1), Color(0.05, 0.03, 0.07, alfa))
	ci.draw_rect(r, Color(0.16, 0.1, 0.2, alfa))
	ci.draw_rect(r.grow(-4), Color(0.89, 0.72, 0.35, 0.8 * alfa), false, 1.0)
	var c := r.get_center()
	var s := r.size.x / 96.0
	for k in 3:
		var raio := (10 + k * 9) * s
		ci.draw_arc(c, raio, 0, TAU, 24, Color(0.89, 0.72, 0.35, (0.6 - k * 0.15) * alfa), 1.0)
	ci.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -8) * s, c + Vector2(8, 0) * s, c + Vector2(0, 8) * s, c + Vector2(-8, 0) * s]), Color(1.0, 0.85, 0.4, alfa))


func _tex(c: Dictionary) -> Texture2D:
	var en := Sessao.idioma == "en"
	if c["foil"]:
		var tf := Carta.textura("carta_foil_en" if en else "carta_foil", c["id"], "webp")
		if tf:
			return tf
	return Carta.textura("carta_en" if en else "carta", c["id"], "webp")


## Brilho foil sobre uma carta: faixa arco-íris diagonal correndo + estrelinhas.
func brilho_foil(ci: CanvasItem, r: Rect2) -> void:
	var fase := fmod(f.tempo / 1.6, 1.0)
	for k in 18:
		var x := r.position.x + (fase * 1.6 - 0.3) * r.size.x + k
		var cor := Color.from_hsv(fmod(k / 18.0 + f.tempo * 0.3, 1.0), 0.6, 1.0, 0.16)
		var a := Vector2(clampf(x, r.position.x, r.end.x), r.position.y)
		var b := Vector2(clampf(x - r.size.x * 0.6, r.position.x, r.end.x), r.end.y)
		if a.x > r.position.x or b.x > r.position.x:
			ci.draw_line(a, b, cor, 1.0)
	for k in 6:
		var u := fmod(f.tempo * 0.5 + k * 0.17, 1.0)
		var p := r.position + Vector2(fmod(k * 37.0, r.size.x), fmod(k * 59.0, r.size.y))
		var al := sin(u * PI)
		ci.draw_line(p - Vector2(3 * al, 0), p + Vector2(3 * al, 0), Color(1, 1, 1, al))
		ci.draw_line(p - Vector2(0, 3 * al), p + Vector2(0, 3 * al), Color(1, 1, 1, al))


func desenhar_loja() -> void:
	f._cabecalho(Sessao.t("Loja"), Sessao.t("abra boosters e complete a coleção"))
	var c := Vector2(180, 250)
	var bob := sin(f.tempo * 1.6) * 3
	f.draw_rect(Rect2(c.x - 50, c.y + PH / 2 + 4, 100, 6), Color(0, 0, 0, 0.35))
	pacote(f, c + Vector2(0, bob), sin(f.tempo * 0.9) * 0.04)
	f.mp.moeda(Vector2(158, 377))
	Fonte57.desenhar(f, Vector2(168, 374), str(Sessao.BOOSTER_PRECO), f.OURO[0], f.ESCURO)
	var linhas := [Sessao.t("3 cartas de todas as tradições"), Sessao.t("pelo menos 1 Entidade"),
		Sessao.t("Lendária: 5% por carta  ·  Foil: 2%")]
	for k in linhas.size():
		f._texto_central(Vector2(180, 456 + k * 12), linhas[k], Color(0.81, 0.88, 1.0, 0.85))
	var m := str(Sessao.moedas())
	f.mp.moeda(Vector2(338 - Fonte57.largura(m) - 10, 18))
	Fonte57.desenhar(f, Vector2(340 - Fonte57.largura(m), 15), m, f.OURO[0], f.ESCURO)
	f.mp._desenhar_aviso()


func desenhar_booster() -> void:
	f.draw_rect(Rect2(-400, -400, 1200, 1500), Color(0.02, 0.01, 0.04, 0.55))
	var c := centro_pacote()
	match etapa:
		"entra":
			var u := clampf(t / 0.6, 0, 1)
			var e := Efeitos._ease_back(u)
			pacote(f, Vector2(c.x, lerpf(-160, c.y, e)), (1.0 - u) * 0.5)
		"cortar":
			var treme := Vector2(randf_range(-1, 1), randf_range(-1, 1)) * (1.0 if cortando else 0.0)
			pacote(f, c + Vector2(0, sin(f.tempo * 1.6) * 2) + treme, inclina)
			_linha_corte(c)
		"rasga":
			var u := clampf(t / 0.7, 0, 1)
			_brilho_abertura(c, 1.0)
			var quique := sin(clampf(t / 0.25, 0, 1) * PI) * 6        # o pacote dá um tranco para baixo ao rasgar
			pacote(f, c + Vector2(0, quique), 0.0, peca.get("pos", Vector2.ZERO) - Vector2(0, quique), peca.get("rot", 0.0), 1.0, true)
		"saem":
			_cartas_saindo(c)
		"revelar", "fim":
			_cartas_reveladas()
	for p in particulas:
		var al := clampf(p["vida"] / p["max"] * 1.5, 0, 1)
		var tam: int = p["tam"]
		f.draw_rect(Rect2((p["p"] as Vector2).round(), Vector2(tam, tam)), Color(p["cor"], al))
	if etapa == "cortar":
		f._texto_central(Vector2(180, 430), Sessao.t("deslize o dedo na linha para abrir"), Color(1.0, 0.89, 0.6, 0.6 + 0.4 * sin(f.tempo * 4)))
	elif etapa == "revelar":
		f._texto_central(Vector2(180, 404), Sessao.t("toque nas cartas para revelar"), Color(1.0, 0.89, 0.6, 0.6 + 0.4 * sin(f.tempo * 4)))
	if zoom >= 0:
		_desenhar_zoom()


func _linha_corte(c: Vector2) -> void:
	var y := y_corte() + sin(f.tempo * 1.6) * 2
	var x0 := c.x - PW / 2
	var tem_trilha := trilha.size() > 1
	for x in int(PW):
		if corte[x] == 0 and not tem_trilha and (x + int(f.tempo * 12)) % 6 < 3:
			f.draw_rect(Rect2(x0 + x, y, 1, 1), Color(1, 1, 1, 0.55 + 0.45 * sin(f.tempo * 5)))
	if tem_trilha:                        # rasgo seguindo o dedo: fenda escura com borda incandescente
		for i in range(1, trilha.size()):
			var a := trilha[i - 1]
			var b := trilha[i]
			if a.distance_to(b) > 40:
				continue
			f.draw_line(a + Vector2(0, 1), b + Vector2(0, 1), Color(1.0, 0.55, 0.15, 0.85), 3.0)
			f.draw_line(a, b, Color(0.04, 0.02, 0.05), 2.0)
			f.draw_line(a + Vector2(0, -1), b + Vector2(0, -1), Color(1.0, 0.85, 0.5, 0.6), 1.0)
	# tesourinha/dedo-guia percorrendo a linha enquanto ninguém corta
	var n := 0
	for v in corte:
		n += v
	if n == 0 and not cortando:
		var u := fmod(f.tempo / 1.4, 1.0)
		var p := Vector2(x0 - 10 + u * (PW + 20), y)
		f.draw_circle(p, 6.0, Color(0.08, 0.04, 0.06, 0.7))
		f.draw_circle(p, 5.0, Color(1, 1, 1, 0.85))
		f.draw_arc(Vector2(x0 - 10, y), 9.0, 0, TAU, 20, Color(1.0, 0.85, 0.4, 0.6), 1.0)
	if dedo.x > -50:
		f.draw_circle(dedo, 4.0, Color(1.0, 0.95, 0.75, 0.9))
		f.draw_arc(dedo, 8.0 + sin(f.tempo * 20) * 1.5, 0, TAU, 20, Color(1.0, 0.85, 0.4, 0.7), 1.0)


func _brilho_abertura(c: Vector2, forca: float) -> void:
	## Luz do pacote aberto: 16 raios saindo do rasgo até fora da tela (900 px), esmaecendo na ponta, girando devagar;
	## núcleo claro pulsando sobre o rasgo.
	var o := Vector2(c.x, y_corte())
	var pul := 0.75 + 0.25 * sin(f.tempo * 9.0)
	for k in 16:
		var a: float = -PI / 2 + (k - 7.5) * 0.17 + sin(f.tempo * 1.3 + k * 0.7) * 0.06
		Efeitos.raio(f, o, a, 900, 0.045 + 0.02 * sin(f.tempo * 3 + k), Color(1.0, 0.92, 0.65, 0.42 * forca * pul))
	for k in 4:
		f.draw_circle(o, (28 - k * 6) * pul, Color(1.0, 0.95, 0.8, (0.08 + k * 0.07) * forca))


## As 3 cartas sobem de dentro do pacote (escalonadas 0,18 s), o pacote desce e sai, as cartas vão para a fileira.
func _cartas_saindo(c: Vector2) -> void:
	var desce := clampf((t - 0.7) / 0.45, 0, 1)
	_brilho_abertura(c, 1.0 - desce)
	for k in 3:
		var u := clampf((t - k * 0.18) / 0.55, 0, 1)
		var sobe := Efeitos._ease_back(u)
		var dentro := Vector2(c.x + (k - 1) * 10, y_corte() + 40)
		var fora := Vector2(c.x + (k - 1) * 22, y_corte() - 70 - k * 6)
		var p := dentro.lerp(fora, sobe)
		var v := clampf((t - 0.9) / 0.6, 0, 1)
		v = 1.0 - pow(1.0 - v, 3.0)
		p = p.lerp(Vector2(X_CARTAS[k], Y_CARTAS), v)
		var s := lerpf(0.8, 1.0, v)
		verso(f, Rect2(p - Vector2(CW, CH) * s / 2, Vector2(CW, CH) * s))
	if desce < 1.0:
		pacote(f, c + Vector2(0, desce * desce * 420), 0.0, peca.get("pos", Vector2.ZERO) - Vector2(0, desce * desce * 420), peca.get("rot", 0.0), 1.0 - desce * 0.3, true)
		# a ponta já foi; o corpo cobre a base das cartas enquanto elas sobem


func _cartas_reveladas() -> void:
	for k in 3:
		var c: Dictionary = cartas[k]
		var p := Vector2(X_CARTAS[k], Y_CARTAS + sin(f.tempo * 1.8 + k) * 2)
		var lend: bool = Sessao.db["cartas"][c["id"]]["lendaria"]
		if not c["virada"]:
			var pulso := 0.5 + 0.5 * sin(f.tempo * 4 + k)
			f.draw_rect(Rect2(p - Vector2(CW, CH) / 2, Vector2(CW, CH)).grow(3), Color(1.0, 0.85, 0.4, 0.35 * pulso), false, 2.0)
			verso(f, Rect2(p - Vector2(CW, CH) / 2, Vector2(CW, CH)))
			continue
		var dt: float = t - c["t_virou"]
		var giro := absf(cos(clampf(dt / 0.35, 0, 1) * PI))      # 1 → 0 → 1: vira no meio
		var frente := dt > 0.175
		# raios atrás das raras
		if frente and (lend or c["foil"]):
			for i in 12:
				var a: float = f.tempo * 0.7 + TAU * i / 12.0
				var cor := Color.from_hsv(fmod(i / 12.0 + f.tempo * 0.2, 1.0), 0.6, 1.0, 0.42) if c["foil"] else Color(1.0, 0.86, 0.45, 0.36)
				Efeitos.raio(f, p, a, 170, 0.1, cor)
		var tam := Vector2(CW * maxf(giro, 0.02), CH)
		var r := Rect2(p - tam / 2, tam)
		if not frente:
			verso(f, r)
			continue
		var tex := _tex(c)
		f.draw_rect(r.grow(1), f.ESCURO)
		if tex:
			f.draw_texture_rect(tex, r, false)
		if c["foil"]:
			brilho_foil(f, r)
		var borda := Color(1.0, 0.85, 0.4) if lend else Color(1, 1, 1, 0.5)
		if c["foil"]:
			borda = Color.from_hsv(fmod(f.tempo * 0.4, 1.0), 0.6, 1.0)
		f.draw_rect(r.grow(2), Color(borda, 0.5 + 0.5 * sin(f.tempo * 5)), false, 2.0)
		if dt > 0.4:
			var tag := Sessao.t("NOVA!") if c["nova"] else Sessao.t("REPETIDA")
			var cor_tag := Color("#8ae38a") if c["nova"] else Color("#ffc070")
			PixelFonte.centrado(f, p + Vector2(0, -CH / 2 - 10), tag, cor_tag, 1, f.ESCURO)
			Efeitos.selo_raridade(f, p + Vector2(0, CH / 2 + 11), Sessao.raridade(c["id"], c["foil"]), 2, f.tempo)


func _desenhar_zoom() -> void:
	var c: Dictionary = cartas[zoom]
	f.draw_rect(Rect2(-400, -400, 1200, 1500), Color(0.02, 0.01, 0.04, 0.75))
	var r := Rect2(30, 110, 300, 420)
	var tex := _tex(c)
	if tex:
		f.draw_texture_rect(tex, r, false)
	if c["foil"]:
		brilho_foil(f, r)
	f._texto_central(Vector2(180, 548), Sessao.t("toque para voltar"), Color(0.81, 0.88, 1.0, 0.8))


func botao_troca(b: Dictionary, r: Rect2, pressao: float) -> void:
	var k: int = b["carta"]
	var c: Dictionary = cartas[k]
	var trocar: bool = c["trocar"]
	var dentro: Rect2 = f._painel(r, trocar, pressao, Color("#4a3410") if trocar else Color("#241a20"))
	var s := ("+%d" % Sessao.valor_troca(c["id"], c["foil"])) if trocar else Sessao.t("Guardar")
	if trocar:
		f.mp.moeda(dentro.get_center() + Vector2(-Fonte57.largura(s) / 2.0 - 8, 0))
	f._texto_central(dentro.get_center() + Vector2(0, 1), s, f.OURO[0] if trocar else f.CREME)
