// Juega en el simulador de Pokémon Showdown los combates de un archivo de especificaciones,
// con el azar fijado por el oráculo, y guarda una "foto" del estado al empezar cada turno.
//   node tools/showdown_diff/run_showdown.mjs <specs.json> <salida.json>
// Showdown se busca en $PANCHITO_SHOWDOWN o en ~/.cache/panchito/showdown-0.11.11/package (ver README).

import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import Module, { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';
import { oracleU, choiceStart } from './lib/oracle.mjs';

const HERE = path.dirname(fileURLToPath(import.meta.url));
export const SHOWDOWN_DIR = process.env.PANCHITO_SHOWDOWN
  || path.join(os.homedir(), '.cache', 'panchito', 'showdown-0.11.11', 'package');
const MAX_TURNS = 60;
const FORMAT = 'gen9customgame@@@!Team Preview';

// Showdown pide 'ts-chacha20' al cargar su PRNG; no la necesitamos (el generador es el oráculo).
const STUB = path.join(HERE, 'lib', 'ts-chacha20-stub.cjs');
const originalResolve = Module._resolveFilename;
Module._resolveFilename = function (request, ...rest) {
  if (request === 'ts-chacha20') return STUB;
  return originalResolve.call(this, request, ...rest);
};

export function loadShowdown() {
  if (!fs.existsSync(path.join(SHOWDOWN_DIR, 'dist', 'sim'))) {
    throw new Error(`No encuentro Showdown en ${SHOWDOWN_DIR}. Ver tools/showdown_diff/README.md.`);
  }
  const require = createRequire(import.meta.url);
  return require(path.join(SHOWDOWN_DIR, 'dist', 'sim'));
}

// Funciones del núcleo de Showdown que piden azar, y qué tirada es cada una.
// En hitStepMoveHitLoop, una probabilidad es la precisión de cada golpe; un número, los golpes.
const CORE = {
  randomizer: () => 'damage_roll',
  getDamage: () => 'crit',
  hitStepAccuracy: () => 'accuracy',
  secondaries: () => 'secondary',
  selfDrops: () => 'secondary',
  hitStepMoveHitLoop: (kind) => (kind === 'chance' ? 'accuracy' : 'multihit'),
  dragIn: () => 'force_switch',
};

// Manejadores de efectos que piden azar, y qué tirada es cada uno: "archivo:efecto:función".
// Los objetos de Showdown están congelados, así que el efecto se reconoce por el archivo y la
// línea del manejador en la pila (ver effectAt()).
const HANDLERS = {
  'conditions:par:onBeforeMove': 'par',
  'conditions:frz:onBeforeMove': 'frz_thaw',
  'conditions:slp:onStart': 'slp_turns',
  'conditions:confusion:onStart': 'confusion_turns',
  'conditions:confusion:onBeforeMove': 'confusion_hit',
  'conditions:attract:onBeforeMove': 'attract',
  'conditions:partiallytrapped:durationCallback': 'partiallytrapped_turns',
  'conditions:lockedmove:onStart': 'lockedmove_turns',
  'conditions:stall:onStallMove': 'protect',
  'abilities:shedskin:onResidual': 'shedskin',
};

const effectStarts = new Map();
/** Efecto (id) que contiene la línea `line` de dist/data/<file>.js. */
function effectAt(file, line) {
  if (!effectStarts.has(file)) {
    const text = fs.readFileSync(path.join(SHOWDOWN_DIR, 'dist', 'data', `${file}.js`), 'utf8').split('\n');
    const starts = [];
    text.forEach((l, i) => {
      const m = l.match(/^ {2}([a-z0-9]+): \{$/);
      if (m) starts.push([i + 1, m[1]]);
    });
    effectStarts.set(file, starts);
  }
  let id = null;
  for (const [start, name] of effectStarts.get(file)) {
    if (start > line) break;
    id = name;
  }
  return id;
}

/** Generador de Showdown que contesta con el oráculo y apunta qué tiradas se piden. */
class OraclePRNG {
  constructor(spec, record) {
    this.spec = spec;
    this.record = record;
    this.battle = null;
    this.startingSeed = 'gen5,0000000000000000';
  }

  getSeed() { return this.startingSeed; }
  setSeed() {}
  clone() { return this; }

  tag(kind) {
    const frames = new Error().stack.split('\n').slice(3, 20);
    for (const frame of frames) {
      const match = frame.match(/at (?:[\w$.<>]+\.)?([\w$]+) \(/) || frame.match(/at ([\w$]+) /);
      if (!match) continue;
      const fn = match[1];
      if (CORE[fn]) return CORE[fn](kind);
      const where = frame.match(/dist\/data\/(conditions|abilities|moves|items)\.js:(\d+):/);
      if (where) {
        const tag = HANDLERS[`${where[1]}:${effectAt(where[1], Number(where[2]))}:${fn}`];
        if (tag) return tag;
      }
    }
    return 'other';
  }

  u(tag) {
    const turn = this.battle ? this.battle.turn : 0;
    this.record.tags[tag] = (this.record.tags[tag] || 0) + 1;
    if (tag === 'other') this.record.other.push(`turno ${turn}: ${new Error().stack.split('\n').slice(3, 7).map((s) => s.trim()).join(' < ')}`);
    return oracleU(this.spec, tag, turn);
  }

  random(from, to) {
    const value = this.u(this.tag('random'));
    if (from === undefined) return value;
    from = Math.floor(from);
    if (!to) return Math.floor(value * from);
    to = Math.floor(to);
    return Math.floor(value * (to - from)) + from;
  }

  randomChance(numerator, denominator) {
    return Math.floor(this.u(this.tag('chance')) * denominator) < numerator;
  }

  sample(items) {
    if (items.length === 0) throw new RangeError('Cannot sample an empty array');
    return items[Math.floor(this.u(this.tag('sample')) * items.length)];
  }

  shuffle(items, start = 0, end = items.length) {
    // Showdown baraja los grupos empatados. Si el empate es entre cosas de Pokémon distintos, el
    // resultado depende de su azar y el combate deja de ser comparable desde aquí. Si todo el grupo
    // es del mismo Pokémon (o del campo), el orden no cambia nada que comparemos y se deja como está.
    if (end - start > 1) {
      const owners = new Set();
      const what = [];
      for (let i = start; i < end; i++) {
        const it = items[i];
        const holder = it.pokemon || it.effectHolder;
        const owner = holder && holder.side ? holder.fullname || holder.name : 'campo';
        owners.add(owner);
        what.push(`${it.choice || it.effect?.id || '?'}@${owner}`);
      }
      if (owners.size > 1) this.record.flags.push({ flag: 'speed_tie', turn: this.battle ? this.battle.turn : 0, what });
    }
    return items;
  }
}

function setOf(dex, set, index, side) {
  return {
    name: `${side}${index + 1}`,
    species: dex.species.get(set.species).name,
    level: set.level,
    gender: set.gender || '',
    ability: dex.abilities.get(set.ability).name,
    item: set.item ? dex.items.get(set.item).name : '',
    nature: dex.natures.get(set.nature).name,
    ivs: set.ivs,
    evs: set.evs,
    moves: set.moves.map((m) => dex.moves.get(m).name),
  };
}

function snapshot(battle, order) {
  return {
    turn: battle.turn,
    weather: battle.field.weather || '',
    sides: battle.sides.map((side, s) => order[s].map((name) => {
      const p = side.pokemon.find((q) => q.name === name);
      const entry = { hp: p.hp, status: p.hp <= 0 ? 'fnt' : (p.status || ''), active: !!p.isActive };
      if (entry.active) {
        const boosts = {};
        for (const [k, v] of Object.entries(p.boosts)) if (v) boosts[k] = v;
        entry.boosts = boosts;
        entry.speed = p.getActionSpeed();
      }
      return entry;
    })),
  };
}

function decide(spec, battle, side, s, order) {
  const req = side.activeRequest;
  if (req.teamPreview) return 'default';
  if (req.forceSwitch) {
    for (const name of order[s]) {
      const position = side.pokemon.findIndex((q) => q.name === name);
      const p = side.pokemon[position];
      if (p.hp > 0 && !p.isActive) return `switch ${position + 1}`;
    }
    return 'pass';
  }
  const moves = req.active[0].moves;
  if (moves.length <= 1) return 'move 1';
  const start = choiceStart(spec, s, battle.turn, moves.length);
  for (let k = 0; k < moves.length; k++) {
    const i = (start + k) % moves.length;
    if (!moves[i].disabled && (moves[i].pp === undefined || moves[i].pp > 0)) return `move ${i + 1}`;
  }
  return 'move 1';
}

export function runOne(sim, spec) {
  const { Battle, Teams, Dex } = sim;
  const record = { tags: {}, flags: [], other: [] };
  const result = { id: spec.id, snapshots: [], final: null, flags: record.flags, tags: record.tags, other: record.other, log: [], error: null };
  try {
    const prng = new OraclePRNG(spec, record);
    const battle = new Battle({ formatid: FORMAT, prng });
    prng.battle = battle;
    const order = [spec.p1.map((_, i) => `a${i + 1}`), spec.p2.map((_, i) => `b${i + 1}`)];
    battle.setPlayer('p1', { name: 'P1', team: Teams.pack(spec.p1.map((set, i) => setOf(Dex, set, i, 'a'))) });
    battle.setPlayer('p2', { name: 'P2', team: Teams.pack(spec.p2.map((set, i) => setOf(Dex, set, i, 'b'))) });
    let lastTurn = -1;
    let guard = 0;
    while (!battle.ended && guard++ < 2000) {
      if (battle.turn !== lastTurn) {
        lastTurn = battle.turn;
        if (battle.turn > MAX_TURNS) { record.flags.push({ flag: 'max_turns', turn: battle.turn }); break; }
        if (battle.turn > 0) result.snapshots.push(snapshot(battle, order));
      }
      let chose = false;
      for (let s = 0; s < 2; s++) {
        const side = battle.sides[s];
        const req = side.activeRequest;
        if (!req || req.wait || side.isChoiceDone()) continue;
        const choice = decide(spec, battle, side, s, order);
        if (!battle.choose(side.id, choice)) throw new Error(`Showdown rechaza "${choice}" (turno ${battle.turn}): ${side.choice.error}`);
        chose = true;
        if (battle.ended) break;
      }
      if (!chose && !battle.ended) throw new Error(`Showdown no pide ninguna decisión (turno ${battle.turn}).`);
    }
    result.final = snapshot(battle, order);
    result.winner = battle.winner || '';
    // Con |split| Showdown escribe cada línea dos veces (privada y pública): se deja una.
    result.log = battle.log
      .filter((line) => !/^\|(t:|j|player|gametype|gen|tier|rule|split|teamsize|clearpoke|poke|teampreview|start|raw|$)/.test(line))
      .filter((line, i, all) => line !== all[i - 1]);
  } catch (err) {
    result.error = String(err && err.stack || err);
  }
  return result;
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const [specsPath, outPath] = process.argv.slice(2);
  if (!specsPath || !outPath) {
    console.error('Uso: node tools/showdown_diff/run_showdown.mjs <specs.json> <salida.json>');
    process.exit(2);
  }
  const sim = loadShowdown();
  const specs = JSON.parse(fs.readFileSync(specsPath, 'utf8'));
  const results = specs.map((spec) => runOne(sim, spec));
  fs.writeFileSync(outPath, JSON.stringify(results));
  const errors = results.filter((r) => r.error).length;
  console.log(`Showdown: ${results.length} combates, ${errors} con error.`);
}
