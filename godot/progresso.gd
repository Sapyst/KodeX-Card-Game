class_name Progresso
extends RefCounted
## Progressão (dados/progressao.json, gerado por servidor/gerar_progressao.py): missões diárias (3 por dia, 1 troca),
## semanais (3), nível com XP e prêmio a cada nível, maestria por tradição (5 níveis), 50 conquistas e títulos.
## Os contadores ficam em Sessao.perfil["prog"] (sincronizado); cada prêmio vai ao servidor, que confere a missão do
## dia/semana pela mesma sorteio, paga uma vez só (perfil "prog_pagos") e respeita tetos diários.
## As missões do dia saem de uma sorteio pela data de Nova York: todo mundo tem as mesmas 3 no mesmo dia.

static var _dados: Dictionary = {}


static func dados() -> Dictionary:
	if _dados.is_empty():
		_dados = JSON.parse_string(FileAccess.get_file_as_string("res://dados/progressao.json"))
	return _dados


static func _l(par) -> String:
	return str(par[1] if Sessao.idioma == "en" else par[0])


static func texto(defn: Dictionary) -> String:
	return str(defn["en"] if Sessao.idioma == "en" else defn["pt"])


static func nome_titulo(id: String) -> String:
	return _l(dados()["titulos"].get(id, [id, id]))


## Sorteio igual ao do servidor (MINSTD): `n` índices distintos de 0..tam-1 a partir da semente.
static func sorteio(semente: int, n: int, tam: int) -> Array:
	var s := (semente * 7919 + 17) % 2147483647
	if s <= 0:
		s += 2147483646
	var out: Array = []
	while out.size() < mini(n, tam):
		s = (s * 48271) % 2147483647
		var i := s % tam
		if not (i in out):
			out.append(i)
	return out


# ---------------- estado ----------------
## O bloco "prog" do perfil, com o dia e a semana já virados (contadores do dia/semana zeram na virada).
static func p() -> Dictionary:
	var pr: Dictionary = Sessao.perfil.get("prog", {})
	for k in ["cont", "maestria"]:
		if not pr.has(k):
			pr[k] = {}
	for k in ["conquistas"]:
		if not pr.has(k):
			pr[k] = []
	var d := hoje()
	if int(pr.get("dia", {}).get("k", -999)) != d:
		pr["dia"] = {"k": d, "cont": {}, "feitas": [], "troca": -1}
	var s := int(floor((d + 3) / 7.0))                  # semana começa na segunda (igual ao Relogio)
	if int(pr.get("semana", {}).get("k", -999)) != s:
		pr["semana"] = {"k": s, "cont": {}, "feitas": []}
	Sessao.perfil["prog"] = pr
	return pr


## Dia de Nova York. Sem a hora da internet ainda, usa o relógio do aparelho só para contar o andamento: quem paga
## é o servidor, que confere a missão pela data dele.
static func hoje() -> int:
	if Relogio.sincronizado():
		return Relogio.dia()
	var t := Time.get_unix_time_from_system()
	return int(floor((t + Relogio.fuso_ny(t)) / 86400.0))


static func cont(k: String) -> int:
	return int(p()["cont"].get(k, 0))


static func diarias() -> Array:
	var pr := p()
	var lista: Array = dados()["diarias"]
	var idx := sorteio(int(pr["dia"]["k"]), 4, lista.size())
	var out: Array = [lista[idx[0]], lista[idx[1]], lista[idx[2]]]
	var t := int(pr["dia"].get("troca", -1))
	if t >= 0 and t < 3:
		out[t] = lista[idx[3]]
	return out


static func semanais() -> Array:
	var lista: Array = dados()["semanais"]
	return sorteio(int(p()["semana"]["k"]) + 100000, 3, lista.size()).map(func(i: int) -> Dictionary: return lista[i])


static func feita(escopo: String, id: String) -> bool:
	return id in (p()[escopo]["feitas"] as Array)


