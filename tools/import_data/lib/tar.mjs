import { gunzipSync } from 'node:zlib';

// Lector mínimo de .tar.gz (formato ustar, el que usa npm). Devuelve los archivos normales.
export function* tarEntries(tgz) {
  const buf = gunzipSync(tgz);
  let off = 0;
  let longName = null;
  while (off + 512 <= buf.length) {
    const header = buf.subarray(off, off + 512);
    if (header.every((b) => b === 0)) break;
    const str = (start, len) => header.subarray(start, start + len).toString('utf8').replace(/\0[\s\S]*$/, '');
    let name = str(0, 100);
    const prefix = str(345, 155);
    if (prefix) name = `${prefix}/${name}`;
    const size = parseInt(str(124, 12).trim() || '0', 8);
    const type = header[156] === 0 ? '0' : String.fromCharCode(header[156]);
    off += 512;
    const data = buf.subarray(off, off + size);
    off += Math.ceil(size / 512) * 512;
    if (type === 'L') { longName = data.toString('utf8').replace(/\0[\s\S]*$/, ''); continue; }
    if (type !== '0') continue;
    if (longName) { name = longName; longName = null; }
    yield { name, data };
  }
}
