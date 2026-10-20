# Reservas de mapas

Antes de pintar o editar un mapa, apúntalo aquí (y haz commit). **Un mapa = una persona a la vez.** Al terminar, borra tu fila.

| Mapa (id) | Quién | Desde | Para qué |
|-----------|-------|-------|----------|
| `maritima_1/exterior` y `ruta_1/exterior` … `ruta_26/exterior` | Rutas y ciudades | 2026-10-20 | Corrientes y escollos (marítima 1), obstáculos de campo, entrenadores en los pasos estrechos y atajos (`feat/rutas-anil-3`) |
| Interiores de las casas de las rutas 2, 3, 4, 9, 10, 11, 12, 13, 14, 15, 17, 18, 19, 20 y 23 (`ruta_N/casa_*` y salas de dentro; **no** los exteriores) | Interiores | 2026-10-20 | Las 93 salas que siguen con el interior genérico (`feat/interiores-rutas`). Solo cambio las escenas de interior y `data/interiores/ruta_N.json` |



## Peticiones a Edificios
- **Resuelto en `d55ff0ed` (Edificios, 20 de octubre):** faro de Ruta 19, casa de madera de Ruta 2 y casa roja de Bilbao recolocados completos, con puertas e interiores conservados. Ver `docs/arte/comparativas/edificios_reales.md`, bloque 1.
- **Abierta** (Rutas y ciudades, 2026-10-19; las explanadas se repintaron después con piezas existentes, `bc503714`): Para repintar las ciudades que son una explanada empedrada (Zaragoza, Málaga, Getafe, Leganés, Móstoles, Puertollano): bordillo de acera, alcorque con árbol, jardinera de dos casillas y tapia de patio, en el estilo del tileset de exterior. Mientras tanto, solo se ha puesto mobiliario.

- **Resuelta** (Edificios, 2026-10-20) Javier autoriza un teatro original para Sevilla y un plató portuario original para el gimnasio de Málaga. Sevilla/rio queda terminado y liberado al cerrar el bloque 3. Málaga/exterior ha sido liberado por Rutas y ciudades (`4bb1376e`) y Edificios ha terminado la nave de 5×5 casillas en el bloque 5. Entrada (58,60), regreso (58,61), salas y 25 pasarelas conservadas; árbol recolocado a (54,55), solar y calle comprobados. Reserva liberada al integrar.

- **Abierta** (Edificios → Interiores, 2026-10-20) El estadio `bernabeu` no tiene puerta ni interior propio en `madrid/bernabeu`; las cinco salas existentes son de otros edificios del barrio. El redibujo conserva ese contrato. Hace falta coordinar una entrada de estadio y salas acordes, reservando primero el exterior y sin alterar las otras cinco conexiones.

## Peticiones a Combate
- **Resuelta en `be78d647`** (la lógica `SurfCurrent` existe; falta colocarla en el mapa, ver «Peticiones de Combate») (Rutas y ciudades, 2026-10-20) Ruta marítima 1: reglas de Surf para escollos y corrientes (una casilla de corriente que arrastre en una dirección, y escollos que no se puedan atravesar con Surf). Con ellas se añadirán corrientes y objetos en los islotes; ahora solo hay escollos de adorno y el comprobador de alcance va a pie.

## Peticiones de Combate

- **Abierta** (Combate y sistemas, 2026-10-20) **Ruta marítima 1**: poner corrientes con nodos `SurfCurrent` (`src/overworld/surf_current.gd`: posición = esquina de arriba a la izquierda, `size_tiles` y `direction`) que lleven hacia los islotes o los alejen, y escollos (rocas con colisión en el agua) que obliguen a rodear. La lógica ya está; falta colocarlos en el mapa. Las corrientes solo actúan con Surf, y Surf sigue desactivado hasta que Javier decida su objeto o medalla.
- **Abierta** (Combate y sistemas, 2026-10-20) Donde la ruta lo pida: rocas de Fuerza y de Golpe Roca y arbustos de Corte con `FieldObstacle` (y `cleared_flag` si deben desaparecer para siempre), y casillas `waterfall` para Cascada.

