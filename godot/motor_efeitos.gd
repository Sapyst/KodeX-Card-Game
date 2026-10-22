class_name MotorEfeitos
extends RefCounted
## Efeitos reais das cartas na mesa: porta a semântica de sim/engine.py (DSL de docs/dsl_efeitos.md).
## A mesa guarda o estado nos nós Carta (campo_ent, campo_selo, mãos, decks) e chama este motor para
## gatilhos, alvos, condições, auras e ações. Tudo é assíncrono: cada ação tem feedback visual curto.
##
## Representações usadas no ctx (igual ao ctx do motor Python):
##   Entidade  → nó Carta em campo
##   Cornucópia → {"cornucopia": idx}
##   Relíquia  → {"dados", "nome", "usos", "portadora", "dono"} (também em Carta.reliquia)
##   cemitério → {"dados", "no"} (no = nó Carta ainda na pilha, ou null)

const CORNUCOPIA_MAX := 15
const FE_MAX := 8
const SLOTS := 4
const CHORONZON := {"entidade": "aby_choronzon", "reliquia": "aby_triangulo", "selo": "aby_circulo"}
const ALVOS_ESCOLHIDOS := ["enemy_entity", "ally_entity", "ally_graveyard_entity"]

const COR_DANO := Color("#ff6a6a")
const COR_CURA := Color("#8ae38a")
const COR_BUFF := Color("#ffe39a")
const COR_DEBUFF := Color("#c88aff")
const COR_GELO := Color("#9ad0ff")
const COR_MUDO := Color("#b8b4c0")
const COR_FE := Color("#7aa8ff")

var m                                   # a mesa (mesa.gd)
var prof_dano := 0
var stats := {"op": {}, "gatilho": {}, "selo": {}}
var _linha_txt := 0                     # empilha os textos centrais de um mesmo efeito
var _static_vistos := {}                # fontes de aura já contadas nas estatísticas


func _init(mesa) -> void:
	m = mesa


# ================= utilidades =================
func _conta(grupo: String, k: String) -> void:
	stats[grupo][k] = int(stats[grupo].get(k, 0)) + 1


func _esperar(t: float) -> void:
	await m.get_tree().create_timer(t).timeout


func campo(d: int) -> Array:
	var out: Array = []
	for i in SLOTS:
		var c = m.campo_ent[d][i]
		if c != null:
			out.append(c)
	return out


func tem_slot(d: int) -> bool:
	return m._espaco_livre(m.campo_ent[d]) >= 0


func humano(d: int) -> bool:
	return m.modo_partida and (m.online_partida() or (d == 0 and not m.auto_jogador))   # online os dois lados são gente


func entidades_cemiterio(d: int) -> Array:
	return (m.cemit[d] as Array).filter(func(e: Dictionary) -> bool: return e["dados"]["tipo"] == "entidade")


func valor(c) -> float:
	if c is Carta:
		return c.atk + c.vida() + c.keywords.size() + c.efeitos.size() + (2 if not c.reliquia.is_empty() else 0)
	return 0.0


func pode_atacar(c: Carta) -> bool:
	return c.em_campo and not c.atacou and not c.sem_ataque and (not c.cansada or c.tem("impeto"))


func _custo_de(obj):
	if obj is Carta:
		return obj.custo
	if obj is Dictionary and obj.has("dados"):
		return int(obj["dados"]["custo"])
	return null


func _pos_de(obj) -> Vector2:
	if obj is Carta and is_instance_valid(obj):
		return obj.position
	if obj is Dictionary and obj.has("cornucopia"):
		return m._pos_placar(obj["cornucopia"]) + Vector2(10, 2)
	if obj is Dictionary and obj.has("portadora") and is_instance_valid(obj["portadora"]):
		return obj["portadora"].position
	return Vector2(180, m.LINHA_Y)


func _texto_centro(txt: String, cor: Color) -> void:
	var y: float = m.LINHA_Y - 22 + 14 * (_linha_txt % 4)
	_linha_txt += 1
	m.efeitos.numero(Vector2(180, y), txt, cor, 2)


## Texto curto do efeito (mostrado no centro ao resolver).
static func rotulo(a: Dictionary) -> String:
	var n := int(a.get("n", 1))
	match a["op"]:
		"damage": return "DANO %d" % n
		"heal": return "CURA %d" % n
		"draw": return "COMPRE %d" % n
		"search": return "BUSCA " + str(a.get("tipo", "CARTA")).to_upper()
		"buff":
			var at := int(a.get("atk", 0)); var vi := int(a.get("vida", 0))
			return "%s%d/%s%d" % ["+" if at >= 0 else "", at, "+" if vi >= 0 else "", vi]
		"destroy": return "DESTRUIR"
		"bounce": return "DEVOLVER"
		"summon": return "INVOCA " + Sessao.nome_token(str(a.get("nome", "TOKEN"))).to_upper()
		"revive": return "REVIVE"
		"discard": return "DESCARTE %d" % n
		"gain_fe": return "+%d FÉ" % n
		"silence": return "SILÊNCIO"
		"freeze": return "CONGELAR"
		"counter": return "ANULADO"
		"give_keyword": return str(a.get("keyword", "")).to_upper()
		"set_stats": return "%d/%d" % [int(a.get("atk", 0)), int(a.get("vida", 0))]
		"copy_stats": return "CÓPIA"
		"swap_control": return "DOMINAR"
		"win": return "CHORONZON"
		"ritual_choronzon": return "SIGILO 333"
	return str(a["op"]).to_upper()


