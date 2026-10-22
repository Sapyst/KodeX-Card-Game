class_name MenuProgresso
extends RefCounted
## Tela Progresso (fluxo.gd, estado "progresso"; botão redondo no Início): abas Missões (3 do dia com 1 troca + 3 da
## semana), Nível (barra de XP, próximos prêmios, título em uso), Maestria (6 tradições) e Conquistas (50, em páginas).
## Regras e números em progresso.gd / dados/progressao.json. px nativos 360×640.

const ABAS := [["missoes", "Missões", "Missions"], ["nivel", "Nível", "Level"], ["maestria", "Maestria", "Mastery"],
	["conquistas", "Conquistas", "Achievements"]]
const POR_PAGINA := 9

var f
var aba := "missoes"
var pagina := 0


func _init(menu) -> void:
	f = menu


func _l(par: Array) -> String:
	return str(par[1] if Sessao.idioma == "en" else par[0])


func botoes() -> void:
	for i in ABAS.size():
		var a: String = ABAS[i][0]
		f._botao(Rect2(14 + i * 84, 88, 80, 22), "", func() -> void: aba = a; pagina = 0; f._ir("progresso"),
			{"desenho": _botao_aba.bind(i)})
	if OS.get_environment("GD_PROG_LOG") != "":
		print("MISSOES dia=", Progresso.hoje(), " ", Progresso.diarias().map(func(m: Dictionary) -> String: return m["id"]),
			" semana ", Progresso.semanais().map(func(m: Dictionary) -> String: return m["id"]))
	match aba:
		"missoes":
			var lista := Progresso.diarias()
			for k in 3:
				f._botao(Rect2(16, 148 + k * 46, 328, 42), "", func() -> void: pass, {"desenho": _linha_missao.bind("dia", lista[k], k)})
			var sem := Progresso.semanais()
			for k in 3:
				f._botao(Rect2(16, 330 + k * 46, 328, 42), "", func() -> void: pass, {"desenho": _linha_missao.bind("semana", sem[k], k)})
			var pr := Progresso.p()
			if int(pr["dia"].get("troca", -1)) < 0:
				for k in 3:
					if not Progresso.feita("dia", str(lista[k]["id"])):
						f._botao(Rect2(292, 152 + k * 46, 48, 16), "", _trocar.bind(k), {"desenho": _botao_trocar})
		"nivel":
			var ts: Array = Sessao.perfil.get("titulos", [])
			for i in mini(ts.size(), 12):
				var id := str(ts[i])
				f._botao(Rect2(30 + (i % 2) * 152, 352 + (i / 2) * 30, 148, 26), "",
					func() -> void: Sessao.perfil["titulo"] = "" if str(Sessao.perfil.get("titulo", "")) == id else id; Sessao.salvar(); f._ir("progresso"),
					{"desenho": _botao_titulo.bind(id)})
		"conquistas":
			var tot: int = (Progresso.dados()["conquistas"] as Array).size()
			var paginas := ceili(tot / float(POR_PAGINA))
			var lista: Array = _conquistas_ordenadas()
			for k in POR_PAGINA:
				var i := pagina * POR_PAGINA + k
				if i < tot:
					f._botao(Rect2(16, 120 + k * 46, 328, 42), "", func() -> void: pass, {"desenho": _linha_conquista.bind(lista[i])})
			if pagina > 0:
				f._botao(Rect2(16, 540, 70, 24), "<", func() -> void: pagina -= 1; f._ir("progresso"))
			if pagina < paginas - 1:
				f._botao(Rect2(274, 540, 70, 24), ">", func() -> void: pagina += 1; f._ir("progresso"))
	f._botao(Rect2(110, 572, 140, 26), "Voltar", func() -> void: f._ir("titulo"))


func _trocar(k: int) -> void:
	f.confirmar(Sessao.t("Trocar esta missão?"), Sessao.t("só 1 troca por dia"), func() -> void:
		if Progresso.trocar(k):
			f.vibrar(15, 0.5)
		f._ir("progresso"))


