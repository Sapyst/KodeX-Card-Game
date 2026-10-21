class_name MesaHud
extends Node2D
## Interface por cima da partida (coordenadas do mundo da mesa, 360 de largura, câmera em mesa.CENTRO):
## - botão de menu (pausa: continuar, regras, animações, vibração, desistir) no canto de cima à esquerda;
## - botão de emotes no canto de cima à direita: 4 falas curtas; o oponente às vezes responde;
## - histórico: as últimas 6 jogadas em miniatura na coluna da esquerda (toque = carta grande com legenda);
## - prévia de dano ao arrastar um ataque (números e caveira de quem morre);
## - marcas do mulligan; entrada especial das Lendárias (raios dourados, carta grande, faixa "LENDÁRIA").
## O menu pausa a mesa com Engine.time_scale = 0, então o desenho dele não depende de animação.

const MINI := Vector2(24, 33)            # miniatura do histórico
const PASSO_H := 37.0
const MAX_HIST := 6
const AZUL := Color("#7aa8ff")
const VERMELHO := Color("#e86a6a")
const OURO := [Color("#ffe39a"), Color("#e2b85a"), Color("#9c7430")]
const ESCURO := Color("#140c10")
const EMOTES := [["Saudações!", "Greetings!"], ["Bem jogado.", "Well played."], ["Hmm...", "Hmm..."], ["Uau!", "Wow!"]]
const RESPOSTAS := [
	[["Que os deuses decidam.", "Let the gods decide."], ["Saudações. Agora, lute.", "Greetings. Now, fight."]],
	[["Eu sei.", "I know."], ["Obrigado. Não vai se repetir... para você.", "Thanks. It won't happen again... for you."]],
	[["Pense rápido.", "Think fast."], ["O tempo corre a meu favor.", "Time is on my side."]],
	[["Ainda não viu nada.", "You haven't seen anything yet."], ["O Códice guarda mais.", "The Codex holds more."]],
]

var m                                    # a mesa (mesa.gd)
var t := 0.0
var historico: Array = []                # {dono, cid, tipo, alvo, t}
var hist_aberto := -1                    # índice tocado: carta grande na tela
var previa := {}                         # {alvo: Carta|null, da, dd, letal_alvo, letal_atk, motivo, direto}
var sem_jogadas := false
var mulligan := false
var marcadas: Array = []
var menu := ""                           # "" | "pausa" | "desistir"
var emotes_abertos := false
var fala_jog := {}                       # {texto, t}
var _ultimo_emote := -10.0
var lendaria := {}                       # {tex, nome, t, cor}


func _init(mesa) -> void:
	m = mesa
	z_index = 880


func _process(delta: float) -> void:
	t += delta
	if not fala_jog.is_empty():
		fala_jog["t"] += delta
		if fala_jog["t"] > 2.4:
			fala_jog = {}
	if not lendaria.is_empty():
		lendaria["t"] += delta
	for h in historico:
		h["t"] += delta
	queue_redraw()


# ---------------- geometria da tela ----------------
func tela() -> Rect2:
	var vs: Vector2 = get_viewport_rect().size
	return Rect2(m.CENTRO - vs / 2.0, vs)


func _topo() -> float:
	var vs: Vector2 = get_viewport_rect().size
	var win := Vector2(DisplayServer.window_get_size())
	var seg := DisplayServer.get_display_safe_area()
	return tela().position.y + (seg.position.y * vs.y / win.y if win.y > 0 else 0.0)


func rect_menu() -> Rect2:
	return Rect2(tela().position.x + 6, maxf(_topo(), tela().position.y) + 6, 24, 24)


func rect_emote() -> Rect2:
	return Rect2(tela().end.x - 30, maxf(_topo(), tela().position.y) + 6, 24, 24)


func _rect_hist(k: int) -> Rect2:
	return Rect2(tela().position.x + 4, rect_menu().end.y + 10 + k * PASSO_H, MINI.x, MINI.y)


func _painel() -> Rect2:
	return Rect2(70, m.CENTRO.y - 96, 220, 192)


