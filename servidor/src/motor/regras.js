// Motor JUIZ do KodeX (online): as mesmas regras de godot/mesa.gd + godot/motor_efeitos.gd, sem animação, na mesma
// ordem de execução (para dar o mesmo resultado carta por carta). Lados são GLOBAIS (0 e 1), não "eu/ele".
//
// A partida inteira é um gerador: `const g = partida.rodar()`; cada `g.next(valor)` avança até o próximo pedido:
//   {tipo: "mulligan", jogador}                → valor: [índices da mão a trocar] (até 2)
//   {tipo: "acao", jogador}                    → valor: {tipo: "jogar"|"mover"|"atacar"|"golpe"|"fim"|"desistir", ...}
//   {tipo: "escolha", jogador, cands, op}      → valor: índice em cands (−1 = pular)
//   {tipo: "sim_nao", jogador, pergunta}       → valor: true/false (reembaralhar o cemitério)
// Sorteios passam por `opcoes.sorteio`: {int(n) → 0..n−1, ordem(lado, lista) → a lista embaralhada (ids no começo da
// partida, cartas depois)}. No servidor é o
// gerador do juiz; no teste de conferência são os sorteios gravados pelo jogo.
// Eventos (`partida.eventos`) descrevem o que aconteceu, para o servidor repassar a cada jogador o que ele pode ver.

import { CARTAS, TOKENS } from "./cartas.js";

const CORNUCOPIA_MAX = 15, FE_MAX = 8, SLOTS = 4, MAO_MAX = 7, MAO_INICIAL = 4, TURNOS_MAX = 80, MULLIGAN_MAX = 2;
const CUSTO_REEMBARALHAR = 5;
const CHORONZON = { entidade: "aby_choronzon", reliquia: "aby_triangulo", selo: "aby_circulo" };
export const ALVOS_ESCOLHIDOS = ["enemy_entity", "ally_entity", "ally_graveyard_entity"];

// ---------------- carta ----------------
let _uid = 0;
class Carta {
  constructor(dados, dono) {
    this.uid = ++_uid;
    this.sem_renascer = false;
    this.definir(dados, dono);
  }
  definir(d, quem) {
    this.id = d.id; this.nome = d.nome; this.tipo = d.tipo; this.custo = d.custo | 0;
    this.atk = d.atk != null ? d.atk | 0 : 0;
    this.defe = d.vida != null ? d.vida | 0 : 0;
    this.keywords = [...(d.keywords || [])];
    this.lendaria = !!d.lendaria;
    this.dono = quem; this.dano = 0;
    this.dados = d;
    this.dono_real = quem;
    this.token = !!d.token;
    this.em_campo = false; this.turno_posto = -1;
    this.resetar();
  }
  vida() { return this.defe - this.dano; }
  tem(kw) { return this.keywords.includes(kw) || this.aura_keywords.includes(kw); }
  protegida() { return this.tem("furtivo") && !this.ja_atacou; }
  sincronizar() {
    this.atk = Math.max(0, this.atk_base + this.buff_atk + this.temp_atk + this.aura_atk + this.rel_atk);
    this.defe = this.vida_base + this.buff_vida + this.temp_vida + this.aura_vida + this.rel_vida;
  }
  limpar_stats() {
    this.buff_atk = 0; this.buff_vida = 0; this.temp_atk = 0; this.temp_vida = 0; this.rel_atk = 0; this.rel_vida = 0;
    this.dano = 0;
    this.sincronizar();
  }
  resetar() {
    const d = this.dados;
    if (!d) return;
    this.atk_base = d.atk != null ? d.atk | 0 : 0;
    this.vida_base = d.vida != null ? d.vida | 0 : 0;
    this.keywords = [...(d.keywords || [])];
    if (this.sem_renascer) this.keywords = this.keywords.filter((k) => k !== "renascer");
    this.efeitos = d.efeitos || [];
    this.buff_atk = 0; this.buff_vida = 0; this.temp_atk = 0; this.temp_vida = 0; this.aura_atk = 0; this.aura_vida = 0;
    this.rel_atk = 0; this.rel_vida = 0;
    this.aura_keywords = [];
    this.dano = 0;
    this.silenciada = false; this.congelada = false; this.sem_ataque = false; this.ja_atacou = false;
    this.reliquia = null;
    this.roubada_temp = false;
    this.cansada = false; this.atacou = false;
    this.dono = this.dono_real;
    this.sincronizar();
  }
}

const ehCarta = (x) => x instanceof Carta;
const custoDe = (o) => (ehCarta(o) ? o.custo : o && o.dados ? o.dados.custo | 0 : null);

// ---------------- partida ----------------
export class Partida {
  constructor({ decks, primeiro = 0, sorteio, humano = [true, true], cornucopia = [15, 15] }) {
    this.sorteio = sorteio;
    this.humano = humano;                       // false = decisões automáticas (iguais à IA do jogo)
    this.deckIds = decks;
    this.primeiro = primeiro;
    this.cornucopia = [...cornucopia];
    this.fe = [0, 0]; this.fe_max = [0, 0];
    this.mao = [[], []]; this.deck = [[], []]; this.cemit = [[], []];
    this.campo_ent = [[null, null, null, null], [null, null, null, null]];
    this.campo_selo = [[null, null], [null, null]];
    this.ativo = primeiro; this.turno_n = 0; this.selo_no_turno = false;
    this.acabou = false; this.vencedor = -1; this.motivo_fim = "";
    this.prof_dano = 0;
    this.eventos = [];
    this.estat = [{}, {}];
  }

  ev(tipo, dados = {}) { this.eventos.push({ tipo, ...dados }); }
  conta(d, k) { this.estat[d][k] = (this.estat[d][k] | 0) + 1; }
  carta(cid, dono) {
    const d = CARTAS[cid];
    if (!d) throw new Error("carta desconhecida: " + cid);
    return new Carta(d, dono);
  }

