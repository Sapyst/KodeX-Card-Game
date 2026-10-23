class_name Moldura
extends RefCounted
## Moldura de perfil (arte/molduras/gerar_molduras.py, versão do jogo): arco ogival com bisel de metal iluminado,
## folhas góticas, pináculo com gema, rodapé; medalhão com o símbolo da tradição no meio da base; barra de vida
## (Cornucópia) logo abaixo; plaquinha com o nome; fita com o nível. A moldura e o medalhão viram texturas uma vez
## (cache por material/tamanho); o retrato é desenhado por baixo, recortado no formato do arco (polígono com UV).

const ESCURO := Color("#140c10")
const LUZ := Vector2(-0.55, -0.83)
const MATERIAIS := {
	"bronze": [Color8(70, 38, 22), Color8(122, 70, 38), Color8(176, 112, 62), Color8(222, 160, 102), Color8(255, 222, 170)],
	"prata": [Color8(52, 54, 66), Color8(98, 102, 120), Color8(152, 158, 176), Color8(204, 210, 224), Color8(250, 252, 255)],
	"ouro": [Color8(92, 54, 20), Color8(156, 100, 34), Color8(220, 160, 60), Color8(255, 212, 110), Color8(255, 244, 196)],
	"jade": [Color8(14, 56, 44), Color8(28, 100, 78), Color8(58, 158, 120), Color8(128, 214, 176), Color8(214, 255, 234)],
	"obsidiana": [Color8(20, 10, 30), Color8(44, 22, 66), Color8(84, 46, 120), Color8(150, 96, 206), Color8(226, 190, 255)],
}
const GEMAS := {"bronze": [Color8(40, 70, 40), Color8(70, 140, 80), Color8(170, 230, 160)], "prata": [Color8(24, 40, 110), Color8(60, 100, 210), Color8(170, 210, 255)],
	"ouro": [Color8(100, 14, 30), Color8(196, 40, 60), Color8(255, 150, 160)], "jade": [Color8(120, 20, 20), Color8(210, 60, 48), Color8(255, 170, 140)],
	"obsidiana": [Color8(80, 0, 60), Color8(200, 40, 160), Color8(255, 160, 240)]}
const COR_TRAD := {
	"indigena": [Color8(64, 26, 14), Color8(150, 66, 34), Color8(255, 196, 110)], "cristianismo": [Color8(20, 30, 70), Color8(50, 76, 150), Color8(255, 230, 150)],
	"taoismo": [Color8(10, 50, 44), Color8(30, 120, 104), Color8(230, 250, 240)], "hinduismo": [Color8(110, 44, 8), Color8(214, 110, 26), Color8(255, 230, 150)],
	"bruxaria": [Color8(34, 18, 50), Color8(84, 48, 116), Color8(200, 160, 240)], "alta_magia": [Color8(14, 12, 18), Color8(50, 40, 60), Color8(236, 196, 96)],
	"abismo": [Color8(16, 4, 24), Color8(60, 20, 80), Color8(230, 120, 255)], "misto": [Color8(30, 22, 30), Color8(90, 70, 50), Color8(255, 228, 160)],
}
const SIMBOLOS := {
	"indigena": ["......###", ".....#++#", "....#++#.", "...#++#..", "..#++#...", "..#+#....", ".#.##....", "#........", "........."],
	"cristianismo": ["...###...", "....#....", "#...#...#", "#########", "#...#...#", "....#....", "....#....", "....#....", "...###..."],
	"taoismo": ["..#####..", ".##...##.", "###.#..##", "###.....#", "####....#", "######..#", "####.#.##", ".#######.", "..#####.."],
	"hinduismo": [".........", "....#....", "...#+#...", "#..#+#..#", "##.#+#.##", ".##+++##.", "..#+++#..", ".#######.", "........."],
	"bruxaria": ["..###....", ".##......", "##....#..", "##...###.", "##....#..", "##.......", ".##......", "..###....", "........."],
	"alta_magia": ["....#....", "...#.#...", "#########", ".#.....#.", "..#...#..", ".#.....#.", "#########", "...#.#...", "....#...."],
	"abismo": [".........", "..#####..", ".#..#..#.", "#..+#+..#", "#..+#+..#", "#..+#+..#", ".#..#..#.", "..#####..", "........."],
	"misto": ["....#....", "...#+#...", "..#+++#..", ".#+++++#.", "#+++++++#", ".#+++++#.", "..#+++#..", "...#+#...", "....#...."],
}
const MADEIRA := [Color("#5a3826"), Color("#4a2d1f"), Color("#331f16"), Color("#6b4630")]

