// Som de embaralhar cartas (riffle) 100% por síntese algorítmica — sem samples, sem IA generativa.
// Camadas: (1) dobrar o monte: atrito de papel curto; (2) riffle: 52 estalos de carta acelerando e
// desacelerando, metade à esquerda e metade à direita do estéreo; (3) "ponte": as cartas escorregam
// juntas (raspão filtrado descendo); (4) duas batidas do monte na mesa para alinhar.
// Uso: node gerar_embaralhar.js   → godot/audio/sfx/embaralhar_1.wav e embaralhar_2.wav
const path = require('path');
const fs = require('fs');
const audio = require('/home/sapista/.claude/skills/build-sfx/tools/index.js');
const SR = audio.SAMPLE_RATE;
const SAIDA = '/mnt/d/Projetos de Jogos/GodsKodex/godot/audio/sfx';
fs.mkdirSync(SAIDA, { recursive: true });

function estereo(dur) {
  const n = Math.floor(dur * SR);
  return { left: new Float32Array(n), right: new Float32Array(n) };
}

function somar(dst, mono, t, vol, pan) {
  const p = audio.panMono(mono, pan);
  const off = Math.floor(t * SR);
  for (let i = 0; i < p.left.length && off + i < dst.left.length; i++) {
    dst.left[off + i] += p.left[i] * vol;
    dst.right[off + i] += p.right[i] * vol;
  }
}

function somarEstereo(dst, st, t, vol) {
  const off = Math.floor(t * SR);
  const L = st.left || st, R = st.right || st;
  for (let i = 0; i < L.length && off + i < dst.left.length; i++) {
    dst.left[off + i] += L[i] * vol;
    dst.right[off + i] += R[i] * vol;
  }
}

// Um estalo de carta: ruído de 4–9 ms, passa-faixa em 2,5–6,5 kHz, ataque instantâneo, queda exponencial,
// mais um "tic" agudo de 1 ms (a borda da carta batendo no polegar).
function estalo() {
  const dur = 0.004 + Math.random() * 0.005;
  const n = audio.whiteNoise(dur + 0.01, 1);
  const f = 2500 + Math.random() * 4000;
  const b = audio.bandPass(n, f, 1.2 + Math.random() * 1.5);
  for (let i = 0; i < b.length; i++) b[i] *= Math.exp(-i / (dur * SR * 0.35));
  const tic = audio.highPass2(audio.whiteNoise(0.0012, 1), 6000);
  audio.addInto(b, tic, 0, 0.5);
  audio.fadeOut(b, 0.002);
  return b;
}

// Atrito de papel: grãos de ruído rosa filtrados (textura), envelope em meia-senoide.
function atrito(dur, freq, gainV) {
  const g = audio.granular.grainCloud({
    source: 'pink', duration: dur, grainSizeMs: 7, density: 260, ampJitter: 0.7,
    filter: { type: 'bp', freq, Q: 0.9 }, panSpread: 0.35,
  });
  const n = g.left.length;
  for (let i = 0; i < n; i++) {
    const e = Math.sin(Math.PI * i / n) * gainV;
    g.left[i] *= e; g.right[i] *= e;
  }
  return g;
}

function batida(forca) {
  // monte batendo na mesa: baque surdo curto (sem ressonância tonal) + tapa de papel
  const imp = audio.transient_designer.designImpact({
    attack: { kind: 'click', durationMs: 4, lpHz: 3500, hpHz: 300, gain: 0.45 },
    body: { kind: 'thump', freq: 150 + Math.random() * 30, decay: 0.05 * forca + 0.02, lpHz: 900, gain: 0.8 },
  });
  const tapa = audio.bandPass(audio.whiteNoise(0.03, 1), 1800 + Math.random() * 400, 0.8);
  for (let i = 0; i < tapa.length; i++) tapa[i] *= Math.exp(-i / (0.006 * SR));
  return { imp, tapa };
}

function render() {
  const out = estereo(2.2);
  // (1) dobrar o monte com os polegares: 0,00–0,18 s
  somarEstereo(out, atrito(0.18, 3200, 0.35), 0.0, 1.0);
  // (2) riffle: 52 estalos entre 0,15 e 1,05 s, densidade em forma de sino (rápido no meio)
  const N = 52;
  let t = 0.15;
  for (let k = 0; k < N; k++) {
    const u = k / (N - 1);
    const intervalo = 0.026 - 0.016 * Math.sin(Math.PI * u) + (Math.random() - 0.5) * 0.004;
    const lado = (k % 2 === 0 ? -1 : 1) * (0.35 + Math.random() * 0.2);   // alterna as metades
    const vol = 0.55 + 0.35 * Math.sin(Math.PI * u) * (0.7 + Math.random() * 0.3);
    somar(out, estalo(), t, vol, lado);
    t += intervalo;
  }
  somarEstereo(out, atrito(0.9, 4200, 0.12), 0.15, 1.0);          // zumbido de papel por baixo do riffle
  // (3) ponte: as cartas escorregam e se juntam — raspão com filtro descendo, 1,08–1,40 s
  const raspao = audio.whiteNoise(0.32, 1);
  audio.lowPassSweep(raspao, 7000, 1800, 1.2, 'exponential');
  const r2 = audio.highPass2(raspao, 900);
  audio.adsrExp(r2, 0.03, 0.08, 0.6, 0.2, 2);
  somar(out, r2, 1.08, 0.22, 0);
  // (4) duas batidas para alinhar: 1,48 s (forte) e 1,66 s (leve)
  for (const [tb, f] of [[1.48, 1.0], [1.66, 0.6]]) {
    const { imp, tapa } = batida(f);
    somarEstereo(out, imp, tb, 0.8 * f);
    somar(out, tapa, tb, 0.45 * f, 0);
  }
  const res = audio.mix_bus.applyFx(out, { hpf: 90, reverb: { duration: 0.35, roomSize: 0.25, hfDamping: 0.6, wet: 0.12 } });
  audio.fadeOut(res.left || res, 0.01);
  if (res.right) audio.fadeOut(res.right, 0.01);
  return res;
}

for (const nome of ['embaralhar_1', 'embaralhar_2']) {
  const r = render();
  audio.mix_bus.masterChain(r, { normalize: 'peak' });
  audio.WavBuilder.write(r, path.join(SAIDA, nome + '.wav'));
  console.log('ok', nome);
}
