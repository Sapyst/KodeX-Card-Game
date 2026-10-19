#!/usr/bin/env python3
"""CLI de duelos.

  python3 duel.py <pastaA> <pastaB> --n 2000 --seed 1 [--bot heur|random] [--json saida.json] [--log]
  python3 duel.py --todos <pasta cartas/> --n 1000 [--json saida.json]
"""
from __future__ import annotations

import argparse
import itertools
import json
import os
import sys
import time
from collections import Counter, defaultdict

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from bots import BOTS  # noqa: E402
from cards import Deck, DeckInvalido, carregar_pasta  # noqa: E402
from engine import Jogo  # noqa: E402


LADOS = ("A", "B")


def novo_registro_carta(c, lado: str, deck: str):
    return {"id": c.id, "nome": c.nome, "tipo": c.tipo, "custo": c.custo, "deck": deck, "lado": lado,
            "jogadas": 0, "partidas_jogada": 0, "vitorias_jogada": 0, "dano_total": 0,
            "compradas": 0, "ficou_na_mao": 0, "partidas_comprada": 0, "vitorias_comprada": 0}


class Agregador:
    def __init__(self, deck_a: Deck, deck_b: Deck):
        self.decks = [deck_a, deck_b]
        self.vitorias = [0, 0]
        self.empates = 0
        self.partidas = 0
        self.rodadas_total = 0
        self.primeiro_venceu = 0
        self.cartas = {}
        for idx, d in enumerate(self.decks):
            for c in d.distintas:
                self.cartas[(idx, c.id)] = novo_registro_carta(c, LADOS[idx], d.nome)

    def registrar(self, jogo: Jogo):
        self.partidas += 1
        self.rodadas_total += jogo.rodada
        if jogo.vencedor is None:
            self.empates += 1
        else:
            self.vitorias[jogo.vencedor] += 1
            if jogo.vencedor == jogo.primeiro:
                self.primeiro_venceu += 1
        for j in jogo.jogadores:
            cont = Counter(j.jogadas)
            for cid, n in cont.items():
                reg = self._reg(j.idx, cid)
                reg["jogadas"] += n
                reg["partidas_jogada"] += 1
                if jogo.vencedor == j.idx:
                    reg["vitorias_jogada"] += 1
            for cid, n in j.dano_por_carta.items():
                self._reg(j.idx, cid)["dano_total"] += n
            for cid, n in j.compradas.items():
                reg = self._reg(j.idx, cid)
                reg["compradas"] += n
                reg["partidas_comprada"] += 1          # a carta chegou à mão nesta partida (jogada ou não)
                if jogo.vencedor == j.idx:
                    reg["vitorias_comprada"] += 1
            for c in j.mao:
                self._reg(j.idx, c.id)["ficou_na_mao"] += 1

    def _reg(self, idx, cid):
        if (idx, cid) not in self.cartas:
            self.cartas[(idx, cid)] = {"id": cid, "nome": cid, "tipo": "token", "custo": 0, "deck": self.decks[idx].nome,
                                       "lado": LADOS[idx], "jogadas": 0, "partidas_jogada": 0, "vitorias_jogada": 0,
                                       "dano_total": 0, "compradas": 0, "ficou_na_mao": 0,
                                       "partidas_comprada": 0, "vitorias_comprada": 0}
        return self.cartas[(idx, cid)]

    def resumo(self) -> dict:
        decididas = self.partidas - self.empates
        return {
            "deck_a": self.decks[0].nome, "deck_b": self.decks[1].nome, "partidas": self.partidas,
            "vitorias_a": self.vitorias[0], "vitorias_b": self.vitorias[1], "empates": self.empates,
            "taxa_a": self.vitorias[0] / self.partidas if self.partidas else 0,
            "taxa_b": self.vitorias[1] / self.partidas if self.partidas else 0,
            "taxa_empate": self.empates / self.partidas if self.partidas else 0,
            "rodadas_media": self.rodadas_total / self.partidas if self.partidas else 0,
            "primeiro_vence": self.primeiro_venceu / decididas if decididas else 0,
            "cartas": [self._carta_dict(r) for r in self.cartas.values()],
        }

    @staticmethod
    def _carta_dict(r) -> dict:
        d = dict(r)
        d["win_rate_jogada"] = r["vitorias_jogada"] / r["partidas_jogada"] if r["partidas_jogada"] else None
        d["dano_medio"] = r["dano_total"] / r["jogadas"] if r["jogadas"] else 0.0
        d["taxa_ficou_na_mao"] = r["ficou_na_mao"] / r["compradas"] if r["compradas"] else None
        # WR "comprada": fração vencida das partidas em que a carta chegou à mão (jogada ou não).
        # Sem o viés de sobrevivência de "WR jogada" (cartas caras só são jogadas em partidas longas).
        d["win_rate_comprada"] = r["vitorias_comprada"] / r["partidas_comprada"] if r.get("partidas_comprada") else None
        return d


