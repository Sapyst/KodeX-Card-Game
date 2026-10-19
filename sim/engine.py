"""Motor de duelos Gods Kodex: estado de jogo, regras de regras.md e DSL de dsl_efeitos.md."""
from __future__ import annotations

import random
from collections import Counter
from dataclasses import dataclass
from typing import Optional

from cards import Card, Deck

CORNUCOPIA_INICIAL = 15
MAO_INICIAL = 4
MAO_MAX = 7
FE_MAX = 8
SLOTS_ENTIDADE = 4
SLOTS_SELO = 2
MAX_RODADAS = 40
DANO_FADIGA = 2
CUSTO_REEMBARALHAR = 5        # deck vazio: paga 5 de Cornucópia (só com 6+) e o cemitério volta ao deck
MAX_ACOES_POR_TURNO = 60
MULLIGAN_MAX = 2

CHORONZON = {"entidade": "aby_choronzon", "reliquia": "aby_triangulo", "selo": "aby_circulo"}
GATILHOS_SELO_JOGADA = {"entidade": "enemy_plays_entity", "rito": "enemy_plays_rite", "reliquia": "enemy_plays_reliquia"}


class FimDeJogo(Exception):
    pass


class AcaoIlegal(Exception):
    pass


class Cornucopia:
    __slots__ = ("idx",)

    def __init__(self, idx: int):
        self.idx = idx

    def __repr__(self):
        return f"Cornucopia({self.idx})"


class Entidade:
    __slots__ = ("carta", "dono", "controlador", "uid", "token", "origem_id", "atk_base", "vida_base",
                 "buff_atk", "buff_vida", "temp_atk", "temp_vida", "aura_atk", "aura_vida", "rel_atk", "rel_vida", "dano",
                 "keywords", "aura_keywords", "efeitos", "cansada", "atacou", "ja_atacou", "congelada",
                 "sem_ataque_neste_turno", "reliquia", "em_campo", "silenciada", "roubada_temp")

    def __init__(self, carta: Card, dono: int, uid: int, token: bool = False, origem_id: Optional[str] = None):
        self.carta = carta
        self.dono = dono
        self.controlador = dono
        self.uid = uid
        self.token = token
        self.origem_id = origem_id or carta.id
        self.atk_base = carta.atk
        self.vida_base = carta.vida
        self.buff_atk = self.buff_vida = 0
        self.temp_atk = self.temp_vida = 0
        self.aura_atk = self.aura_vida = 0
        self.rel_atk = self.rel_vida = 0
        self.dano = 0
        self.keywords = set(carta.keywords)
        self.aura_keywords = set()
        self.efeitos = list(carta.efeitos)
        self.cansada = True
        self.atacou = False
        self.ja_atacou = False
        self.congelada = False
        self.sem_ataque_neste_turno = False
        self.reliquia: Optional[Reliquia] = None
        self.em_campo = True
        self.silenciada = False
        self.roubada_temp = False

    @property
    def atk(self) -> int:
        return max(0, self.atk_base + self.buff_atk + self.temp_atk + self.aura_atk + self.rel_atk)

    @property
    def vida_max(self) -> int:
        return self.vida_base + self.buff_vida + self.temp_vida + self.aura_vida + self.rel_vida

    @property
    def vida(self) -> int:
        return self.vida_max - self.dano

    def tem(self, kw: str) -> bool:
        return kw in self.keywords or kw in self.aura_keywords

    @property
    def protegida(self) -> bool:
        """Furtivo: não pode ser alvo de efeitos inimigos até atacar."""
        return self.tem("furtivo") and not self.ja_atacou

    def pode_atacar(self) -> bool:
        return (self.em_campo and not self.atacou and not self.sem_ataque_neste_turno
                and (not self.cansada or self.tem("impeto")))

    def limpar_stats(self):
        self.buff_atk = self.buff_vida = self.temp_atk = self.temp_vida = self.rel_atk = self.rel_vida = 0
        self.dano = 0

    def __repr__(self):
        return f"<{self.carta.nome} {self.atk}/{self.vida} j{self.controlador}>"


class Selo:
    __slots__ = ("carta", "dono", "turno_posto")

    def __init__(self, carta: Card, dono: int, turno_posto: int):
        self.carta = carta
        self.dono = dono
        self.turno_posto = turno_posto

    @property
    def efeito(self):
        return self.carta.efeitos[0]

    def __repr__(self):
        return f"<Selo {self.carta.nome}>"


class Reliquia:
    __slots__ = ("carta", "dono", "portadora", "usos")

    def __init__(self, carta: Card, dono: int, portadora: Entidade):
        self.carta = carta
        self.dono = dono
        self.portadora = portadora
        self.usos = carta.usos

    def __repr__(self):
        return f"<Reliquia {self.carta.nome}>"


