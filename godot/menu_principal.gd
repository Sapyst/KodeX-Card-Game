class_name MenuPrincipal
extends RefCounted
## Menu principal: leque de cartas-modo (arrastar para os lados, a carta do centro se destaca), botão JOGAR do modo
## escolhido, atalho do deck em uso e barra fixa embaixo (Início, Coleção, Decks, Loja, Opções). px nativos 360×640.

const CENTRO := Vector2(180, 300)
const CW := 148.0
const CH := 206.0
const PASSO := 96.0                # px de arraste por carta

var f
var pos := 1.0                     # índice contínuo no centro do leque (abre no Arcade: cartas dos dois lados)
var vel := 0.0
var _segura := false
var _ini := Vector2.ZERO
var _ult := Vector2.ZERO
var _moveu := false
var _ult_t := 0


func _init(menu) -> void:
	f = menu


func modos() -> Array:
	var torneio_sub := Sessao.t("6 campeões, 1 Códice")
	var adv := "alta_magia"
	if Sessao.modo == "torneio" and not Sessao.torneio_ordem.is_empty():
		torneio_sub = Sessao.t("Luta %d de 6") % (Sessao.torneio_idx + 1)
		adv = Sessao.torneio_ordem[mini(Sessao.torneio_idx, 5)]
	return [
		{"nome": "Torneio", "sub": torneio_sub, "retrato": adv, "cor": Color("#8b1a1a"), "acao": f._torneio},
		{"nome": "Arcade", "sub": Sessao.t("partida rápida  +15"), "retrato": "bruxaria", "cor": Color("#5a3a7a"), "acao": func() -> void: f._ir("arcade")},
		{"nome": "Torneio de 8", "sub": Sessao.t("continuar chave") if Sessao.ta_ativo() else Sessao.t("chave  até 150"), "retrato": "taoismo", "cor": Color("#1f6a5a"), "acao": f._torneio_arcade},
		{"nome": "Tutorial", "sub": Sessao.t("aprenda com Silas"), "retrato": "alta_magia", "cor": Color("#3a3050"), "acao": f._comecar_tutorial},
	]


func atual() -> int:
	return clampi(int(roundf(pos)), 0, modos().size() - 1)


func jogar() -> void:
	f.vibrar(18, 0.6)
	(modos()[atual()]["acao"] as Callable).call()


func atualizar(delta: float) -> void:
	if _segura:
		return
	var n := modos().size()
	pos += vel * delta
	vel *= pow(0.02, delta)
	if absf(vel) < 3.0:
		pos = lerpf(pos, clampf(roundf(pos), 0, n - 1), minf(1.0, delta * 12.0))
	if pos < -0.3 or pos > n - 0.7:
		vel *= 0.5
		pos = lerpf(pos, clampf(pos, 0, n - 1), minf(1.0, delta * 10.0))


# ---------------- entrada (só na faixa do leque) ----------------
func na_area(p: Vector2) -> bool:
	return p.y > CENTRO.y - CH / 2 - 10 and p.y < CENTRO.y + CH / 2 + 10


func pressionar(p: Vector2) -> void:
	_segura = true
	_ini = p
	_ult = p
	_moveu = false
	vel = 0.0
	_ult_t = Time.get_ticks_msec()


func mover(p: Vector2) -> void:
	if not _segura:
		return
	var dx := p.x - _ult.x
	if absf(p.x - _ini.x) > 6:
		_moveu = true
	var antes := atual()
	pos -= dx / PASSO
	var agora := Time.get_ticks_msec()
	vel = lerpf(vel, -dx / PASSO / maxf(0.008, (agora - _ult_t) / 1000.0), 0.5)
	_ult_t = agora
	_ult = p
	if atual() != antes:
		f.vibrar(6, 0.2)


func soltar(p: Vector2) -> void:
	if not _segura:
		return
	_segura = false
	if _moveu:
		return
	vel = 0.0
	var rc := Rect2(CENTRO - Vector2(CW, CH) / 2, Vector2(CW, CH))
	if rc.has_point(p):
		jogar()
	else:                                          # tocou numa carta de lado: traz para o centro
		var alvo := clampf(atual() + (1 if p.x > 180 else -1), 0, modos().size() - 1)
		vel = (alvo - pos) * 6.0


