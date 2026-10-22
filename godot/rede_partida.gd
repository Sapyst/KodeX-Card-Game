class_name RedePartida
extends Node
## Rede de uma partida online (filho da mesa), ligada à SALA da partida no servidor (Durable Object com o juiz) por
## WebSocket. O celular manda só intenções; o juiz confere, aplica e devolve, em ordem (s = sequência):
##   a   jogada do adversário (com o id da carta jogada; Selo vem sem) — ou uma jogada MINHA que a sala forçou por tempo
##   r   revelação: minhas compras, sorteios, descartes, buscas, Selos do adversário que dispararam, retrato do turno
##   eu  eco das minhas jogadas (só para refazer a partida quando o app volta)
##   fim resultado decidido pelo juiz
## Caiu a conexão? Tenta de novo a cada 1,5 s e pede tudo desde a última sequência recebida.

signal chegou                       # jogada do adversário na fila (ou a partida acabou)
signal revelou                      # revelação nova na fila
signal emote(k: int)
signal fim_servidor(vencedor_eu: int, queda: bool)   # 1 = venci, 0 = perdi, 2 = empate
signal forcado(tipo: String)        # a sala decidiu por mim (tempo esgotado)

var pid := ""
var eu := 0                         # meu índice no servidor (0 ou 1)
var desde := 0                      # última sequência recebida
var _n := 0                         # número da última entrada minha
var _ws := WebSocketPeer.new()
var _estado_ws := -1
var _pendentes: Array = []          # entradas que ainda não saíram (sem conexão)
var recebidas: Array = []           # jogadas do adversário ainda não aplicadas
var revelacoes: Array = []          # revelações ainda não usadas pelo motor
var proprias: Array = []            # reconexão: minhas jogadas já feitas (refeitas antes de voltar ao toque)
var conectado := false
var encerrada := false
var op_ausente := 0
var pedido := {}                    # o que a sala está esperando de mim agora ({tipo, turno})
var _parar := false
var _reconectar_em := 0.0
var _retomando := false
var _log := OS.get_environment("GD_REDE_LOG") != ""


func iniciar(p: Dictionary, retomar := false) -> void:
	pid = str(p["pid"])
	eu = int(p["eu"])
	_retomando = retomar
	_abrir()
	if retomar:                                  # volta ao app: espera o servidor mandar tudo (com os ecos)
		while _retomando and not _parar:
			await get_tree().create_timer(0.1, true, false, true).timeout


func _url() -> String:
	var base := Nuvem.url.replace("https://", "wss://").replace("http://", "ws://")
	return "%s/v1/partida/%s/ws?auth=%s" % [base, pid, Nuvem.credencial().uri_encode()]


func _abrir() -> void:
	_ws = WebSocketPeer.new()
	_ws.inbound_buffer_size = 1 << 20
	_ws.connect_to_url(_url())
	_estado_ws = -1


func _process(delta: float) -> void:
	if _parar:
		return
	_ws.poll()
	var st := _ws.get_ready_state()
	if st != _estado_ws:
		_estado_ws = st
		if st == WebSocketPeer.STATE_OPEN:
			conectado = true
			if _log:
				print("REDE abriu; pedindo desde ", desde)
			_ws.send_text(JSON.stringify({"t": "ola", "desde": desde}))
			for m in _pendentes:
				_ws.send_text(m)
			_pendentes.clear()
		elif st == WebSocketPeer.STATE_CLOSED:
			conectado = false
			_reconectar_em = 1.5
			if _log:
				print("REDE fechou: ", _ws.get_close_code(), " ", _ws.get_close_reason())
	if st == WebSocketPeer.STATE_CLOSED and not encerrada:
		_reconectar_em -= delta
		if _reconectar_em <= 0.0:
			_abrir()
	while _ws.get_available_packet_count() > 0:
		_mensagem(_ws.get_packet().get_string_from_utf8())


