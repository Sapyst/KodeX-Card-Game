"""Métricas da rodada 2 (Analista). Roda os duelos direto no motor (não depende do JSON do duel.py).

  python3 relatorios/r2_metricas.py <pastaA> <pastaB> [n] [seed] [--bot heur|def]

Para cada carta de A e B: WR quando jogada, WR quando COMPRADA (sem viés de sobrevivência),
rodada média da 1ª jogada, "na mão". Mais: dano à Cornucópia por fonte, fadiga, contadores
específicos (Boitatá on_damaged, Miguel/Shiva/Baba Yaga Despertar, Andras acertos, Abrahadabra).
"""
import sys, os, re
from collections import Counter, defaultdict
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from cards import carregar_pasta
from engine import Jogo, Cornucopia
from bots import HeurBot, valor

re_corn = re.compile(r"cornucópia j(\d) -(\d+) = ")
re_ent = re.compile(r"<([^<>]+?) (\d+)/(-?\d+) j(\d)>")


class DefBot(HeurBot):
    """HeurBot defensivo: sob pressão (inimigo com Ímpeto pronto ou Cornucópia ≤ 9) prefere
    Entidades a Ritos/Selos, e não faz ataques de 'chip' que deixem corpos feridos."""
    nome = "def"

    def _pressao(self, jogo, j):
        ini = jogo.oponente(j)
        return j.cornucopia <= 9 or any(e.tem("impeto") for e in ini.campo) or j.cornucopia < ini.cornucopia

    def _pontuar_jogada(self, jogo, j, a):
        p = super()._pontuar_jogada(jogo, j, a)
        if self._pressao(jogo, j) and a.carta.tipo == "entidade":
            p += 3.0
        return p

    def _melhor_ataque(self, jogo, j, ataques):
        if not self._pressao(jogo, j):
            return super()._melhor_ataque(jogo, j, ataques)
        melhor, mp = None, 0.0
        for a in ataques:
            pts = self._pontuar_ataque(a.atacante, a.alvo)
            if not isinstance(a.alvo, Cornucopia):
                mata = a.atacante.atk >= a.alvo.vida
                if not mata:
                    pts = 0.0  # não arranha: guarda o corpo intacto como bloqueador
            if pts > mp:
                melhor, mp = a, pts
        return melhor


BOTS = {"heur": HeurBot, "def": DefBot}