  // ---------- consultas ----------
  campo(d) { return this.campo_ent[d].filter((c) => c !== null); }
  espacoLivre(arr) { return arr.findIndex((x) => x === null); }
  temSlot(d) { return this.espacoLivre(this.campo_ent[d]) >= 0; }
  entidadesCemit(d) { return this.cemit[d].filter((e) => e.dados.tipo === "entidade"); }
  campoVazio(d) { return this.campo(d).length === 0; }
  valor(c) { return ehCarta(c) ? c.atk + c.vida() + c.keywords.length + c.efeitos.length + (c.reliquia ? 2 : 0) : 0; }
  podeAtacarFlag(c) { return c.em_campo && !c.atacou && !c.sem_ataque && (!c.cansada || c.tem("impeto")); }
  portadoras(d) { return this.campo(d).filter((e) => !e.reliquia); }

  // ---------- início ----------
  *rodar() {
    for (const d of [0, 1]) {                   // decks: cada lado embaralha com a sua sequência
      const ordem = this.sorteio.ordem(d, [...this.deckIds[d]]);
      this.deck[d] = ordem.map((cid) => this.carta(cid, d));
    }
    this.ev("inicio", { primeiro: this.primeiro });
    for (let k = 0; k < MAO_INICIAL; k++)
      for (const d of [0, 1]) this.receberComprada(d, this.deck[d].pop(), false);
    for (const d of [0, 1]) {                   // mão inicial: troca até 2 (os dois decidem; aplica em ordem)
      const idx = yield { tipo: "mulligan", jogador: d };
      const trocar = [];
      for (const k of (Array.isArray(idx) ? idx : []).slice(0, MULLIGAN_MAX)) {
        const c = this.mao[d][k | 0];
        if (c && !trocar.includes(c)) trocar.push(c);
      }
      this.trocarMao(d, trocar);
    }
    yield* this.partida();
    return this.vencedor;
  }

  trocarMao(d, trocar) {
    if (!trocar.length) return;
    for (const c of trocar) {
      this.mao[d].splice(this.mao[d].indexOf(c), 1);
      this.deck[d].unshift(c);
    }
    this.embaralharDeck(d);
    this.ev("mulligan", { jogador: d, n: trocar.length });
    for (let k = 0; k < trocar.length; k++) this.receberComprada(d, this.deck[d].pop(), false);
  }

  embaralharDeck(d) {
    this.deck[d] = this.sorteio.ordem(d, [...this.deck[d]]);   // recebe e devolve as próprias cartas
  }

  // ---------- turnos ----------
  *partida() {
    this.ativo = this.primeiro;
    this.turno_n = 0;
    while (!this.acabou) {
      this.turno_n++;
      if (this.turno_n > TURNOS_MAX) { this.vencedor = 2; this.acabou = true; this.motivo_fim = "turnos"; break; }
      yield* this.inicioTurno(this.ativo);
      if (this.acabou) break;
      this.ev("turno", { jogador: this.ativo, n: this.turno_n });
      while (!this.acabou) {                    // ações do jogador da vez até "fim"
        const a = yield { tipo: "acao", jogador: this.ativo };
        if (!a || a.tipo === "fim") break;
        if (a.tipo === "desistir") { this.encerrar(1 - this.ativo, "desistencia"); break; }
        yield* this.executarJogada(this.ativo, a);
      }
      if (this.acabou) break;
      yield* this.fimTurno(this.ativo);
      if (this.acabou) break;
      this.ativo = 1 - this.ativo;
    }
  }

  /** O outro lado desistiu fora da vez (ex.: no turno do adversário). */
  desistir(jogador) { if (!this.acabou) this.encerrar(1 - jogador, "desistencia"); }

  *inicioTurno(d) {
    this.fe_max[d] = Math.min(FE_MAX, this.fe_max[d] + 1);
    this.fe[d] = this.fe_max[d];
    if (this.turno_n === 2) this.fe[d] += 1;   // quem joga em segundo: +1 Fé no 1º turno dele
    this.selo_no_turno = false;
    for (const c of this.campo(d)) {
      c.cansada = false; c.atacou = false;
      c.sem_ataque = c.congelada; c.congelada = false;
    }
    if (this.turno_n !== 1) yield* this.comprar(d);
    if (this.acabou) return;
    this.recalcularAuras();
    yield* this.dispararEntidades("start_turn", d, {});
    this.checarFim();
  }

  *fimTurno(d) {
    yield* this.dispararEntidades("end_turn", d, {});
    yield* this.dispararSelos("enemy_end_turn", 1 - d, {});
    for (const j of [0, 1])
      for (const c of this.campo(j)) {
        c.temp_atk = 0; c.temp_vida = 0;
        if (c.roubada_temp) this.devolverControle(c);
      }
    this.recalcularAuras();
    yield* this.processarMortes();
    const mao = this.mao[d];
    while (mao.length > MAO_MAX && !this.acabou) {
      let cara = mao[0];
      for (const c of mao) if (c.custo > cara.custo) cara = c;
      this.descartar(d, cara);
    }
    this.checarFim();
  }

  checarFim() {
    if (this.acabou) return;
    const m0 = this.cornucopia[0] <= 0, m1 = this.cornucopia[1] <= 0;
    if (m0 && m1) this.encerrar(2); else if (m1) this.encerrar(0); else if (m0) this.encerrar(1);
  }
  encerrar(v, motivo = "") {
    if (this.acabou) return;
    this.acabou = true; this.vencedor = v; this.motivo_fim = motivo;
    this.ev("fim", { vencedor: v, motivo });
  }

