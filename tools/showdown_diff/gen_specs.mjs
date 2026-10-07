// Genera combates aleatorios (pero reproducibles) para comparar con Showdown.
//   node tools/showdown_diff/gen_specs.mjs --caps=<capacidades.json> --out=<specs.json> [--n=200] [--seed=1]
//        [--team=3] [--items] [--all-abilities] [--all-moves]
// Por defecto solo usa lo que nuestro motor tiene implementado (lo dice run_ours.gd --capabilities);
// con --all-abilities / --all-moves sirve para medir la cobertura (tarea 2).

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { fnv1a } from './lib/oracle.mjs';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const GEN = path.join(ROOT, 'data', 'generated');
const STATS = ['hp', 'atk', 'def', 'spa', 'spd', 'spe'];
const NATURES = JSON.parse(fs.readFileSync(path.join(GEN, 'natures.json'), 'utf8'));

// Fuera por ahora: dependen de mecánicas que el arnés todavía no compara (o no existen en Showdown).
const MOVE_BLOCKLIST = new Set(['struggle', 'transform', 'metronome', 'assist', 'sketch', 'mimic', 'copycat',
  'mirrormove', 'sleeptalk', 'naturepower', 'roar', 'whirlwind', 'dragontail', 'circlethrow', 'teleport',
  'batonpass', 'uturn', 'voltswitch', 'flipturn', 'partingshot', 'chillyreception', 'shedtail', 'healingwish',
  'lunardance', 'memento', 'finalgambit', 'explosion', 'selfdestruct', 'mistyexplosion', 'perishsong']);

/** Generador pseudoaleatorio sencillo y reproducible (mulberry32). */
function rng(seed) {
  let a = seed >>> 0;
  return () => {
    a = (a + 0x6d2b79f5) >>> 0;
    let t = a;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

function args() {
  const out = { n: 200, seed: 1, team: 3, items: false, allAbilities: false, allMoves: false };
  for (const a of process.argv.slice(2)) {
    const [k, v] = a.replace(/^--/, '').split('=');
    if (k === 'n' || k === 'seed' || k === 'team') out[k] = Number(v);
    else if (k === 'items') out.items = true;
    else if (k === 'all-abilities') out.allAbilities = true;
    else if (k === 'all-moves') out.allMoves = true;
    else out[k] = v;
  }
  return out;
}

function stat(base, iv, ev, level, nature, key) {
  if (key === 'hp') return Math.floor((2 * base + iv + Math.floor(ev / 4)) * level / 100) + level + 10;
  let value = Math.floor((2 * base + iv + Math.floor(ev / 4)) * level / 100) + 5;
  if (nature.plus === key) value = Math.floor(value * 110 / 100);
  if (nature.minus === key) value = Math.floor(value * 90 / 100);
  return value;
}

export function generate(opts) {
  const caps = JSON.parse(fs.readFileSync(opts.caps, 'utf8'));
  const species = JSON.parse(fs.readFileSync(path.join(GEN, 'species.json'), 'utf8'));
  const moves = JSON.parse(fs.readFileSync(path.join(GEN, 'moves.json'), 'utf8'));
  const learnsets = JSON.parse(fs.readFileSync(path.join(GEN, 'learnsets.json'), 'utf8'));
  const okMove = new Set(caps.moves);
  const okAbility = new Set(caps.abilities);
  const okItems = caps.items.filter((id) => id && !id.endsWith('ite') && !id.endsWith('iumz'));

  const pool = [];
  for (const [id, s] of Object.entries(species)) {
    if (!s.num || s.num <= 0 || s.nonstandard || s.base_species || s.forme || !s.learnset) continue;
    const abilities = Object.values(s.abilities || {}).filter((a) => opts.allAbilities || okAbility.has(a));
    if (abilities.length === 0) continue;
    const ls = learnsets[s.learnset];
    if (!ls) continue;
    const learnable = new Set();
    for (const [, m] of ls.level || []) learnable.add(m);
    for (const key of ['machine', 'egg', 'tutor']) for (const m of ls[key] || []) learnable.add(m);
    const usable = [...learnable].filter((m) => moves[m] && !moves[m].nonstandard && !moves[m].is_z && !moves[m].is_max
      && !MOVE_BLOCKLIST.has(m) && (opts.allMoves || okMove.has(m)));
    if (usable.length < 4) continue;
    pool.push({ id, s, abilities, usable });
  }
  if (pool.length < 2) throw new Error('No hay especies suficientes para generar combates.');

  const specs = [];
  for (let n = 0; n < opts.n; n++) {
    const seed = fnv1a(`showdown_diff|${opts.seed}|${n}`);
    const r = rng(seed);
    const pick = (list) => list[Math.floor(r() * list.length)];
    const speeds = new Set();
    const makeSet = () => {
      for (let attempt = 0; attempt < 50; attempt++) {
        const { id, s, abilities, usable } = pick(pool);
        const level = 50 + Math.floor(r() * 51);
        const natureId = pick(Object.keys(NATURES));
        const ivs = Object.fromEntries(STATS.map((k) => [k, Math.floor(r() * 32)]));
        const evs = Object.fromEntries(STATS.map((k) => [k, 0]));
        let budget = 508;
        for (let i = 0; i < 40 && budget > 0; i++) {
          const k = pick(STATS);
          const add = Math.min(budget, 252 - evs[k], 4 * (1 + Math.floor(r() * 16)));
          evs[k] += add;
          budget -= add;
        }
        const speed = stat(s.base_stats.spe, ivs.spe, evs.spe, level, NATURES[natureId], 'spe');
        if (speeds.has(speed)) continue;
        speeds.add(speed);
        const chosen = new Set();
        while (chosen.size < 4) chosen.add(pick(usable));
        let gender = '';
        if (s.gender_ratio >= 0) gender = r() < s.gender_ratio ? 'F' : 'M';
        const set = { species: id, level, nature: natureId, ivs, evs, ability: pick(abilities), moves: [...chosen], gender };
        if (opts.items && okItems.length && r() < 0.6) set.item = pick(okItems);
        return set;
      }
      throw new Error('No consigo velocidades distintas.');
    };
    const spec = { id: `c${opts.seed}-${n}`, seed, p1: [], p2: [] };
    for (let i = 0; i < opts.team; i++) spec.p1.push(makeSet());
    for (let i = 0; i < opts.team; i++) spec.p2.push(makeSet());
    // La mitad de los combates con la suerte fijada (ramas concretas), la otra mitad variable por turno.
    if (r() < 0.5) {
      spec.luck = {
        accuracy: pick([0, 0, 0.995]),
        crit: pick([0.999, 0.999, 0]),
        damage_roll: pick([0, 0.5, 0.999]),
        secondary: pick([0, 0.999]),
        par: pick([0, 0.999]),
        confusion_hit: pick([0, 0.999]),
        frz_thaw: pick([0, 0.999]),
      };
    }
    specs.push(spec);
  }
  return specs;
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const opts = args();
  if (!opts.caps || !opts.out) {
    console.error('Uso: node tools/showdown_diff/gen_specs.mjs --caps=<json> --out=<json> [--n=200] [--seed=1]');
    process.exit(2);
  }
  const specs = generate(opts);
  fs.writeFileSync(opts.out, JSON.stringify(specs, null, 1));
  console.log(`Generados ${specs.length} combates en ${opts.out}.`);
}