func _botoes_menu() -> Array:
	var p := _painel()
	var out: Array = []
	var x := p.position.x + 20
	var w := p.size.x - 40
	if menu == "desistir":
		out.append([Rect2(x, p.position.y + 84, w, 22), "SIM, DESISTIR", "confirmar"])
		out.append([Rect2(x, p.position.y + 114, w, 22), "VOLTAR", "voltar"])
		return out
	var itens := [["CONTINUAR", "continuar"], ["REGRAS", "regras"],
		["ANIMAÇÕES: RÁPIDAS" if Sessao.animacao_rapida else "ANIMAÇÕES: NORMAIS", "animacao"],
		["VIBRAÇÃO: LIGADA" if Sessao.vibracao else "VIBRAÇÃO: DESLIGADA", "vibracao"],
		["SAIR DO TUTORIAL" if m.tut != null else "DESISTIR", "desistir"]]
	for k in itens.size():
		out.append([Rect2(x, p.position.y + 32 + k * 30, w, 22), itens[k][0], itens[k][1]])
	return out


func _rect_emotes(k: int) -> Rect2:
	var r := rect_emote()
	return Rect2(r.end.x - 110, r.end.y + 6 + k * 24, 110, 20)


# ---------------- registro ----------------
func registrar(dono: int, cid: String, tipo: String, alvo := "") -> void:
	historico.push_front({"dono": dono, "cid": cid, "tipo": tipo, "alvo": alvo, "t": 0.0})
	if historico.size() > MAX_HIST:
		historico.resize(MAX_HIST)
	if hist_aberto >= 0:
		hist_aberto = -1


func emote_jogador(k: int) -> void:
	if t - _ultimo_emote < 2.5:
		return
	_ultimo_emote = t
	fala_jog = {"texto": EMOTES[k][1 if Sessao.idioma == "en" else 0], "t": 0.0}
	Sessao.vibrar(10, 0.3)
	if Sessao.modo != "" and randf() < 0.6:            # o oponente responde 60% das vezes, 1,2 s depois
		var linha: Array = RESPOSTAS[k][randi() % RESPOSTAS[k].size()]
		get_tree().create_timer(1.2).timeout.connect(func() -> void:
			if m.acabou:
				return
			var p: Dictionary = Sessao.personagem(Sessao.oponente)
			m.efeitos.falar(p.get("nome", ""), linha[1 if Sessao.idioma == "en" else 0], Color(p.get("cor", "#e2b85a")), Sessao.oponente))


func entrada_lendaria(c: Carta) -> void:
	var tex := Carta.textura("carta_en" if Sessao.idioma == "en" else "carta", c.id, "webp")
	if tex == null:
		return
	lendaria = {"tex": tex, "nome": str(c.dados.get("nome", "")), "t": 0.0, "dono": c.dono}


# ---------------- toque ----------------
## Devolve true se o HUD consumiu o toque (encostar).
func pressionar(p: Vector2) -> bool:
	if menu != "":
		for b in _botoes_menu():
			if (b[0] as Rect2).has_point(p):
				_acao_menu(b[2])
				return true
		if not _painel().has_point(p) and menu == "pausa":
			_acao_menu("continuar")
		return true
	if hist_aberto >= 0:
		hist_aberto = -1
		return true
	if emotes_abertos:
		for k in EMOTES.size():
			if _rect_emotes(k).has_point(p):
				emote_jogador(k)
		emotes_abertos = false
		return true
	if rect_menu().grow(6).has_point(p) and not m.acabou:
		menu = "pausa"
		Sessao.vibrar(10, 0.3)
		m.pausar(true)
		return true
	if rect_emote().grow(6).has_point(p) and not m.acabou and m.tut == null:
		emotes_abertos = true
		Sessao.vibrar(8, 0.3)
		return true
	if not m.ocupado or m.ativo == 1:
		for k in historico.size():
			if _rect_hist(k).grow(2).has_point(p):
				hist_aberto = k
				Sessao.vibrar(8, 0.3)
				return true
	return false