  // ---------- compra, mão, cemitério ----------
  podeReembaralhar(d) {
    return this.cornucopia[d] >= CUSTO_REEMBARALHAR + 1 && this.cemit[d].some((e) => !e.dados.token);
  }
  *comprar(d) {
    if (!this.deck[d].length && this.podeReembaralhar(d)) {
      let sim = true;
      if (this.humano[d]) sim = !!(yield { tipo: "sim_nao", jogador: d, pergunta: "reembaralhar" });
      else if (this.cemit[d].length < 3 && this.cornucopia[d] < 10) sim = false;   // IA: quase nada no cemitério
      if (sim) this.reembaralhar(d);
    }
    if (!this.deck[d].length) {
      this.cornucopia[d] -= 2;
      this.ev("fadiga", { jogador: d });
      this.checarFim();
      return;
    }
    this.receberComprada(d, this.deck[d].pop());
  }
  reembaralhar(d) {
    this.cornucopia[d] -= CUSTO_REEMBARALHAR;
    const entradas = this.cemit[d];
    this.cemit[d] = [];
    for (const e of entradas) {
      if (e.dados.token) continue;
      const c = e.no && !e.no._liberada ? e.no : new Carta(e.dados, d);
      c.definir(e.dados, d);
      c.resetar();
      c.em_campo = false;
      this.deck[d].push(c);
    }
    this.embaralharDeck(d);
    this.ev("reembaralhar", { jogador: d });
    this.checarFim();
  }
  receberComprada(d, c, queimar = true) {
    if (queimar && this.mao[d].length >= MAO_MAX) {   // mão cheia: a comprada queima
      this.cemit[d].push({ dados: c.dados, no: null });
      c._liberada = true;
      this.ev("queima", { jogador: d, uid: c.uid, id: c.id });
      return;
    }
    this.mao[d].push(c);
    this.ev("compra", { jogador: d, uid: c.uid, id: c.id });
  }
  entrarNaMao(d, c) {
    c.resetar();
    c.em_campo = false;
    c.dono = d; c.dono_real = d;
    this.mao[d].push(c);
    this.ev("volta_mao", { jogador: d, uid: c.uid, id: c.id });
  }
  descartar(d, c) {
    this.mao[d].splice(this.mao[d].indexOf(c), 1);
    this.cemit[d].push({ dados: c.dados, no: null });
    c._liberada = true;
    this.ev("descarte", { jogador: d, uid: c.uid, id: c.id });
  }
  removerDoCampo(c) {
    const i = this.campo_ent[c.dono].indexOf(c);
    if (i >= 0) this.campo_ent[c.dono][i] = null;
    return i;
  }
  porEmCampo(c, d, i) {
    this.campo_ent[d][i] = c;
    c.dono = d; c.em_campo = true; c.atacou = false; c.cansada = true;
    this.recalcularAuras();
    this.ev("campo", { jogador: d, slot: i, uid: c.uid, id: c.id });
  }
  destruirVisual(c) {                          // mesa._destruir em partida: o motor já decidiu o destino
    this.removerDoCampo(c);
    c.em_campo = false;
    c.dono = c.dono_real;
    c.resetar();
  }
  desfazer(c) { this.removerDoCampo(c); c.em_campo = false; c._liberada = true; }

  // ---------- jogar ----------
  motivoJogar(c, d) {
    if (c.custo > this.fe[d]) return "SEM FÉ";
    if (c.tipo === "entidade") {
      const sac = c.dados.sacrificio | 0, n = this.campo(d).length;
      if (sac > 0 && n < sac) return "SACRIFÍCIO";
      if (n - sac >= 4) return "CAMPO CHEIO";
    } else if (c.tipo === "selo") {
      if (this.selo_no_turno) return "1 SELO POR TURNO";
      if (this.espacoLivre(this.campo_selo[d]) < 0) return "SEM ESPAÇO";
    } else if (c.tipo === "reliquia") {
      if (!this.portadoras(d).length) return "SEM PORTADORA";
    } else if (this.ritoModo(c, d) === "sem_alvo") return "SEM ALVO";
    return "";
  }
  ritoModo(c, d) {
    const tipo = alvoEscolhido(c.dados);
    if (!tipo) return "area";
    if (this.candidatos(tipo, d, c.dados).length) return tipo === "ally_graveyard_entity" ? "cemiterio" : "alvo";
    for (const ef of c.dados.efeitos || [])
      for (const a of ef.acoes) {
        const al = String(a.alvo ?? "");
        if (al === tipo) continue;
        if (!ALVOS_ESCOLHIDOS.includes(al) || this.candidatos(al, d, c.dados).length) return "area";
      }
    return "sem_alvo";
  }
  podeAtacar(c, alvo) {
    if (c.sem_ataque) return "CONGELADA";
    if (c.cansada && !c.tem("impeto")) return "CANSADA";
    if (c.atacou) return "JÁ ATACOU";
    const ini = 1 - c.dono;
    if (alvo === null) return this.campoVazio(ini) ? "" : "HÁ DEFENSORES";
    const guardas = this.campo(ini).filter((e) => e.tem("guarda"));
    if (guardas.length && !guardas.includes(alvo)) return "GUARDA";
    return "";
  }

  /** Jogada do jogador da vez. Inválida = ignorada (o servidor também avisa o celular). Devolve "" ou o motivo. */
  *executarJogada(d, a) {
    switch (a.tipo) {
      case "jogar": {
        const c = this.mao[d][a.k | 0];
        if (!c) return "carta fora da mão";
        const motivo = this.motivoJogar(c, d);
        if (motivo) return motivo;
        if (c.tipo === "entidade") {
          const sac = c.dados.sacrificio | 0;
          const sacs = [];
          for (const s of a.sac || []) { const e = this.campo_ent[d][Math.max(0, Math.min(3, s | 0))]; if (e && !sacs.includes(e)) sacs.push(e); }
          if (sacs.length < sac) return "sacrifício";
          let i = a.i ?? -1;
          if (sac === 0 && (i < 0 || i > 3 || this.campo_ent[d][i] !== null)) i = this.espacoLivre(this.campo_ent[d]);
          yield* this.jogarEntidade(c, d, i | 0, sacs.slice(0, sac));
        } else if (c.tipo === "selo") {
          let i = a.i | 0;
          if (i < 0 || i > 1 || this.campo_selo[d][i] !== null) i = this.espacoLivre(this.campo_selo[d]);
          this.jogarSelo(c, d, i);
        } else if (c.tipo === "reliquia") {
          const ports = this.portadoras(d);
          const p = ports[a.p | 0];
          if (!p) return "portadora";
          yield* this.jogarReliquia(c, d, p);
        } else {
          const modo = this.ritoModo(c, d);
          if (modo === "area" || a.a == null) yield* this.jogarRito(c, d);   // sem alvo prévio: escolhe ao resolver
          else {
            const tipo = alvoEscolhido(c.dados);
            const cands = this.candidatos(tipo, d, c.dados);
            const alvo = cands[a.a | 0];
            if (!alvo) return "alvo";
            yield* this.jogarRito(c, d, alvo, tipo);
          }
        }
        return "";
      }
      case "mover": {
        const de = a.de | 0, para = a.para | 0;
        const c = this.campo_ent[d][de];
        if (!c || de === para || para < 0 || para > 3 || this.campo_ent[d][para] !== null) return "mover";
        this.campo_ent[d][de] = null; this.campo_ent[d][para] = c;
        this.ev("mover", { jogador: d, de, para, uid: c.uid });
        return "";
      }
      case "atacar": case "golpe": {
        const c = this.campo_ent[d][a.de | 0];
        if (!c) return "atacante";
        const alvo = a.tipo === "golpe" ? null : this.campo_ent[1 - d][a.alvo | 0];
        if (a.tipo === "atacar" && !alvo) return "alvo";
        const m = this.podeAtacar(c, alvo);
        if (m) return m;
        if (alvo === null) yield* this.golpeDireto(c, 1 - d); else yield* this.atacar(c, alvo);
        return "";
      }
    }
    return "ação desconhecida";
  }