def rodar_duelos(deck_a: Deck, deck_b: Deck, n: int, seed: int, bot_nome: str = "heur",
                 log_primeiro: bool = False) -> Agregador:
    fabrica = BOTS[bot_nome]
    agg = Agregador(deck_a, deck_b)
    for i in range(n):
        jogo = Jogo(deck_a, deck_b, [fabrica(), fabrica()], seed=seed * 1_000_003 + i, primeiro=i % 2,
                    log=(log_primeiro and i == 0))
        jogo.jogar()
        agg.registrar(jogo)
        if jogo.log:
            print("\n".join(jogo.log))
            print()
    return agg


# ---------- impressão ----------
def pct(x) -> str:
    return "  —  " if x is None else f"{100 * x:5.1f}%"


def imprimir_resumo(res: dict):
    print(f"== {res['deck_a']} vs {res['deck_b']} — {res['partidas']} duelos ==")
    print(f"  Vitórias A: {pct(res['taxa_a'])}   Vitórias B: {pct(res['taxa_b'])}   Empates: {pct(res['taxa_empate'])}")
    print(f"  Duração média: {res['rodadas_media']:.1f} rodadas   Vantagem de quem começa: {pct(res['primeiro_vence'])}")
    print()
    for lado, deck in zip(LADOS, (res["deck_a"], res["deck_b"])):
        print(f"  -- lado {lado}: cartas de {deck} --")
        print(f"  {'carta':<28} {'tipo':<9} {'C':>2} {'jogadas':>8} {'WR jogada':>10} {'WR comprada':>12} {'dano méd':>9} {'na mão':>7}")
        linhas = [c for c in res["cartas"] if c["lado"] == lado and c["tipo"] != "token"]
        for c in sorted(linhas, key=lambda c: (c["tipo"], c["custo"], c["nome"])):
            print(f"  {c['nome'][:28]:<28} {c['tipo']:<9} {c['custo']:>2} {c['jogadas']:>8} {pct(c['win_rate_jogada']):>10}"
                  f" {pct(c.get('win_rate_comprada')):>12} {c['dano_medio']:>9.2f} {pct(c['taxa_ficou_na_mao']):>7}")
        print()


def imprimir_matriz(nomes: list, matriz: dict):
    larg = max(len(n) for n in nomes) + 1
    print("== Matriz de win rate (linha vence coluna; empate conta 0,5) ==")
    print(" " * larg + "".join(f"{n[:7]:>8}" for n in nomes))
    for a in nomes:
        linha = f"{a:<{larg}}"
        for b in nomes:
            linha += "    —   " if a == b else f"{100 * matriz[a][b]:7.1f}%"
        print(linha)
    print()


def imprimir_ranking(cartas: list, k: int = 15, min_partidas: int = 30):
    elegiveis = [c for c in cartas if c["partidas_jogada"] >= min_partidas and c["tipo"] != "token"]
    elegiveis.sort(key=lambda c: -c["win_rate_jogada"])
    print(f"== Cartas mais fortes (win rate quando jogada, ≥{min_partidas} partidas; 'comprada' = WR da partida em que chegou à mão) ==")
    for c in elegiveis[:k]:
        print(f"  {pct(c['win_rate_jogada'])}  comprada={pct(c.get('win_rate_comprada'))}  {c['nome'][:30]:<30} [{c['deck']}] jogadas={c['jogadas']} dano={c['dano_medio']:.1f}")
    print("== Cartas mais fracas ==")
    for c in elegiveis[-k:][::-1]:
        print(f"  {pct(c['win_rate_jogada'])}  comprada={pct(c.get('win_rate_comprada'))}  {c['nome'][:30]:<30} [{c['deck']}] jogadas={c['jogadas']} na mão={pct(c['taxa_ficou_na_mao'])}")
    print()


