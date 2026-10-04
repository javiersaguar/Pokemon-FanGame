#!/usr/bin/env node
// Importa los gráficos y gritos de los Pokémon desde los packs que ha descargado Javier
// (DIRECTRICES §7.1 y §7.2). Set oficial: 06_generation9_pack; 07_generation8_pack solo si falta algo.
// Copia byte a byte (sin reescalar ni convertir) SOLO las especies que usa el juego.
//
// Uso:
//   node tools/sprites/import_pokemon_assets.mjs                 # especies del juego (ver abajo)
//   node tools/sprites/import_pokemon_assets.mjs --species pikachu,raichualola
//   node tools/sprites/import_pokemon_assets.mjs --all           # todas (para RandomLocke)
// Opciones: --source <carpeta de recursos> (o PANCHITO_RECURSOS), --dry-run, --prune (borra del repo los
// de especies que ya no se usan).
//
// Especies del juego: data/regional_dex.json + data/species_in_use.json + las que aparecen en
// data/encounters/, data/trainers/, starters.json, gifts.json, statics.json y trades.json, con sus familias.
//
// Destino (con nuestros ids en minúsculas):
//   assets/sprites/pokemon/{front,front_shiny,back,back_shiny,icons,icons_shiny,followers,followers_shiny}/<id>.png
//   (y <id>_female.png donde el pack tiene diferencias por sexo) · assets/audio/cries/<id>.ogg
// Resumen de qué se ha copiado y de qué pack: data/generated/pokemon_assets.json (lo lee el validador).
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { readFile, readdir, stat, mkdir, copyFile, writeFile, rename, unlink } from 'node:fs/promises';

const DEFAULT_SOURCE = '/mnt/c/Users/Javier/Pokemon-Panchito-recursos';
const PACKS = [
  { id: '06_generation9_pack', name: 'Generation 9 Resource Pack v3.3.8', followers: 'Graphics/Characters' },
  { id: '07_generation8_pack', name: 'Generation 8 Pack v20.1', followers: 'Graphics/Pokemon' },
];
const VIEWS = [
  { key: 'front', dir: 'Graphics/Pokemon/Front', ext: 'png', dest: 'assets/sprites/pokemon/front' },
  { key: 'front_shiny', dir: 'Graphics/Pokemon/Front shiny', ext: 'png', dest: 'assets/sprites/pokemon/front_shiny' },
  { key: 'back', dir: 'Graphics/Pokemon/Back', ext: 'png', dest: 'assets/sprites/pokemon/back' },
  { key: 'back_shiny', dir: 'Graphics/Pokemon/Back shiny', ext: 'png', dest: 'assets/sprites/pokemon/back_shiny' },
  { key: 'icons', dir: 'Graphics/Pokemon/Icons', ext: 'png', dest: 'assets/sprites/pokemon/icons' },
  { key: 'icons_shiny', dir: 'Graphics/Pokemon/Icons shiny', ext: 'png', dest: 'assets/sprites/pokemon/icons_shiny' },
  { key: 'followers', dir: '<followers>/Followers', ext: 'png', dest: 'assets/sprites/pokemon/followers' },
  { key: 'followers_shiny', dir: '<followers>/Followers shiny', ext: 'png', dest: 'assets/sprites/pokemon/followers_shiny' },
  { key: 'cries', dir: 'Audio/SE/Cries', ext: 'ogg', dest: 'assets/audio/cries', noFemale: true },
];
// Ids de Essentials que no son nuestro id en mayúsculas.
const ESSENTIALS_ALIASES = { nidoranf: 'NIDORANfE', nidoranm: 'NIDORANmA' };
const FORMS_FILES = [
  'PBS/Gen 9 backup/Vanilla PBS Files (with updates)/pokemon_forms.txt',
  'PBS/pokemon_forms_Gen_9_Pack.txt',
];

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '..', '..');
const argv = process.argv.slice(2);
const flag = (name) => argv.includes(name);
const option = (name, fallback) => {
  const i = argv.indexOf(name);
  return i >= 0 && i + 1 < argv.length ? argv[i + 1] : fallback;
};
const source = option('--source', process.env.PANCHITO_RECURSOS || DEFAULT_SOURCE);
const dryRun = flag('--dry-run');

