class_name Visor
extends Node2D
## Visor de carta (menus): a carta sai da grade e cresce até 300×420 no centro (alta resolução, filtro linear,
## brilho foil se for a versão UR). Gestos (a carta segue o dedo na vertical enquanto arrasta):
##   na carta: ↑ abre a lore (a carta encolhe para o topo e o painel do Codex sobe) · ↓ forte (110 px) puxa a carta
##   para baixo e ela volta para o lugar dela na grade · toque fora da carta ou no botão ‹: volta direto para o lugar.
##   na lore: o texto ROLA de verdade (arraste com inércia, roda do mouse). Chegou no fim, parou. Para sair é preciso
##   FORÇAR além da ponta (FORCA_SAIR px de dedo; vibra leve ao bater na ponta e forte ao sair): forçar no topo volta
##   para a carta, forçar no fim fecha e devolve a carta à grade. Botão ‹ ou toque na carta pequena: volta para a carta.
## Botões opcionais embaixo da carta (adicionar/tirar do deck), passados por quem abre.

const GRANDE := Rect2(30, 66, 300, 420)
const PEQUENA := Rect2(128, 22, 104, 146)
const LIMIAR := 60.0              # px de arraste para valer como swipe (carta → lore)
const LIMIAR_FECHAR := 110.0      # px para baixo para a carta voltar à grade (menos sensível que abrir a lore)
const FORCA_SAIR := 200.0         # lore: px que o dedo precisa empurrar ALÉM da ponta do texto para sair
const VOLTAR := Rect2(10, 10, 36, 36)   # botão ‹ no canto superior esquerdo

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
var rol := 0.0                    # lore: rolagem do texto (px)
var rol_vel := 0.0
var rol_max := 0.0                # calculado no desenho (altura do texto − janela)
var forca := 0.0                  # lore: dedo além da ponta (− = topo, + = fim); só arraste conta, inércia não
var _ult := Vector2.ZERO
var _t_ult := 0
var _no_botao := false


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
	rol = 0.0
	rol_vel = 0.0
	forca = 0.0
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
		if absf(rol_vel) > 1.0:                           # inércia da lore: para na ponta, sem sair
			rol = clampf(rol + rol_vel * delta, 0.0, rol_max)
			rol_vel *= pow(0.05, delta)
			if rol <= 0.0 or rol >= rol_max:
				rol_vel = 0.0
		else:
			rol_vel = 0.0
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
func _na_lore() -> bool:
	return vis_alvo > 0.5


func pressionar(p: Vector2) -> void:
	if fase != "aberto":
		return
	_no_botao = VOLTAR.grow(6).has_point(p)
	if _no_botao:
		return                                           # botão ‹: decide no soltar
	for b in _rects_botoes():
		if (b[0] as Rect2).has_point(p):
			return                                       # botão: decide no soltar
	_segura = true
	_ini = p
	_ult = p
	_t_ini = Time.get_ticks_msec()
	_t_ult = _t_ini
	rol_vel = 0.0
	forca = 0.0


func mover(p: Vector2) -> void:
	if not _segura:
		return
	if not _na_lore():
		arr = p.y - _ini.y
		return
	var dy := p.y - _ult.y
	var agora := Time.get_ticks_msec()
	rol_vel = -dy / maxf((agora - _t_ult) / 1000.0, 0.008)
	_ult = p
	_t_ult = agora
	_rolar(-dy, true)


## Lore: d > 0 desce o texto. Passando da ponta, o resto vira "força" (o painel cede 30% dela, como elástico).
func _rolar(d: float, dedo: bool) -> void:
	if forca != 0.0:                                     # já forçando: voltar o dedo devolve a força primeiro
		var antes := forca
		forca += d
		if signf(forca) != signf(antes):
			d = forca
			forca = 0.0
		else:
			d = 0.0
	if d != 0.0:
		var nova := rol + d
		if nova < 0.0 or nova > rol_max:
			rol = clampf(nova, 0.0, rol_max)
			if dedo:
				forca = nova - rol
				Sessao.vibrar(8, 0.25)                    # bateu na ponta
		else:
			rol = nova
	if not dedo:
		forca = 0.0
		return
	arr = -forca * 0.3
	if absf(forca) >= FORCA_SAIR:                        # forçou: sai (topo → carta, fim → grade)
		_segura = false
		Sessao.vibrar(35, 0.9)
		if forca < 0.0:
			vis_alvo = 0.0
			arr = 0.0
		else:
			fechar("cima")
		forca = 0.0


## Roda do mouse (PC/web) na lore.
func rodar(d: float) -> void:
	if fase == "aberto" and _na_lore():
		rol_vel = 0.0
		_rolar(d, false)


