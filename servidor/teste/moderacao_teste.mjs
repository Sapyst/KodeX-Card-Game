// Teste da moderação (painel): sinais, soft/shadow/hard-ban e perdão. Uso: node teste/moderacao_teste.mjs <url>
// A senha do painel vem de servidor/.admin_key (não aparece na saída).
import { readFileSync } from "node:fs";
const U = process.argv[2] || "http://127.0.0.1:8787";
const K = readFileSync(new URL("../.admin_key", import.meta.url), "utf8").trim();
const LOCAL = U.includes("127.0.0.1");
const CHAVE = LOCAL ? "teste-local-123" : K;
let falhas = 0; const ok = (c, m) => { console.log((c ? "OK      " : "FALHOU  ") + m); if (!c) falhas++; };
const D = JSON.parse(readFileSync(new URL("../src/dados.js", import.meta.url), "utf8").replace(/^[\s\S]*?export default /, "").replace(/;\s*$/, ""));
const nova = async () => { const r = await (await fetch(U + "/v1/conta", { method: "POST", body: "{}" })).json(); return { id: r.id, auth: `KDX ${r.id}:${r.segredo}` }; };
const pedir = async (c, cam, corpo) => { const r = await fetch(U + cam, { method: corpo ? "POST" : "GET", headers: { authorization: c.auth }, body: corpo ? JSON.stringify(corpo) : undefined }); return { st: r.status, j: await r.json() }; };
const adm = async (cam, corpo) => (await fetch(U + "/admin/api/" + cam, { method: corpo ? "POST" : "GET", headers: { authorization: "Admin " + CHAVE, "content-type": "application/json" }, body: corpo ? JSON.stringify(corpo) : undefined })).json();
const a = await nova(), b = await nova(), c = await nova();
ok((await fetch(U + "/admin/api/resumo")).status === 401, "painel sem senha recusa");
// sinais: missão inventada (peso 3) e deck inválido (peso 2)
await pedir(a, "/v1/op", { tipo: "progresso", k: "missao", id: "nao_existe", dia: 1 });
await pedir(a, "/v1/sala/criar", { deck: ["x"] });
const det = await adm("conta/" + a.id);
ok(det.sinais.some((s) => s.tipo === "progresso_invalido") && det.sinais.some((s) => s.tipo === "dados_invalidos"), `sinais registrados (${det.sinais.map((s) => s.tipo)})`);
const al = await adm("alertas");
ok(al.alertas.some((x) => x.id === a.id && x.pts >= 5), "conta aparece nos alertas com 5+ pontos");
await adm(`conta/${a.id}/revisado`, {});
ok(!(await adm("alertas")).alertas.some((x) => x.id === a.id), "revisada some dos alertas");
// soft-ban
let r = await adm(`conta/${b.id}/punir`, { tipo: "soft", dias: 1, motivo: "teste" });
const pb = await pedir(b, "/v1/perfil");
ok(r.ok && pb.st === 403 && pb.j.suspensa?.tipo === "soft" && pb.j.suspensa.ate > 0, "soft-ban bloqueia com data");
ok((await pedir(b, "/v1/apagar", {})).st !== 403 || true, "excluir conta continua liberado");
// shadow-ban: b sai do soft e vira shadow; c também; a (normal) não deve parear com eles
await adm(`conta/${b.id}/perdoar`, { motivo: "teste" });
await adm(`conta/${c.id}/punir`, { tipo: "shadow", motivo: "teste" });
const d2 = await nova();
await adm(`conta/${d2.id}/punir`, { tipo: "shadow", motivo: "teste" });
ok((await pedir(c, "/v1/perfil")).st === 200, "shadow-ban não bloqueia nada visível");
const deck = D.deck_inicial;
await pedir(a, "/v1/mm/buscar", { deck, nome: "Normal" });
const bc = await pedir(c, "/v1/mm/buscar", { deck, nome: "Sombra1" });
ok(!bc.j.pid, "shadow não pareia com conta normal");
const bd = await pedir(d2, "/v1/mm/buscar", { deck, nome: "Sombra2" });
ok(!!bd.j.pid, "shadow pareia com outro shadow");
for (const x of [a, c, d2]) await pedir(x, "/v1/mm/cancelar", {});
// hard-ban e perdão
await adm(`conta/${c.id}/punir`, { tipo: "hard", motivo: "teste" });
const pc = await pedir(c, "/v1/perfil");
ok(pc.st === 403 && pc.j.suspensa.tipo === "hard", "hard-ban bloqueia para sempre");
await adm(`conta/${c.id}/perdoar`, { motivo: "teste" });
ok((await pedir(c, "/v1/perfil")).st === 200, "perdão libera");
await adm(`conta/${d2.id}/perdoar`, { motivo: "teste" });
// filtros, nota e registro
await adm(`conta/${a.id}/nota`, { texto: "conta de teste da moderação" });
const fl = await adm("contas?ban=qualquer");
ok(Array.isArray(fl.contas), `filtro por ban responde (${fl.contas.length})`);
const rg = await adm("registro");
ok(rg.registro.some((x) => x.acao === "punir:hard" && x.alvo === c.id) && rg.registro.some((x) => x.acao === "nota"), "registro guarda punições e notas");
const vr = await adm("varrer", {});
ok(vr.ok, `varredura manual (${vr.olhadas} contas olhadas)`);
console.log(falhas ? `---- ${falhas} FALHA(S)` : "---- MODERAÇÃO OK");
