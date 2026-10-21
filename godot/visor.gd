class_name Visor
extends Node2D
## Visor de carta (menus): a carta sai da grade e cresce até 300×420 no centro (alta resolução, filtro linear,
## brilho foil se for a versão UR). Gestos (a carta segue o dedo na vertical enquanto arrasta):
##   na carta: ↑ abre a lore (a carta encolhe para o topo e o painel do Codex sobe) · ↓ puxa a carta para baixo e ela
##   volta para o lugar dela na grade · toque fora da carta: ela volta direto para o lugar.
##   na lore:  ↓ volta para a carta · ↑ fecha (painel sai por cima e a carta volta para a grade).
## Botões opcionais embaixo da carta (adicionar/tirar do deck), passados por quem abre.

const GRANDE := Rect2(30, 66, 300, 420)
const PEQUENA := Rect2(128, 22, 104, 146)
const LIMIAR := 60.0              # px de arraste para valer como swipe

var f
var cid := ""
var foil := false
var slot := Rect2()               # lugar da carta na grade (para onde volta)
var fase := ""                    # "" | "aberto" | "fechando"
var t := 0.0
var vis := 0.0                    # 0 = carta, 1 = lore (animado)
var vis_alvo := 0.0
var arr := 0.0                    # deslocamento vertical do dedo
var _ini := Vector2.ZERO
var _segura := false
var _t_ini := 0
var fecha_t := 0.0
var fecha_modo := ""              # "slot" | "baixo" | "cima"
var _r_saida := Rect2()
var botoes: Array = []            # [{texto, acao: Callable, ativo: Callable -> bool}]
var info := Callable()            # () -> String: linha de contagem (no deck / livres)


func _ready() -> void:
	z_index = 50
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR


func aberto() -> bool:
	return fase != ""


func abrir(id: String, de: Rect2, bts: Array = [], inf := Callable()) -> void:
	cid = id
	slot = de
	foil = int(Sessao.perfil["foils"].get(id, 0)) > 0 and Sessao.tem_foil(id)
	botoes = bts
	info = inf
	fase = "aberto"
	t = 0.0
	vis = 0.0
	vis_alvo = 0.0
	arr = 0.0
	Sessao.vibrar(12, 0.4)


func fechar(modo: String) -> void:
	if fase != "aberto":
		return
	_r_saida = _rect_carta()
	fecha_modo = modo
	fase = "fechando"
	fecha_t = 0.0
	Sessao.vibrar(10 if modo == "slot" else 18, 0.4)


func _process(delta: float) -> void:
	if not aberto():
		return
	t += delta
	vis = lerpf(vis, vis_alvo, minf(1.0, delta * 12.0))
	if not _segura:
		arr = lerpf(arr, 0.0, minf(1.0, delta * 14.0))
	if fase == "fechando":
		fecha_t += delta
		if fecha_t >= 0.42:
			fase = ""
	queue_redraw()


# ---------------- geometria ----------------
static func _ease_back(u: float) -> float:
	var c := 1.70158
	return 1.0 + (c + 1.0) * pow(u - 1.0, 3.0) + c * pow(u - 1.0, 2.0)


static func _lerp_r(a: Rect2, b: Rect2, u: float) -> Rect2:
	return Rect2(a.position.lerp(b.position, u), a.size.lerp(b.size, u))


## Retângulo da carta agora (abrindo, entre carta e lore, seguindo o dedo).
func _rect_carta() -> Rect2:
	var base := _lerp_r(GRANDE, PEQUENA, vis)
	var u := clampf(t / 0.32, 0, 1)
	var r := _lerp_r(slot, base, _ease_back(u))
	var puxa := arr if vis < 0.5 else arr * 0.35          # na lore a carta acompanha menos
	if vis < 0.5 and arr < 0.0:
		puxa = arr * 0.5                                  # para cima resiste um pouco (vai abrir a lore)
	r.position.y += puxa
	return r


func _y_painel() -> float:
	return lerpf(660.0, 182.0, vis) + (arr if vis >= 0.5 else maxf(0.0, -arr) * -0.6)


# ---------------- entrada ----------------
func pressionar(p: Vector2) -> void:
	if fase != "aberto":
		return
	for b in _rects_botoes():
		if (b[0] as Rect2).has_point(p):
			return                                       # botão: decide no soltar
	_segura = true
	_ini = p
	_t_ini = Time.get_ticks_msec()


func mover(p: Vector2) -> void:
	if _segura:
		arr = p.y - _ini.y


