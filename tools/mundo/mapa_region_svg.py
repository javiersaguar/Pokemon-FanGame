#!/usr/bin/env python3
"""Esquema del mapa de la región (documentación, no es arte del juego).

Lee data/region.json y escribe docs/mundo/mapa_region.svg: la costa de la
península y las islas aproximada con puntos reales (latitud y longitud), la
rejilla del mapa regional, las rutas y las ciudades.

Uso: python3 tools/mundo/mapa_region_svg.py
"""
import json
import os

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
CELL = 24

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


def to_grid(lat: float, lon: float) -> tuple[float, float]:
    return (lon + 9.5) * 2.4, (44.0 - lat) * 3.0


def px(cell: tuple[float, float]) -> tuple[float, float]:
    return cell[0] * CELL + CELL / 2, cell[1] * CELL + CELL / 2


def poly(points: list, fill: str, stroke: str = "#4d6b3c") -> str:
    coords = " ".join("%.1f,%.1f" % px(to_grid(*p)) for p in points)
    return '<polygon points="%s" fill="%s" stroke="%s" stroke-width="1.5"/>' % (coords, fill, stroke)


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
    # Recuadro de Canarias.
    ix, iy, iw, ih = region["inset"]["rect"]
    out.append('<rect x="%d" y="%d" width="%d" height="%d" fill="#bfe3f2" stroke="#555" stroke-width="1.5"/>'
               % (ix * CELL, iy * CELL, iw * CELL, ih * CELL))
    out.append('<ellipse cx="%.1f" cy="%.1f" rx="%.1f" ry="%.1f" fill="#e9e2b8" stroke="#4d6b3c" stroke-width="1.5"/>'
               % (3.5 * CELL, 24.0 * CELL, 1.1 * CELL, 1.0 * CELL))
    out.append('<text x="%d" y="%d" font-size="11" fill="#333">%s</text>'
               % (ix * CELL + 4, iy * CELL + 12, region["inset"]["label"]))
    # Rejilla.
    for x in range(w + 1):
        out.append('<line x1="%d" y1="0" x2="%d" y2="%d" stroke="#ffffff" stroke-opacity="0.35"/>' % (x * CELL, x * CELL, h * CELL))
    for y in range(h + 1):
        out.append('<line x1="0" y1="%d" x2="%d" y2="%d" stroke="#ffffff" stroke-opacity="0.35"/>' % (y * CELL, w * CELL, y * CELL))
    # Rutas.
    for rid, r in region["routes"].items():
        kind = r.get("kind", "route")
        pts = " ".join("%.1f,%.1f" % px(tuple(c)) for c in r["cells"])
        if len(r["cells"]) < 2:
            continue
        dash = ' stroke-dasharray="%s"' % DASH[kind] if DASH[kind] else ""
        out.append('<polyline points="%s" fill="none" stroke="%s" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"%s/>'
                   % (pts, COLORS[kind], dash))
    # Ciudades y pueblos.
    for lid, loc in region["locations"].items():
        cx, cy = px(tuple(loc["cell"]))
        gym = loc.get("gym")
        fill = "#d63031" if gym else ("#2e8b57" if loc["kind"] == "town" else "#e67e22")
        out.append('<rect x="%.1f" y="%.1f" width="16" height="16" rx="3" fill="%s" stroke="#222" stroke-width="1.5"/>'
                   % (cx - 8, cy - 8, fill))
        if gym:
            out.append('<text x="%.1f" y="%.1f" font-size="11" font-weight="bold" text-anchor="middle" fill="#fff">%d</text>'
                       % (cx, cy + 4, gym["order"]))
        if "league" in loc:
            out.append('<text x="%.1f" y="%.1f" font-size="12" text-anchor="middle">👑</text>' % (cx + 14, cy - 6))
        out.append('<text x="%.1f" y="%.1f" font-size="11" font-weight="bold" fill="#111" stroke="#fff" stroke-width="3" paint-order="stroke">%s</text>'
                   % (cx + 10, cy + 18, loc["name"]))
    # Leyenda.
    lx, ly = 21 * CELL, 21 * CELL
    out.append('<rect x="%d" y="%d" width="%d" height="%d" fill="#ffffff" fill-opacity="0.85" stroke="#555"/>'
               % (lx, ly, 10 * CELL + 12, 4.6 * CELL))
    items = [("route", "Ruta"), ("ferry", "Ferry"), ("surf", "Surf"), ("plane", "Avión"), ("train", "Tren")]
    for i, (kind, label) in enumerate(items):
        y = ly + 16 + i * 18
        dash = ' stroke-dasharray="%s"' % DASH[kind] if DASH[kind] else ""
        out.append('<line x1="%d" y1="%d" x2="%d" y2="%d" stroke="%s" stroke-width="4"%s/>' % (lx + 8, y, lx + 48, y, COLORS[kind], dash))
        out.append('<text x="%d" y="%d" font-size="11">%s</text>' % (lx + 54, y + 4, label))
    for i, (fill, label) in enumerate([("#d63031", "Gimnasio (orden)"), ("#e67e22", "Ciudad"), ("#2e8b57", "Pueblo")]):
        y = ly + 16 + i * 18
        out.append('<rect x="%d" y="%d" width="12" height="12" fill="%s" stroke="#222"/>' % (lx + 130, y - 6, fill))
        out.append('<text x="%d" y="%d" font-size="11">%s</text>' % (lx + 148, y + 4, label))
    out.append('<text x="%d" y="%d" font-size="11">👑 Liga (Palacio Real)</text>' % (lx + 130, ly + 16 + 3 * 18 + 4))
    out.append("</svg>")
    path = os.path.join(ROOT, "docs", "mundo", "mapa_region.svg")
    with open(path, "w", encoding="utf-8") as f:
        f.write("\n".join(out) + "\n")
    print(path)


if __name__ == "__main__":
    main()