static func andamento(escopo: String, defn: Dictionary) -> int:
	return mini(int(p()[escopo]["cont"].get(defn["cont"], 0)), int(defn["alvo"]))


## Troca uma missão do dia que ainda não foi feita (1 por dia). Devolve true se trocou.
static func trocar(k: int) -> bool:
	var pr := p()
	if int(pr["dia"].get("troca", -1)) >= 0 or k < 0 or k > 2 or feita("dia", str(diarias()[k]["id"])):
		return false
	pr["dia"]["troca"] = k
	Sessao.salvar()
	return true


# ---------------- nível e maestria ----------------
static func xp_para(n: int) -> int:
	var nv: Dictionary = dados()["nivel"]
	return mini(int(nv["base"]) + int(nv["passo"]) * (n - 1), int(nv["teto"]))


## [nível, xp dentro do nível, xp para o próximo]
static func nivel_de(xp: int) -> Array:
	var n := 1
	while xp >= xp_para(n):
		xp -= xp_para(n)
		n += 1
	return [n, xp, xp_para(n)]


static func nivel() -> int:
	return int(nivel_de(int(p().get("xp", 0)))[0])


## Prêmio do nível n: a cada 10 um booster e 30 Koins, a cada 5 um booster, nos outros 40 moedas; alguns dão título.
static func premio_nivel(n: int) -> Dictionary:
	var r := {}
	if n % 10 == 0:
		r = {"booster": 1, "koins": 30}
	elif n % 5 == 0:
		r = {"booster": 1}
	else:
		r = {"moedas": 40}
	var t = dados()["nivel"]["titulos"].get(str(n))
	if t != null:
		r["titulo"] = str(t)
	return r


static func maestria_nivel(trad: String) -> int:
	var x := int(p()["maestria"].get(trad, 0))
	var n := 0
	for lim in dados()["maestria"]["limites"]:
		if x >= int(lim):
			n += 1
	return n


# ---------------- eventos ----------------
## Partida terminada (Sessao.registrar_partida): soma contadores, XP, maestria, e paga missões, níveis e conquistas.
## Devolve os eventos para o resumo da partida.
static func partida(reg: Dictionary) -> Array:
	var pr := p()
	var st: Dictionary = reg.get("stats", {})
	var res := str(reg.get("resultado", ""))
	var venceu := res == "vitoria"
	var trad := str(reg.get("deck", ""))
	var inc := {"partidas": 1, "vitorias": int(venceu), "derrotas": int(res == "derrota"), "empates": int(res == "empate"),
		"entidades": int(st.get("entidades", 0)), "ritos": int(st.get("ritos", 0)), "selos": int(st.get("selos", 0)),
		"reliquias": int(st.get("reliquias", 0)), "golpes": int(st.get("golpes", 0)), "lendarias": int(st.get("lendarias", 0)),
		"dano": maxi(0, int(st.get("dano", 0))), "mortes": int(st.get("mortes", 0))}
	var online: bool = reg.get("contra", "") in ["jogador", "bot"]      # bot também conta como partida online
	if online:
		inc["online_partidas"] = 1
		inc["online_vitorias"] = int(venceu)
	if venceu:
		if str(reg.get("modo", "")) in ["peregrinacao", "diario", "lendario", "livre", "choronzon"]:
			inc["solo_vitorias"] = 1
		if trad in dados()["tradicoes"]:
			inc["vit_" + trad] = 1
		if not online and int(reg.get("nivel", 1)) == 2:
			inc["arquimago_vitorias"] = 1
		if not bool(st.get("sofreu", true)):
			inc["intocavel"] = 1
		if int(st.get("cornucopia", 0)) == 1:
			inc["por_um_fio"] = 1
		if int(reg.get("turnos", 99)) <= 10:
			inc["rapido"] = 1
	if int(reg.get("turnos", 0)) >= 40:
		inc["maratona"] = 1
	_somar(inc)
	if venceu:
		pr["seq"] = int(pr.get("seq", 0)) + 1
	elif res == "derrota":
		pr["seq"] = 0
	pr["cont"]["seq_max"] = maxi(cont("seq_max"), int(pr.get("seq", 0)))
	var x: Dictionary = dados()["xp"]
	var ganho := int(x["vitoria"] if venceu else (x["derrota"] if res == "derrota" else x["empate"])) + (int(x["online"]) if online else 0)
	var ev: Array = [{"tipo": "xp", "xp": ganho}]
	var mn_antes := maestria_nivel(trad)
	if trad in dados()["tradicoes"]:
		pr["maestria"][trad] = int(pr["maestria"].get(trad, 0)) + ganho
	if venceu:                                           # retrato liberado ao vencer o personagem
		for a in MenuPerfil.liberaveis():
			var alvo := str(a.get("como", {}).get("vencer", ""))
			var avs: Array = Sessao.perfil.get("avatares", [])
			if alvo != "" and alvo == str(reg.get("deck_op", "")) and not (a["id"] in avs) and reg.get("contra", "") == "ia":
				avs.append(a["id"])
				Sessao.perfil["avatares"] = avs
				ev.append({"tipo": "avatar", "texto": _l(a["nome"]), "premio": {}})
	ev.append_array(_ganhar_xp(ganho))
	ev.append_array(_missoes())
	ev.append_array(_maestria(trad, mn_antes))
	ev.append_array(verificar())
	Sessao.salvar()
	return ev


