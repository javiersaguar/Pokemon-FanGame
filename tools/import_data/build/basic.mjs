import { toID } from '../lib/util.mjs';

// Código de damageTaken en Showdown -> multiplicador (0 normal, 1 débil, 2 resiste, 3 inmune).
const DAMAGE_TAKEN = { 0: 1, 1: 2, 2: 0.5, 3: 0 };

// types.json: { tipo: { name, effectiveness: {tipo_defensor: mult}, immunities: [...] } }
// "effectiveness" es el multiplicador al ATACAR con ese tipo. "immunities" son estados o
// condiciones a los que es inmune un Pokémon de ese tipo (brn, par, psn, tox, frz, powder, sandstorm...).
// El tipo Astral (stellar) se deja fuera hasta la teracristalización (Fase 9).
export function buildTypes(sd, pa, report) {
  const chart = sd.TypeChart;
  const ids = Object.keys(chart).filter((t) => t !== 'stellar');
  const showdownKey = (id) => Object.keys(chart.normal.damageTaken).find((k) => /^[A-Z]/.test(k) && toID(k) === id);
  const paId = new Map(pa.rows('types').map((t) => [t.identifier, t.id]));
  const names = pa.names('type_names', 'type_id');
  const out = {};
  for (const atk of ids) {
    const key = showdownKey(atk);
    const effectiveness = Object.fromEntries(ids.map((def) => [def, DAMAGE_TAKEN[chart[def].damageTaken[key] ?? 0]]));
    const immunities = Object.entries(chart[atk].damageTaken)
      .filter(([k, v]) => /^[a-z]/.test(k) && v === 3)
      .map(([k]) => k);
    const name = names.get(paId.get(atk));
    if (!name) report.missingName('types', atk);
    out[atk] = { name: name ?? atk, effectiveness, immunities };
  }
  return out;
}

// natures.json: { naturaleza: { name, plus, minus } } (plus/minus vacíos en las neutras).
export function buildNatures(sd, pa, report) {
  const paId = new Map(pa.rows('natures').map((n) => [n.identifier, n.id]));
  const names = pa.names('nature_names', 'nature_id');
  const out = {};
  for (const [id, n] of Object.entries(sd.Natures)) {
    const name = names.get(paId.get(id));
    if (!name) report.missingName('natures', id);
    out[id] = { name: name ?? n.name, plus: n.plus ?? '', minus: n.minus ?? '' };
  }
  return out;
}

export const GROWTH = {
  slow: 'slow',
  medium: 'medium_fast',
  fast: 'fast',
  'medium-slow': 'medium_slow',
  'slow-then-very-fast': 'erratic',
  'fast-then-very-slow': 'fluctuating',
};

// exp_tables.json: { grupo: [exp total para el nivel 0..100] } (el índice es el nivel; el 0 no se usa).
export function buildExpTables(pa) {
  const groups = new Map(pa.rows('growth_rates').map((g) => [g.id, GROWTH[g.identifier]]));
  const out = {};
  for (const g of groups.values()) out[g] = new Array(101).fill(0);
  for (const r of pa.rows('experience')) out[groups.get(r.growth_rate_id)][Number(r.level)] = Number(r.experience);
  return out;
}
