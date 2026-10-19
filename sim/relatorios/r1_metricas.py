"""Métricas instrumentadas a partir do log do motor (rodada 1)."""
import sys, re, itertools, json
from collections import Counter, defaultdict
sys.path.insert(0, '/mnt/d/Projetos de Jogos/GodsKodex/sim')
from cards import carregar_pasta
from engine import Jogo
from bots import HeurBot

BASE = '/mnt/d/Projetos de Jogos/GodsKodex/cartas/'
NOMES = ['indigena', 'cristianismo', 'taoismo', 'hinduismo', 'bruxaria', 'alta_magia']
DECKS = {n: carregar_pasta(BASE + n) for n in NOMES}
N = int(sys.argv[1]) if len(sys.argv) > 1 else 400

custo_por_nome = {}
lendarias = set()
selos = set()
for d in DECKS.values():
    for c in d.cartas:
        custo_por_nome[c.nome] = c.custo
        if c.lendaria:
            lendarias.add(c.nome)
        if c.tipo == 'selo':
            selos.add(c.nome)

re_ent = re.compile(r"<([^<>]+?) (\d+)/(-?\d+) j(\d)>")
re_corn = re.compile(r"cornucópia j(\d) -(\d+) = ")


def analisar(log, nomes_lado):
    """nomes_lado: {0: deck, 1: deck}. Devolve dict de contadores para esta partida."""
    m = Counter()
    linhas = [l.split('] ', 1)[1] if '] ' in l else l for l in log]
    # fonte de dano à cornucópia
    for i, l in enumerate(linhas):
        mc = re_corn.search(l)
        if mc:
            alvo, n = int(mc.group(1)), int(mc.group(2))
            fonte_deck = nomes_lado[1 - alvo]
            prev = linhas[i - 1] if i else ''
            nxt = linhas[i + 1] if i + 1 < len(linhas) else ''
            if 'ataca Cornucopia' in prev:
                m[('corn_ataque', fonte_deck)] += n
            elif nxt.startswith('fadiga'):
                m[('corn_fadiga', nomes_lado[alvo])] += n
            else:
                m[('corn_efeito', fonte_deck)] += n
        if 'ataca Cornucopia' in l:
            me = re_ent.search(l)
            if me:
                m[('ataques_corn', nomes_lado[int(me.group(4))])] += 1
        if ' ataca <' in l:
            me = re_ent.search(l)
            if me:
                m[('ataques_ent', nomes_lado[int(me.group(4))])] += 1
        mj = re.match(r"j(\d) joga (.+)$", l)
        if mj:
            jd, nome = nomes_lado[int(mj.group(1))], mj.group(2)
            m[('joga', jd, nome)] += 1
            if nome in selos:
                m[('selo_posto', jd, nome)] += 1
            # Juízo Final / Monan / Hécate: mortes em seguida
            if nome in ('Juízo Final', 'Fogo de Monan', 'Pó de Ossos', 'Praga dos Gafanhotos', 'Granizo e Fogo', 'Brahmastra', 'Tandava', 'Ritual Menor do Pentagrama'):
                k = i + 1
                while k < len(linhas) and (linhas[k].startswith('morre') or linhas[k].startswith('gatilho') or linhas[k].startswith('renasce') or linhas[k].startswith('selo')):
                    if linhas[k].startswith('morre'):
                        me = re_ent.search(linhas[k])
                        lado = 'inimigas' if int(me.group(4)) != int(mj.group(1)) else 'proprias'
                        m[('mortes_por', jd, nome, lado)] += 1
                    k += 1
        ms = re.match(r"selo (.+) dispara \((\w+)\)", l)
        if ms:
            nome = ms.group(1)
            # dono do selo: o não-ativo; o log tem jX do ativo no prefixo
            ativo = int(re.search(r"j(\d)\]", log[i]).group(1))
            dono = nomes_lado[1 - ativo]
            m[('selo_dispara', dono, nome)] += 1
            if nome == 'Selo de Salomão':
                # carta anulada: última linha "jX joga Y" antes
                for k in range(i - 1, -1, -1):
                    mj2 = re.match(r"j(\d) joga (.+)$", linhas[k])
                    if mj2:
                        alvo = mj2.group(2)
                        m[('salomao_anula_custo', custo_por_nome.get(alvo, 0))] += 1
                        if alvo in lendarias:
                            m[('salomao_anula_lendaria',)] += 1
                        break
        mg = re.match(r"gatilho (\w+) de <([^<>]+?) (\d+)/(-?\d+) j(\d)>", l)
        if mg:
            gat, nome, atk, vida, jd = mg.group(1), mg.group(2), int(mg.group(3)), int(mg.group(4)), nomes_lado[int(mg.group(5))]
            m[('gatilho', jd, nome, gat)] += 1
            if nome == 'Cobra-Grande' and gat == 'enemy_dies':
                m[('cobra_atk_max',)] = max(m[('cobra_atk_max',)], atk + 1)
            if nome == 'Hanuman' and gat == 'on_attack':
                m[('hanuman_atk_max',)] = max(m[('hanuman_atk_max',)], atk + 1)
            if nome == 'Davi, o Pastor' and gat == 'on_attack':
                nxt = linhas[i + 1] if i + 1 < len(linhas) else ''
                if nxt.startswith('morre'):
                    me = re_ent.search(nxt)
                    if me and int(me.group(4)) != int(mg.group(5)):
                        m[('davi_mata',)] += 1
            if nome in ('Tupã, o Trovão', 'Kali', 'Elias, Carro de Fogo', 'Hécate, Senhora das Encruzilhadas', 'Sansão') and gat in ('on_play', 'on_death'):
                k = i + 1
                while k < len(linhas) and (linhas[k].startswith('morre') or linhas[k].startswith('renasce') or linhas[k].startswith('gatilho') or linhas[k].startswith('selo')):
                    if linhas[k].startswith('morre'):
                        me = re_ent.search(linhas[k])
                        if me and int(me.group(4)) != int(mg.group(5)):
                            m[('mortes_por', jd, nome, 'inimigas')] += 1
                    k += 1
        mr = re.match(r"j(\d) rouba <([^<>]+?) (\d+)/(-?\d+) j(\d)>", l)
        if mr:
            nome = mr.group(2)
            m[('rouba', nome in lendarias, custo_por_nome.get(nome, 0))] += 1
        mv = re.match(r"j(\d) revive (.+) para o campo", l)
        if mv:
            jd, nome = nomes_lado[int(mv.group(1))], mv.group(2)
            prev = linhas[i - 1] if i else ''
            fonte = 'outro'
            for k in range(i - 1, max(-1, i - 4), -1):
                if 'Caldeirão' in linhas[k]:
                    fonte = 'Caldeirão'; break
                if 'Pássaro Vermelho' in linhas[k]:
                    fonte = 'Pássaro'; break
                if 'Tumba Vazia' in linhas[k]:
                    fonte = 'Tumba'; break
                mj3 = re.match(r"j(\d) joga (.+)$", linhas[k])
                if mj3:
                    fonte = mj3.group(2); break
            m[('revive_campo', jd, fonte, nome)] += 1
            if nome in lendarias:
                m[('revive_campo_lendaria', jd, fonte)] += 1
    return m


