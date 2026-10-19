"""Testes das regras críticas do motor. Rode: python3 -m unittest discover -s sim/tests  (ou python3 sim/tests/test_engine.py)."""
import os
import sys
import unittest

AQUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(AQUI, ".."))

from bots import HeurBot, PassivoBot, RandomBot  # noqa: E402
from cards import carregar_pasta, carta_de_json, cartas_de_md_multiplo, deck_de_cartas  # noqa: E402
from engine import Acao, AcaoIlegal, FimDeJogo, Jogo, Selo  # noqa: E402

DOCS = os.path.join(AQUI, "..", "..", "docs")
PASTA_TESTE = os.path.join(AQUI, "cartas_teste")


def carta(id, tipo="entidade", custo=1, atk=1, vida=1, kw=(), efeitos=(), sacrificio=0, usos=None, lendaria=False):
    ent = tipo == "entidade"
    return carta_de_json({
        "id": id, "nome": id, "cultura": "teste", "tipo": tipo, "custo": custo,
        "atk": atk if ent else None, "vida": vida if ent else None, "lendaria": lendaria,
        "keywords": list(kw) if ent else [], "sacrificio": sacrificio if ent else 0,
        "efeitos": list(efeitos), "usos": usos,
    })


def ef(gatilho, *acoes, cond=None):
    d = {"gatilho": gatilho, "acoes": list(acoes)}
    if cond:
        d["cond"] = cond
    return d


VANILLA = carta("tst_vanilla", custo=1, atk=1, vida=1)


def novo_jogo(seed=1, primeiro=0, bots=None):
    deck_a = deck_de_cartas("A", [VANILLA] * 32)
    deck_b = deck_de_cartas("B", [VANILLA] * 32)
    return Jogo(deck_a, deck_b, bots or [PassivoBot(), PassivoBot()], seed=seed, primeiro=primeiro)


def turno_de(jogo, idx, fe=8):
    """Começa um turno do jogador idx com Fé definida (sem passar pelo bot)."""
    j = jogo.jogadores[idx]
    jogo.iniciar_turno(j)
    j.fe = j.fe_max = fe
    return j


def selo_antigo(jogo, idx, c):
    """Selo posto num turno anterior (turno_posto = 0)."""
    s = Selo(c, idx, 0)
    jogo.jogadores[idx].selos.append(s)
    return s


class TesteCombate(unittest.TestCase):
    def test_dano_direto_bloqueado_com_campo_inimigo(self):
        jogo = novo_jogo()
        turno_de(jogo, 0)
        atacante = jogo.colocar_entidade(0, carta("a", atk=3, vida=3))
        defensor = jogo.colocar_entidade(1, carta("b", atk=1, vida=1))
        self.assertEqual(jogo.alvos_de_ataque(atacante), [defensor])
        with self.assertRaises(AcaoIlegal):
            jogo.atacar(atacante, jogo.cornucopias[1])
        self.assertEqual(jogo.jogadores[1].cornucopia, 15)

    def test_dano_direto_com_campo_vazio(self):
        jogo = novo_jogo()
        turno_de(jogo, 0)
        atacante = jogo.colocar_entidade(0, carta("a", atk=3, vida=3))
        self.assertEqual(jogo.alvos_de_ataque(atacante), [jogo.cornucopias[1]])
        jogo.atacar(atacante, jogo.cornucopias[1])
        self.assertEqual(jogo.jogadores[1].cornucopia, 12)
        self.assertFalse(atacante.pode_atacar())

    def test_guarda_forca_alvo(self):
        jogo = novo_jogo()
        turno_de(jogo, 0)
        atacante = jogo.colocar_entidade(0, carta("a", atk=3, vida=3))
        jogo.colocar_entidade(1, carta("fraco", atk=1, vida=1))
        guarda = jogo.colocar_entidade(1, carta("g", atk=1, vida=4, kw=["guarda"]))
        self.assertEqual(jogo.alvos_de_ataque(atacante), [guarda])
        with self.assertRaises(AcaoIlegal):
            jogo.atacar(atacante, jogo.jogadores[1].campo[0])

    def test_dano_simultaneo(self):
        jogo = novo_jogo()
        turno_de(jogo, 0)
        a = jogo.colocar_entidade(0, carta("a", atk=2, vida=3))
        b = jogo.colocar_entidade(1, carta("b", atk=3, vida=2))
        jogo.atacar(a, b)
        self.assertFalse(a.em_campo)
        self.assertFalse(b.em_campo)
        self.assertEqual(jogo.jogadores[0].cemiterio[-1].id, "a")

    def test_entidade_entra_cansada_salvo_impeto(self):
        jogo = novo_jogo()
        j = turno_de(jogo, 0)
        lento, rapido = carta("lento", custo=1), carta("rapido", custo=1, kw=["impeto"])
        j.mao += [lento, rapido]
        jogo.jogar_carta(j, lento)
        jogo.jogar_carta(j, rapido)
        prontos = [e.carta.id for e in j.campo if e.pode_atacar()]
        self.assertEqual(prontos, ["rapido"])

    def test_ally_attacked_nao_dispara_em_ataque_a_cornucopia(self):
        jogo = novo_jogo()
        turno_de(jogo, 0)
        a = jogo.colocar_entidade(0, carta("a", atk=1, vida=5))
        jogo.colocar_entidade(1, carta("vigia", atk=0, vida=5, efeitos=[ef("ally_attacked", {"op": "damage", "alvo": "attacker", "n": 3})]))
        alvo = jogo.colocar_entidade(1, carta("b", atk=0, vida=5))
        jogo.atacar(a, alvo)
        self.assertEqual(a.vida, 2)


