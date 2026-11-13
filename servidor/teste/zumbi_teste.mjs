// Teste de socket morto (≈2 min). Uso: servidor local em 8787; node teste/zumbi_teste.mjs
// A pinga a cada 15 s; B conecta e fica muda (como app morto). A deve receber "presenca ligado:false" entre 50 e ~115 s.
import { readFileSync } from "node:fs";
const U = "http://127.0.0.1:8787", WS = "ws://127.0.0.1:8787";
const D = JSON.parse(readFileSync("src/dados.js", "utf8").replace(/^[\s\S]*?export default /, "").replace(/;\s*$/, ""));
const conta = async (n) => { const r = await (await fetch(U + "/v1/conta", { method: "POST", body: JSON.stringify({ perfil_local: { nome: n } }) })).json(); return `KDX ${r.id}:${r.segredo}`; };
const pedir = async (a, c, b) => (await fetch(U + c, { method: "POST", headers: { authorization: a }, body: JSON.stringify(b) })).json();
const A = await conta("Ana"), B = await conta("Bia");
const s = await pedir(A, "/v1/sala/criar", { deck: D.deck_inicial, juiz: true });
await pedir(B, "/v1/sala/entrar", { codigo: s.codigo, deck: D.deck_inicial, juiz: true });
const pid = s.partida.pid, t0 = Date.now();
const abrir = (a) => new Promise((res) => { const w = new WebSocket(`${WS}/v1/partida/${pid}/ws?auth=${encodeURIComponent(a)}`); w.onopen = () => { w.send(JSON.stringify({ t: "ola", desde: 0 })); res(w); }; });
const wa = await abrir(A), wb = await abrir(B);
let caiu = 0, fechouB = 0;
wa.onmessage = (e) => { const m = JSON.parse(e.data); if (m.t === "presenca" && m.ligado === false && !caiu) caiu = Date.now() - t0; };
wb.onclose = (e) => { fechouB = e.code; };
const iv = setInterval(() => wa.send('{"t":"ping"}'), 15000);
while (!caiu && Date.now() - t0 < 150000) await new Promise((r) => setTimeout(r, 1000));
clearInterval(iv);
console.log(caiu ? `OK  adversário mudo detectado em ${Math.round(caiu / 1000)} s (socket dele fechado com ${fechouB})` : "FALHOU  não detectou em 150 s");
console.log(caiu >= 50000 ? "OK  não derrubou antes de 50 s" : "FALHOU  derrubou cedo");
process.exit(0);