static var _cache := {}


const D_ARCO := 0.12                                  # afastamento dos centros dos 2 círculos do arco (× largura): 0 = arco redondo


## Altura do arco (do ápice, y = 0, até a mola, onde começam os lados retos).
static func flecha_de(larg: float) -> float:
	var d := larg * D_ARCO
	var r := larg / 2.0 + d
	return sqrt(r * r - d * d)


## Geometria da janela em arco (px nativos, origem no ápice/canto esquerdo): larg × alt, flecha = altura do arco.
static func _sd(x: float, y: float, larg: float, alt: float, flecha: float) -> float:
	var cx := larg / 2.0
	var d := larg * D_ARCO
	var r := larg / 2.0 + d
	var topo := maxf(Vector2(x - (cx + d), y - flecha).length() - r, Vector2(x - (cx - d), y - flecha).length() - r)
	var sa := maxf(topo, y - flecha)
	var sr := maxf(maxf(absf(x - cx) - larg / 2.0, y - alt), flecha - y)
	return minf(sa, sr)


static func _tom(tons: Array, v: float) -> Color:
	return tons[clampi(int(v * tons.size()), 0, tons.size() - 1)]


## Textura da moldura (aro + pináculo + gema + bolotas + rodapé) com a janela transparente.
## Devolve {tex, ox, oy}: (ox, oy) = onde fica o canto da janela dentro da textura.
static func textura(mat: String, larg: int, alt: int) -> Dictionary:
	var chave := "%s_%d_%d" % [mat, larg, alt]
	if _cache.has(chave):
		return _cache[chave]
	var tons: Array = MATERIAIS.get(mat, MATERIAIS["bronze"])
	var aro := 4
	var flecha := flecha_de(larg)
	var mx := aro + 4
	var topo := aro + 7
	var w := larg + 2 * mx
	var h := alt + topo + aro + 2
	var im := Image.create(w, h, false, Image.FORMAT_RGBA8)
	var ox := mx
	var oy := topo
	for py in h:
		for px in w:
			var x := px - ox + 0.5
			var y := py - oy + 0.5
			var sd := _sd(x, y, larg, alt, flecha)
			if sd <= 0.0 or sd > aro:
				continue
			if sd > aro - 1:
				im.set_pixel(px, py, ESCURO); continue
			if sd <= 1.0:
				im.set_pixel(px, py, tons[0]); continue
			var gx := _sd(x + 1, y, larg, alt, flecha) - _sd(x - 1, y, larg, alt, flecha)
			var gy := _sd(x, y + 1, larg, alt, flecha) - _sd(x, y - 1, larg, alt, flecha)
			var n := Vector2(gx, gy).normalized()
			var u := (sd - 1.0) / float(aro - 2)
			var normal := -cos(PI * u) * n
			im.set_pixel(px, py, _tom(tons, 0.52 + 0.62 * normal.dot(-LUZ)))
	# rodapé (a base alarga 2 px de cada lado)
	var ry := oy + alt + aro - 4
	for yy in 4:
		for xx in range(ox - aro - 2, ox + larg + aro + 2):
			var c: Color = ESCURO if yy == 0 or yy == 3 or xx == ox - aro - 2 or xx == ox + larg + aro + 1 else _tom(tons, 0.92 if yy == 1 else 0.4)
			if xx >= 0 and xx < w and ry + yy < h:
				im.set_pixel(xx, ry + yy, c)
	# bolotas na mola do arco
	for bx in [ox - aro + 1, ox + larg + aro - 2]:
		_esfera(im, bx, oy + int(flecha), 2, tons)
	# pináculo + gema na chave do arco
	var cx := ox + larg / 2
	var ty := oy - aro + 1
	for yy in range(-5, 1):
		var ww := 0 if yy < -3 else 1
		for xx in range(-ww - 1, ww + 2):
			var xp := cx + xx
			var yp := ty + yy
			if xp >= 0 and xp < w and yp >= 0 and yp < h:
				im.set_pixel(xp, yp, ESCURO if absi(xx) == ww + 1 else _tom(tons, 0.9 if xx < 0 else 0.5))
	var gem: Array = GEMAS.get(mat, GEMAS["bronze"])
	for yy in range(-4, 5):
		for xx in range(-3, 4):
			var dd := absf(xx) / 3.0 + absf(yy) / 4.0
			var xp := cx + xx
			var yp := ty + 4 + yy
			if dd > 1.12 or xp < 0 or xp >= w or yp < 0 or yp >= h:
				continue
			var c: Color
			if dd > 0.9:
				c = ESCURO
			elif xx <= 0 and yy <= 0:
				c = gem[2] if xx > -2 and yy > -2 else gem[1]
			elif xx > 0 and yy > 0:
				c = gem[0]
			else:
				c = gem[1]
			im.set_pixel(xp, yp, c)
	var res := {"tex": ImageTexture.create_from_image(im), "ox": ox, "oy": oy, "w": w, "h": h, "flecha": flecha}
	_cache[chave] = res
	return res