# ---------------- desenho ----------------
func desenhar() -> void:
	var lista := modos()
	var n := lista.size()
	var e: float = f._entrada(2)
	# brilho atrás do centro
	var pul := 0.6 + 0.4 * sin(f.tempo * 2.0)
	for k in 4:
		f.draw_circle(CENTRO, 120.0 - k * 22, Color(1.0, 0.82, 0.4, (0.02 + k * 0.012) * pul * e))
	var ordem: Array = range(n)
	ordem.sort_custom(func(a: int, b: int) -> bool: return absf(a - pos) > absf(b - pos))
	for k in ordem:
		var off: float = float(k) - pos
		var a_off := absf(off)
		if a_off > 2.6:
			continue
		var esc := 1.0 - minf(a_off, 2.0) * 0.2
		var ang := clampf(off, -2.0, 2.0) * 0.2           # leque: as de lado giram para fora
		var c := CENTRO + Vector2(signf(off) * (minf(a_off, 1.0) * 92.0 + maxf(0.0, a_off - 1.0) * 52.0),
			minf(a_off, 2.0) * 22.0 + (1.0 - e) * 60.0)
		_carta_modo(c, esc, ang, lista[k], a_off < 0.5, 1.0 - minf(a_off, 2.0) * 0.3)
	# pontinhos
	for k in n:
		var on := k == atual()
		f.draw_rect(Rect2(180 - n * 7 + k * 14, CENTRO.y + CH / 2 + 22, 8 if on else 4, 4), f.OURO[0] if on else Color(0.5, 0.45, 0.5))


func _carta_modo(c: Vector2, esc: float, ang: float, m: Dictionary, centro: bool, luz: float) -> void:
	f.draw_set_transform(c, ang, Vector2(esc, esc))
	var r := Rect2(-CW / 2, -CH / 2, CW, CH)
	var cor: Color = m["cor"]
	f.draw_rect(Rect2(r.position + Vector2(4, 7), r.size), Color(0, 0, 0, 0.5))
	if centro:
		var pul := 0.55 + 0.45 * sin(f.tempo * 4.0)
		f.draw_rect(r.grow(6), Color(1.0, 0.85, 0.4, 0.25 * pul), false, 4.0)
	f.draw_rect(r.grow(1), f.ESCURO)
	f.draw_rect(r, (f.OURO[1] if centro else Color(0.55, 0.5, 0.5)) * Color(luz, luz, luz))
	var dentro := r.grow(-3)
	f.draw_rect(dentro, cor.darkened(0.55) * Color(luz, luz, luz))
	# raios de fundo dentro da carta
	for k in 6:
		f.draw_line(Vector2(0, dentro.position.y + 60), Vector2(0, dentro.position.y + 60) + Vector2.from_angle(-PI / 2 + (k - 2.5) * 0.35) * 90,
			Color(cor.lightened(0.4), 0.15 * luz), 6.0)
	var tex := Carta.textura("retrato", m["retrato"], "png")
	var arte := Rect2(dentro.position, Vector2(dentro.size.x, dentro.size.y - 44))
	if tex:
		var tw := float(tex.get_width())
		var src := Rect2(tw * 0.08, 0, tw * 0.84, minf(tw * 0.84 * arte.size.y / arte.size.x, tex.get_height()))
		f.draw_texture_rect_region(tex, arte, src, Color(luz, luz, luz))
	# faixa do nome
	var faixa := Rect2(dentro.position.x, dentro.end.y - 44, dentro.size.x, 44)
	f.draw_rect(faixa, Color(0.06, 0.04, 0.07, 0.92))
	f.draw_rect(Rect2(faixa.position, Vector2(faixa.size.x, 1)), f.OURO[1] * Color(luz, luz, luz))
	var nome := PixelFonte.normalizar(Sessao.t(m["nome"]))
	PixelFonte.centrado(f, Vector2(0, faixa.position.y + 14), nome, f.OURO[0] * Color(luz, luz, luz), 2, f.ESCURO)
	var sub := str(m["sub"])
	Fonte57.desenhar(f, Vector2(-Fonte57.largura(sub) / 2.0, faixa.position.y + 27), sub, Color(0.81, 0.88, 1.0) * Color(luz, luz, luz), f.ESCURO)
	f.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func botao_jogar(_b: Dictionary, r: Rect2, pressao: float) -> void:
	var dentro: Rect2 = f._painel(r, true, pressao, Color("#3a2410"))
	var pul := 0.5 + 0.5 * sin(f.tempo * 3.0)
	f.draw_rect(r.grow(3), Color(1.0, 0.85, 0.4, 0.2 * pul), false, 2.0)
	var s := Sessao.t("JOGAR") + ":  " + PixelFonte.normalizar(Sessao.t(modos()[atual()]["nome"]))
	PixelFonte.centrado(f, dentro.get_center() + Vector2(0, 1), s, f.OURO[0], 2, f.ESCURO)


