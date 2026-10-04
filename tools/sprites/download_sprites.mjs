#!/usr/bin/env node
// Descarga los sprites de Pokémon (DIRECTRICES §7.2, Fase A.3) desde las carpetas de Pokémon Showdown:
// un único set estilo 5.ª generación (con el Smogon Sprite Project para las generaciones posteriores),
// frente y espalda, normal y shiny (colores oficiales, nunca generados), e iconos de su hoja.
//
// Uso:
//   node tools/sprites/download_sprites.mjs              # especies del juego (Pokédex regional, encuentros,
//                                                       # entrenadores, iniciales, regalos...) y sus familias
//   node tools/sprites/download_sprites.mjs --species pikachu,raichualola
//   node tools/sprites/download_sprites.mjs --all        # todas las especies y formas
// Opciones: --delay <ms> (pausa entre descargas, 300 por defecto), --offline (solo caché), --force (rehace los PNG)
//
// Caché: tools/cache/sprites/ (no se versiona). Destino: assets/sprites/pokemon/<front|back|front_shiny|back_shiny|icons>/<id>.png
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { readFile, readdir, stat, mkdir, writeFile, rename } from 'node:fs/promises';
import { decodePNG, encodePNG, crop, isEmpty } from './png.mjs';

const BASE = 'https://play.pokemonshowdown.com';
const SETS = [
  { key: 'front', folder: 'sprites/gen5' },
  { key: 'back', folder: 'sprites/gen5-back' },
  { key: 'front_shiny', folder: 'sprites/gen5-shiny' },
  { key: 'back_shiny', folder: 'sprites/gen5-back-shiny' },
];
const ICON_SHEET = 'sprites/pokemonicons-sheet.png';
const ICON_INDEX = 'js/battle-dex-data.js';
const ICON_W = 40;
const ICON_H = 30;
const ICON_COLUMNS = 12;
// Las especies con número mayor que el último de la hoja usan el icono 0 (igual que el cliente de Showdown).
const ICON_MAX_NUM = 1025;
const USER_AGENT = 'PokemonPanchito-tools (fangame sin animo de lucro; descarga puntual con pausas)';

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '..', '..');
const cacheDir = path.join(root, 'tools', 'cache', 'sprites');
const outDir = path.join(root, 'assets', 'sprites', 'pokemon');

const argv = process.argv.slice(2);
const flag = (name) => argv.includes(name);
const option = (name, fallback) => {
  const i = argv.indexOf(name);
  return i >= 0 && i + 1 < argv.length ? argv[i + 1] : fallback;
};
const delay = Number(option('--delay', 300));
const offline = flag('--offline');
const force = flag('--force');

const exists = (p) => stat(p).then(() => true, () => false);
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const toID = (s) => String(s ?? '').toLowerCase().replace(/[^a-z0-9]+/g, '');

async function writeAtomic(file, data) {
  await mkdir(path.dirname(file), { recursive: true });
  await writeFile(file + '.tmp', data);
  await rename(file + '.tmp', file);
}

async function readJSON(file, fallback = {}) {
  try {
    return JSON.parse(await readFile(file, 'utf8'));
  } catch {
    return fallback;
  }
}

// --- Descargas con caché (los 404 también se recuerdan) ---

let missingIndex = null;
const missingFile = path.join(cacheDir, 'missing.json');
let lastFetch = 0;

async function fetchCached(relUrl) {
  const file = path.join(cacheDir, relUrl);
  if (await exists(file)) return readFile(file);
  missingIndex ??= await readJSON(missingFile, {});
  if (missingIndex[relUrl]) return null;
  if (offline) return null;
  const wait = lastFetch + delay - Date.now();
  if (wait > 0) await sleep(wait);
  lastFetch = Date.now();
  const res = await fetch(`${BASE}/${relUrl}`, { headers: { 'User-Agent': USER_AGENT } });
  if (res.status === 404) {
    missingIndex[relUrl] = true;
    await writeAtomic(missingFile, JSON.stringify(missingIndex, null, 1));
    return null;
  }
  if (!res.ok) throw new Error(`HTTP ${res.status} al descargar ${relUrl}`);
  const buf = Buffer.from(await res.arrayBuffer());
  await writeAtomic(file, buf);
  return buf;
}

// --- Qué especies ---

function collectSpecies(value, out, speciesIds, anyString) {
  if (Array.isArray(value)) value.forEach((v) => collectSpecies(v, out, speciesIds, anyString));
  else if (value && typeof value === 'object') {
    for (const [k, v] of Object.entries(value)) {
      if (k.startsWith('_')) continue;
      if (k === 'species' && typeof v === 'string') out.add(toID(v));
      else collectSpecies(v, out, speciesIds, anyString);
    }
  } else if (anyString && typeof value === 'string' && speciesIds.has(toID(value))) out.add(toID(value));
}

async function jsonFiles(dir) {
  if (!(await exists(dir))) return [];
  const out = [];
  for (const entry of await readdir(dir, { withFileTypes: true })) {
    const p = path.join(dir, entry.name);
    if (entry.isDirectory()) out.push(...(await jsonFiles(p)));
    else if (entry.name.endsWith('.json')) out.push(p);
  }
  return out;
}

