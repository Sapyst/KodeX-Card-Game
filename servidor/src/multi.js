// Multiplayer do KodeX: fila de busca com prioridade por região, aceitar/recusar, sala por código e partida por
// "passo travado" (lockstep): os dois aparelhos rodam a mesma partida com a mesma semente; aqui só passam as AÇÕES, em
// ordem (seq). Resposta rápida por long-poll (o pedido espera até 20 s pela próxima novidade).
// Região: cf-ipcountry (a Cloudflare informa o país). Prioridade: mesmo país até 5 s → mesmo continente até 15 s → todos.

const CONTINENTE = {
  BR: "SA", AR: "SA", CL: "SA", CO: "SA", PE: "SA", UY: "SA", PY: "SA", BO: "SA", EC: "SA", VE: "SA",
  US: "NA", CA: "NA", MX: "NA", PT: "EU", ES: "EU", FR: "EU", DE: "EU", IT: "EU", GB: "EU", NL: "EU", PL: "EU", IE: "EU",
  JP: "AS", KR: "AS", CN: "AS", IN: "AS", PH: "AS", ID: "AS", AU: "OC", NZ: "OC", ZA: "AF", NG: "AF", AO: "AF", MZ: "AF",
};
const ESPERA_POLL = 20;               // s de long-poll
const ACEITAR_EM = 12;                // s para aceitar a partida encontrada
const QUEDA = 120;                    // s sem contato = desistência

export const ESQUEMA_MULTI = `
CREATE TABLE IF NOT EXISTS fila (id TEXT PRIMARY KEY, nome TEXT, deck TEXT, pais TEXT, cont TEXT, entrou INTEGER, visto INTEGER, partida TEXT,
  foto TEXT);
CREATE TABLE IF NOT EXISTS partidas (pid TEXT PRIMARY KEY, codigo TEXT, j0 TEXT, j1 TEXT, nome0 TEXT, nome1 TEXT, deck0 TEXT, deck1 TEXT,
  semente INTEGER, primeiro INTEGER, estado TEXT, aceite0 INTEGER DEFAULT 0, aceite1 INTEGER DEFAULT 0, prazo INTEGER,
  contato0 INTEGER, contato1 INTEGER, vencedor INTEGER DEFAULT -1, criado INTEGER, revanche0 INTEGER DEFAULT 0, revanche1 INTEGER DEFAULT 0,
  revanche_pid TEXT, foto0 TEXT, foto1 TEXT, pago0 INTEGER DEFAULT 0, pago1 INTEGER DEFAULT 0);
CREATE TABLE IF NOT EXISTS acoes (pid TEXT, seq INTEGER, jogador INTEGER, dados TEXT, ts INTEGER, PRIMARY KEY (pid, seq));`;

const agora = () => Math.floor(Date.now() / 1000);
const dormir = (ms) => new Promise((r) => setTimeout(r, ms));
const aleatorio = (n) => [...crypto.getRandomValues(new Uint8Array(n))].map((b) => b.toString(16).padStart(2, "0")).join("");

function regiao(req) {
  const pais = (req.headers.get("cf-ipcountry") || req.cf?.country || "XX").toUpperCase();
  return { pais, cont: CONTINENTE[pais] || req.cf?.continent || "??" };
}

// foto do perfil (JPEG pequeno em base64, ~3 KB): só vai para o adversário e é apagada 3 h depois da partida
const fotoDe = (corpo) => {
  const f = String(corpo.foto || "");
  return f.length <= 24000 && /^[A-Za-z0-9+/=]*$/.test(f) && f !== "" ? f : null;
};

// nome mostrado ao adversário: o do pedido (o perfil no servidor pode estar alguns segundos atrás), limpo e curto
const nomeDe = (corpo, perfil) => (String(corpo.nome || perfil.nome || "Jogador").replace(/[\u0000-\u001f<>]/g, "").trim() || "Jogador").slice(0, 16);

function deckValido(deck, cartas) {
  return Array.isArray(deck) && deck.length === 32 && deck.every((c) => cartas[c]);
}

