# Reservas de mapas

Antes de pintar o editar un mapa, apúntalo aquí (y haz commit). **Un mapa = una persona a la vez.** Al terminar, borra tu fila.

| Mapa (id) | Quién | Desde | Para qué |
|-----------|-------|-------|----------|
| Interiores de Ibiza: `ibiza/casa_*`, `ibiza/sala_*` y sus salas nuevas (`*_dormitorio`, `sala_calle_48_33_barra`) | Agente 1 | 2026-10-15 | interiores personalizados desde `data/interiores/ibiza.json`; sin tocar el exterior ni los locales de servicio |
| Interiores de Madrid, Barcelona, Valencia y Sevilla: `<ciudad>/sala_*` y `<ciudad>/casa_*` (sin gimnasios, Quirón, ático, laboratorio, locales de servicio ni `barcelona/sala_eixample_10_31`) | Agente 1 | 2026-10-15 | interiores personalizados desde `data/interiores/<ciudad>.json`; puertas y salidas conservadas |
| ruta_26/exterior, ruta_21/exterior, ruta_24/exterior, ruta_25/exterior, ruta_22/exterior | Agente 5 | 2026-10-15 | estructura y paso por hierba según la guía de composición, después detalle (bosque, relieve, agua, adornos, objetos y entrenadores); sin repintar, se conservan puertas y conexiones |
| Los 32 mapas de gimnasio (`<ciudad>/gimnasio_1`, `_2`, `_3` y `gimnasio_lider` de madrid, barcelona, valencia, sevilla, playa_del_ingles, bilbao, valladolid y malaga) | Agente 3 | 2026-10-15 | decoración temática, puzle y líder de cada gimnasio (`pintar_gimnasios.gd`) |
| madrid/quiron y madrid/atico_ayuso | Agente 3 | 2026-10-15 | recorrido completo del gimnasio 1: Quirón → Casa de Correos → despacho → ático |
