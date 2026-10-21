// Teste do multiplayer no servidor local: node teste/multi_teste.mjs [url]
import { readFileSync, writeFileSync } from "node:fs";
const D = JSON.parse(readFileSync(new URL("../src/dados.js", import.meta.url), "utf8").replace(/^[\s\S]*?export default /, "").replace(/;\s*$/, ""));
const U = process.argv[2] || "http://127.0.0.1:8787";
let falhas = 0;
const ok = (c, m) => { console.log((c ? "OK      " : "FALHOU  ") + m); if (!c) falhas++; };
// contas de teste guardadas em ~/.cache (o servidor limita 20 contas novas por dia por conexão)
const ARQ = (process.env.HOME || ".") + "/.cache/kodex_teste_contas.json";
let salvas = {};
try { salvas = JSON.parse(readFileSync(ARQ, "utf8")); } catch {}
async function conta(nome, pais) {
  const chave = U + "|" + nome;
  if (!salvas[chave]) {
    const r = await (await fetch(U + "/v1/conta", { method: "POST", body: JSON.stringify({ perfil_local: { nome } }) })).json();
    if (!r.ok) throw new Error("não deu para criar conta: " + r.erro);
    salvas[chave] = `KDX ${r.id}:${r.segredo}`;
    writeFileSync(ARQ, JSON.stringify(salvas));
  }
  const c = { auth: salvas[chave], pais };
  await fetch(U + "/v1/mm/cancelar", { method: "POST", headers: { authorization: c.auth }, body: "{}" });   // sai de fila antiga
  return c;
}
const pedir = async (c, cam, corpo) => (await fetch(U + cam, { method: corpo ? "POST" : "GET",
  headers: { authorization: c.auth, "cf-ipcountry": c.pais }, body: corpo ? JSON.stringify(corpo) : undefined })).json();
const deck = D.deck_inicial;