static func cor_de(a: Dictionary) -> Color:
	match a["op"]:
		"damage", "destroy": return COR_DANO
		"heal": return COR_CURA
		"buff":
			return COR_DEBUFF if int(a.get("atk", 0)) < 0 or int(a.get("vida", 0)) < 0 else COR_BUFF
		"freeze": return COR_GELO
		"silence": return COR_MUDO
		"gain_fe", "draw", "search": return Color("#cfe0ff")
	return Color("#f2e6c8")


## Tipo de alvo escolhido de um Rito (o primeiro que aparece nas ações), ou "" se o Rito não pede alvo.
static func alvo_escolhido(dados: Dictionary) -> String:
	for ef in dados.get("efeitos", []):
		for a in ef["acoes"]:
			if str(a.get("alvo", "")) in ALVOS_ESCOLHIDOS:
				return a["alvo"]
	return ""


## Candidatos válidos para um tipo de alvo escolhido (para destacar no arraste do jogador).
func candidatos(tipo: String, d: int, dados: Dictionary = {}) -> Array:
	var cmax = null
	for ef in dados.get("efeitos", []):
		var cond = ef.get("cond")
		if cond is Dictionary and cond.get("tipo") == "target_cost_max":
			cmax = int(cond["n"])
	var ok := func(c) -> bool: return cmax == null or int(_custo_de(c)) <= cmax
	match tipo:
		"enemy_entity":
			return campo(1 - d).filter(func(c: Carta) -> bool: return not c.protegida() and ok.call(c))
		"ally_entity":
			return campo(d).filter(func(c: Carta) -> bool: return ok.call(c))
		"ally_graveyard_entity":
			return entidades_cemiterio(d).filter(func(e: Dictionary) -> bool: return cmax == null or int(e["dados"]["custo"]) <= cmax)
	return []


# ================= auras =================
func recalcular_auras() -> void:
	for d in 2:
		for c in campo(d):
			c.aura_atk = 0
			c.aura_vida = 0
			c.aura_keywords = []
	for d in 2:
		for c in campo(d):
			var fontes: Array = []
			if not c.silenciada:
				for ef in c.efeitos:
					if ef["gatilho"] == "static":
						fontes.append(ef)
			if not c.reliquia.is_empty():
				for ef in c.reliquia["dados"]["efeitos"]:
					if ef["gatilho"] == "static":
						fontes.append(ef)
			for ef in fontes:
				_aplicar_aura(ef, c)
			if not fontes.is_empty() and not _static_vistos.has(c.get_instance_id()):
				_static_vistos[c.get_instance_id()] = true
				_conta("gatilho", "static")
	for d in 2:
		for c in campo(d):
			c.sincronizar()


func _aplicar_aura(ef: Dictionary, fonte: Carta) -> void:
	var ctx := {"dono": fonte.dono, "self": fonte, "triggering": fonte}
	if not cond_ok(ef.get("cond"), ctx):
		return
	var eu := campo(fonte.dono)
	var ini := campo(1 - fonte.dono)
	for a in ef["acoes"]:
		var alvos: Array = []
		match str(a.get("alvo", "")):
			"all_ally_entities": alvos = eu
			"other_ally_entities": alvos = eu.filter(func(t: Carta) -> bool: return t != fonte)
			"all_enemy_entities": alvos = ini
			"all_entities": alvos = eu + ini
		for t in alvos:
			if a["op"] == "buff":
				t.aura_atk += int(a.get("atk", 0))
				t.aura_vida += int(a.get("vida", 0))
			elif a["op"] == "give_keyword" and not (a["keyword"] in t.aura_keywords):
				t.aura_keywords.append(a["keyword"])


# ================= condições =================
func cond_ok(cond, ctx: Dictionary) -> bool:
	if not (cond is Dictionary) or cond.is_empty():
		return true
	var dono: int = ctx["dono"]
	var n := int(cond.get("n", 0))
	match cond["tipo"]:
		"ally_count_min": return campo(dono).size() >= n
		"ally_count_max": return campo(dono).size() <= n
		"enemy_count_min": return campo(1 - dono).size() >= n
		"enemy_count_max": return campo(1 - dono).size() <= n
		"hand_min": return m._mao_de(dono).size() >= n
		"hand_max": return m._mao_de(dono).size() <= n
		"cornucopia_below": return m.cornucopia[dono] < n
		"enemy_cornucopia_below": return m.cornucopia[1 - dono] < n
		"graveyard_entities_min": return entidades_cemiterio(dono).size() >= n
		"fe_max_min": return m.fe_max[dono] >= n
		"target_cost_max":
			var trig = ctx.get("triggering")
			if trig == null or (trig is Carta and trig == ctx.get("self")):
				ctx["_cost_max"] = n        # on_play: restringe os alvos escolhíveis
				return true
			var custo = _custo_de(trig)
			return custo != null and int(custo) <= n
	return true


