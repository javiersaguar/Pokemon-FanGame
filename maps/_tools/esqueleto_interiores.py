#!/usr/bin/env python3
"""Crea o completa data/interiores/<ciudad>.json con todas las salas de una ciudad que hay que
personalizar: la pieza de su fachada, su puerta en la calle, un tipo y un nombre propuestos y,
si la sala tiene un regalo, la persona que lo da (mismo nodo, data/npc_rewards.json).
No toca las entradas que ya existen. Deja fuera los gimnasios, el Quirón, los locales de
servicio (Centro Pokémon, hospital, Mercadona y estanco), los transportes y las salas de la
historia (laboratorio, casas del jugador y del rival).

Uso: python3 maps/_tools/esqueleto_interiores.py <inventario.json> <ciudad> [<ciudad> ...]
"""

import hashlib
import json
import os
import sys

sys.dont_write_bytecode = True
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import planificar_interiores as pl  # noqa: E402

SERVICIOS = {'mercadona', 'estanco', 'centro', 'hospital'}
FUERA = {
    'madrid/quiron', 'madrid/laboratorio', 'madrid/atico_ayuso',
    'pozuelo/casa_jugador', 'pozuelo/casa_rival', 'orcasitas/casa_jugador', 'orcasitas/casa_rival',
    # Transporte (Agente 4): andenes del AVE y terminales con control de seguridad.
    'madrid/sala_retiro_20_58', 'malaga/sala_calle_5_57', 'valladolid/sala_calle_52_59',
    'playa_del_ingles/aeropuerto', 'vigo/aeropuerto',
    # Apeadero del AVE de San Miguel (Agente 4, pintar_transportes.gd).
    'pueblo_inicial/sala_calle_30_21',
    # Salas de hitos con interior propio (maps/_pintura/pintar_salas_hitos.gd).
    'santander/botin', 'santander/botin_sala', 'bilbao/guggenheim', 'bilbao/guggenheim_rampa', 'bilbao/guggenheim_sala',
    'pamplona/cafe_iruna', 'pamplona/cafe_comedor', 'rocafonda/ruinas', 'rocafonda/ruinas_2',
    'ruta_17/horreo', 'ruta_18/covadonga', 'ruta_18/covadonga_cueva',
    # Casas de Getafe diseñadas a mano con sus pruebas (regalo y PC de la vecina, tests/ui/test_city_services.gd).
    'getafe/casa_1', 'getafe/casa_vecina',
    # Piso de Rufián y su portal (Agente 2, personajes decididos por Javier).
    'barcelona/sala_eixample_10_31', 'barcelona/casa_rufian', 'barcelona/habitacion_rufian',
}
TIPOS = [
    ('casa_ibicenca', 'vivienda'), ('casa_', 'vivienda'), ('cabana', 'rural'), ('barraca', 'barraca'), ('horreo', 'horreo'),
    ('bloque', 'piso'), ('edificio_cupula', 'piso'), ('edificio_cristal', 'oficina'), ('rascacielos', 'piso'),
    ('intempo', 'piso'), ('atico', 'portal'), ('oficinas', 'oficina'), ('tienda_flores', 'floristeria'),
    ('tienda', 'tienda'), ('puesto', 'puesto'), ('grandes_almacenes', 'grandes_almacenes'), ('teatro', 'teatro'),
    ('torre_socorrista', 'socorrismo'), ('faro', 'faro'), ('molino', 'molino'), ('torre', 'torre'),
    ('ermita', 'ermita'), ('iglesia', 'iglesia'), ('catedral', 'catedral'), ('basilica', 'basilica'),
    ('concatedral', 'catedral'), ('san_', 'iglesia'), ('magdalena', 'iglesia'), ('asuncion', 'iglesia'),
    ('la_seo', 'catedral'), ('micalet', 'catedral'), ('sagrada_familia', 'basilica'), ('monasterio', 'monasterio'),
    ('castillo', 'castillo'), ('puerta_leon', 'castillo'), ('palacio', 'palacio'), ('palau', 'palacio'),
    ('casa_carbonell', 'palacio'), ('casa_batllo', 'museo'), ('la_pedrera', 'museo'), ('edificio_metropolis', 'oficina'),
    ('edificio_carrion', 'cine'), ('museo', 'museo'), ('templo', 'templo'), ('guggenheim', 'museo'), ('centro_botin', 'museo'),
    ('lonja', 'lonja'), ('mercado', 'mercado'), ('boqueria', 'mercado'), ('estacion', 'estacion'), ('boca_metro', 'estacion'),
    ('congreso', 'congreso'), ('ayuntamiento', 'ayuntamiento'), ('universidad', 'universidad'), ('maestranza', 'museo'),
    ('club', 'club'), ('panaderia', 'panaderia'), ('dolmen', 'dolmen'), ('ruinas', 'ruinas'), ('velero', 'caseta'),
    ('gimnasio_madera', 'gimnasio'), ('cafe_iruna', 'cafeteria'),
]