class TesteSelos(unittest.TestCase):
    SELO = carta("selo_draw", tipo="selo", custo=1, efeitos=[ef("ally_dies", {"op": "draw", "n": 1})])

    def test_selo_nao_dispara_no_turno_em_que_entra(self):
        jogo = novo_jogo()
        j0 = turno_de(jogo, 0)
        j0.mao.append(self.SELO)
        jogo.jogar_carta(j0, self.SELO)
        meu = jogo.colocar_entidade(0, carta("meu", atk=1, vida=1))
        inimigo = jogo.colocar_entidade(1, carta("ini", atk=5, vida=5))
        mao_antes = len(j0.mao)
        jogo.atacar(meu, inimigo)
        self.assertFalse(meu.em_campo)
        self.assertEqual(len(j0.selos), 1)
        self.assertEqual(len(j0.mao), mao_antes)

    def test_selo_dispara_no_turno_do_oponente(self):
        jogo = novo_jogo()
        j0 = turno_de(jogo, 0)
        j0.mao.append(self.SELO)
        jogo.jogar_carta(j0, self.SELO)
        meu = jogo.colocar_entidade(0, carta("meu", atk=1, vida=1))
        jogo.encerrar_turno(j0)
        turno_de(jogo, 1)
        inimigo = jogo.colocar_entidade(1, carta("ini", atk=5, vida=5))
        mao_antes = len(j0.mao)
        jogo.atacar(inimigo, meu)
        self.assertEqual(len(j0.selos), 0)
        self.assertEqual(len(j0.mao), mao_antes + 1)
        self.assertIn(self.SELO, j0.cemiterio)

    def test_selo_recem_posto_nao_dispara_mesmo_no_turno_inimigo(self):
        jogo = novo_jogo()
        turno_de(jogo, 1)
        s = Selo(self.SELO, 0, jogo.turno_global)
        jogo.jogadores[0].selos.append(s)
        meu = jogo.colocar_entidade(0, carta("meu", atk=1, vida=1))
        inimigo = jogo.colocar_entidade(1, carta("ini", atk=5, vida=5))
        jogo.atacar(inimigo, meu)
        self.assertEqual(jogo.jogadores[0].selos, [s])

    def test_um_selo_por_turno_e_dois_slots(self):
        jogo = novo_jogo()
        j0 = turno_de(jogo, 0)
        s1, s2 = carta("s1", tipo="selo", efeitos=[ef("enemy_end_turn", {"op": "draw", "n": 1})]), \
            carta("s2", tipo="selo", efeitos=[ef("enemy_end_turn", {"op": "draw", "n": 1})])
        j0.mao += [s1, s2]
        jogo.jogar_carta(j0, s1)
        self.assertFalse(jogo.pode_jogar(j0, s2))
        j0.selo_neste_turno = False
        jogo.jogar_carta(j0, s2)
        j0.selo_neste_turno = False
        j0.mao.append(carta("s3", tipo="selo", efeitos=[ef("enemy_end_turn", {"op": "draw", "n": 1})]))
        self.assertFalse(jogo.pode_jogar(j0, j0.mao[-1]))

    def test_counter_anula_rito(self):
        jogo = novo_jogo()
        contra = carta("contra", tipo="selo", custo=2, efeitos=[ef("enemy_plays_rite", {"op": "counter"})])
        selo_antigo(jogo, 1, contra)
        alvo = jogo.colocar_entidade(1, carta("alvo", atk=1, vida=3))
        j0 = turno_de(jogo, 0)
        raio = carta("raio", tipo="rito", custo=2, efeitos=[ef("on_play", {"op": "damage", "alvo": "enemy_entity", "n": 3})])
        j0.mao.append(raio)
        jogo.jogar_carta(j0, raio)
        self.assertTrue(alvo.em_campo)
        self.assertEqual(alvo.vida, 3)
        self.assertIn(raio, j0.cemiterio)
        self.assertIn(contra, jogo.jogadores[1].cemiterio)
        self.assertEqual(jogo.jogadores[1].selos, [])

    def test_counter_respeita_cond_target_cost_max(self):
        jogo = novo_jogo()
        contra = carta("contra", tipo="selo", efeitos=[ef("enemy_plays_rite", {"op": "counter"}, cond={"tipo": "target_cost_max", "n": 2})])
        s = selo_antigo(jogo, 1, contra)
        alvo = jogo.colocar_entidade(1, carta("alvo", atk=1, vida=5))
        j0 = turno_de(jogo, 0)
        caro = carta("caro", tipo="rito", custo=4, efeitos=[ef("on_play", {"op": "damage", "alvo": "enemy_entity", "n": 3})])
        j0.mao.append(caro)
        jogo.jogar_carta(j0, caro)
        self.assertEqual(alvo.vida, 2)
        self.assertEqual(jogo.jogadores[1].selos, [s])

    def test_counter_em_entidade_remove_sem_despertar(self):
        jogo = novo_jogo()
        selo_antigo(jogo, 1, carta("contra", tipo="selo", efeitos=[ef("enemy_plays_entity", {"op": "counter"})]))
        j0 = turno_de(jogo, 0)
        ent = carta("ent", custo=3, atk=2, vida=2, efeitos=[ef("on_play", {"op": "damage", "alvo": "enemy_cornucopia", "n": 3})])
        j0.mao.append(ent)
        jogo.jogar_carta(j0, ent)
        self.assertEqual(j0.campo, [])
        self.assertIn(ent, j0.cemiterio)
        self.assertEqual(jogo.jogadores[1].cornucopia, 15)

    def test_enemy_attacks_so_em_ataque_a_entidade(self):
        jogo = novo_jogo()
        s_a = selo_antigo(jogo, 1, carta("s_a", tipo="selo", efeitos=[ef("enemy_attacks", {"op": "damage", "alvo": "attacker", "n": 1})]))
        selo_antigo(jogo, 1, carta("s_c", tipo="selo", efeitos=[ef("enemy_attacks_cornucopia", {"op": "heal", "alvo": "ally_cornucopia", "n": 3})]))
        jogo.jogadores[1].cornucopia = 10
        turno_de(jogo, 0)
        a = jogo.colocar_entidade(0, carta("a", atk=2, vida=3))
        jogo.atacar(a, jogo.cornucopias[1])
        self.assertEqual(a.vida, 3)
        self.assertEqual(jogo.jogadores[1].cornucopia, 11)
        self.assertEqual(jogo.jogadores[1].selos, [s_a])
        b = jogo.colocar_entidade(1, carta("b", atk=0, vida=5))
        a.atacou = False
        jogo.atacar(a, b)
        self.assertEqual(a.vida, 2)
        self.assertEqual(jogo.jogadores[1].selos, [])

    def test_alvo_inexistente_pula_so_a_acao(self):
        jogo = novo_jogo()
        turno_de(jogo, 0)
        e = jogo.colocar_entidade(0, carta("e", atk=1, vida=5, efeitos=[ef("on_damaged",
                                                                           {"op": "damage", "alvo": "attacker", "n": 9},
                                                                           {"op": "draw", "n": 1})]))
        j0 = jogo.jogadores[0]
        n = len(j0.mao)
        jogo._dano_entidade(e, 1, carta("rito_qualquer", tipo="rito"))
        self.assertEqual(len(j0.mao), n + 1)


