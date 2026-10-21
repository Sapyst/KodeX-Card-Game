class_name ModosSolo
extends RefCounted
## Modos solo (docs/modos_solo.md): tela Solo com a lista de modos, Peregrinação (roguelike de 8 paradas), Desafio do
## dia, Desafios lendários, Modo livre e Choronzon (chefe secreto). Desenha no menu (fluxo.gd), px nativos 360×640.
## O estado de cada modo fica no perfil (auto-save): pere, lendarios, diario_dia, torneio_vencido, choronzon_vencido.

const MODOS := ["peregrinacao", "diario", "lendario", "livre", "choronzon", "enigma"]
const MOEDAS_ENIGMA := 10
const PARADAS := 8
const CORN_MAX := 20
const MOEDAS_VITORIA_PERE := 20
const MOEDAS_CHEFE_PERE := 100
const MOEDAS_DIARIO := 30
const MOEDAS_LENDARIO := [60, 15]           # já tinha a Lendária na 1ª vitória / vitórias seguintes
const BENCAOS := {
	"fe1": ["+1 Fé no 1º turno", "+1 Faith on turn 1"],
	"corn3": ["+3 de Cornucópia máxima (e cura 3)", "+3 max Cornucopia (and heal 3)"],
	"impeto1": ["A 1ª Entidade de cada batalha ataca na hora", "Your 1st Entity each battle attacks at once"],
	"compra1": ["Compra 1 carta extra no 1º turno", "Draw 1 extra card on turn 1"],
	"selo-1": ["Seus Selos custam 1 a menos", "Your Seals cost 1 less"],
	"vida1": ["Suas Entidades têm +1 de Vida", "Your Entities have +1 Life"],
}
const CAMINHOS := {
	"batalha": ["Batalha", "Battle", "Mestre · +20 moedas e 1 carta", "Master · +20 coins and 1 card"],
	"elite": ["Elite", "Elite", "Arquimago · Bênção e 1 carta", "Archmage · Blessing and 1 card"],
	"santuario": ["Santuário", "Sanctuary", "+5 de Cornucópia", "+5 Cornucopia"],
	"mercador": ["Mercador", "Merchant", "troque 1 carta", "swap 1 card"],
	"chefe": ["Chefe", "Boss", "Arquimago com Lendária, 20 de vida", "Archmage with a Legendary, 20 life"],
}

var f                                       # o menu (fluxo.gd)
var opcoes: Array = []                      # prêmio da Peregrinação: [{id, sai}] ou bênçãos ["fe1", ...]
var tipo_premio := ""                       # "carta" | "bencao"
var rol := 0.0


func _init(menu) -> void:
	f = menu


func en() -> bool:
	return Sessao.idioma == "en"


func _l(par: Array) -> String:
	return par[1] if en() else par[0]


# ================= lista =================
func itens() -> Array:
	var p: Dictionary = Sessao.perfil
	var pere: Dictionary = p.get("pere", {})
	var dia_ok := Relogio.sincronizado()
	var feito_hoje := dia_ok and int(p.get("diario_dia", -1)) == Relogio.dia()
	var vencidos := (p.get("lendarios", {}) as Dictionary).size()
	var aberto_ch := bool(p.get("torneio_vencido", false))
	return [
		{"id": "peregrinacao", "nome": ["Peregrinação", "Pilgrimage"],
			"sub": [("continuar: parada %d de 8" % (int(pere["parada"]) + 1)) if not pere.is_empty() else "8 paradas, cartas e Bênçãos",
				("continue: stop %d of 8" % (int(pere["parada"]) + 1)) if not pere.is_empty() else "8 stops, cards and Blessings"],
			"retrato": "bruxaria", "cor": Color("#5a2a6a")},
		{"id": "diario", "nome": ["Desafio do dia", "Daily challenge"],
			"sub": ["feito hoje (sem prêmio)" if feito_hoje else ("vitória vale %d moedas" % MOEDAS_DIARIO if dia_ok else "precisa de internet"),
				"done today (no reward)" if feito_hoje else ("a win is worth %d coins" % MOEDAS_DIARIO if dia_ok else "needs internet")],
			"retrato": "taoismo", "cor": Color("#1f5a6a")},
		{"id": "lendario", "nome": ["Desafios lendários", "Legendary challenges"],
			"sub": ["%d de 12 conquistadas" % vencidos, "%d of 12 conquered" % vencidos], "retrato": "hinduismo", "cor": Color("#7a4a10")},
		{"id": "enigmas", "nome": ["Enigmas", "Puzzles"],
			"sub": ["vença neste turno · %d de %d" % [(p.get("enigmas", {}) as Dictionary).size(), enigmas().size()],
				"win this turn · %d of %d" % [(p.get("enigmas", {}) as Dictionary).size(), enigmas().size()]],
			"retrato": "alta_magia", "cor": Color("#2a2a5a")},
		{"id": "livre", "nome": ["Modo livre", "Free mode"], "sub": ["qualquer carta, sem prêmio", "any card, no rewards"],
			"retrato": "cristianismo", "cor": Color("#3a4a2a")},
		{"id": "choronzon", "nome": ["Choronzon", "Choronzon"],
			"sub": (["vença o Torneio para abrir", "win the Tournament to unlock"] if not aberto_ch else
				(["vencido · desafie de novo", "defeated · challenge again"] if p.get("choronzon_vencido", false)
				else ["o Habitante do Abismo", "the Dweller in the Abyss"])),
			"retrato": "", "cor": Color("#2a0a2a"), "trancado": not aberto_ch},
	]


