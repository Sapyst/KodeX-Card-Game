// confere o pagamento da progressão no servidor: missão do dia certa paga 1×, missão de outro dia não, teto de 3/dia,
// nível paga 1×, conquista paga 1× e dá título, sequência de dias no presente
import { readFileSync } from "node:fs";
const U = process.argv[2] || "http://127.0.0.1:8787";
const D = JSON.parse(readFileSync("/mnt/d/Projetos de Jogos/GodsKodex/servidor/src/dados.js", "utf8").replace(/^[\s\S]*?export default /, "").replace(/;\s*$/, ""));
let falhas = 0; const ok = (c, m) => { console.log((c ? "OK      " : "FALHOU  ") + m); if (!c) falhas++; };
const r0 = await (await fetch(U + "/v1/conta", { method: "POST", body: "{}" })).json();
const A = `KDX ${r0.id}:${r0.segredo}`;
const op = async (d) => (await (await fetch(U + "/v1/op", { method: "POST", headers: { authorization: A }, body: JSON.stringify(d) })).json());
const saude = await (await fetch(U + "/v1/saude")).json();
const hoje = saude.dia, semana = Math.floor((hoje + 3) / 7);
function sorteio(semente, n, tam) { let s = (semente * 7919 + 17) % 2147483647; if (s <= 0) s += 2147483646; const out = [];
  while (out.length < Math.min(n, tam)) { s = (s * 48271) % 2147483647; const i = s % tam; if (!out.includes(i)) out.push(i); } return out; }
const doDia = sorteio(hoje, 4, D.prog.diarias.length).map((i) => D.prog.diarias[i]);
const fora = D.prog.diarias.find((m) => !doDia.includes(m));
let r = await op({ tipo: "progresso", k: "missao", id: doDia[0].id, dia: hoje });
ok(r.resultado.moedas === (doDia[0].moedas | 0) && r.resultado.booster === (doDia[0].booster | 0), `missão do dia paga (${doDia[0].id}: ${r.resultado.moedas})`);
r = await op({ tipo: "progresso", k: "missao", id: doDia[0].id, dia: hoje });
ok(r.resultado.repetido, "a mesma missão não paga 2×");
r = await op({ tipo: "progresso", k: "missao", id: fora.id, dia: hoje });
ok(r.resultado.erro, "missão que não é do dia é recusada");
await op({ tipo: "progresso", k: "missao", id: doDia[1].id, dia: hoje });
await op({ tipo: "progresso", k: "missao", id: doDia[2].id, dia: hoje });
r = await op({ tipo: "progresso", k: "missao", id: doDia[3].id, dia: hoje });
ok(r.resultado.repetido, "a 4ª (troca) não passa do teto de 3 por dia");
const sem = sorteio(semana + 100000, 3, D.prog.semanais.length).map((i) => D.prog.semanais[i]);
r = await op({ tipo: "progresso", k: "semanal", id: sem[0].id, semana });
ok(!r.resultado.erro && !r.resultado.repetido, "semanal da semana paga");
r = await op({ tipo: "progresso", k: "nivel", nivel: 5 });
ok(r.resultado.booster === 1 && r.resultado.titulo === "iniciado", "nível 5: booster e título Iniciado");
r = await op({ tipo: "progresso", k: "nivel", nivel: 5 });
ok(r.resultado.repetido, "nível não paga 2×");
r = await op({ tipo: "progresso", k: "conquista", id: "vitorias_100" });
ok(r.resultado.moedas === 200 && r.resultado.titulo === "veterano" && r.perfil.titulos.includes("veterano"), "conquista com título");
r = await op({ tipo: "progresso", k: "maestria", trad: "taoismo", nivel: 5 });
ok(r.resultado.titulo === "mestre_taoismo", "maestria 5 dá Mestre do Taoísmo");
r = await op({ tipo: "resgatar" });
ok(r.resultado.seq === 1 && r.perfil.resgates.max === 1, "presente: 1º dia seguido");
console.log(falhas ? `---- ${falhas} FALHA(S)` : "---- PROGRESSO OK");
