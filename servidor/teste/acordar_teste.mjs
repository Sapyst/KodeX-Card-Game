// Teste sem servidor (node teste/acordar_teste.mjs): a sala dorme e acorda; o relógio do turno não pode zerar.
// Simula a sala dormindo e acordando: o relógio do turno não pode zerar.
globalThis.WebSocketRequestResponsePair = class { constructor(a, b) {} };
const { SalaPartida } = await import("../src/sala.js");
import { readFileSync } from "node:fs";
const D = JSON.parse(readFileSync(new URL("../src/dados.js", import.meta.url), "utf8").replace(/^[\s\S]*?export default /, "").replace(/;\s*$/, ""));
const mapa = new Map();
let alarme = 0;
const storage = {
  get: async (k) => Array.isArray(k) ? new Map(k.filter((x) => mapa.has(x)).map((x) => [x, structuredClone(mapa.get(x))])) : structuredClone(mapa.get(k)),
  put: async (k, v) => { if (typeof k === "object") for (const [a, b] of Object.entries(k)) mapa.set(a, structuredClone(b)); else mapa.set(k, structuredClone(v)); },
  list: async ({ prefix }) => new Map([...mapa].filter(([k]) => k.startsWith(prefix)).sort().map(([k, v]) => [k, structuredClone(v)])),
  setAlarm: async (t) => { alarme = t; }, getAlarm: async () => alarme || null, deleteAlarm: async () => { alarme = 0; }, deleteAll: async () => mapa.clear(),
};
const ctx = { storage, getWebSockets: () => [], waitUntil: () => {}, setWebSocketAutoResponse: () => {}, getTags: () => [] };
const env = { DB: { prepare: () => ({ bind: () => ({ run: async () => ({}) }) }) } };
let ok = 0, falha = 0; const conf = (c, m) => { console.log((c ? "OK " : "FALHOU ") + m); c ? ok++ : falha++; };
const real = Date.now;
let relogio = real();
Date.now = () => relogio;
const s1 = new SalaPartida(ctx, env);
await s1.carregar();
const setup = { pid: "x", decks: [D.deck_inicial, [...D.deck_inicial].reverse()], semente: 12345, primeiro: 0, inicio: relogio };
s1.setup = setup; await storage.put("setup", setup); s1.montar();
await s1.receber(0, 1, 0, []); await s1.receber(1, 1, 0, []);   // mãos iniciais
relogio += 5000;
const q = s1.pedido;
await s1.receber(q.jogador, 2, s1.p.turno_n, { tipo: "fim" }); // passa o turno
const desde1 = s1.desdePedido, turno1 = s1.p.turno_n;
await s1.agendar();
conf(alarme > relogio && alarme <= desde1 + 80000 + 500, `alarme marcado antes do prazo da jogada, nunca depois (toca em ${(alarme - relogio) / 1000} s)`);
// dorme 50 s e acorda (objeto novo, mesma memória gravada)
relogio += 50000;
const s2 = new SalaPartida(ctx, env);
await s2.carregar();
conf(s2.p.turno_n === turno1, `acordou no mesmo turno (${s2.p.turno_n})`);
conf(s2.desdePedido === desde1, `prazo do turno continua de onde estava (passaram ${(relogio - s2.desdePedido) / 1000} s, não 0)`);
conf(s2.ultN[q.jogador] === 2 && s2.ultN[1 - q.jogador] === 1, `números das entradas recuperados (${s2.ultN})`);
// alarme do prazo: 80 s depois da última jogada a sala passa o turno por quem sumiu
relogio = desde1 + 81000;
const s3 = new SalaPartida(ctx, env);
ctx.getWebSockets = () => [];
await s3.alarm();
conf(s3.p.turno_n === turno1 + 1 || s3.entradas.some((e) => e.forcado), `prazo vencido depois de dormir: sala passou o turno (turno ${s3.p.turno_n})`);
console.log(falha ? `---- ${falha} FALHA(S)` : "---- ACORDAR OK");
