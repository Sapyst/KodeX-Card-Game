class_name TorneioArcade
extends RefCounted
## Chave do torneio arcade de 8 (dentro do menu fluxo.gd). Colunas: quartas (8) → semifinal (4) → final (2) → campeão.
## Resultados aparecem um a um: linha dourada até a próxima coluna, vencedor entra deslizando, perdedor apaga com um X.

const COL := [[6.0, 118.0], [134.0, 84.0], [224.0, 70.0], [300.0, 54.0]]   # [x, largura] de cada coluna
const Y0 := 104.0
const PASSO := 56.0
const ALT := 26.0
const RODADA_NOME := ["Quartas de final", "Semifinal", "Final", "Campeão!"]

var f
var anim: Array = []              # [{r, m, vencedor, perdedor, margem, t0}] — resultados sendo mostrados
var t := 0.0
var faixa_t := -1.0               # >=0: faixa CAMPEÃO / ELIMINADO na tela
var ganho := 0


func _init(menu) -> void:
	f = menu


func y_slot(r: int, i: int) -> float:
	if r == 0:
		return Y0 + i * PASSO
	return (y_slot(r - 1, 2 * i) + y_slot(r - 1, 2 * i + 1)) / 2.0


func rect_slot(r: int, i: int) -> Rect2:
	return Rect2(COL[r][0], y_slot(r, i) - ALT / 2, COL[r][1], ALT)


func atualizar(delta: float) -> void:
	t += delta
	if faixa_t >= 0.0:
		faixa_t += delta


func _visivel(r: int, i: int) -> float:
	## 0..1: quanto o vencedor deste slot já apareceu (slots de rodadas futuras dependem da animação)
	if r == 0:
		return 1.0
	for a in anim:
		if a["r"] + 1 == r and a["m"] == i:
			return clampf((t - a["t0"]) / 0.45, 0, 1)
	var d := Sessao.ta()
	return 1.0 if int(d["rodadas"][r][i]) >= 0 else 0.0


func _perdeu(r: int, i: int) -> float:
	## 0..1: quanto o X de eliminado já apareceu neste slot
	var d := Sessao.ta()
	if r >= int(d["rodada"]):
		return 0.0
	var idx: int = int(d["rodadas"][r][i])
	var prox: int = int(d["rodadas"][r + 1][i / 2])
	if prox < 0 or prox == idx:
		return 0.0
	for a in anim:
		if a["r"] == r and a["m"] == i / 2:
			return clampf((t - a["t0"] - 0.3) / 0.3, 0, 1)
	return 1.0


## Mostra os resultados de uma rodada, um a cada 0,7 s.
func animar(res: Array, r: int) -> void:
	var base := t + 0.3
	for k in res.size():
		var a: Dictionary = res[k]
		a["r"] = r
		a["t0"] = base + k * 0.7
		anim.append(a)
	var d := Sessao.ta()
	var fim := base + res.size() * 0.7 + 0.4
	f.get_tree().create_timer(fim - t).timeout.connect(func() -> void:
		anim.clear()
		if d["fim"] or d["eliminado"]:
			ganho = Sessao.ta_pagar()
			if d["fim"] or ganho > 0 or d["eliminado"]:
				faixa_t = 0.0
				var eu: int = (d["participantes"] as Array).find("jogador")
				if d["fim"] and int(d["rodadas"][3][0]) == eu:
					Sessao.vibrar_pulsos(4, 40, 0.9, 0.08)
				f.vibrar(30, 0.6)
		f._ir("chave"))


func desenhar() -> void:
	var d := Sessao.ta()
	if d.is_empty():
		return
	var r_atual: int = mini(int(d["rodada"]), 3)
	PixelFonte.centrado(f, Vector2(180, 22), Sessao.t("TORNEIO ARCADE"), f.OURO[0], 3, f.ESCURO)
	f._texto_central(Vector2(180, 46), Sessao.t(RODADA_NOME[r_atual]), Color(0.81, 0.88, 1.0))
	for r in 4:
		PixelFonte.centrado(f, Vector2(COL[r][0] + COL[r][1] / 2, 80), Sessao.t(["QUARTAS", "SEMI", "FINAL", "CAMPEÃO"][r]), Color(0.72, 0.66, 0.53), 1)
	var parts: Array = d["participantes"]
	var eu: int = parts.find("jogador")
	# linhas entre colunas (cinza; dourada no caminho do vencedor, crescendo durante a animação)
	for r in 3:
		for i in (8 >> r):
			var a := rect_slot(r, i)
			var b := rect_slot(r + 1, i / 2)
			var meio := a.end.x + (b.position.x - a.end.x) / 2
			var cinza := Color(0.4, 0.36, 0.42, 0.6)
			var p := [Vector2(a.end.x, a.get_center().y), Vector2(meio, a.get_center().y), Vector2(meio, b.get_center().y), Vector2(b.position.x, b.get_center().y)]
			for k in 3:
				f.draw_line(p[k], p[k + 1], cinza, 1.0)
			var venc: int = int(d["rodadas"][r + 1][i / 2])
			if venc >= 0 and venc == int(d["rodadas"][r][i]):
				var u := _visivel(r + 1, i / 2)
				var cor := Color(1.0, 0.85, 0.4)
				var total := 3.0 * u
				for k in 3:
					var seg := clampf(total - k, 0, 1)
					if seg > 0:
						f.draw_line(p[k], p[k].lerp(p[k + 1], seg), cor, 2.0)
				var margem := int(d["margem"].get("%d-%d" % [r, i / 2], 0))
				if u >= 1.0 and margem > 0:
					PixelFonte.centrado(f, Vector2(meio + 1, b.get_center().y - 7), "+%d" % margem, Color(1.0, 0.85, 0.4, 0.8), 1)
	# slots
	for r in 4:
		for i in (8 >> r):
			var idx: int = int(d["rodadas"][r][i])
			var u := _visivel(r, i)
			if idx < 0 or u <= 0.0:
				f.draw_rect(rect_slot(r, i), Color(0.12, 0.09, 0.12, 0.6))
				f.draw_rect(rect_slot(r, i), Color(0.3, 0.26, 0.32), false, 1.0)
				continue
			var rc := rect_slot(r, i)
			rc.position.x -= (1.0 - u) * 30
			_slot(rc, parts[idx], idx == eu, u, r == 3)
			var x := _perdeu(r, i)
			if x > 0.0:
				f.draw_rect(rc, Color(0.05, 0.02, 0.04, 0.6 * x))
				var c := rc.get_center()
				f.draw_line(c + Vector2(-7, -7) * x, c + Vector2(7, 7) * x, Color(0.9, 0.3, 0.3, x), 2.0)
				f.draw_line(c + Vector2(7, -7) * x, c + Vector2(-7, 7) * x, Color(0.9, 0.3, 0.3, x), 2.0)
	if faixa_t >= 0.0:
		_faixa(d, eu)
	f.mp._desenhar_aviso()


