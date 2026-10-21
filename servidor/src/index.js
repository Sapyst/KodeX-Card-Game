// Servidor do KodeX (Cloudflare Worker + D1). Fonte da verdade da economia: moedas, Koins, Essência, boosters,
// coleção, foils, versos e prêmios. O jogo mostra na hora e adota o perfil que o servidor devolve.
// Conta anônima: id + segredo (o servidor guarda só o SHA-256 do segredo). Sem email nesta fase.
// Tudo o que depende de hora usa a hora do servidor no fuso de Nova York (com horário de verão).
import D from "./dados.js";

const R = {
  MOEDAS_INICIO: 200, MOEDAS_DIA: 50, ACUMULO_DIAS: 3, KOINS_DIA: 10, KOINS_SEMANA: 100, KOINS_VERSAO: 30, MOEDAS_VERSAO: 50,
  BOOSTER_PRECO: 100, CHANCE_FOIL: 0.02, CHANCE_LENDARIA: 0.05, CHANCE_TRADICAO: 0.7, GARANTIA_LENDARIA: 10,
  TROCA: { comum: 20, lendaria: 60, foil: 150 },
  ESS_DESFAZ: { C: 5, R: 10, SR: 40, UR: 100 }, ESS_CRIA: { C: 40, R: 100, SR: 400 },
};
// Prêmios que o jogo informa (resultado de partida): valor e teto por dia de Nova York. O teto limita quem trapaceia.
const PREMIOS = {
  arcade: { teto: 10, moedas: (d) => [10, 15, 25][clamp(d.nivel | 0, 0, 2)] },
  torneio8: { teto: 3, moedas: (d) => [0, 30, 70, 150][clamp(d.posicao | 0, 0, 3)], booster: (d) => ((d.posicao | 0) >= 3 ? 1 : 0) },
  pere_vitoria: { teto: 15, moedas: () => 20 },
  pere_chefe: { teto: 2, moedas: () => 120, booster: () => 1 },
  diario: { teto: 1, moedas: () => 30 },
  lendario: { teto: 5 },
  enigma: { teto: 12 },
  choronzon: { teto: 3 },
};
const LIVRES = ["nome", "tem_foto", "decks", "deck_ativo", "verso", "novas", "pacote", "tarcade", "torneio", "versao_vista",
  "pere", "torneio_vencido", "pere_fim", "historico", "estat"];

const clamp = (v, a, b) => Math.max(a, Math.min(b, v));
const json = (obj, status = 200) => new Response(JSON.stringify(obj), {
  status, headers: { "content-type": "application/json; charset=utf-8", "access-control-allow-origin": "*",
    "access-control-allow-headers": "authorization, content-type", "access-control-allow-methods": "GET, POST, OPTIONS" } });
const erro = (msg, status = 400) => json({ ok: false, erro: msg }, status);

// ---------- tempo (Nova York) ----------
function domingo(ano, mes, n) {                       // meia-noite UTC do n-ésimo domingo do mês
  const t = Date.UTC(ano, mes - 1, 1) / 1000;
  const dsem = new Date(t * 1000).getUTCDay();
  return t + (((7 - dsem) % 7) + 7 * (n - 1)) * 86400;
}
function fusoNY(ts) {
  const ano = new Date(ts * 1000).getUTCFullYear();
  return ts >= domingo(ano, 3, 2) + 7 * 3600 && ts < domingo(ano, 11, 1) + 6 * 3600 ? -4 * 3600 : -5 * 3600;
}
const agora = () => Date.now() / 1000;
const dia = (ts = agora()) => Math.floor((ts + fusoNY(ts)) / 86400);
const semana = (ts = agora()) => Math.floor((dia(ts) + 3) / 7);       // começa na segunda
const semanaSexta = (ts = agora()) => Math.floor((dia(ts) - 1) / 7);  // começa na sexta