  pagar(d, custo) { this.fe[d] -= custo; }

  *jogarEntidade(c, d, i, sacrificios = []) {
    this.conta(d, "entidades");
    if (c.lendaria) this.conta(d, "lendarias");
    this.pagar(d, c.custo);
    this.mao[d].splice(this.mao[d].indexOf(c), 1);
    this.ev("joga", { jogador: d, uid: c.uid, id: c.id, tipo: "entidade" });
    for (const s of sacrificios) yield* this.morrer(s, false);
    yield* this.processarMortes();
    if (i < 0 || this.campo_ent[d][i] !== null) i = this.espacoLivre(this.campo_ent[d]);
    if (i < 0) { this.cemit[d].push({ dados: c.dados, no: null }); c._liberada = true; return; }
    this.porEmCampo(c, d, i);
    const ctx = { triggering: c, attacker: null };
    yield* this.dispararSelos("enemy_plays_entity", 1 - d, ctx);
    if (ctx.anulado) {
      if (c.em_campo) {
        this.removerDoCampo(c);
        c.em_campo = false;
        this.cemit[d].push({ dados: c.dados, no: c });
        this.destruirVisual(c);
        this.recalcularAuras();
      }
      this.checarFim();
      return;
    }
    yield* this.processarMortes();
    if (c.em_campo && !this.acabou) {
      yield* this.dispararEfeitosEntidade(c, "on_play", { triggering: c, interativo: this.humano[d] });
      yield* this.processarMortes();
    }
    this.checarFim();
  }

  jogarSelo(c, d, i) {
    this.conta(d, "selos");
    this.pagar(d, c.custo);
    this.mao[d].splice(this.mao[d].indexOf(c), 1);
    this.campo_selo[d][i] = c;
    this.selo_no_turno = true;
    c.dono = d;
    c.turno_posto = this.turno_n;
    this.ev("selo", { jogador: d, slot: i, uid: c.uid, id: c.id });   // o adversário não vê o id
  }

  *jogarRito(c, d, pre = null, tipoPre = "") {
    this.conta(d, "ritos");
    this.pagar(d, c.custo);
    this.mao[d].splice(this.mao[d].indexOf(c), 1);
    this.ev("joga", { jogador: d, uid: c.uid, id: c.id, tipo: "rito" });
    const ctx = { triggering: c, attacker: null, dono: d, fonte: c, self: null, interativo: this.humano[d] };
    if (pre !== null && tipoPre) ctx["_esc_" + tipoPre] = pre;
    yield* this.dispararSelos("enemy_plays_rite", 1 - d, ctx);
    if (!ctx.anulado) {
      for (const ef of c.dados.efeitos || []) {
        if (this.acabou) break;
        if (this.condOk(ef.cond, ctx)) yield* this.executarAcoes(ef.acoes, ctx);
      }
    }
    this.cemit[d].push({ dados: c.dados, no: null });
    c._liberada = true;
    yield* this.processarMortes();
    this.checarFim();
  }

  *jogarReliquia(c, d, port) {
    this.conta(d, "reliquias");
    this.pagar(d, c.custo);
    this.mao[d].splice(this.mao[d].indexOf(c), 1);
    c._liberada = true;
    const rel = { dados: c.dados, nome: c.nome, usos: c.dados.usos ?? null, portadora: port, dono: d };
    port.reliquia = rel;
    this.ev("reliquia", { jogador: d, uid: c.uid, id: c.id, portadora: port.uid });
    const ctx = { triggering: rel, attacker: null, equipped: port };
    yield* this.dispararSelos("enemy_plays_reliquia", 1 - d, ctx);
    if (ctx.anulado) {
      this.removerReliquia(rel);
      yield* this.processarMortes();
      this.checarFim();
      return;
    }
    yield* this.processarMortes();
    if (port.reliquia === rel && port.em_campo && !this.acabou) {
      yield* this.dispararEfeitosReliquia(rel, "on_equip", { triggering: rel, interativo: this.humano[d] });
      this.recalcularAuras();
      yield* this.processarMortes();
    }
    this.checarFim();
  }

  // ---------- combate ----------
  *atacar(c, alvo) {
    c.atacou = true;
    this.conta(c.dono, "ataques");
    this.ev("ataque", { jogador: c.dono, uid: c.uid, alvo: alvo.uid });
    if (!(yield* this.antesDoAtaque(c, alvo))) { this.checarFim(); return; }
    const da = c.atk, dd = alvo.atk;
    alvo.dano += da;
    c.dano += dd;
    yield* this.posDano(alvo, da, c, c);
    yield* this.posDano(c, dd, alvo, null);
    yield* this.processarMortes();
    this.checarFim();
  }
  *golpeDireto(c, alvoDono) {
    c.atacou = true;
    this.conta(c.dono, "golpes_diretos");
    this.ev("golpe", { jogador: c.dono, uid: c.uid });
    if (!(yield* this.antesDoAtaque(c, null))) { this.checarFim(); return; }
    this.cornucopia[alvoDono] -= c.atk;
    this.checarFim();
  }
  *antesDoAtaque(atacante, alvo) {
    atacante.atacou = true;
    atacante.ja_atacou = true;
    const ini = 1 - atacante.dono;
    const trig = alvo !== null ? alvo : { cornucopia: ini };
    const ctx = { attacker: atacante, triggering: trig, defender: alvo };
    yield* this.dispararEfeitosEntidade(atacante, "on_attack", ctx);
    if (atacante.reliquia) yield* this.dispararEfeitosReliquia(atacante.reliquia, "equipped_attacks", ctx);
    if (alvo === null) yield* this.dispararSelos("enemy_attacks_cornucopia", ini, ctx);
    else {
      yield* this.dispararSelos("enemy_attacks", ini, ctx);
      yield* this.dispararEntidades("ally_attacked", ini, ctx, alvo);
    }
    yield* this.processarMortes();
    if (this.acabou || !atacante.em_campo || atacante.dono !== 1 - ini) return false;
    if (alvo !== null && (!alvo.em_campo || alvo.dono !== ini)) return false;
    return true;
  }

