# Reservas de mapas

Antes de pintar o editar un mapa, apúntalo aquí (y haz commit). **Un mapa = una persona a la vez.** Al terminar, borra tu fila.

| Mapa (id) | Quién | Desde | Para qué |
|-----------|-------|-------|----------|
| `playa_del_ingles/exterior`, `orcasitas/exterior`, `sevilla/centro`, `valladolid/exterior`, `pamplona/exterior`, `vigo/exterior`, `las_palmas/vegueta_triana`, `ibiza/exterior`, `bilbao/exterior`, `santander/exterior`, `huelva/exterior`, `murcia/exterior`, `alicante/exterior`, `malaga/exterior`, `palma/exterior`, `madrid/moncloa`, `madrid/chamberi`, `madrid/bernabeu`, `madrid/retiro`, `pozuelo/exterior`, `soto_del_real/exterior` y `madrid/palacio_real` | Rutas y ciudades | 2026-10-20 | Segunda pasada a nivel Añil: llenar huecos y romper bordes rectos con árboles, alcorques y jardineras, sin mover puertas (`feat/rutas-anil-3`) |
| `maritima_1/exterior` y `ruta_1/exterior` … `ruta_26/exterior` | Rutas y ciudades | 2026-10-20 | Corrientes y escollos (marítima 1), obstáculos de campo, entrenadores en los pasos estrechos y atajos (`feat/rutas-anil-3`) |
| Salas de dentro (solo interiores) de 17 monumentos: Alcázar y Archivo de Indias (Sevilla), Liceu, Alcazaba, Gibralfaro y Catedral de Málaga, Almudaina y Bellver, Santa Bárbara, la Magdalena, Universidad de Alcalá, Infantado, Montserrat, Catedral de Valladolid, Museo de la Minería, Atapuerca, Castillo de la Luz y Catedral de Bilbao | Interiores | 2026-10-21 | Una o dos salas hijas por monumento; la sala madre se redistribuye para abrir el paso. Sin tocar exteriores (`feat/interiores-rutas`) |



## Peticiones a Edificios
- **Abierta** (Rutas y ciudades, 2026-10-20) Casillas de **cascada** para el tileset de exterior, con terreno `waterfall` (las usa `Player` para Cascada): una caída de dos o tres casillas de alto que empalme con el agua de abajo y de arriba, del estilo del tileset. En los packs no hay autotile de cascada (solo `DistortionWorld_Waterfall` del pack 05, que es del Mundo Distorsión). Hasta entonces no hay Cascada en ningún mapa.
- **Resuelto en `d55ff0ed` (Edificios, 20 de octubre):** faro de Ruta 19, casa de madera de Ruta 2 y casa roja de Bilbao recolocados completos, con puertas e interiores conservados. Ver `docs/arte/comparativas/edificios_reales.md`, bloque 1.
- **Resuelta** (Edificios, 2026-10-21; petición de Rutas y ciudades, 2026-10-19; las explanadas se repintaron después con piezas existentes, `bc503714`): Para repintar las ciudades que son una explanada empedrada (Zaragoza, Málaga, Getafe, Leganés, Móstoles, Puertollano): bordillo de acera, alcorque con árbol, jardinera de dos casillas y tapia de patio, en el estilo del tileset de exterior. Entregadas 30 piezas (fuentes 386–415); lista y montaje en `docs/arte/comparativas/edificios_reales.md`, «Piezas urbanas».

- **Resuelta** (Edificios, 2026-10-20) Javier autoriza un teatro original para Sevilla y un plató portuario original para el gimnasio de Málaga. Sevilla/rio queda terminado y liberado al cerrar el bloque 3. Málaga/exterior ha sido liberado por Rutas y ciudades (`4bb1376e`) y Edificios ha terminado la nave de 5×5 casillas en el bloque 5. Entrada (58,60), regreso (58,61), salas y 25 pasarelas conservadas; árbol recolocado a (54,55), solar y calle comprobados. Reserva liberada al integrar.