# ---------------- desenho ----------------
func desenhar() -> void:
	f._cabecalho(_l(["Progresso", "Progress"]), _l(["missões, nível e conquistas", "missions, level and achievements"]))
	match aba:
		"missoes":
			var h := Relogio.segundos_ate_amanha()
			_rotulo(Vector2(18, 128), _l(["HOJE", "TODAY"]), _l(["novas em %dh %02dmin", "new in %dh %02dmin"]) % [h / 3600, (h % 3600) / 60])
			var b := Relogio.segundos_ate_segunda()
			_rotulo(Vector2(18, 310), _l(["SEMANA", "WEEK"]), _l(["novas em %d dias e %dh", "new in %d days %dh"]) % [b / 86400, (b % 86400) / 3600])
			var seq := int(Sessao.perfil.get("resgates", {}).get("seq", 0))
			f._texto_central(Vector2(180, 486), _l(["Dias seguidos: %d  ·  bônus a cada 7 (+1 booster, +20 Koins)", "Days in a row: %d  ·  bonus every 7 (+1 booster, +20 Koins)"]) % seq, Color("#9ad0ff"))
			f._texto_central(Vector2(180, 502), _l(["Missões pagam na hora, ao terminar a partida.", "Missions pay right away, when the match ends."]), Color(0.72, 0.66, 0.6))
		"nivel":
			_desenhar_nivel()
		"maestria":
			_desenhar_maestria()
		"conquistas":
			var feitas: int = (Progresso.p()["conquistas"] as Array).size()
			var tot: int = (Progresso.dados()["conquistas"] as Array).size()
			f._texto_central(Vector2(180, 552), "%d / %d  ·  %s %d/%d" % [feitas, tot, _l(["página", "page"]), pagina + 1, ceili(tot / float(POR_PAGINA))], Color(0.72, 0.66, 0.6))


func _rotulo(pos: Vector2, titulo: String, sub: String) -> void:
	PixelFonte.desenhar(f, pos, titulo, f.OURO[0])
	Fonte57.desenhar(f, Vector2(342 - Fonte57.largura(sub), pos.y - 1), sub, Color(0.72, 0.66, 0.6), f.ESCURO)


func _botao_aba(_b: Dictionary, r: Rect2, pressao: float, i: int) -> void:
	var ativa: bool = ABAS[i][0] == aba
	var dd: Rect2 = f._painel(r, ativa, pressao, Color("#3a2410") if ativa else Color("#241a20"))
	f._texto_central(dd.get_center(), _l([ABAS[i][1], ABAS[i][2]]), f.OURO[0] if ativa else Color("#b8b0c0"))


func _barra(r: Rect2, frac: float, cor: Color) -> void:
	f.draw_rect(r.grow(1), f.ESCURO)
	f.draw_rect(r, Color("#140c10"))
	f.draw_rect(Rect2(r.position, Vector2(roundf(r.size.x * clampf(frac, 0.0, 1.0)), r.size.y)), cor)
	f.draw_rect(Rect2(r.position, Vector2(roundf(r.size.x * clampf(frac, 0.0, 1.0)), 1)), cor.lightened(0.35))


func _linha_missao(_b: Dictionary, r: Rect2, pressao: float, escopo: String, m: Dictionary, _k: int) -> void:
	var feita := Progresso.feita(escopo, str(m["id"]))
	var dd: Rect2 = f._painel(r, feita, pressao, Color("#2a2010") if feita else Color("#1e161e"))
	var tx := Progresso.texto(m)
	Fonte57.desenhar(f, dd.position + Vector2(8, 4), tx, f.OURO[0] if feita else f.CREME, f.ESCURO)
	var prem := {}
	for k in ["moedas", "booster", "koins"]:
		if m.has(k):
			prem[k] = int(m[k])
	var andamento := Progresso.andamento(escopo, m)
	var alvo := int(m["alvo"])
	_barra(Rect2(dd.position + Vector2(8, 18), Vector2(150, 5)), float(andamento) / alvo, Color("#3a8a4a") if feita else f.OURO[1])
	Fonte57.desenhar(f, dd.position + Vector2(164, 15), "%d/%d" % [andamento, alvo], Color(0.72, 0.66, 0.6), f.ESCURO)
	Fonte57.desenhar(f, dd.position + Vector2(8, 26), Progresso.premio_txt(prem) + ("  ·  " + _l(["feita", "done"]) if feita else ""),
		Color("#9ad08a") if feita else Color("#e0c88a"), f.ESCURO)


