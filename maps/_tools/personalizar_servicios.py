#!/usr/bin/env python3
"""Pone gente y frases propias de su ciudad en los locales de servicio (Centro Pokémon u hospital,
Mercadona y estanco) sin volver a pintarlos: cambia en la escena ya guardada las frases (y el nombre
que sale en el diálogo) de la persona de la sala (Paciente o Cliente), del Visitante y de la placa de
la ciudad (PlacaCiudad). No toca muebles, puertas, la enfermera, el dependiente ni el PC.

El contenido está en maps/_tools/contenido_interiores/_servicios.py (SERVICIOS = {mapa: {nodo: ...}}):
    "zaragoza/centro": {
        "Paciente": ("Nombre", ["frase", ...]),
        "Visitante": ("Nombre", ["frase", ...]),
        "PlacaCiudad": ["línea", ...],
    }
Uso: python3 maps/_tools/personalizar_servicios.py [mapa ...]   (sin mapas: todos los del contenido)
"""
import importlib.util
import os
import re
import sys

sys.dont_write_bytecode = True

RAIZ = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def cadena(texto):
    return '"%s"' % texto.replace("\\", "\\\\").replace('"', '\\"')


def cambiar_nodo(texto, nodo, nombre, frases):
    inicio = re.search(r'^\[node name="%s" [^\n]*parent="Entities"[^\n]*\]\n' % re.escape(nodo), texto, re.M)
    if not inicio:
        return texto, False
    fin = texto.find("\n[", inicio.end())
    fin = len(texto) if fin < 0 else fin + 1
    bloque = texto[inicio.end():fin]
    lineas = "lines = PackedStringArray(%s)" % ", ".join(cadena(f) for f in frases)
    if re.search(r"^lines = PackedStringArray\(.*\)$", bloque, re.M):
        bloque = re.sub(r"^lines = PackedStringArray\(.*\)$", lambda m: lineas, bloque, count=1, flags=re.M)
    else:
        bloque = lineas + "\n" + bloque
    if nombre is not None:
        nuevo = "display_name = %s" % cadena(nombre)
        if re.search(r"^display_name = .*$", bloque, re.M):
            bloque = re.sub(r"^display_name = .*$", lambda m: nuevo, bloque, count=1, flags=re.M)
        else:
            bloque = nuevo + "\n" + bloque
    return texto[:inicio.end()] + bloque + texto[fin:], True


def main():
    spec = importlib.util.spec_from_file_location("s", os.path.join(RAIZ, "maps/_tools/contenido_interiores/_servicios.py"))
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    mapas = sys.argv[1:] or list(mod.SERVICIOS)
    for mapa in mapas:
        ruta = os.path.join(RAIZ, "maps/%s.tscn" % mapa)
        texto = open(ruta, encoding="utf-8").read()
        cambios = []
        for nodo, valor in mod.SERVICIOS[mapa].items():
            nombre, frases = (None, valor) if nodo == "PlacaCiudad" else valor
            texto, hecho = cambiar_nodo(texto, nodo, nombre, frases)
            if not hecho:
                raise SystemExit("%s no tiene el nodo %s" % (mapa, nodo))
            cambios.append(nodo)
        with open(ruta, "w", encoding="utf-8", newline="\n") as f:
            f.write(texto)
        print("%s: %s" % (mapa, ", ".join(cambios)))


if __name__ == "__main__":
    main()