- **Abierta para Interiores; acceso preparado** (Edificios → Interiores, actualización 2026-10-21). Puerta física del estadio en **(19,14)**, relativa **(5,0)** al ancla **(14,14)**; futuro regreso libre **(19,15)**. Sin `Warp` por encargo de Javier. Pendientes **vestíbulo, vestuarios, palco y túnel** para otra sesión. Las cinco salas actuales son de otros edificios y conservan sus conexiones. Exterior liberado; volver a reservar antes de enlazar.

## Peticiones a Combate
- **Resuelta en `be78d647`** (la lógica `SurfCurrent` existe; falta colocarla en el mapa, ver «Peticiones de Combate») (Rutas y ciudades, 2026-10-20) Ruta marítima 1: reglas de Surf para escollos y corrientes (una casilla de corriente que arrastre en una dirección, y escollos que no se puedan atravesar con Surf). Con ellas se añadirán corrientes y objetos en los islotes; ahora solo hay escollos de adorno y el comprobador de alcance va a pie.

## Peticiones de Combate

- **Resuelta** (Rutas y ciudades, `feat/rutas-anil-3`): cuatro corrientes y 22 escollos colocados, con camino, cala del premio y `tests/mundo/test_corrientes.gd`. (Combate y sistemas, 2026-10-20) **Ruta marítima 1**: poner corrientes con nodos `SurfCurrent` (`src/overworld/surf_current.gd`: posición = esquina de arriba a la izquierda, `size_tiles` y `direction`) que lleven hacia los islotes o los alejen, y escollos (rocas con colisión en el agua) que obliguen a rodear. La lógica ya está; falta colocarlos en el mapa. Las corrientes solo actúan con Surf, y Surf sigue desactivado hasta que Javier decida su objeto o medalla.
- **Resuelta en parte** (Rutas y ciudades, `feat/rutas-anil-3`): 9 obstáculos (4 de Corte, 4 de Golpe Roca y 1 de Fuerza) que solo cierran objetos, y 8 atajos; `data/bloqueos_campo.json` y `tests/mundo/test_bloqueos_campo.gd`. **Cascada, no:** el tileset no tiene casillas de cascada (pedidas a Edificios). (Combate y sistemas, 2026-10-20) Donde la ruta lo pida: rocas de Fuerza y de Golpe Roca y arbustos de Corte con `FieldObstacle` (y `cleared_flag` si deben desaparecer para siempre), y casillas `waterfall` para Cascada.


### Entrega de piezas urbanas a Rutas

30 módulos preparados en `feat/edificios-personajes`, fuentes **386–415**. IDs, anclas, colisiones y montaje: `docs/arte/comparativas/edificios_reales.md`, «Piezas urbanas». No se ha modificado ningún mapa reservado. Validados con suite completa, arte, datos y grafo; disponibles al integrar esta entrega en `main`. Bordillos y alcorque vacío van bajo los personajes, sin colisión. Tapias, jardineras y árbol tienen huella explícita. No hace falta regenerar el tileset desde Rutas.

### Coordinación de la puerta del Bernabéu

Edificios prepara el hueco de entrada de la pieza 375. Ancla conservada **(14,14)**; puerta relativa **(5,0)**, casilla exterior **(19,14)**, futuro regreso **(19,15)**. Se evita el cartel de (20,15). **No enlazar a ninguna de las cinco salas del barrio**: pertenecen a otras fachadas. Petición abierta para otra sesión de Interiores: **vestíbulo, vestuarios, palco y túnel**, con entrada y salida en ese acceso. En esta tarea solo se prepara el dibujo y la colisión de la puerta, sin añadir pasarela ni sala. La escena y los personajes no se repintan.

**Entrega del acceso (21 de octubre):** puerta transitable comprobada, sin pasarela; cinco conexiones conservadas. Suite 751/751, arte y datos sin errores, grafo conectado. Exterior liberado.

**Salas hechas (Interiores, 21 de octubre):** pasarela `Estadio` en (19,14) con vuelta `from_estadio` en (19,15), hacia la sala de trofeos `madrid/sala_bernabeu_19_14` y sus tres salas de dentro (vestuario, túnel y palco). Exterior sin repintar; cinco pasarelas del barrio intactas. **Petición cerrada.**
