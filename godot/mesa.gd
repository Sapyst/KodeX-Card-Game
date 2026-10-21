extends Node2D
## Mesa em pixel art (render nativo 360×640, ampliado ×2): entrada com a câmera girando e zoom, velas acendendo,
## deck caindo em cascata, dois embaralhamentos riffle, cortes, batida, monte vai para o deck e compra da mão inicial.

const CENTRO := Vector2(180, 320)
const N_CARTAS := 32
const MAO_INICIAL := 4

# falsa perspectiva: a mesa encolhe para cima (fundo = 84% da largura da frente)
const TOPO_Y := 34.0
const BASE_Y := 606.0
const ESC_TOPO := 0.84

# espaços em coordenadas "planas" da mesa
# as duas metades são espelhadas em volta da linha do meio (y 291): cada lado tem a sua faixa na borda da mesa para o
# retrato (em cima, menor pela perspectiva); a mão do jogador fica abaixo da faixa dele
const ENT_OPON := [Vector2(68, 212), Vector2(143, 212), Vector2(218, 212), Vector2(293, 212)]
const SELO_OPON := [Vector2(143, 126), Vector2(218, 126)]
const ENT_JOG := [Vector2(68, 370), Vector2(143, 370), Vector2(218, 370), Vector2(293, 370)]
const SELO_JOG := [Vector2(143, 458), Vector2(218, 458)]
const DECK_JOG := Vector2(306, 458)
const CEMIT_JOG := Vector2(55, 458)
const DECK_OPON := Vector2(55, 126)
const CEMIT_OPON := Vector2(306, 126)
const LINHA_Y := 291.0
const ESC_CAMPO := 0.88
const LUZ_PRINCIPAL := Vector2(180, -34)

# paleta
const PEDRA := [Color("#16121c"), Color("#1c1724"), Color("#0e0b13")]
const MADEIRA := [Color("#5a3826"), Color("#4a2d1f"), Color("#331f16"), Color("#6b4630")]
const VELUDO := [Color("#3d1f33"), Color("#33192b"), Color("#26111f")]
const OURO := [Color("#ffe39a"), Color("#e2b85a"), Color("#9c7430")]
const ESCURO := Color("#140c10")

const DIGITOS := {
	"0": ["111", "101", "101", "101", "111"], "1": ["010", "110", "010", "010", "111"], "2": ["111", "001", "111", "100", "111"],
	"3": ["111", "001", "011", "001", "111"], "4": ["101", "101", "111", "001", "001"], "5": ["111", "100", "111", "001", "111"],
	"6": ["111", "100", "111", "101", "111"], "7": ["111", "001", "010", "010", "010"], "8": ["111", "101", "111", "101", "111"],
	"9": ["111", "101", "111", "001", "111"], "/": ["001", "001", "010", "100", "100"],
}

var camera: Camera2D
var ambiente: CanvasModulate
var tabuleiro: Node2D
var camada_cartas: Node2D
var luzes: Array[PointLight2D] = []
var luz_base: Array[float] = []
var luz_pos0: Array[Vector2] = []
var deck_jog: Array[Carta] = []
var deck_opon: Array[Carta] = []
var mao_jog: Array[Carta] = []
var mao_opon: Array[Carta] = []
var rng := RandomNumberGenerator.new()          # lógica (alvo/descarte aleatório): mesma semente nos dois aparelhos
var rng_vis := RandomNumberGenerator.new()      # só enfeite (madeira, cascata, riffle): pode divergir sem problema
var rng_deck: Array = [RandomNumberGenerator.new(), RandomNumberGenerator.new()]   # embaralhar: uma sequência por deck
var rede: RedePartida = null                    # partida online (passo travado)
var online_info: Dictionary = {}
var dessinc := false
var ruido := FastNoiseLite.new()
var tempo := 0.0
var efeitos: Efeitos
var chao: Efeitos
var placar: Node2D
var cornucopia := [15, 15]
var placar_pulo := [0.0, 0.0]
var campo_ent := [[null, null, null, null], [null, null, null, null]]
var campo_selo := [[null, null], [null, null]]
var cemiterio := [0, 0]
var tremor := 0.0
var segurando: Carta = null
var origem := ""                      # "mao" | "campo"
var origem_idx := -1
var ponteiro := Vector2.ZERO
var ocupado := false                  # animação em curso: ignora toques
signal escolhido(valor)
signal fim_turno_pedido
var modo_partida := OS.get_environment("GD_DEMO") == ""
var auto_jogador := OS.get_environment("GD_AUTO") != ""
var db: Dictionary = {}
var fe := [0, 0]
var fe_max := [0, 0]
var ativo := 0
var turno_n := 0
var selo_no_turno := false
var acabou := false
var botao_fim := Rect2(296, 318, 50, 14)
var segurando_t := 0.0
var segurando_ini := Vector2.ZERO
var nivel_ia := [1, 1]                 # 0 Aprendiz · 1 Mestre · 2 Arquimago (por lado; o jogador só usa com GD_AUTO)
var estilo_ia := ["equilibrado", "equilibrado"]
var rng_ia := RandomNumberGenerator.new()
var hud: MesaHud
var log_partida: Array = []           # [turno, dono, tipo, carta, alvo] de cada jogada (histórico do perfil)
var _inicio_ms := 0
var _corn_ini := [15, 15]               # vida no começo da partida (modos com vida diferente de 15)
var perg: Pergaminho                  # regras e resumo da partida (numa CanvasLayer: fora da câmera)
var alt_util := 640.0                 # usados pelo Pergaminho (mesma interface do menu)
var pos_base := Vector2.ZERO
var pausado := false
var acelerar_ia := false              # botão ">> RÁPIDO" no turno do oponente: 2,5× até a sua vez
var _vel_teste := 1.0
var _som: AudioStreamPlayer


func _ready() -> void:
	# partida de verdade: embaralhamento novo a cada vez (antes era sempre a semente 7 = mesma ordem e mesma mão);
	# testes fixam com GD_SEED; o Desafio do dia usa a semente do dia (igual para todo mundo)
	if OS.get_environment("GD_SEED") != "":
		rng.seed = OS.get_environment("GD_SEED").to_int()
	elif _extras().has("semente"):
		rng.seed = int(_extras()["semente"])
	else:
		rng.randomize()
	if online_partida():
		online_info = Sessao.extras.get("online", {})
		rng.seed = int(online_info.get("semente", 1))
	rng_vis.randomize()
	for d in 2:                       # cada deck tem a sua sequência (índice GLOBAL do jogador): a ordem não importa
		rng_deck[d].seed = rng.seed * 31 + 7 + _global(d) * 1000003
	ruido.frequency = 3.0
	ambiente = CanvasModulate.new()
	ambiente.color = Color.BLACK
	add_child(ambiente)
	tabuleiro = Node2D.new()
	tabuleiro.draw.connect(_desenhar_tabuleiro)
	add_child(tabuleiro)
	_criar_luzes()
	camada_cartas = Node2D.new()
	add_child(camada_cartas)
	veu_alvo = Node2D.new()                   # escurece a mesa durante a escolha de alvo; as candidatas sobem acima dele
	veu_alvo.z_index = 740
	veu_alvo.draw.connect(func() -> void: veu_alvo.draw_rect(Rect2(-400, -400, 1200, 1500), Color(0.03, 0.02, 0.05, 0.62 * veu_a)))
	add_child(veu_alvo)
	if modo_partida:
		db = Sessao.db                        # já no idioma escolhido
	motor = MotorEfeitos.new(self)
	if OS.get_environment("GD_VELOCIDADE") != "":          # testes automáticos: acelera animações e timers
		_vel_teste = maxf(0.1, OS.get_environment("GD_VELOCIDADE").to_float())
	aplicar_tempo()
	rng_ia.seed = rng.seed + 991
	if modo_partida and Sessao.modo != "" and Sessao.modo != "tutorial":
		nivel_ia[1] = Sessao.dificuldade
		estilo_ia[1] = Sessao.estilo_ia(Sessao.oponente)
	for lado in 2:                                           # teste: GD_IA_0 / GD_IA_1 = "nivel:estilo"
		var cfg_ia := OS.get_environment("GD_IA_%d" % lado)
		if cfg_ia != "":
			nivel_ia[lado] = int(cfg_ia.split(":")[0])
			if cfg_ia.contains(":"):
				estilo_ia[lado] = cfg_ia.split(":")[1]
	hud = MesaHud.new(self)
	add_child(hud)
	var camada := CanvasLayer.new()
	camada.layer = 20
	add_child(camada)
	perg = Pergaminho.new(self)
	camada.add_child(perg)
	if OS.get_environment("GD_HUD_TESTE") != "":              # teste: "14:menu;16:regras;19:fechar;20:emote:1;22:hist:0;24:lendaria:ind_tupa"
		for passo in OS.get_environment("GD_HUD_TESTE").split(";"):
			var pt := passo.split(":")
			get_tree().create_timer(float(pt[0]), true, false, true).timeout.connect(_passo_hud.bind(pt))
	_som = AudioStreamPlayer.new()
	_som.volume_db = -6.0
	add_child(_som)
	placar = Node2D.new()
	placar.z_index = 50
	placar.draw.connect(_desenhar_placar)
	add_child(placar)
	efeitos = Efeitos.new()
	add_child(efeitos)
	carrossel = Carrossel.new()               # visor do cemitério (ver e reviver)
	add_child(carrossel)
	chao = Efeitos.new()                      # efeitos rentes à mesa: ficam POR BAIXO das cartas
	add_child(chao)
	chao.z_index = 20
	camera = Camera2D.new()
	camera.position = CENTRO
	camera.ignore_rotation = false
	add_child(camera)
	camera.make_current()
	if online_partida():
		rede = RedePartida.new()
		add_child(rede)
		rede.emote.connect(hud.emote_oponente)
		rede.fim_servidor.connect(_fim_servidor)
		await rede.iniciar(online_info, bool(online_info.get("retomar", false)))
	_preparar_retratos()
	await _intro()
	if modo_partida and Sessao.modo == "enigma":
		await _enigma()
		return
	await _cascata_deck()
	await _riffle()
	await _riffle()
	await _cortes()
	await _bater_monte()
	await _ir_para_deck()
	await _comprar_mao()
	print("PRONTO: mão inicial comprada")
	if OS.get_environment("GD_TESTE_REEMB") != "":             # teste: Guarda em campo + deck vazio → reembaralhar
		var g := _nova_carta(proj(DECK_JOG), 1.0)
		g.definir(db["cartas"]["hin_durga"], 0)
		g.virada_para_cima = true
		deck_jog.erase(g)
		await _por_em_campo(g, 0, 1)
		for c in deck_jog.duplicate():
			cemit[0].append({"dados": c.dados, "no": null})
			c.queue_free()
		deck_jog.clear()
		cemiterio[0] = cemit[0].size()
		await get_tree().create_timer(1.0).timeout
		get_tree().create_timer(1.5).timeout.connect(func() -> void: escolhido.emit(true))
		await _comprar(0)
		print("REEMB deck=", deck_jog.size(), " cornucopia=", cornucopia[0], " mao=", mao_jog.size())
		await get_tree().create_timer(1.5).timeout
		get_tree().quit()
		return
	if OS.get_environment("GD_TESTE_TOKEN") != "":             # teste visual: invoca o Cão Celestial e abre o zoom
		await motor._invocar_tokens(0, {"nome": "Xiaotian Quan, Cão Celestial", "atk": 2, "vida": 1, "n": 1}, null)
		await get_tree().create_timer(1.0).timeout
		efeitos.zoom = campo_ent[0][_primeiro_ocupado(0)]
		await get_tree().create_timer(1.0).timeout
		get_tree().quit()
		return
	if OS.get_environment("GD_TESTE_CEMIT") != "":             # teste visual: monte do cemitério + carrossel de ver
		var ids := ["tao_lan_caihe", "tao_he_xiangu", "tao_nezha", "tao_zhong_kui", "tao_guan_yu", "tao_lu_dongbin", "tao_flechas_de_houyi"]
		for cid in ids:
			cemit[0].append({"dados": db["cartas"][cid], "no": null})
			await get_tree().create_timer(0.35).timeout
		var c := _nova_carta(proj(DECK_JOG), 1.0)
		c.definir(db["cartas"]["tao_erlang_shen"], 0)
		c.virada_para_cima = true
		await _por_em_campo(c, 0, 1)
		await get_tree().create_timer(0.6).timeout
		motor.morrer(c, false)
		await get_tree().create_timer(2.2).timeout
		abrir_cemiterio(0)
		await get_tree().create_timer(1.6).timeout
		carrossel.vel = 7.0
		await get_tree().create_timer(1.6).timeout
		carrossel.vel = -10.0
		await get_tree().create_timer(2.0).timeout
		await carrossel.fechar()
		await get_tree().create_timer(1.5).timeout
		get_tree().quit()
		return
	if OS.get_environment("GD_TESTE_GALERIA") != "":           # teste visual da galeria do cemitério
		var fal: Array = []
		for cid in ["tao_lu_dongbin", "tao_lan_caihe", "tao_erlang_shen", "tao_nezha", "tao_zhang_guolao", "tao_guan_yu", "tao_xiwangmu", "tao_cao_guojiu"]:
			fal.append({"dados": db["cartas"][cid], "no": null})
		get_tree().create_timer(1.2).timeout.connect(func() -> void: carrossel.vel = -9.0)
		if OS.get_environment("GD_TESTE_ZOOM") != "":
			get_tree().create_timer(2.2).timeout.connect(func() -> void: carrossel.zoom_alvo = 2.2; carrossel.pan = Vector2(0, -60))
		get_tree().create_timer(3.0).timeout.connect(func() -> void:
			carrossel.escolhido = int(roundf(carrossel.pos))
			carrossel.selecionado.emit(carrossel.escolhido))
		print("GALERIA ", await pedir_cemiterio(fal))
		await get_tree().create_timer(1.0).timeout
		get_tree().quit()
		return
	if modo_partida and Sessao.modo == "tutorial":
		tut = Tutorial.new(self)
		await tut.rodar()
		Sessao.modo = ""
		Sessao.resultado = ""
		await get_tree().create_timer(0.8).timeout
		if OS.get_environment("GD_SAIR_NO_FIM") != "":
			get_tree().quit()
			return
		get_tree().change_scene_to_file("res://fluxo.tscn")
		return
	if modo_partida and OS.get_environment("GD_ROTEIRO") != "":
		await _roteiro_efeitos()
		await get_tree().create_timer(1.0).timeout
		get_tree().quit()
		return
	if modo_partida:
		if OS.get_environment("GD_TOQUE_AUTO") != "":
			_responder_auto()
		await _mulligan()
		if online_partida():
			await _mulligan_remoto()
		for lado in 2:                                     # Arquimago usa o mulligan (a mesma regra do jogador)
			if int(nivel_ia[lado]) == 2 and _arq_tem("M") and (lado == 1 or auto_jogador) and Sessao.modo != "tutorial" and not online_partida():
				await _mulligan_ia(lado)
		await _partida()
		Sessao.resultado = "vitoria" if vencedor == 0 else ("derrota" if vencedor == 1 else "empate")
		_registrar_partida()
		if online_partida():
			await _fim_online()
			return
		Sessao.extras["fim_cornucopia"] = cornucopia[0]       # Peregrinação: a vida continua na próxima parada
		if (Sessao.modo != "" and not auto_jogador) or OS.get_environment("GD_RESUMO") != "":
			await get_tree().create_timer(0.6).timeout
			await _resumo()
		if Sessao.modo != "" and OS.get_environment("GD_SAIR_NO_FIM") == "":
			await get_tree().create_timer(0.3).timeout
			get_tree().change_scene_to_file("res://fluxo.tscn")
			return
		if OS.get_environment("GD_SAIR_NO_FIM") != "":
			await get_tree().create_timer(4.0).timeout
			get_tree().quit()
	if OS.get_environment("GD_DEMO") != "":
		await _demo()
		print("DEMO: fim")


# ---------------- perspectiva ----------------
func escala_em(y: float) -> float:
	return lerpf(ESC_TOPO, 1.0, clampf((y - TOPO_Y) / (BASE_Y - TOPO_Y), 0.0, 1.0))


func proj(p: Vector2) -> Vector2:
	return Vector2(CENTRO.x + (p.x - CENTRO.x) * escala_em(p.y), p.y).round()


func quad(c: Vector2, hw: float, hh: float) -> PackedVector2Array:
	return PackedVector2Array([proj(c + Vector2(-hw, -hh)), proj(c + Vector2(hw, -hh)), proj(c + Vector2(hw, hh)), proj(c + Vector2(-hw, hh))])


# ---------------- luz de velas ----------------
func _textura_luz(tam: int) -> GradientTexture2D:
	var g := Gradient.new()
	g.set_color(0, Color(1, 1, 1, 1))
	g.set_color(1, Color(1, 1, 1, 0))
	g.add_point(0.35, Color(1, 1, 1, 0.55))
	var t := GradientTexture2D.new()
	t.gradient = g
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(1.0, 0.5)
	t.width = tam
	t.height = tam
	return t


func _criar_luzes() -> void:
	## Sem velas visíveis: só o reflexo delas. Uma luz grande central vindo de cima, duas laterais e um preenchimento
	## fraco perto da mão. Todas tremulam (energia e posição) como chama de vela.
	var tex := _textura_luz(256)
	var defs := [
		[Vector2(180, -40), 5.8, 1.35, Color(1.0, 0.80, 0.55)],     # central, de cima
		[Vector2(-46, 300), 3.8, 0.75, Color(1.0, 0.70, 0.42)],     # lateral esquerda
		[Vector2(406, 300), 3.8, 0.75, Color(1.0, 0.70, 0.42)],     # lateral direita
		[Vector2(180, 640), 3.0, 0.50, Color(1.0, 0.85, 0.70)],     # preenchimento da mão
	]
	for d in defs:
		var l := PointLight2D.new()
		l.texture = tex
		l.position = d[0]
		l.texture_scale = d[1]
		l.color = d[3]
		l.energy = 0.0
		l.set_meta("liga", 0.0)
		add_child(l)
		luzes.append(l)
		luz_base.append(d[2])
		luz_pos0.append(d[0])


func _process(delta: float) -> void:
	tempo += delta
	# tremulação de vela: duas frequências de ruído somadas (lenta + rápida) na energia e um balanço de 2–3 px
	for i in luzes.size():
		var l: PointLight2D = luzes[i]
		var lento := ruido.get_noise_1d(tempo * 2.0 + i * 37.0)
		var rapido := ruido.get_noise_1d(tempo * 11.0 + i * 91.0)
		l.energy = luz_base[i] * (0.88 + 0.08 * lento + 0.05 * rapido) * float(l.get_meta("liga", 0.0))
		l.position = luz_pos0[i] + Vector2(lento * 3.0, rapido * 2.0)
	# tremor de câmera
	tremor = maxf(0.0, tremor - delta * 14.0)
	camera.offset = Vector2(randf_range(-tremor, tremor), randf_range(-tremor, tremor)).round()
	# animação ociosa: mão respira (1 px), cartas do campo flutuam (1 px), alternando a fase
	for k in mao_jog.size():
		var c: Carta = mao_jog[k]
		if c != segurando:
			c.bob = Vector2(0, sin(tempo * 2.2 + k * 1.3) * 1.2)
	for ch in camada_cartas.get_children():
		if ch is Carta:
			(ch as Carta).aura_arcoiris = false
			(ch as Carta).destaque = 0
	# destaques do turno do jogador: o que dá para jogar (mão) e quem pode atacar (campo); recalcula a cada 0,25 s
	var minha_vez := modo_partida and ativo == 0 and not ocupado and not acabou and segurando == null and alvos_pedidos.is_empty()
	if minha_vez:
		_t_destaque -= delta
		if _t_destaque <= 0.0:
			_t_destaque = 0.25
			_jogaveis.clear()
			for c in mao_jog:
				if _motivo_jogar(c, 0) == "":
					_jogaveis.append(c)
		for c in _jogaveis:
			if is_instance_valid(c) and c in mao_jog:
				if tut == null or (tut.pode_pegar.is_valid() and tut.pode_pegar.call(c, "mao")):
					(c as Carta).destaque = 1
		for c in campo_ent[0]:
			if c != null and (c as Carta).virada_para_cima and motor.pode_atacar(c):
				if tut == null or (tut.pode_pegar.is_valid() and tut.pode_pegar.call(c, "campo")):
					(c as Carta).destaque = 2
	else:
		_t_destaque = 0.0
	for dono in 2:
		for i in 4:
			var c = campo_ent[dono][i]
			if c != null and c != segurando:
				(c as Carta).bob = Vector2(0, sin(tempo * 1.6 + i * 1.9 + dono) * 0.9)
			if c != null:
				var cc: Carta = c
				cc.aura_arcoiris = cc.virada_para_cima and (cc.atk > cc.atk_base or cc.defe > cc.vida_base)
	_atualizar_pilhas()
	_atualizar_relogio()
	if modo_partida:
		_atualizar_zoom(delta)
		_atualizar_previa()
		hud.sem_jogadas = minha_vez and turno_n > 0 and not hud.mulligan and _jogaveis.is_empty() and _t_destaque > 0.0 \
			and not campo_ent[0].any(func(e) -> bool: return e != null and (e as Carta).destaque == 2)
	var vs := get_viewport_rect().size
	alt_util = vs.y
	pos_base = Vector2(roundf((vs.x - 360.0) / 2.0), 0.0)
	# carta segurada: segue o dedo com atraso, inclina conforme a velocidade
	if segurando != null:
		var alvo := ponteiro + Vector2(0, -14)
		var novo := segurando.position.lerp(alvo, 0.35)
		var vel := novo - segurando.position
		segurando.position = novo
		segurando.inclinacao = lerpf(segurando.inclinacao, clampf(-vel.x * 0.045, -0.4, 0.4), 0.3)
		segurando.rotation = lerpf(segurando.rotation, clampf(vel.x * 0.012, -0.2, 0.2), 0.25)
	for d in 2:
		placar_pulo[d] = maxf(0.0, placar_pulo[d] - delta * 3.0)
	placar.queue_redraw()


# ---------------- mesa ----------------
func _desenhar_tabuleiro() -> void:
	var t := tabuleiro
	# piso de pedra grande (a câmera gira e se afasta)
	for gy in range(-50, 90):
		for gx in range(-50, 72):
			var c: Color = PEDRA[(gx * 7 + gy * 13) % 2]
			t.draw_rect(Rect2(gx * 16, gy * 16, 16, 16), c)
			t.draw_rect(Rect2(gx * 16, gy * 16, 16, 1), PEDRA[2])
			t.draw_rect(Rect2(gx * 16 + (8 if gy % 2 else 0), gy * 16, 1, 16), PEDRA[2])
	# tampo de madeira: tábuas convergindo (perspectiva)
	var tampo := PackedVector2Array([proj(Vector2(8, TOPO_Y)), proj(Vector2(352, TOPO_Y)), proj(Vector2(352, BASE_Y)), proj(Vector2(8, BASE_Y))])
	t.draw_colored_polygon(tampo, MADEIRA[1])
	var n_tab := 15
	for k in range(1, n_tab):
		var x := 8 + 344.0 * k / n_tab
		t.draw_line(proj(Vector2(x, TOPO_Y)), proj(Vector2(x, BASE_Y)), MADEIRA[2], 1.0)
	for k in 160:                                                   # veios
		var px := rng_vis.randf_range(10, 350)
		var py := rng_vis.randf_range(TOPO_Y + 4, BASE_Y - 8)
		t.draw_line(proj(Vector2(px, py)), proj(Vector2(px, py + rng_vis.randf_range(4, 14))), MADEIRA[0] if k % 3 else MADEIRA[3], 1.0)
	# veludo da área de jogo + bordado dourado
	var vel := PackedVector2Array([proj(Vector2(22, TOPO_Y + 16)), proj(Vector2(338, TOPO_Y + 16)), proj(Vector2(338, BASE_Y - 16)), proj(Vector2(22, BASE_Y - 16))])
	t.draw_colored_polygon(vel, VELUDO[0])
	for k in 220:                                                   # textura do veludo
		var p := proj(Vector2(rng_vis.randf_range(24, 336), rng_vis.randf_range(TOPO_Y + 18, BASE_Y - 18)))
		t.draw_rect(Rect2(p, Vector2(1, 1)), VELUDO[1])
	t.draw_polyline(vel + PackedVector2Array([vel[0]]), OURO[2], 1.0)
	var vel2 := PackedVector2Array([proj(Vector2(25, TOPO_Y + 19)), proj(Vector2(335, TOPO_Y + 19)), proj(Vector2(335, BASE_Y - 19)), proj(Vector2(25, BASE_Y - 19))])
	t.draw_polyline(vel2 + PackedVector2Array([vel2[0]]), OURO[1], 1.0)
	# moldura dourada da mesa
	t.draw_polyline(tampo + PackedVector2Array([tampo[0]]), OURO[1], 2.0)
	t.draw_polyline(PackedVector2Array([proj(Vector2(8, BASE_Y + 1)), proj(Vector2(352, BASE_Y + 1))]), OURO[2], 1.0)
	# linha central bordada + emblema
	for x in range(30, 331, 4):
		t.draw_rect(Rect2(proj(Vector2(x, LINHA_Y)), Vector2(2, 1)), OURO[1])
	var e := proj(Vector2(180, LINHA_Y))
	_anel(e, 15, OURO[1]); _anel(e, 11, OURO[2])
	t.draw_circle(e, 10.0, VELUDO[2])
	for k in 8:
		var a := TAU * k / 8.0
		t.draw_rect(Rect2((e + Vector2.from_angle(a) * 13).round(), Vector2(1, 1)), OURO[0])
	t.draw_rect(Rect2(e + Vector2(-2, -2), Vector2(5, 5)), OURO[1])
	# espaços entalhados
	for p in ENT_OPON + ENT_JOG:
		_espaco(p, OURO[2])
	for p in SELO_OPON + SELO_JOG:
		_espaco(p, Color("#7a5aa8"))
	for p in [DECK_JOG, DECK_OPON, CEMIT_JOG, CEMIT_OPON]:
		_espaco(p, Color("#8c7a6a"))