const a = await conta("Ana", "BR"), b = await conta("Bia", "BR"), c = await conta("Cid", "JP");
// sala por código
const s = await pedir(a, "/v1/sala/criar", { deck, nome: "Ana", foto: "AAAA" });
ok(s.ok && /^[A-Z]{4}$/.test(s.codigo), "sala criada " + s.codigo);
const espera = pedir(a, `/v1/partida/${s.partida.pid}?estado=sala`);       // long-poll do dono
const e = await pedir(b, "/v1/sala/entrar", { codigo: s.codigo.toLowerCase(), deck });
ok(e.ok && e.partida.estado === "jogando" && e.partida.eu === 1, "amiga entrou na sala");
const ea = await espera;
ok(ea.partida.estado === "jogando" && ea.partida.adversario === "Bia", "dono soube pelo long-poll");
ok(e.partida.foto_op === "AAAA" && ea.partida.foto_op === "", "foto vai só para o adversário");
ok(ea.partida.semente === e.partida.semente && ea.partida.primeiro === e.partida.primeiro, "mesma semente nos dois");
const pid = s.partida.pid;
// ações em ordem, long-poll e reenvio sem duplicar
const t0 = Date.now();
const lp = pedir(b, `/v1/partida/${pid}/acoes?desde=0`);
await new Promise((r) => setTimeout(r, 400));
await pedir(a, `/v1/partida/${pid}/acao`, { n: 1, dados: { tipo: "jogar", carta: 3 } });
const r1 = await lp;
ok(r1.acoes.length === 1 && r1.acoes[0].jogador === 0 && Date.now() - t0 < 2000, `long-poll entregou em ${Date.now() - t0} ms`);
await pedir(a, `/v1/partida/${pid}/acao`, { n: 1, dados: { tipo: "jogar", carta: 3 } });
await pedir(a, `/v1/partida/${pid}/acao`, { n: 2, dados: { tipo: "fim_turno" } });
const r2 = await pedir(b, `/v1/partida/${pid}/acoes?desde=0`);
ok(r2.acoes.length === 2 && r2.acoes[1].seq === 2, "reenvio não duplicou, ordem certa");
// desistência e revanche
await pedir(b, `/v1/partida/${pid}/acao`, { n: 1, dados: { tipo: "desistir" } });
const f = await pedir(a, `/v1/partida/${pid}/acoes?desde=2`);
ok(f.partida.estado === "fim" && f.partida.vencedor === 0, "desistência dá vitória ao outro");
// prêmio online: o servidor confere o resultado (Ana venceu por desistência) e paga uma vez só
const pa1 = await pedir(a, "/v1/op", { tipo: "premio", motivo: "online", pid });
const pa2 = await pedir(a, "/v1/op", { tipo: "premio", motivo: "online", pid });
const pb1 = await pedir(b, "/v1/op", { tipo: "premio", motivo: "online", pid });
ok(pa1.resultado?.moedas === 20 && pa2.resultado?.moedas === 0 && pb1.resultado?.moedas === 5, `prêmio online: vitória 20, repetido 0, derrota 5 (${pa1.resultado?.moedas}/${pa2.resultado?.moedas}/${pb1.resultado?.moedas})`);
const pc = await pedir(c, "/v1/op", { tipo: "premio", motivo: "online", pid });
ok(!pc.resultado?.moedas, "quem não jogou a partida não ganha");
const rv1 = await pedir(a, `/v1/partida/${pid}/revanche`, {});
ok(!rv1.partida.revanche_pid && rv1.partida.revanche === 1, "revanche espera o outro");
const [rv2, rv3] = await Promise.all([pedir(b, `/v1/partida/${pid}/revanche`, {}), pedir(a, `/v1/partida/${pid}`)]);
const rp = rv2.partida.revanche_pid;
ok(rp && rp.length === 20, "revanche criada");
const nova = await pedir(a, `/v1/partida/${rp}`);
ok(nova.ok && nova.partida.estado === "jogando" && nova.partida.adversario === "Bia", "revanche jogável pelos dois");
// busca: mesmo país pareia na hora; outro continente espera
const ba = await pedir(a, "/v1/mm/buscar", { deck });
const bc = await pedir(c, "/v1/mm/buscar", { deck });
ok(!bc.pid, "Japão não pareia na hora com Brasil");
const bb = await pedir(b, "/v1/mm/buscar", { deck });
ok(!!bb.pid, "Brasil × Brasil pareia na hora");
const ma = await pedir(a, "/v1/mm/estado");
ok(ma.estado === "encontrada" && ma.partida.estado === "aceitar", "Ana vê a partida para aceitar");
await pedir(a, "/v1/mm/responder", { pid: bb.pid, aceitar: true });
const rb = await pedir(b, "/v1/mm/responder", { pid: bb.pid, aceitar: true });
ok(rb.partida.estado === "jogando", "os dois aceitaram → jogando");
// recusa: quem aceitou volta pra fila, quem recusou sai
const t1 = Date.now();
const mc = await pedir(c, "/v1/mm/estado");   // espera Cid (JP) achar alguém global
ok(mc.estado === "buscando", "sozinho segue buscando após 20 s");
await pedir(a, "/v1/mm/buscar", { deck });
const mc2 = await pedir(c, "/v1/mm/estado");
ok(mc2.estado === "encontrada", `global depois de 15 s (${Math.round((Date.now() - t1) / 1000)} s)`);
await pedir(c, "/v1/mm/responder", { pid: mc2.partida.pid, aceitar: true });
await pedir(a, "/v1/mm/responder", { pid: mc2.partida.pid, aceitar: false });
const mc3 = await pedir(c, "/v1/mm/estado?x=1");
ok(mc3.estado === "buscando" || mc3.estado === "encontrada", "quem aceitou voltou à fila");
const ma3 = await pedir(a, "/v1/mm/estado");
ok(ma3.estado === "fora", "quem recusou saiu da fila");
await pedir(c, "/v1/mm/cancelar", {});
console.log(falhas ? `---- ${falhas} FALHA(S)` : "---- MULTI OK");
process.exit(falhas ? 1 : 0);
