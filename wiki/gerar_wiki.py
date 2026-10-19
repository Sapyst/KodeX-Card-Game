"""Gera o Wiki KodeX (Markdown para o GitHub) a partir das fichas em cartas/<deck>/NN_*.md.
  wiki/README.md            índice: tradições, tipos, regras resumidas, links
  wiki/<deck>.md            página do deck: identidade + galeria das cartas montadas
  wiki/cartas/<id>.md       ficha da carta: carta montada, arte pura, atributos, texto PT/EN, contexto, papel, balanço
Uso: python3 wiki/gerar_wiki.py"""
import glob, json, os, re

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
WIKI = os.path.join(RAIZ, "wiki")
DECKS = [("indigena", "Indígena brasileira"), ("cristianismo", "Cristianismo"), ("taoismo", "Taoismo"),
         ("hinduismo", "Hinduísmo"), ("bruxaria", "Bruxaria"), ("alta_magia", "Alta magia"), ("abismo", "Conjunto do Abismo")]
TIPO = {"entidade": "Entidade", "selo": "Selo", "rito": "Rito", "reliquia": "Relíquia"}
KW = {"guarda": "Guarda", "impeto": "Ímpeto", "furtivo": "Furtivo", "renascer": "Renascer"}
EN = json.load(open(os.path.join(RAIZ, "godot", "dados", "cartas_en.json"), encoding="utf-8"))["cartas"]
LORE = json.load(open(os.path.join(RAIZ, "godot", "dados", "lore.json"), encoding="utf-8"))["personagens"]
PROV = set()
p = os.path.join(RAIZ, "arte", "_provisorias_ids.json")
if os.path.exists(p):
    PROV = set(json.load(open(p)))


def secao(md, titulo):
    m = re.search(r"## " + titulo + r"[^\n]*\n(.*?)(?=\n## |\Z)", md, re.S)
    return m.group(1).strip() if m else ""


def ler(f):
    md = open(f, encoding="utf-8").read()
    c = json.loads(re.search(r"```json\s*(\{.*?\})\s*```", md, re.S).group(1))
    cop = re.search(r"\|\s*C[óo]pias no deck\s*\|\s*(\d)\s*\|", md)
    c["copias"] = int(cop.group(1)) if cop else 1
    c["texto"] = secao(md, "Texto da carta")
    c["contexto"] = secao(md, "Contexto mitol")
    c["papel"] = secao(md, "Papel no jogo")
    c["balanco"] = secao(md, "Balanço")
    c["atributos"] = (re.search(r"Atributos obrigatórios:\s*(.*)", md) or [None, ""])[1]
    c["arquivo"] = os.path.relpath(f, RAIZ)
    return c


def linha_stats(c):
    s = f"{TIPO[c['tipo']]} · custo {c['custo'] if c['custo'] < 90 else '—'}"
    if c["tipo"] == "entidade":
        s += f" · ATK {c['atk']} / DEF {c['vida']}"
    if c.get("usos"):
        s += f" · Usos {c['usos']}"
    if c.get("lendaria") and c["cultura"] != "abismo":
        s += " · **Lendária**"
    return s


def ficha(c, deck, nome_deck, ant, prox):
    cid = c["id"]
    kws = ", ".join(KW[k] for k in c.get("keywords", [])) or "—"
    en = EN.get(cid, {})
    L = [f"# {c['nome']}", "",
         f"[← {nome_deck}](../{deck}.md) · [Wiki KodeX](../README.md)" + (f" · [◀ {ant['nome']}]({ant['id']}.md)" if ant else "") + (f" · [{prox['nome']} ▶]({prox['id']}.md)" if prox else ""), "",
         "| Carta | Arte |", "|---|---|",
         f"| <img src=\"../../cartas_finais/v1/{deck}/{cid}.png\" width=\"340\"> | <img src=\"../../arte/{deck}/{cid}.png\" width=\"300\"> |", "",
         "| | |", "|---|---|",
         f"| **Tradição** | {nome_deck} |", f"| **Tipo** | {TIPO[c['tipo']]} |",
         f"| **Custo de Fé** | {c['custo'] if c['custo'] < 90 else '— (só por ritual)'} |"]
    if c["tipo"] == "entidade":
        L += [f"| **ATK / DEF** | {c['atk']} / {c['vida']} |"]
    if c.get("sacrificio"):
        L += [f"| **Sacrifício** | {c['sacrificio']} |"]
    if c.get("usos"):
        L += [f"| **Usos** | {c['usos']} |"]
    L += [f"| **Palavras-chave** | {kws} |", f"| **Lendária** | {'sim' if c.get('lendaria') else 'não'} |",
          f"| **Cópias no deck** | {c['copias']} |", f"| **Id** | `{cid}` |"]
    if cid in PROV:
        L += ["| **Arte** | provisória nesta Alpha |"]
    L += ["", "## Texto da carta", "", f"> {c['texto']}", ""]
    if en:
        L += [f"**EN — {en.get('nome', '')}:** *{en.get('texto', '')}*", ""]
    if c["contexto"]:
        L += ["## Contexto mitológico", "", c["contexto"], ""]
    if c["papel"]:
        L += ["## Papel no jogo", "", c["papel"], ""]
    if c["atributos"]:
        L += ["## Atributos visuais", "", c["atributos"].replace(" · ", " · "), ""]
    if c["balanco"]:
        L += ["<details><summary>Balanço (conta de custo)</summary>", "", c["balanco"], "", "</details>", ""]
    L += [f"<sub>Ficha completa: `{c['arquivo']}` · cartas base da versão Alpha</sub>", ""]
    return "\n".join(L)