func _anel(c: Vector2, r: float, cor: Color) -> void:
	tabuleiro.draw_arc(c, r, 0, TAU, 48, cor, 1.0)


func _espaco(c: Vector2, cor: Color) -> void:
	var hw := Carta.LARG * ESC_CAMPO / 2 + 2
	var hh := Carta.ALT * ESC_CAMPO / 2 + 2
	var q := quad(c, hw, hh)
	tabuleiro.draw_colored_polygon(q, VELUDO[2])
	# entalhe: borda escura em cima/esquerda, clara embaixo/direita
	tabuleiro.draw_line(q[0], q[1], ESCURO, 1.0)
	tabuleiro.draw_line(q[0], q[3], ESCURO, 1.0)
	tabuleiro.draw_line(q[3], q[2], cor, 1.0)
	tabuleiro.draw_line(q[1], q[2], cor, 1.0)
	for qq in q:                                                   # tachas nos cantos
		tabuleiro.draw_rect(Rect2(qq + Vector2(-1, -1), Vector2(2, 2)), cor)


func _placar(p: Vector2, s: String, cor: Color) -> void:
	tabuleiro.draw_rect(Rect2(p + Vector2(-2, -2), Vector2(8 + s.length() * 4 + 3, 9)), ESCURO)
	tabuleiro.draw_rect(Rect2(p + Vector2(0, 1), Vector2(3, 3)), cor)
	var x := p.x + 6
	for ch in s:
		var g: Array = DIGITOS.get(ch, DIGITOS["0"])
		for yy in 5:
			var row: String = g[yy]
			for xx in 3:
				if row[xx] == "1":
					tabuleiro.draw_rect(Rect2(x + xx, p.y + yy, 1, 1), Color("#f2e6c8"))
		x += 4


