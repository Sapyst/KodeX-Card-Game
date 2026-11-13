// Sala de uma partida online (Durable Object): o JUIZ roda aqui. Cada celular fica ligado por WebSocket e manda só
// intenções ("jogar a carta 2 no espaço 1", "atacar", "fim", escolhas); a sala confere, aplica no motor
// (motor/regras.js) e devolve a cada um só o que ele pode ver:
//   {s, a: {...}}  jogada do adversário (carta jogada vai com o id; Selo vai sem)
//   {s, r: {...}}  revelação (compra própria, sorteio, descarte, busca, Selo do adversário que disparou, retrato do turno)
//   {s, fim: {vencedor, motivo}}
// `s` é a sequência de cada jogador: reconectou → manda {t: "ola", desde: s} e a sala reenvia o que faltou.
// A sala guarda só a configuração e as entradas; se a Cloudflare a desligar, ela se reconstrói refazendo as entradas
// com a mesma semente (o motor é determinístico).
//
// Custo (a sala só é cobrada enquanto está acordada): ela DORME entre as jogadas (hibernação do WebSocket).
//  - o ping de 10 s dos celulares é respondido pela própria Cloudflare (setWebSocketAutoResponse), sem acordar a sala;
//  - o alarme toca só no prazo da jogada, no prazo da queda ou a cada 60 s para achar socket morto (ping parado);
//  - cada entrada guarda a hora (ts) e o número (n): ao acordar, o relógio do turno continua de onde estava;
//  - 1 h depois do fim a sala apaga tudo e guarda só o resultado (quem volta ao app ainda recebe o fim).
import { Partida, sorteioJuiz } from "./motor/regras.js";

const PRAZO_ACAO = 80;           // s sem jogada na vez → a sala passa o turno (o celular já passa com 75 s + folga de rede)
const PRAZO_ESCOLHA = 45;        // s sem escolher alvo / sim-não → pula
const PRAZO_MULLIGAN = 30;       // s sem decidir a mão inicial → mantém (o celular conta 28 s)
const PRAZO_QUEDA = 120;         // s sem nenhum dos dois aparelhos do jogador ligado → derrota por abandono
const MSG_MAX = 2048;            // bytes por mensagem do celular (intenções têm ~40–80)
const EMOTE_MS = 1000;           // no máximo 1 emote por segundo
const VIGIA_MS = 60000;          // sem prazo perto: acorda a cada 60 s só para achar socket morto
const ZUMBI_MS = 35000;          // socket sem ping há 35 s (o celular pinga a cada 10 s) = aparelho sumiu
const LIMPAR_MS = 3600000;       // 1 h depois do fim: apaga as entradas e guarda só o resultado (teste: SALA_LIMPAR_S)
const PING = '{"t":"ping"}', PONG = '{"t":"pong"}';   // exatamente o que o jogo manda (JSON.stringify do Godot)

export class SalaPartida {
  constructor(ctx, env) {
    this.ctx = ctx;
    this.env = env;
    this.pronta = null;
    this.alarmeEm = 0;
    this.limparMs = env.SALA_LIMPAR_S ? parseInt(env.SALA_LIMPAR_S, 10) * 1000 : LIMPAR_MS;
    // ping/pong sem acordar a sala (a Cloudflare responde e anota a hora: getWebSocketAutoResponseTimestamp)
    try { ctx.setWebSocketAutoResponse(new WebSocketRequestResponsePair(PING, PONG)); } catch (e) { /* ambiente sem suporte */ }
  }