class TesteKeywordsEReliquias(unittest.TestCase):
    def test_renascer_volta_uma_vez(self):
        jogo = novo_jogo()
        j0 = turno_de(jogo, 0)
        fenix = carta("fenix", custo=1, atk=1, vida=1, kw=["renascer"])
        e = jogo.colocar_entidade(0, fenix)
        grande = jogo.colocar_entidade(1, carta("g", atk=5, vida=5))
        jogo.atacar(e, grande)
        self.assertFalse(e.em_campo)
        self.assertEqual(j0.cemiterio, [])
        voltou = j0.mao[-1]
        self.assertEqual(voltou.id, "fenix")
        self.assertNotIn("renascer", voltou.keywords)
        jogo.jogar_carta(j0, voltou)
        e2 = j0.campo[0]
        e2.cansada = False
        jogo.atacar(e2, grande)
        self.assertEqual([c.id for c in j0.cemiterio], ["fenix"])

    def test_reliquia_morre_com_portadora(self):
        jogo = novo_jogo()
        j0 = turno_de(jogo, 0)
        port = jogo.colocar_entidade(0, carta("port", atk=1, vida=2))
        rel = carta("lanca", tipo="reliquia", custo=1, efeitos=[ef("on_equip", {"op": "buff", "alvo": "equipped", "atk": 2, "vida": 0, "perm": True})])
        j0.mao.append(rel)
        jogo.jogar_carta(j0, rel, port)
        self.assertEqual(port.atk, 3)
        self.assertIs(port.reliquia.carta, rel)
        grande = jogo.colocar_entidade(1, carta("g", atk=5, vida=9))
        jogo.atacar(port, grande)
        self.assertFalse(port.em_campo)
        self.assertIn(rel, j0.cemiterio)
        self.assertIn(port.carta, j0.cemiterio)

    def test_reliquia_usos_some_na_ultima_carga(self):
        jogo = novo_jogo()
        j0 = turno_de(jogo, 0)
        port = jogo.colocar_entidade(0, carta("port", atk=1, vida=9))
        orbe = carta("orbe", tipo="reliquia", custo=1, usos=2, efeitos=[ef("equipped_attacks", {"op": "damage", "alvo": "enemy_cornucopia", "n": 1})])
        j0.mao.append(orbe)
        jogo.jogar_carta(j0, orbe, port)
        for _ in range(2):
            jogo.atacar(port, jogo.cornucopias[1])
            port.atacou = False
        self.assertIsNone(port.reliquia)
        self.assertIn(orbe, j0.cemiterio)
        self.assertEqual(jogo.jogadores[1].cornucopia, 15 - 2 - 2)

    def test_buff_de_on_equip_some_quando_usos_acabam(self):
        jogo = novo_jogo()
        j0 = turno_de(jogo, 0)
        port = jogo.colocar_entidade(0, carta("port", atk=1, vida=2))
        rel = carta("rel", tipo="reliquia", custo=1, usos=1, efeitos=[
            ef("on_equip", {"op": "buff", "alvo": "equipped", "atk": 2, "vida": 3, "perm": True}),
            ef("equipped_attacks", {"op": "damage", "alvo": "enemy_cornucopia", "n": 1})])
        j0.mao.append(rel)
        jogo.jogar_carta(j0, rel, port)
        self.assertEqual((port.atk, port.vida), (3, 5))
        jogo.atacar(port, jogo.cornucopias[1])
        self.assertIsNone(port.reliquia)
        self.assertEqual((port.atk, port.vida), (1, 2))

    def test_sacrificio_nao_aciona_renascer(self):
        jogo = novo_jogo()
        j0 = turno_de(jogo, 0)
        fenix = jogo.colocar_entidade(0, carta("fenix", kw=["renascer"]))
        grande = carta("grande", custo=5, atk=5, vida=5, sacrificio=1)
        j0.mao.append(grande)
        jogo.jogar_carta(j0, grande)
        self.assertFalse(fenix.em_campo)
        self.assertIn(fenix.carta, j0.cemiterio)
        self.assertNotIn("fenix", [c.id for c in j0.mao])

    def test_morta_ja_esta_no_cemiterio_durante_ultimo_sopro(self):
        jogo = novo_jogo()
        j0 = turno_de(jogo, 0)
        imortal = carta("imortal", atk=1, vida=1, efeitos=[ef("on_death", {"op": "revive", "alvo": "ally_graveyard_entity_random", "para": "field"})])
        e = jogo.colocar_entidade(0, imortal)
        jogo._morrer(e)
        self.assertEqual([x.carta.id for x in j0.campo], ["imortal"])
        self.assertNotIn(imortal, j0.cemiterio)

    def test_uma_reliquia_por_entidade(self):
        jogo = novo_jogo()
        j0 = turno_de(jogo, 0)
        port = jogo.colocar_entidade(0, carta("port"))
        r1 = carta("r1", tipo="reliquia", efeitos=[ef("on_equip", {"op": "buff", "alvo": "equipped", "atk": 1, "vida": 0, "perm": True})])
        r2 = carta("r2", tipo="reliquia", efeitos=[ef("on_equip", {"op": "buff", "alvo": "equipped", "atk": 1, "vida": 0, "perm": True})])
        j0.mao += [r1, r2]
        jogo.jogar_carta(j0, r1, port)
        self.assertFalse(jogo.pode_jogar(j0, r2))

    def test_furtivo_nao_e_alvo_ate_atacar(self):
        jogo = novo_jogo()
        furtivo = jogo.colocar_entidade(1, carta("f", atk=1, vida=3, kw=["furtivo"]))
        j0 = turno_de(jogo, 0)
        raio = carta("raio", tipo="rito", custo=1, efeitos=[ef("on_play", {"op": "damage", "alvo": "enemy_entity", "n": 2})])
        j0.mao.append(raio)
        jogo.jogar_carta(j0, raio)
        self.assertEqual(furtivo.vida, 3)
        furtivo.ja_atacou = True
        j0.mao.append(raio)
        jogo.jogar_carta(j0, raio)
        self.assertEqual(furtivo.vida, 1)

    def test_sacrificio(self):
        jogo = novo_jogo()
        j0 = turno_de(jogo, 0)
        grande = carta("grande", custo=5, atk=5, vida=5, sacrificio=1)
        j0.mao.append(grande)
        self.assertFalse(jogo.pode_jogar(j0, grande))
        vitima = jogo.colocar_entidade(0, carta("vitima"))
        self.assertTrue(jogo.pode_jogar(j0, grande))
        jogo.jogar_carta(j0, grande)
        self.assertFalse(vitima.em_campo)
        self.assertEqual([e.carta.id for e in j0.campo], ["grande"])
        self.assertIn(vitima.carta, j0.cemiterio)

    def test_freeze_impede_ataque_no_proximo_turno(self):
        jogo = novo_jogo()
        j0 = turno_de(jogo, 0)
        ini = jogo.colocar_entidade(1, carta("ini", atk=2, vida=5))
        gelo = carta("gelo", tipo="rito", custo=1, efeitos=[ef("on_play", {"op": "freeze", "alvo": "enemy_entity"})])
        j0.mao.append(gelo)
        jogo.jogar_carta(j0, gelo)
        jogo.encerrar_turno(j0)
        turno_de(jogo, 1)
        self.assertFalse(ini.pode_atacar())
        jogo.encerrar_turno(jogo.jogadores[1])
        turno_de(jogo, 0)
        jogo.encerrar_turno(j0)
        turno_de(jogo, 1)
        self.assertTrue(ini.pode_atacar())


