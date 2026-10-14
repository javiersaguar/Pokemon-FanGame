#!/usr/bin/env python3
"""Animación propia para cada movimiento (data/battle_motion_moves.json).

Lee las animaciones originales de Elite Battle DX (pack 17_ebdx_anim_pack, solo lectura): de cada
movimiento saca qué gráficos usa y con qué recorte, cuántas partículas, si viajan del atacante al
objetivo o se quedan en uno de los dos, el fondo que pone (color o imagen de 512×384), cómo tiñe al
objetivo, si lo sacude y cuánto dura. Con eso escribe la secuencia por fases que reproduce
src/battle/scene/battle_move_animation.gd con los gráficos originales, sin girarlos ni escalarlos.

Los movimientos que EBDX no tiene se arman con sus datos (tipo, categoría, a quién apunta,
contacto, puño, mordisco, corte, sonido, viento, curación, subida de características) y con los
gráficos que EBDX usa para su tipo; el gráfico se elige de forma estable por el id del movimiento.

Las 38 secuencias hechas a mano antes (las que ya están en el JSON sin "origen") no se tocan.
Copia los gráficos que hagan falta y los apunta en data/battle_motion_assets.json con su sha256.

Uso: python3 tools/arte/animaciones_movimientos.py <carpeta de recursos>
"""
import hashlib
import json
import os
import re
import shutil
import struct
import sys
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PACK = "17_ebdx_anim_pack"
CODE = "EBDX_Anim_Pack/Plugins/Elite Battle DX/[002] Animation Code"
GFX = "EBDX_Anim_Pack/Graphics/EBDX/Animations/Moves"
TARGET_DIR = "assets/sprites/ui/battle/moves"
SELF_TARGETS = {"self", "ally_side", "allies", "ally_team", "adjacent_ally_or_self", "adjacent_ally"}
FIELD_TARGETS = {"all", "foe_side"}

TYPE_SPECIAL_PATTERN = {
    "fire": "flames", "electric": "lightning", "ice": "ice_shards", "psychic": "psychic_rings",
    "ghost": "shadow_burst", "dark": "shadow_burst", "water": "water_splash", "grass": "petals",
    "poison": "mist", "ground": "ground_wave", "rock": "ground_wave", "fighting": "strike_sparks",
    "fairy": "charge", "dragon": "shadow_burst", "steel": "strike_sparks", "flying": "jet",
    "bug": "charge", "normal": "charge",
}
TRAVEL_PATTERNS = {"projectile", "beam", "jet", "pressure_jet", "petals", "rings", "wave"}


def png_size(path):
    with open(path, "rb") as f:
        head = f.read(24)
    return struct.unpack(">II", head[16:24])


def parse_blocks(code_dir):
    """{move: texto del bloque} de todas las defineMoveAnimation."""
    blocks = {}
    for base, _, files in os.walk(code_dir):
        for name in sorted(files):
            if not name.endswith(".rb"):
                continue
            text = open(os.path.join(base, name), encoding="utf-8", errors="ignore").read()
            parts = re.split(r"EliteBattle\.defineMoveAnimation\(:([A-Z0-9_]+)\)", text)
            for i in range(1, len(parts), 2):
                blocks[parts[i].lower()] = parts[i + 1]
    return blocks


def color_of(match):
    return [int(float(match.group(i))) for i in (1, 2, 3)]


