extends Node
## Autoload "Relogio": hora confiável para as recompensas diária e semanal.
## Nunca usa o relógio do aparelho (mudar a hora do sistema não muda nada): pergunta a hora a um servidor da Cloudflare
## (/cdn-cgi/trace devolve "ts=<unix>" no corpo e libera CORS, então funciona também na web) e, a partir daí, conta o
## tempo com o relógio monotônico do motor (Time.get_ticks_msec), que o usuário não consegue ajustar.
## Antes de entregar um prêmio, Sessao sempre pede uma sincronização nova: acelerar o jogo (speedhack) também não adianta.

signal sincronizou(ok: bool)

const FONTES := ["https://cloudflare.com/cdn-cgi/trace", "https://1.1.1.1/cdn-cgi/trace"]
const FUSO := -3 * 3600                 # dia e semana viram à 00:00 de Brasília (sem horário de verão desde 2019)
const ESPERA := 6.0                     # segundos de limite por pedido

var _base := -1.0                       # hora do servidor (unix, s) no instante _ticks
var _ticks := 0
var _pedindo := false


func _ready() -> void:
	if OS.get_environment("GD_HORA_TESTE") != "":        # teste: hora fixa (unix), sem rede
		_base = float(OS.get_environment("GD_HORA_TESTE"))
		_ticks = Time.get_ticks_msec()


func _notification(what: int) -> void:
	# o relógio monotônico pode parar com o celular dormindo: ao voltar para o app, pergunta a hora de novo
	if what == NOTIFICATION_APPLICATION_RESUMED:
		sincronizar()


func sincronizado() -> bool:
	return _base > 0.0


## Hora atual (unix, s) — só vale com sincronizado() == true.
func agora() -> float:
	return _base + (Time.get_ticks_msec() - _ticks) / 1000.0


## Número do dia (dias desde 1970 no horário de Brasília).
func dia() -> int:
	return int(floor((agora() + FUSO) / 86400.0))


## Número da semana, começando na segunda-feira (1/1/1970 foi quinta: dia 4 = segunda).
func semana() -> int:
	return int(floor((dia() + 3) / 7.0))


func segundos_ate_amanha() -> int:
	return int(86400.0 - fposmod(agora() + FUSO, 86400.0))


func segundos_ate_segunda() -> int:
	var dias_na_semana := posmod(dia() + 3, 7)           # 0 = segunda
	return (6 - dias_na_semana) * 86400 + segundos_ate_amanha()


## Pergunta a hora ao servidor (tenta as fontes em ordem). Devolve true se conseguiu.
func sincronizar() -> bool:
	if OS.get_environment("GD_HORA_TESTE") != "":
		sincronizou.emit(true)
		return true
	if OS.get_environment("GD_HORA_OFFLINE") != "":       # teste: sem internet
		sincronizou.emit(false)
		return false
	while _pedindo:                                       # outro pedido em andamento: espera o resultado dele
		await sincronizou
		return sincronizado()
	_pedindo = true
	var ok := false
	for url in FONTES:
		var ts := await _pedir(url)
		if ts > 1.7e9:                                    # resposta plausível (depois de 2023)
			_base = ts
			_ticks = Time.get_ticks_msec()
			ok = true
			break
	_pedindo = false
	sincronizou.emit(ok)
	return ok


func _pedir(url: String) -> float:
	var http := HTTPRequest.new()
	http.timeout = ESPERA
	add_child(http)
	if http.request(url) != OK:
		http.queue_free()
		return -1.0
	var res: Array = await http.request_completed
	http.queue_free()
	if int(res[0]) != HTTPRequest.RESULT_SUCCESS or int(res[1]) != 200:
		return -1.0
	var corpo := (res[3] as PackedByteArray).get_string_from_utf8()
	for linha in corpo.split("\n"):
		if linha.begins_with("ts="):
			return float(linha.substr(3))
	return -1.0
