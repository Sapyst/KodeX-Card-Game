// Painel de administração do KodeX (/admin): ver contas, o que há nelas, dar presente com mensagem (suporte, consolo,
// boost) e ler relatórios de erro. Protegido pela senha ADMIN_KEY (segredo do Worker: `npx wrangler secret put ADMIN_KEY`).
// O presente entra direto no perfil e vira uma carta no "correio" da conta: o jogo mostra a mensagem ao abrir.
import { PAGINA_ADMIN } from "./admin_pagina.js";

const enc = new TextEncoder();
async function senhaOk(env, dada) {
  if (!env.ADMIN_KEY || !dada) return false;
  const a = new Uint8Array(await crypto.subtle.digest("SHA-256", enc.encode(String(dada))));
  const b = new Uint8Array(await crypto.subtle.digest("SHA-256", enc.encode(String(env.ADMIN_KEY))));
  let dif = 0;
  for (let i = 0; i < a.length; i++) dif |= a[i] ^ b[i];      // comparação sem atalho (tempo constante)
  return dif === 0;
}

function nivelDe(xp, N) {
  let n = 1;
  const para = (k) => Math.min(N.base + N.passo * (k - 1), N.teto);
  while (xp >= para(n)) { xp -= para(n); n++; }
  return n;
}

function resumoPerfil(p, D) {
  const col = p.colecao || {};
  const pr = p.prog || {};
  return {
    nome: p.nome || "", moedas: p.moedas | 0, koins: p.koins | 0, essencia: p.essencia | 0, boosters: p.boosters_gratis | 0,
    cartas_distintas: Object.values(col).filter((n) => (n | 0) > 0).length, cartas_total: Object.values(col).reduce((a, n) => a + (n | 0), 0),
    foils: Object.values(p.foils || {}).filter((n) => (n | 0) > 0).length, versos: (p.versos || []).length,
    titulos: p.titulos || [], titulo: p.titulo || "", nivel: nivelDe(pr.xp | 0, D.prog.nivel), xp: pr.xp | 0,
    conquistas: (pr.conquistas || []).length, dias_seguidos: p.resgates?.seq | 0, dias_max: p.resgates?.max | 0,
    estat: p.estat || {}, historico: (p.historico || []).slice(0, 10).map((h) => ({ t: h.t, modo: h.modo, contra: h.contra,
      adversario: h.adversario, resultado: h.resultado, turnos: h.turnos })),
    decks: (p.decks || []).map((d) => ({ nome: d.nome, n: (d.cartas || []).length, livre: !!d.livre })),
    correio: (p.correio || []).slice(-10), torneio_vencido: !!p.torneio_vencido, choronzon_vencido: !!p.choronzon_vencido,
    enigmas: Object.keys(p.enigmas || {}).length,
  };
}

