#!/usr/bin/env node
// Verifica las estadísticas base y los EVs de data/generated/species.json contra WikiDex (DIRECTRICES §3).
// Usa la API de MediaWiki por lotes, con pausas y caché local (nada de scraping masivo).
//
// Uso:
//   node tools/wikidex/verify_stats.mjs               # Pokédex regional + especies del juego + muestra de 150
//   node tools/wikidex/verify_stats.mjs --sample 400  # muestra más amplia (repartida por toda la Pokédex)
//   node tools/wikidex/verify_stats.mjs --species pikachu,garchomp
//   node tools/wikidex/verify_stats.mjs --all         # todas las especies (sin formas)
// Opciones: --delay <ms> (1500 por defecto), --offline (solo caché).
//
// Resultado: data/generated/wikidex_check.json (lo lee el validador) y un resumen por pantalla.
// Sale con código 1 si hay diferencias. Las diferencias se revisan a mano: si WikiDex tiene razón,
// se corrige con un override en data/species_overrides.json (con "fuente": "WikiDex").
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { readFile, stat, mkdir, writeFile, rename, readdir } from 'node:fs/promises';

const API = 'https://www.wikidex.net/api.php';
const USER_AGENT = 'PokemonPanchito-tools (fangame sin animo de lucro; verificacion puntual con pausas)';
const BATCH = 20;
const FIELDS = { hp: 'PS', atk: 'Ataque', def: 'Defensa', spa: 'At. especial', spd: 'Def. especial', spe: 'Velocidad' };
const EV_FIELDS = { hp: 'PEP', atk: 'PEA', def: 'PED', spa: 'PEAe', spd: 'PEDe', spe: 'PEV' };

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '..', '..');
const cacheDir = path.join(root, 'tools', 'cache', 'wikidex');
const argv = process.argv.slice(2);
const option = (name, fallback) => {
  const i = argv.indexOf(name);
  return i >= 0 && i + 1 < argv.length ? argv[i + 1] : fallback;
};
const delay = Number(option('--delay', 1500));
const offline = argv.includes('--offline');

const exists = (p) => stat(p).then(() => true, () => false);
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const toID = (s) => String(s ?? '').toLowerCase().replace(/[^a-z0-9]+/g, '');
const safe = (title) => title.replace(/[^\p{L}\p{N}._-]+/gu, '_');

async function readJSON(file, fallback = {}) {
  try { return JSON.parse(await readFile(file, 'utf8')); } catch { return fallback; }
}

async function writeAtomic(file, text) {
  await mkdir(path.join(root, 'tools', 'cache'), { recursive: true });
  await writeFile(path.join(root, 'tools', 'cache', '.gdignore'), '');
  await mkdir(path.dirname(file), { recursive: true });
  await writeFile(file + '.tmp', text);
  await rename(file + '.tmp', file);
}

async function jsonFiles(dir) {
  if (!(await exists(dir))) return [];
  const out = [];
  for (const e of await readdir(dir, { withFileTypes: true })) {
    const p = path.join(dir, e.name);
    if (e.isDirectory()) out.push(...(await jsonFiles(p)));
    else if (e.name.endsWith('.json')) out.push(p);
  }
  return out;
}

function collect(value, out) {
  if (Array.isArray(value)) value.forEach((v) => collect(v, out));
  else if (value && typeof value === 'object') {
    for (const [k, v] of Object.entries(value)) {
      if (k === 'species' && typeof v === 'string') out.add(toID(v));
      else collect(v, out);
    }
  }
}

