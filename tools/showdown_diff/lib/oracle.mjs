// Oráculo del azar compartido por los dos motores (Showdown y el nuestro).
// La misma función está en run_ours.gd: si cambias una, cambia la otra.
//
// Cada tirada tiene una etiqueta (crit, accuracy, damage_roll...). El resultado depende solo de
// (semilla del combate, etiqueta, turno), así que los dos motores reciben la misma "suerte"
// aunque llamen al azar en distinto orden. Si spec.luck fija una etiqueta, se usa ese valor.

/** FNV-1a de 32 bits sobre los bytes UTF-8 del texto. */
export function fnv1a(text) {
  let h = 0x811c9dc5;
  for (const byte of new TextEncoder().encode(text)) {
    h ^= byte;
    h = Math.imul(h, 0x01000193) >>> 0;
  }
  return h >>> 0;
}

/** u en [0, 1) para la tirada `tag` del turno `turn`. */
export function oracleU(spec, tag, turn) {
  if (spec.luck && Object.prototype.hasOwnProperty.call(spec.luck, tag)) return spec.luck[tag];
  return fnv1a(`${spec.seed}|${tag}|${turn}`) / 4294967296;
}

/** Movimiento con el que se empieza a buscar uno usable (0..n-1). */
export function choiceStart(spec, side, turn, n) {
  return fnv1a(`${spec.seed}|choice|${side}|${turn}`) % n;
}

/** Etiquetas que entienden los dos motores. */
export const TAGS = [
  'accuracy', 'crit', 'damage_roll', 'secondary', 'multihit', 'par', 'frz_thaw', 'slp_turns',
  'confusion_turns', 'confusion_hit', 'attract', 'partiallytrapped_turns', 'lockedmove_turns',
  'protect', 'shedskin', 'force_switch',
];
