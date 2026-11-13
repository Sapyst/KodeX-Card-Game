// Teste das otimizações do online (13/11/2026). Uso, com o servidor local assim:
//   npx wrangler dev --port 8787 --ip 127.0.0.1 --var DECKS_LIVRES_TESTE:1 --var SALA_LIMPAR_S:3
//   node teste/otimizacao_teste.mjs
// Confere: ping respondido sem a sala (auto-resposta), partida casual fora do ranking, limpeza da sala 3 s depois do fim
// (quem volta recebe só o resultado), limite diário de ranqueadas (429) e limite de pedidos por conta (429).
import { readFileSync } from "node:fs";
import { execSync } from "node:child_process";
const U = process.argv[2] || "http://127.0.0.1:8787";
const WS = U.replace(/^http/, "ws");
const D = JSON.parse(readFileSync(new URL("../src/dados.js", import.meta.url), "utf8").replace(/^[\s\S]*?export default /, "").replace(/;\s*$/, ""));
let falhas = 0; const ok = (c, m) => { console.log((c ? "OK      " : "FALHOU  ") + m); if (!c) falhas++; };
const espera = (ms) => new Promise((r) => setTimeout(r, ms));
const conta = async (nome) => { const r = await (await fetch(U + "/v1/conta", { method: "POST", body: JSON.stringify({ perfil_local: { nome } }) })).json(); return { auth: `KDX ${r.id}:${r.segredo}`, id: r.id }; };
const pedir = async (c, cam, corpo) => {
  const r = await fetch(U + cam, { method: corpo ? "POST" : "GET", headers: { authorization: c.auth }, body: corpo ? JSON.stringify(corpo) : undefined });
  return { status: r.status, ...(await r.json()) };
};
const sql = (q) => execSync(`npx wrangler d1 execute kodex --local --command "${q}"`, { cwd: new URL("..", import.meta.url).pathname, stdio: "pipe" });

const A = await conta("Ana"), B = await conta("Bia");
const deck = D.deck_inicial;

// ---- sala casual com juiz: ping sem acordar a sala, fim por desistência, limpeza e volta depois da limpeza
const s = await pedir(A, "/v1/sala/criar", { deck, juiz: true, nome: "Ana" });
const e = await pedir(B, "/v1/sala/entrar", { codigo: s.codigo, deck, juiz: true, nome: "Bia" });
ok(e.ok && e.partida.casual, "sala com código entra como casual");
const pid = s.partida.pid;
const abrir = (c) => new Promise((res) => {
  const ws = new WebSocket(`${WS}/v1/partida/${pid}/ws?auth=${encodeURIComponent(c.auth)}`);
  const j = { ws, msgs: [], fora: [] };
  ws.onmessage = (ev) => { const m = JSON.parse(ev.data); (m.s ? j.msgs : j.fora).push(m); };
  ws.onopen = () => res(j);
});
const a = await abrir(A), b = await abrir(B);
a.ws.send(JSON.stringify({ t: "ola", desde: 0 })); b.ws.send(JSON.stringify({ t: "ola", desde: 0 }));
await espera(600);
a.ws.send('{"t":"ping"}');
await espera(300);
ok(a.fora.some((m) => m.t === "pong"), "ping respondido (auto-resposta da Cloudflare)");
const ultimoB = b.msgs.length ? b.msgs[b.msgs.length - 1].s : 0;
b.ws.send(JSON.stringify({ t: "in", n: 1, t_turno: 0, d: { tipo: "desistir" } }));
await espera(800);
ok(a.msgs.some((m) => m.fim && m.fim.vencedor === 0), "desistência da Bia: juiz manda o fim (Ana vence)");
const info = await pedir(A, `/v1/partida/${pid}`);
ok(info.partida.estado === "fim" && info.partida.vencedor === 0, "resultado gravado no banco");
const pr = await pedir(A, "/v1/op", { tipo: "premio", motivo: "online", pid });
ok(pr.resultado?.moedas === 0 && pr.resultado?.casual, "vitória casual não paga moedas");
a.ws.close(); b.ws.close();
await espera(4500);                                      // SALA_LIMPAR_S=3: a sala já se limpou
const b2 = await abrir(B);
b2.ws.send(JSON.stringify({ t: "ola", desde: ultimoB }));
await espera(600);
const fimB = b2.msgs.find((m) => m.fim);
ok(fimB && fimB.fim.vencedor === 0 && fimB.s === ultimoB + 1, `sala limpa: quem volta recebe só o fim (s=${fimB?.s})`);
ok([...b2.msgs, ...b2.fora].some((m) => m.t === "pronto" && m.vez === -1), "…e o 'pronto' (o jogo sai da espera)");
b2.ws.close();

// ---- limite diário de ranqueadas
const dia = (await (await fetch(U + "/v1/saude")).json()).dia;
sql(`INSERT INTO limites (id, dia, motivo, n) VALUES ('${A.id}', ${dia}, 'ranqueada', 30) ON CONFLICT(id, dia, motivo) DO UPDATE SET n = 30`);
const bl = await pedir(A, "/v1/mm/buscar", { deck, juiz: true });
ok(bl.status === 429 && bl.erro === "limite de partidas ranqueadas de hoje", `30 ranqueadas no dia: busca recusada (${bl.status} ${bl.erro})`);
const sl = await pedir(A, "/v1/sala/criar", { deck, juiz: true });
ok(sl.ok, "…mas a sala com amigo (casual) continua liberada");
await pedir(A, "/v1/mm/cancelar", {});

// ---- limite de pedidos por conta (120 por minuto)
const rs = await Promise.all(Array.from({ length: 140 }, () => pedir(B, "/v1/perfil")));
const barrados = rs.filter((r) => r.status === 429).length;
ok(barrados > 0 && barrados <= 40, `140 pedidos em rajada: ${barrados} barrados com 429`);

console.log(falhas ? `---- ${falhas} FALHA(S)` : "---- OTIMIZAÇÃO OK");
process.exit(falhas ? 1 : 0);
