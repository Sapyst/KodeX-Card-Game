// Teste das travas contra trapaça (levantamento 07/11/2026, itens 1.1–1.3). Uso: node teste/seguranca_teste.mjs [url]
// Rodar com o servidor local SEM a liberação de decks de teste:  npx wrangler dev --port 8787 --var DECKS_LIVRES_TESTE:0
import { readFileSync } from "node:fs";
const U = process.argv[2] || "http://127.0.0.1:8787";
const D = JSON.parse(readFileSync(new URL("../src/dados.js", import.meta.url), "utf8").replace(/^[\s\S]*?export default /, "").replace(/;\s*$/, ""));
let falhas = 0; const ok = (c, m) => { console.log((c ? "OK      " : "FALHOU  ") + m); if (!c) falhas++; };
const criar = async (local) => (await fetch(U + "/v1/conta", { method: "POST", body: JSON.stringify({ perfil_local: local }) })).json();
const auth = (r) => `KDX ${r.id}:${r.segredo}`;
const pedir = async (a, cam, corpo) => { const r = await fetch(U + cam, { method: corpo ? "POST" : "GET", headers: { authorization: a }, body: corpo ? JSON.stringify(corpo) : undefined }); return { status: r.status, ...(await r.json()) }; };

// 1.3 — conta nova com perfil forjado
const ids = Object.keys(D.cartas);
const forjado = { nome: "Trapaça", moedas: 5000, koins: 2000, essencia: 2000, boosters_gratis: 10, titulos: ["portador"],
  colecao: Object.fromEntries(ids.map((c) => [c, 3])), decks: [{ nome: "Tudo", cartas: ids.slice(0, 32) }], deck_ativo: 0 };
const c1 = await criar(forjado);
const p1 = c1.perfil, novo = (await criar({ nome: "Limpa" })).perfil;
ok(p1.moedas === novo.moedas && (p1.koins | 0) === (novo.koins | 0) && (p1.essencia | 0) === (novo.essencia | 0), `economia forjada ignorada (moedas ${p1.moedas})`);
ok((p1.boosters_gratis | 0) === (novo.boosters_gratis | 0), "boosters forjados ignorados");
ok(Object.keys(p1.colecao).length === Object.keys(novo.colecao).length, `coleção forjada ignorada (${Object.keys(p1.colecao).length} cartas)`);
ok(!(p1.titulos || []).includes("portador"), "títulos forjados ignorados");
ok(p1.nome === "Trapaça", "nome (campo livre) mantido");
const ativo = p1.decks[p1.deck_ativo];
ok(ativo && ativo.cartas.length === 32 && ativo.cartas.every((c) => (p1.colecao[c] | 0) > 0), "deck ativo é jogável com a coleção nova");

// 1.2 — deck online fora da coleção
const A = auth(c1);
const lend = ids.filter((c) => D.cartas[c].l);
const deckLend = Array.from({ length: 32 }, (_, i) => lend[i % lend.length]);
let r = await pedir(A, "/v1/mm/buscar", { deck: deckLend, juiz: true, nome: "T" });
ok(!r.ok && /coleção/.test(r.erro || ""), `fila recusa 32 Lendárias (${r.erro})`);
r = await pedir(A, "/v1/sala/criar", { deck: deckLend, juiz: true, nome: "T" });
ok(!r.ok, "sala recusa deck fora da coleção");
const deck4 = Array(32).fill(D.deck_inicial[0]);
r = await pedir(A, "/v1/sala/criar", { deck: deck4, juiz: true, nome: "T" });
ok(!r.ok, "sala recusa 32 cópias da mesma carta");
r = await pedir(A, "/v1/mm/sair", {});

// 1.1 — /fim e /acao em partida com juiz
const B = auth(await criar({ nome: "Bia" }));
const s = await pedir(A, "/v1/sala/criar", { deck: D.deck_inicial, juiz: true, nome: "Ana" });
ok(s.ok, "sala com deck inicial aceita");
const e = await pedir(B, "/v1/sala/entrar", { codigo: s.codigo, deck: [...D.deck_inicial].reverse(), juiz: true, nome: "Bia" });
ok(e.ok && e.partida.juiz, "segunda conta entra com deck inicial");
const pid = s.partida.pid;
r = await pedir(A, `/v1/partida/${pid}/fim`, { vencedor_eu: true });
ok(r.status === 409, `/fim recusado com juiz (${r.status})`);
r = await pedir(A, `/v1/partida/${pid}/acao`, { n: 1, dados: { tipo: "desistir" } });
ok(r.status === 409, `/acao recusado com juiz (${r.status})`);
const info = await pedir(B, `/v1/partida/${pid}`);
ok(info.partida && (info.partida.vencedor == null || info.partida.vencedor < 0), `resultado continua aberto (vencedor ${info.partida?.vencedor})`);

// protocolo antigo (sem juiz) continua com /fim
const s2 = await pedir(A, "/v1/sala/criar", { deck: D.deck_inicial, nome: "Ana" });
const e2 = await pedir(B, "/v1/sala/entrar", { codigo: s2.codigo, deck: D.deck_inicial, nome: "Bia" });
r = await pedir(A, `/v1/partida/${s2.partida.pid}/fim`, { vencedor_eu: true });
ok(e2.ok && r.ok, "partida antiga (sem juiz) ainda encerra por /fim");

console.log(falhas ? `${falhas} FALHA(S)` : "TUDO OK");
process.exit(falhas ? 1 : 0);
