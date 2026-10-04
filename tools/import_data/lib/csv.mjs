// Parser CSV (RFC 4180): comillas, comillas dobles escapadas y saltos de línea dentro de campos.
export function parseCSV(text) {
  const rows = [];
  let row = [];
  let i = text.charCodeAt(0) === 0xfeff ? 1 : 0;
  const n = text.length;
  while (i < n) {
    let field;
    if (text[i] === '"') {
      let j = i + 1;
      let parts = '';
      for (;;) {
        const q = text.indexOf('"', j);
        if (q === -1) throw new Error('CSV mal formado: comillas sin cerrar');
        parts += text.slice(j, q);
        if (text[q + 1] === '"') { parts += '"'; j = q + 2; continue; }
        i = q + 1;
        break;
      }
      field = parts;
    } else {
      let j = i;
      while (j < n && text[j] !== ',' && text[j] !== '\n' && text[j] !== '\r') j++;
      field = text.slice(i, j);
      i = j;
    }
    row.push(field);
    if (text[i] === ',') { i++; continue; }
    if (text[i] === '\r') i++;
    if (text[i] === '\n') i++;
    rows.push(row);
    row = [];
  }
  if (row.length) rows.push(row);
  const [header, ...data] = rows;
  return data
    .filter((r) => !(r.length === 1 && r[0] === ''))
    .map((r) => Object.fromEntries(header.map((h, k) => [h, r[k] ?? ''])));
}
