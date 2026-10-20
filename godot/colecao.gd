class_name Colecao
extends RefCounted
## Coleção (dentro do menu fluxo.gd): abas por tradição, grade 4 colunas de cartas montadas (74×104) com rolagem por
## arraste + inércia, e a página de lore de cada carta (carta grande, título, lore, curiosidade, "arte em revisão").
## Tudo em px nativos 360×640. A área rolável vai de y 96 a 594; o que passa da borda é recortado.

const ABAS := ["indigena", "cristianismo", "taoismo", "hinduismo", "bruxaria", "alta_magia", "abismo"]
const CW := 74.0
const CH := 104.0
const PASSO := 112.0
const TOPO := 96.0
const BASE := 594.0

var f                               # o menu (fluxo.gd)
var aba := "alta_magia"
var rolagem := 0.0
var vel := 0.0
var carta := ""                     # id aberto na página de lore
var rolagem_lore := 0.0
var _ids: Array = []


func _init(menu) -> void:
	f = menu


func abrir_aba(d: String) -> void:
	aba = d
	rolagem = 0.0
	vel = 0.0
	_ids.clear()
	for cid in Sessao.db["cartas"]:
		if str(Sessao.db["cartas"][cid]["cultura"]) == d:
			_ids.append(cid)
	for nome in Sessao.tokens:
		if str(Sessao.tokens[nome]["cultura"]) == d:
			_ids.append(Sessao.tokens[nome]["id"])


func _altura_conteudo() -> float:
	return ceil(_ids.size() / 4.0) * PASSO + 8


func limitar(alvo: float) -> float:
	return clampf(alvo, 0.0, maxf(0.0, _altura_conteudo() - (BASE - TOPO)))


func atualizar(delta: float, segurando: bool) -> void:
	if segurando:
		return
	if absf(vel) > 1.0:
		rolagem = limitar(rolagem + vel * delta)
		vel *= pow(0.04, delta)                  # inércia: perde ~96% da velocidade por segundo
	else:
		vel = 0.0


func _rect_carta(k: int) -> Rect2:
	return Rect2(20 + (k % 4) * (CW + 8), TOPO + 6 + (k / 4) * PASSO - rolagem, CW, CH)


func tocar(p: Vector2) -> String:
	if p.y < TOPO or p.y > BASE:
		return ""
	for k in _ids.size():
		if _rect_carta(k).has_point(p):
			return _ids[k]
	return ""


func _tex(cid: String) -> Texture2D:
	return Carta.textura("carta_en" if Sessao.idioma == "en" else "carta", cid, "webp")


## Desenha só a parte da textura que cabe entre TOPO e BASE (a grade rola por baixo do cabeçalho).
func _recortado(ci: CanvasItem, tex: Texture2D, r: Rect2, y0: float, y1: float, mod := Color.WHITE) -> void:
	var vis := r.intersection(Rect2(r.position.x, y0, r.size.x, y1 - y0))
	if vis.size.y <= 0.0:
		return
	var sx := tex.get_width() / r.size.x
	var sy := tex.get_height() / r.size.y
	var src := Rect2((vis.position.x - r.position.x) * sx, (vis.position.y - r.position.y) * sy, vis.size.x * sx, vis.size.y * sy)
	ci.draw_texture_rect_region(tex, vis, src, mod)


