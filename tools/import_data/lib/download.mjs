import { createHash } from 'node:crypto';
import { readFile, stat } from 'node:fs/promises';
import { writeAtomic } from './util.mjs';

const exists = (p) => stat(p).then(() => true, () => false);

function checkIntegrity(buf, integrity, what) {
  const [algo, expected] = integrity.split('-', 2);
  const actual = createHash(algo).update(buf).digest('base64');
  if (actual !== expected) throw new Error(`Integridad incorrecta en ${what}: esperado ${integrity}, obtenido ${algo}-${actual}`);
}

// Descarga `url` a `dest` (caché). Si ya está en caché no vuelve a descargar.
export async function fetchCached(url, dest, { offline = false, integrity } = {}) {
  let buf;
  if (await exists(dest)) {
    buf = await readFile(dest);
  } else {
    if (offline) throw new Error(`Modo sin conexión y falta en la caché: ${dest}`);
    const res = await fetch(url);
    if (!res.ok) throw new Error(`HTTP ${res.status} al descargar ${url}`);
    buf = Buffer.from(await res.arrayBuffer());
    if (integrity) checkIntegrity(buf, integrity, url);
    await writeAtomic(dest, buf);
  }
  if (integrity) checkIntegrity(buf, integrity, dest);
  return buf;
}

// Ejecuta `fn` sobre `items` con un máximo de `limit` tareas a la vez.
export async function mapLimit(items, limit, fn) {
  const results = new Array(items.length);
  let next = 0;
  const worker = async () => {
    while (next < items.length) {
      const i = next++;
      results[i] = await fn(items[i], i);
    }
  };
  await Promise.all(Array.from({ length: Math.min(limit, items.length) }, worker));
  return results;
}