# ================= alvos =================
func alvos(alvo, ctx: Dictionary, acao: Dictionary) -> Array:
	var dono: int = ctx["dono"]
	var cmax = ctx.get("_cost_max")
	var custo_ok := func(e) -> bool: return cmax == null or int(_custo_de(e) if _custo_de(e) != null else 0) <= int(cmax)
	match str(alvo):
		"self":
			var e = ctx.get("self")
			return [e] if e is Carta else []
		"attacker", "defender":
			var e = ctx.get(alvo)
			return [e] if e is Carta else []
		"triggering":
			var t = ctx.get("triggering")
			if t is Carta and t.dono != dono and t.protegida():
				return []
			return [t] if t != null else []
		"equipped":
			var e = ctx.get("equipped")
			return [e] if e is Carta else []
		"enemy_entity":
			return await _escolher(dono, campo(1 - dono).filter(func(e: Carta) -> bool: return not e.protegida() and custo_ok.call(e)), acao, ctx)
		"enemy_entity_random":
			return await _aleatorio(campo(1 - dono).filter(func(e: Carta) -> bool: return not e.protegida() and custo_ok.call(e)))
		"all_enemy_entities":
			return campo(1 - dono)
		"ally_entity":
			return await _escolher(dono, campo(dono).filter(func(e: Carta) -> bool: return custo_ok.call(e)), acao, ctx)
		"ally_entity_random":
			return await _aleatorio(campo(dono).filter(func(e: Carta) -> bool: return custo_ok.call(e)))
		"all_ally_entities":
			return campo(dono)
		"other_ally_entities":
			return campo(dono).filter(func(e: Carta) -> bool: return e != ctx.get("self"))
		"all_entities":
			return campo(dono) + campo(1 - dono)
		"enemy_cornucopia":
			return [{"cornucopia": 1 - dono}]
		"ally_cornucopia":
			return [{"cornucopia": dono}]
		"enemy_hand_random":
			return await _aleatorio(m._mao_de(1 - dono).duplicate())
		"ally_graveyard_entity":
			return await _escolher(dono, entidades_cemiterio(dono).filter(func(e: Dictionary) -> bool: return cmax == null or int(e["dados"]["custo"]) <= int(cmax)), acao, ctx)
		"ally_graveyard_entity_random":
			return await _aleatorio(entidades_cemiterio(dono).filter(func(e: Dictionary) -> bool: return cmax == null or int(e["dados"]["custo"]) <= int(cmax)))
	return []


func _escolher(dono: int, cands: Array, acao: Dictionary, ctx: Dictionary) -> Array:
	if cands.is_empty():
		return []
	# dentro de um mesmo efeito, o mesmo tipo de alvo escolhido reaproveita a escolha (ex.: cura 2 e +1/+1 na mesma aliada)
	var chave := "_esc_" + str(acao.get("alvo"))
	var prev = ctx.get(chave)
	if prev != null:
		for c in cands:
			if is_same(c, prev):
				return [prev]
	var esc = null
	if m.decisao_da_rede(dono) and ctx.get("interativo", false):   # online: a escolha do adversário chega pela rede
		var v: int = await m.esc_rede(dono)
		if v < 0 or v >= cands.size():
			return []
		esc = cands[v]
	elif humano(dono) and ctx.get("interativo", false):      # o jogador toca o alvo (mesmo com 1 só: pode PULAR)
		if m.auto_jogador:                                    # teste online com a IA jogando por mim
			esc = cands[0] if cands.size() == 1 else ia_alvo(dono, cands, acao)
		elif cands[0] is Carta:
			esc = await m.pedir_alvo(cands, _dica_alvo(acao), "PULAR", ctx.get("fonte"))
		else:
			esc = await m.pedir_cemiterio(cands)
		m.enviar_esc(m._indice(cands, esc))
		if esc == null:
			return []
	elif cands.size() == 1:
		esc = cands[0]
	else:
		esc = ia_alvo(dono, cands, acao)
	ctx[chave] = esc
	return [esc]


static func _dica_alvo(acao: Dictionary) -> String:
	return "ALVO: " + rotulo(acao)


func _aleatorio(cands: Array) -> Array:
	if cands.is_empty():
		return []
	return [cands[await m.sortear(cands.size())]]


## Escolha de alvo da IA (port de HeurBot.escolher_alvo).
func ia_alvo(_dono: int, cands: Array, acao: Dictionary):
	var op: String = acao["op"]
	var alvo := str(acao.get("alvo", ""))
	if not (cands[0] is Carta):
		var best = cands[0]
		for e in cands:
			if int(e["dados"]["custo"]) > int(best["dados"]["custo"]):
				best = e
		return best
	var maxpor := func(lista: Array, f: Callable):
		var b = lista[0]
		for e in lista:
			if f.call(e) > f.call(b):
				b = e
		return b
	if alvo.begins_with("enemy"):
		if op == "damage":
			var n := int(acao.get("n", 0))
			var mataveis := cands.filter(func(e: Carta) -> bool: return e.vida() <= n)
			if not mataveis.is_empty():
				return maxpor.call(mataveis, valor)
			return maxpor.call(cands, func(e: Carta) -> float: return e.atk)
		return maxpor.call(cands, valor)
	if op == "heal":
		var n := int(acao.get("n", 0))
		return maxpor.call(cands, func(e: Carta) -> float: return mini(e.dano, n))
	if op in ["buff", "give_keyword", "set_stats"]:
		var negativo := op == "buff" and (int(acao.get("atk", 0)) < 0 or int(acao.get("vida", 0)) < 0)
		if negativo:
			return maxpor.call(cands, func(e: Carta) -> float: return -valor(e))
		var prontos := cands.filter(func(e: Carta) -> bool: return pode_atacar(e))
		var pool := prontos if not prontos.is_empty() else cands
		if op == "set_stats":
			return maxpor.call(pool, func(e: Carta) -> float: return -(e.atk + e.vida()))
		return maxpor.call(pool, func(e: Carta) -> float: return e.atk)
	if op in ["damage", "destroy", "freeze", "silence", "bounce"]:
		return maxpor.call(cands, func(e: Carta) -> float: return -valor(e))
	return maxpor.call(cands, valor)


