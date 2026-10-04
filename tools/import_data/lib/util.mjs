import { mkdir, writeFile, rename } from 'node:fs/promises';
import path from 'node:path';

// Mismo criterio que Showdown: minúsculas y solo [a-z0-9].
export const toID = (s) => String(s ?? '').toLowerCase().replace(/[^a-z0-9]+/g, '');

// "allAdjacentFoes" -> "all_adjacent_foes", "Human-Like" -> "human_like", "Water 1" -> "water_1".
export const snake = (s) => String(s)
  .replace(/([a-z0-9])([A-Z])/g, '$1_$2')
  .toLowerCase()
  .replace(/[^a-z0-9]+/g, '_')
  .replace(/^_+|_+$/g, '');

// Limpia los textos de PokeAPI: saltos de línea del juego, guiones blandos y espacios repetidos.
export const cleanText = (s) => String(s ?? '')
  .replace(/\u00ad[\n\f\r]+/g, '')
  .replace(/[\n\f\r\t]+/g, ' ')
  .replace(/\s+/g, ' ')
  .trim();

export const isFn = (v) => typeof v === 'function';
export const isPlainObject = (v) => v !== null && typeof v === 'object' && !Array.isArray(v);

// Lista de callbacks (funciones) de un objeto de Showdown, incluidos los anidados: "onHit", "condition.onStart"...
export function callbacks(obj, prefix = '') {
  const out = [];
  for (const [k, v] of Object.entries(obj ?? {})) {
    if (isFn(v)) out.push(prefix + k);
    else if (isPlainObject(v)) out.push(...callbacks(v, `${prefix}${k}.`));
    else if (Array.isArray(v)) v.forEach((e, i) => isPlainObject(e) && out.push(...callbacks(e, `${prefix}${k}[${i}].`)));
  }
  return out;
}

// Quita claves con undefined para que el JSON solo tenga lo que existe.
export const compact = (o) => Object.fromEntries(Object.entries(o).filter(([, v]) => v !== undefined));

export const boostsToSnake = (b) => b ? Object.fromEntries(Object.entries(b).map(([k, v]) => [snake(k), v])) : undefined;

// JSON con una entrada por línea: diffs legibles en git y archivos compactos.
export function serialize(obj) {
  const keys = Object.keys(obj);
  if (!keys.length) return '{}\n';
  return '{\n' + keys.map((k, i) => `${JSON.stringify(k)}: ${JSON.stringify(obj[k])}${i < keys.length - 1 ? ',' : ''}`).join('\n') + '\n}\n';
}

export async function writeAtomic(file, text) {
  await mkdir(path.dirname(file), { recursive: true });
  await writeFile(file + '.tmp', text, 'utf8');
  await rename(file + '.tmp', file);
}
