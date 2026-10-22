// Sala de uma partida online (Durable Object): o JUIZ roda aqui. Cada celular fica ligado por WebSocket e manda só
// intenções ("jogar a carta 2 no espaço 1", "atacar", "fim", escolhas); a sala confere, aplica no motor
// (motor/regras.js) e devolve a cada um só o que ele pode ver:
//   {s, a: {...}}  jogada do adversário (carta jogada vai com o id; Selo vai sem)
//   {s, r: {...}}  revelação (compra própria, sorteio, descarte, busca, Selo do adversário que disparou, retrato do turno)
//   {s, fim: {vencedor, motivo}}
// `s` é a sequência de cada jogador: reconectou → manda {t: "ola", desde: s} e a sala reenvia o que faltou.
// A sala guarda só a configuração e as entradas; se a Cloudflare a desligar, ela se reconstrói refazendo as entradas
// com a mesma semente (o motor é determinístico).
import { Partida, sorteioJuiz } from "./motor/regras.js";

const PRAZO_ACAO = 100;          // s sem jogada na vez → a sala passa o turno (o celular já passa com 75 s)
const PRAZO_ESCOLHA = 45;        // s sem escolher alvo / sim-não → pula
const PRAZO_MULLIGAN = 40;       // s sem decidir a mão inicial → mantém
const PRAZO_QUEDA = 120;         // s sem nenhum dos dois aparelhos do jogador ligado → derrota por abandono

export class SalaPartida {
  constructor(ctx, env) {
    this.ctx = ctx;
    this.env = env;
    this.pronta = null;
  }

  // ---------- reconstrução ----------
  async carregar() {
    if (this.pronta) return this.pronta;
    this.pronta = (async () => {
      this.setup = await this.ctx.storage.get("setup");
      this.entradas = (await this.ctx.storage.get("entradas")) || [];
      this.ultN = (await this.ctx.storage.get("ultN")) || [0, 0];
      this.quedaDesde = (await this.ctx.storage.get("quedaDesde")) || [0, 0];
      if (this.setup) this.montar();
    })();
    return this.pronta;
  }
  montar() {
    const s = this.setup;
    this.p = new Partida({ decks: s.decks, primeiro: s.primeiro, sorteio: sorteioJuiz(s.semente), humano: [true, true] });
    this.fluxo = [[], []];           // mensagens de cada jogador (índice = s − 1)
    this.revLidas = [0, 0];
    this.fila = [[], []];            // entradas recebidas e ainda não pedidas pelo motor
    this.reproduzindo = true;                                 // (re)montando: nada sai para os celulares agora
    this.g = this.p.rodar();
    this.pedido = this.g.next().value;
    this.coletarRevelacoes();                                 // a mão inicial já foi comprada antes do 1º pedido
    this.desdePedido = Date.now();
    for (const e of this.entradas) this.aplicar(e);           // refaz a partida com as mesmas entradas, na mesma ordem
    this.reproduzindo = false;
  }

  // ---------- fluxo para os celulares ----------
  empurrar(j, msg) {
    const m = { s: this.fluxo[j].length + 1, ...msg };
    this.fluxo[j].push(m);
    if (!this.reproduzindo) for (const ws of this.ctx.getWebSockets("j" + j)) { try { ws.send(JSON.stringify(m)); } catch (e) { /* caiu */ } }
  }
  coletarRevelacoes() {
    for (const j of [0, 1]) {
      const r = this.p.rev[j];
      while (this.revLidas[j] < r.length) this.empurrar(j, { r: r[this.revLidas[j]++] });
    }
  }

  /** Visão pública de uma entrada (o que o adversário recebe). */
  publica(j, pedido, d) {
    if (pedido.tipo === "mulligan") return { tipo: "mull", k: d };
    if (pedido.tipo === "escolha") return { tipo: "esc", v: d };
    if (pedido.tipo === "sim_nao") return { tipo: "esc", v: d ? 1 : 0 };
    const a = { ...d };
    if (a.tipo === "jogar") {
      const c = this.p.mao[j][a.k | 0];
      if (c && c.tipo !== "selo") { a.id = c.id; if (c.sem_renascer) a.sr = true; }   // carta revelada (e se já usou o Renascer)
      else if (c) a.custo = c.custo;                     // …só quanto de Fé foi gasto (isso todo mundo vê)
    }
    return a;
  }

