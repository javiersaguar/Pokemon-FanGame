# Reservas de mapas

Antes de pintar o editar un mapa, apúntalo aquí (y haz commit). **Un mapa = una persona a la vez.** Al terminar, borra tu fila.

| Mapa (id) | Quién | Desde | Para qué |
|-----------|-------|-------|----------|
| `maritima_1/exterior` y `ruta_1/exterior` … `ruta_26/exterior` | Rutas y ciudades | 2026-10-20 | Corrientes y escollos (marítima 1), obstáculos de campo, entrenadores en los pasos estrechos y atajos (`feat/rutas-anil-3`) |
| Interiores de las casas de las rutas 2, 3, 4, 9, 10, 11, 12, 13, 14, 15, 17, 18, 19, 20 y 23 (`ruta_N/casa_*` y salas de dentro; **no** los exteriores) | Interiores | 2026-10-20 | Las 93 salas que siguen con el interior genérico (`feat/interiores-rutas`). Solo cambio las escenas de interior y `data/interiores/ruta_N.json` |
| `madrid/bernabeu` | Edificios | 2026-10-21 | Preparar puerta física de la pieza 375, sin enlazar interiores; conservar cinco pasarelas del barrio |



## Peticiones a Edificios
- **Resuelto en `d55ff0ed` (Edificios, 20 de octubre):** faro de Ruta 19, casa de madera de Ruta 2 y casa roja de Bilbao recolocados completos, con puertas e interiores conservados. Ver `docs/arte/comparativas/edificios_reales.md`, bloque 1.
- **Resuelta** (Edificios, 2026-10-21; petición de Rutas y ciudades, 2026-10-19; las explanadas se repintaron después con piezas existentes, `bc503714`): Para repintar las ciudades que son una explanada empedrada (Zaragoza, Málaga, Getafe, Leganés, Móstoles, Puertollano): bordillo de acera, alcorque con árbol, jardinera de dos casillas y tapia de patio, en el estilo del tileset de exterior. Entregadas 30 piezas (fuentes 386–415); lista y montaje en `docs/arte/comparativas/edificios_reales.md`, «Piezas urbanas».

- **Resuelta** (Edificios, 2026-10-20) Javier autoriza un teatro original para Sevilla y un plató portuario original para el gimnasio de Málaga. Sevilla/rio queda terminado y liberado al cerrar el bloque 3. Málaga/exterior ha sido liberado por Rutas y ciudades (`4bb1376e`) y Edificios ha terminado la nave de 5×5 casillas en el bloque 5. Entrada (58,60), regreso (58,61), salas y 25 pasarelas conservadas; árbol recolocado a (54,55), solar y calle comprobados. Reserva liberada al integrar.

- **Abierta** (Edificios → Interiores, 2026-10-20) El estadio `bernabeu` no tiene puerta ni interior propio en `madrid/bernabeu`; las cinco salas existentes son de otros edificios del barrio. El redibujo conserva ese contrato. Hace falta coordinar una entrada de estadio y salas acordes, reservando primero el exterior y sin alterar las otras cinco conexiones.

## Peticiones a Combate
- **Resuelta en `be78d647`** (la lógica `SurfCurrent` existe; falta colocarla en el mapa, ver «Peticiones de Combate») (Rutas y ciudades, 2026-10-20) Ruta marítima 1: reglas de Surf para escollos y corrientes (una casilla de corriente que arrastre en una dirección, y escollos que no se puedan atravesar con Surf). Con ellas se añadirán corrientes y objetos en los islotes; ahora solo hay escollos de adorno y el comprobador de alcance va a pie.

## Peticiones de Combate

- **Resuelta** (Rutas y ciudades, `feat/rutas-anil-3`): cuatro corrientes y 22 escollos colocados, con camino, cala del premio y `tests/mundo/test_corrientes.gd`. (Combate y sistemas, 2026-10-20) **Ruta marítima 1**: poner corrientes con nodos `SurfCurrent` (`src/overworld/surf_current.gd`: posición = esquina de arriba a la izquierda, `size_tiles` y `direction`) que lleven hacia los islotes o los alejen, y escollos (rocas con colisión en el agua) que obliguen a rodear. La lógica ya está; falta colocarlos en el mapa. Las corrientes solo actúan con Surf, y Surf sigue desactivado hasta que Javier decida su objeto o medalla.
- **Abierta** (Combate y sistemas, 2026-10-20) Donde la ruta lo pida: rocas de Fuerza y de Golpe Roca y arbustos de Corte con `FieldObstacle` (y `cleared_flag` si deben desaparecer para siempre), y casillas `waterfall` para Cascada.


### Entrega de piezas urbanas a Rutas

30 módulos preparados en `feat/edificios-personajes`, fuentes **386–415**. IDs, anclas, colisiones y montaje: `docs/arte/comparativas/edificios_reales.md`, «Piezas urbanas». No se ha modificado ningún mapa reservado. Validados con suite completa, arte, datos y grafo; disponibles al integrar esta entrega en `main`. Bordillos y alcorque vacío van bajo los personajes, sin colisión. Tapias, jardineras y árbol tienen huella explícita. No hace falta regenerar el tileset desde Rutas.

### Coordinación de la puerta del Bernabéu

Edificios prepara el hueco de entrada de la pieza 375. Ancla conservada **(14,14)**; puerta relativa **(5,0)**, casilla exterior **(19,14)**, futuro regreso **(19,15)**. Se evita el cartel de (20,15). **No enlazar a ninguna de las cinco salas del barrio**: pertenecen a otras fachadas. Petición abierta para otra sesión de Interiores: **vestíbulo, vestuarios, palco y túnel**, con entrada y salida en ese acceso. En esta tarea solo se prepara el dibujo y la colisión de la puerta, sin añadir pasarela ni sala. La escena y los personajes no se repintan.