def features(block, gfx_dir):
    """Lo que hace única a la animación original."""
    f = {"graphics": [], "alias": None}
    if "pbBitmap" not in block:
        m = re.search(r"playMoveAnimation\(:([A-Z0-9_]+)", block)
        if m:
            f["alias"] = m.group(1).lower()
        return f
    for m in re.finditer(r'pbBitmap\("Graphics/EBDX/Animations/Moves/([A-Za-z0-9_]+)"\)', block):
        name = m.group(1)
        path = os.path.join(gfx_dir, name + ".png")
        if not os.path.exists(path):
            continue
        before = block[max(0, m.start() - 400):m.start()]
        loops = re.findall(r"for \w+ in 0\.\.\.(\d+)", before)
        count = int(loops[-1]) if loops else 1
        after = block[m.end():m.end() + 500]
        rect = re.search(r"src_rect\.set\(\s*[^,]+,\s*[^,]+,\s*(\d+)\s*,\s*(\d+)\s*\)", after)
        f["graphics"].append({"name": name, "count": count,
                              "rect": [int(rect.group(1)), int(rect.group(2))] if rect else None,
                              "size": list(png_size(path))})
    bg = re.search(r"fill_rect\([^)]*Color\.new\((\d+),\s*(\d+),\s*(\d+)", block)
    f["backdrop"] = color_of(bg) if bg else None
    tint = {}
    for channel in ("red", "green", "blue"):
        m = re.search(r"@targetSprite\.tone\.%s\s*([+-])=" % channel, block)
        if m:
            tint[channel] = 1 if m.group(1) == "+" else -1
    color = re.search(r"@targetSprite\.color\s*=\s*Color\.new\((\d+),\s*(\d+),\s*(\d+)", block)
    f["flash"] = color_of(color) if color else None
    f["tint"] = tint
    f["shake"] = bool(re.search(r"@targetSprite\.ox\s*[+-]=|moveEntireScene", block))
    f["user_moves"] = bool(re.search(r"@userSprite\.(x|y)\s*[+-]=", block))
    f["user_anchor"] = bool(re.search(r"@userSprite\.get(Anchor|Center)", block))
    f["target_anchor"] = bool(re.search(r"@targetSprite\.get(Anchor|Center)", block))
    frames = [int(x) for x in re.findall(r"for \w+ in (?:0\.\.\.|1\.\.)(\d+)", block)]
    frames += [int(x) for x in re.findall(r"(\d+)\.times do", block)]
    f["frames"] = max(frames) if frames else 40
    f["sounds"] = re.findall(r'pbSEPlay\("([^"]+)"', block)
    return f


def stable(move_id, options):
    if not options:
        return None
    h = int(hashlib.sha1(move_id.encode()).hexdigest(), 16)
    return options[h % len(options)]


def usable(g):
    """Gráfico que se puede mostrar sin escalar: un recorte que divide la hoja, o la hoja entera."""
    w, h = g["size"]
    if g["name"].find("bg") >= 0 or max(w, h) > 320:
        return None
    rect = g["rect"]
    if rect and (rect[0] <= 0 or rect[1] <= 0 or w % rect[0] or h % rect[1]):
        rect = None
    if rect is None and (w > 160 or h > 160):
        return None
    return {"asset": g["name"], "frame": rect if rect else [], "count": max(1, min(10, g["count"]))}


def backdrop_image(f):
    for g in f.get("graphics", []):
        w, h = g["size"]
        if "bg" in g["name"] and h == 384 and w % 512 == 0:
            return g["name"]
    return None


def tint_color(f):
    if f.get("flash"):
        return f["flash"]
    t = f.get("tint") or {}
    if not t:
        return None
    return [255 if t.get(c, 0) > 0 else (96 if t.get(c, 0) < 0 else 200) for c in ("red", "green", "blue")]