func _acao_menu(a: String) -> void:
	Sessao.vibrar(10, 0.35)
	match a:
		"continuar":
			menu = ""
			m.pausar(false)
		"regras":
			m.abrir_regras()
		"animacao":
			Sessao.alternar_animacao()
			m.aplicar_tempo()
		"vibracao":
			Sessao.alternar_vibracao()
		"desistir":
			menu = "desistir"
		"voltar":
			menu = "pausa"
		"confirmar":
			menu = ""
			m.pausar(false)
			m.desistir()


# ---------------- desenho ----------------
func _draw() -> void:
	var tl := tela()
	_desenhar_hist()
	_desenhar_previa()
	if mulligan:
		for c in marcadas:
			if is_instance_valid(c):
				var cc: Vector2 = (c as Carta).position
				draw_circle(cc, 13.0, Color(0.1, 0.02, 0.03, 0.85))
				draw_arc(cc, 13.0, 0, TAU, 24, VERMELHO, 2.0)
				draw_line(cc + Vector2(-6, -6), cc + Vector2(6, 6), VERMELHO, 3.0)
				draw_line(cc + Vector2(6, -6), cc + Vector2(-6, 6), VERMELHO, 3.0)
	if not fala_jog.is_empty():
		_balao(Vector2(180, 512), fala_jog["texto"], fala_jog["t"])
	# botões do canto (somem no fim da partida)
	if not m.acabou:
		_botao_canto(rect_menu(), "menu")
		if m.tut == null:
			_botao_canto(rect_emote(), "emote")
	if emotes_abertos:
		for k in EMOTES.size():
			var r := _rect_emotes(k)
			draw_rect(r.grow(1), ESCURO)
			draw_rect(r, Color("#2a1f2a"))
			draw_rect(Rect2(r.position, Vector2(r.size.x, 1)), OURO[2])
			Fonte57.desenhar(self, r.position + Vector2(7, 6), EMOTES[k][1 if Sessao.idioma == "en" else 0], Color("#f2e6c8"))
	if sem_jogadas and not m.acabou and m.ativo == 0 and menu == "":
		var r: Rect2 = m.botao_fim
		var a := 0.6 + 0.4 * sin(t * 5.0)
		PixelFonte.centrado(self, r.get_center() + Vector2(0, -14), Sessao.t("SEM JOGADAS"), Color(OURO[0], a), 1, ESCURO)
	if hist_aberto >= 0 and hist_aberto < historico.size():
		_desenhar_carta_hist(historico[hist_aberto], tl)
	if not lendaria.is_empty():
		_desenhar_lendaria(tl)
	if menu != "":
		_desenhar_menu(tl)


func _botao_canto(r: Rect2, qual: String) -> void:
	var c := r.get_center()
	draw_circle(c, 12.0, Color(0.05, 0.03, 0.05, 0.85))
	draw_arc(c, 12.0, 0, TAU, 24, OURO[2], 1.5)
	if qual == "menu":
		for k in 3:
			draw_rect(Rect2(c + Vector2(-6, -5 + k * 4), Vector2(12, 2)), OURO[0])
	else:
		draw_rect(Rect2(c + Vector2(-7, -6), Vector2(14, 9)), OURO[0])
		draw_colored_polygon(PackedVector2Array([c + Vector2(-4, 3), c + Vector2(0, 3), c + Vector2(-5, 7)]), OURO[0])
		for k in 3:
			draw_rect(Rect2(c + Vector2(-4 + k * 3, -2), Vector2(2, 2)), ESCURO)


func _icone_tipo(c: Vector2, tipo: String, cor: Color) -> void:
	draw_circle(c, 5.5, ESCURO)
	match tipo:
		"ataque":
			draw_line(c + Vector2(-3, 3), c + Vector2(3, -3), cor, 1.5)
			draw_line(c + Vector2(-3, -1), c + Vector2(-1, 1), cor, 1.0)
		"golpe":
			draw_colored_polygon(PackedVector2Array([c + Vector2(-1, -4), c + Vector2(3, -4), c + Vector2(0, 0), c + Vector2(2, 0),
				c + Vector2(-2, 4), c + Vector2(-1, 1), c + Vector2(-3, 1)]), cor)
		"selo", "selo_revelado":
			draw_rect(Rect2(c + Vector2(-3, -3), Vector2(6, 6)), cor, false, 1.0)
			draw_rect(Rect2(c + Vector2(-1, -1), Vector2(2, 2)), cor)
		"rito":
			draw_circle(c, 2.5, cor)
			for k in 4:
				draw_rect(Rect2(c + Vector2.from_angle(k * PI / 2.0) * 4.0 - Vector2(0.5, 0.5), Vector2(1, 1)), cor)
		"reliquia":
			draw_colored_polygon(PackedVector2Array([c + Vector2(0, -4), c + Vector2(3, 0), c + Vector2(0, 4), c + Vector2(-3, 0)]), cor)
		_:
			draw_colored_polygon(PackedVector2Array([c + Vector2(-3, -2), c + Vector2(3, -2), c + Vector2(0, 3)]), cor)


