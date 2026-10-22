// Painel de administração do KodeX (/admin): ver contas, o que há nelas, dar presente com mensagem (suporte, consolo,
// boost) e ler relatórios de erro. Protegido pela senha ADMIN_KEY (segredo do Worker: `npx wrangler secret put ADMIN_KEY`).
// O presente entra direto no perfil e vira uma carta no "correio" da conta: o jogo mostra a mensagem ao abrir.
import { PAGINA_ADMIN } from "./admin_pagina.js";
import { DESCRICAO, punicao, registrar, varredura } from "./moderacao.js";
import { CARTAS } from "./motor/cartas.js";

// pontuação de alerta por conta: soma dos pesos dos sinais dos últimos 7 dias que vieram depois da última revisão
async function pontuacoes(env, ag) {
  const r = (await env.DB.prepare(`SELECT s.id, SUM(s.peso) pts, COUNT(*) n, MAX(s.ts) ult FROM sinais s LEFT JOIN revisoes r ON r.id=s.id
    WHERE s.ts > ? AND (r.ts IS NULL OR s.ts > r.ts) GROUP BY s.id`).bind(ag - 7 * 86400).all()).results;
  const m = {};
  for (const x of r) m[x.id] = { pts: x.pts | 0, n: x.n | 0, ult: x.ult | 0 };
  return m;
}
async function punicoesTodas(env) {
  const r = (await env.DB.prepare("SELECT id, tipo, ate, motivo FROM punicoes").all()).results;
  const m = {}, ag = Math.floor(Date.now() / 1000);
  for (const x of r) if (x.tipo === "hard" || !x.ate || x.ate > ag) m[x.id] = x;
  return m;
}

