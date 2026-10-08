#!/usr/bin/env bash
# Genera (o regenera desde la caché) todos los planos reales de docs/mundo/planos/.
# Cada línea: id, latitud y longitud del centro, ancho y alto en metros y metros por casilla.
# La primera vez descarga de OpenStreetMap (Overpass) y tarda; después usa tools/cache/osm/.
# Uso: bash tools/mundo/planos.sh
set -u
cd "$(dirname "$0")/../.."
p() { python3 tools/mundo/osm_plano.py "$@" | head -2 | cut -c1-160; }
p san_miguel_de_bernuy 41.4005 -3.9530 1100 1100 --metros-casilla=12
p madrid_centro 40.4190 -3.7000 3600 2400 --metros-casilla=30 --sin-edificios
p madrid_palacio_real 40.4180 -3.7135 900 700 --metros-casilla=6
p madrid_bernabeu_castellana 40.4500 -3.6905 1400 1200 --metros-casilla=15 --sin-edificios
p sur_de_madrid 40.3180 -3.8000 12000 5000 --metros-casilla=100 --sin-edificios
p mostoles 40.3225 -3.8650 1800 1600 --metros-casilla=15 --sin-edificios
p leganes 40.3290 -3.7640 1800 1600 --metros-casilla=15 --sin-edificios
p getafe 40.3050 -3.7240 2600 2000 --metros-casilla=20 --sin-edificios
p zaragoza 41.6545 -0.8800 2600 1800 --metros-casilla=20 --sin-edificios
p barcelona_centro 41.3920 2.1550 6000 4200 --metros-casilla=40 --sin-edificios
p barcelona_camp_nou 41.3809 2.1228 1000 800 --metros-casilla=8
p palma 39.5690 2.6400 4200 2400 --metros-casilla=30 --sin-edificios
p ibiza 38.9080 1.4330 2200 1600 --metros-casilla=15 --sin-edificios
p valencia 39.4700 -0.3540 7600 4800 --metros-casilla=50 --sin-edificios
p alicante 38.3460 -0.4840 2600 2000 --metros-casilla=20 --sin-edificios
p murcia 37.9860 -1.1300 2200 1800 --metros-casilla=18 --sin-edificios
p sevilla 37.3860 -5.9930 4000 3200 --metros-casilla=30 --sin-edificios
p las_palmas 28.1220 -15.4250 4400 6400 --metros-casilla=40 --sin-edificios
p playa_del_ingles 27.7550 -15.5750 4000 2400 --metros-casilla=30 --sin-edificios
p vigo 42.2370 -8.7240 3600 2600 --metros-casilla=25 --sin-edificios
p santander 43.4680 -3.7900 4800 2600 --metros-casilla=30 --sin-edificios
p bilbao 43.2620 -2.9350 3400 2400 --metros-casilla=25 --sin-edificios
p pamplona 42.8170 -1.6450 2200 1800 --metros-casilla=18 --sin-edificios
p valladolid 41.6520 -4.7250 2400 2200 --metros-casilla=20 --sin-edificios
p puertollano 38.6880 -4.1080 2600 2200 --metros-casilla=20 --sin-edificios
p malaga 36.7200 -4.4200 3400 2400 --metros-casilla=25 --sin-edificios