class TesteAurasEEfeitos(unittest.TestCase):
    def test_aura_some_com_a_fonte(self):
        jogo = novo_jogo()
        turno_de(jogo, 0)
        soldado = jogo.colocar_entidade(0, carta("s", atk=1, vida=1))
        totem = jogo.colocar_entidade(0, carta("totem", atk=0, vida=2, efeitos=[ef("static", {"op": "buff", "alvo": "all_ally_entities", "atk": 2, "vida": 1, "perm": True})]))
        self.assertEqual((soldado.atk, soldado.vida), (3, 2))
        self.assertEqual((totem.atk, totem.vida), (2, 3))
        jogo._morrer(totem)
        self.assertEqual((soldado.atk, soldado.vida), (1, 1))

    def test_aura_negativa_removida_pode_matar(self):
        jogo = novo_jogo()
        turno_de(jogo, 0)
        soldado = jogo.colocar_entidade(0, carta("s", atk=1, vida=2))
        soldado.dano = 2
        totem = jogo.colocar_entidade(0, carta("totem", atk=0, vida=2, efeitos=[ef("static", {"op": "buff", "alvo": "all_ally_entities", "atk": 0, "vida": 1, "perm": True})]))
        self.assertEqual(soldado.vida, 1)
        jogo._morrer(totem)
        self.assertFalse(soldado.em_campo)

    def test_silence_remove_aura_e_keywords(self):
        jogo = novo_jogo()
        soldado = jogo.colocar_entidade(1, carta("s", atk=1, vida=1))
        totem = jogo.colocar_entidade(1, carta("totem", atk=0, vida=2, kw=["guarda"], efeitos=[ef("static", {"op": "buff", "alvo": "all_ally_entities", "atk": 2, "vida": 0, "perm": True})]))
        j0 = turno_de(jogo, 0)
        sil = carta("sil", tipo="rito", custo=1, efeitos=[ef("on_play", {"op": "silence", "alvo": "enemy_entity"})])
        j0.mao.append(sil)
        jogo.bots[0] = _BotAlvoFixo(totem)
        jogo.jogar_carta(j0, sil)
        self.assertEqual(soldado.atk, 1)
        self.assertFalse(totem.tem("guarda"))

    def test_buff_temporario_expira_no_fim_do_turno(self):
        jogo = novo_jogo()
        j0 = turno_de(jogo, 0)
        e = jogo.colocar_entidade(0, carta("e", atk=1, vida=1))
        b = carta("b", tipo="rito", custo=1, efeitos=[ef("on_play", {"op": "buff", "alvo": "ally_entity", "atk": 2, "vida": 2, "perm": False})])
        j0.mao.append(b)
        jogo.jogar_carta(j0, b)
        self.assertEqual((e.atk, e.vida), (3, 3))
        jogo.encerrar_turno(j0)
        self.assertEqual((e.atk, e.vida), (1, 1))

    def test_swap_control_temporario_volta(self):
        jogo = novo_jogo()
        alvo = jogo.colocar_entidade(1, carta("alvo", atk=2, vida=2))
        j0 = turno_de(jogo, 0)
        poss = carta("poss", tipo="rito", custo=3, efeitos=[ef("on_play", {"op": "swap_control", "alvo": "enemy_entity", "perm": False})])
        j0.mao.append(poss)
        jogo.jogar_carta(j0, poss)
        self.assertEqual(alvo.controlador, 0)
        self.assertIn(alvo, j0.campo)
        self.assertFalse(alvo.pode_atacar())
        jogo.encerrar_turno(j0)
        self.assertEqual(alvo.controlador, 1)
        self.assertIn(alvo, jogo.jogadores[1].campo)

    def test_summon_respeita_slots_e_token_nao_vai_ao_cemiterio(self):
        jogo = novo_jogo()
        j0 = turno_de(jogo, 0)
        for i in range(3):
            jogo.colocar_entidade(0, carta(f"e{i}"))
        inv = carta("inv", tipo="rito", custo=1, efeitos=[ef("on_play", {"op": "summon", "atk": 1, "vida": 1, "nome": "Tok", "n": 3})])
        j0.mao.append(inv)
        jogo.jogar_carta(j0, inv)
        self.assertEqual(len(j0.campo), 4)
        token = j0.campo[-1]
        self.assertTrue(token.token)
        jogo._morrer(token)
        self.assertNotIn(token.carta, j0.cemiterio)

    def test_search_filtra_e_revive(self):
        jogo = novo_jogo()
        j0 = turno_de(jogo, 0)
        alvo_busca = carta("busca_me", custo=2, kw=["guarda"])
        j0.deck.append(alvo_busca)
        busca = carta("busca", tipo="rito", custo=1, efeitos=[ef("on_play", {"op": "search", "keyword": "guarda"})])
        j0.mao.append(busca)
        jogo.jogar_carta(j0, busca)
        self.assertIn(alvo_busca, j0.mao)
        morto = carta("morto", custo=3, atk=3, vida=3)
        j0.cemiterio.append(morto)
        rev = carta("rev", tipo="rito", custo=4, efeitos=[ef("on_play", {"op": "revive", "alvo": "ally_graveyard_entity", "para": "field"})])
        j0.mao.append(rev)
        jogo.jogar_carta(j0, rev)
        self.assertEqual(j0.campo[-1].carta, morto)
        self.assertNotIn(morto, j0.cemiterio)

    def test_set_stats_copy_stats_give_keyword_e_discard(self):
        jogo = novo_jogo()
        j0 = turno_de(jogo, 0)
        jogo.jogadores[1].mao[:] = [VANILLA, VANILLA]
        ini = jogo.colocar_entidade(1, carta("ini", atk=4, vida=4))
        meu = jogo.colocar_entidade(0, carta("meu", atk=1, vida=1, efeitos=[ef("on_play", {"op": "copy_stats", "alvo": "enemy_entity"})]))
        jogo._disparar_efeitos_entidade(meu, "on_play", {})
        self.assertEqual((meu.atk, meu.vida), (4, 4))
        rito = carta("r", tipo="rito", custo=1, efeitos=[ef("on_play",
                                                           {"op": "set_stats", "alvo": "enemy_entity", "atk": 1, "vida": 1},
                                                           {"op": "give_keyword", "alvo": "ally_entity", "keyword": "guarda"},
                                                           {"op": "discard", "alvo": "enemy_hand_random", "n": 1})])
        j0.mao.append(rito)
        jogo.jogar_carta(j0, rito)
        self.assertEqual((ini.atk, ini.vida), (1, 1))
        self.assertTrue(meu.tem("guarda"))
        self.assertEqual(len(jogo.jogadores[1].mao), 1)

    def test_cond_bloqueia_efeito(self):
        jogo = novo_jogo()
        j0 = turno_de(jogo, 0)
        j0.cornucopia = 15
        cura = carta("cura", tipo="rito", custo=1, efeitos=[ef("on_play", {"op": "draw", "n": 1}, cond={"tipo": "cornucopia_below", "n": 10})])
        j0.mao.append(cura)
        n = len(j0.mao) - 1
        jogo.jogar_carta(j0, cura)
        self.assertEqual(len(j0.mao), n)
        j0.cornucopia = 5
        j0.mao.append(cura)
        jogo.jogar_carta(j0, cura)
        self.assertEqual(len(j0.mao), n + 1)

    def test_target_cost_max_em_on_play_filtra_o_alvo(self):
        jogo = novo_jogo()
        caro = jogo.colocar_entidade(1, carta("caro", custo=5, atk=5, vida=5))
        barato = jogo.colocar_entidade(1, carta("barato", custo=2, atk=2, vida=2))
        j0 = turno_de(jogo, 0)
        nar = carta("nar", custo=4, atk=3, vida=3, efeitos=[ef("on_play", {"op": "destroy", "alvo": "enemy_entity"}, cond={"tipo": "target_cost_max", "n": 3})])
        j0.mao.append(nar)
        jogo.jogar_carta(j0, nar)
        self.assertTrue(caro.em_campo)
        self.assertFalse(barato.em_campo)

    def test_atacante_nao_se_fere_com_proprio_on_damaged(self):
        jogo = novo_jogo()
        alvo = jogo.colocar_entidade(1, carta("alvo", atk=1, vida=3))
        turno_de(jogo, 0)
        cur = jogo.colocar_entidade(0, carta("cur", atk=1, vida=2, efeitos=[ef("on_damaged", {"op": "damage", "alvo": "attacker", "n": 1})]))
        jogo.atacar(cur, alvo)
        self.assertTrue(cur.em_campo)
        self.assertEqual(cur.vida, 1)
        self.assertEqual(alvo.vida, 2)

    def test_gain_fe_perm_sobe_so_a_maxima(self):
        jogo = novo_jogo()
        j0 = turno_de(jogo, 0, fe=3)
        r = carta("rampa", tipo="rito", custo=1, efeitos=[ef("on_play", {"op": "gain_fe", "n": 1, "perm": True})])
        j0.mao.append(r)
        jogo.jogar_carta(j0, r)
        self.assertEqual(j0.fe_max, 4)
        self.assertEqual(j0.fe, 2)

    def test_furtivo_escapa_de_selo_que_o_aponta_como_triggering(self):
        jogo = novo_jogo()
        selo_antigo(jogo, 1, carta("s", tipo="selo", efeitos=[ef("enemy_plays_entity", {"op": "destroy", "alvo": "triggering"})]))
        j0 = turno_de(jogo, 0)
        gato = carta("gato", custo=2, atk=1, vida=1, kw=["furtivo"])
        j0.mao.append(gato)
        jogo.jogar_carta(j0, gato)
        self.assertEqual(len(j0.campo), 1)

    def test_revive_para_campo_nao_dispara_despertar(self):
        jogo = novo_jogo()
        j0 = turno_de(jogo, 0)
        ent = carta("desp", custo=2, atk=1, vida=1, efeitos=[ef("on_play", {"op": "draw", "n": 1})])
        j0.cemiterio.append(ent)
        n = len(j0.mao)
        rev = carta("rev", tipo="rito", custo=1, efeitos=[ef("on_play", {"op": "revive", "alvo": "ally_graveyard_entity", "para": "field"})])
        j0.mao.append(rev)
        jogo.jogar_carta(j0, rev)
        self.assertEqual(len(j0.campo), 1)
        self.assertEqual(len(j0.mao), n)

    def test_alvo_defender_em_ally_attacked_e_selo(self):
        jogo = novo_jogo()
        selo_antigo(jogo, 1, carta("s", tipo="selo", efeitos=[ef("enemy_attacks", {"op": "buff", "alvo": "defender", "atk": 0, "vida": 3, "perm": False})]))
        jogo.colocar_entidade(1, carta("cura", atk=0, vida=5, efeitos=[ef("ally_attacked", {"op": "heal", "alvo": "defender", "n": 2})]))
        alvo = jogo.colocar_entidade(1, carta("alvo", atk=0, vida=5))
        alvo.dano = 2
        turno_de(jogo, 0)
        a = jogo.colocar_entidade(0, carta("a", atk=4, vida=4))
        jogo.atacar(a, alvo)
        self.assertTrue(alvo.em_campo)
        self.assertEqual(alvo.vida, 4)

    def test_other_ally_entities_exclui_a_fonte(self):
        jogo = novo_jogo()
        turno_de(jogo, 0)
        s = jogo.colocar_entidade(0, carta("s", atk=1, vida=1))
        lider = jogo.colocar_entidade(0, carta("lider", atk=1, vida=1, efeitos=[
            ef("static", {"op": "give_keyword", "alvo": "other_ally_entities", "keyword": "guarda"}),
            ef("on_play", {"op": "buff", "alvo": "other_ally_entities", "atk": 1, "vida": 0, "perm": True})]))
        jogo._disparar_efeitos_entidade(lider, "on_play", {})
        self.assertTrue(s.tem("guarda") and not lider.tem("guarda"))
        self.assertEqual((s.atk, lider.atk), (2, 1))

    def test_summon_com_keywords(self):
        jogo = novo_jogo()
        j0 = turno_de(jogo, 0)
        inv = carta("inv", tipo="rito", custo=1, efeitos=[ef("on_play", {"op": "summon", "atk": 1, "vida": 1, "nome": "Muro", "keywords": ["guarda"], "n": 2})])
        j0.mao.append(inv)
        jogo.jogar_carta(j0, inv)
        self.assertEqual(len(j0.campo), 2)
        self.assertTrue(all(e.tem("guarda") for e in j0.campo))

    def test_ultimo_sopro_e_ally_dies(self):
        jogo = novo_jogo()
        j0 = turno_de(jogo, 0)
        sopro = jogo.colocar_entidade(0, carta("sopro", atk=1, vida=1, efeitos=[ef("on_death", {"op": "damage", "alvo": "enemy_cornucopia", "n": 2})]))
        vinganca = jogo.colocar_entidade(0, carta("ving", atk=1, vida=1, efeitos=[ef("ally_dies", {"op": "buff", "alvo": "self", "atk": 1, "vida": 1, "perm": True})]))
        jogo._morrer(sopro)
        self.assertEqual(jogo.jogadores[1].cornucopia, 13)
        self.assertEqual((vinganca.atk, vinganca.vida), (2, 2))


