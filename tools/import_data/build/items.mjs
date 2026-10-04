import { toID, snake, compact, callbacks, boostsToSnake } from '../lib/util.mjs';
import { EXCLUDED_NONSTANDARD } from './moves.mjs';
import { LANG_EN } from '../config.mjs';

// Bolsillo de PokeAPI -> bolsillo de la mochila (Fase 11.1).
const POCKET = {
  misc: 'items', medicine: 'medicine', pokeballs: 'pokeballs', machines: 'machines',
  berries: 'berries', mail: 'mail', battle: 'battle', key: 'key',
};

// Categorías de PokeAPI que no pintan nada en el juego.
const SKIP_CATEGORIES = new Set([
  'unused', 'data-cards', 'apricorn-box', 'curry-ingredients', 'sandwich-ingredients', 'picnic',
  'tm-materials', 'miracle-shooter', 'dynamax-crystals',
]);

// Identificadores de PokeAPI que Showdown llama de otra forma.
const ALIASES = { stick: 'leek', 'pretty-wing': 'prettyfeather' };
const itemID = (identifier) => ALIASES[identifier] ?? toID(identifier.replace(/--(held|bag)$/, ''));

const ids = (v) => (v === undefined ? undefined : (Array.isArray(v) ? v.map(toID) : toID(v)));

function showdownFields(it) {
  if (!it) return {};
  const hooks = callbacks(it);
  return {
    fling_power: it.fling?.basePower,
    is_berry: it.isBerry,
    is_pokeball: it.isPokeball,
    is_gem: it.isGem,
    is_choice: it.isChoice,
    natural_gift: it.naturalGift && { power: it.naturalGift.basePower, type: toID(it.naturalGift.type) },
    on_plate: ids(it.onPlate),
    on_memory: ids(it.onMemory),
    on_drive: ids(it.onDrive),
    mega_stone: typeof it.megaStone === 'object' && it.megaStone !== null
      ? Object.fromEntries(Object.entries(it.megaStone).map(([k, v]) => [toID(k), toID(v)]))
      : ids(it.megaStone),
    mega_evolves: ids(it.megaEvolves),
    item_user: ids(it.itemUser),
    forced_forme: ids(it.forcedForme),
    z_move: it.zMove === undefined ? undefined : (it.zMove === true ? true : toID(it.zMove)),
    z_move_type: ids(it.zMoveType),
    z_move_from: ids(it.zMoveFrom),
    boosts: boostsToSnake(it.boosts),
    ignore_klutz: it.ignoreKlutz,
    is_primal_orb: it.isPrimalOrb,
    gen: it.gen,
    nonstandard: it.isNonstandard ? snake(it.isNonstandard) : undefined,
    held_needs_script: hooks.length > 0 || it.condition !== undefined || undefined,
    script_hooks: hooks.length ? hooks : undefined,
  };
}

// items.json: base de PokeAPI (todos los objetos del juego, con precio, bolsillo y textos en español)
// + datos de combate de Showdown + efectos de uso de extra/item_effects.json.
export function buildItems(sd, pa, extra, report) {
  const categories = new Map(pa.rows('item_categories').map((c) => [c.id, c]));
  const pockets = new Map(pa.rows('item_pockets').map((p) => [p.id, p.identifier]));
  const flagNames = new Map(pa.rows('item_flags').map((f) => [f.id, snake(f.identifier)]));
  const flags = new Map();
  for (const r of pa.rows('item_flag_map')) {
    if (!flags.has(r.item_id)) flags.set(r.item_id, []);
    flags.get(r.item_id).push(flagNames.get(r.item_flag_id));
  }
  const names = pa.names('item_names', 'item_id');
  const namesEn = pa.names('item_names', 'item_id', LANG_EN);
  const descs = pa.latestText('item_flavor_text', 'item_id');

  const out = {};
  for (const r of pa.rows('items')) {
    const cat = categories.get(r.category_id);
    if (!cat || SKIP_CATEGORIES.has(cat.identifier)) continue;
    const id = itemID(r.identifier);
    if (out[id]) { report.note('items', `identificador duplicado en PokeAPI: ${r.identifier}`); continue; }
    const it = sd.Items[id];
    if (it && EXCLUDED_NONSTANDARD.has(it.isNonstandard)) continue;
    const name = names.get(r.id);
    if (!name) report.missingName('items', id);
    const description = descs.get(r.id);
    if (!description) report.missingDesc('items', id);
    out[id] = compact({
      name: name ?? it?.name ?? namesEn.get(r.id) ?? r.identifier,
      name_en: it?.name ?? namesEn.get(r.id),
      pocket: POCKET[pockets.get(cat.pocket_id)] ?? 'items',
      category: snake(cat.identifier),
      price: Number(r.cost) || 0,
      fling_power: r.fling_power ? Number(r.fling_power) : undefined,
      flags: flags.get(r.id),
      ...compact(showdownFields(it)),
      description: description ?? '',
    });
  }

  // Objetos de combate que están en Showdown pero no en PokeAPI.
  for (const [id, it] of Object.entries(sd.Items)) {
    if (out[id] || EXCLUDED_NONSTANDARD.has(it.isNonstandard) || it.num <= 0) continue;
    report.missingName('items', id);
    report.missingDesc('items', id);
    out[id] = compact({
      name: it.name,
      name_en: it.name,
      pocket: it.isBerry ? 'berries' : it.isPokeball ? 'pokeballs' : 'items',
      category: 'held_items',
      price: 0,
      ...compact(showdownFields(it)),
      description: '',
    });
  }

  // Efectos de uso (curar, capturar, repeler...) y correcciones manuales.
  for (const [id, fx] of Object.entries(extra)) {
    if (id.startsWith('_')) continue;
    if (!out[id]) { report.note('items', `extra/item_effects.json: el objeto "${id}" no existe`); continue; }
    Object.assign(out[id], fx);
  }
  return out;
}
