# Fondos de combate según el sitio y la hora

Capturas reales de la pantalla de combate (512×384, dos Pokémon y las cajas de datos), hechas con
`godot --path . -s res://tools/arte/capturar_fondos.gd`. Comparativas al lado de `anil_combate.png`
(Añil a la izquierda): `fondos_combate/hierba_vs_anil.png`, `ciudad_vs_anil.png`,
`gimnasio_madrid_vs_anil.png` y `liga_vs_anil.png`.

**Todo es provisional** hasta que lo apruebe Javier.

## Cómo se monta

- **Datos:** `data/battle_backgrounds.json`. Lógica: `src/battle/scene/battle_backgrounds.gd` (qué
  escena toca) y `src/battle/scene/battle_background.gd` (cómo se pinta).
- **Capas, de atrás adelante**, como en Elite Battle: DX:
  1. el fondo del pack (384×308, a ×2 exacto y con el encuadre de la respuesta 14);
  2. en exteriores, el cielo de EBDX de cada momento del día, con el sol bajo al amanecer y al atardecer
     y estrellas que parpadean de noche;
  3. los elementos de EBDX que configura su `Environments.rb` (decorados, niebla, público, luces de
     discoteca, suelos de la Liga), con su opacidad y su desplazamiento;
  4. el **frente**: piezas puestas a mano en `composiciones` y montadas por `build_fondos.gd`.
- **Tinte del momento del día** (solo exteriores, nunca el cielo ni los Pokémon): el `tone` de EBDX.
  Mañana: cielo de día con luz dorada y el sol saliendo por la izquierda. Tarde: cielo del atardecer,
  tinte naranja y el sol poniéndose por la derecha. Noche: cielo de noche, tinte azul y estrellas.
- **Bases:** un óvalo dibujado a mano (`assets/_fuentes/mundo/base_combate_*.px2`) con la paleta de
  cada material.
- **Sin arte generado por código:** los fondos y elementos son copias byte a byte (procedencia y SHA-256
  en `data/battle_background_assets.json`). Los frentes solo superponen árboles del pack 03 a ×1 y
  piezas que vienen a ×2 exacto (muebles de Akizakura16 y `.px2` a mano), puestas a ×1 con un píxel de
  cada bloque de 2×2. Nada se rota ni se escala.
- **Qué fondo sale:** se decide al empezar el combate (`SceneManager.prepare_battle`). Con Surf o con la
  caña, el de agua. En un exterior, la nieve y la arena bajo los pies del jugador cambian el fondo. Cada
  mapa al aire libre está asignado uno a uno; los interiores, por lo que son (claves en su nombre). El
  test `tests/combate/test_fondos_combate.gd` recorre todos los mapas (más de 950) y falla si alguno se queda con el
  fondo genérico.

## Las escenas

