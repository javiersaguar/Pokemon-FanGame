#!/usr/bin/env python3
"""Plano real de una zona a partir de OpenStreetMap, como referencia para pintar
sus mapas (documentación, no es arte del juego).

Descarga de la API de Overpass las calles, edificios, agua, parques, vías de tren
y lugares con nombre de un rectángulo, y escribe docs/mundo/planos/<id>.svg con:
- el plano (norte arriba),
- la cuadrícula de casillas del juego encima (--metros-casilla: cuántos metros
  reales mide una casilla; una cada 10 casillas lleva número),
- los nombres de monumentos, plazas, iglesias, estadios, museos...

Los datos son de OpenStreetMap (© colaboradores de OpenStreetMap, licencia ODbL):
el SVG lleva la atribución. La respuesta se guarda en tools/cache/osm/<id>.json
(no se sube) para no volver a pedirla.

Uso:
  python3 tools/mundo/osm_plano.py <id> <lat> <lon> <ancho_m> <alto_m> [--metros-casilla=8] [--sin-edificios]
"""
import json
import math
import os
import sys
import time
import urllib.parse
import urllib.request

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
CACHE = os.path.join(ROOT, "tools", "cache", "osm")
OUT = os.path.join(ROOT, "docs", "mundo", "planos")
ENDPOINTS = ["https://overpass-api.de/api/interpreter", "https://overpass.kumi.systems/api/interpreter",
             "https://lz4.overpass-api.de/api/interpreter"]
AGENT = "PokemonSpainFangame-docs/1.0 (proyecto personal sin animo de lucro)"
PX_PER_M = 0.5  # escala del SVG

ROAD_WIDTH = {"motorway": 14, "trunk": 12, "primary": 10, "secondary": 8, "tertiary": 7,
              "residential": 5, "unclassified": 5, "living_street": 4, "pedestrian": 5,
              "service": 3, "footway": 2, "path": 1.5, "track": 2, "cycleway": 1.5, "steps": 2}
LABEL_KEYS = ("tourism", "historic", "amenity", "leisure", "building", "place", "shop", "railway", "man_made")
LABEL_AMENITY = {"place_of_worship", "townhall", "theatre", "marketplace", "university", "hospital",
                 "fountain", "arts_centre", "cinema", "library", "bus_station", "ferry_terminal", "casino",
                 "nightclub", "events_venue", "grave_yard", "police", "post_office"}


def query(bbox: tuple, buildings: bool) -> str:
    s, w, n, e = bbox
    b = "(%f,%f,%f,%f)" % (s, w, n, e)
    parts = [
        'way["highway"]%s;' % b,
        'way["waterway"]%s;' % b,
        'way["natural"~"water|coastline|beach|sand|wood|scrub|cliff|bare_rock"]%s;' % b,
        'relation["natural"="water"]%s;' % b,
        'way["leisure"~"park|garden|stadium|pitch|marina|playground|sports_centre"]%s;' % b,
        'way["landuse"~"grass|forest|meadow|recreation_ground|cemetery|farmland|orchard|vineyard|industrial|railway|construction"]%s;' % b,
        'way["railway"~"rail|subway|tram|light_rail|platform"]%s;' % b,
        'way["man_made"~"pier|breakwater|bridge|tower|lighthouse"]%s;' % b,
        'way["amenity"]%s;' % b,
        'way["tourism"]%s;' % b,
        'way["historic"]%s;' % b,
        'node["tourism"]%s;' % b,
        'node["historic"]%s;' % b,
        'node["amenity"~"place_of_worship|townhall|theatre|fountain|marketplace|nightclub|arts_centre|casino"]%s;' % b,
        'node["shop"~"supermarket|tobacco"]%s;' % b,
        'node["leisure"~"fitness_centre|stadium"]%s;' % b,
        'way["leisure"="fitness_centre"]%s;' % b,
        'node["place"~"square|neighbourhood|quarter|locality|suburb"]%s;' % b,
        'way["place"="square"]%s;' % b,
    ]
    if buildings:
        parts.append('way["building"]%s;' % b)
    return "[out:json][timeout:180];(" + "".join(parts) + ");out geom tags;"


def fetch(pid: str, bbox: tuple, buildings: bool) -> dict:
    os.makedirs(CACHE, exist_ok=True)
    path = os.path.join(CACHE, pid + ".json")
    if os.path.exists(path):
        with open(path, encoding="utf-8") as f:
            return json.load(f)
    data = urllib.parse.urlencode({"data": query(bbox, buildings)}).encode()
    last = ""
    for attempt in range(6):
        url = ENDPOINTS[attempt % len(ENDPOINTS)]
        try:
            req = urllib.request.Request(url, data=data, headers={"User-Agent": AGENT})
            with urllib.request.urlopen(req, timeout=240) as resp:
                text = resp.read().decode("utf-8")
            result = json.loads(text)
            with open(path, "w", encoding="utf-8") as f:
                json.dump(result, f)
            return result
        except Exception as exc:  # servidor ocupado: se reintenta con otro
            last = str(exc)
            time.sleep(10 + 10 * attempt)
    raise SystemExit("No se pudo descargar %s: %s" % (pid, last))