# ---------- matriz completa ----------
def carregar_culturas(pasta: str) -> list:
    decks = []
    for nome in sorted(os.listdir(pasta)):
        caminho = os.path.join(pasta, nome)
        if nome.startswith("_") or not os.path.isdir(caminho):
            continue
        try:
            decks.append(carregar_pasta(caminho))
        except DeckInvalido as e:
            print(f"  (ignorando {nome}: {e})", file=sys.stderr)
    return decks


def rodar_todos(decks: list, n: int, seed: int, bot_nome: str) -> dict:
    nomes = [d.nome for d in decks]
    matriz = {a: {b: None for b in nomes} for a in nomes}
    global_cartas = defaultdict(lambda: None)
    confrontos = []
    for i, (da, db) in enumerate(itertools.combinations(decks, 2)):
        agg = rodar_duelos(da, db, n, seed + i, bot_nome)
        res = agg.resumo()
        confrontos.append(res)
        matriz[da.nome][db.nome] = res["taxa_a"] + res["taxa_empate"] / 2
        matriz[db.nome][da.nome] = res["taxa_b"] + res["taxa_empate"] / 2
        for c in res["cartas"]:
            chave = (c["deck"], c["id"])
            g = global_cartas[chave]
            if g is None:
                global_cartas[chave] = dict(c)
            else:
                for k in ("jogadas", "partidas_jogada", "vitorias_jogada", "dano_total", "compradas", "ficou_na_mao",
                          "partidas_comprada", "vitorias_comprada"):
                    g[k] += c[k]
    cartas = []
    for g in global_cartas.values():
        cartas.append(Agregador._carta_dict(g))
    media = {a: sum(v for v in matriz[a].values() if v is not None) / max(1, len(nomes) - 1) for a in nomes}
    return {"decks": nomes, "matriz": matriz, "media_por_deck": media, "confrontos": confrontos, "cartas": cartas}


# ---------- main ----------
def main(argv=None):
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("pastas", nargs="*", help="pastaA pastaB")
    p.add_argument("--todos", metavar="PASTA_CARTAS", help="matriz completa entre todas as culturas")
    p.add_argument("--n", type=int, default=1000)
    p.add_argument("--seed", type=int, default=1)
    p.add_argument("--bot", choices=sorted(BOTS), default="heur")
    p.add_argument("--json", metavar="ARQUIVO")
    p.add_argument("--log", action="store_true", help="imprime o log do primeiro duelo")
    args = p.parse_args(argv)

    t0 = time.time()
    if args.todos:
        decks = carregar_culturas(args.todos)
        if len(decks) < 2:
            print("Menos de duas culturas válidas; nada a comparar.")
            return 1
        saida = rodar_todos(decks, args.n, args.seed, args.bot)
        imprimir_matriz(saida["decks"], saida["matriz"])
        print("== Média por deck ==")
        for nome, m in sorted(saida["media_por_deck"].items(), key=lambda kv: -kv[1]):
            print(f"  {pct(m)}  {nome}")
        print()
        imprimir_ranking(saida["cartas"])
    else:
        if len(args.pastas) != 2:
            p.error("informe pastaA e pastaB (ou --todos)")
        deck_a, deck_b = carregar_pasta(args.pastas[0]), carregar_pasta(args.pastas[1])
        agg = rodar_duelos(deck_a, deck_b, args.n, args.seed, args.bot, log_primeiro=args.log)
        saida = agg.resumo()
        imprimir_resumo(saida)
    dt = time.time() - t0
    print(f"({dt:.1f}s, bot={args.bot}, seed={args.seed})")
    saida["meta"] = {"n": args.n, "seed": args.seed, "bot": args.bot, "segundos": round(dt, 2)}
    if args.json:
        with open(args.json, "w", encoding="utf-8") as f:
            json.dump(saida, f, ensure_ascii=False, indent=1)
        print(f"JSON em {args.json}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