func soltar(p: Vector2) -> void:
	if fase != "aberto":
		return
	if not _segura:
		for b in _rects_botoes():
			if (b[0] as Rect2).grow(4).has_point(p):
				var bt: Dictionary = b[1]
				if not bt.has("ativo") or (bt["ativo"] as Callable).call():
					(bt["acao"] as Callable).call()
		return
	_segura = false
	var dy := p.y - _ini.y
	if absf(dy) < 8 and Time.get_ticks_msec() - _t_ini < 400:      # toque
		if vis < 0.5 and not _rect_carta().has_point(p):
			fechar("slot")
		return
	if vis < 0.5:
		if dy < -LIMIAR:
			vis_alvo = 1.0
			arr = 0.0
			Sessao.vibrar(12, 0.4)
		elif dy > LIMIAR:
			fechar("baixo")
	else:
		if dy > LIMIAR:
			vis_alvo = 0.0
			arr = 0.0
			Sessao.vibrar(12, 0.4)
		elif dy < -LIMIAR:
			fechar("cima")


func _rects_botoes() -> Array:
	var out: Array = []
	if vis > 0.3 or botoes.is_empty():
		return out
	var w := 300.0 / botoes.size() - 6
	for k in botoes.size():
		out.append([Rect2(30 + k * (w + 6) + 3, 512, w, 26), botoes[k]])
	return out


# ---------------- desenho ----------------
func _tex() -> Texture2D:
	var en := Sessao.idioma == "en"
	if foil:
		var tf := Carta.textura("carta_foil_en" if en else "carta_foil", cid, "webp")
		if tf:
			return tf
	return Carta.textura("carta_en" if en else "carta", cid, "webp")


func _draw() -> void:
	if not aberto():
		return
	var u := clampf(t / 0.25, 0, 1)
	var fade := 1.0
	var r := _rect_carta()
	if fase == "fechando":
		var uf := clampf(fecha_t / 0.4, 0, 1)
		var e := uf * uf * (3.0 - 2.0 * uf)
		fade = 1.0 - e
		match fecha_modo:
			"baixo":                                     # continua descendo e faz a curva até o lugar na grade
				var meio := Rect2(_r_saida.position + Vector2(0, 150), _r_saida.size * 0.8)
				var a := _lerp_r(_r_saida, meio, e)
				var b := _lerp_r(meio, slot, e)
				r = _lerp_r(a, b, e)
			"cima":                                      # sobe junto com o painel e desce até a grade
				var alto := Rect2(_r_saida.position + Vector2(0, -90), _r_saida.size)
				r = _lerp_r(_lerp_r(_r_saida, alto, e), _lerp_r(alto, slot, e), e)
			_:
				r = _lerp_r(_r_saida, slot, e)
	draw_rect(Rect2(-400, -400, 1200, 1500), Color(0.02, 0.01, 0.04, 0.9 * u * fade))
	# painel da lore
	var yp := _y_painel()
	if fase == "fechando" and fecha_modo == "cima":
		yp -= clampf(fecha_t / 0.3, 0, 1) * 500
	if yp < 640 and (vis > 0.02 or fecha_modo == "cima"):
		_painel_lore(yp, minf(1.0, vis * 1.4) * (fade if fecha_modo != "cima" else 1.0))
	# raios suaves atrás da carta grande
	if vis < 0.5 and fase == "aberto":
		for k in 10:
			Efeitos.raio(self, r.get_center(), t * 0.3 + TAU * k / 10.0, 260, 0.1, Color(1.0, 0.86, 0.45, 0.1 * u * (1.0 - vis * 2)))
	# carta (inclina levemente com o arraste)
	var rot := clampf(arr / 900.0, -0.08, 0.08) if fase == "aberto" else 0.0
	draw_set_transform(r.get_center(), rot, Vector2.ONE)
	var rr := Rect2(-r.size / 2, r.size)
	draw_rect(Rect2(rr.position + Vector2(4, 7), rr.size), Color(0, 0, 0, 0.5))
	var tex := _tex()
	if tex:
		draw_texture_rect(tex, rr, false)
	if foil:
		f.bo.brilho_foil(self, rr)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if fase != "aberto":
		return
	var al := u * (1.0 - vis)
	if not cid.begins_with("tok_"):
		Efeitos.selo_raridade(self, Vector2(r.end.x - 14, r.position.y - 10), Sessao.raridade(cid, foil), 2, f.tempo)
	if al > 0.05:
		if info.is_valid():
			PixelFonte.centrado(self, Vector2(180, 500), info.call(), Color(0.81, 0.88, 1.0, al), 1)
		for b in _rects_botoes():
			var br: Rect2 = b[0]
			var bt: Dictionary = b[1]
			var ok: bool = not bt.has("ativo") or (bt["ativo"] as Callable).call()
			draw_rect(br.grow(1), Color(0.08, 0.05, 0.07, al))
			draw_rect(br, Color(0.24, 0.12, 0.2, al) if ok else Color(0.14, 0.12, 0.14, al))
			draw_rect(Rect2(br.position, Vector2(br.size.x, 1)), Color(0.89, 0.72, 0.35, al if ok else al * 0.3))
			PixelFonte.centrado(self, br.get_center() + Vector2(0, 1), Sessao.t(bt["texto"]), Color(1.0, 0.89, 0.6, al if ok else al * 0.35), 1)
		# dica de gesto com setas quicando
		var bob := absf(sin(f.tempo * 4.0)) * 3
		PixelFonte.centrado(self, Vector2(180, 552 - bob), "^", Color(1.0, 0.85, 0.4, al), 2)
		PixelFonte.centrado(self, Vector2(180, 566), Sessao.t("DESLIZE PARA CIMA: LORE"), Color(1.0, 0.89, 0.6, al * 0.8), 1)
		PixelFonte.centrado(self, Vector2(180, 578), Sessao.t("PARA BAIXO OU TOQUE FORA: VOLTAR"), Color(0.81, 0.88, 1.0, al * 0.6), 1)