func botoes_lista() -> void:
	var lst := itens()
	for k in lst.size():
		var it: Dictionary = lst[k]
		f._botao(Rect2(20, 88 + k * 70, 320, 62), "", abrir.bind(it["id"]), {"solo": it, "desenho": botao_item})
	f._botao(Rect2(110, 88 + lst.size() * 70 + 6, 140, 26), "Voltar", func() -> void: f._ir("titulo"))


func botao_item(b: Dictionary, r: Rect2, pressao: float) -> void:
	var it: Dictionary = b["solo"]
	var tranc: bool = it.get("trancado", false)
	var dentro: Rect2 = f._painel(r, false, pressao, (it["cor"] as Color).darkened(0.45 if not tranc else 0.75))
	var mini := Rect2(dentro.position + Vector2(4, 4), Vector2(40, dentro.size.y - 8))
	f.draw_rect(mini.grow(1), f.ESCURO)
	var tex: Texture2D = Carta.textura("retrato", it["retrato"], "png") if it["retrato"] != "" else Carta.textura("arte", "aby_choronzon", "png")
	if tex:
		var tw := float(tex.get_width())
		var th := tw * mini.size.y / mini.size.x
		f.draw_texture_rect_region(tex, mini, Rect2(0, 0, tw, minf(th, tex.get_height())), Color(1, 1, 1, 0.35 if tranc else 1.0))
	if tranc:
		var cc := mini.get_center()
		f.draw_rect(Rect2(cc + Vector2(-6, -2), Vector2(12, 10)), Color(0.75, 0.68, 0.55))
		f.draw_arc(cc + Vector2(0, -3), 4.0, PI, TAU, 10, Color(0.75, 0.68, 0.55), 2.0)
	PixelFonte.desenhar(f, dentro.position + Vector2(52, 10), PixelFonte.normalizar(_l(it["nome"])), f.OURO[0] if not tranc else Color("#8a8090"), 2, f.ESCURO)
	Fonte57.desenhar(f, dentro.position + Vector2(52, 32), _l(it["sub"]), f.CREME if not tranc else Color("#8a8090"), f.ESCURO)
	Fonte57.desenhar(f, Vector2(dentro.end.x - 12, dentro.get_center().y - 3), ">", f.OURO[1])


func abrir(id: String) -> void:
	match id:
		"peregrinacao":
			f._ir("pere")
		"diario":
			if not Relogio.sincronizado():
				f.mp.avisar(Sessao.t("Sem conexão: o desafio do dia usa a hora da internet."))
				Relogio.sincronizar()
				return
			f._ir("diario")
		"lendario":
			f._ir("lendarios")
		"livre":
			f._ir("livre")
		"enigmas":
			f._ir("enigmas")
		"choronzon":
			if not Sessao.perfil.get("torneio_vencido", false):
				f.mp.avisar(Sessao.t("Vença o Torneio para abrir."))
				return
			_choronzon()


# ================= Peregrinação =================
func pere() -> Dictionary:
	return Sessao.perfil.get("pere", {})


func comecar_pere(trad: String) -> void:
	Sessao.perfil["pere"] = {"trad": trad, "parada": 0, "corn": 15, "corn_max": CORN_MAX, "deck": Sessao.deck_tematico(trad),
		"bencaos": [], "caminhos": _sortear_caminhos(0), "vitorias": 0}
	Sessao.salvar()
	f._ir("pere")


func _sortear_caminhos(parada: int) -> Array:
	if parada >= PARADAS - 1:
		return ["chefe"]
	if parada == 0:
		return ["batalha", "batalha"]
	var pool := ["batalha", "batalha", "batalha", "elite", "elite", "santuario", "mercador"]
	var a: String = pool[Sessao.rng.randi_range(0, pool.size() - 1)]
	var b: String = pool[Sessao.rng.randi_range(0, pool.size() - 1)]
	while b == a and a != "batalha":
		b = pool[Sessao.rng.randi_range(0, pool.size() - 1)]
	return [a, b]


func botoes_pere() -> void:
	var p := pere()
	if p.is_empty():
		for i in 6:
			var d: String = Sessao.DECKS[i]
			f._botao(Rect2(16 + (i % 2) * 168, 112 + (i / 2) * 150, 160, 140), Sessao.nome_deck(d), comecar_pere.bind(d), {"deck": d})
		f._botao(Rect2(110, 572, 140, 26), "Voltar", func() -> void: f._ir("solo"))
		return
	var cams: Array = p["caminhos"]
	for k in cams.size():
		var w := 150.0 if cams.size() == 2 else 220.0
		var x := 25.0 + k * 160.0 if cams.size() == 2 else 70.0
		f._botao(Rect2(x, 330, w, 92), "", seguir.bind(cams[k]), {"caminho": cams[k], "desenho": botao_caminho})
	f._botao(Rect2(60, 520, 110, 26), "Ver deck", ver_deck)
	f._botao(Rect2(190, 520, 110, 26), "Abandonar", func() -> void:
		f.confirmar(Sessao.t("Abandonar a Peregrinação?"), Sessao.t("o progresso atual se perde"), func() -> void:
			Sessao.perfil.erase("pere"); Sessao.salvar(); f._ir("solo")))
	f._botao(Rect2(110, 560, 140, 26), "Voltar", func() -> void: f._ir("solo"))