func desenhar_grade(ci: CanvasItem) -> void:
	var d := aba
	var n_tok := 0
	for cid in _ids:
		if str(cid).begins_with("tok_"):
			n_tok += 1
	var possui := 0
	for cid in _ids:
		if not str(cid).begins_with("tok_") and Sessao.copias(cid) > 0:
			possui += 1
	var info := Sessao.t("POSSUI %d DE %d") % [possui, _ids.size() - n_tok]
	if n_tok > 0:
		info += "  -  " + Sessao.t("%d TOKENS") % n_tok
	PixelFonte.centrado(ci, Vector2(180, 86), info, Color(0.81, 0.88, 1.0, 0.8), 1)
	var pulso := 0.5 + 0.5 * sin(f.tempo * 3.0)
	for k in _ids.size():
		var r := _rect_carta(k)
		if r.end.y < TOPO or r.position.y > BASE:
			continue
		var cid: String = _ids[k]
		var tex := _tex(cid)
		var visivel := r.intersection(Rect2(0, TOPO, 360, BASE - TOPO))
		ci.draw_rect(visivel.grow(1), f.ESCURO)
		if tex:
			_recortado(ci, tex, r, TOPO, BASE)
		if not cid.begins_with("tok_"):
			var tem := Sessao.copias(cid)
			if tem == 0:
				ci.draw_rect(visivel, Color(0.02, 0.01, 0.03, 0.62))          # ainda não possui: escurecida com cadeado
				var cc := r.get_center()
				if cc.y > TOPO + 8 and cc.y < BASE - 8:
					ci.draw_rect(Rect2(cc + Vector2(-6, -2), Vector2(12, 10)), Color(0.75, 0.68, 0.55, 0.9))
					ci.draw_arc(cc + Vector2(0, -3), 4.0, PI, TAU, 10, Color(0.75, 0.68, 0.55, 0.9), 2.0)
			elif tem > 1 and r.end.y - 12 > TOPO and r.end.y < BASE:
				var sx := "x%d" % tem
				var wx := PixelFonte.largura(sx) + 6
				ci.draw_rect(Rect2(r.end.x - wx - 1, r.end.y - 11, wx, 10), Color(0.45, 0.32, 0.1, 0.95))
				PixelFonte.desenhar(ci, Vector2(r.end.x - wx + 2, r.end.y - 8), sx, f.OURO[0])
		if int(Sessao.perfil["foils"].get(cid, 0)) > 0 and r.position.y + 4 > TOPO and r.position.y + 14 < BASE:
			# selo FOIL arco-íris no canto de cima, à esquerda
			var sf := "FOIL"
			var wf := PixelFonte.largura(sf) + 6
			ci.draw_rect(Rect2(r.position.x + 2, r.position.y + 2, wf, 9), Color(0.08, 0.05, 0.1, 0.9))
			PixelFonte.desenhar(ci, r.position + Vector2(5, 4), sf, Color.from_hsv(fmod(f.tempo * 0.5, 1.0), 0.6, 1.0))
		if cid in Sessao.arte_revisao and r.position.y + 8 > TOPO and r.position.y + 8 < BASE:
			# selo "em revisão": faixinha no canto de cima, pulsando
			var s := Sessao.t("REVISÃO")
			var w := PixelFonte.largura(s) + 6
			var fx := Rect2(r.end.x - w - 2, r.position.y + 2, w, 9)
			ci.draw_rect(fx, Color(0.55, 0.12, 0.12, 0.85 + 0.15 * pulso))
			PixelFonte.desenhar(ci, fx.position + Vector2(3, 2), s, Color("#ffe0c0"))
	_barra_rolagem(ci, rolagem, _altura_conteudo(), TOPO, BASE)
	ci.draw_set_transform(Vector2.ZERO)


func _barra_rolagem(ci: CanvasItem, rol: float, total: float, y0: float, y1: float) -> void:
	var vis := y1 - y0
	if total <= vis:
		return
	var h := maxf(20.0, vis * vis / total)
	var y := y0 + (vis - h) * rol / (total - vis)
	ci.draw_rect(Rect2(352, y0, 2, vis), Color(1, 1, 1, 0.08))
	ci.draw_rect(Rect2(351, y, 4, h), Color(0.89, 0.72, 0.35, 0.7))


# ---------------- página de lore ----------------
func abrir_carta(cid: String) -> void:
	carta = cid
	rolagem_lore = 0.0
	vel = 0.0


func _entrada_lore() -> Dictionary:
	return Sessao.codex.get(carta, {})


