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
## Lição 2 (mão inicial, cemitério, reembaralhar e fadiga): mão = Silfo, Abrahadabra, Homúnculo, Pedra de Visão; a
## troca da Pedra traz o Pentagrama; depois o deck é cortado para 1 carta (Orobas) para o deck acabar no 3º turno.
const DECK_JOGADOR_2 := ["alt_orobas", "alt_pentagrama_flamejante", "alt_pedra_de_visao", "alt_homunculo", "alt_abrahadabra", "alt_silfo"]
const DECK_OPONENTE_2 := ["tao_he_xiangu", "tao_lan_caihe"]
var licao := 1

const FALAS2 := {
	"pt": {
		"oi2": "De volta? Ótimo. A primeira aula foi sobre vencer. Esta é sobre o que ninguém te conta: a mão que você recebe, o cemitério e o que acontece quando as cartas acabam.",
		"mull": "Toda partida começa assim: quatro cartas e o direito de trocar até duas. Toque na Pedra de Visão (hoje não teremos tempo para relíquias) e depois em TROCAR. Ela volta ao deck e outra carta vem no lugar.",
		"mull_ok": "Outra carta veio no lugar, do fundo do deck embaralhado. Troque sempre o que não vai usar nos dois primeiros turnos; o resto se ajeita.",
		"silfo2": "Comecemos como da outra vez: arraste o Silfo para a sua fileira.",
		"direto2a": "Campo vazio do lado dela. Mande o Silfo direto na Cornucópia.",
		"direto2a_ok": "Um ponto. Toque em FIM TURNO.",
		"lan2": "Lan Caihe, de novo com o cesto de flores. Repare na sua pilha de deck, ali à direita: cada turno tira uma carta dela. Hoje ela está... curta. Foi de propósito.",
		"ataque2": "Arraste o Silfo sobre Lan Caihe.",
		"cemiterio": "Lan caiu, e foi para o cemitério dela, no canto. O seu fica aqui embaixo, à esquerda. Tudo o que morre ou se gasta vai parar lá. Segure o dedo no cemitério quando quiser rever as cartas.",
		"rito2": "Lance Abrahadabra no meio da mesa: 3 de dano direto.",
		"rito_cem": "Viu para onde o Rito foi? Cemitério. Ritos se gastam; só as Entidades ficam. Agora, uma maldade pedagógica: vou tirar dez da sua Cornucópia. Toque em FIM TURNO e confie em mim.",
		"fadiga": "Seu deck acabou, e a mesa cobrou: menos 2 de Cornucópia. É a fadiga, e ela cobra todo turno sem carta. Com 6 ou mais de Cornucópia, porém, há saída. Devolvo o que tirei. Toque em FIM TURNO.",
		"reemb": "Aí está a pergunta. Pagando 5 de Cornucópia, o cemitério inteiro volta embaralhado ao deck. Toque em REEMBARALHAR.",
		"reemb_ok": "Caro, mas melhor que sangrar 2 por turno. E a carta que voltou foi comprada na hora: Abrahadabra, outra vez.",
		"final2": "Lin está com 2. Você sabe o que fazer: arraste o Rito para o meio da mesa.",
		"fim2a": "Mão inicial, cemitério, fadiga e o reembaralhar. Agora nenhum deck vazio te pega de surpresa.",
		"fim2b": "Minha dica: conte as cartas do deck antes de apostar numa partida longa. Quem conta, não paga fadiga. Vá, o Torneio espera.",
		"toque": "toque para continuar",
	},
	"en": {
		"oi2": "Back again? Good. The first lesson was about winning. This one is about what nobody tells you: the hand you're dealt, the graveyard, and what happens when the cards run out.",
		"mull": "Every match starts like this: four cards and the right to swap up to two. Tap the Shew Stone (no time for relics today) and then SWAP. It goes back into the deck and another card takes its place.",
		"mull_ok": "Another card came instead, from the shuffled deck. Always swap what you won't use in the first two turns; the rest sorts itself out.",
		"silfo2": "Let's start like last time: drag the Sylph onto your row.",
		"direto2a": "Her side is empty. Send the Sylph straight at the Cornucopia.",
		"direto2a_ok": "One point. Tap END TURN.",
		"lan2": "Lan Caihe, again with her basket of flowers. Look at your deck pile, over on the right: every turn takes one card from it. Today it's... short. On purpose.",
		"ataque2": "Drag the Sylph onto Lan Caihe.",
		"cemiterio": "Lan fell and went to her graveyard, in the corner. Yours is down here on the left. Everything that dies or is spent ends up there. Hold your finger on the graveyard whenever you want to look through it.",
		"rito2": "Cast Abrahadabra in the middle of the table: 3 direct damage.",
		"rito_cem": "See where the Rite went? Graveyard. Rites are spent; only Entities stay. Now, a pedagogical cruelty: I'm taking ten off your Cornucopia. Tap END TURN and trust me.",
		"fadiga": "Your deck ran out and the table collected: minus 2 Cornucopia. That's fatigue, and it collects every turn without a card. With 6 or more Cornucopia, though, there's a way out. I'll give back what I took. Tap END TURN.",
		"reemb": "There's the question. For 5 Cornucopia, the whole graveyard shuffles back into the deck. Tap RESHUFFLE.",
		"reemb_ok": "Pricey, but better than bleeding 2 a turn. And the card that came back was drawn right away: Abrahadabra, once more.",
		"final2": "Lin is at 2. You know what to do: drag the Rite to the middle of the table.",
		"fim2a": "Opening hand, graveyard, fatigue and the reshuffle. No empty deck will catch you off guard now.",
		"fim2b": "My tip: count the cards in your deck before betting on a long match. Those who count never pay fatigue. Go, the Tournament awaits.",
		"toque": "tap to continue",
	},
	"es": {
		"oi2": "¿De vuelta? Perfecto. La primera lección fue sobre ganar. Esta es sobre lo que nadie te cuenta: la mano que recibes, el cementerio y lo que pasa cuando se acaban las cartas.",
		"mull": "Toda partida empieza así: cuatro cartas y el derecho a cambiar hasta dos. Toca la Piedra de Visión (hoy no hay tiempo para reliquias) y luego CAMBIAR. Vuelve al mazo y otra carta ocupa su lugar.",
		"mull_ok": "Vino otra carta en su lugar, del mazo barajado. Cambia siempre lo que no vayas a usar en los dos primeros turnos; el resto se acomoda.",
		"silfo2": "Empecemos como la otra vez: arrastra al Silfo a tu fila.",
		"direto2a": "Su lado está vacío. Manda al Silfo directo a la Cornucopia.",
		"direto2a_ok": "Un punto. Toca FIN TURNO.",
		"lan2": "Lan Caihe, otra vez con la canasta de flores. Mira tu pila de mazo, a la derecha: cada turno saca una carta. Hoy está... corta. A propósito.",
		"ataque2": "Arrastra al Silfo sobre Lan Caihe.",
		"cemiterio": "Lan cayó y fue a su cementerio, en la esquina. El tuyo está aquí abajo, a la izquierda. Todo lo que muere o se gasta termina ahí. Mantén el dedo en el cementerio cuando quieras repasar las cartas.",
		"rito2": "Lanza Abrahadabra al centro de la mesa: 3 de daño directo.",
		"rito_cem": "¿Viste adónde fue el Rito? Al cementerio. Los Ritos se gastan; solo las Entidades se quedan. Ahora, una maldad pedagógica: te quito diez de la Cornucopia. Toca FIN TURNO y confía en mí.",
		"fadiga": "Tu mazo se acabó y la mesa cobró: menos 2 de Cornucopia. Es la fatiga, y cobra cada turno sin carta. Con 6 o más de Cornucopia, sin embargo, hay salida. Te devuelvo lo que quité. Toca FIN TURNO.",
		"reemb": "Ahí está la pregunta. Pagando 5 de Cornucopia, todo el cementerio vuelve barajado al mazo. Toca BARAJAR.",
		"reemb_ok": "Caro, pero mejor que sangrar 2 por turno. Y la carta que volvió se robó al instante: Abrahadabra, otra vez.",
		"final2": "Lin está en 2. Ya sabes qué hacer: arrastra el Rito al centro de la mesa.",
		"fim2a": "Mano inicial, cementerio, fatiga y el barajar. Ningún mazo vacío te tomará por sorpresa.",
		"fim2b": "Mi consejo: cuenta las cartas del mazo antes de apostar a una partida larga. Quien cuenta no paga fatiga. Ve, el Torneo espera.",
		"toque": "toca para continuar",
	},
}