func botao_caminho(b: Dictionary, r: Rect2, pressao: float) -> void:
	var c: String = b["caminho"]
	var cor: Color = {"batalha": Color("#5a2a2a"), "elite": Color("#6a4a10"), "santuario": Color("#1f5a3a"), "mercador": Color("#2a3a6a"),
		"chefe": Color("#4a0a2a")}.get(c, Color("#241a20"))
	var dentro: Rect2 = f._painel(r, c in ["elite", "chefe"], pressao, cor)
	var info: Array = CAMINHOS[c]
	PixelFonte.centrado(f, Vector2(dentro.get_center().x, dentro.position.y + 22), PixelFonte.normalizar(info[1] if en() else info[0]), f.OURO[0], 2, f.ESCURO)
	var sub: String = info[3] if en() else info[2]
	var linhas := Fonte57.quebrar(sub, int(dentro.size.x) - 12)
	for k in linhas.size():
		var s: String = linhas[k]
		Fonte57.desenhar(f, Vector2(roundf(dentro.get_center().x - Fonte57.largura(s) / 2.0), dentro.position.y + 46 + k * 11), s, f.CREME, f.ESCURO)


func desenhar_pere() -> void:
	var p := pere()
	if p.is_empty():
		f._cabecalho(Sessao.t("Peregrinação"), Sessao.t("escolha a fé que vai carregar"))
		return
	f._cabecalho(Sessao.t("Peregrinação"), Sessao.nome_deck(p["trad"]))
	# trilha das 8 paradas
	for k in PARADAS:
		var x := 40.0 + k * 40.0
		var feito: bool = k < int(p["parada"])
		var atual: bool = k == int(p["parada"])
		if k > 0:
			f.draw_rect(Rect2(x - 32, 129, 24, 2), f.OURO[2] if feito or atual else Color(0.3, 0.26, 0.3))
		var raio := 9.0 if k == PARADAS - 1 else 7.0
		f.draw_circle(Vector2(x, 130), raio + 1, f.ESCURO)
		f.draw_circle(Vector2(x, 130), raio, f.OURO[1] if feito else (Color("#e04040") if k == PARADAS - 1 else Color(0.25, 0.2, 0.26)))
		if atual:
			f.draw_arc(Vector2(x, 130), raio + 4 + sin(f.tempo * 4.0), 0, TAU, 20, f.OURO[0], 1.5)
	var corn := "%d / %d" % [int(p["corn"]), int(p["corn_max"])]
	f._texto_central(Vector2(180, 158), (Sessao.t("Cornucópia") + "  " + corn), Color("#ff9a8a"))
	var bs: Array = p["bencaos"]
	var y := 182.0
	f._texto_central(Vector2(180, y), Sessao.t("Bênçãos") + (": " + str(bs.size()) if not bs.is_empty() else ": -"), f.OURO[1])
	for k in bs.size():
		f._texto_central(Vector2(180, y + 14 + k * 12), _l(BENCAOS[bs[k]]), f.CREME)
	f._texto_central(Vector2(180, 316), Sessao.t("Escolha o caminho"), Color(0.85, 0.78, 0.66))


func ver_deck() -> void:
	var p := pere()
	var conta := {}
	for cid in p["deck"]:
		conta[cid] = int(conta.get(cid, 0)) + 1
	var blocos: Array = [["titulo", "Deck"]]
	for tipo in ["entidade", "selo", "rito", "reliquia"]:
		blocos.append(["sub", Sessao.t({"entidade": "Entidades", "selo": "Selos", "rito": "Ritos", "reliquia": "Relíquias"}[tipo])])
		for cid in conta:
			if Sessao.db["cartas"][cid]["tipo"] == tipo:
				blocos.append(["item", "%s x%d" % [Sessao.db["cartas"][cid]["nome"], conta[cid]]])
	f.perg.abrir(blocos)


func seguir(caminho: String) -> void:
	var p := pere()
	match caminho:
		"santuario":
			p["corn"] = mini(int(p["corn_max"]), int(p["corn"]) + 5)
			_avancar()
			f.perg.abrir([["titulo", _l(["Santuário", "Sanctuary"])], ["destaque", "+5", ""],
				["centro", _l(["Cornucópia: %d de %d" % [int(p["corn"]), int(p["corn_max"])], "Cornucopia: %d of %d" % [int(p["corn"]), int(p["corn_max"])]])]],
				func() -> void: f._ir("pere"))
		"mercador":
			_preparar_premio_cartas(false)
			f._ir("pere_premio")
		_:
			var opon: String = Sessao.DECKS[Sessao.rng.randi_range(0, 5)]
			var nivel := 1 if caminho == "batalha" else 2
			var corn_op: int = {"batalha": 15, "elite": 18, "chefe": 20}[caminho]
			var deck_op := Sessao.deck_tematico(opon)
			var ext := {"cornucopia": [int(p["corn"]), corn_op], "bencaos": (p["bencaos"] as Array).duplicate(), "caminho": caminho}
			if caminho == "chefe":
				for cid in deck_op:
					if Sessao.db["cartas"][cid]["lendaria"]:
						ext["mao_garantida"] = [cid]
						break
			Sessao.preparar_modo("peregrinacao", p["deck"], opon, deck_op, nivel, ext)
			f._jogar()