def rodar(a, b, n, seed=11):
    da, db = DECKS[a], DECKS[b]
    tot = Counter()
    jogos = []
    for i in range(n):
        jogo = Jogo(da, db, [HeurBot(), HeurBot()], seed=seed * 1_000_003 + i, primeiro=i % 2, log=True)
        jogo.jogar()
        nomes_lado = {0: a + '@A', 1: b + '@B'}
        m = analisar(jogo.log, nomes_lado)
        m[('partidas',)] = 1
        m[('rodadas',)] = jogo.rodada
        m[('rod<6',)] = 1 if jogo.rodada < 6 else 0
        m[('rod>14',)] = 1 if jogo.rodada > 14 else 0
        if jogo.vencedor is not None:
            m[('vence', nomes_lado[jogo.vencedor])] += 1
        # Jaci
        jaci = any('joga Jaci' in l for l in jogo.log)
        m[('jaci_jogos',)] += jaci
        m[('jaci_rodadas',)] += jogo.rodada if jaci else 0
        m[('jaci_vence',)] += 1 if (jaci and jogo.vencedor is not None and nomes_lado[jogo.vencedor].startswith('indigena')) else 0
        bab = any('joga Babalon' in l for l in jogo.log)
        m[('babalon_jogos',)] += bab
        tot.update(m)
    return tot