  // ---------- auras ----------
  recalcularAuras() {
    for (const d of [0, 1]) for (const c of this.campo(d)) { c.aura_atk = 0; c.aura_vida = 0; c.aura_keywords = []; }
    for (const d of [0, 1])
      for (const c of this.campo(d)) {
        const fontes = [];
        if (!c.silenciada) for (const ef of c.efeitos) if (ef.gatilho === "static") fontes.push(ef);
        if (c.reliquia) for (const ef of c.reliquia.dados.efeitos || []) if (ef.gatilho === "static") fontes.push(ef);
        for (const ef of fontes) this.aplicarAura(ef, c);
      }
    for (const d of [0, 1]) for (const c of this.campo(d)) c.sincronizar();
  }
  aplicarAura(ef, fonte) {
    const ctx = { dono: fonte.dono, self: fonte, triggering: fonte };
    if (!this.condOk(ef.cond, ctx)) return;
    const eu = this.campo(fonte.dono), ini = this.campo(1 - fonte.dono);
    for (const a of ef.acoes) {
      let alvos = [];
      switch (String(a.alvo ?? "")) {
        case "all_ally_entities": alvos = eu; break;
        case "other_ally_entities": alvos = eu.filter((t) => t !== fonte); break;
        case "all_enemy_entities": alvos = ini; break;
        case "all_entities": alvos = eu.concat(ini); break;
      }
      for (const t of alvos) {
        if (a.op === "buff") { t.aura_atk += a.atk | 0; t.aura_vida += a.vida | 0; }
        else if (a.op === "give_keyword" && !t.aura_keywords.includes(a.keyword)) t.aura_keywords.push(a.keyword);
      }
    }
  }

  // ---------- condições e alvos ----------
  condOk(cond, ctx) {
    if (!cond || typeof cond !== "object" || !Object.keys(cond).length) return true;
    const dono = ctx.dono, n = cond.n | 0;
    switch (cond.tipo) {
      case "ally_count_min": return this.campo(dono).length >= n;
      case "ally_count_max": return this.campo(dono).length <= n;
      case "enemy_count_min": return this.campo(1 - dono).length >= n;
      case "enemy_count_max": return this.campo(1 - dono).length <= n;
      case "hand_min": return this.mao[dono].length >= n;
      case "hand_max": return this.mao[dono].length <= n;
      case "cornucopia_below": return this.cornucopia[dono] < n;
      case "enemy_cornucopia_below": return this.cornucopia[1 - dono] < n;
      case "graveyard_entities_min": return this.entidadesCemit(dono).length >= n;
      case "fe_max_min": return this.fe_max[dono] >= n;
      case "target_cost_max": {
        const trig = ctx.triggering;
        if (trig == null || (ehCarta(trig) && trig === ctx.self)) { ctx._cost_max = n; return true; }
        const custo = custoDe(trig);
        return custo !== null && custo <= n;
      }
    }
    return true;
  }
  candidatos(tipo, d, dados = {}) {
    let cmax = null;
    for (const ef of dados.efeitos || []) if (ef.cond && ef.cond.tipo === "target_cost_max") cmax = ef.cond.n | 0;
    const ok = (c) => cmax === null || custoDe(c) <= cmax;
    if (tipo === "enemy_entity") return this.campo(1 - d).filter((c) => !c.protegida() && ok(c));
    if (tipo === "ally_entity") return this.campo(d).filter(ok);
    if (tipo === "ally_graveyard_entity") return this.entidadesCemit(d).filter((e) => cmax === null || (e.dados.custo | 0) <= cmax);
    return [];
  }
  *alvos(alvo, ctx, acao) {
    const dono = ctx.dono, cmax = ctx._cost_max ?? null;
    const custoOk = (e) => cmax === null || (custoDe(e) ?? 0) <= cmax;
    switch (String(alvo)) {
      case "self": return ehCarta(ctx.self) ? [ctx.self] : [];
      case "attacker": case "defender": return ehCarta(ctx[alvo]) ? [ctx[alvo]] : [];
      case "triggering": {
        const t = ctx.triggering;
        if (ehCarta(t) && t.dono !== dono && t.protegida()) return [];
        return t != null ? [t] : [];
      }
      case "equipped": return ehCarta(ctx.equipped) ? [ctx.equipped] : [];
      case "enemy_entity": return yield* this.escolher(dono, this.campo(1 - dono).filter((e) => !e.protegida() && custoOk(e)), acao, ctx);
      case "enemy_entity_random": return this.aleatorio(this.campo(1 - dono).filter((e) => !e.protegida() && custoOk(e)));
      case "all_enemy_entities": return this.campo(1 - dono);
      case "ally_entity": return yield* this.escolher(dono, this.campo(dono).filter(custoOk), acao, ctx);
      case "ally_entity_random": return this.aleatorio(this.campo(dono).filter(custoOk));
      case "all_ally_entities": return this.campo(dono);
      case "other_ally_entities": return this.campo(dono).filter((e) => e !== ctx.self);
      case "all_entities": return this.campo(dono).concat(this.campo(1 - dono));
      case "enemy_cornucopia": return [{ cornucopia: 1 - dono }];
      case "ally_cornucopia": return [{ cornucopia: dono }];
      case "enemy_hand_random": return this.aleatorio([...this.mao[1 - dono]]);
      case "ally_graveyard_entity":
        return yield* this.escolher(dono, this.entidadesCemit(dono).filter((e) => cmax === null || (e.dados.custo | 0) <= cmax), acao, ctx);
      case "ally_graveyard_entity_random":
        return this.aleatorio(this.entidadesCemit(dono).filter((e) => cmax === null || (e.dados.custo | 0) <= cmax));
    }
    return [];
  }
  *escolher(dono, cands, acao, ctx) {
    if (!cands.length) return [];
    const chave = "_esc_" + String(acao.alvo);
    const prev = ctx[chave];
    if (prev != null && cands.includes(prev)) return [prev];
    let esc = null;
    if (this.humano[dono] && ctx.interativo) {   // o jogador escolhe (mesmo com 1 só: pode pular)
      const v = yield { tipo: "escolha", jogador: dono, op: acao.op, alvo: acao.alvo, cands: cands.map(refDe) };
      if (!Number.isInteger(v) || v < 0 || v >= cands.length) return [];
      esc = cands[v];
    } else if (cands.length === 1) esc = cands[0];
    else esc = this.iaAlvo(dono, cands, acao);
    ctx[chave] = esc;
    return [esc];
  }
  aleatorio(cands) {
    if (!cands.length) return [];
    return [cands[this.sorteio.int(cands.length)]];
  }
  iaAlvo(_dono, cands, acao) {
    const op = acao.op, alvo = String(acao.alvo ?? "");
    if (!ehCarta(cands[0])) {
      let best = cands[0];
      for (const e of cands) if ((e.dados.custo | 0) > (best.dados.custo | 0)) best = e;
      return best;
    }
    const maxpor = (lista, f) => { let b = lista[0]; for (const e of lista) if (f(e) > f(b)) b = e; return b; };
    const valor = (e) => this.valor(e);
    if (alvo.startsWith("enemy")) {
      if (op === "damage") {
        const n = acao.n | 0;
        const mat = cands.filter((e) => e.vida() <= n);
        if (mat.length) return maxpor(mat, valor);
        return maxpor(cands, (e) => e.atk);
      }
      return maxpor(cands, valor);
    }
    if (op === "heal") { const n = acao.n | 0; return maxpor(cands, (e) => Math.min(e.dano, n)); }
    if (["buff", "give_keyword", "set_stats"].includes(op)) {
      const neg = op === "buff" && ((acao.atk | 0) < 0 || (acao.vida | 0) < 0);
      if (neg) return maxpor(cands, (e) => -valor(e));
      const prontos = cands.filter((e) => this.podeAtacarFlag(e));
      const pool = prontos.length ? prontos : cands;
      if (op === "set_stats") return maxpor(pool, (e) => -(e.atk + e.vida()));
      return maxpor(pool, (e) => e.atk);
    }
    if (["damage", "destroy", "freeze", "silence", "bounce"].includes(op)) return maxpor(cands, (e) => -valor(e));
    return maxpor(cands, valor);
  }