export async function rotaAdmin(req, env, url, corpo, h) {
  const { json, erro, lerPerfil, gravarPerfil, agora, D } = h;
  if (url.pathname === "/admin" || url.pathname === "/admin/")
    return new Response(PAGINA_ADMIN, { headers: { "content-type": "text/html; charset=utf-8", "cache-control": "no-store",
      "x-robots-tag": "noindex", "content-security-policy": "default-src 'self' 'unsafe-inline'; img-src 'self' data:" } });
  if (!url.pathname.startsWith("/admin/api/")) return null;
  const chave = (req.headers.get("authorization") || "").replace(/^Admin /, "");
  if (!(await senhaOk(env, chave))) {
    await new Promise((r) => setTimeout(r, 800));              // senha errada: espera (atrapalha chute em massa)
    return erro("senha de admin errada", 401);
  }
  const rota = url.pathname.slice("/admin/api/".length);
  const ag = Math.floor(agora());

  if (rota === "resumo") {
    const um = async (sql, ...b) => Object.values((await env.DB.prepare(sql).bind(...b).first()) || { n: 0 })[0] | 0;
    return json({ ok: true,
      contas: await um("SELECT COUNT(*) n FROM contas"),
      ativas_24h: await um("SELECT COUNT(*) n FROM perfis WHERE atualizado > ?", ag - 86400),
      ativas_7d: await um("SELECT COUNT(*) n FROM perfis WHERE atualizado > ?", ag - 7 * 86400),
      com_kode: await um("SELECT COUNT(*) n FROM kodes"), com_email: await um("SELECT COUNT(*) n FROM emails"),
      jogando_agora: await um("SELECT COUNT(*) n FROM partidas WHERE estado='jogando' AND contato0 > ? AND contato1 > ?", ag - 120, ag - 120),
      partidas_24h: await um("SELECT COUNT(*) n FROM partidas WHERE criado > ? AND estado IN ('jogando','fim')", ag - 86400),
      na_fila: await um("SELECT COUNT(*) n FROM fila WHERE partida IS NULL AND visto > ?", ag - 30),
      erros_7d: await um("SELECT COUNT(*) n FROM erros WHERE ts > ?", ag - 7 * 86400) });
  }
  if (rota === "contas") {
    const q = String(url.searchParams.get("q") || "").trim().toLowerCase();
    const linhas = (await env.DB.prepare(`SELECT c.id, c.criado, p.atualizado, p.dados, k.usuario kode, e.email
      FROM contas c LEFT JOIN perfis p ON p.id=c.id LEFT JOIN kodes k ON k.id=c.id LEFT JOIN emails e ON e.id=c.id
      ORDER BY p.atualizado DESC LIMIT 500`).all()).results;
    const out = [];
    for (const l of linhas) {
      const p = l.dados ? JSON.parse(l.dados) : {};
      const nome = String(p.nome || "");
      if (q && !(nome.toLowerCase().includes(q) || String(l.kode || "").includes(q) || l.id.startsWith(q) ||
        l.id.slice(0, 6).toLowerCase() === q)) continue;
      out.push({ id: l.id, curto: l.id.slice(0, 6).toUpperCase(), nome, kode: l.kode || "", email: l.email ? l.email.replace(/^(.).*(@.*)$/, "$1***$2") : "",
        moedas: p.moedas | 0, koins: p.koins | 0, nivel: nivelDe(p.prog?.xp | 0, D.prog.nivel), criado: l.criado, visto: l.atualizado | 0 });
      if (out.length >= 100) break;
    }
    return json({ ok: true, contas: out });
  }
  const mc = /^conta\/([0-9a-f]{24})(\/presente)?$/.exec(rota);
  if (mc) {
    const id = mc[1];
    const p = await lerPerfil(env, id);
    if (!p) return erro("conta não encontrada", 404);
    if (!mc[2]) {
      const k = await env.DB.prepare("SELECT usuario FROM kodes WHERE id=?").bind(id).first();
      const e = await env.DB.prepare("SELECT email FROM emails WHERE id=?").bind(id).first();
      const c = await env.DB.prepare("SELECT criado FROM contas WHERE id=?").bind(id).first();
      const pt = (await env.DB.prepare("SELECT pid, nome0, nome1, estado, vencedor, criado, j0 FROM partidas WHERE j0=? OR j1=? ORDER BY criado DESC LIMIT 8")
        .bind(id, id).all()).results.map((x) => ({ quando: x.criado, contra: x.j0 === id ? x.nome1 : x.nome0, estado: x.estado,
          resultado: x.vencedor < 0 ? "-" : x.vencedor === 2 ? "empate" : (x.vencedor === (x.j0 === id ? 0 : 1) ? "vitória" : "derrota") }));
      return json({ ok: true, id, curto: id.slice(0, 6).toUpperCase(), kode: k?.usuario || "",
        email: e ? e.email.replace(/^(.).*(@.*)$/, "$1***$2") : "", criado: c?.criado | 0, perfil: resumoPerfil(p, D), online: pt });
    }
    if (req.method !== "POST") return erro("use POST", 405);
    // presente: valores com teto por envio (evita erro de digitação gigante), mensagem obrigatória
    const lim = (v, max) => Math.max(0, Math.min(max, v | 0));
    const it = { moedas: lim(corpo.moedas, 100000), koins: lim(corpo.koins, 10000), essencia: lim(corpo.essencia, 10000),
      boosters: lim(corpo.boosters, 100), cartas: (Array.isArray(corpo.cartas) ? corpo.cartas : []).map(String).filter((c) => D.cartas[c]).slice(0, 20) };
    const msg = String(corpo.mensagem || "").trim().slice(0, 400);
    if (!msg) return erro("escreva uma mensagem para a pessoa");
    p.moedas = (p.moedas | 0) + it.moedas;
    p.koins = (p.koins | 0) + it.koins;
    p.essencia = (p.essencia | 0) + it.essencia;
    p.boosters_gratis = (p.boosters_gratis | 0) + it.boosters;
    p.colecao ||= {};
    for (const cid of it.cartas) { p.colecao[cid] = (p.colecao[cid] | 0) + 1; (p.novas ||= {})[cid] = true; }
    const carta = { id: crypto.randomUUID().slice(0, 8), ts: ag, msg, de: String(corpo.de || "KodeX").slice(0, 24), itens: it, lido: false };
    (p.correio ||= []).push(carta);
    if (p.correio.length > 30) p.correio = p.correio.slice(-30);
    await gravarPerfil(env, id, p);
    return json({ ok: true, carta, perfil: resumoPerfil(p, D) });
  }
  if (rota === "erros") {
    const r = (await env.DB.prepare("SELECT e.id, e.ts, e.versao, e.so, e.texto, json_extract(p.dados,'$.nome') nome FROM erros e LEFT JOIN perfis p ON p.id=e.id ORDER BY e.ts DESC LIMIT 30").all()).results;
    return json({ ok: true, erros: r.map((x) => ({ ...x, curto: String(x.id || "").slice(0, 6).toUpperCase() })) });
  }
  if (rota === "cartas") return json({ ok: true, cartas: Object.keys(D.cartas) });
  return erro("rota de admin desconhecida", 404);
}
