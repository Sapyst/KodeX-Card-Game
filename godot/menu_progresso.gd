class_name MenuProgresso
extends RefCounted
## Tela Progresso (fluxo.gd, estado "progresso"; botão redondo no Início): abas Missões (3 do dia com 1 troca + 3 da
## semana), Nível (barra de XP, próximos prêmios, título em uso), Maestria (6 tradições) e Conquistas (50, em páginas).
## Regras e números em progresso.gd / dados/progressao.json. px nativos 360×640.

const ABAS := [["missoes", "Missões", "Missions"], ["calendario", "Calendário", "Calendar"], ["nivel", "Nível", "Level"],
	["maestria", "Maestria", "Mastery"], ["conquistas", "Conquistas", "Achievements"]]
const TITULOS_POR_PAGINA := 12
const POR_PAGINA := 9

var f
var aba := "missoes"
var pagina := 0


func _init(menu) -> void:
	f = menu


func _l(par) -> String:
	return str(Sessao.par(par))


func botoes() -> void:
	for i in ABAS.size():
		var a: String = ABAS[i][0]
		f._botao(Rect2(14 + i * 67, 88, 64, 22), "", func() -> void: aba = a; pagina = 0; f._ir("progresso"),
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
						f._botao(Rect2(292, 152 + k * 46, 48, 16), "", _trocar.bind(k), {"desenho": _botao_trocar, "toque": Rect2(284, 144 + k * 46, 64, 32)})
		"nivel":
			var ts: Array = Sessao.perfil.get("titulos", [])
			var pags := ceili(ts.size() / float(TITULOS_POR_PAGINA))
			for j in TITULOS_POR_PAGINA:
				var i := pagina * TITULOS_POR_PAGINA + j
				if i >= ts.size():
					break
				var id := str(ts[i])
				f._botao(Rect2(30 + (j % 2) * 152, 352 + (j / 2) * 30, 148, 26), "",
					func() -> void: Sessao.perfil["titulo"] = "" if str(Sessao.perfil.get("titulo", "")) == id else id; Sessao.salvar(); f._ir("progresso"),
					{"desenho": _botao_titulo.bind(id)})
			if pagina > 0:
				f._botao(Rect2(16, 540, 70, 24), "<", func() -> void: pagina -= 1; f._ir("progresso"))
			if pagina < pags - 1:
				f._botao(Rect2(274, 540, 70, 24), ">", func() -> void: pagina += 1; f._ir("progresso"))
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
	f._cabecalho(Sessao.t("Progresso"), Sessao.t("missões, nível e conquistas"))
	match aba:
		"missoes":
			if Relogio.sincronizado():
				var h := Relogio.segundos_ate_amanha()
				_rotulo(Vector2(18, 128), Sessao.t("HOJE"), Sessao.t("novas em %dh %02dmin") % [h / 3600, (h % 3600) / 60])
				var b := Relogio.segundos_ate_segunda()
				_rotulo(Vector2(18, 310), Sessao.t("SEMANA"), Sessao.t("novas em %d dias e %dh") % [b / 86400, (b % 86400) / 3600])
			else:                                           # sem a hora da internet a contagem seria inventada
				_rotulo(Vector2(18, 128), Sessao.t("HOJE"), Sessao.t("aguardando a hora da internet"))
				_rotulo(Vector2(18, 310), Sessao.t("SEMANA"), Sessao.t("aguardando a hora da internet"))
			var seq := int(Sessao.perfil.get("resgates", {}).get("seq", 0))
			f._texto_central(Vector2(180, 486), Sessao.t("Dias seguidos: %d  ·  bônus a cada 7 (+1 booster, +20 Koins)") % seq, Color("#9ad0ff"))
			f._texto_central(Vector2(180, 502), Sessao.t("Missões pagam na hora, ao terminar a partida."), Color(0.72, 0.66, 0.6))
		"calendario":
			_desenhar_calendario()
		"nivel":
			_desenhar_nivel()
		"maestria":
			_desenhar_maestria()
		"conquistas":
			var feitas: int = (Progresso.p()["conquistas"] as Array).size()
			var tot: int = (Progresso.dados()["conquistas"] as Array).size()
			f._texto_central(Vector2(180, 552), "%d / %d  ·  %s %d/%d" % [feitas, tot, Sessao.t("página"), pagina + 1, ceili(tot / float(POR_PAGINA))], Color(0.72, 0.66, 0.6))


func _rotulo(pos: Vector2, titulo: String, sub: String) -> void:
	PixelFonte.desenhar(f, pos, titulo, f.OURO[0])
	Fonte57.desenhar(f, Vector2(342 - Fonte57.largura(sub), pos.y - 1), sub, Color(0.72, 0.66, 0.6), f.ESCURO)


func _botao_aba(_b: Dictionary, r: Rect2, pressao: float, i: int) -> void:
	var ativa: bool = ABAS[i][0] == aba
	var dd: Rect2 = f._painel(r, ativa, pressao, Color("#3a2410") if ativa else Color("#241a20"))
	f._texto_central(dd.get_center(), Sessao.t(ABAS[i][1]), f.OURO[0] if ativa else Color("#b8b0c0"))


func _barra(r: Rect2, frac: float, cor: Color) -> void:
	f.draw_rect(r.grow(1), f.ESCURO)
	f.draw_rect(r, Color("#140c10"))
	f.draw_rect(Rect2(r.position, Vector2(roundf(r.size.x * clampf(frac, 0.0, 1.0)), r.size.y)), cor)
	f.draw_rect(Rect2(r.position, Vector2(roundf(r.size.x * clampf(frac, 0.0, 1.0)), 1)), cor.lightened(0.35))


func _linha_missao(_b: Dictionary, r: Rect2, pressao: float, escopo: String, m: Dictionary, _k: int) -> void:
	var feita := Progresso.feita(escopo, str(m["id"]))
	var dd: Rect2 = f._painel(r, feita, pressao, Color("#2a2010") if feita else Color("#1e161e"))
	var tx := Fonte57.cortar(Progresso.texto(m), int(dd.size.x) - 16 - (64 if escopo == "dia" else 0))   # não invade o "trocar"
	Fonte57.desenhar(f, dd.position + Vector2(8, 4), tx, f.OURO[0] if feita else f.CREME, f.ESCURO)
	var prem := Progresso.premio_missao(m, _k) if escopo == "dia" else Progresso.premio_semanal(m)
	var andamento := Progresso.andamento(escopo, m)
	var alvo := int(m["alvo"])
	_barra(Rect2(dd.position + Vector2(8, 18), Vector2(150, 5)), float(andamento) / alvo, Color("#3a8a4a") if feita else f.OURO[1])
	var ct := "%d/%d" % [andamento, alvo]
	Fonte57.desenhar(f, dd.position + Vector2(dd.size.x - 8 - Fonte57.largura(ct), 26), ct, Color(0.72, 0.66, 0.6), f.ESCURO)   # à direita, na linha do prêmio
	Fonte57.desenhar(f, dd.position + Vector2(8, 26), Progresso.premio_txt(prem) + ("  ·  " + Sessao.t("feita") if feita else ""),
		Color("#9ad08a") if feita else Color("#e0c88a"), f.ESCURO)


func _botao_trocar(_b: Dictionary, r: Rect2, pressao: float) -> void:
	var dd: Rect2 = f._painel(r, false, pressao, Color("#30202a"))
	f._texto_central(dd.get_center(), Sessao.t("trocar"), Color("#d8c8ff"))


func _desenhar_nivel() -> void:
	var pr := Progresso.p()
	var nv: Array = Progresso.nivel_de(int(pr.get("xp", 0)))
	PixelFonte.centrado(f, Vector2(180, 150), str(nv[0]), f.OURO[0], 5, f.ESCURO)
	f._texto_central(Vector2(180, 182), Sessao.t("nível"), Color(0.72, 0.66, 0.6))
	_barra(Rect2(60, 194, 240, 8), float(nv[1]) / float(nv[2]), f.OURO[1])
	f._texto_central(Vector2(180, 214), "%d / %d XP" % [nv[1], nv[2]], f.CREME)
	var x: Dictionary = Progresso.dados()["xp"]
	f._texto_central(Vector2(180, 226), Sessao.t("XP: vitória %d · derrota %d · empate %d · online +%d") % [int(x["vitoria"]), int(x["derrota"]), int(x["empate"]), int(x["online"])], Color(0.6, 0.55, 0.55))
	f._texto_central(Vector2(180, 238), Sessao.t("missão do dia +%d · semanal +%d") % [int(x["missao"]), int(x["semanal"])], Color(0.6, 0.55, 0.55))
	PixelFonte.desenhar(f, Vector2(18, 254), Sessao.t("PRÓXIMOS PRÊMIOS"), f.OURO[0])
	for k in 4:
		var n: int = int(nv[0]) + 1 + k
		Fonte57.desenhar(f, Vector2(24, 268 + k * 14), Sessao.t("Nível %d") % n, f.CREME, f.ESCURO)
		Fonte57.desenhar(f, Vector2(90, 268 + k * 14), Progresso.premio_txt(Progresso.premio_nivel(n)), Color("#e0c88a"), f.ESCURO)
	PixelFonte.desenhar(f, Vector2(18, 340), Sessao.t("TÍTULOS  (TOQUE PARA USAR)"), f.OURO[0])
	if (Sessao.perfil.get("titulos", []) as Array).is_empty():
		var ls := Fonte57.quebrar(Sessao.t("Ganhe títulos subindo de nível, nas conquistas e na maestria."), 320)
		for k in ls.size():
			f._texto_central(Vector2(180, 372 + k * 12 * Fonte57.fator), ls[k], Color(0.72, 0.66, 0.6))


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
		Fonte57.desenhar(f, dd.position + Vector2(50, 4), Fonte57.cortar(Sessao.nome_deck(t), int(dd.size.x) - 140), f.OURO[0], f.ESCURO)
		for e in lim.size():                            # 10 losangos: acesos = níveis de maestria
			var c := Vector2(dd.end.x - 6 - (lim.size() - e) * 8, dd.position.y + 8)
			var pts := PackedVector2Array([c + Vector2(0, -4), c + Vector2(4, 0), c + Vector2(0, 4), c + Vector2(-4, 0)])
			f.draw_colored_polygon(pts, f.OURO[0] if e < n else Color("#3a2c36"))
		var prox := int(lim[mini(n, lim.size() - 1)])
		var ant := 0 if n == 0 else int(lim[n - 1])
		_barra(Rect2(dd.position + Vector2(50, 18), Vector2(dd.size.x - 58, 5)), 1.0 if n >= lim.size() else float(x - ant) / float(prox - ant), f.OURO[1])
		var sub := Sessao.t("máxima!") if n >= lim.size() else ("%d / %d XP  ·  " % [x, prox] + Sessao.t("próximo: ") +
			Progresso.premio_txt(_premio_maestria(t, n + 1)))
		var lw := int(dd.size.x) - 56
		Fonte57.desenhar(f, dd.position + Vector2(50, 28), Fonte57.cortar(sub, lw), Color("#e0c88a"), f.ESCURO)
		Fonte57.desenhar(f, dd.position + Vector2(50, 40), Fonte57.cortar(Sessao.t("XP das partidas com um deck desta tradição"), lw), Color(0.6, 0.55, 0.55), f.ESCURO)
		k += 1


func _premio_maestria(t: String, n: int) -> Dictionary:
	return Progresso.premio_maestria(t, n)


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
	var ct := "%d/%d" % [v, int(c["alvo"])]
	Fonte57.desenhar(f, dd.position + Vector2(dd.size.x - 8 - Fonte57.largura(ct), 26), ct, Color(0.72, 0.66, 0.6), f.ESCURO)
	var r2 := Progresso.premio_conquista(c)
	Fonte57.desenhar(f, dd.position + Vector2(8, 26), Progresso.premio_txt(r2) + ("  ·  " + Sessao.t("conquistada") if feita else ""),
		Color("#9ad08a") if feita else Color("#e0c88a"), f.ESCURO)


## Calendário de 28 dias: cada presente diário resgatado marca 1 dia (faltar não zera; no 28º recomeça).
func _desenhar_calendario() -> void:
	var cal: Array = Progresso.dados()["calendario"]
	var c: Dictionary = Sessao.perfil.get("cal", {})
	var feitos := int(c.get("n", 0))
	for d in cal.size():
		var r := Rect2(19 + (d % 7) * 46, 128 + (d / 7) * 62, 44, 58)
		var marcado := d < feitos
		var proximo := d == feitos
		var grande := d == 6 or d == 13 or d == 20 or d == 27
		var fundo := Color("#3a2c12") if marcado else (Color("#2a1f2a") if not grande else Color("#2c2030"))
		f.draw_rect(r.grow(1), f.ESCURO)
		f.draw_rect(r, fundo)
		f.draw_rect(Rect2(r.position, Vector2(r.size.x, 1)), f.OURO[2] if not grande else f.OURO[0])
		if proximo:
			f.draw_rect(r.grow(2), Color(1.0, 0.85, 0.4, 0.3 + 0.25 * sin(f.tempo * 4.0)), false, 1.0)
		var dia := str(d + 1)
		Fonte57.desenhar(f, r.position + Vector2(4, 4), dia, f.OURO[0] if marcado else Color(0.72, 0.66, 0.6), f.ESCURO)
		var linhas := _rotulo_cal(cal[d])
		for k in linhas.size():
			var tx: String = linhas[k]
			Fonte57.desenhar(f, Vector2(r.get_center().x - Fonte57.largura(tx) / 2.0, r.position.y + 22 + k * 12), tx,
				Color("#9ad08a") if marcado else Color("#e0c88a"), f.ESCURO)
		if marcado:                                       # visto: dia já recebido
			f.draw_line(r.position + Vector2(30, 8), r.position + Vector2(33, 11), Color("#9ad08a"), 2.0)
			f.draw_line(r.position + Vector2(33, 11), r.position + Vector2(39, 4), Color("#9ad08a"), 2.0)
	var y := 128 + 4 * 62 + 10
	f._texto_central(Vector2(180, y), Sessao.t("Dias marcados: %d de 28  ·  ciclo %d") % [feitos, int(c.get("ciclo", 0)) + 1], f.CREME)
	if feitos < cal.size():
		f._texto_central(Vector2(180, y + 14), Sessao.t("Próximo: ") + Progresso.premio_txt(cal[feitos]), Color("#e0c88a"))
	var ls := Fonte57.quebrar(Sessao.t("Cada presente diário marca 1 dia. Faltar um dia não zera: o calendário continua de onde parou."), 320)
	for k in ls.size():
		f._texto_central(Vector2(180, y + 34 + k * 12), ls[k], Color(0.72, 0.66, 0.6))


## Rótulo curto do prêmio de um dia (até 2 linhas que cabem em 44 px).
func _rotulo_cal(r: Dictionary) -> Array:
	var out: Array = []
	if str(r.get("escolha", "")) != "":
		out.append(Sessao.t("carta"))
		out.append(Sessao.t("à escolha"))
	if int(r.get("moedas", 0)) > 0:
		out.append("+%d" % int(r["moedas"]))
		out.append(Sessao.t("ouro"))
	if int(r.get("koins", 0)) > 0:
		out.append("+%d" % int(r["koins"]))
		out.append("Koins")
	if int(r.get("essencia", 0)) > 0:
		out.append("+%d" % int(r["essencia"]))
		out.append(Sessao.t("Ess."))
	if int(r.get("booster", 0)) > 0:
		out.append("%dx" % int(r["booster"]))
		out.append("booster")
	if int(r.get("booster_trad", 0)) > 0:
		out.append("booster")
		out.append(Sessao.t("tradição"))
	return out.slice(0, 2) if out.size() <= 2 else [out[0], out[1]]