func _nome(cid: String) -> String:
	if Sessao.db["cartas"].has(cid):
		return str(Sessao.db["cartas"][cid]["nome"])
	for nome in Sessao.tokens:
		if Sessao.tokens[nome]["id"] == cid:
			return str(Sessao.tokens[nome]["en"]) if Sessao.idioma == "en" else str(nome)
	return cid


func _linhas_lore() -> Array:
	var e := _entrada_lore()
	var en := Sessao.idioma == "en"
	var out: Array = []                     # [tipo, texto]
	out.append(["titulo", str(e.get("titulo_en" if en else "titulo_pt", ""))])
	for ln in Fonte57.quebrar(str(e.get("lore_en" if en else "lore_pt", "")), 318):
		out.append(["texto", ln])
	var cur := str(e.get("curiosidade_en" if en else "curiosidade_pt", ""))
	if cur != "":
		out.append(["espaco", ""])
		out.append(["cur_titulo", Sessao.t("CURIOSIDADE")])
		for ln in Fonte57.quebrar(cur, 300):
			out.append(["cur", ln])
	if carta in Sessao.arte_revisao:
		out.append(["espaco", ""])
		out.append(["revisao", Sessao.t("Arte em revisão: versão provisória desta Alpha.")])
	return out


func _altura_lore() -> float:
	return 200.0 + 30 + _linhas_lore().size() * 11 + 20


func limitar_lore(alvo: float) -> float:
	return clampf(alvo, 0.0, maxf(0.0, _altura_lore() - (BASE - 44)))


func atualizar_lore(delta: float, segurando: bool) -> void:
	if segurando:
		return
	if absf(vel) > 1.0:
		rolagem_lore = limitar_lore(rolagem_lore + vel * delta)
		vel *= pow(0.04, delta)
	else:
		vel = 0.0


func desenhar_lore(ci: CanvasItem) -> void:
	var y0 := 44.0
	var off := y0 - rolagem_lore
	var tex := _tex(carta)
	var foil := int(Sessao.perfil["foils"].get(carta, 0)) > 0 and Sessao.tem_foil(carta)
	if foil:                              # possui a versão foil: mostra a full-art com brilho
		tex = Carta.textura("carta_foil_en" if Sessao.idioma == "en" else "carta_foil", carta, "webp")
	var r := Rect2(116, off + 4, 128, 179)
	if tex:
		ci.draw_rect(r.intersection(Rect2(0, y0, 360, BASE - y0)).grow(2), f.ESCURO)
		_recortado(ci, tex, r, y0, BASE)
		if foil and r.position.y > y0 and r.end.y < BASE:
			f.bo.brilho_foil(ci, r)
	var y := off + 196.0
	var nome := PixelFonte.normalizar(_nome(carta))
	if y > y0 and y < BASE:
		PixelFonte.centrado(ci, Vector2(180, y), nome, f.OURO[0], 2, f.ESCURO)
	y += 16
	for item in _linhas_lore():
		var tipo: String = item[0]
		var s: String = item[1]
		if y > y0 + 2 and y < BASE - 8:
			match tipo:
				"titulo":
					var w := Fonte57.largura(s)
					Fonte57.desenhar(ci, Vector2(180 - w / 2.0, y), s, f.OURO[1], f.ESCURO)
				"texto":
					Fonte57.desenhar(ci, Vector2(21, y), s, f.CREME, f.ESCURO)
				"cur_titulo":
					ci.draw_rect(Rect2(16, y - 3, 328, 1), Color(0.89, 0.72, 0.35, 0.6))
					PixelFonte.desenhar(ci, Vector2(21, y + 2), s, f.OURO[0])
				"cur":
					ci.draw_rect(Rect2(16, y - 2, 3, 11), Color(0.89, 0.72, 0.35, 0.8))
					Fonte57.desenhar(ci, Vector2(28, y), s, Color("#ffe9b8"), f.ESCURO)
				"revisao":
					Fonte57.desenhar(ci, Vector2(21, y), s, Color("#ff9a8a"), f.ESCURO)
		y += 11 if tipo != "titulo" else 14
	_barra_rolagem(ci, rolagem_lore, _altura_lore(), y0, BASE)
