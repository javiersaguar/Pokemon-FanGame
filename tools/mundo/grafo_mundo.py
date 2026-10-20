#!/usr/bin/env python3
"""Grafo del mundo: cómo se unen los mapas pintados y si se llega a todo desde los pueblos iniciales.

Lee maps/**/*.tscn (sin los de muestra ni los de pruebas) y saca, de cada mapa, sus bordes con conexión
(MapConnection), sus pasarelas y puertas (Warp) y los saltos de los eventos (Cutscene.teleport en un
evento de src/events/ que usa el mapa). Recorre el grafo con sentido desde los pueblos iniciales
(Pozuelo y Orcasitas, data/region.json → start) y escribe docs/mundo/conexiones.md con: lo que no se
alcanza, los mapas desde los que no se puede volver, las uniones de un solo sentido (las previstas y las
que no), los cortes por medallas (data/personajes_en_el_mapa.json, colocaciones con "hasta"), cómo se
llega a cada ciudad y ruta de data/region.json y la tabla mapa por mapa.

El test tests/mundo/test_acceso_mundo.gd hace la misma comprobación dentro de Godot y falla si algo no
se alcanza.

Uso (desde la raíz del repo): python3 tools/mundo/grafo_mundo.py [--salida docs/mundo/conexiones.md]
"""
import argparse
import json
import re
from collections import deque
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SKIP = ("_", "muestras", "test")
# Uniones de un solo sentido a propósito: [origen, destino, motivo].
ONE_WAY_OK = [
    ("madrid/atico_ayuso", "madrid/chamberi",
     "de la terraza del ático se baja a Chamberí; se sube con Ayuso desde su despacho (evento)"),
]
MODES = {"ferry": "ferry", "avion": "avión", "ave": "AVE"}
# Surf es una herramienta de campo de la 3.ª medalla (decisiones del 2026-10-13, §2). Aún no se da en el juego.
SURF_MEDAL = 3


