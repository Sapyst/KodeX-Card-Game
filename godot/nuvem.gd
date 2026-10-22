extends Node
## Autoload "Nuvem": conta anônima e sincronia com o servidor do KodeX (servidor/: Cloudflare Worker + D1).
## Endereço do servidor: GD_SERVIDOR (testes) → user://config.cfg [rede] servidor → arquivo servidor.json do repositório
## no GitHub ({"url": "..."}). Sem endereço, o jogo funciona offline como antes (ativo() = false).
## Com servidor, ele é a fonte da verdade da economia: cada operação (booster, presente, prêmio, Essência, verso...) vai
## para /v1/op e o perfil que volta é adotado (Sessao.adotar_servidor). Nome, decks e opções vão por /v1/livre.
## Credenciais (id + segredo) ficam cifradas em user://conta.dat. Lista de palavras da frase: BIP39 português
## (github.com/bitcoin/bips, bip-0039/portuguese.txt).

signal mudou                                   # conectou, desconectou ou adotou um perfil novo

const ARQ_CONTA := "user://conta.dat"
const URL_CONFIG := "https://raw.githubusercontent.com/Sapyst/KodeX-Card-Game/main/servidor.json"
const ESPERA := 8.0

var url := ""
var id := ""
var _segredo := ""
var online := false                            # último pedido chegou ao servidor
var suspensa := {}                             # {tipo, ate, motivo}: conta suspensa pela moderação (soft/hard)
var _livres_pendente := false


## Credencial da conta para a sala da partida (WebSocket; vai na URL, só por HTTPS).
func credencial() -> String:
	return "KDX %s:%s" % [id, _segredo]


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
		if str(r.get("erro", "")) == "não autenticado":   # conta apagada ou de outro servidor: cria uma nova levando o progresso
			id = ""
			_segredo = ""
			DirAccess.remove_absolute(ARQ_CONTA)
			await iniciar()
			return
		if r.get("ok", false):
			Sessao.adotar_servidor(r["perfil"])
			kode = str(r.get("kode", ""))
			email_mask = str(r.get("email", ""))
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
			"pere", "torneio_vencido", "historico", "estat", "prog", "titulo", "pere_fim", "avatares"]:
		if Sessao.perfil.has(k):
			campos[k] = Sessao.perfil[k]
	await _pedir("POST", "/v1/livre", {"campos": campos})


# ---------------- conta Kode (usuário + senha; frase de 12 palavras para trocar/recuperar) ----------------
var kode := ""                                 # usuário Kode desta conta ("" = sem Kode)
var email_mask := ""                           # email ligado, mascarado (t***@x.com)
const RODADAS := 200000                        # reforço da senha/frase no aparelho (SHA-256 encadeado, ~0,1 s)


## Reforça um texto com 200 mil rodadas de SHA-256 (o servidor nunca vê a senha nem a frase).
static func reforcar(texto: String) -> String:
	var b := texto.to_utf8_buffer()
	for k in RODADAS:
		var h := HashingContext.new()
		h.start(HashingContext.HASH_SHA256)
		h.update(b)
		b = h.finish()
	return b.hex_encode()


static func normalizar_frase(f: String) -> String:
	var p := PackedStringArray()
	for w in f.to_lower().replace(",", " ").replace("\n", " ").split(" ", false):
		p.append(w.strip_edges())
	return " ".join(p)


## 12 palavras da lista BIP39 em português, sorteadas com bytes criptográficos (128 bits de entropia).
static func gerar_frase() -> String:
	var lista := FileAccess.get_file_as_string("res://dados/bip39_pt.txt").split("\n", false)
	var bytes := Crypto.new().generate_random_bytes(24)
	var w := PackedStringArray()
	for k in 12:
		w.append(lista[(int(bytes[k * 2]) * 256 + int(bytes[k * 2 + 1])) % lista.size()].strip_edges())
	return " ".join(w)


func atualizar_info() -> void:
	var r := await _pedir("GET", "/v1/perfil")
	if r.get("ok", false):
		kode = str(r.get("kode", ""))
		email_mask = str(r.get("email", ""))
		mudou.emit()


