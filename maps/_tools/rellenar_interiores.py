#!/usr/bin/env python3
"""Vuelca en data/interiores/<ciudad>.json el contenido escrito a mano de una ciudad: tipo, nombre,
gente (nombre, aspecto, papel y frases) y carteles de cada sala, y las salas de dentro («padre»).

El contenido está en maps/_tools/contenido_interiores/<ciudad>.py, con un diccionario SALAS:
    "zaragoza/sala_calle_24_29": {
        "tipo": "basilica", "nombre": "Basílica del Pilar",
        "gente": [("Sacristán", "npc_old_man", "cura", ["frase", "frase"]), ...],
        "carteles": [("pared", ["frase"]), ...],
        "dentro": {"zaragoza/sala_calle_24_29_capilla": {"tipo": ..., "nombre": ..., "gente": [...], "carteles": [...]}},
    }
La persona que da un regalo (la que el esqueleto dejó con "regalo") conserva su nodo, su aspecto y
su regalo: la primera persona del contenido marcada con papel que empiece por «regalo:» le pone el
papel y las frases (por ejemplo "regalo:cocina").

Después: python3 maps/_tools/planificar_interiores.py <ciudad> y pintar_interiores_datos.gd.
Uso: python3 maps/_tools/rellenar_interiores.py <ciudad>
"""
import importlib.util
import json
import os
import sys

sys.dont_write_bytecode = True

RAIZ = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def personas(lista, previas):
    regalo = [p for p in previas if "regalo" in p]
    out = []
    for nombre, aspecto, papel, frases in lista:
        if papel.startswith("regalo:") and regalo:
            p = dict(regalo.pop(0))
            p["papel"] = papel.split(":", 1)[1]
            p["frases"] = list(frases)
            p["nombre"] = nombre
            out.append(p)
            continue
        out.append({"nombre": nombre, "aspecto": aspecto, "papel": papel.split(":")[-1], "frases": list(frases)})
    if regalo:
        raise SystemExit("falta la persona del regalo: %s" % regalo)
    return out


def entrada(previa, c):
    e = {k: v for k, v in previa.items() if k in ("pieza", "calle", "padre")}
    e["tipo"] = c["tipo"]
    e["nombre"] = c["nombre"]
    e["personas"] = personas(c.get("gente", []), previa.get("personas", []))
    e["carteles"] = [{"sobre": s, "frases": list(f)} for s, f in c.get("carteles", [])]
    return e


def main():
    ciudad = sys.argv[1]
    ruta = os.path.join(RAIZ, "data/interiores/%s.json" % ciudad)
    datos = json.load(open(ruta, encoding="utf-8"))
    spec = importlib.util.spec_from_file_location("c", os.path.join(RAIZ, "maps/_tools/contenido_interiores/%s.py" % ciudad))
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    salas = datos["interiores"]
    faltan = [k for k in salas if k not in mod.SALAS and "padre" not in salas[k]]
    if faltan:
        raise SystemExit("salas sin contenido: %s" % faltan)
    nuevas = {}
    for k, c in mod.SALAS.items():
        if k not in salas:
            raise SystemExit("%s no está en el esqueleto" % k)
        nuevas[k] = entrada(salas[k], c)
        for hijo, ch in c.get("dentro", {}).items():
            e = entrada(salas.get(hijo, {}), ch)
            e["padre"] = k
            nuevas[hijo] = e
    datos["interiores"] = nuevas
    with open(ruta, "w", encoding="utf-8", newline="\n") as f:
        json.dump(datos, f, ensure_ascii=False, indent=1)
        f.write("\n")
    print("%s: %d salas" % (ciudad, len(nuevas)))


if __name__ == "__main__":
    main()