def leer_mapas() -> dict:
    maps = {}
    teleports = {}
    for f in sorted((ROOT / "maps").rglob("*.tscn")):
        rel = f.relative_to(ROOT / "maps").with_suffix("").as_posix()
        if rel.startswith(SKIP):
            continue
        s = f.read_text(encoding="utf-8")
        m = re.search(r'^id = &"([^"]+)"', s, re.M)
        name = re.search(r'^display_name = "([^"]*)"', s, re.M)
        outdoor = re.search(r'^outdoor = false', s, re.M) is None
        edges, warps, events, guards, warp_tiles = [], [], [], {}, {}
        for block in re.split(r"\n(?=\[)", s):
            hidden = re.search(r'^hidden_if_flag = &"visited_map:([^"]+)"', block, re.M)
            pos = re.search(r'^position = Vector2\(([-\d.]+), ([-\d.]+)\)', block, re.M)
            tile = (int(float(pos.group(1))) // 32, int(float(pos.group(2))) // 32) if pos else None
            if hidden and tile:
                guards[tile] = hidden.group(1)
            t = re.search(r'^target_map = &"([^"]+)"', block, re.M)
            if not t:
                continue
            if block.startswith("[node"):
                warp = re.search(r'^\[node name="([^"]+)"', block)
                sp = re.search(r'^target_spawn = &"([^"]+)"', block, re.M)
                warps.append((warp.group(1) if warp else "?", t.group(1), sp.group(1) if sp else "default"))
                warp_tiles[warps[-1][0]] = tile
            else:
                e = re.search(r'^edge = "(\w+)"', block, re.M)
                edges.append((e.group(1) if e else "east", t.group(1)))  # "east" es el valor por defecto
        # Pasarelas que tapa un revisor hasta haber estado en el destino (AVE: viaje rápido a lo ya visitado).
        visit_gated = set()
        for w, t, _ in warps:
            at = warp_tiles.get(w)
            if at and (guards.get(at) or guards.get((at[0], at[1] + 1))):
                visit_gated.add(t)
        for path in re.findall(r'path="res://(src/events/[^"]+\.gd)"', s):
            if path not in teleports:
                code = (ROOT / path).read_text(encoding="utf-8") if (ROOT / path).exists() else ""
                teleports[path] = re.findall(r'Cutscene\.teleport\(&?"([^"]+)"', code)
            for target in teleports[path]:
                events.append((Path(path).stem, target))
        maps[m.group(1) if m else rel] = {"name": name.group(1) if name else rel, "edges": edges, "warps": warps,
                                          "events": events, "outdoor": outdoor, "visit_gated": visit_gated,
                                          "file": "maps/%s.tscn" % rel}
    return maps


def bloqueos(maps: dict) -> dict:
    """Obstáculos de campo y atajos (data/bloqueos_campo.json, de tools/mundo/bloqueos_campo.gd).

    Quita de `maps` las salidas a las que solo se llega abriendo un bloqueo cuya acción no está disponible
    (data/world.json → field.actions.<acción>.item vacío) o que es un atajo (se abre en el propio mapa)."""
    path = ROOT / "data" / "bloqueos_campo.json"
    data = json.loads(path.read_text(encoding="utf-8")).get("mapas", {}) if path.exists() else {}
    world = json.loads((ROOT / "data" / "world.json").read_text(encoding="utf-8"))
    actions = world.get("field", {}).get("actions", {})
    ready = {a for a, v in actions.items() if isinstance(v, dict) and v.get("item")}
    cut = []
    for k, info in data.items():
        for exit_ in info.get("tras_bloqueo", []):
            if all(c in ready for c in exit_["condicion"]) or k not in maps:
                continue
            kind, name = exit_["salida"].split(" ", 1)
            if kind == "pasarela":
                maps[k]["warps"] = [w for w in maps[k]["warps"] if w[0] != name]
            else:
                maps[k]["edges"] = [e for e in maps[k]["edges"] if e[0] != name]
            cut.append((k, exit_["salida"], exit_["destino"], exit_["condicion"]))
    return {"mapas": data, "cortadas": cut, "listas": sorted(ready)}


def grafo(maps: dict, first_visit: bool = False) -> tuple:
    """Grafo con sentido. Con first_visit, sin las pasarelas que piden haber estado ya en el destino."""
    graph = {k: set() for k in maps}
    kinds = {}
    missing = []
    for k, v in maps.items():
        links = [("borde " + e, t) for e, t in v["edges"]] + [("pasarela " + w, t) for w, t, _ in v["warps"]] \
            + [("evento " + ev, t) for ev, t in v["events"]]
        for kind, t in links:
            if first_visit and t in v["visit_gated"]:
                continue
            if t in maps:
                graph[k].add(t)
                kinds.setdefault((k, t), kind)
            else:
                missing.append((k, kind, t))
    return graph, kinds, missing


def alcance(graph: dict, starts: list) -> dict:
    """Mapa → anterior en el camino más corto desde los pueblos iniciales."""
    prev = {s: None for s in starts if s in graph}
    q = deque(prev)
    while q:
        a = q.popleft()
        for b in sorted(graph[a]):
            if b not in prev:
                prev[b] = a
                q.append(b)
    return prev


def medallas(graph: dict, starts: list, cost: dict) -> dict:
    """Mapa → (medallas que hacen falta, pasos, anterior): el camino que pide menos medallas y, a igualdad, el más corto."""
    import heapq
    best = {}
    heap = [((0, 0), s, "") for s in starts if s in graph]
    while heap:
        (need, steps), a, prev = heapq.heappop(heap)
        if a in best:
            continue
        best[a] = (need, steps, prev or None)
        for b in sorted(graph[a]):
            if b not in best:
                heapq.heappush(heap, ((max(need, cost.get((a, b), 0)), steps + 1), b, a))
    return best


def vuelta(graph: dict, starts: list) -> set:
    """Mapas desde los que se puede volver a algún pueblo inicial."""
    back = {}
    for a, outs in graph.items():
        for b in outs:
            back.setdefault(b, set()).add(a)
    seen = set(s for s in starts if s in graph)
    q = deque(seen)
    while q:
        b = q.popleft()
        for a in back.get(b, ()):
            if a not in seen:
                seen.add(a)
                q.append(a)
    return seen


def camino(prev: dict, target: str) -> list:
    out = []
    while target is not None:
        out.append(target)
        target = prev[target]
    return list(reversed(out))


def modos(path: list, maps: dict, gates: list) -> list:
    """Cómo se viaja en un camino: andando, Cercanías, ferry, avión, AVE, Surf y cortes por medallas."""
    out = []
    for a, b in zip(path, path[1:]):
        for key, label in MODES.items():
            if b.startswith("transporte/%s_" % key) and label not in out:
                out.append(label)
        if (a.startswith("maritima_1/") or b.startswith("maritima_1/")) and "Surf" not in out:
            out.append("Surf")
        warp_names = [w for w, t, _ in maps[a]["warps"] if t == b]
        if any(w.startswith("Cercanias") for w in warp_names) and "Cercanías C-5" not in out:
            out.append("Cercanías C-5")
        for g in gates:
            if (a, b) in g["links"] and "corte: " + g["label"] not in out:
                out.append("corte: " + g["label"])
    return out or ["andando"]


def cortes(maps: dict) -> list:
    """Cortes por medallas de data/personajes_en_el_mapa.json: colocaciones fijas con "hasta"."""
    data = json.loads((ROOT / "data" / "personajes_en_el_mapa.json").read_text(encoding="utf-8"))
    out = {}
    for c in data.get("colocados", []):
        until = c.get("hasta")
        if not isinstance(until, dict) or not c.get("fija"):
            continue
        mapa = c.get("mapa", "")
        key = (mapa, c.get("lugar", ""))
        g = out.setdefault(key, {"map": mapa, "place": c.get("lugar", ""), "until": until, "ids": [], "links": set(),
                                 "cells": []})
        g["ids"].append(c.get("id", ""))
        g["cells"].append(tuple(int(x) for x in c.get("casilla", c.get("cerca", [0, 0]))))
    for g in out.values():
        medals = int(g["until"].get("medallas", 0))
        short = "C-5 averiado" if "C-5" in g["place"] else g["place"].split(":")[0]
        g["label"] = "%s hasta %d %s" % (short, medals, "medalla" if medals == 1 else "medallas")
        v = maps.get(g["map"])
        if v is None:
            continue
        # La pasarela que tapan (bloquea_pasarela) o el borde junto al que están (columna 0 = oeste...).
        for w, t, _ in v["warps"]:
            if w.startswith("Cercanias"):
                g["links"].add((g["map"], t))
        if all(cell[0] <= 1 for cell in g["cells"]):  # en la primera o segunda columna: cortan el borde oeste
            for e, t in v["edges"]:
                if e == "west":
                    g["links"].add((g["map"], t))
    return sorted(out.values(), key=lambda g: (g["map"], g["place"]))


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--salida", default="docs/mundo/conexiones.md")
    args = ap.parse_args()
    region = json.loads((ROOT / "data" / "region.json").read_text(encoding="utf-8"))
    starts = [region["locations"][s]["map"] for s in region.get("start", [])]
    maps = leer_mapas()
    blocks = bloqueos(maps)
    graph, kinds, missing = grafo(maps)
    first_graph = grafo(maps, True)[0]
    gates = cortes(maps)
    prev_all = alcance(graph, starts)
    per_start = {s: alcance(graph, [s]) for s in starts}
    cost = {}
    for g in gates:
        for ab in g["links"]:
            cost[ab] = int(g["until"].get("medallas", 0))
    surf_links = {(a, b) for a in maps for b in first_graph[a] if a.startswith("maritima_1/") or b.startswith("maritima_1/")}
    with_surf = dict(cost)
    for ab in surf_links:
        with_surf[ab] = max(with_surf.get(ab, 0), SURF_MEDAL)
    best = medallas(first_graph, starts[:1], with_surf)
    best_free_surf = medallas(first_graph, starts[:1], cost)
    first = {k: v[2] for k, v in best.items()}
    back = vuelta(graph, starts)
    unreachable = sorted(k for k in maps if k not in prev_all)
    trapped = sorted(k for k in prev_all if k not in back)
    one_way, one_way_ok = [], []
    allowed = {(a, b): why for a, b, why in ONE_WAY_OK}
    for a in sorted(graph):
        for b in sorted(graph[a]):
            if a in graph[b]:
                continue
            kind = kinds[(a, b)]
            if a.startswith("transporte/") or b.startswith("transporte/"):
                continue  # los viajes son de ida a propósito: se sube en un puerto y se baja en otro
            if kind.startswith("evento"):
                one_way_ok.append((a, b, "salto del evento %s" % kind.split(" ", 1)[1]))
            elif (a, b) in allowed:
                one_way_ok.append((a, b, allowed[(a, b)]))
            else:
                one_way.append((a, b))
    names = {s: region["locations"][s]["name"] for s in region.get("start", [])}
    lines = [
        "# Conexiones del mundo",
        "",
        "> Generado con `python3 tools/mundo/grafo_mundo.py` a partir de los mapas pintados (`maps/**/*.tscn`) y de "
        "`data/region.json`. No se edita a mano: se vuelve a generar al pintar o unir mapas. El test "
        "`tests/mundo/test_acceso_mundo.gd` comprueba lo mismo dentro del juego.",
        "",
        "Bordes = `MapConnection` (se pasa andando, sin fundido; `span` = solo un tramo del borde). "
        "Pasarelas = `Warp` (puertas, ferris, avión, AVE, Cercanías). Eventos = saltos de un evento "
        "(`Cutscene.teleport`). El recorrido tiene sentido: sale de los pueblos iniciales "
        "(decisiones del 2026-10-13, §7).",
        "",
        "## Desde los pueblos iniciales",
        "",
        "- **%d mapas** en total. Se llega a **%d** desde %s." % (
            len(maps), len(prev_all), " y ".join("%s (`%s`: %d)" % (names[s], m, len(per_start[m]))
                                                 for s, m in zip(region.get("start", []), starts))),
    ]
    if unreachable:
        lines.append("- **No se alcanzan (%d):** %s." % (len(unreachable), ", ".join("`%s`" % k for k in unreachable)))
    else:
        lines.append("- No queda ningún mapa aislado.")
    if trapped:
        lines.append("- **Sin vuelta a los pueblos iniciales (%d):** %s." % (len(trapped), ", ".join("`%s`" % k for k in trapped)))
    else:
        lines.append("- Desde todos los mapas se puede volver a los pueblos iniciales.")
    lines += ["", "## Orden de los gimnasios", "",
              "Medallas que hacen falta para llegar a la ciudad de cada gimnasio por primera vez, con los cortes de "
              "abajo y con Surf en la 3.ª medalla (decisiones del 2026-10-13, §2). Para el gimnasio N deberían bastar N − 1.", "",
              "| Gimnasio | Ciudad | Medallas para llegar | Sin contar Surf | ¿Cuadra? |", "|---|---|---|---|---|"]
    gyms = sorted((v["gym"]["order"], k, v) for k, v in region["locations"].items() if isinstance(v.get("gym"), dict))
    for order, key, v in gyms:
        mp = v.get("map", "")
        need = best.get(mp, (None,))[0]
        free = best_free_surf.get(mp, (None,))[0]
        ok = need is not None and need <= order - 1
        why = "sí" if ok else ("**no**: PENDIENTE JAVIER (Surf con la %d.ª medalla)" % SURF_MEDAL
                               if free is not None and free <= order - 1 else "**no**")
        lines.append("| %d | %s | %s | %s | %s |" % (order, v["name"], need if need is not None else "—",
                                                     free if free is not None else "—", why))
    lines += ["", "## Ciudades y rutas", "",
              "Camino desde %s la primera vez (sin el AVE, que solo lleva a destinos ya visitados): el que pide menos "
              "medallas y, a igualdad, el más corto. Los cortes por medallas se abren solos al tenerlas." % names[region["start"][0]],
              "", "| Lugar | Mapa | Se llega | Medallas | Cómo |", "|---|---|---|---|---|"]
    entries = [(v["name"], v.get("map", "")) for v in region["locations"].values()]
    entries += [(v["name"], v.get("map", "")) for v in region.get("districts", {}).values()]
    entries += [(v["name"], v.get("map", "")) for v in region["routes"].values() if v.get("map") is not None and "kind" not in v]
    entries += [(v["name"], v.get("map", "")) for v in region["routes"].values() if v.get("kind") == "surf"]
    for rid, v in region["routes"].items():
        for mp in v.get("maps", []):
            entries.append(("%s · %s" % (v["name"], maps.get(mp, {}).get("name", mp)), mp))
    for label, mp in entries:
        if not mp or mp not in maps:
            lines.append("| %s | %s | pendiente | — | sin mapa todavía |" % (label, "`%s`" % mp if mp else "—"))
            continue
        if mp not in first:
            how = "tras visitar el destino (AVE)" if mp in prev_all else "**no**"
            lines.append("| %s | `%s` | %s | — | — |" % (label, mp, how))
            continue
        path = camino(first, mp)
        lines.append("| %s | `%s` | sí, %d pasos | %d | %s |" % (label, mp, len(path) - 1, best[mp][0],
                                                                ", ".join(modos(path, maps, gates))))
    lines += ["", "## Cortes por medallas", "",
              "Personajes fijos de `data/personajes_en_el_mapa.json` que tapan un paso hasta tener medallas (`hasta`).", ""]
    for g in gates:
        links = ", ".join("`%s` → `%s`" % ab for ab in sorted(g["links"])) or "—"
        lines.append("- **%s** (`%s`): %s. Cierra %s." % (g["label"], g["map"], ", ".join(g["ids"]), links))
    lines += ["", "## Obstáculos de campo y atajos", "",
              "Rocas de Golpe Roca y de Fuerza, arbolillos de Corte y troncos que se apartan desde un lado "
              "(`data/bloqueos_campo.json`, de `tools/mundo/bloqueos_campo.gd`). Las salidas a las que solo se llega "
              "abriendo uno se quitan del grafo mientras su acción no esté disponible (`data/world.json` → "
              "`field.actions`; ahora: %s)." % (", ".join(blocks["listas"]) or "ninguna"), ""]
    total = sum(len(v.get("bloqueos", [])) for v in blocks["mapas"].values())
    lines.append("- **%d bloqueos** en %d mapas." % (total, len(blocks["mapas"])))
    for k in sorted(blocks["mapas"]):
        v = blocks["mapas"][k]
        kinds_count = {}
        for b in v.get("bloqueos", []):
            kinds_count[b["tipo"]] = kinds_count.get(b["tipo"], 0) + 1
        what = ", ".join("%d %s" % (n, t) for t, n in sorted(kinds_count.items()))
        extra = (" Detrás: %s." % ", ".join(v["opcional"])) if v.get("opcional") else ""
        lines.append("  - `%s`: %s.%s" % (k, what, extra))
    if blocks["cortadas"]:
        lines += ["", "**Salidas tras un bloqueo cerrado (quitadas del grafo):**", ""]
        for k, s, t, c in blocks["cortadas"]:
            lines.append("- `%s`, %s → `%s` (hace falta: %s)." % (k, s, t, ", ".join(c)))
    else:
        lines.append("- Ninguna salida queda detrás de un bloqueo: solo cierran objetos, zonas opcionales y atajos.")
    lines += ["", "## Uniones de un solo sentido", ""]
    for a, b, why in one_way_ok:
        lines.append("- `%s` → `%s`: a propósito (%s)." % (a, b, why))
    lines.append("- Los viajes (`transporte/*`) son de ida a propósito: se sube en un puerto y se baja en otro; "
                 "cada uno tiene su viaje de vuelta.")
    if one_way:
        lines += ["", "**Sin vuelta y sin motivo:**", ""]
        for a, b in one_way:
            lines.append("- `%s` → `%s`: solo de ida (falta la vuelta)." % (a, b))
    lines += ["", "## Uniones pendientes", ""]
    if not missing:
        lines.append("Ninguna: todos los destinos existen.")
    for a, kind, t in missing:
        lines.append("- `%s` → `%s` (%s): el mapa de destino aún no existe." % (a, t, kind))
    lines += ["", "## Mapa por mapa", "", "| Mapa | Nombre | Bordes | Pasarelas |", "|---|---|---|---|"]
    for k in sorted(maps):
        v = maps[k]
        ed = ", ".join("%s → `%s`" % (e, t) for e, t in v["edges"]) or "—"
        wa = ", ".join("%s → `%s`" % (w, t) for w, t, _ in v["warps"])
        ev = ", ".join("evento %s → `%s`" % (e, t) for e, t in v["events"])
        lines.append("| `%s` | %s | %s | %s |" % (k, v["name"], ed, ", ".join(x for x in (wa, ev) if x) or "—"))
    out = ROOT / args.salida
    out.write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")
    print("%s: %d mapas, %d alcanzables, %d aislados, %d sin vuelta, %d de ida sin motivo" % (
        args.salida, len(maps), len(prev_all), len(unreachable), len(trapped), len(one_way)))


if __name__ == "__main__":
    main()