  // ---------- gatilhos ----------
  *dispararEntidades(gat, idx, ctxBase, excluir = null) {
    for (const c of this.campo(idx)) {
      if ((excluir !== null && c === excluir) || !c.em_campo) continue;
      yield* this.dispararEfeitosEntidade(c, gat, ctxBase);
    }
    yield* this.processarMortes();
  }
  *dispararEfeitosEntidade(c, gat, ctxBase, exigeCampo = true) {
    if (c.silenciada) return;
    for (const ef of [...c.efeitos]) {
      if (ef.gatilho !== gat) continue;
      if (exigeCampo && !c.em_campo) return;
      const ctx = { ...ctxBase, self: c, dono: c.dono, fonte: c, gatilho: gat };
      if (!("triggering" in ctxBase)) ctx.triggering = c;
      if (this.condOk(ef.cond, ctx)) {
        this.ev("gatilho", { uid: c.uid, gatilho: gat });
        yield* this.executarAcoes(ef.acoes, ctx);
      }
    }
  }
  *dispararEfeitosReliquia(rel, gat, ctxBase) {
    const port = rel.portadora;
    for (const ef of rel.dados.efeitos || []) {
      if (ef.gatilho !== gat) continue;
      if (port.reliquia !== rel) return;
      const ctx = { ...ctxBase, gatilho: gat, self: port, equipped: port, dono: port.dono, fonte: rel };
      if (this.condOk(ef.cond, ctx)) yield* this.executarAcoes(ef.acoes, ctx);
    }
    if (gat === "equipped_attacks" && rel.usos != null && port.reliquia === rel) {
      rel.usos = (rel.usos | 0) - 1;
      if (rel.usos <= 0) this.removerReliquia(rel);
    }
  }
  *dispararSelos(gat, idx, ctxBase) {
    if (this.ativo === idx) return;
    const selos = this.campo_selo[idx].filter((s) => s !== null).sort((a, b) => a.turno_posto - b.turno_posto);
    for (const s of selos) {
      if (this.acabou) return;
      const ef = s.efeitos.length ? s.efeitos[0] : null;
      if (!ef || ef.gatilho !== gat || s.turno_posto === this.turno_n || !this.campo_selo[idx].includes(s)) continue;
      const ctx = { ...ctxBase, self: null, dono: idx, fonte: s, gatilho: gat };
      if (!this.condOk(ef.cond, ctx)) continue;
      const slot = this.campo_selo[idx].indexOf(s);
      this.campo_selo[idx][slot] = null;
      this.cemit[idx].push({ dados: s.dados, no: null });
      s._liberada = true;
      this.ev("selo_dispara", { jogador: idx, slot, uid: s.uid, id: s.id });
      yield* this.executarAcoes(ef.acoes, ctx);
      if (ctx.anulado) ctxBase.anulado = true;
    }
  }

