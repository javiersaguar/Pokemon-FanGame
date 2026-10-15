#!/usr/bin/env python3
"""Esquema del mapa de la región (base aprobada del mapa regional, decisiones del 2026-10-13 §1).

Lee data/region.json y escribe docs/mundo/mapa_region.svg: la costa de la península y las islas aproximada
con puntos reales (latitud y longitud), la rejilla del mapa regional, las rutas, los transportes, las
ciudades y pueblos, y dos recuadros: Canarias y Madrid y alrededores (pueblos iniciales, barrios y el sur
de Madrid). Los nombres se colocan donde no tapan otro nombre ni otro punto.

Lo usan el menú F9 (src/ui/playtest/playtest_world_map.gd) y el mapa regional del juego
(src/ui/region_map/region_map_screen.gd) como fondo; los puntos los dibuja cada pantalla encima.

Uso: python3 tools/mundo/mapa_region_svg.py
"""
import json
import os

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
CELL = 24
FONT = 11
CHAR_W = 6.1  # ancho medio de un carácter a 11 px (sans-serif), para no solapar nombres

# Costa aproximada (latitud, longitud), de Cap de Creus en el sentido de las agujas del reloj.
PENINSULA = [
    (42.32, 3.32), (41.38, 2.18), (41.10, 1.25), (40.70, 0.85), (39.98, -0.03), (39.45, -0.32),
    (38.73, 0.23), (38.34, -0.48), (37.63, -0.69), (37.58, -0.98), (36.72, -2.19), (36.83, -2.46),
    (36.72, -3.52), (36.71, -4.42), (36.50, -4.90), (36.13, -5.35), (36.01, -5.60), (36.53, -6.30),
    (37.20, -6.95), (37.20, -7.40), (37.00, -7.93), (37.02, -8.99), (37.95, -8.87), (38.70, -9.40),
    (39.36, -9.40), (40.64, -8.75), (41.15, -8.67), (42.20, -8.85), (42.88, -9.27), (43.37, -8.40),
    (43.79, -7.69), (43.54, -7.04), (43.66, -5.85), (43.55, -5.66), (43.47, -3.79), (43.35, -3.00),
    (43.32, -1.98), (43.37, -1.79), (43.00, -1.00), (42.70, 0.70), (42.50, 1.70), (42.43, 3.17),
]
# Frontera con Portugal (aproximada), de norte a sur.
PORTUGAL_BORDER = [(42.10, -8.20), (41.85, -6.55), (41.00, -6.90), (40.00, -7.00), (39.00, -7.30),
                   (38.20, -7.20), (37.20, -7.40)]
# Portugal (fuera de la región): su costa de norte a sur y la frontera de vuelta.
PORTUGAL = [(41.87, -8.87), (41.15, -8.67), (40.64, -8.75), (39.36, -9.40), (38.70, -9.40), (37.95, -8.87),
            (37.02, -8.99), (37.00, -7.93), (37.20, -7.40)] + list(reversed(PORTUGAL_BORDER))
MALLORCA = [(39.95, 3.20), (39.80, 2.35), (39.55, 2.35), (39.35, 2.80), (39.30, 3.25), (39.65, 3.48),
            (39.85, 3.15)]
MENORCA = [(40.05, 3.80), (39.88, 3.85), (39.82, 4.30), (40.00, 4.28)]
IBIZA = [(39.10, 1.45), (38.95, 1.20), (38.85, 1.40), (38.95, 1.60), (39.07, 1.60)]

COLORS = {"route": "#9b6b3f", "ferry": "#2f6fb5", "surf": "#21a0b5", "plane": "#7a4fb0", "train": "#c0392b"}
DASH = {"route": "", "ferry": "6 4", "surf": "2 4", "plane": "10 6", "train": "8 3 2 3"}


def to_grid(lat: float, lon: float) -> tuple:
    return (lon + 9.5) * 2.4, (44.0 - lat) * 3.0


def px(cell) -> tuple:
    return cell[0] * CELL + CELL / 2, cell[1] * CELL + CELL / 2


def poly(points: list, fill: str, stroke: str = "#4d6b3c") -> str:
    coords = " ".join("%.1f,%.1f" % px(to_grid(*p)) for p in points)
    return '<polygon points="%s" fill="%s" stroke="%s" stroke-width="1.5"/>' % (coords, fill, stroke)


def overlaps(a: tuple, b: tuple) -> bool:
    return a[0] < b[2] and b[0] < a[2] and a[1] < b[3] and b[1] < a[3]


