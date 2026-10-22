class_name Historico
extends RefCounted
## Histórico do perfil (fluxo.gd, estado "historico"): contadores (contra a IA / contra jogadores, por modo, por
## adversário), as últimas partidas (adversário, IA ou jogador, data e hora, modo, resultado, turnos) e, ao tocar numa
## delas, o log jogada a jogada num pergaminho. Dados em Sessao.perfil["historico"] e ["estat"] (sincronizados).

const MODOS := {"arcade": "Arcade", "arcade_t": "Torneio de 8", "torneio": "Torneio",
	"peregrinacao": "Peregrinação", "diario": "Desafio do dia", "lendario": "Lendário",
	"livre": "Modo livre", "choronzon": "Choronzon", "online": "Online", "bot": "Online (bot)"}
const NIVEIS := ["Aprendiz", "Mestre", "Arquimago"]
const POR_TELA := 9

var f


func _init(menu) -> void:
	f = menu


func _l(par) -> String:
	return Sessao.par(par)


static func nome_modo(m: String) -> String:
	return Sessao.par(MODOS.get(m, [m, m]))


func _data(t: int) -> String:
	var bias: int = int(Time.get_time_zone_from_system().get("bias", 0))
	var d := Time.get_datetime_dict_from_unix_time(t + bias * 60)
	return "%02d/%02d %02d:%02d" % [d["day"], d["month"], d["hour"], d["minute"]]


func _placar(l: Dictionary) -> String:
	return "%dV %dD %dE" % [int(l.get("v", 0)), int(l.get("d", 0)), int(l.get("e", 0))]


func _total(l: Dictionary) -> int:
	return int(l.get("v", 0)) + int(l.get("d", 0)) + int(l.get("e", 0))


func botoes() -> void:
	var h: Array = Sessao.perfil.get("historico", [])
	for k in mini(h.size(), POR_TELA):
		f._botao(Rect2(16, 196 + k * 38, 328, 34), "", abrir_log.bind(k), {"hist_k": k, "desenho": botao_linha})
	f._botao(Rect2(110, 196 + POR_TELA * 38 + 8, 140, 26), "Voltar", func() -> void: f._ir("perfil"))


func desenhar() -> void:
	f._cabecalho(Sessao.t("Histórico"), Sessao.t("suas partidas e números"))
	var e: Dictionary = Sessao.perfil.get("estat", {})
	var contra: Dictionary = e.get("contra", {})
	var ia: Dictionary = contra.get("ia", {})
	var jg: Dictionary = contra.get("jogador", {})
	var y := 92.0
	f._texto_central(Vector2(180, y), Sessao.t("Contra a IA: %d  ·  %s") % [_total(ia), _placar(ia)], f.CREME)
	f._texto_central(Vector2(180, y + 13), Sessao.t("Contra jogadores: %d  ·  %s") % [_total(jg), _placar(jg)], Color("#9ad0ff"))
	var modos: Dictionary = e.get("modos", {})
	var partes := PackedStringArray()
	for m in modos:
		partes.append("%s %d" % [nome_modo(m), _total(modos[m])])
	var linhas := Fonte57.quebrar("  ·  ".join(partes) if not partes.is_empty() else Sessao.t("Nenhuma partida ainda."), 330)
	for k in mini(linhas.size(), 3):
		f._texto_central(Vector2(180, y + 30 + k * 11), linhas[k], Color(0.72, 0.66, 0.6))
	var adv: Dictionary = e.get("adversarios", {})
	var top := ""
	var topn := 0
	for a in adv:
		if _total(adv[a]) > topn:
			topn = _total(adv[a])
			top = a
	if top != "":
		f._texto_central(Vector2(180, y + 66), Sessao.t("Mais enfrentado: %s (%d, %s)") % [top, topn, _placar(adv[top])], f.OURO[1])
	PixelFonte.desenhar(f, Vector2(18, 184), Sessao.t("ÚLTIMAS PARTIDAS"), f.OURO[0])