  // ---------- dano e morte ----------
  *posDano(e, n, fonte, atacante) {
    if (n <= 0 || this.prof_dano >= 8) return;
    this.prof_dano++;
    const ctx = { triggering: ehCarta(fonte) ? fonte : null, attacker: atacante };
    yield* this.dispararEfeitosEntidade(e, "on_damaged", ctx);
    yield* this.dispararSelos("ally_damaged", e.dono, { triggering: e, attacker: atacante, defender: e });
    this.prof_dano--;
  }
  danoCornucopia(idx, n) { if (n > 0) this.cornucopia[idx] -= n; }
  *processarMortes() {
    for (let k = 0; k < 50; k++) {
      const mortos = [];
      for (const idx of [this.ativo, 1 - this.ativo]) for (const c of this.campo(idx)) if (c.vida() <= 0) mortos.push(c);
      if (!mortos.length) return;
      for (const c of mortos) if (c.em_campo) yield* this.morrer(c);
    }
  }
  *morrer(c, renascer = true) {
    if (!c.em_campo) return;
    const controlador = c.dono;
    this.conta(controlador, "mortes");
    const silenciada = c.silenciada, efs = [...c.efeitos], rel = c.reliquia;
    this.removerDoCampo(c);
    c.em_campo = false;
    this.recalcularAuras();
    this.ev("morre", { jogador: controlador, uid: c.uid });
    if (c.token) this.desfazer(c);
    else if (renascer && c.keywords.includes("renascer")) { c.sem_renascer = true; this.entrarNaMao(c.dono_real, c); }
    else { this.cemit[c.dono_real].push({ dados: c.dados, no: c }); this.destruirVisual(c); }
    if (rel) {
      yield* this.dispararEfeitosReliquia(rel, "equipped_dies", { triggering: c });
      this.removerReliquia(rel);
    }
    if (!silenciada) {
      const antes = c.efeitos, sil = c.silenciada, donoAgora = c.dono;
      c.efeitos = efs; c.silenciada = false; c.dono = controlador;   // Último Sopro resolve para quem a controlava
      yield* this.dispararEfeitosEntidade(c, "on_death", { triggering: c }, false);
      c.efeitos = antes; c.silenciada = sil; c.dono = donoAgora;
    }
    const ctx = { triggering: c, attacker: null };
    yield* this.dispararEntidades("ally_dies", controlador, ctx);
    yield* this.dispararSelos("ally_dies", controlador, ctx);
    yield* this.dispararEntidades("enemy_dies", 1 - controlador, ctx);
  }
  removerReliquia(rel) {
    const port = rel.portadora;
    if (port.reliquia === rel) { port.reliquia = null; port.rel_atk = 0; port.rel_vida = 0; }
    this.cemit[rel.dono].push({ dados: rel.dados, no: null });
    this.recalcularAuras();
  }

  // ---------- ações ----------
  *executarAcoes(acoes, ctx) {
    for (const a of acoes) {
      if (this.acabou) return;
      yield* this.executarAcao(a, ctx);
    }
    this.recalcularAuras();
  }
  *executarAcao(a, ctx) {
    const op = a.op, dono = ctx.dono, fonte = ctx.fonte;
    switch (op) {
      case "draw": for (let k = 0; k < (a.n ?? 1); k++) yield* this.comprar(dono); return;
      case "search": this.buscar(dono, a); return;
      case "discard":
        for (let k = 0; k < (a.n ?? 1); k++) {
          const mao = this.mao[1 - dono];
          if (!mao.length) break;
          this.descartar(1 - dono, mao[this.sorteio.int(mao.length)]);
        }
        return;
      case "gain_fe": {
        const n = a.n ?? 1;
        if (a.perm) this.fe_max[dono] = Math.min(FE_MAX, this.fe_max[dono] + n); else this.fe[dono] += n;
        return;
      }
      case "counter": ctx.anulado = true; return;
      case "win": this.encerrar(dono, "choronzon"); return;
      case "ritual_choronzon": yield* this.ritualChoronzon(dono); return;
      case "summon": this.invocarTokens(dono, a, fonte); return;
    }
    const lista = yield* this.alvos(a.alvo, ctx, a);
    if (!lista.length) return;
    if (op === "damage") {
      const n = a.n | 0, pend = [];
      for (const t of lista) {
        if (ehCarta(t) && t.em_campo) { t.dano += n; pend.push(t); }
        else if (t && t.cornucopia != null) this.danoCornucopia(t.cornucopia, n);
      }
      for (const t of pend) yield* this.posDano(t, n, fonte, null);
    } else for (const t of lista) yield* this.aplicarEmAlvo(op, a, t, ctx);
  }
  *aplicarEmAlvo(op, a, t, ctx) {
    const dono = ctx.dono;
    switch (op) {
      case "heal": {
        const n = a.n | 0;
        if (ehCarta(t) && t.em_campo) t.dano = Math.max(0, t.dano - n);
        else if (t && t.cornucopia != null) this.cornucopia[t.cornucopia] = Math.min(CORNUCOPIA_MAX, this.cornucopia[t.cornucopia] + n);
        break;
      }
      case "buff":
        if (ehCarta(t) && t.em_campo) {
          const at = a.atk | 0, vi = a.vida | 0, f = ctx.fonte;
          if (ctx.gatilho === "on_equip" && f && !ehCarta(f) && t.reliquia === f) { t.rel_atk += at; t.rel_vida += vi; }
          else if (a.perm ?? true) { t.buff_atk += at; t.buff_vida += vi; }
          else { t.temp_atk += at; t.temp_vida += vi; }
          t.sincronizar();
        }
        break;
      case "destroy":
        if (ehCarta(t)) yield* this.morrer(t);
        else if (t && t.portadora) this.removerReliquia(t);
        break;
      case "bounce": if (ehCarta(t) && t.em_campo) this.devolverAMao(t); break;
      case "revive": this.reviver(dono, t, String(a.para ?? "hand")); break;
      case "silence":
        if (ehCarta(t)) { t.keywords = []; t.efeitos = []; t.silenciada = true; this.recalcularAuras(); }
        break;
      case "freeze": if (ehCarta(t)) t.congelada = true; break;
      case "give_keyword": if (ehCarta(t) && t.em_campo && !t.keywords.includes(a.keyword)) t.keywords.push(a.keyword); break;
      case "set_stats":
        if (ehCarta(t) && t.em_campo) { t.atk_base = a.atk | 0; t.vida_base = a.vida | 0; t.limpar_stats(); }
        break;
      case "copy_stats": {
        const s = ctx.self;
        if (ehCarta(t) && ehCarta(s) && s.em_campo) { s.atk_base = t.atk; s.vida_base = Math.max(1, t.vida()); s.limpar_stats(); }
        break;
      }
      case "swap_control": if (ehCarta(t) && t.em_campo && t.dono !== dono) this.roubar(t, dono, a.perm ?? true); break;
    }
    this.recalcularAuras();
  }
  buscar(d, a) {
    const deck = this.deck[d];
    const cands = deck.filter((c) => (a.tipo == null || c.tipo === a.tipo) && (a.custo_max == null || c.custo <= (a.custo_max | 0)) &&
      (a.keyword == null || c.keywords.includes(a.keyword)));
    if (!cands.length) return;
    const jog = cands.filter((c) => c.custo <= this.fe_max[d] + 1);   // a mais cara jogável no próximo turno (senão a mais barata)
    let esc = cands[0];
    if (jog.length) { for (const c of jog) if (c.custo > esc.custo || !jog.includes(esc)) esc = c; }
    else for (const c of cands) if (c.custo < esc.custo) esc = c;
    deck.splice(deck.indexOf(esc), 1);
    this.embaralharDeck(d);
    this.receberComprada(d, esc, false);
  }
  invocarTokens(d, a, fonte) {
    const nome = String(a.nome ?? "Token");
    const info = TOKENS[nome] || {};
    const dados = { id: info.id || "token_" + nome.toLowerCase().replaceAll(" ", "_"), nome, cultura: info.cultura || "token",
      tipo: "entidade", custo: 0, atk: a.atk | 0, vida: a.vida | 0, lendaria: false, keywords: [...(a.keywords || [])],
      sacrificio: 0, efeitos: [], usos: null, token: true };
    for (let k = 0; k < (a.n ?? 1); k++) {
      const i = this.espacoLivre(this.campo_ent[d]);
      if (i < 0) break;
      const c = new Carta(dados, d);
      this.porEmCampo(c, d, i);
    }
  }
  reviver(d, e, para) {
    if (!e || !e.dados || ehCarta(e)) return;
    const idx = this.cemit[d].lastIndexOf(e);
    if (idx < 0) return;
    if (para === "field" && !this.temSlot(d)) return;
    this.cemit[d].splice(idx, 1);
    let c = e.no && !e.no._liberada && !e.no.em_campo && !this.mao[d].includes(e.no) ? e.no : null;
    if (c === null) c = new Carta(e.dados, d);
    c.resetar();
    c.dono = d;
    if (para === "field") this.porEmCampo(c, d, this.espacoLivre(this.campo_ent[d]));
    else this.entrarNaMao(d, c);
  }
  devolverAMao(c) {
    this.removerDoCampo(c);
    c.em_campo = false;
    if (c.reliquia) this.removerReliquia(c.reliquia);
    if (c.token) this.desfazer(c);
    else { c.resetar(); this.entrarNaMao(c.dono_real, c); }
    this.recalcularAuras();
  }
  roubar(c, novo, perm) {
    const i = this.espacoLivre(this.campo_ent[novo]);
    if (i < 0) return;
    this.removerDoCampo(c);
    c.dono = novo; c.cansada = true; c.atacou = false;
    c.roubada_temp = !perm && c.dono_real !== novo;
    this.porEmCampo(c, novo, i);
    c.cansada = true;
    this.recalcularAuras();
  }
  devolverControle(c) {
    c.roubada_temp = false;
    this.removerDoCampo(c);
    const orig = c.dono_real;
    c.dono = orig;
    const i = this.espacoLivre(this.campo_ent[orig]);
    if (i >= 0) { this.porEmCampo(c, orig, i); c.cansada = true; }
    else { c.em_campo = false; this.cemit[orig].push({ dados: c.dados, no: c }); this.destruirVisual(c); }
  }
  *ritualChoronzon(d) {
    const tri = this.campo(d).some((c) => c.reliquia && c.reliquia.dados.id === CHORONZON.reliquia);
    const cir = this.campo_selo[d].some((s) => s && s.id === CHORONZON.selo);
    const chor = this.mao[d].find((c) => c.id === CHORONZON.entidade) || null;
    if (tri && cir && chor) {
      this.mao[d].splice(this.mao[d].indexOf(chor), 1);
      let i = this.espacoLivre(this.campo_ent[d]);
      if (i < 0) { i = 0; const velha = this.campo_ent[d][0]; if (velha) yield* this.morrer(velha, false); }
      this.porEmCampo(chor, d, i);
      yield* this.dispararEfeitosEntidade(chor, "on_play", { triggering: chor });
    } else yield* this.comprar(d);
  }

