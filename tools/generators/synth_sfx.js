// Usage (from project root): node tools/generators/synth_sfx.js  -> writes assets/sounds/generated/*.wav (placeholders)
// Procedural placeholder SFX for the mine. 44.1 kHz mono 16-bit WAV.
const fs = require("fs");
const SR = 44100;
let seed = 12345;
const rnd = () => { seed = (seed * 1664525 + 1013904223) >>> 0; return seed / 4294967296; };
const noise = () => rnd() * 2 - 1;

function writeWav(path, data, loop = false) {
  let peak = 0; for (const v of data) peak = Math.max(peak, Math.abs(v));
  const gain = peak > 0 ? 0.89 / peak : 1;
  const n = data.length, pcm = Buffer.alloc(n * 2);
  for (let i = 0; i < n; i++) pcm.writeInt16LE(Math.max(-32767, Math.min(32767, Math.round(data[i] * gain * 32767))), i * 2);
  const chunks = [];
  const fmt = Buffer.alloc(24); fmt.write("fmt ", 0); fmt.writeUInt32LE(16, 4); fmt.writeUInt16LE(1, 8); fmt.writeUInt16LE(1, 10);
  fmt.writeUInt32LE(SR, 12); fmt.writeUInt32LE(SR * 2, 16); fmt.writeUInt16LE(2, 20); fmt.writeUInt16LE(16, 22); chunks.push(fmt);
  const dh = Buffer.alloc(8); dh.write("data", 0); dh.writeUInt32LE(pcm.length, 4); chunks.push(dh, pcm);
  if (loop) { // 'smpl' chunk with one forward loop over the whole file
    const s = Buffer.alloc(8 + 36 + 24); s.write("smpl", 0); s.writeUInt32LE(36 + 24, 4);
    s.writeUInt32LE(Math.round(1e9 / SR), 8 + 8); s.writeUInt32LE(60, 8 + 12); s.writeUInt32LE(1, 8 + 28);
    s.writeUInt32LE(0, 44 + 4); s.writeUInt32LE(0, 44 + 8); s.writeUInt32LE(n - 1, 44 + 12); chunks.push(s);
  }
  const body = Buffer.concat(chunks);
  const hdr = Buffer.alloc(12); hdr.write("RIFF", 0); hdr.writeUInt32LE(4 + body.length, 4); hdr.write("WAVE", 8);
  fs.writeFileSync(path, Buffer.concat([hdr, body]));
}
// simple resonant band-pass (biquad, constant peak gain)
function bandpass(f, q) {
  const w = 2 * Math.PI * f / SR, a = Math.sin(w) / (2 * q), a0 = 1 + a;
  const b0 = a / a0, b2 = -a / a0, a1 = -2 * Math.cos(w) / a0, a2 = (1 - a) / a0;
  let x1 = 0, x2 = 0, y1 = 0, y2 = 0;
  return x => { const y = b0 * x + b2 * x2 - a1 * y1 - a2 * y2; x2 = x1; x1 = x; y2 = y1; y1 = y; return y; };
}
const lowpass = f => { const k = 1 - Math.exp(-2 * Math.PI * f / SR); let y = 0; return x => (y += k * (x - y)); };
const buf = s => new Float64Array(Math.round(s * SR));

