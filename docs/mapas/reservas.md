# Reservas de mapas

Antes de pintar o editar un mapa, apúntalo aquí (y haz commit). **Un mapa = una persona a la vez.** Al terminar, borra tu fila.

| Mapa (id) | Quién | Desde | Para qué |
|-----------|-------|-------|----------|
| Interiores de Ibiza: `ibiza/casa_*`, `ibiza/sala_*` y sus salas nuevas (`*_dormitorio`, `sala_calle_48_33_barra`) | Agente 1 | 2026-10-15 | interiores personalizados desde `data/interiores/ibiza.json`; sin tocar el exterior ni los locales de servicio |
| Interiores de Madrid, Barcelona, Valencia y Sevilla: `<ciudad>/sala_*` y `<ciudad>/casa_*` (sin gimnasios, Quirón, ático, laboratorio, locales de servicio ni `barcelona/sala_eixample_10_31`) | Agente 1 | 2026-10-15 | interiores personalizados desde `data/interiores/<ciudad>.json`; puertas y salidas conservadas |
| ruta_16/exterior, ruta_5/exterior, ruta_6/exterior, ruta_7/exterior, ruta_8/exterior | Agente 5 | 2026-10-15 | detalle de exterior al nivel de Añil (bosque, relieve, agua, adornos, objetos y entrenadores); sin repintar, se conservan puertas y conexiones |
| Los 32 mapas de gimnasio (`<ciudad>/gimnasio_1`, `_2`, `_3` y `gimnasio_lider` de madrid, barcelona, valencia, sevilla, playa_del_ingles, bilbao, valladolid y malaga) | Agente 3 | 2026-10-15 | decoración temática, puzle y líder de cada gimnasio (`pintar_gimnasios.gd`) |
| madrid/quiron y madrid/atico_ayuso | Agente 3 | 2026-10-15 | recorrido completo del gimnasio 1: Quirón → Casa de Correos → despacho → ático |
| madrid/liga_iniesta, madrid/liga_nadal, madrid/liga_gasol, madrid/liga_alonso y madrid/liga_sanchez (nuevos) | Agente 2 | 2026-10-15 | la Liga del Palacio Real: una sala por miembro del Alto Mando y la del Líder Supremo (decisión de Javier); la entrada desde el interior del Palacio, reservado por el Agente 1, va en Peticiones |
| calle_victoria/* (nuevos), madrid/centro y madrid/palacio_real | Agente 4 | 2026-10-15 | Calle de la Victoria: el túnel largo bajo Sol y sus dos bocas (una pieza de boca de metro y su puerta en cada exterior, sin repintar) |
| playa_del_ingles/exterior y vigo/exterior | Agente 4 | 2026-10-15 | el Falcon aparcado junto a los aeropuertos (una pieza nueva y un cartel, sin repintar ni tapar pasarelas) |
