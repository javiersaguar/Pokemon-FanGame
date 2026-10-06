#!/usr/bin/env python3
"""Reproduce las copias originales y verifica sus hashes, sin convertir audio."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil

parser = argparse.ArgumentParser()
parser.add_argument("source", type=Path, help="Carpeta Pokemon-Panchito-recursos")
args = parser.parse_args()
root = Path(__file__).resolve().parents[2]
manifest = json.loads((root / "data/audio_assets.json").read_text())
for entry in manifest["files"]:
    source = args.source / entry["pack"] / entry["source"]
    if hashlib.sha256(source.read_bytes()).hexdigest() != entry["sha256"]:
        raise SystemExit(f"El archivo original ha cambiado: {source}")
    destination = root / entry["target"]
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(source, destination)
print(f"Copiados {len(manifest['files'])} archivos originales.")