func _desenhar_hist() -> void:
	for k in historico.size():
		var h: Dictionary = historico[k]
		var r := _rect_hist(k)
		var entra := clampf(float(h["t"]) / 0.25, 0.0, 1.0)
		r.position.x -= (1.0 - entra) * 30.0
		var al := (1.0 - k * 0.12) * entra
		var cor: Color = AZUL if h["dono"] == 0 else VERMELHO
		draw_rect(r.grow(2), Color(ESCURO, al))
		draw_rect(r.grow(1), Color(cor, al))
		var oculto: bool = h["tipo"] == "selo" and h["dono"] == 1
		var tex: Texture2D = null if oculto else Carta.textura("arte", h["cid"], "png")
		if tex:
			var tw := float(tex.get_width())
			var th := float(tex.get_height())
			var sw := minf(tw, th * MINI.x / MINI.y)
			var sh := sw * MINI.y / MINI.x
			draw_texture_rect_region(tex, r, Rect2((tw - sw) / 2.0, (th - sh) / 3.0, sw, sh), Color(1, 1, 1, al))
		else:
			draw_rect(r, Color(0.24, 0.12, 0.2, al))
			PixelFonte.centrado(self, r.get_center(), "?", Color(OURO[1], al), 2)
		_icone_tipo(r.end - Vector2(2, 3), h["tipo"], Color(cor.lightened(0.3), al))


func _desenhar_carta_hist(h: Dictionary, tl: Rect2) -> void:
	draw_rect(tl, Color(0.02, 0.01, 0.03, 0.78))
	var en := Sessao.idioma == "en"
	var oculto: bool = h["tipo"] == "selo" and h["dono"] == 1
	var tex: Texture2D = null if oculto else Carta.textura("carta_en" if en else "carta", h["cid"], "webp")
	var r := Rect2(100, m.CENTRO.y - 140, 160, 224)
	if tex:
		draw_texture_rect(tex, r, false)
	else:
		draw_rect(r, Color("#3d1f33"))
		PixelFonte.centrado(self, r.get_center(), "?", OURO[1], 4)
	var quem := ("You" if en else "Você") if h["dono"] == 0 else ("Opponent" if en else "Oponente")
	var acao := ""
	match h["tipo"]:
		"ataque": acao = ("attacked %s" if en else "atacou %s") % _nome(h["alvo"])
		"golpe": acao = "hit the Cornucopia" if en else "golpeou a Cornucópia"
		"selo": acao = "set a Seal" if en else "colocou um Selo"
		"selo_revelado": acao = "Seal triggered" if en else "Selo disparado"
		_: acao = "played" if en else "jogou"
	var s := quem + " " + acao
	Fonte57.desenhar(self, Vector2(roundf(180 - Fonte57.largura(s) / 2.0), r.end.y + 10), s, AZUL if h["dono"] == 0 else Color("#ffb0a0"), ESCURO)
	var dica := "tap to close" if en else "toque para fechar"
	Fonte57.desenhar(self, Vector2(roundf(180 - Fonte57.largura(dica) / 2.0), r.end.y + 24), dica, Color(0.7, 0.66, 0.6, 0.7))


func _nome(cid: String) -> String:
	if cid == "":
		return "?"
	if Sessao.db["cartas"].has(cid):
		return str(Sessao.db["cartas"][cid]["nome"])
	for nome in Sessao.tokens:
		if Sessao.tokens[nome]["id"] == cid:
			return str(Sessao.tokens[nome]["en"]) if Sessao.idioma == "en" else str(nome)
	return cid


