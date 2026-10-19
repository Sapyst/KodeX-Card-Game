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


func _process(_d: float) -> void:
	queue_redraw()


func _draw() -> void:
	var x0 := -LARG / 2
	var y0 := -ALT / 2
	if not empilhada:
		_sombra(x0, y0)
	draw_set_transform_matrix(Transform2D(0.0, Vector2(maxf(absf(giro), 0.02), 1.0), inclinacao, bob.round()))
	# espessura: faixa de papel aparecendo embaixo e à direita (luz vem de cima)
	draw_rect(Rect2(x0 + 1, y0 + ALT, LARG - 1, ESPESSURA), PAPEL)
	draw_rect(Rect2(x0 + 1, y0 + ALT + ESPESSURA - 1, LARG - 1, 1), PAPEL_ESC)
	draw_rect(Rect2(x0 + LARG, y0 + 1, 1, ALT + ESPESSURA - 1), PAPEL_ESC)
	if virada_para_cima:
		_frente(x0, y0)
	else:
		_verso(x0, y0)
	if virada_para_cima and (cansada or atacou):
		draw_rect(Rect2(x0, y0, LARG, ALT), Color(0.05, 0.03, 0.1, 0.35))
		if cansada:
			PixelFonte.desenhar(self, Vector2(x0 + LARG - 14, y0 + 14), "Z", Color("#cfe0ff"))
			PixelFonte.desenhar(self, Vector2(x0 + LARG - 9, y0 + 10), "Z", Color("#cfe0ff"))
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
	draw_rect(Rect2(x0 + 2, y0 + 2, 9, 10), Color("#2a3a7a"))                          # custo
	draw_rect(Rect2(x0 + 3, y0 + 3, 7, 8), Color("#4f6fb0"))
	PixelFonte.centrado(self, Vector2(x0 + 7, y0 + 7), str(custo), Color.WHITE)
	if lendaria:
		draw_rect(Rect2(x0 + 1, y0 + 1, LARG - 2, 1), Color("#ffe39a"))
		draw_rect(Rect2(x0 + 1, y0 + ALT - 2, LARG - 2, 1), Color("#ffe39a"))
	if "guarda" in keywords:
		draw_rect(Rect2(x0, y0, LARG, ALT), Color("#e2b85a"), false, 2.0)
	var kw := ""
	for k in keywords:
		kw += {"guarda": "G", "impeto": "I", "furtivo": "F", "renascer": "R"}.get(k, "")
	if kw != "":
		draw_rect(Rect2(x0 + 8, y0 + 69, kw.length() * 4 + 3, 8), Color("#2a2028"))
		PixelFonte.desenhar(self, Vector2(x0 + 10, y0 + 71), kw, Color("#ffe39a"))
	match tipo:
		"entidade":
			draw_rect(Rect2(x0 + 2, y0 + ALT - 12, 16, 10), Color("#5a2a2a"))
			PixelFonte.centrado(self, Vector2(x0 + 10, y0 + ALT - 7), str(atk), Color("#ffd9a0"))
			draw_rect(Rect2(x0 + LARG - 18, y0 + ALT - 12, 16, 10), Color("#2a3a5a"))
			var cor_def := Color("#ff8a8a") if dano > 0 else Color("#cfe0ff")
			PixelFonte.centrado(self, Vector2(x0 + LARG - 10, y0 + ALT - 7), str(maxi(defe - dano, 0)), cor_def)
		"selo":
			PixelFonte.centrado(self, Vector2(x0 + LARG / 2, y0 + ALT - 7), "SELO", Color("#c8b0f0"))
		"rito":
			PixelFonte.centrado(self, Vector2(x0 + LARG / 2, y0 + ALT - 7), "RITO", Color("#a8e0b8"))


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
