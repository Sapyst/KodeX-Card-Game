// Moderação do KodeX: sinais de comportamento alarmante (a pessoa não vê nada), punições (soft, shadow, hard) e a
// varredura agendada (cron a cada 30 min). O painel (/admin) lê tudo isto.
//
// Sinais na hora (peso): tetos de prêmio batidos (1), missão/semana/dia que não batem com o servidor (3), deck/carta
// inválidos mandados pelo jogo (2), abandono de partida online (1), Kode travado por muitas senhas erradas (2).
// Varredura: ganho de moedas > 2000 ou XP > 3000 desde a última olhada (3), vitória até o turno 4 (4), vitórias online
// ≥ 90% com 20+ partidas (2). Um mesmo sinal conta 1× por dia. Pontuação = soma dos pesos dos últimos 7 dias.

export const ESQUEMA_MOD = `
CREATE TABLE IF NOT EXISTS sinais (id TEXT, dia INTEGER, ts INTEGER, tipo TEXT, detalhe TEXT, peso INTEGER, UNIQUE (id, dia, tipo, detalhe));
CREATE INDEX IF NOT EXISTS sinais_id ON sinais (id);
CREATE TABLE IF NOT EXISTS punicoes (id TEXT PRIMARY KEY, tipo TEXT, ate INTEGER, motivo TEXT, ts INTEGER);
CREATE TABLE IF NOT EXISTS revisoes (id TEXT PRIMARY KEY, ts INTEGER);
CREATE TABLE IF NOT EXISTS notas (id TEXT, ts INTEGER, texto TEXT);
CREATE TABLE IF NOT EXISTS admin_log (ts INTEGER, acao TEXT, alvo TEXT, detalhe TEXT);
CREATE TABLE IF NOT EXISTS vistos (id TEXT PRIMARY KEY, ts INTEGER, moedas INTEGER, xp INTEGER);`;

const agora = () => Math.floor(Date.now() / 1000);
export const DESCRICAO = {
  teto_premio: "Bateu o teto diário de um prêmio", progresso_invalido: "Pediu missão/nível que não confere com o servidor",
  dados_invalidos: "Mandou deck ou carta inválidos", abandono: "Abandonou partida online", kode_bloqueio: "Kode travado por senha errada",
  ganho_moedas: "Ganho de moedas muito alto", ganho_xp: "Ganho de XP muito alto", vitoria_impossivel: "Vitória rápida demais",
  vitorias_suspeitas: "Taxa de vitórias online fora do normal",
};

/** Registra um sinal (silencioso; nunca atrapalha o pedido). */
export async function sinal(env, id, tipo, detalhe = "", peso = 1) {
  if (!id) return;
  try {
    const dia = Math.floor(agora() / 86400);
    await env.DB.prepare("INSERT OR IGNORE INTO sinais (id, dia, ts, tipo, detalhe, peso) VALUES (?, ?, ?, ?, ?, ?)")
      .bind(id, dia, agora(), tipo, String(detalhe).slice(0, 120), peso).run();
  } catch (e) { /* moderação nunca derruba o jogo */ }
}

/** Punição em vigor: {tipo: "soft"|"shadow"|"hard", ate, motivo} ou null. */
export async function punicao(env, id) {
  const p = await env.DB.prepare("SELECT tipo, ate, motivo FROM punicoes WHERE id=?").bind(id).first().catch(() => null);
  if (!p) return null;
  if (p.tipo !== "hard" && p.ate && p.ate < agora()) return null;   // venceu
  return p;
}

export async function registrar(env, acao, alvo, detalhe) {
  await env.DB.prepare("INSERT INTO admin_log (ts, acao, alvo, detalhe) VALUES (?, ?, ?, ?)")
    .bind(agora(), acao, alvo || "", typeof detalhe === "string" ? detalhe : JSON.stringify(detalhe || {})).run();
}

/** Varredura agendada: compara com a última olhada e procura padrões nas últimas partidas. */
export async function varredura(env, nivelDe) {
  const ag = agora();
  const lista = (await env.DB.prepare(`SELECT p.id, p.dados, v.ts vts, v.moedas vm, v.xp vx FROM perfis p LEFT JOIN vistos v ON v.id=p.id
    WHERE p.atualizado > ?`).bind(ag - 2 * 3600).all()).results;
  let n = 0;
  for (const l of lista) {
    const p = JSON.parse(l.dados || "{}");
    const moedas = p.moedas | 0, xp = p.prog?.xp | 0;
    if (l.vts) {
      const horas = Math.max(1, (ag - l.vts) / 3600);
      const dm = moedas - (l.vm | 0), dx = xp - (l.vx | 0);
      if (dm > 2000 * Math.min(1, horas / 24) + 500) { await sinal(env, l.id, "ganho_moedas", `+${dm} em ${Math.round(horas)} h`, 3); n++; }
      if (dx > 3000 * Math.min(1, horas / 24) + 600) { await sinal(env, l.id, "ganho_xp", `+${dx} XP em ${Math.round(horas)} h`, 3); n++; }
    }
    for (const h of (p.historico || []).slice(0, 10))
      if (h.resultado === "vitoria" && (h.turnos | 0) > 0 && (h.turnos | 0) <= 4 && (h.t | 0) > ag - 86400) {
        await sinal(env, l.id, "vitoria_impossivel", `turno ${h.turnos} · ${h.modo} · ${h.adversario}`, 4); n++; break;
      }
    const on = p.estat?.contra?.jogador;
    const tot = on ? (on.v | 0) + (on.d | 0) + (on.e | 0) : 0;
    if (tot >= 20 && (on.v | 0) / tot >= 0.9) { await sinal(env, l.id, "vitorias_suspeitas", `${on.v}/${tot} vitórias online`, 2); n++; }
    await env.DB.prepare("INSERT INTO vistos (id, ts, moedas, xp) VALUES (?, ?, ?, ?) ON CONFLICT(id) DO UPDATE SET ts=excluded.ts, moedas=excluded.moedas, xp=excluded.xp")
      .bind(l.id, ag, moedas, xp).run();
  }
  await env.DB.prepare("DELETE FROM sinais WHERE ts < ?").bind(ag - 60 * 86400).run();   // guarda 60 dias
  return { olhadas: lista.length, sinais: n };
}