  // ---------- retrato do estado (conferência com o jogo) ----------
  /** Texto canônico do estado, em lados globais. O jogo (mesa.gd, _canon) monta o MESMO texto. */
  canon() {
    const lado = (d) => {
      const ent = this.campo_ent[d].map((c) => (c ? [c.id, c.atk, c.defe, c.dano, [...c.keywords].sort().join("+") + "|" + [...c.aura_keywords].sort().join("+"),
        (c.cansada ? "c" : "") + (c.atacou ? "a" : "") + (c.congelada ? "g" : "") + (c.sem_ataque ? "x" : "") + (c.silenciada ? "s" : "") +
        (c.ja_atacou ? "j" : "") + (c.roubada_temp ? "R" : "") + (c.reliquia ? "r:" + c.reliquia.dados.id + ":" + (c.reliquia.usos ?? "-") : "")].join("/") : "_"));
      return [this.cornucopia[d], this.fe[d], this.fe_max[d], this.mao[d].map((c) => c.id).join(","), this.deck[d].length,
        this.cemit[d].map((e) => e.dados.id).join(","), ent.join(";"), this.campo_selo[d].map((s) => (s ? s.id : "_")).join(",")].join("#");
    };
    return `T${this.turno_n}A${this.ativo}|` + lado(0) + "|" + lado(1);
  }
}

export function alvoEscolhido(dados) {
  for (const ef of dados.efeitos || []) for (const a of ef.acoes) if (ALVOS_ESCOLHIDOS.includes(String(a.alvo ?? ""))) return a.alvo;
  return "";
}

/** Referência pública de um candidato (para o celular saber qual destacar). */
function refDe(x) {
  if (ehCarta(x)) return { uid: x.uid, id: x.id };
  if (x && x.dados) return { cemit: x.dados.id };
  return {};
}

// ---------------- sorteio do juiz (servidor) ----------------
/** Gerador simples e rápido (mulberry32) com semente; o mesmo para a partida inteira (guardada no servidor). */
export function sorteioJuiz(semente) {
  let s = semente >>> 0;
  const prox = () => {
    s = (s + 0x6d2b79f5) >>> 0;
    let t = s;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
  return {
    int: (n) => Math.floor(prox() * n),
    ordem: (_d, arr) => { const a = [...arr]; for (let i = a.length - 1; i > 0; i--) { const j = Math.floor(prox() * (i + 1)); [a[i], a[j]] = [a[j], a[i]]; } return a; },
  };
}
