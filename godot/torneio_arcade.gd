class_name TorneioArcade
extends RefCounted
## Chave do torneio arcade de 8 (dentro do menu fluxo.gd), de baixo para cima: quartas (8 cartas) → semifinal (4) →
## final (2) → campeão (1). Cada participante é uma carta com o retrato. Avançar: a carta voa até a fileira de cima
## deixando um rastro dourado e pousa com um anel de luz. Derrotado: a carta escurece, racha, tomba e solta cinzas.
## Campeão: raios, a carta cresce no centro, cai um booster de prêmio e chovem moedas.

const ROW_Y := [468.0, 344.0, 226.0, 112.0]
const TAM := [Vector2(38, 53), Vector2(48, 67), Vector2(58, 81), Vector2(76, 106)]
const RODADA_NOME := ["Quartas de final", "Semifinal", "Final", "Campeão!"]

var f
var anim: Array = []              # [{r, m, vencedor, perdedor, margem, t0, pousou, caiu}]
var t := 0.0
var faixa_t := -1.0               # >=0: resultado final na tela (campeão ou eliminado)
var ganho := 0
var particulas: Array = []


func _init(menu) -> void:
	f = menu


# ---------------- geometria ----------------
func x_slot(r: int, i: int) -> float:
	if r == 0:
		return 182.0 + (i - 3.5) * 42.0
	return (x_slot(r - 1, 2 * i) + x_slot(r - 1, 2 * i + 1)) / 2.0


func centro(r: int, i: int) -> Vector2:
	return Vector2(x_slot(r, i), ROW_Y[r])


func _campeao(d: Dictionary) -> bool:
	return d.get("fim", false) and int(d["rodadas"][3][0]) == (d["participantes"] as Array).find("jogador")


func _anim_de(r: int, m: int):
	for a in anim:
		if a["r"] == r and a["m"] == m:
			return a
	return null


## Índice (na fileira r) de onde saiu o vencedor do confronto m.
func _origem(a: Dictionary) -> int:
	var slots: Array = Sessao.ta()["rodadas"][a["r"]]
	return 2 * int(a["m"]) if int(slots[2 * int(a["m"])]) == int(a["vencedor"]) else 2 * int(a["m"]) + 1


func _u_voo(a: Dictionary) -> float:
	return clampf((t - a["t0"]) / 0.6, 0, 1)


func _pos_voo(a: Dictionary) -> Vector2:
	var u := _u_voo(a)
	var e := u * u * (3.0 - 2.0 * u)
	var de := centro(a["r"], _origem(a))
	var para := centro(a["r"] + 1, a["m"])
	return de.lerp(para, e) + Vector2(0, -sin(u * PI) * 26)


# ---------------- ciclo ----------------
func atualizar(delta: float) -> void:
	t += delta
	if faixa_t >= 0.0:
		faixa_t += delta
	for p in particulas:
		p["v"] += Vector2(0, p["g"]) * delta
		p["p"] += p["v"] * delta
		p["vida"] -= delta
	particulas = particulas.filter(func(p: Dictionary) -> bool: return p["vida"] > 0.0)
	for a in anim:
		var u := _u_voo(a)
		if u > 0.0 and u < 1.0 and randf() < 0.8:                     # rastro dourado do voo
			_soltar(_pos_voo(a), 2, Color("#ffe39a"), 30, 0.0)
		if u >= 1.0 and not a.get("pousou", false):                    # pouso: anel e faíscas
			a["pousou"] = true
			_soltar(centro(a["r"] + 1, a["m"]), 18, Color("#ffe39a"), 120, 80.0)
			f.vibrar(10, 0.3)
		if t - a["t0"] > 0.15 and not a.get("caiu", false):             # derrotado: cinzas
			a["caiu"] = true
			var k_perd: int = _origem(a) ^ 1
			_soltar(centro(a["r"], k_perd), 22, Color("#5a4a52"), 50, 60.0)
			_soltar(centro(a["r"], k_perd), 8, Color("#e05050"), 70, 60.0)
	var d := Sessao.ta()
	if faixa_t > 0.5 and faixa_t < 3.2 and not d.is_empty() and _campeao(d) and randf() < 0.6:
		particulas.append({"p": Vector2(randf_range(20, 340), -10), "v": Vector2(randf_range(-20, 20), randf_range(60, 140)),
			"cor": Color.WHITE, "vida": 4.0, "max": 4.0, "g": 120.0, "tam": 1, "moeda": true})