# ================= gatilhos =================
func disparar_entidades(gat: String, idx: int, ctx_base: Dictionary, excluir = null) -> void:
	for c in campo(idx):
		if (excluir != null and c == excluir) or not c.em_campo:
			continue
		await disparar_efeitos_entidade(c, gat, ctx_base)
	await processar_mortes()


func disparar_efeitos_entidade(c: Carta, gat: String, ctx_base: Dictionary, exige_campo := true) -> void:
	if c.silenciada:
		return
	for ef in c.efeitos.duplicate():
		if ef["gatilho"] != gat:
			continue
		if exige_campo and not c.em_campo:
			return
		var ctx := ctx_base.duplicate()
		ctx["self"] = c
		ctx["dono"] = c.dono
		ctx["fonte"] = c
		ctx["gatilho"] = gat
		if not ctx.has("triggering"):
			ctx["triggering"] = c
		if cond_ok(ef.get("cond"), ctx):
			_conta("gatilho", gat)
			await _anunciar_fonte(c, gat)
			await executar_acoes(ef["acoes"], ctx)


func disparar_efeitos_reliquia(rel: Dictionary, gat: String, ctx_base: Dictionary) -> void:
	var port: Carta = rel["portadora"]
	for ef in rel["dados"]["efeitos"]:
		if ef["gatilho"] != gat:
			continue
		if not is_same(port.reliquia, rel):
			return
		var ctx := ctx_base.duplicate()
		ctx["gatilho"] = gat
		ctx["self"] = port
		ctx["equipped"] = port
		ctx["dono"] = port.dono
		ctx["fonte"] = rel
		if cond_ok(ef.get("cond"), ctx):
			_conta("gatilho", gat)
			if gat != "on_equip":
				m._piscar(port)
				m.efeitos.numero(port.position + Vector2(0, 34), PixelFonte.normalizar(str(rel["nome"])), COR_BUFF, 1)
			await executar_acoes(ef["acoes"], ctx)
	if gat == "equipped_attacks" and rel.get("usos") != null and is_same(port.reliquia, rel):
		rel["usos"] = int(rel["usos"]) - 1
		if int(rel["usos"]) <= 0:
			m.efeitos.numero(port.position + Vector2(0, 44), "USOS ESGOTADOS", COR_MUDO, 1)
			remover_reliquia(rel)


## Selos de `idx` com esse gatilho disparam (só no turno do oponente dele e nunca no turno em que foram postos).
func disparar_selos(gat: String, idx: int, ctx_base: Dictionary) -> void:
	if m.ativo == idx:
		return
	var selos: Array = []
	for i in 2:
		if m.campo_selo[idx][i] != null:
			selos.append(m.campo_selo[idx][i])
	selos.sort_custom(func(a: Carta, b: Carta) -> bool: return a.turno_posto < b.turno_posto)
	for s in selos:
		if m.acabou:
			return
		if m.online_partida() and idx == 1:                # Selo do adversário: só o juiz sabe qual é e se dispara
			var r: Dictionary = await m.rede.revelacao("selo")
			if not r.get("dispara", false):
				continue
			m._identificar(s, str(r.get("id", "")), idx)
		var ef: Dictionary = s.efeitos[0] if not s.efeitos.is_empty() else {}
		var ctx := ctx_base.duplicate()
		ctx["self"] = null
		ctx["dono"] = idx
		ctx["fonte"] = s
		ctx["gatilho"] = gat
		if not (m.online_partida() and idx == 1):
			if ef.is_empty() or ef["gatilho"] != gat or s.turno_posto == m.turno_n or not (s in m.campo_selo[idx]):
				continue
			if not cond_ok(ef.get("cond"), ctx):
				continue
		_conta("gatilho", "selo:" + gat)
		_conta("selo", s.id)
		var slot: int = m.campo_selo[idx].find(s)
		m.campo_selo[idx][slot] = null
		m.cemit[idx].append({"dados": s.dados, "no": null})
		await m._revelar_selo(s)
		_linha_txt = 0
		await executar_acoes(ef["acoes"], ctx)
		await m._selo_ao_cemiterio(s)
		if ctx.get("anulado", false):
			ctx_base["anulado"] = true


## Brilho curto na Entidade cujo efeito vai resolver + o nome do gatilho (Despertar, Último Sopro…).
func _anunciar_fonte(c: Carta, gat: String) -> void:
	_linha_txt = 0
	if not is_instance_valid(c):
		return
	var nome_gat: String = {"on_play": "DESPERTAR", "on_death": "ÚLTIMO SOPRO", "on_attack": "AO ATACAR",
		"on_damaged": "AO SOFRER DANO", "ally_attacked": "PROTEÇÃO", "start_turn": "INÍCIO DO TURNO",
		"end_turn": "FIM DO TURNO", "ally_dies": "ALIADA MORREU", "enemy_dies": "INIMIGA MORREU"}.get(gat, "")
	if c.em_campo:
		m._piscar(c)
		m.efeitos.anel(c.position, COR_BUFF, 30)
	if nome_gat != "":
		m.efeitos.numero(c.position + Vector2(0, -44), nome_gat, COR_BUFF, 1)
	await _esperar(0.25)