func _desenhar_previa() -> void:
	if previa.is_empty():
		return
	var pulso := 0.75 + 0.25 * sin(t * 8.0)
	if previa.get("motivo", "") != "":
		var alvo_m = previa.get("alvo")
		var pm: Vector2 = (alvo_m as Carta).position if alvo_m != null and is_instance_valid(alvo_m) else Vector2(180, m.LINHA_Y - 40)
		PixelFonte.centrado(self, pm + Vector2(0, -34), Sessao.t(previa["motivo"]), Color("#ffd0a0"), 1, ESCURO)
		return
	if previa.get("direto", false):
		var pp: Vector2 = m._pos_placar(1) + Vector2(16, 2)
		PixelFonte.centrado(self, pp + Vector2(30, 0), "-%d" % int(previa["da"]), Color(1.0, 0.35, 0.35, pulso), 2, ESCURO)
		return
	var alvo = previa.get("alvo")
	var atk = m.segurando
	if alvo == null or not is_instance_valid(alvo) or atk == null or not is_instance_valid(atk):
		return
	# painel acima da carta arrastada (ela cobre o alvo): CAUSA x (+ MATA) / SOFRE y (+ MORRE)
	var pc: Vector2 = (atk as Carta).position + Vector2(0, -58)
	var l1 := Sessao.t("CAUSA %d") % int(previa["da"])
	var l2 := Sessao.t("SOFRE %d") % int(previa["dd"])
	var w := maxf(PixelFonte.largura(l1), PixelFonte.largura(l2)) + 30
	var r := Rect2(pc.x - w / 2.0, pc.y - 13, w, 26)
	draw_rect(r.grow(1), ESCURO)
	draw_rect(r, Color(0.12, 0.07, 0.09, 0.92))
	draw_rect(Rect2(r.position, Vector2(r.size.x, 1)), Color(OURO[2], 0.8))
	PixelFonte.desenhar(self, r.position + Vector2(6, 4), l1, Color(1.0, 0.45, 0.4, pulso))
	PixelFonte.desenhar(self, r.position + Vector2(6, 15), l2, Color(1.0, 0.75, 0.55) if int(previa["dd"]) > 0 else Color(0.7, 0.66, 0.6))
	if previa["letal_alvo"]:
		_caveira(Vector2(r.end.x - 9, r.position.y + 8), pulso)
	if previa["letal_atk"]:
		_caveira(Vector2(r.end.x - 9, r.position.y + 19), pulso)


func _caveira(c: Vector2, a: float) -> void:
	var cor := Color(0.95, 0.92, 0.85, a)
	draw_rect(Rect2(c + Vector2(-6, -7), Vector2(12, 9)), ESCURO)
	draw_rect(Rect2(c + Vector2(-5, -6), Vector2(10, 7)), cor)
	draw_rect(Rect2(c + Vector2(-3, 1), Vector2(6, 3)), cor)
	draw_rect(Rect2(c + Vector2(-3, -4), Vector2(2, 2)), ESCURO)
	draw_rect(Rect2(c + Vector2(1, -4), Vector2(2, 2)), ESCURO)
	draw_rect(Rect2(c + Vector2(-1, 2), Vector2(1, 2)), ESCURO)
	draw_rect(Rect2(c + Vector2(1, 2), Vector2(1, 2)), ESCURO)


func _balao(p: Vector2, s: String, tt: float) -> void:
	var w := Fonte57.largura(s) + 14
	var sobe := clampf(tt / 0.15, 0.0, 1.0)
	var al := clampf((2.4 - tt) / 0.3, 0.0, 1.0)
	var r := Rect2(p.x - w / 2.0, p.y - 18 + (1.0 - sobe) * 6.0, w, 16)
	draw_rect(r.grow(1), Color(0.16, 0.1, 0.08, al))
	draw_rect(r, Color(0.93, 0.89, 0.81, al))
	draw_colored_polygon(PackedVector2Array([Vector2(p.x - 4, r.end.y), Vector2(p.x + 4, r.end.y), Vector2(p.x, r.end.y + 5)]),
		Color(0.93, 0.89, 0.81, al))
	Fonte57.desenhar(self, r.position + Vector2(7, 5), s, Color(0.24, 0.14, 0.09, al))


