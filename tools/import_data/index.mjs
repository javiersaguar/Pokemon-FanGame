#!/usr/bin/env node
// Importa los datos oficiales (Showdown + PokeAPI) a data/generated/*.json.
// Uso: node tools/import_data/index.mjs [--offline] [--verbose]
import path from 'node:path';
import { readFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { SHOWDOWN, POKEAPI, LANG_ES } from './config.mjs';
import { loadShowdown, loadPokeAPI } from './lib/sources.mjs';
import { serialize, writeAtomic } from './lib/util.mjs';
import { buildTypes, buildNatures, buildExpTables } from './build/basic.mjs';
import { buildMoves, buildAbilities } from './build/moves.mjs';
import { buildItems } from './build/items.mjs';
import { buildSpecies, buildLearnsets } from './build/species.mjs';

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '..', '..');
const cacheDir = path.join(root, 'tools', 'cache');
const outDir = path.join(root, 'data', 'generated');
const args = new Set(process.argv.slice(2));
const offline = args.has('--offline');
const verbose = args.has('--verbose');

class Report {
  missingNames = {};
  missingDescs = {};
  notes = {};
  missingName(kind, id) { (this.missingNames[kind] ??= []).push(id); }
  missingDesc(kind, id) { (this.missingDescs[kind] ??= []).push(id); }
  note(kind, msg) { (this.notes[kind] ??= []).push(msg); }
}

const preview = (list, n = 15) => list.slice(0, n).join(', ') + (list.length > n ? `, … (+${list.length - n})` : '');

async function main() {
  const t0 = Date.now();
  console.log(`Fuentes: ${SHOWDOWN.package}@${SHOWDOWN.version} · ${POKEAPI.repo}@${POKEAPI.commit.slice(0, 12)}${offline ? ' (sin conexión)' : ''}`);
  const [sd, pa] = await Promise.all([loadShowdown(cacheDir, { offline }), loadPokeAPI(cacheDir, { offline })]);
  const extraItems = JSON.parse(await readFile(path.join(here, 'extra', 'item_effects.json'), 'utf8'));

  const report = new Report();
  const types = buildTypes(sd, pa, report);
  const natures = buildNatures(sd, pa, report);
  const expTables = buildExpTables(pa);
  const moves = buildMoves(sd, pa, report);
  const abilities = buildAbilities(sd, pa, report);
  const items = buildItems(sd, pa, extraItems, report);
  const species = buildSpecies(sd, pa, report);
  const learnsets = buildLearnsets(sd, species, moves);

  const files = { species, moves, abilities, items, types, learnsets, exp_tables: expTables, natures };
  const counts = Object.fromEntries(Object.entries(files).map(([k, v]) => [k, Object.keys(v).length]));
  const missingCount = (m) => Object.fromEntries(Object.entries(m).map(([k, v]) => [k, v.length]));
  const meta = {
    generator: 'tools/import_data',
    language_id: LANG_ES,
    sources: {
      showdown: { package: SHOWDOWN.package, version: SHOWDOWN.version, integrity: SHOWDOWN.integrity },
      pokeapi: { repo: POKEAPI.repo, commit: POKEAPI.commit },
    },
    counts,
    missing_spanish_names: missingCount(report.missingNames),
    missing_spanish_descriptions: missingCount(report.missingDescs),
  };

  for (const [name, data] of Object.entries(files)) await writeAtomic(path.join(outDir, `${name}.json`), serialize(data));
  await writeAtomic(path.join(outDir, 'meta.json'), JSON.stringify(meta, null, 2) + '\n');
  await writeAtomic(path.join(cacheDir, 'import_report.json'), JSON.stringify(report, null, 2) + '\n');

  console.log('\nRegistros generados en data/generated/:');
  for (const [k, v] of Object.entries(counts)) console.log(`  ${`${k}.json`.padEnd(18)} ${String(v).padStart(5)}`);
  console.log('\nSin nombre en español:');
  for (const [k, v] of Object.entries(report.missingNames)) console.log(`  ${k.padEnd(10)} ${String(v.length).padStart(4)}  ${preview(v)}`);
  console.log('\nSin descripción en español:');
  for (const [k, v] of Object.entries(report.missingDescs)) console.log(`  ${k.padEnd(10)} ${String(v.length).padStart(4)}${verbose ? '  ' + preview(v, 1e9) : ''}`);
  console.log('\nAvisos:');
  for (const [k, v] of Object.entries(report.notes)) {
    console.log(`  ${k.padEnd(10)} ${String(v.length).padStart(4)}`);
    if (verbose) v.forEach((n) => console.log(`      - ${n}`));
  }
  console.log(`\nInforme completo: tools/cache/import_report.json · ${((Date.now() - t0) / 1000).toFixed(1)} s`);
}

main().catch((e) => {
  console.error(`ERROR: ${e.message}`);
  process.exit(1);
});