func _botao_trocar(_b: Dictionary, r: Rect2, pressao: float) -> void:
	var dd: Rect2 = f._painel(r, false, pressao, Color("#30202a"))
	f._texto_central(dd.get_center(), _l(["trocar", "swap"]), Color("#d8c8ff"))


func _desenhar_nivel() -> void:
	var pr := Progresso.p()
	var nv: Array = Progresso.nivel_de(int(pr.get("xp", 0)))
	PixelFonte.centrado(f, Vector2(180, 150), str(nv[0]), f.OURO[0], 5, f.ESCURO)
	f._texto_central(Vector2(180, 182), _l(["nível", "level"]), Color(0.72, 0.66, 0.6))
	_barra(Rect2(60, 194, 240, 8), float(nv[1]) / float(nv[2]), f.OURO[1])
	f._texto_central(Vector2(180, 214), "%d / %d XP" % [nv[1], nv[2]], f.CREME)
	f._texto_central(Vector2(180, 226), _l(["XP: vitória 30 · derrota 15 · empate 20 · online +10",
		"XP: win 30 · loss 15 · draw 20 · online +10"]), Color(0.6, 0.55, 0.55))
	f._texto_central(Vector2(180, 238), _l(["missão do dia +20 · semanal +60", "daily mission +20 · weekly +60"]), Color(0.6, 0.55, 0.55))
	PixelFonte.desenhar(f, Vector2(18, 254), _l(["PRÓXIMOS PRÊMIOS", "NEXT REWARDS"]), f.OURO[0])
	for k in 4:
		var n: int = int(nv[0]) + 1 + k
		Fonte57.desenhar(f, Vector2(24, 268 + k * 14), _l(["Nível %d", "Level %d"]) % n, f.CREME, f.ESCURO)
		Fonte57.desenhar(f, Vector2(90, 268 + k * 14), Progresso.premio_txt(Progresso.premio_nivel(n)), Color("#e0c88a"), f.ESCURO)
	PixelFonte.desenhar(f, Vector2(18, 340), _l(["TÍTULOS  (TOQUE PARA USAR)", "TITLES  (TAP TO WEAR)"]), f.OURO[0])
	if (Sessao.perfil.get("titulos", []) as Array).is_empty():
		f._texto_central(Vector2(180, 372), _l(["Ganhe títulos subindo de nível, nas conquistas e na maestria.",
			"Earn titles by leveling up, with achievements and mastery."]), Color(0.72, 0.66, 0.6))


func _botao_titulo(_b: Dictionary, r: Rect2, pressao: float, id: String) -> void:
	var usando := str(Sessao.perfil.get("titulo", "")) == id
	var dd: Rect2 = f._painel(r, usando, pressao, Color("#3a2410") if usando else Color("#241a20"))
	f._texto_central(dd.get_center(), Progresso.nome_titulo(id), f.OURO[0] if usando else f.CREME)


