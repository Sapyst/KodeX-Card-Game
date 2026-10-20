class_name Carta
extends Node2D
## Carta de exemplo em pixel art (render nativo 360×640). Face 64×90 (5:7) + 2 px de espessura em cor de papel.
## A sombra aponta para longe da luz principal (passada pela mesa em `luz`).

const LARG := 64
const ALT := 90
const ESPESSURA := 2

# paleta
const PAPEL := Color("#e8dcc0")        # borda lateral (grossura da carta) — nunca preta
const PAPEL_ESC := Color("#b9a582")
const VERSO_FUNDO := Color("#2a2040")
const VERSO_MEIO := Color("#3b2d5e")
const OURO := Color("#e2b85a")
const OURO_ESC := Color("#9c7430")
const CONTORNO := Color("#3a2a24")     # contorno marrom escuro, não preto puro

var virada_para_cima := false
var levantada := 0.0                    # 0..1: altura da carta (sombra maior e mais longe)
var luz := Vector2(180, -60)            # posição global da luz principal
var empilhada := false                  # no monte: só a borda conta, sem sombra própria
var giro := 1.0                         # 1 → 0 → 1 ao virar (independente da escala, que pode estar animando)
var inclinacao := 0.0                   # cisalhamento ao arrastar (simula a carta tombando na direção do movimento)
var brilho := 0.0                       # 0..1: clarão branco por cima (golpe, destruição)
var bob := Vector2.ZERO                 # deslocamento leve de animação ociosa (respirar/flutuar), em px
var tipo := "entidade"                  # entidade | selo | rito
var atk := 0
var defe := 0
var dano := 0
var dono := 0                           # 0 = jogador, 1 = oponente
var id := ""
var nome := ""
var custo := 0
var keywords: Array = []
var texto := ""
var cultura := ""
var lendaria := false
var cansada := false                    # entrou neste turno (sem Ímpeto): não ataca
var atacou := false
var apagada := false                    # na mão, sem Fé para jogar
# ---- estado de regras (motor_efeitos.gd) ----
var dados: Dictionary = {}              # ficha da carta (cartas.json) ou do token
var dono_real := 0                      # dono original (mão/cemitério); `dono` = quem controla (lado do campo)
var atk_base := 0
var vida_base := 0
var buff_atk := 0
var buff_vida := 0
var temp_atk := 0
var temp_vida := 0
var aura_atk := 0
var aura_vida := 0
var rel_atk := 0
var rel_vida := 0
var aura_keywords: Array = []
var efeitos: Array = []
var silenciada := false
var congelada := false                  # não atacará no próximo turno do controlador
var sem_ataque := false                 # congelada neste turno
var ja_atacou := false                  # já atacou alguma vez (Furtivo some)
var destaque := 0                       # 1 = dá para jogar (mão, dourado) · 2 = pronta para atacar (campo, laranja)
var aura_arcoiris := false              # fortalecida em campo: brilho arco-íris no chão, por baixo da carta
var _t_aura := 0.0
var reliquia: Dictionary = {}           # {dados, nome, usos, portadora, dono}
var token := false
var em_campo := false
var roubada_temp := false
var turno_posto := -1                   # Selo: turno em que foi posto
var sem_renascer := false


var _fx: Node2D                          # camada sem luz da mesa (cores fiéis): efeito de Guarda


func _ready() -> void:
	_fx = Node2D.new()
	var mat := CanvasItemMaterial.new()
	mat.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	_fx.material = mat
	_fx.draw.connect(_desenhar_fx)
	add_child(_fx)


func _process(_d: float) -> void:
	queue_redraw()
	if _fx:
		_fx.queue_redraw()


func _desenhar_fx() -> void:
	if em_campo and virada_para_cima and tipo == "entidade" and tem("guarda"):
		_fx.draw_set_transform_matrix(Transform2D(0.0, Vector2(maxf(absf(giro), 0.02), 1.0), inclinacao, bob.round()))
		_guarda(-LARG / 2, -ALT / 2)


