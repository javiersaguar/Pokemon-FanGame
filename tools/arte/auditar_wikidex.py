#!/usr/bin/env python3
"""Contrasta identificadores, sin importar descripciones ni modificar datos generados."""
import argparse
import sys
sys.dont_write_bytecode = True
import csv
from datetime import date
from html.parser import HTMLParser
import json
from pathlib import Path
import re
import urllib.request

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "docs/arte/cobertura_combate"
SOURCES = {"moves": "https://www.wikidex.net/wiki/Lista_de_movimientos",
           "abilities": "https://www.wikidex.net/wiki/Lista_de_habilidades"}
VARIANTS = {263: "dragonsmaw", 266: "asoneglastrier", 267: "asonespectrier", 301: "embodyaspectteal",
            302: "embodyaspectwellspring", 303: "embodyaspecthearthflame", 304: "embodyaspectcornerstone"}

def to_id(name):
    return re.sub(r"[^a-z0-9]", "", name.lower())

class Tables(HTMLParser):
    """Expande rowspan: Z físico/especial y nombres de variantes comparten celdas."""
    def __init__(self):
        super().__init__()
        self.tables = []
        self.depth = 0
        self.cell = None
        self.sup = 0

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == "table":
            self.depth += 1
            if self.depth == 1:
                self.rows, self.spans = [], {}
        if self.depth != 1:
            return
        if tag == "tr":
            self.cells = []
        elif tag in ("td", "th"):
            self.cell = []
            self.rowspan = int(attrs.get("rowspan", 1))
        elif tag == "sup":
            self.sup += 1
        elif tag == "br" and self.cell is not None:
            self.cell.append("|")

    def handle_data(self, data):
        if self.cell is not None and not self.sup:
            self.cell.append(data)

    def handle_endtag(self, tag):
        if self.depth == 1:
            if tag == "sup":
                self.sup = max(0, self.sup - 1)
            elif tag in ("td", "th") and self.cell is not None:
                self.cells.append((" ".join("".join(self.cell).split()), self.rowspan))
                self.cell = None
            elif tag == "tr":
                row, col = [], 0
                pending = dict(self.spans)
                self.spans = {}
                for value, span in self.cells:
                    while col in pending:
                        text, left = pending.pop(col)
                        row.append(text)
                        if left > 1:
                            self.spans[col] = (text, left - 1)
                        col += 1
                    row.append(value)
                    if span > 1:
                        self.spans[col] = (value, span - 1)
                    col += 1
                while col in pending:
                    text, left = pending.pop(col)
                    row.append(text)
                    if left > 1:
                        self.spans[col] = (text, left - 1)
                    col += 1
                self.rows.append(row)
        if tag == "table":
            if self.depth == 1:
                self.tables.append(self.rows)
            self.depth -= 1

def extract(kind, html):
    parser = Tables()
    parser.feed(html)
    entries = {}
    for table in parser.tables:
        if not table or not table[0] or table[0][0] != "#":
            continue
        header = table[0]
        if kind == "moves" and header[1:3] == ["Nombre", "Gen"]:
            for row in table[1:]:
                es, en = row[1].split("|", 1)
                ident = to_id(en)
                if not ident:
                    raise ValueError("Movimiento sin nombre: cambio de formato de WikiDex")
                entry = entries.setdefault(ident, {"id": ident, "name_en": en, "name_es": es, "indices": []})
                # Los Gigamax tienen ordinal propio; Showdown les asigna 1000 a todos.
                index = "gigamax:" + row[0].strip("|") if "Precisión" not in header else int(row[0].strip("|"))
                if index not in entry["indices"]:
                    entry["indices"].append(index)
        elif kind == "abilities" and header[1] == "Nombre (ES)":
            for row in table[1:]:
                if row[1] == "—":
                    continue
                index = int(row[0]) if row[0].isdigit() else None
                ident = VARIANTS.get(index, to_id(row[3]))
                entries[ident] = {"id": ident, "index": index, "name_en": row[3], "name_es": row[1],
                                  "unused": index is None}
    if len(entries) < (900 if kind == "moves" else 300):
        raise ValueError("Tabla incompleta o formato cambiado; no sustituir la referencia")
    return sorted(entries.values(), key=lambda row: row["id"])

def refresh():
    snapshot = {"checked_on": str(date.today()), "sources": SOURCES,
                "scope": "Tablas de las dos listas; nombres e índices, sin descripciones."}
    for kind, url in SOURCES.items():
        req = urllib.request.Request(url, headers={"User-Agent": "PokemonSpain-catalog-audit/1.0"})
        with urllib.request.urlopen(req, timeout=30) as response:
            snapshot[kind] = extract(kind, response.read().decode("utf-8"))
    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / "wikidex_referencia.json").write_text(json.dumps(snapshot, ensure_ascii=False, indent=2) + "\n")

def report():
    snapshot = json.loads((OUT / "wikidex_referencia.json").read_text())
    result = {"reference_date": snapshot["checked_on"], "sources": snapshot["sources"]}
    motion = json.loads((ROOT / "data/battle_motion_moves.json").read_text())
    for kind in SOURCES:
        local = json.loads((ROOT / f"data/generated/{kind}.json").read_text())
        entries = [row for row in snapshot[kind] if not row.get("unused")]
        entries.sort(key=lambda row: (row.get("index", 1000) if kind == "abilities" else (row["indices"][0] if isinstance(row["indices"][0], int) else 1000), row["id"]))
        missing, indices, names, rows = [], [], [], []
        for row in entries:
            ident = row["id"]
            data = local.get(ident)
            if data is None:
                missing.append(row)
            elif kind == "abilities" and data["num"] != row["index"]:
                indices.append({"id": ident, "local": data["num"], "wikidex": row["index"]})
            # Solo detecta fallback al inglés; nombres regionales válidos no son errores.
            pending_name = data is not None and data["name"] == data["name_en"] and data["name"] not in row["name_es"].split("/")
            if pending_name:
                names.append({"id": ident, "local": data["name"], "wikidex": row["name_es"]})
            rows.append([ident, str(row.get("index", "")) if kind == "abilities" else " / ".join(map(str, row["indices"])), row["name_es"], str(data is not None), str(pending_name),
                         str(ident in motion) if kind == "moves" else ""])
        result[kind] = {"reference_entries": len(entries), "local_entries": len(local),
                        "missing": missing, "index_differences": indices, "english_fallback": names,
                        "local_variants_outside_reference": sorted(set(local) - {row["id"] for row in entries}),
                        "unused_reference": [row for row in snapshot[kind] if row.get("unused")]}
        with (OUT / f"wikidex_{kind}.csv").open("w", newline="") as file:
            writer = csv.writer(file, lineterminator="\n")
            writer.writerow(["id", "indice_referencia", "nombre_referencia", "catalogado", "nombre_por_completar", "animacion_propia"])
            writer.writerows(rows)
    (OUT / "wikidex_estado.json").write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n")
    for kind in SOURCES:
        section = result[kind]
        print(f"{kind}: referencia={section['reference_entries']}, catálogo={section['local_entries']}, ausencias={len(section['missing'])}, índices={len(section['index_differences'])}, nombres={len(section['english_fallback'])}")
    return result

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--actualizar", action="store_true", help="Descargar las tablas antes de contrastar")
    args = parser.parse_args()
    if args.actualizar:
        refresh()
    report()
