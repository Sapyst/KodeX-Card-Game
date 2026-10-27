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
	"0": ["111", "101", "101", "101", "111"], "1": ["010", "110", "010", "010", "111"], "2": ["111", "001", "111", "100", "111"],
	"3": ["111", "001", "011", "001", "111"], "4": ["101", "101", "111", "001", "001"], "5": ["111", "100", "111", "001", "111"],
	"6": ["111", "100", "111", "101", "111"], "7": ["111", "001", "010", "010", "010"], "8": ["111", "101", "111", "101", "111"],
	"9": ["111", "101", "111", "001", "111"], "/": ["001", "001", "010", "100", "100"], "-": ["000", "000", "111", "000", "000"],
	"+": ["000", "010", "111", "010", "000"], "!": ["010", "010", "010", "000", "010"], "¡": ["010", "000", "010", "010", "010"], "¿": ["010", "000", "010", "100", "011"], "?": ["110", "001", "010", "000", "010"],
	"^": ["010", "111", "010", "010", "010"],
	"<": ["001", "010", "100", "010", "001"], ">": ["100", "010", "001", "010", "100"],
	"(": ["010", "100", "100", "100", "010"], ")": ["010", "001", "001", "001", "010"],
	"%": ["101", "001", "010", "100", "101"],
	":": ["000", "010", "000", "010", "000"], ".": ["000", "000", "000", "000", "010"], " ": ["000", "000", "000", "000", "000"],
}


const SEM_ACENTO := {"Ð": "D", "—": "-", "–": "-", "·": "-", "→": "-", ";": " ", ",": " ", "'": " ", "\"": " ",
	"×": "X", "*": "+"}

## Letras acentuadas: letra base + marca. Acentos ficam 1 px acima da letra (linhas -3 e -2); a cedilha, embaixo (5 e 6).
const ACENTOS := {"Á": ["A", "agudo"], "À": ["A", "grave"], "Â": ["A", "circ"], "Ã": ["A", "til"], "Ä": ["A", "trema"],
	"É": ["E", "agudo"], "È": ["E", "grave"], "Ê": ["E", "circ"], "Ë": ["E", "trema"],
	"Í": ["I", "agudo"], "Ì": ["I", "grave"], "Î": ["I", "circ"], "Ï": ["I", "trema"],
	"Ó": ["O", "agudo"], "Ò": ["O", "grave"], "Ô": ["O", "circ"], "Õ": ["O", "til"], "Ö": ["O", "trema"],
	"Ú": ["U", "agudo"], "Ù": ["U", "grave"], "Û": ["U", "circ"], "Ü": ["U", "trema"],
	"Ç": ["C", "cedilha"], "Ñ": ["N", "til"]}
const MARCAS := {"agudo": [Vector2(2, -3), Vector2(1, -2)], "grave": [Vector2(0, -3), Vector2(1, -2)],
	"circ": [Vector2(1, -3), Vector2(0, -2), Vector2(2, -2)], "til": [Vector2(1, -3), Vector2(2, -3), Vector2(0, -2), Vector2(1, -2)],
	"trema": [Vector2(0, -2), Vector2(2, -2)], "cedilha": [Vector2(1, 5), Vector2(1, 6), Vector2(0, 6)]}


## Normaliza para a fonte 3×5: maiúsculas; acentos sem glifo próprio caem na letra base.
static func normalizar(s: String) -> String:
	return s.to_upper()


## Alta resolução: maiúsculas em Noto Sans SemiCondensed Bold (OFL) na resolução real da tela; medidas em px do
## layout 360×640 (maiúscula ≈ 5,7 px por esc). O desenho por retângulos (G, MARCAS) ficou só como referência.
const TAM := 8
const BASE := 5.6
static var _f: Font


static func fonte() -> Font:
	if _f == null:
		_f = load("res://fontes/NotoSans-SemiCondensedBold.ttf")
	return _f


static func largura(s: String, esc: int = 1) -> int:
	return ceili(fonte().get_string_size(s.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, TAM * esc).x)


## pos = canto superior esquerdo. `contorno`: borda suave em volta das letras.
static func desenhar(ci: CanvasItem, pos: Vector2, s: String, cor: Color, esc: int = 1, contorno := Color(0, 0, 0, 0)) -> void:
	var f := fonte()
	var t := s.to_upper()
	var p := Vector2(pos.x, pos.y + BASE * esc)
	if contorno.a > 0.0:
		ci.draw_string_outline(f, p, t, HORIZONTAL_ALIGNMENT_LEFT, -1, TAM * esc, 2 * esc, contorno)
	ci.draw_string(f, p, t, HORIZONTAL_ALIGNMENT_LEFT, -1, TAM * esc, cor)


## Corta o texto até caber em `larg` px (sem reticências: rótulos curtos).
static func cortar(s: String, larg: float, esc: int = 1) -> String:
	var t := s.to_upper()
	while t.length() > 1 and largura(t, esc) > larg:
		t = t.substr(0, t.length() - 1)
	return t.strip_edges()


static func centrado(ci: CanvasItem, centro: Vector2, s: String, cor: Color, esc: int = 1, contorno := Color(0, 0, 0, 0)) -> void:
	desenhar(ci, Vector2(roundf(centro.x - largura(s, esc) / 2.0), centro.y - 5 * esc / 2.0), s, cor, esc, contorno)


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
