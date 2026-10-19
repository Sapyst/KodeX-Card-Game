extends Node
## Autoload "Sessao": o que a próxima partida usa (decks, oponente, modo) e o progresso do torneio.

const DECKS := ["indigena", "cristianismo", "taoismo", "hinduismo", "bruxaria", "alta_magia"]
const NOME_DECK := {"indigena": "Indígena", "cristianismo": "Cristianismo", "taoismo": "Taoismo",
	"hinduismo": "Hinduísmo", "bruxaria": "Bruxaria", "alta_magia": "Alta magia", "misto": "Misto"}

var db: Dictionary = {}
var lore: Dictionary = {}
var rng := RandomNumberGenerator.new()

var modo := ""                       # "torneio" | "arcade" | "" (teste por variável de ambiente)
var deck_jogador_nome := "indigena"
var deck_jogador: Array = []         # ids das 32 cartas
var deck_oponente: Array = []
var oponente := "cristianismo"        # chave do personagem (= deck dele)
var resultado := ""                  # "vitoria" | "derrota" | "empate" — preenchido pela mesa

# torneio
var torneio_ordem: Array = []        # 6 oponentes; o último é sempre alta_magia
var torneio_idx := 0


func _ready() -> void:
	rng.randomize()
	db = JSON.parse_string(FileAccess.get_file_as_string("res://dados/cartas.json"))
	if FileAccess.file_exists("res://dados/lore.json"):
		lore = JSON.parse_string(FileAccess.get_file_as_string("res://dados/lore.json"))


func personagem(deck: String) -> Dictionary:
	return lore.get("personagens", {}).get(deck, {"nome": NOME_DECK.get(deck, deck), "titulo": "", "cor": "#e2b85a"})


## Deck temático (o de 32 da tradição) ou "misto": 32 cartas de todas as tradições com a mesma proporção
## 14 Entidades / 6 Selos / 8 Ritos / 4 Relíquias, no máximo 2 cópias e Lendária só 1 cópia (Conjunto do Abismo fora).
func montar_deck(tipo: String) -> Array:
	if tipo != "misto":
		return (db["decks"][tipo] as Array).duplicate()
	var por_tipo := {"entidade": [], "selo": [], "rito": [], "reliquia": []}
	for cid in db["cartas"]:
		var c: Dictionary = db["cartas"][cid]
		if c["cultura"] == "abismo":
			continue
		por_tipo[c["tipo"]].append(cid)
	var cota := {"entidade": 14, "selo": 6, "rito": 8, "reliquia": 4}
	var deck: Array = []
	for t in cota:
		var pool: Array = por_tipo[t].duplicate()
		var conta := {}
		var lend := 0
		while deck.filter(func(x: String) -> bool: return db["cartas"][x]["tipo"] == t).size() < cota[t] and not pool.is_empty():
			var cid: String = pool[rng.randi_range(0, pool.size() - 1)]
			var c: Dictionary = db["cartas"][cid]
			var limite := 1 if c["lendaria"] else 2
			if c["lendaria"] and lend >= 2:
				pool.erase(cid); continue
			if int(conta.get(cid, 0)) >= limite:
				pool.erase(cid); continue
			conta[cid] = int(conta.get(cid, 0)) + 1
			if c["lendaria"]:
				lend += 1
			deck.append(cid)
	return deck


func novo_torneio(deck_escolhido: String) -> void:
	modo = "torneio"
	deck_jogador_nome = deck_escolhido
	var campeoes := DECKS.slice(0, 5)
	campeoes.shuffle()
	torneio_ordem = campeoes + ["alta_magia"]
	torneio_idx = 0
	preparar_luta_torneio()


func preparar_luta_torneio() -> void:
	oponente = torneio_ordem[torneio_idx]
	deck_jogador = montar_deck(deck_jogador_nome)
	deck_oponente = montar_deck(oponente)
	resultado = ""


func preparar_arcade(meu_deck: String, opon: String, deck_opon: String) -> void:
	modo = "arcade"
	deck_jogador_nome = DECKS[rng.randi_range(0, 5)] if meu_deck == "aleatorio" else meu_deck
	oponente = DECKS[rng.randi_range(0, 5)] if opon == "aleatorio" else opon
	var d_op := deck_opon
	if d_op == "do_personagem":
		d_op = oponente
	elif d_op == "tematico_aleatorio":
		d_op = DECKS[rng.randi_range(0, 5)]
	deck_jogador = montar_deck(deck_jogador_nome)
	deck_oponente = montar_deck(d_op)
	resultado = ""