def main() -> None:
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    opts = dict(a[2:].split("=", 1) if "=" in a else (a[2:], "1") for a in sys.argv[1:] if a.startswith("--"))
    if len(args) != 5:
        raise SystemExit(__doc__)
    pid, lat0, lon0, width_m, height_m = args[0], float(args[1]), float(args[2]), float(args[3]), float(args[4])
    tile_m = float(opts.get("metros-casilla", "8"))
    buildings = "sin-edificios" not in opts
    m_lat = 110540.0
    m_lon = 111320.0 * math.cos(math.radians(lat0))
    bbox = (lat0 - height_m / 2 / m_lat, lon0 - width_m / 2 / m_lon, lat0 + height_m / 2 / m_lat, lon0 + width_m / 2 / m_lon)
    data = fetch(pid, bbox, buildings)

    def xy(lat: float, lon: float) -> tuple:
        return ((lon - bbox[1]) * m_lon * PX_PER_M, (bbox[2] - lat) * m_lat * PX_PER_M)

    w_px, h_px = width_m * PX_PER_M, height_m * PX_PER_M
    tol = max(0.6, tile_m * PX_PER_M / 6)
    minor = {"footway", "path", "steps", "cycleway", "track", "service", "bridleway", "corridor"}
    skip_minor = tile_m >= 20

    def pts_of(geom: list) -> str:
        return fmt(simplify([xy(p["lat"], p["lon"]) for p in geom], tol))
    layers = {k: [] for k in ("land", "water", "rail", "building", "road", "label")}
    labels = []
    for el in data.get("elements", []):
        tags = el.get("tags", {})
        geom = el.get("geometry")
        if el["type"] == "relation" and el.get("members"):
            for m in el["members"]:
                if m.get("role") == "outer" and m.get("geometry"):
                    pts = pts_of(m["geometry"])
                    layers["water"].append('<polyline points="%s" fill="#9fd3ec" stroke="#5aa9d0"/>' % pts)
            continue
        if geom:
            if skip_minor and tags.get("highway") in minor:
                continue
            if skip_minor and tags.get("landuse") == "farmland":
                continue
            if skip_minor and tags.get("amenity") and not tags.get("name") and "building" not in tags:
                continue
            pts = pts_of(geom)
            closed = len(geom) > 2 and geom[0] == geom[-1]
            hw = tags.get("highway")
            if "waterway" in tags and tags.get("tunnel") in ("yes", "culvert", "flooded"):
                continue
            if "waterway" in tags:
                wdt = 10 if tags["waterway"] in ("river", "canal") else 3
                layers["water"].append('<polyline points="%s" fill="none" stroke="#5aa9d0" stroke-width="%d"/>' % (pts, wdt))
            elif tags.get("natural") in ("water",) or tags.get("leisure") == "marina":
                layers["water"].append('<polygon points="%s" fill="#9fd3ec" stroke="#5aa9d0"/>' % pts)
            elif tags.get("natural") == "coastline":
                layers["water"].append('<polyline points="%s" fill="none" stroke="#2f78a8" stroke-width="3"/>' % pts)
            elif tags.get("natural") in ("beach", "sand"):
                layers["land"].append('<polygon points="%s" fill="#f3e3a6"/>' % pts)
            elif tags.get("leisure") in ("park", "garden", "playground") or tags.get("landuse") in ("grass", "meadow", "recreation_ground", "forest", "orchard", "vineyard") or tags.get("natural") in ("wood", "scrub"):
                layers["land"].append('<polygon points="%s" fill="#bfe3a5" stroke="#9ccc7f"/>' % pts)
            elif tags.get("leisure") in ("stadium", "pitch", "sports_centre"):
                layers["land"].append('<polygon points="%s" fill="#8fd18a" stroke="#4e9a4a"/>' % pts)
            elif tags.get("landuse") == "cemetery" or tags.get("amenity") == "grave_yard":
                layers["land"].append('<polygon points="%s" fill="#cfe0c8" stroke="#8aa87e"/>' % pts)
            elif tags.get("landuse") in ("industrial", "railway", "construction"):
                layers["land"].append('<polygon points="%s" fill="#e3d8e8"/>' % pts)
            elif tags.get("landuse") == "farmland":
                layers["land"].append('<polygon points="%s" fill="#f2efd5"/>' % pts)
            elif "railway" in tags:
                layers["rail"].append('<polyline points="%s" fill="none" stroke="#666" stroke-width="3" stroke-dasharray="8 5"/>' % pts)
            elif hw:
                width = ROAD_WIDTH.get(hw, 3)
                color = "#ffffff" if width >= 4 else "#f7f2e8"
                if hw in ("pedestrian",) or tags.get("area") == "yes":
                    if closed:
                        layers["road"].append('<polygon points="%s" fill="#efe7da" stroke="#cdbfa8"/>' % pts)
                        continue
                if not skip_minor:
                    layers["road"].append('<polyline points="%s" fill="none" stroke="#b9ad98" stroke-width="%.1f" stroke-linecap="round" stroke-linejoin="round"/>' % (pts, width + 1.5))
                else:
                    color = "#ffffff" if width >= 7 else "#fbf8f1"
                layers["road"].append('<polyline points="%s" fill="none" stroke="%s" stroke-width="%.1f" stroke-linecap="round" stroke-linejoin="round"/>' % (pts, color, width))
            elif "building" in tags or tags.get("man_made") in ("pier", "breakwater", "tower", "lighthouse"):
                fill = "#c9b8a8" if tags.get("amenity") == "place_of_worship" or tags.get("historic") else "#d9d0c9"
                layers["building"].append('<polygon points="%s" fill="%s" stroke="#b3a69b" stroke-width="0.6"/>' % (pts, fill))
            elif closed and (tags.get("amenity") or tags.get("tourism") or tags.get("historic")):
                layers["land"].append('<polygon points="%s" fill="#f1e0d0" stroke="#d0b8a0"/>' % pts)
        name = tags.get("name")
        if name and any(k in tags for k in LABEL_KEYS) and "highway" not in tags:
            kind = local_kind(tags)
            detail = tile_m <= 12 and (tags.get("tourism") not in SKIP_TOURISM | {None} or "historic" in tags
                                       or tags.get("amenity") in LABEL_AMENITY or tags.get("leisure") or tags.get("place"))
            if kind is None and not notable(tags) and not detail:
                continue
            c = el.get("center") or (el if "lat" in el else None)
            if c is None and geom:
                c = {"lat": sum(p["lat"] for p in geom) / len(geom), "lon": sum(p["lon"] for p in geom) / len(geom)}
            if c:
                labels.append((xy(c["lat"], c["lon"]), name if kind is None else kind, tags))
    # Nombres de calles principales (una vez cada una).
    seen = set()
    for el in data.get("elements", []):
        tags = el.get("tags", {})
        if tags.get("highway") in ("primary", "secondary", "tertiary", "pedestrian", "trunk") and tags.get("name") and el.get("geometry"):
            if tags["name"] in seen:
                continue
            seen.add(tags["name"])
            g = el["geometry"][len(el["geometry"]) // 2]
            x, y = xy(g["lat"], g["lon"])
            layers["label"].append('<text x="%.1f" y="%.1f" font-size="9" fill="#7a6a55" font-style="italic" stroke="#fff" stroke-width="2.5" paint-order="stroke">%s</text>'
                                   % (x, y, esc(tags["name"])))
    for (x, y), name, tags in labels:
        if name in LOCAL_COLORS:
            layers["label"].append('<rect x="%.1f" y="%.1f" width="8" height="8" fill="%s" stroke="#222" stroke-width="0.8"><title>%s</title></rect>'
                                   % (x - 4, y - 4, LOCAL_COLORS[name], esc(name)))
            continue
        kind = "tourism" if "tourism" in tags else ("historic" if "historic" in tags else "other")
        color = {"tourism": "#b03030", "historic": "#7a3fa0"}.get(kind, "#204070")
        layers["label"].append('<circle cx="%.1f" cy="%.1f" r="3" fill="%s"/>' % (x, y, color))
        layers["label"].append('<text x="%.1f" y="%.1f" font-size="11" font-weight="bold" fill="%s" stroke="#fff" stroke-width="3" paint-order="stroke">%s</text>'
                               % (x + 5, y - 4, color, esc(name)))
    # Cuadrícula de casillas.
    grid = []
    step = tile_m * PX_PER_M
    nx, ny = int(width_m / tile_m), int(height_m / tile_m)
    for i in range(nx + 1):
        major = i % 10 == 0
        grid.append('<line x1="%.1f" y1="0" x2="%.1f" y2="%.1f" stroke="%s" stroke-width="%s" stroke-opacity="%s"/>'
                    % (i * step, i * step, h_px, "#d04020" if major else "#666", "1" if major else "0.4", "0.6" if major else "0.18"))
        if major:
            grid.append('<text x="%.1f" y="10" font-size="9" fill="#d04020">%d</text>' % (i * step + 2, i))
    for j in range(ny + 1):
        major = j % 10 == 0
        grid.append('<line x1="0" y1="%.1f" x2="%.1f" y2="%.1f" stroke="%s" stroke-width="%s" stroke-opacity="%s"/>'
                    % (j * step, w_px, j * step, "#d04020" if major else "#666", "1" if major else "0.4", "0.6" if major else "0.18"))
        if major:
            grid.append('<text x="2" y="%.1f" font-size="9" fill="#d04020">%d</text>' % (j * step - 2, j))
    head = ['<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" viewBox="0 0 %d %d" font-family="sans-serif">'
            % (w_px, h_px + 20, w_px, h_px + 20),
            '<rect width="100%%" height="%d" fill="#f4f1ea"/>' % h_px]
    foot = ['<rect y="%d" width="100%%" height="20" fill="#fff"/>' % h_px,
            '<text x="4" y="%d" font-size="11" fill="#333">%s · %d×%d m · casilla = %g m (%d×%d casillas) · © colaboradores de OpenStreetMap (ODbL)</text>'
            % (h_px + 14, esc(pid), width_m, height_m, tile_m, nx, ny),
            "</svg>"]
    body = layers["land"] + layers["water"] + layers["rail"] + layers["road"] + layers["building"] + grid + layers["label"]
    os.makedirs(OUT, exist_ok=True)
    path = os.path.join(OUT, pid + ".svg")
    with open(path, "w", encoding="utf-8") as f:
        f.write("\n".join(head + body + foot) + "\n")
    print("%s: %d elementos, %d nombres, %dx%d casillas" % (path, len(data.get("elements", [])), len(labels), nx, ny))
    names = sorted({n for _, n, _ in labels if n not in LOCAL_COLORS})
    counts = {k: sum(1 for _, n, _ in labels if n == k) for k in LOCAL_COLORS}
    print("Locales: " + ", ".join("%s %d" % (k, v) for k, v in counts.items()))
    print("Lugares (%d): %s" % (len(names), "; ".join(names)))
    with open(os.path.join(CACHE, pid + ".lugares.txt"), "w", encoding="utf-8") as f:
        f.write("\n".join(names) + "\n")


# Locales que pidió Javier: se marcan con un cuadrado de color (sin nombre) en su sitio real.
LOCAL_COLORS = {"Mercadona": "#00a650", "Estanco": "#c8a000", "Basic-Fit": "#ff7a00"}
SKIP_TOURISM = {"hotel", "hostel", "guest_house", "apartment", "information", "artwork", "picnic_site",
                "camp_site", "motel", "chalet", "caravan_site"}
SKIP_HISTORIC = {"memorial", "boundary_stone", "milestone", "wayside_cross", "wayside_shrine"}


def local_kind(tags: dict):
    brand = (tags.get("brand", "") + " " + tags.get("name", "")).lower()
    if tags.get("shop") == "supermarket" and "mercadona" in brand:
        return "Mercadona"
    if tags.get("shop") == "tobacco":
        return "Estanco"
    if tags.get("leisure") == "fitness_centre" and "basic" in brand and "fit" in brand:
        return "Basic-Fit"
    return None


def notable(tags: dict) -> bool:
    if tags.get("place") in ("square", "neighbourhood", "quarter", "suburb", "locality", "village"):
        return True
    if tags.get("tourism") in SKIP_TOURISM or tags.get("historic") in SKIP_HISTORIC:
        return False
    if "shop" in tags:
        return False
    return "wikidata" in tags or "wikipedia" in tags


def simplify(points: list, tol: float) -> list:
    """Douglas-Peucker: quita puntos que se desvían menos de `tol` píxeles."""
    if len(points) < 3 or tol <= 0:
        return points
    (x1, y1), (x2, y2) = points[0], points[-1]
    dx, dy = x2 - x1, y2 - y1
    norm = math.hypot(dx, dy) or 1e-9
    far, index = 0.0, 0
    for i in range(1, len(points) - 1):
        px_, py_ = points[i]
        d = abs(dy * px_ - dx * py_ + x2 * y1 - y2 * x1) / norm
        if d > far:
            far, index = d, i
    if far <= tol:
        return [points[0], points[-1]]
    return simplify(points[:index + 1], tol)[:-1] + simplify(points[index:], tol)


def fmt(points: list) -> str:
    return " ".join("%d,%d" % (round(x), round(y)) for x, y in points)


def esc(text: str) -> str:
    return text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


if __name__ == "__main__":
    main()
