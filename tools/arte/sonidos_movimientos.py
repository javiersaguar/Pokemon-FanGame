#!/usr/bin/env python3
"""Sonidos de las animaciones de movimientos, sacados del EBDX move & common animation pack (pack 17).

Lee las animaciones de EBDX (Plugins/.../Move Animations/*.rb): cada defineMoveAnimation(:MOVIMIENTO)
y los pbSEPlay que hace, en orden (si solo llama a otra animación con playMoveAnimation, usa los de
esa). Copia sin modificar los sonidos usados a assets/audio/se/anim/, los apunta con su sha256 en
data/audio_assets.json y escribe data/battle_motion_sounds.json: movimiento → sonidos (hasta 3).
Los movimientos que EBDX no anima toman el sonido más común de los de su tipo.

  python3 tools/arte/sonidos_movimientos.py [carpeta-de-recursos]
"""
import collections
import hashlib
import json
import os
import re
import shutil
import sys

RESOURCES = sys.argv[1] if len(sys.argv) > 1 else "/mnt/c/Users/Javier/Pokemon-Panchito-recursos"
PACK17 = "17_ebdx_anim_pack"
PACK16 = "16_elite_battle_dx"
CODE = os.path.join(RESOURCES, PACK17, "EBDX_Anim_Pack/Plugins/Elite Battle DX/[002] Animation Code/Move Animations")
SOUND_DIRS = [
    (PACK17, "EBDX_Anim_Pack/Audio/SE"),
    (PACK16, "Audio/SE"),
]
TARGET = "assets/audio/se/anim"
MAX_SOUNDS = 3
DEFINE = re.compile(r"EliteBattle\.defineMoveAnimation\(:([A-Z0-9_]+)\)")
PLAY_SE = re.compile(r'pbSEPlay\("([^"]+)"')
ALIAS = re.compile(r"EliteBattle\.playMoveAnimation\(:([A-Z0-9_]+)")


def slug(name: str) -> str:
    return re.sub(r"[^a-z0-9]+", "_", name.lower()).strip("_")


def parse_blocks() -> tuple[dict, dict]:
    sounds, aliases = {}, {}
    for base, _, files in os.walk(CODE):
        for file in sorted(files):
            if not file.endswith(".rb"):
                continue
            text = open(os.path.join(base, file), encoding="utf-8", errors="ignore").read()
            parts = DEFINE.split(text)
            for i in range(1, len(parts), 2):
                move = parts[i].lower().replace("_", "")
                body = parts[i + 1]
                found = PLAY_SE.findall(body)
                if found:
                    sounds[move] = found
                else:
                    alias = ALIAS.search(body)
                    if alias:
                        aliases[move] = alias.group(1).lower().replace("_", "")
    return sounds, aliases


def find_file(path: str):
    for pack, root in SOUND_DIRS:
        folder = os.path.join(RESOURCES, pack, root, os.path.dirname(path))
        if not os.path.isdir(folder):
            continue
        stem = os.path.basename(path).lower()
        for file in sorted(os.listdir(folder)):
            if os.path.splitext(file)[0].lower() == stem:
                return pack, os.path.relpath(os.path.join(folder, file), os.path.join(RESOURCES, pack))
    return None


def main() -> None:
    raw, aliases = parse_blocks()
    for move, other in aliases.items():
        if move not in raw and other in raw:
            raw[move] = raw[other]
    moves = json.load(open("data/generated/moves.json", encoding="utf-8"))
    motion = json.load(open("data/battle_motion_moves.json", encoding="utf-8"))
    os.makedirs(TARGET, exist_ok=True)
    copied, out, missing = {}, {}, set()
    for move, paths in sorted(raw.items()):
        ids = []
        for path in paths:
            if len(ids) >= MAX_SOUNDS:
                break
            found = find_file(path)
            if found is None:
                missing.add(path)
                continue
            pack, source = found
            ext = os.path.splitext(source)[1].lower()
            sid = slug(os.path.basename(path))
            target = f"{TARGET}/{sid}{ext}"
            if target not in copied:
                full = os.path.join(RESOURCES, pack, source)
                shutil.copyfile(full, target)
                copied[target] = {"pack": pack, "source": source.replace(os.sep, "/"), "target": target,
                                  "sha256": hashlib.sha256(open(full, "rb").read()).hexdigest()}
            if f"anim/{sid}" not in ids:
                ids.append(f"anim/{sid}")
        if ids:
            out[move] = ids
    by_type = collections.defaultdict(collections.Counter)
    for move, ids in out.items():
        if move in moves:
            by_type[moves[move].get("type", "normal")][ids[0]] += 1
    generic = collections.Counter(ids[0] for ids in out.values())
    for move in motion:
        if move.startswith("_") or move in out:
            continue
        t = moves.get(move, {}).get("type", "normal")
        counter = by_type.get(t) or generic
        out[move] = [counter.most_common(1)[0][0]]
    doc = ("Sonidos de las animaciones de movimientos (tools/arte/sonidos_movimientos.py): los pbSEPlay de "
           "cada animación del EBDX move & common animation pack, en orden y hasta 3; los que EBDX no anima, "
           "el más común de su tipo. Archivos en assets/audio/se/anim/ (procedencia en data/audio_assets.json).")
    with open("data/battle_motion_sounds.json", "w", encoding="utf-8", newline="\n") as fh:
        fh.write(json.dumps({"_doc": doc, "moves": dict(sorted(out.items()))}, ensure_ascii=False, indent=1) + "\n")
    assets = json.load(open("data/audio_assets.json", encoding="utf-8"))
    assets["files"] = [f for f in assets["files"] if not f["target"].startswith(TARGET + "/")] + sorted(copied.values(), key=lambda f: f["target"])
    with open("data/audio_assets.json", "w", encoding="utf-8", newline="\n") as fh:
        fh.write(json.dumps(assets, ensure_ascii=False, indent=2) + "\n")
    print(f"{len(raw)} animaciones con sonido en EBDX, {len(copied)} sonidos copiados, {len(out)} movimientos con sonido; sin archivo: {sorted(missing)}")


if __name__ == "__main__":
    main()