// ---------- regras das cartas (mesmas do jogo) ----------
const carta = (cid) => D.cartas[cid];
const copias = (p, cid) => p.colecao[cid] | 0;
const raridade = (cid, foil) => (carta(cid).l ? (foil ? "UR" : "SR") : (carta(cid).u <= 3 ? "C" : "R"));
function emUso(p, cid) {
  let n = 0;
  for (const d of p.decks || []) if (!d.livre) n += (d.cartas || []).filter((c) => c === cid).length;
  return n;
}
function perfilNovo() {
  const colecao = {};
  for (const cid of D.deck_inicial) colecao[cid] = (colecao[cid] | 0) + 1;
  const v = D.versoes[0];
  return { versao: 2, nome: "", tem_foto: false, moedas: R.MOEDAS_INICIO, koins: 0, essencia: 0, boosters_gratis: 0, colecao,
    foils: {}, versos: [], verso: "classico", decks: [{ nome: "Alta Magia", cartas: [...D.deck_inicial] }], deck_ativo: 0,
    versao_vista: v, versao_premiada: v };
}
function sortear(lista) { return lista[Math.floor(Math.random() * lista.length)]; }

function abrirBooster(p, gratis, trad) {
  if (gratis) {
    if ((p.boosters_gratis | 0) <= 0) return { erro: "sem booster grátis" };
    p.boosters_gratis -= 1;
  } else {
    if ((p.moedas | 0) < R.BOOSTER_PRECO) return { erro: "moedas insuficientes" };
    p.moedas -= R.BOOSTER_PRECO;
  }
  const comuns = [], lend = [], foils = [];
  for (const [cid, c] of Object.entries(D.cartas)) {
    if (c.c === "abismo") continue;
    if (c.l) { lend.push(cid); if (D.foils.includes(cid)) foils.push(cid); } else comuns.push(cid);
  }
  const daTrad = (l) => {
    if (!trad || Math.random() >= R.CHANCE_TRADICAO) return l;
    const f = l.filter((cid) => carta(cid).c === trad);
    return f.length ? f : l;
  };
  const saida = [];
  for (let k = 0; k < 3; k++) {
    const r = Math.random();
    if (r < R.CHANCE_FOIL && foils.length) saida.push({ id: sortear(daTrad(foils)), foil: true });
    else if (r < R.CHANCE_FOIL + R.CHANCE_LENDARIA) saida.push({ id: sortear(daTrad(lend)), foil: false });
    else saida.push({ id: sortear(daTrad(comuns)), foil: false });
  }
  if (!saida.some((e) => carta(e.id).t === "entidade")) {           // pelo menos 1 Entidade
    const ents = comuns.filter((cid) => carta(cid).t === "entidade");
    for (let k = 2; k >= 0; k--) if (!saida[k].foil && !carta(saida[k].id).l) { saida[k] = { id: sortear(ents), foil: false }; break; }
  }
  let temLend = saida.some((e) => carta(e.id).l);
  if (!temLend && (p.sem_lendaria | 0) >= R.GARANTIA_LENDARIA - 1) { saida[2] = { id: sortear(daTrad(lend)), foil: false }; temLend = true; }
  p.sem_lendaria = temLend ? 0 : (p.sem_lendaria | 0) + 1;
  for (const e of saida) {
    e.nova = copias(p, e.id) === 0;
    if (e.nova) (p.novas ||= {})[e.id] = true;
    p.colecao[e.id] = copias(p, e.id) + 1;
    if (e.foil) p.foils[e.id] = (p.foils[e.id] | 0) + 1;
  }
  return { cartas: saida };
}

function resgatar(p) {
  const r = p.resgates || {};
  const d = dia(), s = semana(), sx = semanaSexta();
  const dias = clamp(d - (r.dia ?? d - 1), 0, R.ACUMULO_DIAS);
  const bo = s > (r.semana ?? s - 1) ? 1 : 0;
  const ks = sx > (r.sexta ?? sx - 1) ? R.KOINS_SEMANA : 0;
  if (!dias && !bo && !ks) return { dias: 0, moedas: 0, booster: 0, koins: 0, koins_semana: 0 };
  p.resgates = { dia: d, semana: s, sexta: sx };
  p.moedas += dias * R.MOEDAS_DIA;
  p.boosters_gratis = (p.boosters_gratis | 0) + bo;
  p.koins = (p.koins | 0) + dias * R.KOINS_DIA + ks;
  return { dias, moedas: dias * R.MOEDAS_DIA, booster: bo, koins: dias * R.KOINS_DIA + ks, koins_semana: ks };
}