static func _esfera(im: Image, cx: int, cy: int, r: int, tons: Array) -> void:
	for yy in range(-r - 1, r + 2):
		for xx in range(-r - 1, r + 2):
			var d := Vector2(xx, yy).length()
			var xp := cx + xx
			var yp := cy + yy
			if d > r + 0.5 or xp < 0 or yp < 0 or xp >= im.get_width() or yp >= im.get_height():
				continue
			im.set_pixel(xp, yp, ESCURO if d > r - 0.5 else _tom(tons, 0.9 if (xx < 0 and yy < 0) else (0.55 if xx <= 0 or yy <= 0 else 0.3)))


## Medalhão com o símbolo da tradição (raio r).
static func medalhao(trad: String, mat: String, r: int) -> Texture2D:
	var chave := "med_%s_%s_%d" % [trad, mat, r]
	if _cache.has(chave):
		return _cache[chave]
	var tons: Array = MATERIAIS.get(mat, MATERIAIS["bronze"])
	var cores: Array = COR_TRAD.get(trad, COR_TRAD["misto"])
	var lado := 2 * r + 3
	var im := Image.create(lado, lado, false, Image.FORMAT_RGBA8)
	var c := r + 1
	for y in lado:
		for x in lado:
			var v := Vector2(x - c, y - c)
			var d := v.length()
			if d > r + 0.5:
				continue
			if d > r - 0.5:
				im.set_pixel(x, y, ESCURO)
			elif d > r - 2.6:
				var n := v / maxf(d, 0.001)
				var u := (d - (r - 2.6)) / 2.1
				im.set_pixel(x, y, _tom(tons, 0.52 + 0.62 * (-cos(PI * u) * n).dot(-LUZ)))
			elif d > r - 3.2:
				im.set_pixel(x, y, ESCURO)
			else:
				var k := clampf((v + Vector2(1.5, 1.5)).length() / (r - 2.0), 0.0, 1.0)
				im.set_pixel(x, y, (cores[1] as Color).lerp(cores[0], k))
	var g: Array = SIMBOLOS.get(trad, SIMBOLOS["misto"])
	var sx := c - 4
	var sy := c - 4
	for yy in g.size():
		var row: String = g[yy]
		for xx in row.length():
			if row[xx] == "#" and sx + xx + 1 < lado and sy + yy + 1 < lado:
				im.set_pixel(sx + xx + 1, sy + yy + 1, cores[0])
	for yy in g.size():
		var row: String = g[yy]
		for xx in row.length():
			if row[xx] == "#":
				im.set_pixel(sx + xx, sy + yy, cores[2])
			elif row[xx] == "+":
				im.set_pixel(sx + xx, sy + yy, (cores[2] as Color).lerp(cores[1], 0.45))
	var tex := ImageTexture.create_from_image(im)
	_cache[chave] = tex
	return tex