async function targets(species) {
  if (argv.includes('--all')) return Object.keys(species).filter((id) => !species[id].base_species);
  if (option('--species', '')) return option('--species', '').split(',').map(toID).filter((id) => species[id]);
  const found = new Set();
  ((await readJSON(path.join(root, 'data', 'regional_dex.json'))).species ?? []).forEach((s) => found.add(toID(s)));
  for (const dir of ['encounters', 'trainers']) {
    for (const f of await jsonFiles(path.join(root, 'data', dir))) collect(await readJSON(f), found);
  }
  // Familias evolutivas completas (lo que se consigue evolucionando).
  const queue = [...found];
  while (queue.length) {
    const s = species[queue.pop()];
    if (!s) continue;
    for (const next of [s.prevo, ...(s.evolutions ?? []).filter((e) => !e.region).map((e) => e.to)]) {
      if (next && species[next] && !found.has(next)) { found.add(next); queue.push(next); }
    }
  }
  // Muestra repartida por toda la Pokédex nacional (cada N números), siempre la misma.
  const base = Object.keys(species).filter((id) => !species[id].base_species && species[id].num > 0)
    .sort((a, b) => species[a].num - species[b].num);
  const sample = Number(option('--sample', 150));
  const step = Math.max(1, Math.floor(base.length / sample));
  for (let i = 0; i < base.length; i += step) found.add(base[i]);
  return [...found].filter((id) => species[id] && !species[id].base_species).sort();
}

// --- WikiDex ---

let lastFetch = 0;
async function fetchPages(titles) {
  const out = {};
  const missing = [];
  for (const t of titles) {
    const file = path.join(cacheDir, `${safe(t)}.json`);
    if (await exists(file)) out[t] = (await readJSON(file)).content ?? null;
    else missing.push(t);
  }
  if (offline) return out;
  for (let i = 0; i < missing.length; i += BATCH) {
    const batch = missing.slice(i, i + BATCH);
    const wait = lastFetch + delay - Date.now();
    if (wait > 0) await sleep(wait);
    lastFetch = Date.now();
    const params = new URLSearchParams({
      action: 'query', prop: 'revisions', rvprop: 'content', rvslots: 'main', redirects: '1',
      titles: batch.join('|'), format: 'json', formatversion: '2',
    });
    const res = await fetch(`${API}?${params}`, { headers: { 'User-Agent': USER_AGENT } });
    if (!res.ok) throw new Error(`HTTP ${res.status} en WikiDex`);
    const data = await res.json();
    const redirects = new Map((data.query?.redirects ?? []).map((r) => [r.to, r.from]));
    const normalized = new Map((data.query?.normalized ?? []).map((n) => [n.to, n.from]));
    for (const page of data.query?.pages ?? []) {
      let original = page.title;
      if (redirects.has(original)) original = redirects.get(original);
      if (normalized.has(original)) original = normalized.get(original);
      const content = page.revisions?.[0]?.slots?.main?.content ?? null;
      out[original] = content;
      await writeAtomic(path.join(cacheDir, `${safe(original)}.json`), JSON.stringify({ title: page.title, content }));
    }
  }
  return out;
}

const ORDINALS = { primera: 1, segunda: 2, tercera: 3, cuarta: 4, quinta: 5, sexta: 6, séptima: 7, octava: 8, novena: 9, décima: 10 };

// Bloque {{Características}} vigente de la forma base. En "Características de combate", cada forma tiene
// su encabezado ("=== Zamazenta escudo supremo ===") y cada época su etiqueta ("=== A partir de la
// séptima generación ===", ";En la octava generación"...): se toma el primer grupo (forma base) y en él
// el bloque "A partir de la ... generación" más reciente (o el último si no hay ninguno).
function currentBlock(wikitext, speciesName) {
  let section = wikitext;
  const start = wikitext.indexOf('== Características de combate');
  if (start >= 0) {
    const end = wikitext.indexOf('\n== ', start + 5);
    section = wikitext.slice(start, end >= 0 ? end : undefined);
  }
  const tokens = [...section.matchAll(/^(={3,}\s*(.+?)\s*={3,}|;\s*(.+)|Las (?:\[\[)?(?:características|estadísticas)(?:\]\])? de (.+?) son:?)\s*$|\{\{\s*Características\s*\n([\s\S]*?)\}\}/gm)];
  // El grupo de la forma base: los bloques antes del primer encabezado de forma o, si la página empieza
  // con uno ("=== Pikachu ==="), los de ese primer encabezado. Las megas y demás formas van después.
  let label = '';
  let forms = 0;
  const blocks = [];
  for (const t of tokens) {
    if (t[5] !== undefined) {
      blocks.push({ label, body: t[5] });
      continue;
    }
    // "Las características de Mega-Gallade son:" = otra forma (si no es la propia especie).
    if (t[4] !== undefined) {
      const owner = t[4].replace(/\[\[|\]\]/g, '').trim();
      if (owner.toLowerCase() !== speciesName.toLowerCase() && blocks.length > 0) break;
      continue;
    }
    const text = (t[2] ?? t[3] ?? '').toLowerCase();
    if (t[2] !== undefined && !text.includes('generación')) {
      forms += 1;
      if (blocks.length > 0 || forms > 1) break;
      label = '';
    } else {
      label = text;
    }
  }
  if (!blocks.length) return null;
  const generation = (b) => {
    const m = /a partir de la (\S+) generación/.exec(b.label);
    return m ? (ORDINALS[m[1]] ?? 0) : -1;
  };
  const latest = blocks.reduce((best, b) => (generation(b) > generation(best) ? b : best), blocks[blocks.length - 1]);
  return generation(latest) >= 0 ? latest.body : blocks[blocks.length - 1].body;
}