async function novaPartida(env, a, b, estado, pidFixo) {
  const pid = pidFixo || aleatorio(10);
  await env.DB.prepare("UPDATE partidas SET foto0=NULL, foto1=NULL WHERE criado < ? AND estado != 'jogando'").bind(agora() - 3 * 3600).run();
  const sem = crypto.getRandomValues(new Uint32Array(1))[0] % 2000000000;
  await env.DB.prepare(`INSERT OR IGNORE INTO partidas (pid, codigo, j0, j1, nome0, nome1, deck0, deck1, semente, primeiro, estado, prazo, contato0, contato1, criado)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`)
    .bind(pid, a.codigo || null, a.id, b?.id || null, a.nome, b?.nome || null, a.deck, b?.deck || null, sem, sem % 2, estado,
      agora() + ACEITAR_EM, agora(), agora(), agora()).run();
  await env.DB.prepare("UPDATE partidas SET foto0=?, foto1=? WHERE pid=?").bind(a.foto || null, b?.foto || null, pid).run();
  return pid;
}

// tenta parear quem está na fila (sem partida) com o melhor adversário pela região e pelo tempo de espera
async function parear(env, eu) {
  const lista = (await env.DB.prepare("SELECT * FROM fila WHERE partida IS NULL AND id != ? AND visto > ? ORDER BY entrou")
    .bind(eu.id, agora() - 30).all()).results;
  const espera = agora() - eu.entrou;
  const escolha = lista.find((o) => o.pais === eu.pais) || (espera >= 5 ? lista.find((o) => o.cont === eu.cont) : null) ||
    (espera >= 15 ? lista[0] : null) || (lista.find((o) => agora() - o.entrou >= 15) ?? null);
  if (!escolha) return null;
  const pid = await novaPartida(env, eu, escolha, "aceitar");
  // os dois aparelhos podem tentar parear ao mesmo tempo: só vale se os dois ainda estavam livres
  const r = await env.DB.prepare("UPDATE fila SET partida=? WHERE id IN (?, ?) AND partida IS NULL").bind(pid, eu.id, escolha.id).run();
  if ((r.meta?.changes ?? 2) < 2) {
    await env.DB.batch([env.DB.prepare("UPDATE fila SET partida=NULL WHERE partida=?").bind(pid),
      env.DB.prepare("DELETE FROM partidas WHERE pid=?").bind(pid)]);
    return null;
  }
  return pid;
}

async function infoPartida(env, pid, id) {
  const p = await env.DB.prepare("SELECT * FROM partidas WHERE pid=?").bind(pid).first();
  if (!p) return null;
  const eu = p.j0 === id ? 0 : (p.j1 === id ? 1 : -1);
  if (eu < 0) return null;
  // queda: o outro sem contato há mais de QUEDA s numa partida em andamento → vitória de quem ficou
  if (p.estado === "jogando" && agora() - (eu === 0 ? p.contato1 : p.contato0) > QUEDA) {
    await env.DB.prepare("UPDATE partidas SET estado='fim', vencedor=? WHERE pid=?").bind(eu, pid).run();
    p.estado = "fim"; p.vencedor = eu; p.queda = true;
  }
  if (p.estado === "aceitar" && agora() > p.prazo) {
    await cancelar(env, p, "tempo");
    p.estado = "cancelada";
  }
  return {
    pid, eu, estado: p.estado, semente: p.semente, primeiro: p.primeiro, vencedor: p.vencedor, codigo: p.codigo, queda: !!p.queda,
    adversario: eu === 0 ? p.nome1 : p.nome0, foto_op: (eu === 0 ? p.foto1 : p.foto0) || "",
    op_ausente: p.estado === "jogando" ? Math.max(0, agora() - (eu === 0 ? p.contato1 : p.contato0)) : 0, deck_eu: JSON.parse((eu === 0 ? p.deck0 : p.deck1) || "[]"),
    deck_op: JSON.parse((eu === 0 ? p.deck1 : p.deck0) || "[]"), prazo: p.prazo - agora(),
    aceitei: !!(eu === 0 ? p.aceite0 : p.aceite1), aceite_op: (eu === 0 ? p.aceite1 : p.aceite0),
    revanche: (p.revanche0 | 0) + (p.revanche1 | 0), revanche_eu: !!(eu === 0 ? p.revanche0 : p.revanche1), revanche_pid: p.revanche_pid || "",
  };
}