def tipo_de(pieza, mid):
    for clave, tipo in TIPOS:
        if pieza.startswith(clave) or pieza == clave.rstrip('_'):
            if tipo == 'piso' and pieza.startswith('bloque'):
                return 'portal' if int(hashlib.sha1(mid.encode()).hexdigest(), 16) % 3 == 0 else 'piso'
            return tipo
    return 'vivienda'


def main(argv):
    inv = json.load(open(argv[0], encoding='utf-8'))['maps']
    entradas = {}
    for mid, m in inv.items():
        if not m['outdoor']:
            continue
        for w in m['warps']:
            entradas.setdefault(w['target_map'], []).append((mid, w))
    for ciudad in argv[1:]:
        ruta = os.path.join(pl.DATOS, ciudad + '.json')
        if os.path.exists(ruta):
            datos = json.load(open(ruta, encoding='utf-8'))
        else:
            datos = {'_doc': 'Interiores personalizados de %s (propuesta provisional: textos, gente y distribución pendientes de Javier). Lo pinta maps/_pintura/pintar_interiores_datos.gd; la distribución la calcula maps/_tools/planificar_interiores.py.' % ciudad,
                     'ciudad': ciudad.replace('_', ' ').title(), 'interiores': {}}
        ints = datos['interiores']
        nuevas = 0
        for mid in sorted(inv):
            m = inv[mid]
            if m['outdoor'] or mid.split('/')[0] != ciudad or mid in FUERA:
                continue
            f = mid.split('/')[-1]
            if f in SERVICIOS or f.startswith('gimnasio') or mid.startswith('transporte/'):
                continue
            if mid not in entradas and not any(mid in [x['target_map'] for x in mm['warps']] for mm in inv.values()):
                # Sala sin ninguna puerta que lleve a ella: no se personaliza.
                continue
            if mid in ints:
                continue
            fuera = entradas.get(mid, [])
            pieza = fuera[0][1].get('piece', '') if fuera else ''
            e = {'tipo': tipo_de(pieza, mid), 'nombre': m['display_name'].split(' · ')[0], 'pieza': pieza}
            if fuera:
                e['calle'] = [fuera[0][0], fuera[0][1]['tile']]
            for ent in m['entities']:
                if ent.get('event', '').endswith('npc_reward_event.gd'):
                    e['personas'] = [{'nodo': ent['name'], 'nombre': 'Anfitriona', 'aspecto': ent.get('sheet', 'npc_woman'),
                                      'regalo': ent['event_params']['reward_id']}]
            ints[mid] = e
            nuevas += 1
        pl.guardar(ruta, datos)
        print('%s: %d salas (%d nuevas)' % (ciudad, len(ints), nuevas))


if __name__ == '__main__':
    main(sys.argv[1:])
