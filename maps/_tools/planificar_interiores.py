#!/usr/bin/env python3
"""Planifica los interiores de data/interiores/<ciudad>.json.

Cada entrada dice qué es el edificio (tipo, nombre, personas con sus frases, carteles
que se examinan). Este script rellena lo que falte de la distribución: tamaño, puerta,
suelo, pared, alfombras, muebles con su casilla y el sitio de cada persona y cartel.
Solo coloca piezas del catálogo (data/interiores/_piezas.json): no dibuja nada.

Comprueba que se llega andando a la salida, a cada persona, a cada cartel y a cada paso
a otra sala, y que no hay dos salas con la misma firma (suelo, pared, muebles y casillas).

Uso:
  python3 maps/_tools/planificar_interiores.py <ciudad> [<ciudad> ...] [--rehacer] [--inventario <json>]
    --rehacer     vuelve a calcular la distribución aunque ya exista
    --inventario  JSON de maps/_tools/inventario_interiores.gd (pasos y apariciones que hay que conservar)
  python3 maps/_tools/planificar_interiores.py --firmas   comprueba las firmas de todos los ficheros
"""

import hashlib
import json
import os
import random
import sys
import unicodedata

RAIZ = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
DATOS = os.path.join(RAIZ, 'data', 'interiores')
CAT = json.load(open(os.path.join(DATOS, '_piezas.json'), encoding='utf-8'))
MUEBLES = CAT['muebles']
MADERAS = ['madera', 'oliva', 'nogal', 'menta', 'verde', 'mostaza']
MOSTRADORES = ['turquesa', 'blanco', 'cristal', 'madera', 'azul', 'naranja', 'oliva', 'celeste', 'verde', 'tablas']
CAMAS = ['cama_rosa', 'cama_azul', 'cama_colcha_rosa', 'cama_colcha_azul', 'cama_celeste']
TABURETES = ['taburete_rojo', 'taburete_marron', 'taburete_amarillo', 'taburete_verde', 'banqueta_roja', 'banqueta_azul']
MIRA = {'abajo': 0, 'izquierda': 1, 'derecha': 2, 'arriba': 3}
DIRS = [(0, 1), (-1, 0), (1, 0), (0, -1)]


# --------------------------------------------------------------------------- recetas
# Cada paso: (probabilidad, primitiva, argumentos). Las piezas pueden llevar {m} (madera
# de la sala), {c} (color de mostrador), {t} (taburete) y {cama}.

def P(prob, prim, *args):
    return (prob, prim, args)


CASA_SUELOS = ['parquet', 'moqueta_beige', 'hidraulica_rosa', 'rombos_lila', 'rombos_verdes', 'tatami_verde', 'alfombra_naranja']
CASA_PAREDES = ['salvia', 'beige_rayado', 'crema', 'melocoton', 'mostaza', 'retro', 'topo', 'lima', 'amarillo_cuadros']