async function premio(env, id, p, d) {
  const regra = PREMIOS[d.motivo];
  if (!regra) return { erro: "motivo desconhecido" };
  const hoje = dia();
  const lim = await env.DB.prepare("SELECT n FROM limites WHERE id=? AND dia=? AND motivo=?").bind(id, hoje, d.motivo).first();
  if ((lim?.n | 0) >= regra.teto) return { moedas: 0, teto: true };
  await env.DB.prepare("INSERT INTO limites (id, dia, motivo, n) VALUES (?, ?, ?, 1) ON CONFLICT(id, dia, motivo) DO UPDATE SET n = n + 1")
    .bind(id, hoje, d.motivo).run();
  const out = { moedas: 0, booster: 0, koins: 0 };
  if (d.motivo === "diario") {
    if (p.diario_dia === hoje) return { moedas: 0, teto: true };
    p.diario_dia = hoje;
  }
  if (d.motivo === "lendario") {
    const cid = String(d.carta || "");
    if (!carta(cid)?.l) return { erro: "carta inválida" };
    const reg = (p.lendarios ||= {});
    const primeira = !(reg[cid] | 0);
    reg[cid] = (reg[cid] | 0) + 1;
    if (primeira && copias(p, cid) === 0) { p.colecao[cid] = 1; (p.novas ||= {})[cid] = true; out.carta = cid; }
    else out.moedas = primeira ? 60 : 15;
  } else if (d.motivo === "enigma") {
    const reg = (p.enigmas ||= {});
    const eid = String(d.enigma || "").slice(0, 8);
    if (!eid || reg[eid]) return { moedas: 0, repetido: true };
    reg[eid] = true; out.moedas = 10;
  } else if (d.motivo === "choronzon") {
    if (!p.choronzon_vencido) {
      p.choronzon_vencido = true; (p.titulos ||= []).push("selador_do_abismo"); out.moedas = 200; out.booster = 2;
    } else out.moedas = 25;
  } else {
    out.moedas = regra.moedas ? regra.moedas(d) : 0;
    out.booster = regra.booster ? regra.booster(d) : 0;
  }
  p.moedas += out.moedas;
  p.boosters_gratis = (p.boosters_gratis | 0) + out.booster;
  return out;
}

// Campos livres (nome, decks...): o servidor aceita, mas confere que decks normais só usam cópias que a conta tem.
function aplicarLivres(p, campos) {
  for (const k of LIVRES) if (k in campos) p[k] = campos[k];
  p.nome = String(p.nome || "").slice(0, 16);
  if (Array.isArray(p.historico)) p.historico = p.historico.slice(0, 30);
  if (JSON.stringify(p.historico || []).length > 400000) p.historico = (p.historico || []).slice(0, 10);
  if (!Array.isArray(p.decks)) p.decks = [];
  p.decks = p.decks.slice(0, 16).map((d) => ({ ...d, nome: String(d.nome || "").slice(0, 16),
    cartas: (Array.isArray(d.cartas) ? d.cartas : []).filter((c) => carta(c)).slice(0, 32) }));
  for (const d of p.decks) {
    if (d.livre) continue;
    const conta = {};
    d.cartas = d.cartas.filter((c) => { conta[c] = (conta[c] | 0) + 1; return conta[c] <= copias(p, c); });
  }
  if (p.verso && p.verso !== "classico" && !(p.versos || []).includes(p.verso)) p.verso = "classico";
}

