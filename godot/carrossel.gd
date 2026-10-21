class_name Carrossel
extends Node2D
## Carrossel do cemitério: as cartas saem da pilha uma a uma e se abrem num leque horizontal; arrastar rola com
## inércia e trava na carta mais próxima (mola); as cartas de lado giram (achatam), encolhem e escurecem.
## Modo "ver" (tocar na pilha) ou "escolher" (reviver: tocar na carta do centro escolhe). Ao fechar, as cartas
## voltam para a pilha; a escolhida sobe e some num clarão. px nativos 360×640.

signal selecionado(idx)

const PASSO := 64.0               # distância entre cartas no leque (px por índice)
const CW := 188.0                 # carta do centro 188×263 (maior, para ler o texto)
const CH := 263.0
const CY := 300.0

var itens: Array = []             # [{tex, nome}]
var origem := Vector2.ZERO        # pilha de onde saem e para onde voltam
var modo := ""                    # "" (fechado) | "ver" | "escolher"
var titulo := ""
var pos := 0.0                    # índice no centro (contínuo)
var vel := 0.0
var t := 0.0                      # s desde a abertura
var fechando := -1.0              # s desde o início do fechamento (-1 = aberto)
var escolhido := -1
var tam_pilha := Vector2(28, 39)  # tamanho da carta na pilha da mesa (abre de lá e volta exatamente para lá)
var _segura := false
# zoom da carta do centro: pinça (2 dedos) ou roda do mouse; com zoom, arrastar move a carta; um toque volta
var zoom := 1.0
var zoom_alvo := 1.0
var pan := Vector2.ZERO
var _dedos := {}
var _dist_ini := 0.0
var _zoom_ini := 1.0
var _pincou := false
const ZOOM_MAX := 2.6
var _ini := Vector2.ZERO
var _ult := Vector2.ZERO
var _moveu := false
var _ult_t := 0
var _btn := Rect2(130, 556, 100, 24)


func _ready() -> void:
	z_index = 960
	var mat := CanvasItemMaterial.new()
	mat.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	material = mat
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR


func aberto() -> bool:
	return modo != ""


func abrir(lista: Array, de: Vector2, m: String, tit: String) -> void:
	itens = lista
	origem = de
	modo = m
	titulo = tit
	pos = float(maxi(0, lista.size() - 1))      # começa pela carta do topo da pilha (a última que caiu)
	vel = 0.0
	t = 0.0
	fechando = -1.0
	escolhido = -1
	Sessao.vibrar(15, 0.4)


func fechar() -> void:
	if fechando >= 0.0:
		return
	fechando = 0.0
	Sessao.vibrar(10, 0.3)
	await get_tree().create_timer(0.55).timeout
	modo = ""
	itens = []
	queue_redraw()                    # apaga o último quadro desenhado (senão o carrossel fica "congelado" na mesa)


## Escolha (reviver): abre, espera o toque na carta do centro (ou PULAR) e devolve o índice ou -1.
func escolher(lista: Array, de: Vector2, tit: String) -> int:
	abrir(lista, de, "escolher", tit)
	var r: int = await selecionado
	await fechar()
	return r


func _process(delta: float) -> void:
	if not aberto():
		return
	t += delta
	zoom = lerpf(zoom, zoom_alvo, minf(1.0, delta * 14.0))
	if zoom_alvo <= 1.0:
		pan = pan.lerp(Vector2.ZERO, minf(1.0, delta * 14.0))
	if fechando >= 0.0:
		fechando += delta
	elif not _segura:
		pos += vel * delta
		vel *= pow(0.02, delta)
		var alvo := clampf(roundf(pos), 0, itens.size() - 1)
		if absf(vel) < 3.0:                         # mola até a carta mais próxima
			pos = lerpf(pos, alvo, minf(1.0, delta * 12.0))
		if pos < -0.3 or pos > itens.size() - 0.7:  # borda elástica
			vel *= 0.5
			pos = lerpf(pos, clampf(pos, 0, itens.size() - 1), minf(1.0, delta * 10.0))
	queue_redraw()


# ---------------- entrada ----------------
func zoom_ativo() -> bool:
	return zoom_alvo > 1.02


func _zerar_zoom() -> void:
	zoom_alvo = 1.0
	Sessao.vibrar(8, 0.3)