func _draw() -> void:
	var x0 := -LARG / 2
	var y0 := -ALT / 2
	if not empilhada:
		_sombra(x0, y0)
	if aura_arcoiris:
		_aura(x0, y0)
	draw_set_transform_matrix(Transform2D(0.0, Vector2(maxf(absf(giro), 0.02), 1.0), inclinacao, bob.round()))
	# espessura: faixa de papel aparecendo embaixo e à direita (luz vem de cima)
	draw_rect(Rect2(x0 + 1, y0 + ALT, LARG - 1, ESPESSURA), PAPEL)
	draw_rect(Rect2(x0 + 1, y0 + ALT + ESPESSURA - 1, LARG - 1, 1), PAPEL_ESC)
	draw_rect(Rect2(x0 + LARG, y0 + 1, 1, ALT + ESPESSURA - 1), PAPEL_ESC)
	if virada_para_cima:
		_frente(x0, y0)
	else:
		_verso(x0, y0)
	if destaque > 0:
		var tt := Time.get_ticks_msec() / 1000.0
		var pulso := 0.55 + 0.45 * sin(tt * TAU / 1.1)
		var cor := Color(1.0, 0.85, 0.4) if destaque == 1 else Color(1.0, 0.5, 0.2)
		var r := Rect2(x0, y0, LARG, ALT + ESPESSURA)
		draw_rect(r.grow(1), Color(cor.lightened(0.3), 0.6 + 0.4 * pulso), false, 2.0)
		draw_rect(r.grow(3), Color(cor, 0.55 * pulso), false, 2.0)
		draw_rect(r.grow(5), Color(cor, 0.25 * pulso), false, 2.0)
	var dormindo := cansada and not tem("impeto")
	if virada_para_cima and (dormindo or atacou):
		draw_rect(Rect2(x0, y0, LARG, ALT), Color(0.05, 0.03, 0.1, 0.35))
		if dormindo:
			PixelFonte.desenhar(self, Vector2(x0 + LARG - 14, y0 + 14), "Z", Color("#cfe0ff"))
			PixelFonte.desenhar(self, Vector2(x0 + LARG - 9, y0 + 10), "Z", Color("#cfe0ff"))
	if virada_para_cima and em_campo:
		if congelada or sem_ataque:
			draw_rect(Rect2(x0, y0, LARG, ALT), Color(0.35, 0.6, 1.0, 0.28))
			draw_rect(Rect2(x0, y0, LARG, ALT), Color("#9ad0ff"), false, 1.0)
		if silenciada:
			draw_rect(Rect2(x0 + 8, y0 + 40, 48, 9), Color("#2a2830"))
			PixelFonte.centrado(self, Vector2(x0 + LARG / 2, y0 + 45), Sessao.t("MUDO"), Color("#b8b4c0"))
	if not reliquia.is_empty():
		_faixa_reliquia(x0, y0)
	if apagada:
		draw_rect(Rect2(x0, y0, LARG, ALT), Color(0.05, 0.03, 0.08, 0.5))
	if brilho > 0.0:
		draw_rect(Rect2(x0, y0, LARG, ALT), Color(1, 1, 1, brilho))


func _sombra(x0: int, y0: int) -> void:
	var dir := (global_position - luz).normalized()
	var dist := 2.0 + 9.0 * levantada
	var off := (dir * dist).rotated(-global_rotation) / maxf(absf(global_scale.y), 0.01)
	var a := 0.32 - 0.12 * levantada
	draw_rect(Rect2(Vector2(x0, y0) + off.round() + Vector2(-1, 0), Vector2(LARG + 2, ALT + ESPESSURA + 1)), Color(0.05, 0.02, 0.06, a))


func _moldura(x0: int, y0: int, fundo: Color) -> void:
	draw_rect(Rect2(x0, y0, LARG, ALT), CONTORNO)
	draw_rect(Rect2(x0 + 1, y0 + 1, LARG - 2, ALT - 2), fundo)


