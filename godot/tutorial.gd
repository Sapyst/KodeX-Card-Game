class_name Tutorial
extends RefCounted
## Tutorial: partida montada (Alta Magia × Taoísmo) narrada por Silas Ashcombe, o Magus.
## 3 turnos do jogador; em cada passo só a jogada pedida é aceita (pode_pegar / pode_soltar / fim_ok),
## uma mão-guia mostra o gesto e o painel de fala espera um toque. Termina com vitória.
## Teste sem humano: GD_TUTORIAL_AUTO=1 (toca as falas e faz as jogadas sozinho).

## Ordem de compra (o fim da lista sai primeiro): mão inicial, depois as compras de cada turno.
const DECK_JOGADOR := ["alt_andras", "alt_homunculo", "alt_pedra_de_visao", "alt_orobas", "alt_abrahadabra",
	"alt_pentagrama_flamejante", "alt_silfo"]
const DECK_OPONENTE := ["tao_he_xiangu", "tao_flechas_de_houyi", "tao_cao_guojiu", "tao_lan_caihe"]
const CORNUCOPIA_LIN := 6

const FALAS := {
	"pt": {
		"oi": "Então quer aprender o Códice? Silas Ashcombe, Magus do Triângulo, a seu dispor. Esta mesa é uma situação montada: faça só o que eu mandar.",
		"cornucopia": "Lá em cima está Lin Yuehua, do Taoísmo. Os números junto ao círculo do meio são as Cornucópias, a vida de cada um. A dela chegou ferida: 6. A sua: 15. Zere a dela e você vence.",
		"fe": "Ao lado fica a sua Fé: é ela que paga as cartas. O número no canto de cada carta é o custo. Hoje eu te empresto a Fé que precisar.",
		"mao": "Estas são as suas cartas. As que brilham em dourado podem ser jogadas agora.",
		"silfo": "Primeiro, uma Entidade: espíritos e criaturas que atacam e defendem. Arraste o Silfo até um dos quatro espaços da sua fileira.",
		"silfo_ok": "O Silfo está em campo. Vermelho é o ATK, azul é a DEF. Ele tem Ímpeto: ataca no mesmo turno em que entra. Quase toda Entidade precisa esperar um turno.",
		"direto": "O campo dela está vazio. Sem Entidades inimigas, você golpeia a Cornucópia direto. Arraste o Silfo para o lado dela da mesa.",
		"direto_ok": "Um ponto a menos. Pouco? O Abismo também começou pequeno. Toque em FIM TURNO.",
		"lan": "Ela invocou Lan Caihe: 1 de ATK, 1 de DEF. Dica: segure o dedo sobre qualquer carta para ler o texto inteiro.",
		"reliquia": "Turno novo: você comprou uma carta e a Fé recarregou. Esta é uma Relíquia, a Pedra de Visão. Arraste-a sobre o Silfo para equipá-lo.",
		"reliquia_ok": "+1 de ATK e +3 de DEF. Viu o arco-íris no chão, por baixo dele? É o sinal de carta fortalecida.",
		"ataque": "Agora o ataque: arraste o Silfo sobre Lan Caihe. As duas trocam golpes, ATK contra DEF. Quem fica sem DEF vai para o cemitério.",
		"ataque_ok": "Lan Caihe virou pó e o Silfo aguentou o troco. Ataque onde o seu ATK mata e a sua DEF aguenta.",
		"selo": "Agora um Selo, uma armadilha. Fica virado para baixo e dispara sozinho no turno dela. Arraste o Pentagrama Flamejante para um dos espaços de Selo, na fileira de baixo.",
		"selo_ok": "O Pentagrama anula o próximo Rito que ela lançar, e ela não sabe o que está ali. Toque em FIM TURNO e observe.",
		"anulou": "Ela lançou as Flechas de Houyi no Silfo e o meu Pentagrama queimou o Rito antes que tocasse em nada. Ainda comprei uma carta e curei 2. Armadilhas vencem partidas.",
		"guarda": "Veja Cao Guojiu, com o escudo e a moldura azul: é Guarda. Enquanto uma Guarda estiver de pé, seus ataques têm de ir nela primeiro.",
		"andras": "Hoje te empresto Fé de sobra: 7. Arraste Andras para um espaço vazio. O Despertar dele destrói uma Entidade inimiga de custo 3 ou menos.",
		"andras_alvo": "Despertar com alvo: toque em Cao Guojiu.",
		"andras_ok": "A Guarda caiu e o caminho está livre. Andras acabou de chegar e está cansado. O Silfo, não.",
		"direto2": "Arraste o Silfo para golpear a Cornucópia dela outra vez.",
		"direto2_ok": "Restam 3. E eu guardei o melhor para o fim.",
		"rito": "Abrahadabra é um Rito: magia de efeito imediato. Causa 3 de dano direto na Cornucópia. Arraste-o para o meio da mesa e termine isto.",
		"fim1": "Perfeito. Fé, Entidades, Relíquias, Selos, Ritos, Guarda e Despertar: o Códice inteiro na ponta dos seus dedos.",
		"fim2": "Agora vá ao Torneio. Cinco campeões esperam por você... e, no fim, eu. Não me decepcione.",
		"lin1": "Uma armadilha? Meu Rito... queimou?!",
		"toque": "toque para continuar",
	},
	"en": {
		"oi": "So you wish to learn the Codex? Silas Ashcombe, Magus of the Triangle, at your service. This table is a staged game: do only what I tell you.",
		"cornucopia": "Up there is Lin Yuehua, of Taoism. The numbers by the central circle are the Cornucopias, each player's life. Hers arrived wounded: 6. Yours: 15. Bring hers to zero and you win.",
		"fe": "Next to it is your Faith: it pays for your cards. The number in each card's corner is its cost. Today I'll lend you all the Faith you need.",
		"mao": "These are your cards. The ones glowing gold can be played right now.",
		"silfo": "First, an Entity: spirits and creatures that attack and defend. Drag the Sylph onto one of the four spaces in your row.",
		"silfo_ok": "The Sylph is on the field. Red is ATK, blue is DEF. It has Rush: it attacks the turn it arrives. Most Entities must wait a turn.",
		"direto": "Her field is empty. With no enemy Entities, you strike the Cornucopia directly. Drag the Sylph to her side of the table.",
		"direto_ok": "One point down. Small? The Abyss started small too. Tap END TURN.",
		"lan": "She summoned Lan Caihe: 1 ATK, 1 DEF. Tip: hold your finger on any card to read its full text.",
		"reliquia": "New turn: you drew a card and your Faith refilled. This is a Relic, Dee's Shew Stone. Drag it onto the Sylph to equip it.",
		"reliquia_ok": "+1 ATK and +3 DEF. See the rainbow on the floor beneath it? That's the sign of an empowered card.",
		"ataque": "Now the attack: drag the Sylph onto Lan Caihe. They trade blows, ATK against DEF. Whoever runs out of DEF goes to the graveyard.",
		"ataque_ok": "Lan Caihe turned to dust and the Sylph took the hit back. Attack where your ATK kills and your DEF survives.",
		"selo": "Now a Seal, a trap. It stays face down and fires on its own during her turn. Drag the Blazing Pentagram onto one of the Seal spaces, in the lower row.",
		"selo_ok": "The Pentagram cancels the next Rite she casts, and she has no idea what's there. Tap END TURN and watch.",
		"anulou": "She cast the Arrows of Houyi at the Sylph and my Pentagram burned the Rite before it touched anything. I even drew a card and healed 2. Traps win games.",
		"guarda": "Look at Cao Guojiu, with the shield and the blue frame: that's Guard. While a Guard stands, your attacks must hit it first.",
		"andras": "Today I lend you plenty of Faith: 7. Drag Andras onto an empty space. His Awaken destroys an enemy Entity costing 3 or less.",
		"andras_alvo": "Awaken with a target: tap Cao Guojiu.",
		"andras_ok": "The Guard has fallen and the way is clear. Andras just arrived and is tired. The Sylph is not.",
		"direto2": "Drag the Sylph to strike her Cornucopia once more.",
		"direto2_ok": "3 left. And I saved the best for last.",
		"rito": "Abrahadabra is a Rite: magic with an instant effect. It deals 3 damage straight to the Cornucopia. Drag it to the middle of the table and finish this.",
		"fim1": "Perfect. Faith, Entities, Relics, Seals, Rites, Guard and Awaken: the whole Codex at your fingertips.",
		"fim2": "Now go to the Tournament. Five champions await you... and, at the end, me. Don't disappoint me.",
		"lin1": "A trap? My Rite... burned?!",
		"toque": "tap to continue",
	},
}