  // ---------- reconstrução ----------
  async carregar() {
    if (this.pronta) return this.pronta;
    this.pronta = (async () => {
      this.encerrada = await this.ctx.storage.get("encerrada");            // sala já limpa: só o resultado
      this.ultEmote = [0, 0];
      this.presenca = [true, true];
      if (this.encerrada) return;
      const base = await this.ctx.storage.get(["setup", "entradas", "ultN", "quedaDesde", "fimEm"]);
      this.setup = base.get("setup");
      this.entradas = base.get("entradas") || [];                            // salas antigas: lista inteira numa chave
      const novas = await this.ctx.storage.list({ prefix: "in:" });          // novas: uma chave por entrada (in:000001...)
      for (const e of novas.values()) this.entradas.push(e);
      // último número aceito de cada lado: vem das próprias entradas (salas antigas: chave ultN)
      this.ultN = base.get("ultN") || [0, 0];
      for (const e of this.entradas) if (e.n) this.ultN[e.j] = Math.max(this.ultN[e.j], e.n);
      this.quedaDesde = base.get("quedaDesde") || [0, 0];
      this.fimEm = base.get("fimEm") || 0;
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
    this.tsAtual = s.inicio || Date.now();                    // hora "de então" enquanto refaz (o relógio do turno não zera)
    this.g = this.p.rodar();
    this.pedido = this.g.next().value;
    this.coletarRevelacoes();                                 // a mão inicial já foi comprada antes do 1º pedido
    this.desdePedido = this.tsAtual;
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
      this.empurrar(j, { eu: { pedido: this.pedido.tipo, d, fe: this.p.fe[j] } });   // eco para o próprio (refazer a partida ao voltar)
      this.empurrar(1 - j, { a: pub });                       // o adversário vê a jogada antes do que ela causa
      const r = this.g.next(d);
      this.coletarRevelacoes();
      if (r.done) { this.pedido = null; break; }
      this.pedido = r.value;
      this.desdePedido = this.reproduzindo ? this.tsAtual : Date.now();
    }
    this.avisarPedido();
    this.coletarRevelacoes();
    if (this.p.acabou && !this.fimAvisado) {
      this.fimAvisado = true;
      for (const j of [0, 1]) this.empurrar(j, { fim: { vencedor: this.p.vencedor, motivo: this.p.motivo_fim } });
      if (!this.reproduzindo) {
        this.ctx.waitUntil(this.gravarResultado());
        this.fimEm = Date.now();                              // daqui a 1 h a sala se limpa (alarme)
        this.ctx.waitUntil(this.ctx.storage.put("fimEm", this.fimEm).then(() => this.agendar()));
      }
    }
  }

  /** Diz ao celular de quem a sala está esperando o quê (fora da sequência: é só um lembrete). */
  avisarPedido(ws = null) {
    if (this.reproduzindo || !this.pedido || this.p.acabou) return;
    const q = this.pedido;
    const msg = JSON.stringify({ t: "pedido", tipo: q.tipo, jogador: q.jogador, turno: this.p.turno_n, prazo_s: this.prazoDe(q),
      passou_ms: Date.now() - this.desdePedido });
    // vai para os DOIS lados: quem espera usa prazo_s/passou_ms para mostrar o relógio do adversário igual ao da sala
    const todos = ws ? [ws] : [...this.ctx.getWebSockets("j0"), ...this.ctx.getWebSockets("j1")];
    for (const w of todos) { try { w.send(msg); } catch (e) { /* caiu */ } }
  }

  async gravarResultado() {
    if (!this.setup?.pid) return;
    await this.env.DB.prepare("UPDATE partidas SET estado='fim', vencedor=CASE WHEN vencedor < 0 THEN ? ELSE vencedor END WHERE pid=?")
      .bind(this.p.vencedor, this.setup.pid).run();
  }

  /** Aplica uma entrada já aceita (ao vivo ou refazendo a partida): desistência, jogada forçada pela sala ou normal. */
  aplicar(e) {
    if (this.reproduzindo && e.ts) this.tsAtual = e.ts;
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
    e.ts = Date.now();                                        // hora da entrada: ao acordar, o prazo do turno continua daqui
    this.entradas.push(e);                                    // 1 linha por entrada (o n vai junto: sem regravar ultN)
    await this.ctx.storage.put("in:" + String(this.entradas.length).padStart(6, "0"), e);
    this.aplicar(e);
  }

  async receber(j, n, t, d) {
    if (n <= this.ultN[j]) return;                           // repetida (reconexão reenviou)
    if (this.p.acabou) return;
    if (d && d.tipo === "desistir") {                         // desistir vale a qualquer hora
      this.ultN[j] = n;
      await this.aceitar({ j, n, desistir: true });
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
    await this.aceitar({ j, n, d });
    await this.agendar();
  }
  avisar(j, erro) {
    for (const ws of this.ctx.getWebSockets("j" + j)) { try { ws.send(JSON.stringify({ t: "erro", erro })); } catch (e) { /* caiu */ } }
  }

  // ---------- prazos (alarme) ----------
  prazoDe(q) { return q.tipo === "acao" ? PRAZO_ACAO : q.tipo === "mulligan" ? PRAZO_MULLIGAN : PRAZO_ESCOLHA; }
  /** Próximo alarme: o prazo da jogada, o prazo da queda de quem sumiu ou a vigia de sockets mortos (60 s), o que vier
   *  antes. Partida acabada: só a limpeza. Não regrava o alarme se ele já está marcado para (quase) a mesma hora. */
  async agendar() {
    if (!this.p) return;
    const ag = Date.now();
    let quando;
    if (this.p.acabou) {
      if (!this.fimEm) return;
      quando = this.fimEm + this.limparMs;
    } else {
      quando = ag + VIGIA_MS;
      if (this.pedido) quando = Math.min(quando, this.desdePedido + this.prazoDe(this.pedido) * 1000 + 500);
      for (const j of [0, 1]) if (this.quedaDesde[j]) quando = Math.min(quando, this.quedaDesde[j] + PRAZO_QUEDA * 1000 + 500);
      quando = Math.max(quando, ag + 500);
    }
    if (Math.abs(quando - this.alarmeEm) < 1000) return;
    this.alarmeEm = quando;
    await this.ctx.storage.setAlarm(quando);
  }
  /** Fecha sockets que pararam de pingar há ZUMBI_MS (app morto em segundo plano, troca de rede sem aviso). */
  fecharZumbis() {
    const ag = Date.now();
    for (const ws of this.ctx.getWebSockets()) {
      let ult = 0;
      try { ult = this.ctx.getWebSocketAutoResponseTimestamp(ws)?.getTime() || 0; } catch (e) { /* sem suporte */ }
      const at = ws.deserializeAttachment() || {};
      ult = Math.max(ult, at.desde || 0, at.msg || 0);
      if (ult && ag - ult > ZUMBI_MS) { try { ws.close(4002, "sem ping"); } catch (e) { /* já fechou */ } }
    }
  }
  /** Avisa o lado `j` se o adversário dele está ligado (fora de sequência; o celular mostra "SEM SINAL" com o tempo). */
  avisarPresenca(j, ligado, desde = 0) {
    if (this.presenca[j] === ligado && ligado) return;
    this.presenca[j] = ligado;
    const msg = JSON.stringify({ t: "presenca", ligado, ausente_s: ligado ? 0 : Math.round((Date.now() - desde) / 1000) });
    for (const ws of this.ctx.getWebSockets("j" + j)) { try { ws.send(msg); } catch (e) { /* caiu */ } }
  }
  async alarm() {
    await this.carregar();
    this.alarmeEm = 0;                                        // o alarme que tocou já não está marcado
    if (this.encerrada || !this.p) return;
    if (this.p.acabou) {                                      // 1 h depois do fim: apaga tudo e guarda só o resultado
      if (this.fimEm && Date.now() >= this.fimEm + this.limparMs - 1000) await this.limpar();
      else await this.agendar();
      return;
    }
    try {
      const agora = Date.now();
      this.fecharZumbis();
      const antes = JSON.stringify(this.quedaDesde);
      for (const j of [0, 1]) {                                // ninguém ligado há muito tempo → abandono
        const ligado = this.ctx.getWebSockets("j" + j).some((w) => (w.readyState ?? 1) === 1);
        if (ligado) this.quedaDesde[j] = 0;
        else if (!this.quedaDesde[j]) this.quedaDesde[j] = agora;
        else if (agora - this.quedaDesde[j] > PRAZO_QUEDA * 1000) {
          await this.aceitar({ j, desistir: true, abandono: true });
          return;
        }
        this.avisarPresenca(1 - j, ligado, this.quedaDesde[j]);
      }
      if (JSON.stringify(this.quedaDesde) !== antes) await this.ctx.storage.put("quedaDesde", this.quedaDesde);
      const q = this.pedido;
      if (q && (agora - this.desdePedido) / 1000 > this.prazoDe(q)) {   // a sala decide por quem sumiu, e avisa os dois
        const d = q.tipo === "acao" ? { tipo: "fim" } : q.tipo === "mulligan" ? [] : q.tipo === "sim_nao" ? false : -1;
        await this.aceitar({ j: q.jogador, d, forcado: q.tipo });
      }
    } finally {
      await this.agendar();                                  // uma exceção acima não pode matar a cadeia de alarmes
    }
  }
  async limpar() {
    const fim = { vencedor: this.p.vencedor, motivo: this.p.motivo_fim || "" };
    await this.ctx.storage.deleteAlarm();
    await this.ctx.storage.deleteAll();
    await this.ctx.storage.put("encerrada", fim);
    this.encerrada = fim;
    this.p = null;
  }

  // ---------- WebSocket ----------
  async fetch(req) {
    await this.carregar();
    const url = new URL(req.url);
    const j = parseInt(req.headers.get("x-jogador") || "-1", 10);
    if (this.encerrada && url.pathname.endsWith("/estado")) return Response.json({ ok: true, acabou: true, vencedor: this.encerrada.vencedor });
    if (!this.setup && !this.encerrada) {                                        // primeira conexão: a configuração vem do Worker (D1)
      const setup = JSON.parse(req.headers.get("x-setup") || "null");
      if (!setup) return new Response("sala sem configuração", { status: 400 });
      setup.inicio = Date.now();                              // o prazo da mão inicial conta daqui (mesmo se a sala dormir)
      this.setup = setup;
      await this.ctx.storage.put("setup", setup);
      this.montar();
    }
    if (url.pathname.endsWith("/estado")) return Response.json({ ok: true, acabou: this.p.acabou, vencedor: this.p.vencedor });
    if (req.headers.get("upgrade") !== "websocket" || (j !== 0 && j !== 1)) return new Response("use WebSocket", { status: 426 });
    const par = new WebSocketPair();
    // um aparelho por lado: o que chegou agora vale; o anterior (outro celular da mesma conta, ou socket zumbi) é fechado
    for (const w of this.ctx.getWebSockets("j" + j)) { try { w.close(4001, "outro aparelho entrou"); } catch (e) { /* já fechou */ } }
    this.ctx.acceptWebSocket(par[1], ["j" + j]);
    par[1].serializeAttachment({ desde: Date.now() });        // hora da entrada (vigia de socket morto)
    if (!this.encerrada) {
      if (this.quedaDesde[j]) { this.quedaDesde[j] = 0; await this.ctx.storage.put("quedaDesde", this.quedaDesde); }
      await this.agendar();
    }
    return new Response(null, { status: 101, webSocket: par[0] });
  }

  async webSocketMessage(ws, texto) {
    await this.carregar();
    const tags = this.ctx.getTags(ws);
    const j = tags.includes("j0") ? 0 : 1;
    if (typeof texto !== "string" || texto.length > MSG_MAX) { try { ws.close(1009, "mensagem grande demais"); } catch (e) { /* já fechou */ } return; }
    if (texto === PING) { try { ws.send(PONG); } catch (e) { /* caiu */ } return; }   // (a Cloudflare já responde sozinha)
    let m;
    try { m = JSON.parse(texto); } catch (e) { return; }
    if (!m || typeof m !== "object") return;
    if (this.encerrada) {                                     // sala limpa: quem volta recebe só o resultado e o "pronto"
      if (m.t === "ola") {
        const s = (m.desde | 0) + 1;
        try {
          ws.send(JSON.stringify({ s, fim: this.encerrada }));
          ws.send(JSON.stringify({ t: "pronto", s, vez: -1, n: 0 }));
        } catch (e) { /* caiu */ }
      }
      return;
    }
    if (m.t === "ola") {                                      // (re)conectou: manda o que faltou desde `desde`
      const desde = Math.min(this.fluxo[j].length, Math.max(0, m.desde | 0));
      if (this.quedaDesde[j]) { this.quedaDesde[j] = 0; await this.ctx.storage.put("quedaDesde", this.quedaDesde); }
      this.avisarPresenca(1 - j, true);                       // o outro lado fica sabendo que este voltou
      const op = this.ctx.getWebSockets("j" + (1 - j)).length > 0;
      try { ws.send(JSON.stringify({ t: "presenca", ligado: op, ausente_s: op || !this.quedaDesde[1 - j] ? 0 : Math.round((Date.now() - this.quedaDesde[1 - j]) / 1000) })); } catch (e) { /* caiu */ }
      for (const msg of this.fluxo[j].slice(desde)) ws.send(JSON.stringify(msg));
      // n = último número de entrada aceito: o celular que reabriu continua a contar dali (senão tudo parece repetido)
      ws.send(JSON.stringify({ t: "pronto", s: this.fluxo[j].length, vez: this.pedido?.jogador ?? -1, n: this.ultN[j] }));
      this.avisarPedido(ws);
      return;
    }
    if (m.t === "in") {
      ws.serializeAttachment({ ...(ws.deserializeAttachment() || {}), msg: Date.now() });
      await this.receber(j, m.n | 0, m.t_turno, m.d);
    }
    if (m.t === "ping") ws.send(JSON.stringify({ t: "pong" }));
    if (m.t === "emote") {                                    // fala rápida: vai direto ao outro, não entra na partida
      const agora = Date.now();
      if (agora - this.ultEmote[j] < EMOTE_MS) return;        // sem spam no adversário
      this.ultEmote[j] = agora;
      for (const w of this.ctx.getWebSockets("j" + (1 - j))) { try { w.send(JSON.stringify({ t: "emote", k: m.k | 0 })); } catch (e) { /* caiu */ } }
    }
  }
  /** Um aparelho sumiu: se era o último desse lado, o adversário já fica sabendo (não espera o alarme). */
  async sumiu(ws) {
    await this.carregar();
    const j = this.ctx.getTags(ws).includes("j0") ? 0 : 1;
    const resta = this.ctx.getWebSockets("j" + j).filter((w) => w !== ws && (w.readyState ?? 1) === 1).length;
    if (resta === 0 && this.p && !this.p.acabou) {
      if (!this.quedaDesde[j]) { this.quedaDesde[j] = Date.now(); await this.ctx.storage.put("quedaDesde", this.quedaDesde); }
      this.avisarPresenca(1 - j, false, this.quedaDesde[j]);
      await this.agendar();                                   // o prazo da queda (2 min) entra no alarme
    }
  }
  async webSocketClose(ws, code) { try { ws.close(code, "fim"); } catch (e) { /* já fechou */ } await this.sumiu(ws); }
  async webSocketError(ws) { await this.sumiu(ws); }
}
