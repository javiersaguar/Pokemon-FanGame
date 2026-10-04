import { toID, snake, compact, callbacks, boostsToSnake, isPlainObject } from '../lib/util.mjs';
import { LANG_EN } from '../config.mjs';

export const EXCLUDED_NONSTANDARD = new Set(['CAP', 'Custom']);

// Campos de Showdown que el motor resuelve "por datos" (Fase 7.6). Cualquier otro comportamiento
// (callbacks, condiciones, clima, cambios forzados...) marca el movimiento como needs_script (Fase 9.2).
const SCRIPT_FIELDS = [
  'condition', 'sideCondition', 'pseudoWeather', 'weather', 'terrain', 'slotCondition', 'selfSwitch',
  'forceSwitch', 'stallingMove', 'callsMove', 'hasCrashDamage', 'multiaccuracy', 'overrideOffensiveStat',
  'overrideDefensiveStat', 'overrideOffensivePokemon', 'stealsBoosts', 'mindBlownRecoil', 'chloroblastRecoil',
  'smartTarget', 'tracksTarget', 'nonGhostTarget', 'isZ', 'isMax', 'placeholderFor',
];
const DATA_VOLATILES = new Set(['confusion', 'flinch']);

const CATEGORY = { Physical: 'physical', Special: 'special', Status: 'status' };

function secondaryEntry(s) {
  const extra = Object.keys(s).filter((k) => !['chance', 'status', 'volatileStatus', 'boosts', 'self', 'dustproof', 'kingsrock'].includes(k));
  const selfExtra = s.self ? Object.keys(s.self).filter((k) => k !== 'boosts') : [];
  const dataOnly = !extra.length && !selfExtra.length && (!s.volatileStatus || DATA_VOLATILES.has(s.volatileStatus));
  return {
    dataOnly,
    entry: compact({
      chance: s.chance ?? 100,
      status: s.status,
      volatile_status: s.volatileStatus,
      boosts: boostsToSnake(s.boosts),
      self_boosts: boostsToSnake(s.self?.boosts),
    }),
  };
}

const fraction = (v) => (Array.isArray(v) ? v : undefined);