func soltar(p: Vector2) -> void:
	if fase != "aberto":
		return
	if _no_botao:
		_no_botao = false
		if VOLTAR.grow(8).has_point(p):
			_voltar()
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
	var toque := absf(dy) < 8 and Time.get_ticks_msec() - _t_ini < 400
	if _na_lore():
		forca = 0.0
		if Time.get_ticks_msec() - _t_ult > 80:
			rol_vel = 0.0                                # dedo parou antes de soltar: sem inércia
		if toque:
			if _rect_carta().has_point(p):
				_voltar()                                # toque na carta pequena: volta para a carta
			elif p.y < _y_painel():
				fechar("cima")                           # toque fora (acima do painel): volta ao Codex
		return
	if toque:
		if not _rect_carta().has_point(p):
			fechar("slot")
		return
	if dy < -LIMIAR:
		vis_alvo = 1.0
		arr = 0.0
		rol = 0.0
		Sessao.vibrar(12, 0.4)
	elif dy > LIMIAR_FECHAR:
		fechar("baixo")


## Botão ‹: da lore volta para a carta; da carta volta para o lugar dela no Codex.
func _voltar() -> void:
	if _na_lore():
		vis_alvo = 0.0
		arr = 0.0
		forca = 0.0
		Sessao.vibrar(12, 0.4)
	else:
		fechar("slot")


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
	if foil:
		var tf := Carta.textura(Sessao.pasta("carta_foil"), cid, "webp")
		if tf:
			return tf
	return Carta.textura(Sessao.pasta("carta"), cid, "webp")


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
	_botao_voltar(u)
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
			PixelFonte.centrado(self, br.get_center(), Sessao.t(bt["texto"]), Color(1.0, 0.89, 0.6, al if ok else al * 0.35), 1)
		# dica de gesto com setas quicando
		var bob := absf(sin(f.tempo * 4.0)) * 3
		PixelFonte.centrado(self, Vector2(180, 552 - bob), "^", Color(1.0, 0.85, 0.4, al), 2)
		PixelFonte.centrado(self, Vector2(180, 566), Sessao.t("DESLIZE PARA CIMA: LORE"), Color(1.0, 0.89, 0.6, al * 0.8), 1)
		PixelFonte.centrado(self, Vector2(180, 578), Sessao.t("PARA BAIXO OU TOQUE FORA: VOLTAR"), Color(0.81, 0.88, 1.0, al * 0.6), 1)


## Botão ‹ redondo (aro dourado, seta desenhada) no canto superior esquerdo.
func _botao_voltar(al: float) -> void:
	var c := VOLTAR.get_center()
	var k := 0.92 if _no_botao else 1.0
	draw_circle(c + Vector2(0, 2), 17 * k, Color(0, 0, 0, 0.45 * al))
	draw_circle(c, 17 * k, Color(0.89, 0.72, 0.35, al))
	draw_circle(c, 15.5 * k, Color(0.12, 0.07, 0.12, al))
	draw_arc(c, 13.5 * k, PI * 1.1, PI * 1.9, 12, Color(1, 1, 1, 0.12 * al), 1.5)
	var pts := PackedVector2Array([c + Vector2(4, -7) * k, c + Vector2(-4, 0) * k, c + Vector2(4, 7) * k])
	draw_polyline(pts, Color(1.0, 0.89, 0.6, al), 3.0, true)