func _soltar(p: Vector2, n: int, cor: Color, vel: float, g: float) -> void:
	for i in n:
		particulas.append({"p": p + Vector2(randf_range(-4, 4), randf_range(-4, 4)), "v": Vector2.from_angle(randf() * TAU) * randf_range(vel * 0.3, vel),
			"cor": cor, "vida": randf_range(0.4, 0.9), "max": 0.9, "g": g, "tam": 1 + int(randf() < 0.3)})


## Mostra os resultados de uma rodada, um a cada 0,8 s.
func animar(res: Array, r: int) -> void:
	var base := t + 0.4
	for k in res.size():
		var a: Dictionary = res[k]
		a["r"] = r
		a["t0"] = base + k * 0.8
		anim.append(a)
	var d := Sessao.ta()
	var fim := base + res.size() * 0.8 + 0.5
	f.get_tree().create_timer(fim - t).timeout.connect(func() -> void:
		anim.clear()
		if d["fim"] or d["eliminado"]:
			var antes := ganho
			ganho = Sessao.ta_pagar()
			if faixa_t < 0.0 and (ganho > 0 or d["fim"] or antes == 0):
				faixa_t = 0.0
				if _campeao(d):
					Sessao.vibrar_pulsos(4, 40, 0.9, 0.08)
				else:
					f.vibrar(30, 0.6)
		f._ir("chave"))


# ---------------- desenho ----------------
func _fundo_arena() -> void:
	## Padrão próprio da chave: treliça de losangos dourados bem fraca, colunas de luz em cada fileira e um halo
	## pulsando atrás do lugar do campeão.
	for k in range(-20, 30):
		var x := k * 26.0 + fmod(f.tempo * 4.0, 26.0)
		f.draw_line(Vector2(x, 60), Vector2(x + 520, 640), Color(0.89, 0.72, 0.35, 0.035), 1.0)
		f.draw_line(Vector2(x + 520, 60), Vector2(x, 640), Color(0.89, 0.72, 0.35, 0.035), 1.0)
	for r in 4:
		var y: float = ROW_Y[r]
		f.draw_rect(Rect2(0, y - TAM[r].y / 2 - 6, 360, TAM[r].y + 22), Color(0.89, 0.72, 0.35, 0.025 + r * 0.01))
	var pul := 0.6 + 0.4 * sin(f.tempo * 2.0)
	for k in 5:
		f.draw_circle(Vector2(180, ROW_Y[3]), 90.0 - k * 16, Color(1.0, 0.82, 0.4, (0.025 + k * 0.012) * pul))


func _rotulo_fileira(r: int) -> void:
	var s := Sessao.t(["QUARTAS", "SEMIFINAL", "FINAL", "CAMPEÃO"][r])
	if r == 3:
		PixelFonte.centrado(f, Vector2(180, ROW_Y[r] - TAM[r].y / 2 - 10), s, f.OURO[1], 1, f.ESCURO)
		return
	var w := PixelFonte.largura(s)                     # rótulo vertical na margem esquerda
	f.draw_set_transform(Vector2(6, ROW_Y[r] + w / 2.0), -PI / 2, Vector2.ONE)
	PixelFonte.desenhar(f, Vector2.ZERO, s, Color(0.72, 0.66, 0.53, 0.8))
	f.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## Carta de participante: moldura na cor da tradição, retrato (busto) ou foto do jogador, nome embaixo.