# ================= dano, morte =================
func pos_dano(e: Carta, n: int, fonte, atacante) -> void:
	if n <= 0 or prof_dano >= 8:
		return
	prof_dano += 1
	var ctx := {"triggering": fonte if fonte is Carta else null, "attacker": atacante}
	await disparar_efeitos_entidade(e, "on_damaged", ctx)
	await disparar_selos("ally_damaged", e.dono, {"triggering": e, "attacker": atacante, "defender": e})
	prof_dano -= 1


func dano_cornucopia(idx: int, n: int) -> void:
	if n <= 0:
		return
	m.cornucopia[idx] -= n
	m.placar_pulo[idx] = 1.0
	m.tremor = maxf(m.tremor, 3.0)
	var p: Vector2 = m._pos_placar(idx) + Vector2(10, 2)
	m.efeitos.faiscas(p, 16, Color("#ff9a6a"))
	m.efeitos.numero(p + Vector2(22, -8), "-%d" % n, Color("#ff5050"), 2)


func processar_mortes() -> void:
	for _k in 50:
		var mortos: Array = []
		for idx in [m.ativo, 1 - m.ativo]:
			for c in campo(idx):
				if c.vida() <= 0:
					mortos.append(c)
		if mortos.is_empty():
			return
		for c in mortos:
			if is_instance_valid(c) and c.em_campo:     # um token já desfeito pode ter sido liberado no meio da cadeia
				await morrer(c)


func morrer(c: Carta, renascer := true) -> void:
	if not is_instance_valid(c) or not c.em_campo:
		return
	var controlador := c.dono
	m._conta(controlador, "mortes")
	var silenciada := c.silenciada
	var efs: Array = c.efeitos.duplicate()
	var rel: Dictionary = c.reliquia
	m._remover_do_campo(c)
	c.em_campo = false
	recalcular_auras()
	if c.dono == 1:
		m._provocar(2)
	if c.token:
		await m._desfazer(c)
	elif renascer and "renascer" in c.keywords:
		c.sem_renascer = true
		await m._renascer(c)
	else:
		m.cemit[c.dono_real].append({"dados": c.dados, "no": c})
		await m._destruir(c)
	if not rel.is_empty():
		await disparar_efeitos_reliquia(rel, "equipped_dies", {"triggering": c})
		remover_reliquia(rel)
	if not silenciada:
		var antes := c.efeitos
		var sil := c.silenciada
		var dono_agora := c.dono
		c.efeitos = efs
		c.silenciada = false
		c.dono = controlador                    # Último Sopro resolve para quem a controlava
		await disparar_efeitos_entidade(c, "on_death", {"triggering": c}, false)
		if is_instance_valid(c):
			c.efeitos = antes
			c.silenciada = sil
			c.dono = dono_agora
	var ctx := {"triggering": c, "attacker": null}
	await disparar_entidades("ally_dies", controlador, ctx)
	await disparar_selos("ally_dies", controlador, ctx)
	await disparar_entidades("enemy_dies", 1 - controlador, ctx)


func remover_reliquia(rel: Dictionary) -> void:
	var port: Carta = rel["portadora"]
	if is_same(port.reliquia, rel):
		port.reliquia = {}
		port.rel_atk = 0
		port.rel_vida = 0
		if port.em_campo:
			m.efeitos.faiscas(port.position + Vector2(0, 40), 10, COR_BUFF)
	m.cemit[rel["dono"]].append({"dados": rel["dados"], "no": null})
	m.cemiterio[rel["dono"]] += 1
	recalcular_auras()


# ================= ações =================
func executar_acoes(acoes: Array, ctx: Dictionary) -> void:
	for a in acoes:
		if m.acabou:
			return
		await executar_acao(a, ctx)
	recalcular_auras()


