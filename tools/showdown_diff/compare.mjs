// Compara turno a turno los resultados de Showdown y de nuestro motor.
//   node tools/showdown_diff/compare.mjs <specs.json> <showdown.json> <nuestro.json> [--report=<md>] [--json=<json>]
// Un combate "coincide" si todas las fotos (PS, estado, quién está en el campo, cambios de
// características y clima) son iguales hasta el final. Si hay un empate de velocidad (Showdown lo
// resuelve con su propio azar), solo se comparan los turnos anteriores.

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

function sameBoosts(a = {}, b = {}) {
  const keys = new Set([...Object.keys(a), ...Object.keys(b)]);
  for (const k of keys) if ((a[k] || 0) !== (b[k] || 0)) return false;
  return true;
}

/** Diferencias entre dos fotos ("" si son iguales). */
export function diffSnapshots(sd, ours) {
  const out = [];
  if ((sd.weather || '') !== (ours.weather || '')) out.push(`clima: Showdown "${sd.weather}" / nuestro "${ours.weather}"`);
  for (let s = 0; s < 2; s++) {
    for (let i = 0; i < sd.sides[s].length; i++) {
      const a = sd.sides[s][i];
      const b = ours.sides[s][i];
      const who = `${s === 0 ? 'P1' : 'P2'} #${i + 1}`;
      if (!b) { out.push(`${who}: falta en nuestro motor`); continue; }
      if (a.hp !== b.hp) out.push(`${who} PS: Showdown ${a.hp} / nuestro ${b.hp}`);
      if (a.status !== b.status) out.push(`${who} estado: Showdown "${a.status}" / nuestro "${b.status}"`);
      if (a.active !== b.active) out.push(`${who} en el campo: Showdown ${a.active} / nuestro ${b.active}`);
      if (a.active && b.active && !sameBoosts(a.boosts, b.boosts)) {
        out.push(`${who} cambios: Showdown ${JSON.stringify(a.boosts)} / nuestro ${JSON.stringify(b.boosts)}`);
      }
      if (a.active && b.active && a.speed !== undefined && b.speed !== undefined && a.speed !== b.speed) {
        out.push(`${who} velocidad: Showdown ${a.speed} / nuestro ${b.speed}`);
      }
    }
  }
  return out.join('; ');
}

function firstTie(result) {
  const ties = (result.flags || []).filter((f) => f.flag === 'speed_tie').map((f) => f.turn);
  return ties.length ? Math.min(...ties) : Infinity;
}

function turnLog(log, turn) {
  const out = [];
  let current = 0;
  for (const line of log || []) {
    const m = line.match(/^\|turn\|(\d+)/);
    if (m) { current = Number(m[1]); continue; }
    if (current === turn) out.push(line);
  }
  return out;
}

export function compare(specs, sdResults, ourResults) {
  const sdById = new Map(sdResults.map((r) => [r.id, r]));
  const ourById = new Map(ourResults.map((r) => [r.id, r]));
  const rows = [];
  for (const spec of specs) {
    const sd = sdById.get(spec.id);
    const ours = ourById.get(spec.id);
    const row = { id: spec.id, status: 'coincide', turn: null, detail: '', spec };
    if (!sd || !ours) { row.status = 'sin_resultado'; rows.push(row); continue; }
    if (sd.error) { row.status = 'error_showdown'; row.detail = sd.error.split('\n')[0]; rows.push(row); continue; }
    if (ours.error) { row.status = 'error_nuestro'; row.detail = ours.error; rows.push(row); continue; }
    const tie = Math.min(firstTie(sd), firstTie(ours));
    const n = Math.max(sd.snapshots.length, ours.snapshots.length);
    for (let k = 0; k < n; k++) {
      const a = sd.snapshots[k];
      const b = ours.snapshots[k];
      const turn = (a || b).turn;
      if (turn >= tie) { row.status = 'empate_velocidad'; row.turn = turn; break; }
      if (!a || !b) {
        row.status = 'difiere'; row.turn = turn;
        row.detail = !a ? 'Showdown terminó antes' : 'nuestro motor terminó antes';
        row.prev = k > 0 ? turn - 1 : 0;
        break;
      }
      const d = diffSnapshots(a, b);
      if (d) { row.status = 'difiere'; row.turn = turn; row.detail = d; row.prev = turn - 1; break; }
    }
    const capped = [...(sd.flags || []), ...(ours.flags || [])].some((f) => f.flag === 'max_turns');
    if (row.status === 'coincide' && capped) {
      // Al llegar al límite de turnos, cada motor para en un punto algo distinto: no se compara el final.
      row.status = 'limite_turnos';
    } else if (row.status === 'coincide') {
      const d = diffSnapshots(sd.final, ours.final);
      if (d && Math.max(sd.final.turn, ours.final.turn) < tie) {
        row.status = 'difiere'; row.turn = 'final'; row.detail = d; row.prev = sd.final.turn;
      }
    }
    if (row.status === 'difiere') {
      row.sdLog = turnLog(sd.log, row.prev);
      row.ourLog = turnLog(ours.log, row.prev);
      row.otherTags = sd.other.slice(0, 3);
    }
    rows.push(row);
  }
  return rows;
}

export function summary(rows) {
  const count = {};
  for (const r of rows) count[r.status] = (count[r.status] || 0) + 1;
  return count;
}

function setLine(set) {
  return `${set.species} Nv${set.level} [${set.ability}${set.item ? ', ' + set.item : ''}] ${set.moves.join('/')}`;
}

export function report(rows) {
  const count = summary(rows);
  const lines = ['# Comparación con Showdown (generado)', '', `Combates: ${rows.length}`, ''];
  for (const [k, v] of Object.entries(count)) lines.push(`- **${k}**: ${v}`);
  lines.push('');
  for (const r of rows.filter((x) => x.status !== 'coincide' && x.status !== 'empate_velocidad')) {
    lines.push(`## ${r.id}: ${r.status}${r.turn !== null ? ` en el turno ${r.turn}` : ''}`, '');
    lines.push(`- ${r.detail}`);
    lines.push(`- P1: ${r.spec.p1.map(setLine).join(' · ')}`);
    lines.push(`- P2: ${r.spec.p2.map(setLine).join(' · ')}`);
    if (r.spec.luck) lines.push(`- Suerte fijada: ${JSON.stringify(r.spec.luck)}`);
    if (r.sdLog) {
      lines.push('', `Turno ${r.prev} en Showdown:`, '```', ...r.sdLog.slice(0, 40), '```');
      lines.push(`Turno ${r.prev} en nuestro motor:`, '```', ...r.ourLog.slice(0, 40), '```');
    }
    if (r.otherTags && r.otherTags.length) lines.push(`- Azar sin etiqueta en Showdown: ${r.otherTags.join(' | ')}`);
    lines.push('');
  }
  return lines.join('\n');
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const [specsPath, sdPath, oursPath, ...rest] = process.argv.slice(2);
  const opts = Object.fromEntries(rest.map((a) => a.replace(/^--/, '').split('=')));
  const rows = compare(
    JSON.parse(fs.readFileSync(specsPath, 'utf8')),
    JSON.parse(fs.readFileSync(sdPath, 'utf8')),
    JSON.parse(fs.readFileSync(oursPath, 'utf8')),
  );
  if (opts.report) fs.writeFileSync(opts.report, report(rows));
  if (opts.json) fs.writeFileSync(opts.json, JSON.stringify(rows.map(({ spec, ...r }) => r), null, 1));
  console.log(JSON.stringify(summary(rows)));
}
