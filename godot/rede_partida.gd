class_name RedePartida
extends Node
## Rede de uma partida online (filho da mesa). "Passo travado": os dois aparelhos rodam a mesma partida com a mesma
## semente e só trocam AÇÕES (jogar, atacar, mover, fim de turno, escolhas de alvo, mulligan, desistir, emote).
## Envio: fila em ordem; cada ação leva um número (n) e o servidor ignora repetidas, então dá para reenviar sem medo.
## Recepção: long-poll em /v1/partida/{pid}/acoes?desde=N (o servidor segura o pedido até chegar algo, ~150 ms de atraso).
## Queda de conexão: tenta de novo a cada 1,5 s sem perder nada (as ações ficam no servidor). 2 min sem contato do
## outro lado = vitória por abandono (o servidor decide).

signal chegou                       # ação nova do adversário na fila (ou a partida acabou)
signal emote(k: int)
signal fim_servidor(vencedor_eu: int, queda: bool)   # 1 = venci, 0 = perdi, 2 = empate

var pid := ""
var eu := 0
var desde := 0                      # última seq lida
var _n := 0                         # número da última ação enviada por mim
var _envio: Array = []
var _enviando := false
var recebidas: Array = []           # ações do adversário ainda não aplicadas (em ordem)
var proprias: Array = []            # reconexão: minhas ações já enviadas, reaplicadas antes de voltar ao toque
var conectado := true
var encerrada := false
var _parar := false
var _ger := 0                       # cutucar() começa um pedido novo; a resposta do antigo é ignorada
var op_ausente := 0                 # segundos sem notícia do aparelho do adversário (servidor)
var _log := OS.get_environment("GD_REDE_LOG") != ""


func iniciar(p: Dictionary, retomar := false) -> void:
	pid = str(p["pid"])
	eu = int(p["eu"])
	if retomar:
		await carregar_historico()
	_laco_receber()


## Reconexão (app fechado no meio): baixa todas as ações; as minhas viram "proprias" (reaplicadas em ordem) e as dele
## entram na fila normal. Devolve quantas ações havia.
func carregar_historico() -> int:
	var r: Dictionary = await Nuvem.mp("GET", "/v1/partida/%s/acoes?desde=0&ja=1" % pid, {}, 12.0)
	for a in r.get("acoes", []):
		desde = maxi(desde, int(a["seq"]))
		var dados: Dictionary = a["dados"]
		if int(a["jogador"]) == eu:
			_n = maxi(_n, int(dados.get("n", 0)))
			if dados.get("tipo", "") != "emote":
				proprias.append(dados)
		elif dados.get("tipo", "") != "emote":
			recebidas.append(dados)
	return proprias.size() + recebidas.size()


func enviar(dados: Dictionary) -> void:
	if encerrada and dados.get("tipo", "") != "desistir":
		return
	_n += 1
	_envio.append({"n": _n, "dados": dados})
	if not _enviando:
		_laco_enviar()


func _laco_enviar() -> void:
	_enviando = true
	while not _envio.is_empty() and not _parar:
		var item: Dictionary = _envio[0]
		var r: Dictionary = await Nuvem.mp("POST", "/v1/partida/%s/acao" % pid, item, 10.0)
		if r.get("ok", false) or str(r.get("erro", "")) == "partida encerrada":
			_envio.pop_front()
			conectado = true
		else:
			conectado = false
			await get_tree().create_timer(1.5, true, false, true).timeout
	_enviando = false


func _laco_receber() -> void:
	var g := _ger
	while not _parar and g == _ger:
		var r: Dictionary = await Nuvem.mp("GET", "/v1/partida/%s/acoes?desde=%d" % [pid, desde], {}, 30.0)
		if _parar or g != _ger:
			return
		if _log:
			print("REDE recebeu desde=", desde, " ok=", r.get("ok", "vazio"), " n=", (r.get("acoes", []) as Array).size(), " erro=", r.get("erro", ""))
		if r.is_empty() or not r.get("ok", false):
			conectado = false
			await get_tree().create_timer(1.5, true, false, true).timeout
			continue
		conectado = true
		var novas := false
		for a in r.get("acoes", []):
			if int(a["seq"]) <= desde:
				continue
			desde = int(a["seq"])
			if int(a["jogador"]) == eu:
				continue
			var dados: Dictionary = a["dados"]
			if dados.get("tipo", "") == "emote":
				emote.emit(int(dados.get("k", 0)))
				continue
			recebidas.append(dados)
			novas = true
		if novas:
			chegou.emit()
		var p: Dictionary = r.get("partida", {})
		op_ausente = int(p.get("op_ausente", 0))
		if str(p.get("estado", "")) in ["fim", "cancelada"]:      # a mesa aplica o que restou na fila e encerra
			encerrada = true
			var v := int(p.get("vencedor", -1))
			fim_servidor.emit(2 if v == 2 or v < 0 else (1 if v == eu else 0), bool(p.get("queda", false)))
			chegou.emit()
			return


## Próxima ação do adversário (espera chegar). {} = a partida acabou antes.
func proxima() -> Dictionary:
	while recebidas.is_empty():
		if encerrada or _parar:
			return {}
		await chegou
	return recebidas.pop_front()


## Avisa o servidor do resultado visto aqui (o primeiro a avisar vale; desistência e queda já vêm decididas).
func avisar_fim(vencedor_local: int) -> void:
	encerrada = true
	var corpo := {"vencedor_eu": true} if vencedor_local == 0 else ({"vencedor_eu": false} if vencedor_local == 1 else {"empate": true})
	await Nuvem.mp("POST", "/v1/partida/%s/fim" % pid, corpo, 8.0)


func parar() -> void:
	_parar = true
	chegou.emit()


func cutucar() -> void:
	if _parar or encerrada:
		return
	_ger += 1
	_laco_receber()
