#!/usr/bin/env python3
"""Comprueba que cada Pokémon de los entrenadores (data/trainers/*.json) está en la etapa que toca a su
nivel, con la misma regla que el validador del RandomLocke (level_appropriate, RomValidator):
nivel mínimo de la especie <= nivel < nivel máximo sin evolucionar. Si no, la ROM sale con
«Etapa no acorde al nivel». También avisa de los legendarios por debajo del nivel 30.

Uso: python3 tools/mundo/comprobar_equipos.py [archivo.json ...]   (sin argumentos: todos)
Sale con código 1 si hay algún problema.
"""
import glob
import json
import os
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
LEVEL_METHODS = {"level", "level_hold", "level_move", "level_extra"}


def load_species() -> dict:
    species = json.load(open(os.path.join(ROOT, "data", "generated", "species.json"), encoding="utf-8"))
    overrides = json.load(open(os.path.join(ROOT, "data", "species_overrides.json"), encoding="utf-8"))
    for sid, changes in overrides.get("species", {}).items():
        if sid.startswith("_"):
            continue
        base = dict(species.get(changes.get("base", sid), {}))
        base.update({k: v for k, v in changes.items() if not k.startswith("_") and k != "base"})
        species[sid] = base
    return species


def load_policy() -> dict:
    return json.load(open(os.path.join(ROOT, "data", "randomizer", "policy.json"), encoding="utf-8"))


class Rules:
    def __init__(self, species: dict, policy: dict):
        self.species = species
        self.gap = int(policy.get("evolution_gap", 15))
        self.over = int(policy.get("overlevel_gap", 10))
        self.legendary_level = int(policy.get("early_legendary_level", 30))
        self.legendary_tags = set(policy.get("legendary_tags", []))
        self.prevo = {}
        for sid in sorted(species):
            for evo in self.evos(sid):
                to = evo.get("to", "")
                if "region" not in evo and to in species and to not in self.prevo:
                    self.prevo[to] = (sid, evo)
        self._min = {}
        self._max = {}

    def evos(self, sid: str) -> list:
        return self.species.get(sid, {}).get("evolutions") or []

    def min_level(self, sid: str) -> int:
        if sid in self._min:
            return self._min[sid]
        raw = self.species.get(sid, {})
        if "min_level" in raw:
            return int(raw["min_level"])
        level = 1
        if sid in self.prevo:
            frm, evo = self.prevo[sid]
            base = self.min_level(frm)
            if evo.get("method", "") in LEVEL_METHODS and "level" in evo:
                level = max(base, int(evo["level"]))
            else:
                level = min(base + self.gap, 100)
        self._min[sid] = level
        return level

    def max_level(self, sid: str) -> int:
        if sid in self._max:
            return self._max[sid]
        raw = self.species.get(sid, {})
        if "max_level" in raw:
            return int(raw["max_level"]) + 1
        best = 101
        for evo in self.evos(sid):
            if "region" in evo or evo.get("to", "") not in self.species:
                continue
            if evo.get("method", "") in LEVEL_METHODS and "level" in evo:
                best = min(best, int(evo["level"]) + self.over)
            else:
                best = min(best, self.min_level(sid) + self.gap + self.over)
        self._max[sid] = best
        return best

    def legendary(self, sid: str) -> bool:
        raw = self.species.get(sid, {})
        if raw.get("is_legendary") or raw.get("is_mythical"):
            return True
        return bool(self.legendary_tags & set(raw.get("tags", [])))

    def check(self, sid: str, level: int) -> str:
        if sid not in self.species:
            return "la especie %s no existe" % sid
        lo, hi = self.min_level(sid), self.max_level(sid)
        if lo > level or level >= hi:
            return "%s al %d: etapa no acorde (de %d a %d)" % (sid, level, lo, hi - 1)
        if self.legendary(sid) and level < self.legendary_level:
            return "%s al %d: legendario por debajo del %d" % (sid, level, self.legendary_level)
        return ""


def main() -> int:
    rules = Rules(load_species(), load_policy())
    files = sys.argv[1:] or sorted(glob.glob(os.path.join(ROOT, "data", "trainers", "*.json")))
    problems = 0
    for path in files:
        trainers = json.load(open(path, encoding="utf-8"))
        for tid, trainer in trainers.items():
            if tid.startswith("_"):
                continue
            for member in trainer.get("party", []):
                issue = rules.check(member["species"], int(member["level"]))
                if issue:
                    problems += 1
                    print("%s · %s: %s" % (os.path.basename(path), tid, issue))
    print("comprobar_equipos: %d problemas." % problems)
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