var m                                    # a mesa (mesa.gd)
var auto := OS.get_environment("GD_TUTORIAL_AUTO") != ""
var pode_pegar := Callable()             # (c: Carta, de: String) -> bool; vazio = nada pode ser pego
var pode_soltar := Callable()            # (c: Carta, origem: String, p: Vector2) -> bool
var fim_ok := false
var esperando_toque := false
signal tocado


func _init(mesa) -> void:
	m = mesa


func txt(chave: String) -> String:
	return FALAS.get(Sessao.idioma, FALAS["pt"]).get(chave, chave)


## Painel do Silas no topo; espera um toque (o 1º toque completa a digitação). `espera` = false: só mostra.
func falar(chave: String, espera := true) -> void:
	var p: Dictionary = Sessao.personagem("alta_magia")
	m.efeitos.tutor = {"nome": p.get("nome", "Silas Ashcombe"), "cor": Color(p.get("cor", "#8b1a1a")).lightened(0.35),
		"texto": txt(chave), "t": 0.0, "toque": txt("toque") if espera else ""}
	if not espera:
		return
	m.ocupado = true
	esperando_toque = true
	if auto:
		_auto_avancar()
	await tocado
	esperando_toque = false
	m.efeitos.tutor = {}
	m.ocupado = false


func _auto_avancar() -> void:
	await m.get_tree().create_timer(1.6).timeout
	while esperando_toque:
		toque()
		await m.get_tree().create_timer(0.4).timeout