func executar_acao(a: Dictionary, ctx: Dictionary) -> void:
	var op: String = a["op"]
	var dono: int = ctx["dono"]
	var fonte = ctx.get("fonte")
	_conta("op", op)
	match op:
		"draw":
			_texto_centro(rotulo(a), cor_de(a))
			for k in int(a.get("n", 1)):
				await m._comprar(dono)
		"search":
			await _buscar(dono, a)
		"discard":
			_texto_centro(rotulo(a), COR_DEBUFF)
			for k in int(a.get("n", 1)):
				var mao: Array = m._mao_de(1 - dono)
				if mao.is_empty():
					break
				if m.online_partida():                       # o juiz sorteia e revela a carta descartada
					var r: Dictionary = await m.rede.revelacao("descarte")
					var c: Carta = mao[clampi(int(r.get("k", 0)), 0, mao.size() - 1)]
					m._identificar(c, str(r.get("id", "")), 1 - dono)
					await m._descartar(1 - dono, c)
				else:
					await m._descartar(1 - dono, mao[await m.sortear(mao.size())])
		"gain_fe":
			var n := int(a.get("n", 1))
			if a.get("perm", false):
				m.fe_max[dono] = mini(FE_MAX, m.fe_max[dono] + n)
				_texto_centro("+%d FÉ MÁX" % n, COR_FE)
			else:
				m.fe[dono] += n
				_texto_centro(rotulo(a), COR_FE)
			m.efeitos.faiscas(m._pos_fe(dono), 12, COR_FE)
			m._atualizar_apagadas()
			await _esperar(0.3)
		"counter":
			ctx["anulado"] = true
			_texto_centro("ANULADO", COR_DEBUFF)
			m.efeitos.flash(Color("#6a3aa8"), 0.25)
			await _esperar(0.35)
		"win":
			await m._encerrar(dono, "CHORONZON")
		"ritual_choronzon":
			await _ritual_choronzon(dono)
		"summon":
			_texto_centro(rotulo(a), COR_BUFF)
			await _invocar_tokens(dono, a, fonte)
		_:
			var lista: Array = await alvos(a.get("alvo"), ctx, a)
			if lista.is_empty():
				return
			_texto_centro(rotulo(a), cor_de(a))
			if op == "damage":
				var n := int(a["n"])
				var pend: Array = []
				for t in lista:
					await _feixe(fonte, t, COR_DANO)
					if t is Carta and t.em_campo:
						t.dano += n
						m.efeitos.numero(t.position + Vector2(0, -20), "-%d" % n, COR_DANO)
						m._piscar(t)
						m._sacudir(t, 3.0)
						pend.append(t)
					elif t is Dictionary and t.has("cornucopia"):
						dano_cornucopia(t["cornucopia"], n)
				m.tremor = maxf(m.tremor, 2.5)
				await _esperar(0.3)
				for t in pend:
					await pos_dano(t, n, fonte, null)    # dano de efeito não tem atacante
			else:
				for t in lista:
					await aplicar_em_alvo(op, a, t, ctx)
				await _esperar(0.25)


func _feixe(fonte, alvo, cor: Color) -> void:
	var de := _pos_de(fonte)
	var para := _pos_de(alvo)
	if de.distance_to(para) < 4:
		m.efeitos.faiscas(para, 10, cor)
		return
	for k in 6:
		m.efeitos.faiscas(de.lerp(para, k / 6.0), 3, cor)
		await _esperar(0.02)
	m.efeitos.faiscas(para, 10, cor)


func aplicar_em_alvo(op: String, a: Dictionary, t, ctx: Dictionary) -> void:
	var dono: int = ctx["dono"]
	match op:
		"heal":
			var n := int(a["n"])
			if t is Carta and t.em_campo:
				t.dano = maxi(0, t.dano - n)
				m.efeitos.numero(t.position + Vector2(0, -20), "+%d" % n, COR_CURA)
				m.efeitos.faiscas(t.position, 10, COR_CURA)
			elif t is Dictionary and t.has("cornucopia"):
				var idx: int = t["cornucopia"]
				m.cornucopia[idx] = mini(CORNUCOPIA_MAX, m.cornucopia[idx] + n)
				var p: Vector2 = m._pos_placar(idx) + Vector2(10, 2)
				m.efeitos.numero(p + Vector2(22, -8), "+%d" % n, COR_CURA, 2)
				m.efeitos.faiscas(p, 12, COR_CURA)
		"buff":
			if t is Carta and t.em_campo:
				var at := int(a.get("atk", 0))
				var vi := int(a.get("vida", 0))
				var fonte = ctx.get("fonte")
				if ctx.get("gatilho") == "on_equip" and fonte is Dictionary and is_same(t.reliquia, fonte):
					t.rel_atk += at
					t.rel_vida += vi
				elif a.get("perm", true):
					t.buff_atk += at
					t.buff_vida += vi
				else:
					t.temp_atk += at
					t.temp_vida += vi
				t.sincronizar()
				var neg := at < 0 or vi < 0
				m.efeitos.numero(t.position + Vector2(0, -20), rotulo(a), COR_DEBUFF if neg else COR_BUFF, 1)
				m.efeitos.faiscas(t.position, 10, COR_DEBUFF if neg else COR_BUFF)
				m._piscar(t)
		"destroy":
			if t is Carta:
				m.efeitos.flash(Color("#300010"), 0.25)
				m.efeitos.anel(t.position, COR_DANO, 36)
				await morrer(t)
			elif t is Dictionary and t.has("portadora"):
				remover_reliquia(t)
		"bounce":
			if t is Carta and t.em_campo:
				await devolver_a_mao(t)
		"revive":
			await _reviver(dono, t, str(a.get("para", "hand")))
		"silence":
			if t is Carta:
				t.keywords.clear()
				t.efeitos = []
				t.silenciada = true
				recalcular_auras()
				m.efeitos.faiscas(t.position, 12, COR_MUDO)
				m.efeitos.numero(t.position + Vector2(0, -20), "SILÊNCIO", COR_MUDO, 1)
		"freeze":
			if t is Carta:
				t.congelada = true
				m.efeitos.anel(t.position, COR_GELO, 32)
				m.efeitos.faiscas(t.position, 12, COR_GELO)
				m.efeitos.numero(t.position + Vector2(0, -20), "CONGELADA", COR_GELO, 1)
		"give_keyword":
			if t is Carta and t.em_campo:
				if not (a["keyword"] in t.keywords):
					t.keywords.append(a["keyword"])
				m.efeitos.numero(t.position + Vector2(0, -28), str(a["keyword"]).to_upper(), COR_BUFF, 1)
				m._piscar(t)
		"set_stats":
			if t is Carta and t.em_campo:
				t.atk_base = int(a["atk"])
				t.vida_base = int(a["vida"])
				t.limpar_stats()
				m.efeitos.numero(t.position + Vector2(0, -20), "%d/%d" % [t.atk_base, t.vida_base], COR_BUFF, 2)
				m.efeitos.faiscas(t.position, 14, COR_BUFF)
				m._piscar(t)
		"copy_stats":
			var s = ctx.get("self")
			if t is Carta and s is Carta and s.em_campo:
				s.atk_base = t.atk
				s.vida_base = maxi(1, t.vida())
				s.limpar_stats()
				m._piscar(s)
		"swap_control":
			if t is Carta and t.em_campo and t.dono != dono:
				await roubar(t, dono, a.get("perm", true))
	recalcular_auras()