def rodar(pasta_a, pasta_b, n=1000, seed=11, bot="heur", quiet=False):
    da, db = carregar_pasta(pasta_a), carregar_pasta(pasta_b)
    fab = BOTS[bot]
    nomes = {0: da.nome, 1: db.nome}
    cartas = {0: {}, 1: {}}
    for idx, d in ((0, da), (1, db)):
        for c in d.distintas:
            cartas[idx][c.id] = {"nome": c.nome, "tipo": c.tipo, "custo": c.custo, "pj": 0, "vj": 0, "pc": 0, "vc": 0,
                                 "rod1": [], "comp": 0, "mao": 0, "jog": 0}
    T = Counter(); vit = [0, 0]; rod = 0; primeiro = 0; emp = 0
    for i in range(n):
        g = Jogo(da, db, [fab(), fab()], seed=seed * 1_000_003 + i, primeiro=i % 2, log=True)
        g.jogar()
        rod += g.rodada
        if g.vencedor is None:
            emp += 1
        else:
            vit[g.vencedor] += 1
            if g.vencedor == g.primeiro:
                primeiro += 1
        L = [l for l in g.log]
        # rodada da 1ª jogada por carta
        prim = {0: {}, 1: {}}
        for l in L:
            m = re.match(r"\[r(\d+) t\d+ j(\d)\] j(\d) joga (.+)$", l)
            if m:
                r_, jd, nome = int(m.group(1)), int(m.group(3)), m.group(4)
                prim[jd].setdefault(nome, r_)
        for jd, j in enumerate(g.jogadores):
            ganhou = g.vencedor == jd
            cont = Counter(j.jogadas)
            for cid, k in cont.items():
                if cid in cartas[jd]:
                    reg = cartas[jd][cid]; reg["jog"] += k; reg["pj"] += 1; reg["vj"] += ganhou
                    if reg["nome"] in prim[jd]:
                        reg["rod1"].append(prim[jd][reg["nome"]])
            for cid, k in j.compradas.items():
                if cid in cartas[jd]:
                    reg = cartas[jd][cid]; reg["comp"] += k; reg["pc"] += 1; reg["vc"] += ganhou
            for c in j.mao:
                if c.id in cartas[jd]:
                    cartas[jd][c.id]["mao"] += 1
            if j.fadiga:
                T[("fadiga_jogos", jd)] += 1
        # dano à Cornucópia por fonte + contadores de log
        LL = [l.split('] ', 1)[1] for l in L]
        em_ataque = False
        for i2, l in enumerate(LL):
            if ' ataca ' in l:
                em_ataque = True
            elif (l.startswith('j') and ' joga ' in l) or 'enemy_end_turn' in l or ' revive ' in l or l.startswith('mulligan'):
                em_ataque = False
            if l.startswith('morre'):
                me = re_ent.search(l)
                if me:
                    T[("mortes_combate" if em_ataque else "mortes_efeito", int(me.group(4)))] += 1
            mc = re_corn.search(l)
            if mc:
                alvo, nn = int(mc.group(1)), int(mc.group(2))
                k = i2 - 1; tipo = 'efeito'
                while k >= 0 and k >= i2 - 6:
                    if 'ataca Cornucopia' in LL[k]: tipo = 'ataque'; break
                    if LL[k].startswith('j') and ' joga ' in LL[k]: break
                    if LL[k].startswith('selo') and 'enemy_end_turn' in LL[k]: break
                    k -= 1
                if i2 + 1 < len(LL) and LL[i2 + 1].startswith('fadiga'):
                    T[("fadiga_dano", alvo)] += nn
                else:
                    T[(tipo, 1 - alvo)] += nn
            if 'ataca Cornucopia' in l:
                me = re_ent.search(l)
                if me: T[("ataques_corn", int(me.group(4)))] += 1
            mg = re.match(r"gatilho (\w+) de <([^<>]+?) (\d+)/(-?\d+) j(\d)>", l)
            if mg:
                gat, nome, jd = mg.group(1), mg.group(2), int(mg.group(5))
                T[("gat", jd, nome, gat)] += 1
                if gat == "on_play" and nome in ("São Miguel Arcanjo", "Shiva Nataraja", "Baba Yaga", "Andras, o Semeador de Discórdia", "Narasimha", "Judite"):
                    nxt = LL[i2 + 1] if i2 + 1 < len(LL) else ''
                    if nxt.startswith('morre'):
                        me = re_ent.search(nxt)
                        if me and int(me.group(4)) != jd:
                            T[("mata_despertar", jd, nome)] += 1
    P = n
    res = {"a": nomes[0], "b": nomes[1], "n": n, "taxa_a": vit[0] / P, "taxa_b": vit[1] / P, "emp": emp / P,
           "rodadas": rod / P, "primeiro": primeiro / max(1, P - emp)}
    for jd in (0, 1):
        res[f"ataque_{jd}"] = T[("ataque", jd)] / P
        res[f"efeito_{jd}"] = T[("efeito", jd)] / P
        res[f"fadiga_dano_{jd}"] = T[("fadiga_dano", jd)] / P
        res[f"fadiga_jogos_{jd}"] = T[("fadiga_jogos", jd)] / P
        res[f"ataques_corn_{jd}"] = T[("ataques_corn", jd)] / P
        res[f"mortes_efeito_causadas_{jd}"] = T[("mortes_efeito", 1 - jd)] / P
        res[f"mortes_combate_causadas_{jd}"] = T[("mortes_combate", 1 - jd)] / P
    res["T"] = T; res["cartas"] = cartas
    if not quiet:
        print(f"== {nomes[0]} (A) x {nomes[1]} (B) — n={n} seed={seed} bot={bot}")
        print(f"   A {100*res['taxa_a']:.1f}%  B {100*res['taxa_b']:.1f}%  rodadas {res['rodadas']:.1f}  1º vence {100*res['primeiro']:.1f}%")
        for jd in (0, 1):
            print(f"   [{nomes[jd]}] dano Cornucópia: ataque {res[f'ataque_{jd}']:.1f} efeito {res[f'efeito_{jd}']:.1f} | ataques à Cornucópia {res[f'ataques_corn_{jd}']:.1f}/partida | fadiga: {100*res[f'fadiga_jogos_{jd}']:.0f}% das partidas, {res[f'fadiga_dano_{jd}']:.1f} de dano | Entidades inimigas mortas: por efeito {res[f'mortes_efeito_causadas_{jd}']:.1f}, em combate {res[f'mortes_combate_causadas_{jd}']:.1f}")
        esp = [(k, v) for k, v in T.items() if k[0] in ("mata_despertar",) or (k[0] == "gat" and k[2] in ("Boitatá", "Curupira", "Mapinguari", "Babalon, a Mulher Escarlate", "Hanuman", "Krishna, o Auriga") )]
        for k, v in sorted(esp, key=str):
            print(f"      {str(k):<70} {v/P:.2f}/partida")
        for jd in (0, 1):
            print(f"   -- {nomes[jd]}: carta | WR jogada | WR comprada | rod.1ª jogada | na mão")
            regs = sorted(cartas[jd].values(), key=lambda r: -(r["vc"] / max(1, r["pc"])))
            for r in regs:
                wrj = 100 * r["vj"] / max(1, r["pj"]); wrc = 100 * r["vc"] / max(1, r["pc"])
                r1 = sum(r["rod1"]) / len(r["rod1"]) if r["rod1"] else 0
                nm = 100 * r["mao"] / max(1, r["comp"])
                print(f"      {r['nome'][:28]:<28} {r['tipo'][:4]} C{r['custo']}  jog {wrj:5.1f}  comp {wrc:5.1f}  r1 {r1:4.1f}  mão {nm:4.1f}  (jog={r['jog']})")
    return res


if __name__ == "__main__":
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    bot = "heur"
    if "--bot" in sys.argv:
        bot = sys.argv[sys.argv.index("--bot") + 1]
        if bot in args: args.remove(bot)
    n = int(args[2]) if len(args) > 2 else 1000
    seed = int(args[3]) if len(args) > 3 else 11
    rodar(args[0], args[1], n, seed, bot)
