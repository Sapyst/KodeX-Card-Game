"""Monta arte/HANDOFF_ANTIGRAVITY.md: instruções + ficha e prompt de TODAS as cartas para outro agente gerar e revisar no ComfyUI.
Uso: python3 montar_handoff.py"""
import glob, json, os, re

AQUI = os.path.dirname(os.path.abspath(__file__))
RAIZ = os.path.dirname(AQUI)
DECKS = [("indigena", "Indígena brasileira"), ("cristianismo", "Cristianismo"), ("taoismo", "Taoismo"),
         ("hinduismo", "Hinduísmo"), ("bruxaria", "Bruxaria"), ("alta_magia", "Alta magia"), ("abismo", "Conjunto do Abismo")]


def ficha(path):
    md = open(path, encoding="utf-8").read()
    c = json.loads(re.search(r"```json\s*(\{.*?\})\s*```", md, re.S).group(1))
    txt = re.search(r"## Texto da carta\s*\n(.*?)\n\s*\n", md, re.S)
    ctx = re.search(r"## Contexto mitol[óo]gico\s*\n(.*?)\n## ", md, re.S)
    pr = re.search(r"## Prompt de arte.*?```prompt\s*(.*?)```", md, re.S)
    return c, " ".join(txt.group(1).split()) if txt else "", (ctx.group(1).strip() if ctx else ""), \
        (" ".join(pr.group(1).split()) if pr else "")


def revisoes():
    rev = {}
    for d, _ in DECKS:
        p = os.path.join(AQUI, d, "_revisao_artes.md")
        if not os.path.exists(p):
            continue
        for ln in open(p, encoding="utf-8"):
            m = re.match(r"\|\s*(\w+)\s*\|\s*(APROVADA|REPROVADA)\s*\|\s*(.*?)\s*\|\s*$", ln)
            if m:
                rev[m.group(1)] = (m.group(2), m.group(3))
    return rev


def resumo_contexto(ctx, limite=700):
    ctx = re.sub(r"\s+", " ", ctx)
    if len(ctx) <= limite:
        return ctx
    corte = ctx[:limite].rsplit(". ", 1)[0]
    return corte + ". […]"