func _buscar(d: int, a: Dictionary) -> void:
	var deck: Array = m._deck_de(d)
	if m.online_partida():                               # o juiz procura no deck (escondido) e diz se achou
		_texto_centro(rotulo(a), cor_de(a))
		var r: Dictionary = await m.rede.revelacao("busca")
		if not r.get("achou", false) or deck.is_empty():
			m.efeitos.numero(Vector2(180, m.LINHA_Y + 20), "NADA NO DECK", COR_MUDO, 1)
			await _esperar(0.3)
			return
		var achada: Carta = deck.pop_back()
		await m._receber_comprada(d, achada, false)        # a minha vem revelada; a dele continua verso
		return
	var cands: Array = deck.filter(func(c: Carta) -> bool:
		return (a.get("tipo") == null or c.tipo == a["tipo"]) \
			and (a.get("custo_max") == null or c.custo <= int(a["custo_max"])) \
			and (a.get("keyword") == null or a["keyword"] in c.keywords))
	_texto_centro(rotulo(a), cor_de(a))
	if cands.is_empty():
		m.efeitos.numero(Vector2(180, m.LINHA_Y + 20), "NADA NO DECK", COR_MUDO, 1)
		await _esperar(0.3)
		return
	# escolha: a mais cara jogável no próximo turno (senão a mais barata) — HeurBot.escolher_busca
	var jog := cands.filter(func(c: Carta) -> bool: return c.custo <= m.fe_max[d] + 1)
	var esc: Carta = cands[0]
	if not jog.is_empty():
		for c in jog:
			if c.custo > esc.custo or not (esc in jog):
				esc = c
	else:
		for c in cands:
			if c.custo < esc.custo:
				esc = c
	deck.erase(esc)
	m._embaralhar_deck(d)
	await m._receber_comprada(d, esc, false)


func _invocar_tokens(d: int, a: Dictionary, fonte) -> void:
	var nome := str(a.get("nome", "Token"))
	var info: Dictionary = Sessao.tokens.get(nome, {})        # arte, tradição e nome em inglês do token
	var de_quem := str(fonte.nome) if (fonte is Object and is_instance_valid(fonte) and fonte is Carta) else ""
	var texto := (Sessao.t("Token invocado por %s.") % de_quem) if de_quem != "" else "Token."
	if "guarda" in (a.get("keywords", []) as Array):
		texto = Sessao.t("Guarda. ") + texto
	var dados := {"id": str(info.get("id", "token_" + nome.to_lower().replace(" ", "_"))),
		"nome": Sessao.nome_token(nome), "cultura": str(info.get("cultura", "token")), "tipo": "entidade",
		"custo": 0, "atk": int(a["atk"]), "vida": int(a["vida"]), "lendaria": false,
		"keywords": (a.get("keywords", []) as Array).duplicate(), "sacrificio": 0, "efeitos": [], "usos": null,
		"texto": texto, "token": true}
	var de := _pos_de(fonte)
	for k in int(a.get("n", 1)):
		var i: int = m._espaco_livre(m.campo_ent[d])
		if i < 0:
			break
		var c: Carta = m._nova_carta(de, 0.5)
		c.definir(dados, d)
		c.virada_para_cima = true
		await m._por_em_campo(c, d, i)


func _reviver(d: int, e, para: String) -> void:
	if not (e is Dictionary) or not e.has("dados"):
		return
	var idx: int = -1
	for k in m.cemit[d].size():
		if is_same(m.cemit[d][k], e):
			idx = k
	if idx < 0:
		return
	if para == "field" and not tem_slot(d):
		return
	m.cemit[d].remove_at(idx)
	var c: Carta = e["no"] if e["no"] != null and is_instance_valid(e["no"]) and not e["no"].em_campo and not (e["no"] in m._mao_de(d)) else null
	var pos_cem: Vector2 = m.proj(m.CEMIT_JOG if d == 0 else m.CEMIT_OPON)
	if c == null:
		c = m._nova_carta(pos_cem, m.esc_em(pos_cem))
		c.definir(e["dados"], d)
		c.virada_para_cima = true
	c.resetar()
	c.dono = d
	c.visible = true
	m.efeitos.faiscas(c.position, 18, COR_BUFF)
	m.efeitos.anel(c.position, COR_BUFF, 30)
	m.efeitos.numero(c.position + Vector2(0, -30), "REVIVE", COR_BUFF, 1)
	if para == "field":
		await m._por_em_campo(c, d, m._espaco_livre(m.campo_ent[d]))
		# revive para o campo não dispara Despertar nem enemy_plays_entity
	else:
		await m._entrar_na_mao(d, c)


