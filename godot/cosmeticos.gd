class_name Cosmeticos
extends RefCounted
## Cosméticos à venda por Koins. Por enquanto: versos (fundos) de carta. Pixel art 128×180 em assets/versos/
## (arte/versos: 4 feitos por código, 3 de IA local; os 2 lendários de IA ganham efeitos animados desenhados por cima,
## os mesmos de arte/versos/animar_lendarios.py: varredura, brilhos, anel, aura e partículas subindo).
## Preços: código 150 · IA 300 · lendário 800 Koins (com 10/dia e 100/sexta, ~170 por semana).

const VERSOS := [
	{"id": "classico", "nome": ["Clássico", "Classic", "Clásico"], "preco": 0},
	{"id": "codice", "nome": ["Códice", "Codex", "Códice"], "preco": 150, "arq": "proc_codice"},
	{"id": "mandala", "nome": ["Mandala", "Mandala", "Mandala"], "preco": 150, "arq": "proc_mandala"},
	{"id": "constelacao", "nome": ["Constelação", "Constellation", "Constelación"], "preco": 150, "arq": "proc_constelacao"},
	{"id": "azulejo", "nome": ["Azulejo", "Azulejo", "Azulejo"], "preco": 150, "arq": "proc_azulejo"},
	{"id": "arvore", "nome": ["Árvore da Vida", "Tree of Life", "Árbol de la Vida"], "preco": 300, "arq": "ia_arvore_0"},
	{"id": "vitral", "nome": ["Vitral", "Stained Glass", "Vitral"], "preco": 300, "arq": "ia_vitral_0"},
	{"id": "dragao", "nome": ["Dragão de Jade", "Jade Dragon", "Dragón de Jade"], "preco": 300, "arq": "ia_dragao_0"},
	{"id": "ouroboros", "nome": ["Ouroboros", "Ouroboros", "Ouroboros"], "preco": 800, "arq": "ia_ouroboros_1", "lendario": true,
		"fx": {"varredura": true, "brilhos": true, "aura": Vector2(62.6, 85.8), "anel": [39.0, Vector2(62.6, 85.8)]}},
	{"id": "lotus", "nome": ["Lótus Cósmica", "Cosmic Lotus", "Loto Cósmico"], "preco": 800, "arq": "ia_lotus_0", "lendario": true,
		"fx": {"varredura": true, "brilhos": true, "aura": Vector2(63.5, 89.5), "motes": true}},
]
const W := 128.0
const H := 180.0

static var _tex := {}
static var _pos := {}                      # posições fixas (sementes) de faíscas e partículas por verso


static func item(id: String) -> Dictionary:
	for v in VERSOS:
		if v["id"] == id:
			return v
	return VERSOS[0]


static func nome(id: String) -> String:
	return Sessao.par(item(id)["nome"])


static func textura(id: String) -> Texture2D:
	if not _tex.has(id):
		var it := item(id)
		var cam := "res://assets/versos/%s.png" % str(it.get("arq", ""))
		_tex[id] = load(cam) if it.has("arq") and ResourceLoader.exists(cam) else null
	return _tex[id]


## Desenha o verso `id` no retângulo r (qualquer tamanho; os efeitos escalam junto). fx = animar (cartas empilhadas
## no deck passam false para não pesar). Devolve false para o Clássico (quem chama desenha o verso padrão).
static func desenhar(ci: CanvasItem, id: String, r: Rect2, fx := true, alfa := 1.0) -> bool:
	var tex := textura(id)
	if tex == null:
		return false
	ci.draw_texture_rect(tex, r, false, Color(1, 1, 1, alfa))
	var it := item(id)
	if fx and it.has("fx"):
		_efeitos(ci, id, it["fx"], r, Time.get_ticks_msec() / 1000.0, alfa)
	return true


static func _efeitos(ci: CanvasItem, id: String, fx: Dictionary, r: Rect2, t: float, alfa: float) -> void:
	var s := r.size.x / W
	var u := fmod(t / 2.0, 1.0)                                    # loop de 2 s
	if not _pos.has(id):
		var rng := RandomNumberGenerator.new()
		rng.seed = 7
		var br: Array = []
		for k in 12:
			br.append([Vector2(rng.randi_range(10, 118), rng.randi_range(12, 168)), rng.randf()])
		var mo: Array = []
		for k in 22:
			mo.append([rng.randi_range(14, 114), rng.randf(), [1, 1, 2][rng.randi_range(0, 2)]])
		_pos[id] = {"brilhos": br, "motes": mo}
	var p: Dictionary = _pos[id]
	var P := func(v: Vector2) -> Vector2: return r.position + v * s
	if fx.has("aura"):
		var c: Vector2 = P.call(fx["aura"])
		var puls := 0.5 + 0.5 * sin(u * TAU)
		for k in 6:
			ci.draw_circle(c, (40.0 + 6.0 * puls - k * 6.0) * s, Color(1.0, 0.9, 0.67, (0.035 + 0.02 * puls) * alfa))
	if fx.get("varredura", false):
		var pos := -60.0 + u * (W + H + 120.0)                     # faixa x + 0,6·y = pos, largura 18
		var faixa := PackedVector2Array([Vector2(pos - 9, 0), Vector2(pos + 9, 0), Vector2(pos + 9 - 0.6 * H, H), Vector2(pos - 9 - 0.6 * H, H)])
		var caixa := PackedVector2Array([Vector2.ZERO, Vector2(W, 0), Vector2(W, H), Vector2(0, H)])
		for poli in Geometry2D.intersect_polygons(faixa, caixa):
			var pts := PackedVector2Array()
			for q in poli:
				pts.append(P.call(q))
			ci.draw_colored_polygon(pts, Color(1.0, 0.97, 0.86, 0.16 * alfa))
	if fx.has("anel"):
		var raio: float = fx["anel"][0]
		var c2: Vector2 = fx["anel"][1]
		for k in 10:
			var ang := u * TAU - k * 0.07
			var q := c2 + Vector2(cos(ang), sin(ang)) * raio
			ci.draw_rect(Rect2(P.call(q) - Vector2(s, s) * 0.5, Vector2(s, s) * (1.5 if k == 0 else 1.0)), Color(1.0, 0.98, 0.82, (1.0 - k / 10.0) * 0.9 * alfa))
	if fx.get("brilhos", false):
		for b in p["brilhos"]:
			var v := maxf(0.0, sin((u + float(b[1])) * TAU * 2.0))
			if v > 0.05:
				var c3: Vector2 = P.call(b[0])
				var tam := (1.0 + v * 2.5) * s
				ci.draw_rect(Rect2(c3 - Vector2(tam, s * 0.5), Vector2(tam * 2, s)), Color(1.0, 0.9, 0.6, v * alfa))
				ci.draw_rect(Rect2(c3 - Vector2(s * 0.5, tam), Vector2(s, tam * 2)), Color(1.0, 0.9, 0.6, v * alfa))
				ci.draw_rect(Rect2(c3 - Vector2(s, s) * 0.5, Vector2(s, s)), Color(1, 1, 0.92, v * alfa))
	if fx.get("motes", false):
		for m in p["motes"]:
			var v2 := fmod(u * float(m[2]) + float(m[1]), 1.0)
			var q2 := Vector2(float(m[0]) + sin(v2 * TAU * 2.0 + float(m[1]) * 9.0) * 3.0, H - 8.0 - v2 * (H - 16.0))
			ci.draw_rect(Rect2(P.call(q2), Vector2(s, s)), Color(0.9, 0.78, 1.0, sin(v2 * PI) * 0.85 * alfa))