func _verso(x0: int, y0: int) -> void:
	_moldura(x0, y0, VERSO_FUNDO)
	# filete dourado com cantos recortados
	draw_rect(Rect2(x0 + 4, y0 + 3, LARG - 8, 1), OURO)
	draw_rect(Rect2(x0 + 4, y0 + ALT - 4, LARG - 8, 1), OURO_ESC)
	draw_rect(Rect2(x0 + 3, y0 + 4, 1, ALT - 8), OURO)
	draw_rect(Rect2(x0 + LARG - 4, y0 + 4, 1, ALT - 8), OURO_ESC)
	# padrão de losangos pequenos
	for yy in range(y0 + 8, y0 + ALT - 8, 6):
		for xx in range(x0 + 8 + (3 if ((yy - y0) / 6) % 2 else 0), x0 + LARG - 8, 6):
			draw_rect(Rect2(xx, yy, 1, 1), VERSO_MEIO)
	# losango central
	var cx := x0 + LARG / 2
	var cy := y0 + ALT / 2
	for i in range(-14, 15):
		var w := 9 - absi(i) * 9 / 14
		draw_rect(Rect2(cx - w, cy + i, w * 2 + 1, 1), VERSO_MEIO)
		draw_rect(Rect2(cx - w, cy + i, 1, 1), OURO)
		draw_rect(Rect2(cx + w, cy + i, 1, 1), OURO_ESC)
	draw_rect(Rect2(cx - 2, cy - 2, 5, 5), OURO)
	draw_rect(Rect2(cx - 1, cy - 1, 3, 3), VERSO_FUNDO)
	draw_rect(Rect2(cx, cy, 1, 1), Color("#fff2c8"))


const COR_CULTURA := {"indigena": Color("#9a4a26"), "cristianismo": Color("#36508c"), "taoismo": Color("#1f6a5a"),
	"hinduismo": Color("#b8661c"), "bruxaria": Color("#4e2c6c"), "alta_magia": Color("#2a2430"), "abismo": Color("#3a2a18")}
static var _texturas: Dictionary = {}


## Textura do jogo (assets/arte: 48×64 na mesa; assets/carta: carta inteira no zoom). Carrega uma vez só.
static func textura(pasta: String, cid: String, ext: String) -> Texture2D:
	var k := pasta + cid
	if not _texturas.has(k):
		var caminho := "res://assets/%s/%s.%s" % [pasta, cid, ext]
		_texturas[k] = load(caminho) if ResourceLoader.exists(caminho) else null
	return _texturas[k]