const FALAS := {
	"pt": {
		"oi": "Ah, você veio. Silas Ashcombe, Magus do Triângulo. Antes do torneio, uma aula particular. Arrumei esta mesa do meu jeito; siga minhas instruções e ninguém se machuca... muito.",
		"cornucopia": "Do outro lado está Lin Yuehua: cento e oitenta anos de paciência taoísta. Os números junto ao círculo são as Cornucópias, a vida de cada um. A dela já caiu para 6. A sua está cheia: 15. Leve a dela a zero.",
		"fe": "Aqui fica a sua Fé. Toda carta se paga com ela, e o número no canto é o preço. Hoje a conta é minha. Considere um empréstimo... eu cobro depois.",
		"mao": "Sua mão. As cartas com brilho dourado são as que você pode pagar agora. As outras esperam a vez delas.",
		"silfo": "Comecemos por uma Entidade, uma criatura que luta por você. Arraste o Silfo para um dos quatro espaços da sua fileira.",
		"silfo_ok": "Bem-vindo à mesa, pequeno Silfo. O número vermelho é o ataque; o azul, a defesa. E repare: ele tem Ímpeto. Quase toda criatura precisa de um turno para se acostumar com o mundo. Ele, não.",
		"direto": "O lado dela está vazio, e campo vazio é porta aberta. Arraste o Silfo até o território da Lin e acerte a Cornucópia dela em cheio.",
		"direto_ok": "Um ponto. Parece pouco, mas toda queda começa com um tropeço. Quando estiver pronto, toque em FIM TURNO.",
		"lan": "Lan Caihe, a Imortal que canta pelas ruas com um cesto de flores. Graciosa e frágil: 1 de ataque, 1 de defesa. Quer ler uma carta com calma? Segure o dedo sobre ela.",
		"reliquia": "Turno novo, carta nova, Fé renovada. Isto é uma Relíquia: a Pedra de Visão de John Dee, por onde ele jurava falar com anjos. Arraste-a sobre o Silfo.",
		"reliquia_ok": "Um de ataque e três de defesa a mais. E esse arco-íris sob a carta? É a mesa avisando que ela está mais forte do que nasceu.",
		"ataque": "Hora de sujar as mãos. Arraste o Silfo sobre Lan Caihe. Os dois se golpeiam ao mesmo tempo, e quem ficar sem defesa vai para o cemitério.",
		"ataque_ok": "Pétalas para todo lado. O Silfo levou o troco e continua de pé. O segredo é esse: escolha brigas em que você bate mais forte do que apanha.",
		"selo": "Agora, minha parte favorita: um Selo. Fica virado para baixo, calado, e dispara sozinho no turno dela. Ponha o Pentagrama Flamejante num dos espaços de Selo, na fileira de baixo.",
		"selo_ok": "Ela vai olhar para essa carta virada e imaginar o pior. E vai acertar. Toque em FIM TURNO e assista.",
		"anulou": "Ouviu o estalo? As Flechas de Houyi nem chegaram perto do Silfo: o Pentagrama queimou o Rito no ar. E ainda me rendeu uma carta e 2 de vida. Uma boa armadilha vale mais que um exército.",
		"guarda": "Mas ela trouxe Cao Guojiu. Está vendo o escudo e a moldura azul? Isso é Guarda: enquanto ele estiver de pé, todo ataque seu tem que passar por ele primeiro.",
		"andras": "Por isso eu trouxe Andras, o semeador da discórdia. Hoje te adianto 7 de Fé. Ponha-o num espaço vazio: ao despertar, ele destrói uma Entidade inimiga de custo 3 ou menos.",
		"andras_alvo": "O Despertar pede um alvo. Toque em Cao Guojiu.",
		"andras_ok": "Lá se vai a muralha. Andras acabou de chegar e precisa de um turno, mas o Silfo está bem acordado.",
		"direto2": "Caminho livre outra vez. Mande o Silfo direto na Cornucópia dela.",
		"direto2_ok": "Três. Agora ela sentiu. E eu guardei o melhor para o fim.",
		"rito": "Abrahadabra. Um Rito: magia que acontece na hora e se desfaz. Três de dano direto na Cornucópia, exatamente o que falta. Arraste-o para o meio da mesa.",
		"fim1": "Esplêndido. Fé, Entidades, Relíquias, Selos, Ritos, Guarda, Despertar... Em três turnos você aprendeu o que muita gente leva um torneio inteiro para entender.",
		"fim2": "A Lin vai se recuperar, e os outros campeões também. Vá ao Torneio, vença os cinco e, no fim, venha me encontrar. Estarei esperando... e, dessa vez, não vou te emprestar nada.",
		"lin1": "Uma armadilha?! Meu Rito virou cinza!",
		"toque": "toque para continuar",
	},
	"en": {
		"oi": "Ah, you came. Silas Ashcombe, Magus of the Triangle. Before the tournament, a private lesson. I've set this table my way, so follow my instructions and no one gets hurt... much.",
		"cornucopia": "Across from you sits Lin Yuehua: a hundred and eighty years of Taoist patience. The numbers by the circle are the Cornucopias, each player's life. Hers is already down to 6. Yours is full: 15. Bring hers to zero.",
		"fe": "This is your Faith. Every card is paid for with it, and the number in the corner is the price. Today it's on me. Consider it a loan... I'll collect later.",
		"mao": "Your hand. Cards glowing gold are the ones you can afford right now. The rest will wait their turn.",
		"silfo": "Let's begin with an Entity, a creature that fights for you. Drag the Sylph onto one of the four spaces in your row.",
		"silfo_ok": "Welcome to the table, little Sylph. The red number is attack; the blue one, defense. And note: it has Rush. Most creatures need a turn to get used to the world. Not this one.",
		"direto": "Her side is empty, and an empty field is an open door. Drag the Sylph into Lin's territory and strike her Cornucopia directly.",
		"direto_ok": "One point. It seems small, but every fall begins with a stumble. When you're ready, tap END TURN.",
		"lan": "Lan Caihe, the Immortal who sings through the streets with a basket of flowers. Graceful and fragile: 1 attack, 1 defense. Want to read a card at your leisure? Hold your finger on it.",
		"reliquia": "New turn, new card, Faith restored. This is a Relic: John Dee's Shew Stone, through which he swore he spoke with angels. Drag it onto the Sylph.",
		"reliquia_ok": "One more attack, three more defense. And that rainbow under the card? That's the table telling you it's stronger than it was born.",
		"ataque": "Time to get your hands dirty. Drag the Sylph onto Lan Caihe. They strike each other at the same time, and whoever runs out of defense goes to the graveyard.",
		"ataque_ok": "Petals everywhere. The Sylph took a hit back and is still standing. That's the secret: pick fights where you hit harder than you get hit.",
		"selo": "Now, my favorite part: a Seal. It sits face down, silent, and fires on its own during her turn. Place the Blazing Pentagram on one of the Seal spaces in the lower row.",
		"selo_ok": "She'll stare at that face-down card and imagine the worst. She'll be right. Tap END TURN and watch.",
		"anulou": "Hear that crack? The Arrows of Houyi never got near the Sylph: the Pentagram burned the Rite out of the air. It even earned me a card and 2 life. A good trap is worth more than an army.",
		"guarda": "But she brought Cao Guojiu. See the shield and the blue frame? That's Guard: while he stands, every attack of yours has to go through him first.",
		"andras": "Which is why I brought Andras, the sower of discord. I'll advance you 7 Faith today. Put him in an empty space: when he awakens, he destroys an enemy Entity that costs 3 or less.",
		"andras_alvo": "Awaken needs a target. Tap Cao Guojiu.",
		"andras_ok": "There goes the wall. Andras just arrived and needs a turn, but the Sylph is wide awake.",
		"direto2": "The way is clear again. Send the Sylph straight at her Cornucopia.",
		"direto2_ok": "Three. Now she feels it. And I saved the best for last.",
		"rito": "Abrahadabra. A Rite: magic that happens at once and is gone. Three damage straight to the Cornucopia, exactly what's left. Drag it to the middle of the table.",
		"fim1": "Splendid. Faith, Entities, Relics, Seals, Rites, Guard, Awaken... In three turns you learned what many take a whole tournament to grasp.",
		"fim2": "Lin will recover, and so will the other champions. Go to the Tournament, defeat all five, and at the end, come find me. I'll be waiting... and this time, I won't lend you anything.",
		"lin1": "A trap?! My Rite turned to ash!",
		"toque": "tap to continue",
	},
	"es": {
		"oi": "Ah, viniste. Silas Ashcombe, Magus del Triángulo. Antes del torneo, una lección privada. Preparé esta mesa a mi manera; sigue mis instrucciones y nadie saldrá herido... demasiado.",
		"cornucopia": "Frente a ti está Lin Yuehua: ciento ochenta años de paciencia taoísta. Los números junto al círculo son las Cornucopias, la vida de cada uno. La suya ya bajó a 6. La tuya está llena: 15. Lleva la suya a cero.",
		"fe": "Aquí está tu Fe. Cada carta se paga con ella, y el número de la esquina es el precio. Hoy invito yo. Considéralo un préstamo... luego cobro.",
		"mao": "Tu mano. Las cartas con brillo dorado son las que puedes pagar ahora. Las demás esperan su turno.",
		"silfo": "Empecemos con una Entidad, una criatura que lucha por ti. Arrastra al Silfo a uno de los cuatro espacios de tu fila.",
		"silfo_ok": "Bienvenido a la mesa, pequeño Silfo. El número rojo es el ataque; el azul, la defensa. Y fíjate: tiene Ímpetu. Casi todas las criaturas necesitan un turno para acostumbrarse al mundo. Él no.",
		"direto": "Su lado está vacío, y un campo vacío es una puerta abierta. Arrastra al Silfo al territorio de Lin y golpea su Cornucopia directamente.",
		"direto_ok": "Un punto. Parece poco, pero toda caída empieza con un tropiezo. Cuando estés listo, toca FIN TURNO.",
		"lan": "Lan Caihe, la Inmortal que canta por las calles con una canasta de flores. Grácil y frágil: 1 de ataque, 1 de defensa. ¿Quieres leer una carta con calma? Mantén el dedo sobre ella.",
		"reliquia": "Turno nuevo, carta nueva, Fe renovada. Esto es una Reliquia: la Piedra de Visión de John Dee, por la que juraba hablar con ángeles. Arrástrala sobre el Silfo.",
		"reliquia_ok": "Uno más de ataque, tres más de defensa. ¿Y ese arcoíris bajo la carta? Es la mesa avisándote que está más fuerte de lo que nació.",
		"ataque": "Hora de ensuciarse las manos. Arrastra al Silfo sobre Lan Caihe. Los dos se golpean al mismo tiempo, y quien se quede sin defensa va al cementerio.",
		"ataque_ok": "Pétalos por todas partes. El Silfo recibió el contragolpe y sigue en pie. Ese es el secreto: elige peleas donde pegues más fuerte de lo que te pegan.",
		"selo": "Ahora, mi parte favorita: un Sello. Queda boca abajo, en silencio, y se activa solo durante su turno. Pon el Pentagrama Llameante en uno de los espacios de Sello, en la fila de abajo.",
		"selo_ok": "Va a mirar esa carta boca abajo e imaginar lo peor. Y tendrá razón. Toca FIN TURNO y observa.",
		"anulou": "¿Oíste el chasquido? Las Flechas de Houyi ni se acercaron al Silfo: el Pentagrama quemó el Rito en el aire. Y encima me dio una carta y 2 de vida. Una buena trampa vale más que un ejército.",
		"guarda": "Pero ella trajo a Cao Guojiu. ¿Ves el escudo y el marco azul? Eso es Guardia: mientras siga en pie, todos tus ataques tienen que pasar primero por él.",
		"andras": "Por eso traje a Andras, el sembrador de discordia. Hoy te adelanto 7 de Fe. Ponlo en un espacio vacío: al despertar, destruye una Entidad enemiga de costo 3 o menos.",
		"andras_alvo": "El Despertar pide un objetivo. Toca a Cao Guojiu.",
		"andras_ok": "Adiós a la muralla. Andras acaba de llegar y necesita un turno, pero el Silfo está bien despierto.",
		"direto2": "El camino está libre otra vez. Manda al Silfo directo a su Cornucopia.",
		"direto2_ok": "Tres. Ahora sí lo siente. Y guardé lo mejor para el final.",
		"rito": "Abrahadabra. Un Rito: magia que ocurre al instante y se desvanece. Tres de daño directo a la Cornucopia, justo lo que falta. Arrástralo al centro de la mesa.",
		"fim1": "Espléndido. Fe, Entidades, Reliquias, Sellos, Ritos, Guardia, Despertar... En tres turnos aprendiste lo que a muchos les toma un torneo entero entender.",
		"fim2": "Lin se recuperará, y los demás campeones también. Ve al Torneo, vence a los cinco y, al final, ven a buscarme. Te estaré esperando... y esta vez no te voy a prestar nada.",
		"lin1": "¡¿Una trampa?! ¡Mi Rito se hizo cenizas!",
		"toque": "toca para continuar",
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
	var tabela: Dictionary = FALAS2 if licao == 2 else FALAS
	return tabela.get(Sessao.idioma, tabela["pt"]).get(chave, chave)


## Painel do Silas no topo; espera um toque (o 1º toque completa a digitação). `espera` = false: só mostra.
func falar(chave: String, espera := true) -> void:
	var p: Dictionary = Sessao.personagem("alta_magia")
	m.efeitos.tutor = {"nome": p.get("nome", "Silas Ashcombe"), "cor": Color(p.get("cor", "#8b1a1a")).lightened(0.35),
		"texto": txt(chave), "t": -0.3 if espera else 0.0, "toque": txt("toque") if espera else "", "grande": espera}
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
	if licao == 2:
		await _rodar_licao2()
		return
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


# ================= Lição 2: mão inicial, cemitério, reembaralhar e fadiga =================
func _rodar_licao2() -> void:
	m.cornucopia[1] = CORNUCOPIA_LIN
	m.ativo = 0
	m.turno_n = 0
	await falar("oi2")
	await _mulligan_guiado()
	await falar("mull_ok")
	for id in ["alt_silfo", "alt_abrahadabra"]:         # se a troca levou uma carta da aula, ela volta
		await _garantir_na_mao(id)
	_cortar_deck(["alt_orobas"])
	# ---------- turno 1: Silfo + golpe direto ----------
	await _turno(0, 2)
	falar("silfo2", false)
	await _jogada_da_mao("alt_silfo", m.pos_ent(0, 1), func() -> bool: return _silfo() != null and not m.ocupado)
	var silfo = _silfo()
	falar("direto2a", false)
	var c_antes: int = m.cornucopia[1]
	await _jogada_do_campo(silfo, Vector2(180, m.LINHA_Y - 70), func() -> bool: return m.cornucopia[1] < c_antes,
		func(_c, _o, p: Vector2) -> bool: return p.y < m.LINHA_Y)
	await falar("direto2a_ok", false)
	await _fim_turno_jogador()
	m.efeitos.tutor = {}
	# ---------- turno da Lin: Lan Caihe ----------
	await _turno(1, 3)
	var lan = _da_mao_oponente("tao_lan_caihe")
	if lan:
		await m._jogar_entidade(lan, 1, 1)
	await m.get_tree().create_timer(0.4).timeout
	await m._fim_turno(1)
	m.efeitos.foco = [m._rect_espaco(m.proj(m.DECK_JOG))]
	await falar("lan2")
	m.efeitos.foco = []
	# ---------- turno 2: ataque (Lan morre), Rito (vai ao cemitério), "maldade" ----------
	await _turno(0, 3)
	falar("ataque2", false)
	var alvo_lan = m.campo_ent[1][1]
	if alvo_lan != null:
		await _jogada_do_campo(silfo, alvo_lan.position, func() -> bool: return silfo.atacou and not m.ocupado,
			func(_c, _o, p: Vector2) -> bool: return m._inimigo_sob(p) == 1)
	m.efeitos.foco = [m._rect_espaco(m.proj(m.CEMIT_OPON)), m._rect_espaco(m.proj(m.CEMIT_JOG))]
	await falar("cemiterio")
	m.efeitos.foco = []
	falar("rito2", false)
	c_antes = m.cornucopia[1]
	await _jogada_da_mao("alt_abrahadabra", Vector2(180, m.LINHA_Y - 40), func() -> bool: return m.cornucopia[1] < c_antes and not m.ocupado)
	m.efeitos.foco = [m._rect_espaco(m.proj(m.CEMIT_JOG))]
	await falar("rito_cem", false)
	m.efeitos.foco = []
	m.cornucopia[0] = 5                                  # a "maldade": a fadiga vai doer no próximo turno
	m.placar_pulo[0] = 1.0
	await _fim_turno_jogador()
	m.efeitos.tutor = {}
	# ---------- turno da Lin: nada ----------
	await _turno(1, 4)
	await m.get_tree().create_timer(0.5).timeout
	await m._fim_turno(1)
	# ---------- turno 3: deck vazio com 5 de Cornucópia → fadiga ----------
	await _turno(0, 4)
	await falar("fadiga", false)
	m.cornucopia[0] = 10                                 # devolve: agora dá para reembaralhar
	m.placar_pulo[0] = 1.0
	await _fim_turno_jogador()
	m.efeitos.tutor = {}
	# ---------- turno da Lin: nada ----------
	await _turno(1, 5)
	await m.get_tree().create_timer(0.5).timeout
	await m._fim_turno(1)
	# ---------- turno 4: a pergunta do reembaralhar (sem await: a fala vem por cima do pedido) ----------
	_turno(0, 5)
	await _ate(func() -> bool: return not m.efeitos.escolha.is_empty())
	falar("reemb", false)
	var bsim: Rect2 = m.efeitos.escolha[0]["rect"]
	_guia(bsim.get_center() + Vector2(0, 40), bsim.get_center())
	if auto:
		await m.get_tree().create_timer(1.2).timeout
		m.escolhido.emit(true)
	await _ate(func() -> bool: return m.efeitos.escolha.is_empty())
	_sem_guia()
	await _ate(func() -> bool: return not m.ocupado)
	await falar("reemb_ok")
	falar("final2", false)
	await _garantir_na_mao("alt_abrahadabra")
	await _jogada_da_mao("alt_abrahadabra", Vector2(180, m.LINHA_Y - 40), func() -> bool: return m.acabou)
	m.efeitos.tutor = {}
	await m.get_tree().create_timer(0.6).timeout
	m.efeitos.confete(120)
	await falar("fim2a")
	m.efeitos.confete(60)
	await falar("fim2b")
	print("TUTORIAL 2: fim, vencedor=", m.vencedor)


## Mão inicial guiada: abre o mulligan da mesa (forçado: no tutorial ele fica desligado) e pede a troca da Pedra.
func _mulligan_guiado() -> void:
	var pedra = _na_mao("alt_pedra_de_visao")
	falar("mull", false)
	m._mulligan(true)
	await _ate(func() -> bool: return m.hud.mulligan)
	if pedra:
		_guia(pedra.position + Vector2(0, -36), pedra.position)
	if auto:
		await m.get_tree().create_timer(1.2).timeout
		if pedra and m.hud.mulligan:
			m.hud.marcadas.append(pedra)
			m.efeitos.escolha[1]["texto"] = Sessao.t("TROCAR (%d)") % 1
			m.escolhido.emit(true)
	await _ate(func() -> bool: return not m.hud.mulligan)
	_sem_guia()
	await _ate(func() -> bool: return not m.ocupado)
	m.efeitos.tutor = {}


## A carta precisa estar na mão (a pessoa pode ter trocado outra no mulligan): se não está, chega do deck.
func _garantir_na_mao(id: String) -> void:
	if _na_mao(id) != null:
		return
	var c: Carta = m._carta_db(id, 0, m.proj(m.DECK_JOG), 1.0)
	c.virada_para_cima = true
	m.ocupado = true
	await m._entrar_na_mao(0, c)
	m.ocupado = false


## Deixa no deck só as cartas de `manter` (na ordem dada; a última sai primeiro): a aula precisa do deck acabar.
func _cortar_deck(manter: Array) -> void:
	var novos: Array = []
	for id in manter:
		for c in m.deck_jog:
			if c.id == id and not (c in novos):
				novos.append(c)
				break
	for c in m.deck_jog:
		if not (c in novos):
			c.queue_free()
	m.deck_jog.clear()
	for c in novos:
		m.deck_jog.append(c)
	m._deitar_cartas()


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