const exists = (p) => stat(p).then(() => true, () => false);
const toID = (s) => String(s ?? '').toLowerCase().replace(/[^a-z0-9]+/g, '');

async function readJSON(file, fallback = {}) {
  try { return JSON.parse(await readFile(file, 'utf8')); } catch { return fallback; }
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

function collect(value, out, ids, anyString) {
  if (Array.isArray(value)) value.forEach((v) => collect(v, out, ids, anyString));
  else if (value && typeof value === 'object') {
    for (const [k, v] of Object.entries(value)) {
      if (k.startsWith('_')) continue;
      if ((k === 'species' || k === 'give') && typeof v === 'string') out.add(toID(v));
      else collect(v, out, ids, anyString);
    }
  } else if (anyString && typeof value === 'string' && ids.has(toID(value))) out.add(toID(value));
}

// --- Qué especies ---

async function speciesInUse(species) {
  const ids = new Set(Object.keys(species));
  const found = new Set();
  ((await readJSON(path.join(root, 'data', 'regional_dex.json'))).species ?? []).forEach((s) => found.add(toID(s)));
  ((await readJSON(path.join(root, 'data', 'species_in_use.json'))).species ?? []).forEach((s) => found.add(toID(s)));
  for (const dir of ['encounters', 'trainers']) {
    for (const f of await jsonFiles(path.join(root, 'data', dir))) collect(await readJSON(f), found, ids, false);
  }
  for (const name of ['starters', 'gifts', 'statics', 'trades']) {
    collect(await readJSON(path.join(root, 'data', `${name}.json`)), found, ids, true);
  }
  const queue = [...found];
  while (queue.length) {
    const s = species[queue.pop()];
    if (!s) continue;
    for (const next of [s.prevo, ...(s.evolutions ?? []).filter((e) => !e.region).map((e) => e.to)]) {
      if (next && species[next] && !found.has(next)) { found.add(next); queue.push(next); }
    }
  }
  const unknown = [...found].filter((id) => !ids.has(id));
  if (unknown.length) console.warn(`Especies que no existen en species.json (se ignoran): ${unknown.join(', ')}`);
  return [...found].filter((id) => ids.has(id)).sort();
}

// --- Nombres de Essentials ---

// Formas de Essentials: {ESPECIE: [{n, name}]} a partir de pokemon_forms.txt.
async function loadForms(packDir) {
  const forms = {};
  for (const rel of FORMS_FILES) {
    let text;
    try { text = await readFile(path.join(packDir, rel), 'utf8'); } catch { continue; }
    let current = null;
    for (const line of text.split(/\r?\n/)) {
      const head = /^\[([A-Za-z0-9_]+),(\d+)\]/.exec(line);
      if (head) {
        current = { species: head[1], n: Number(head[2]), name: '' };
        (forms[current.species] ??= []).push(current);
        continue;
      }
      const fn = /^FormName\s*=\s*(.+?)\s*$/.exec(line);
      if (fn && current) current.name = fn[1];
    }
  }
  return forms;
}

// "Alolan" → "alola", "Mega Charizard X" → "megax", "Heat Rotom" → "heat", "Paldean (Combat Breed)" → "paldeacombat".
function normalizeForm(name, speciesName) {
  let s = toID(name).replace(/alolan/g, 'alola').replace(/galarian/g, 'galar').replace(/hisuian/g, 'hisui').replace(/paldean/g, 'paldea');
  const base = toID(speciesName);
  if (base) s = s.replace(base, '');
  return s.replace(/(forme|form|mode|breed|style|cloak|size)$/g, '').replace(/(forme|form|mode|breed)/g, '');
}

function essentialsName(id, species, forms) {
  const s = species[id];
  const baseId = s.base_species || id;
  const ess = ESSENTIALS_ALIASES[baseId] ?? baseId.toUpperCase();
  if (!s.base_species) return ess;
  const wanted = toID(s.forme);
  const candidates = (forms[ess] ?? []).map((f) => ({ ...f, norm: normalizeForm(f.name, species[baseId]?.name_en ?? baseId) }));
  const exact = candidates.find((f) => f.norm === wanted);
  const partial = candidates.filter((f) => f.norm.startsWith(wanted) || wanted.startsWith(f.norm)).sort((a, b) => a.norm.length - b.norm.length)[0];
  const match = exact ?? partial;
  return match ? `${ess}_${match.n}` : null;
}

// --- Principal ---

async function main() {
  if (!(await exists(path.join(source, PACKS[0].id)))) {
    console.error(`ERROR: no encuentro ${PACKS[0].id} en ${source} (usa --source o PANCHITO_RECURSOS).`);
    process.exit(2);
  }
  const species = await readJSON(path.join(root, 'data', 'generated', 'species.json'));
  let targets;
  if (flag('--all')) targets = Object.keys(species).filter((id) => !species[id].is_cosmetic_form && species[id].num > 0).sort();
  else if (option('--species', '')) targets = option('--species', '').split(',').map(toID).filter((id) => species[id]);
  else targets = await speciesInUse(species);
  const forms = await loadForms(path.join(source, PACKS[0].id));
  console.log(`Importando ${targets.length} especies desde ${source}${dryRun ? ' (simulación)' : ''}...`);

  const manifest = { source: PACKS.map((p) => p.name), species: {}, missing: {}, unmatched_forms: [] };
  const stats = { copied: 0, unchanged: 0, fallback: 0 };
  for (const id of targets) {
    const ess = essentialsName(id, species, forms);
    if (!ess) { manifest.unmatched_forms.push(id); continue; }
    const entry = (manifest.species[id] = { essentials: ess, files: {} });
    for (const view of VIEWS) {
      const variants = [[ess, id]];
      // Las formas usan el grito de su especie si no tienen uno propio (como en Essentials).
      if (view.noFemale && ess.includes('_')) variants[0] = [[ess, ess.replace(/_\d+$/, '')], id];
      if (!view.noFemale) variants.push([`${ess}_female`, `${id}_female`]);
      for (const [names, to] of variants) {
        let found = null;
        for (const pack of PACKS) {
          for (const from of [names].flat()) {
            const file = path.join(source, pack.id, view.dir.replace('<followers>', pack.followers), `${from}.${view.ext}`);
            if (!found && (await exists(file))) found = { file, pack: pack.id };
          }
          if (found) break;
        }
        if (!found) {
          if (to === id) (manifest.missing[view.key] ??= []).push(id);
          continue;
        }
        if (found.pack !== PACKS[0].id) stats.fallback++;
        const dest = path.join(root, view.dest, `${to}.${view.ext}`);
        entry.files[to === id ? view.key : `${view.key}_female`] = found.pack;
        const data = await readFile(found.file);
        const current = (await exists(dest)) ? await readFile(dest) : null;
        if (current && current.equals(data)) { stats.unchanged++; continue; }
        if (!dryRun) {
          await mkdir(path.dirname(dest), { recursive: true });
          await copyFile(found.file, dest);
        }
        stats.copied++;
      }
    }
  }

  if (flag('--prune') && !dryRun) {
    const keep = new Set(targets.flatMap((id) => [id, `${id}_female`]));
    for (const view of VIEWS) {
      const dir = path.join(root, view.dest);
      if (!(await exists(dir))) continue;
      for (const name of await readdir(dir)) {
        const m = new RegExp(`^(.+)\\.${view.ext}$`).exec(name);
        if (m && !keep.has(m[1])) {
          await unlink(path.join(dir, name));
          if (await exists(path.join(dir, `${name}.import`))) await unlink(path.join(dir, `${name}.import`));
        }
      }
    }
  }

  if (!dryRun) {
    const out = path.join(root, 'data', 'generated', 'pokemon_assets.json');
    await writeFile(out + '.tmp', JSON.stringify(manifest, null, 1) + '\n');
    await rename(out + '.tmp', out);
  }
  console.log(`\nCopiados: ${stats.copied} · sin cambios: ${stats.unchanged} · del pack 07 (reserva): ${stats.fallback}`);
  for (const [key, ids] of Object.entries(manifest.missing)) console.log(`Faltan en ${key} (${ids.length}): ${ids.join(', ')}`);
  if (manifest.unmatched_forms.length) console.log(`Formas sin correspondencia en Essentials: ${manifest.unmatched_forms.join(', ')}`);
  console.log('\nDespués: godot --headless --path . --import (para crear los .import).');
  process.exit(Object.keys(manifest.missing).length || manifest.unmatched_forms.length ? 1 : 0);
}

main().catch((e) => {
  console.error(`ERROR: ${e.message}`);
  process.exit(2);
});
