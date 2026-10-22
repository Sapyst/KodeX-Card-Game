extends Node
## Efeitos sonoros (autoload "Som"). Arquivos em res://audio/sfx/, sintetizados por arte/som/sintetizar_sfx.py
## (catálogo: docs/audio/catalogo_animacoes.md). 8 canais: um som não corta o outro.
##   Som.tocar("carta_comprar")                 → sorteia em rodízio carta_comprar_1..4
##   Som.tocar("efeito_cura", "celestial")      → efeito_cura_celestial (se não existir: a 1ª variação que houver)
## Cada toque varia o tom em ±3% para a repetição não cansar. Opção "Som" em Opções (Sessao.som).

const CANAIS := 8
const PASTA := "res://audio/sfx/"
var _canais: Array[AudioStreamPlayer] = []
var _prox := 0
var _arquivos := {}                     # id ou id_variação → stream
var _rodizio := {}                      # id → próximo índice das variações numeradas


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for k in CANAIS:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_canais.append(p)


func _stream(nome: String) -> AudioStream:
	if not _arquivos.has(nome):
		var arq := PASTA + nome + ".ogg"
		if not ResourceLoader.exists(arq):
			arq = PASTA + nome + ".wav"
		_arquivos[nome] = load(arq) if ResourceLoader.exists(arq) else null
	return _arquivos[nome]


func _escolher(id: String, variacao: String) -> AudioStream:
	if variacao != "":
		var s := _stream(id + "_" + variacao)
		if s:
			return s
	var s0 := _stream(id)
	if s0:
		return s0
	var nums: Array = []                                   # variações numeradas: rodízio
	for k in range(1, 9):
		var s := _stream("%s_%d" % [id, k])
		if s == null:
			break
		nums.append(s)
	if not nums.is_empty():
		var i: int = _rodizio.get(id, 0)
		_rodizio[id] = (i + 1) % nums.size()
		return nums[i]
	for v in ["comum", "meu", "minha", "leve", "1"]:      # sem variação pedida: a padrão
		var s := _stream(id + "_" + v)
		if s:
			return s
	return null


func tocar(id: String, variacao := "", vol_db := 0.0, atraso := 0.0, tom := 0.0) -> void:
	if not Sessao.som:
		return
	if atraso > 0.0:
		get_tree().create_timer(atraso, true, false, true).timeout.connect(tocar.bind(id, variacao, vol_db, 0.0, tom))
		return
	var s := _escolher(id, variacao)
	if s == null:
		return
	var p := _canais[_prox]
	for k in CANAIS:                                       # prefere um canal livre
		var c := _canais[(_prox + k) % CANAIS]
		if not c.playing:
			p = c
			_prox = (_prox + k + 1) % CANAIS
			break
	if p == _canais[_prox]:
		_prox = (_prox + 1) % CANAIS
	p.stream = s
	p.volume_db = vol_db
	p.pitch_scale = (tom if tom > 0.0 else 1.0) * randf_range(0.97, 1.03)
	p.play()