## Polígono da janela em arco (para recortar o retrato), em coordenadas da janela.
static func poligono_janela(larg: float, alt: float, flecha: float) -> PackedVector2Array:
	var d := larg * D_ARCO
	var r := larg / 2.0 + d
	var pts := PackedVector2Array([Vector2(0, alt), Vector2(0, flecha)])
	var cx := larg / 2.0
	var a0 := PI
	var apice := atan2(-sqrt(r * r - d * d), -d) + TAU
	for k in range(1, 9):                               # lado esquerdo: círculo com centro à direita
		var a := lerpf(a0, apice, k / 8.0)
		pts.append(Vector2(cx + d + r * cos(a), flecha + r * sin(a)))
	for k in range(7, -1, -1):                          # lado direito: espelho
		var a := lerpf(a0, apice, k / 8.0)
		pts.append(Vector2(cx - d - r * cos(a), flecha + r * sin(a)))
	pts.append(Vector2(larg, alt))
	return pts


## Retrato recortado no arco + moldura por cima + medalhão da tradição no meio da base. (x0, y0) = ápice/canto esquerdo
## da janela. brilho 0..1 = vez do jogador (halo dourado atrás do aro).
static func arco(ci: CanvasItem, x0: float, y0: float, larg: int, alt: int, mat: String, trad: String, retrato: Texture2D,
		brilho := 0.0, raio_med := 7) -> void:
	var m := textura(mat, larg, alt)
	x0 = roundf(x0)
	y0 = roundf(y0)
	var flecha: float = m["flecha"]
	if brilho > 0.0:                                    # halo em arco: 3 camadas crescendo para fora
		for k: int in [9, 6, 3]:
			var lg: int = larg + 2 * k
			var halo := PackedVector2Array()
			for p in poligono_janela(lg, alt + 2 * k, flecha_de(lg)):
				halo.append(p + Vector2(x0 - k, y0 - k - 3))
			ci.draw_colored_polygon(halo, Color(1.0, 0.85, 0.4, (0.16 + 0.03 * (9 - k)) * brilho))
	var pol := poligono_janela(larg, alt, flecha)
	var pts := PackedVector2Array()
	for p in pol:
		pts.append(p + Vector2(x0, y0))
	var cores: Array = COR_TRAD.get(trad, COR_TRAD["misto"])
	ci.draw_colored_polygon(pts, (cores[1] as Color).darkened(0.45))
	if retrato:
		var tw := float(retrato.get_width())
		var th := float(retrato.get_height())
		var k := maxf(larg / tw, alt / th)              # cobre a janela, alinhado em cima (o rosto fica no arco)
		var ux := (tw - larg / k) / 2.0
		var uvs := PackedVector2Array()
		for p in pol:
			uvs.append(Vector2((ux + p.x / k) / tw, (p.y / k) / th))
		ci.draw_polygon(pts, PackedColorArray([Color.WHITE]), uvs, retrato)
	else:                                               # silhueta: cabeça e ombros
		var c := Vector2(x0 + larg / 2.0, y0 + alt * 0.55)
		var sil := (cores[0] as Color).lightened(0.12)
		ci.draw_circle(c + Vector2(0, -alt * 0.14), larg * 0.2, sil)
		ci.draw_colored_polygon(PackedVector2Array([Vector2(x0 + 3, y0 + alt), Vector2(x0 + 5, c.y + 3), Vector2(c.x, c.y),
			Vector2(x0 + larg - 5, c.y + 3), Vector2(x0 + larg - 3, y0 + alt)]), sil)
	ci.draw_texture(m["tex"], Vector2(x0 - m["ox"], y0 - m["oy"]))
	var med := medalhao(trad, mat, raio_med)
	ci.draw_texture(med, Vector2(roundf(x0 + larg / 2.0 - med.get_width() / 2.0), y0 + alt - raio_med))