async function cancelar(env, p, motivo) {
  await env.DB.prepare("UPDATE partidas SET estado='cancelada' WHERE pid=?").bind(p.pid).run();
  // quem aceitou (ou não recusou) volta para a fila; quem recusou ou deixou passar o tempo sai
  for (const [j, ace] of [[p.j0, p.aceite0], [p.j1, p.aceite1]]) {
    if (!j) continue;
    if (ace === 1) await env.DB.prepare("UPDATE fila SET partida=NULL, entrou=?, visto=? WHERE id=?").bind(agora(), agora(), j).run();
    else await env.DB.prepare("DELETE FROM fila WHERE id=?").bind(j).run();
  }
}

export async function rotaMulti(req, env, url, corpo, id, perfil, D, json, erro) {
  const caminho = url.pathname;
  const contato = async (pid) => {
    const p = await env.DB.prepare("SELECT j0 FROM partidas WHERE pid=?").bind(pid).first();
    if (p) await env.DB.prepare(`UPDATE partidas SET ${p.j0 === id ? "contato0" : "contato1"}=? WHERE pid=?`).bind(agora(), pid).run();
  };

  if (caminho === "/v1/mm/buscar" && req.method === "POST") {
    if (!deckValido(corpo.deck, D.cartas)) return erro("deck inválido (32 cartas)");
    const { pais, cont } = regiao(req);
    const eu = { id, nome: nomeDe(corpo, perfil), deck: JSON.stringify(corpo.deck), pais, cont, entrou: agora(), foto: fotoDe(corpo) };
    await env.DB.prepare("INSERT INTO fila (id, nome, deck, pais, cont, entrou, visto, partida, foto) VALUES (?, ?, ?, ?, ?, ?, ?, NULL, ?) ON CONFLICT(id) DO UPDATE SET nome=excluded.nome, deck=excluded.deck, pais=excluded.pais, cont=excluded.cont, entrou=excluded.entrou, visto=excluded.visto, partida=NULL, foto=excluded.foto")
      .bind(eu.id, eu.nome, eu.deck, pais, cont, eu.entrou, eu.entrou, eu.foto).run();
    const pid = await parear(env, eu);
    return json({ ok: true, pais, cont, pid });
  }
  if (caminho === "/v1/mm/estado") {                    // long-poll: devolve quando achar partida (ou em 20 s)
    for (let k = 0; k < parseInt(env.ESPERA_S || "20", 10) * 2; k++) {
      const f = await env.DB.prepare("SELECT * FROM fila WHERE id=?").bind(id).first();
      if (!f) return json({ ok: true, estado: "fora" });
      if (k % 4 === 0) await env.DB.prepare("UPDATE fila SET visto=? WHERE id=?").bind(agora(), id).run();
      if (f.partida) return json({ ok: true, estado: "encontrada", partida: await infoPartida(env, f.partida, id) });
      const pid = await parear(env, f);
      if (pid) return json({ ok: true, estado: "encontrada", partida: await infoPartida(env, pid, id) });
      await dormir(500);
    }
    const f = await env.DB.prepare("SELECT entrou, pais, cont FROM fila WHERE id=?").bind(id).first();
    return json({ ok: true, estado: "buscando", espera: f ? agora() - f.entrou : 0 });
  }
  if (caminho === "/v1/mm/cancelar" && req.method === "POST") {
    await env.DB.prepare("DELETE FROM fila WHERE id=?").bind(id).run();
    return json({ ok: true });
  }
  if (caminho === "/v1/mm/responder" && req.method === "POST") {
    const p = await env.DB.prepare("SELECT * FROM partidas WHERE pid=?").bind(String(corpo.pid)).first();
    if (!p || p.estado !== "aceitar") return erro("partida indisponível", 410);
    const lado = p.j0 === id ? 0 : 1;
    if (!corpo.aceitar) {
      await env.DB.prepare(`UPDATE partidas SET aceite${lado}=-1 WHERE pid=?`).bind(p.pid).run();
      p[`aceite${lado}`] = -1; await cancelar(env, p, "recusou");
      return json({ ok: true, estado: "cancelada" });
    }
    await env.DB.prepare(`UPDATE partidas SET aceite${lado}=1 WHERE pid=?`).bind(p.pid).run();
    p[`aceite${lado}`] = 1;
    if (p.aceite0 === 1 && p.aceite1 === 1) {
      await env.DB.prepare("UPDATE partidas SET estado='jogando', contato0=?, contato1=? WHERE pid=?").bind(agora(), agora(), p.pid).run();
      await env.DB.prepare("DELETE FROM fila WHERE id IN (?, ?)").bind(p.j0, p.j1).run();
    }
    return json({ ok: true, partida: await infoPartida(env, p.pid, id) });
  }
  if (caminho === "/v1/sala/criar" && req.method === "POST") {
    if (!deckValido(corpo.deck, D.cartas)) return erro("deck inválido (32 cartas)");
    const letras = "ABCDEFGHJKLMNPQRSTUVWXYZ";
    const codigo = [...crypto.getRandomValues(new Uint8Array(4))].map((b) => letras[b % letras.length]).join("");
    const pid = await novaPartida(env, { id, nome: nomeDe(corpo, perfil), deck: JSON.stringify(corpo.deck), codigo, foto: fotoDe(corpo) }, null, "sala");
    await env.DB.prepare("UPDATE partidas SET prazo=? WHERE pid=?").bind(agora() + 900, pid).run();
    return json({ ok: true, codigo, partida: await infoPartida(env, pid, id) });
  }
  if (caminho === "/v1/sala/entrar" && req.method === "POST") {
    if (!deckValido(corpo.deck, D.cartas)) return erro("deck inválido (32 cartas)");
    const cod = String(corpo.codigo || "").toUpperCase().trim();
    const p = await env.DB.prepare("SELECT * FROM partidas WHERE codigo=? AND estado='sala' AND prazo > ?").bind(cod, agora()).first();
    if (!p) return erro("sala não encontrada", 404);
    if (p.j0 === id) return erro("é a sua própria sala");
    await env.DB.prepare("UPDATE partidas SET j1=?, nome1=?, deck1=?, foto1=?, estado='jogando', contato0=?, contato1=? WHERE pid=?")
      .bind(id, nomeDe(corpo, perfil), JSON.stringify(corpo.deck), fotoDe(corpo), agora(), agora(), p.pid).run();
    return json({ ok: true, partida: await infoPartida(env, p.pid, id) });
  }
  const m = /^\/v1\/partida\/([0-9a-f]{20})(\/[a-z]+)?$/.exec(caminho);
  if (m) {
    const pid = m[1], sub = m[2] || "";
    const info = await infoPartida(env, pid, id);
    if (!info) return erro("partida não encontrada", 404);
    await contato(pid);
    if (sub === "" ) {                                  // long-poll do estado (sala esperando o amigo, revanche...)
      const desde = String(url.searchParams.get("estado") || "");
      const rev = String(url.searchParams.get("rev") || "");
      for (let k = 0; k < parseInt(env.ESPERA_S || "20", 10) * 2; k++) {
        const i = await infoPartida(env, pid, id);
        if (i.estado !== desde || (rev !== "" && rev !== String(i.revanche)) || i.revanche_pid) return json({ ok: true, partida: i });
        await dormir(500);
      }
      return json({ ok: true, partida: await infoPartida(env, pid, id) });
    }
    if (sub === "/acao" && req.method === "POST") {    // anexa a próxima ação (seq precisa ser a seguinte)
      if (info.estado !== "jogando") return erro("partida encerrada", 410);
      // o servidor dá a ordem (seq); a mesma ação reenviada (mesmo n do jogador) não duplica
      const n = corpo.n | 0;
      const ja = await env.DB.prepare("SELECT seq FROM acoes WHERE pid=? AND jogador=? AND json_extract(dados, '$.n')=?").bind(pid, info.eu, n).first();
      if (ja) return json({ ok: true, seq: ja.seq });
      const dados = { ...(corpo.dados || {}), n };
      let seq = 0;
      for (let t = 0; t < 5 && !seq; t++) {
        const ult = await env.DB.prepare("SELECT MAX(seq) s FROM acoes WHERE pid=?").bind(pid).first();
        const r = await env.DB.prepare("INSERT OR IGNORE INTO acoes (pid, seq, jogador, dados, ts) VALUES (?, ?, ?, ?, ?)")
          .bind(pid, (ult?.s ?? 0) + 1, info.eu, JSON.stringify(dados), agora()).run();
        if ((r.meta?.changes ?? 1) > 0) seq = (ult?.s ?? 0) + 1;
      }
      if (!seq) return erro("tente de novo", 503);
      if (corpo.dados?.tipo === "desistir")
        await env.DB.prepare("UPDATE partidas SET estado='fim', vencedor=? WHERE pid=?").bind(1 - info.eu, pid).run();
      return json({ ok: true, seq });
    }
    if (sub === "/acoes") {                            // long-poll: ações com seq > desde
      const desde = parseInt(url.searchParams.get("desde") || "0", 10);
      // confere a cada POLL_MS (PC: 50 ms; Cloudflare grátis: 300 ms, para caber no limite de CPU) durante até ESPERA_S
      const passo = Math.max(20, parseInt(env.POLL_MS || "50", 10)), voltas = Math.ceil(parseInt(env.ESPERA_S || "20", 10) * 1000 / passo);
      for (let k = 0; k < voltas; k++) {
        const r = (await env.DB.prepare("SELECT seq, jogador, dados FROM acoes WHERE pid=? AND seq > ? ORDER BY seq").bind(pid, desde).all()).results;
        const i = await infoPartida(env, pid, id);
        if (r.length || i.estado !== "jogando") return json({ ok: true, acoes: r.map((a) => ({ seq: a.seq, jogador: a.jogador, dados: JSON.parse(a.dados) })), partida: i });
        await dormir(passo);
        if (k % Math.ceil(2000 / passo) === 0) await contato(pid);
      }
      return json({ ok: true, acoes: [], partida: await infoPartida(env, pid, id) });
    }
    if (sub === "/fim" && req.method === "POST") {
      const v = corpo.vencedor_eu === true ? info.eu : corpo.vencedor_eu === false ? 1 - info.eu : 2;
      await env.DB.prepare("UPDATE partidas SET estado='fim', vencedor=CASE WHEN vencedor < 0 THEN ? ELSE vencedor END WHERE pid=?").bind(v, pid).run();
      return json({ ok: true, partida: await infoPartida(env, pid, id) });
    }
    if (sub === "/revanche" && req.method === "POST") { // os dois pedem → nova partida com os mesmos decks
      if (info.estado !== "fim") return erro("a partida ainda não acabou", 409);
      if (corpo.recusar) {
        await env.DB.prepare("UPDATE partidas SET revanche0=-1, revanche1=-1 WHERE pid=?").bind(pid).run();
        return json({ ok: true, partida: await infoPartida(env, pid, id) });
      }
      await env.DB.prepare(`UPDATE partidas SET revanche${info.eu}=1 WHERE pid=? AND revanche${info.eu}=0`).bind(pid).run();
      const p = await env.DB.prepare("SELECT * FROM partidas WHERE pid=?").bind(pid).first();
      if (p.revanche0 === 1 && p.revanche1 === 1) {
        // pid da revanche é derivado do pid atual: se os dois pedirem juntos, criam a MESMA partida (INSERT OR IGNORE)
        const pid2 = (await crypto.subtle.digest("SHA-256", new TextEncoder().encode("revanche:" + pid)))
        const hex2 = [...new Uint8Array(pid2)].map((b) => b.toString(16).padStart(2, "0")).join("").slice(0, 20);
        await novaPartida(env, { id: p.j0, nome: p.nome0, deck: p.deck0, foto: p.foto0 }, { id: p.j1, nome: p.nome1, deck: p.deck1, foto: p.foto1 }, "jogando", hex2);
        await env.DB.prepare("UPDATE partidas SET revanche_pid=? WHERE pid=?").bind(hex2, pid).run();
      }
      return json({ ok: true, partida: await infoPartida(env, pid, id) });
    }
  }
  return null;
}