class TesteTurnoERecursos(unittest.TestCase):
    def test_fadiga(self):
        jogo = novo_jogo()
        j0 = jogo.jogadores[0]
        j0.deck.clear()
        jogo.comprar(j0, 2)
        self.assertEqual(j0.cornucopia, 15 - 4)
        self.assertEqual(j0.fadiga, 2)

    def test_primeiro_nao_compra_segundo_ganha_fe_temporaria(self):
        jogo = novo_jogo()
        jogo.preparar()
        j0, j1 = jogo.jogadores
        jogo.iniciar_turno(j0)
        self.assertEqual(len(j0.mao), 4)
        self.assertEqual((j0.fe_max, j0.fe), (1, 1))
        jogo.encerrar_turno(j0)
        jogo.iniciar_turno(j1)
        self.assertEqual(len(j1.mao), 5)
        self.assertEqual((j1.fe_max, j1.fe), (1, 2))
        jogo.encerrar_turno(j1)
        jogo.iniciar_turno(j0)
        self.assertEqual(len(j0.mao), 5)
        self.assertEqual((j0.fe_max, j0.fe), (2, 2))

    def test_fe_cresce_ate_8(self):
        jogo = novo_jogo()
        j0 = jogo.jogadores[0]
        for _ in range(12):
            jogo.iniciar_turno(j0)
            j0.deck.append(VANILLA)
        self.assertEqual(j0.fe_max, 8)

    def test_mao_maxima_ao_comprar(self):
        jogo = novo_jogo()
        j0 = jogo.jogadores[0]
        jogo.comprar(j0, 9)
        self.assertEqual(len(j0.mao), 7)
        self.assertEqual(len(j0.cemiterio), 2)

    def test_jogo_termina_por_cornucopia(self):
        jogo = novo_jogo()
        turno_de(jogo, 0)
        jogo.jogadores[1].cornucopia = 2
        a = jogo.colocar_entidade(0, carta("a", atk=3, vida=3))
        with self.assertRaises(FimDeJogo):
            jogo.executar(jogo.jogadores[0], Acao("atacar", atacante=a, alvo=jogo.cornucopias[1]))
        self.assertTrue(jogo.acabou)
        self.assertEqual(jogo.vencedor, 0)

    def test_empate_por_limite_de_rodadas(self):
        jogo = novo_jogo()
        jogo.max_rodadas = 3
        for j in jogo.jogadores:
            j.deck.extend([VANILLA] * 50)
        self.assertIsNone(jogo.jogar())
        self.assertTrue(jogo.acabou)
        self.assertEqual(jogo.rodada, 4)