func botao_linha(b: Dictionary, r: Rect2, pressao: float) -> void:
	var p: Dictionary = Sessao.perfil["historico"][b["hist_k"]]
	var res: String = p.get("resultado", "")
	var cor: Color = Color("#3a8a4a") if res == "vitoria" else (Color("#8a3a3a") if res == "derrota" else Color("#5a5a60"))
	var fundo := Color("#1a2a1c") if res == "vitoria" else (Color("#2e1618") if res == "derrota" else Color("#1e161e"))   # verde / vermelho
	var dentro: Rect2 = f._painel(r, false, pressao, fundo)
	f.draw_rect(Rect2(dentro.position, Vector2(18, dentro.size.y)), cor)
	PixelFonte.centrado(f, Vector2(dentro.position.x + 9, dentro.get_center().y), {"vitoria": "V", "derrota": "D"}.get(res, "E"), Color.WHITE, 1)
	var contra := str(p.get("adversario", "?"))
	if p.get("contra", "ia") == "bot":
		pass                                             # o nome já termina em " - Bot"
	elif p.get("contra", "ia") == "ia":
		contra += "  ·  " + Sessao.t("IA") + " " + _l(NIVEIS[clampi(int(p.get("nivel", 1)), 0, 2)])
	else:
		contra += "  ·  " + Sessao.t("jogador")
	Fonte57.desenhar(f, dentro.position + Vector2(24, 3), contra, f.CREME, f.ESCURO)
	var info := "%s  ·  %s  ·  %d %s" % [_data(int(p.get("t", 0))), nome_modo(str(p.get("modo", ""))), int(p.get("turnos", 0)), Sessao.t("turnos")]
	Fonte57.desenhar(f, dentro.position + Vector2(24, 15), info, Color(0.72, 0.66, 0.6), f.ESCURO)
	var rt: String = Sessao.t({"vitoria": "hist|VITÓRIA", "derrota": "hist|DERROTA"}.get(res, "hist|EMPATE"))
	PixelFonte.desenhar(f, Vector2(dentro.end.x - PixelFonte.largura(rt) - 6, dentro.position.y + 4), rt,
		Color("#7fcf8a") if res == "vitoria" else (Color("#ff8a7a") if res == "derrota" else Color("#a89a8e")))


func _nome_carta(cid: String) -> String:
	if cid == "":
		return "?"
	if Sessao.db["cartas"].has(cid):
		return str(Sessao.db["cartas"][cid]["nome"])
	for nome in Sessao.tokens:
		if Sessao.tokens[nome]["id"] == cid:
			return Sessao.nome_token(nome)
	return cid


func abrir_log(k: int) -> void:
	var p: Dictionary = Sessao.perfil["historico"][k]
	var st: Dictionary = p.get("stats", {})
	var res := _l({"vitoria": "Vitória", "derrota": "Derrota"}.get(p.get("resultado", ""), "Empate"))
	var b: Array = [["titulo", res], ["centro", "%s  ·  %s" % [str(p.get("adversario", "")), _data(int(p.get("t", 0)))]],
		["centro", "%s  ·  %d %s  ·  %d min" % [nome_modo(str(p.get("modo", ""))), int(p.get("turnos", 0)), Sessao.t("turnos"), int(p.get("duracao", 0)) / 60]],
		["divisor"],
		["item", Sessao.t("Cartas jogadas: %d (oponente %d)") % [int(st.get("cartas", 0)), int(st.get("cartas_op", 0))]],
		["item", Sessao.t("Dano causado: %d  ·  recebido: %d") % [int(st.get("dano", 0)), int(st.get("recebido", 0))]],
		["item", Sessao.t("Entidades destruídas: %d  ·  perdidas: %d") % [int(st.get("mortes", 0)), int(st.get("perdas", 0))]],
		["sub", Sessao.t("Jogada a jogada")]]
	for ln in p.get("log", []):
		var turno := int(ln[0])
		var quem := Sessao.t("Você") if int(ln[1]) == 0 else str(p.get("adversario", Sessao.t("Oponente")))
		var carta := _nome_carta(str(ln[3]))
		var alvo := _nome_carta(str(ln[4])) if str(ln[4]) != "" else ""
		var t := ""
		match str(ln[2]):
			"entidade": t = Sessao.t("invocou %s") % carta
			"rito": t = Sessao.t("lançou %s") % carta
			"reliquia": t = Sessao.t("equipou %s em %s") % [carta, alvo]
			"selo": t = Sessao.t("colocou um Selo") if int(ln[1]) == 1 else Sessao.t("colocou o Selo %s") % carta
			"selo_revelado": t = Sessao.t("Selo disparou: %s") % carta
			"ataque": t = Sessao.t("atacou %s com %s") % [alvo, carta]
			"golpe": t = Sessao.t("golpeou a Cornucópia com %s") % carta
			_: t = carta
		b.append(["txt", "T%d  %s %s" % [turno, quem, t]])
	if (p.get("log", []) as Array).is_empty():
		b.append(["centro", Sessao.t("Sem jogadas registradas.")])
	f.perg.abrir(b)
