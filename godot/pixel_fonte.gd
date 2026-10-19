class_name PixelFonte
## Fonte pixel 3×5 (maiúsculas, dígitos, sinais) desenhada com retângulos — nítida em qualquer escala inteira.

const G := {
	"A": ["010", "101", "111", "101", "101"], "B": ["110", "101", "110", "101", "110"], "C": ["011", "100", "100", "100", "011"],
	"D": ["110", "101", "101", "101", "110"], "E": ["111", "100", "110", "100", "111"], "F": ["111", "100", "110", "100", "100"],
	"G": ["011", "100", "101", "101", "011"], "H": ["101", "101", "111", "101", "101"], "I": ["111", "010", "010", "010", "111"],
	"J": ["001", "001", "001", "101", "010"], "K": ["101", "101", "110", "101", "101"], "L": ["100", "100", "100", "100", "111"],
	"M": ["101", "111", "111", "101", "101"], "N": ["110", "101", "101", "101", "101"], "O": ["010", "101", "101", "101", "010"],
	"P": ["110", "101", "110", "100", "100"], "Q": ["010", "101", "101", "110", "011"], "R": ["110", "101", "110", "101", "101"],
	"S": ["011", "100", "010", "001", "110"], "T": ["111", "010", "010", "010", "010"], "U": ["101", "101", "101", "101", "011"],
	"V": ["101", "101", "101", "010", "010"], "W": ["101", "101", "111", "111", "101"], "X": ["101", "101", "010", "101", "101"],
	"Y": ["101", "101", "010", "010", "010"], "Z": ["111", "001", "010", "100", "111"],
	"Ó": ["010", "000", "111", "101", "111"], "Á": ["010", "000", "111", "111", "101"],
	"0": ["111", "101", "101", "101", "111"], "1": ["010", "110", "010", "010", "111"], "2": ["111", "001", "111", "100", "111"],
	"3": ["111", "001", "011", "001", "111"], "4": ["101", "101", "111", "001", "001"], "5": ["111", "100", "111", "001", "111"],
	"6": ["111", "100", "111", "101", "111"], "7": ["111", "001", "010", "010", "010"], "8": ["111", "101", "111", "101", "111"],
	"9": ["111", "101", "111", "001", "111"], "/": ["001", "001", "010", "100", "100"], "-": ["000", "000", "111", "000", "000"],
	"+": ["000", "010", "111", "010", "000"], "!": ["010", "010", "010", "000", "010"], " ": ["000", "000", "000", "000", "000"],
}


const SEM_ACENTO := {"À": "A", "Â": "A", "Ã": "A", "É": "E", "Ê": "E", "Í": "I", "Ô": "O", "Õ": "O", "Ú": "U", "Ü": "U",
	"Ç": "C", "Ð": "D", "Ñ": "N", "—": "-", "–": "-", "·": "-", "→": "-", ":": " ", ";": " ", ",": " ", ".": " ", "'": " ", "\"": " ",
	"(": " ", ")": " ", "×": "X", "*": "+"}


## Normaliza para a fonte 3×5: maiúsculas; acentos sem glifo próprio caem na letra base.
static func normalizar(s: String) -> String:
	var out := ""
	for ch in s.to_upper():
		out += SEM_ACENTO.get(ch, ch) if not G.has(ch) else ch
	return out


static func largura(s: String, esc: int = 1) -> int:
	return (s.length() * 4 - 1) * esc


## pos = canto superior esquerdo. `contorno` desenha 1 px (× esc) de borda em volta de cada pixel aceso.
static func desenhar(ci: CanvasItem, pos: Vector2, s: String, cor: Color, esc: int = 1, contorno := Color(0, 0, 0, 0)) -> void:
	var pts: Array[Vector2] = []
	var x := 0
	for ch in normalizar(s):
		var g: Array = G.get(ch, G["-"])
		for yy in 5:
			var row: String = g[yy]
			for xx in 3:
				if row[xx] == "1":
					pts.append(Vector2(x + xx, yy))
		x += 4
	if contorno.a > 0.0:
		for p in pts:
			ci.draw_rect(Rect2(pos + (p - Vector2.ONE) * esc, Vector2(3, 3) * esc), contorno)
	for p in pts:
		ci.draw_rect(Rect2(pos + p * esc, Vector2(esc, esc)), cor)


static func centrado(ci: CanvasItem, centro: Vector2, s: String, cor: Color, esc: int = 1, contorno := Color(0, 0, 0, 0)) -> void:
	desenhar(ci, (centro - Vector2(largura(s, esc), 5 * esc) / 2).round(), s, cor, esc, contorno)


## Quebra o texto em linhas de no máximo `max_chars` caracteres (fonte monoespaçada).
static func quebrar(s: String, max_chars: int) -> PackedStringArray:
	var linhas := PackedStringArray()
	var atual := ""
	for p in normalizar(s).split(" ", false):
		var t := (atual + " " + p).strip_edges()
		if t.length() <= max_chars:
			atual = t
		else:
			linhas.append(atual)
			atual = p
	if atual != "":
		linhas.append(atual)
	return linhas