func botao_deck(_b: Dictionary, r: Rect2, pressao: float) -> void:
	var dentro: Rect2 = f._painel(r, false, pressao)
	var i := int(Sessao.perfil["deck_ativo"])
	var d: Dictionary = Sessao.perfil["decks"][clampi(i, 0, Sessao.perfil["decks"].size() - 1)]
	var n := (d["cartas"] as Array).size()
	var tex: Texture2D = null
	for cid in d["cartas"]:
		if Sessao.db["cartas"][cid]["lendaria"]:
			tex = Carta.textura("arte", cid, "png")
			break
	var mini := Rect2(dentro.position + Vector2(4, 2), Vector2(15, 20))
	f.draw_rect(mini.grow(1), f.ESCURO)
	if tex:
		f.draw_texture_rect(tex, mini, false)
	Fonte57.desenhar(f, dentro.position + Vector2(24, 4), Sessao.t("Deck em uso") + ": " + str(d["nome"]), f.CREME, f.ESCURO)
	PixelFonte.desenhar(f, dentro.position + Vector2(24, 15), "%d/%d" % [n, Sessao.DECK_TAM], Color(0.81, 0.88, 1.0) if n == Sessao.DECK_TAM else Color("#ff9a8a"))
	Fonte57.desenhar(f, Vector2(dentro.end.x - 10, dentro.position.y + 7), ">", f.OURO[1])


## Aba da barra inferior: ícone pixel desenhado por código + rótulo; a ativa sobe 2 px e fica dourada.
func aba(b: Dictionary, r: Rect2, pressao: float) -> void:
	var ativa: bool = b["aba_menu"] == "inicio"
	var cor: Color = f.OURO[0] if ativa else Color(0.62, 0.58, 0.62)
	var c := r.get_center() + Vector2(0, -5 - (2 if ativa else 0) + pressao)
	_icone(b["aba_menu"], c, cor)
	PixelFonte.centrado(f, Vector2(r.get_center().x, r.end.y - 7), Sessao.t(b["texto"]).to_upper(), cor, 1)
	if b["aba_menu"] == "loja" and Sessao.boosters_gratis() > 0:
		f.draw_circle(c + Vector2(9, -7), 3.5, Color("#e04040"))


func _icone(qual: String, c: Vector2, cor: Color) -> void:
	match qual:
		"inicio":
			f.draw_colored_polygon(PackedVector2Array([c + Vector2(-8, 0), c + Vector2(0, -8), c + Vector2(8, 0)]), cor)
			f.draw_rect(Rect2(c + Vector2(-6, 0), Vector2(12, 8)), cor)
			f.draw_rect(Rect2(c + Vector2(-2, 3), Vector2(4, 5)), f.ESCURO)
		"colecao":
			f.draw_rect(Rect2(c + Vector2(-8, -6), Vector2(9, 13)), cor, false, 2.0)
			f.draw_rect(Rect2(c + Vector2(-1, -8), Vector2(9, 13)), cor)
		"decks":
			for k in 3:
				f.draw_rect(Rect2(c + Vector2(-7 + k * 2, -8 + k * 3), Vector2(12, 9)), cor if k == 2 else Color(cor, 0.6), k != 2, 1.0)
		"loja":
			f.draw_rect(Rect2(c + Vector2(-7, -3), Vector2(14, 11)), cor)
			f.draw_arc(c + Vector2(0, -3), 4.0, PI, TAU, 8, cor, 2.0)
			f.draw_rect(Rect2(c + Vector2(-1, 1), Vector2(2, 3)), f.ESCURO)
		"opcoes":
			f.draw_circle(c, 6.0, cor)
			f.draw_circle(c, 2.5, f.ESCURO)
			for k in 6:
				f.draw_rect(Rect2(c + Vector2.from_angle(TAU * k / 6.0) * 7.0 - Vector2(1.5, 1.5), Vector2(3, 3)), cor)
