// Conta as linhas gravadas pela sala numa partida inteira (motor real, storage falso). Uso: node teste/gravacoes_teste.mjs [sala.js]
// Joga partidas inteiras na sala (motor real, storage falso) e conta linhas gravadas; também dorme/acorda no meio.
globalThis.WebSocketRequestResponsePair = class {};
import { readFileSync } from "node:fs";
const arq = process.argv[2] ? new URL(process.argv[2], "file://" + process.cwd() + "/").href : new URL("../src/sala.js", import.meta.url).href;
const { SalaPartida } = await import(arq);
const D = JSON.parse(readFileSync(new URL("../src/dados.js", import.meta.url), "utf8").replace(/^[\s\S]*?export default /, "").replace(/;\s*$/, ""));
let relogio = 1_800_000_000_000; Date.now = () => relogio;
function fazer() {
  const mapa = new Map(); let alarme = 0; const c = { linhas: 0, alarmes: 0, disparos: 0 };
  const storage = {
    get: async (k) => Array.isArray(k) ? new Map(k.filter((x) => mapa.has(x)).map((x) => [x, structuredClone(mapa.get(x))])) : structuredClone(mapa.get(k)),
    put: async (k, v) => { if (typeof k === "object") for (const [a, b] of Object.entries(k)) { mapa.set(a, structuredClone(b)); c.linhas++; } else { mapa.set(k, structuredClone(v)); c.linhas++; } },
    list: async ({ prefix }) => new Map([...mapa].filter(([k]) => k.startsWith(prefix)).sort().map(([k, v]) => [k, structuredClone(v)])),
    setAlarm: async (t) => { alarme = t; c.linhas++; c.alarmes++; }, getAlarm: async () => alarme || null, deleteAlarm: async () => { alarme = 0; }, deleteAll: async () => mapa.clear(),
  };
  const ws = (t) => ({ t, readyState: 1, send: () => {}, close: () => {}, deserializeAttachment: () => ({ desde: relogio }), serializeAttachment: () => {} });
  const socks = [ws("j0"), ws("j1")];
  const ctx = { storage, getWebSockets: (t) => t ? socks.filter((w) => w.t === t) : socks, waitUntil: () => {}, setWebSocketAutoResponse: () => {},
    getTags: (w) => [w.t], getWebSocketAutoResponseTimestamp: () => new Date(relogio - 5000) };
  return { ctx, c, mapa, alarme: () => alarme };
}
const env = { DB: { prepare: () => ({ bind: () => ({ run: async () => ({}) }) }) } };
const amb = fazer();
let sala = new SalaPartida(amb.ctx, env);
await sala.carregar();
const setup = { pid: "x", decks: [D.deck_inicial, [...D.deck_inicial].reverse()], semente: 777, primeiro: 0, inicio: relogio };
sala.setup = setup; await amb.ctx.storage.put("setup", setup); sala.montar();
const n = [0, 0]; let entradas = 0, dormiu = 0;
for (let k = 0; k < 2000 && !sala.p.acabou; k++) {
  // de vez em quando o alarme marcado vence antes da próxima jogada: toca (como na Cloudflare)
  const q = sala.pedido;
  if (!q && sala.p.pedido === undefined) break;
  if (q.tipo === "mulligan") { await sala.receber(0, ++n[0], 0, []); await sala.receber(1, ++n[1], 0, []); entradas += 2; continue; }
  relogio += 4000;                                       // 4 s por decisão
  if (amb.alarme() && amb.alarme() <= relogio) { amb.c.disparos++; await sala.alarm(); }
  if (k % 25 === 24) { sala = new SalaPartida(amb.ctx, env); await sala.carregar(); dormiu++; }   // dormiu e acordou
  const j = sala.pedido.jogador, d = sala.pedido.tipo === "sim_nao" ? false : sala.pedido.tipo === "escolha" ? -1 : { tipo: "fim" };
  await sala.receber(j, ++n[j], sala.p.turno_n, d); entradas++;
}
const chaves = amb.mapa.size;
console.log(`${arq.split("/").pop()}: acabou=${sala.p.acabou} turnos=${sala.p.turno_n} entradas=${entradas} acordou=${dormiu}× | linhas gravadas=${amb.c.linhas} (alarmes ${amb.c.alarmes}, disparos ${amb.c.disparos}) | linhas guardadas no fim=${chaves}`);