static func contar(k: String, n := 1) -> void:
	_somar({k: n})
	Sessao.salvar()


static func _somar(inc: Dictionary) -> void:
	var pr := p()
	for k in inc:
		if int(inc[k]) == 0:
			continue
		for alvo in [pr["cont"], pr["dia"]["cont"], pr["semana"]["cont"]]:
			alvo[k] = int(alvo.get(k, 0)) + int(inc[k])


static func _ganhar_xp(n: int) -> Array:
	var pr := p()
	var antes := nivel()
	pr["xp"] = int(pr.get("xp", 0)) + n
	var ev: Array = []
	for nv in range(antes + 1, nivel() + 1):
		var r := premio_nivel(nv)
		_pagar({"k": "nivel", "nivel": nv}, r)
		ev.append({"tipo": "nivel", "texto": _l(["Nível %d", "Level %d"]) % nv, "premio": r})
	return ev


static func _missoes() -> Array:
	var pr := p()
	var ev: Array = []
	for escopo in ["dia", "semana"]:
		var lista := diarias() if escopo == "dia" else semanais()
		for m in lista:
			var id := str(m["id"])
			if feita(escopo, id) or andamento(escopo, m) < int(m["alvo"]):
				continue
			(pr[escopo]["feitas"] as Array).append(id)
			var r := {}
			for k in ["moedas", "booster", "koins"]:
				if m.has(k):
					r[k] = int(m[k])
			if escopo == "dia":
				_pagar({"k": "missao", "id": id, "dia": int(pr["dia"]["k"])}, r)
				_somar({"missoes": 1})
			else:
				_pagar({"k": "semanal", "id": id, "semana": int(pr["semana"]["k"])}, r)
			ev.append({"tipo": "missao", "texto": texto(m), "premio": r, "semanal": escopo == "semana"})
			ev.append_array(_ganhar_xp(int(dados()["xp"]["missao" if escopo == "dia" else "semanal"])))
	if not ev.is_empty():                                # a missão das missões (semanal) pode fechar agora
		ev.append_array(_missoes())
	return ev


static func _maestria(trad: String, antes: int) -> Array:
	var ev: Array = []
	var agora := maestria_nivel(trad)
	for nv in range(antes + 1, agora + 1):
		var r: Dictionary = (dados()["maestria"]["premios"][nv - 1] as Dictionary).duplicate()
		if r.has("titulo"):
			r["titulo"] = str(r["titulo"]) + trad
		_pagar({"k": "maestria", "trad": trad, "nivel": nv}, r)
		ev.append({"tipo": "maestria", "texto": _l(["Maestria %s %d", "%s Mastery %d"]) % [Sessao.nome_deck(trad), nv], "premio": r})
	var mx := 0
	for t in dados()["tradicoes"]:
		mx = maxi(mx, maestria_nivel(t))
	p()["cont"]["maestria_max"] = mx
	return ev