func _mensagem(texto: String) -> void:
	var m = JSON.parse_string(texto)
	if not (m is Dictionary):
		return
	if _log:
		print("REDE ", texto.substr(0, 160))
	match str(m.get("t", "")):
		"pedido":
			pedido = m
			return
		"pronto":
			_retomando = false
			_n = maxi(_n, int(m.get("n", 0)))      # continua a numeração de onde a sala parou
			return
		"erro":
			print("REDE erro do juiz: ", m.get("erro", ""))
			return
		"emote":
			emote.emit(int(m.get("k", 0)))
			return
		"pong":
			return
	if not m.has("s") or int(m["s"]) <= desde:
		return
	desde = int(m["s"])
	if m.has("eu"):                              # eco da minha jogada: só vale ao refazer a partida
		if _retomando:
			var e: Dictionary = m["eu"]
			proprias.append(_entrada_local(str(e.get("pedido", "")), e.get("d")))
		return
	if m.has("a"):
		var a: Dictionary = m["a"]
		if a.has("forcado"):                     # a sala jogou por mim (passou do tempo)
			if not _retomando:
				forcado.emit(str(a["forcado"]))
			return
		recebidas.append(a)
		chegou.emit()
	elif m.has("r"):
		revelacoes.append(m["r"])
		revelou.emit()
	elif m.has("fim"):
		var f: Dictionary = m["fim"]
		var v := int(f.get("vencedor", -1))
		encerrada = true
		fim_servidor.emit(2 if v == 2 or v < 0 else (1 if v == eu else 0), str(f.get("motivo", "")) == "abandono")
		chegou.emit()
		revelou.emit()


## Converte o eco do servidor (formato do juiz) para o formato que a mesa usa nas ações.
func _entrada_local(tipo_pedido: String, d) -> Dictionary:
	match tipo_pedido:
		"mulligan": return {"tipo": "mull", "k": d if d is Array else []}
		"escolha": return {"tipo": "esc", "v": int(d)}
		"sim_nao": return {"tipo": "esc", "v": 1 if d == true else 0}
	return d if d is Dictionary else {}


## Manda uma entrada minha (no formato do juiz), marcada com o turno em que foi feita.
func enviar_juiz(dados, turno: int) -> void:
	if encerrada and not (dados is Dictionary and dados.get("tipo", "") == "desistir"):
		return
	_n += 1
	var txt := JSON.stringify({"t": "in", "n": _n, "t_turno": turno, "d": dados})
	if conectado and _ws.get_ready_state() == WebSocketPeer.STATE_OPEN:
		_ws.send_text(txt)
	else:
		_pendentes.append(txt)


func enviar_emote(k: int) -> void:
	if conectado:
		_ws.send_text(JSON.stringify({"t": "emote", "k": k}))


## Próxima jogada do adversário (espera chegar). {} = a partida acabou antes.
func proxima() -> Dictionary:
	while recebidas.is_empty():
		if encerrada or _parar:
			return {}
		await chegou
	return recebidas.pop_front()


## Próxima revelação do juiz; `tipo` confere que é a esperada ("" = qualquer). {} = a partida acabou antes.
func revelacao(tipo := "") -> Dictionary:
	while revelacoes.is_empty():
		if encerrada or _parar:
			return {}
		await revelou
	var r: Dictionary = revelacoes.pop_front()
	if tipo != "" and str(r.get("r", "")) != tipo:
		push_warning("revelação fora de ordem: esperava %s, veio %s" % [tipo, str(r.get("r", ""))])
		r["_fora_de_ordem"] = true
	return r


func avisar_fim(_vencedor_local: int) -> void:
	encerrada = true                             # o juiz já decide o resultado; nada a mandar


func cutucar() -> void:
	if not _parar and not encerrada and _ws.get_ready_state() != WebSocketPeer.STATE_OPEN:
		_abrir()


func parar() -> void:
	_parar = true
	_ws.close()
	chegou.emit()
	revelou.emit()
