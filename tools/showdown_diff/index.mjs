// Comparación completa con Showdown: capacidades → combates → Showdown → nuestro motor → informe.
//   node tools/showdown_diff/index.mjs [--n=200] [--seed=1] [--team=3] [--items] [--all-abilities] [--all-moves]
//        [--out=tools/cache/showdown_diff] [--max-diff=-1]
// Godot: $GODOT o "godot" en el PATH. Showdown: ver README. Sale con código 1 si hay más
// combates distintos que --max-diff (por defecto no falla nunca: -1).

import fs from 'node:fs';
import path from 'node:path';
import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { generate } from './gen_specs.mjs';
import { loadShowdown, runOne } from './run_showdown.mjs';
import { compare, report, summary } from './compare.mjs';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const GODOT = process.env.GODOT || 'godot';

const opts = { n: 200, seed: 1, team: 3, items: false, allAbilities: false, allMoves: false,
  out: path.join(ROOT, 'tools', 'cache', 'showdown_diff'), maxDiff: -1 };
for (const a of process.argv.slice(2)) {
  const [k, v] = a.replace(/^--/, '').split('=');
  if (['n', 'seed', 'team'].includes(k)) opts[k] = Number(v);
  else if (k === 'max-diff') opts.maxDiff = Number(v);
  else if (k === 'items') opts.items = true;
  else if (k === 'all-abilities') opts.allAbilities = true;
  else if (k === 'all-moves') opts.allMoves = true;
  else if (k === 'out') opts.out = path.resolve(v);
}

fs.mkdirSync(opts.out, { recursive: true });
const cacheRoot = path.join(ROOT, 'tools', 'cache');
if (opts.out.startsWith(cacheRoot) && !fs.existsSync(path.join(cacheRoot, '.gdignore'))) {
  fs.writeFileSync(path.join(cacheRoot, '.gdignore'), '');
}
const file = (name) => path.join(opts.out, name);
const godot = (...args) => execFileSync(GODOT, ['--headless', '--path', ROOT, '-s', 'res://tools/showdown_diff/run_ours.gd', '--', ...args],
  { stdio: ['ignore', 'inherit', 'inherit'], env: { ...process.env, XDG_DATA_HOME: process.env.XDG_DATA_HOME || '/tmp/panchito-showdown-diff' } });

const t0 = Date.now();
godot(`--capabilities=${file('capacidades.json')}`);
opts.caps = file('capacidades.json');
const specs = generate(opts);
fs.writeFileSync(file('combates.json'), JSON.stringify(specs));
console.log(`Generados ${specs.length} combates.`);

const sim = loadShowdown();
const sd = specs.map((spec) => runOne(sim, spec));
fs.writeFileSync(file('showdown.json'), JSON.stringify(sd));
console.log(`Showdown: ${sd.length} combates, ${sd.filter((r) => r.error).length} con error.`);

godot(`--specs=${file('combates.json')}`, `--out=${file('nuestro.json')}`);
const ours = JSON.parse(fs.readFileSync(file('nuestro.json'), 'utf8'));

const rows = compare(specs, sd, ours);
fs.writeFileSync(file('informe.md'), report(rows));
fs.writeFileSync(file('resultado.json'), JSON.stringify(rows.map(({ spec, ...r }) => r), null, 1));
const count = summary(rows);
console.log(`Resultado (${((Date.now() - t0) / 1000).toFixed(1)} s): ${JSON.stringify(count)}`);
console.log(`Informe: ${file('informe.md')}`);
const differ = rows.filter((r) => !['coincide', 'empate_velocidad', 'limite_turnos'].includes(r.status)).length;
if (opts.maxDiff >= 0 && differ > opts.maxDiff) process.exit(1);