async function op(env, id, p, d) {
  switch (d.tipo) {
    case "resgatar": return resgatar(p);
    case "booster": return abrirBooster(p, !!d.gratis, d.pacote && D.cartas && String(d.pacote));
    case "trocar": {
      const cid = String(d.carta);
      if (!carta(cid) || copias(p, cid) <= 1 || copias(p, cid) - 1 < emUso(p, cid)) return { erro: "não dá para trocar" };
      const foil = !!d.foil && (p.foils[cid] | 0) > 0;
      p.colecao[cid] -= 1;
      if (foil) p.foils[cid] -= 1;
      const v = foil ? R.TROCA.foil : (carta(cid).l ? R.TROCA.lendaria : R.TROCA.comum);
      p.moedas += v;
      return { moedas: v };
    }
    case "desfazer": {
      const cid = String(d.carta);
      if (!carta(cid) || copias(p, cid) <= 1 || copias(p, cid) - 1 < emUso(p, cid)) return { erro: "não dá para desfazer" };
      const fo = p.foils[cid] | 0;
      const foil = copias(p, cid) - fo <= 0;
      p.colecao[cid] -= 1;
      if (foil) p.foils[cid] -= 1;
      const g = R.ESS_DESFAZ[raridade(cid, foil)];
      p.essencia = (p.essencia | 0) + g;
      return { essencia: g };
    }
    case "criar": {
      const cid = String(d.carta);
      const c = carta(cid);
      if (!c || c.c === "abismo" || copias(p, cid) >= (c.l ? 1 : 2)) return { erro: "não dá para criar" };
      const custo = R.ESS_CRIA[raridade(cid, false)];
      if ((p.essencia | 0) < custo) return { erro: "essência insuficiente" };
      p.essencia -= custo;
      if (copias(p, cid) === 0) (p.novas ||= {})[cid] = true;
      p.colecao[cid] = copias(p, cid) + 1;
      return { carta: cid };
    }
    case "verso": {
      const vid = String(d.verso);
      const preco = D.versos[vid];
      if (preco === undefined || vid === "classico") return { erro: "verso inválido" };
      if ((p.versos || []).includes(vid)) return { erro: "já tem" };
      if ((p.koins | 0) < preco) return { erro: "Koins insuficientes" };
      p.koins -= preco; (p.versos ||= []).push(vid); p.verso = vid;
      return { verso: vid };
    }
    case "versao": {                                    // presente de versão nova, uma vez por versão publicada
      const v = String(d.versao);
      if (!D.versoes.includes(v) || p.versao_premiada === v) return { moedas: 0 };
      if (D.versoes.indexOf(v) > D.versoes.indexOf(p.versao_premiada ?? D.versoes[D.versoes.length - 1])) return { moedas: 0 };
      p.versao_premiada = v; p.koins = (p.koins | 0) + R.KOINS_VERSAO; p.moedas += R.MOEDAS_VERSAO;
      return { moedas: R.MOEDAS_VERSAO, koins: R.KOINS_VERSAO };
    }
    case "premio": return premio(env, id, p, d);
  }
  return { erro: "operação desconhecida" };
}

// ---------- email (opcional): código de 6 dígitos ----------
// Envio pelo Resend (env.RESEND_KEY + env.REMETENTE). Sem chave: em MODO_DEV=1 (só no PC, nunca público) o código volta
// na resposta para testar; fora disso o login por email responde "ainda não configurado".
const emailValido = (e) => /^[^\s@]{1,64}@[^\s@]{1,190}\.[a-z]{2,24}$/i.test(e);
async function enviarCodigo(env, email, codigo) {
  if (!env.RESEND_KEY) return env.MODO_DEV === "1" ? "dev" : "";
  const r = await fetch("https://api.resend.com/emails", {
    method: "POST", headers: { authorization: `Bearer ${env.RESEND_KEY}`, "content-type": "application/json" },
    body: JSON.stringify({ from: env.REMETENTE || "KodeX <onboarding@resend.dev>", to: [email], subject: "Seu código do KodeX",
      text: `Seu código do KodeX: ${codigo}\n\nVale por 10 minutos. Se não foi você, ignore este email.` }) });
  return r.ok ? "ok" : "";
}

// ---------- contas ----------
const hex = (buf) => [...new Uint8Array(buf)].map((b) => b.toString(16).padStart(2, "0")).join("");
const sha = async (s) => hex(await crypto.subtle.digest("SHA-256", new TextEncoder().encode(s)));
const aleatorio = (n) => hex(crypto.getRandomValues(new Uint8Array(n)));

async function autenticar(req, env) {
  const m = /^KDX ([0-9a-f]{24}):([0-9a-f]{64})$/.exec(req.headers.get("authorization") || "");
  if (!m) return null;
  const c = await env.DB.prepare("SELECT segredo_hash FROM contas WHERE id=?").bind(m[1]).first();
  return c && c.segredo_hash === (await sha(m[2])) ? m[1] : null;
}
// Limite por conexão (IP visto pela Cloudflare, guardado só como hash, por dia) contra criação em massa.
async function limiteIp(req, env, motivo, teto) {
  const ip = req.headers.get("cf-connecting-ip") || req.headers.get("x-forwarded-for") || "local";
  const chave = "ip:" + (await sha("kodex-ip:" + ip)).slice(0, 24);
  const hoje = dia();
  const lim = await env.DB.prepare("SELECT n FROM limites WHERE id=? AND dia=? AND motivo=?").bind(chave, hoje, motivo).first();
  if ((lim?.n | 0) >= teto) return false;
  await env.DB.prepare("INSERT INTO limites (id, dia, motivo, n) VALUES (?, ?, ?, 1) ON CONFLICT(id, dia, motivo) DO UPDATE SET n = n + 1")
    .bind(chave, hoje, motivo).run();
  return true;
}