## Barra de vida (Cornucópia). esc = tamanho da letra (1 ou 2); a barra cresce junto.
static func barra(ci: CanvasItem, cx: float, y: float, larg: float, vida: int, vida_max: int, tons: Array, esc := 1) -> void:
	var r := Rect2(roundf(cx - larg / 2.0), roundf(y), roundf(larg), 7 * esc + 2)
	ci.draw_rect(r.grow(1), ESCURO)
	ci.draw_rect(r, tons[1])
	ci.draw_rect(Rect2(r.position, Vector2(r.size.x, 1)), tons[3])
	var dentro := r.grow(-1)
	ci.draw_rect(dentro, Color8(26, 12, 16))
	var fr := clampf(float(vida) / maxf(1.0, vida_max), 0.0, 1.0)
	var cheio := Rect2(dentro.position, Vector2(roundf(dentro.size.x * fr), dentro.size.y))
	if cheio.size.x > 0:
		var baixa := fr <= 0.34
		ci.draw_rect(cheio, Color8(200, 40, 44) if not baixa else Color8(230, 70, 40))
		ci.draw_rect(Rect2(cheio.position, Vector2(cheio.size.x, 2 * esc)), Color8(255, 130, 110))
		ci.draw_rect(Rect2(cheio.position + Vector2(0, cheio.size.y - 2 * esc), Vector2(cheio.size.x, 2 * esc)), Color8(120, 14, 24))
	var s := str(maxi(vida, 0))
	var w := Fonte57.largura(s, esc)
	var p := Vector2(roundf(cx - w / 2.0), r.position.y + 1)
	ci.draw_rect(Rect2(p - Vector2(2 * esc, 0), Vector2(w + 4 * esc, 7 * esc)), Color(ESCURO, 0.75))
	Fonte57.desenhar(ci, p, s, Color8(255, 246, 230), Color(0, 0, 0), esc)


## Plaquinha de madeira com o nome entalhado (a mesma da mesa).
static func plaquinha(ci: CanvasItem, centro: Vector2, nome: String, esc := 1) -> void:
	var w := float(Fonte57.largura(nome, esc) + 16)
	var alt := 7 * esc + 5
	var pr := Rect2(roundf(centro.x - w / 2), roundf(centro.y - alt / 2.0), w, alt)
	ci.draw_rect(pr.grow(1), ESCURO)
	ci.draw_rect(pr, MADEIRA[0])
	for k in range(3, alt - 1, 3):
		ci.draw_line(Vector2(pr.position.x + 2, pr.position.y + k), Vector2(pr.end.x - 2, pr.position.y + k), MADEIRA[1], 1.0)
	ci.draw_rect(Rect2(pr.position, Vector2(pr.size.x, 1)), MADEIRA[3].lightened(0.25))
	ci.draw_rect(Rect2(pr.position + Vector2(0, pr.size.y - 1), Vector2(pr.size.x, 1)), MADEIRA[2].darkened(0.3))
	for x in [pr.position.x + 3, pr.end.x - 5]:
		ci.draw_rect(Rect2(x, roundf(pr.get_center().y - 1), 2, 2), Color("#e2b85a"))
	var tv := Fonte57.tinta_v(nome) * esc
	var pos := Vector2(roundf(centro.x - Fonte57.largura(nome, esc) / 2.0), roundf(pr.get_center().y - (tv.x + tv.y + esc) / 2.0))
	Fonte57.desenhar(ci, pos + Vector2(0, 1), nome, MADEIRA[3].lightened(0.35), Color(0, 0, 0, 0), esc)
	Fonte57.desenhar(ci, pos, nome, Color("#24130c"), Color(0, 0, 0, 0), esc)


static func fita(ci: CanvasItem, cx: float, y: float, texto: String, tons: Array, esc := 1) -> void:
	var w := Fonte57.largura(texto, esc) + 10
	var r := Rect2(roundf(cx - w / 2.0), roundf(y), w, 7 * esc + 3)
	for lado in [-1, 1]:                                  # caudas em V
		var bx := r.position.x - 4 if lado < 0 else r.end.x
		ci.draw_colored_polygon(PackedVector2Array([Vector2(bx, r.position.y + 1), Vector2(bx + 4, r.position.y + 1),
			Vector2(bx + 4, r.end.y + 1), Vector2(bx, r.end.y + 1), Vector2(bx + 2, r.get_center().y + 1)]), Color8(64, 18, 32))
	ci.draw_rect(r.grow(1), ESCURO)
	ci.draw_rect(r, Color8(96, 30, 48))
	ci.draw_rect(Rect2(r.position, Vector2(r.size.x, 1)), tons[3])
	var tv := Fonte57.tinta_v(texto) * esc
	Fonte57.desenhar(ci, Vector2(r.position.x + 5, roundf(r.get_center().y - (tv.x + tv.y + esc) / 2.0)), texto, tons[4], ESCURO, esc)