class Labels:
    """Coloca cada nombre en el primer sitio libre alrededor de su punto (derecha, izquierda, abajo, arriba)."""

    def __init__(self, width: int, height: int) -> None:
        self.taken = []
        self.width, self.height = width, height

    def block(self, box: tuple) -> None:
        self.taken.append(box)

    def place(self, cx: float, cy: float, text: str, size: int = FONT, radius: float = 9) -> tuple:
        w = len(text) * CHAR_W * size / FONT
        h = size + 2
        candidates = [
            (cx + radius, cy + h / 2 - 2, "start"), (cx - radius - w, cy + h / 2 - 2, "start"),
            (cx - w / 2, cy + radius + h - 2, "start"), (cx - w / 2, cy - radius - 3, "start"),
            (cx + radius, cy + radius + h - 2, "start"), (cx - radius - w, cy + radius + h - 2, "start"),
            (cx + radius, cy - radius - 3, "start"), (cx - radius - w, cy - radius - 3, "start"),
            (cx - w / 2, cy + radius + 2 * h, "start"), (cx - w / 2, cy - radius - h - 3, "start"),
        ]
        best = candidates[0]
        for x, y, anchor in candidates:
            box = (x - 1, y - h + 2, x + w + 1, y + 3)
            if box[0] < 0 or box[2] > self.width or box[1] < 0 or box[3] > self.height:
                continue
            if not any(overlaps(box, other) for other in self.taken):
                best = (x, y, anchor)
                break
        x, y, anchor = best
        self.taken.append((x - 1, y - h + 2, x + len(text) * CHAR_W * size / FONT + 1, y + 3))
        return x, y