function parseStats(wikitext, speciesName) {
  if (!wikitext) return null;
  const body = currentBlock(wikitext, speciesName);
  if (!body) return null;
  const fields = {};
  for (const line of body.split('\n')) {
    const f = /^\s*\|\s*([^=]+?)\s*=\s*(\d+)\s*$/.exec(line);
    if (f) fields[f[1]] = Number(f[2]);
  }
  const stats = {}, evs = {};
  for (const [k, label] of Object.entries(FIELDS)) if (label in fields) stats[k] = fields[label];
  for (const [k, label] of Object.entries(EV_FIELDS)) if (label in fields) evs[k] = fields[label];
  return Object.keys(stats).length === 6 ? { stats, evs } : null;
}

async function main() {
  const species = await readJSON(path.join(root, 'data', 'generated', 'species.json'));
  const overrides = (await readJSON(path.join(root, 'data', 'species_overrides.json'))).species ?? {};
  const ids = await targets(species);
  // Título de la página: el nombre en español (WikiDex usa los nombres oficiales).
  const titleOf = (id) => species[id].name.replace(/’/g, "'");
  console.log(`Comprobando ${ids.length} especies en WikiDex (lotes de ${BATCH}, pausa de ${delay} ms${offline ? ', sin conexión' : ''})...`);
  const pages = await fetchPages(ids.map(titleOf));
  const mismatches = [];
  const unchecked = [];
  for (const id of ids) {
    const parsed = parseStats(pages[titleOf(id)], titleOf(id));
    if (!parsed) { unchecked.push(id); continue; }
    // Como en DataDB, un override sustituye el campo entero.
    const ours = overrides[id]?.base_stats ?? species[id].base_stats;
    const ourEvs = overrides[id]?.ev_yield ?? species[id].ev_yield ?? {};
    const diffs = [];
    for (const k of Object.keys(FIELDS)) {
      if (ours[k] !== parsed.stats[k]) diffs.push(`${FIELDS[k]}: ${ours[k]} (nuestro) ≠ ${parsed.stats[k]} (WikiDex)`);
      if (k in parsed.evs && (ourEvs[k] ?? 0) !== parsed.evs[k]) diffs.push(`EV ${FIELDS[k]}: ${ourEvs[k] ?? 0} ≠ ${parsed.evs[k]}`);
    }
    if (diffs.length) mismatches.push({ species: id, differences: diffs });
  }
  const report = {
    source: 'WikiDex (https://www.wikidex.net), plantilla {{Características}} más reciente',
    checked: ids.length - unchecked.length,
    species: ids.filter((id) => !unchecked.includes(id)),
    unchecked,
    mismatches,
  };
  await writeAtomic(path.join(root, 'data', 'generated', 'wikidex_check.json'), JSON.stringify(report, null, 1) + '\n');
  console.log(`\nComprobadas: ${report.checked} · sin datos en WikiDex: ${unchecked.length} · con diferencias: ${mismatches.length}`);
  if (unchecked.length) console.log(`Sin datos (revisar el título de la página): ${unchecked.join(', ')}`);
  for (const m of mismatches) console.log(`  ${m.species}: ${m.differences.join('; ')}`);
  process.exit(mismatches.length ? 1 : 0);
}

main().catch((e) => {
  console.error(`ERROR: ${e.message}`);
  process.exit(2);
});
