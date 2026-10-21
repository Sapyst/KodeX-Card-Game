extends Node
## Autoload "Nuvem": conta anônima e sincronia com o servidor do KodeX (servidor/: Cloudflare Worker + D1).
## Endereço do servidor: GD_SERVIDOR (testes) → user://config.cfg [rede] servidor → arquivo servidor.json do repositório
## no GitHub ({"url": "..."}). Sem endereço, o jogo funciona offline como antes (ativo() = false).
## Com servidor, ele é a fonte da verdade da economia: cada operação (booster, presente, prêmio, Essência, verso...) vai
## para /v1/op e o perfil que volta é adotado (Sessao.adotar_servidor). Nome, decks e opções vão por /v1/livre.
## Credenciais (id + segredo) ficam cifradas em user://conta.dat; nada de email nesta fase.

signal mudou                                   # conectou, desconectou ou adotou um perfil novo

const ARQ_CONTA := "user://conta.dat"
const URL_CONFIG := "https://raw.githubusercontent.com/Sapyst/KodeX-Card-Game/main/servidor.json"
const ESPERA := 8.0

var url := ""
var id := ""
var _segredo := ""
var online := false                            # último pedido chegou ao servidor
var _livres_pendente := false


func ativo() -> bool:
	return url != "" and id != ""


func id_curto() -> String:
	return id.substr(0, 6).to_upper() if id != "" else "-"


func _ready() -> void:
	_ler_conta()
	iniciar()


func _chave() -> String:
	return Sessao._chave()


func _ler_conta() -> void:
	if not FileAccess.file_exists(ARQ_CONTA):
		return
	var f := FileAccess.open_encrypted_with_pass(ARQ_CONTA, FileAccess.READ, _chave())
	if f == null:
		return
	var d = JSON.parse_string(f.get_as_text())
	if d is Dictionary:
		id = str(d.get("id", ""))
		_segredo = str(d.get("segredo", ""))


func _gravar_conta() -> void:
	var f := FileAccess.open_encrypted_with_pass(ARQ_CONTA, FileAccess.WRITE, _chave())
	if f:
		f.store_string(JSON.stringify({"id": id, "segredo": _segredo}))


## Descobre o servidor, cria a conta (levando o progresso local na 1ª vez) ou baixa o perfil da conta existente.
func iniciar() -> void:
	url = OS.get_environment("GD_SERVIDOR")
	if url == "":
		var cfg := ConfigFile.new()
		if cfg.load(Sessao.CONFIG) == OK:
			url = str(cfg.get_value("rede", "servidor", ""))
	if url == "" and OS.get_environment("GD_SEM_REDE") == "":
		var r := await _pedir("GET", URL_CONFIG, {}, false)
		if r.has("url"):
			url = str(r["url"]).trim_suffix("/")
	if url == "":
		return
	if id == "":
		var local := Sessao.perfil.duplicate(true)
		for k in Sessao.PROTEGIDOS:
			local[k] = Sessao._ler(k)
		var r := await _pedir("POST", "/v1/conta", {"perfil_local": local})
		if r.get("ok", false):
			id = str(r["id"])
			_segredo = str(r["segredo"])
			_gravar_conta()
			Sessao.adotar_servidor(r["perfil"])
	else:
		var r := await _pedir("GET", "/v1/perfil")
		if r.get("ok", false):
			Sessao.adotar_servidor(r["perfil"])
			await _reenviar_pendentes()
	mudou.emit()


## Operação de economia. Devolve o "resultado" do servidor ({} se não conectou; a operação fica pendente se `guardar`).
func op(tipo: String, dados := {}, guardar := false) -> Dictionary:
	var corpo := dados.duplicate()
	corpo["tipo"] = tipo
	var r := await _pedir("POST", "/v1/op", corpo)
	if r.has("perfil"):
		Sessao.adotar_servidor(r["perfil"])
		return r.get("resultado", {})
	if guardar:                                # sem conexão: tenta de novo na próxima abertura (o servidor confere os tetos)
		var pend: Array = Sessao.perfil.get("ops_pendentes", [])
		if pend.size() < 40:
			pend.append(corpo)
		Sessao.perfil["ops_pendentes"] = pend
		Sessao.salvar_so_local()
	return {}


func _reenviar_pendentes() -> void:
	var pend: Array = Sessao.perfil.get("ops_pendentes", [])
	Sessao.perfil["ops_pendentes"] = []
	for corpo in pend:
		var r := await _pedir("POST", "/v1/op", corpo)
		if r.has("perfil"):
			Sessao.adotar_servidor(r["perfil"])


## Nome, decks e opções: envio agrupado 1,5 s depois da última mudança.
func livres_mudaram() -> void:
	if not ativo() or _livres_pendente:
		return
	_livres_pendente = true
	await get_tree().create_timer(1.5).timeout
	_livres_pendente = false
	var campos := {}
	for k in ["nome", "tem_foto", "decks", "deck_ativo", "verso", "novas", "pacote", "tarcade", "torneio", "versao_vista",
			"pere", "torneio_vencido"]:
		if Sessao.perfil.has(k):
			campos[k] = Sessao.perfil[k]
	await _pedir("POST", "/v1/livre", {"campos": campos})


func codigo_transferencia() -> String:
	var r := await _pedir("POST", "/v1/vincular")
	return str(r.get("codigo", ""))


## Entra numa conta de outro aparelho pelo código de 8 letras (o aparelho antigo é desconectado).
func entrar(codigo: String) -> bool:
	if url == "":
		return false
	var r := await _pedir("POST", "/v1/entrar", {"codigo": codigo}, true, false)
	if not r.get("ok", false):
		return false
	id = str(r["id"])
	_segredo = str(r["segredo"])
	_gravar_conta()
	Sessao.adotar_servidor(r["perfil"], true)
	mudou.emit()
	return true


func apagar_conta() -> bool:
	var r := await _pedir("POST", "/v1/apagar")
	if r.get("ok", false):
		id = ""
		_segredo = ""
		DirAccess.remove_absolute(ARQ_CONTA)
		mudou.emit()
		return true
	return false


func _pedir(metodo: String, caminho: String, corpo := {}, relativo := true, autenticado := true) -> Dictionary:
	var http := HTTPRequest.new()
	http.timeout = ESPERA
	add_child(http)
	var cab := PackedStringArray(["content-type: application/json"])
	if autenticado and id != "":
		cab.append("authorization: KDX %s:%s" % [id, _segredo])
	var alvo := (url + caminho) if relativo else caminho
	var err := http.request(alvo, cab, HTTPClient.METHOD_POST if metodo == "POST" else HTTPClient.METHOD_GET,
		JSON.stringify(corpo) if metodo == "POST" else "")
	if err != OK:
		http.queue_free()
		return {}
	var res: Array = await http.request_completed
	http.queue_free()
	if int(res[0]) != HTTPRequest.RESULT_SUCCESS:
		online = false
		return {}
	online = true
	var d = JSON.parse_string((res[3] as PackedByteArray).get_string_from_utf8())
	return d if d is Dictionary else {}