# ---------------- entrada ----------------
func _intro() -> void:
	camera.zoom = Vector2(0.34, 0.34)
	camera.rotation = -2.5
	var t := create_tween().set_parallel(true)
	t.tween_property(camera, "rotation", 0.0, 2.8).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	t.tween_property(camera, "zoom", Vector2(1.06, 1.06), 2.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(ambiente, "color", Color(0.40, 0.33, 0.44), 1.6).set_delay(0.2)
	t.chain().tween_property(camera, "zoom", Vector2.ONE, 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	# luz central acende devagar; laterais acendem com um estouro de chama (110%) e assentam
	_acender(0, 0.5, 1.4)
	_acender(1, 1.1, 0.5)
	_acender(2, 1.35, 0.5)
	_acender(3, 1.0, 1.2)
	await t.finished


func _acender(i: int, atraso: float, dur: float) -> void:
	await get_tree().create_timer(atraso).timeout
	var l: PointLight2D = luzes[i]
	var t := create_tween()
	t.tween_method(func(v: float) -> void: l.set_meta("liga", v), 0.0, 1.25, dur * 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_method(func(v: float) -> void: l.set_meta("liga", v), 1.25, 1.0, dur * 0.6).set_trans(Tween.TRANS_SINE)


# ---------------- utilidades de movimento ----------------
func _nova_carta(pos: Vector2, esc: float) -> Carta:
	var c := Carta.new()
	c.position = pos
	c.scale = Vector2(esc, esc)
	c.luz = LUZ_PRINCIPAL
	camada_cartas.add_child(c)
	return c


## Move em arco (Bézier quadrática): sobe `altura` px no meio do caminho e "levanta" a carta (sombra) junto.
func _arco(c: Carta, destino: Vector2, dur: float, altura: float, rot_final: float, esc_final: float,
		trans := Tween.TRANS_CUBIC, ease := Tween.EASE_IN_OUT) -> Tween:
	var ini := c.position
	var ctrl := (ini + destino) / 2 + Vector2(0, -altura)
	var rot_ini := c.rotation
	var esc_ini := c.scale.x
	var t := create_tween()
	t.tween_method(func(u: float) -> void:
		var a := ini.lerp(ctrl, u)
		var b := ctrl.lerp(destino, u)
		c.position = a.lerp(b, u)
		c.rotation = lerp_angle(rot_ini, rot_final, u)
		var s := lerpf(esc_ini, esc_final, u) * (1.0 + 0.10 * sin(u * PI) * clampf(altura / 30.0, 0, 1))
		c.scale = Vector2(s, s)
		c.levantada = sin(u * PI) * clampf(altura / 30.0, 0, 1), 0.0, 1.0, dur).set_trans(trans).set_ease(ease)
	return t


func _pos_monte(i: int) -> Vector2:
	return CENTRO + Vector2(0, -int(i / 3))          # 1 px de grossura a cada 3 cartas


func _z_monte() -> void:
	for i in deck_jog.size():
		var c: Carta = deck_jog[i]
		c.z_index = i
		c.empilhada = i > 0


# ---------------- deck: cascata ----------------
func _cascata_deck() -> void:
	for i in N_CARTAS:
		var c := _nova_carta(Vector2(CENTRO.x + rng_vis.randf_range(-70, 70), -90), 1.0)
		c.rotation = rng_vis.randf_range(-0.6, 0.6)
		c.z_index = i
		deck_jog.append(c)
		_arco(c, _pos_monte(i), 0.42, 40, rng_vis.randf_range(-0.04, 0.04), 1.0, Tween.TRANS_QUAD, Tween.EASE_OUT)
		await get_tree().create_timer(0.03).timeout
	await get_tree().create_timer(0.45).timeout
	_z_monte()


func _bater_monte() -> void:
	# alinha e dá uma batidinha (escala 1 → 0,96 → 1)
	for i in deck_jog.size():
		var c: Carta = deck_jog[i]
		var t := create_tween().set_parallel(true)
		t.tween_property(c, "position", _pos_monte(i), 0.1)
		t.tween_property(c, "rotation", 0.0, 0.1)
	await get_tree().create_timer(0.12).timeout
	for c in deck_jog:
		var t := create_tween()
		t.tween_property(c, "scale", Vector2(1.0, 0.94), 0.06)
		t.tween_property(c, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(0.25).timeout


# ---------------- embaralhar ----------------
func _riffle() -> void:
	if not _som.playing:
		tocar_som("embaralhar_1")
	var meio := deck_jog.size() / 2 + rng_vis.randi_range(-3, 3)
	var esq: Array[Carta] = deck_jog.slice(0, meio)
	var dir: Array[Carta] = deck_jog.slice(meio)
	# separa em duas metades que levantam e inclinam
	for i in esq.size():
		var c: Carta = esq[i]
		c.empilhada = i > 0
		_arco(c, CENTRO + Vector2(-64, -int(i / 3)), 0.3, 14, -0.16, 1.0)
	for i in dir.size():
		var c: Carta = dir[i]
		c.empilhada = i > 0
		c.z_index = i
		_arco(c, CENTRO + Vector2(64, -int(i / 3)), 0.3, 14, 0.16, 1.0)
	await get_tree().create_timer(0.38).timeout
	# intercala: cai 1–3 cartas de cada lado, de baixo para cima, em arco curto
	var nova: Array[Carta] = []
	var a := 0
	var b := 0
	while a < esq.size() or b < dir.size():
		var lado_esq := (rng_vis.randf() < 0.5 and a < esq.size()) or b >= dir.size()
		for k in rng_vis.randi_range(1, 3):
			if lado_esq and a < esq.size():
				nova.append(esq[a]); a += 1
			elif not lado_esq and b < dir.size():
				nova.append(dir[b]); b += 1
	for i in nova.size():
		var c: Carta = nova[i]
		c.z_index = 200 + i
		c.empilhada = false
		_arco(c, _pos_monte(i) + Vector2(rng_vis.randi_range(-2, 2), 0), 0.16, 8, rng_vis.randf_range(-0.05, 0.05), 1.0, Tween.TRANS_QUAD, Tween.EASE_IN)
		await get_tree().create_timer(0.022).timeout
	await get_tree().create_timer(0.2).timeout
	deck_jog = nova
	_z_monte()


func _cortes() -> void:
	# 3 cortes: um bloco de baixo sai pela direita, sobe e cai por cima do monte
	for k in 3:
		var tam := rng_vis.randi_range(7, 12)
		var bloco: Array[Carta] = deck_jog.slice(0, tam)
		for c in bloco:
			deck_jog.erase(c)
		for i in bloco.size():
			var c: Carta = bloco[i]
			c.z_index = 300 + i
			c.empilhada = i > 0
			_arco(c, CENTRO + Vector2(58, -30 - int(i / 2)), 0.18, 10, 0.12, 1.0, Tween.TRANS_QUAD, Tween.EASE_OUT)
		for i in deck_jog.size():
			var c: Carta = deck_jog[i]
			create_tween().tween_property(c, "position", _pos_monte(i), 0.14)
		await get_tree().create_timer(0.22).timeout
		deck_jog.append_array(bloco)
		for i in bloco.size():
			var c: Carta = bloco[i]
			_arco(c, _pos_monte(deck_jog.size() - bloco.size() + i), 0.2, 6, 0.0, 1.0, Tween.TRANS_QUAD, Tween.EASE_IN)
		await get_tree().create_timer(0.26).timeout
		_z_monte()


# ---------------- monte → espaço do deck ----------------
func _ir_para_deck() -> void:
	var destino := proj(DECK_JOG)
	var esc := ESC_CAMPO * escala_em(DECK_JOG.y)
	for i in deck_jog.size():
		var c: Carta = deck_jog[i]
		_arco(c, destino + Vector2(0, -int(i / 3)), 0.5, 26, 0.0, esc)
		await get_tree().create_timer(0.008).timeout
	# deck do oponente desliza de fora da tela pelo alto-esquerdo
	var dest_o := proj(DECK_OPON)
	var esc_o := ESC_CAMPO * escala_em(DECK_OPON.y)
	for i in N_CARTAS:
		var c := _nova_carta(Vector2(-60, -80), esc_o)
		c.dono = 1
		c.dono_real = 1                                  # verso do oponente (o jogador usa o verso equipado)
		c.rotation = -0.5
		c.z_index = i
		c.empilhada = i > 0
		deck_opon.append(c)
		_arco(c, dest_o + Vector2(0, -int(i / 3)), 0.55, 30, 0.0, esc_o, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		await get_tree().create_timer(0.006).timeout
	await get_tree().create_timer(0.65).timeout
	if modo_partida:
		if Sessao.modo == "tutorial":                    # tutorial: ordem fixa (sem embaralhar)
			for i in deck_jog.size():
				deck_jog[i].definir(db["cartas"][Sessao.deck_jogador[i]], 0)
			for i in deck_opon.size():
				deck_opon[i].definir(db["cartas"][Sessao.deck_oponente[i]], 1)
		elif Sessao.modo != "":
			_dar_ids(deck_jog, Sessao.deck_jogador, 0)
			_dar_ids(deck_opon, Sessao.deck_oponente, 1)
			_aplicar_extras_deck()
		else:
			_dar_dados(deck_jog, OS.get_environment("GD_DECK_A") if OS.get_environment("GD_DECK_A") != "" else "indigena", 0)
			_dar_dados(deck_opon, OS.get_environment("GD_DECK_B") if OS.get_environment("GD_DECK_B") != "" else "cristianismo", 1)


# ---------------- mão inicial ----------------
func _layout_mao(n: int, k: int) -> Array:
	var meio := (n - 1) / 2.0
	var d := k - meio
	return [Vector2(180 + d * 52, 600 + absf(d) * absf(d) * 3), deg_to_rad(d * 7.0)]


func _layout_mao_opon(n: int, k: int) -> Array:
	var meio := (n - 1) / 2.0
	var d := k - meio
	return [Vector2(180 + d * 34, -6 - absf(d) * absf(d) * 2), PI - deg_to_rad(d * 6.0)]


func _rearrumar(mao: Array[Carta], layout: Callable, esc: float) -> void:
	for k in mao.size():
		var c: Carta = mao[k]
		var lay: Array = layout.call(mao.size(), k)
		var t := create_tween().set_parallel(true)
		t.tween_property(c, "position", lay[0], 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		t.tween_property(c, "rotation", lay[1], 0.25)
		t.tween_property(c, "scale", Vector2(esc, esc), 0.25)


func _comprar_mao() -> void:
	for k in MAO_INICIAL:
		# jogador: topo levanta, viaja em arco e vira no ar
		var c: Carta = deck_jog.pop_back()
		c.empilhada = false
		c.z_index = 500 + k
		if not modo_partida:
			var ficha: Array = [["entidade", 3, 4], ["entidade", 2, 3], ["selo", 0, 0], ["rito", 0, 0]][k]
			c.tipo = ficha[0]; c.atk = ficha[1]; c.defe = ficha[2]; c.dono = 0
		mao_jog.append(c)
		var t0 := create_tween()
		t0.tween_property(c, "position:y", c.position.y - 10, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		t0.parallel().tween_property(c, "levantada", 0.6, 0.12)
		await t0.finished
		var lay: Array = _layout_mao(mao_jog.size(), mao_jog.size() - 1)
		_arco(c, lay[0], 0.42, 40, lay[1], 1.0)
		get_tree().create_timer(0.1).timeout.connect(func() -> void: c.virar(0.26))
		var anteriores: Array[Carta] = mao_jog.slice(0, mao_jog.size() - 1)
		for kk in anteriores.size():
			var a: Carta = anteriores[kk]
			var l2: Array = _layout_mao(mao_jog.size(), kk)
			var t := create_tween().set_parallel(true)
			t.tween_property(a, "position", l2[0], 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			t.tween_property(a, "rotation", l2[1], 0.3)
		# oponente: compra para cima, sem virar
		var o: Carta = deck_opon.pop_back()
		o.empilhada = false
		o.z_index = 500 + k
		mao_opon.append(o)
		var lo: Array = _layout_mao_opon(mao_opon.size(), mao_opon.size() - 1)
		_arco(o, lo[0], 0.42, 20, lo[1], 0.62)
		_rearrumar(mao_opon.slice(0, mao_opon.size() - 1), _layout_mao_opon, 0.62)
		await get_tree().create_timer(0.5).timeout
	# a mão "assenta": batida leve de escala em sequência
	for c in mao_jog:
		var t := create_tween()
		t.tween_property(c, "scale", Vector2(1.06, 1.06), 0.08)
		t.tween_property(c, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		await get_tree().create_timer(0.05).timeout
	await get_tree().create_timer(0.4).timeout


# ================= placar dinâmico =================
func _pos_placar(dono: int) -> Vector2:
	return proj(Vector2(34, LINHA_Y + 8)) if dono == 0 else proj(Vector2(34, LINHA_Y - 14))


func _desenhar_placar() -> void:
	_desenhar_retratos()
	for d in 2:
		var p := _pos_placar(d)
		var s := str(maxi(cornucopia[d], 0))
		var pulo: float = placar_pulo[d]
		var esc := 1 + int(pulo > 0.5)
		var cor := Color("#ff6a6a") if pulo > 0.0 else Color("#f2e6c8")
		placar.draw_rect(Rect2(p + Vector2(-2, -2), Vector2(9 + PixelFonte.largura(s, esc), 5 * esc + 4)), ESCURO)
		placar.draw_rect(Rect2(p + Vector2(0, 1), Vector2(3, 3)), Color("#e86a6a"))
		PixelFonte.desenhar(placar, p + Vector2(6, -(esc - 1) * 2), s, cor, esc)
		if modo_partida:
			var pf := proj(Vector2(300, LINHA_Y + 8)) if d == 0 else proj(Vector2(300, LINHA_Y - 14))
			var sf := "%d/%d" % [fe[d], fe_max[d]]
			placar.draw_rect(Rect2(pf + Vector2(-2, -2), Vector2(9 + PixelFonte.largura(sf), 9)), ESCURO)
			placar.draw_rect(Rect2(pf + Vector2(0, 1), Vector2(3, 3)), Color("#7aa8ff"))
			PixelFonte.desenhar(placar, pf + Vector2(6, 0), sf, Color("#cfe0ff"))
	if modo_partida:
		var r := botao_fim
		var vez := ativo == 0 and not acabou
		var ia := ativo == 1 and not acabou
		if vez and hud.sem_jogadas:                      # sem jogadas: o botão pulsa em dourado
			var a := 0.35 + 0.35 * sin(tempo * 5.0)
			placar.draw_rect(r.grow(3), Color(1.0, 0.85, 0.4, a))
		placar.draw_rect(r.grow(1), ESCURO)
		placar.draw_rect(r, Color("#5a3a1a") if vez else (Color("#3a2a50") if ia and acelerar_ia else Color("#2a2430")))
		placar.draw_rect(Rect2(r.position, Vector2(r.size.x, 1)), OURO[1] if vez else (Color("#b8a0ff") if ia else Color("#4a4450")))
		if (vez or online_partida()) and relogio_ativo and restante < AVISO_TEMPO:      # corda queimando: últimos 20 s do turno
			var fr := clampf(restante / AVISO_TEMPO, 0.0, 1.0)
			var corda := Rect2(r.position.x, r.position.y - 7, r.size.x * fr, 3)
			placar.draw_rect(Rect2(r.position.x, r.position.y - 7, r.size.x, 3), Color(0.1, 0.06, 0.05, 0.8))
			placar.draw_rect(corda, Color("#c8a060"))
			var ponta := Vector2(corda.end.x, corda.position.y + 1)
			var chama := 0.5 + 0.5 * sin(tempo * 25.0)
			placar.draw_circle(ponta, 2.5 + chama, Color(1.0, 0.55, 0.15, 0.9))
			placar.draw_circle(ponta, 1.5, Color(1.0, 0.95, 0.6))
			PixelFonte.centrado(placar, Vector2(r.get_center().x, r.position.y - 13), "%d" % ceili(restante), Color(1.0, 0.7, 0.4), 1)
		var rot := "FIM TURNO" if vez else (("RÁPIDO" if acelerar_ia else ">> RÁPIDO") if ia else "AGUARDE")
		PixelFonte.centrado(placar, r.get_center(), Sessao.t(rot), Color("#ffe39a") if vez else (Color("#d8c8ff") if ia else Color("#8a8090")))


# ================= posições do campo =================
func pos_ent(dono: int, i: int) -> Vector2:
	return proj((ENT_JOG if dono == 0 else ENT_OPON)[i])


func pos_selo(dono: int, i: int) -> Vector2:
	return proj((SELO_JOG if dono == 0 else SELO_OPON)[i])


func esc_em(p: Vector2) -> float:
	return ESC_CAMPO * escala_em(p.y)


func _rect_espaco(p: Vector2) -> Rect2:
	var e := esc_em(p)
	var sz := Vector2(Carta.LARG, Carta.ALT) * e
	return Rect2(p - sz / 2, sz).grow(3)


# ================= entrada (toque / mouse) =================
func _unhandled_input(ev: InputEvent) -> void:
	# no celular cada toque chega também como mouse emulado (device -1): sem isto o toque contava duas vezes
	if (ev is InputEventMouseButton or ev is InputEventMouseMotion) and ev.device == InputEvent.DEVICE_ID_EMULATION:
		return
	var pos_ev: Vector2 = ev.position if "position" in ev else Vector2.ZERO
	if perg.aberto():                            # regras/resumo por cima de tudo (CanvasLayer: posição de tela)
		if "position" in ev:
			perg.entrada(ev, pos_ev - pos_base)
		return
	if carrossel.aberto():                       # carrossel recebe o evento cru (pinça, roda, arraste)
		carrossel.evento(ev, get_canvas_transform().affine_inverse() * pos_ev)
		return
	var p: Vector2 = get_canvas_transform().affine_inverse() * pos_ev
	if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT or ev is InputEventScreenTouch:
		if ev.pressed:
			pressionar(p)
		else:
			soltar(p)
	elif ev is InputEventMouseMotion or ev is InputEventScreenDrag:
		mover(p)


func pressionar(p: Vector2) -> void:
	ponteiro = p
	if carrossel.aberto():
		carrossel.pressionar(p)
		return
	if modo_partida and hud.pressionar(p):
		return
	if hud.mulligan:                            # mão inicial: marcar até 2 cartas ou tocar um dos botões
		for b in efeitos.escolha:
			if (b["rect"] as Rect2).grow(3).has_point(p):
				escolhido.emit(b["valor"])
				return
		for k in range(mao_jog.size() - 1, -1, -1):
			var cm: Carta = mao_jog[k]
			if cm.contem(p):
				if cm in hud.marcadas:
					hud.marcadas.erase(cm)
				elif hud.marcadas.size() < MULLIGAN_MAX:
					hud.marcadas.append(cm)
				Sessao.vibrar(10, 0.35)
				efeitos.escolha[1]["texto"] = Sessao.t("TROCAR (%d)") % hud.marcadas.size()
				return
		return
	if zoom_travado:                          # qualquer toque fecha a carta ampliada
		zoom_travado = false
		efeitos.zoom = null
		_ignorar_soltar = true
		return
	if tut != null and tut.esperando_toque:     # tutorial: toque avança a fala do Silas
		tut.toque()
		return
	if not alvos_pedidos.is_empty():            # escolhendo alvo: toca um destacado ou o botão PULAR
		for b in efeitos.escolha:
			if (b["rect"] as Rect2).grow(3).has_point(p):
				alvo_tocado.emit(null)
				return
		for c in alvos_pedidos:
			if is_instance_valid(c) and (c as Carta).contem(p):
				alvo_tocado.emit(c)
				return
		return
	if not efeitos.escolha.is_empty():
		for b in efeitos.escolha:
			if (b["rect"] as Rect2).grow(3).has_point(p):
				escolhido.emit(b["valor"])
				return
		return
	if modo_partida and botao_fim.grow(4).has_point(p):
		if tut != null and not tut.fim_ok:
			return
		if ativo == 0 and not ocupado and not acabou:
			Sessao.vibrar(10, 0.4)
			fim_turno_pedido.emit()
		elif ativo == 1 and not acabou:            # turno do oponente: liga/desliga o modo rápido
			acelerar_ia = not acelerar_ia
			Sessao.vibrar(10, 0.4)
			aplicar_tempo()
		return
	if modo_partida and segurando == null and alvos_pedidos.is_empty() and efeitos.escolha.is_empty() and tut == null:
		for d in 2:                               # tocar numa pilha de cemitério abre o carrossel
			if not cemit[d].is_empty() and _rect_espaco(proj(CEMIT_JOG if d == 0 else CEMIT_OPON)).grow(6).has_point(p):
				abrir_cemiterio(d)
				return
	if ocupado or segurando != null or (modo_partida and (ativo != 0 or acabou)):
		_tentar_zoom(p)
		return
	for k in range(mao_jog.size() - 1, -1, -1):
		var c: Carta = mao_jog[k]
		if c.contem(p):
			_pegar(c, "mao", k)
			return
	for i in 4:
		var c = campo_ent[0][i]
		if c != null and (c as Carta).contem(p):
			_pegar(c, "campo", i)
			return
	_tentar_zoom(p)


func mover(p: Vector2) -> void:
	ponteiro = p
	if carrossel.aberto():
		carrossel.mover(p)
		return


func soltar(p: Vector2) -> void:
	ponteiro = p
	if carrossel.aberto():
		carrossel.soltar(p)
		return
	zoom_pendente = null
	if _ignorar_soltar:
		_ignorar_soltar = false
		return
	if not zoom_travado:
		efeitos.zoom = null
	if segurando == null:
		return
	var c := segurando
	segurando = null
	efeitos.destaques.clear()
	ocupado = true
	if tut != null and tut.pode_soltar.is_valid() and not tut.pode_soltar.call(c, origem, p):
		if origem == "mao":
			await _recusar(c)
		else:
			await _voltar_ao_espaco(c)
		ocupado = false
		return
	if origem == "mao":
		await _soltar_da_mao(c, p)
	else:
		await _soltar_do_campo(c, p)
	ocupado = false


func _pegar(c: Carta, de: String, idx: int) -> void:
	if tut != null and not (tut.pode_pegar.is_valid() and tut.pode_pegar.call(c, de)):
		_tentar_zoom(ponteiro)                   # tutorial: carta fora do roteiro só pode ser lida (segurar)
		return
	Sessao.vibrar(12, 0.3)
	segurando_t = 0.0
	segurando_ini = ponteiro
	segurando = c
	origem = de
	origem_idx = idx
	c.z_index = 800
	var t := create_tween().set_parallel(true)
	t.tween_property(c, "scale", Vector2(1.15, 1.15), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(c, "levantada", 1.0, 0.12)
	efeitos.destaques.clear()
	if de == "mao" and modo_partida:
		_destacar_jogada(c)
	elif de == "mao":
		if c.tipo == "entidade":
			for i in 4:
				if campo_ent[0][i] == null:
					efeitos.destaques.append(_rect_espaco(pos_ent(0, i)))
		elif c.tipo == "selo":
			for i in 2:
				if campo_selo[0][i] == null:
					efeitos.destaques.append(_rect_espaco(pos_selo(0, i)))
		else:
			for i in 4:
				if campo_ent[1][i] != null:
					efeitos.destaques.append(_rect_espaco(pos_ent(1, i)))
	else:
		for i in 4:
			if campo_ent[0][i] == null:
				efeitos.destaques.append(_rect_espaco(pos_ent(0, i)))
			if campo_ent[1][i] != null:
				efeitos.destaques.append(_rect_espaco(pos_ent(1, i)))
		if _campo_vazio(1):
			efeitos.destaques.append(Rect2(_pos_placar(1) + Vector2(-6, -6), Vector2(30, 18)))


func _campo_vazio(dono: int) -> bool:
	for i in 4:
		if campo_ent[dono][i] != null:
			return false
	return true


func _espaco_sob(p: Vector2, posicoes: Callable, n: int, livre: Array) -> int:
	for i in n:
		if livre[i] == null and _rect_espaco(posicoes.call(i)).grow(8).has_point(p):
			return i
	return -1


func _inimigo_sob(p: Vector2) -> int:
	for i in 4:
		var c = campo_ent[1][i]
		if c != null and _rect_espaco(pos_ent(1, i)).grow(6).has_point(p):
			return i
	return -1


# ================= soltar =================
func _soltar_da_mao(c: Carta, p: Vector2) -> void:
	if modo_partida:
		await _soltar_da_mao_partida(c, p)
		return
	if c.tipo == "entidade":
		var i := _espaco_sob(p, func(i: int) -> Vector2: return pos_ent(0, i), 4, campo_ent[0])
		if i < 0:
			await _recusar(c); return
		mao_jog.erase(c)
		campo_ent[0][i] = c
		_rearrumar_mao()
		var cima: bool = await _escolher_face(c, pos_ent(0, i))
		await _cair(c, pos_ent(0, i), cima)
	elif c.tipo == "selo":
		var i := _espaco_sob(p, func(i: int) -> Vector2: return pos_selo(0, i), 2, campo_selo[0])
		if i < 0:
			await _recusar(c); return
		mao_jog.erase(c)
		campo_selo[0][i] = c
		_rearrumar_mao()
		await _cair(c, pos_selo(0, i), false)                # Selo: sempre virado para baixo
	else:
		var alvo := _inimigo_sob(p)
		if alvo < 0:
			await _recusar(c); return
		mao_jog.erase(c)
		_rearrumar_mao()
		await _lancar_rito(c, alvo)


func _soltar_do_campo(c: Carta, p: Vector2) -> void:
	var livre := _espaco_sob(p, func(i: int) -> Vector2: return pos_ent(0, i), 4, campo_ent[0])
	var inimigo := _inimigo_sob(p)
	if livre >= 0:                                                       # mudar de lugar
		_enviar({"tipo": "mover", "de": origem_idx, "para": livre})
		campo_ent[0][origem_idx] = null
		campo_ent[0][livre] = c
		var dest := pos_ent(0, livre)
		await _arco(c, dest, 0.28, 18, 0.0, esc_em(dest)).finished
		_impacto(c, dest, 0.5)
	elif inimigo >= 0 and c.virada_para_cima:
		var motivo := _pode_atacar(c, campo_ent[1][inimigo])
		if motivo != "":
			efeitos.numero(c.position + Vector2(0, -40), motivo, Color("#ffd0a0"), 1)
			await _recusar(c); return
		_enviar({"tipo": "atacar", "de": origem_idx, "alvo": inimigo})
		await _voltar_ao_espaco(c)
		await _atacar(c, campo_ent[1][inimigo])
	elif _campo_vazio(1) and c.virada_para_cima and p.y < LINHA_Y:
		var motivo := _pode_atacar(c, null)
		if motivo != "":
			efeitos.numero(c.position + Vector2(0, -40), motivo, Color("#ffd0a0"), 1)
			await _recusar(c); return
		_enviar({"tipo": "golpe", "de": origem_idx})
		await _voltar_ao_espaco(c)
		await _golpe_direto(c, 1)
	else:
		await _recusar(c)


func _voltar_ao_espaco(c: Carta) -> void:
	var dest := pos_ent(0, origem_idx)
	var t := create_tween().set_parallel(true)
	t.tween_property(c, "position", dest, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(c, "scale", Vector2.ONE * esc_em(dest), 0.14)
	t.tween_property(c, "rotation", 0.0, 0.14)
	t.tween_property(c, "inclinacao", 0.0, 0.14)
	t.tween_property(c, "levantada", 0.0, 0.14)
	await t.finished
	c.z_index = 100


## Soltou em lugar inválido: sacode (6 batidas em 0,2 s) e volta para a origem como puxada por um ímã (elástico 0,5 s).
func _recusar(c: Carta) -> void:
	Sessao.vibrar_pulsos(2, 15, 0.5)
	var base := c.position
	var t := create_tween()
	for dx in [5, -5, 4, -4, 2, 0]:
		t.tween_property(c, "position", base + Vector2(dx, 0), 0.034)
	t.parallel().tween_property(c, "inclinacao", 0.0, 0.2)
	await t.finished
	efeitos.faiscas(c.position, 6, Color("#ff8a6a"))
	var dest: Vector2
	var rot := 0.0
	var esc := 1.0
	if origem == "mao":
		var lay: Array = _layout_mao(mao_jog.size(), mao_jog.find(c))
		dest = lay[0]; rot = lay[1]
	else:
		dest = pos_ent(0, origem_idx); esc = esc_em(dest)
	var t2 := create_tween().set_parallel(true)
	t2.tween_property(c, "position", dest, 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	t2.tween_property(c, "rotation", rot, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t2.tween_property(c, "scale", Vector2(esc, esc), 0.3)
	t2.tween_property(c, "levantada", 0.0, 0.3)
	await t2.finished
	c.z_index = 500 + mao_jog.find(c) if origem == "mao" else 100


func _rearrumar_mao() -> void:
	for k in mao_jog.size():
		var c: Carta = mao_jog[k]
		c.z_index = 500 + k
		var lay: Array = _layout_mao(mao_jog.size(), k)
		var t := create_tween().set_parallel(true)
		t.tween_property(c, "position", lay[0], 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		t.tween_property(c, "rotation", lay[1], 0.3)


## A carta paira 26 px acima do espaço e aparecem os botões CIMA/BAIXO; devolve true para cima.
func _escolher_face(c: Carta, dest: Vector2) -> bool:
	var t := create_tween().set_parallel(true)
	t.tween_property(c, "position", dest + Vector2(0, -26), 0.18).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(c, "rotation", 0.0, 0.18)
	t.tween_property(c, "inclinacao", 0.0, 0.18)
	t.tween_property(c, "scale", Vector2(1.1, 1.1), 0.18)
	await t.finished
	var y := dest.y - 26 - Carta.ALT * 0.55 - 14
	efeitos.escolha = [
		{"rect": Rect2(dest.x - 38, y, 34, 11), "texto": "CIMA", "valor": true},
		{"rect": Rect2(dest.x + 4, y, 34, 11), "texto": "BAIXO", "valor": false}]
	var v: bool = await escolhido
	efeitos.escolha.clear()
	return v


## Queda no espaço: sobe 24 px e cresce (125%), cai em 0,16 s acelerando, achata no impacto e solta poeira.
func _cair(c: Carta, dest: Vector2, para_cima: bool) -> void:
	c.z_index = 700
	if c.virada_para_cima != para_cima:
		await c.virar(0.2)
	var e := esc_em(dest)
	var t := create_tween().set_parallel(true)
	t.tween_property(c, "position", dest + Vector2(0, -24), 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(c, "scale", Vector2(e, e) * 1.25, 0.12)
	t.tween_property(c, "rotation", 0.0, 0.12)
	t.tween_property(c, "inclinacao", 0.0, 0.12)
	await t.finished
	var t2 := create_tween().set_parallel(true)
	t2.tween_property(c, "position", dest, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t2.tween_property(c, "scale", Vector2(e, e), 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t2.tween_property(c, "levantada", 0.0, 0.16)
	await t2.finished
	_impacto(c, dest, 1.0)
	Sessao.vibrar(20, 0.5)
	c.z_index = 100


func _impacto(c: Carta, dest: Vector2, forca: float) -> void:
	var e := c.scale.x
	var t := create_tween()
	t.tween_property(c, "scale", Vector2(e * 1.08, e * 0.9), 0.05)
	t.tween_property(c, "scale", Vector2(e, e), 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	chao.onda_poeira(dest, Carta.LARG * e, forca)
	chao.poeira(dest + Vector2(0, Carta.ALT * e / 2), int(10 * forca))
	tremor = maxf(tremor, 2.0 * forca)


# ================= combate =================
func _remover_do_campo(c: Carta) -> int:
	for i in 4:
		if campo_ent[c.dono][i] == c:
			campo_ent[c.dono][i] = null
			return i
	return -1


## Ataque entre Entidades: recua 8 px (0,14 s), dispara até o alvo (0,11 s), impacto com clarão, faíscas, números de dano,
## tremor de 3 px, volta (0,3 s). Quem zerar a Vida é destruído.
func _atacar(c: Carta, alvo: Carta) -> void:
	c.atacou = true
	if modo_partida:
		_conta(c.dono, "ataques")
		hud.registrar(c.dono, c.id, "ataque", alvo.id)
		if not await motor.antes_do_ataque(c, alvo):          # Selo/efeito cancelou o ataque
			await _checar_fim()
			return
	var ini := c.position
	var dir := (alvo.position - ini).normalized()
	c.z_index = 750
	var t := create_tween().set_parallel(true)
	t.tween_property(c, "position", ini - dir * 8, 0.14).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.tween_property(c, "scale", c.scale * 1.12, 0.14)
	t.tween_property(c, "levantada", 0.8, 0.14)
	await t.finished
	var contato := alvo.position - dir * 22
	var t2 := create_tween()
	t2.tween_property(c, "position", contato, 0.11).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	await t2.finished
	# impacto (simultâneo)
	var da := c.atk
	var dd := alvo.atk
	alvo.dano += da
	c.dano += dd
	tremor = 3.5
	Sessao.vibrar(35, 0.7)
	efeitos.flash(Color.WHITE, 0.18)
	efeitos.faiscas((contato + alvo.position) / 2, 18)
	efeitos.numero(alvo.position + Vector2(0, -20), "-%d" % da, Color("#ff6a6a"))
	if dd > 0:
		efeitos.numero(c.position + Vector2(0, -20), "-%d" % dd, Color("#ff6a6a"))
	_piscar(alvo); _piscar(c)
	_sacudir(alvo, 3.0)
	var t3 := create_tween().set_parallel(true)
	t3.tween_property(c, "position", ini, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t3.tween_property(c, "scale", Vector2.ONE * esc_em(ini), 0.3)
	t3.tween_property(c, "levantada", 0.0, 0.3)
	await t3.finished
	c.z_index = 100
	if modo_partida:
		await motor.apos_combate(c, alvo, da, dd)
		await _checar_fim()
		return
	if alvo.vida() <= 0:
		await _destruir(alvo)
	if c.vida() <= 0:
		await _destruir(c)


func _piscar(c: Carta) -> void:
	var t := create_tween()
	t.tween_property(c, "brilho", 0.9, 0.04)
	t.tween_property(c, "brilho", 0.0, 0.22)


func _sacudir(c: Carta, amp: float) -> void:
	var base := c.position
	var t := create_tween()
	for k in 6:
		t.tween_property(c, "position", base + Vector2(amp * (1 if k % 2 == 0 else -1) * (1.0 - k / 6.0), 0), 0.035)
	t.tween_property(c, "position", base, 0.035)


## Derrota da carta: treme, pisca 2×, estilhaça em ~70 fragmentos e reaparece pequena no cemitério do dono.
func _destruir(c: Carta) -> void:
	_remover_do_campo(c)
	if modo_partida:                       # o motor já decidiu (Renascer, token, cemitério); aqui é só o visual
		c.em_campo = false
		c.dono = c.dono_real
	_sacudir(c, 2.0)
	for k in 2:
		var t := create_tween()
		t.tween_property(c, "brilho", 1.0, 0.06)
		t.tween_property(c, "brilho", 0.2, 0.08)
		await t.finished
	efeitos.estilhacar(c.position, c.cores_estilhaco(), int(Carta.LARG * c.scale.x), int(Carta.ALT * c.scale.y))
	Sessao.vibrar(45, 0.8)
	tremor = 2.5
	c.visible = false
	await get_tree().create_timer(0.35).timeout
	var cem := proj(CEMIT_JOG if c.dono == 0 else CEMIT_OPON)
	var k_pilha := _indice_cemit(c)
	c.position = cem + Vector2(0, -_altura_pilha(k_pilha))
	c.rotation = 0.0
	c.brilho = 0.0
	c.dano = 0
	c.empilhada = false
	c.scale = Vector2.ZERO
	c.visible = true
	c.z_index = 60
	cemiterio[c.dono] += 1
	if not c.virada_para_cima:
		c.virada_para_cima = true
	if modo_partida:
		c.resetar()
	var tw := create_tween()
	tw.tween_property(c, "scale", Vector2.ONE * esc_em(cem), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_callback(func() -> void:                   # assentou: a pilha organizada passa a mostrá-la
		if is_instance_valid(c) and not c.em_campo and _indice_cemit(c) >= 0:
			c.visible = false)


# ---------- pilha do cemitério (organizada, na ordem real de entrada) ----------
const PILHA_MAX := 12                     # no máximo 12 px de espessura visível (1 px por carta)


func _altura_pilha(k: int) -> float:
	return float(mini(k, PILHA_MAX))


func _indice_cemit(c: Carta) -> int:
	for d in 2:
		for k in cemit[d].size():
			if is_same(cemit[d][k]["no"], c):
				return k
	return -1


## Topo visível de cada pilha: a última entrada que já assentou (as que ainda estão voando não contam).
func _topo_assentado(d: int) -> int:
	for k in range(cemit[d].size() - 1, -1, -1):
		var no = cemit[d][k]["no"]
		if no == null or not is_instance_valid(no) or not (no as Carta).visible or (no as Carta).em_campo:
			return k
	return -1


func _atualizar_pilhas() -> void:
	if not modo_partida:
		return
	if pilha_cem == null:
		pilha_cem = Node2D.new()
		pilha_cem.z_index = 38
		pilha_cem.draw.connect(_desenhar_pilhas)
		camada_cartas.add_child(pilha_cem)
	for d in 2:
		var k := _topo_assentado(d)
		var cem := proj(CEMIT_JOG if d == 0 else CEMIT_OPON)
		if topo_cem[d] == null:
			topo_cem[d] = _nova_carta(cem, esc_em(cem))
			topo_cem[d].z_index = 39
			topo_cem[d].virada_para_cima = true
		var tc: Carta = topo_cem[d]
		tc.visible = k >= 0
		if k >= 0:
			var dd: Dictionary = cemit[d][k]["dados"]
			if tc.id != str(dd.get("id", "")) or tc.get_meta("k", -1) != k:
				tc.definir(dd, d)
				tc.resetar()
				tc.virada_para_cima = true
				tc.set_meta("k", k)
			tc.position = cem + Vector2(0, -_altura_pilha(k))
			tc.scale = Vector2.ONE * esc_em(cem)
			tc.rotation = 0.0
	pilha_cem.queue_redraw()


## Espessura da pilha: uma lâmina de papel por carta (até 12), alinhadas, com a borda escura alternada.
func _desenhar_pilhas() -> void:
	for d in 2:
		var k := _topo_assentado(d)
		if k < 1:
			continue
		var cem := proj(CEMIT_JOG if d == 0 else CEMIT_OPON)
		var e := esc_em(cem)
		var sz := Vector2(Carta.LARG, Carta.ALT) * e
		var n := int(_altura_pilha(k))
		pilha_cem.draw_rect(Rect2(cem - sz / 2 + Vector2(2, 3), sz + Vector2(0, n)), Color(0, 0, 0, 0.35))
		for j in n:
			var r := Rect2(cem - sz / 2 + Vector2(0, -j), sz)
			pilha_cem.draw_rect(r, Carta.PAPEL if j % 2 == 0 else Carta.PAPEL_ESC)
			pilha_cem.draw_rect(Rect2(r.position.x, r.end.y - 1, r.size.x, 1), Carta.PAPEL_ESC.darkened(0.25))


## Golpe direto na Cornucópia (só com o campo inimigo vazio): recuo maior, investida até o placar, tremor de 5 px,
## clarão vermelho, número grande e o placar pulsa.
func _golpe_direto(c: Carta, alvo_dono: int) -> void:
	c.atacou = true
	if modo_partida:
		_conta(c.dono, "golpes_diretos")
		hud.registrar(c.dono, c.id, "golpe")
		if not await motor.antes_do_ataque(c, null):
			await _checar_fim()
			return
	var ini := c.position
	var alvo := _pos_placar(alvo_dono) + Vector2(10, 2)
	var dir := (alvo - ini).normalized()
	c.z_index = 750
	var t := create_tween().set_parallel(true)
	t.tween_property(c, "position", ini - dir * 14, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.tween_property(c, "scale", c.scale * 1.2, 0.2)
	t.tween_property(c, "levantada", 1.0, 0.2)
	t.tween_property(c, "rotation", dir.angle() + PI / 2 if dir.y < 0 else 0.0, 0.2)
	await t.finished
	var t2 := create_tween()
	t2.tween_property(c, "position", alvo + Vector2(0, 26 if alvo_dono == 1 else -26), 0.13).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	await t2.finished
	cornucopia[alvo_dono] -= c.atk
	placar_pulo[alvo_dono] = 1.0
	tremor = 5.0
	Sessao.vibrar(60, 1.0)
	efeitos.flash(Color("#ff3030"), 0.3)
	efeitos.faiscas(alvo, 26, Color("#ff9a6a"))
	efeitos.numero(alvo + Vector2(20, -10), "-%d" % c.atk, Color("#ff5050"), 3)
	var t3 := create_tween().set_parallel(true)
	t3.tween_property(c, "position", ini, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t3.tween_property(c, "scale", Vector2.ONE * esc_em(ini), 0.35)
	t3.tween_property(c, "rotation", 0.0, 0.35)
	t3.tween_property(c, "levantada", 0.0, 0.35)
	await t3.finished
	c.z_index = 100
	if modo_partida:
		await _checar_fim()
		return
	if cornucopia[alvo_dono] <= 0:
		acabou = true
		if alvo_dono == 1:
			await _vitoria()
		else:
			await _derrota()
		fim_turno_pedido.emit()               # a partida podia estar esperando o botão FIM do jogador


## Rito: a carta sobe ao centro do lado inimigo, brilha 3×, dispara um feixe de faíscas no alvo (3 de dano) e se desfaz.
func _lancar_rito(c: Carta, alvo_idx: int) -> void:
	var alvo: Carta = campo_ent[1][alvo_idx]
	var p := Vector2(180, LINHA_Y - 10)
	var t := create_tween().set_parallel(true)
	t.tween_property(c, "position", p, 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(c, "rotation", 0.0, 0.25)
	t.tween_property(c, "inclinacao", 0.0, 0.25)
	t.tween_property(c, "scale", Vector2(1.2, 1.2), 0.25)
	await t.finished
	for k in 3:
		var tb := create_tween()
		tb.tween_property(c, "brilho", 0.6, 0.08)
		tb.tween_property(c, "brilho", 0.0, 0.1)
		await tb.finished
	for k in 8:
		efeitos.faiscas(p.lerp(alvo.position, k / 8.0), 4, Color("#8ae3a8"))
		await get_tree().create_timer(0.025).timeout
	alvo.dano += 3
	_piscar(alvo); _sacudir(alvo, 3.0)
	tremor = 3.0
	efeitos.numero(alvo.position + Vector2(0, -20), "-3", Color("#ff6a6a"))
	efeitos.estilhacar(c.position, [Color("#8ae3a8"), Color("#d8ffe0"), Color("#4aa070")], 60, 80)
	c.queue_free()
	cemiterio[0] += 1
	await get_tree().create_timer(0.3).timeout
	if alvo.vida() <= 0:
		await _destruir(alvo)


# ================= vitória / derrota =================
func _vitoria() -> void:
	await get_tree().create_timer(0.3).timeout
	Sessao.vibrar_pulsos(3, 40, 0.8, 0.09)
	efeitos.faixa = "VITÓRIA"
	efeitos.faixa_t = 0.0
	efeitos.confete(90)
	efeitos.flash(Color("#ffe39a"), 0.4)
	for k in mao_jog.size():                                   # a mão comemora: pulinhos em sequência
		var c: Carta = mao_jog[k]
		var t := create_tween()
		t.tween_property(c, "position:y", c.position.y - 14, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		t.tween_property(c, "position:y", c.position.y, 0.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		await get_tree().create_timer(0.08).timeout
	await get_tree().create_timer(2.6).timeout


func _derrota() -> void:
	await get_tree().create_timer(0.3).timeout
	tremor = 6.0
	efeitos.flash(Color("#300010"), 0.6)
	var t := create_tween().set_parallel(true)
	t.tween_property(ambiente, "color", Color(0.24, 0.24, 0.30), 1.0)
	for i in luzes.size():
		var l: PointLight2D = luzes[i]
		t.tween_method(func(v: float) -> void: l.set_meta("liga", v), 1.0, 0.45, 1.0)
	Sessao.vibrar(150, 1.0)
	efeitos.faixa = "DERROTA"
	efeitos.faixa_t = 0.0
	efeitos.cinzas(70)
	for c in mao_jog:                                          # a mão afunda 30 px
		create_tween().tween_property(c, "position:y", c.position.y + 30, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await get_tree().create_timer(3.0).timeout


# ================= oponente (roteiro simples) =================
func _oponente_joga(idx: int, atk: int, defe: int) -> Carta:
	var c: Carta = mao_opon.pop_back()
	c.tipo = "entidade"; c.atk = atk; c.defe = defe; c.dono = 1
	_rearrumar(mao_opon, _layout_mao_opon, 0.62)
	campo_ent[1][idx] = c
	var dest := pos_ent(1, idx)
	await _arco(c, dest + Vector2(0, -24), 0.35, 20, 0.0, esc_em(dest) * 1.25).finished
	await _cair(c, dest, true)
	return c


# ================= demonstração (GD_DEMO=1) =================
func _demo_arrastar(de: Vector2, para: Vector2, dur: float = 0.55) -> void:
	efeitos.cursor = de
	await get_tree().create_timer(0.15).timeout
	efeitos.cursor_apertado = true
	pressionar(de)
	await get_tree().create_timer(0.12).timeout
	var n := int(dur * 30)
	for k in n + 1:
		var u := float(k) / n
		var e := u * u * (3.0 - 2.0 * u)
		var pos := de.lerp(para, e) + Vector2(0, -sin(u * PI) * 18)
		efeitos.cursor = pos
		mover(pos)
		await get_tree().process_frame
	await get_tree().create_timer(0.12).timeout
	efeitos.cursor_apertado = false
	await soltar(para)


func _demo_tocar(p: Vector2) -> void:
	for k in 8:
		efeitos.cursor = efeitos.cursor.lerp(p, 0.4)
		await get_tree().process_frame
	efeitos.cursor = p
	efeitos.cursor_apertado = true
	await get_tree().create_timer(0.1).timeout
	pressionar(p)
	efeitos.cursor_apertado = false


func _demo_esperar_escolha() -> void:
	while efeitos.escolha.is_empty():
		await get_tree().process_frame
	await get_tree().create_timer(0.4).timeout


func _demo() -> void:
	await get_tree().create_timer(0.5).timeout
	await _oponente_joga(1, 2, 2)
	await _oponente_joga(2, 1, 3)
	await get_tree().create_timer(0.4).timeout
	var ent_a: Carta = mao_jog[0]
	var ent_b: Carta = mao_jog[1]
	var selo: Carta = mao_jog[2]
	var rito: Carta = mao_jog[3]
	# 1) Entidade A → espaço 2, escolhe CIMA
	_demo_arrastar(ent_a.position, pos_ent(0, 1))
	await _demo_esperar_escolha()
	await _demo_tocar((efeitos.escolha[0]["rect"] as Rect2).get_center())
	await get_tree().create_timer(0.7).timeout
	# 2) Selo → espaço de Selo (cai virado para baixo, sem perguntar)
	await _demo_arrastar(selo.position, pos_selo(0, 0))
	await get_tree().create_timer(0.5).timeout
	# 3) Entidade B solta em lugar errado → sacode e volta
	await _demo_arrastar(ent_b.position, Vector2(180, LINHA_Y + 12))
	await get_tree().create_timer(0.5).timeout
	# 4) Entidade B → espaço 3, escolhe BAIXO
	_demo_arrastar(ent_b.position, pos_ent(0, 2))
	await _demo_esperar_escolha()
	await _demo_tocar((efeitos.escolha[1]["rect"] as Rect2).get_center())
	await get_tree().create_timer(0.7).timeout
	# 5) muda A de lugar (espaço 2 → espaço 1)
	await _demo_arrastar(ent_a.position, pos_ent(0, 0))
	await get_tree().create_timer(0.5).timeout
	# 6) A ataca a Entidade 2/2 do oponente (destrói; A fica 3/2)
	await _demo_arrastar(ent_a.position, pos_ent(1, 1))
	await get_tree().create_timer(0.6).timeout
	# 7) Rito na Entidade 1/3 (3 de dano: destrói)
	await _demo_arrastar(rito.position, pos_ent(1, 2))
	await get_tree().create_timer(0.6).timeout
	# 8) campo inimigo vazio: golpe direto na Cornucópia (15 → 12)
	await _demo_arrastar(ent_a.position, Vector2(180, 150))
	await get_tree().create_timer(0.8).timeout
	efeitos.cursor = Vector2(-100, -100)
	# 9) "mais tarde…": Cornucópia inimiga em 3 → golpe final → VITÓRIA
	efeitos.numero(Vector2(180, LINHA_Y - 40), "MAIS TARDE", Color("#f2e6c8"), 2)
	await get_tree().create_timer(0.9).timeout
	cornucopia[1] = 3
	placar_pulo[1] = 0.6
	await get_tree().create_timer(0.5).timeout
	await _demo_arrastar(ent_a.position, Vector2(180, 150))
	efeitos.cursor = Vector2(-100, -100)
	await get_tree().create_timer(0.6).timeout
	# 10) recomeço rápido para mostrar a DERROTA: oponente golpeia a sua Cornucópia em 2
	efeitos.faixa = ""
	efeitos.particulas.clear()
	cornucopia[0] = 2
	placar_pulo[0] = 0.6
	for i in 4:
		var c = campo_ent[0][i]
		if c != null:
			(c as Carta).visible = false
			campo_ent[0][i] = null
	await get_tree().create_timer(0.4).timeout
	var inimiga := await _oponente_joga(0, 4, 4)
	await get_tree().create_timer(0.3).timeout
	await _golpe_direto(inimiga, 0)


# ================= partida (regras + efeitos reais das cartas: motor_efeitos.gd) =================
const MAO_MAX := 7
const FE_TETO := 8
const TURNOS_MAX := 80
const AREA_CAMPO := Rect2(26, 50, 308, 470)       # "qualquer lugar do campo acima da mão" (Rito sem alvo)
var estat := [{}, {}]                 # contadores por lado (impressos no fim da partida)
var motor: MotorEfeitos
var cemit := [[], []]                 # cemitério lógico: [{dados, no}] (no = nó ainda na pilha, ou null)
var vencedor := -1                    # -1 em jogo · 0 jogador · 1 oponente · 2 empate
var alvos_pedidos: Array = []         # o jogador está escolhendo um alvo por toque
var veu_alvo: Node2D
var tut: Tutorial = null
var carrossel: Carrossel
var pilha_cem: Node2D = null
var topo_cem: Array = [null, null]                  # tutorial em curso (só a jogada pedida é aceita)
var _t_destaque := 0.0
var _jogaveis: Array = []
var veu_a := 0.0
signal alvo_tocado(alvo)


func _conta(d: int, k: String) -> void:
	estat[d][k] = int(estat[d].get(k, 0)) + 1
var zoom_travado := false
var _ignorar_soltar := false             # carta ampliada fica aberta até o próximo toque
var zoom_pendente: Carta = null
var zoom_t := 0.0
var zoom_ini := Vector2.ZERO


## Embaralha os ids do deck (Fisher–Yates com o rng da mesa) e dá a cada nó do monte uma carta real.
func _dar_dados(nos: Array[Carta], deck_nome: String, dono: int) -> void:
	_dar_ids(nos, (db["decks"][deck_nome] as Array), dono)


func _dar_ids(nos: Array[Carta], lista: Array, dono: int) -> void:
	var ids: Array = lista.duplicate()
	for i in range(ids.size() - 1, 0, -1):
		var j: int = rng_deck[dono].randi_range(0, i)
		var tmp = ids[i]
		ids[i] = ids[j]
		ids[j] = tmp
	for i in nos.size():
		var c: Carta = nos[i]
		c.definir(db["cartas"][ids[i % ids.size()]], dono)


func _mao_de(d: int) -> Array[Carta]:
	return mao_jog if d == 0 else mao_opon


func _deck_de(d: int) -> Array[Carta]:
	return deck_jog if d == 0 else deck_opon


func _rearrumar_de(d: int) -> void:
	if d == 0:
		_rearrumar_mao()
	else:
		_rearrumar(mao_opon, _layout_mao_opon, 0.62)


func _espaco_livre(arr: Array) -> int:
	for i in arr.size():
		if arr[i] == null:
			return i
	return -1


func _partida() -> void:
	ativo = 0
	if online_partida():
		ativo = 0 if int(online_info.get("primeiro", 0)) == rede.eu else 1
	turno_n = 0
	_inicio_ms = Time.get_ticks_msec()
	_corn_ini = cornucopia.duplicate()
	while not acabou:
		turno_n += 1
		if turno_n > TURNOS_MAX:
			print("FIM DA PARTIDA: empate por limite de turnos")
			vencedor = 2
			break
		ocupado = true                        # início/fim de turno resolvem gatilhos: sem toques no meio
		await _inicio_turno(ativo)
		ocupado = false
		if acabou:
			break
		var terminou := false
		if ativo == 0 and online_partida() and not rede.proprias.is_empty():   # reconexão: refaz as minhas jogadas já enviadas
			terminou = await _turno_rede(0)
		if terminou or acabou:
			pass
		elif ativo == 0 and not auto_jogador:
			_atualizar_apagadas()
			if OS.get_environment("GD_TOQUE_AUTO") != "":
				_toque_auto()
			_iniciar_relogio()
			await fim_turno_pedido
			relogio_ativo = false
			if online_partida() and not acabou:
				_enviar({"tipo": "fim", "h": _hash_estado()})
		elif online_partida() and ativo == 1:
			await _turno_rede(1)
		else:
			if ativo == 0 and online_partida():
				_teste_queda()
			await _turno_ia(ativo)
		if acabou:
			break
		ocupado = true
		await _fim_turno(ativo)
		ocupado = false
		if acabou:
			break
		ativo = 1 - ativo
	var r: String = {0: "vitória", 1: "derrota", 2: "empate"}.get(vencedor, "empate")
	print("FIM DA PARTIDA: %s no turno %d (Cornucópias %d × %d)" % [r, turno_n, cornucopia[0], cornucopia[1]])
	print("ESTAT jogador: ", estat[0], "  oponente: ", estat[1])
	print(motor.resumo())


## Início do turno: Fé máx +1 (teto 8) e restaura; o 2º jogador ganha +1 Fé temporária no 1º turno dele;
## Entidades acordam (congeladas perdem este turno); compra 1 (quem começa não compra no 1º turno); "início do turno".
func _inicio_turno(d: int) -> void:
	if d == 0 and acelerar_ia:
		acelerar_ia = false
		aplicar_tempo()
	fe_max[d] = mini(FE_TETO, fe_max[d] + 1)
	fe[d] = fe_max[d]
	if turno_n == 2:                                     # quem joga em segundo: +1 Fé no 1º turno dele
		fe[d] += 1
	if d == 0 and turno_n == 1 and _bencao("fe1"):        # Bênção: +1 Fé no 1º turno
		fe[d] += 1
	selo_no_turno = false
	for c in motor.campo(d):
		c.cansada = false
		c.atacou = false
		c.sem_ataque = c.congelada
		c.congelada = false
	_atualizar_apagadas()
	efeitos.numero(Vector2(180, LINHA_Y - 4), "SEU TURNO" if d == 0 else "TURNO DELE", Color("#ffe39a") if d == 0 else Color("#cfe0ff"), 2)
	await get_tree().create_timer(0.6).timeout
	if turno_n != 1:                                     # quem começa não compra no 1º turno
		await _comprar(d)
	elif _bencao("compra1"):                            # Bênção: compra 1 no 1º turno (quem começa não compraria)
		await _comprar(d)
	if acabou:
		return
	await motor.inicio_turno(d)
	await _checar_fim()
	_atualizar_apagadas()


## Fim do turno: "fim do turno" das Entidades, Selos enemy_end_turn do outro lado, buffs temporários expiram,
## mão acima de 7 descarta (a mais cara).
func _fim_turno(d: int) -> void:
	efeitos.destaques.clear()
	await motor.fim_turno(d)
	var mao := _mao_de(d)
	while mao.size() > MAO_MAX and not acabou:
		var cara: Carta = mao[0]
		for c in mao:
			if c.custo > cara.custo:
				cara = c
		await _descartar(d, cara)
	await _checar_fim()
	_atualizar_apagadas()


func _checar_fim() -> void:
	if acabou:
		return
	var m0: bool = cornucopia[0] <= 0
	var m1: bool = cornucopia[1] <= 0
	if m0 and m1:
		await _encerrar(2)
	elif m1:
		await _encerrar(0)
	elif m0:
		await _encerrar(1)


func _encerrar(v: int, motivo := "") -> void:
	if acabou:
		return
	acabou = true
	vencedor = v
	if rede != null:
		rede.avisar_fim(v)
		rede.chegou.emit()
	alvos_pedidos.clear()
	efeitos.escolha.clear()
	efeitos.dica = ""
	efeitos.destaques.clear()
	efeitos.alvos.clear()
	efeitos.faixa_alvo = {}
	efeitos.galeria = {}
	_veu(0.0)
	if motivo != "":
		efeitos.numero(Vector2(180, LINHA_Y - 30), motivo, Color("#e0a8ff"), 3)
		await get_tree().create_timer(0.6).timeout
	if v == 0:
		await _vitoria()
	elif v == 1:
		await _derrota()
	else:
		efeitos.faixa = "EMPATE"
		efeitos.faixa_t = 0.0
		await get_tree().create_timer(2.5).timeout
	fim_turno_pedido.emit()               # a partida podia estar esperando o botão FIM do jogador


## Compra 1. Deck vazio: pode reembaralhar o cemitério pagando 5 de Cornucópia (com 6+); senão fadiga (2 de dano).
## Mão cheia (7) = a carta comprada queima.
func _comprar(d: int) -> void:
	var deck := _deck_de(d)
	if deck.is_empty() and modo_partida and _pode_reembaralhar(d):
		var sim := true
		if _reemb_gratis():
			pass                                         # Peregrinação: grátis, não há o que decidir
		elif decisao_da_rede(d):
			sim = await esc_rede(d) == 1
		elif motor.humano(d) and auto_jogador:            # teste online: a IA decide e manda
			sim = not (cemit[d].size() < 3 and cornucopia[d] < 10)
			enviar_esc(1 if sim else 0)
		elif motor.humano(d):
			sim = await pedir_sim_nao("DECK VAZIO", "REEMBARALHAR O CEMITÉRIO: -%d CORNUCÓPIA" % CUSTO_REEMBARALHAR,
				"REEMBARALHAR", "NÃO  (-2)")
			enviar_esc(1 if sim else 0)
		elif cemit[d].size() < 3 and cornucopia[d] < 10:
			sim = false                                  # IA: com quase nada no cemitério, prefere a fadiga
		if sim:
			await _reembaralhar(d)
			deck = _deck_de(d)
	if deck.is_empty():
		cornucopia[d] -= 2
		placar_pulo[d] = 1.0
		tremor = 3.0
		efeitos.numero(_pos_placar(d) + Vector2(36, 2), "-2", Color("#ff5050"), 2)
		efeitos.numero(Vector2(180, LINHA_Y + (40 if d == 0 else -40)), "DECK VAZIO", Color("#ffd0a0"), 1)
		await get_tree().create_timer(0.5).timeout
		await _checar_fim()
		return
	await _receber_comprada(d, deck.pop_back())


const CUSTO_REEMBARALHAR := 5


func _pode_reembaralhar(d: int) -> bool:
	var tem_cartas: bool = cemit[d].any(func(e: Dictionary) -> bool: return not e["dados"].get("token", false))
	if _reemb_gratis():
		return tem_cartas
	return cornucopia[d] >= CUSTO_REEMBARALHAR + 1 and tem_cartas


## Regra só da Peregrinação: deck vazio reembaralha o cemitério de graça (sem pagar Cornucópia), para os dois lados.
func _reemb_gratis() -> bool:
	return modo_partida and Sessao.modo == "peregrinacao"


## Paga 5 de Cornucópia; as cartas do cemitério voam (viradas para baixo, uma a cada 0,04 s) para o deck, que embaralha.
func _reembaralhar(d: int) -> void:
	if not _reemb_gratis():
		cornucopia[d] -= CUSTO_REEMBARALHAR
		placar_pulo[d] = 1.0
		efeitos.numero(_pos_placar(d) + Vector2(36, 2), "-%d" % CUSTO_REEMBARALHAR, Color("#ff5050"), 2)
	tremor = 2.5
	Sessao.vibrar(40, 0.7)
	efeitos.flash(Color("#7a5aa8"), 0.25)
	efeitos.numero(Vector2(180, LINHA_Y + (40 if d == 0 else -40)), "REEMBARALHAR", Color("#e0c8ff"), 2)
	tocar_som("embaralhar_2")
	var cem := proj(CEMIT_JOG if d == 0 else CEMIT_OPON)
	var dest := proj(DECK_JOG if d == 0 else DECK_OPON)
	var deck := _deck_de(d)
	var entradas: Array = cemit[d].duplicate()
	cemit[d].clear()
	cemiterio[d] = 0
	for k in entradas.size():
		var e: Dictionary = entradas[k]
		if e["dados"].get("token", false):
			if e["no"] != null and is_instance_valid(e["no"]):
				(e["no"] as Carta).queue_free()
			continue
		var c: Carta
		if e["no"] != null and is_instance_valid(e["no"]):
			c = e["no"]
		else:
			c = _nova_carta(cem, esc_em(cem))
		c.definir(e["dados"], d)
		c.resetar()
		c.visible = true
		c.em_campo = false
		c.apagada = false
		c.empilhada = false
		c.z_index = 300 + k
		if c.virada_para_cima:
			c.virar(0.2)
		deck.append(c)
		_arco(c, dest + Vector2(0, -k / 3), 0.38, 30, rng_vis.randf_range(-0.3, 0.3), esc_em(dest))
		efeitos.faiscas(c.position, 4, Color("#c8b0f0"))
		await get_tree().create_timer(0.04).timeout
	await get_tree().create_timer(0.45).timeout
	_embaralhar_deck(d)
	for c in deck:                                       # batidinha do monte embaralhado
		c.rotation = 0.0
		var t := create_tween()
		t.tween_property(c, "scale", Vector2(c.scale.x, c.scale.y * 0.92), 0.06)
		t.tween_property(c, "scale", Vector2.ONE * esc_em(dest), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	efeitos.anel(dest, Color("#c8b0f0"), 40)
	await get_tree().create_timer(0.3).timeout
	await _checar_fim()


## Pergunta sim/não: mesa escurece, faixa com título e subtítulo, dois botões.
func pedir_sim_nao(titulo: String, sub: String, txt_sim: String, txt_nao: String) -> bool:
	efeitos.t_escolha = 0.0
	efeitos.faixa_alvo = {"titulo": titulo, "sub": Sessao.t(sub), "y": LINHA_Y}
	efeitos.escolha = [{"rect": Rect2(70, LINHA_Y + 20, 104, 16), "texto": txt_sim, "valor": true},
		{"rect": Rect2(186, LINHA_Y + 20, 104, 16), "texto": txt_nao, "valor": false}]
	_veu(1.0)
	Sessao.vibrar(12, 0.4)
	var v = await escolhido
	efeitos.faixa_alvo = {}
	efeitos.escolha.clear()
	_veu(0.0, 0.18)
	return v == true


## A carta (já fora do deck) vai para a mão com o arco de compra. `queimar`: mão cheia manda ao cemitério.
func _receber_comprada(d: int, c: Carta, queimar := true) -> void:
	var mao := _mao_de(d)
	c.empilhada = false
	c.z_index = 500 + mao.size()
	if queimar and mao.size() >= MAO_MAX:
		if not c.virada_para_cima:
			await c.virar(0.2)
		efeitos.numero(c.position + Vector2(0, -40), "MÃO CHEIA", Color("#ffd0a0"), 1)
		await get_tree().create_timer(0.3).timeout
		efeitos.estilhacar(c.position, c.cores_estilhaco(), int(Carta.LARG * c.scale.x), int(Carta.ALT * c.scale.y))
		cemit[d].append({"dados": c.dados, "no": null})
		c.queue_free()
		cemiterio[d] += 1
		return
	mao.append(c)
	var t0 := create_tween()
	t0.tween_property(c, "position:y", c.position.y - 10, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t0.parallel().tween_property(c, "levantada", 0.6, 0.12)
	await t0.finished
	if d == 0:
		var lay: Array = _layout_mao(mao.size(), mao.size() - 1)
		_arco(c, lay[0], 0.42, 40, lay[1], 1.0)
		if not c.virada_para_cima:
			get_tree().create_timer(0.1).timeout.connect(func() -> void: c.virar(0.26))
		var anteriores: Array[Carta] = mao.slice(0, mao.size() - 1)
		for kk in anteriores.size():
			var a: Carta = anteriores[kk]
			var l2: Array = _layout_mao(mao.size(), kk)
			var t := create_tween().set_parallel(true)
			t.tween_property(a, "position", l2[0], 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			t.tween_property(a, "rotation", l2[1], 0.3)
	else:
		if c.virada_para_cima:
			c.virar(0.2)
		var lo: Array = _layout_mao_opon(mao.size(), mao.size() - 1)
		_arco(c, lo[0], 0.42, 20, lo[1], 0.62)
		_rearrumar(mao.slice(0, mao.size() - 1), _layout_mao_opon, 0.62)
	await get_tree().create_timer(0.5).timeout
	_rearrumar_de(d)
	_atualizar_apagadas()


## Carta volta para a mão do dono (Renascer, bounce, revive para a mão): estado impresso, face certa, encaixa no leque.
func _entrar_na_mao(d: int, c: Carta) -> void:
	c.resetar()
	c.em_campo = false
	c.dono = d
	c.dono_real = d
	var mao := _mao_de(d)
	mao.append(c)
	c.z_index = 500 + mao.size()
	if d == 1 and c.virada_para_cima:
		c.virar(0.24)
	elif d == 0 and not c.virada_para_cima:
		c.virar(0.24)
	var t := create_tween().set_parallel(true)
	t.tween_property(c, "levantada", 0.0, 0.3)
	if d == 0:
		t.tween_property(c, "scale", Vector2.ONE, 0.3)
	_rearrumar_de(d)
	_atualizar_apagadas()
	await get_tree().create_timer(0.35).timeout


## Descarte (efeito ou mão > 7): a carta vira, mostra-se e se desfaz; vai ao cemitério.
func _descartar(d: int, c: Carta) -> void:
	_mao_de(d).erase(c)
	_rearrumar_de(d)
	c.z_index = 760
	if not c.virada_para_cima:
		await c.virar(0.2)
	efeitos.numero(c.position + Vector2(0, 40 if d == 1 else -52), "DESCARTE", Color("#c88aff"), 1)
	await get_tree().create_timer(0.3).timeout
	efeitos.estilhacar(c.position, [Color("#c88aff"), Color("#4e2c6c"), Color("#f2e6c8")], int(Carta.LARG * c.scale.x), int(Carta.ALT * c.scale.y))
	cemit[d].append({"dados": c.dados, "no": null})
	cemiterio[d] += 1
	c.visible = false                          # libera depois: um ataque/efeito em curso ainda pode apontar para ela
	get_tree().create_timer(6.0).timeout.connect(c.queue_free)
	_atualizar_apagadas()


## Token/carta que some sem ir à pilha do cemitério.
func _desfazer(c: Carta) -> void:
	_remover_do_campo(c)
	c.em_campo = false
	_sacudir(c, 2.0)
	await get_tree().create_timer(0.15).timeout
	efeitos.estilhacar(c.position, c.cores_estilhaco(), int(Carta.LARG * c.scale.x), int(Carta.ALT * c.scale.y))
	c.visible = false                          # libera depois: gatilhos ainda podem apontar para ela (triggering)
	get_tree().create_timer(6.0).timeout.connect(c.queue_free)
	await get_tree().create_timer(0.2).timeout


func _embaralhar_deck(d: int) -> void:
	var deck := _deck_de(d)
	for i in range(deck.size() - 1, 0, -1):
		var j: int = rng_deck[d].randi_range(0, i)
		var tmp := deck[i]
		deck[i] = deck[j]
		deck[j] = tmp
	var base := proj(DECK_JOG if d == 0 else DECK_OPON)
	for i in deck.size():
		deck[i].position = base + Vector2(0, -int(i / 3))
		deck[i].z_index = i
		deck[i].empilhada = i > 0


func _pos_fe(d: int) -> Vector2:
	return proj(Vector2(300, LINHA_Y + 8)) if d == 0 else proj(Vector2(300, LINHA_Y - 14))


## Põe uma Entidade num espaço (invocação, token, revive, roubo): entra cansada; cai com poeira.
func _por_em_campo(c: Carta, d: int, i: int) -> void:
	campo_ent[d][i] = c
	c.dono = d
	c.em_campo = true
	c.apagada = false
	c.atacou = false
	c.cansada = true
	motor.recalcular_auras()
	var dest := pos_ent(d, i)
	if c.position.distance_to(dest) > 60:
		await _arco(c, dest + Vector2(0, -24), 0.35, 20, 0.0, esc_em(dest) * 1.25).finished
	await _cair(c, dest, true)


## Selo dispara: sobe, vira para cima com clarão roxo e brilho, mostra o nome.
func _revelar_selo(s: Carta) -> void:
	if modo_partida:
		hud.registrar(s.dono, s.id, "selo_revelado")
	s.z_index = 760
	Sessao.vibrar(30, 0.6)
	efeitos.flash(Color("#7a5aa8"), 0.22)
	var e := s.scale.x
	var t := create_tween().set_parallel(true)
	t.tween_property(s, "scale", Vector2(e, e) * 1.35, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(s, "levantada", 1.0, 0.15)
	await t.finished
	if not s.virada_para_cima:
		await s.virar(0.24)
	efeitos.anel(s.position, Color("#c8b0f0"), 44)
	efeitos.faiscas(s.position, 20, Color("#c8b0f0"))
	await _vitrine(s, 1.2, Color("#c8b0f0"))
	for k in 2:
		var tb := create_tween()
		tb.tween_property(s, "brilho", 0.8, 0.07)
		tb.tween_property(s, "brilho", 0.0, 0.14)
		await tb.finished
	await get_tree().create_timer(0.2).timeout


func _selo_ao_cemiterio(s: Carta) -> void:
	await get_tree().create_timer(0.2).timeout
	efeitos.estilhacar(s.position, [Color("#c8b0f0"), Color("#7a5aa8"), Color("#3b2d5e")], int(Carta.LARG * s.scale.x), int(Carta.ALT * s.scale.y))
	cemiterio[s.dono_real] += 1
	s.queue_free()
	await get_tree().create_timer(0.2).timeout


## Mostra a carta montada grande no centro por `dur` s (Rito lançado, Selo revelado, Entidade do oponente).
func _primeiro_ocupado(d: int) -> int:
	for i in 4:
		if campo_ent[d][i] != null:
			return i
	return -1


func _vitrine(c: Carta, dur := 1.15, cor := Color("#ffe39a")) -> void:
	var tex := Carta.textura("carta_en" if Sessao.idioma == "en" else "carta", c.id, "webp")
	if tex == null or acabou:
		return
	efeitos.vitrine = {"tex": tex, "de": c.global_position, "t": 0.0, "dur": dur, "cor": cor}
	Sessao.vibrar(10, 0.3)
	await get_tree().create_timer(dur).timeout
	efeitos.vitrine = {}


# ---------- escolha de alvo pelo jogador (toque) ----------
func _veu(alvo: float, dur := 0.2) -> void:
	create_tween().tween_method(func(v: float) -> void:
		veu_a = v
		veu_alvo.queue_redraw(), veu_a, alvo, dur)


## Escurece a mesa, ergue as candidatas acima do véu com brilho dourado, mira e seta; faixa no meio com o pedido.
## A carta que pediu o alvo (Rito no centro) vai para o canto esquerdo da faixa. O botão devolve null (PULAR/CANCELAR).
func pedir_alvo(cands: Array, dica: String, botao := "PULAR", fonte = null):
	alvos_pedidos = cands.duplicate()
	var z_antes := {}
	for c in cands:
		var cc: Carta = c
		z_antes[c] = [cc.z_index, cc.scale]
		cc.z_index = 745
		create_tween().tween_property(cc, "scale", cc.scale * 1.15, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var fonte_volta = null
	if fonte is Carta and is_instance_valid(fonte) and not (fonte as Carta).em_campo and not (fonte in cands):
		var fc: Carta = fonte
		fonte_volta = [fc.position, fc.scale]
		var tf := create_tween().set_parallel(true)
		tf.tween_property(fc, "position", Vector2(30, LINHA_Y), 0.22).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tf.tween_property(fc, "scale", Vector2(0.9, 0.9), 0.22)
	var titulo := "ESCOLHA O ALVO"
	var sub := Sessao.t(dica)
	if dica.begins_with("ALVO: "):
		sub = Sessao.t("EFEITO: ") + Sessao.t(dica.substr(6))
		if fonte is Carta and is_instance_valid(fonte):
			sub = PixelFonte.normalizar((fonte as Carta).nome).to_upper() + ":  " + Sessao.t(dica.substr(6))
	elif dica.begins_with("SACRIFIQUE"):
		titulo = dica
		sub = Sessao.t("TOQUE UMA ENTIDADE SUA")
	efeitos.t_escolha = 0.0
	efeitos.alvos = cands.duplicate()
	efeitos.faixa_alvo = {"titulo": titulo, "sub": sub, "y": LINHA_Y}
	efeitos.escolha = [{"rect": Rect2(152, LINHA_Y + 19, 56, 14), "texto": botao, "valor": "pular"}]
	_veu(1.0)
	Sessao.vibrar(12, 0.4)
	var r = await alvo_tocado
	if r != null:
		var rc: Carta = r
		efeitos.anel(rc.global_position, Color("#ffe39a"), 40)
		efeitos.faiscas(rc.global_position, 18)
		var tb := create_tween()
		tb.tween_property(rc, "brilho", 0.7, 0.07)
		tb.tween_property(rc, "brilho", 0.0, 0.15)
		Sessao.vibrar(18, 0.6)
	alvos_pedidos.clear()
	efeitos.alvos.clear()
	efeitos.faixa_alvo = {}
	efeitos.escolha.clear()
	_veu(0.0, 0.18)
	for c in z_antes:
		if is_instance_valid(c):
			(c as Carta).z_index = z_antes[c][0]
			create_tween().tween_property(c, "scale", z_antes[c][1], 0.15)
	if fonte_volta != null and is_instance_valid(fonte):
		var tf := create_tween().set_parallel(true)
		tf.tween_property(fonte, "position", fonte_volta[0], 0.18)
		tf.tween_property(fonte, "scale", fonte_volta[1], 0.18)
		await tf.finished
	return r


func _itens_cemiterio(lista: Array) -> Array:
	var pasta := "carta_en" if Sessao.idioma == "en" else "carta"
	var out: Array = []
	for e in lista:
		var dd: Dictionary = e["dados"]
		out.append({"tex": Carta.textura(pasta, str(dd.get("id", "")), "webp"), "nome": str(dd.get("nome", ""))})
	return out


## Ver o cemitério (o seu ou o do oponente): carrossel horizontal saindo da pilha.
func abrir_cemiterio(d: int) -> void:
	var cem := proj(CEMIT_JOG if d == 0 else CEMIT_OPON)
	carrossel.tam_pilha = Vector2(Carta.LARG, Carta.ALT) * esc_em(cem)
	carrossel.abrir(_itens_cemiterio(cemit[d]), cem, "ver",
		"SEU CEMITÉRIO" if d == 0 else "CEMITÉRIO DELE")


## Escolha no cemitério (reviver): o mesmo carrossel, só com as candidatas; tocar na carta do centro escolhe.
func pedir_cemiterio(cands: Array, titulo := "REVIVER QUAL?"):
	carrossel.tam_pilha = Vector2(Carta.LARG, Carta.ALT) * esc_em(proj(CEMIT_JOG))
	var r: int = await carrossel.escolher(_itens_cemiterio(cands), proj(CEMIT_JOG), titulo)
	if r < 0:
		return null
	return cands[r]


# ---------- jogar cartas ----------
## Como um Rito é jogado: "area" (soltar em qualquer lugar do campo), "alvo" (soltar sobre o alvo),
## "cemiterio" (soltar sobre o cemitério) ou "sem_alvo" (não há alvo útil: recusa).
func _rito_modo(c: Carta, d: int) -> String:
	var tipo := MotorEfeitos.alvo_escolhido(c.dados)
	if tipo == "":
		return "area"
	if not motor.candidatos(tipo, d, c.dados).is_empty():
		return "cemiterio" if tipo == "ally_graveyard_entity" else "alvo"
	for ef in c.dados.get("efeitos", []):
		for a in ef["acoes"]:
			var al := str(a.get("alvo", ""))
			if al == tipo:
				continue
			if not (al in MotorEfeitos.ALVOS_ESCOLHIDOS) or not motor.candidatos(al, d, c.dados).is_empty():
				return "area"
	return "sem_alvo"


func _portadoras(d: int) -> Array:
	return motor.campo(d).filter(func(e: Carta) -> bool: return e.reliquia.is_empty())


## "" = pode jogar; senão um motivo curto (mostrado sobre a carta).
func _motivo_jogar(c: Carta, d: int) -> String:
	if c.custo > fe[d]:
		return "SEM FÉ"
	match c.tipo:
		"entidade":
			var sac := int(c.dados.get("sacrificio", 0))
			var n := motor.campo(d).size()
			if sac > 0 and n < sac:
				return "SACRIFÍCIO %d" % sac
			if n - sac >= 4:
				return "CAMPO CHEIO"
		"selo":
			if selo_no_turno:
				return "1 SELO POR TURNO"
			if _espaco_livre(campo_selo[d]) < 0:
				return "SEM ESPAÇO"
		"reliquia":
			if _portadoras(d).is_empty():
				return "SEM PORTADORA"
		"rito":
			if _rito_modo(c, d) == "sem_alvo":
				return "SEM ALVO"
	return ""


func _atualizar_apagadas() -> void:
	for c in mao_jog:
		c.apagada = modo_partida and (ativo != 0 or acabou or _motivo_jogar(c, 0) != "")
		if c.custo > fe[0] or ativo != 0:
			c.apagada = true


func _pagar(d: int, custo: int) -> void:
	fe[d] -= custo
	_atualizar_apagadas()


## Destaques enquanto o jogador arrasta uma carta da mão (só o que é válido para aquele tipo).
func _destacar_jogada(c: Carta) -> void:
	efeitos.destaques.clear()
	if _motivo_jogar(c, 0) != "":
		return
	match c.tipo:
		"entidade":
			if int(c.dados.get("sacrificio", 0)) > 0:
				efeitos.destaques.append(Rect2(26, LINHA_Y + 6, 308, 128))
			else:
				for i in 4:
					if campo_ent[0][i] == null:
						efeitos.destaques.append(_rect_espaco(pos_ent(0, i)))
		"selo":
			for i in 2:
				if campo_selo[0][i] == null:
					efeitos.destaques.append(_rect_espaco(pos_selo(0, i)))
		"reliquia":
			for e in _portadoras(0):
				efeitos.destaques.append(_rect_espaco((e as Carta).position))
		"rito":
			match _rito_modo(c, 0):
				"area":
					efeitos.destaques.append(AREA_CAMPO)
				"alvo":
					for e in motor.candidatos(MotorEfeitos.alvo_escolhido(c.dados), 0, c.dados):
						efeitos.destaques.append(_rect_espaco((e as Carta).position))
				"cemiterio":
					efeitos.destaques.append(_rect_espaco(proj(CEMIT_JOG)))


func _carta_sob(p: Vector2, lista: Array) -> Carta:
	for e in lista:
		if is_instance_valid(e) and _rect_espaco((e as Carta).position).grow(6).has_point(p):
			return e
	return null


func _soltar_da_mao_partida(c: Carta, p: Vector2) -> void:
	var motivo := _motivo_jogar(c, 0)
	if motivo != "":
		efeitos.numero(c.position + Vector2(0, -52), motivo, Color("#ffd0a0"), 1)
		await _recusar(c)
		return
	match c.tipo:
		"entidade":
			var sac := int(c.dados.get("sacrificio", 0))
			if sac <= 0:
				var i := _espaco_sob(p, func(k: int) -> Vector2: return pos_ent(0, k), 4, campo_ent[0])
				if i < 0:
					await _recusar(c)
					return
				_enviar({"tipo": "jogar", "k": mao_jog.find(c), "i": i})
				await _jogar_entidade(c, 0, i)
				return
			if not (p.y > LINHA_Y and p.y < 548):
				await _recusar(c)
				return
			var t := create_tween().set_parallel(true)
			t.tween_property(c, "position", Vector2(180, LINHA_Y + 150), 0.18)
			t.tween_property(c, "rotation", 0.0, 0.18)
			t.tween_property(c, "inclinacao", 0.0, 0.18)
			t.tween_property(c, "scale", Vector2(0.9, 0.9), 0.18)
			var escolhidas: Array = []
			for k in sac:
				var cands := motor.campo(0).filter(func(e: Carta) -> bool: return not (e in escolhidas))
				var s = await pedir_alvo(cands, "SACRIFIQUE %d" % (sac - k), "CANCELAR")
				if s == null:
					efeitos.numero(c.position + Vector2(0, -52), "CANCELADO", Color("#ffd0a0"), 1)
					await _recusar(c)
					return
				escolhidas.append(s)
				(s as Carta).brilho = 0.5
			var slot := _espaco_sob(p, func(k: int) -> Vector2: return pos_ent(0, k), 4, campo_ent[0])
			_enviar({"tipo": "jogar", "k": mao_jog.find(c), "i": slot, "sac": escolhidas.map(func(e: Carta) -> int: return campo_ent[0].find(e))})
			await _jogar_entidade(c, 0, slot, escolhidas)
		"selo":
			var i := _espaco_sob(p, func(k: int) -> Vector2: return pos_selo(0, k), 2, campo_selo[0])
			if i < 0:
				await _recusar(c)
				return
			_enviar({"tipo": "jogar", "k": mao_jog.find(c), "i": i})
			await _jogar_selo(c, 0, i)
		"reliquia":
			var ports := _portadoras(0)
			var port := _carta_sob(p, ports)
			if port == null:
				await _recusar(c)
				return
			_enviar({"tipo": "jogar", "k": mao_jog.find(c), "p": ports.find(port)})
			await _jogar_reliquia(c, 0, port)
		_:
			match _rito_modo(c, 0):
				"area":
					if not AREA_CAMPO.has_point(p):
						await _recusar(c)
						return
					_enviar({"tipo": "jogar", "k": mao_jog.find(c)})
					await _jogar_rito(c, 0)
				"alvo":
					var tipo := MotorEfeitos.alvo_escolhido(c.dados)
					var cands_r := motor.candidatos(tipo, 0, c.dados)
					var alvo := _carta_sob(p, cands_r)
					if alvo == null:
						await _recusar(c)
						return
					_enviar({"tipo": "jogar", "k": mao_jog.find(c), "t": tipo, "a": cands_r.find(alvo)})
					await _jogar_rito(c, 0, alvo, tipo)
				"cemiterio":
					if not _rect_espaco(proj(CEMIT_JOG)).grow(10).has_point(p):
						await _recusar(c)
						return
					var cands := motor.candidatos("ally_graveyard_entity", 0, c.dados)
					var e = cands[0] if cands.size() == 1 else await pedir_cemiterio(cands)
					if e == null:
						await _recusar(c)
						return
					_enviar({"tipo": "jogar", "k": mao_jog.find(c), "t": "ally_graveyard_entity", "a": _indice(cands, e)})
					await _jogar_rito(c, 0, e, "ally_graveyard_entity")
				_:
					await _recusar(c)


## Entidade: paga, sai da mão, sacrifícios morrem (sem Renascer), entra cansada → Selos enemy_plays_entity do
## oponente → (se não anulada) Despertar. `i` < 0 ou ocupado: primeiro espaço livre.
func _jogar_entidade(c: Carta, d: int, i: int, sacrificios: Array = []) -> void:
	_conta(d, "entidades")
	hud.registrar(d, c.id, "entidade")
	_pagar(d, c.custo)
	_mao_de(d).erase(c)
	_rearrumar_de(d)
	c.apagada = false
	for s in sacrificios:
		efeitos.numero((s as Carta).position + Vector2(0, -30), "SACRIFÍCIO", Color("#e0a8ff"), 1)
		await motor.morrer(s, false)
	await motor.processar_mortes()
	if i < 0 or campo_ent[d][i] != null:
		i = _espaco_livre(campo_ent[d])
	if i < 0:
		cemit[d].append({"dados": c.dados, "no": null})
		c.queue_free()
		return
	await _por_em_campo(c, d, i)
	if d == 0 and _bencao("impeto1") and not _impeto_usado:   # Bênção: a 1ª Entidade da batalha ataca na hora
		_impeto_usado = true
		c.cansada = false
		efeitos.numero(c.position + Vector2(0, -46), Sessao.t("BÊNÇÃO"), Color("#ffe39a"), 1)
	if c.lendaria and not acabou:                  # Lendária: entrada especial (raios, carta grande, faixa)
		await _entrada_lendaria(c)
	elif d == 1:
		await _vitrine(c, 1.0, Color("#ff9a8a"))
	if c.tem("impeto"):
		efeitos.numero(c.position + Vector2(0, -34), "ÍMPETO", Color("#ffe39a"), 1)
	var ctx := {"triggering": c, "attacker": null}
	await motor.disparar_selos("enemy_plays_entity", 1 - d, ctx)
	if ctx.get("anulado", false):
		if c.em_campo:
			_remover_do_campo(c)
			c.em_campo = false
			cemit[d].append({"dados": c.dados, "no": c})
			efeitos.numero(c.position + Vector2(0, -30), "ANULADA", Color("#c88aff"), 1)
			await _destruir(c)
			motor.recalcular_auras()
		await _checar_fim()
		return
	await motor.processar_mortes()
	if c.em_campo and not acabou:
		await motor.disparar_efeitos_entidade(c, "on_play", {"triggering": c, "interativo": motor.humano(d)})
		await motor.processar_mortes()
	await _checar_fim()


func _jogar_selo(c: Carta, d: int, i: int) -> void:
	_conta(d, "selos")
	hud.registrar(d, c.id, "selo")
	_pagar(d, c.custo)
	_mao_de(d).erase(c)
	_rearrumar_de(d)
	campo_selo[d][i] = c
	selo_no_turno = true
	c.apagada = false
	c.dono = d
	c.turno_posto = turno_n
	var dest := pos_selo(d, i)
	if d == 1 or c.position.distance_to(dest) > 60:
		await _arco(c, dest + Vector2(0, -24), 0.35, 20, 0.0, esc_em(dest) * 1.25).finished
	await _cair(c, dest, false)


## Rito: sobe ao centro, vira, mostra o nome e brilha → Selos enemy_plays_rite do oponente (podem anular) →
## efeito (alvo já escolhido pelo arraste em `pre`) → cemitério.
func _jogar_rito(c: Carta, d: int, pre = null, tipo_pre := "") -> void:
	_conta(d, "ritos")
	hud.registrar(d, c.id, "rito")
	_pagar(d, c.custo)
	_mao_de(d).erase(c)
	_rearrumar_de(d)
	c.apagada = false
	c.z_index = 760
	var p := Vector2(180, LINHA_Y + (40 if d == 0 else -40))
	var t := create_tween().set_parallel(true)
	t.tween_property(c, "position", p, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(c, "rotation", 0.0, 0.3)
	t.tween_property(c, "inclinacao", 0.0, 0.3)
	t.tween_property(c, "scale", Vector2(1.2, 1.2), 0.3)
	t.tween_property(c, "levantada", 1.0, 0.3)
	await t.finished
	if not c.virada_para_cima:
		await c.virar(0.24)
	await _vitrine(c, 1.15)
	for k in 3:
		var tb := create_tween()
		tb.tween_property(c, "brilho", 0.6, 0.08)
		tb.tween_property(c, "brilho", 0.0, 0.12)
		await tb.finished
	var ctx := {"triggering": c, "attacker": null, "dono": d, "fonte": c, "self": null, "interativo": motor.humano(d)}
	if pre != null and tipo_pre != "":
		ctx["_esc_" + tipo_pre] = pre
	await motor.disparar_selos("enemy_plays_rite", 1 - d, ctx)
	if ctx.get("anulado", false):
		efeitos.numero(p + Vector2(0, -50), "ANULADO", Color("#c88aff"), 2)
		await get_tree().create_timer(0.4).timeout
	else:
		motor._linha_txt = 0
		for ef in c.dados.get("efeitos", []):
			if acabou:
				break
			if motor.cond_ok(ef.get("cond"), ctx):
				await motor.executar_acoes(ef["acoes"], ctx)
	cemit[d].append({"dados": c.dados, "no": null})
	efeitos.estilhacar(c.position, [Color("#8ae3a8"), Color("#d8ffe0"), Color("#4aa070")], 70, 100)
	tremor = maxf(tremor, 2.0)
	c.queue_free()
	cemiterio[d] += 1
	await get_tree().create_timer(0.3).timeout
	await motor.processar_mortes()
	await _checar_fim()


## Relíquia: voa até a portadora, encolhe e vira a faixa dourada sob ela → Selos enemy_plays_reliquia → on_equip.
func _jogar_reliquia(c: Carta, d: int, port: Carta) -> void:
	_conta(d, "reliquias")
	hud.registrar(d, c.id, "reliquia", port.id if port != null else "")
	_pagar(d, c.custo)
	_mao_de(d).erase(c)
	_rearrumar_de(d)
	c.apagada = false
	c.z_index = 780
	if not c.virada_para_cima:
		c.virar(0.2)
	await _arco(c, port.position + Vector2(0, -10), 0.32, 24, 0.0, 0.9).finished
	for k in 2:
		var tb := create_tween()
		tb.tween_property(c, "brilho", 0.7, 0.07)
		tb.tween_property(c, "brilho", 0.0, 0.1)
		await tb.finished
	var t2 := create_tween().set_parallel(true)
	t2.tween_property(c, "position", port.position + Vector2(0, Carta.ALT * port.scale.y / 2 + 6), 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t2.tween_property(c, "scale", Vector2(0.15, 0.08), 0.18)
	await t2.finished
	c.queue_free()
	var rel := {"dados": c.dados, "nome": c.nome, "usos": c.dados.get("usos"), "portadora": port, "dono": d}
	port.reliquia = rel
	efeitos.faiscas(port.position + Vector2(0, 36), 18, Color("#ffe39a"))
	efeitos.anel(port.position, Color("#ffe39a"), 36)
	efeitos.numero(port.position + Vector2(0, -44), PixelFonte.normalizar(c.nome), Color("#ffe39a"), 1)
	_piscar(port)
	var ctx := {"triggering": rel, "attacker": null, "equipped": port}
	await motor.disparar_selos("enemy_plays_reliquia", 1 - d, ctx)
	if ctx.get("anulado", false):
		motor.remover_reliquia(rel)
		await motor.processar_mortes()
		await _checar_fim()
		return
	await motor.processar_mortes()
	if is_same(port.reliquia, rel) and port.em_campo and not acabou:
		motor._linha_txt = 0
		await motor.disparar_efeitos_reliquia(rel, "on_equip", {"triggering": rel, "interativo": motor.humano(d)})
		motor.recalcular_auras()
		await motor.processar_mortes()
	await _checar_fim()


# ---------- regras de ataque ----------
## "" = pode; senão o motivo. alvo == null → golpe direto na Cornucópia.
func _pode_atacar(c: Carta, alvo: Carta) -> String:
	if not modo_partida:
		return ""
	if not c.virada_para_cima:
		return "VIRADA"
	if c.sem_ataque:
		return "CONGELADA"
	if c.cansada and not c.tem("impeto"):
		return "CANSADA"
	if c.atacou:
		return "JÁ ATACOU"
	var inimigo := 1 - c.dono
	if alvo == null:
		return "" if _campo_vazio(inimigo) else "HÁ DEFENSORES"
	var guardas: Array = []
	for i in 4:
		var e = campo_ent[inimigo][i]
		if e != null and (e as Carta).virada_para_cima and (e as Carta).tem("guarda"):
			guardas.append(e)
	if not guardas.is_empty() and not (alvo in guardas):
		return "GUARDA"
	return ""


## Renascer: em vez de ir ao cemitério, volta para a mão do dono (uma vez — perde a palavra-chave).
func _renascer(c: Carta) -> void:
	_piscar(c)
	efeitos.faiscas(c.position, 16, Color("#ffe39a"))
	efeitos.numero(c.position + Vector2(0, -34), "RENASCER", Color("#ffe39a"), 1)
	await get_tree().create_timer(0.35).timeout
	await _entrar_na_mao(c.dono_real, c)


# ---------- segurar para ver a carta ----------
func _tentar_zoom(p: Vector2) -> void:
	var cands: Array = []
	for c in mao_jog:
		cands.append(c)
	for d in 2:
		for i in 4:
			if campo_ent[d][i] != null:
				cands.append(campo_ent[d][i])
	for i in 2:
		if campo_selo[0][i] != null:
			cands.append(campo_selo[0][i])
	for i in range(cands.size() - 1, -1, -1):
		var c: Carta = cands[i]
		if is_instance_valid(c) and c.contem(p) and (c.virada_para_cima or c.dono == 0):
			zoom_pendente = c
			zoom_t = 0.0
			zoom_ini = p
			return


func _atualizar_zoom(delta: float) -> void:
	if segurando != null:
		segurando_t += delta
		if segurando_t > 0.4 and ponteiro.distance_to(segurando_ini) < 5.0:
			# segurou parado: abre a carta e cancela o arraste (ela volta ao lugar)
			var c := segurando
			segurando = null
			efeitos.destaques.clear()
			efeitos.zoom = c
			zoom_travado = true
			_devolver(c)
	elif zoom_pendente != null:
		zoom_t += delta
		if not is_instance_valid(zoom_pendente) or ponteiro.distance_to(zoom_ini) >= 5.0:
			zoom_pendente = null
			efeitos.zoom = null
		elif zoom_t > 0.4:
			efeitos.zoom = zoom_pendente
			zoom_travado = true
			zoom_pendente = null


# ---------- IA (oponente; e o jogador com GD_AUTO=1) — port do HeurBot de sim/bots.py ----------
const LIMIAR_RITO := 1.5


func _turno_ia(d: int) -> void:
	ocupado = true
	_acoes_ia = 0
	await get_tree().create_timer(0.4).timeout
	for _k in 60:
		if acabou:
			break
		var acao := _ia_escolher(d)
		if acao.is_empty():
			break
		_conta(d, "ia_" + str(acao["tipo"]))
		_acoes_ia += 1
		if online_partida():                          # teste online: a IA joga por mim e a jogada vai pela rede
			_enviar(_codificar_ia(d, acao))
		if acao["tipo"] == "jogar":
			var carta: Carta = acao["carta"]
			if d == 1 and (carta.lendaria or carta.custo >= 5):
				_provocar(0)
			match carta.tipo:
				"entidade":
					var sac := int(carta.dados.get("sacrificio", 0))
					var vitimas: Array = motor.campo(d)
					vitimas.sort_custom(func(a: Carta, b: Carta) -> bool: return motor.valor(a) < motor.valor(b))
					await _jogar_entidade(carta, d, -1, vitimas.slice(0, sac))
				"selo":
					await _jogar_selo(carta, d, _espaco_livre(campo_selo[d]))
				"reliquia":
					await _jogar_reliquia(carta, d, acao["alvo"])
				_:
					await _jogar_rito(carta, d)
		else:
			var c: Carta = acao["atacante"]
			if acao["alvo"] == null:
				if d == 1:
					_provocar(1)
				await _golpe_direto(c, 1 - d)
			else:
				await _atacar(c, acao["alvo"])
		await get_tree().create_timer(0.35).timeout
	await get_tree().create_timer(0.3).timeout
	if online_partida() and not acabou:
		_enviar({"tipo": "fim", "h": _hash_estado()})
	ocupado = false


## Nível da IA por lado: 0 Aprendiz (erra de propósito), 1 Mestre (heurística gulosa), 2 Arquimago (planeja o turno).
func _ia_escolher(d: int) -> Dictionary:
	match int(nivel_ia[d]):
		0: return _ia_com_erros(d, ERROS_APRENDIZ)
		2: return _ia_arquimago(d)
	return _ia_com_erros(d, ERROS_MESTRE)


## Mestre: uma ação por vez: letal na Cornucópia > melhor jogada (pontuação > 0) > melhor ataque.
func _ia_escolher_mestre(d: int) -> Dictionary:
	var ini := 1 - d
	var prontos: Array = motor.campo(d).filter(func(e: Carta) -> bool: return motor.pode_atacar(e))
	if _campo_vazio(ini) and not prontos.is_empty():
		var total := 0
		for e in prontos:
			total += (e as Carta).atk
		if total >= cornucopia[ini]:
			for e in prontos:
				if _pode_atacar(e, null) == "" and (e as Carta).atk > 0:
					return {"tipo": "atacar", "atacante": e, "alvo": null}
	var jogada := _ia_melhor_jogada(d)
	if not jogada.is_empty():
		return jogada
	var melhor := {}
	var nota := 0.0
	for e in prontos:
		var plano := _ia_plano_ataque(e)
		if plano["acao"] != "nada" and float(plano["nota"]) > nota:
			nota = plano["nota"]
			melhor = {"tipo": "atacar", "atacante": e, "alvo": plano.get("alvo")}
	return melhor


func _ia_melhor_jogada(d: int) -> Dictionary:
	var melhor := {}
	var pontos_melhor := 0.0
	var vistos := {}
	for c in _mao_de(d):
		var carta: Carta = c
		if vistos.has(carta.id) or _motivo_jogar(carta, d) != "":
			continue
		vistos[carta.id] = true
		var opcoes: Array = []
		if carta.tipo == "reliquia":
			for port in _portadoras(d):
				var pc: Carta = port
				opcoes.append([1.5 + carta.custo * 0.5 + pc.atk * 0.3 + (1.5 if motor.pode_atacar(pc) else 0.0), pc])
		elif carta.tipo == "entidade":
			var base := 2.0 + carta.custo + carta.keywords.size() * 0.5 + (_peso(d, "impeto") if carta.tem("impeto") else 0.0) \
				+ (_peso(d, "guarda") if carta.tem("guarda") else 0.0)
			var sac := int(carta.dados.get("sacrificio", 0))
			if sac > 0:
				var vs: Array = motor.campo(d).map(func(e: Carta) -> float: return motor.valor(e))
				vs.sort()
				for k in sac:
					base -= float(vs[k]) * 0.5
			opcoes.append([base, null])
		elif carta.tipo == "selo":
			opcoes.append([1.5 + carta.custo * 0.5 + _peso(d, "selo"), null])
		else:
			opcoes.append([_ia_utilidade_rito(d, carta), null])
		for o in opcoes:
			var pts: float = o[0]
			if pts > pontos_melhor or (pts == pontos_melhor and not melhor.is_empty() and carta.custo > (melhor["carta"] as Carta).custo):
				pontos_melhor = pts
				melhor = {"tipo": "jogar", "carta": carta, "alvo": o[1]}
	return melhor if pontos_melhor > 0.0 else {}


func _ia_utilidade_rito(d: int, c: Carta) -> float:
	var total := 0.0
	for ef in c.dados.get("efeitos", []):
		if not motor.cond_ok(ef.get("cond"), {"dono": d, "triggering": c}):
			return 0.0
		for a in ef["acoes"]:
			total += _ia_utilidade_acao(d, a)
	return total if total >= LIMIAR_RITO else 0.0


func _ia_utilidade_acao(d: int, a: Dictionary) -> float:
	var ini := 1 - d
	var op: String = a["op"]
	var alvo := str(a.get("alvo", ""))
	var meus: Array = motor.campo(d)
	var deles: Array = motor.campo(ini)
	var inimigos: Array = deles.filter(func(e: Carta) -> bool: return not e.protegida()) if alvo in ["enemy_entity", "enemy_entity_random"] else deles
	var n := int(a.get("n", 0))
	var rem := _peso(d, "remocao")
	match op:
		"damage":
			if alvo == "enemy_cornucopia":
				return 2.0 * _peso(d, "face") + (10.0 if cornucopia[ini] <= n else 0.0)
			if alvo == "all_enemy_entities":
				var s := 0.0
				for e in deles:
					s += 1.5 if (e as Carta).vida() <= n else 0.7
				return s
			if alvo == "all_entities":
				var s := 0.0
				for e in deles:
					s += 1.5 if (e as Carta).vida() <= n else 0.7
				for e in meus:
					s -= 1.0 if (e as Carta).vida() <= n else 0.3
				return s
			if not inimigos.is_empty():
				for e in inimigos:
					if (e as Carta).vida() <= n:
						return 3.0 * rem
				return 1.0
			return 0.0
		"heal":
			if alvo == "ally_cornucopia":
				return 1.0 if cornucopia[d] <= 15 - n else 0.0
			for e in meus:
				if (e as Carta).dano > 0:
					return 1.5
			return 0.0
		"draw":
			return 1.5 * n
		"search":
			for c in _deck_de(d):
				var cc: Carta = c
				if (a.get("tipo") == null or cc.tipo == a["tipo"]) and (a.get("custo_max") == null or cc.custo <= int(a["custo_max"])) \
						and (a.get("keyword") == null or a["keyword"] in cc.keywords):
					return 2.0
			return 0.0
		"buff":
			if alvo.begins_with("enemy") or alvo == "all_enemy_entities":
				return 2.0 if not inimigos.is_empty() else 0.0
			if meus.is_empty():
				return 0.0
			var prontos := meus.any(func(e: Carta) -> bool: return motor.pode_atacar(e))
			return (2.0 if (prontos or a.get("perm", true)) else 0.5) + 0.3 * (int(a.get("atk", 0)) + int(a.get("vida", 0)))
		"destroy", "bounce", "freeze", "silence", "swap_control", "set_stats":
			if inimigos.is_empty() and alvo.begins_with("enemy"):
				return 0.0
			if alvo == "all_entities":
				var s := 0.0
				for e in deles:
					s += motor.valor(e) * 0.5
				for e in meus:
					s -= motor.valor(e) * 0.5
				return s
			if op == "set_stats" and alvo.begins_with("ally"):
				return 2.0 if not meus.is_empty() else 0.0
			if op == "swap_control" and not motor.tem_slot(d):
				return 0.0
			return {"destroy": 4.0, "swap_control": 4.0, "bounce": 2.0, "freeze": 1.5, "silence": 1.5, "set_stats": 2.0}[op] * rem
		"summon":
			return 2.0 if motor.tem_slot(d) else 0.0
		"revive":
			if motor.entidades_cemiterio(d).is_empty():
				return 0.0
			if str(a.get("para", "hand")) == "field" and not motor.tem_slot(d):
				return 0.0
			return 3.0
		"discard":
			return 2.0 if not _mao_de(ini).is_empty() else 0.0
		"gain_fe":
			for c in _mao_de(d):
				if (c as Carta).tipo != "rito" and (c as Carta).custo <= fe[d] + n:
					return 1.5
			return 0.5
		"give_keyword":
			return 1.5 if not meus.is_empty() else 0.0
		"copy_stats":
			return 1.0
		"win", "ritual_choronzon":
			return 20.0
	return 1.0


## Melhor ataque desta Entidade: mata-e-sobrevive > troca favorável > dano grátis; Cornucópia se o campo inimigo
## está vazio. Nunca morre sem matar. {"acao": "direto"|"carta"|"nada", "alvo", "nota"}
func _ia_plano_ataque(c: Carta) -> Dictionary:
	if c.atk <= 0 and c.efeitos.is_empty() and c.reliquia.is_empty():
		return {"acao": "nada", "nota": 0.0}
	if _pode_atacar(c, null) == "":
		return {"acao": "direto", "alvo": null, "nota": (10.0 + c.atk) * _peso(c.dono, "face")}
	var inimigo := 1 - c.dono
	var melhor: Carta = null
	var nota := 0.0
	for e in motor.campo(inimigo):
		if _pode_atacar(c, e) != "":
			continue
		var alvo: Carta = e
		var mata := c.atk >= alvo.vida()
		var morre := alvo.atk >= c.vida()
		var n := 0.0
		if mata and not morre:
			n = (8.0 + motor.valor(alvo)) * _peso(c.dono, "mata")
		elif mata and morre:
			var diff := motor.valor(alvo) - motor.valor(c) * _peso(c.dono, "perda")
			n = 2.0 + diff if diff >= -_peso(c.dono, "troca") else 0.0
		elif not morre:
			n = (1.0 + c.atk * 0.5) * _peso(c.dono, "face") if c.atk > 0 else 0.0
		if n > nota:
			nota = n
			melhor = alvo
	if melhor != null:
		return {"acao": "carta", "alvo": melhor, "nota": nota}
	return {"acao": "nada", "nota": 0.0}


var _ultima_provocacao := -100.0


## Fala curta do oponente (lore.json → provocacoes[i]): 0 = carta forte, 1 = golpe na Cornucópia, 2 = perdeu carta.
## No máximo uma a cada 6 s, para não virar ruído.
func _provocar(i: int) -> void:
	if Sessao.modo in ["", "enigma"] or tempo - _ultima_provocacao < 6.0:
		return
	var p: Dictionary = Sessao.personagem(Sessao.oponente)
	var lista: Array = p.get("provocacoes", [])
	if i >= lista.size():
		return
	_ultima_provocacao = tempo
	efeitos.falar(p.get("nome", ""), lista[i], Color(p.get("cor", "#e2b85a")), Sessao.oponente)


## Carta que estava sendo arrastada volta ao lugar sem sacudir (usado ao abrir o zoom).
func _devolver(c: Carta) -> void:
	var t := create_tween().set_parallel(true)
	t.tween_property(c, "inclinacao", 0.0, 0.15)
	t.tween_property(c, "levantada", 0.0, 0.15)
	if origem == "mao":
		var k := mao_jog.find(c)
		var lay: Array = _layout_mao(mao_jog.size(), k)
		c.z_index = 500 + k
		t.tween_property(c, "position", lay[0], 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		t.tween_property(c, "rotation", lay[1], 0.2)
		t.tween_property(c, "scale", Vector2.ONE, 0.2)
	else:
		var dest := pos_ent(0, origem_idx)
		c.z_index = 100
		t.tween_property(c, "position", dest, 0.2)
		t.tween_property(c, "rotation", 0.0, 0.2)
		t.tween_property(c, "scale", Vector2.ONE * esc_em(dest), 0.2)


# ================= roteiro de vídeo (GD_ROTEIRO=1): os 5 tipos de jogada com efeito real =================
func _carta_db(cid: String, d: int, pos: Vector2, esc: float) -> Carta:
	var c := _nova_carta(pos, esc)
	c.definir(db["cartas"][cid], d)
	return c


func _roteiro_efeitos() -> void:
	ativo = 0
	turno_n = 5
	fe_max = [8, 7]
	fe = [8, 0]
	# mesa montada: Rama (pronto) do nosso lado; Lázaro e Nezha do outro; um Selo (Arapuca) do oponente, de turno passado
	var rama := _carta_db("hin_rama", 0, proj(DECK_JOG), 0.5)
	rama.virada_para_cima = true
	await _por_em_campo(rama, 0, 1)
	rama.cansada = false
	var lazaro := _carta_db("cri_lazaro_de_betania", 1, proj(DECK_OPON), 0.5)
	lazaro.virada_para_cima = true
	await _por_em_campo(lazaro, 1, 1)
	var nezha := _carta_db("tao_nezha", 1, proj(DECK_OPON), 0.5)
	nezha.virada_para_cima = true
	await _por_em_campo(nezha, 1, 2)
	var selo := _carta_db("ind_arapuca", 1, proj(DECK_OPON), 0.5)
	await _jogar_selo_roteiro(selo, 1, 0)
	# mão: Rito sem alvo, Rito com alvo, Relíquia, Entidade com Despertar de alvo
	var ids := ["ind_cauim", "tao_flechas_de_houyi", "ind_ibirapema", "bru_circe"]
	cornucopia[0] = 11
	for k in mini(ids.size(), mao_jog.size()):
		mao_jog[k].definir(db["cartas"][ids[k]], 0)
		mao_jog[k].virada_para_cima = true
	_atualizar_apagadas()
	efeitos.numero(Vector2(180, LINHA_Y - 4), "SEU TURNO", Color("#ffe39a"), 2)
	await get_tree().create_timer(1.2).timeout
	var banquete: Carta = mao_jog[0]
	var flechas: Carta = mao_jog[1]
	var ibira: Carta = mao_jog[2]
	var circe: Carta = mao_jog[3]
	# 1) Rito sem alvo: solta em qualquer lugar do campo
	await _demo_arrastar(banquete.position, Vector2(180, 250), 0.7)
	await _esperar_livre()
	await get_tree().create_timer(0.8).timeout
	# 2) Rito com alvo: solta em cima do Lázaro
	await _demo_arrastar(flechas.position, lazaro.position, 0.7)
	await _esperar_livre()
	await get_tree().create_timer(0.8).timeout
	# 3) Relíquia: solta sobre o Rama
	await _demo_arrastar(ibira.position, rama.position, 0.6)
	await _esperar_livre()
	await get_tree().create_timer(0.8).timeout
	# 4) Despertar com alvo: Circe cai no espaço, o jogador toca a Nezha
	_demo_arrastar(circe.position, pos_ent(0, 2), 0.6)
	while alvos_pedidos.is_empty():
		await get_tree().process_frame
	await get_tree().create_timer(0.7).timeout
	await _demo_tocar(nezha.position)
	await _esperar_livre()
	await get_tree().create_timer(0.8).timeout
	# 5) Rama ataca a Nezha → o Selo Arapuca do oponente dispara
	await _demo_arrastar(rama.position, nezha.position, 0.6)
	await _esperar_livre()
	efeitos.cursor = Vector2(-100, -100)
	await get_tree().create_timer(1.5).timeout
	print("ROTEIRO: fim  ", motor.resumo())


func _esperar_livre() -> void:
	await get_tree().process_frame
	while ocupado:
		await get_tree().process_frame


func _jogar_selo_roteiro(c: Carta, d: int, i: int) -> void:
	campo_selo[d][i] = c
	c.dono = d
	c.turno_posto = 1
	var dest := pos_selo(d, i)
	await _arco(c, dest + Vector2(0, -24), 0.35, 20, 0.0, esc_em(dest) * 1.25).finished
	await _cair(c, dest, false)


# ================= menu, tempo, regras, mulligan, resumo, lendárias (HUD em mesa_hud.gd) =================
const MULLIGAN_MAX := 2                       # regras.md: pode trocar até 2 cartas da mão inicial, uma vez


func vibrar(ms: int, forca: float = 0.5) -> void:
	Sessao.vibrar(ms, forca)


## Velocidade da mesa = teste × opção "animações rápidas" (1,5×) × botão RÁPIDO no turno do oponente (2,5×); pausa = 0.
func aplicar_tempo() -> void:
	var v := _vel_teste * Sessao.velocidade_mesa()
	if acelerar_ia and ativo == 1:
		v *= 2.5
	if rede != null and (rede.recebidas.size() > 2 or not rede.proprias.is_empty()):
		v *= 4.0                                   # alcançando: várias jogadas na fila
	Engine.time_scale = 0.0 if pausado else v


func pausar(sim: bool) -> void:
	pausado = sim and not online_partida()        # online o jogo não para (o outro lado continua)
	aplicar_tempo()


func desistir() -> void:
	if tut != null:                            # tutorial: sai direto para o menu
		Engine.time_scale = 1.0
		Sessao.modo = ""
		Sessao.resultado = ""
		get_tree().change_scene_to_file("res://fluxo.tscn")
		return
	if online_partida():
		_enviar({"tipo": "desistir"})
	_encerrar(1, Sessao.t("DESISTÊNCIA"))


func tocar_som(nome: String) -> void:
	var arq := "res://audio/sfx/%s.wav" % nome
	if _som and ResourceLoader.exists(arq):
		_som.stream = load(arq)
		_som.play()


## Prévia ao arrastar uma Entidade do campo: dano dos dois lados e caveira em quem morre (ou o motivo da recusa).
func _atualizar_previa() -> void:
	hud.previa = {}
	if segurando == null or origem != "campo" or not segurando.virada_para_cima or ativo != 0:
		return
	var c := segurando
	var i := _inimigo_sob(ponteiro)
	if i >= 0:
		var alvo: Carta = campo_ent[1][i]
		var motivo := _pode_atacar(c, alvo)
		if motivo != "":
			hud.previa = {"motivo": motivo, "alvo": alvo}
		else:
			hud.previa = {"alvo": alvo, "da": c.atk, "dd": alvo.atk, "letal_alvo": alvo.vida() - c.atk <= 0,
				"letal_atk": c.vida() - alvo.atk <= 0}
	elif _campo_vazio(1) and ponteiro.y < LINHA_Y:
		var motivo := _pode_atacar(c, null)
		hud.previa = {"motivo": motivo, "alvo": null} if motivo != "" else {"direto": true, "da": c.atk}


## Mulligan: depois da mão inicial, o jogador marca até 2 cartas; elas voltam ao deck, ele embaralha e compra o mesmo número.
func _mulligan() -> void:
	if online_partida() and auto_jogador:
		if not rede.proprias.is_empty() and str(rede.proprias[0].get("tipo", "")) == "mull":
			rede.proprias.pop_front()                  # reconexão: a escolha já foi enviada
		else:
			_enviar({"tipo": "mull", "k": []})
		return
	if Sessao.modo == "tutorial" or auto_jogador or OS.get_environment("GD_SEM_MULLIGAN") != "":
		return
	hud.mulligan = true
	hud.marcadas.clear()
	efeitos.t_escolha = 0.0
	efeitos.faixa_alvo = {"titulo": Sessao.t("MÃO INICIAL"), "sub": Sessao.t("TOQUE ATÉ 2 CARTAS PARA TROCAR"), "y": LINHA_Y}
	efeitos.escolha = [{"rect": Rect2(70, LINHA_Y + 20, 104, 16), "texto": Sessao.t("MANTER"), "valor": false},
		{"rect": Rect2(186, LINHA_Y + 20, 104, 16), "texto": Sessao.t("TROCAR (%d)") % 0, "valor": true}]
	if OS.get_environment("GD_MULLIGAN_AUTO") != "":           # teste: "0,2" marca essas cartas e troca
		for k in OS.get_environment("GD_MULLIGAN_AUTO").split(","):
			hud.marcadas.append(mao_jog[int(k)])
		efeitos.escolha[1]["texto"] = Sessao.t("TROCAR (%d)") % hud.marcadas.size()
		get_tree().create_timer(1.5).timeout.connect(func() -> void: escolhido.emit(true))
	var v
	var refeito := false
	if online_partida() and not rede.proprias.is_empty() and str(rede.proprias[0].get("tipo", "")) == "mull":
		for k in rede.proprias.pop_front().get("k", []):
			if int(k) < mao_jog.size():
				hud.marcadas.append(mao_jog[int(k)])
		v = true
		refeito = true
	else:
		if online_partida():
			_contagem_mulligan(25)
		v = await escolhido
	var trocar: Array = hud.marcadas.duplicate() if v == true else []
	if online_partida() and not refeito:
		_enviar({"tipo": "mull", "k": trocar.map(func(c: Carta) -> int: return mao_jog.find(c))})
	hud.mulligan = false
	hud.marcadas.clear()
	efeitos.faixa_alvo = {}
	efeitos.escolha.clear()
	if trocar.is_empty():
		return
	ocupado = true
	tocar_som("embaralhar_2")
	var dest := proj(DECK_JOG)
	var esc := ESC_CAMPO * escala_em(DECK_JOG.y)
	for c in trocar:
		mao_jog.erase(c)
		(c as Carta).z_index = 600
		(c as Carta).virar(0.2)
		_arco(c, dest, 0.38, 30, 0.0, esc)
		await get_tree().create_timer(0.12).timeout
	_rearrumar_de(0)
	await get_tree().create_timer(0.45).timeout
	for c in trocar:
		(c as Carta).empilhada = true
		deck_jog.insert(0, c)
	_embaralhar_deck(0)
	efeitos.numero(proj(DECK_JOG) + Vector2(0, -40), Sessao.t("EMBARALHANDO"), Color("#e0c8ff"), 1)
	await get_tree().create_timer(0.35).timeout
	for k in trocar.size():
		await _receber_comprada(0, deck_jog.pop_back(), false)
	ocupado = false


## Lendária entrando em campo: o HUD mostra a carta grande com raios (2 s); vibra e treme no impacto.
func _entrada_lendaria(c: Carta) -> void:
	hud.entrada_lendaria(c)
	Sessao.vibrar_pulsos(2, 40, 0.8, 0.08)
	await get_tree().create_timer(0.45).timeout
	tremor = 6.0
	efeitos.flash(Color("#ffe39a") if c.dono == 0 else Color("#ff9a6a"), 0.3)
	efeitos.faiscas(c.position, 30, Color("#ffe39a"))
	await get_tree().create_timer(1.55).timeout


func abrir_regras() -> void:
	perg.abrir(_blocos_regras())


func _blocos_regras() -> Array:
	if Sessao.idioma == "en":
		return [["titulo", "Rules"],
			["sub", "Goal"], ["txt", "Bring the enemy Cornucopia (15) down to 0. Summoning Choronzon wins on the spot."],
			["sub", "Faith"], ["txt", "Your mana. Max Faith goes up by 1 every turn (up to 8) and refills. Every card costs Faith."],
			["sub", "Turn"], ["txt", "Draw 1 card, then play cards and attack in any order. Hand limit is 7."],
			["sub", "Card types"],
			["item", "Entity: fights on the field (4 slots). Enters tired: attacks next turn."],
			["item", "Seal: face down, fires on the enemy turn when its trigger happens. 1 per turn, 2 slots."],
			["item", "Rite: instant effect, then goes to the graveyard."],
			["item", "Relic: equips an allied Entity."],
			["sub", "Combat"],
			["txt", "Drag one of your Entities onto an enemy one. Both deal damage at the same time. Direct hits on the Cornucopia only when the enemy has no Entities."],
			["sub", "Keywords"],
			["item", "Haste: can attack the turn it enters."],
			["item", "Guard: enemies must attack it first."],
			["item", "Rebirth: when it dies, goes back to your hand (once)."],
			["item", "Stealth: can't be targeted by enemy effects until it attacks."],
			["item", "Awaken: effect when summoned from the hand."],
			["item", "Last Breath: effect when it dies."],
			["item", "Sacrifice N: sacrifice N allied Entities to summon it."],
			["item", "Uses N: a Relic with N charges."],
			["sub", "Empty deck"],
			["txt", "With 6+ Cornucopia you may pay 5 to reshuffle the graveyard into the deck. Otherwise each missing card deals 2 damage."],
			["sub", "Tips"],
			["item", "Hold a card to read it."], ["item", "Tap a graveyard to see it."],
			["item", "Left column: the last plays. Tap one to see the card."]]
	return [["titulo", "Regras"],
		["sub", "Objetivo"], ["txt", "Zere a Cornucópia inimiga (15). Invocar Choronzon vence na hora."],
		["sub", "Fé"], ["txt", "É o seu recurso. A Fé máxima sobe 1 por turno (até 8) e se renova. Toda carta custa Fé."],
		["sub", "Turno"], ["txt", "Compre 1 carta; depois jogue cartas e ataque na ordem que quiser. A mão tem limite de 7."],
		["sub", "Tipos de carta"],
		["item", "Entidade: luta no campo (4 espaços). Entra cansada: ataca no turno seguinte."],
		["item", "Selo: fica virado e dispara no turno inimigo quando o gatilho acontece. 1 por turno, 2 espaços."],
		["item", "Rito: efeito imediato; depois vai ao cemitério."],
		["item", "Relíquia: equipa uma Entidade aliada."],
		["sub", "Combate"],
		["txt", "Arraste uma Entidade sua sobre uma inimiga. As duas causam dano ao mesmo tempo. Golpe direto na Cornucópia só quando o inimigo não tem Entidades."],
		["sub", "Palavras-chave"],
		["item", "Ímpeto: pode atacar no turno em que entra."],
		["item", "Guarda: os inimigos precisam atacá-la primeiro."],
		["item", "Renascer: ao morrer, volta para a sua mão (uma vez)."],
		["item", "Furtivo: não pode ser alvo de efeitos inimigos até atacar."],
		["item", "Despertar: efeito ao ser invocada da mão."],
		["item", "Último Sopro: efeito ao morrer."],
		["item", "Sacrifício N: sacrifique N Entidades aliadas para invocá-la."],
		["item", "Usos N: Relíquia com N cargas."],
		["sub", "Deck vazio"],
		["txt", "Com 6 ou mais de Cornucópia, você pode pagar 5 para reembaralhar o cemitério no deck. Senão, cada carta que faltar causa 2 de dano."],
		["sub", "Dicas"],
		["item", "Segure uma carta para ler."], ["item", "Toque num cemitério para vê-lo."],
		["item", "Coluna da esquerda: as últimas jogadas. Toque numa para ver a carta."]]


## Resumo no fim da partida (pergaminho): resultado, turnos, cartas jogadas, dano, mortes e moedas do Arcade.
func _resumo() -> void:
	var en := Sessao.idioma == "en"
	var p: Dictionary = Sessao.personagem(Sessao.oponente)
	var titulo: Array = {0: ["Vitória", "Victory"], 1: ["Derrota", "Defeat"], 2: ["Empate", "Draw"]}.get(vencedor, ["Empate", "Draw"])
	var jog := func(d: int) -> int:
		return int(estat[d].get("entidades", 0)) + int(estat[d].get("selos", 0)) + int(estat[d].get("ritos", 0)) + int(estat[d].get("reliquias", 0))
	var b: Array = [["titulo", titulo[1 if en else 0]]]
	if p.has("nome"):
		b.append(["centro", ("against %s" if en else "contra %s") % p["nome"]])
	b.append(["divisor"])
	b.append(["item", ("Turns: %d" if en else "Turnos: %d") % turno_n])
	b.append(["item", ("Cards played: %d (opponent %d)" if en else "Cartas jogadas: %d (oponente %d)") % [jog.call(0), jog.call(1)]])
	b.append(["item", ("Damage to the enemy Cornucopia: %d" if en else "Dano na Cornucópia inimiga: %d") % (int(_corn_ini[1]) - maxi(cornucopia[1], 0))])
	b.append(["item", ("Damage taken: %d" if en else "Dano recebido: %d") % (int(_corn_ini[0]) - maxi(cornucopia[0], 0))])
	b.append(["item", ("Enemy Entities destroyed: %d" if en else "Entidades inimigas destruídas: %d") % int(estat[1].get("mortes", 0))])
	b.append(["item", ("Attacks: %d" if en else "Ataques: %d") % (int(estat[0].get("ataques", 0)) + int(estat[0].get("golpes_diretos", 0)))])
	if Sessao.modo == "arcade" and vencedor == 0:
		b.append(["espaco"])
		b.append(["destaque", "+%d" % Sessao.moedas_arcade(), "moeda"])
		b.append(["centro", "Arcade coins" if en else "moedas do Arcade"])
	perg.abrir(b)
	await perg.fechou


func _passo_hud(pt: PackedStringArray) -> void:
	match pt[1]:
		"menu": hud.pressionar(hud.rect_menu().get_center())
		"continuar": hud._acao_menu("continuar")
		"desistir": hud._acao_menu("desistir")
		"regras": hud._acao_menu("regras")
		"fechar": perg.fechar()
		"rolar": perg.rolagem = perg._limitar(float(pt[2]))
		"emote": hud.emote_jogador(int(pt[2]))
		"emotes": hud.pressionar(hud.rect_emote().get_center())
		"hist": hud.hist_aberto = int(pt[2])
		"tocar": hud.pressionar(Vector2(180, 600))
		"zoom": efeitos.zoom = campo_ent[0][0] if campo_ent[0][0] != null else mao_jog[0]
		"atacar": await _atacar(campo_ent[0][int(pt[2])], campo_ent[1][int(pt[3])])
		"golpe": await _golpe_direto(campo_ent[0][int(pt[2])], 1)
		"fim": fim_turno_pedido.emit()
		"lendaria":
			var c := _carta_db(pt[2], 1, proj(DECK_OPON), 0.6)
			c.virada_para_cima = true
			await _por_em_campo(c, 1, _espaco_livre(campo_ent[1]))
			hud.registrar(1, c.id, "entidade")
			await _entrada_lendaria(c)
		"previa":
			var a := _carta_db(pt[2], 0, pos_ent(0, 0), esc_em(pos_ent(0, 0)))
			a.virada_para_cima = true
			await _por_em_campo(a, 0, 0)
			var b := _carta_db(pt[3], 1, pos_ent(1, 1), esc_em(pos_ent(1, 1)))
			b.virada_para_cima = true
			await _por_em_campo(b, 1, 1)
			a.cansada = false
			segurando = a
			origem = "campo"
			origem_idx = 0
			ponteiro = pos_ent(1, 1)


# ================= IA: personalidade, Aprendiz e Arquimago =================
## Pesos por estilo (multiplicam as notas da heurística). agressivo: Cornucópia acima de tudo e aceita trocas ruins;
## controle: matar e remover vale mais, perder Entidade dói; selos: arma o campo de Selos e protege com Guarda.
const PESOS_IA := {
	"equilibrado": {"face": 1.0, "mata": 1.0, "perda": 1.0, "troca": 0.0, "remocao": 1.0, "selo": 0.0, "impeto": 0.0, "guarda": 0.0},
	"agressivo": {"face": 1.6, "mata": 0.8, "perda": 0.7, "troca": 1.5, "remocao": 0.8, "selo": -0.5, "impeto": 1.5, "guarda": 0.0},
	"controle": {"face": 0.8, "mata": 1.35, "perda": 1.3, "troca": 0.0, "remocao": 1.5, "selo": 0.5, "impeto": 0.0, "guarda": 1.0},
	"selos": {"face": 0.9, "mata": 1.1, "perda": 1.15, "troca": 0.0, "remocao": 1.1, "selo": 2.5, "impeto": 0.0, "guarda": 1.5},
}


func _peso(d: int, k: String) -> float:
	return float(PESOS_IA.get(estilo_ia[d], PESOS_IA["equilibrado"]).get(k, 1.0))


## Aprendiz: a mesma heurística, com erros de propósito: às vezes não vê o letal (50%), joga uma carta qualquer em vez
## da melhor (30%), ataca um alvo qualquer (30%) ou encerra o turno cedo depois de já ter agido (20%).
var _acoes_ia := 0


## Erros de propósito por nível: [não vê o letal, carta qualquer, alvo qualquer, encerra cedo]. O Mestre erra pouco
## (fica entre o Aprendiz e o Arquimago, que não erra); o Aprendiz erra bastante. GD_ERROS_MESTRE ajusta nos testes.
const ERROS_APRENDIZ := [0.5, 0.3, 0.3, 0.2]
var ERROS_MESTRE: Array = (OS.get_environment("GD_ERROS_MESTRE").split(",") as Array).map(func(x) -> float: return float(x)) \
	if OS.get_environment("GD_ERROS_MESTRE") != "" else [0.0, 0.12, 0.12, 0.05]


func _ia_com_erros(d: int, erros: Array) -> Dictionary:
	if _acoes_ia > 0 and rng_ia.randf() < float(erros[3]):
		return {}
	var ini := 1 - d
	var prontos: Array = motor.campo(d).filter(func(e: Carta) -> bool: return motor.pode_atacar(e))
	if rng_ia.randf() >= float(erros[0]) and _campo_vazio(ini) and not prontos.is_empty():
		var total := 0
		for e in prontos:
			total += (e as Carta).atk
		if total >= cornucopia[ini]:
			for e in prontos:
				if _pode_atacar(e, null) == "" and (e as Carta).atk > 0:
					return {"tipo": "atacar", "atacante": e, "alvo": null}
	var jogaveis: Array = _mao_de(d).filter(func(c: Carta) -> bool: return _motivo_jogar(c, d) == "" and c.tipo != "reliquia")
	if not jogaveis.is_empty() and rng_ia.randf() < float(erros[1]):
		return {"tipo": "jogar", "carta": jogaveis[rng_ia.randi_range(0, jogaveis.size() - 1)], "alvo": null}
	var jogada := _ia_melhor_jogada(d)
	if not jogada.is_empty():
		return jogada
	for e in prontos:
		if rng_ia.randf() < float(erros[2]):
			var alvos: Array = motor.campo(ini).filter(func(x: Carta) -> bool: return _pode_atacar(e, x) == "")
			if not alvos.is_empty():
				return {"tipo": "atacar", "atacante": e, "alvo": alvos[rng_ia.randi_range(0, alvos.size() - 1)]}
	var melhor := {}
	var nota := 0.0
	for e in prontos:
		var plano := _ia_plano_ataque(e)
		if plano["acao"] != "nada" and float(plano["nota"]) > nota:
			nota = plano["nota"]
			melhor = {"tipo": "atacar", "atacante": e, "alvo": plano.get("alvo")}
	return melhor


## Arquimago: mesmas regras de todo mundo, só joga melhor. As jogadas do Mestre (a escolha de "conjunto de cartas" foi
## testada e perdia: 41% contra o Mestre) e
## 1) letal planejado: soma o melhor plano de ataques do turno inteiro (cada combinação atacante → alvo/Cornucópia/nada,
## com Guarda, dano simultâneo e golpe direto só com o campo limpo) aos Ritos de dano na Cornucópia que cabem na Fé;
## 2) ataques pelo plano do turno. Melhorias ligáveis (GD_ARQ, para medir): M mulligan, A ameaça, B campo, P ordem.
var _arq := (OS.get_environment("GD_ARQ") if OS.get_environment("GD_ARQ") != "" else "M,A,B,P,L").split(",")


func _arq_tem(k: String) -> bool:
	return k in _arq


func _ia_arquimago(d: int) -> Dictionary:
	var plano := _ia_plano_ataques(d)
	if plano.get("letal", false):
		return plano["primeiro"]
	# letal com Ritos de dano direto: rito primeiro, os ataques vêm na próxima escolha
	var face_plano := int(plano.get("face", 0))
	var fe_livre: int = fe[d]
	var dano_ritos := 0
	var primeiro_rito: Carta = null
	for c in _mao_de(d):
		var carta: Carta = c
		if carta.tipo != "rito" or _motivo_jogar(carta, d) != "" or carta.custo > fe_livre:
			continue
		var n := _ia_dano_cornucopia(carta)
		if n > 0:
			dano_ritos += n
			fe_livre -= carta.custo
			if primeiro_rito == null:
				primeiro_rito = carta
	if primeiro_rito != null and face_plano + dano_ritos >= cornucopia[1 - d]:
		return {"tipo": "jogar", "carta": primeiro_rito, "alvo": null}
	var jogada := _ia_melhor_jogada(d)
	if not jogada.is_empty():
		return jogada
	if float(plano.get("nota", 0.0)) > 0.0:
		return plano["primeiro"]
	return {}


func _ia_dano_cornucopia(c: Carta) -> int:
	var n := 0
	for ef in c.dados.get("efeitos", []):
		for a in ef["acoes"]:
			if str(a["op"]) == "damage" and str(a.get("alvo", "")) == "enemy_cornucopia":
				n += int(a.get("n", 0))
	return n


## M: mulligan da IA (a regra vale para os dois lados): troca até 2 cartas de custo 5+ se a mão não tiver ao menos
## 2 cartas de custo 3 ou menos; senão troca só as de custo 7+.
func _mulligan_ia(d: int) -> void:
	var mao := _mao_de(d)
	var baratas := mao.filter(func(c: Carta) -> bool: return c.custo <= 3).size()
	var limite := 5 if baratas < 2 else 7
	var trocar: Array = mao.filter(func(c: Carta) -> bool: return c.custo >= limite)
	trocar.sort_custom(func(a: Carta, b: Carta) -> bool: return a.custo > b.custo)
	if trocar.size() > MULLIGAN_MAX:
		trocar.resize(MULLIGAN_MAX)
	await _trocar_mao(d, trocar)


## Devolve as cartas ao deck, embaralha (sequência do deck) e compra o mesmo número.
func _trocar_mao(d: int, trocar: Array) -> void:
	if trocar.is_empty():
		return
	var mao := _mao_de(d)
	var deck := _deck_de(d)
	for c in trocar:
		mao.erase(c)
		(c as Carta).empilhada = true
		(c as Carta).position = proj(DECK_JOG if d == 0 else DECK_OPON)
		if (c as Carta).virada_para_cima:
			(c as Carta).virar(0.01)
		deck.insert(0, c)
	_embaralhar_deck(d)
	for k in trocar.size():
		await _receber_comprada(d, deck.pop_back(), false)


## Plano de ataques do turno inteiro. Devolve {primeiro: ação, nota, letal}.
func _ia_plano_ataques(d: int) -> Dictionary:
	var ini := 1 - d
	var atacantes: Array = motor.campo(d).filter(func(e: Carta) -> bool: return motor.pode_atacar(e) and e.atk > 0 \
		and not e.sem_ataque and not e.atacou)
	atacantes.sort_custom(func(a: Carta, b: Carta) -> bool: return a.atk > b.atk)
	if atacantes.size() > 4:
		atacantes.resize(4)
	if atacantes.is_empty():
		return {}
	var inimigos: Array = motor.campo(ini)
	var hp: Array = inimigos.map(func(e: Carta) -> int: return e.vida())
	var guarda: Array = inimigos.map(func(e: Carta) -> bool: return e.virada_para_cima and e.tem("guarda"))
	var estado := {"melhor": -INF, "seq": [], "letal": false, "face": 0}
	var ordens: Array = [atacantes]
	if _arq_tem("P") and atacantes.size() > 1:
		ordens = _permutacoes(atacantes)
	for ordem in ordens:
		_ia_busca(d, ordem, 0, inimigos, hp, guarda, 0, 0.0, [], estado)
	if _arq_tem("L") and not estado["letal"] and estado.has("top"):
		var melhor_l := -INF
		for folha in estado["top"]:
			var v := float(folha[0]) - 0.7 * _ia_resposta(d, inimigos, folha[2], folha[1])
			if v > melhor_l:
				melhor_l = v
				estado["seq"] = folha[1]
				estado["face"] = folha[3]
		estado["melhor"] = melhor_l
	var seq: Array = estado["seq"]
	for passo in seq:
		if int(passo[1]) != -2:
			var alvo = null if int(passo[1]) == -1 else inimigos[int(passo[1])]
			return {"primeiro": {"tipo": "atacar", "atacante": passo[0], "alvo": alvo}, "nota": estado["melhor"], "letal": estado["letal"],
				"face": estado["face"]}
	return {"nota": 0.0}


func _permutacoes(a: Array) -> Array:
	if a.size() <= 1:
		return [a.duplicate()]
	var out: Array = []
	for i in a.size():
		var resto := a.duplicate()
		var x = resto.pop_at(i)
		for p in _permutacoes(resto):
			out.append([x] + p)
	return out


func _ia_busca(d: int, atq: Array, k: int, inim: Array, hp: Array, guarda: Array, face: int, nota: float, seq: Array, est: Dictionary) -> void:
	if k == atq.size():
		var letal: bool = face >= int(cornucopia[1 - d])
		var total := nota + face * 1.2 * _peso(d, "face") + (1000.0 if letal else 0.0)
		if _arq_tem("B"):
			# campo inimigo limpo = golpe direto no próximo turno com o que sobrar vivo; o nosso vazio = Cornucópia exposta
			var vivos_inim := 0
			for i in inim.size():
				if int(hp[i]) > 0:
					vivos_inim += 1
			if vivos_inim == 0 and not inim.is_empty():
				var potencial := 0
				for c in motor.campo(d):
					potencial += (c as Carta).atk
				total += 0.6 * potencial
			var mortos_meus := 0
			for p in seq:
				if bool(p[2]) if p.size() > 2 else false:
					mortos_meus += 1
			if mortos_meus >= motor.campo(d).size() and vivos_inim > 0:
				var ameaca := 0
				for i in inim.size():
					if int(hp[i]) > 0:
						ameaca += (inim[i] as Carta).atk
				total -= 1.0 * ameaca
		if _arq_tem("L") and not letal:                  # guarda os 8 melhores planos para olhar a resposta do oponente
			var top: Array = est.get("top", [])
			top.append([total, seq.duplicate(), hp.duplicate(), face])
			top.sort_custom(func(x: Array, y: Array) -> bool: return float(x[0]) > float(y[0]))
			if top.size() > 8:
				top.resize(8)
			est["top"] = top
		if total > float(est["melhor"]):
			est["melhor"] = total
			est["seq"] = seq.duplicate()
			est["letal"] = letal
			est["face"] = face
		return
	var a: Carta = atq[k]
	# nada
	seq.append([a, -2])
	_ia_busca(d, atq, k + 1, inim, hp, guarda, face, nota, seq, est)
	seq.pop_back()
	var vivos := 0
	var guardas_vivas := false
	for i in inim.size():
		if int(hp[i]) > 0:
			vivos += 1
			guardas_vivas = guardas_vivas or bool(guarda[i])
	if vivos == 0:
		seq.append([a, -1])
		_ia_busca(d, atq, k + 1, inim, hp, guarda, face + a.atk, nota, seq, est)
		seq.pop_back()
		return
	for i in inim.size():
		if int(hp[i]) <= 0 or (guardas_vivas and not bool(guarda[i])):
			continue
		var e: Carta = inim[i]
		var mata := a.atk >= int(hp[i])
		var morre := e.atk >= a.vida()
		var n := 0.0
		if mata:
			n += (motor.valor(e) + 3.0 + (1.5 * e.atk if _arq_tem("A") else 0.0)) * _peso(d, "mata")
		else:
			n += 0.25 * a.atk
		if morre:
			n -= (motor.valor(a) + 1.0) * _peso(d, "perda")
		var antes: int = hp[i]
		hp[i] = int(hp[i]) - a.atk
		seq.append([a, i, morre])
		_ia_busca(d, atq, k + 1, inim, hp, guarda, face, nota + n, seq, est)
		seq.pop_back()
		hp[i] = antes


# ================= regras extras dos modos solo (Sessao.extras) =================
const MODOS_SOLO := ["livre", "diario", "lendario", "peregrinacao", "choronzon", "enigma"]
var _impeto_usado := false


func _extras() -> Dictionary:
	return Sessao.extras if (modo_partida and Sessao.modo in MODOS_SOLO) else {}


func _bencao(b: String) -> bool:
	return b in (_extras().get("bencaos", []) as Array)


## Cornucópia inicial, Lendária garantida na mão inicial do oponente e Bênçãos que mexem nas cartas do jogador.
func _aplicar_extras_deck() -> void:
	var ex := _extras()
	if ex.has("cornucopia"):
		cornucopia = [int(ex["cornucopia"][0]), int(ex["cornucopia"][1])]
	for cid in ex.get("mao_garantida", []):
		for k in deck_opon.size():
			if deck_opon[k].id == cid:                       # vai para o topo (as compras saem de pop_back)
				var c := deck_opon[k]
				deck_opon.remove_at(k)
				deck_opon.append(c)
				break
	if _bencao("selo-1") or _bencao("vida1"):
		for c in deck_jog:
			if c.tipo == "selo" and _bencao("selo-1"):
				c.custo = maxi(0, c.custo - 1)
			if c.tipo == "entidade" and _bencao("vida1"):
				c.vida_base += 1
				c.sincronizar()
	for c in deck_opon:
		c.queue_redraw()
	if OS.get_environment("GD_MODO_TESTE") != "":
		print("EXTRAS cornucopia=", cornucopia, " topo_opon=", deck_opon[deck_opon.size() - 1].id, " selos_jog=",
			deck_jog.filter(func(c: Carta) -> bool: return c.tipo == "selo").map(func(c: Carta) -> int: return c.custo))


# ================= Enigma: "vença neste turno" (dados/enigmas.json) =================
## Mesa montada: suas Entidades prontas, as dele, sua mão, sua Fé e a Cornucópia dele. Um turno só. Zerou a Cornucópia
## inimiga = resolvido; tocou FIM TURNO sem vencer = escolhe tentar de novo (recarrega a mesa) ou sair.
func _enigma() -> void:
	var e: Dictionary = _extras().get("enigma", {})
	cornucopia = [15, int(e.get("corn", 5))]
	for k in 6:                                          # deck com algumas cartas: compras de Rito não causam fadiga
		var f := _nova_carta(proj(DECK_JOG) + Vector2(0, -int(k / 3)), ESC_CAMPO * escala_em(DECK_JOG.y))
		f.definir(db["cartas"]["tao_lan_caihe"], 0)
		f.empilhada = k > 0
		f.z_index = k
		deck_jog.append(f)
	for lado in 2:
		var ids: Array = e.get("meu_campo" if lado == 0 else "campo_dele", [])
		for i in ids.size():
			var c := _carta_db(ids[i], lado, proj(DECK_JOG if lado == 0 else DECK_OPON), esc_em(pos_ent(lado, i)))
			c.virada_para_cima = true
			await _por_em_campo(c, lado, i)
			c.cansada = false
	for cid in e.get("mao", []):
		var c := _carta_db(cid, 0, proj(DECK_JOG), 1.0)
		c.virada_para_cima = true
		await _entrar_na_mao(0, c)
	fe_max[0] = int(e.get("fe", 0))
	fe[0] = fe_max[0]
	ativo = 0
	turno_n = 3
	var tit: Array = e.get("titulo", ["Enigma", "Puzzle"])
	efeitos.numero(Vector2(180, LINHA_Y - 4), str(tit[1] if Sessao.idioma == "en" else tit[0]).to_upper(), Color("#ffe39a"), 2)
	_atualizar_apagadas()
	if int(Sessao.extras.get("tentativas", 0)) >= 2:          # 3ª tentativa em diante: mostra a dica
		var dica: Array = e.get("dica", ["", ""])
		perg.abrir([["titulo", "Hint" if Sessao.idioma == "en" else "Dica"], ["centro", str(dica[1] if Sessao.idioma == "en" else dica[0])]])
	while true:
		await fim_turno_pedido
		if acabou:
			break
		var de_novo := await pedir_sim_nao(Sessao.t("AINDA NÃO"), Sessao.t("A CORNUCÓPIA DELE NÃO ZEROU"), Sessao.t("TENTAR DE NOVO"), Sessao.t("SAIR"))
		if de_novo:
			Sessao.extras["tentativas"] = int(Sessao.extras.get("tentativas", 0)) + 1
			get_tree().reload_current_scene()
			return
		vencedor = 1
		break
	Sessao.resultado = "vitoria" if vencedor == 0 else "derrota"
	print("ENIGMA ", Sessao.extras.get("enigma_id", ""), " vencedor=", vencedor, " cornucopia=", cornucopia)
	await get_tree().create_timer(0.8).timeout
	if OS.get_environment("GD_SAIR_NO_FIM") != "":
		get_tree().quit()
		return
	get_tree().change_scene_to_file("res://fluxo.tscn")


## L (olhar 2 passos): depois do nosso plano, a melhor resposta de ataque do oponente no turno dele (com as Entidades
## que sobraram dos dois lados). Devolve a nota dele: mortes que ele causa − perdas dele + golpe direto (+ letal).
func _ia_resposta(d: int, inimigos: Array, hp_inim: Array, seq: Array) -> float:
	var atq: Array = []                                   # atacantes dele: [atk, hp, valor]
	for i in inimigos.size():
		if int(hp_inim[i]) > 0 and (inimigos[i] as Carta).atk > 0:
			var e: Carta = inimigos[i]
			atq.append([e.atk, int(hp_inim[i]), motor.valor(e)])
	var defs: Array = []                                  # nossos que sobram: [atk, hp, valor, guarda]
	var dano := {}
	for p in seq:
		if int(p[1]) >= 0:
			dano[p[0]] = int(dano.get(p[0], 0)) + (inimigos[int(p[1])] as Carta).atk
	for c in motor.campo(d):
		var cc: Carta = c
		var hp_r := cc.vida() - int(dano.get(cc, 0))
		if hp_r > 0:
			defs.append([cc.atk, hp_r, motor.valor(cc), cc.virada_para_cima and cc.tem("guarda")])
	if atq.is_empty():
		return 0.0
	atq.sort_custom(func(x: Array, y: Array) -> bool: return int(x[0]) > int(y[0]))
	if atq.size() > 4:
		atq.resize(4)
	var est := {"melhor": 0.0}
	_ia_resp_busca(atq, 0, defs, defs.map(func(x: Array) -> int: return int(x[1])), 0, 0.0, int(cornucopia[d]), est)
	return float(est["melhor"])


func _ia_resp_busca(atq: Array, k: int, defs: Array, hp: Array, face: int, nota: float, corn: int, est: Dictionary) -> void:
	if k == atq.size():
		var total := nota + face * 1.2 + (1000.0 if face >= corn else 0.0)
		if total > float(est["melhor"]):
			est["melhor"] = total
		return
	var a: Array = atq[k]
	_ia_resp_busca(atq, k + 1, defs, hp, face, nota, corn, est)
	var vivos := 0
	var guardas := false
	for i in defs.size():
		if int(hp[i]) > 0:
			vivos += 1
			guardas = guardas or bool(defs[i][3])
	if vivos == 0:
		_ia_resp_busca(atq, k + 1, defs, hp, face + int(a[0]), nota, corn, est)
		return
	for i in defs.size():
		if int(hp[i]) <= 0 or (guardas and not bool(defs[i][3])):
			continue
		var n := 0.0
		if int(a[0]) >= int(hp[i]):
			n += float(defs[i][2]) + 3.0
		else:
			n += 0.25 * int(a[0])
		if int(defs[i][0]) >= int(a[1]):
			n -= float(a[2]) + 1.0
		var antes: int = hp[i]
		hp[i] = int(hp[i]) - int(a[0])
		_ia_resp_busca(atq, k + 1, defs, hp, face, nota + n, corn, est)
		hp[i] = antes


# ================= tempo por turno (universal: contra a IA e online) =================
## 75 s por turno do jogador (tempo real: não acelera com as animações rápidas e para com o menu de pausa, só offline).
## Nos últimos 20 s a corda queima ao lado do FIM TURNO. Acabou: cancela o que estiver pendente e passa o turno.
const TEMPO_TURNO := 75.0
const AVISO_TEMPO := 20.0
var relogio_ativo := false
var restante := 0.0
var _relogio_us := 0


func _limite_turno() -> bool:
	return modo_partida and tut == null and Sessao.modo != "enigma" and (online_partida() or Sessao.tempo_turno)


func online_partida() -> bool:
	return modo_partida and Sessao.modo == "online"


func _iniciar_relogio() -> void:
	if _limite_turno():
		restante = TEMPO_TURNO if OS.get_environment("GD_TEMPO_TURNO") == "" else float(OS.get_environment("GD_TEMPO_TURNO"))
		if OS.get_environment("GD_TEMPO_TURNO") != "":
			print("RELOGIO turno ", turno_n, " limite ", restante)
		relogio_ativo = true
		_relogio_us = Time.get_ticks_usec()


func _atualizar_relogio() -> void:
	var agora := Time.get_ticks_usec()
	var dt := (agora - _relogio_us) / 1000000.0
	_relogio_us = agora
	if not relogio_ativo or acabou or (pausado and not online_partida()):
		return
	var antes := restante
	restante -= dt
	if antes > 10.0 and restante <= 10.0:
		Sessao.vibrar(30, 0.5)
	if restante <= 0.0:
		_tempo_esgotado()


func _tempo_esgotado() -> void:
	relogio_ativo = false
	if ativo != 0:                                 # online: a corda do adversário só aparece; quem passa é o aparelho dele
		return
	efeitos.numero(Vector2(180, LINHA_Y - 4), Sessao.t("TEMPO!"), Color("#ffb070"), 2)
	Sessao.vibrar_pulsos(2, 40, 0.7)
	if not alvos_pedidos.is_empty():
		alvo_tocado.emit(null)
	if not efeitos.escolha.is_empty():
		escolhido.emit(efeitos.escolha[efeitos.escolha.size() - 1]["valor"])
	if carrossel.aberto():
		carrossel.selecionado.emit(-1)
	if segurando != null:
		var c := segurando
		segurando = null
		if origem == "mao":
			_recusar(c)
		else:
			_voltar_ao_espaco(c)
	while ocupado and not acabou:
		await get_tree().process_frame
	if not acabou and ativo == 0:
		fim_turno_pedido.emit()


# ================= histórico do perfil =================
func _registrar_partida() -> void:
	if not modo_partida or tut != null or (auto_jogador and OS.get_environment("GD_REGISTRAR") == "") or Sessao.modo in ["", "tutorial", "enigma"]:
		return
	var p: Dictionary = Sessao.personagem(Sessao.oponente)
	if online_partida():
		p = {"nome": str(online_info.get("adversario", "?"))}
	var jog := func(d: int) -> int:
		return int(estat[d].get("entidades", 0)) + int(estat[d].get("selos", 0)) + int(estat[d].get("ritos", 0)) + int(estat[d].get("reliquias", 0))
	Sessao.registrar_partida({
		"t": int(Time.get_unix_time_from_system()), "modo": Sessao.modo, "contra": "jogador" if online_partida() else "ia",
		"adversario": str(p.get("nome", Sessao.nome_deck(Sessao.oponente))), "nivel": int(nivel_ia[1]),
		"resultado": Sessao.resultado, "turnos": turno_n, "duracao": int((Time.get_ticks_msec() - _inicio_ms) / 1000),
		"deck": Sessao.deck_jogador_nome, "deck_op": Sessao.oponente,
		"stats": {"cartas": jog.call(0), "cartas_op": jog.call(1), "dano": int(_corn_ini[1]) - maxi(cornucopia[1], 0), "recebido": int(_corn_ini[0]) - maxi(cornucopia[0], 0),
			"mortes": int(estat[1].get("mortes", 0)), "perdas": int(estat[0].get("mortes", 0))},
		"log": log_partida})


# ================= online (passo travado: os dois aparelhos rodam a mesma partida e trocam só as ações) =================
## Aqui o jogador local é sempre o lado 0 (embaixo). _global(d) = índice do jogador no servidor (0 = quem criou/pareou
## primeiro): usado para tudo que precisa ser igual nos dois aparelhos (semente de cada deck, conferência do estado).
func _global(d: int) -> int:
	return d ^ int(online_info.get("eu", 0))


func _enviar(dados: Dictionary) -> void:
	if rede != null:
		rede.enviar(dados)


func enviar_esc(v: int) -> void:
	_enviar({"tipo": "esc", "v": v})


## Posição de um candidato na lista (cartas e entradas do cemitério comparadas por identidade). -1 = nenhum.
func _indice(lista: Array, x) -> int:
	if x == null:
		return -1
	for k in lista.size():
		if is_same(lista[k], x):
			return k
	return -1


## A escolha deste lado vem da rede? Adversário: sempre. Eu: só ao refazer jogadas já enviadas (reconexão).
func decisao_da_rede(d: int) -> bool:
	return rede != null and (d == 1 or not rede.proprias.is_empty())


func _proxima_rede(d: int) -> Dictionary:
	if d == 0:
		return rede.proprias.pop_front() if not rede.proprias.is_empty() else {}
	return await rede.proxima()


func esc_rede(d: int) -> int:
	var a: Dictionary = await _proxima_rede(d)
	if a.is_empty():
		return -1
	if str(a.get("tipo", "")) != "esc":
		_dessincronia("esperava uma escolha, veio " + str(a.get("tipo", "")))
		return -1
	return int(a.get("v", -1))


## Turno vindo da rede (adversário; ou o meu ao reconectar). true = terminou com "fim"; false = acabaram as minhas
## jogadas guardadas (reconexão no meio do turno: o resto é no toque).
func _turno_rede(d: int) -> bool:
	ocupado = true
	if d == 1:
		_iniciar_relogio()
	var terminou := true
	while not acabou:
		aplicar_tempo()
		var a: Dictionary = await _proxima_rede(d)
		if a.is_empty():
			terminou = d == 1
			break
		var tipo := str(a.get("tipo", ""))
		if tipo == "fim":
			if a.has("h") and int(a["h"]) != _hash_estado():
				_dessincronia("estado diferente no fim do turno %d" % turno_n)
			break
		if tipo == "desistir":
			await _encerrar(0 if d == 1 else 1, Sessao.t("O ADVERSÁRIO DESISTIU") if d == 1 else Sessao.t("DESISTÊNCIA"))
			break
		await _aplicar_acao(d, a)
		await get_tree().create_timer(0.25).timeout
	relogio_ativo = false
	ocupado = false
	aplicar_tempo()
	return terminou


## Aplica uma ação recebida no lado d (as mesmas funções que o toque e a IA usam: o resultado é o mesmo nos dois aparelhos).
func _aplicar_acao(d: int, a: Dictionary) -> void:
	match str(a.get("tipo", "")):
		"jogar":
			var mao := _mao_de(d)
			var k := int(a.get("k", -1))
			if k < 0 or k >= mao.size():
				_dessincronia("carta %d fora da mão (%d)" % [k, mao.size()])
				return
			var c: Carta = mao[k]
			match c.tipo:
				"entidade":
					var sacs: Array = []
					for s in a.get("sac", []):
						var e = campo_ent[d][clampi(int(s), 0, 3)]
						if e != null:
							sacs.append(e)
					await _jogar_entidade(c, d, int(a.get("i", -1)), sacs)
				"selo":
					var i := int(a.get("i", -1))
					if i < 0 or i > 1 or campo_selo[d][i] != null:
						i = _espaco_livre(campo_selo[d])
					if i < 0:
						_dessincronia("sem espaço de Selo")
						return
					await _jogar_selo(c, d, i)
				"reliquia":
					var ports := _portadoras(d)
					var pi := int(a.get("p", -1))
					if pi < 0 or pi >= ports.size():
						_dessincronia("portadora %d inexistente" % pi)
						return
					await _jogar_reliquia(c, d, ports[pi])
				_:
					var t := str(a.get("t", ""))
					if t == "":
						await _jogar_rito(c, d)
					else:
						var cands := motor.candidatos(t, d, c.dados)
						var ai := int(a.get("a", -1))
						if ai < 0 or ai >= cands.size():
							_dessincronia("alvo do rito inexistente")
							await _jogar_rito(c, d)
						else:
							await _jogar_rito(c, d, cands[ai], t)
		"mover":
			var de := clampi(int(a.get("de", 0)), 0, 3)
			var para := clampi(int(a.get("para", 0)), 0, 3)
			var c = campo_ent[d][de]
			if c == null or campo_ent[d][para] != null:
				_dessincronia("mover inválido")
				return
			campo_ent[d][de] = null
			campo_ent[d][para] = c
			var dest := pos_ent(d, para)
			await _arco(c, dest, 0.28, 18, 0.0, esc_em(dest)).finished
			_impacto(c, dest, 0.5)
		"atacar", "golpe":
			var c = campo_ent[d][clampi(int(a.get("de", 0)), 0, 3)]
			if c == null:
				_dessincronia("atacante inexistente")
				return
			if a["tipo"] == "golpe":
				if d == 1:
					_provocar(1)
				await _golpe_direto(c, 1 - d)
			else:
				var alvo = campo_ent[1 - d][clampi(int(a.get("alvo", 0)), 0, 3)]
				if alvo == null:
					_dessincronia("alvo do ataque inexistente")
					return
				await _atacar(c, alvo)
		"mull", "esc":
			_dessincronia("ação fora de hora: " + str(a["tipo"]))
		_:
			pass


## Mão inicial do adversário: espera a escolha dele (mostra que está esperando) e troca as mesmas cartas.
func _mulligan_remoto() -> void:
	if rede.recebidas.is_empty():
		efeitos.faixa_alvo = {"titulo": Sessao.t("AGUARDANDO"), "sub": Sessao.t("O ADVERSÁRIO ESTÁ ESCOLHENDO A MÃO"), "y": LINHA_Y}
	var a: Dictionary = await rede.proxima()
	efeitos.faixa_alvo = {}
	if a.is_empty():
		return
	if str(a.get("tipo", "")) != "mull":
		_dessincronia("esperava a mão inicial")
		rede.recebidas.push_front(a)
		return
	var trocar: Array = []
	for k in a.get("k", []):
		if int(k) >= 0 and int(k) < mao_opon.size() and not (mao_opon[int(k)] in trocar):
			trocar.append(mao_opon[int(k)])
	ocupado = true
	await _trocar_mao(1, trocar)
	ocupado = false


## Retrato do estado na ordem GLOBAL dos jogadores (igual nos dois aparelhos se nada divergiu).
func _hash_estado() -> int:
	var partes: Array = []
	for g in 2:
		var d := g ^ int(online_info.get("eu", 0))
		partes.append([cornucopia[d], fe[d], fe_max[d], _mao_de(d).size(), _deck_de(d).size(), cemit[d].size(),
			(campo_ent[d] as Array).map(func(c) -> String: return "" if c == null else "%s:%d:%d" % [(c as Carta).id, (c as Carta).atk, (c as Carta).vida()]),
			(campo_selo[d] as Array).map(func(c) -> String: return "" if c == null else (c as Carta).id)])
	return hash(str(partes))


func _dessincronia(msg: String) -> void:
	print("DESSINCRONIA: ", msg)
	if not dessinc:
		dessinc = true
		efeitos.numero(Vector2(180, LINHA_Y - 30), Sessao.t("DESSINCRONIA"), Color("#ff7070"), 2)


## O servidor encerrou (desistência, abandono por queda de 2 min, ou o outro aparelho viu o fim antes).
func _fim_servidor(v: int, queda: bool) -> void:
	while not acabou and (ocupado or (ativo == 1 and not rede.recebidas.is_empty())):
		await get_tree().create_timer(0.3, true, false, true).timeout
	if acabou:
		return
	var motivo := ""
	if queda:
		motivo = Sessao.t("O ADVERSÁRIO SAIU") if v == 1 else Sessao.t("SEM CONEXÃO")
	await _encerrar(0 if v == 1 else (1 if v == 0 else 2), motivo)


## Fim da partida online: relatório dos dois lados e revanche (os dois precisam aceitar) ou menu.
func _fim_online() -> void:
	rede.parar()
	await get_tree().create_timer(0.6).timeout
	if OS.get_environment("GD_SAIR_NO_FIM") != "":
		print("ONLINE FIM vencedor=", vencedor, " turnos=", turno_n, " hash=", _hash_estado(), " dessinc=", dessinc)
		await get_tree().create_timer(1.0).timeout
		get_tree().quit()
		return
	var ganho: int = [20, 5, 10][0 if vencedor == 0 else (1 if vencedor == 1 else 2)]
	Sessao.premio("online", {"pid": rede.pid}, ganho)
	await _resumo_online(ganho)
	var rev := await pedir_sim_nao(Sessao.t("REVANCHE?"), Sessao.t("OS DOIS PRECISAM ACEITAR"), Sessao.t("REVANCHE"), Sessao.t("MENU"))
	if not rev:
		Nuvem.mp("POST", "/v1/partida/%s/revanche" % rede.pid, {"recusar": true})
		_voltar_menu()
		return
	efeitos.faixa_alvo = {"titulo": Sessao.t("REVANCHE"), "sub": Sessao.t("ESPERANDO O ADVERSÁRIO..."), "y": LINHA_Y}
	_veu(1.0)
	var r: Dictionary = await Nuvem.mp("POST", "/v1/partida/%s/revanche" % rede.pid, {}, 10.0)
	var info: Dictionary = r.get("partida", {})
	var limite := Time.get_ticks_msec() + 30000
	while str(info.get("revanche_pid", "")) == "" and int(info.get("revanche", 0)) >= 0 and Time.get_ticks_msec() < limite:
		var r2: Dictionary = await Nuvem.mp("GET", "/v1/partida/%s?estado=fim&rev=%d" % [rede.pid, int(info.get("revanche", 0))], {}, 25.0)
		if r2.is_empty():
			await get_tree().create_timer(1.0).timeout
		else:
			info = r2.get("partida", info)
	var novo := str(info.get("revanche_pid", ""))
	if novo != "":
		var r3: Dictionary = await Nuvem.mp("GET", "/v1/partida/%s" % novo, {}, 10.0)
		if r3.get("ok", false):
			Sessao.preparar_online(r3["partida"])
			get_tree().change_scene_to_file("res://mesa.tscn")
			return
	efeitos.faixa_alvo = {"titulo": Sessao.t("SEM REVANCHE"), "sub": Sessao.t("O ADVERSÁRIO NÃO ACEITOU"), "y": LINHA_Y}
	await get_tree().create_timer(2.0).timeout
	_voltar_menu()


func _voltar_menu() -> void:
	Engine.time_scale = 1.0
	Sessao.modo = ""
	Sessao.extras = {}
	Sessao.online_salvo("")
	get_tree().change_scene_to_file("res://fluxo.tscn")


## Relatório com as duas colunas (você × adversário): o mesmo números que o outro aparelho vê, do lado dele.
func _resumo_online(ganho := 0) -> void:
	var en := Sessao.idioma == "en"
	var adv := str(online_info.get("adversario", "?"))
	var titulo: Array = {0: ["Vitória", "Victory"], 1: ["Derrota", "Defeat"], 2: ["Empate", "Draw"]}.get(vencedor, ["Empate", "Draw"])
	var jog := func(d: int) -> int:
		return int(estat[d].get("entidades", 0)) + int(estat[d].get("selos", 0)) + int(estat[d].get("ritos", 0)) + int(estat[d].get("reliquias", 0))
	var atq := func(d: int) -> int:
		return int(estat[d].get("ataques", 0)) + int(estat[d].get("golpes_diretos", 0))
	var b: Array = [["titulo", titulo[1 if en else 0]], ["centro", ("against %s" if en else "contra %s") % adv],
		["centro", "%d %s  ·  %d min" % [turno_n, Sessao.t("turnos"), int((Time.get_ticks_msec() - _inicio_ms) / 60000)]], ["divisor"],
		["sub", ("You  ×  %s" if en else "Você  ×  %s") % adv],
		["item", ("Cards played: %d × %d" if en else "Cartas jogadas: %d × %d") % [jog.call(0), jog.call(1)]],
		["item", ("Damage dealt: %d × %d" if en else "Dano causado: %d × %d") % [int(_corn_ini[1]) - maxi(cornucopia[1], 0), int(_corn_ini[0]) - maxi(cornucopia[0], 0)]],
		["item", ("Entities destroyed: %d × %d" if en else "Entidades destruídas: %d × %d") % [int(estat[1].get("mortes", 0)), int(estat[0].get("mortes", 0))]],
		["item", ("Attacks: %d × %d" if en else "Ataques: %d × %d") % [atq.call(0), atq.call(1)]],
		["item", ("Cornucopia left: %d × %d" if en else "Cornucópia no fim: %d × %d") % [maxi(cornucopia[0], 0), maxi(cornucopia[1], 0)]]]
	if ganho > 0:
		b.append(["espaco"])
		b.append(["destaque", "+%d" % ganho, "moeda"])
	if dessinc:
		b.append(["espaco"])
		b.append(["centro", "The two devices disagreed during this match (desync). Please report it." if en else "Os dois aparelhos divergiram nesta partida (dessincronia). Avise para corrigirmos."])
	perg.abrir(b)
	await perg.fechou


## Jogada da IA no formato da rede (mesmos parâmetros que _turno_ia usa em seguida).
func _codificar_ia(d: int, acao: Dictionary) -> Dictionary:
	if acao["tipo"] == "jogar":
		var carta: Carta = acao["carta"]
		var r := {"tipo": "jogar", "k": _mao_de(d).find(carta)}
		match carta.tipo:
			"entidade":
				var vitimas: Array = motor.campo(d)
				vitimas.sort_custom(func(a: Carta, b: Carta) -> bool: return motor.valor(a) < motor.valor(b))
				r["i"] = -1
				r["sac"] = vitimas.slice(0, int(carta.dados.get("sacrificio", 0))).map(func(e: Carta) -> int: return campo_ent[d].find(e))
			"selo":
				r["i"] = _espaco_livre(campo_selo[d])
			"reliquia":
				r["p"] = _portadoras(d).find(acao["alvo"])
		return r
	var c: Carta = acao["atacante"]
	if acao["alvo"] == null:
		return {"tipo": "golpe", "de": campo_ent[d].find(c)}
	return {"tipo": "atacar", "de": campo_ent[d].find(c), "alvo": campo_ent[1 - d].find(acao["alvo"])}


## Testes online: GD_DESISTIR_TURNO=n desiste no meu turno n; GD_CAIR_TURNO=n fecha o jogo no meu turno n (simula
## o app morrendo no meio da partida, para testar a volta com GD_ONLINE_TESTE=retomar).
func _teste_queda() -> void:
	if OS.get_environment("GD_DESISTIR_TURNO") != "" and turno_n >= int(OS.get_environment("GD_DESISTIR_TURNO")):
		desistir()
	if OS.get_environment("GD_CAIR_TURNO") != "" and turno_n >= int(OS.get_environment("GD_CAIR_TURNO")):
		print("CAIU no turno ", turno_n)
		get_tree().quit()


# ================= teste: "dedo automático" (GD_TOQUE_AUTO=1) =================
## Joga o meu turno pelo CAMINHO DO TOQUE (pressionar → arrastar → soltar), com a jogada que a IA escolheria. Serve para
## testar o online com as mesmas funções que a pessoa usa (o GD_AUTO pula o toque e chama as funções direto).
func _toque_auto() -> void:
	await get_tree().create_timer(0.6).timeout
	var tentativas := 0
	while not acabou and ativo == 0 and tentativas < 30:
		tentativas += 1
		while (ocupado or not alvos_pedidos.is_empty() or not efeitos.escolha.is_empty() or carrossel.aberto()) and not acabou:
			await get_tree().process_frame
		if acabou or ativo != 0:
			return
		var acao := _ia_escolher(0)
		if acao.is_empty():
			break
		var c: Carta
		var destino := Vector2.ZERO
		if acao["tipo"] == "jogar":
			c = acao["carta"]
			match c.tipo:
				"entidade":
					var i := _espaco_livre(campo_ent[0])
					destino = pos_ent(0, i if i >= 0 else 0)
				"selo":
					destino = pos_selo(0, maxi(0, _espaco_livre(campo_selo[0])))
				"reliquia":
					destino = (acao["alvo"] as Carta).position
				_:
					match _rito_modo(c, 0):
						"alvo":
							var cands := motor.candidatos(MotorEfeitos.alvo_escolhido(c.dados), 0, c.dados)
							destino = (cands[0] as Carta).position if not cands.is_empty() else Vector2(180, 300)
						"cemiterio":
							destino = proj(CEMIT_JOG)
						_:
							destino = Vector2(180, LINHA_Y + 70)
		else:
			c = acao["atacante"]
			destino = (acao["alvo"] as Carta).position if acao["alvo"] != null else Vector2(180, LINHA_Y - 70)
		pressionar(c.position)
		if segurando != c:
			break
		await get_tree().process_frame
		mover(destino)
		ponteiro = destino
		soltar(destino)
		await get_tree().create_timer(0.3).timeout
	while (ocupado or not alvos_pedidos.is_empty()) and not acabou:
		await get_tree().process_frame
	if not acabou and ativo == 0:
		pressionar(botao_fim.get_center())


## Responde sozinho às perguntas do toque (alvo, sim/não, cemitério, mão inicial, relatório, revanche): sempre a 1ª opção.
func _responder_auto() -> void:
	while is_inside_tree():
		await get_tree().create_timer(0.25).timeout
		if perg.aberto():
			perg.fechar()
		elif carrossel.aberto():
			carrossel.selecionado.emit(0)
		elif not alvos_pedidos.is_empty():
			var c = alvos_pedidos[0]
			if is_instance_valid(c):
				alvo_tocado.emit(c)
		elif not efeitos.escolha.is_empty():
			escolhido.emit(efeitos.escolha[0]["valor"])


# ================= retratos: quem está de fato na mesa (você embaixo, o adversário em cima) =================
const RET_TAM := Vector2(36, 48)                       # foto 3:4 (px nativos); a plaquinha cobre o pé da foto
var ret_tex: Array = [null, null]
var ret_nome: Array = ["", ""]


## Você: a sua foto/imagem do perfil e o seu nome. Adversário: online, a foto e o nome da pessoa; contra a IA, o retrato
## e o nome do personagem (Choronzon: a arte da carta). Sem foto = silhueta.
func _preparar_retratos() -> void:
	if not modo_partida or Sessao.modo == "":
		return
	ret_nome[0] = str(Sessao.perfil.get("nome", "")).strip_edges()
	if ret_nome[0] == "":
		ret_nome[0] = Sessao.t("Você")
	if Sessao.perfil.get("tem_foto", false) and FileAccess.file_exists(Sessao.FOTO):
		var im := Image.load_from_file(Sessao.FOTO)
		if im:
			ret_tex[0] = ImageTexture.create_from_image(im)
	if online_partida():
		ret_nome[1] = str(online_info.get("adversario", "?"))
		var b64 := str(online_info.get("foto_op", ""))
		if b64 != "":
			var im := Image.new()
			if im.load_jpg_from_buffer(Marshalls.base64_to_raw(b64)) == OK:
				ret_tex[1] = ImageTexture.create_from_image(im)
		return
	var op := Sessao.oponente
	ret_nome[1] = str(Sessao.personagem(op).get("nome", Sessao.nome_deck(op)))
	if Carta.textura("retrato", op, "png") != null:
		ret_tex[1] = ImageTexture.create_from_image(MenuPerfil.imagem_avatar(op))
	elif op == "choronzon":
		ret_tex[1] = Carta.textura("arte", "aby_choronzon", "png")


## Retrato no meio da faixa da borda de cada lado: o seu embaixo (entre os Selos e a mão), o do adversário em cima,
## menor pela perspectiva da mesa.
func ret_rect(d: int) -> Rect2:
	var y := 524.0 if d == 0 else 62.0
	var tam := (RET_TAM * escala_em(y)).round()
	return Rect2((Vector2(180, y) - tam / 2).round(), tam)


func _desenhar_retratos() -> void:
	for d in 2:
		if ret_nome[d] == "":
			continue
		var r := ret_rect(d)
		if ativo == d and not acabou:                  # de quem é a vez: brilho dourado pulsando em volta
			var a := 0.35 + 0.3 * sin(tempo * 4.0)
			placar.draw_rect(r.grow(5), Color(1.0, 0.85, 0.4, a * 0.5))
			placar.draw_rect(r.grow(4), Color(1.0, 0.85, 0.4, a), false, 1.0)
		placar.draw_rect(r.grow(3), ESCURO)
		placar.draw_rect(r.grow(2), OURO[2])
		placar.draw_rect(r.grow(1), OURO[1], false, 1.0)
		placar.draw_rect(r, Color("#1a1218"))
		if ret_tex[d] != null:
			placar.draw_texture_rect(ret_tex[d], r, false)
		else:                                          # silhueta: cabeça e ombros
			var c := r.get_center()
			placar.draw_circle(c + Vector2(0, -6), 6.0, Color("#3a2c36"))
			placar.draw_colored_polygon(PackedVector2Array([c + Vector2(-11, 17), c + Vector2(-9, 4), c + Vector2(0, 1),
				c + Vector2(9, 4), c + Vector2(11, 17)]), Color("#3a2c36"))
		for cc in [r.position, Vector2(r.end.x, r.position.y)]:   # losangos nos cantos de cima
			placar.draw_colored_polygon(PackedVector2Array([cc + Vector2(0, -3), cc + Vector2(3, 0), cc + Vector2(0, 3), cc + Vector2(-3, 0)]), OURO[0])
		_plaquinha(Vector2(r.get_center().x, r.end.y - 1), ret_nome[d])
		if d == 1 and rede != null:
			_status_adversario(r)


## Plaquinha de madeira com o nome entalhado: tábua com veio, luz em cima, sombra embaixo, 2 pregos dourados; as letras
## são cavadas (tinta escura com a borda de baixo clara, como o corte na madeira pegando luz).
func _plaquinha(centro: Vector2, nome: String) -> void:
	var w := float(Fonte57.largura(nome) + 20)
	var pr := Rect2(roundf(centro.x - w / 2), roundf(centro.y - 6), w, 12)
	placar.draw_rect(pr.grow(1), ESCURO)
	placar.draw_rect(pr, MADEIRA[0])
	for k in 3:                                         # veio da madeira
		placar.draw_line(Vector2(pr.position.x + 2, pr.position.y + 3 + k * 3), Vector2(pr.end.x - 2, pr.position.y + 3 + k * 3), MADEIRA[1], 1.0)
	placar.draw_rect(Rect2(pr.position, Vector2(pr.size.x, 1)), MADEIRA[3].lightened(0.25))
	placar.draw_rect(Rect2(pr.position + Vector2(0, pr.size.y - 1), Vector2(pr.size.x, 1)), MADEIRA[2].darkened(0.3))
	for x in [pr.position.x + 3, pr.end.x - 4]:          # pregos
		placar.draw_rect(Rect2(x, pr.position.y + 5, 2, 2), OURO[1])
		placar.draw_rect(Rect2(x, pr.position.y + 5, 1, 1), OURO[0])
	var tv := Fonte57.tinta_v(nome)
	var pos := Vector2(roundf(centro.x - Fonte57.largura(nome) / 2.0), roundf(pr.get_center().y - (tv.x + tv.y + 1) / 2.0))
	Fonte57.desenhar(placar, pos + Vector2(0, 1), nome, MADEIRA[3].lightened(0.35))   # borda do corte pegando luz
	Fonte57.desenhar(placar, pos, nome, Color("#24130c"))                              # fundo do entalhe


## Online: "..." enquanto o adversário pensa no turno dele; "sem sinal" quando o aparelho dele sumiu.
func _status_adversario(r: Rect2) -> void:
	if acabou:
		return
	var txt := ""
	if rede.op_ausente >= 10:
		txt = Sessao.t("SEM SINAL %ds") % rede.op_ausente
	elif ativo == 1 and rede.recebidas.is_empty() and not ocupado:
		txt = "." .repeat(1 + int(tempo * 3) % 3)
	if txt == "":
		return
	var c := Vector2(r.end.x + 6, r.position.y + 2)
	var w := PixelFonte.largura(txt) + 6
	placar.draw_rect(Rect2(c, Vector2(w, 9)).grow(1), ESCURO)
	placar.draw_rect(Rect2(c, Vector2(w, 9)), Color("#f2e6c8") if txt.begins_with(".") else Color("#5a1a1a"))
	PixelFonte.desenhar(placar, c + Vector2(3, 2), txt, ESCURO if txt.begins_with(".") else Color("#ffb0a0"))


## Online: a mão inicial tem 25 s, contados no subtítulo; esgotou = mantém a mão.
func _contagem_mulligan(seg: int) -> void:
	var fim := Time.get_ticks_msec() + seg * 1000
	while hud.mulligan and not acabou:
		var resta := ceili((fim - Time.get_ticks_msec()) / 1000.0)
		if resta <= 0:
			escolhido.emit(false)
			return
		efeitos.faixa_alvo["sub"] = Sessao.t("TOQUE ATÉ 2 CARTAS PARA TROCAR") + "  ·  %d S" % resta
		await get_tree().create_timer(0.25, true, false, true).timeout


## Voltou do segundo plano: o laço da rede pede de novo na hora (sem esperar o pedido antigo vencer).
func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_RESUMED and rede != null:
		rede.cutucar()