func _painel_lore(y: float, al: float) -> void:
	var r := Rect2(10, y, 340, 640 - y + 40)
	draw_rect(r.grow(1), Color(0.89, 0.72, 0.35, 0.8 * al))
	draw_rect(r, Color(0.1, 0.07, 0.11, 0.97 * al))
	draw_rect(Rect2(150, y + 6, 60, 3), Color(0.89, 0.72, 0.35, 0.6 * al))    # alça de arrastar
	var e: Dictionary = Sessao.codex.get(cid, {})
	var nome := PixelFonte.normalizar(_nome())
	PixelFonte.centrado(self, Vector2(180, y + 22), nome, Color(1.0, 0.89, 0.6, al), 2, Color("#140c10"))
	var tit := str(Sessao.campo(e, "titulo"))
	Fonte57.desenhar(self, Vector2(180 - Fonte57.largura(tit) / 2.0, y + 36), tit, Color(0.89, 0.72, 0.35, al), Color("#140c10"))
	# janela do texto: de y+50 até 26 px antes do fim da tela; linhas fora dela não aparecem e as da borda esmaecem
	var topo := y + 50.0
	var fundo := 640.0 - 26.0
	draw_rect(Rect2(18, topo - 3, 324, 1), Color(0.89, 0.72, 0.35, 0.35 * al))
	var eg := Fonte57.grande()
	var lh := 11.0 * eg
	var itens: Array = []                                # [x, texto, cor, barra]
	if eg > 1 and Sessao.db["cartas"].has(cid):          # texto grande: o texto da carta também, legível
		for ln in Fonte57.quebrar(str(Sessao.db["cartas"][cid].get("texto", "")), 316, eg):
			itens.append([22.0, ln, Color(1.0, 0.92, 0.7), false])
		itens.append(null)
	for ln in Fonte57.quebrar(str(Sessao.campo(e, "lore")), 316, eg):
		itens.append([22.0, ln, Color(0.95, 0.9, 0.78), false])
	var cur := str(Sessao.campo(e, "curiosidade"))
	if cur != "":
		itens.append("curiosidade")
		for ln in Fonte57.quebrar(cur, 300, eg):
			itens.append([28.0, ln, Color(1.0, 0.91, 0.72), true])
	var yy := topo + 4.0 - rol
	for it in itens:
		if it == null:
			yy += 8
			continue
		if it is String:                                 # cabeçalho CURIOSIDADE
			yy += 6
			var a1 := al * _fade_janela(yy, 13.0, topo, fundo)
			if a1 > 0.0:
				draw_rect(Rect2(18, yy - 2, 324, 1), Color(0.89, 0.72, 0.35, 0.5 * a1))
				PixelFonte.desenhar(self, Vector2(22, yy + 3), Sessao.t("CURIOSIDADE"), Color(1.0, 0.85, 0.4, a1))
			yy += 13
			continue
		var a := al * _fade_janela(yy, lh, topo, fundo)
		if a > 0.0:
			if it[3]:
				draw_rect(Rect2(18, yy - 2, 3, lh), Color(0.89, 0.72, 0.35, 0.8 * a))
			var cor: Color = it[2]
			Fonte57.desenhar(self, Vector2(it[0], yy), it[1], Color(cor.r, cor.g, cor.b, a), Color(0.08, 0.05, 0.06, a), eg)
		yy += lh
	var altura := yy + rol - topo + 10.0
	rol_max = maxf(0.0, altura - (fundo - topo))
	# barra de rolagem (só se o texto não couber)
	if rol_max > 0.0:
		var h := fundo - topo
		var hb := maxf(24.0, h * h / altura)
		var yb := topo + (h - hb) * (rol / rol_max)
		draw_rect(Rect2(343, topo, 2, h), Color(1, 1, 1, 0.06 * al))
		draw_rect(Rect2(342, yb, 4, hb), Color(0.89, 0.72, 0.35, 0.7 * al))
	# força além da ponta: barra enchendo e o aviso do que vai acontecer
	var fz := clampf(absf(forca) / FORCA_SAIR, 0.0, 1.0)
	if fz > 0.05:
		var ytxt := topo + 6 if forca < 0.0 else fundo - 16
		var txt := Sessao.t("PUXE MAIS: VOLTAR À CARTA") if forca < 0.0 else Sessao.t("PUXE MAIS: FECHAR")
		draw_rect(Rect2(100, ytxt - 3, 160, 16), Color(0.05, 0.03, 0.06, 0.9 * al))
		draw_rect(Rect2(100, ytxt + 11, 160 * fz, 2), Color(1.0, 0.85, 0.4, al))
		PixelFonte.centrado(self, Vector2(180, ytxt + 4), txt, Color(1.0, 0.89, 0.6, al * minf(1.0, fz * 2.0)), 1)
	var bob := absf(sin(f.tempo * 4.0)) * 2
	var dica := Sessao.t("ARRASTE PARA LER  ·  ‹ OU TOQUE NA CARTA: VOLTAR") if rol_max > 0.0 else Sessao.t("‹ OU TOQUE NA CARTA: VOLTAR")
	PixelFonte.centrado(self, Vector2(180, 627 + bob), dica, Color(0.81, 0.88, 1.0, 0.6 * al), 1)


## Alfa de uma linha (topo em y, altura h) na janela [topo, fundo]: some fora e esmaece nos 14 px das bordas — só
## na borda que tem texto escondido (no começo do texto o topo fica nítido; no fim, o fundo).
func _fade_janela(y: float, h: float, topo: float, fundo: float) -> float:
	if y < topo - 1.0 or y + h > fundo + 1.0:
		return 0.0
	var a_topo := maxf(clampf((y - topo + 2.0) / 14.0, 0.0, 1.0), 1.0 - clampf(rol / 14.0, 0.0, 1.0))
	var a_fundo := maxf(clampf((fundo - (y + h) + 2.0) / 14.0, 0.0, 1.0), 1.0 - clampf((rol_max - rol) / 14.0, 0.0, 1.0))
	return a_topo * a_fundo


func _nome() -> String:
	if Sessao.db["cartas"].has(cid):
		return str(Sessao.db["cartas"][cid]["nome"])
	for n in Sessao.tokens:
		if Sessao.tokens[n]["id"] == cid:
			return Sessao.nome_token(n)
	return cid