func toque() -> void:
	if not esperando_toque:
		return
	var tu: Dictionary = m.efeitos.tutor
	if not tu.is_empty() and tu["t"] * 45.0 < (tu["texto"] as String).length():
		tu["t"] = 999.0                                      # 1º toque: mostra o texto inteiro
		return
	tocado.emit()


func _ate(cond: Callable) -> void:
	while not cond.call() and not m.acabou:
		await m.get_tree().process_frame


func _guia(de: Vector2, para: Vector2) -> void:
	m.efeitos.guia = {"de": de, "para": para, "t": 0.0}


func _sem_guia() -> void:
	m.efeitos.guia = {}
	pode_pegar = Callable()
	pode_soltar = Callable()


func _na_mao(id: String):
	for c in m.mao_jog:
		if c.id == id:
			return c
	return null


func _da_mao_oponente(id: String):
	for c in m.mao_opon:
		if c.id == id:
			return c
	return null


func _espaco_livre(d: int) -> int:
	return m._espaco_livre(m.campo_ent[d])


## Pede uma jogada da mão: guia da carta até `para`, só essa carta pode ser pega; espera `pronto`.
func _jogada_da_mao(id: String, para: Vector2, pronto: Callable, soltar := Callable()) -> void:
	var c = _na_mao(id)
	if c == null:
		return
	pode_pegar = func(x, de: String) -> bool: return de == "mao" and x == c
	pode_soltar = soltar
	_guia(c.position, para)
	if auto:
		await m.get_tree().create_timer(0.6).timeout
		await m._demo_arrastar(c.position, para, 0.6)
	await _ate(pronto)
	_sem_guia()
	await _ate(func() -> bool: return not m.ocupado)


## Pede um ataque/arraste de uma carta do campo até `para`.
func _jogada_do_campo(c, para: Vector2, pronto: Callable, soltar := Callable()) -> void:
	pode_pegar = func(x, de: String) -> bool: return de == "campo" and x == c
	pode_soltar = soltar
	_guia(c.position, para)
	if auto:
		await m.get_tree().create_timer(0.6).timeout
		await m._demo_arrastar(c.position, para, 0.6)
	await _ate(pronto)
	_sem_guia()
	await _ate(func() -> bool: return not m.ocupado)


func _fim_turno_jogador() -> void:
	fim_ok = true
	_guia(m.botao_fim.get_center() + Vector2(0, 40), m.botao_fim.get_center())
	if auto:
		await m.get_tree().create_timer(0.8).timeout
		m._demo_tocar(m.botao_fim.get_center())
	await m.fim_turno_pedido
	fim_ok = false
	_sem_guia()
	m.ocupado = true
	await m._fim_turno(0)
	m.ocupado = false


func _turno(d: int, fe: int) -> void:
	m.ativo = d
	m.turno_n += 1
	m.ocupado = true
	await m._inicio_turno(d)
	m.fe[d] = fe
	m.fe_max[d] = maxi(m.fe_max[d], mini(fe, 8))
	m.ocupado = false
	m._atualizar_apagadas()