func _slot(r: Rect2, pid: String, sou_eu: bool, al: float, campeao: bool) -> void:
	var cor_borda := Color(1.0, 0.85, 0.4) if sou_eu else Color(0.5, 0.45, 0.52)
	if campeao:
		var pul := 0.5 + 0.5 * sin(f.tempo * 4)
		f.draw_rect(r.grow(3), Color(1.0, 0.85, 0.4, 0.4 * pul * al), false, 3.0)
	f.draw_rect(r.grow(1), Color(f.ESCURO, al))
	f.draw_rect(r, Color(0.16, 0.11, 0.15, al) if not sou_eu else Color(0.28, 0.2, 0.1, al))
	f.draw_rect(r, Color(cor_borda, al), false, 1.0)
	var foto := Rect2(r.position + Vector2(3, 3), Vector2(15, 20))
	f.draw_rect(foto, Color(0.08, 0.05, 0.08, al))
	if sou_eu:
		if f.mp.foto_tex:
			f.draw_texture_rect(f.mp.foto_tex, foto, false, Color(1, 1, 1, al))
	elif pid != "viajante":
		var tex := Carta.textura("retrato", pid, "png")
		if tex:
			var tw := float(tex.get_width())
			var src := Rect2(tw * 0.22, 0, tw * 0.56, tw * 0.56 * 20.0 / 15.0)
			f.draw_texture_rect_region(tex, foto, src, Color(1, 1, 1, al))
	else:
		f.draw_circle(foto.get_center() + Vector2(0, -3), 4.0, Color(0.45, 0.4, 0.5, al))
	var nome := Sessao.ta_nome(pid)
	var larg := int(r.size.x - 24)
	while Fonte57.largura(nome) > larg and nome.length() > 2:
		nome = nome.substr(0, nome.length() - 1)
	Fonte57.desenhar(f, r.position + Vector2(21, 9), nome, Color(f.OURO[0], al) if sou_eu else Color(f.CREME, al), f.ESCURO)


func _faixa(d: Dictionary, eu: int) -> void:
	var u := clampf(faixa_t / 0.35, 0, 1)
	var campeao: bool = d["fim"] and int(d["rodadas"][3][0]) == eu
	var c := Vector2(180, 548)
	if campeao:
		for k in 14:
			Efeitos.raio(f, c, faixa_t * 0.6 + TAU * k / 14.0, 260 * u, 0.09, Color(1.0, 0.86, 0.45, 0.3))
	var h := 40.0 * u
	f.draw_rect(Rect2(-10, c.y - h / 2, 380, h), Color(0.24, 0.12, 0.2, 0.95) if campeao else Color(0.1, 0.09, 0.12, 0.95))
	f.draw_rect(Rect2(-10, c.y - h / 2, 380, 2), f.OURO[1])
	f.draw_rect(Rect2(-10, c.y + h / 2 - 2, 380, 2), f.OURO[1])
	if u < 1.0:
		return
	var titulo := Sessao.t("CAMPEÃO!") if campeao else (Sessao.t("ELIMINADO") if d["eliminado"] else Sessao.t("FIM DO TORNEIO"))
	PixelFonte.centrado(f, c + Vector2(0, -7 + (absf(sin(faixa_t * 4)) * -2 if campeao else 0)), titulo, f.OURO[0] if campeao else Color("#b8b0c0"), 2, f.ESCURO)
	var p := int(d.get("premio", 0))
	if p > 0:
		var s := Sessao.t("+%d moedas") % p
		var w := Fonte57.largura(s)
		f.mp.moeda(Vector2(180 - w / 2.0 - 8, c.y + 11))
		Fonte57.desenhar(f, Vector2(180 - w / 2.0, c.y + 8), s, f.OURO[0], f.ESCURO)


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
	f._ir("chave")
	animar(res, r)


## Jogador eliminado: as rodadas seguintes são resolvidas e mostradas em sequência.
func ver_resto() -> void:
	var r := int(Sessao.ta()["rodada"])
	if r > 2:
		return
	var res := Sessao.ta_resolver_rodada(null)
	f._ir("chave")
	animar(res, r)


func concluir() -> void:
	Sessao.ta_encerrar()
	faixa_t = -1.0
	f._ir("arcade")