func _avancar() -> void:
	var p := pere()
	p["parada"] = int(p["parada"]) + 1
	p["caminhos"] = _sortear_caminhos(int(p["parada"]))
	Sessao.salvar()


## Prêmio de carta: 3 opções de todas as tradições (sem Abismo); cada uma substitui a carta mais barata do mesmo tipo
## no deck (Lendária nunca sai). Elite/Chefe: 1 das 3 é Lendária, se houver alguma que o deck ainda não tem.
func _preparar_premio_cartas(com_lendaria: bool) -> void:
	tipo_premio = "carta"
	opcoes.clear()
	var p := pere()
	var deck: Array = p["deck"]
	var comuns: Array = []
	var lend: Array = []
	for cid in Sessao.db["cartas"]:
		var c: Dictionary = Sessao.db["cartas"][cid]
		if c["cultura"] == "abismo":
			continue
		if c["lendaria"]:
			if not cid in deck:
				lend.append(cid)
		else:
			comuns.append(cid)
	var escolhidas: Array = []
	if com_lendaria and not lend.is_empty():
		escolhidas.append(lend[Sessao.rng.randi_range(0, lend.size() - 1)])
	while escolhidas.size() < 3:
		var cid: String = comuns[Sessao.rng.randi_range(0, comuns.size() - 1)]
		if not cid in escolhidas and deck.count(cid) < 2:
			escolhidas.append(cid)
	for cid in escolhidas:
		opcoes.append({"id": cid, "sai": _quem_sai(cid)})


func _quem_sai(novo: String) -> String:
	var deck: Array = pere()["deck"]
	var tipo: String = Sessao.db["cartas"][novo]["tipo"]
	var pior := ""
	for cid in deck:
		var c: Dictionary = Sessao.db["cartas"][cid]
		if c["tipo"] != tipo or c["lendaria"]:
			continue
		if pior == "" or int(c["custo"]) < int(Sessao.db["cartas"][pior]["custo"]):
			pior = cid
	return pior


func botoes_premio() -> void:
	if tipo_premio == "bencao":
		for k in opcoes.size():
			f._botao(Rect2(30, 150 + k * 80, 300, 66), "", escolher_bencao.bind(opcoes[k]), {"bencao": opcoes[k], "desenho": botao_bencao})
		return
	for k in opcoes.size():
		f._botao(Rect2(14 + k * 112, 140, 108, 236), "", escolher_carta.bind(k), {"premio": k, "carta_id": opcoes[k]["id"], "desenho": botao_premio})
	f._botao(Rect2(110, 420, 140, 26), "Pular", escolher_carta.bind(-1))


func botao_premio(b: Dictionary, r: Rect2, pressao: float) -> void:
	var o: Dictionary = opcoes[b["premio"]]
	var cr := Rect2(r.position + Vector2(4, 4 + pressao), Vector2(100, 140))
	var tex := Carta.textura("carta_en" if en() else "carta", o["id"], "webp")
	f.draw_rect(cr.grow(2), f.OURO[1] if Sessao.db["cartas"][o["id"]]["lendaria"] else f.ESCURO)
	if tex:
		f.draw_texture_rect(tex, cr, false)
	var y := cr.end.y + 10
	Fonte57.desenhar(f, Vector2(r.position.x + 4, y), _l(["sai:", "out:"]), Color("#ff9a8a"))
	var nome := str(Sessao.db["cartas"][o["sai"]]["nome"]) if o["sai"] != "" else "-"
	var linhas := Fonte57.quebrar(nome, 100)
	for k in mini(linhas.size(), 3):
		Fonte57.desenhar(f, Vector2(r.position.x + 4, y + 12 + k * 10), linhas[k], f.CREME)
	var toque := _l(["toque para levar", "tap to take"])
	Fonte57.desenhar(f, Vector2(roundf(r.get_center().x - Fonte57.largura(toque) / 2.0), r.end.y - 14), toque, Color(f.OURO[0], 0.6 + 0.4 * sin(f.tempo * 4.0)))


func botao_bencao(b: Dictionary, r: Rect2, pressao: float) -> void:
	var dentro: Rect2 = f._painel(r, true, pressao, Color("#3a2a10"))
	var s := _l(BENCAOS[b["bencao"]])
	var linhas := Fonte57.quebrar(s, int(dentro.size.x) - 20)
	for k in linhas.size():
		Fonte57.desenhar(f, Vector2(roundf(dentro.get_center().x - Fonte57.largura(linhas[k]) / 2.0), dentro.get_center().y - linhas.size() * 5 + k * 11), linhas[k], f.OURO[0], f.ESCURO)