RECETAS = {
    'vivienda': {
        'tamanos': [(10, 8), (11, 8), (12, 9), (12, 8), (13, 9), (11, 9), (12, 10), (14, 10)],
        'suelos': CASA_SUELOS, 'paredes': CASA_PAREDES,
        'pasos': [
            P(0.95, 'arriba', [['fogones', 'fregadero', 'nevera'], ['nevera_alta', 'encimera', 'fogones'],
                               ['fregadero', 'fogones', 'nevera_alta'], ['alacena', 'fogones', 'fregadero'],
                               ['fogones', 'encimera'], ['nevera', 'fregadero', 'fogones']]),
            P(0.85, 'arriba', [['tele'], ['tele', 'planta'], ['cajon_oliva', 'tele'], ['planta', 'tele'], ['tele', 'estante_{m}']]),
            P(0.7, 'arriba', [['estanteria_alta_{m}'], ['estanteria_baja_{m}', 'estante_{m}'], ['armario_{m}', 'estanteria_alta_{m}'], ['vitrina_madera']]),
            P(0.75, 'suelo', 'centro', [[('mesa_cristal', 0, 0), ('silla_derecha', -1, 0), ('silla_izquierda', 2, 0)],
                                        [('mesa_cristal', 0, 0), ('{t}', -1, 1), ('{t}', 2, 1)],
                                        [('mesa_cristal_larga', 0, 0), ('silla_derecha', -1, 0), ('silla_izquierda', 3, 0)],
                                        [('mesa_cristal_larga', 0, 0), ('{t}', 0, 2), ('{t}', 2, 2)]]),
            P(0.55, 'suelo', 'lado', [[('sofa', 0, 0)], [('sillon_derecha', 0, 0), ('mesa_cristal', 1, 1), ('sillon_izquierda', 3, 0)]]),
            P(0.35, 'arriba', [['{cama}', 'cajon_rosa'], ['cajon_gris', '{cama}']]),
            P(0.9, 'esquina', [['planta'], ['arbol_maceta'], ['palmera_maceta']]),
            P(0.45, 'esquina', [['planta'], ['papelera'], ['caja']]),
            P(0.6, 'alfombra', ['alfombra_roja', 'alfombra_naranja', 'moqueta_azul', 'tatami_verde', 'moqueta_beige']),
        ],
    },
    'piso': {
        'tamanos': [(10, 8), (9, 8), (11, 8), (10, 9), (12, 8)],
        'suelos': CASA_SUELOS + ['rombos_morados', 'losa_crema'], 'paredes': CASA_PAREDES + ['menta', 'gris_cemento'],
        'pasos': [
            P(0.9, 'arriba', [['fogones', 'nevera'], ['fregadero', 'fogones'], ['nevera_alta', 'fogones'], ['encimera', 'nevera']]),
            P(0.6, 'arriba', [['tele'], ['tele_pequena'], ['consola', 'tele']]),
            P(0.8, 'suelo', 'cualquiera', [[('sofa', 0, 0)], [('mesa_cristal', 0, 0), ('{t}', 2, 1)], [('sillon_derecha', 0, 0), ('mesa_cristal', 1, 1)]]),
            P(0.5, 'arriba', [['{cama}'], ['ropero_{m}']]),
            P(0.7, 'esquina', [['planta'], ['cajas'], ['papelera'], ['caja']]),
            P(0.4, 'alfombra', ['alfombra_naranja', 'moqueta_azul', 'alfombra_roja']),
        ],
    },
    'portal': {
        'tamanos': [(10, 8), (11, 9), (12, 8), (9, 9), (12, 9)],
        'suelos': ['losa_crema', 'losa_gris', 'rombos_oscuros', 'hidraulica_rosa', 'piedra', 'rombos_lila'],
        'paredes': ['madera_oscura', 'topo', 'crema', 'gris_cemento', 'beige_rayado', 'mostaza'],
        'pasos': [
            P(1.0, 'arriba', [['escalera_mano'], ['escalera_mano', 'planta'], ['planta', 'escalera_mano']]),
            P(0.9, 'arriba', [['archivador_bajo'], ['cajonera_gris', 'cajon_gris'], ['cajonera_azul'], ['archivador', 'archivador']]),
            P(0.7, 'barra', 'lado', 3, False),
            P(0.6, 'suelo', 'lado', [[('banco_rojo', 0, 0)], [('sillon_derecha', 0, 0)], [('{t}', 0, 0), ('{t}', 1, 0)]]),
            P(0.9, 'esquina', [['arbol_maceta'], ['palmera_maceta'], ['planta']]),
            P(0.5, 'alfombra', ['alfombra_roja', 'moqueta_azul', 'moqueta_beige']),
        ],
    },
    'dormitorio': {
        'tamanos': [(8, 7), (9, 7), (9, 8), (10, 7), (8, 8)],
        'suelos': CASA_SUELOS, 'paredes': CASA_PAREDES,
        'pasos': [
            P(1.0, 'arriba', [['{cama}', 'cajon_rosa'], ['cajon_gris', '{cama}'], ['{cama}'], ['{cama}', 'ropero_{m}']]),
            P(0.8, 'arriba', [['ropero_{m}'], ['armario_{m}', 'cajonera_roja'], ['cajonera_gris'], ['estante_{m}']]),
            P(0.6, 'esquina', [['planta'], ['tele_pequena'], ['consola'], ['papelera']]),
            P(0.5, 'alfombra', ['alfombra_roja', 'alfombra_naranja', 'moqueta_azul']),
        ],
    },
    'rural': {
        'tamanos': [(10, 8), (11, 8), (12, 9), (10, 9), (13, 9)],
        'suelos': ['piedra', 'parquet', 'tatami_verde', 'losa_crema', 'moqueta_beige'],
        'paredes': ['salvia', 'beige_rayado', 'madera_oscura', 'mostaza', 'topo'],
        'pasos': [
            P(0.9, 'arriba', [['fogones', 'alacena'], ['alacena', 'fregadero'], ['fogones', 'encimera']]),
            P(0.8, 'suelo', 'centro', [[('mesa_cristal_larga', 0, 0), ('banqueta_roja', 0, 2), ('banqueta_roja', 2, 2)],
                                       [('mesa_cristal', 0, 0), ('taburete_marron', -1, 1), ('taburete_marron', 2, 1)]]),
            P(0.6, 'arriba', [['{cama}'], ['escalera_mano']]),
            P(0.8, 'esquina', [['cajas'], ['caja'], ['planta']]),
            P(0.6, 'esquina', [['cajas'], ['arbol_maceta']]),
        ],
    },
    'bar': {
        'tamanos': [(12, 9), (13, 9), (14, 10), (12, 10), (15, 10), (11, 9)],
        'suelos': ['rombos_oscuros', 'parquet', 'losa_crema', 'hidraulica_rosa', 'rombos_morados', 'piedra'],
        'paredes': ['madera_oscura', 'marino', 'mostaza', 'retro', 'beige_rayado', 'topo'],
        'pasos': [
            P(1.0, 'arriba', [['nevera_alta', 'encimera', 'estanteria_alta_nogal'], ['estanteria_baja_nogal', 'encimera', 'nevera_alta'],
                              ['alacena', 'encimera', 'alacena'], ['nevera_alta', 'fogones', 'encimera']]),
            P(1.0, 'barra', 'arriba', 0, True),
            P(0.85, 'suelo', 'cualquiera', [[('mesa_cristal', 0, 0), ('{t}', -1, 1), ('{t}', 2, 1)],
                                            [('mesa_cristal', 0, 0), ('silla_derecha', -1, 0), ('silla_izquierda', 2, 0)]]),
            P(0.6, 'suelo', 'cualquiera', [[('mesa_cristal', 0, 0), ('{t}', 2, 0)], [('mesa_cristal', 0, 0), ('{t}', -1, 0)]]),
            P(0.6, 'arriba', [['tele'], ['tele_pequena']]),
            P(0.6, 'esquina', [['papelera'], ['planta'], ['cajas']]),
            P(0.2, 'encima', ['plato_comida', 'taza', 'plato']),
        ],
    },
    'restaurante': {
        'tamanos': [(13, 10), (14, 10), (15, 11), (12, 10), (16, 11)],
        'suelos': ['parquet', 'hidraulica_rosa', 'losa_crema', 'rombos_verdes', 'alfombra_roja'],
        'paredes': ['beige_rayado', 'mostaza', 'retro', 'melocoton', 'madera_oscura', 'crema'],
        'pasos': [
            P(1.0, 'arriba', [['fogones', 'fregadero', 'encimera', 'nevera_alta'], ['nevera_alta', 'fogones', 'fogones', 'encimera']]),
            P(0.7, 'barra', 'arriba', 0, False),
            P(1.0, 'suelo', 'cualquiera', [[('mesa_cristal', 0, 0), ('silla_derecha', -1, 0), ('silla_izquierda', 2, 0)]]),
            P(1.0, 'suelo', 'cualquiera', [[('mesa_cristal', 0, 0), ('{t}', -1, 1), ('{t}', 2, 1)], [('mesa_cristal_larga', 0, 0), ('{t}', 0, 2), ('{t}', 2, 2)]]),
            P(0.7, 'suelo', 'cualquiera', [[('mesa_cristal', 0, 0), ('silla_derecha', -1, 0), ('silla_izquierda', 2, 0)]]),
            P(0.7, 'esquina', [['planta'], ['arbol_maceta'], ['palmera_maceta']]),
            P(0.7, 'encima', ['plato_comida', 'plato', 'jarron_flores', 'taza']),
        ],
    },
    'panaderia': {
        'tamanos': [(10, 8), (11, 8), (12, 9), (10, 9)],
        'suelos': ['hidraulica_rosa', 'losa_crema', 'parquet', 'rombos_lila', 'azulejo_menta'],
        'paredes': ['amarillo_cuadros', 'crema', 'melocoton', 'mostaza', 'beige_rayado'],
        'pasos': [
            P(1.0, 'arriba', [['estanteria_baja_{m}', 'estanteria_baja_{m}'], ['estanteria_alta_{m}', 'fogones'], ['alacena', 'encimera', 'alacena']]),
            P(1.0, 'barra', 'arriba', 0, False),
            P(0.8, 'arriba', [['vitrina_madera'], ['vitrina_blanca'], ['vitrina_alta']]),
            P(0.6, 'suelo', 'lado', [[('mesa_cristal', 0, 0), ('{t}', 2, 1)], [('cajas', 0, 0)]]),
            P(0.7, 'esquina', [['cajas'], ['caja'], ['planta']]),
            P(0.9, 'encima', ['plato_comida', 'plato', 'taza']),
        ],
    },
    'tienda': {
        'tamanos': [(10, 8), (11, 9), (12, 9), (12, 8), (13, 9)],
        'suelos': ['losa_crema', 'losa_gris', 'parquet', 'rombos_lila', 'moqueta_azul', 'rombos_verdes', 'hidraulica_rosa'],
        'paredes': ['crema', 'retro', 'melocoton', 'beige_rayado', 'menta', 'topo', 'lima'],
        'pasos': [
            P(1.0, 'arriba', [['estanteria_alta_{m}', 'estanteria_alta_{m}'], ['vitrina_madera', 'estanteria_alta_{m}'], ['estanteria_baja_{m}', 'vitrina_blanca', 'estanteria_baja_{m}']]),
            P(1.0, 'barra', 'lado', 3, False),
            P(0.8, 'suelo', 'centro', [[('isla_{c}', 0, 0)], [('estanteria_baja_{m}', 0, 0), ('estanteria_baja_{m}', 2, 0)], [('vitrina_blanca', 0, 0), ('vitrina_blanca', 2, 0)]]),
            P(0.6, 'arriba', [['vitrina_alta'], ['armario_{m}'], ['cajonera_azul']]),
            P(0.8, 'esquina', [['planta'], ['cajas'], ['papelera']]),
        ],
    },
    'floristeria': {
        'tamanos': [(10, 8), (11, 8), (12, 9)],
        'suelos': ['tatami_verde', 'losa_crema', 'rombos_verdes', 'parquet'],
        'paredes': ['lima', 'salvia', 'menta', 'crema'],
        'pasos': [
            P(1.0, 'arriba', [['arbol_maceta', 'palmera_maceta', 'arbol_maceta'], ['palmera_maceta', 'planta', 'palmera_maceta']]),
            P(1.0, 'barra', 'lado', 3, False),
            P(1.0, 'suelo', 'centro', [[('planta', 0, 0), ('planta', 1, 0), ('planta', 2, 0)], [('arbol_maceta', 0, 0), ('planta', 1, 0), ('arbol_maceta', 2, 0)]]),
            P(1.0, 'esquina', [['planta'], ['palmera_maceta']]),
            P(1.0, 'esquina', [['planta'], ['arbol_maceta']]),
            P(0.8, 'esquina', [['cajas'], ['planta']]),
            P(0.8, 'encima', ['jarron_flores']),
        ],
    },
    'farmacia': {
        'tamanos': [(10, 8), (11, 8), (12, 9)],
        'suelos': ['azulejo_menta', 'losa_crema', 'losa_gris'],
        'paredes': ['menta', 'crema', 'azulejo_azul'],
        'pasos': [
            P(1.0, 'arriba', [['estanteria_alta_menta', 'estanteria_alta_menta'], ['estanteria_baja_menta', 'vitrina_blanca', 'estanteria_baja_menta']]),
            P(1.0, 'barra', 'centro', 3, False),
            P(0.7, 'arriba', [['vitrina_blanca_estrecha'], ['vitrina_alta']]),
            P(0.6, 'suelo', 'lado', [[('banco_rojo', 0, 0)], [('{t}', 0, 0), ('{t}', 1, 0)]]),
            P(0.7, 'esquina', [['planta'], ['papelera']]),
        ],
    },
    'oficina': {
        'tamanos': [(12, 9), (13, 9), (14, 10), (12, 10), (15, 10), (16, 11)],
        'suelos': ['moqueta_azul', 'losa_gris', 'moqueta_beige', 'rombos_lila', 'losa_crema'],
        'paredes': ['gris_cemento', 'crema', 'topo', 'beige_rayado', 'madera_oscura', 'menta'],
        'pasos': [
            P(1.0, 'arriba', [['archivo_alto', 'archivo_alto'], ['armario_archivo', 'archivador_bajo', 'taquilla_archivo'], ['archivo_alto', 'archivador']]),
            P(1.0, 'suelo', 'cualquiera', [[('mostrador_{c}', 0, 0), ('banqueta_azul', 1, 2)], [('mostrador_{c}', 0, 0), ('banqueta_roja', 1, 2)]]),
            P(0.85, 'suelo', 'cualquiera', [[('mostrador_{c}', 0, 0), ('banqueta_azul', 1, 2)], [('mesa_cristal', 0, 0), ('banqueta_azul', 0, 2)]]),
            P(0.5, 'suelo', 'cualquiera', [[('mostrador_{c}', 0, 0), ('banqueta_azul', 1, 2)]]),
            P(0.6, 'arriba', [['ordenador'], ['maquina_billetes'], ['tele']]),
            P(0.8, 'esquina', [['arbol_maceta'], ['palmera_maceta'], ['planta']]),
            P(0.6, 'esquina', [['papelera'], ['cajas']]),
            P(0.4, 'encima', ['libro_abierto', 'taza']),
        ],
    },
    'banco': {
        'tamanos': [(13, 10), (14, 10), (12, 10), (15, 11)],
        'suelos': ['losa_crema', 'losa_gris', 'rombos_oscuros', 'moqueta_azul'],
        'paredes': ['madera_oscura', 'crema', 'gris_cemento', 'topo'],
        'pasos': [
            P(1.0, 'barra', 'arriba', 0, False),
            P(1.0, 'arriba', [['archivo_alto'], ['armario_archivo', 'taquilla_archivo']]),
            P(0.9, 'suelo', 'lado', [[('banco_rojo', 0, 0)], [('sofa', 0, 0)]]),
            P(0.8, 'lado', [['maquina_billetes'], ['maquina_billetes', 'maquina_billetes']]),
            P(1.0, 'esquina', [['arbol_maceta'], ['palmera_maceta']]),
            P(0.7, 'esquina', [['planta'], ['papelera']]),
            P(0.5, 'alfombra', ['alfombra_roja', 'moqueta_azul']),
        ],
    },
    'comisaria': {
        'tamanos': [(12, 9), (13, 10), (14, 10)],
        'suelos': ['losa_gris', 'rombos_oscuros', 'moqueta_azul', 'chapa'],
        'paredes': ['gris_cemento', 'marino', 'topo', 'gris_raya_roja'],
        'pasos': [
            P(1.0, 'barra', 'centro', 4, False),
            P(1.0, 'arriba', [['taquilla_azul', 'taquilla_azul', 'archivo_alto'], ['archivo_alto', 'taquilla_gris', 'taquilla_gris']]),
            P(0.8, 'suelo', 'lado', [[('banco_rojo', 0, 0)], [('banqueta_azul', 0, 0), ('banqueta_azul', 1, 0)]]),
            P(0.6, 'arriba', [['ordenador'], ['tele']]),
            P(0.6, 'esquina', [['papelera'], ['cajas']]),
        ],
    },
    'aula': {
        'tamanos': [(12, 10), (13, 10), (14, 11), (12, 11)],
        'suelos': ['parquet', 'rombos_verdes', 'losa_crema', 'tatami_verde', 'moqueta_beige'],
        'paredes': ['lima', 'salvia', 'crema', 'beige_rayado', 'melocoton'],
        'pasos': [
            P(1.0, 'arriba', [['estanteria_alta_{m}', 'mostrador_{c}'], ['mostrador_{c}', 'estanteria_baja_{m}'], ['armario_{m}', 'mostrador_{c}', 'armario_{m}']]),
            P(1.0, 'filas', '{t}', 'mesa_cristal', 1),
            P(0.7, 'esquina', [['planta'], ['papelera']]),
            P(0.6, 'esquina', [['arbol_maceta'], ['cajas']]),
        ],
    },
    'biblioteca': {
        'tamanos': [(13, 10), (14, 11), (12, 10), (15, 11)],
        'suelos': ['parquet', 'moqueta_beige', 'alfombra_roja', 'losa_crema'],
        'paredes': ['madera_oscura', 'beige_rayado', 'salvia', 'mostaza'],
        'pasos': [
            P(1.0, 'arriba', [['estanteria_alta_{m}', 'estanteria_alta_{m}', 'estanteria_alta_{m}'], ['estanteria_alta_{m}', 'estanteria_alta_{m}']]),
            P(1.0, 'suelo', 'centro', [[('estanteria_alta_{m}', 0, 0), ('estanteria_alta_{m}', 2, 0)], [('estanteria_baja_{m}', 0, 0), ('estanteria_baja_{m}', 2, 0), ('estanteria_baja_{m}', 4, 0)]]),
            P(1.0, 'suelo', 'cualquiera', [[('mesa_cristal_larga', 0, 0), ('{t}', 0, 2), ('{t}', 2, 2)], [('mesa_cristal', 0, 0), ('{t}', -1, 1)]]),
            P(0.7, 'barra', 'lado', 3, False),
            P(0.8, 'esquina', [['planta'], ['arbol_maceta']]),
            P(0.8, 'encima', ['libro_abierto']),
        ],
    },
    'hotel': {
        'tamanos': [(13, 10), (14, 10), (12, 9), (15, 11)],
        'suelos': ['alfombra_roja', 'losa_crema', 'moqueta_azul', 'rombos_oscuros', 'hidraulica_rosa'],
        'paredes': ['madera_oscura', 'crema', 'melocoton', 'mostaza', 'beige_rayado'],
        'pasos': [
            P(1.0, 'arriba', [['recepcion'], ['estanteria_baja_{m}', 'recepcion']]),
            P(0.9, 'suelo', 'lado', [[('sofa', 0, 0)], [('sillon_derecha', 0, 0), ('mesa_cristal', 1, 1), ('sillon_izquierda', 3, 0)]]),
            P(0.8, 'arriba', [['escalera_mano'], ['pecera']]),
            P(1.0, 'esquina', [['palmera_maceta'], ['arbol_maceta']]),
            P(0.8, 'esquina', [['palmera_maceta'], ['planta']]),
            P(0.6, 'alfombra', ['alfombra_roja', 'moqueta_azul', 'alfombra_naranja']),
        ],
    },
    'gimnasio': {
        'tamanos': [(13, 10), (14, 10), (12, 9), (15, 11)],
        'suelos': ['tatami_verde', 'moqueta_azul', 'chapa', 'parquet', 'losa_gris'],
        'paredes': ['gris_cemento', 'lima', 'marino', 'crema', 'gris_raya_roja'],
        'pasos': [
            P(1.0, 'arriba', [['taquilla_gris', 'taquilla_gris', 'taquilla_azul', 'taquilla_azul'], ['taquilla_azul', 'taquilla_azul', 'taquilla_gris']]),
            P(1.0, 'alfombra', ['tatami_verde', 'moqueta_azul', 'alfombra_roja'], 'grande'),
            P(0.8, 'suelo', 'lado', [[('banqueta_azul', 0, 0), ('banqueta_azul', 1, 0)], [('banco_rojo', 0, 0)]]),
            P(0.6, 'arriba', [['tele'], ['nevera_alta']]),
            P(0.6, 'esquina', [['cajas'], ['papelera'], ['caja']]),
        ],
    },
    'discoteca': {
        'tamanos': [(14, 10), (15, 11), (13, 10), (16, 11)],
        'suelos': ['rombos_oscuros', 'moqueta_azul', 'rombos_morados', 'chapa'],
        'paredes': ['marino', 'madera_oscura', 'gris_raya_roja', 'retro'],
        'pasos': [
            P(1.0, 'barra', 'lado', 4, True),
            P(1.0, 'arriba', [['altavoz', 'mostrador_cristal', 'altavoz'], ['altavoz', 'consola', 'mostrador_cristal', 'altavoz']]),
            P(1.0, 'alfombra', ['rombos_morados', 'alfombra_roja', 'moqueta_azul'], 'grande'),
            P(0.8, 'esquina', [['altavoz'], ['papelera']]),
            P(0.8, 'esquina', [['altavoz'], ['cajas']]),
            P(0.6, 'suelo', 'lado', [[('sofa', 0, 0)], [('sillon_derecha', 0, 0)]]),
        ],
    },
    'teatro': {
        'tamanos': [(14, 11), (15, 11), (16, 12), (13, 11)],
        'suelos': ['alfombra_roja', 'moqueta_azul', 'rombos_oscuros', 'moqueta_beige'],
        'paredes': ['madera_oscura', 'marino', 'mostaza', 'beige_rayado'],
        'pasos': [
            P(1.0, 'escenario', ['parquet', 'losa_crema', 'tatami_verde']),
            P(1.0, 'filas', 'taburete_rojo', None, 1),
            P(0.6, 'esquina', [['palmera_maceta'], ['arbol_maceta']]),
        ],
    },
    'iglesia': {
        'tamanos': [(12, 11), (13, 11), (14, 12), (12, 12), (15, 12)],
        'suelos': ['losa_crema', 'piedra', 'losa_gris', 'rombos_oscuros'],
        'paredes': ['beige_rayado', 'crema', 'topo', 'madera_oscura', 'mostaza'],
        'pasos': [
            P(1.0, 'altar', ['estatua_gargola', 'estatua_aguila', 'pedestal']),
            P(1.0, 'filas', 'banco_rojo', None, 1),
            P(1.0, 'pasillo', ['alfombra_roja']),
            P(0.7, 'esquina', [['arbol_maceta'], ['palmera_maceta']]),
        ],
    },
    'museo': {
        'tamanos': [(14, 10), (15, 11), (16, 11), (14, 11), (16, 12)],
        'suelos': ['losa_crema', 'parquet', 'piedra', 'alfombra_roja', 'losa_gris'],
        'paredes': ['madera_oscura', 'crema', 'beige_rayado', 'topo', 'mostaza'],
        'pasos': [
            P(1.0, 'arriba', [['vitrina_madera', 'estatua_gargola', 'vitrina_madera'], ['vitrina_alta', 'pedestal', 'vitrina_alta'], ['estatua_aguila', 'vitrina_blanca']]),
            P(1.0, 'suelo', 'centro', [[('isla_{c}', 0, 0)], [('pedestal', 0, 0), ('pedestal', 3, 0)], [('vitrina_blanca', 0, 0), ('vitrina_blanca', 3, 0)]]),
            P(0.9, 'suelo', 'lado', [[('banco_rojo', 0, 0)], [('estatua_gargola', 0, 0)], [('vitrina_alta', 0, 0)]]),
            P(0.8, 'lado', [['vitrina_madera_estrecha'], ['vitrina_blanca_estrecha'], ['estatua_gargola']]),
            P(0.7, 'esquina', [['palmera_maceta'], ['arbol_maceta'], ['pedestal']]),
            P(0.5, 'alfombra', ['alfombra_roja', 'moqueta_azul']),
        ],
    },
    'palacio': {
        'tamanos': [(15, 11), (16, 12), (16, 11), (14, 11)],
        'suelos': ['alfombra_roja', 'losa_crema', 'hidraulica_rosa', 'rombos_oscuros', 'piedra'],
        'paredes': ['madera_oscura', 'mostaza', 'crema', 'beige_rayado', 'melocoton'],
        'pasos': [
            P(1.0, 'arriba', [['estatua_aguila', 'vitrina_madera', 'estatua_aguila'], ['arbol_maceta', 'estatua_gargola', 'estatua_gargola', 'arbol_maceta'], ['vitrina_alta', 'estatua_aguila', 'vitrina_alta']]),
            P(0.9, 'suelo', 'centro', [[('mesa_cristal_larga', 0, 0), ('silla_derecha', -1, 0), ('silla_izquierda', 3, 0)], [('sillon_derecha', 0, 0), ('mesa_cristal', 1, 1), ('sillon_izquierda', 3, 0)]]),
            P(0.8, 'lado', [['estatua_gargola'], ['vitrina_alta'], ['pedestal']]),
            P(1.0, 'esquina', [['palmera_maceta'], ['arbol_maceta']]),
            P(0.8, 'esquina', [['arbol_maceta'], ['pedestal']]),
            P(0.8, 'alfombra', ['alfombra_roja', 'moqueta_azul'], 'grande'),
        ],
    },
    'castillo': {
        'tamanos': [(13, 10), (14, 11), (12, 10), (15, 11), (16, 12)],
        'suelos': ['piedra', 'losa_gris', 'losa_crema'],
        'paredes': ['topo', 'gris_cemento', 'beige_rayado', 'madera_oscura'],
        'pasos': [
            P(1.0, 'arriba', [['estatua_gargola', 'escalera_mano', 'estatua_gargola'], ['pedestal', 'estatua_aguila', 'pedestal'], ['escalera_mano', 'cajas']]),
            P(0.8, 'suelo', 'lado', [[('banco_rojo', 0, 0)], [('cajas', 0, 0)], [('mesa_cristal_larga', 0, 0)]]),
            P(0.8, 'lado', [['vitrina_alta'], ['estatua_gargola'], ['taquilla_gris']]),
            P(0.8, 'esquina', [['cajas'], ['caja'], ['pedestal']]),
            P(0.6, 'alfombra', ['alfombra_roja'], 'pasillo'),
        ],
    },
    'torre': {
        'tamanos': [(8, 8), (9, 8), (8, 9), (10, 8)],
        'suelos': ['chapa', 'piedra', 'losa_gris', 'parquet'],
        'paredes': ['gris_cemento', 'topo', 'beige_rayado', 'azulejo_azul', 'crema'],
        'pasos': [
            P(1.0, 'arriba', [['escalera_mano'], ['escalera_mano', 'cajas']]),
            P(0.8, 'esquina', [['cajas'], ['caja'], ['cajon_gris']]),
            P(0.6, 'esquina', [['papelera'], ['banqueta_azul'], ['tele_pequena']]),
        ],
    },
    'caseta': {
        'tamanos': [(8, 7), (9, 7), (8, 8)],
        'suelos': ['chapa', 'parquet', 'losa_gris', 'azulejo_menta'],
        'paredes': ['azulejo_azul', 'melocoton', 'crema', 'gris_cemento'],
        'pasos': [
            P(1.0, 'arriba', [['cajon_gris', 'nevera'], ['taquilla_azul', 'cajonera_gris'], ['cajas', 'tele_pequena']]),
            P(0.8, 'esquina', [['banqueta_azul'], ['taburete_rojo'], ['caja']]),
            P(0.6, 'esquina', [['papelera'], ['planta']]),
        ],
    },
    'almacen': {
        'tamanos': [(12, 9), (13, 10), (14, 10), (12, 10)],
        'suelos': ['chapa', 'losa_gris', 'piedra'],
        'paredes': ['gris_cemento', 'gris_raya_roja', 'topo'],
        'pasos': [
            P(1.0, 'arriba', [['cajas', 'cajas'], ['taquilla_gris', 'cajas', 'escalera_mano']]),
            P(1.0, 'suelo', 'cualquiera', [[('cajas', 0, 0)], [('cajas', 0, 0), ('caja', 3, 1)]]),
            P(0.8, 'suelo', 'cualquiera', [[('cajas', 0, 0)], [('caja', 0, 0), ('caja', 1, 0)]]),
            P(0.8, 'esquina', [['caja'], ['papelera']]),
            P(0.6, 'esquina', [['cajas'], ['caja']]),
        ],
    },
    'mercado': {
        'tamanos': [(15, 11), (16, 12), (14, 11), (16, 11)],
        'suelos': ['losa_gris', 'losa_crema', 'piedra', 'hidraulica_rosa', 'rombos_verdes'],
        'paredes': ['gris_cemento', 'beige_rayado', 'topo', 'crema', 'retro'],
        'pasos': [
            P(1.0, 'puestos', 3),
            P(0.8, 'esquina', [['cajas'], ['caja']]),
            P(0.8, 'esquina', [['cajas'], ['papelera']]),
            P(0.9, 'encima', ['plato_comida', 'plato']),
        ],
    },
    'puesto': {
        'tamanos': [(9, 8), (10, 8), (10, 7), (9, 7)],
        'suelos': ['losa_gris', 'losa_crema', 'piedra', 'chapa', 'hidraulica_rosa'],
        'paredes': ['retro', 'beige_rayado', 'topo', 'crema', 'melocoton'],
        'pasos': [
            P(1.0, 'barra', 'centro', 3, False),
            P(1.0, 'arriba', [['cajas'], ['nevera_alta', 'cajas'], ['estanteria_baja_{m}', 'caja']]),
            P(0.6, 'esquina', [['caja'], ['papelera']]),
            P(0.9, 'encima', ['plato_comida', 'plato', 'taza']),
        ],
    },
    'estacion': {
        'tamanos': [(14, 10), (15, 11), (16, 11), (13, 10)],
        'suelos': ['losa_gris', 'losa_crema', 'chapa', 'rombos_oscuros'],
        'paredes': ['gris_raya_roja', 'gris_cemento', 'crema', 'azulejo_azul'],
        'pasos': [
            P(1.0, 'arriba', [['maquina_billetes', 'maquina_billetes'], ['maquina_billetes', 'tele', 'maquina_billetes']]),
            P(1.0, 'barra', 'lado', 3, False),
            P(1.0, 'suelo', 'centro', [[('banco_rojo', 0, 0), ('banco_rojo', 4, 0)], [('banco_rojo', 0, 0)]]),
            P(0.7, 'suelo', 'lado', [[('banco_rojo', 0, 0)]]),
            P(0.8, 'esquina', [['papelera'], ['planta']]),
            P(0.6, 'esquina', [['papelera'], ['tele_pequena']]),
        ],
    },
    'institucion': {
        'tamanos': [(15, 11), (16, 12), (14, 11), (16, 11)],
        'suelos': ['alfombra_roja', 'losa_crema', 'moqueta_azul', 'rombos_oscuros', 'parquet'],
        'paredes': ['madera_oscura', 'crema', 'beige_rayado', 'mostaza', 'topo'],
        'pasos': [
            P(1.0, 'arriba', [['estatua_aguila', 'mostrador_{c}', 'estatua_aguila'], ['archivo_alto', 'mostrador_{c}', 'archivo_alto'], ['vitrina_alta', 'mostrador_{c}', 'vitrina_alta']]),
            P(1.0, 'filas', 'banco_rojo', None, 1),
            P(0.8, 'esquina', [['palmera_maceta'], ['arbol_maceta']]),
            P(0.6, 'esquina', [['arbol_maceta'], ['pedestal']]),
        ],
    },
    'peluqueria': {
        'tamanos': [(10, 8), (11, 8), (12, 9)],
        'suelos': ['rombos_oscuros', 'losa_crema', 'hidraulica_rosa', 'rombos_lila'],
        'paredes': ['retro', 'crema', 'menta', 'melocoton'],
        'pasos': [
            P(1.0, 'arriba', [['vitrina_alta', 'vitrina_alta', 'vitrina_alta'], ['vitrina_blanca_estrecha', 'vitrina_blanca_estrecha', 'vitrina_blanca_estrecha']]),
            P(1.0, 'suelo', 'centro', [[('silla_derecha', 0, 0), ('silla_izquierda', 2, 0)], [('banqueta_roja', 0, 0), ('banqueta_roja', 2, 0), ('banqueta_roja', 4, 0)]]),
            P(0.8, 'suelo', 'lado', [[('sofa', 0, 0)], [('banco_rojo', 0, 0)]]),
            P(0.7, 'esquina', [['planta'], ['papelera']]),
        ],
    },
    'taller': {
        'tamanos': [(12, 9), (13, 10), (12, 10)],
        'suelos': ['chapa', 'losa_gris', 'rombos_oscuros'],
        'paredes': ['gris_cemento', 'gris_raya_roja', 'marino', 'topo'],
        'pasos': [
            P(1.0, 'arriba', [['taquilla_gris', 'encimera', 'taquilla_gris'], ['cajonera_gris', 'cajonera_azul', 'escalera_mano']]),
            P(1.0, 'suelo', 'cualquiera', [[('mesa_cristal_larga', 0, 0), ('caja', 0, 2)], [('mostrador_tablas', 0, 0)]]),
            P(0.8, 'suelo', 'cualquiera', [[('cajas', 0, 0)], [('caja', 0, 0), ('caja', 1, 0)]]),
            P(0.7, 'esquina', [['papelera'], ['caja']]),
        ],
    },
    'cueva': {
        'tamanos': [(12, 9), (13, 10), (12, 10), (14, 10)],
        'suelos': ['piedra', 'losa_gris', 'chapa'],
        'paredes': ['topo', 'gris_cemento', 'madera_oscura'],
        'pasos': [
            P(1.0, 'arriba', [['pedestal', 'estatua_gargola', 'pedestal'], ['estatua_aguila'], ['cajas', 'pedestal']]),
            P(0.8, 'suelo', 'cualquiera', [[('pedestal', 0, 0)], [('cajas', 0, 0)], [('caja', 0, 0), ('caja', 2, 1)]]),
            P(0.8, 'esquina', [['caja'], ['pedestal']]),
            P(0.6, 'esquina', [['cajas'], ['papelera']]),
        ],
    },
}
# Alias: tipos que comparten receta con otro (el nombre, la gente y los textos los distinguen).
ALIAS = {
    'casa': 'vivienda', 'chalet': 'vivienda', 'masia': 'rural', 'barraca': 'rural', 'cortijo': 'rural', 'horreo': 'rural',
    'cafeteria': 'bar', 'taberna': 'bar', 'churreria': 'bar', 'chiringuito': 'bar', 'heladeria': 'panaderia',
    'pasteleria': 'panaderia', 'ropa': 'tienda', 'souvenirs': 'tienda', 'electronica': 'tienda', 'libreria': 'biblioteca',
    'zapateria': 'tienda', 'kiosco': 'puesto', 'gestoria': 'oficina', 'agencia': 'oficina', 'inmobiliaria': 'oficina',
    'startup': 'oficina', 'redaccion': 'oficina', 'academia': 'aula', 'colegio': 'aula', 'universidad': 'aula',
    'hostal': 'hotel', 'club': 'discoteca', 'cine': 'teatro', 'plato': 'teatro', 'ermita': 'iglesia', 'catedral': 'iglesia',
    'basilica': 'iglesia', 'monasterio': 'iglesia', 'galeria': 'museo', 'faro': 'torre', 'molino': 'torre', 'socorrismo': 'caseta',
    'ayuntamiento': 'institucion', 'congreso': 'institucion', 'tribunal': 'institucion', 'sede': 'oficina', 'consulado': 'palacio',
    'nave': 'almacen', 'grandes_almacenes': 'tienda', 'boxeo': 'gimnasio', 'ruinas': 'cueva', 'dolmen': 'cueva', 'cripta': 'cueva',
    'mezquita': 'iglesia', 'templo': 'museo', 'correos': 'banco', 'estudio': 'oficina', 'clinica': 'farmacia', 'lonja': 'mercado',
    'bodega': 'almacen', 'garaje': 'taller', 'barberia': 'peluqueria', 'sala_conciertos': 'discoteca', 'casino': 'palacio',
}