## O roteiro inteiro. Chamado pela mesa no lugar de _partida() quando Sessao.modo == "tutorial".
func rodar() -> void:
	m.cornucopia[1] = CORNUCOPIA_LIN
	m.ativo = 0
	m.turno_n = 0
	await falar("oi")
	m.efeitos.foco = [Rect2(m._pos_placar(1) - Vector2(14, 10), Vector2(60, 34)), Rect2(m._pos_placar(0) - Vector2(14, 10), Vector2(60, 34))]
	await falar("cornucopia")
	m.efeitos.foco = []
	# ---------- turno 1: Entidade + golpe direto ----------
	await _turno(0, 2)
	await falar("fe")
	await falar("mao")
	m.efeitos.tutor = {}
	falar("silfo", false)
	await _jogada_da_mao("alt_silfo", m.pos_ent(0, 1), func() -> bool: return _silfo() != null and not m.ocupado)
	await falar("silfo_ok")
	var silfo = _silfo()
	falar("direto", false)
	var c_antes: int = m.cornucopia[1]
	await _jogada_do_campo(silfo, Vector2(180, m.LINHA_Y - 70), func() -> bool: return m.cornucopia[1] < c_antes,
		func(_c, _o, p: Vector2) -> bool: return p.y < m.LINHA_Y)
	await falar("direto_ok", false)
	await _fim_turno_jogador()
	m.efeitos.tutor = {}
	# ---------- turno da Lin: Lan Caihe ----------
	await _turno(1, 3)
	var lan = _da_mao_oponente("tao_lan_caihe")
	if lan:
		await m._jogar_entidade(lan, 1, 1)
	await m.get_tree().create_timer(0.4).timeout
	await m._fim_turno(1)
	await falar("lan")
	# ---------- turno 2: Relíquia, ataque, Selo ----------
	await _turno(0, 3)
	falar("reliquia", false)
	await _jogada_da_mao("alt_pedra_de_visao", silfo.position, func() -> bool: return not silfo.reliquia.is_empty() and not m.ocupado,
		func(_c, _o, p: Vector2) -> bool: return silfo.contem(p) or p.distance_to(silfo.position) < 30)
	await falar("reliquia_ok")
	falar("ataque", false)
	var alvo_lan = m.campo_ent[1][1]
	await _jogada_do_campo(silfo, alvo_lan.position, func() -> bool: return silfo.atacou and not m.ocupado,
		func(_c, _o, p: Vector2) -> bool: return m._inimigo_sob(p) == 1)
	await falar("ataque_ok")
	falar("selo", false)
	await _jogada_da_mao("alt_pentagrama_flamejante", m.pos_selo(0, 0),
		func() -> bool: return m.campo_selo[0].any(func(s) -> bool: return s != null) and not m.ocupado)
	await falar("selo_ok", false)
	await _fim_turno_jogador()
	m.efeitos.tutor = {}
	# ---------- turno da Lin: Cao Guojiu (Guarda) + Flechas de Houyi → anuladas ----------
	await _turno(1, 6)
	var cao = _da_mao_oponente("tao_cao_guojiu")
	if cao:
		await m._jogar_entidade(cao, 1, 2)
	await m.get_tree().create_timer(0.5).timeout
	var flechas = _da_mao_oponente("tao_flechas_de_houyi")
	if flechas:
		await m._jogar_rito(flechas, 1, silfo, MotorEfeitos.alvo_escolhido(flechas.dados))
	var lin: Dictionary = Sessao.personagem("taoismo")
	m.efeitos.falar(lin.get("nome", ""), txt("lin1"), Color(lin.get("cor", "#3aa58a")), "taoismo")
	await m.get_tree().create_timer(2.6).timeout
	await m._fim_turno(1)
	await falar("anulou")
	# ---------- turno 3: Guarda, Despertar com alvo, golpe direto, Rito final ----------
	await _turno(0, 7)
	var cao_campo = m.campo_ent[1][2]
	if cao_campo:
		m.efeitos.foco = [Rect2(cao_campo.position - Vector2(20, 26), Vector2(40, 52))]
	await falar("guarda")
	m.efeitos.foco = []
	falar("andras", false)
	var vaga: int = _espaco_livre(0)
	var alvo_esperado = cao_campo
	# o Despertar abre a escolha de alvo: troca a fala e (no auto) toca em Cao Guojiu
	_ao_pedir_alvo(alvo_esperado)
	await _jogada_da_mao("alt_andras", m.pos_ent(0, vaga),
		func() -> bool: return m.campo_ent[1].all(func(x) -> bool: return x == null) and not m.ocupado)
	await falar("andras_ok")
	falar("direto2", false)
	c_antes = m.cornucopia[1]
	await _jogada_do_campo(silfo, Vector2(180, m.LINHA_Y - 70), func() -> bool: return m.cornucopia[1] < c_antes,
		func(_c, _o, p: Vector2) -> bool: return p.y < m.LINHA_Y)
	await falar("direto2_ok")
	falar("rito", false)
	await _jogada_da_mao("alt_abrahadabra", Vector2(180, m.LINHA_Y - 40), func() -> bool: return m.acabou)
	m.efeitos.tutor = {}
	# vitória: a mesa já tocou a faixa e o confete; mais uma rodada de festa e as palavras finais
	await m.get_tree().create_timer(0.6).timeout
	m.efeitos.confete(120)
	await falar("fim1")
	m.efeitos.confete(60)
	await falar("fim2")


## Espera a escolha de alvo do Despertar de Andras aparecer: fala curta e, no teste automático, toca no alvo.
func _ao_pedir_alvo(alvo) -> void:
	await _ate(func() -> bool: return not m.alvos_pedidos.is_empty())
	if m.acabou:
		return
	falar("andras_alvo", false)
	if auto:
		await m.get_tree().create_timer(1.0).timeout
		m._demo_tocar(alvo.position)


func _silfo():
	for c in m.campo_ent[0]:
		if c != null and c.id == "alt_silfo":
			return c
	return null