## Recebe o evento cru (com o ponto já em coordenadas da mesa): roda do mouse, pinça e arraste com zoom.
func evento(ev: InputEvent, p: Vector2) -> void:
	if fechando >= 0.0:
		return
	if ev is InputEventMouseButton and (ev.button_index == MOUSE_BUTTON_WHEEL_UP or ev.button_index == MOUSE_BUTTON_WHEEL_DOWN):
		if ev.pressed:
			zoom_alvo = clampf(zoom_alvo * (1.15 if ev.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0 / 1.15), 1.0, ZOOM_MAX)
		return
	if ev is InputEventScreenTouch:
		if ev.pressed:
			_dedos[ev.index] = p
			if _dedos.size() == 2:
				var v: Array = _dedos.values()
				_dist_ini = maxf(10.0, (v[0] as Vector2).distance_to(v[1]))
				_zoom_ini = zoom_alvo
				_pincou = true
				_segura = false
			elif _dedos.size() == 1:
				pressionar(p)
		else:
			_dedos.erase(ev.index)
			if _dedos.is_empty():
				if _pincou:
					_pincou = false
					_segura = false
				else:
					soltar(p)
		return
	if ev is InputEventScreenDrag:
		var antes: Vector2 = _dedos.get(ev.index, p)
		_dedos[ev.index] = p
		if _dedos.size() >= 2:
			var v: Array = _dedos.values()
			zoom_alvo = clampf(_zoom_ini * (v[0] as Vector2).distance_to(v[1]) / _dist_ini, 1.0, ZOOM_MAX)
		elif zoom_ativo():
			pan += p - antes
			if (p - _ini).length() > 6:
				_moveu = true
		else:
			mover(p)
		return
	if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT:
		if ev.pressed:
			pressionar(p)
		else:
			soltar(p)
		return
	if ev is InputEventMouseMotion and _segura:
		if zoom_ativo():
			pan += p - _ult
			_ult = p
			if (p - _ini).length() > 6:
				_moveu = true
		else:
			mover(p)


func pressionar(p: Vector2) -> void:
	if fechando >= 0.0:
		return
	_segura = true
	_ini = p
	_ult = p
	_moveu = false
	vel = 0.0
	_ult_t = Time.get_ticks_msec()


func mover(p: Vector2) -> void:
	if not _segura or fechando >= 0.0:
		return
	var dx := p.x - _ult.x
	if absf(p.x - _ini.x) > 6:
		_moveu = true
	pos -= dx / PASSO
	var agora := Time.get_ticks_msec()
	var dt := maxf(0.008, (agora - _ult_t) / 1000.0)
	vel = lerpf(vel, -dx / PASSO / dt, 0.5)
	_ult_t = agora
	if int(roundf(pos)) != int(roundf(pos + dx / PASSO)):
		Sessao.vibrar(4, 0.15)
	_ult = p


func soltar(p: Vector2) -> void:
	if not _segura:
		return
	_segura = false
	if _moveu:
		return
	vel = 0.0
	if zoom_ativo():                                   # com zoom, um toque volta ao tamanho normal
		_zerar_zoom()
		return
	if _btn.grow(4).has_point(p):
		if modo == "escolher":
			selecionado.emit(-1)
		else:
			fechar()
		return
	var centro := int(roundf(pos))
	var rc := Rect2(Vector2(180, CY) - Vector2(CW, CH) / 2, Vector2(CW, CH))
	if rc.has_point(p):
		if modo == "escolher":
			escolhido = centro
			Sessao.vibrar_pulsos(2, 25, 0.7, 0.06)
			selecionado.emit(centro)
		return
	if p.y > CY - CH / 2 and p.y < CY + CH / 2:     # tocou numa carta de lado: rola até ela
		var alvo := clampf(centro + (1 if p.x > 180 else -1), 0, itens.size() - 1)
		vel = (alvo - pos) * 6.0
	elif modo == "ver":
		fechar()


# ---------------- desenho ----------------
static func _ease_back(u: float) -> float:
	var c := 1.70158
	return 1.0 + (c + 1.0) * pow(u - 1.0, 3.0) + c * pow(u - 1.0, 2.0)