def main():
    import sys
    sys.path.insert(0, AQUI)
    import gerar_artes as GA
    rev = revisoes()
    L = []
    L += [
        "# Gods Kodex — geração e revisão das artes das cartas (handoff para o Antigravity)",
        "",
        "Você vai **gerar e revisar no ComfyUI local** as ilustrações das 161 cartas do jogo de cartas *Gods Kodex*",
        "(6 decks mitológicos de 32 cartas + o Conjunto do Abismo de 4). Este arquivo tem tudo: regras de estilo,",
        "configuração do ComfyUI, o fluxo de pesquisa → geração → checagem → regeneração, e a ficha + o prompt de cada carta.",
        "",
        "Projeto: `/mnt/d/Projetos de Jogos/GodsKodex/` (Linux; `D:\\Projetos de Jogos\\GodsKodex` no Windows).",
        "As fichas completas das cartas estão em `cartas/<deck>/NN_<slug>.md` (seções *Contexto mitológico* e *Prompt de arte*).",
        "",
        "## 1. Regras de estilo (inegociáveis)",
        "",
        "1. **Pixel art** (estilo aprovado), 16-bit, paleta limitada, contorno de pixel nítido. Nada de render 3D, nada de pintura lisa.",
        "2. **SEM CHIBI.** Proporções adultas e realistas: cabeça ≈ 1/7 da altura do corpo em figuras humanas adultas, olhos de tamanho",
        "   normal, mãos e pés proporcionais. Rejeite na hora qualquer imagem com cabeça grande, corpo atarracado, olhos enormes,",
        "   aparência de bebê/criança fofa ou estética *kawaii*. Seres que na tradição SÃO crianças (Saci, Curupira, Nezha) devem ter",
        "   proporção de criança real de 10–12 anos (cabeça ≈ 1/6 da altura), nunca bonequinho.",
        "3. **Fidelidade à tradição:** cada figura precisa dos atributos que a identificam (ex.: Saci = uma perna só, gorro vermelho,",
        "   cachimbo; Curupira = pés virados para trás; Ganesha = cabeça de elefante com uma presa quebrada; serafim = seis asas).",
        "   Se o atributo-chave não aparece, a imagem está reprovada, por mais bonita que seja.",
        "4. **Respeito:** hinduísmo, cristianismo e as culturas indígenas são religiões/culturas vivas. Nada de caricatura, sexualização",
        "   ou gore. Deus e Cristo **não aparecem em figura** (decisão do autor) — milagres dele são mostrados pelo efeito (luz, túmulo vazio).",
        "   Povos indígenas: adornos corretos para o povo citado na ficha (pintura de jenipapo/urucum, cocar, maracá, borduna),",
        "   sem estereótipo de faroeste e sem pele tingida de vermelho/azul como se fosse cor da pele.",
        "5. **Só a ilustração:** sem moldura, sem texto, sem letras/runas legíveis, sem número, sem borda. O frame da carta é aplicado depois.",
        "6. **Formato:** 768×1024 px (3:4, em pé). A arte inteira aparece na carta (janela 3:4), então o assunto deve caber com margem;",
        "   deixe ~8% livres no topo e ~10% embaixo (a pílula do nome e a do efeito cobrem um pouco essas faixas).",
        "7. **Uma figura principal** com silhueta clara sobre fundo escuro com um ponto de luz. O modelo erra muito com multidões,",
        "   geometria exata (pentagramas, círculos com letras) e cenas com 3+ elementos importantes — simplifique quando falhar.",
        "",
        "## 2. ComfyUI",
        "",
        "- Servidor local: `http://127.0.0.1:8188`. Se não responder, iniciar com `/mnt/d/Comfy-Desktop/run_backend.sh` (log em `/mnt/d/Comfy-Desktop/logs/comfyui.log`).",
        "- GPU: RTX 5070 Laptop 8 GB. Uma imagem leva ~15 s.",
        f"- Checkpoint: `{GA.CKPT}` (Illustrious, responde a tags separadas por vírgula, não a frases longas).",
        "- KSampler: `steps 28`, `cfg 6.0`, `sampler euler_ancestral`, `scheduler normal`, `denoise 1.0`, latente 768×1024.",
        "- Seed: livre; registre a seed usada de cada arte aprovada no log (ver §5).",
        "- Script pronto que monta o workflow pela API: `arte/gerar_artes.py` (lê o bloco ```prompt de cada ficha e salva em",
        "  `arte/<deck>/<id>.png`; `--cultura`, `--id`, `--force`, `--seed-offset`, `--dry`). Pode usar ele ou montar o seu workflow.",
        "- Modelos extras disponíveis: `4x-UltraSharp.pth` (upscale — NÃO usar na arte final, quebra o pixel), `Juggernaut_XL`,",
        "  `Animagine_XL_3.1` e `z_image_turbo` (não usar: estilo aprovado é o pixelPerfect).",
        "",
        "**Prefixo fixo** (vai antes do prompt de cada carta):",
        "```",
        GA.PREFIXO.strip().rstrip(","),
        "```",
        "Em cartas com `no humans` (criaturas, objetos, cenas) **remova** do prefixo as tags `mature, adult proportions, realistic body",
        "proportions, tall figure, small head` — elas só servem para figuras humanoides.",
        "",
        "**Negativo fixo:**",
        "```",
        GA.NEGATIVO.strip(),
        "```",
        "",
        "## 3. Pesquisa e mapeamento de referências (ANTES de gerar)",
        "",
        "Para cada carta, monte uma pequena ficha visual — é ela que garante a fidelidade, mesmo em pixel art:",
        "",
        "1. **Leia a ficha** (`cartas/<deck>/NN_<slug>.md`): *Contexto mitológico* (fonte primária, povo/região, variantes) e o prompt atual.",
        "2. **Busque imagens de referência** da figura na tradição — priorize fontes iconográficas confiáveis: Wikimedia Commons,",
        "   acervos de museus (British Museum, Met, Museu Nacional, Museu do Índio, Museu Goeldi, National Palace Museum, LACMA),",
        "   ícones e iluminuras para o cristianismo, pinturas de templo e miniaturas para o hinduísmo, xilogravuras e pinturas de",
        "   ano novo (nianhua) para o taoismo, gravuras de grimórios (Collin de Plancy, Lemegeton) para a alta magia, gravuras",
        "   históricas e folclore ilustrado (Bilibin para Baba Yaga) para a bruxaria. Evite fan art e outras IAs como referência.",
        "3. **Extraia uma checklist de 3–6 atributos obrigatórios** visíveis (forma do corpo, objeto que segura, roupa/adorno, cor",
        "   tradicional, animal/montaria, cenário típico) + **o que NÃO pode aparecer** (anacronismos, atributos de outra figura,",
        "   elementos de outra cultura). Ex.: *Mapinguari* → olho único na testa, boca no ventre, pelagem desgrenhada, garras longas;",
        "   NÃO: gorila genérico com dois olhos.",
        "4. **Traduza a checklist em tags** e acrescente/corrija no prompt (mantendo 25–45 tags, inglês, na ordem: sujeito → atributos",
        "   → pose → cenário → luz/cor → enquadramento). Descreva atributos em vez de nomes próprios (o modelo não conhece",
        "   \"Curupira\"; conhece \"feet turned backwards\").",
        "5. Salve a checklist e os links das referências em `arte/<deck>/_referencias/<id>.md` (crie a pasta). Opcional: guarde 1–3",
        "   imagens de referência ali (só para consulta; não use como entrada img2img de obra protegida).",
        "",
        "## 4. Geração, checagem e regeneração",
        "",
        "Para cada carta (todas as 161 — inclusive as marcadas como aprovadas abaixo, que foram revisadas ANTES da regra \"sem chibi\"):",
        "",
        "1. Gere **3 candidatas** com seeds diferentes a partir do prompt corrigido.",
        "2. **Cheque cada candidata visualmente** contra: (a) a checklist do §3, (b) as regras do §1 (sem chibi, sem texto, proporção,",
        "   respeito), (c) a pose combinando com a mecânica da carta (abaixo), (d) qualidade (sem membros extras, rosto derretido,",
        "   figura cortada nas bordas).",
        "3. Escolha a melhor que passe em **tudo**. Se nenhuma passar: ajuste o prompt mirando no que falhou (reforce o atributo",
        "   ausente com 2–3 tags redundantes, tire tags que puxam para o erro, simplifique o cenário) e gere mais 3. Limite: **4 rodadas**",
        "   (12 imagens) por carta; se ainda falhar, marque `PENDENTE` no log com o motivo e siga para a próxima.",
        "4. Salve a escolhida em `arte/<deck>/<id>.png` (substitui a atual; a anterior vai para `arte/<deck>/_v1/` se ainda não estiver lá).",
        "   As outras candidatas podem ficar em `arte/<deck>/_candidatas/`.",
        "5. **Atualize o bloco ```prompt da ficha** (`cartas/<deck>/NN_<slug>.md`, seção *Prompt de arte*) com o prompt que gerou a",
        "   arte aprovada. Não altere nenhuma outra seção da ficha.",
        "",
        "**Pose × mecânica:** Entidade com Guarda → postura defensiva, de frente; dano/ataque → gesto de golpe ou disparo;",
        "Relíquia → o objeto em destaque (`object focus, no humans`); Selo → cena de armadilha/proteção escondida, tom escuro;",
        "Rito → o ritual/evento em curso com um ponto focal. Lendárias podem ter mais imponência (enquadramento de baixo para cima).",
        "",
        "## 5. Entregáveis",
        "",
        "- `arte/<deck>/<id>.png` — 161 artes 768×1024 aprovadas.",
        "- `arte/<deck>/_referencias/<id>.md` — checklist + links.",
        "- `arte/LOG_ANTIGRAVITY.md` — tabela: `id | rodadas | seed final | veredito (APROVADA/PENDENTE) | o que mudou no prompt`.",
        "- Fichas `cartas/**/NN_*.md` com o bloco ```prompt atualizado.",
        "",
        "Material de apoio já existente: `arte/<deck>/_v1/` (1ª geração reprovada), `arte/<deck>/_candidatas/<id>_a|b.png`",
        "(2ª tentativa parcial, não revisada), `arte/<deck>/_revisao_artes.md` (revisão anterior com os motivos).",
        "",
        "## 6. Cartas",
        "",
        "Status = resultado da revisão anterior (antes da regra \"sem chibi\" — reavalie todas). O prompt listado é o atual da ficha",
        "(já corrigido nas reprovadas). Contexto resumido; o completo está na ficha.",
        "",
    ]
    total = 0
    for deck, nome_deck in DECKS:
        arquivos = sorted(glob.glob(os.path.join(RAIZ, "cartas", deck, "[0-9][0-9]_*.md")))
        L += [f"### {nome_deck} — {len(arquivos)} cartas", ""]
        for f in arquivos:
            c, texto, ctx, prompt = ficha(f)
            cid = c["id"]; total += 1
            tipo = c["tipo"].capitalize().replace("Reliquia", "Relíquia")
            stats = f" · {c['atk']}/{c['vida']}" if c["tipo"] == "entidade" else ""
            lend = " · Lendária" if c.get("lendaria") and deck != "abismo" else ""
            st, motivo = rev.get(cid, ("SEM REVISÃO", ""))
            cands = sorted(glob.glob(os.path.join(AQUI, deck, "_candidatas", cid + "_*.png")))
            L += [f"#### {c['nome']}  (`{cid}`)",
                  f"- Ficha: `cartas/{deck}/{os.path.basename(f)}` · {tipo}{stats}{lend}",
                  f"- Destino: `arte/{deck}/{cid}.png`",
                  f"- Texto da carta: {texto}",
                  f"- Contexto: {resumo_contexto(ctx)}",
                  f"- Revisão anterior: **{st}**" + (f" — {motivo}" if motivo else ""),
                  ]
            if cands:
                L.append("- Candidatas já geradas (não revisadas): " + ", ".join(f"`arte/{deck}/_candidatas/{os.path.basename(x)}`" for x in cands))
            L += ["- Prompt atual:", "```prompt", prompt, "```", ""]
    L.insert(4, f"Total de cartas neste arquivo: **{total}**.")
    open(os.path.join(AQUI, "HANDOFF_ANTIGRAVITY.md"), "w", encoding="utf-8").write("\n".join(L) + "\n")
    print("cartas:", total)


if __name__ == "__main__":
    main()
