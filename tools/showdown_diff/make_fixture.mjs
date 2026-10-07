// Crea la muestra fija que usa el test tests/combate/test_showdown_muestra.gd: combates que ya
// coinciden con Showdown, con las fotos de Showdown guardadas (así el test no necesita Node).
//   node tools/showdown_diff/make_fixture.mjs [--per-seed=10] [--seeds=1,2,3] [--item-seeds=11,12]
// (--item-seeds: lotes con objetos, como --items en index.mjs)
// Rehazla cuando cambien los datos (data/generated) o se corrija algo que cambie los combates.

import fs from 'node:fs';
import path from 'node:path';
import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { generate } from './gen_specs.mjs';
import { loadShowdown, runOne } from './run_showdown.mjs';
import { compare } from './compare.mjs';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const OUT = path.join(ROOT, 'tests', 'combate', 'showdown_muestra.json');
const GODOT = process.env.GODOT || 'godot';
const opts = { perSeed: 10, seeds: [1, 2, 3], itemSeeds: [11, 12] };
for (const a of process.argv.slice(2)) {
  const [k, v] = a.replace(/^--/, '').split('=');
  if (k === 'per-seed') opts.perSeed = Number(v);
  if (k === 'seeds') opts.seeds = v.split(',').map(Number);
  if (k === 'item-seeds') opts.itemSeeds = v ? v.split(',').map(Number) : [];
}

const tmp = fs.mkdtempSync('/tmp/showdown-muestra-');
const run = (...args) => execFileSync(GODOT, ['--headless', '--path', ROOT, '-s', 'res://tools/showdown_diff/run_ours.gd', '--', ...args],
  { stdio: ['ignore', 'ignore', 'inherit'], env: { ...process.env, XDG_DATA_HOME: '/tmp/panchito-showdown-diff' } });
run(`--capabilities=${path.join(tmp, 'caps.json')}`);
const sim = loadShowdown();
const fixture = [];
const batches = [...opts.seeds.map((seed) => ({ seed, items: false })), ...opts.itemSeeds.map((seed) => ({ seed, items: true }))];
for (const { seed, items } of batches) {
  const specs = generate({ caps: path.join(tmp, 'caps.json'), n: 60, seed, team: 3, items });
  const sd = specs.map((s) => runOne(sim, s));
  fs.writeFileSync(path.join(tmp, 'specs.json'), JSON.stringify(specs));
  run(`--specs=${path.join(tmp, 'specs.json')}`, `--out=${path.join(tmp, 'ours.json')}`);
  const ours = JSON.parse(fs.readFileSync(path.join(tmp, 'ours.json'), 'utf8'));
  const rows = compare(specs, sd, ours);
  let taken = 0;
  for (let i = 0; i < specs.length && taken < opts.perSeed; i++) {
    const capped = (sd[i].flags || []).some((f) => f.flag === 'max_turns');
    if (rows[i].status !== 'coincide' || capped || sd[i].snapshots.length > 40) continue;
    const strip = (s) => ({ turn: s.turn, weather: s.weather, sides: s.sides });
    fixture.push({ spec: specs[i], showdown: { snapshots: sd[i].snapshots.map(strip), final: strip(sd[i].final) } });
    taken++;
  }
}
fs.writeFileSync(OUT, JSON.stringify(fixture));
console.log(`Muestra: ${fixture.length} combates en ${path.relative(ROOT, OUT)} (${(fs.statSync(OUT).size / 1024).toFixed(0)} KB).`);
