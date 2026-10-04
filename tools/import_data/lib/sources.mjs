import { createRequire } from 'node:module';
import { stat } from 'node:fs/promises';
import path from 'node:path';
import { SHOWDOWN, POKEAPI, LANG_ES, LANG_EN } from '../config.mjs';
import { fetchCached, mapLimit } from './download.mjs';
import { tarEntries } from './tar.mjs';
import { parseCSV } from './csv.mjs';
import { cleanText, writeAtomic } from './util.mjs';

const require = createRequire(import.meta.url);
const exists = (p) => stat(p).then(() => true, () => false);
const PLACEHOLDER_TEXT = /no se puede usar, por lo que sería mejor olvidarlo|This move can’t be used|^[\s-]*$|\[VAR/;

// Datos de Showdown: se descarga el tarball de npm (integridad verificada) y se extrae solo dist/data.
export async function loadShowdown(cacheDir, { offline }) {
  const dir = path.join(cacheDir, `showdown-${SHOWDOWN.version}`);
  // Se guardan como .cjs: son módulos CommonJS y tools/ está en modo ES module.
  const wanted = SHOWDOWN.files.map((f) => path.join(dir, `${f}.cjs`));
  if (!(await Promise.all(wanted.map(exists))).every(Boolean)) {
    const tgz = await fetchCached(SHOWDOWN.tarball, path.join(cacheDir, `${SHOWDOWN.package}-${SHOWDOWN.version}.tgz`),
      { offline, integrity: SHOWDOWN.integrity });
    for (const { name, data } of tarEntries(tgz)) {
      const m = /^package\/dist\/data\/([a-z-]+)\.js$/.exec(name);
      if (m && SHOWDOWN.files.includes(m[1])) await writeAtomic(path.join(dir, `${m[1]}.cjs`), data);
    }
  }
  const load = (f) => require(path.join(dir, `${f}.cjs`));
  return {
    Pokedex: load('pokedex').Pokedex,
    Moves: load('moves').Moves,
    Abilities: load('abilities').Abilities,
    Items: load('items').Items,
    Learnsets: load('learnsets').Learnsets,
    Natures: load('natures').Natures,
    TypeChart: load('typechart').TypeChart,
    FormatsData: load('formats-data').FormatsData,
  };
}

// CSV de PokeAPI en un commit fijo.
export async function loadPokeAPI(cacheDir, { offline }) {
  const dir = path.join(cacheDir, `pokeapi-${POKEAPI.commit.slice(0, 12)}`);
  const base = `https://raw.githubusercontent.com/${POKEAPI.repo}/${POKEAPI.commit}/data/v2/csv`;
  const tables = {};
  await mapLimit(POKEAPI.files, 6, async (f) => {
    const buf = await fetchCached(`${base}/${f}.csv`, path.join(dir, `${f}.csv`), { offline });
    tables[f] = parseCSV(buf.toString('utf8'));
  });
  return new PokeAPI(tables);
}

class PokeAPI {
  constructor(tables) {
    this.tables = tables;
    const lang = tables.languages.find((l) => l.iso639 === 'es' && l.iso3166 === 'es');
    if (!lang || Number(lang.id) !== LANG_ES) throw new Error(`El español (es-ES) ya no es el idioma ${LANG_ES} en languages.csv`);
    const vgOrder = new Map(tables.version_groups.map((g) => [g.id, Number(g.order)]));
    this.versionGroupOrder = vgOrder;
    this.versionOrder = new Map(tables.versions.map((v) => [v.id, vgOrder.get(v.version_group_id) * 1000 + Number(v.id)]));
  }

  rows(name) { return this.tables[name]; }

  // Map id -> fila completa en el idioma pedido (para tablas *_names).
  namesRows(table, idCol, lang = LANG_ES) {
    const out = new Map();
    for (const r of this.tables[table]) if (Number(r.local_language_id) === lang) out.set(r[idCol], r);
    return out;
  }

  names(table, idCol, lang = LANG_ES, col = 'name') {
    const out = new Map();
    for (const [id, r] of this.namesRows(table, idCol, lang)) if (r[col]) out.set(id, cleanText(r[col]));
    return out;
  }

  // Texto más reciente (por orden de versión) en el idioma pedido. Se descartan los textos de
  // relleno de los juegos recientes ("Este movimiento no se puede usar...", "- - -", "[VAR...").
  latestText(table, idCol, lang = LANG_ES) {
    const sample = this.tables[table][0];
    const byVersion = 'version_id' in sample;
    const order = byVersion ? this.versionOrder : this.versionGroupOrder;
    const verCol = byVersion ? 'version_id' : 'version_group_id';
    const best = new Map();
    for (const r of this.tables[table]) {
      if (Number(r.language_id) !== lang) continue;
      const text = cleanText(r.flavor_text);
      if (PLACEHOLDER_TEXT.test(text)) continue;
      const o = order.get(r[verCol]) ?? 0;
      const cur = best.get(r[idCol]);
      if (!cur || o >= cur.o) best.set(r[idCol], { o, text });
    }
    return new Map([...best].map(([k, v]) => [k, v.text]));
  }
}

export { LANG_ES, LANG_EN };