func _carta(c: Vector2, tam: Vector2, pid: String, sou_eu: bool, cinza := 0.0, rot := 0.0, brilho := 0.0, nome := true) -> void:
	f.draw_set_transform(c, rot, Vector2.ONE)
	var r := Rect2(-tam / 2, tam)
	var cor: Color = Color(1.0, 0.85, 0.4) if sou_eu else (Color("#6a5a78") if pid == "viajante" else Carta.COR_CULTURA.get(pid, Color("#6a6070")).lightened(0.25))
	cor = cor.lerp(Color(0.35, 0.33, 0.36), cinza)
	f.draw_rect(Rect2(r.position + Vector2(2, 3), r.size), Color(0, 0, 0, 0.45))
	f.draw_rect(r.grow(1), f.ESCURO)
	f.draw_rect(r, cor.darkened(0.45))
	var dentro := r.grow(-2)
	f.draw_rect(dentro, Color(0.07, 0.05, 0.08))
	var tex: Texture2D = null
	var src := Rect2()
	if sou_eu:
		tex = f.mp.foto_tex
		if tex:
			src = Rect2(Vector2.ZERO, tex.get_size())
	elif pid != "viajante":
		tex = Carta.textura("retrato", pid, "png")
		if tex:
			var tw := float(tex.get_width())
			src = Rect2(tw * 0.18, 0, tw * 0.64, minf(tw * 0.64 * dentro.size.y / dentro.size.x, tex.get_height()))
	var mod := Color(1, 1, 1).lerp(Color(0.42, 0.4, 0.44), cinza)
	if tex:
		f.draw_texture_rect_region(tex, dentro, src, mod)
	else:                               # silhueta encapuzada (Viajante / sem foto)
		var cc := dentro.get_center()
		var k := dentro.size.x / 38.0
		f.draw_circle(cc + Vector2(0, -5) * k, 7 * k, Color(0.3, 0.26, 0.34).lerp(Color(0.25, 0.25, 0.25), cinza))
		f.draw_colored_polygon(PackedVector2Array([cc + Vector2(-13, 20) * k, cc + Vector2(-9, 2) * k, cc + Vector2(0, -2) * k, cc + Vector2(9, 2) * k, cc + Vector2(13, 20) * k]), Color(0.3, 0.26, 0.34).lerp(Color(0.25, 0.25, 0.25), cinza))
		if pid == "viajante":
			PixelFonte.centrado(f, cc + Vector2(0, -5) * k, "?", Color(1.0, 0.85, 0.4, 1.0 - cinza), 1)
	f.draw_rect(r, Color(cor, 0.9), false, 1.0)
	f.draw_rect(Rect2(r.position + Vector2(1, 1), Vector2(r.size.x - 2, 1)), Color(1, 1, 1, 0.25 * (1.0 - cinza)))
	if brilho > 0.0:
		f.draw_rect(r.grow(2), Color(1.0, 0.85, 0.4, brilho), false, 2.0)
		f.draw_rect(r.grow(5), Color(1.0, 0.85, 0.4, brilho * 0.4), false, 2.0)
	if cinza > 0.5:                      # rachaduras
		var a := Color(0.05, 0.02, 0.04, cinza)
		f.draw_line(r.position + Vector2(r.size.x * 0.3, 0), r.get_center() + Vector2(-2, 2), a, 1.0)
		f.draw_line(r.get_center() + Vector2(-2, 2), Vector2(r.end.x, r.position.y + r.size.y * 0.7), a, 1.0)
		f.draw_line(r.get_center() + Vector2(-2, 2), Vector2(r.position.x + r.size.x * 0.35, r.end.y), a, 1.0)
	f.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if nome:
		var n := PixelFonte.normalizar(Sessao.ta_nome(pid).split(" ")[0])
		var maxc := int((tam.x + 8) / 4)
		if n.length() > maxc:
			n = n.substr(0, maxc)
		PixelFonte.centrado(f, c + Vector2(0, tam.y / 2 + 6), n, (f.OURO[0] if sou_eu else f.CREME).lerp(Color(0.4, 0.38, 0.42), cinza), 1, f.ESCURO)


func _verso(c: Vector2, tam: Vector2, chegando := false) -> void:
	var r := Rect2(c - tam / 2, tam)
	f.draw_rect(r.grow(1), Color(0.05, 0.03, 0.07, 0.8))
	f.draw_rect(r, Color(0.13, 0.09, 0.16, 0.85))
	f.draw_rect(r.grow(-3), Color(0.89, 0.72, 0.35, 0.35), false, 1.0)
	var pul := 0.5 + 0.5 * sin(f.tempo * 3.0)
	PixelFonte.centrado(f, c, "?", Color(1.0, 0.85, 0.4, 0.35 + (0.4 * pul if chegando else 0.0)), 2 if tam.x > 50 else 1)