// 1. Water drip: rising "plink" plus a small bubble resonance
{
  const d = buf(0.7);
  for (let i = 0; i < d.length; i++) {
    const t = i / SR;
    const f = 900 + 1500 * (1 - Math.exp(-t * 60));
    const ph = 2 * Math.PI * (900 * t + 1500 * (t - (1 - Math.exp(-t * 60)) / 60));
    d[i] = Math.sin(ph) * Math.exp(-t * 38) + 0.35 * Math.sin(2 * Math.PI * 1450 * t) * Math.exp(-Math.max(0, t - 0.02) * 55) * (t > 0.02 ? 1 : 0);
    if (t < 0.004) d[i] += noise() * 0.3 * (1 - t / 0.004);
  }
  writeWav("assets/sounds/generated/drip.wav", d);
}
// 2. Wood creak: stick-slip impulse train through wooden body resonances
{
  const d = buf(1.8), res = [bandpass(310, 9), bandpass(720, 12), bandpass(1650, 14)];
  let phase = 0;
  for (let i = 0; i < d.length; i++) {
    const t = i / SR;
    const env = Math.sin(Math.PI * Math.min(1, t / 1.8)) ** 1.5;
    const rate = 70 + 45 * Math.sin(2 * Math.PI * 0.8 * t) + 20 * Math.sin(2 * Math.PI * 3.1 * t);
    phase += rate / SR;
    let x = 0;
    if (phase >= 1) { phase -= 1; x = (0.6 + 0.4 * rnd()) * env; }
    x += noise() * 0.02 * env;
    d[i] = res[0](x) * 1.0 + res[1](x) * 0.7 + res[2](x) * 0.35;
  }
  writeWav("assets/sounds/generated/creak.wav", d);
}
// 3. Distant rumble: brown noise, low-passed, with a slow swell and a few thuds
{
  const d = buf(6.0), lp1 = lowpass(90), lp2 = lowpass(60);
  let brown = 0;
  const thuds = [1.4, 2.3, 3.9];
  for (let i = 0; i < d.length; i++) {
    const t = i / SR;
    brown = brown * 0.998 + noise() * 0.06;
    const env = Math.sin(Math.PI * t / 6.0) ** 2;
    let x = lp2(lp1(brown)) * env * 3;
    for (const th of thuds) if (t > th) x += Math.sin(2 * Math.PI * 42 * (t - th)) * Math.exp(-(t - th) * 5) * 0.5 * env;
    d[i] = x;
  }
  writeWav("assets/sounds/generated/rumble.wav", d);
}
// 4. Lantern fire crackle: soft hiss bed + random crackles, loopable (crossfaded)
{
  const len = 4.0, fade = 0.4, raw = buf(len + fade), hp = bandpass(3000, 0.7), lp = lowpass(2500);
  let next = 0;
  for (let i = 0; i < raw.length; i++) {
    const t = i / SR;
    let x = lp(noise()) * 0.06;
    if (t >= next) { next = t + 0.02 + rnd() * 0.18; }
    const since = t - (next - 0.2);
    raw[i] = x;
  }
  // crackles: short filtered noise bursts
  for (let c = 0; c < 45; c++) {
    const start = Math.floor(rnd() * (raw.length - SR * 0.03)), amp = 0.2 + rnd() * 0.8, dec = 300 + rnd() * 700;
    const bp = bandpass(1500 + rnd() * 3500, 2);
    for (let j = 0; j < SR * 0.03; j++) raw[start + j] += bp(noise()) * amp * Math.exp(-j / SR * dec) * 2.5;
  }
  const n = Math.round(len * SR), nf = Math.round(fade * SR), d = new Float64Array(n);
  for (let i = 0; i < n; i++) d[i] = raw[i];
  for (let i = 0; i < nf; i++) { const k = i / nf; d[i] = raw[i] * k + raw[n + i] * (1 - k); }
  writeWav("assets/sounds/generated/lantern_crackle.wav", d, true);
}
// 5. Distant pickaxe taps: three metallic strikes, dull and far
{
  const d = buf(2.6), lp = lowpass(3000);
  const hits = [0.1, 0.78, 1.5];
  for (const h of hits) {
    const res = [bandpass(1850 + rnd() * 100, 25), bandpass(3150, 30), bandpass(620, 8)], s = Math.round(h * SR);
    for (let j = 0; s + j < d.length && j < SR * 0.9; j++) {
      const x = j < 60 ? noise() * (1 - j / 60) : 0;
      d[s + j] += (res[0](x) * 1.0 + res[1](x) * 0.5 + res[2](x) * 1.2) * (0.8 + 0.2 * rnd());
    }
  }
  for (let i = 0; i < d.length; i++) d[i] = lp(d[i]);
  writeWav("assets/sounds/generated/pick_taps.wav", d);
}
// 6. Distant blast: short noise burst, deep boom, long rumbling tail with falling debris
{
  const d = buf(5.0), lp = lowpass(220), lp2 = lowpass(70);
  let brown = 0;
  for (let i = 0; i < d.length; i++) {
    const t = i / SR;
    brown = brown * 0.997 + noise() * 0.08;
    const boom = Math.sin(2 * Math.PI * (38 - 12 * Math.min(t, 1)) * t) * Math.exp(-t * 2.2) * 1.2;
    const crack = t < 0.08 ? noise() * (1 - t / 0.08) * 0.9 : 0;
    const tail = lp2(brown) * 4 * Math.exp(-t * 0.7);
    d[i] = lp(crack + boom + tail);
  }
  for (let k = 0; k < 40; k++) { // pebbles falling after the blast
    const s0 = Math.floor((0.8 + rnd() * 3.5) * SR), bp = bandpass(900 + rnd() * 2500, 6), amp = 0.05 + rnd() * 0.12;
    for (let j = 0; j < SR * 0.05 && s0 + j < d.length; j++) d[s0 + j] += bp(noise()) * amp * Math.exp(-j / SR * 80);
  }
  writeWav("assets/sounds/generated/blast.wav", d);
}
console.log("done");