func _desenhar_maestria() -> void:
	var lim: Array = Progresso.dados()["maestria"]["limites"]
	var k := 0
	for t in Progresso.dados()["tradicoes"]:
		var r := Rect2(16, 124 + k * 66, 328, 60)
		var dd: Rect2 = f._painel(r, false, 0.0, Color(Sessao.personagem(t).get("cor", "#3a3050")).darkened(0.65))
		var tex := Carta.textura("retrato", t, "png")
		if tex:
			var ft := Rect2(dd.position + Vector2(4, 4), Vector2(38, dd.size.y - 8))
			f.draw_rect(ft.grow(1), f.OURO[2])
			f.draw_texture_rect_region(tex, ft, Rect2(tex.get_width() * 0.15, 0, tex.get_width() * 0.7, tex.get_width() * 0.7 * ft.size.y / ft.size.x))
		var n := Progresso.maestria_nivel(t)
		var x := int(Progresso.p()["maestria"].get(t, 0))
		Fonte57.desenhar(f, dd.position + Vector2(50, 4), Sessao.nome_deck(t), f.OURO[0], f.ESCURO)
		for e in 5:                                     # 5 losangos: acesos = níveis de maestria
			var c := Vector2(dd.end.x - 46 + e * 9, dd.position.y + 8)
			var pts := PackedVector2Array([c + Vector2(0, -4), c + Vector2(4, 0), c + Vector2(0, 4), c + Vector2(-4, 0)])
			f.draw_colored_polygon(pts, f.OURO[0] if e < n else Color("#3a2c36"))
		var prox := int(lim[mini(n, lim.size() - 1)])
		var ant := 0 if n == 0 else int(lim[n - 1])
		_barra(Rect2(dd.position + Vector2(50, 18), Vector2(dd.size.x - 58, 5)), 1.0 if n >= lim.size() else float(x - ant) / float(prox - ant), f.OURO[1])
		var sub := _l(["máxima!", "maxed!"]) if n >= lim.size() else ("%d / %d XP  ·  " % [x, prox] + _l(["próximo: ", "next: "]) +
			Progresso.premio_txt(_premio_maestria(t, n + 1)))
		Fonte57.desenhar(f, dd.position + Vector2(50, 28), sub, Color("#e0c88a"), f.ESCURO)
		Fonte57.desenhar(f, dd.position + Vector2(50, 40), _l(["XP das partidas com um deck desta tradição", "XP from matches with a deck of this tradition"]), Color(0.6, 0.55, 0.55), f.ESCURO)
		k += 1


func _premio_maestria(t: String, n: int) -> Dictionary:
	var r: Dictionary = (Progresso.dados()["maestria"]["premios"][n - 1] as Dictionary).duplicate()
	if r.has("titulo"):
		r["titulo"] = str(r["titulo"]) + t
	return r


## Feitas primeiro? Não: as que faltam primeiro (o que dá para buscar), feitas no fim.
func _conquistas_ordenadas() -> Array:
	var feitas: Array = Progresso.p()["conquistas"]
	var lista: Array = Progresso.dados()["conquistas"]
	return lista.filter(func(c: Dictionary) -> bool: return not (c["id"] in feitas)) + lista.filter(func(c: Dictionary) -> bool: return c["id"] in feitas)


func _linha_conquista(_b: Dictionary, r: Rect2, pressao: float, c: Dictionary) -> void:
	var feita: bool = c["id"] in (Progresso.p()["conquistas"] as Array)
	var dd: Rect2 = f._painel(r, feita, pressao, Color("#2a2010") if feita else Color("#1e161e"))
	Fonte57.desenhar(f, dd.position + Vector2(8, 4), Progresso.texto(c), f.OURO[0] if feita else f.CREME, f.ESCURO)
	var v := mini(Progresso.valor(str(c["cont"])), int(c["alvo"]))
	_barra(Rect2(dd.position + Vector2(8, 18), Vector2(150, 5)), float(v) / float(c["alvo"]), Color("#3a8a4a") if feita else f.OURO[1])
	Fonte57.desenhar(f, dd.position + Vector2(164, 15), "%d/%d" % [v, int(c["alvo"])], Color(0.72, 0.66, 0.6), f.ESCURO)
	var r2 := {"moedas": int(c.get("moedas", 0))}
	if c.has("titulo"):
		r2["titulo"] = c["titulo"]
	Fonte57.desenhar(f, dd.position + Vector2(8, 26), Progresso.premio_txt(r2) + ("  ·  " + _l(["conquistada", "earned"]) if feita else ""),
		Color("#9ad08a") if feita else Color("#e0c88a"), f.ESCURO)
