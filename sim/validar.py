#!/usr/bin/env python3
"""Valida as cartas de uma cultura: JSON no vocabulário da DSL, distribuição 14/6/8/4,
curva de custo, cópias, lendárias. Uso: python3 validar.py <pasta cartas/<cultura>> [--quiet]"""
import sys, re, json, os, glob
from collections import Counter

KEYWORDS = {"impeto", "guarda", "renascer", "furtivo"}
TIPOS = {"entidade", "selo", "rito", "reliquia"}
G_ENT = {"on_play", "on_death", "on_attack", "on_damaged", "ally_attacked", "start_turn", "end_turn",
         "ally_dies", "enemy_dies", "static"}
G_SELO = {"enemy_attacks", "enemy_attacks_cornucopia", "enemy_plays_entity", "enemy_plays_rite",
          "enemy_plays_reliquia", "ally_dies", "ally_damaged", "enemy_end_turn"}
G_RITO = {"on_play"}
G_REL = {"on_equip", "static", "equipped_attacks", "equipped_dies"}
COND = {"ally_count_min", "ally_count_max", "enemy_count_min", "enemy_count_max", "hand_min", "hand_max",
        "cornucopia_below", "enemy_cornucopia_below", "graveyard_entities_min", "fe_max_min", "target_cost_max"}
ALVOS = {"self", "attacker", "defender", "triggering", "equipped", "other_ally_entities", "enemy_entity", "enemy_entity_random", "all_enemy_entities",
         "ally_entity", "ally_entity_random", "all_ally_entities", "all_entities", "enemy_cornucopia",
         "ally_cornucopia", "enemy_hand_random", "ally_graveyard_entity", "ally_graveyard_entity_random"}
OPS = {"damage": {"alvo", "n"}, "heal": {"alvo", "n"}, "draw": {"n"}, "search": set(),
       "buff": {"alvo", "atk", "vida", "perm"}, "destroy": {"alvo"}, "bounce": {"alvo"},
       "summon": {"atk", "vida", "nome"}, "revive": {"alvo", "para"}, "discard": {"alvo", "n"},
       "gain_fe": {"n", "perm"}, "silence": {"alvo"}, "freeze": {"alvo"}, "counter": set(),
       "give_keyword": {"alvo", "keyword"}, "set_stats": {"alvo", "atk", "vida"}, "copy_stats": {"alvo"},
       "swap_control": {"alvo"}, "win": set(), "ritual_choronzon": set()}
PREFIXOS = {"indigena": "ind", "cristianismo": "cri", "taoismo": "tao", "hinduismo": "hin",
            "bruxaria": "bru", "alta_magia": "alt", "abismo": "aby"}


def extrair(md):
    m = re.search(r"```json\s*(\{.*?\})\s*```", md, re.S)
    if not m:
        return None, "sem bloco ```json"
    try:
        return json.loads(m.group(1)), None
    except json.JSONDecodeError as e:
        return None, f"JSON inválido: {e}"


def copias(md):
    m = re.search(r"\|\s*C[óo]pias no deck\s*\|\s*(\d)\s*\|", md)
    return int(m.group(1)) if m else None


def lendaria_tabela(md):
    m = re.search(r"\|\s*Lend[áa]ria\s*\|\s*(sim|n[ãa]o)\s*\|", md, re.I)
    return (m.group(1).lower() == "sim") if m else None