def main() -> None:
    with open(os.path.join(ROOT, "data", "region.json"), encoding="utf-8") as f:
        region = json.load(f)
    w, h = region["size"]
    out = ['<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" viewBox="0 0 %d %d" font-family="sans-serif">'
           % (w * CELL, h * CELL, w * CELL, h * CELL),
           '<rect width="100%" height="100%" fill="#bfe3f2"/>']
    out.append(poly(PENINSULA, "#e9e2b8"))
    # Portugal (fuera de la región): la parte de la península al oeste de la frontera.
    out.append(poly(PORTUGAL, "#d6d6d6", "#9a9a9a"))
    for island in (MALLORCA, MENORCA, IBIZA):
        out.append(poly(island, "#e9e2b8"))
    insets = region.get("insets", {"canarias": region["inset"]})
    labels = Labels(w * CELL, h * CELL)
    # Recuadros: Canarias (con la isla) y Madrid y alrededores (con su marco hasta Madrid).
    for key, inset in insets.items():
        ix, iy, iw, ih = inset["rect"]
        fill = "#bfe3f2" if key == "canarias" else "#f3edcf"
        out.append('<rect x="%d" y="%d" width="%d" height="%d" fill="%s" stroke="#555" stroke-width="1.5"/>'
                   % (ix * CELL, iy * CELL, iw * CELL, ih * CELL, fill))
        if key == "canarias":
            out.append('<ellipse cx="%.1f" cy="%.1f" rx="%.1f" ry="%.1f" fill="#e9e2b8" stroke="#4d6b3c" stroke-width="1.5"/>'
                       % (3.5 * CELL, 24.0 * CELL, 1.1 * CELL, 1.0 * CELL))
        out.append('<text x="%d" y="%d" font-size="11" fill="#333">%s</text>' % (ix * CELL + 4, iy * CELL + 12, inset["label"]))
        labels.block((ix * CELL, iy * CELL, ix * CELL + 8 + len(inset["label"]) * CHAR_W, iy * CELL + 16))
        if "anchor" in inset:
            ax, ay = px(inset["anchor"])
            out.append('<rect x="%.1f" y="%.1f" width="28" height="28" fill="none" stroke="#555" stroke-width="1" stroke-dasharray="3 2"/>'
                       % (ax - 14, ay - 14))
            out.append('<line x1="%.1f" y1="%.1f" x2="%d" y2="%d" stroke="#555" stroke-width="1" stroke-dasharray="3 2"/>'
                       % (ax + 14, ay - 14, ix * CELL, (iy + ih) * CELL))
    # Rejilla.
    for x in range(w + 1):
        out.append('<line x1="%d" y1="0" x2="%d" y2="%d" stroke="#ffffff" stroke-opacity="0.35"/>' % (x * CELL, x * CELL, h * CELL))
    for y in range(h + 1):
        out.append('<line x1="0" y1="%d" x2="%d" y2="%d" stroke="#ffffff" stroke-opacity="0.35"/>' % (y * CELL, w * CELL, y * CELL))
    # Rutas y transportes.
    for rid, r in region["routes"].items():
        kind = r.get("kind", "route")
        if len(r["cells"]) < 2:
            continue
        pts = " ".join("%.1f,%.1f" % px(c) for c in r["cells"])
        dash = ' stroke-dasharray="%s"' % DASH[kind] if DASH[kind] else ""
        width = 3 if r.get("inset") == "madrid" else 4
        out.append('<polyline points="%s" fill="none" stroke="%s" stroke-width="%d" stroke-linecap="round" stroke-linejoin="round"%s/>'
                   % (pts, COLORS[kind], width, dash))
    # Marcadores (se reservan antes de colocar los nombres).
    marks = []
    for lid, loc in region["locations"].items():
        cx, cy = px(loc["cell"])
        labels.block((cx - 9, cy - 9, cx + 9, cy + 9))
        marks.append((lid, loc, cx, cy, "location"))
    for did, dist in region.get("districts", {}).items():
        cx, cy = px(dist["cell"])
        labels.block((cx - 6, cy - 6, cx + 6, cy + 6))
        marks.append((did, dist, cx, cy, "district"))
    for lid, loc, cx, cy, what in marks:
        if what == "district":
            out.append('<circle cx="%.1f" cy="%.1f" r="5" fill="#f0b030" stroke="#222" stroke-width="1.2"/>' % (cx, cy))
            x, y = labels.place(cx, cy, loc["name"], 10, 7)
            out.append('<text x="%.1f" y="%.1f" font-size="10" fill="#111" stroke="#fff" stroke-width="3" paint-order="stroke">%s</text>'
                       % (x, y, loc["name"]))
            continue
        gym = loc.get("gym")
        start = lid in region.get("start", [])
        fill = "#d63031" if gym else ("#2e8b57" if loc["kind"] == "town" else "#e67e22")
        if start:
            fill = "#1f6fb5"
        out.append('<rect x="%.1f" y="%.1f" width="16" height="16" rx="3" fill="%s" stroke="#222" stroke-width="1.5"/>'
                   % (cx - 8, cy - 8, fill))
        if gym:
            out.append('<text x="%.1f" y="%.1f" font-size="11" font-weight="bold" text-anchor="middle" fill="#fff">%d</text>'
                       % (cx, cy + 4, gym["order"]))
        if start:
            out.append('<text x="%.1f" y="%.1f" font-size="11" font-weight="bold" text-anchor="middle" fill="#fff">★</text>' % (cx, cy + 4))
        if "league" in loc:
            out.append('<text x="%.1f" y="%.1f" font-size="12" text-anchor="middle">👑</text>' % (cx + 14, cy - 6))
        x, y = labels.place(cx, cy, loc["name"])
        out.append('<text x="%.1f" y="%.1f" font-size="11" font-weight="bold" fill="#111" stroke="#fff" stroke-width="3" paint-order="stroke">%s</text>'
                   % (x, y, loc["name"]))
    # Leyenda.
    lx, ly = 21 * CELL, 21 * CELL
    out.append('<rect x="%d" y="%d" width="%d" height="%d" fill="#ffffff" fill-opacity="0.85" stroke="#555"/>'
               % (lx, ly, 10 * CELL + 12, 4.6 * CELL))
    items = [("route", "Ruta"), ("ferry", "Ferry"), ("surf", "Surf"), ("plane", "Avión"), ("train", "Tren (AVE, C-5)")]
    for i, (kind, label) in enumerate(items):
        y = ly + 16 + i * 18
        dash = ' stroke-dasharray="%s"' % DASH[kind] if DASH[kind] else ""
        out.append('<line x1="%d" y1="%d" x2="%d" y2="%d" stroke="%s" stroke-width="4"%s/>' % (lx + 8, y, lx + 48, y, COLORS[kind], dash))
        out.append('<text x="%d" y="%d" font-size="11">%s</text>' % (lx + 54, y + 4, label))
    for i, (fill, label) in enumerate([("#d63031", "Gimnasio (orden)"), ("#e67e22", "Ciudad"), ("#2e8b57", "Pueblo"),
                                       ("#1f6fb5", "★ Pueblo inicial")]):
        y = ly + 16 + i * 18
        out.append('<rect x="%d" y="%d" width="12" height="12" fill="%s" stroke="#222"/>' % (lx + 140, y - 6, fill))
        out.append('<text x="%d" y="%d" font-size="11">%s</text>' % (lx + 158, y + 4, label))
    y = ly + 16 + 4 * 18
    out.append('<circle cx="%d" cy="%d" r="5" fill="#f0b030" stroke="#222"/>' % (lx + 146, y))
    out.append('<text x="%d" y="%d" font-size="11">Barrio · 👑 Liga</text>' % (lx + 158, y + 4))
    out.append("</svg>")
    path = os.path.join(ROOT, "docs", "mundo", "mapa_region.svg")
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(out) + "\n")
    print(path)


if __name__ == "__main__":
    main()