def pattern_for(move, f, travels):
    flags = move.get("flags", {})
    mtype = move["type"]
    cat = move["category"]
    name = move.get("name_en", "").lower()
    target = move.get("target", "normal")
    if target in SELF_TARGETS or (cat == "status" and target in FIELD_TARGETS):
        if move.get("heal") or flags.get("heal"):
            return "healing"
        boosts = move.get("boosts") or {}
        if "protect" in name or "detect" in name or "shield" in name or "guard" in name:
            return "shield"
        if any(k in boosts for k in ("def", "spd")):
            return "shield_motes"
        if any(k in boosts for k in ("atk", "spa")):
            return "swords"
        return "healing" if mtype in ("fairy", "normal", "grass") else "charge"
    if cat == "status":
        if flags.get("sound"):
            return "rings"
        if "powder" in name or "spore" in name:
            return "mist"
        if mtype in ("psychic", "ghost", "dark"):
            return "psychic_rings"
        return "charge"
    if flags.get("punch"):
        return "heavy_punch" if move.get("power", 0) >= 100 else "punch"
    if flags.get("slicing"):
        return "cut"
    if flags.get("bite"):
        return "peck"
    if "kick" in name or "stomp" in name:
        return "chop"
    if flags.get("sound"):
        return "rings"
    if flags.get("wind"):
        return "jet"
    if target in ("all_adjacent_foes", "all_adjacent") and mtype in ("ground", "rock"):
        return "ground_wave"
    if flags.get("contact"):
        if move.get("multihit"):
            return "strike_sparks"
        return "slash" if mtype in ("dragon", "dark", "steel", "bug") and cat == "physical" else ""
    if travels:
        if "beam" in name or "ray" in name or (f and any(g["count"] >= 12 for g in f.get("graphics", []))):
            return "beam"
        if mtype == "water":
            return "pressure_jet"
        if flags.get("bullet"):
            return "projectile"
        return "jet" if mtype in ("flying", "dragon") else "projectile"
    return TYPE_SPECIAL_PATTERN.get(mtype, "charge")


def build(move_id, move, f, pools):
    cat = move["category"]
    target = move.get("target", "normal")
    flags = move.get("flags", {})
    self_move = target in SELF_TARGETS or (cat == "status" and target in FIELD_TARGETS)
    graphics = []
    if f:
        seen = set()
        for g in f["graphics"]:
            u = usable(g)
            if u and u["asset"] not in seen:
                seen.add(u["asset"])
                graphics.append(u)
    origin = "ebdx" if graphics else "datos"
    if not graphics:
        pool = pools.get((move["type"], "status" if cat == "status" else "attack")) or pools.get((move["type"], "any")) or pools["any"]
        graphics = [dict(stable(move_id, pool))]
    travels = bool(f and f["user_anchor"] and f["target_anchor"] and not self_move)
    if not f and cat != "status" and not self_move and not flags.get("contact"):
        # Sin original: viaja si el nombre lo dice (rayo, bola, disparo, pulso...) o es un proyectil.
        name = move.get("name_en", "").lower()
        travels = flags.get("bullet", False) or any(w in name for w in (
            "beam", "ray", "ball", "bomb", "shot", "pulse", "blast", "cannon", "missile", "spear", "arrow", "sphere"))
    pattern = pattern_for(move, f, travels)
    travels = pattern in TRAVEL_PATTERNS
    frames = f["frames"] if f else (48 if cat == "status" else 36)
    longest = 0.8 if cat == "physical" else 1.0
    duration = round(min(longest, max(0.5, frames / 40.0)), 2)
    phases = []
    main = graphics[0]
    first = {"asset": main["asset"], "frame": main["frame"], "count": min(8, max(3, main["count"])),
             "pattern": pattern, "duration": duration if len(graphics) == 1 else round(duration * 0.65, 2),
             "focus": "user" if self_move else "target", "status_asset": True,
             "kind": "sparkle" if (self_move or cat == "status") and not travels else ("orb" if travels else "burst"),
             "impact": not self_move and cat != "status" and len(graphics) == 1}
    phases.append(first)
    if len(graphics) > 1 and not self_move:
        hit = graphics[1]
        phases.append({"asset": hit["asset"], "frame": hit["frame"], "count": min(6, max(2, hit["count"])),
                       "pattern": "strike_sparks" if cat != "status" else "charge",
                       "duration": round(max(0.3, duration * 0.35), 2), "focus": "target", "status_asset": True,
                       "kind": "burst" if cat != "status" else "sparkle", "impact": cat != "status"})
    spec = {"origen": origin, "phases": phases, "duration": duration}
    if flags.get("contact") and not self_move:
        spec["user_motion"] = "quick" if move.get("priority", 0) > 0 else "lunge"
    elif self_move:
        spec["user_motion"] = "hop" if flags.get("dance") else ("flash" if cat == "status" else "")
    elif flags.get("sound"):
        spec["user_motion"] = "sway"
    if f:
        image = backdrop_image(f)
        if image:
            spec["backdrop_asset"] = image
        elif f.get("backdrop"):
            spec["backdrop"] = f["backdrop"]
        tint = tint_color(f)
        if tint and not self_move:
            spec["target_tint"] = tint
        if f.get("shake") and not self_move:
            spec["shake"] = True
    elif cat != "status" and move.get("power", 0) >= 100:
        spec["shake"] = True
    return spec