def validar_carta(c, cultura, erros, avisos, nome_arq):
    def err(s): erros.append(f"{nome_arq}: {s}")
    def av(s): avisos.append(f"{nome_arq}: {s}")
    for k in ("id", "nome", "cultura", "tipo", "custo", "atk", "vida", "lendaria", "keywords", "sacrificio", "efeitos", "usos"):
        if k not in c:
            err(f"campo '{k}' ausente")
    if erros and erros[-1].startswith(nome_arq) and "ausente" in erros[-1]:
        return
    pref = PREFIXOS.get(cultura)
    if pref and not c["id"].startswith(pref + "_"):
        err(f"id '{c['id']}' deveria começar com '{pref}_'")
    if not re.fullmatch(r"[a-z]{3}_[a-z0-9_]+", c["id"]):
        err(f"id '{c['id']}' fora do padrão (minúsculas, sem acento)")
    if c["tipo"] not in TIPOS:
        err(f"tipo '{c['tipo']}' inválido")
        return
    if not (isinstance(c["custo"], int) and 0 <= c["custo"] <= 8):
        err(f"custo {c['custo']} fora de 0–8")
    if c["tipo"] == "entidade":
        if not (isinstance(c["atk"], int) and isinstance(c["vida"], int) and c["vida"] >= 1 and c["atk"] >= 0):
            err("entidade precisa de atk ≥ 0 e vida ≥ 1 inteiros")
        else:
            P = 2 * c["custo"] + 1 + (2 if c["lendaria"] else 0) + 2 * c.get("sacrificio", 0)
            base = c["atk"] + c["vida"]
            if base > P:
                err(f"ATK+Vida={base} acima do orçamento P={P} (sem contar habilidades)")
            elif base + 1 >= P and (c["efeitos"] or c["keywords"]):
                av(f"ATK+Vida={base} já ocupa quase todo o orçamento P={P}; habilidades/keywords ficam 'de graça' — conferir")
            elif base < P - 6:
                av(f"ATK+Vida={base} muito abaixo de P={P}; habilidades precisam valer {P - base} pts — conferir")
        if not (0 <= c.get("sacrificio", 0) <= 2):
            err("sacrificio deve ser 0–2")
    else:
        if c["atk"] is not None or c["vida"] is not None:
            err("atk/vida devem ser null fora de Entidade")
        if c.get("sacrificio", 0) != 0:
            err("sacrificio só em Entidade")
    bad_kw = set(c["keywords"]) - KEYWORDS
    if bad_kw:
        err(f"keywords inválidas: {bad_kw}")
    if c["keywords"] and c["tipo"] != "entidade":
        err("keywords só em Entidade")
    if c["usos"] is not None and c["tipo"] != "reliquia":
        err("usos só em Relíquia")
    gat_ok = {"entidade": G_ENT, "selo": G_SELO, "rito": G_RITO, "reliquia": G_REL}[c["tipo"]]
    efs = c["efeitos"]
    if c["tipo"] == "rito" and len(efs) != 1:
        err("Rito precisa de exatamente 1 efeito (on_play)")
    if c["tipo"] == "selo" and len(efs) != 1:
        err("Selo precisa de exatamente 1 efeito")
    if c["tipo"] == "entidade" and len(efs) > 2:
        err("Entidade: máx. 2 efeitos")
    for ef in efs:
        g = ef.get("gatilho")
        if g not in gat_ok:
            err(f"gatilho '{g}' inválido para {c['tipo']}")
        cond = ef.get("cond")
        if cond is not None and cond.get("tipo") not in COND:
            err(f"cond tipo '{cond.get('tipo')}' inválido")
        for a in ef.get("acoes", []):
            op = a.get("op")
            if op not in OPS:
                err(f"op '{op}' inválida"); continue
            if op in ("win", "ritual_choronzon") and cultura != "abismo":
                err(f"op '{op}' é exclusiva do Conjunto do Abismo")
            faltam = OPS[op] - set(a)
            if faltam:
                err(f"op '{op}' sem campos {faltam}")
            if "alvo" in a and a["alvo"] not in ALVOS:
                err(f"alvo '{a['alvo']}' inválido")
            if op == "counter" and g not in {"enemy_plays_entity", "enemy_plays_rite", "enemy_plays_reliquia"}:
                err("counter só com gatilho enemy_plays_*")
            if op == "damage" and a.get("alvo") == "enemy_cornucopia" and a.get("n", 0) > 3:
                err("dano direto à Cornucópia máx. 3 por carta")
            if op == "revive" and a.get("para") not in ("hand", "field"):
                err("revive.para deve ser hand|field")
            if g == "static" and not (op in ("buff", "give_keyword") and (a.get("alvo", "").startswith("all_") or a.get("alvo") == "other_ally_entities")):
                err("static só aceita buff/give_keyword em all_*")
            if op == "search":
                extras = set(a) - {"op", "tipo", "custo_max", "keyword"}
                if extras:
                    err(f"search com campos desconhecidos {extras}")


def main():
    pasta = sys.argv[1].rstrip("/")
    cultura = os.path.basename(pasta)
    erros, avisos = [], []
    cartas = []
    for f in sorted(glob.glob(os.path.join(pasta, "*.md"))):
        nome = os.path.basename(f)
        if nome.startswith("_"):
            continue
        md = open(f, encoding="utf-8").read()
        c, e = extrair(md)
        if e:
            erros.append(f"{nome}: {e}"); continue
        n = copias(md)
        if n not in (1, 2):
            erros.append(f"{nome}: linha '| Cópias no deck | 1 ou 2 |' ausente/inválida"); n = 1
        lt = lendaria_tabela(md)
        if lt is not None and c.get("lendaria") is not None and lt != c["lendaria"]:
            erros.append(f"{nome}: tabela diz Lendária={lt} mas JSON diz {c['lendaria']}")
        if c.get("lendaria") and n != 1:
            erros.append(f"{nome}: Lendária com 2 cópias")
        if not re.search(r"## Contexto mitol", md):
            erros.append(f"{nome}: falta seção '## Contexto mitológico'")
        if not re.search(r"## Texto da carta", md):
            erros.append(f"{nome}: falta seção '## Texto da carta'")
        validar_carta(c, cultura, erros, avisos, nome)
        cartas.append((c, n))
    ids = Counter(c["id"] for c, _ in cartas)
    for i, k in ids.items():
        if k > 1:
            erros.append(f"id duplicado: {i}")
    total = sum(n for _, n in cartas)
    tipos = Counter()
    curva = Counter()
    lend = 0
    for c, n in cartas:
        tipos[c["tipo"]] += n
        if c["tipo"] == "entidade":
            cu = c["custo"]
            faixa = "1-2" if cu <= 2 else "3-4" if cu <= 4 else "5-6" if cu <= 6 else "7-8"
            curva[faixa] += n
        if c.get("lendaria"):
            lend += 1
    esperado = {"entidade": 14, "selo": 6, "rito": 8, "reliquia": 4}
    for t, q in esperado.items():
        if tipos[t] != q:
            erros.append(f"distribuição: {t} = {tipos[t]} (esperado {q})")
    if total != 32:
        erros.append(f"total de cartas no deck = {total} (esperado 32)")
    curva_esp = {"1-2": 4, "3-4": 6, "5-6": 3, "7-8": 1}
    for f_, q in curva_esp.items():
        if curva[f_] != q:
            (avisos if abs(curva[f_] - q) <= 1 else erros).append(f"curva de custo Entidades {f_} = {curva[f_]} (esperado {q})")
    if not (1 <= lend <= 2):
        erros.append(f"lendárias = {lend} (esperado 1–2)")
    print(f"[{cultura}] {len(cartas)} arquivos, {total} cartas no deck, tipos={dict(tipos)}, curva={dict(curva)}, lendárias={lend}")
    for a in avisos:
        print("  AVISO:", a)
    for e in erros:
        print("  ERRO:", e)
    print("OK" if not erros else f"{len(erros)} erro(s)")
    sys.exit(0 if not erros else 1)


if __name__ == "__main__":
    main()