async function gameSpecies(species) {
  const ids = new Set(Object.keys(species));
  const found = new Set();
  const regional = await readJSON(path.join(root, 'data', 'regional_dex.json'), {});
  (regional.species ?? []).forEach((s) => found.add(toID(s)));
  for (const dir of ['encounters', 'trainers']) {
    for (const file of await jsonFiles(path.join(root, 'data', dir))) collectSpecies(await readJSON(file), found, ids, false);
  }
  for (const name of ['starters', 'gifts', 'statics', 'trades']) {
    collectSpecies(await readJSON(path.join(root, 'data', `${name}.json`)), found, ids, true);
  }
  // Familias completas: lo que se puede conseguir evolucionando (y sus preevoluciones).
  const queue = [...found];
  while (queue.length) {
    const id = queue.pop();
    const s = species[id];
    if (!s) continue;
    for (const next of [s.prevo, ...(s.evolutions ?? []).filter((e) => !e.region).map((e) => e.to)]) {
      if (next && species[next] && !found.has(next)) {
        found.add(next);
        queue.push(next);
      }
    }
  }
  return [...found].filter((id) => ids.has(id));
}

// Nombre del archivo en Showdown: especie base + "-" + forma ("raichu-alola", "charizard-megax").
const spriteId = (id, s) => (s.base_species ? `${s.base_species}-${s.forme}` : id);

// --- Iconos ---

async function loadIcons() {
  const sheetBuf = await fetchCached(ICON_SHEET);
  const indexBuf = await fetchCached(ICON_INDEX);
  if (!sheetBuf || !indexBuf) return null;
  const src = indexBuf.toString('utf8');
  const start = src.indexOf('BattlePokemonIconIndexes');
  const body = src.slice(src.indexOf('{', start) + 1, src.indexOf('}', start));
  const indexes = {};
  for (const m of body.matchAll(/([a-z0-9]+)\s*:\s*(\d+)\s*(?:\+\s*(\d+))?/g)) {
    indexes[m[1]] = Number(m[2]) + Number(m[3] ?? 0);
  }
  return { sheet: decodePNG(sheetBuf), indexes };
}

function iconFor(icons, id, s) {
  let num = s.num > 0 && s.num <= ICON_MAX_NUM ? s.num : 0;
  if (icons.indexes[id] !== undefined) num = icons.indexes[id];
  const x = (num % ICON_COLUMNS) * ICON_W;
  const y = Math.floor(num / ICON_COLUMNS) * ICON_H;
  if (num === 0 || y + ICON_H > icons.sheet.height) return null;
  const img = crop(icons.sheet, x, y, ICON_W, ICON_H);
  return isEmpty(img) ? null : encodePNG(img);
}

// --- Principal ---

async function main() {
  const species = await readJSON(path.join(root, 'data', 'generated', 'species.json'));
  let targets;
  if (flag('--all')) targets = Object.keys(species).filter((id) => !species[id].is_cosmetic_form);
  else if (option('--species', '')) targets = option('--species', '').split(',').map(toID).filter(Boolean);
  else targets = await gameSpecies(species);
  targets.sort();
  const unknown = targets.filter((id) => !species[id]);
  if (unknown.length) console.warn(`Especies que no existen (se ignoran): ${unknown.join(', ')}`);
  targets = targets.filter((id) => species[id]);
  console.log(`Sprites de ${targets.length} especies (pausa de ${delay} ms entre descargas${offline ? ', sin conexión' : ''}).`);

  const stats = { written: 0, kept: 0, missing: {} };
  const record = (key, id) => (stats.missing[key] ??= []).push(id);
  for (const [i, id] of targets.entries()) {
    const sid = spriteId(id, species[id]);
    for (const set of SETS) {
      const dest = path.join(outDir, set.key, `${id}.png`);
      if (!force && (await exists(dest))) { stats.kept++; continue; }
      const buf = await fetchCached(`${set.folder}/${sid}.png`);
      if (!buf) { record(set.key, id); continue; }
      await writeAtomic(dest, buf);
      stats.written++;
    }
    if ((i + 1) % 25 === 0) console.log(`  ${i + 1}/${targets.length}...`);
  }

  const icons = await loadIcons();
  if (!icons) {
    console.warn('No se ha podido cargar la hoja de iconos de Showdown.');
  } else {
    for (const id of targets) {
      const dest = path.join(outDir, 'icons', `${id}.png`);
      if (!force && (await exists(dest))) { stats.kept++; continue; }
      const png = iconFor(icons, id, species[id]);
      if (!png) { record('icons', id); continue; }
      await writeAtomic(dest, png);
      stats.written++;
    }
  }

  console.log(`\nEscritos: ${stats.written} · ya estaban: ${stats.kept}`);
  for (const [key, ids] of Object.entries(stats.missing)) {
    console.log(`Sin sprite en ${key} (${ids.length}): ${ids.slice(0, 30).join(', ')}${ids.length > 30 ? ', …' : ''}`);
  }
  console.log('\nDespués: godot --headless --path . --import (para crear los .import).');
}

main().catch((e) => {
  console.error(`ERROR: ${e.message}`);
  process.exit(1);
});