## Lendária: 0–0,45 s a carta cresce (ease-out-back) com raios girando; segura até 1,6 s; some até 2,0 s.
func _desenhar_lendaria(tl: Rect2) -> void:
	var tt: float = lendaria["t"]
	if tt > 2.0:
		lendaria = {}
		return
	var al := clampf(tt / 0.15, 0.0, 1.0) * clampf((2.0 - tt) / 0.3, 0.0, 1.0)
	draw_rect(tl, Color(0.02, 0.01, 0.03, 0.82 * al))
	var c := Vector2(180, m.CENTRO.y - 20)
	var cor: Color = Color("#ffe39a") if lendaria["dono"] == 0 else Color("#ffb08a")
	for k in 12:
		var a0 := TAU * k / 12.0 + tt * 0.8
		var pts := PackedVector2Array([c, c + Vector2.from_angle(a0) * 420.0, c + Vector2.from_angle(a0 + TAU / 26.0) * 420.0])
		draw_colored_polygon(pts, Color(cor, 0.14 * al))
	for k in 3:
		draw_circle(c, 120.0 - k * 30.0, Color(cor, 0.035 * al))
	var u := clampf(tt / 0.45, 0.0, 1.0)
	var s := 1.70158
	var e := 1.0 + (s + 1.0) * pow(u - 1.0, 3) + s * pow(u - 1.0, 2)
	var esc := (0.3 + 0.85 * e) * (1.0 + 0.02 * sin(tt * 4.0))
	var tam := Vector2(150, 210) * esc
	var r := Rect2(c - tam / 2.0, tam)
	draw_texture_rect(lendaria["tex"], r, false, Color(1, 1, 1, al))
	if tt > 0.35:
		var a2 := al * clampf((tt - 0.35) / 0.2, 0.0, 1.0)
		PixelFonte.centrado(self, Vector2(180, r.position.y - 16), Sessao.t("LENDÁRIA"), Color(cor, a2), 3, ESCURO)
		var nome := PixelFonte.normalizar(lendaria["nome"])
		PixelFonte.centrado(self, Vector2(180, r.end.y + 14), nome, Color(cor, a2), 2, ESCURO)


func _desenhar_menu(tl: Rect2) -> void:
	draw_rect(tl, Color(0.02, 0.01, 0.03, 0.7))
	var p := _painel()
	if menu == "desistir":
		p.size.y = 150
	draw_rect(p.grow(2), ESCURO)
	draw_rect(p.grow(1), OURO[2])
	draw_rect(p, Color("#1e161e"))
	draw_rect(Rect2(p.position + Vector2(2, 2), Vector2(p.size.x - 4, 1)), Color(OURO[1], 0.5))
	var titulo := "PAUSA" if menu == "pausa" else ("SAIR?" if m.tut != null else "DESISTIR?")
	PixelFonte.centrado(self, Vector2(180, p.position.y + 16), Sessao.t(titulo), OURO[0], 2, ESCURO)
	if menu == "desistir":
		var aviso := Sessao.t("A partida conta como derrota.") if m.tut == null else Sessao.t("Você pode refazer o tutorial no menu.")
		Fonte57.desenhar(self, Vector2(roundf(180 - Fonte57.largura(aviso) / 2.0), p.position.y + 50), aviso, Color("#d8ccb4"))
	for b in _botoes_menu():
		var r: Rect2 = b[0]
		var perigo: bool = b[2] in ["desistir", "confirmar"]
		draw_rect(r.grow(1), ESCURO)
		draw_rect(r, Color("#5a1c1c") if perigo else Color("#2e2230"))
		draw_rect(Rect2(r.position, Vector2(r.size.x, 1)), Color("#c86a5a") if perigo else OURO[2])
		PixelFonte.centrado(self, r.get_center(), Sessao.t(b[1]), OURO[0] if not perigo else Color("#ffd0c0"), 1)
