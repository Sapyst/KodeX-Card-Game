"""Bots: um heurístico (HeurBot) e um aleatório (RandomBot) para comparação.

Cada bot expõe uma função por ponto de decisão do motor:
mulligan, escolher_acao, escolher_alvo, escolher_busca, escolher_sacrificio, escolher_descarte.
"""
from __future__ import annotations

from cards import Card
from engine import Acao, Cornucopia, Entidade, Jogo, Jogador


class BotBase:
    nome = "base"

    def mulligan(self, jogo: Jogo, j: Jogador, mao: list) -> list:
        return []

    def escolher_acao(self, jogo: Jogo, j: Jogador):
        raise NotImplementedError

    def escolher_alvo(self, jogo: Jogo, j: Jogador, candidatos: list, acao: dict, ctx: dict):
        return candidatos[0]

    def escolher_busca(self, jogo: Jogo, j: Jogador, candidatos: list) -> Card:
        return candidatos[0]

    def escolher_sacrificio(self, jogo: Jogo, j: Jogador, candidatos: list, n: int) -> list:
        return candidatos[:n]

    def escolher_descarte(self, jogo: Jogo, j: Jogador, mao: list, n: int) -> list:
        return mao[:n]


class PassivoBot(BotBase):
    """Nunca age. Útil em testes, onde o teste comanda o motor diretamente."""
    nome = "passivo"

    def escolher_acao(self, jogo, j):
        return None


class RandomBot(BotBase):
    nome = "random"

    def mulligan(self, jogo, j, mao):
        return [c for c in mao if jogo.rng.random() < 0.3][:2]

    def escolher_acao(self, jogo, j):
        acoes = jogo.acoes_legais(j)
        if not acoes:
            return None
        i = jogo.rng.randrange(len(acoes) + 1)
        return None if i == len(acoes) else acoes[i]

    def escolher_alvo(self, jogo, j, candidatos, acao, ctx):
        return jogo.rng.choice(candidatos)

    def escolher_busca(self, jogo, j, candidatos):
        return jogo.rng.choice(candidatos)

    def escolher_sacrificio(self, jogo, j, candidatos, n):
        return jogo.rng.sample(candidatos, n)

    def escolher_descarte(self, jogo, j, mao, n):
        return jogo.rng.sample(mao, n)


def valor(e: Entidade) -> float:
    return e.atk + e.vida + len(e.keywords) + len(e.efeitos) + (2 if e.reliquia else 0)


def pode_atacar_ainda(e: Entidade) -> bool:
    return e.pode_atacar()


