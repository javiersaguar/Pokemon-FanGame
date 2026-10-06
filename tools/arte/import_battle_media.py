#!/usr/bin/env python3
"""Copia los gráficos originales EBDX/NikDie utilizados, sin alterarlos."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
parser = argparse.ArgumentParser()
parser.add_argument("source", type=Path)
args = parser.parse_args()
root = Path(__file__).resolve().parents[2]
manifest = json.loads((root / "data/battle_motion_assets.json").read_text())
for entry in manifest["files"]:
    source = args.source / entry["pack"] / entry["source"]
    if hashlib.sha256(source.read_bytes()).hexdigest() != entry["sha256"]:
        raise SystemExit(f"El original ha cambiado: {source}")
    destination = root / entry["target"]
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(source, destination)
print(f"Copiados {len(manifest['files'])} gráficos originales.")