func _frente(x0: int, y0: int) -> void:
	var base: Color = COR_CULTURA.get(cultura, Color("#a9a7ad"))
	_moldura(x0, y0, base)
	draw_rect(Rect2(x0 + 1, y0 + 1, LARG - 2, 1), base.lightened(0.35))               # luz no topo
	var janela := Rect2(x0 + 8, y0 + 13, 48, 64)                                        # janela da arte, 3:4 exato
	draw_rect(janela.grow(1), Color("#140c10"))
	var tex := textura("arte", id, "png") if id != "" else null
	if tex:
		draw_texture_rect(tex, janela, false)
	else:
		draw_rect(janela, Color("#6f6d76"))
	draw_rect(Rect2(x0 + 12, y0 + 3, LARG - 14, 8), Color("#d8d6dc"))                  # pílula do nome
	if nome != "":
		var n := PixelFonte.normalizar(nome)
		if n.length() > 12:
			n = n.substr(0, 12)
		PixelFonte.desenhar(self, Vector2(x0 + 14, y0 + 5), n, Color("#2a2028"))
	_selo_num(Rect2(x0 + 1, y0 + 1, 0, 14), str(custo), Color("#2f4f9a"), Color.WHITE)   # custo (dígitos 2×)
	if lendaria:
		draw_rect(Rect2(x0 + 1, y0 + 1, LARG - 2, 1), Color("#ffe39a"))
		draw_rect(Rect2(x0 + 1, y0 + ALT - 2, LARG - 2, 1), Color("#ffe39a"))
	if tem("guarda"):
		draw_rect(Rect2(x0, y0, LARG, ALT), Color("#e2b85a"), false, 2.0)
	var kw := ""
	for k in keywords + aura_keywords.filter(func(k2: String) -> bool: return not (k2 in keywords)):
		kw += ({"guarda": "G", "impeto": "R", "furtivo": "S", "renascer": "B"} if Sessao.idioma == "en" else {"guarda": "G", "impeto": "I", "furtivo": "F", "renascer": "R"}).get(k, "")
	if kw != "":
		draw_rect(Rect2(x0 + 8, y0 + 69, kw.length() * 4 + 3, 8), Color("#2a2028"))
		PixelFonte.desenhar(self, Vector2(x0 + 10, y0 + 71), kw, Color("#ffe39a"))
	match tipo:
		"entidade":
			var base_atk: int = int(dados["atk"]) if dados.get("atk") != null else atk
			var base_def: int = int(dados["vida"]) if dados.get("vida") != null else defe
			var cor_atk := Color("#ffe39a") if atk > base_atk else (Color("#e0a8ff") if atk < base_atk else Color("#ffe0b0"))
			_selo_num(Rect2(x0 + 1, y0 + ALT - 15, 0, 14), str(atk), Color("#8a2a1a"), cor_atk)
			var cor_def := Color("#ffb0b0") if dano > 0 else (Color("#ffe39a") if defe > base_def else (Color("#e0a8ff") if defe < base_def else Color("#e0ecff")))
			_selo_num(Rect2(x0 + LARG - 1, y0 + ALT - 15, 0, 14), str(maxi(defe - dano, 0)), Color("#1f3f7a"), cor_def, true)
		"selo":
			PixelFonte.centrado(self, Vector2(x0 + LARG / 2, y0 + ALT - 7), Sessao.t("SELO"), Color("#c8b0f0"))
		"rito":
			PixelFonte.centrado(self, Vector2(x0 + LARG / 2, y0 + ALT - 7), Sessao.t("RITO"), Color("#a8e0b8"))
		"reliquia":
			PixelFonte.centrado(self, Vector2(x0 + LARG / 2, y0 + ALT - 7), Sessao.t("RELÍQUIA"), Color("#ffe39a"))