## Valores que vêm do perfil (coleção, modos, dias seguidos) + contadores; paga as conquistas novas.
static func valor(k: String) -> int:
	var pf := Sessao.perfil
	match k:
		"foils":
			var n := 0
			for cid in pf.get("foils", {}):
				n += int(int(pf["foils"][cid]) > 0)
			return n
		"cartas_distintas":
			return (pf.get("colecao", {}) as Dictionary).values().filter(func(v) -> bool: return int(v) > 0).size()
		"tradicoes_completas":
			var n := 0
			for t in dados()["tradicoes"]:
				var todas := true
				for cid in Sessao.db["cartas"]:
					if Sessao.db["cartas"][cid]["cultura"] == t and int(pf.get("colecao", {}).get(cid, 0)) <= 0:
						todas = false
						break
				n += int(todas)
			return n
		"tradicoes_vencidas":
			var n := 0
			for t in dados()["tradicoes"]:
				n += int(cont("vit_" + t) > 0)
			return n
		"enigmas":
			return (pf.get("enigmas", {}) as Dictionary).size()
		"torneio_vencido", "choronzon_vencido":
			return int(bool(pf.get(k, false)))
		"pere_fim":
			return int(pf.get("pere_fim", 0))
		"nivel":
			return nivel()
		"dias_max":
			return int(pf.get("resgates", {}).get("max", 0))
	return cont(k)


static func verificar() -> Array:
	var pr := p()
	var ev: Array = []
	for c in dados()["conquistas"]:
		var id := str(c["id"])
		if id in (pr["conquistas"] as Array) or valor(str(c["cont"])) < int(c["alvo"]):
			continue
		(pr["conquistas"] as Array).append(id)
		var r := {"moedas": int(c.get("moedas", 0))}
		if c.has("koins"):
			r["koins"] = int(c["koins"])
		if c.has("titulo"):
			r["titulo"] = str(c["titulo"])
		_pagar({"k": "conquista", "id": id}, r)
		ev.append({"tipo": "conquista", "texto": texto(c), "premio": r})
	if not ev.is_empty():
		Sessao.salvar()
	return ev


## Credita na hora e manda ao servidor (que confere e devolve o perfil certo).
static func _pagar(op: Dictionary, r: Dictionary) -> void:
	if int(r.get("moedas", 0)) > 0:
		Sessao._gravar("moedas", Sessao.moedas() + int(r["moedas"]))
	if int(r.get("booster", 0)) > 0:
		Sessao._gravar("boosters_gratis", Sessao.boosters_gratis() + int(r["booster"]))
	if int(r.get("koins", 0)) > 0:
		Sessao._gravar("koins", Sessao.koins() + int(r["koins"]))
	if r.has("titulo"):
		var t: Array = Sessao.perfil.get("titulos", [])
		if not (r["titulo"] in t):
			t.append(r["titulo"])
		Sessao.perfil["titulos"] = t
	if Nuvem.ativo():
		Nuvem.op("progresso", op, true)


## "+40 moedas · +1 booster · Título: X" para os resumos.
static func premio_txt(r: Dictionary) -> String:
	var partes := PackedStringArray()
	if int(r.get("moedas", 0)) > 0:
		partes.append(_l(["+%d moedas", "+%d coins"]) % int(r["moedas"]))
	if int(r.get("booster", 0)) > 0:
		partes.append(_l(["+%d booster", "+%d booster"]) % int(r["booster"]))
	if int(r.get("koins", 0)) > 0:
		partes.append("+%d Koins" % int(r["koins"]))
	if r.has("titulo"):
		partes.append(_l(["Título: %s", "Title: %s"]) % nome_titulo(str(r["titulo"])))
	return "  ·  ".join(partes)