| Escena | Dónde sale | Fondo y piezas | Base | Captura |
|---|---|---|---|---|
| Hierba de ruta | Rutas de campo, parques, San Miguel | *Field* + linde de bosque (pack 03) | hierba | `fondos_combate/hierba.png` |
| Bosque | Casa de Campo, Rutas 2, 17 y 23 | *Forest* + pinares densos + sombra del bosque de EBDX | hierba | `fondos_combate/bosque.png` |
| Olivar | Ruta 13 | *Field* + bosque al fondo y olivos a mano en hileras | tierra | `fondos_combate/olivar.png` |
| Palmeral | Ruta 11 | *Field* + palmeras a mano | tierra | `fondos_combate/palmeral.png` |
| Montaña | Rutas 1, 8, 18, 20, 25 y 26 | *Mountain* + montaña de EBDX + pinos | tierra | `fondos_combate/montana.png` |
| Nieve | Rutas 3 y 12, y cualquier casilla de nieve | *Snow* + montaña nevada de EBDX + abetos nevados | nieve | `fondos_combate/nieve.png` |
| Playa | Las Canteras, Malvarrosa, Playa del Inglés, Rutas 10 y 15, la arena | *Sand* + palmeras, sombrilla, tumbona, tabla y nevera | arena | `fondos_combate/playa.png` |
| Desierto | Ruta 7 (Monegros) | *Sand* + árboles secos y matorral | arena | `fondos_combate/desierto.png` |
| Agua | Ruta marítima 1, Surf y pesca | *Water* + montaña al fondo de EBDX | agua | `fondos_combate/agua.png` |
| Ciudad | Todas las ciudades y barrios | *City* + arbolado de calle | adoquín | `fondos_combate/ciudad.png` |
| Cueva | Cueva de Covadonga, ruinas de Rocafonda, criptas | *Cave* + decorados y niebla de EBDX | roca | `fondos_combate/cueva.png` |
| Cueva oscura | Calle de la Victoria, Andén 0 | *CaveDark* + niebla | roca | `fondos_combate/cueva_oscura.png` |
| Casa | Casas, pisos, portales, graneros, molinos | *IndoorA* + pared, estantería, tele, sofá, armario | madera | `fondos_combate/casa.png` |
| Edificio público | Centros Pokémon, hospitales, Mercadona, estancos, tiendas, oficinas, bares, estaciones, aeropuertos, barcos | *IndoorB* + pared, vitrina, mostrador con ordenador, máquina, archivo | baldosa | `fondos_combate/edificio.png` |
| Monumento | Catedrales, iglesias, palacios, museos, teatros, Congreso | *IndoorB* + columnas, estatuas y retrato | mármol | `fondos_combate/monumento.png` |
| Gimnasio 1 · Real Casa de Correos | Sus cuatro salas y la terraza del ático | *IndoorA* + escaños, banderas, retrato de la presidenta, atril, lámpara | alfombra roja | `fondos_combate/gimnasio_madrid.png` |
| Gimnasio 2 · Spotify Camp Nou | Sus cuatro salas | *Field* + gradas azulgrana, público, escudo, portería, palanca y obras | césped | `fondos_combate/gimnasio_barcelona.png` |
| Gimnasio 3 · Akuarela Playa | Sus cuatro salas | *DanceFloor* + luces de discoteca, público, bola, cabina del DJ, altavoces | pista de luces | `fondos_combate/gimnasio_valencia.png` |
| Gimnasio 4 · El Club de la Comedia | Sus cuatro salas | *IndoorB* + pared, escenario, micro, focos, guitarra, trajes de flamenca | tablas | `fondos_combate/gimnasio_sevilla.png` |
| Gimnasio 5 · Concierto en la playa | Sus cuatro salas | *Sand* + escenario, batería, altavoces, focos, público, palmeras | arena | `fondos_combate/gimnasio_playa_del_ingles.png` |
| Gimnasio 6 · San Mamés | Sus cuatro salas | *Field* + gradas rojiblancas, público, escudo, portería, taquillas | césped | `fondos_combate/gimnasio_bilbao.png` |
| Gimnasio 7 · Plaza Mayor | Sus cuatro salas | *IndoorA* + columnas, lámparas de araña, barandilla dorada, retrato del Rey, estufa | alfombra granate | `fondos_combate/gimnasio_valladolid.png` |
| Gimnasio 8 · Rodaje en el puerto | Sus cuatro salas | *Darkness* + andamio, cámara, silla del director, claqueta, focos, camerino | plató | `fondos_combate/gimnasio_malaga.png` |
| Liga · Alto Mando | Salas de Alonso, Gasol, Iniesta y Nadal | *Champion* + todos los elementos de la Liga de EBDX, banderas, retrato y lámparas | tarima dorada | `fondos_combate/liga.png` |
| Liga · campeón | Sala de Pedro Sánchez | *Sapphire* + elementos de EBDX, atril, banderas y copa | tarima dorada | `fondos_combate/liga_campeon.png` |

Momentos del día del fondo de hierba: `fondos_combate/hierba_morning.png`, `hierba_day.png`,
`hierba_evening.png` y `hierba_night.png`; la ciudad de noche, `fondos_combate/ciudad_night.png`.

## Comparación con Añil

- **Como Añil:** fondo con profundidad y horizonte, linde de árboles detrás del rival, cajas de datos
  encima y Pokémon a ×2. En los exteriores, el cielo y la luz cambian con la hora, como en EBDX.
- **Distinto a propósito:** Añil no pone plataformas bajo los Pokémon (EBDX solo cambia el suelo). Aquí
  hay bases, como pidió Javier y como en los juegos de 4.ª y 5.ª generación.
- **Pendiente de revisar con Javier:** los rótulos de los gimnasios no se ponen (a ×1 no se leen); las
  nubes de EBDX tampoco, porque solo funcionan teñidas con el color del cielo.

## Referencia nueva · 25 de octubre de 2026

Javier aporta una [captura de combate de World Frontier](../referencias/javier_2026-10-25/combate_world_frontier.png). Pide mejorar el diseño dentro del combate y los ambientes. [Análisis y orden de trabajo](../guia_world_frontier_2026-10-25.md): campo continuo y legible, arquitectura y luz coherentes, paneles más cuidados y muestra con mensaje y cuatro acciones. Los 25 ambientes anteriores existen y sus pruebas pasan; este añadido no los declara redibujados.

Desajuste detectado: la terraza `madrid/atico_ayuso` usa el mismo fondo interior y alfombra que las salas de Madrid; necesita una variante exterior. El nombre «Real Casa de Correos» de la escena también está desactualizado respecto a ese emplazamiento. Pendiente del siguiente bloque de Combate/interfaz.