def receta(tipo):
    t = ALIAS.get(tipo, tipo)
    if t not in RECETAS:
        raise SystemExit('tipo sin receta: %s' % tipo)
    return RECETAS[t]


# --------------------------------------------------------------------------- sala

class Sala:
    def __init__(self, W, H, puerta_x):
        self.W, self.H, self.px = W, H, puerta_x
        self.solido = {}       # casilla -> índice del mueble (colisión)
        self.cubierto = {}     # parte de arriba de muebles en el suelo (capa Above, se pasa por detrás)
        self.pared_ocupada = {}  # casillas de pared tapadas por un mueble
        self.reservado = set()   # pasillo, apariciones, pasos
        self.filas_desde = None
        self.muebles = []
        self.encima = []
        self.alfombras = []
        self.anclas = {}       # papel -> lista de (casilla, mirada)
        self.huecos_arriba = set()  # columnas de la pared de arriba con paso a otra sala

    def suelo(self, c):
        x, y = c
        return 1 <= x <= self.W - 2 and 2 <= y <= self.H - 2

    def libre(self, c):
        return self.suelo(c) and c not in self.solido and c not in self.reservado and c not in self.cubierto

    def pisable(self, c):
        x, y = c
        if (x, y) == (self.px, self.H - 1):
            return True
        return self.suelo(c) and c not in self.solido

    def celdas(self, nombre, x, y):
        """Devuelve (sólidas, cubiertas, en la pared) o None si no cabe.

        Sólidas: casillas del suelo con colisión. Cubiertas: parte de arriba de una pieza
        alta puesta en el suelo (capa Above, se pasa por detrás). En la pared: casillas de
        la pared que tapa una pieza apoyada en ella (o el margen de una pieza de tres columnas)."""
        pz = MUEBLES[nombre]
        w, h = pz['rect'][2], pz['rect'][3]
        base = pz.get('base', h)
        contra_muro = y <= 1
        margen = w == 3 and pz.get('tipo') in ('cama', 'estatua', 'escalera', 'pc')
        sol, cub, pared = [], [], []
        for dy in range(h):
            for dx in range(w):
                c = (x + dx, y + dy)
                lateral = c[0] < 1 or c[0] > self.W - 2
                if c[1] < 2 or lateral:
                    # Solo se tapa la pared de arriba con piezas apoyadas en ella, y la lateral
                    # con el margen transparente de las piezas de tres columnas.
                    if c[1] < 0 or c[0] < 0 or c[0] > self.W - 1 or c[1] > self.H - 2:
                        return None
                    if lateral and not (margen and dx in (0, w - 1)):
                        return None
                    if c[1] < 2 and not contra_muro:
                        return None
                    if c[0] in self.huecos_arriba or c in self.pared_ocupada:
                        return None
                    pared.append(c)
                    continue
                if c[1] > self.H - 2:
                    return None
                if dy >= h - base or contra_muro:
                    if c in self.solido or c in self.reservado or c in self.cubierto:
                        return None
                    sol.append(c)
                else:
                    if c in self.solido or c in self.reservado or c in self.cubierto:
                        return None
                    cub.append(c)
        return sol, cub, pared

    def poner(self, nombre, x, y):
        r = self.celdas(nombre, x, y)
        if r is None:
            return False
        sol, cub, pared = r
        i = len(self.muebles)
        self.muebles.append([nombre, x, y])
        for c in sol:
            self.solido[c] = i
        for c in cub:
            self.cubierto[c] = i
        for c in pared:
            self.pared_ocupada[c] = i
        return True

    def quitar_ultimos(self, n):
        for _ in range(n):
            i = len(self.muebles) - 1
            self.muebles.pop()
            for tabla in (self.solido, self.cubierto, self.pared_ocupada):
                for c in [c for c, j in tabla.items() if j == i]:
                    del tabla[c]

    def alcance(self, bloqueos=()):
        inicio = (self.px, self.H - 2)
        vistos = {inicio}
        cola = [inicio]
        bloq = set(bloqueos)
        while cola:
            c = cola.pop()
            for d in DIRS:
                n = (c[0] + d[0], c[1] + d[1])
                if n in vistos or n in bloq or not self.pisable(n):
                    continue
                vistos.add(n)
                cola.append(n)
        return vistos


