class_name Historico
extends RefCounted
## Histórico do perfil (fluxo.gd, estado "historico"): contadores (contra a IA / contra jogadores, por modo, por
## adversário), as últimas partidas (adversário, IA ou jogador, data e hora, modo, resultado, turnos) e, ao tocar numa
## delas, o log jogada a jogada num pergaminho. Dados em Sessao.perfil["historico"] e ["estat"] (sincronizados).

const MODOS := {"arcade": ["Arcade", "Arcade"], "arcade_t": ["Torneio de 8", "8-player Tournament"], "torneio": ["Torneio", "Tournament"],
	"peregrinacao": ["Peregrinação", "Pilgrimage"], "diario": ["Desafio do dia", "Daily challenge"], "lendario": ["Lendário", "Legendary"],
	"livre": ["Modo livre", "Free mode"], "choronzon": ["Choronzon", "Choronzon"], "online": ["Online", "Online"], "bot": ["Online (bot)", "Online (bot)"]}
const NIVEIS := [["Aprendiz", "Apprentice"], ["Mestre", "Master"], ["Arquimago", "Archmage"]]
const POR_TELA := 9

var f


func _init(menu) -> void:
	f = menu


func _l(par: Array) -> String:
	return par[1] if Sessao.idioma == "en" else par[0]


static func nome_modo(m: String) -> String:
	return MODOS.get(m, [m, m])[1 if Sessao.idioma == "en" else 0]


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
	f._texto_central(Vector2(180, y), _l(["Contra a IA: %d  ·  %s", "Against the AI: %d  ·  %s"]) % [_total(ia), _placar(ia)], f.CREME)
	f._texto_central(Vector2(180, y + 13), _l(["Contra jogadores: %d  ·  %s", "Against players: %d  ·  %s"]) % [_total(jg), _placar(jg)], Color("#9ad0ff"))
	var modos: Dictionary = e.get("modos", {})
	var partes := PackedStringArray()
	for m in modos:
		partes.append("%s %d" % [nome_modo(m), _total(modos[m])])
	var linhas := Fonte57.quebrar("  ·  ".join(partes) if not partes.is_empty() else _l(["Nenhuma partida ainda.", "No matches yet."]), 330)
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
		f._texto_central(Vector2(180, y + 66), _l(["Mais enfrentado: %s (%d, %s)", "Most faced: %s (%d, %s)"]) % [top, topn, _placar(adv[top])], f.OURO[1])
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
	var rt: String = _l({"vitoria": ["VITÓRIA", "WIN"], "derrota": ["DERROTA", "LOSS"]}.get(res, ["EMPATE", "DRAW"]))
	PixelFonte.desenhar(f, Vector2(dentro.end.x - PixelFonte.largura(rt) - 6, dentro.position.y + 4), rt,
		Color("#7fcf8a") if res == "vitoria" else (Color("#ff8a7a") if res == "derrota" else Color("#a89a8e")))


func _nome_carta(cid: String) -> String:
	if cid == "":
		return "?"
	if Sessao.db["cartas"].has(cid):
		return str(Sessao.db["cartas"][cid]["nome"])
	for nome in Sessao.tokens:
		if Sessao.tokens[nome]["id"] == cid:
			return str(Sessao.tokens[nome]["en"]) if Sessao.idioma == "en" else str(nome)
	return cid


func abrir_log(k: int) -> void:
	var p: Dictionary = Sessao.perfil["historico"][k]
	var en := Sessao.idioma == "en"
	var st: Dictionary = p.get("stats", {})
	var res := _l({"vitoria": ["Vitória", "Victory"], "derrota": ["Derrota", "Defeat"]}.get(p.get("resultado", ""), ["Empate", "Draw"]))
	var b: Array = [["titulo", res], ["centro", "%s  ·  %s" % [str(p.get("adversario", "")), _data(int(p.get("t", 0)))]],
		["centro", "%s  ·  %d %s  ·  %d min" % [nome_modo(str(p.get("modo", ""))), int(p.get("turnos", 0)), Sessao.t("turnos"), int(p.get("duracao", 0)) / 60]],
		["divisor"],
		["item", _l(["Cartas jogadas: %d (oponente %d)", "Cards played: %d (opponent %d)"]) % [int(st.get("cartas", 0)), int(st.get("cartas_op", 0))]],
		["item", _l(["Dano causado: %d  ·  recebido: %d", "Damage dealt: %d  ·  taken: %d"]) % [int(st.get("dano", 0)), int(st.get("recebido", 0))]],
		["item", _l(["Entidades destruídas: %d  ·  perdidas: %d", "Entities destroyed: %d  ·  lost: %d"]) % [int(st.get("mortes", 0)), int(st.get("perdas", 0))]],
		["sub", _l(["Jogada a jogada", "Play by play"])]]
	for ln in p.get("log", []):
		var turno := int(ln[0])
		var quem := _l(["Você", "You"]) if int(ln[1]) == 0 else str(p.get("adversario", _l(["Oponente", "Opponent"])))
		var carta := _nome_carta(str(ln[3]))
		var alvo := _nome_carta(str(ln[4])) if str(ln[4]) != "" else ""
		var t := ""
		match str(ln[2]):
			"entidade": t = _l(["invocou %s", "summoned %s"]) % carta
			"rito": t = _l(["lançou %s", "cast %s"]) % carta
			"reliquia": t = _l(["equipou %s em %s", "equipped %s on %s"]) % [carta, alvo]
			"selo": t = _l(["colocou um Selo", "set a Seal"]) if int(ln[1]) == 1 else _l(["colocou o Selo %s", "set the Seal %s"]) % carta
			"selo_revelado": t = _l(["Selo disparou: %s", "Seal triggered: %s"]) % carta
			"ataque": t = _l(["atacou %s com %s", "attacked %s with %s"]) % [alvo, carta]
			"golpe": t = _l(["golpeou a Cornucópia com %s", "hit the Cornucopia with %s"]) % carta
			_: t = carta
		b.append(["txt", "T%d  %s %s" % [turno, quem, t]])
	if (p.get("log", []) as Array).is_empty():
		b.append(["centro", _l(["Sem jogadas registradas.", "No plays recorded."])])
	f.perg.abrir(b)