class Jogador:
    def __init__(self, idx: int, deck: Deck):
        self.idx = idx
        self.nome = deck.nome
        self.deck = list(deck.cartas)
        self.mao: list = []
        self.campo: list = []
        self.selos: list = []
        self.cemiterio: list = []
        self.cornucopia = CORNUCOPIA_INICIAL
        self.fe_max = 0
        self.fe = 0
        self.selo_neste_turno = False
        self.fadiga = 0
        self.jogadas: list = []
        self.compradas: Counter = Counter()
        self.dano_por_carta: Counter = Counter()

    @property
    def tem_slot_entidade(self) -> bool:
        return len(self.campo) < SLOTS_ENTIDADE

    def entidades_cemiterio(self) -> list:
        return [c for c in self.cemiterio if c.eh_entidade]


@dataclass
class Acao:
    tipo: str  # 'jogar' | 'atacar'
    carta: Optional[Card] = None
    atacante: Optional[Entidade] = None
    alvo: object = None

    def __repr__(self):
        if self.tipo == "jogar":
            return f"jogar({self.carta.nome}{' -> ' + repr(self.alvo) if self.alvo is not None else ''})"
        return f"atacar({self.atacante!r} -> {self.alvo!r})"


class Jogo:
    def __init__(self, deck_a: Deck, deck_b: Deck, bots, seed: int = 0, primeiro: int = 0,
                 max_rodadas: int = MAX_RODADAS, log: bool = False):
        self.rng = random.Random(seed)
        self.jogadores = [Jogador(0, deck_a), Jogador(1, deck_b)]
        self.cornucopias = [Cornucopia(0), Cornucopia(1)]
        self.bots = list(bots)
        self.primeiro = primeiro
        self.ativo = primeiro
        self.rodada = 0
        self.turno_global = 0
        self.vencedor: Optional[int] = None  # 0, 1 ou None (empate quando acabou)
        self.acabou = False
        self.max_rodadas = max_rodadas
        self.log: Optional[list] = [] if log else None
        self._uid = 0
        self._prof_dano = 0

    # ---------- utilidades ----------
    def oponente(self, j) -> Jogador:
        idx = j if isinstance(j, int) else j.idx
        return self.jogadores[1 - idx]

    def _log(self, msg: str):
        if self.log is not None:
            self.log.append(f"[r{self.rodada} t{self.turno_global} j{self.ativo}] {msg}")

    def _novo_uid(self) -> int:
        self._uid += 1
        return self._uid

    # ---------- fluxo da partida ----------
    def jogar(self) -> Optional[int]:
        try:
            self.preparar()
            while not self.acabou:
                for idx in (self.primeiro, 1 - self.primeiro):
                    if idx == self.primeiro:
                        self.rodada += 1
                        if self.rodada > self.max_rodadas:
                            self._encerrar(None, "limite de rodadas")
                    self.turno(self.jogadores[idx])
        except FimDeJogo:
            pass
        return self.vencedor

    def preparar(self):
        for j in self.jogadores:
            self.rng.shuffle(j.deck)
            self.comprar(j, MAO_INICIAL)
        for idx in (self.primeiro, 1 - self.primeiro):
            self._mulligan(self.jogadores[idx])

    def _mulligan(self, j: Jogador):
        troca = [c for c in self.bots[j.idx].mulligan(self, j, list(j.mao)) if c in j.mao][:MULLIGAN_MAX]
        if not troca:
            return
        for c in troca:
            j.mao.remove(c)
        self.comprar(j, len(troca))
        j.deck.extend(troca)
        self.rng.shuffle(j.deck)
        self._log(f"mulligan j{j.idx}: {[c.nome for c in troca]}")

    def turno(self, j: Jogador):
        self.iniciar_turno(j)
        self.fase_acoes(j)
        self.encerrar_turno(j)

    def iniciar_turno(self, j: Jogador):
        self.ativo = j.idx
        self.turno_global += 1
        j.fe_max = min(FE_MAX, j.fe_max + 1)
        j.fe = j.fe_max
        if self.turno_global == 2:
            j.fe += 1
        j.selo_neste_turno = False
        for e in j.campo:
            e.cansada = False
            e.atacou = False
            e.sem_ataque_neste_turno = e.congelada
            e.congelada = False
        if self.turno_global > 1:
            self.comprar(j, 1)
        self.recalcular_auras()
        self._disparar_entidades("start_turn", j.idx, {})
        self._checar_fim()

    def fase_acoes(self, j: Jogador):
        bot = self.bots[j.idx]
        for _ in range(MAX_ACOES_POR_TURNO):
            acao = bot.escolher_acao(self, j)
            if acao is None:
                break
            self.executar(j, acao)

    def encerrar_turno(self, j: Jogador):
        self._disparar_entidades("end_turn", j.idx, {})
        self._disparar_selos("enemy_end_turn", 1 - j.idx, {})
        self._expirar_temporarios()
        self._descartar_excesso(j)
        self._checar_fim()

    def _expirar_temporarios(self):
        for jog in self.jogadores:
            for e in list(jog.campo):
                e.temp_atk = e.temp_vida = 0
                if e.roubada_temp:
                    self._devolver_controle(e)
        self.recalcular_auras()
        self._processar_mortes()

    def _devolver_controle(self, e: Entidade):
        e.roubada_temp = False
        atual = self.jogadores[e.controlador]
        original = self.jogadores[e.dono]
        atual.campo.remove(e)
        if original.tem_slot_entidade:
            e.controlador = e.dono
            original.campo.append(e)
            e.cansada = True
        else:
            e.controlador = e.dono
            original.campo.append(e)
            self._morrer(e)

    def _descartar_excesso(self, j: Jogador):
        excesso = len(j.mao) - MAO_MAX
        if excesso <= 0:
            return
        escolha = [c for c in self.bots[j.idx].escolher_descarte(self, j, list(j.mao), excesso) if c in j.mao]
        while len(escolha) < excesso:
            escolha.append(next(c for c in j.mao if c not in escolha))
        for c in escolha[:excesso]:
            j.mao.remove(c)
            j.cemiterio.append(c)

    # ---------- compra / fim ----------
    def comprar(self, j: Jogador, n: int = 1):
        for _ in range(n):
            if not j.deck and j.cornucopia >= CUSTO_REEMBARALHAR + 1 and j.cemiterio:
                j.cornucopia -= CUSTO_REEMBARALHAR
                j.deck = list(j.cemiterio)
                j.cemiterio.clear()
                self.rng.shuffle(j.deck)
                self._log(f"reembaralhou j{j.idx}")
            if not j.deck:
                j.fadiga += 1
                self._dano_cornucopia(j.idx, DANO_FADIGA, None)
                self._log(f"fadiga j{j.idx}")
                continue
            c = j.deck.pop()
            if len(j.mao) >= MAO_MAX:
                j.cemiterio.append(c)
            else:
                self._para_mao(j, c)

    def _para_mao(self, j: Jogador, c: Card):
        j.mao.append(c)
        j.compradas[c.id] += 1

    def _checar_fim(self):
        if self.acabou:
            raise FimDeJogo()
        mortos = [j.idx for j in self.jogadores if j.cornucopia <= 0]
        if len(mortos) == 2:
            self._encerrar(None, "ambas as Cornucópias a zero")
        elif mortos:
            self._encerrar(1 - mortos[0], "Cornucópia a zero")

    def _encerrar(self, vencedor: Optional[int], motivo: str):
        self.acabou = True
        self.vencedor = vencedor
        self._log(f"FIM: {'empate' if vencedor is None else 'vence j%d' % vencedor} ({motivo})")
        raise FimDeJogo()

    # ---------- ações legais ----------
    def pode_jogar(self, j: Jogador, c: Card) -> bool:
        if c.custo > j.fe:
            return False
        if c.tipo == "entidade":
            return len(j.campo) >= c.sacrificio and len(j.campo) - c.sacrificio < SLOTS_ENTIDADE
        if c.tipo == "selo":
            return not j.selo_neste_turno and len(j.selos) < SLOTS_SELO
        if c.tipo == "reliquia":
            return any(e.reliquia is None for e in j.campo)
        return True

    def alvos_de_ataque(self, atacante: Entidade) -> list:
        ini = self.jogadores[1 - atacante.controlador]
        if not ini.campo:
            return [self.cornucopias[ini.idx]]
        guardas = [e for e in ini.campo if e.tem("guarda")]
        return guardas or list(ini.campo)

    def acoes_legais(self, j: Jogador) -> list:
        acoes = []
        vistos = set()
        for c in j.mao:
            if c.id in vistos or not self.pode_jogar(j, c):
                continue
            vistos.add(c.id)
            if c.tipo == "reliquia":
                acoes.extend(Acao("jogar", carta=c, alvo=e) for e in j.campo if e.reliquia is None)
            else:
                acoes.append(Acao("jogar", carta=c))
        for e in j.campo:
            if e.pode_atacar():
                acoes.extend(Acao("atacar", atacante=e, alvo=t) for t in self.alvos_de_ataque(e))
        return acoes

    def executar(self, j: Jogador, acao: Acao):
        if j.idx != self.ativo:
            raise AcaoIlegal("não é o turno deste jogador")
        if acao.tipo == "jogar":
            self.jogar_carta(j, acao.carta, acao.alvo)
        elif acao.tipo == "atacar":
            self.atacar(acao.atacante, acao.alvo)
        else:
            raise AcaoIlegal(acao.tipo)
        self._checar_fim()

    # ---------- jogar cartas ----------
    def jogar_carta(self, j: Jogador, c: Card, alvo=None):
        if c not in j.mao or not self.pode_jogar(j, c):
            raise AcaoIlegal(f"não pode jogar {c.nome}")
        j.fe -= c.custo
        j.mao.remove(c)
        j.jogadas.append(c.id)
        self._log(f"j{j.idx} joga {c.nome}")
        if c.tipo == "entidade":
            self._jogar_entidade(j, c)
        elif c.tipo == "rito":
            self._jogar_rito(j, c)
        elif c.tipo == "reliquia":
            self._jogar_reliquia(j, c, alvo)
        else:
            j.selos.append(Selo(c, j.idx, self.turno_global))
            j.selo_neste_turno = True

    def _jogar_entidade(self, j: Jogador, c: Card):
        if c.sacrificio:
            cands = list(j.campo)
            escolha = [e for e in self.bots[j.idx].escolher_sacrificio(self, j, cands, c.sacrificio) if e in cands]
            escolha = (escolha + [e for e in cands if e not in escolha])[:c.sacrificio]
            for e in escolha:
                self._morrer(e, renascer=False)
            self._processar_mortes()
        ent = self._criar_entidade(j, c)
        ctx = {"triggering": ent, "attacker": None}
        self._disparar_selos("enemy_plays_entity", 1 - j.idx, ctx)
        if ctx.get("anulado"):
            self._remover_do_campo(ent)
            j.cemiterio.append(c)
            self.recalcular_auras()
            return
        self._processar_mortes()
        if ent.em_campo:
            self._disparar_efeitos_entidade(ent, "on_play", {"triggering": ent})
            self._processar_mortes()

    def _criar_entidade(self, j: Jogador, c: Card, token: bool = False, origem_id: Optional[str] = None) -> Entidade:
        ent = Entidade(c, j.idx, self._novo_uid(), token=token, origem_id=origem_id)
        j.campo.append(ent)
        self.recalcular_auras()
        return ent

    def _jogar_rito(self, j: Jogador, c: Card):
        ctx = {"triggering": c, "attacker": None, "dono": j.idx, "fonte": c, "self": None}
        self._disparar_selos("enemy_plays_rite", 1 - j.idx, ctx)
        if not ctx.get("anulado"):
            for ef in c.efeitos:
                if self._cond_ok(ef.cond, ctx):
                    self._executar_acoes(ef.acoes, ctx)
        j.cemiterio.append(c)
        self._processar_mortes()

    def _jogar_reliquia(self, j: Jogador, c: Card, portadora):
        if not isinstance(portadora, Entidade) or portadora.controlador != j.idx or portadora.reliquia is not None \
                or not portadora.em_campo:
            raise AcaoIlegal("relíquia precisa de portadora aliada sem relíquia")
        rel = Reliquia(c, j.idx, portadora)
        portadora.reliquia = rel
        ctx = {"triggering": rel, "attacker": None, "equipped": portadora}
        self._disparar_selos("enemy_plays_reliquia", 1 - j.idx, ctx)
        if ctx.get("anulado"):
            self._remover_reliquia(rel)
            return
        self._processar_mortes()
        if portadora.reliquia is rel and portadora.em_campo:
            self._disparar_efeitos_reliquia(rel, "on_equip", {"triggering": rel})
            self.recalcular_auras()
            self._processar_mortes()

    # ---------- combate ----------
    def atacar(self, atacante: Entidade, alvo):
        if atacante.controlador != self.ativo or not atacante.pode_atacar():
            raise AcaoIlegal("entidade não pode atacar")
        if alvo not in self.alvos_de_ataque(atacante):
            raise AcaoIlegal("alvo de ataque ilegal")
        atacante.atacou = True
        atacante.ja_atacou = True
        ini = 1 - atacante.controlador
        ctx = {"attacker": atacante, "triggering": alvo, "defender": alvo if isinstance(alvo, Entidade) else None}
        self._log(f"{atacante!r} ataca {alvo!r}")
        self._disparar_efeitos_entidade(atacante, "on_attack", ctx)
        if atacante.reliquia:
            self._disparar_efeitos_reliquia(atacante.reliquia, "equipped_attacks", ctx)
        if isinstance(alvo, Cornucopia):
            self._disparar_selos("enemy_attacks_cornucopia", ini, ctx)
        else:
            self._disparar_selos("enemy_attacks", ini, ctx)
            self._disparar_entidades("ally_attacked", ini, ctx, excluir=alvo)
        self._processar_mortes()
        if not atacante.em_campo:
            return
        if isinstance(alvo, Cornucopia):
            self._dano_cornucopia(alvo.idx, atacante.atk, atacante)
        elif alvo.em_campo:
            da, dd = atacante.atk, alvo.atk
            alvo.dano += da
            atacante.dano += dd
            self._creditar_dano(atacante, da)
            self._creditar_dano(alvo, dd)
            self._pos_dano(alvo, da, atacante, atacante)
            # o contragolpe do defensor não tem "atacante": a Entidade que ataca não se fere a si mesma
            self._pos_dano(atacante, dd, alvo, None)
        self._processar_mortes()

    # ---------- dano e morte ----------
    def _creditar_dano(self, fonte, n: int):
        if n <= 0 or fonte is None:
            return
        if isinstance(fonte, Entidade):
            self.jogadores[fonte.controlador].dano_por_carta[fonte.origem_id] += n
        elif isinstance(fonte, (Selo, Reliquia)):
            self.jogadores[fonte.dono].dano_por_carta[fonte.carta.id] += n
        elif isinstance(fonte, Card):
            self.jogadores[self.ativo].dano_por_carta[fonte.id] += n

    def _dano_entidade(self, e: Entidade, n: int, fonte, atacante=None):
        if n <= 0 or not e.em_campo:
            return
        e.dano += n
        self._creditar_dano(fonte, n)
        self._pos_dano(e, n, fonte, atacante)

    def _pos_dano(self, e: Entidade, n: int, fonte, atacante):
        if n <= 0 or self._prof_dano >= 8:
            return
        self._prof_dano += 1
        try:
            self._pos_dano_inner(e, n, fonte, atacante)
        finally:
            self._prof_dano -= 1

    def _pos_dano_inner(self, e: Entidade, n: int, fonte, atacante):
        fonte_ent = fonte if isinstance(fonte, Entidade) else None
        ctx = {"triggering": fonte_ent, "attacker": atacante}
        self._disparar_efeitos_entidade(e, "on_damaged", ctx)
        self._disparar_selos("ally_damaged", e.controlador, {"triggering": e, "attacker": atacante, "defender": e})

    def _dano_cornucopia(self, idx: int, n: int, fonte):
        if n <= 0:
            return
        self.jogadores[idx].cornucopia -= n
        self._creditar_dano(fonte, n)
        self._log(f"cornucópia j{idx} -{n} = {self.jogadores[idx].cornucopia}")

    def _processar_mortes(self):
        for _ in range(50):
            mortos = [e for idx in (self.ativo, 1 - self.ativo) for e in self.jogadores[idx].campo if e.vida <= 0]
            if not mortos:
                return
            for e in mortos:
                if e.em_campo:
                    self._morrer(e)

    def _remover_do_campo(self, e: Entidade):
        self.jogadores[e.controlador].campo.remove(e)
        e.em_campo = False

    def _morrer(self, e: Entidade, renascer: bool = True):
        if not e.em_campo:
            return
        self._log(f"morre {e!r}")
        self._remover_do_campo(e)
        self.recalcular_auras()
        if not e.token:
            dono = self.jogadores[e.dono]
            if renascer and "renascer" in e.keywords:
                self._para_mao(dono, e.carta.sem_renascer())
                self._log(f"renasce {e.carta.nome} para a mão de j{e.dono}")
            else:
                dono.cemiterio.append(e.carta)
        rel = e.reliquia
        if rel is not None:
            self._disparar_efeitos_reliquia(rel, "equipped_dies", {"triggering": e})
            self._remover_reliquia(rel)
        if not e.silenciada:
            self._disparar_efeitos_entidade(e, "on_death", {"triggering": e}, exige_campo=False)
        ctx = {"triggering": e, "attacker": None}
        self._disparar_entidades("ally_dies", e.controlador, ctx)
        self._disparar_selos("ally_dies", e.controlador, ctx)
        self._disparar_entidades("enemy_dies", 1 - e.controlador, ctx)

    def _remover_reliquia(self, rel: Reliquia):
        port = rel.portadora
        if port.reliquia is rel:
            port.reliquia = None
            port.rel_atk = port.rel_vida = 0
        self.jogadores[rel.dono].cemiterio.append(rel.carta)
        self.recalcular_auras()

    # ---------- auras ----------
    def recalcular_auras(self):
        for j in self.jogadores:
            for e in j.campo:
                e.aura_atk = e.aura_vida = 0
                e.aura_keywords = set()
        for j in self.jogadores:
            for e in list(j.campo):
                fontes = [ef for ef in e.efeitos if ef.gatilho == "static"]
                if e.reliquia is not None:
                    fontes += [ef for ef in e.reliquia.carta.efeitos if ef.gatilho == "static"]
                for ef in fontes:
                    self._aplicar_aura(ef, e)

    def _aplicar_aura(self, ef, fonte: Entidade):
        ctx = {"dono": fonte.controlador, "self": fonte, "triggering": fonte}
        if not self._cond_ok(ef.cond, ctx):
            return
        eu = self.jogadores[fonte.controlador]
        ini = self.jogadores[1 - fonte.controlador]
        for a in ef.acoes:
            alvo = a.get("alvo", "")
            if alvo == "all_ally_entities":
                alvos = eu.campo
            elif alvo == "other_ally_entities":
                alvos = [t for t in eu.campo if t is not fonte]
            elif alvo == "all_enemy_entities":
                alvos = ini.campo
            elif alvo == "all_entities":
                alvos = eu.campo + ini.campo
            else:
                continue
            for t in alvos:
                if a["op"] == "buff":
                    t.aura_atk += a.get("atk", 0) or 0
                    t.aura_vida += a.get("vida", 0) or 0
                elif a["op"] == "give_keyword":
                    t.aura_keywords.add(a["keyword"])

    # ---------- gatilhos ----------
    def _disparar_entidades(self, gatilho: str, idx: int, ctx_base: dict, excluir=None):
        for e in list(self.jogadores[idx].campo):
            if e is excluir or not e.em_campo:
                continue
            self._disparar_efeitos_entidade(e, gatilho, ctx_base)
        self._processar_mortes()

    def _disparar_efeitos_entidade(self, e: Entidade, gatilho: str, ctx_base: dict, exige_campo: bool = True):
        if e.silenciada:
            return
        for ef in e.efeitos:
            if ef.gatilho != gatilho:
                continue
            if exige_campo and not e.em_campo:
                return
            ctx = dict(ctx_base)
            ctx["self"] = e
            ctx["dono"] = e.controlador
            ctx["fonte"] = e
            ctx.setdefault("triggering", e)
            if self._cond_ok(ef.cond, ctx):
                self._log(f"gatilho {gatilho} de {e!r}")
                self._executar_acoes(ef.acoes, ctx)

    def _disparar_efeitos_reliquia(self, rel: Reliquia, gatilho: str, ctx_base: dict):
        for ef in rel.carta.efeitos:
            if ef.gatilho != gatilho:
                continue
            if rel.portadora.reliquia is not rel:
                return
            ctx = dict(ctx_base)
            ctx["gatilho"] = gatilho
            ctx["self"] = rel.portadora
            ctx["equipped"] = rel.portadora
            ctx["dono"] = rel.portadora.controlador
            ctx["fonte"] = rel
            if self._cond_ok(ef.cond, ctx):
                self._log(f"gatilho {gatilho} de {rel!r}")
                self._executar_acoes(ef.acoes, ctx)
        if gatilho == "equipped_attacks" and rel.usos is not None and rel.portadora.reliquia is rel:
            rel.usos -= 1
            if rel.usos <= 0:
                self._log(f"{rel!r} gasta o último uso")
                self._remover_reliquia(rel)

    def _disparar_selos(self, gatilho: str, idx: int, ctx_base: dict):
        if self.ativo == idx:
            return
        j = self.jogadores[idx]
        for s in list(j.selos):
            if s.efeito.gatilho != gatilho or s.turno_posto == self.turno_global or s not in j.selos:
                continue
            ctx = dict(ctx_base)
            ctx["self"] = None
            ctx["dono"] = idx
            ctx["fonte"] = s
            if not self._cond_ok(s.efeito.cond, ctx):
                continue
            self._log(f"selo {s.carta.nome} dispara ({gatilho})")
            j.selos.remove(s)
            j.cemiterio.append(s.carta)
            self._executar_acoes(s.efeito.acoes, ctx)
            if ctx.get("anulado"):
                ctx_base["anulado"] = True

    # ---------- condições ----------
    def _cond_ok(self, cond: Optional[dict], ctx: dict) -> bool:
        if not cond:
            return True
        dono = ctx["dono"]
        eu, ini = self.jogadores[dono], self.jogadores[1 - dono]
        t, n = cond["tipo"], cond.get("n", 0)
        if t == "ally_count_min":
            return len(eu.campo) >= n
        if t == "ally_count_max":
            return len(eu.campo) <= n
        if t == "enemy_count_min":
            return len(ini.campo) >= n
        if t == "enemy_count_max":
            return len(ini.campo) <= n
        if t == "hand_min":
            return len(eu.mao) >= n
        if t == "hand_max":
            return len(eu.mao) <= n
        if t == "cornucopia_below":
            return eu.cornucopia < n
        if t == "enemy_cornucopia_below":
            return ini.cornucopia < n
        if t == "graveyard_entities_min":
            return len(eu.entidades_cemiterio()) >= n
        if t == "fe_max_min":
            return eu.fe_max >= n
        if t == "target_cost_max":
            trig = ctx.get("triggering")
            if trig is None or trig is ctx.get("self"):
                # on_play/Rito: a condição restringe os alvos escolhíveis, não a própria carta
                ctx["_cost_max"] = n
                return True
            custo = self._custo_de(trig)
            return custo is not None and custo <= n
        return True

    @staticmethod
    def _custo_de(obj) -> Optional[int]:
        if isinstance(obj, Card):
            return obj.custo
        if isinstance(obj, (Entidade, Selo, Reliquia)):
            return obj.carta.custo
        return None

    # ---------- alvos ----------
    def _alvos(self, alvo: Optional[str], ctx: dict, acao: dict) -> list:
        dono = ctx["dono"]
        eu, ini = self.jogadores[dono], self.jogadores[1 - dono]
        if alvo == "self":
            e = ctx.get("self")
            return [e] if e is not None else []
        if alvo in ("attacker", "defender"):
            e = ctx.get(alvo)
            return [e] if e is not None else []
        if alvo == "triggering":
            t = ctx.get("triggering")
            if isinstance(t, Entidade) and t.controlador != dono and t.protegida:
                return []  # Furtivo também escapa de Selos/efeitos inimigos que o apontam como gatilho
            return [t] if t is not None else []
        if alvo == "equipped":
            e = ctx.get("equipped")
            return [e] if e is not None else []
        cmax = ctx.get("_cost_max")
        def custo_ok(e):
            return cmax is None or (self._custo_de(e) or 0) <= cmax
        if alvo == "enemy_entity":
            return self._escolher(dono, [e for e in ini.campo if not e.protegida and custo_ok(e)], acao, ctx)
        if alvo == "enemy_entity_random":
            return self._aleatorio([e for e in ini.campo if not e.protegida and custo_ok(e)])
        if alvo == "all_enemy_entities":
            return list(ini.campo)
        if alvo == "ally_entity":
            return self._escolher(dono, [e for e in eu.campo if custo_ok(e)], acao, ctx)
        if alvo == "ally_entity_random":
            return self._aleatorio([e for e in eu.campo if custo_ok(e)])
        if alvo == "all_ally_entities":
            return list(eu.campo)
        if alvo == "other_ally_entities":
            return [e for e in eu.campo if e is not ctx.get("self")]
        if alvo == "all_entities":
            return list(eu.campo) + list(ini.campo)
        if alvo == "enemy_cornucopia":
            return [self.cornucopias[ini.idx]]
        if alvo == "ally_cornucopia":
            return [self.cornucopias[eu.idx]]
        if alvo == "enemy_hand_random":
            return self._aleatorio(list(ini.mao))
        if alvo == "ally_graveyard_entity":
            return self._escolher(dono, [c for c in eu.entidades_cemiterio() if custo_ok(c)], acao, ctx)
        if alvo == "ally_graveyard_entity_random":
            return self._aleatorio([c for c in eu.entidades_cemiterio() if custo_ok(c)])
        return []

    def _escolher(self, dono: int, cands: list, acao: dict, ctx: dict) -> list:
        if not cands:
            return []
        # dentro de um mesmo efeito, o mesmo tipo de alvo escolhido reaproveita a escolha
        # (ex.: Rito "cura 2 e +1/+1 numa aliada" atinge a mesma Entidade nas duas ações)
        chave = "_esc_" + str(acao.get("alvo"))
        prev = ctx.get(chave)
        if prev is not None and prev in cands:
            return [prev]
        if len(cands) == 1:
            esc = cands[0]
        else:
            esc = self.bots[dono].escolher_alvo(self, self.jogadores[dono], cands, acao, ctx)
            if esc not in cands:
                esc = cands[0]
        ctx[chave] = esc
        return [esc]

    def _aleatorio(self, cands: list) -> list:
        return [self.rng.choice(cands)] if cands else []

    # ---------- ações ----------
    def _executar_acoes(self, acoes, ctx: dict):
        for a in acoes:
            if self.acabou:
                return
            self._executar_acao(a, ctx)

    def _executar_acao(self, a: dict, ctx: dict):
        op = a["op"]
        dono = ctx["dono"]
        eu, ini = self.jogadores[dono], self.jogadores[1 - dono]
        fonte = ctx.get("fonte")
        if op == "draw":
            self.comprar(eu, int(a.get("n", 1)))
        elif op == "search":
            self._buscar(eu, a)
        elif op == "discard":
            for _ in range(int(a.get("n", 1))):
                if ini.mao:
                    c = self.rng.choice(ini.mao)
                    ini.mao.remove(c)
                    ini.cemiterio.append(c)
        elif op == "gain_fe":
            n = int(a.get("n", 1))
            if a.get("perm", False):
                # rampa: só a Fé máxima sobe; a Fé atual vem no próximo turno
                eu.fe_max = min(FE_MAX, eu.fe_max + n)
            else:
                eu.fe += n
        elif op == "counter":
            ctx["anulado"] = True
            self._log("efeito anulado (counter)")
        elif op == "win":
            self._encerrar(dono, "win")
        elif op == "ritual_choronzon":
            self._ritual_choronzon(eu)
        elif op == "summon":
            self._invocar_tokens(eu, a, fonte)
        else:
            alvos = self._alvos(a.get("alvo"), ctx, a)
            if op == "damage":
                pend = []
                for t in alvos:
                    if isinstance(t, Entidade) and t.em_campo:
                        t.dano += int(a["n"])
                        self._creditar_dano(fonte, int(a["n"]))
                        pend.append(t)
                    elif isinstance(t, Cornucopia):
                        self._dano_cornucopia(t.idx, int(a["n"]), fonte)
                for t in pend:
                    # dano de habilidade/Rito/Selo não tem atacante: `attacker` em on_damaged fica vazio
                    self._pos_dano(t, int(a["n"]), fonte, None)
            else:
                for t in alvos:
                    self._aplicar_em_alvo(op, a, t, ctx)

    def _aplicar_em_alvo(self, op: str, a: dict, t, ctx: dict):
        dono = ctx["dono"]
        eu = self.jogadores[dono]
        if op == "heal":
            if isinstance(t, Entidade) and t.em_campo:
                t.dano = max(0, t.dano - int(a["n"]))
            elif isinstance(t, Cornucopia):
                j = self.jogadores[t.idx]
                j.cornucopia = min(CORNUCOPIA_INICIAL, j.cornucopia + int(a["n"]))
        elif op == "buff":
            if isinstance(t, Entidade) and t.em_campo:
                if ctx.get("gatilho") == "on_equip" and t.reliquia is ctx.get("fonte"):
                    t.rel_atk += int(a.get("atk", 0) or 0)
                    t.rel_vida += int(a.get("vida", 0) or 0)
                elif a.get("perm", True):
                    t.buff_atk += int(a.get("atk", 0) or 0)
                    t.buff_vida += int(a.get("vida", 0) or 0)
                else:
                    t.temp_atk += int(a.get("atk", 0) or 0)
                    t.temp_vida += int(a.get("vida", 0) or 0)
        elif op == "destroy":
            if isinstance(t, Entidade):
                self._morrer(t)
            elif isinstance(t, Reliquia):
                self._remover_reliquia(t)
        elif op == "bounce":
            if isinstance(t, Entidade) and t.em_campo:
                self._devolver_a_mao(t)
        elif op == "revive":
            self._reviver(eu, t, a.get("para", "hand"))
        elif op == "silence":
            if isinstance(t, Entidade):
                t.keywords.clear()
                t.efeitos = []
                t.silenciada = True
                self.recalcular_auras()
        elif op == "freeze":
            if isinstance(t, Entidade):
                t.congelada = True
        elif op == "give_keyword":
            if isinstance(t, Entidade) and t.em_campo:
                t.keywords.add(a["keyword"])
        elif op == "set_stats":
            if isinstance(t, Entidade) and t.em_campo:
                t.atk_base, t.vida_base = int(a["atk"]), int(a["vida"])
                t.limpar_stats()
        elif op == "copy_stats":
            s = ctx.get("self")
            if isinstance(t, Entidade) and isinstance(s, Entidade) and s.em_campo:
                s.atk_base, s.vida_base = t.atk, max(1, t.vida)
                s.limpar_stats()
        elif op == "swap_control":
            if isinstance(t, Entidade) and t.em_campo and t.controlador != dono:
                self._roubar(t, dono, perm=a.get("perm", True))

    def _buscar(self, j: Jogador, a: dict):
        cands = [c for c in j.deck
                 if (a.get("tipo") is None or c.tipo == a["tipo"])
                 and (a.get("custo_max") is None or c.custo <= a["custo_max"])
                 and (a.get("keyword") is None or a["keyword"] in c.keywords)]
        if cands:
            c = cands[0] if len(cands) == 1 else self.bots[j.idx].escolher_busca(self, j, cands)
            if c not in cands:
                c = cands[0]
            j.deck.remove(c)
            self._para_mao(j, c)
            self._log(f"j{j.idx} busca {c.nome}")
        self.rng.shuffle(j.deck)

    def _invocar_tokens(self, j: Jogador, a: dict, fonte):
        nome = a.get("nome", "Token")
        carta = Card(id="token_" + nome.lower().replace(" ", "_"), nome=nome, cultura="token", tipo="entidade",
                     custo=0, atk=int(a["atk"]), vida=int(a["vida"]), lendaria=False,
                     keywords=tuple(a.get("keywords") or ()), sacrificio=0, efeitos=(), usos=None, token=True)
        origem = None
        if isinstance(fonte, Entidade):
            origem = fonte.origem_id
        elif isinstance(fonte, (Selo, Reliquia)):
            origem = fonte.carta.id
        elif isinstance(fonte, Card):
            origem = fonte.id
        for _ in range(int(a.get("n", 1))):
            if not j.tem_slot_entidade:
                break
            self._criar_entidade(j, carta, token=True, origem_id=origem)

    def _reviver(self, j: Jogador, c, para: str):
        if not isinstance(c, Card) or c not in j.cemiterio:
            return
        if para == "field":
            if not j.tem_slot_entidade:
                return
            j.cemiterio.remove(c)
            ent = self._criar_entidade(j, c)
            self._log(f"j{j.idx} revive {c.nome} para o campo")
            # revive não repete Despertar (regras.md §8): evita laços de Lendária revivida
        else:
            j.cemiterio.remove(c)
            self._para_mao(j, c)

    def _devolver_a_mao(self, e: Entidade):
        self._remover_do_campo(e)
        if e.reliquia is not None:
            self._remover_reliquia(e.reliquia)
        if not e.token:
            self._para_mao(self.jogadores[e.dono], e.carta)
        self.recalcular_auras()

    def _roubar(self, e: Entidade, novo: int, perm: bool):
        destino = self.jogadores[novo]
        if not destino.tem_slot_entidade:
            return
        self.jogadores[e.controlador].campo.remove(e)
        e.controlador = novo
        destino.campo.append(e)
        e.cansada = True
        e.atacou = False
        e.roubada_temp = (not perm) and e.dono != novo
        if perm and e.dono == novo:
            e.roubada_temp = False
        self.recalcular_auras()
        self._log(f"j{novo} rouba {e!r} ({'perm' if perm else 'temp'})")

    def _ritual_choronzon(self, j: Jogador):
        tem_triangulo = any(e.reliquia is not None and e.reliquia.carta.id == CHORONZON["reliquia"] for e in j.campo)
        tem_circulo = any(s.carta.id == CHORONZON["selo"] for s in j.selos)
        chor = next((c for c in j.mao if c.id == CHORONZON["entidade"]), None)
        if tem_triangulo and tem_circulo and chor is not None:
            j.mao.remove(chor)
            j.jogadas.append(chor.id)
            ent = self._criar_entidade(j, chor)
            self._log("Sigilo 333 completo: Choronzon entra em campo")
            self._disparar_efeitos_entidade(ent, "on_play", {"triggering": ent})
        else:
            self.comprar(j, 1)

    # ---------- helpers para testes/bots ----------
    def colocar_entidade(self, idx: int, c: Card, pronta: bool = True) -> Entidade:
        ent = self._criar_entidade(self.jogadores[idx], c)
        ent.cansada = not pronta
        return ent

    def valor_entidade(self, e: Entidade) -> float:
        return e.atk + e.vida + len(e.keywords) + len(e.efeitos) + (2 if e.reliquia else 0)