def main():
    os.makedirs(os.path.join(WIKI, "cartas"), exist_ok=True)
    totais = {"entidade": 0, "selo": 0, "rito": 0, "reliquia": 0}
    indice = []
    for deck, nome_deck in DECKS:
        cartas = [ler(f) for f in sorted(glob.glob(os.path.join(RAIZ, "cartas", deck, "[0-9][0-9]_*.md")))]
        for i, c in enumerate(cartas):
            totais[c["tipo"]] += 1
            open(os.path.join(WIKI, "cartas", c["id"] + ".md"), "w", encoding="utf-8").write(
                ficha(c, deck, nome_deck, cartas[i - 1] if i else None, cartas[i + 1] if i + 1 < len(cartas) else None))
        # página do deck
        idf = os.path.join(RAIZ, "cartas", deck, "_deck.md")
        ident = ""
        if os.path.exists(idf):
            ident = secao(open(idf, encoding="utf-8").read(), "Identidade") or ""
        P = [f"# {nome_deck}", "", "[← Wiki KodeX](README.md)", ""]
        if deck in LORE:
            pp = LORE[deck]
            P += [f"<img src=\"../arte/personagens/{deck}.png\" width=\"160\" align=\"right\">", "",
                  f"**Campeão no torneio:** {pp['nome']} — *{pp['titulo']}*", ""]
        if ident:
            P += ["## Identidade do deck", "", ident, ""]
        n32 = sum(c["copias"] for c in cartas)
        P += [f"**{len(cartas)} cartas distintas · {n32} no deck**", ""]
        for t in ("entidade", "selo", "rito", "reliquia"):
            grupo = [c for c in cartas if c["tipo"] == t]
            if not grupo:
                continue
            P += [f"## {TIPO[t]}s" if t != "reliquia" else "## Relíquias", ""]
            linha = []
            for c in grupo:
                linha.append(f"<a href=\"cartas/{c['id']}.md\"><img src=\"../cartas_finais/v1/{deck}/{c['id']}.png\" width=\"150\" title=\"{c['nome']}\"></a>")
            for k in range(0, len(linha), 4):
                P += [" ".join(linha[k:k + 4]), ""]
            P += ["| Carta | Atributos | Texto |", "|---|---|---|"]
            for c in grupo:
                P += [f"| [{c['nome']}](cartas/{c['id']}.md){' ×2' if c['copias'] == 2 else ''} | {linha_stats(c)} | {c['texto'].replace('|', '/')} |"]
            P += [""]
        open(os.path.join(WIKI, deck + ".md"), "w", encoding="utf-8").write("\n".join(P))
        indice.append((deck, nome_deck, len(cartas), cartas))
    # índice
    I = ["# Wiki KodeX", "", "<img src=\"../arte/logo/logo_kodex.png\" width=\"520\">", "",
         "O códice das cartas do **KodeX** — **cartas base da versão Alpha (v0.1.0-alpha)**.",
         "Cada página traz a carta montada, a arte pura, os atributos, o texto (PT/EN), o contexto mitológico e o papel no jogo.", "",
         "## Tradições", "", "| | Tradição | Cartas | Lendárias |", "|---|---|---|---|"]
    for deck, nome_deck, n, cartas in indice:
        lend = ", ".join(f"[{c['nome']}](cartas/{c['id']}.md)" for c in cartas if c.get("lendaria")) if deck != "abismo" else "Choronzon (vitória imediata)"
        capa = next((c for c in cartas if c.get("lendaria")), cartas[0])
        I += [f"| <img src=\"../arte/{deck}/{capa['id']}.png\" width=\"60\"> | [{nome_deck}]({deck}.md) | {n} | {lend} |"]
    I += ["", "## Tipos de carta", "", "| Tipo | Total | O que é |", "|---|---|---|",
          f"| Entidade | {totais['entidade']} | deuses, espíritos, heróis e criaturas; ATK/DEF, atacam e defendem |",
          f"| Selo | {totais['selo']} | armadilha virada para baixo; dispara no turno do oponente |",
          f"| Rito | {totais['rito']} | efeito imediato (magia, milagre, ritual) |",
          f"| Relíquia | {totais['reliquia']} | objeto equipado numa Entidade aliada |", "",
          "## Regras em uma página", "",
          "- Deck de **32** cartas; mão inicial de **4**; **15** pontos de **Cornucópia** (vida).",
          "- **Fé** (recurso) começa em 0 e sobe +1 por turno até 8.",
          "- Campo: 4 espaços de Entidade e 2 de Selo por jogador.",
          "- Dano direto na Cornucópia só quando o oponente não tem Entidades em campo.",
          "- Palavras-chave: **Guarda** (tem de ser atacada primeiro), **Ímpeto** (ataca no turno em que entra), "
          "**Furtivo** (não pode ser alvo até atacar), **Renascer** (volta à mão ao morrer, uma vez), "
          "**Despertar** (efeito ao entrar), **Último Sopro** (efeito ao morrer), **Sacrifício N**.",
          "- **Choronzon**: quem o invoca pelo Sigilo 333 vence a partida.", "",
          "Regras completas: [docs/regras.md](../docs/regras.md) · Lore do torneio: [docs/lore_torneio.md](../docs/lore_torneio.md) · "
          "Como as artes foram feitas: [ARTE.md](../ARTE.md)", "", "<sub>© 2026 Sapyst — todos os direitos reservados.</sub>", ""]
    open(os.path.join(WIKI, "README.md"), "w", encoding="utf-8").write("\n".join(I))
    print("ok", sum(totais.values()), "cartas")


if __name__ == "__main__":
    main()
