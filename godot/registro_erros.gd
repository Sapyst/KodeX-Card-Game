class_name RegistroErros
extends Logger
## Relatório de erros local: todo erro do jogo (de script ou do motor) vai para user://erros.log com data, versão e a
## tela/modo em que aconteceu, mais as 3 primeiras linhas da pilha. Nada sai do aparelho sozinho: em Opções > Relatório
## de erros a pessoa vê quantos há e escolhe enviar (vai para o servidor do jogo, sem nome nem foto) ou apagar.
## Ligado em Sessao._ready (OS.add_logger). Chamado de qualquer thread: grava com trava e sem tocar na árvore de nós.

const ARQ := "user://erros.log"
const MAX_BYTES := 64000                 # passou disso, guarda só a metade mais nova
const MAX_POR_SESSAO := 40               # um erro repetido a cada quadro não enche o arquivo

static var contexto := ""                # tela/modo atual (Sessao atualiza)
var _trava := Mutex.new()
var _n := 0
var _vistos := {}


func _log_error(function: String, file: String, line: int, code: String, rationale: String, _editor_notify: bool,
		error_type: int, script_backtraces: Array[ScriptBacktrace]) -> void:
	if error_type == ERROR_TYPE_WARNING:
		return
	var chave := "%s:%d:%s" % [file, line, code]
	_trava.lock()
	var repetido: bool = _vistos.has(chave)
	_vistos[chave] = true
	_n += 1
	var cheio := _n > MAX_POR_SESSAO
	_trava.unlock()
	if repetido or cheio:
		return
	var tipo: String = ["ERRO", "AVISO", "SCRIPT", "SHADER"][clampi(error_type, 0, 3)]
	var linhas := PackedStringArray()
	linhas.append("[%s] v%s · %s · %s" % [Time.get_datetime_string_from_system(true), ProjectSettings.get_setting("application/config/version", "?"),
		OS.get_name(), contexto])
	linhas.append("%s: %s %s" % [tipo, code, rationale])
	linhas.append("  em %s (%s:%d)" % [function, file.get_file(), line])
	for bt in script_backtraces:
		for k in mini(bt.get_frame_count(), 3):
			linhas.append("  ← %s (%s:%d)" % [bt.get_frame_function(k), bt.get_frame_file(k).get_file(), bt.get_frame_line(k)])
		break
	_gravar("\n".join(linhas) + "\n")


func _log_message(_message: String, _error: bool) -> void:
	pass


func _gravar(txt: String) -> void:
	_trava.lock()
	var f := FileAccess.open(ARQ, FileAccess.READ_WRITE) if FileAccess.file_exists(ARQ) else FileAccess.open(ARQ, FileAccess.WRITE)
	if f:
		f.seek_end()
		f.store_string(txt)
		f.close()
	_trava.unlock()


## Corta o arquivo se cresceu demais (chamado ao abrir o jogo).
static func aparar() -> void:
	if not FileAccess.file_exists(ARQ):
		return
	var t := FileAccess.get_file_as_string(ARQ)
	if t.length() > MAX_BYTES:
		t = t.substr(t.length() - MAX_BYTES / 2)
		t = t.substr(t.find("\n[") + 1)
		var f := FileAccess.open(ARQ, FileAccess.WRITE)
		f.store_string(t)
		f.close()


static func quantos() -> int:
	if not FileAccess.file_exists(ARQ):
		return 0
	return FileAccess.get_file_as_string(ARQ).count("\n[") + int(FileAccess.get_file_as_string(ARQ).begins_with("["))


static func texto() -> String:
	return FileAccess.get_file_as_string(ARQ) if FileAccess.file_exists(ARQ) else ""


static func apagar() -> void:
	if FileAccess.file_exists(ARQ):
		DirAccess.remove_absolute(ARQ)