const enc = new TextEncoder();
async function igual(dada, certa) {
  if (!certa || !dada) return false;
  const a = new Uint8Array(await crypto.subtle.digest("SHA-256", enc.encode(String(dada))));
  const b = new Uint8Array(await crypto.subtle.digest("SHA-256", enc.encode(String(certa))));
  let dif = 0;
  for (let i = 0; i < a.length; i++) dif |= a[i] ^ b[i];      // comparação sem atalho (tempo constante)
  return dif === 0;
}
// Papéis: ADMIN_KEY = admin (tudo); MOD_KEY (segredo opcional) = moderação, sem o reset de senha do Kode.
async function papelDe(env, dada) {
  if (await igual(dada, env.ADMIN_KEY)) return "admin";
  if (await igual(dada, env.MOD_KEY)) return "mod";
  return "";
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
      "x-robots-tag": "noindex", "content-security-policy": "default-src 'self' 'unsafe-inline'; img-src 'self' data: https://raw.githubusercontent.com" } });
  if (!url.pathname.startsWith("/admin/api/")) return null;
  const chave = (req.headers.get("authorization") || "").replace(/^Admin /, "");
  // trava contra chute: 5 senhas erradas na mesma conexão = 1 hora bloqueada (a senha é curta)
  const ip = req.headers.get("cf-connecting-ip") || "local";
  const ipk = "adm:" + [...new Uint8Array(await crypto.subtle.digest("SHA-256", enc.encode("kodex-adm:" + ip)))].slice(0, 12).map((b) => b.toString(16).padStart(2, "0")).join("");
  const hora = Math.floor(Date.now() / 3600000);
  const tent = await env.DB.prepare("SELECT n FROM limites WHERE id=? AND dia=? AND motivo='admin_falha'").bind(ipk, hora).first();
  if ((tent?.n | 0) >= 5) return erro("muitas tentativas erradas: espere 1 hora", 429);
  const papel = await papelDe(env, chave);
  if (!papel) {
    await env.DB.prepare("INSERT INTO limites (id, dia, motivo, n) VALUES (?, ?, 'admin_falha', 1) ON CONFLICT(id, dia, motivo) DO UPDATE SET n = n + 1").bind(ipk, hora).run();
    await new Promise((r) => setTimeout(r, 800));
    return erro("senha de admin errada", 401);
  }
  const rota = url.pathname.slice("/admin/api/".length);
  const ag = Math.floor(agora());

  if (rota === "resumo") {
    const um = async (sql, ...b) => Object.values((await env.DB.prepare(sql).bind(...b).first()) || { n: 0 })[0] | 0;
    return json({ ok: true, papel,
      contas: await um("SELECT COUNT(*) n FROM contas"),
      ativas_24h: await um("SELECT COUNT(*) n FROM perfis WHERE atualizado > ?", ag - 86400),
      ativas_7d: await um("SELECT COUNT(*) n FROM perfis WHERE atualizado > ?", ag - 7 * 86400),
      com_kode: await um("SELECT COUNT(*) n FROM kodes"), com_email: await um("SELECT COUNT(*) n FROM emails"),
      jogando_agora: await um("SELECT COUNT(*) n FROM partidas WHERE estado='jogando' AND contato0 > ? AND contato1 > ?", ag - 120, ag - 120),
      partidas_24h: await um("SELECT COUNT(*) n FROM partidas WHERE criado > ? AND estado IN ('jogando','fim')", ag - 86400),
      na_fila: await um("SELECT COUNT(*) n FROM fila WHERE partida IS NULL AND visto > ?", ag - 30),
      erros_7d: await um("SELECT COUNT(*) n FROM erros WHERE ts > ?", ag - 7 * 86400),
      alertas: Object.keys(await pontuacoes(env, ag)).length, punidas: Object.keys(await punicoesTodas(env)).length });
  }
  if (rota === "contas") {
    const q = String(url.searchParams.get("q") || "").trim().toLowerCase();
    const F = Object.fromEntries(url.searchParams);
    const pts = await pontuacoes(env, ag), puns = await punicoesTodas(env);
    const linhas = (await env.DB.prepare(`SELECT c.id, c.criado, p.atualizado, p.dados, k.usuario kode, e.email
      FROM contas c LEFT JOIN perfis p ON p.id=c.id LEFT JOIN kodes k ON k.id=c.id LEFT JOIN emails e ON e.id=c.id
      ORDER BY p.atualizado DESC LIMIT 500`).all()).results;
    const out = [];
    for (const l of linhas) {
      const p = l.dados ? JSON.parse(l.dados) : {};
      const nome = String(p.nome || "");
      if (q && !(nome.toLowerCase().includes(q) || String(l.kode || "").includes(q) || l.id.startsWith(q) ||
        l.id.slice(0, 6).toLowerCase() === q)) continue;
      const nivel = nivelDe(p.prog?.xp | 0, D.prog.nivel), visto = l.atualizado | 0, pun = puns[l.id], al = pts[l.id];
      if (F.atividade === "24h" && visto < ag - 86400) continue;
      if (F.atividade === "7d" && visto < ag - 7 * 86400) continue;
      if (F.atividade === "inativa" && visto > ag - 30 * 86400) continue;
      if (F.ban === "nenhum" && pun) continue;
      if (F.ban && F.ban !== "nenhum" && F.ban !== "todos" && (!pun || (F.ban !== "qualquer" && pun.tipo !== F.ban))) continue;
      if ((F.nivel_min | 0) > nivel || (F.moedas_min | 0) > (p.moedas | 0)) continue;
      if (F.kode === "1" && !l.kode) continue;
      if (F.email === "1" && !l.email) continue;
      if (F.alerta === "1" && !al) continue;
      out.push({ id: l.id, curto: l.id.slice(0, 6).toUpperCase(), nome, kode: l.kode || "", email: l.email ? l.email.replace(/^(.).*(@.*)$/, "$1***$2") : "",
        moedas: p.moedas | 0, koins: p.koins | 0, nivel, criado: l.criado, visto, ban: pun ? pun.tipo : "", alerta: al ? al.pts : 0 });
      if (out.length >= 100) break;
    }
    return json({ ok: true, contas: out });
  }
  // Reset do Kode. Moderação e admin: invalida a frase secreta (o jogo pede para gerar 12 palavras novas na próxima vez).
  // Só admin: também troca a senha por uma temporária. A senha é sorteada e reforçada NO NAVEGADOR do painel (o servidor
  // recebe só a chave reforçada, como no login) e o jogo obriga a escolher outra no próximo acesso. Desconecta os aparelhos.
  const mk = /^conta\/([0-9a-f]{24})\/kode_reset$/.exec(rota);
  if (mk && req.method === "POST") {
    const id = mk[1];
    const k = await env.DB.prepare("SELECT usuario FROM kodes WHERE id=?").bind(id).first();
    if (!k) return erro("esta conta não tem Kode", 404);
    const comSenha = !!corpo.senha;
    if (comSenha && papel !== "admin") return erro("só o admin pode trocar a senha", 403);
    if (comSenha && !/^[0-9a-f]{64}$/.test(String(corpo.chave_senha || ""))) return erro("chave da senha inválida");
    if (comSenha) {
      const sal = (await env.DB.prepare("SELECT sal FROM kodes WHERE id=?").bind(id).first()).sal;
      const hex = (buf) => [...new Uint8Array(buf)].map((b) => b.toString(16).padStart(2, "0")).join("");
      const sh = hex(await crypto.subtle.digest("SHA-256", enc.encode(sal + corpo.chave_senha)));
      await env.DB.prepare("UPDATE kodes SET senha_hash=?, senha_temp=1, frase_hash='', refazer_frase=1, falhas=0, bloqueado_ate=0 WHERE id=?").bind(sh, id).run();
      const seg = hex(crypto.getRandomValues(new Uint8Array(32)));                 // derruba as sessões abertas
      await env.DB.prepare("UPDATE contas SET segredo_hash=? WHERE id=?").bind(hex(await crypto.subtle.digest("SHA-256", enc.encode(seg))), id).run();
    } else {
      await env.DB.prepare("UPDATE kodes SET frase_hash='', refazer_frase=1 WHERE id=?").bind(id).run();
    }
    await registrar(env, comSenha ? "kode_reset_senha" : "kode_reset_frase", id, { usuario: k.usuario, papel });
    return json({ ok: true, usuario: k.usuario });
  }
  const mm = /^conta\/([0-9a-f]{24})\/(punir|perdoar|nota|revisado)$/.exec(rota);
  if (mm && req.method === "POST") {
    const [, id, acao] = mm;
    if (!(await env.DB.prepare("SELECT 1 FROM contas WHERE id=?").bind(id).first())) return erro("conta não encontrada", 404);
    if (acao === "punir") {
      const tipo = String(corpo.tipo || "");
      if (!["soft", "shadow", "hard"].includes(tipo)) return erro("tipo: soft, shadow ou hard");
      const dias = Math.max(0, Math.min(3650, Number(corpo.dias) || 0));
      if (tipo === "soft" && !dias) return erro("soft-ban precisa de dias");
      const ate = tipo === "hard" ? 0 : dias ? ag + Math.round(dias * 86400) : 0;     // shadow sem dias = até tirar
      const motivo = String(corpo.motivo || "").trim().slice(0, 300);
      if (!motivo) return erro("escreva o motivo (fica no registro)");
      await env.DB.prepare("INSERT INTO punicoes (id, tipo, ate, motivo, ts) VALUES (?, ?, ?, ?, ?) ON CONFLICT(id) DO UPDATE SET tipo=excluded.tipo, ate=excluded.ate, motivo=excluded.motivo, ts=excluded.ts")
        .bind(id, tipo, ate, motivo, ag).run();
      if (tipo !== "shadow") await env.DB.prepare("DELETE FROM fila WHERE id=?").bind(id).run();
      await registrar(env, "punir:" + tipo, id, { dias, motivo });
    } else if (acao === "perdoar") {
      await env.DB.prepare("DELETE FROM punicoes WHERE id=?").bind(id).run();
      await registrar(env, "perdoar", id, String(corpo.motivo || ""));
    } else if (acao === "nota") {
      const texto = String(corpo.texto || "").trim().slice(0, 1000);
      if (!texto) return erro("nota vazia");
      await env.DB.prepare("INSERT INTO notas (id, ts, texto) VALUES (?, ?, ?)").bind(id, ag, texto).run();
      await registrar(env, "nota", id, texto.slice(0, 120));
    } else {
      await env.DB.prepare("INSERT INTO revisoes (id, ts) VALUES (?, ?) ON CONFLICT(id) DO UPDATE SET ts=excluded.ts").bind(id, ag).run();
      await registrar(env, "revisado", id, "");
    }
    return json({ ok: true });
  }
  // Gerenciador da conta: soma (dar) ou subtrai (tirar) moedas, Koins, Essência, boosters grátis e cartas. Valores negativos
  // tiram (nunca abaixo de zero). Dar com mensagem vira carta no correio do jogo; tirar fica só no registro. Só admin tira.
  const ma = /^conta\/([0-9a-f]{24})\/ajustar$/.exec(rota);
  if (ma && req.method === "POST") {
    const id = ma[1];
    const p = await lerPerfil(env, id);
    if (!p) return erro("conta não encontrada", 404);
    const lim = (v, max) => Math.max(-max, Math.min(max, Math.trunc(Number(v) || 0)));
    const d = { moedas: lim(corpo.moedas, 100000), koins: lim(corpo.koins, 10000), essencia: lim(corpo.essencia, 10000), boosters: lim(corpo.boosters, 100) };
    const cartas = {};
    for (const [cid, n] of Object.entries(corpo.cartas || {})) if (D.cartas[cid] && lim(n, 99)) cartas[cid] = lim(n, 99);
    const tira = Object.values(d).some((v) => v < 0) || Object.values(cartas).some((v) => v < 0);
    if (tira && papel !== "admin") return erro("só o admin pode tirar itens", 403);
    if (!Object.values(d).some(Boolean) && !Object.keys(cartas).length) return erro("nada para ajustar");
    const msg = String(corpo.mensagem || "").trim().slice(0, 400);
    p.moedas = Math.max(0, (p.moedas | 0) + d.moedas);
    p.koins = Math.max(0, (p.koins | 0) + d.koins);
    p.essencia = Math.max(0, (p.essencia | 0) + d.essencia);
    p.boosters_gratis = Math.max(0, (p.boosters_gratis | 0) + d.boosters);
    p.colecao ||= {};
    const dadas = [];
    for (const [cid, n] of Object.entries(cartas)) {
      p.colecao[cid] = Math.max(0, (p.colecao[cid] | 0) + n);
      if (n > 0) { (p.novas ||= {})[cid] = true; for (let k = 0; k < n; k++) dadas.push(cid); }
      if (!p.colecao[cid]) delete p.colecao[cid];
    }
    let carta = null;
    const pos = { moedas: Math.max(0, d.moedas), koins: Math.max(0, d.koins), essencia: Math.max(0, d.essencia), boosters: Math.max(0, d.boosters), cartas: dadas.slice(0, 40) };
    if (msg && (pos.moedas || pos.koins || pos.essencia || pos.boosters || pos.cartas.length)) {
      carta = { id: crypto.randomUUID().slice(0, 8), ts: ag, msg, de: String(corpo.de || "KodeX").slice(0, 24), itens: pos, lido: false };
      (p.correio ||= []).push(carta);
      if (p.correio.length > 30) p.correio = p.correio.slice(-30);
    }
    await gravarPerfil(env, id, p);
    await registrar(env, tira ? "ajuste (dar/tirar)" : "presente", id, { ...d, cartas, mensagem: msg, pacote: String(corpo.pacote || "") });
    return json({ ok: true, carta, perfil: resumoPerfil(p, D), colecao: p.colecao });
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
      const sinais = (await env.DB.prepare("SELECT ts, tipo, detalhe, peso FROM sinais WHERE id=? ORDER BY ts DESC LIMIT 40").bind(id).all()).results
        .map((x) => ({ ...x, descricao: DESCRICAO[x.tipo] || x.tipo }));
      const notas = (await env.DB.prepare("SELECT ts, texto FROM notas WHERE id=? ORDER BY ts DESC LIMIT 30").bind(id).all()).results;
      const rev = await env.DB.prepare("SELECT ts FROM revisoes WHERE id=?").bind(id).first();
      return json({ ok: true, id, curto: id.slice(0, 6).toUpperCase(), kode: k?.usuario || "", colecao: p.colecao || {},
        email: e ? e.email.replace(/^(.).*(@.*)$/, "$1***$2") : "", criado: c?.criado | 0, perfil: resumoPerfil(p, D), online: pt,
        punicao: await punicao(env, id), sinais, notas, revisado: rev?.ts | 0, alerta: (await pontuacoes(env, ag))[id]?.pts | 0 });
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
    await registrar(env, "presente", id, { ...it, mensagem: msg });
    return json({ ok: true, carta, perfil: resumoPerfil(p, D) });
  }
  if (rota === "erros") {
    const r = (await env.DB.prepare("SELECT e.id, e.ts, e.versao, e.so, e.texto, json_extract(p.dados,'$.nome') nome FROM erros e LEFT JOIN perfis p ON p.id=e.id ORDER BY e.ts DESC LIMIT 30").all()).results;
    return json({ ok: true, erros: r.map((x) => ({ ...x, curto: String(x.id || "").slice(0, 6).toUpperCase() })) });
  }
  if (rota === "cartas") return json({ ok: true, cartas: Object.keys(D.cartas),
    detalhes: Object.keys(D.cartas).map((id) => ({ id, nome: CARTAS[id]?.nome || id, cultura: D.cartas[id].c, tipo: D.cartas[id].t,
      custo: CARTAS[id]?.custo ?? 0, lendaria: !!D.cartas[id].l })) });
  // pacotes salvos do painel (combinações prontas de moedas, boosters e cartas para dar com um clique)
  if (rota === "pacotes" && req.method === "GET")
    return json({ ok: true, pacotes: (await env.DB.prepare("SELECT id, nome, dados, ts FROM admin_pacotes ORDER BY nome").all()).results
      .map((x) => ({ ...x, dados: JSON.parse(x.dados) })) });
  if (rota === "pacotes" && req.method === "POST") {
    const nome = String(corpo.nome || "").trim().slice(0, 60);
    if (!nome) return erro("dê um nome ao pacote");
    const lim = (v, max) => Math.max(0, Math.min(max, v | 0));
    const cartas = {};
    for (const [cid, n] of Object.entries(corpo.cartas || {})) if (D.cartas[cid] && (n | 0) > 0) cartas[cid] = lim(n, 99);
    const dados = { moedas: lim(corpo.moedas, 100000), koins: lim(corpo.koins, 10000), essencia: lim(corpo.essencia, 10000),
      boosters: lim(corpo.boosters, 100), cartas, mensagem: String(corpo.mensagem || "").slice(0, 400) };
    await env.DB.prepare("INSERT INTO admin_pacotes (id, nome, dados, ts) VALUES (?, ?, ?, ?) ON CONFLICT(nome) DO UPDATE SET dados=excluded.dados, ts=excluded.ts")
      .bind(crypto.randomUUID().slice(0, 8), nome, JSON.stringify(dados), ag).run();
    await registrar(env, "pacote salvo", "", { nome, ...dados });
    return json({ ok: true });
  }
  const mpk = /^pacotes\/([0-9a-f-]{8})\/apagar$/.exec(rota);
  if (mpk && req.method === "POST") {
    await env.DB.prepare("DELETE FROM admin_pacotes WHERE id=?").bind(mpk[1]).run();
    return json({ ok: true });
  }
  if (rota === "alertas") {                         // contas com sinais não revisados, da maior pontuação para a menor
    const pts = await pontuacoes(env, ag), puns = await punicoesTodas(env);
    const ids = Object.keys(pts).sort((a, b) => pts[b].pts - pts[a].pts).slice(0, 60);
    const out = [];
    for (const id of ids) {
      const pr = await env.DB.prepare("SELECT json_extract(dados,'$.nome') nome FROM perfis WHERE id=?").bind(id).first();
      const tipos = (await env.DB.prepare("SELECT tipo, COUNT(*) n, SUM(peso) pts FROM sinais WHERE id=? AND ts > ? GROUP BY tipo ORDER BY pts DESC")
        .bind(id, ag - 7 * 86400).all()).results.map((x) => ({ ...x, descricao: DESCRICAO[x.tipo] || x.tipo }));
      out.push({ id, curto: id.slice(0, 6).toUpperCase(), nome: pr?.nome || "", ...pts[id], tipos, ban: puns[id]?.tipo || "" });
    }
    return json({ ok: true, alertas: out });
  }
  if (rota === "registro") {
    const r = (await env.DB.prepare(`SELECT l.ts, l.acao, l.alvo, l.detalhe, json_extract(p.dados,'$.nome') nome FROM admin_log l
      LEFT JOIN perfis p ON p.id=l.alvo ORDER BY l.ts DESC LIMIT 150`).all()).results;
    return json({ ok: true, registro: r.map((x) => ({ ...x, curto: String(x.alvo || "").slice(0, 6).toUpperCase() })) });
  }
  if (rota === "varrer" && req.method === "POST") {
    const r = await varredura(env);
    await registrar(env, "varredura manual", "", r);
    return json({ ok: true, ...r });
  }
  return erro("rota de admin desconhecida", 404);
}