func desenhar() -> void:
	var d := Sessao.ta()
	if d.is_empty():
		return
	_fundo_arena()
	var r_atual: int = mini(int(d["rodada"]), 3)
	PixelFonte.centrado(f, Vector2(180, 18), Sessao.t("TORNEIO ARCADE"), f.OURO[0], 2, f.ESCURO)
	f._texto_central(Vector2(180, 34), Sessao.t(RODADA_NOME[r_atual]), Color(0.81, 0.88, 1.0))
	var parts: Array = d["participantes"]
	var eu: int = parts.find("jogador")
	# linhas: do topo de cada carta até a base da carta de cima (cinza; dourada no caminho do vencedor)
	for r in 3:
		for i in (8 >> r):
			var a := centro(r, i) - Vector2(0, TAM[r].y / 2)
			var b := centro(r + 1, i / 2) + Vector2(0, TAM[r + 1].y / 2 + 12)
			var meio := (a.y + b.y) / 2.0
			var p := [a, Vector2(a.x, meio), Vector2(b.x, meio), b]
			for k in 3:
				f.draw_line(p[k], p[k + 1], Color(0.45, 0.4, 0.46, 0.55), 1.0)
			var venc: int = int(d["rodadas"][r + 1][i / 2])
			if venc >= 0 and venc == int(d["rodadas"][r][i]):
				var an: Variant = _anim_de(r, i / 2)
				var u := 1.0 if an == null else _u_voo(an)
				for k in 3:
					var seg := clampf(u * 3.0 - k, 0, 1)
					if seg > 0:
						f.draw_line(p[k], p[k].lerp(p[k + 1], seg), Color(1.0, 0.85, 0.4), 2.0)
				var margem := int(d["margem"].get("%d-%d" % [r, i / 2], 0))
				if u >= 1.0 and margem > 0:
					PixelFonte.centrado(f, Vector2((a.x + b.x) / 2.0, meio - 5), "+%d" % margem, Color(1.0, 0.85, 0.4, 0.75), 1)
	# cartas
	for r in 4:
		_rotulo_fileira(r)
		for i in (8 >> r):
			var c := centro(r, i)
			var idx: int = int(d["rodadas"][r][i])
			var an: Variant = _anim_de(r - 1, i) if r > 0 else null
			if idx < 0 or (an != null and _u_voo(an) < 1.0):
				_verso(c, TAM[r], r == r_atual)
				continue
			var cinza := 0.0
			var queda := 0.0
			if r < int(d["rodada"]):
				var prox: int = int(d["rodadas"][r + 1][i / 2])
				if prox >= 0 and prox != idx:
					var ap: Variant = _anim_de(r, i / 2)
					cinza = 1.0 if ap == null else clampf((t - ap["t0"] - 0.1) / 0.5, 0, 1)
					queda = cinza
			var brilho := 0.0
			if an != null:
				brilho = clampf(1.0 - (t - an["t0"] - 0.6) / 0.6, 0, 1)
			if r == 3:
				brilho = maxf(brilho, 0.4 + 0.3 * sin(f.tempo * 4.0))
			_carta(c + Vector2(0, queda * 6), TAM[r], parts[idx], idx == eu, cinza, queda * (0.12 if i % 2 == 0 else -0.12), brilho)
	# cartas em voo (por cima de tudo)
	for a in anim:
		var u := _u_voo(a)
		if u > 0.0 and u < 1.0:
			var tam: Vector2 = TAM[a["r"]].lerp(TAM[a["r"] + 1], u) * (1.0 + 0.15 * sin(u * PI))
			_carta(_pos_voo(a), tam, parts[a["vencedor"]], int(a["vencedor"]) == eu, 0.0, 0.0, 0.8, false)
	for p in particulas:
		if p.get("moeda", false):
			f.mp.moeda((p["p"] as Vector2).round())
			continue
		var al := clampf(p["vida"] / p["max"] * 1.5, 0, 1)
		f.draw_rect(Rect2((p["p"] as Vector2).round(), Vector2(p["tam"], p["tam"])), Color(p["cor"], al))
	if faixa_t >= 0.0:
		if _campeao(d):
			_tela_campeao(d, eu)
		else:
			_faixa_eliminado(d)
	f.mp._desenhar_aviso()


func _faixa_eliminado(d: Dictionary) -> void:
	var u := clampf(faixa_t / 0.3, 0, 1)
	var c := Vector2(180, 540)
	var h := 34.0 * u
	f.draw_rect(Rect2(-10, c.y - h / 2, 380, h), Color(0.08, 0.06, 0.1, 0.95))
	f.draw_rect(Rect2(-10, c.y - h / 2, 380, 1), Color(0.6, 0.3, 0.3))
	f.draw_rect(Rect2(-10, c.y + h / 2 - 1, 380, 1), Color(0.6, 0.3, 0.3))
	if u < 1.0:
		return
	var tit := Sessao.t("ELIMINADO") if d["eliminado"] else Sessao.t("FIM DO TORNEIO")
	PixelFonte.centrado(f, c + Vector2(0, -6), tit, Color("#d8a0a0"), 2, f.ESCURO)
	var p := int(d.get("premio", 0))
	if p > 0:
		var s := Sessao.t("+%d moedas") % p
		var w := Fonte57.largura(s)
		f.mp.moeda(Vector2(180 - w / 2.0 - 8, c.y + 10))
		Fonte57.desenhar(f, Vector2(180 - w / 2.0, c.y + 7), s, f.OURO[0], f.ESCURO)