  /** Confere se a entrada serve para o que o motor está pedindo (e se a jogada é permitida agora). */
  valida(j, pedido, d) {
    if (!pedido || pedido.jogador !== j) return "não é a sua vez";
    if (pedido.tipo === "mulligan") return Array.isArray(d) && d.length <= 2 ? "" : "mão inicial inválida";
    if (pedido.tipo === "escolha") return Number.isInteger(d) && d >= -1 && d < pedido.cands.length ? "" : "escolha inválida";
    if (pedido.tipo === "sim_nao") return typeof d === "boolean" ? "" : "resposta inválida";
    if (!d || typeof d !== "object") return "jogada inválida";
    const p = this.p;
    switch (d.tipo) {
      case "fim": case "desistir": return "";
      case "jogar": {
        const c = p.mao[j][d.k | 0];
        if (!c) return "carta fora da mão";
        const m = p.motivoJogar(c, j);
        if (m) return m;
        if (c.tipo === "entidade" && (c.dados.sacrificio | 0) > 0) {
          const sacs = new Set((d.sac || []).map((x) => x | 0).filter((x) => x >= 0 && x < 4 && p.campo_ent[j][x]));
          if (sacs.size < (c.dados.sacrificio | 0)) return "sacrifício";
        }
        if (c.tipo === "reliquia" && !p.portadoras(j)[d.p | 0]) return "portadora";
        return "";
      }
      case "mover": {
        const c = p.campo_ent[j][d.de | 0];
        return c && (d.para | 0) >= 0 && (d.para | 0) < 4 && !p.campo_ent[j][d.para | 0] ? "" : "mover";
      }
      case "atacar": case "golpe": {
        const c = p.campo_ent[j][d.de | 0];
        if (!c) return "atacante";
        const alvo = d.tipo === "golpe" ? null : p.campo_ent[1 - j][d.alvo | 0];
        if (d.tipo === "atacar" && !alvo) return "alvo";
        return p.podeAtacar(c, alvo);
      }
    }
    return "jogada desconhecida";
  }

  /** Alimenta o motor com as entradas que ele está pedindo, enquanto houver. */
  avancar() {
    while (this.pedido && !this.p.acabou) {
      const j = this.pedido.jogador;
      if (!this.fila[j].length) break;
      const d = this.fila[j].shift();
      const pub = this.publica(j, this.pedido, d);
      this.empurrar(j, { eu: { pedido: this.pedido.tipo, d, mao: this.p.mao[j].map((c) => c.id), fe: this.p.fe[j] } });   // eco para o próprio (refazer a partida ao voltar; a mão é dele)
      this.empurrar(1 - j, { a: pub });                       // o adversário vê a jogada antes do que ela causa
      const r = this.g.next(d);
      this.coletarRevelacoes();
      if (r.done) { this.pedido = null; break; }
      this.pedido = r.value;
      this.desdePedido = Date.now();
    }
    this.avisarPedido();
    this.coletarRevelacoes();
    if (this.p.acabou && !this.fimAvisado) {
      this.fimAvisado = true;
      for (const j of [0, 1]) this.empurrar(j, { fim: { vencedor: this.p.vencedor, motivo: this.p.motivo_fim } });
      if (!this.reproduzindo) this.ctx.waitUntil(this.gravarResultado());
    }
  }

  /** Diz ao celular de quem a sala está esperando o quê (fora da sequência: é só um lembrete). */
  avisarPedido(ws = null) {
    if (this.reproduzindo || !this.pedido || this.p.acabou) return;
    const q = this.pedido;
    const msg = JSON.stringify({ t: "pedido", tipo: q.tipo, jogador: q.jogador, turno: this.p.turno_n });
    for (const w of ws ? [ws] : this.ctx.getWebSockets("j" + q.jogador)) { try { w.send(msg); } catch (e) { /* caiu */ } }
  }

  async gravarResultado() {
    if (!this.setup?.pid) return;
    await this.env.DB.prepare("UPDATE partidas SET estado='fim', vencedor=CASE WHEN vencedor < 0 THEN ? ELSE vencedor END WHERE pid=?")
      .bind(this.p.vencedor, this.setup.pid).run();
  }

  /** Aplica uma entrada já aceita (ao vivo ou refazendo a partida): desistência, jogada forçada pela sala ou normal. */
  aplicar(e) {
    if (e.desistir) {
      this.empurrar(1 - e.j, { a: { tipo: "desistir", abandono: !!e.abandono } });
      this.p.desistir(e.j);
      if (e.abandono) this.p.motivo_fim = "abandono";
    } else {
      if (e.forcado) this.empurrar(e.j, { a: { forcado: e.forcado, ...this.publica(e.j, this.pedido, e.d) } });
      this.fila[e.j].push(e.d);
    }
    this.avancar();
  }
  async aceitar(e) {
    this.entradas.push(e);
    await this.ctx.storage.put({ entradas: this.entradas, ultN: this.ultN });
    this.aplicar(e);
  }

