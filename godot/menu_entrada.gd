class_name MenuEntrada
extends RefCounted
## Tela de entrada (fluxo.gd, estado "entrada"): aparece na 1ª abertura, antes de criar o perfil.
## Convidado (conta temporária neste aparelho) · Kode (usuário e senha: entrar ou criar) · Google, Email e Apple
## desabilitados até a versão final. No topo, botão de idioma com globo: troca o jogo inteiro, como em Opções.
## px nativos 360×640.

const DESLIGADO := Color("#5a5260")
const W := 240.0

var f                                       # o menu (fluxo.gd)
var kode_aberto := false                    # o botão do Kode se abriu em "Entrar" / "Criar"


func _init(menu) -> void:
	f = menu


func _y0() -> float:
	return 238.0 + f.extra()


func botoes() -> void:
	f._botao(Rect2(262, 10, 88, 28), "", func() -> void: Sessao.trocar_idioma(); f._ir("entrada"); f.transicao = 0.0,
		{"desenho": _botao_idioma})
	var x := 180.0 - W / 2.0
	var y := _y0()
	f._botao(Rect2(x, y, W, 36), "", _convidado, {"desenho": _botao_entrada.bind("convidado", "Jogar como convidado", true, true)})
	y += 46
	if kode_aberto:
		f._botao(Rect2(x, y, W / 2.0 - 4, 36), "", _kode.bind(false), {"desenho": _botao_entrada.bind("kode", "Entrar", true, false)})
		f._botao(Rect2(x + W / 2.0 + 4, y, W / 2.0 - 4, 36), "", _kode.bind(true), {"desenho": _botao_entrada.bind("kode", "Criar Kode", true, false)})
	else:
		f._botao(Rect2(x, y, W, 36), "", func() -> void: kode_aberto = true; f._ir("entrada"); f.transicao = 0.0,
			{"desenho": _botao_entrada.bind("kode", "Kode (usuário e senha)", true, false)})
	y += 46
	for it in [["google", "Google"], ["email", "E-mail"], ["apple", "Apple"]]:   # nomes universais: iguais em todo idioma
		f._botao(Rect2(x, y, W, 36), "", func() -> void: f.mp.avisar(Sessao.t("Disponível na versão final do jogo.")),
			{"desenho": _botao_entrada.bind(it[0], it[1], false, false)})
		y += 46


func desenhar() -> void:
	var y := _y0()
	f._texto_central(Vector2(180, y - 22), Sessao.t("Como você quer entrar?"), f.CREME)
	var aviso := Sessao.t("Login com email, Google e Apple estará disponível na versão final do jogo.")
	var linhas := Fonte57.quebrar(aviso, 250)
	for k in linhas.size():
		f._texto_central(Vector2(180, y + 5 * 46 + 6 + k * 11), linhas[k], Color(0.62, 0.57, 0.62))


func _convidado() -> void:
	f.confirmar(Sessao.t("Jogar como convidado?"),
		Sessao.t("Conta temporária: fica só neste aparelho. Se desinstalar sem criar um Kode, o progresso se perde."),
		func() -> void: f.concluir_entrada())


func _kode(criar: bool) -> void:
	f.volta_conta = "entrada"
	if criar:
		f._criar_kode()
	else:
		f._entrar_kode()


# ================= desenho =================
func _botao_entrada(_b: Dictionary, r: Rect2, pressao: float, icone: String, texto: String, ativo: bool, principal: bool) -> void:
	var dentro: Rect2 = f._painel(r, principal, pressao if ativo else 0.0, Color("#3a2410") if principal else (Color("#241a20") if ativo else Color("#1a161c")))
	var cor: Color = (f.OURO[0] if principal else f.CREME) if ativo else DESLIGADO
	var t := Sessao.t(texto)
	var larg := 13 + 8 + Fonte57.largura(t)
	var x0 := roundf(dentro.get_center().x - larg / 2.0)
	_icone(icone, Vector2(x0, roundf(dentro.get_center().y - 6)), cor)
	Fonte57.desenhar(f, Vector2(x0 + 21, roundf(dentro.get_center().y - 4)), t, cor, f.ESCURO)


func _botao_idioma(_b: Dictionary, r: Rect2, pressao: float) -> void:
	var dentro: Rect2 = f._painel(r, true, pressao, Color("#2a1c12"))
	var sigla: String = {"pt": "PT-BR", "en": "EN", "es": "ES"}.get(Sessao.idioma, "EN")
	var larg := 13 + 6 + Fonte57.largura(sigla)
	var x0 := roundf(dentro.get_center().x - larg / 2.0)
	_icone("globo", Vector2(x0, roundf(dentro.get_center().y - 6)), f.OURO[0])
	Fonte57.desenhar(f, Vector2(x0 + 19, roundf(dentro.get_center().y - 4)), sigla, f.OURO[0], f.ESCURO)


## Ícones lineares 13×13 desenhados pixel a pixel (cor única, sem preenchimento).
func _icone(nome: String, p: Vector2, cor: Color) -> void:
	var px := func(x: int, y: int) -> void: f.draw_rect(Rect2(p.x + x, p.y + y, 1, 1), cor)
	match nome:
		"globo":                                    # círculo + meridiano central + 2 paralelos + equador
			for y in 13:
				for x in 13:
					var dx := x - 6.0
					var dy := y - 6.0
					var d := sqrt(dx * dx + dy * dy)
					var borda := absf(d - 5.8) < 0.55
					var meridiano := absf(sqrt(dx * dx / 6.25 + dy * dy / 36.0) - 0.97) < 0.12 and d < 5.8
					var paralelo := (y == 6 or y == 3 or y == 9) and d < 5.6
					if borda or meridiano or paralelo or (x == 6 and d < 5.8):
						px.call(x, y)
		"convidado":                                # cabeça e ombros
			for y in 13:
				for x in 13:
					var c := Vector2(x - 6.0, y - 3.5).length()
					var o := Vector2((x - 6.0) / 5.5, (y - 13.0) / 5.0).length()
					if absf(c - 2.6) < 0.6 or (absf(o - 1.0) < 0.14 and y <= 12):
						px.call(x, y)
		"kode":                                     # chave: argola + haste + 2 dentes
			for y in 13:
				for x in 13:
					if absf(Vector2(x - 3.5, y - 6.0).length() - 2.8) < 0.6:
						px.call(x, y)
			for x in range(7, 13):
				px.call(x, 6)
			for y in range(7, 10):
				px.call(10, y); px.call(12, y)
		"google":                                   # G
			for y in 13:
				for x in 13:
					var v := Vector2(x - 6.0, y - 6.0)
					var a := rad_to_deg(atan2(v.y, v.x))
					if absf(v.length() - 5.5) < 0.6 and not (a > -40 and a < 5):
						px.call(x, y)
			for x in range(7, 12):
				px.call(x, 6)
		"email":                                    # envelope
			for x in 13:
				px.call(x, 2); px.call(x, 10)
			for y in range(2, 11):
				px.call(0, y); px.call(12, y)
			for k in 7:
				px.call(k, 2 + k * 5 / 6); px.call(12 - k, 2 + k * 5 / 6)
		"apple":                                    # maçã com folha
			for y in 13:
				for x in 13:
					var e := Vector2((x - 6.0) / 5.5, (y - 7.5) / 5.0).length()
					if absf(e - 1.0) < 0.13 and not (y < 4 and absf(x - 6.0) < 1.5):
						px.call(x, y)
			px.call(7, 1); px.call(8, 0); px.call(9, 0)