async function lerPerfil(env, id) {
  const r = await env.DB.prepare("SELECT dados FROM perfis WHERE id=?").bind(id).first();
  return r ? JSON.parse(r.dados) : null;
}
const gravarPerfil = (env, id, p) =>
  env.DB.prepare("INSERT INTO perfis (id, dados, atualizado) VALUES (?, ?, ?) ON CONFLICT(id) DO UPDATE SET dados=excluded.dados, atualizado=excluded.atualizado")
    .bind(id, JSON.stringify(p), Math.floor(agora())).run();

// Migração de quem já jogava offline: aceita uma vez o progresso local, com tetos (alpha).
function importarLocal(local) {
  const p = perfilNovo();
  if (!local || typeof local !== "object") return p;
  p.moedas = clamp(local.moedas | 0, 0, 5000);
  p.koins = clamp(local.koins | 0, 0, 2000);
  p.essencia = clamp(local.essencia | 0, 0, 2000);
  p.boosters_gratis = clamp(local.boosters_gratis | 0, 0, 10);
  p.colecao = {};
  for (const [cid, n] of Object.entries(local.colecao || {})) if (carta(cid)) p.colecao[cid] = clamp(n | 0, 0, 3);
  for (const cid of D.deck_inicial) p.colecao[cid] = Math.max(p.colecao[cid] | 0, 1);
  p.foils = {};
  for (const [cid, n] of Object.entries(local.foils || {})) if (D.foils.includes(cid)) p.foils[cid] = clamp(n | 0, 0, p.colecao[cid] | 0);
  p.versos = (local.versos || []).filter((v) => v in D.versos);
  for (const k of ["resgates", "sem_lendaria", "lendarios", "enigmas", "diario_dia", "versao_premiada", "choronzon_vencido", "titulos"])
    if (k in local) p[k] = local[k];
  aplicarLivres(p, local);
  return p;
}