## Vira no ar: escala X → 0 (troca a face) → volta, levantando junto.
func virar(duracao: float = 0.3) -> void:
	var t := create_tween()
	t.tween_property(self, "giro", 0.0, duracao / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	t.tween_callback(func() -> void: virada_para_cima = not virada_para_cima)
	t.tween_property(self, "giro", 1.0, duracao / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await t.finished


func vida() -> int:
	return defe - dano


## Contém o ponto (coordenadas globais)? Considera rotação e escala.
func contem(p_global: Vector2) -> bool:
	var l := to_local(p_global)
	return absf(l.x) <= LARG / 2.0 + 2 and absf(l.y) <= ALT / 2.0 + 2


func cores_estilhaco() -> Array:
	if not virada_para_cima:
		return [VERSO_FUNDO, VERSO_MEIO, OURO, CONTORNO, PAPEL]
	return [Color("#a9a7ad"), Color("#6f6d76"), Color("#85838c"), Color("#d8d6dc"), PAPEL, CONTORNO]


func definir(d: Dictionary, quem: int) -> void:
	id = d["id"]; nome = d["nome"]; tipo = d["tipo"]; custo = int(d["custo"])
	atk = int(d["atk"]) if d["atk"] != null else 0
	defe = int(d["vida"]) if d["vida"] != null else 0
	keywords = d.get("keywords", []).duplicate()
	texto = d.get("texto", ""); cultura = d.get("cultura", ""); lendaria = d.get("lendaria", false)
	dono = quem; dano = 0
	dados = d
	dono_real = quem
	token = bool(d.get("token", false))
	resetar()


func tem(kw: String) -> bool:
	return kw in keywords or kw in aura_keywords


## Furtivo: não pode ser alvo de efeitos inimigos até atacar.
func protegida() -> bool:
	return tem("furtivo") and not ja_atacou


## ATK/Def mostrados = base + buffs permanentes + temporários + aura + Relíquia (Def = Vida máxima; vida() = Def − dano).
func sincronizar() -> void:
	atk = maxi(0, atk_base + buff_atk + temp_atk + aura_atk + rel_atk)
	defe = vida_base + buff_vida + temp_vida + aura_vida + rel_vida


func limpar_stats() -> void:
	buff_atk = 0; buff_vida = 0; temp_atk = 0; temp_vida = 0; rel_atk = 0; rel_vida = 0
	dano = 0
	sincronizar()


## Volta ao estado impresso (ao entrar na mão: Renascer, bounce, revive). Renascer usado não volta.
func resetar() -> void:
	if dados.is_empty():
		return
	atk_base = int(dados["atk"]) if dados.get("atk") != null else 0
	vida_base = int(dados["vida"]) if dados.get("vida") != null else 0
	keywords = (dados.get("keywords", []) as Array).duplicate()
	if sem_renascer:
		keywords.erase("renascer")
	efeitos = dados.get("efeitos", [])
	buff_atk = 0; buff_vida = 0; temp_atk = 0; temp_vida = 0; aura_atk = 0; aura_vida = 0; rel_atk = 0; rel_vida = 0
	aura_keywords = []
	dano = 0
	silenciada = false; congelada = false; sem_ataque = false; ja_atacou = false
	reliquia = {}
	roubada_temp = false
	cansada = false; atacou = false
	dono = dono_real
	sincronizar()


## Relíquia equipada: faixa dourada logo abaixo da carta, com o nome (e Usos, se tiver).
func _faixa_reliquia(x0: int, y0: int) -> void:
	var n := PixelFonte.normalizar(str(reliquia.get("nome", "")))
	if n.length() > 13:
		n = n.substr(0, 13)
	if reliquia.get("usos") != null:
		n += " " + str(reliquia["usos"])
	var r := Rect2(x0 + 2, y0 + ALT + ESPESSURA, LARG - 4, 8)
	draw_rect(r.grow(1), Color("#140c10"))
	draw_rect(r, Color("#5a3a1a"))
	draw_rect(Rect2(r.position, Vector2(r.size.x, 1)), Color("#ffe39a"))
	PixelFonte.centrado(self, r.get_center() + Vector2(0, 1), n, Color("#ffe39a"))


## Selo com número em dígitos 2× (6×10 px cada) e contorno escuro. r.position = canto (esquerdo, ou direito se `direita`).
func _selo_num(r: Rect2, s: String, fundo: Color, cor: Color, direita := false) -> void:
	var w := PixelFonte.largura(s, 2) + 6
	var x := r.position.x - w if direita else r.position.x
	var caixa := Rect2(x, r.position.y, w, r.size.y)
	draw_rect(caixa.grow(1), Color("#140c10"))
	draw_rect(caixa, fundo)
	draw_rect(Rect2(caixa.position, Vector2(w, 1)), fundo.lightened(0.4))
	PixelFonte.desenhar(self, caixa.position + Vector2(3, 2), s, cor, 2)


## Aura arco-íris no chão (a carta é desenhada por cima, então só a borda aparece): 6 contornos que crescem
## 1→9 px além da carta, matiz girando 0,35 volta/s, alfa pulsando 0,8 s, e 4 faíscas que orbitam.
func _aura(x0: int, y0: int) -> void:
	_t_aura += get_process_delta_time()
	var pulso := 0.8 + 0.2 * sin(_t_aura * TAU / 0.8)
	var esp := 2.0 + 1.5 * sin(_t_aura * TAU / 1.6)          # a aura "respira" 2–3,5 px
	# brilho difuso: 5 faixas de 3 px, de fora (fraca) para dentro (forte); cada lado com um matiz diferente
	for i in range(5, 0, -1):
		var g := esp + i * 3.0
		var al := (0.16 + 0.12 * (5 - i)) * pulso
		var r := Rect2(x0 - g, y0 - g, LARG + 2 * g, ALT + ESPESSURA + 2 * g)
		var h0 := fmod(_t_aura * 0.4 + i * 0.05, 1.0)
		draw_rect(Rect2(r.position, Vector2(r.size.x, 3)), Color.from_hsv(h0, 0.9, 1.0, al))
		draw_rect(Rect2(Vector2(r.end.x - 3, r.position.y), Vector2(3, r.size.y)), Color.from_hsv(fmod(h0 + 0.25, 1.0), 0.9, 1.0, al))
		draw_rect(Rect2(Vector2(r.position.x, r.end.y - 3), Vector2(r.size.x, 3)), Color.from_hsv(fmod(h0 + 0.5, 1.0), 0.9, 1.0, al))
		draw_rect(Rect2(r.position, Vector2(3, r.size.y)), Color.from_hsv(fmod(h0 + 0.75, 1.0), 0.9, 1.0, al))
	var per := 2.0 * (LARG + ALT) + 40.0
	for k in 6:
		var d := fmod(_t_aura * 80.0 + k * per / 6.0, per)
		var q := _no_contorno(x0 - esp - 4, y0 - esp - 4, LARG + 2 * esp + 8, ALT + ESPESSURA + 2 * esp + 8, d)
		draw_rect(Rect2(q.round() - Vector2.ONE, Vector2(3, 3)), Color.from_hsv(fmod(_t_aura * 0.4 + k / 6.0, 1.0), 0.5, 1.0, 0.95))


func _no_contorno(x: float, y: float, w: float, h: float, d: float) -> Vector2:
	if d < w: return Vector2(x + d, y)
	d -= w
	if d < h: return Vector2(x + w, y + d)
	d -= h
	if d < w: return Vector2(x + w - d, y + h)
	d -= w
	return Vector2(x, y + h - minf(d, h))


const ESCUDO := ["0111110", "1222221", "1233321", "1233321", "1223221", "0122210", "0012100", "0001000"]


## Guarda: carta mais clara (véu azul 12%), contorno azul-aço de 2 px, um reflexo de escudo atravessando a carta
## a cada 1,8 s e um escudo pixel 7×8 (×1) preso no topo, no meio.
func _guarda(x0: int, y0: int) -> void:
	var tt := Time.get_ticks_msec() / 1000.0
	var r := Rect2(x0, y0, LARG, ALT)
	_fx.draw_rect(r, Color(0.75, 0.88, 1.0, 0.2))
	var fase := fmod(tt / 1.8, 1.0)
	var bx := x0 - 8 + fase * (LARG + 16)
	for k in 3:                                   # reflexo inclinado: 3 degraus de 2 px de altura cada terço
		var xx := bx + k * 3
		var faixa := Rect2(xx, y0 + k * ALT / 3.0, 4, ALT / 3.0).intersection(r)
		if faixa.size.x > 0:
			_fx.draw_rect(faixa, Color(1, 1, 1, 0.22))
	var pulso := 0.7 + 0.3 * sin(tt * TAU / 1.4)
	_fx.draw_rect(r.grow(1), Color(0.7, 0.85, 1.0, pulso), false, 2.0)
	_fx.draw_rect(r.grow(3), Color(0.45, 0.65, 1.0, 0.55 * pulso), false, 2.0)
	_fx.draw_rect(r.grow(5), Color(0.45, 0.65, 1.0, 0.25 * pulso), false, 2.0)
	var cores := [Color(0, 0, 0, 0), Color("#1b2333"), Color("#c9d6ea"), Color("#4f7fd0")]
	var ox := x0 + LARG / 2 - 7                    # escudo 2× (14×16 px) centrado sobre a borda de cima
	var oy := y0 - 9
	for yy in ESCUDO.size():
		for xx in 7:
			var v := int(ESCUDO[yy][xx])
			if v > 0:
				_fx.draw_rect(Rect2(ox + xx * 2, oy + yy * 2, 2, 2), cores[v])
