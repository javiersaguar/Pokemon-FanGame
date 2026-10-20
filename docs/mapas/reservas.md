# Reservas de mapas

Antes de pintar o editar un mapa, apúntalo aquí (y haz commit). **Un mapa = una persona a la vez.** Al terminar, borra tu fila.

| Mapa (id) | Quién | Desde | Para qué |
|-----------|-------|-------|----------|
| ruta_1 a ruta_26/exterior y maritima_1/exterior | Rutas y ciudades | 2026-10-20 | relieve, agua y detalle (24, 26, 9, 10, 11, 1, 2, 4, marítima 1) y entrenadores con línea de visión y objetos en todas |


Sesión anterior cerrada. Reservas activas del 19 de octubre: Véase `docs/CIERRE_2026-10-15.md`.

## Peticiones a Edificios
- **Resuelto en `d55ff0ed` (Edificios, 20 de octubre):** faro de Ruta 19, casa de madera de Ruta 2 y casa roja de Bilbao recolocados completos, con puertas e interiores conservados. Ver `docs/arte/comparativas/edificios_reales.md`, bloque 1.
- (Rutas y ciudades, 2026-10-19) Para repintar las ciudades que son una explanada empedrada (Zaragoza, Málaga, Getafe, Leganés, Móstoles, Puertollano): bordillo de acera, alcorque con árbol, jardinera de dos casillas y tapia de patio, en el estilo del tileset de exterior. Mientras tanto, solo se ha puesto mobiliario.

- (Edificios, 2026-10-20) Javier autoriza un teatro original para Sevilla y un plató portuario original para el gimnasio de Málaga. Sevilla/rio queda terminado y liberado al cerrar el bloque 3. Málaga/exterior ha sido liberado por Rutas y ciudades (`4bb1376e`) y Edificios ha terminado la nave de 5×5 casillas en el bloque 5. Entrada (58,60), regreso (58,61), salas y 25 pasarelas conservadas; árbol recolocado a (54,55), solar y calle comprobados. Reserva liberada al integrar.

- (Edificios → Interiores, 2026-10-20) El estadio `bernabeu` no tiene puerta ni interior propio en `madrid/bernabeu`; las cinco salas existentes son de otros edificios del barrio. El redibujo conserva ese contrato. Hace falta coordinar una entrada de estadio y salas acordes, reservando primero el exterior y sin alterar las otras cinco conexiones.

## Peticiones a Combate
- (Rutas y ciudades, 2026-10-20) Ruta marítima 1: reglas de Surf para escollos y corrientes (una casilla de corriente que arrastre en una dirección, y escollos que no se puedan atravesar con Surf). Con ellas se añadirán corrientes y objetos en los islotes; ahora solo hay escollos de adorno y el comprobador de alcance va a pie.