def y_arriba(nombre):
    """Fila de la casilla de arriba de una pieza apoyada en la pared de arriba."""
    pz = MUEBLES[nombre]
    h = pz['rect'][3]
    base = pz.get('base', h)
    if pz.get('tipo') == 'cama':
        return 1
    if base == 1:
        return 3 - h
    return 2 if h < 3 else 1


def ancho(nombre):
    return MUEBLES[nombre]['rect'][2]


def alto(nombre):
    return MUEBLES[nombre]['rect'][3]


# --------------------------------------------------------------------------- primitivas

class Planificador:
    def __init__(self, rng, sala, ctx):
        self.r = rng
        self.s = sala
        self.ctx = ctx

    def pieza(self, n):
        n = n.replace('{m}', self.ctx['m']).replace('{c}', self.ctx['c']).replace('{t}', self.ctx['t']).replace('{cama}', self.ctx['cama'])
        if n not in MUEBLES:
            raise SystemExit('pieza desconocida: %s' % n)
        return n

    def arriba(self, opciones, lado=None):
        s = self.s
        op = [self.pieza(n) for n in self.r.choice(opciones)]
        total = sum(ancho(n) for n in op)
        xs = list(range(1, s.W - 1 - total + 1))
        if lado == 'izq':
            xs = xs[:1]
        elif lado == 'der':
            xs = xs[-1:]
        self.r.shuffle(xs)
        for x0 in xs:
            x = x0
            puestos = 0
            ok = True
            for n in op:
                if not s.poner(n, x, y_arriba(n)):
                    ok = False
                    break
                puestos += 1
                x += ancho(n)
            if ok:
                for n_i in range(puestos):
                    nombre, mx, my = s.muebles[-1 - n_i]
                    w = ancho(nombre)
                    fila = my + alto(nombre)
                    clave = 'pieza:' + MUEBLES[nombre]['tipo']
                    for dx in range(w):
                        s.anclas.setdefault('arriba', []).append(((mx + dx, fila), 'arriba'))
                        s.anclas.setdefault(clave, []).append(((mx + dx, fila), 'arriba'))
                    s.anclas.setdefault(clave, []).append(((mx - 1, fila - 1), 'derecha'))
                    s.anclas.setdefault(clave, []).append(((mx + w, fila - 1), 'izquierda'))
                return True
            s.quitar_ultimos(puestos)
        return False

    def lado(self, opciones):
        s = self.s
        op = [self.pieza(n) for n in self.r.choice(opciones)]
        lados = ['izq', 'der']
        self.r.shuffle(lados)
        for l in lados:
            ys = list(range(2, s.H - 2))
            self.r.shuffle(ys)
            for y0 in ys:
                y = y0
                puestos = 0
                ok = True
                for n in op:
                    x = 1 if l == 'izq' else s.W - 1 - ancho(n)
                    if not s.poner(n, x, y):
                        ok = False
                        break
                    puestos += 1
                    y += alto(n)
                if ok:
                    return True
                s.quitar_ultimos(puestos)
        return False

    def suelo(self, zona, opciones):
        s = self.s
        op = [(self.pieza(n), dx, dy) for (n, dx, dy) in self.r.choice(opciones)]
        minx = min(dx for _, dx, _ in op)
        maxx = max(dx + ancho(n) - 1 for n, dx, _ in op)
        miny = min(dy for _, _, dy in op)
        maxy = max(dy + alto(n) - 1 for n, _, dy in op)
        cand = []
        for y in range(2 - miny, s.H - 1 - maxy):
            for x in range(1 - minx, s.W - 1 - maxx):
                cx = x + (minx + maxx) / 2.0
                cy = y + (miny + maxy) / 2.0
                if zona == 'centro' and not (abs(cx - (s.W - 1) / 2.0) <= s.W / 4.0 and 3 <= cy <= s.H - 3):
                    continue
                if zona == 'lado' and not (x + minx <= 2 or x + maxx >= s.W - 3):
                    continue
                cand.append((x, y))
        self.r.shuffle(cand)
        for (x, y) in cand[:80]:
            puestos = 0
            ok = True
            for (n, dx, dy) in op:
                if not s.poner(n, x + dx, y + dy):
                    ok = False
                    break
                puestos += 1
            if ok:
                for (n, dx, dy) in op:
                    t = MUEBLES[n]['tipo']
                    for c, m in self._alrededor(x + dx, y + dy, n):
                        s.anclas.setdefault('pieza:' + t, []).append((c, m))
                return True
            s.quitar_ultimos(puestos)
        return False

    def _alrededor(self, x, y, n):
        w, h = ancho(n), alto(n)
        out = []
        for dx in range(w):
            out.append(((x + dx, y + h), 'arriba'))
            out.append(((x + dx, y - 1), 'abajo'))
        for dy in range(h):
            out.append(((x - 1, y + dy), 'derecha'))
            out.append(((x + w, y + dy), 'izquierda'))
        return out

    def esquina(self, opciones):
        s = self.s
        op = self.pieza(self.r.choice(opciones)[0])
        w, h = ancho(op), alto(op)
        sitios = [(1, y_arriba(op)), (s.W - 1 - w, y_arriba(op)), (1, s.H - 1 - h), (s.W - 1 - w, s.H - 1 - h)]
        self.r.shuffle(sitios)
        for (x, y) in sitios:
            if s.poner(op, x, y):
                return True
        return False

    def barra(self, zona, largo, taburetes):
        """Mostrador con alguien detrás. zona: arriba (contra el muro), lado o centro."""
        s = self.s
        color = self.ctx['c']
        if largo == 0:
            largo = max(3, min(s.W - 5, self.r.choice([4, 5, 6])))
        largo = max(2, min(largo, s.W - 4))
        cand = []
        if zona == 'arriba':
            ys = [3, 4] if s.H >= 9 else [3]
        elif zona == 'lado':
            ys = list(range(3, s.H - 4))
        else:
            ys = list(range(4, s.H - 3))
        for y in ys:
            for x in range(1, s.W - 1 - largo + 1):
                if zona == 'lado' and not (x <= 2 or x + largo - 1 >= s.W - 3):
                    continue
                if zona == 'centro' and abs((x + (largo - 1) / 2.0) - (s.W - 1) / 2.0) > 2:
                    continue
                cand.append((x, y))
        self.r.shuffle(cand)
        for (x, y) in cand:
            piezas = []
            for i in range(largo):
                suf = 'i' if i == 0 else ('d' if i == largo - 1 else 'm')
                piezas.append(('mostrador_%s_%s' % (color, suf), x + i, y))
            puestos = 0
            ok = True
            for (n, px, py) in piezas:
                if not s.poner(n, px, py):
                    ok = False
                    break
                puestos += 1
            detras = [(x + i, y - 1) for i in range(largo)]
            if ok and any(s.libre(c) for c in detras):
                delante = [(x + i, y + 2) for i in range(largo)]
                if not all(s.suelo(c) for c in delante):
                    s.quitar_ultimos(puestos)
                    continue
                for c in detras:
                    s.anclas.setdefault('tras_mostrador', []).append((c, 'abajo'))
                for c in delante:
                    s.anclas.setdefault('cliente', []).append((c, 'arriba'))
                s.anclas.setdefault('mostrador', []).append(((x, y), largo))
                if taburetes:
                    extra = 0
                    for i in range(1, largo, 2):
                        c = (x + i, y + 2)
                        if s.poner(self.ctx['t'], c[0], c[1]):
                            extra += 1
                return True
            s.quitar_ultimos(puestos)
        return False

    def filas(self, asiento, mesa, hueco):
        """Filas de asientos (bancos, butacas, pupitres) a los dos lados de un pasillo en la
        columna de la puerta. Con mesa, cada puesto es la mesa y el asiento debajo."""
        s = self.s
        asiento = self.pieza(asiento)
        mesa = self.pieza(mesa) if mesa else None
        y = s.filas_desde or (4 if s.H >= 11 else 3)
        unidad_w = ancho(mesa) if mesa else ancho(asiento)
        unidad_h = (alto(mesa) + alto(asiento)) if mesa else alto(asiento)
        # Se deja una columna libre junto a cada pared para poder rodear las filas.
        izq_min, der_max = 2, s.W - 3
        filas = 0
        while y + unidad_h - 1 <= s.H - 4:
            puestos_fila = 0
            for lado in (-1, 1):
                x = s.px - 1 - unidad_w + 1 if lado < 0 else s.px + 1
                while izq_min <= x and x + unidad_w - 1 <= der_max:
                    piezas = [(mesa, x, y), (asiento, x + (unidad_w - ancho(asiento)) // 2, y + alto(mesa))] if mesa else [(asiento, x, y)]
                    puestos = 0
                    ok = True
                    for (n, px, py) in piezas:
                        if not s.poner(n, px, py):
                            ok = False
                            break
                        puestos += 1
                    if ok:
                        puestos_fila += 1
                        for (n, px, py) in piezas:
                            if n == asiento:
                                s.anclas.setdefault('asiento', []).append(((px, py + alto(n)), 'arriba'))
                    else:
                        s.quitar_ultimos(puestos)
                    x = x - unidad_w - (1 if mesa else 0) if lado < 0 else x + unidad_w + (1 if mesa else 0)
            if puestos_fila:
                filas += 1
            y += unidad_h + hueco
        return filas >= 1

    def escenario(self, suelos):
        s = self.s
        x0, x1 = 2, s.W - 3
        s.alfombras.append([self.r.choice(suelos), [x0, 2, x1 - x0 + 1, 2]])
        for x in range(x0, x1 + 1):
            s.anclas.setdefault('escenario', []).append(((x, 2), 'abajo'))
            s.anclas.setdefault('escenario', []).append(((x, 3), 'abajo'))
        # Pasillo delante del escenario; las butacas empiezan debajo.
        for x in range(1, s.W - 1):
            s.reservado.add((x, 4))
        s.filas_desde = 5
        return True

    def altar(self, estatuas):
        s = self.s
        cx = s.px
        mesa = 'mostrador_blanco' if self.r.random() < 0.5 else 'mostrador_madera'
        x = max(1, min(s.W - 4, cx - 1))
        if not s.poner(mesa, x, 3):
            return False
        for c in [(x + i, 2) for i in range(3)]:
            s.anclas.setdefault('altar', []).append((c, 'abajo'))
        est = self.pieza(self.r.choice(estatuas))
        for xx in (x - 2 - ancho(est) + 1, x + 4):
            if 1 <= xx and xx + ancho(est) - 1 <= s.W - 2:
                s.poner(est, xx, y_arriba(est))
        for xx in (1, s.W - 2):
            s.poner('arbol_maceta' if self.r.random() < 0.5 else 'palmera_maceta', xx, y_arriba('arbol_maceta'))
        # Pasillo delante del altar; los bancos empiezan debajo.
        for xx in range(1, s.W - 1):
            s.reservado.add((xx, 5))
        s.filas_desde = 6
        return True

    def pasillo(self, suelos):
        s = self.s
        s.alfombras.append([self.r.choice(suelos), [s.px, 4, 1, s.H - 5]])
        return True

    def alfombra(self, suelos, forma=None):
        s = self.s
        suelo = self.r.choice(suelos)
        if forma == 'grande':
            w, h = max(3, s.W - 6), max(2, s.H - 6)
        elif forma == 'pasillo':
            s.alfombras.append([suelo, [s.px, 2, 1, s.H - 3]])
            return True
        else:
            w, h = self.r.choice([(3, 2), (4, 2), (4, 3), (5, 3), (3, 3)])
        w = min(w, s.W - 4)
        h = min(h, s.H - 5)
        cand = [(x, y) for x in range(2, s.W - 1 - w) for y in range(3, s.H - 1 - h)]
        if not cand:
            return False
        x, y = self.r.choice(cand)
        s.alfombras.append([suelo, [x, y, w, h]])
        return True

    def encima(self, objetos):
        s = self.s
        sitios = []
        for i, (n, x, y) in enumerate(s.muebles):
            t = MUEBLES[n]['tipo']
            if t in ('mesa', 'mostrador'):
                for dx in range(ancho(n)):
                    sitios.append((x + dx, y))
        if not sitios:
            return False
        self.r.shuffle(sitios)
        k = min(len(sitios), self.r.choice([1, 2, 2, 3]))
        usados = set(c for _, c in [(e[0], (e[1], e[2])) for e in s.encima])
        for c in sitios[:k]:
            if c in usados:
                continue
            s.encima.append([self.pieza(self.r.choice(objetos)), c[0], c[1]])
        return True

    def puestos(self, n):
        s = self.s
        hechos = 0
        colores = MOSTRADORES[:]
        self.r.shuffle(colores)
        intentos = 0
        while hechos < n and intentos < 40:
            intentos += 1
            color = colores[hechos % len(colores)]
            x = self.r.randrange(1, max(2, s.W - 4))
            y = self.r.randrange(3, max(4, s.H - 4))
            piezas = [('mostrador_%s_i' % color, x, y), ('mostrador_%s_m' % color, x + 1, y), ('mostrador_%s_d' % color, x + 2, y)]
            puestos = 0
            ok = True
            for (pn, px, py) in piezas:
                if not s.poner(pn, px, py):
                    ok = False
                    break
                puestos += 1
            if ok and s.libre((x + 1, y - 1)) and all(s.suelo((x + i, y + 2)) for i in range(3)):
                s.anclas.setdefault('tras_mostrador', []).append(((x + 1, y - 1), 'abajo'))
                for i in range(3):
                    s.anclas.setdefault('cliente', []).append(((x + i, y + 2), 'arriba'))
                # El sitio del vendedor no se ocupa con otro puesto.
                s.reservado.add((x + 1, y - 1))
                hechos += 1
            else:
                s.quitar_ultimos(puestos)
        return hechos > 0


# --------------------------------------------------------------------------- planificación

def semilla(texto):
    return int(hashlib.sha1(texto.encode('utf-8')).hexdigest()[:12], 16)


def nodo(nombre, usados):
    t = unicodedata.normalize('NFKD', nombre)
    t = ''.join(ch for ch in t if not unicodedata.combining(ch))
    t = ''.join(p[:1].upper() + p[1:] for p in ''.join(ch if ch.isalnum() else ' ' for ch in t).split())
    t = t or 'Persona'
    base = t
    i = 2
    while t in usados:
        t = '%s%d' % (base, i)
        i += 1
    usados.add(t)
    return t


def planificar(map_id, e, conservar, intento=0):
    """Devuelve la entrada con la distribución calculada, o lanza ValueError."""
    tipo = e['tipo']
    rc = receta(tipo)
    rng = random.Random(semilla('%s|%s|%d' % (map_id, tipo, intento)))
    if 'tamano' in e and e.get('tamano_fijo'):
        W, H = e['tamano']
    else:
        W, H = rng.choice(rc['tamanos'])
        if 'escala' in e:
            W = max(8, min(16, W + int(e['escala'])))
    hijos = e.get('_hijos', [])
    # Una sala con paso a otra por arriba necesita sitio para el hueco.
    if hijos and W < 10:
        W = 10
    if 'puerta' in e and e.get('puerta_fija'):
        px = e['puerta'][0]
    else:
        px = rng.choice([x for x in range(3, W - 3)]) if W >= 8 else W // 2
    s = Sala(W, H, px)
    s.reservado |= {(px, H - 2), (px, H - 3)}
    # Pasos a otras salas por la pared de arriba (las salas hijas de esta).
    huecos = []
    libres = [x for x in range(2, W - 2) if abs(x - px) >= 2]
    rng.shuffle(libres)
    for h_id in hijos:
        for x in libres:
            if all(abs(x - o) >= 3 for o in huecos):
                huecos.append(x)
                break
        else:
            raise ValueError('no cabe el paso a %s' % h_id)
    for x in huecos:
        s.huecos_arriba.add(x)
        s.reservado |= {(x, 2), (x, 3)}
    # Casillas fijas (personas o carteles con sitio fijo).
    for grupo in ('personas', 'carteles'):
        for it in e.get(grupo, []):
            if it.get('fijo') and 'en' in it:
                s.reservado.add(tuple(it['en']))
    for c in conservar.get('reservar', []):
        s.reservado.add(tuple(c))
    ctx = {
        'm': rng.choice(MADERAS),
        'c': rng.choice(MOSTRADORES),
        't': rng.choice(TABURETES),
        'cama': rng.choice(CAMAS),
    }
    pl = Planificador(rng, s, ctx)
    for prob, prim, args in rc['pasos']:
        if rng.random() > prob:
            continue
        getattr(pl, prim)(*args)
    # Lo que piden las personas y los carteles (la cama de quien duerme, la tele que se mira...).
    for t in requisitos(e):
        if t in tipos_puestos(s):
            continue
        prim, args = REQUISITOS[t]
        if not getattr(pl, prim)(*args):
            raise ValueError('no cabe %s' % t)
    # Todo el suelo libre tiene que quedar unido.
    alc = s.alcance()
    sueltas = [c for c in ((x, y) for x in range(1, W - 1) for y in range(2, H - 1)) if s.pisable(c) and c not in alc]
    if sueltas:
        raise ValueError('suelo encerrado en %s' % (sueltas[:3],))
    for x in huecos:
        if (x, 2) not in alc:
            raise ValueError('no se llega al paso de arriba')
    # Personas.
    usados = set()
    ocupadas = set()
    personas = []
    for p in e.get('personas', []):
        q = dict(p)
        q['nodo'] = p.get('nodo') or nodo(p.get('nombre', 'Persona'), usados)
        usados.add(q['nodo'])
        if p.get('fijo') and 'en' in p:
            c = tuple(p['en'])
            ocupadas.add(c)
            personas.append(q)
            continue
        c, mira = colocar_persona(s, rng, p.get('papel', 'libre'), ocupadas)
        if c is None:
            raise ValueError('sin sitio para %s' % q['nodo'])
        ocupadas.add(c)
        q['en'] = list(c)
        q['mira'] = p.get('mira') or mira
        personas.append(q)
    # Con las personas puestas se tiene que seguir llegando a todo.
    alc = s.alcance(ocupadas)
    sueltas = [c for c in ((x, y) for x in range(1, W - 1) for y in range(2, H - 1)) if s.pisable(c) and c not in alc and c not in ocupadas]
    if sueltas:
        raise ValueError('las personas encierran %s' % (sueltas[:3],))
    for q in personas:
        if not se_habla(s, tuple(q['en']), alc):
            raise ValueError('no se llega a hablar con %s' % q['nodo'])
    # Carteles: sobre un mueble (se examina) o en la pared.
    carteles = []
    for k in e.get('carteles', []):
        q = dict(k)
        q['nodo'] = k.get('nodo') or nodo(k.get('nombre', 'Cartel'), usados)
        usados.add(q['nodo'])
        if k.get('fijo') and 'en' in k:
            carteles.append(q)
            continue
        sitio = None
        for c in colocar_cartel(s, rng, k.get('sobre'), alc, ocupadas):
            puestos = {tuple(x['en']) for x in carteles} | {c}
            if all(se_habla(s, tuple(p['en']), alc, puestos) for p in personas):
                sitio = c
                break
        if sitio is None:
            raise ValueError('sin sitio para el cartel %s' % q['nodo'])
        ocupadas.add(sitio)
        q['en'] = list(sitio)
        carteles.append(q)
    out = dict(e)
    out['tamano'] = [W, H]
    out['puerta'] = [px, H - 1]
    out['suelo'] = e.get('suelo') if e.get('suelo_fijo') else rng.choice(rc['suelos'])
    out['pared'] = e.get('pared') if e.get('pared_fija') else rng.choice(rc['paredes'])
    out['felpudo'] = rng.choice(['alfombra_roja', 'moqueta_azul', 'alfombra_naranja', 'tatami_verde'])
    if out['felpudo'] == out['suelo']:
        out['felpudo'] = 'moqueta_beige'
    out['alfombras'] = [[a[0] if a[0] != out['suelo'] else 'moqueta_beige', a[1]] for a in s.alfombras]
    out['muebles'] = [[n, x, y] for (n, x, y) in s.muebles]
    out['encima'] = [[n, x, y] for (n, x, y) in s.encima]
    out['personas'] = personas
    out['carteles'] = carteles
    out['apariciones'] = {'default': [px, H - 2]}
    out['pasos'] = []
    for h_id, x in zip(hijos, huecos):
        out['pasos'].append({'nodo': nodo(h_id.split('/')[-1].split('_')[-1].capitalize(), usados), 'en': [x, 1], 'destino': h_id,
                             'aparicion': 'default', 'vuelta': 'desde_' + h_id.split('/')[-1], 'llegada': [x, 2]})
        out['apariciones']['desde_' + h_id.split('/')[-1]] = [x, 2]
    out.pop('_hijos', None)
    return out


REQUISITOS = {
    'tele': ('arriba', ([['tele'], ['tele_pequena'], ['tele', 'cajon_oliva']],)),
    'cama': ('arriba', ([['{cama}'], ['{cama}', 'cajon_rosa']],)),
    'cocina': ('arriba', ([['fogones', 'fregadero'], ['fogones'], ['fregadero', 'nevera']],)),
    'nevera': ('arriba', ([['nevera_alta'], ['nevera']],)),
    'mesa': ('suelo', ('cualquiera', [[('mesa_cristal', 0, 0)], [('mesa_cristal', 0, 0), ('{t}', 2, 1)]])),
    'estanteria': ('arriba', ([['estanteria_alta_{m}'], ['estanteria_baja_{m}']],)),
    'armario': ('arriba', ([['ropero_{m}'], ['armario_{m}']],)),
    'vitrina': ('arriba', ([['vitrina_madera'], ['vitrina_blanca'], ['vitrina_alta']],)),
    'estatua': ('arriba', ([['estatua_gargola'], ['pedestal']],)),
    'archivo': ('arriba', ([['archivo_alto'], ['archivador_bajo']],)),
    'caja': ('esquina', ([['cajas'], ['caja']],)),
    'cajonera': ('arriba', ([['cajonera_gris'], ['cajon_gris'], ['cajonera_azul']],)),
    'maquina': ('arriba', ([['consola'], ['maquina_billetes']],)),
    'sofa': ('suelo', ('lado', [[('sofa', 0, 0)]])),
    'planta': ('esquina', ([['planta'], ['arbol_maceta']],)),
    'taburete': ('suelo', ('cualquiera', [[('{t}', 0, 0)]])),
    'mostrador': ('barra', ('lado', 3, False)),
    'altavoz': ('esquina', ([['altavoz']],)),
    'pc': ('arriba', ([['ordenador']],)),
}
PIDE_PAPEL = {'cama': 'cama', 'tele': 'tele', 'cocina': 'cocina', 'mesa': 'mesa', 'estanteria': 'estanteria',
              'vitrina': 'vitrina', 'dependiente': 'mostrador', 'tras_mostrador': 'mostrador'}


def requisitos(e):
    out = []
    for p in e.get('personas', []):
        t = PIDE_PAPEL.get(p.get('papel', ''))
        if t and t not in out:
            out.append(t)
    for k in e.get('carteles', []):
        t = k.get('sobre')
        if t and t != 'pared':
            t = MUEBLES[t]['tipo'] if t in MUEBLES and t not in REQUISITOS else t
            if t not in out:
                out.append(t)
    return out


def tipos_puestos(s):
    out = set()
    for n, _, _ in s.muebles:
        out.add(MUEBLES[n]['tipo'])
        out.add(n)
    if s.anclas.get('tras_mostrador') or s.anclas.get('altar'):
        out.add('mostrador')
    return out


def colocar_persona(s, rng, papel, ocupadas):
    orden = {
        'dependiente': ['tras_mostrador', 'altar', 'escenario', 'pieza:mesa', 'libre'],
        'tras_mostrador': ['tras_mostrador', 'libre'],
        'cliente': ['cliente', 'pieza:mesa', 'pieza:taburete', 'libre'],
        'cura': ['altar', 'tras_mostrador', 'libre'],
        'artista': ['escenario', 'libre'],
        'publico': ['asiento', 'cliente', 'libre'],
        'mesa': ['pieza:mesa', 'pieza:taburete', 'pieza:silla', 'libre'],
        'cama': ['pieza:cama', 'libre'],
        'tele': ['pieza:tele', 'pieza:sofa', 'libre'],
        'cocina': ['pieza:cocina', 'pieza:nevera', 'libre'],
        'estanteria': ['pieza:estanteria', 'pieza:vitrina', 'libre'],
        'vitrina': ['pieza:vitrina', 'pieza:estatua', 'libre'],
        'libre': ['libre'],
    }.get(papel, ['libre'])
    for clave in orden:
        if clave == 'libre':
            cand = [(x, y) for x in range(1, s.W - 1) for y in range(2, s.H - 2) if s.libre((x, y))]
            rng.shuffle(cand)
            for c in cand:
                if c in ocupadas or _junto_al_pasillo(s, c):
                    continue
                return c, rng.choice(['abajo', 'abajo', 'izquierda', 'derecha'])
            continue
        anclas = list(s.anclas.get(clave, []))
        rng.shuffle(anclas)
        for c, mira in anclas:
            if s.libre(c) and c not in ocupadas and not _junto_al_pasillo(s, c):
                return c, mira
    return None, None


def _junto_al_pasillo(s, c):
    return c[0] == s.px and c[1] >= s.H - 4


def se_habla(s, c, alc, carteles=()):
    """Se llega a hablar con quien está en c: desde una casilla de al lado o por encima de un
    mostrador de una o dos casillas de fondo (si no hay un cartel encima, que se leería antes)."""
    for d in DIRS:
        n = (c[0] + d[0], c[1] + d[1])
        if n in alc:
            return True
        m1 = n
        m2 = (c[0] + 2 * d[0], c[1] + 2 * d[1])
        m3 = (c[0] + 3 * d[0], c[1] + 3 * d[1])
        if m1 in carteles or not _es_mostrador(s, m1):
            continue
        if m2 in alc:
            return True
        if m2 not in carteles and _es_mostrador(s, m2) and m3 in alc:
            return True
    return False


def _es_mostrador(s, c):
    return c in s.solido and MUEBLES[s.muebles[s.solido[c]][0]]['tipo'] in ('mostrador', 'poste', 'isla')


def colocar_cartel(s, rng, sobre, alc, ocupadas):
    cand = []
    for i, (n, x, y) in enumerate(s.muebles):
        t = MUEBLES[n]['tipo']
        if sobre and sobre not in (n, t):
            continue
        w, h = ancho(n), alto(n)
        for dx in range(w):
            c = (x + dx, y + h - 1)
            if c in s.solido and c not in ocupadas and (c[0], c[1] + 1) in alc:
                cand.append(c)
    if not cand and sobre == 'pared':
        cand = [(x, 1) for x in range(1, s.W - 1) if (x, 2) in alc and x not in s.huecos_arriba and (x, 1) not in ocupadas]
    rng.shuffle(cand)
    return cand


def firma(e):
    return json.dumps([e.get('tamano'), e.get('suelo'), e.get('pared'), e.get('puerta'), sorted(map(tuple, (tuple([a[0]] + a[1]) for a in e.get('alfombras', [])))),
                       sorted(tuple(m) for m in e.get('muebles', []))], ensure_ascii=False)


# --------------------------------------------------------------------------- ficheros

def compacto(v, nivel=0):
    """JSON legible: listas cortas y objetos pequeños en una línea."""
    sangria = ' ' * nivel
    if isinstance(v, dict):
        if not v:
            return '{}'
        linea = json.dumps(v, ensure_ascii=False)
        if len(linea) <= 100 and not any(isinstance(x, (dict, list)) and x and isinstance(x, dict) for x in v.values()):
            return linea
        partes = ['%s %s: %s' % (sangria, json.dumps(k, ensure_ascii=False), compacto(x, nivel + 1)) for k, x in v.items()]
        return '{\n' + ',\n'.join(partes) + '\n' + sangria + '}'
    if isinstance(v, list):
        if not v:
            return '[]'
        linea = json.dumps(v, ensure_ascii=False)
        if len(linea) <= 100 and not any(isinstance(x, dict) for x in v):
            return linea
        partes = ['%s %s' % (sangria, compacto(x, nivel + 1)) for x in v]
        return '[\n' + ',\n'.join(partes) + '\n' + sangria + ']'
    return json.dumps(v, ensure_ascii=False)


def guardar(ruta, datos):
    with open(ruta, 'w', encoding='utf-8', newline='\n') as f:
        f.write(compacto(datos) + '\n')


def cargar_inventario(ruta):
    if not ruta:
        return {}
    return json.load(open(ruta, encoding='utf-8'))['maps']


def conservar_de(inv, map_id):
    """Pasos y apariciones de la sala actual que otros mapas usan y hay que mantener."""
    out = {'reservar': []}
    return out


def todas_las_firmas(excepto=None):
    vistas = {}
    for f in sorted(os.listdir(DATOS)):
        if not f.endswith('.json') or f.startswith('_'):
            continue
        d = json.load(open(os.path.join(DATOS, f), encoding='utf-8'))
        for mid, e in d.get('interiores', {}).items():
            if mid == excepto or 'muebles' not in e:
                continue
            vistas.setdefault(firma(e), []).append(mid)
    return vistas


def main(argv):
    rehacer = '--rehacer' in argv
    inv = {}
    if '--inventario' in argv:
        inv = cargar_inventario(argv[argv.index('--inventario') + 1])
    if '--firmas' in argv:
        rep = {k: v for k, v in todas_las_firmas().items() if len(v) > 1}
        for k, v in rep.items():
            print('FIRMA REPETIDA:', ', '.join(v))
        print('%d firmas repetidas' % len(rep))
        return 1 if rep else 0
    ciudades = [a for a in argv if not a.startswith('--') and not (len(argv) > argv.index(a) > 0 and argv[argv.index(a) - 1] == '--inventario')]
    errores = 0
    for ciudad in ciudades:
        ruta = os.path.join(DATOS, ciudad + '.json')
        datos = json.load(open(ruta, encoding='utf-8'))
        ints = datos['interiores']
        # Las salas hijas (padre) abren un paso en la pared de arriba de su sala madre.
        hijos = {}
        for mid, e in ints.items():
            if e.get('padre'):
                hijos.setdefault(e['padre'], []).append(mid)
        vistas = todas_las_firmas()
        orden = sorted(ints, key=lambda m: (1 if ints[m].get('padre') else 0, m))
        for mid in orden:
            e = ints[mid]
            if 'muebles' in e and not rehacer:
                continue
            e = dict(e)
            if hijos.get(mid):
                e['_hijos'] = sorted(hijos[mid])
            hecho = None
            ultimo = ''
            for intento in range(200):
                try:
                    cand = planificar(mid, e, conservar_de(inv, mid), intento)
                except ValueError as err:
                    ultimo = str(err)
                    continue
                f = firma(cand)
                if f in vistas and any(o != mid for o in vistas[f]):
                    ultimo = 'firma repetida'
                    continue
                hecho = cand
                break
            if hecho is None:
                print('ERROR %s: %s' % (mid, ultimo))
                errores += 1
                continue
            for k in list(vistas):
                if mid in vistas[k]:
                    vistas[k].remove(mid)
            vistas.setdefault(firma(hecho), []).append(mid)
            ints[mid] = hecho
        # Las salas hijas vuelven por su puerta de abajo al paso de su sala madre.
        for mid, e in ints.items():
            if e.get('padre'):
                madre = ints[e['padre']]
                paso = next((p for p in madre.get('pasos', []) if p['destino'] == mid), None)
                if paso:
                    e['salida'] = {'destino': e['padre'], 'aparicion': paso['vuelta']}
        guardar(ruta, datos)
        print('%s: %d interiores' % (ciudad, len(ints)))
    return 1 if errores else 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