func desenhar_premio() -> void:
	if tipo_premio == "bencao":
		f._cabecalho(Sessao.t("Bênção"), Sessao.t("escolha uma"))
	else:
		f._cabecalho(Sessao.t("Nova carta"), Sessao.t("leve uma para o deck"))


func escolher_carta(k: int) -> void:
	var p := pere()
	if k >= 0:
		var o: Dictionary = opcoes[k]
		var deck: Array = p["deck"]
		if o["sai"] != "":
			deck.erase(o["sai"])
		deck.append(o["id"])
	opcoes.clear()
	Sessao.salvar()
	f._ir("pere")


func escolher_bencao(bid: String) -> void:
	var p := pere()
	(p["bencaos"] as Array).append(bid)
	if bid == "corn3":
		p["corn_max"] = int(p["corn_max"]) + 3
		p["corn"] = int(p["corn"]) + 3
	_preparar_premio_cartas(true)
	Sessao.salvar()
	f._ir("pere_premio")


## Volta da mesa: vitória paga e avança (Elite: Bênção antes da carta; Chefe: fim com prêmio); derrota encerra.
func pos_pere() -> void:
	var p := pere()
	var ex: Dictionary = Sessao.extras
	var caminho: String = ex.get("caminho", "batalha")
	var venceu := Sessao.resultado == "vitoria"
	Sessao.resultado = ""
	if p.is_empty():
		f._ir("solo")
		return
	if not venceu:
		var parada := int(p["parada"]) + 1
		Sessao.perfil.erase("pere")
		Sessao.salvar()
		f._ir("solo")
		f.perg.abrir([["titulo", _l(["Fim da jornada", "Journey over"])],
			["centro", _l(["Você caiu na parada %d de 8." % parada, "You fell at stop %d of 8." % parada])],
			["centro", _l(["Vitórias: %d" % int(p["vitorias"]), "Wins: %d" % int(p["vitorias"])])]])
		return
	p["corn"] = clampi(int(ex.get("fim_cornucopia", p["corn"])), 1, int(p["corn_max"]))
	p["vitorias"] = int(p["vitorias"]) + 1
	if caminho == "chefe":
		Sessao.premio("pere_chefe", {}, MOEDAS_CHEFE_PERE + MOEDAS_VITORIA_PERE, 1)
		Sessao.perfil.erase("pere")
		Sessao.salvar()
		f._ir("solo")
		f.perg.abrir([["titulo", _l(["Peregrinação completa", "Pilgrimage complete"])],
			["destaque", "+%d" % (MOEDAS_CHEFE_PERE + MOEDAS_VITORIA_PERE), "moeda"], ["espaco"], ["destaque", "+1", "booster"],
			["centro", _l(["booster grátis - abra na Loja", "free booster - open it in the Shop"])]])
		return
	Sessao.premio("pere_vitoria", {}, MOEDAS_VITORIA_PERE)
	_avancar()
	if caminho == "elite":
		tipo_premio = "bencao"
		opcoes.clear()
		var livres: Array = BENCAOS.keys().filter(func(b: String) -> bool: return not b in (p["bencaos"] as Array))
		livres.shuffle()
		opcoes = livres.slice(0, 3)
	else:
		_preparar_premio_cartas(false)
	f._ir("pere_premio")


# ================= Desafio do dia =================
## Mesma partida para todo mundo no dia (número do dia de Brasília): tradições, Mestre e embaralhamento pela semente.
func diario() -> Dictionary:
	var dia := Relogio.dia()
	var r := RandomNumberGenerator.new()
	r.seed = dia * 7919 + 17
	var a: String = Sessao.DECKS[r.randi_range(0, 5)]
	var b: String = Sessao.DECKS[r.randi_range(0, 5)]
	while b == a:
		b = Sessao.DECKS[r.randi_range(0, 5)]
	return {"dia": dia, "meu": a, "opon": b}


func botoes_diario() -> void:
	f._botao(Rect2(90, 420, 180, 30), "Jogar", jogar_diario)
	f._botao(Rect2(110, 462, 140, 26), "Voltar", func() -> void: f._ir("solo"))


func desenhar_diario() -> void:
	var d := diario()
	f._cabecalho(Sessao.t("Desafio do dia"), Sessao.t("a mesma partida para todo mundo"))
	var p := Sessao.personagem(d["opon"])
	var linhas := [
		_l(["Você joga com %s" % Sessao.nome_deck(d["meu"]), "You play %s" % Sessao.nome_deck(d["meu"])]),
		_l(["contra %s (%s)" % [p.get("nome", ""), Sessao.nome_deck(d["opon"])], "against %s (%s)" % [p.get("nome", ""), Sessao.nome_deck(d["opon"])]]),
		_l(["Nível: Mestre", "Level: Master"]),
	]
	for k in linhas.size():
		f._texto_central(Vector2(180, 150 + k * 18), linhas[k], f.CREME)
	var tex := Carta.textura("retrato", d["opon"], "png")
	if tex:
		var r := Rect2(130, 220, 100, 133)
		f.draw_rect(r.grow(2), f.OURO[2])
		f.draw_texture_rect(tex, r, false)
	var feito := int(Sessao.perfil.get("diario_dia", -1)) == int(d["dia"])
	var s := _l(["Prêmio de hoje já recebido. Jogue pelo prazer.", "Today's reward already taken. Play for fun."]) if feito \
		else _l(["Vitória: +%d moedas (uma vez por dia)" % MOEDAS_DIARIO, "Win: +%d coins (once a day)" % MOEDAS_DIARIO])
	f._texto_central(Vector2(180, 380), s, f.OURO[1])