class TesteChoronzon(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cartas = {c.id: c for c in cartas_de_md_multiplo(os.path.join(DOCS, "choronzon.md"))}
        cls.chor, cls.tri, cls.circ, cls.sig = (cartas[k] for k in ("aby_choronzon", "aby_triangulo", "aby_circulo", "aby_sigilo"))

    def _preparar(self, com_triangulo=True, com_circulo=True, com_choronzon=True):
        jogo = novo_jogo()
        j0 = turno_de(jogo, 0)
        port = jogo.colocar_entidade(0, carta("port"))
        if com_triangulo:
            j0.mao.append(self.tri)
            jogo.jogar_carta(j0, self.tri, port)
        if com_circulo:
            j0.selos.append(Selo(self.circ, 0, jogo.turno_global))
        if com_choronzon:
            j0.mao.append(self.chor)
        j0.mao.append(self.sig)
        return jogo, j0

    def test_ritual_vence_com_as_tres_condicoes(self):
        jogo, j0 = self._preparar()
        with self.assertRaises(FimDeJogo):
            jogo.executar(j0, Acao("jogar", carta=self.sig))
        self.assertEqual(jogo.vencedor, 0)
        self.assertTrue(any(e.carta.id == "aby_choronzon" for e in j0.campo))

    def test_ritual_falha_sem_cada_peca(self):
        for faltando in ("com_triangulo", "com_circulo", "com_choronzon"):
            jogo, j0 = self._preparar(**{faltando: False})
            mao_antes = len(j0.mao) - 1
            jogo.executar(j0, Acao("jogar", carta=self.sig))
            self.assertFalse(jogo.acabou, faltando)
            self.assertEqual(len(j0.mao), mao_antes + 1, faltando)

    def test_choronzon_nao_pode_ser_invocado_pagando_fe(self):
        jogo, j0 = self._preparar()
        self.assertFalse(jogo.pode_jogar(j0, self.chor))

    def test_ritual_ignora_slots(self):
        jogo, j0 = self._preparar()
        while len(j0.campo) < 4:
            jogo.colocar_entidade(0, carta("x"))
        with self.assertRaises(FimDeJogo):
            jogo.executar(j0, Acao("jogar", carta=self.sig))
        self.assertEqual(jogo.vencedor, 0)


class TesteBotsEDeterminismo(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.deck = carregar_pasta(PASTA_TESTE)

    def test_deck_de_teste_carrega_32(self):
        self.assertEqual(len(self.deck), 32)
        self.assertEqual(len(self.deck.cartas), 32)

    def _rodar(self, fabrica, seed):
        jogo = Jogo(self.deck, self.deck, [fabrica(), fabrica()], seed=seed, log=True)
        jogo.jogar()
        return jogo

    def test_deterministico_com_mesma_seed(self):
        for fabrica in (HeurBot, RandomBot):
            a, b = self._rodar(fabrica, 42), self._rodar(fabrica, 42)
            self.assertEqual(a.vencedor, b.vencedor)
            self.assertEqual(a.log, b.log)

    def test_partidas_terminam(self):
        for seed in range(10):
            jogo = self._rodar(HeurBot, seed)
            self.assertTrue(jogo.acabou)
            self.assertLessEqual(jogo.rodada, 41)

    def test_heur_ataca_cornucopia_quando_campo_vazio(self):
        jogo = novo_jogo(bots=[HeurBot(), HeurBot()])
        turno_de(jogo, 0, fe=0)
        a = jogo.colocar_entidade(0, carta("a", atk=2, vida=2))
        acao = jogo.bots[0].escolher_acao(jogo, jogo.jogadores[0])
        self.assertEqual(acao.tipo, "atacar")
        self.assertIs(acao.alvo, jogo.cornucopias[1])

    def test_heur_evita_troca_ruim(self):
        jogo = novo_jogo(bots=[HeurBot(), HeurBot()])
        turno_de(jogo, 0, fe=0)
        jogo.colocar_entidade(0, carta("a", atk=1, vida=1))
        jogo.colocar_entidade(1, carta("muro", atk=5, vida=5))
        self.assertIsNone(jogo.bots[0].escolher_acao(jogo, jogo.jogadores[0]))


class _BotAlvoFixo(PassivoBot):
    def __init__(self, alvo):
        self.alvo = alvo

    def escolher_alvo(self, jogo, j, candidatos, acao, ctx):
        return self.alvo if self.alvo in candidatos else candidatos[0]


if __name__ == "__main__":
    unittest.main(verbosity=1)