## Campeão: escurece, raios girando, a carta do campeão cresce no centro, um booster cai quicando e as moedas
## chovem (partículas) enquanto o contador sobe até o prêmio.
func _tela_campeao(d: Dictionary, eu: int) -> void:
	var u := clampf(faixa_t / 0.4, 0, 1)
	f.draw_rect(Rect2(-400, -400, 1200, 1500), Color(0.02, 0.01, 0.04, 0.72 * u))
	var c := Vector2(180, 232)
	for k in 16:
		Efeitos.raio(f, c, faixa_t * 0.5 + TAU * k / 16.0, 420 * u, 0.08, Color(1.0, 0.86, 0.45, 0.3))
	var e := Efeitos._ease_back(u)
	_carta(c, Vector2(110, 154) * e, "jogador", true, 0.0, sin(f.tempo * 1.5) * 0.03, 0.6 + 0.4 * sin(f.tempo * 4), false)
	PixelFonte.centrado(f, Vector2(180, 118 - (1.0 - u) * 20), Sessao.t("CAMPEÃO!"), f.OURO[0], 3, f.ESCURO)
	# booster de prêmio caindo e quicando
	var ub := clampf((faixa_t - 0.6) / 0.7, 0, 1)
	if ub > 0.0:
		var yb := lerpf(-120, 410, Efeitos._ease_back(ub))
		f.bo.pacote(f, Vector2(118, yb), sin(f.tempo * 1.4) * 0.06, Vector2.ZERO, 0.0, 1.0, false, 0.5)
		PixelFonte.centrado(f, Vector2(118, yb + 56), "+1 BOOSTER", Color(1.0, 0.89, 0.6, ub), 1, f.ESCURO)
	# moedas: pilha e contador subindo
	var um := clampf((faixa_t - 1.0) / 1.2, 0, 1)
	if um > 0.0:
		for k in int(um * 9):
			f.mp.moeda(Vector2(232 + (k % 3) * 9 + (k / 3) * 3, 424 - (k / 3) * 6 - (k % 3) * 1))
		var s := "+%d" % int(round(int(d.get("premio", 0)) * um))
		var w := Fonte57.largura(s) * 2
		f.draw_set_transform(Vector2(246 - w / 2.0, 384), 0.0, Vector2(2, 2))
		Fonte57.desenhar(f, Vector2.ZERO, s, f.OURO[0], f.ESCURO)
		f.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


# ---------------- ações ----------------
func lutar() -> void:
	Sessao.preparar_partida_ta()
	var adv: String = Sessao.ta()["participantes"][Sessao.ta_adversario()]
	var lista: Array = []
	if adv != "viajante":
		var p: Dictionary = Sessao.personagem(adv)
		for tx in p.get("arcade_intro", p.get("intro", []).slice(0, 1)):
			lista.append({"quem": p.get("nome", adv), "texto": tx, "cor": Color(p.get("cor", "#e2b85a")), "retrato": adv})
	else:
		lista.append({"quem": Sessao.t("O Viajante"), "texto": Sessao.t("Não carrego bandeira nem tradição. Só cartas, e a vontade de ver você cair."), "cor": f.CREME, "retrato": ""})
	f._falar(lista, func() -> void: f._jogar())


## Volta da mesa: resolve a rodada com o resultado do jogador e anima.
func pos_partida() -> void:
	var venceu := Sessao.resultado == "vitoria"
	Sessao.resultado = ""
	var r := int(Sessao.ta()["rodada"])
	var res := Sessao.ta_resolver_rodada(venceu)
	animar(res, r)                          # antes de _ir: os botões só aparecem quando a animação acaba
	f._ir("chave")


## Jogador eliminado: as rodadas seguintes são resolvidas e mostradas em sequência.
func ver_resto() -> void:
	var r := int(Sessao.ta()["rodada"])
	if r > 2:
		return
	faixa_t = -1.0
	var res := Sessao.ta_resolver_rodada(null)
	animar(res, r)
	f._ir("chave")


func concluir() -> void:
	Sessao.ta_encerrar()
	faixa_t = -1.0
	particulas.clear()
	f._ir("arcade")


func abrir_premio() -> void:
	Sessao.ta_encerrar()
	faixa_t = -1.0
	particulas.clear()
	f.bo.comprar(true)