// moves.json
export function buildMoves(sd, pa, report) {
  const byIdent = new Map(pa.rows('moves').map((m) => [toID(m.identifier), m.id]));
  const byNum = new Set(pa.rows('moves').map((m) => m.id));
  const names = pa.names('move_names', 'move_id');
  const namesEn = pa.names('move_names', 'move_id', LANG_EN);
  const descs = pa.latestText('move_flavor_text', 'move_id');
  const typeNames = pa.names('type_names', 'type_id');
  const typeId = new Map(pa.rows('types').map((t) => [t.identifier, t.id]));

  const out = {};
  for (const [id, m] of Object.entries(sd.Moves)) {
    if (EXCLUDED_NONSTANDARD.has(m.isNonstandard) || m.num <= 0) continue;
    let paId = byIdent.get(id);
    if (!paId && byNum.has(String(m.num)) && toID(namesEn.get(String(m.num))) === toID(m.name)) paId = String(m.num);
    if (!paId && byNum.has(String(m.num)) && m.num < 10000) {
      paId = String(m.num);
      report.note('moves', `${id} enlazado con PokeAPI por número (${m.num})`);
    }

    let name = paId ? names.get(paId) : undefined;
    if (name && id.startsWith('hiddenpower') && id !== 'hiddenpower') name += ` (${typeNames.get(typeId.get(toID(m.type)))})`;
    if (!name) report.missingName('moves', id);
    const description = paId ? descs.get(paId) : undefined;
    if (!description) report.missingDesc('moves', id);

    const secondaries = (m.secondaries ?? (m.secondary ? [m.secondary] : [])).map(secondaryEntry);
    const hooks = callbacks(m);
    const selfExtra = m.self ? Object.keys(m.self).filter((k) => k !== 'boosts') : [];
    const needsScript = hooks.length > 0
      || SCRIPT_FIELDS.some((f) => m[f] !== undefined && m[f] !== false)
      || (m.volatileStatus && !DATA_VOLATILES.has(m.volatileStatus))
      || selfExtra.length > 0
      || m.target === 'scripted'
      || secondaries.some((s) => !s.dataOnly);

    out[id] = compact({
      num: m.num,
      name: name ?? m.name,
      name_en: m.name,
      type: toID(m.type),
      category: CATEGORY[m.category],
      power: m.basePower ?? 0,
      accuracy: m.accuracy === true ? 0 : m.accuracy,
      pp: m.pp,
      priority: m.priority ?? 0,
      target: snake(m.target),
      flags: Object.fromEntries(Object.keys(m.flags ?? {}).map((f) => [f, true])),
      secondaries: secondaries.length ? secondaries.map((s) => s.entry) : undefined,
      boosts: boostsToSnake(m.boosts),
      self_boosts: boostsToSnake(m.self?.boosts ?? m.selfBoost?.boosts),
      status: m.status,
      volatile_status: m.volatileStatus,
      drain: fraction(m.drain),
      recoil: fraction(m.recoil),
      heal: fraction(m.heal),
      multihit: m.multihit,
      crit_ratio: m.critRatio,
      will_crit: m.willCrit,
      ohko: m.ohko === undefined ? undefined : (m.ohko === true ? 'any' : toID(m.ohko)),
      damage: m.damage,
      selfdestruct: m.selfdestruct === undefined ? undefined : snake(m.selfdestruct),
      struggle_recoil: m.struggleRecoil,
      thaws_target: m.thawsTarget,
      ignore_immunity: m.ignoreImmunity === undefined ? undefined
        : (isPlainObject(m.ignoreImmunity) ? Object.keys(m.ignoreImmunity).map(toID) : m.ignoreImmunity),
      ignore_defensive: m.ignoreDefensive,
      ignore_evasion: m.ignoreEvasion,
      ignore_ability: m.ignoreAbility,
      breaks_protect: m.breaksProtect,
      sleep_usable: m.sleepUsable,
      no_pp_boosts: m.noPPBoosts,
      side_condition: m.sideCondition && toID(m.sideCondition),
      pseudo_weather: m.pseudoWeather && toID(m.pseudoWeather),
      weather: m.weather && toID(m.weather),
      terrain: m.terrain && toID(m.terrain),
      self_switch: m.selfSwitch,
      force_switch: m.forceSwitch,
      is_z: m.isZ ? toID(m.isZ) : undefined,
      is_max: m.isMax ? (m.isMax === true ? true : toID(m.isMax)) : undefined,
      z_move: m.zMove && compact({ power: m.zMove.basePower, effect: m.zMove.effect, boosts: boostsToSnake(m.zMove.boost) }),
      max_move: m.maxMove && compact({ power: m.maxMove.basePower }),
      nonstandard: m.isNonstandard ? snake(m.isNonstandard) : undefined,
      needs_script: needsScript,
      script_hooks: hooks.length ? hooks : undefined,
      description: description ?? '',
    });
  }
  return out;
}

// abilities.json
export function buildAbilities(sd, pa, report) {
  const byIdent = new Map(pa.rows('abilities').map((a) => [toID(a.identifier), a.id]));
  const names = pa.names('ability_names', 'ability_id');
  const descs = pa.latestText('ability_flavor_text', 'ability_id');
  const out = {};
  for (const [id, a] of Object.entries(sd.Abilities)) {
    if (EXCLUDED_NONSTANDARD.has(a.isNonstandard) || a.num <= 0) continue;
    const paId = byIdent.get(id) ?? (names.has(String(a.num)) ? String(a.num) : undefined);
    const name = paId ? names.get(paId) : undefined;
    if (!name) report.missingName('abilities', id);
    const description = paId ? descs.get(paId) : undefined;
    if (!description) report.missingDesc('abilities', id);
    const hooks = callbacks(a);
    out[id] = compact({
      num: a.num,
      name: name ?? a.name,
      name_en: a.name,
      rating: a.rating,
      flags: Object.keys(a.flags ?? {}).length ? Object.fromEntries(Object.keys(a.flags).map((f) => [f, true])) : undefined,
      nonstandard: a.isNonstandard ? snake(a.isNonstandard) : undefined,
      needs_script: hooks.length > 0 || a.condition !== undefined,
      script_hooks: hooks.length ? hooks : undefined,
      description: description ?? '',
    });
  }
  return out;
}