func jogar_diario() -> void:
	var d := diario()
	Sessao.preparar_modo("diario", Sessao.deck_tematico(d["meu"]), d["opon"], Sessao.deck_tematico(d["opon"]), 1,
		{"semente": int(d["dia"]) * 104729, "dia": d["dia"]})
	f._jogar()


func pos_diario() -> void:
	var venceu := Sessao.resultado == "vitoria"
	Sessao.resultado = ""
	var dia := int(Sessao.extras.get("dia", -1))
	f._ir("diario")
	if venceu and int(Sessao.perfil.get("diario_dia", -1)) != dia:
		Sessao.perfil["diario_dia"] = dia
		Sessao.premio("diario", {}, MOEDAS_DIARIO)
		f.perg.abrir([["titulo", _l(["Desafio do dia", "Daily challenge"])], ["destaque", "+%d" % MOEDAS_DIARIO, "moeda"],
			["centro", _l(["Volte amanhã para um novo desafio.", "Come back tomorrow for a new challenge."])]])


# ================= Desafios lendários =================
func lendarias() -> Array:
	var out: Array = []
	for cid in Sessao.db["cartas"]:
		if Sessao.db["cartas"][cid]["lendaria"] and Sessao.db["cartas"][cid]["cultura"] != "abismo":
			out.append(cid)
	return out


func botoes_lendarios() -> void:
	var l := lendarias()
	for k in l.size():
		f._botao(Rect2(16 + (k % 4) * 84, 92 + (k / 4) * 132, 76, 124), "", jogar_lendario.bind(l[k]), {"lend": l[k], "carta_id": l[k], "desenho": botao_lendario})
	f._botao(Rect2(110, 92 + 3 * 132 + 8, 140, 26), "Voltar", func() -> void: f._ir("solo"))


func botao_lendario(b: Dictionary, r: Rect2, pressao: float) -> void:
	var cid: String = b["lend"]
	var venc := int((Sessao.perfil.get("lendarios", {}) as Dictionary).get(cid, 0))
	var cr := Rect2(r.position + Vector2(2, 2 + pressao), Vector2(72, 101))
	var tex := Carta.textura("carta_en" if en() else "carta", cid, "webp")
	f.draw_rect(cr.grow(2), f.OURO[1] if venc > 0 else f.ESCURO)
	if tex:
		f.draw_texture_rect(tex, cr, false, Color(1, 1, 1, 1.0) if venc > 0 else Color(0.55, 0.5, 0.55))
	var s := _l(["CONQUISTADA", "CONQUERED"]) if venc > 0 else _l(["DESAFIAR", "CHALLENGE"])
	PixelFonte.centrado(f, Vector2(r.get_center().x, r.end.y - 8), s, f.OURO[0] if venc > 0 else f.CREME, 1, f.ESCURO)


func desenhar_lendarios() -> void:
	f._cabecalho(Sessao.t("Desafios lendários"), Sessao.t("vença o nível mais difícil e leve a Lendária"))


func jogar_lendario(cid: String) -> void:
	var trad: String = Sessao.db["cartas"][cid]["cultura"]
	var deck_op := Sessao.deck_tematico(trad)
	if not cid in deck_op:
		deck_op[deck_op.size() - 1] = cid
	Sessao.preparar_modo("lendario", Sessao.deck_ativo_ids(), trad, deck_op, 2, {"mao_garantida": [cid], "lendaria": cid})
	f._jogar()


func pos_lendario() -> void:
	var venceu := Sessao.resultado == "vitoria"
	Sessao.resultado = ""
	var cid: String = Sessao.extras.get("lendaria", "")
	f._ir("lendarios")
	if not venceu or cid == "":
		return
	var reg: Dictionary = Sessao.perfil.get("lendarios", {})
	var primeira := int(reg.get(cid, 0)) == 0
	reg[cid] = int(reg.get(cid, 0)) + 1
	Sessao.perfil["lendarios"] = reg
	var nome := str(Sessao.db["cartas"][cid]["nome"])
	if Nuvem.ativo():
		Nuvem.op("premio", {"motivo": "lendario", "carta": cid}, true)
	if primeira and Sessao.copias(cid) == 0:
		Sessao.adicionar_carta(cid)
		f.perg.abrir([["titulo", _l(["Lendária conquistada", "Legendary conquered"])], ["centro", nome],
			["centro", _l(["A carta entrou na sua coleção.", "The card joined your collection."])]])
	else:
		var m: int = MOEDAS_LENDARIO[0] if primeira else MOEDAS_LENDARIO[1]
		Sessao.ganhar_moedas(m)                   # o servidor confere e devolve o valor certo (op "lendario" acima)
		f.perg.abrir([["titulo", _l(["Desafio vencido", "Challenge won"])], ["centro", nome], ["destaque", "+%d" % m, "moeda"]])