func _draw() -> void:
	if not aberto():
		return
	var n := itens.size()
	var fecha := clampf(fechando / 0.45, 0, 1) if fechando >= 0.0 else 0.0
	var fundo := minf(1.0, t / 0.2) * (1.0 - fecha)
	draw_rect(Rect2(-400, -400, 1200, 1500), Color(0.02, 0.01, 0.04, 0.8 * fundo))
	# leque de luz atrás da carta do centro
	for k in 10:
		Efeitos.raio(self, Vector2(180, CY), t * 0.3 + TAU * k / 10.0, 230, 0.12, Color(0.78, 0.68, 1.0, 0.12 * fundo))
	PixelFonte.centrado(self, Vector2(180, 118), Sessao.t(titulo), Color(1.0, 0.89, 0.6, fundo), 2, Color("#140c10"))
	PixelFonte.centrado(self, Vector2(180, 134), "%d / %d" % [clampi(int(roundf(pos)) + 1, 1, n), n], Color(0.81, 0.88, 1.0, fundo), 1)
	# ordem: de fora para dentro (a do centro por cima)
	var ordem: Array = range(n)
	ordem.sort_custom(func(a: int, b: int) -> bool: return absf(a - pos) > absf(b - pos))
	for k in ordem:
		var off: float = float(k) - pos
		var a_off := absf(off)
		if a_off > 4.5:
			continue
		# posição no leque
		var x: float = 180.0 + signf(off) * (minf(a_off, 1.0) * 118.0 + maxf(0.0, a_off - 1.0) * 26.0)
		var esc := 1.0 - minf(a_off, 3.0) * 0.16
		var giro := 1.0 - minf(a_off, 1.6) * 0.38           # achatamento horizontal = carta girada
		var alvo_c := Vector2(x, CY + minf(a_off, 3.0) * 10.0)
		var alvo_t := Vector2(CW * esc * giro, CH * esc)
		# abrir: sai da pilha escalonado (0,035 s por carta, a do centro primeiro); fechar: volta
		# abrir: sai do topo da pilha para baixo (a última que entrou sai primeiro), cada uma do seu lugar no monte
		var na_pilha := origem + Vector2(0, -minf(k, 12))
		var atraso := minf(n - 1 - k, 10) * 0.035
		var u := clampf((t - atraso) / 0.4, 0, 1)
		var e := _ease_back(u)
		var c := na_pilha.lerp(alvo_c, e)
		var tam := tam_pilha.lerp(alvo_t, e)
		var rot := (1.0 - u) * 0.25 * signf(off)
		if fecha > 0.0:
			# fechar: voltam em ordem (de baixo para cima) e assentam alinhadas, sem girar, no lugar de cada uma
			var uf := clampf((fechando - minf(k, 10) * 0.02) / 0.3, 0, 1)
			uf = uf * uf * (3.0 - 2.0 * uf)
			if k == escolhido:                                   # a escolhida sobe e some
				c = alvo_c + Vector2(0, -uf * 120)
				tam = alvo_t * (1.0 + uf * 0.25)
			else:
				c = alvo_c.lerp(na_pilha, uf)
				tam = alvo_t.lerp(tam_pilha, uf)
				rot = 0.0
		var al := 1.0 if k != escolhido or fecha <= 0.0 else 1.0 - fecha
		if fecha <= 0.0:
			if a_off < 0.5:
				tam *= zoom
				c += pan
			else:
				al *= 1.0 - clampf((zoom - 1.0) * 1.4, 0.0, 0.9)      # com zoom, as de lado somem
		var esc_cor := 1.0 - minf(a_off, 3.0) * 0.22
		draw_set_transform(c, rot, Vector2.ONE)
		var r := Rect2(-tam / 2, tam)
		draw_rect(Rect2(r.position + Vector2(3, 5), r.size), Color(0, 0, 0, 0.45 * al))
		draw_rect(r.grow(1), Color(0.05, 0.03, 0.06, al))
		var it: Dictionary = itens[k]
		if it.get("tex") != null:
			draw_texture_rect(it["tex"], r, false, Color(esc_cor, esc_cor, esc_cor, al))
		else:
			draw_rect(r, Color(0.2, 0.15, 0.2, al))
			PixelFonte.centrado(self, Vector2.ZERO, PixelFonte.normalizar(str(it["nome"])).substr(0, 12), Color(1, 1, 1, al), 1)
		if a_off < 0.5 and fecha <= 0.0:
			var pul := 0.55 + 0.45 * sin(t * 5.0)
			var cor := Color(1.0, 0.85, 0.4) if modo == "escolher" else Color(0.78, 0.68, 1.0)
			draw_rect(r.grow(2), Color(cor, pul), false, 2.0)
			draw_rect(r.grow(5), Color(cor, pul * 0.35), false, 2.0)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if fecha <= 0.0 and n > 0:
		var centro := clampi(int(roundf(pos)), 0, n - 1)
		var some := 1.0 - clampf((zoom - 1.0) * 3.0, 0.0, 1.0)          # textos de baixo somem com o zoom
		var nome := PixelFonte.normalizar(str(itens[centro]["nome"]))
		PixelFonte.centrado(self, Vector2(180, CY + CH / 2 + 18), nome, Color(1.0, 0.95, 0.85, fundo * some), 1, Color("#140c10"))
		var dica := Sessao.t("toque na carta para reviver") if modo == "escolher" else Sessao.t("deslize para os lados")
		if zoom_ativo():
			dica = Sessao.t("toque para voltar")
		elif fecha <= 0.0:
			dica += "  -  " + Sessao.t("pinça para ampliar")
		var y_dica := CY + CH / 2 + 32 if not zoom_ativo() else 96.0      # com zoom, a dica vai para o topo
		var al_dica := (0.6 + 0.4 * sin(t * 4)) * (some if not zoom_ativo() else 1.0)
		PixelFonte.centrado(self, Vector2(180, y_dica), dica, Color(0.81, 0.88, 1.0, al_dica), 1, Color("#140c10"))
		# setas nas bordas
		var bob := sin(t * 5) * 2
		if centro > 0:
			PixelFonte.centrado(self, Vector2(14 - bob, CY), "<", Color(1.0, 0.85, 0.4, 0.8), 3)
		if centro < n - 1:
			PixelFonte.centrado(self, Vector2(346 + bob, CY), ">", Color(1.0, 0.85, 0.4, 0.8), 3)
		draw_rect(_btn.grow(1), Color("#140c10"))
		draw_rect(_btn, Color("#3d1f33"))
		draw_rect(Rect2(_btn.position, Vector2(_btn.size.x, 1)), Color("#e2b85a"))
		PixelFonte.centrado(self, _btn.get_center(), Sessao.t("PULAR") if modo == "escolher" else Sessao.t("FECHAR"), Color("#ffe39a"), 1)