func _painel_lore(y: float, al: float) -> void:
	var r := Rect2(10, y, 340, 640 - y + 40)
	draw_rect(r.grow(1), Color(0.89, 0.72, 0.35, 0.8 * al))
	draw_rect(r, Color(0.1, 0.07, 0.11, 0.97 * al))
	draw_rect(Rect2(150, y + 6, 60, 3), Color(0.89, 0.72, 0.35, 0.6 * al))    # alça de arrastar
	var e: Dictionary = Sessao.codex.get(cid, {})
	var en := Sessao.idioma == "en"
	var nome := PixelFonte.normalizar(_nome())
	PixelFonte.centrado(self, Vector2(180, y + 22), nome, Color(1.0, 0.89, 0.6, al), 2, Color("#140c10"))
	var tit := str(e.get("titulo_en" if en else "titulo_pt", ""))
	Fonte57.desenhar(self, Vector2(180 - Fonte57.largura(tit) / 2.0, y + 36), tit, Color(0.89, 0.72, 0.35, al), Color("#140c10"))
	var yy := y + 54
	var eg := Fonte57.grande()
	if eg > 1 and Sessao.db["cartas"].has(cid):          # texto grande: o texto da carta também, legível
		for ln in Fonte57.quebrar(str(Sessao.db["cartas"][cid].get("texto", "")), 316, eg):
			Fonte57.desenhar(self, Vector2(22, yy), ln, Color(1.0, 0.92, 0.7, al), Color("#140c10"), eg)
			yy += 11 * eg
		yy += 8
	for ln in Fonte57.quebrar(str(e.get("lore_en" if en else "lore_pt", "")), 316, eg):
		Fonte57.desenhar(self, Vector2(22, yy), ln, Color(0.95, 0.9, 0.78, al), Color("#140c10"), eg)
		yy += 11 * eg
	var cur := str(e.get("curiosidade_en" if en else "curiosidade_pt", ""))
	if cur != "":
		yy += 6
		draw_rect(Rect2(18, yy - 2, 324, 1), Color(0.89, 0.72, 0.35, 0.5 * al))
		PixelFonte.desenhar(self, Vector2(22, yy + 3), Sessao.t("CURIOSIDADE"), Color(1.0, 0.85, 0.4, al))
		yy += 13
		for ln in Fonte57.quebrar(cur, 300, eg):
			draw_rect(Rect2(18, yy - 2, 3, 11 * eg), Color(0.89, 0.72, 0.35, 0.8 * al))
			Fonte57.desenhar(self, Vector2(28, yy), ln, Color(1.0, 0.91, 0.72, al), Color("#140c10"), eg)
			yy += 11 * eg
	var bob := absf(sin(f.tempo * 4.0)) * 2
	PixelFonte.centrado(self, Vector2(180, 624 + bob), Sessao.t("BAIXO: CARTA  -  CIMA: FECHAR"), Color(0.81, 0.88, 1.0, 0.6 * al), 1)


func _nome() -> String:
	if Sessao.db["cartas"].has(cid):
		return str(Sessao.db["cartas"][cid]["nome"])
	for n in Sessao.tokens:
		if Sessao.tokens[n]["id"] == cid:
			return str(Sessao.tokens[n]["en"]) if Sessao.idioma == "en" else str(n)
	return cid
