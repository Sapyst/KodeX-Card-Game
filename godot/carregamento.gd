extends Node2D
## Tela de carregamento (primeira cena): 5 cartas sorteadas giram em órbita, virando (verso ↔ frente), enquanto o
## menu carrega numa thread. O sorteio nunca repete cartas entre si nem as da última abertura (user://config.cfg).
## Fica no mínimo 1,6 s para a animação ser vista, depois esmaece 0,3 s e entra no menu.

const PROXIMA := "res://fluxo.tscn"
const N := 5
const MINIMO := 1.6

var cartas: Array = []            # [{tex, fase}]
var t := 0.0
var saindo := -1.0
var progresso := 0.0
var _pronto: PackedScene = null


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var cfg := ConfigFile.new()
	cfg.load(Sessao.CONFIG)
	var ultimas: Array = cfg.get_value("carregamento", "ultimas", [])
	var pool: Array = []
	for cid in Sessao.db["cartas"]:
		if not cid in ultimas and ResourceLoader.exists("res://assets/carta/%s.webp" % cid):
			pool.append(cid)
	pool.shuffle()
	var escolhidas: Array = pool.slice(0, N)
	cfg.set_value("carregamento", "ultimas", escolhidas)
	cfg.save(Sessao.CONFIG)
	var pasta := "carta_en" if Sessao.idioma == "en" else "carta"
	for k in escolhidas.size():
		cartas.append({"tex": Carta.textura(pasta, escolhidas[k], "webp"), "fase": TAU * k / N})
	ResourceLoader.load_threaded_request(PROXIMA)


func _process(delta: float) -> void:
	t += delta
	if _pronto == null:
		var prog: Array = []
		var st := ResourceLoader.load_threaded_get_status(PROXIMA, prog)
		if not prog.is_empty():
			progresso = maxf(progresso, float(prog[0]))
		if st == ResourceLoader.THREAD_LOAD_LOADED:
			_pronto = ResourceLoader.load_threaded_get(PROXIMA)
			progresso = 1.0
	if _pronto != null and t >= MINIMO and saindo < 0.0:
		saindo = 0.0
	if saindo >= 0.0:
		saindo += delta
		if saindo >= 0.3:
			get_tree().change_scene_to_packed(_pronto)
			return
	queue_redraw()


func _draw() -> void:
	var vs := get_viewport_rect().size
	var c := vs / 2.0 + Vector2(0, -20)
	draw_rect(Rect2(Vector2.ZERO, vs), Color("#0d0b12"))
	var fade := 1.0 - clampf(saindo / 0.3, 0, 1) if saindo >= 0.0 else minf(1.0, t / 0.25)
	# círculos de runas girando devagar atrás da órbita
	for i in 3:
		var raio := 70.0 + i * 34.0
		draw_arc(c, raio, t * (0.4 if i % 2 == 0 else -0.3), t * (0.4 if i % 2 == 0 else -0.3) + TAU * 0.85, 48,
			Color(0.89, 0.72, 0.35, 0.12 * fade), 1.0)
	# órbita: ordena por profundidade (as de trás primeiro)
	var itens: Array = []
	for k in cartas.size():
		var a: float = t * 1.1 + cartas[k]["fase"]
		itens.append([sin(a), k, a])
	itens.sort_custom(func(x: Array, y: Array) -> bool: return x[0] < y[0])
	for it in itens:
		var prof: float = it[0]                       # -1 (atrás) .. 1 (frente)
		var a: float = it[2]
		var k: int = it[1]
		var p := c + Vector2(cos(a) * 100.0, prof * 26.0)
		var esc := 0.75 + 0.25 * (prof + 1.0) / 2.0
		var giro := cos(t * 2.4 + k * 1.3)            # vira sobre o próprio eixo
		var tam := Vector2(66, 92) * esc
		var w := maxf(2.0, tam.x * absf(giro))
		var r := Rect2(p - Vector2(w, tam.y) / 2, Vector2(w, tam.y))
		var luz := 0.55 + 0.45 * (prof + 1.0) / 2.0
		draw_rect(Rect2(r.position + Vector2(2, 4), r.size), Color(0, 0, 0, 0.4 * fade))
		if giro > 0.0 and cartas[k]["tex"] != null:
			draw_texture_rect(cartas[k]["tex"], r, false, Color(luz, luz, luz, fade))
		else:                                          # verso
			draw_rect(r, Color(0.16 * luz, 0.1 * luz, 0.2 * luz, fade))
			draw_rect(r.grow(-3), Color(0.89, 0.72, 0.35, 0.7 * fade * luz), false, 1.0)
			var q := r.get_center()
			var s := minf(6.0, w / 4.0)
			draw_colored_polygon(PackedVector2Array([q + Vector2(0, -s), q + Vector2(s, 0), q + Vector2(0, s), q + Vector2(-s, 0)]),
				Color(1.0, 0.85, 0.4, fade * luz))
	# texto e barra de progresso
	var pontos := ".".repeat(int(t * 3.0) % 4)
	var txt := Sessao.t("CARREGANDO") + pontos
	PixelFonte.desenhar(self, Vector2(c.x - PixelFonte.largura(Sessao.t("CARREGANDO"), 2) / 2.0, c.y + 96), txt, Color(1.0, 0.89, 0.6, fade), 2, Color("#140c10"))
	var barra := Rect2(c.x - 70, c.y + 116, 140, 3)
	draw_rect(barra, Color(1, 1, 1, 0.08 * fade))
	var vis := clampf(minf(progresso, t / MINIMO), 0, 1)
	draw_rect(Rect2(barra.position, Vector2(barra.size.x * vis, barra.size.y)), Color(0.89, 0.72, 0.35, fade))