  async receber(j, n, t, d) {
    if (n <= this.ultN[j]) return;                           // repetida (reconexão reenviou)
    if (this.p.acabou) return;
    if (d && d.tipo === "desistir") {                         // desistir vale a qualquer hora
      this.ultN[j] = n;
      await this.aceitar({ j, desistir: true });
      return;
    }
    // a jogada diz de que turno ela é: atrasada (a sala já passou o turno por tempo) não vale
    if ((t | 0) !== this.p.turno_n) { this.ultN[j] = n; this.avisar(j, "jogada de outro turno"); return; }
    // entradas de quem não está sendo pedido agora (só a mão inicial, decidida pelos dois ao mesmo tempo) esperam na fila
    const pedidoDele = this.pedido && this.pedido.jogador === j ? this.pedido : null;
    if (pedidoDele) {
      const erro = this.valida(j, pedidoDele, d);
      if (erro) { this.ultN[j] = n; this.avisar(j, erro); return; }
    } else if (this.pedido && this.pedido.tipo === "mulligan") {
      if (!Array.isArray(d) || d.length > 2 || this.fila[j].length) { this.ultN[j] = n; this.avisar(j, "mão inicial inválida"); return; }
    } else { this.ultN[j] = n; this.avisar(j, "não é a sua vez"); return; }
    this.ultN[j] = n;
    await this.aceitar({ j, d });
    await this.agendar();
  }
  avisar(j, erro) {
    for (const ws of this.ctx.getWebSockets("j" + j)) { try { ws.send(JSON.stringify({ t: "erro", erro })); } catch (e) { /* caiu */ } }
  }

  // ---------- prazos (alarme) ----------
  async agendar() {
    if (this.p.acabou) return;
    await this.ctx.storage.setAlarm(Date.now() + 15000);
  }
  async alarm() {
    await this.carregar();
    if (!this.p || this.p.acabou) return;
    const agora = Date.now();
    for (const j of [0, 1]) {                                // ninguém ligado há muito tempo → abandono
      const ligado = this.ctx.getWebSockets("j" + j).length > 0;
      if (ligado) this.quedaDesde[j] = 0;
      else if (!this.quedaDesde[j]) this.quedaDesde[j] = agora;
      else if (agora - this.quedaDesde[j] > PRAZO_QUEDA * 1000) {
        await this.aceitar({ j, desistir: true, abandono: true });
        return;
      }
    }
    await this.ctx.storage.put("quedaDesde", this.quedaDesde);
    const q = this.pedido;
    if (q) {
      const esperou = (agora - this.desdePedido) / 1000;
      const prazo = q.tipo === "acao" ? PRAZO_ACAO : q.tipo === "mulligan" ? PRAZO_MULLIGAN : PRAZO_ESCOLHA;
      if (esperou > prazo) {                                  // a sala decide por quem sumiu, e avisa os dois
        const d = q.tipo === "acao" ? { tipo: "fim" } : q.tipo === "mulligan" ? [] : q.tipo === "sim_nao" ? false : -1;
        await this.aceitar({ j: q.jogador, d, forcado: q.tipo });
      }
    }
    await this.agendar();
  }

  // ---------- WebSocket ----------
  async fetch(req) {
    await this.carregar();
    const url = new URL(req.url);
    const j = parseInt(req.headers.get("x-jogador") || "-1", 10);
    if (!this.setup) {                                        // primeira conexão: a configuração vem do Worker (D1)
      const setup = JSON.parse(req.headers.get("x-setup") || "null");
      if (!setup) return new Response("sala sem configuração", { status: 400 });
      this.setup = setup;
      await this.ctx.storage.put("setup", setup);
      this.montar();
    }
    if (url.pathname.endsWith("/estado")) return Response.json({ ok: true, acabou: this.p.acabou, vencedor: this.p.vencedor });
    if (req.headers.get("upgrade") !== "websocket" || (j !== 0 && j !== 1)) return new Response("use WebSocket", { status: 426 });
    const par = new WebSocketPair();
    this.ctx.acceptWebSocket(par[1], ["j" + j]);
    await this.agendar();
    return new Response(null, { status: 101, webSocket: par[0] });
  }

  async webSocketMessage(ws, texto) {
    await this.carregar();
    const tags = this.ctx.getTags(ws);
    const j = tags.includes("j0") ? 0 : 1;
    let m;
    try { m = JSON.parse(texto); } catch (e) { return; }
    if (m.t === "ola") {                                      // (re)conectou: manda o que faltou desde `desde`
      const desde = Math.max(0, m.desde | 0);
      for (const msg of this.fluxo[j].slice(desde)) ws.send(JSON.stringify(msg));
      // n = último número de entrada aceito: o celular que reabriu continua a contar dali (senão tudo parece repetido)
      ws.send(JSON.stringify({ t: "pronto", s: this.fluxo[j].length, vez: this.pedido?.jogador ?? -1, n: this.ultN[j] }));
      if (this.pedido?.jogador === j) this.avisarPedido(ws);
      return;
    }
    if (m.t === "in") await this.receber(j, m.n | 0, m.t_turno, m.d);
    if (m.t === "ping") ws.send(JSON.stringify({ t: "pong" }));
    if (m.t === "emote") {                                    // fala rápida: vai direto ao outro, não entra na partida
      for (const w of this.ctx.getWebSockets("j" + (1 - j))) { try { w.send(JSON.stringify({ t: "emote", k: m.k | 0 })); } catch (e) { /* caiu */ } }
    }
  }
  async webSocketClose(ws, code) { try { ws.close(code, "fim"); } catch (e) { /* já fechou */ } }
  async webSocketError() { /* o alarme cuida de quem sumiu */ }
}