export default {
  async fetch(req, env) {
    if (req.method === "OPTIONS") return json({});
    const url = new URL(req.url);
    const corpo = req.method === "POST" ? await req.json().catch(() => ({})) : {};
    try {
      if (url.pathname === "/v1/saude") return json({ ok: true, agora: agora(), dia: dia() });
      if (url.pathname === "/v1/conta" && req.method === "POST") {
        if (!(await limiteIp(req, env, "conta", 20))) return erro("muitas contas criadas hoje nesta conexão", 429);
        const id = aleatorio(12), segredo = aleatorio(32);
        const p = corpo.perfil_local ? importarLocal(corpo.perfil_local) : perfilNovo();
        await env.DB.prepare("INSERT INTO contas (id, segredo_hash, criado) VALUES (?, ?, ?)").bind(id, await sha(segredo), Math.floor(agora())).run();
        await gravarPerfil(env, id, p);
        return json({ ok: true, id, segredo, perfil: p });
      }
      if (url.pathname === "/v1/entrar" && req.method === "POST") {   // usa um código de transferência
        const cod = String(corpo.codigo || "").toUpperCase().replace(/[^A-Z0-9]/g, "");
        const c = await env.DB.prepare("SELECT id, expira FROM codigos WHERE codigo=?").bind(cod).first();
        if (!c || c.expira < agora()) return erro("código inválido ou vencido", 404);
        await env.DB.prepare("DELETE FROM codigos WHERE codigo=?").bind(cod).run();
        const segredo = aleatorio(32);                                // novo segredo: o aparelho antigo é desconectado
        await env.DB.prepare("UPDATE contas SET segredo_hash=? WHERE id=?").bind(await sha(segredo), c.id).run();
        return json({ ok: true, id: c.id, segredo, perfil: await lerPerfil(env, c.id) });
      }
      if (url.pathname === "/v1/email/pedir" && req.method === "POST") {
        const email = String(corpo.email || "").trim().toLowerCase();
        if (!emailValido(email)) return erro("email inválido");
        if (!(await limiteIp(req, env, "email", 20))) return erro("muitos pedidos, tente mais tarde", 429);
        const ant = await env.DB.prepare("SELECT pedido FROM email_codigos WHERE email=?").bind(email).first();
        if (ant && agora() - ant.pedido < 60) return erro("espere 1 minuto para pedir outro código", 429);
        const codigo = String(100000 + (crypto.getRandomValues(new Uint32Array(1))[0] % 900000));
        const envio = await enviarCodigo(env, email, codigo);
        if (!envio) return erro("login por email ainda não configurado", 503);
        await env.DB.prepare("INSERT INTO email_codigos (email, codigo_hash, expira, tentativas, pedido) VALUES (?, ?, ?, 0, ?) ON CONFLICT(email) DO UPDATE SET codigo_hash=excluded.codigo_hash, expira=excluded.expira, tentativas=0, pedido=excluded.pedido")
          .bind(email, await sha(codigo + email), Math.floor(agora()) + 600, Math.floor(agora())).run();
        const ja = await env.DB.prepare("SELECT id FROM emails WHERE email=?").bind(email).first();
        return json({ ok: true, existe: !!ja, ...(envio === "dev" ? { dev_codigo: codigo } : {}) });
      }
      if (url.pathname === "/v1/email/confirmar" && req.method === "POST") {
        // email já ligado a uma conta → entra nela (novo segredo); senão → liga o email à conta deste aparelho
        const email = String(corpo.email || "").trim().toLowerCase();
        const c = await env.DB.prepare("SELECT codigo_hash, expira, tentativas FROM email_codigos WHERE email=?").bind(email).first();
        if (!c || c.expira < agora() || c.tentativas >= 5) return erro("código vencido, peça outro", 410);
        if (c.codigo_hash !== (await sha(String(corpo.codigo || "").trim() + email))) {
          await env.DB.prepare("UPDATE email_codigos SET tentativas = tentativas + 1 WHERE email=?").bind(email).run();
          return erro("código errado", 403);
        }
        await env.DB.prepare("DELETE FROM email_codigos WHERE email=?").bind(email).run();
        const ligado = await env.DB.prepare("SELECT id FROM emails WHERE email=?").bind(email).first();
        if (ligado) {
          const segredo = aleatorio(32);
          await env.DB.prepare("UPDATE contas SET segredo_hash=? WHERE id=?").bind(await sha(segredo), ligado.id).run();
          return json({ ok: true, entrou: true, id: ligado.id, segredo, perfil: await lerPerfil(env, ligado.id) });
        }
        const eu = await autenticar(req, env);
        if (!eu) return erro("abra o jogo conectado para ligar o email", 401);
        await env.DB.prepare("DELETE FROM emails WHERE id=?").bind(eu).run();       // uma conta, um email
        await env.DB.prepare("INSERT INTO emails (email, id, criado) VALUES (?, ?, ?)").bind(email, eu, Math.floor(agora())).run();
        return json({ ok: true, ligou: true });
      }
      // ---------- conta Kode ----------
      const usuarioValido = (u) => /^[a-z0-9_]{3,16}$/.test(u);
      const chaveValida = (k) => /^[0-9a-f]{64}$/.test(k);
      if (url.pathname === "/v1/kode/entrar" && req.method === "POST") {
        const u = String(corpo.usuario || "").toLowerCase();
        if (!usuarioValido(u) || !chaveValida(String(corpo.chave_senha || ""))) return erro("usuário ou senha errados", 403);
        if (!(await limiteIp(req, env, "kode_entrar", 60))) return erro("muitas tentativas, tente mais tarde", 429);
        const k = await env.DB.prepare("SELECT * FROM kodes WHERE usuario=?").bind(u).first();
        if (!k) return erro("usuário ou senha errados", 403);
        if (k.bloqueado_ate > agora()) return erro("muitas tentativas: espere 15 minutos", 429);
        if (k.senha_hash !== (await sha(k.sal + corpo.chave_senha))) {
          const f = k.falhas + 1;
          await env.DB.prepare("UPDATE kodes SET falhas=?, bloqueado_ate=? WHERE usuario=?").bind(f % 5, f >= 5 ? Math.floor(agora()) + 900 : 0, u).run();
          return erro("usuário ou senha errados", 403);
        }
        await env.DB.prepare("UPDATE kodes SET falhas=0 WHERE usuario=?").bind(u).run();
        const segredo = aleatorio(32);
        await env.DB.prepare("UPDATE contas SET segredo_hash=? WHERE id=?").bind(await sha(segredo), k.id).run();
        return json({ ok: true, id: k.id, segredo, perfil: await lerPerfil(env, k.id) });
      }
      if (url.pathname === "/v1/kode/recuperar" && req.method === "POST") {   // trocar ou recuperar a senha pela frase
        const u = String(corpo.usuario || "").toLowerCase();
        if (!usuarioValido(u) || !chaveValida(String(corpo.chave_frase || "")) || !chaveValida(String(corpo.nova_chave_senha || "")))
          return erro("dados inválidos");
        if (!(await limiteIp(req, env, "kode_recuperar", 20))) return erro("muitas tentativas, tente mais tarde", 429);
        const k = await env.DB.prepare("SELECT * FROM kodes WHERE usuario=?").bind(u).first();
        if (!k || k.frase_hash !== (await sha(k.sal + corpo.chave_frase))) return erro("usuário ou frase errados", 403);
        const segredo = aleatorio(32);
        await env.DB.prepare("UPDATE kodes SET senha_hash=?, falhas=0, bloqueado_ate=0 WHERE usuario=?").bind(await sha(k.sal + corpo.nova_chave_senha), u).run();
        await env.DB.prepare("UPDATE contas SET segredo_hash=? WHERE id=?").bind(await sha(segredo), k.id).run();
        return json({ ok: true, id: k.id, segredo, perfil: await lerPerfil(env, k.id) });
      }
      const id = await autenticar(req, env);
      if (!id) return erro("não autenticado", 401);
      if (url.pathname === "/v1/kode/criar" && req.method === "POST") {        // protege a conta deste aparelho com um Kode
        const u = String(corpo.usuario || "").toLowerCase();
        if (!usuarioValido(u)) return erro("usuário: 3 a 16 letras minúsculas, números ou _");
        if (!chaveValida(String(corpo.chave_senha || "")) || !chaveValida(String(corpo.chave_frase || ""))) return erro("dados inválidos");
        if (await env.DB.prepare("SELECT 1 FROM kodes WHERE usuario=?").bind(u).first()) return erro("esse usuário já existe", 409);
        if (await env.DB.prepare("SELECT 1 FROM kodes WHERE id=?").bind(id).first()) return erro("esta conta já tem um Kode", 409);
        const sal = aleatorio(16);
        await env.DB.prepare("INSERT INTO kodes (usuario, id, sal, senha_hash, frase_hash, criado) VALUES (?, ?, ?, ?, ?, ?)")
          .bind(u, id, sal, await sha(sal + corpo.chave_senha), await sha(sal + corpo.chave_frase), Math.floor(agora())).run();
        return json({ ok: true, usuario: u });
      }
      const p = await lerPerfil(env, id);
      if (url.pathname === "/v1/perfil") {
        const em = await env.DB.prepare("SELECT email FROM emails WHERE id=?").bind(id).first();
        const ko = await env.DB.prepare("SELECT usuario FROM kodes WHERE id=?").bind(id).first();
        return json({ ok: true, perfil: p, dia: dia(), email: em ? em.email.replace(/^(.).*(@.*)$/, "$1***$2") : "", kode: ko ? ko.usuario : "" });
      }
      if (url.pathname === "/v1/livre" && req.method === "POST") {
        aplicarLivres(p, corpo.campos || {});
        await gravarPerfil(env, id, p);
        return json({ ok: true, perfil: p });
      }
      if (url.pathname === "/v1/op" && req.method === "POST") {
        const res = await op(env, id, p, corpo);
        if (!res.erro) await gravarPerfil(env, id, p);
        return json({ ok: !res.erro, resultado: res, perfil: p });
      }
      if (url.pathname === "/v1/vincular" && req.method === "POST") {
        const letras = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
        const cod = [...crypto.getRandomValues(new Uint8Array(8))].map((b) => letras[b % letras.length]).join("");
        await env.DB.prepare("INSERT INTO codigos (codigo, id, expira) VALUES (?, ?, ?)").bind(cod, id, Math.floor(agora()) + 600).run();
        return json({ ok: true, codigo: cod, expira_em: 600 });
      }
      if (url.pathname === "/v1/apagar" && req.method === "POST") {   // excluir a conta (exigência da Play Store)
        for (const t of ["perfis", "limites", "codigos", "emails", "kodes"]) await env.DB.prepare(`DELETE FROM ${t} WHERE id=?`).bind(id).run();
        await env.DB.prepare("DELETE FROM contas WHERE id=?").bind(id).run();
        return json({ ok: true });
      }
      return erro("rota desconhecida", 404);
    } catch (e) {
      return erro("erro interno: " + e.message, 500);
    }
  },
};
