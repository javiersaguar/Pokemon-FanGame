#!/usr/bin/env python3
"""Sube los niveles de una zona (entrenadores y encuentros) a otra franja y evoluciona cada especie a la
etapa que le toca a su nivel (regla level_appropriate del RandomLocke). Lo usa la vuelta a casa de
Javier: San Miguel de Bernuy y las Rutas 1-4 se recorren tras la 7.ª medalla (decisiones del 2026-10-13, §7).

Uso: python3 tools/mundo/subir_niveles.py <zona> <nivel_min> <nivel_max>
     (ejemplo: ruta_1 48 50; reescribe data/trainers/<zona>.json y data/encounters/<zona>.json)
"""
import json
import os
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
SPECIES = json.load(open(os.path.join(ROOT, "data", "generated", "species.json"), encoding="utf-8"))


def evolve(species: str, level: int) -> str:
    """Sube por las evoluciones mientras toque: por nivel si ya lo alcanza; por objeto, amistad o
    intercambio, a partir del nivel 40 (en la recta final todo va evolucionado)."""
    for _ in range(3):
        options = SPECIES.get(species, {}).get("evolutions") or []
        nxt = None
        for e in options:
            if e.get("method") == "level":
                if int(e.get("level") or 0) <= level and e["to"] in SPECIES:
                    nxt = e["to"]
                    break
            elif level >= 40 and e.get("to") in SPECIES:
                nxt = e["to"]
                break
        if nxt is None:
            return species
        species = nxt
    return species


def scale(value: int, old_lo: int, old_hi: int, lo: int, hi: int) -> int:
    if old_hi <= old_lo:
        return hi
    return lo + round((value - old_lo) * (hi - lo) / (old_hi - old_lo))


def main() -> None:
    zone, lo, hi = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
    tpath = os.path.join(ROOT, "data", "trainers", zone + ".json")
    epath = os.path.join(ROOT, "data", "encounters", zone + ".json")
    if os.path.exists(tpath):
        trainers = json.load(open(tpath, encoding="utf-8"))
        levels = [m["level"] for t in trainers.values() for m in t["party"]]
        for t in trainers.values():
            for m in t["party"]:
                m["level"] = scale(m["level"], min(levels), max(levels), lo, hi)
                m["species"] = evolve(m["species"], m["level"])
        open(tpath, "w", encoding="utf-8").write(json.dumps(trainers, ensure_ascii=False, indent=2) + "\n")
    if os.path.exists(epath):
        enc = json.load(open(epath, encoding="utf-8"))
        slots = [s for k in ("day", "night") for s in enc.get("land", {}).get(k, [])]
        slots += [s for k in ("water", "old_rod", "good_rod", "super_rod", "rock_smash", "headbutt") for s in enc.get(k, [])]
        if slots:
            olo, ohi = min(s["min"] for s in slots), max(s["max"] for s in slots)
            for s in slots:
                s["min"] = scale(s["min"], olo, ohi, lo, hi)
                s["max"] = max(s["min"], scale(s["max"], olo, ohi, lo, hi))
                s["species"] = evolve(s["species"], s["min"])
        open(epath, "w", encoding="utf-8").write(json.dumps(enc, ensure_ascii=False, indent=2) + "\n")
    print("%s: niveles %d-%d" % (zone, lo, hi))


if __name__ == "__main__":
    main()
