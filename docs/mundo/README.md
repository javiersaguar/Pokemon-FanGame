# El mundo de Pokémon Spain

Carpeta de trabajo para construir la región **ciudad a ciudad**. Aquí está todo lo investigado (lugares reales, monumentos, distribución de cada ciudad) y las propuestas de diseño, para que cualquier agente pueda coger una ciudad y desarrollarla entera sin volver a investigar.

> Decisiones de Javier (2026-10-09): ciudades, líderes, Alto Mando, Campeón, otras ciudades, personajes y locales de la lista de abajo. **El lore de cada ciudad lo decide Javier más adelante.** Todo lo que no viene de él va marcado como **propuesta** o **PENDIENTE JAVIER**.

## Índice

| Documento | Qué tiene |
|-----------|-----------|
| [`region.md`](region.md) | Mapa de la región, orden de la aventura, rutas, transportes, curva de niveles y coordenadas del mapa regional |
| [`mapa_region.svg`](mapa_region.svg) | Esquema visual del mapa (solo documentación; el mapa del juego se dibuja aparte) |
| [`rutas.md`](rutas.md) | Las rutas entre ciudades con su paisaje real, entrenadores y Pokémon propuestos |
| [`ciudades/`](ciudades/) | **Una ficha por ciudad**: lugares reales, cómo representarlos con los tiles, distribución del mapa, gimnasio, entrenadores, tiendas y conexiones |
| [`personajes.md`](personajes.md) | Los famosos: diseño como personaje (sprite del pack 11), dónde aparecen, equipo, frases y foto real en combate |
| [`locales.md`](locales.md) | Mercadona, Estanco y Basic Fit (y el Centro Pokémon): qué hacen en el juego y cómo se ven |
| [`arte_ciudades.md`](arte_ciudades.md) | Qué edificios y monumentos hay en los packs, cuáles hay que componer y cuáles hay que dibujar a mano |

## Lo que decidió Javier

**Gimnasios** (en este orden):

| # | Ciudad | Líder | Dónde es el combate |
|---|--------|-------|---------------------|
| 1 | Madrid | Isabel Díaz Ayuso | En su ático |
| 2 | Barcelona | Joan Laporta | En el Camp Nou |
| 3 | Valencia | Labrador (*Gandía Shore*) | Discoteca Akuarela |
| 4 | Sevilla | Joaquín Sánchez | En "el club de la comedia" |
| 5 | Las Palmas de Gran Canaria | Quevedo | Playa del Inglés |
| 6 | Bilbao | La chica del *Aupa Athletic* | San Mamés |
| 7 | Valladolid | Juanmi Latasa | Plaza Mayor |
| 8 | Málaga | Antonio Banderas | En el rodaje de otra película |

**Liga Pokémon** dentro del **Palacio Real** (Madrid). Alto Mando: Andrés Iniesta, Rafa Nadal, Pau Gasol y Fernando Alonso. **Líder Supremo:** Pedro Sánchez, jefe del **Clan PSOE** (equipo villano que imita al Team Rocket).

**Otras ciudades:** Zaragoza, Murcia, Palma de Mallorca, Alicante, Vigo, Móstoles, Leganés y Getafe (pueblos al sur de Madrid), Pamplona, Puertollano, **San Miguel de Bernuy** (pueblo de Javier: firma de autor, y Javier sale como entrenador), Santander e Ibiza (se llega haciendo Surf desde Mallorca).

**Locales que hay en las ciudades:** Mercadona, Estanco y Basic Fit.