# ================= Modo livre =================
var livre := {"meu": "0", "oponente": "aleatorio", "deck_dele": "do_personagem", "dificuldade": "1"}


func botoes_livre() -> void:
	f._botao(Rect2(20, 110, 320, 40), "", ciclar_livre.bind("meu"), {"campo_livre": "meu", "desenho": botao_campo})
	f._botao(Rect2(20, 166, 320, 40), "", ciclar_livre.bind("oponente"), {"campo_livre": "oponente", "desenho": botao_campo})
	f._botao(Rect2(20, 222, 320, 40), "", ciclar_livre.bind("deck_dele"), {"campo_livre": "deck_dele", "desenho": botao_campo})
	f._botao(Rect2(20, 278, 320, 40), "", ciclar_livre.bind("dificuldade"), {"campo_livre": "dificuldade", "desenho": botao_campo})
	f._botao(Rect2(90, 350, 180, 30), "Jogar", jogar_livre)
	f._botao(Rect2(90, 392, 180, 26), "Novo deck livre", novo_deck_livre)
	f._botao(Rect2(110, 430, 140, 26), "Voltar", func() -> void: f._ir("solo"))


func botao_campo(b: Dictionary, r: Rect2, pressao: float) -> void:
	var campo: String = b["campo_livre"]
	var dentro: Rect2 = f._painel(r, false, pressao)
	var rotulo := Sessao.t({"meu": "Seu deck", "oponente": "Oponente", "deck_dele": "Deck do oponente", "dificuldade": "Dificuldade"}[campo])
	Fonte57.desenhar(f, dentro.position + Vector2(8, 4), rotulo, Color("#b8a888"))
	var v: String = livre[campo]
	var txt := ""
	if campo == "meu":
		var i := int(v)
		txt = str(Sessao.perfil["decks"][i]["nome"]) + ("  (" + Sessao.t("livre") + ")" if Sessao.deck_livre(i) else "") if i < Sessao.perfil["decks"].size() else "-"
	elif campo == "dificuldade":
		txt = Sessao.t(["Aprendiz", "Mestre", "Arquimago"][int(v)])
	else:
		txt = f._nome_opcao(campo, v)
	Fonte57.desenhar(f, dentro.position + Vector2(8, 19), txt, f.OURO[0], f.ESCURO)
	Fonte57.desenhar(f, Vector2(dentro.end.x - 12, dentro.position.y + 19), ">", f.OURO[1])


func ciclar_livre(campo: String) -> void:
	if campo == "meu":
		var validos: Array = []
		for i in Sessao.perfil["decks"].size():
			if Sessao.deck_valido(i, true):
				validos.append(str(i))
		if not validos.is_empty():
			livre["meu"] = validos[(validos.find(livre["meu"]) + 1) % validos.size()]
	elif campo == "dificuldade":
		livre["dificuldade"] = str((int(livre["dificuldade"]) + 1) % 3)
	else:
		var lista: Array = f.OPC[campo]
		livre[campo] = lista[(lista.find(livre[campo]) + 1) % lista.size()]
	f._ir("livre")
	f.transicao = 0.0


func desenhar_livre() -> void:
	f._cabecalho(Sessao.t("Modo livre"), Sessao.t("teste decks com qualquer carta"))
	f._texto_central(Vector2(180, 474), Sessao.t("Sem prêmios. Decks livres só valem aqui."), Color(0.72, 0.66, 0.53))


func novo_deck_livre() -> void:
	f.mp.gaveta = "livre"
	f.mp.novo_deck()


func jogar_livre() -> void:
	var i := int(livre["meu"])
	if not Sessao.deck_valido(i, true):
		f.mp.avisar(Sessao.t("O deck precisa de exatamente 32 cartas."))
		return
	var opon: String = livre["oponente"]
	if opon == "aleatorio":
		opon = Sessao.DECKS[Sessao.rng.randi_range(0, 5)]
	var dd: String = livre["deck_dele"]
	var deck_op: Array = Sessao.montar_deck(opon if dd == "do_personagem" else ("misto" if dd == "misto" else Sessao.DECKS[Sessao.rng.randi_range(0, 5)]))
	Sessao.preparar_modo("livre", (Sessao.perfil["decks"][i]["cartas"] as Array), opon, deck_op, int(livre["dificuldade"]))
	f._jogar()


func pos_livre() -> void:
	Sessao.resultado = ""
	f._ir("livre")


# ================= Choronzon =================
## O Habitante do Abismo: Conjunto do Abismo (pode invocar Choronzon e vencer na hora) + 28 cartas de todas as tradições,
## 30 de Cornucópia, nível Arquimago.
func _choronzon() -> void:
	var deck: Array = Sessao.montar_deck("misto")
	var abismo: Array = Sessao.db["decks"].get("abismo", [])
	for k in mini(abismo.size(), 4):
		deck[deck.size() - 1 - k] = abismo[k]
	Sessao.preparar_modo("choronzon", Sessao.deck_ativo_ids(), "choronzon", deck, 2, {"cornucopia": [15, 30]})
	var falas: Array = [
		{"quem": "Choronzon", "texto": _l(["Você fechou o livro. Eu sou o que estava escrito na última página.",
			"You closed the book. I am what was written on the last page."]), "cor": Color("#c070ff"), "retrato": ""},
		{"quem": "Choronzon", "texto": _l(["Três, três, três. Conte comigo.", "Three, three, three. Count with me."]), "cor": Color("#c070ff"), "retrato": ""}]
	f._falar(falas, func() -> void: f._jogar())


