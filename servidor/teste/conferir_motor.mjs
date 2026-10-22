// Conferência do motor juiz com o jogo: refaz uma partida gravada pelo Godot (GD_GRAVAR) usando os MESMOS sorteios e
// jogadas, e compara o retrato do estado antes de cada jogada. Uso: node teste/conferir_motor.mjs arquivo.jsonl [...]
import { readFileSync } from "node:fs";
import { Partida } from "../src/motor/regras.js";

function conferir(arq) {
  const L = readFileSync(arq, "utf8").trim().split("\n").map((l) => JSON.parse(l));
  const decks = L.find((x) => x.t === "decks");
  if (!decks) return { ok: false, erro: "sem decks" };
  const emb = [[], []], rng = [], mull = [[], []], passos = [];
  for (const x of L) {
    if (x.t === "emb") emb[x.d].push(x.ids);
    else if (x.t === "rng") rng.push(x);
    else if (x.t === "mull") mull[x.d].push(x.k);
    else if (x.t === "canon" || x.t === "acao" || x.t === "fim") passos.push(x);
  }
  const inicio = [decks.d0, decks.d1];
  const sorteio = {
    ordem: (d, lista) => {
      if (inicio[d]) { const o = inicio[d]; inicio[d] = null; return [...o]; }
      const ids = emb[d].shift();
      if (!ids) throw new Error(`embaralhar lado ${d}: o jogo não embaralhou aqui`);
      const resto = [...lista], out = [];
      for (const id of ids) { const i = resto.findIndex((c) => c.id === id); if (i < 0) throw new Error("embaralhar: carta " + id + " não está no deck"); out.push(resto.splice(i, 1)[0]); }
      return out;
    },
    int: (n) => {
      const r = rng.shift();
      if (!r) throw new Error(`sorteio de ${n}: o jogo não sorteou aqui`);
      if (r.n !== n) throw new Error(`sorteio: jogo sorteou entre ${r.n}, juiz entre ${n}`);
      return r.v;
    },
  };
  const p = new Partida({ decks: [decks.d0, decks.d1], primeiro: 0, sorteio, humano: [false, false], cornucopia: decks.corn });
  const g = p.rodar();
  let r = g.next(), k = 0, conferidos = 0;
  try {
    while (!r.done) {
      const q = r.value;
      if (q.tipo === "mulligan") { r = g.next(mull[q.jogador].shift() || []); continue; }
      if (q.tipo !== "acao") throw new Error("pedido inesperado: " + q.tipo);
      const canon = passos[k++];
      if (!canon || canon.t !== "canon") throw new Error("o jogo não tinha jogada aqui (" + (canon?.t ?? "fim do arquivo") + ")");
      const meu = p.canon();
      if (meu !== canon.s) return { ok: false, erro: "estado diferente", passo: k, jogo: canon.s, juiz: meu, ultima: passos[k - 3] };
      conferidos++;
      const a = passos[k++];
      if (a.d !== q.jogador) throw new Error(`vez errada: jogo ${a.d}, juiz ${q.jogador}`);
      r = g.next(a);
    }
    const fim = passos[k];
    if (fim?.t === "canon" && fim.s !== p.canon()) return { ok: false, erro: "estado final diferente", jogo: fim.s, juiz: p.canon() };
    const vf = passos.find((x) => x.t === "fim");
    if (vf && vf.vencedor !== p.vencedor) return { ok: false, erro: `vencedor: jogo ${vf.vencedor}, juiz ${p.vencedor}` };
    return { ok: true, conferidos, turnos: p.turno_n, vencedor: p.vencedor };
  } catch (e) { return { ok: false, erro: e.message, passo: k, conferidos }; }
}

let ok = 0;
for (const arq of process.argv.slice(2)) {
  const r = conferir(arq);
  if (r.ok) { ok++; console.log(`OK      ${arq.split("/").pop()}: ${r.conferidos} retratos iguais, ${r.turnos} turnos, vencedor ${r.vencedor}`); }
  else { console.log(`FALHOU  ${arq.split("/").pop()}: ${r.erro} (passo ${r.passo ?? "-"})`); if (r.jogo) { console.log("  jogo: " + r.jogo); console.log("  juiz: " + r.juiz); console.log("  antes: " + JSON.stringify(r.ultima)); } }
}
console.log(`---- ${ok}/${process.argv.length - 2} partidas iguais`);