func devolver_a_mao(c: Carta) -> void:
	m._remover_do_campo(c)
	c.em_campo = false
	var rel: Dictionary = c.reliquia
	if not rel.is_empty():
		remover_reliquia(rel)
	m.efeitos.faiscas(c.position, 12, Color("#cfe0ff"))
	m.efeitos.numero(c.position + Vector2(0, -24), "DEVOLVIDA", Color("#cfe0ff"), 1)
	if c.token:
		await m._desfazer(c)
	else:
		c.resetar()
		await m._entrar_na_mao(c.dono_real, c)
	recalcular_auras()


func roubar(c: Carta, novo: int, perm: bool) -> void:
	var i: int = m._espaco_livre(m.campo_ent[novo])
	if i < 0:
		return
	m._remover_do_campo(c)
	c.dono = novo
	c.cansada = true
	c.atacou = false
	c.roubada_temp = (not perm) and c.dono_real != novo
	m.efeitos.numero(c.position + Vector2(0, -24), "DOMINADA", COR_DEBUFF, 1)
	await m._por_em_campo(c, novo, i)
	c.cansada = true
	recalcular_auras()


func devolver_controle(c: Carta) -> void:
	c.roubada_temp = false
	m._remover_do_campo(c)
	var orig := c.dono_real
	c.dono = orig
	var i: int = m._espaco_livre(m.campo_ent[orig])
	if i >= 0:
		await m._por_em_campo(c, orig, i)
		c.cansada = true
	else:
		c.em_campo = false
		m.cemit[orig].append({"dados": c.dados, "no": c})
		await m._destruir(c)


func _ritual_choronzon(d: int) -> void:
	var tri := false
	for c in campo(d):
		if not c.reliquia.is_empty() and c.reliquia["dados"]["id"] == CHORONZON["reliquia"]:
			tri = true
	var cir := false
	for i in 2:
		var s = m.campo_selo[d][i]
		if s != null and s.id == CHORONZON["selo"]:
			cir = true
	var chor: Carta = null
	for c in m._mao_de(d):
		if c.id == CHORONZON["entidade"]:
			chor = c
	if m.online_partida() and d == 1:                     # mão e Selos dele são escondidos: o juiz diz
		var r: Dictionary = await m.rede.revelacao("ritual")
		tri = r.get("ok", false)
		cir = tri
		chor = null
		if tri:
			chor = m._mao_de(d)[clampi(int(r.get("k", 0)), 0, m._mao_de(d).size() - 1)]
			m._identificar(chor, CHORONZON["entidade"], d)
	if tri and cir and chor != null:
		_texto_centro("SIGILO 333", COR_DEBUFF)
		m._mao_de(d).erase(chor)
		m._rearrumar_de(d)
		var i: int = m._espaco_livre(m.campo_ent[d])
		if i < 0:
			i = 0
			var velha = m.campo_ent[d][0]
			if velha != null:
				await morrer(velha, false)
		if not chor.virada_para_cima:
			chor.virar(0.2)
		await m._por_em_campo(chor, d, i)
		await disparar_efeitos_entidade(chor, "on_play", {"triggering": chor})
	else:
		_texto_centro("COMPRE 1", Color("#cfe0ff"))
		await m._comprar(d)


# ================= combate (chamado pela mesa) =================
## Gatilhos de declaração de ataque. Devolve false se o ataque foi cancelado (atacante ou defensor saiu do campo).
func antes_do_ataque(atacante: Carta, alvo) -> bool:
	atacante.atacou = true
	atacante.ja_atacou = true
	var ini := 1 - atacante.dono
	var trig = alvo if alvo != null else {"cornucopia": ini}
	var ctx := {"attacker": atacante, "triggering": trig, "defender": alvo}
	await disparar_efeitos_entidade(atacante, "on_attack", ctx)
	if not atacante.reliquia.is_empty():
		await disparar_efeitos_reliquia(atacante.reliquia, "equipped_attacks", ctx)
	if alvo == null:
		await disparar_selos("enemy_attacks_cornucopia", ini, ctx)
	else:
		await disparar_selos("enemy_attacks", ini, ctx)
		await disparar_entidades("ally_attacked", ini, ctx, alvo)
	await processar_mortes()
	if m.acabou or not is_instance_valid(atacante) or not atacante.em_campo or atacante.dono != 1 - ini:
		return false
	if alvo != null and (not is_instance_valid(alvo) or not alvo.em_campo or alvo.dono != ini):
		return false
	return true


func apos_combate(atacante: Carta, alvo: Carta, da: int, dd: int) -> void:
	await pos_dano(alvo, da, atacante, atacante)
	await pos_dano(atacante, dd, alvo, null)       # contragolpe não tem atacante
	await processar_mortes()


# ================= turnos =================
func inicio_turno(d: int) -> void:
	recalcular_auras()
	await disparar_entidades("start_turn", d, {})


func fim_turno(d: int) -> void:
	await disparar_entidades("end_turn", d, {})
	await disparar_selos("enemy_end_turn", 1 - d, {})
	for j in 2:
		for c in campo(j):
			c.temp_atk = 0
			c.temp_vida = 0
			if c.roubada_temp:
				await devolver_controle(c)
	recalcular_auras()
	await processar_mortes()


func resumo() -> String:
	return "EFEITOS ops=%s gatilhos=%s selos=%s" % [str(stats["op"]), str(stats["gatilho"]), str(stats["selo"])]