def main():
    saida = {}
    pares = list(itertools.combinations(NOMES, 2)) + [(n, n) for n in NOMES]
    for a, b in pares:
        t = rodar(a, b, N)
        saida[f'{a} x {b}'] = {str(k): v for k, v in t.items()}
        P = t[('partidas',)]
        print(f"\n===== {a} x {b}  (n={P})  rodadas méd {t[('rodadas',)]/P:.1f}  <6: {100*t[('rod<6',)]/P:.0f}%  >14: {100*t[('rod>14',)]/P:.0f}%")
        for lado in (a + '@A', b + '@B'):
            print(f"  [{lado}] dano Cornucópia por fonte: ataque {t[('corn_ataque', lado)]/P:.1f}  efeito {t[('corn_efeito', lado)]/P:.1f}  (fadiga sofrida {t[('corn_fadiga', lado)]/P:.1f}) | ataques: corn {t[('ataques_corn', lado)]/P:.1f} ent {t[('ataques_ent', lado)]/P:.1f}")
            # selos
            for k, v in sorted(t.items()):
                if k[0] == 'selo_posto' and k[1] == lado:
                    disp = t[('selo_dispara', lado, k[2])]
                    print(f"     selo {k[2]:<26} postos {v:>4} disparos {disp:>4} ({100*disp/max(1,v):.0f}%)")
        # específicos
        esp = defaultdict(float)
        for k, v in t.items():
            if k[0] in ('gatilho',) and k[2] in ('Boitatá', 'Anhangá', 'Babalon, a Mulher Escarlate', 'Davi, o Pastor', 'Hanuman', 'Cobra-Grande', 'Kali', 'Curupira', 'Mapinguari'):
                esp[(k[2], k[3])] += v
            if k[0] in ('mortes_por', 'revive_campo', 'revive_campo_lendaria', 'rouba', 'salomao_anula_custo', 'salomao_anula_lendaria', 'davi_mata'):
                esp[k] += v
        for k in sorted(esp, key=str):
            print(f"     {str(k):<80} {esp[k]:.0f}")
        if t[('cobra_atk_max',)]:
            print(f"     cobra_atk_max (soma por partida onde disparou) {t[('cobra_atk_max',)]}")
        if t[('hanuman_atk_max',)]:
            print(f"     hanuman_atk_max soma {t[('hanuman_atk_max',)]}")
        if t[('jaci_jogos',)]:
            print(f"     Jaci: jogos {t[('jaci_jogos',)]} rodadas méd {t[('jaci_rodadas',)]/t[('jaci_jogos',)]:.1f} WR indígena c/ Jaci {100*t[('jaci_vence',)]/t[('jaci_jogos',)]:.0f}%")
        if t[('babalon_jogos',)]:
            g = sum(v for k, v in t.items() if k[0]=='gatilho' and k[2].startswith('Babalon'))
            print(f"     Babalon: jogos {t[('babalon_jogos',)]} gatilhos/jogo {g/t[('babalon_jogos',)]:.2f}")
        for lado in (a + '@A', b + '@B'):
            jog = {k[2]: v for k, v in t.items() if k[0] == 'joga' and k[1] == lado}
            print(f"  [{lado}] jogadas/partida: " + ", ".join(f"{n[:14]}={v/P:.2f}" for n, v in sorted(jog.items(), key=lambda kv: -kv[1])[:12]))
    json.dump(saida, open('/tmp/claude-1000/-mnt-d/1ab27e6c-b814-4b43-9cfa-26ff299ace8f/scratchpad/metricas.json', 'w'), ensure_ascii=False, indent=0)


if __name__ == '__main__':
    main()
