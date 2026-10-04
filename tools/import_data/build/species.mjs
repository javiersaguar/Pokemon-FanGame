import { toID, snake, compact } from '../lib/util.mjs';
import { GROWTH } from './basic.mjs';
import { EXCLUDED_NONSTANDARD } from './moves.mjs';

const STATS = { 1: 'hp', 2: 'atk', 3: 'def', 4: 'spa', 5: 'spd', 6: 'spe' };
const EVO_METHOD = {
  levelFriendship: 'friendship', useItem: 'item', trade: 'trade', levelHold: 'level_hold',
  levelMove: 'level_move', levelExtra: 'level_extra', other: 'other',
};
const GENDER = { M: 'male', F: 'female' };

// Traduce las condiciones de texto de Showdown más comunes a campos estructurados.
// El texto original se conserva siempre en "condition".
function parseCondition(cond, evo) {
  const c = cond.toLowerCase();
  let m;
  if (c.includes('at night')) evo.time = 'night';
  else if (c.includes('during the day')) evo.time = 'day';
  else if (c.includes('evening')) evo.time = 'dusk';
  if (c.includes('atk stat > its def')) evo.stat_relation = 'atk_gt_def';
  else if (c.includes('atk stat < its def')) evo.stat_relation = 'atk_lt_def';
  else if (c.includes('atk stat equal to its def')) evo.stat_relation = 'atk_eq_def';
  if ((m = /with an? ([a-z]+)-type in the party/.exec(c))) evo.party_type = m[1];
  else if ((m = /with an? ([a-z0-9.' -]+?) in (the )?party/.exec(c))) evo.party_species = toID(m[1]);
  if ((m = /with an? ([a-z]+)-type move/.exec(c))) evo.known_move_type = m[1];
  if ((m = /(\w+) levels of affection/.exec(c))) evo.min_affection = { one: 1, two: 2, three: 3 }[m[1]] ?? Number(m[1]);
  if (c.includes('during rain')) evo.weather = 'rain';
  if (c.includes('magnetic field')) evo.location = 'magnetic_field';
  if (c.includes('upside-down')) evo.upside_down = true;
  if (evo.method === 'trade' && (m = /^with an? ([a-z]+)$/.exec(c))) evo.trade_with = toID(m[1]);
}

function evolutionOf(target, source) {
  const evo = { to: toID(target.name), method: EVO_METHOD[target.evoType] ?? 'level' };
  if (target.evoLevel !== undefined) evo.level = target.evoLevel;
  if (target.evoItem) evo.item = toID(target.evoItem);
  if (target.evoMove) evo.move = toID(target.evoMove);
  if (target.evoRegion) evo.region = toID(target.evoRegion);
  if (target.gender && target.gender !== 'N' && target.gender !== source.gender) evo.gender = GENDER[target.gender];
  if (target.evoCondition) {
    evo.condition = target.evoCondition;
    parseCondition(target.evoCondition, evo);
  }
  return evo;
}

function genderRatio(s) {
  if (s.gender === 'N') return -1;
  if (s.gender === 'F') return 1;
  if (s.gender === 'M') return 0;
  return s.genderRatio ? s.genderRatio.F : 0.5;
}

const ids = (v) => (v === undefined ? undefined : (Array.isArray(v) ? v.map(toID) : toID(v)));

// species.json (incluye formas: "raichualola", "charizardmegax"... con "base_species").
export function buildSpecies(sd, pa, report) {
  const P = sd.Pokedex;
  const F = sd.FormatsData;
  const L = sd.Learnsets;
  const keep = (id, s) => s && s.num > 0 && !EXCLUDED_NONSTANDARD.has(s.isNonstandard) && !EXCLUDED_NONSTANDARD.has(F[id]?.isNonstandard);

  const species = new Map(pa.rows('pokemon_species').map((s) => [s.id, s]));
  const spNames = pa.namesRows('pokemon_species_names', 'pokemon_species_id');
  const spFlavor = pa.latestText('pokemon_species_flavor_text', 'species_id');
  const growth = new Map(pa.rows('growth_rates').map((g) => [g.id, GROWTH[g.identifier]]));
  const pokemonByIdent = new Map(pa.rows('pokemon').map((p) => [toID(p.identifier), p]));
  const defaultPokemon = new Map(pa.rows('pokemon').filter((p) => p.is_default === '1').map((p) => [p.species_id, p]));
  const evYield = new Map();
  for (const r of pa.rows('pokemon_stats')) {
    if (Number(r.effort) <= 0) continue;
    if (!evYield.has(r.pokemon_id)) evYield.set(r.pokemon_id, {});
    evYield.get(r.pokemon_id)[STATS[r.stat_id]] = Number(r.effort);
  }
  const formsByIdent = new Map(pa.rows('pokemon_forms').map((f) => [toID(f.identifier), f]));
  const formNames = pa.namesRows('pokemon_form_names', 'pokemon_form_id');
  const formFlavor = pa.latestText('pokemon_form_flavor_text', 'pokemon_form_id');
  const hasLearnset = (k) => !!L[k]?.learnset;

  const out = {};
  for (const [id, s] of Object.entries(P)) {
    if (!keep(id, s)) continue;
    const num = String(s.num);
    const sp = species.get(num);
    if (!sp) { report.note('species', `${id}: sin datos de especie en PokeAPI (num ${num})`); }
    const isForme = !!s.baseSpecies;
    const baseName = spNames.get(num)?.name;

    let pkmn = pokemonByIdent.get(id) ?? pokemonByIdent.get(id.replace(/f$/, 'female'));
    if (!pkmn) {
      pkmn = defaultPokemon.get(num);
      if (isForme) report.note('species', `${id}: EVs y experiencia base tomados de la forma base`);
    }
    const form = formsByIdent.get(id) ?? formsByIdent.get(id.replace(/f$/, 'female'));
    const fName = form && formNames.get(form.id);

    // Como en los juegos, una forma se llama igual que su especie ("Raichu"); la forma va en form_name.
    const name = baseName;
    const formName = isForme ? (fName?.form_name || fName?.pokemon_name || undefined) : undefined;
    if (!name) report.missingName('species', id);
    if (isForme && !formName) report.missingName('forms', id);
    const dexEntry = (form && formFlavor.get(form.id)) || spFlavor.get(num);
    if (!dexEntry) report.missingDesc('species', id);

    const learnset = hasLearnset(id) ? id
      : (s.changesFrom && hasLearnset(toID(s.changesFrom))) ? toID(s.changesFrom)
        : (s.baseSpecies && hasLearnset(toID(s.baseSpecies))) ? toID(s.baseSpecies) : '';
    if (!learnset) report.note('learnsets', `${id}: sin learnset`);

    const nonstandard = s.isNonstandard ?? F[id]?.isNonstandard;
    out[id] = compact({
      num: s.num,
      name: name ?? s.name,
      name_en: s.name,
      base_species: isForme ? toID(s.baseSpecies) : undefined,
      forme: isForme ? toID(s.forme) : undefined,
      form_name: formName,
      types: s.types.map(toID),
      base_stats: s.baseStats,
      abilities: Object.fromEntries(Object.entries(s.abilities).map(([slot, a]) => [slot, toID(a)])),
      gender_ratio: genderRatio(s),
      catch_rate: sp ? Number(sp.capture_rate) : 45,
      base_exp: pkmn?.base_experience ? Number(pkmn.base_experience) : 0,
      exp_group: sp ? growth.get(sp.growth_rate_id) : 'medium_fast',
      ev_yield: (pkmn && evYield.get(pkmn.id)) ?? {},
      egg_groups: (s.eggGroups ?? []).map(snake),
      egg_cycles: sp ? Number(sp.hatch_counter) : undefined,
      hatch_steps: sp ? Number(sp.hatch_counter) * 256 : undefined,
      base_friendship: sp ? Number(sp.base_happiness) : 50,
      height: s.heightm,
      weight: s.weightkg,
      color: snake(s.color),
      genus: spNames.get(num)?.genus || undefined,
      generation: s.gen ?? (sp ? Number(sp.generation_id) : undefined),
      prevo: s.prevo ? toID(s.prevo) : undefined,
      evolutions: [],
      forms: s.otherFormes ? ids(s.otherFormes).filter((f) => keep(f, P[f])) : undefined,
      cosmetic_forms: ids(s.cosmeticFormes),
      is_cosmetic_form: s.isCosmeticForme,
      is_mega: isForme && /^(mega|primal)/i.test(s.forme) ? true : undefined,
      is_gmax: s.forme === 'Gmax' ? true : undefined,
      battle_only: ids(s.battleOnly),
      changes_from: ids(s.changesFrom),
      required_item: ids(s.requiredItem),
      required_items: ids(s.requiredItems),
      required_ability: ids(s.requiredAbility),
      required_move: ids(s.requiredMove),
      can_gigantamax: ids(s.canGigantamax),
      is_legendary: sp?.is_legendary === '1' || undefined,
      is_mythical: sp?.is_mythical === '1' || undefined,
      is_baby: sp?.is_baby === '1' || undefined,
      tags: s.tags?.map(snake),
      nonstandard: nonstandard ? snake(nonstandard) : undefined,
      learnset,
      dex_entry: dexEntry ?? '',
    });
  }

  for (const [id, s] of Object.entries(P)) {
    if (!out[id] || !s.evos) continue;
    out[id].evolutions = s.evos.map(toID).filter((to) => out[to]).map((to) => evolutionOf(P[to], s));
  }
  return out;
}

// learnsets.json: { id: { gen, level: [[nivel, movimiento]...], machine, tutor, egg } }
// Se usa la generación más reciente que tenga datos de cada tipo. Nivel 0 = al evolucionar.
export function buildLearnsets(sd, speciesOut, movesOut) {
  const out = {};
  for (const s of Object.values(speciesOut)) {
    if (!s.learnset || out[s.learnset]) continue;
    const learnset = sd.Learnsets[s.learnset].learnset;
    const latest = { L: 0, M: 0, T: 0, E: 0 };
    for (const srcs of Object.values(learnset)) {
      for (const src of srcs) if (src[1] in latest) latest[src[1]] = Math.max(latest[src[1]], Number(src[0]));
    }
    const level = [];
    const sets = { M: new Set(), T: new Set(), E: new Set() };
    for (const [move, srcs] of Object.entries(learnset)) {
      if (!movesOut[move]) continue;
      for (const src of srcs) {
        const kind = src[1];
        if (!(kind in latest) || Number(src[0]) !== latest[kind]) continue;
        if (kind === 'L') level.push([Number(src.slice(2)), move]);
        else sets[kind].add(move);
      }
    }
    level.sort((a, b) => a[0] - b[0] || (a[1] < b[1] ? -1 : a[1] > b[1] ? 1 : 0));
    out[s.learnset] = {
      gen: latest.L,
      level,
      machine: [...sets.M].sort(),
      tutor: [...sets.T].sort(),
      egg: [...sets.E].sort(),
    };
  }
  return out;
}
