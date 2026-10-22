// Teste da sala com juiz (Durable Object + WebSocket). Uso: node teste/sala_teste.mjs [url]
// Duas contas entram numa sala com juiz; cada uma só passa a vez (mão inicial mantida), até o fim por fadiga.
// Confere: segredo das compras, recusa de jogada fora da vez/inválida, reconexão com reenvio, resultado no banco.
import { readFileSync } from "node:fs";
const U = process.argv[2] || "http://127.0.0.1:8787";
const WS = U.replace(/^http/, "ws");
const D = JSON.parse(readFileSync(new URL("../src/dados.js", import.meta.url), "utf8").replace(/^[\s\S]*?export default /, "").replace(/;\s*$/, ""));
let falhas = 0; const ok = (c, m) => { console.log((c ? "OK      " : "FALHOU  ") + m); if (!c) falhas++; };
const conta = async (nome) => { const r = await (await fetch(U + "/v1/conta", { method: "POST", body: JSON.stringify({ perfil_local: { nome } }) })).json(); return `KDX ${r.id}:${r.segredo}`; };
const pedir = async (a, cam, corpo) => (await fetch(U + cam, { method: corpo ? "POST" : "GET", headers: { authorization: a }, body: corpo ? JSON.stringify(corpo) : undefined })).json();
const espera = (ms) => new Promise((r) => setTimeout(r, ms));

const A = await conta("Ana"), B = await conta("Bia");
const deckA = D.deck_inicial, deckB = [...D.deck_inicial].reverse();
const s = await pedir(A, "/v1/sala/criar", { deck: deckA, juiz: true, nome: "Ana" });
const e = await pedir(B, "/v1/sala/entrar", { codigo: s.codigo, deck: deckB, juiz: true, nome: "Bia" });
ok(e.ok && e.partida.juiz && e.partida.deck_op.length === 0, "partida com juiz não manda o deck do adversário");
const pid = s.partida.pid;

function jogador(nome, auth, lado) {
  const j = { nome, lado, msgs: [], ultimo: 0, n: 0, turno: 0, fim: null, erros: [] };
  j.abrir = () => new Promise((res) => {
    j.ws = new WebSocket(`${WS}/v1/partida/${pid}/ws?auth=${encodeURIComponent(auth)}`);
    j.ws.onopen = () => { j.ws.send(JSON.stringify({ t: "ola", desde: j.ultimo })); res(); };
    j.ws.onmessage = (ev) => {
      const m = JSON.parse(ev.data);
      if (m.t === "erro") { j.erros.push(m.erro); return; }
      if (m.t === "pedido") { j.pedido = m; return; }
      if (m.t === "pronto" || m.t === "pong") return;
      if (m.s <= j.ultimo) return;
      j.ultimo = m.s; j.msgs.push(m);
      if (m.r?.r === "turno") { j.turno = m.r.n; j.ativo = +m.r.canon.split("|")[0].split("A")[1]; }
      if (m.fim) j.fim = m.fim;
    };
  });
  j.mandar = (d, turno = j.turno) => j.ws.send(JSON.stringify({ t: "in", n: ++j.n, t_turno: turno, d }));
  return j;
}
const a = jogador("Ana", A, 0), b = jogador("Bia", B, 1);
await a.abrir(); await b.abrir();
await espera(800);
const comprasA = a.msgs.filter((m) => m.r?.r === "compra" && m.r.lado === 0).length;
ok(comprasA === 4, `Ana recebe as 4 cartas da mão inicial dela (${comprasA})`);
ok(!b.msgs.some((m) => m.r?.r === "compra" && m.r.lado === 0), "Bia não recebe nenhuma carta da Ana");
// fora da vez: Bia tenta passar o turno antes da mão inicial
b.mandar({ tipo: "fim" }, 0); await espera(300);
ok(b.erros.length > 0, `jogada fora da vez recusada (${b.erros[0]})`);
a.mandar([], 0); b.mandar([], 0);
await espera(800);
// carta fora da mão (índice 9) deve ser recusada
const primeiro = a.msgs.find((m) => m.r?.r === "turno") ? 0 : 1;
let jogadas = 0, reconectou = false;
for (let k = 0; k < 900 && !a.fim; k++) {
  const quem = a.pedido && (!b.pedido || a.pedido.turno >= b.pedido.turno) && a.pedido.jogador === 0 ? a : b.pedido?.jogador === 1 ? b : a;
  const q = quem.pedido;
  if (!q) { await espera(50); continue; }
  quem.pedido = null;
  if (k === 3 && q.tipo === "acao") { quem.mandar({ tipo: "jogar", k: 9 }, q.turno); await espera(200); ok(quem.erros.some((x) => x.includes("fora da mão")), "carta inexistente recusada"); quem.pedido = q; continue; }
  if (k === 20 && !reconectou) {                       // Bia cai e volta: recebe o que perdeu
    reconectou = true;
    b.ws.close(); await espera(400);
    const antes = b.ultimo;
    if (quem === a) { a.mandar(q.tipo === "sim_nao" ? false : { tipo: "fim" }, q.turno); await espera(500); }
    else b.pedido = q;
    await b.abrir(); await espera(700);
    ok(b.ultimo >= antes, `reconexão recebeu o que faltou (${antes} → ${b.ultimo})`);
    continue;
  }
  quem.mandar(q.tipo === "sim_nao" ? false : q.tipo === "escolha" ? -1 : q.tipo === "mulligan" ? [] : { tipo: "fim" }, q.turno);
  jogadas++;
  await espera(40);
}
await espera(800);
if (!a.fim) { console.log("DEBUG a.ativo", a.ativo, "turno", a.turno, "erros A", a.erros.slice(-4), "erros B", b.erros.slice(-4)); console.log("ultimas A", JSON.stringify(a.msgs.slice(-3))); }
ok(!!a.fim && !!b.fim && a.fim.vencedor === b.fim.vencedor, `fim por fadiga: vencedor ${a.fim?.vencedor} (${a.turno} turnos)`);
const seqA = a.msgs.map((m) => m.s), seqB = b.msgs.map((m) => m.s);
ok(seqA.every((v, i) => v === i + 1) && seqB.every((v, i) => v === i + 1), "sequência sem buracos nos dois");
ok(!b.msgs.some((m) => m.r?.r === "compra" && m.r.lado === 0 && !m.r.queima), "em toda a partida a Bia nunca viu uma compra da Ana");
const info = await pedir(A, `/v1/partida/${pid}`);
ok(info.partida.estado === "fim" && info.partida.vencedor === a.fim.vencedor, "resultado gravado no banco pelo juiz");
a.ws.close(); b.ws.close();
console.log(falhas ? `---- ${falhas} FALHA(S)` : "---- SALA OK");
process.exit(falhas ? 1 : 0);