def main():
    if len(sys.argv) < 2:
        raise SystemExit(__doc__)
    res = Path(sys.argv[1]) / PACK
    code_dir = res / CODE
    gfx_dir = res / GFX
    moves = json.loads((ROOT / "data/generated/moves.json").read_text())
    blocks = parse_blocks(code_dir)
    feats = {k: features(v, gfx_dir) for k, v in blocks.items()}
    # Alias: la animación de otro movimiento (EBDX las reutiliza).
    for k, f in list(feats.items()):
        seen = {k}
        while f and f.get("alias") and f["alias"] in feats and f["alias"] not in seen:
            seen.add(f["alias"])
            f = feats[f["alias"]]
        feats[k] = f if f and f.get("graphics") else None
    # Gráficos de EBDX por tipo, para los movimientos que no tiene: solo los tres más usados por los
    # movimientos de ese tipo (los de energía genérica), no los de un movimiento muy concreto.
    counts = defaultdict(Counter)
    shapes = {}
    for k, f in feats.items():
        if not f or k not in moves:
            continue
        m = moves[k]
        bucket = "status" if m["category"] == "status" else "attack"
        for g in {g["name"]: g for g in f["graphics"]}.values():
            u = usable(g)
            if u:
                shapes[u["asset"]] = u
                for key in ((m["type"], bucket), (m["type"], "any"), "any"):
                    counts[key][u["asset"]] += 1
    pools = {key: [shapes[a] for a, _ in sorted(c.items(), key=lambda kv: (-kv[1], kv[0]))[:3]]
             for key, c in counts.items()}
    out_path = ROOT / "data/battle_motion_moves.json"
    current = json.loads(out_path.read_text())
    result = {}
    stats = Counter()
    # Primero las que ya estaban, en su orden; después las nuevas, por orden alfabético.
    order = [k for k in current if k in moves] + sorted(k for k in moves if k not in current)
    for move_id in order:
        if move_id in current and "origen" not in current[move_id]:
            result[move_id] = current[move_id]
            stats["a mano"] += 1
            continue
        spec = build(move_id, moves[move_id], feats.get(move_id), pools)
        result[move_id] = spec
        stats[spec["origen"]] += 1
    out_path.write_text(json.dumps(result, ensure_ascii=False, indent=1) + "\n")
    # Gráficos: copiar los que falten y apuntarlos.
    manifest_path = ROOT / "data/battle_motion_assets.json"
    manifest = json.loads(manifest_path.read_text())
    known = {e["target"] for e in manifest["files"]}
    needed = set()
    for spec in result.values():
        for phase in spec.get("phases", [spec]):
            if "asset" in phase:
                needed.add(phase["asset"])
        if spec.get("backdrop_asset"):
            needed.add(spec["backdrop_asset"])
    copied = 0
    for name in sorted(needed):
        target = "%s/%s.png" % (TARGET_DIR, name)
        source = gfx_dir / (name + ".png")
        if target in known or not source.exists():
            continue
        dest = ROOT / target
        shutil.copyfile(source, dest)
        manifest["files"].append({"pack": PACK, "source": "%s/%s.png" % (GFX, name), "target": target,
                                  "size": list(png_size(source)),
                                  "sha256": hashlib.sha256(source.read_bytes()).hexdigest()})
        copied += 1
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n")
    print("Animaciones:", dict(stats), "| total", len(result), "| gráficos nuevos", copied)


if __name__ == "__main__":
    main()