func kode_criar(usuario: String, senha: String, frase: String) -> String:
	var u := usuario.to_lower()
	var r := await _pedir("POST", "/v1/kode/criar", {"usuario": u, "chave_senha": reforcar("kodex|%s|%s" % [u, senha]),
		"chave_frase": reforcar("kodex-frase|%s|%s" % [u, normalizar_frase(frase)])})
	if r.get("ok", false):
		kode = u
		mudou.emit()
		return ""
	return str(r.get("erro", "sem conexão"))


func _entrou(r: Dictionary) -> void:
	id = str(r["id"])
	_segredo = str(r["segredo"])
	_gravar_conta()
	Sessao.adotar_servidor(r["perfil"], true)
	await atualizar_info()


func kode_entrar(usuario: String, senha: String) -> String:
	var u := usuario.to_lower()
	var r := await _pedir("POST", "/v1/kode/entrar", {"usuario": u, "chave_senha": reforcar("kodex|%s|%s" % [u, senha])}, true, false)
	if r.get("ok", false):
		await _entrou(r)
		return ""
	return str(r.get("erro", "sem conexão"))


func kode_recuperar(usuario: String, frase: String, nova_senha: String) -> String:
	var u := usuario.to_lower()
	var r := await _pedir("POST", "/v1/kode/recuperar", {"usuario": u,
		"chave_frase": reforcar("kodex-frase|%s|%s" % [u, normalizar_frase(frase)]),
		"nova_chave_senha": reforcar("kodex|%s|%s" % [u, nova_senha])}, true, false)
	if r.get("ok", false):
		await _entrou(r)
		return ""
	return str(r.get("erro", "sem conexão"))


# ---------------- email (código de 6 dígitos) ----------------
func email_pedir(email: String) -> Dictionary:
	return await _pedir("POST", "/v1/email/pedir", {"email": email.strip_edges()}, true, false)


func email_confirmar(email: String, codigo: String) -> String:
	var r := await _pedir("POST", "/v1/email/confirmar", {"email": email.strip_edges(), "codigo": codigo.strip_edges()})
	if r.get("entrou", false):
		await _entrou(r)
		return ""
	if r.get("ligou", false):
		await atualizar_info()
		return ""
	return str(r.get("erro", "sem conexão"))


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


## Pedido com 1 nova tentativa: se não conectou, relê o endereço do servidor (o túnel do PC muda de endereço quando
## religa) e, se mudou, repete no endereço novo.
func _pedir(metodo: String, caminho: String, corpo := {}, relativo := true, autenticado := true, espera := ESPERA) -> Dictionary:
	var r := await _pedir_uma(metodo, caminho, corpo, relativo, autenticado, espera)
	if r.is_empty() and relativo and OS.get_environment("GD_SERVIDOR") == "" and await _reler_endereco():
		r = await _pedir_uma(metodo, caminho, corpo, relativo, autenticado, espera)
	return r


## Multiplayer (busca, sala, partida): pedido autenticado com espera própria (long-poll segura até ~20 s no servidor).
func mp(metodo: String, caminho: String, corpo := {}, espera := ESPERA) -> Dictionary:
	if not ativo():
		return {}
	return await _pedir(metodo, caminho, corpo, true, true, espera)


var _ultima_releitura := -100000


func _reler_endereco() -> bool:
	if Time.get_ticks_msec() - _ultima_releitura < 30000:         # no máximo 1 releitura a cada 30 s
		return false
	_ultima_releitura = Time.get_ticks_msec()
	var r := await _pedir_uma("GET", URL_CONFIG + "?t=%d" % Time.get_unix_time_from_system(), {}, false, false)
	var novo := str(r.get("url", "")).trim_suffix("/")
	if novo != "" and novo != url:
		url = novo
		return true
	return false


func _pedir_uma(metodo: String, caminho: String, corpo := {}, relativo := true, autenticado := true, espera := ESPERA) -> Dictionary:
	var http := HTTPRequest.new()
	http.timeout = espera
	http.accept_gzip = not OS.has_feature("web")   # no navegador, Accept-Encoding vira preflight de CORS
	add_child(http)
	# GET sem content-type: no navegador, esse cabeçalho força uma checagem (preflight) que o GitHub recusa
	var cab := PackedStringArray(["content-type: application/json"] if metodo == "POST" else [])
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
	if d is Dictionary and str(d.get("erro", "")) == "conta suspensa" and suspensa.is_empty():
		suspensa = d.get("suspensa", {})
		mudou.emit()
	return d if d is Dictionary else {}