class HeurBot(BotBase):
    """Joga a curva de Fé, prefere trocas favoráveis e vai à Cornucópia quando o campo inimigo está vazio."""
    nome = "heur"
    LIMIAR_RITO = 1.5

    # ----- mulligan -----
    def mulligan(self, jogo, j, mao):
        caras = sorted((c for c in mao if c.custo >= 4), key=lambda c: -c.custo)
        return caras[:2]

    # ----- ação -----
    def escolher_acao(self, jogo, j):
        acoes = jogo.acoes_legais(j)
        if not acoes:
            return None
        ataques = [a for a in acoes if a.tipo == "atacar"]
        jogadas = [a for a in acoes if a.tipo == "jogar"]
        letal = self._ataque_letal(jogo, j, ataques)
        if letal is not None:
            return letal
        melhor = self._melhor_jogada(jogo, j, jogadas)
        if melhor is not None:
            return melhor
        return self._melhor_ataque(jogo, j, ataques)

    def _ataque_letal(self, jogo, j, ataques):
        ini = jogo.oponente(j)
        if ini.campo or not ataques:
            return None
        total = sum(e.atk for e in j.campo if e.pode_atacar())
        return ataques[0] if total >= ini.cornucopia else None

    # ----- jogar cartas -----
    def _melhor_jogada(self, jogo, j, jogadas):
        melhor, melhor_pontos = None, 0.0
        for a in jogadas:
            pontos = self._pontuar_jogada(jogo, j, a)
            if pontos > melhor_pontos or (pontos == melhor_pontos and melhor is not None
                                           and a.carta.custo > melhor.carta.custo):
                melhor, melhor_pontos = a, pontos
        return melhor

    def _pontuar_jogada(self, jogo, j, a: Acao) -> float:
        c = a.carta
        if c.tipo == "entidade":
            base = 2 + c.custo + len(c.keywords) * 0.5
            if c.sacrificio:
                sacrificados = sorted(j.campo, key=valor)[:c.sacrificio]
                base -= sum(valor(e) for e in sacrificados) * 0.5
            return base
        if c.tipo == "selo":
            return 1.5 + c.custo * 0.5
        if c.tipo == "reliquia":
            portadora = a.alvo
            return 1.5 + c.custo * 0.5 + portadora.atk * 0.3 + (1.5 if portadora.pode_atacar() else 0)
        return self._utilidade_rito(jogo, j, c)

    def _utilidade_rito(self, jogo, j, c: Card) -> float:
        ini = jogo.oponente(j)
        total = 0.0
        for ef in c.efeitos:
            ctx = {"dono": j.idx, "triggering": c}
            if not jogo._cond_ok(ef.cond, ctx):
                return 0.0
            for a in ef.acoes:
                total += self._utilidade_acao(jogo, j, ini, a)
        return total if total >= self.LIMIAR_RITO else 0.0

    def _utilidade_acao(self, jogo, j, ini, a: dict) -> float:
        op, alvo = a["op"], a.get("alvo", "")
        inimigos = [e for e in ini.campo if not e.protegida] if alvo in ("enemy_entity", "enemy_entity_random") \
            else list(ini.campo)
        n = int(a.get("n", 0) or 0)
        if op == "damage":
            if alvo == "enemy_cornucopia":
                return 2.0 + (10 if ini.cornucopia <= n else 0)
            if alvo == "all_enemy_entities":
                return sum(1.5 if e.vida <= n else 0.7 for e in ini.campo)
            if alvo == "all_entities":
                return sum(1.5 if e.vida <= n else 0.7 for e in ini.campo) - sum(1.0 if e.vida <= n else 0.3 for e in j.campo)
            if inimigos:
                return 3.0 if any(e.vida <= n for e in inimigos) else 1.0
            return 0.0
        if op == "heal":
            if alvo == "ally_cornucopia":
                return 1.0 if j.cornucopia <= 15 - n else 0.0
            return 1.5 if any(e.dano > 0 for e in j.campo) else 0.0
        if op == "draw":
            return 1.5 * n
        if op == "search":
            return 2.0 if any(self._casa_busca(c, a) for c in j.deck) else 0.0
        if op == "buff":
            if alvo.startswith("enemy") or alvo == "all_enemy_entities":
                return 2.0 if inimigos else 0.0
            if not j.campo:
                return 0.0
            atk, vida = int(a.get("atk", 0) or 0), int(a.get("vida", 0) or 0)
            prontos = any(e.pode_atacar() for e in j.campo)
            return (2.0 if (prontos or a.get("perm", True)) else 0.5) + 0.3 * (atk + vida)
        if op in ("destroy", "bounce", "freeze", "silence", "swap_control", "set_stats"):
            if not inimigos and alvo.startswith("enemy"):
                return 0.0
            if op == "swap_control":
                if not j.tem_slot_entidade:
                    return 0.0
                if not a.get("perm", True) and not any(e.tem("impeto") for e in inimigos):
                    return 0.5
            return {"destroy": 4.0, "swap_control": 4.0, "bounce": 2.0, "freeze": 1.5, "silence": 1.5, "set_stats": 2.0}[op]
        if op == "summon":
            return 2.0 if j.tem_slot_entidade else 0.0
        if op == "revive":
            return 3.0 if j.entidades_cemiterio() else 0.0
        if op == "discard":
            return 2.0 if ini.mao else 0.0
        if op == "gain_fe":
            return 1.5 if any(c.custo <= j.fe + n for c in j.mao if c.tipo != "rito") else 0.5
        if op == "give_keyword":
            return 1.5 if j.campo else 0.0
        if op == "copy_stats":
            return 1.0
        if op in ("win", "ritual_choronzon"):
            return 20.0
        return 1.0

    @staticmethod
    def _casa_busca(c: Card, a: dict) -> bool:
        return ((a.get("tipo") is None or c.tipo == a["tipo"])
                and (a.get("custo_max") is None or c.custo <= a["custo_max"])
                and (a.get("keyword") is None or a["keyword"] in c.keywords))

    # ----- ataques -----
    def _melhor_ataque(self, jogo, j, ataques):
        melhor, melhor_pontos = None, 0.0
        for a in ataques:
            pontos = self._pontuar_ataque(a.atacante, a.alvo)
            if pontos > melhor_pontos:
                melhor, melhor_pontos = a, pontos
        return melhor

    @staticmethod
    def _pontuar_ataque(atacante: Entidade, alvo) -> float:
        if atacante.atk <= 0 and not atacante.efeitos:
            return 0.0
        if isinstance(alvo, Cornucopia):
            return 10.0 + atacante.atk
        mata = atacante.atk >= alvo.vida
        morre = alvo.atk >= atacante.vida
        if mata and not morre:
            return 8.0 + valor(alvo)
        if mata and morre:
            diff = valor(alvo) - valor(atacante)
            return 2.0 + diff if diff >= 0 else 0.0
        if not morre:
            return 1.0 + atacante.atk * 0.5 if atacante.atk > 0 else 0.0
        return 0.0

    # ----- alvos -----
    def escolher_alvo(self, jogo, j, candidatos, acao, ctx):
        op, alvo = acao["op"], acao.get("alvo", "")
        if isinstance(candidatos[0], Card):
            return max(candidatos, key=lambda c: c.custo)
        if alvo.startswith("enemy"):
            if op == "damage":
                n = int(acao.get("n", 0) or 0)
                mataveis = [e for e in candidatos if e.vida <= n]
                return max(mataveis, key=valor) if mataveis else max(candidatos, key=lambda e: e.atk)
            return max(candidatos, key=valor)
        if op == "heal":
            return max(candidatos, key=lambda e: min(e.dano, int(acao.get("n", 0) or 0)))
        if op in ("buff", "give_keyword"):
            atk = int(acao.get("atk", 0) or 0) if op == "buff" else 0
            if atk < 0 or (op == "buff" and int(acao.get("vida", 0) or 0) < 0):
                return min(candidatos, key=valor)
            prontos = [e for e in candidatos if e.pode_atacar()]
            pool = prontos or candidatos
            return max(pool, key=lambda e: e.atk)
        if op in ("damage", "destroy", "freeze", "silence", "bounce"):
            return min(candidatos, key=valor)
        return max(candidatos, key=valor)

    def escolher_busca(self, jogo, j, candidatos):
        jogaveis = [c for c in candidatos if c.custo <= j.fe_max + 1]
        if jogaveis:
            return max(jogaveis, key=lambda c: c.custo)
        return min(candidatos, key=lambda c: c.custo)

    def escolher_sacrificio(self, jogo, j, candidatos, n):
        return sorted(candidatos, key=valor)[:n]

    def escolher_descarte(self, jogo, j, mao, n):
        return sorted(mao, key=lambda c: -c.custo)[:n]


BOTS = {"heur": HeurBot, "random": RandomBot}