func pos_choronzon() -> void:
	var venceu := Sessao.resultado == "vitoria"
	Sessao.resultado = ""
	f._ir("solo")
	if not venceu:
		return
	if not Sessao.perfil.get("choronzon_vencido", false):
		Sessao.perfil["choronzon_vencido"] = true
		var t: Array = Sessao.perfil.get("titulos", [])
		t.append("selador_do_abismo")
		Sessao.perfil["titulos"] = t
		Sessao.premio("choronzon", {}, 200, 2)
		f.perg.abrir([["titulo", _l(["Abismo selado", "Abyss sealed"])],
			["centro", _l(["Título: Selador do Abismo", "Title: Sealer of the Abyss"])],
			["destaque", "+200", "moeda"], ["espaco"], ["destaque", "+2", "booster"]])
	else:
		Sessao.premio("choronzon", {}, 25)
		f.perg.abrir([["titulo", "Choronzon"], ["destaque", "+25", "moeda"]])


# ================= Enigmas =================
static var _enigmas: Array = []


func enigmas() -> Array:
	if _enigmas.is_empty():
		_enigmas = JSON.parse_string(FileAccess.get_file_as_string("res://dados/enigmas.json"))
	return _enigmas


func botoes_enigmas() -> void:
	var l := enigmas()
	for k in l.size():
		f._botao(Rect2(20, 88 + k * 50, 320, 44), "", jogar_enigma.bind(k), {"enigma": l[k], "desenho": botao_enigma})
	f._botao(Rect2(110, 88 + l.size() * 50 + 6, 140, 26), "Voltar", func() -> void: f._ir("solo"))


func botao_enigma(b: Dictionary, r: Rect2, pressao: float) -> void:
	var e: Dictionary = b["enigma"]
	var feito := (Sessao.perfil.get("enigmas", {}) as Dictionary).has(e["id"])
	var dentro: Rect2 = f._painel(r, feito, pressao, Color("#2a2a4a") if not feito else Color("#3a3010"))
	Fonte57.desenhar(f, dentro.position + Vector2(10, 6), _l(e["titulo"]), f.OURO[0] if feito else f.CREME, f.ESCURO)
	var info := _l(["Fé %d · Cornucópia dele %d" % [int(e["fe"]), int(e["corn"])], "Faith %d · their Cornucopia %d" % [int(e["fe"]), int(e["corn"])]])
	Fonte57.desenhar(f, dentro.position + Vector2(10, 19), info, Color(0.72, 0.66, 0.6), f.ESCURO)
	for k in 4:
		var c := Vector2(dentro.end.x - 60 + k * 12, dentro.get_center().y)
		var on := k < int(e["estrelas"])
		f.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -5), c + Vector2(2, -1), c + Vector2(5, -1), c + Vector2(2.5, 1.5),
			c + Vector2(3.5, 5), c + Vector2(0, 3), c + Vector2(-3.5, 5), c + Vector2(-2.5, 1.5), c + Vector2(-5, -1), c + Vector2(-2, -1)]),
			f.OURO[0] if on else Color(0.3, 0.27, 0.3))
	if feito:
		PixelFonte.desenhar(f, Vector2(dentro.end.x - 12, dentro.position.y + 4), "V", f.OURO[0])


func desenhar_enigmas() -> void:
	f._cabecalho(Sessao.t("Enigmas"), Sessao.t("zere a Cornucópia dele neste turno"))


func jogar_enigma(k: int) -> void:
	var e: Dictionary = enigmas()[k]
	Sessao.preparar_modo("enigma", [], "alta_magia", [], 1, {"enigma": e, "enigma_id": e["id"]})
	f._jogar()


func pos_enigma() -> void:
	var venceu := Sessao.resultado == "vitoria"
	Sessao.resultado = ""
	f._ir("enigmas")
	if not venceu:
		return
	var reg: Dictionary = Sessao.perfil.get("enigmas", {})
	var id: String = Sessao.extras.get("enigma_id", "")
	if reg.has(id):
		f.perg.abrir([["titulo", _l(["Resolvido", "Solved"])], ["centro", _l(["De novo! Prêmio só na 1ª vez.", "Again! Reward only the 1st time."])]])
		return
	reg[id] = true
	Sessao.perfil["enigmas"] = reg
	Sessao.premio("enigma", {"enigma": id}, MOEDAS_ENIGMA)
	f.perg.abrir([["titulo", _l(["Resolvido", "Solved"])], ["destaque", "+%d" % MOEDAS_ENIGMA, "moeda"]])


func pos_partida() -> void:
	match Sessao.modo:
		"enigma": pos_enigma()
		"peregrinacao": pos_pere()
		"diario": pos_diario()
		"lendario": pos_lendario()
		"livre": pos_livre()
		"choronzon": pos_choronzon()
	Sessao.modo = ""