**Personajes** (Javier dirá dónde va cada uno; aquí van propuestas): Ibai Llanos; Lamine Yamal con su padre HustleHard304 y su hermano Keyne (combate triple); Rosalía; Enrique Iglesias; Julio Iglesias; Sergio Ramos; Pep Guardiola; Gerard Piqué; Aitana; Ester Expósito; Elxokas; Folagor03, Sekiam y PokeAlex (guiño a los fans de Pokémon); Amancio Ortega; Santiago Abascal; Ilia Topuria; Nico e Iñaki Williams; Pereira7; David Broncano; Óscar Puente; Mario Casas; Pablo Iglesias e Irene Montero (combate doble); Francisco Franco; Almeida; Chicote y Cristina Pedroche; Luis Rubiales y Jenni Hermoso (en una boda); Jorge Javier; Coto Matamoros; Belén Esteban; Melendi; el rey Felipe VI; el rey emérito Juan Carlos I; Ábalos y Koldo; Leire Díez; Sarah Santaolalla; Vito Quiles; Bertrand Ndongo; Vegeta y Willyrex; Ferran Torres; Juan Roig. Cuando entres en combate puede aparecer **una imagen real** de cada uno.

## Cómo se desarrolla una ciudad (para los agentes)

1. **Lee su ficha** en `ciudades/` y la parte de `arte_ciudades.md` que le toque.
2. **Reserva el mapa** en `docs/mapas/reservas.md` (un mapa = una persona a la vez).
3. **Pinta el exterior** con el pintor de mapas (`maps/_pintura/`, tiles de los packs; está prohibido el arte generado por código). Sigue la distribución de la ficha: las calles y los monumentos tienen que estar **donde están en la ciudad real** (orientación norte arriba, a escala de juego).
4. **Interiores** (Centro Pokémon, Mercadona, Estanco, Basic Fit, gimnasio, casas) con su tileset de interiores.
5. **Lógica**: warps, carteles, NPCs, entrenadores (`data/trainers/<ciudad>.json`), encuentros (`data/encounters/`), tienda (`data/shops.json`) y conexión con sus rutas (`region.md`).
6. **Comprueba que se llega a todo** con `godot --headless --path . -s res://maps/_tools/alcance.gd -- <id del mapa>` (puertas, carteles, personajes y bordes con conexión) y saca la **captura y comparativa** (`maps/_tools/captura_mapa.gd`, necesita ventana) en `docs/arte/comparativas/`, con su fila en `docs/arte/seguimiento.md`. Nada es definitivo hasta que lo aprueba Javier.
7. **Marca la ciudad como hecha** en la tabla de estado de abajo.

## Estado de cada ciudad

| Ciudad | Ficha | Mapa exterior | Interiores | Lógica | Aprobada |
|--------|-------|---------------|------------|--------|----------|
| San Miguel de Bernuy | ✅ | ✅ provisional ([captura](../arte/comparativas/san_miguel_mapa.png)) | — | carteles y vecinos | — |
| Madrid (y Palacio Real) | ✅ | Moncloa y Sol/Gran Vía ✅ provisionales ([Moncloa](../arte/comparativas/madrid_moncloa_mapa.png), [centro](../arte/comparativas/madrid_centro_mapa.png)); Palacio Real, Retiro y Chamberí pendientes | — | carteles, vecinos, reclutas del Clan, entrenadores de ciudad | — |
| Móstoles, Leganés y Getafe | ✅ | — | — | — | — |
| Zaragoza | ✅ | — | — | — | — |
| Barcelona | ✅ | — | — | — | — |
| Palma de Mallorca | ✅ | — | — | — | — |
| Ibiza | ✅ | — | — | — | — |
| Valencia | ✅ | — | — | — | — |
| Alicante | ✅ | — | — | — | — |
| Murcia | ✅ | — | — | — | — |
| Sevilla | ✅ | — | — | — | — |
| Las Palmas de Gran Canaria | ✅ | — | — | — | — |
| Vigo | ✅ | — | — | — | — |
| Santander | ✅ | — | — | — | — |
| Bilbao | ✅ | — | — | — | — |
| Pamplona | ✅ | — | — | — | — |
| Valladolid | ✅ | — | — | — | — |
| Puertollano | ✅ | — | — | — | — |
| Málaga | ✅ | — | — | — | — |
