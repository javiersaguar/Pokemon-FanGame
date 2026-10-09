#!/usr/bin/env python3
"""Grafo del mundo: cómo se unen los mapas pintados.

Lee maps/**/*.tscn (sin los de muestra ni los de pruebas) y saca, de cada mapa, sus bordes con conexión
(MapConnection) y sus pasarelas (Warp: ferris, avión, Cercanías). Escribe docs/mundo/conexiones.md con:
los grupos de mapas que se tocan entre sí, cuáles se alcanzan desde el pueblo inicial, los destinos que
aún no existen y las uniones de un solo sentido.

Uso (desde la raíz del repo): python3 tools/mundo/grafo_mundo.py [--salida docs/mundo/conexiones.md]
"""
import argparse
import re
from collections import deque
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
START = "pueblo_inicial/exterior"
SKIP = ("_", "muestras", "test")


def leer_mapas() -> dict:
    maps = {}
    for f in sorted((ROOT / "maps").rglob("*.tscn")):
        rel = f.relative_to(ROOT / "maps").with_suffix("").as_posix()
        if rel.startswith(SKIP):
            continue
        s = f.read_text(encoding="utf-8")
        m = re.search(r'^id = &"([^"]+)"', s, re.M)
        name = re.search(r'^display_name = "([^"]*)"', s, re.M)
        edges, warps = [], []
        for block in re.split(r"\n(?=\[)", s):
            t = re.search(r'^target_map = &"([^"]+)"', block, re.M)
            if not t:
                continue
            if block.startswith("[node"):
                warp = re.search(r'^\[node name="([^"]+)"', block)
                warps.append((warp.group(1) if warp else "?", t.group(1)))
            else:
                e = re.search(r'^edge = "(\w+)"', block, re.M)
                edges.append((e.group(1) if e else "east", t.group(1)))  # "east" es el valor por defecto
        maps[m.group(1) if m else rel] = {"name": name.group(1) if name else rel, "edges": edges,
                                          "warps": warps, "file": "maps/%s.tscn" % rel}
    return maps


def grupos(graph: dict) -> list:
    undirected = {k: set(v) for k, v in graph.items()}
    for k, v in graph.items():
        for n in v:
            undirected.setdefault(n, set()).add(k)
    seen, out = set(), []
    for k in sorted(graph):
        if k in seen:
            continue
        comp, q = {k}, deque([k])
        while q:
            for n in undirected[q.popleft()]:
                if n not in comp and n in graph:
                    comp.add(n)
                    q.append(n)
        seen |= comp
        out.append(sorted(comp))
    return sorted(out, key=lambda c: (START not in c, -len(c)))


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--salida", default="docs/mundo/conexiones.md")
    args = ap.parse_args()
    maps = leer_mapas()
    graph = {k: set() for k in maps}
    missing, one_way = [], []
    for k, v in maps.items():
        for kind, t in [("borde " + e, t) for e, t in v["edges"]] + [("pasarela " + w, t) for w, t in v["warps"]]:
            if t in maps:
                graph[k].add(t)
            else:
                missing.append((k, kind, t))
    for a in graph:
        for b in graph[a]:
            if a not in graph[b]:
                one_way.append((a, b))
    lines = [
        "# Conexiones del mundo",
        "",
        "> Generado con `python3 tools/mundo/grafo_mundo.py` a partir de los mapas pintados (`maps/**/*.tscn`). "
        "No se edita a mano: se vuelve a generar al pintar o unir mapas.",
        "",
        "Bordes = `MapConnection` (se pasa andando, sin fundido; `span` = solo un tramo del borde). "
        "Pasarelas = `Warp` (ferris, avión, Cercanías). Los interiores aún no existen.",
        "",
        "## Grupos de mapas unidos entre sí",
        "",
    ]
    for comp in grupos(graph):
        head = "Se llega desde San Miguel de Bernuy" if START in comp else "**Aislado del pueblo inicial**"
        lines.append("- %s (%d mapas): %s" % (head, len(comp), ", ".join("`%s`" % c for c in comp)))
    lines += ["", "## Uniones pendientes", ""]
    if not missing and not one_way:
        lines.append("Ninguna.")
    for a, kind, t in missing:
        lines.append("- `%s` → `%s` (%s): el mapa de destino aún no existe." % (a, t, kind))
    for a, b in one_way:
        lines.append("- `%s` → `%s`: solo de ida (falta la vuelta)." % (a, b))
    lines += ["", "## Mapa por mapa", "", "| Mapa | Nombre | Bordes | Pasarelas |", "|---|---|---|---|"]
    for k in sorted(maps):
        v = maps[k]
        ed = ", ".join("%s → `%s`" % (e, t) for e, t in v["edges"]) or "—"
        wa = ", ".join("%s → `%s`" % (w, t) for w, t in v["warps"]) or "—"
        lines.append("| `%s` | %s | %s | %s |" % (k, v["name"], ed, wa))
    out = ROOT / args.salida
    out.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print("%s: %d mapas, %d grupos" % (args.salida, len(maps), len(grupos(graph))))


if __name__ == "__main__":
    main()
