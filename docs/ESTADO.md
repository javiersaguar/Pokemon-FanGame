# Estado del proyecto

**Hito actual:** `v0.1` (MVP, Fase 8 de la guía).

**Último aviso (2026-10-04, Javier):** 🚨 **Los gráficos actuales no valen: el mínimo es el nivel de Pokémon Añil.** Leed `docs/DIRECTRICES.md` §0, §7 y §8 **antes de seguir**:
- Capturas de referencia en `docs/arte/referencias/` (combate, pueblo, datos del Pokémon y ruta).
- La resolución pasa a **512×384** con el mundo a ×2 (Fase 3.2). **Se acabó el arte generado por código.**
- **Prueba de nivel gráfico** (§7, pasos 1–6): mapas de muestra (A1), combate y pantalla de datos de muestra (A3), sprites reales de Pokémon (A2) y comparación lado a lado para que Javier la apruebe. Hasta la aprobación, el MVP no añade más pantallas ni mapas visibles.
- **Shiny**: 1/4096 de base (≈ 0,024 %) y sprites con los colores shiny oficiales, nunca generados por código (§8 y Fase 6.7).

**Aviso anterior (2026-10-04, Javier):** 📌 **Nuevas directrices obligatorias en [`docs/DIRECTRICES.md`](DIRECTRICES.md).** Leedlas antes de vuestra siguiente tarea. Resumen:
1. **Arte de nivel profesional**, pieza a pieza → nueva **Fase A** de la guía.
2. **Varias partidas** (8+ ranuras) y **modo RandomLocke** con motor de aleatorización propio → **Fase 8.7** y nueva **Fase R**. ⚠️ La **regla R.2** (todo por ID de datos, nada escrito a mano en los eventos) afecta **ya** al MVP.
3. **Estadísticas**: verificar con **WikiDex** y aplicar los retoques de **Pokémon Añil** como overrides → **Fase 4.1**.
4. **Menú inicial muy currado** con **"Realizado por Javier Saguar"** → **Fase 15.2**.
5. **Autoría**: solo Javier Saguar y sin coautores. **Ejecutad una vez en vuestra copia:** `git config core.hooksPath .githooks` (ver `DIRECTRICES.md` §5).

Hay carpetas nuevas en el reparto (`DIRECTRICES.md` §6). Cada agente: confirmad en vuestra sección que lo habéis leído y añadid las tareas nuevas a vuestro plan.

**Aviso anterior (2026-10-04, Agente 1):** ✅ **Esqueleto listo, podéis empezar.** Antes de nada, leed `docs/contratos.md` y `README.md` (worktree, tests y `--import`).

## Cómo se usa

- **Al empezar y al terminar cada tarea**, actualiza tu sección: en qué estás, qué has terminado y qué te bloquea.
- **Lee las secciones de los demás** antes de empezar.
- **Peticiones**: si necesitas un cambio en algo que no es tuyo, no lo edites; añade una fila en "Peticiones" indicando para qué agente es. El destinatario la marca como `hecha` o `rechazada` (con el motivo).
- **Cambios de contrato** (`docs/contratos.md`): avísalos en la sección del final.
- **Dudas de diseño**: van a "Preguntas para Javier". No se inventan.

### Propiedad de carpetas

| Agente | Rol | Es dueño de |
|--------|-----|-------------|
| 1 | Mundo y arquitectura | `project.godot`, `src/autoload/` (salvo `data_db.gd`, `dialogue.gd` y `audio_manager.gd`), `src/overworld/` (salvo `src/overworld/trainers/`), `src/events/`, `src/main/`, `src/util/`, `maps/`, `assets/tilesets/`, `assets/sprites/characters/`, `data/world.json`, `docs/flags.md`, `docs/mapas/` |
| 2 | Datos y motor de combate | `tools/`, `data/generated/`, `data/species_overrides.json`, `data/regional_dex.json`, `src/autoload/data_db.gd`, `src/pokemon/`, `src/battle/engine/`, `src/battle/effects/`, `src/battle/ai/`, `tests/` |
| 3 | Presentación, UI y contenido Panchito | `src/ui/`, `src/battle/scene/`, `src/items/`, `src/overworld/trainers/`, `src/autoload/dialogue.gd`, `src/autoload/audio_manager.gd`, `data/trainer_classes.json`, `data/trainers/`, `data/items_panchito.json`, `data/shops.json`, `data/encounters/`, `assets/` (salvo `tilesets/` y `sprites/characters/`), `docs/entrenadores.md`, `docs/objetos_especiales.md` |

- `src/main/`, `src/util/`, `data/world.json`, `docs/flags.md` y `docs/mapas/` no estaban en el reparto: los ha tomado el Agente 1 (arquitectura). Si alguien no está de acuerdo, que lo diga en "Peticiones".
- **Compartidos**: `README.md` y `CREDITOS.md` (cada agente edita solo su sección), `docs/ESTADO.md` (cada uno su sección y sus filas), `.gitignore`, `.gitattributes`, `.gutconfig.json` y `addons/` (los cambios se piden al Agente 1).
- `res://default_bus_layout.tres` (buses de audio, ruta por defecto de Godot): Agente 3.

---

## Agente 1 — Mundo y arquitectura

**He leído `docs/DIRECTRICES.md`** (2026-10-04, secciones 0–8) y he reordenado mi plan.

**En qué estoy:** prueba de nivel gráfico (§7, paso 3):
1. ✅ Proyecto a **512×384** con el mundo a ×2 (cámara del jugador con `zoom = 2`, UI sin zoom, posiciones en píxeles enteros del arte, fondo negro).
2. Pokémon que te sigue (Fase 14.5: sigue el historial de casillas, se esconde en interiores y con Surf, brillo si es shiny), sombras de los personajes y hierba que se mueve al pisarla, listos para el arte real.
3. ⏳ `maps/test/muestra_ruta.tscn` y `maps/test/muestra_pueblo.tscn` con los packs reales: **bloqueado** hasta que estén los recursos de la lista del Agente 3 en `assets/_terceros/`.

Mientras tanto, lógica sin pantallas nuevas: API de cinemáticas y entidades de los eventos del MVP (Fase 13.1: disparadores, enfermera, Poké Balls del inicial con `DataDB.starter()`, tendero), con la regla R.2 en todos.

**Terminado:**
- Paso 0, el esqueleto: proyecto de Godot 4.7.2, estructura de carpetas, GUT 9.7.1, Input Map, escena `Main` (World/Battle/UI/Transition), autoloads, `GameState`, `SaveManager` (`save_version`, `.tmp` → `.bak` → renombrar, migraciones), `SceneManager` (mapas con fundido, combate, derrota → Centro Pokémon, pila de menús, flujo de partida), `Clock`, menú Debug (F9) con `Debug.register_command()`, `docs/contratos.md` §0–7, `docs/flags.md` y `docs/mapas/reservas.md`.
- **Fase 5** (`contratos.md` §5):
  - Jugador por casillas: toque corto = girar, pasos encadenados sin parones, correr, choque con la pared (`bump`) y `EventBus.player_stepped`.
  - Cámara con límites en los bordes del mapa (fija en los interiores que caben en pantalla). Warps al pisar, con fundido y el sonido del warp.
  - Base `MapEntity` → `Character` → `Player` / `NPC` (girarse al hablar, paseo aleatorio, `_on_interact()` para comportamientos propios). Objetos del suelo y ocultos (`ItemBall`, flag `item_taken:…`), carteles e interacción con `accept`, también por encima de un mostrador.
  - Encuentros salvajes con `DataDB.encounter_table()`, `land_rate`, momento del día y Repelente (`repel_steps`).
  - Sala de pruebas: NPCs (uno que pasea, otro detrás del mostrador y otro que lanza combates de prueba), objetos visibles y ocultos, cartel, warps entre los dos mapas y tabla de encuentros.
  - **Criterio de "hecho" comprobado** con una partida automatizada: moverse por los dos mapas conectados, hablar con NPCs, recoger objetos, encuentro en la hierba alta (abre la BattleScene del Agente 3), guardar y cargar.
- Directrices: 512×384 y zoom 2; `gui/theme/custom` (petición 8); `pokemon` y `shiny` en `data/world.json` (petición 10 y §8); regla R.2 en encuentros, objetos del suelo y NPC de pruebas; `core.hooksPath .githooks` activado (vale para todos los worktrees); `docs/.gdignore`, para que Godot no importe las capturas de `docs/`; fila de los personajes provisionales en `docs/arte/seguimiento.md`.
- **Varias partidas** (Fase 8.7 y R.9, `contratos.md` §2–§4): 8 ranuras (`data/world.json` → `saves.slots`), resumen completo (modo, jugador, tiempo, medallas, Pokédex, lugar, fecha e iconos del equipo; en RandomLocke, código, muertes y estado), miniatura del mundo sin la interfaz, última ranura usada para "Continuar", copiar y borrar ranuras. `GameState.mode`/`randomlocke`/`slot`/`rom_patch`; el parche de la ROM se guarda con la ranura (`slot_<n>.rom.json`) y se aplica en DataDB antes de cargar el mapa. `SceneManager.start_new_game(map, spawn, options)` para el flujo de nueva partida. Comando de Debug `slots`.
- Tests en `tests/mundo/`: GameState, SaveManager (también ranuras, copia y RandomLocke), mapas y encuentros.
- Integración: he unido `origin/main` (las directrices de Javier) con el `main` local de los agentes. **El `main` local no está subido a GitHub** (pregunta 10).

**Bloqueos:** mapas de muestra → recursos en `assets/_terceros/` (Javier). Fase 8 → `BattleSetup` (petición 1), pantallas del Agente 3 y preguntas 1 y 2.

---

## Agente 2 — Datos y motor de combate

**He leído `docs/DIRECTRICES.md`** (2026-10-04, secciones 0–8). Mi orden: (1) entregar el motor (hecho, abajo); (2) **script de descarga de sprites de Pokémon** (§7.2), ya; (3) shiny: tiradas desde `data/world.json` → `shiny`, test estadístico y validador de las 4 versiones (§8); (4) regla R.2 en `DataDB` (`starter()`, `gift()`, `static_encounter()`, `trade()` y marcadores) y `DataDB.apply_patch()`; (5) `src/randomizer/` para `v0.2`; (6) verificación de estadísticas con WikiDex (§3).

**En qué estoy:** siguiente paso, la Fase 9 (sistema de efectos con hooks, para que funcionen los movimientos que necesitan script: el validador lista 52 que se usan ya en el MVP), clima, campos y trampas, dobles, gimmicks e IA 2–4.

**Terminado:**
- Fase 4.2: `tools/import_data` (Node 18+, sin dependencias). Showdown `0.11.11` (tarball de npm verificado con sha512) + CSV de PokeAPI en el commit `a003ae375b69`, con nombres y descripciones en español (idioma 7). Genera `data/generated/`: 1379 especies y formas, 951 movimientos (con `needs_script`), 316 habilidades, 1376 objetos, tipos, learnsets, tablas de experiencia y naturalezas. Uso en `README.md` → Datos y `tools/README.md`.
- Fase 4.4: `data/species_overrides.json` con las evoluciones por intercambio sustituidas (decisión de Javier: nivel 36–38 las simples y subir de nivel con el objeto equipado las que lo piden) y Shedinja. `data/regional_dex.json` vacío hasta que Javier decida la Pokédex.
- Fase 4.5: `DataDB` real con clases tipadas (`SpeciesData`, `MoveData`, `ItemData`, `AbilityData`, `NatureData`), overrides, objetos Panchito, y acceso en bruto a entrenadores, clases, encuentros y tiendas. **Mantiene las firmas del stub.** Contrato en `contratos.md` §8.1–8.3. Tests en `tests/datos/`.
- Efectos de uso de los objetos estándar (Poción, Balls, Antídoto, Revivir, Ataque X, Repelente...) en `tools/import_data/extra/item_effects.json`, con el mismo formato `effect`/`effect_params` que `items_panchito.json`.
- Fase 6: `Pokemon` (creación reproducible, fichas de entrenador, estadísticas, EVs, experiencia, movimientos, guardado), `EvolutionRules`, y `Party`, `PCStorage` y `Pokedex`, que GameState ya crea y guarda solo (`contratos.md` §8.4). Tests en `tests/pokemon/`.
- **Fase 7: `BattleEngine` entregado** (`contratos.md` §8.5, ya no es previsto): turnos, orden, daño **exacto** (comparado con el simulador real de Showdown), estados, efectos por datos, captura, huida, objetos, experiencia con Repartir Experiencia, dinero, evoluciones pendientes e IA 0/1. `BattleSetup.wild()` y `BattleSetup.trainer()`. **Agente 3:** ya puedes escribir el adaptador del `BattleDriver`; los textos de presentación llevan `tag` en `data` para que la escena los sustituya si quiere. Tests en `tests/combate/` (daño, flujo, captura, huida, IA, aprender movimientos, combate completo con semilla).
- Fase 4.6: validador (`tools/validate/`, también como test). Hoy: 0 errores; avisos de iconos y de los movimientos que necesitan script.
- Comandos de Debug: `givepkmn`, `heal`, `party`, `setlevel`, `wildbattle`, `trainerbattle` y `dex`.
- **DIRECTRICES §7.2: `tools/sprites/download_sprites.mjs`** (instrucciones en `tools/README.md`). Set único estilo 5.ª generación de Pokémon Showdown (frente, espalda, normal y shiny **oficiales**) e iconos de su hoja (40×30), con pausas y caché. Ya descargados los de las **32 especies del MVP** (encuentros, entrenadores y sus familias) en `assets/sprites/pokemon/<front|back|front_shiny|back_shiny|icons>/<id>.png`, con sus `.import`. Créditos en `CREDITOS.md` → Gráficos. **Agente 3:** apúntalos en `docs/arte/seguimiento.md` y `docs/arte/licencias.md`; los iconos shiny y los Pokémon que te siguen no están en Showdown (hacen falta packs): cuando la biblia fije sus rutas, el validador también los comprobará.
- **Regla R.2 y parche R.1 en `DataDB`** (`contratos.md` §8.1–8.2): `starter()`, `gift()`, `static_encounter()`, `trade()`, `placed_item()` (petición 12), `item_placements()`, `resolve_markers()` y `apply_patch()` / `clear_patch()`. **Agente 3:** `Dialogue` puede resolver los marcadores llamando a `DataDB.resolve_markers(text)`; el formato que espero de `starters.json`, `gifts.json`, `statics.json` y `trades.json` está en §8.1 (si prefieres otro, dímelo). **Agente 1:** el evento del inicial puede usar `Pokemon.from_spec(DataDB.starter_spec(&"starter_1"))`.
- **Motor de RandomLocke (Fase R.1–R.6, mi parte de R.7)** en `src/randomizer/` (`contratos.md` §8.6): `Randomizer.generate(seed, settings)` puro y determinista (se puede llamar desde un hilo), `RomPatch` (`apply()`, `to_json()`, `spoiler_text()`), `RandomizerSettings` con presets (`clasico`, `solo_aleatorio`, `caos`), validación R.4 con subsemillas, códigos `PANCHITO-XXXX-XXXX-XX` y tests (determinismo, parche dorado, **1000 semillas sin fallos**, reglas, tiempo: ~0,2 s el clásico y ~0,9 s el caos). Reglas Locke en el combate: `BattleSetup.locke_rules`, evento `pokemon_died` y `result.deaths`. Configuración en `data/randomizer.json` (archivo nuevo, lo tomo yo como Agente 2). **Agente 1:** guarda `rom.to_json()` en `slot_<n>.rom.json` y aplica `RomPatch.from_dict(...).apply()` antes de cargar el mapa; el contador de muertes puede leer `result.deaths`. **Agente 3:** la pantalla de ajustes puede leer los presets de `data/randomizer.json` y los campos de `RandomizerSettings`; `SeedCode.decode()` da el error en español.
- **DIRECTRICES §3: verificación con WikiDex** (`tools/wikidex/verify_stats.mjs`, uso en `tools/README.md`): API de MediaWiki por lotes, con pausas y caché. Comprobadas **197 especies** (las del juego, sus familias y una muestra de toda la Pokédex nacional): estadísticas base iguales en todas; 2 EVs de PokeAPI corregidos con `"fuente": "WikiDex"` en `species_overrides.json` (Slowking y Nymble). El validador lee el resultado (`data/generated/wikidex_check.json`) y avisa si hay diferencias o especies del juego sin comprobar. Cuando Javier decida la Pokédex regional, se vuelve a pasar.
- **DIRECTRICES §8 (mi parte):** shiny por tiradas independientes de 1/`odds` (`data/world.json` → `shiny`, petición 13), Amuleto Iris (3), Masuda (6) y ambos (8); los entrenadores no tiran salvo `"shiny": true`; `forceshiny` y `givepkmn ... shiny` en el Debug; test estadístico con 1.000.000 de tiradas sembradas y test de que los shiny son los sprites oficiales.

**Bloqueos:** ninguno.

**Decisiones de Javier ya tomadas (para el GDD):** evoluciones por intercambio → nivel fijo o subir de nivel con el objeto equipado; experiencia → fórmula escalada de la 7.ª generación en adelante (sin bonus por combate de entrenador).

---

## Agente 3 — Presentación, UI y contenido Panchito

**He leído `docs/DIRECTRICES.md`** (2026-10-04, secciones 0–8) y he reordenado mi plan:

**En qué estoy:** prueba de nivel gráfico (§7) y Fase A, en `feat/agente3-arte`:
1. `docs/arte/BIBLIA.md`, `docs/arte/seguimiento.md` (ya con los placeholders que hay a la vista) y `docs/arte/licencias.md`.
2. Lista de recursos para descargar (tilesets, personajes, Pokémon que te siguen, fondos de combate y fuente) y propuesta del set de sprites de Pokémon, en "Preguntas para Javier".
3. Validador de arte (`tools/arte/`) y galería.
4. Pantalla de combate y pantalla de datos del Pokémon de muestra a 512×384, y comparativas en `docs/arte/comparativas/`.

Hecho de la Fase A: `docs/arte/BIBLIA.md` (propuesta), `docs/arte/seguimiento.md`, `docs/arte/licencias.md`, `docs/arte/recursos.md` (lista para descargar, preguntas 8 y 9), paleta maestra propuesta (`assets/arte/paleta.json` → `.gpl` y `.png`) y validador de arte (`tools/arte/validar.gd`, uso en `README.md`).

**Después** (tras la aprobación de Javier): menú inicial de la Fase 15.2 ("Realizado por Javier Saguar"), pantallas del MVP, TrainerNPC, marcadores R.2 en `Dialogue`, `starters.json`/`gifts.json`/`statics.json`/`trades.json` y las pantallas del RandomLocke (R.8).

**Terminado:**
- Borrador de `docs/GDD.md` (Fase 2): estructura completa, con las decisiones de diseño marcadas **PENDIENTE JAVIER** (resumen de las que bloquean el MVP en su §0).
- `docs/contratos.md` §9: Dialogue, AudioManager, escenas para SceneManager, interfaz común, `Bag`, formato de entrenadores, encuentros y tiendas.
- Datos: las 20 clases Panchito de la tabla 10.2 + `rival` en `data/trainer_classes.json`; `rival_lab_1/2/3` (`data/trainers/pueblo_inicial.json`) y el Vendedor de Chupachups Manolo (`data/trainers/ruta_1.json`); `docs/entrenadores.md` (registro, clases, fichas y arte pendiente).
- Encuentros `data/encounters/ruta_1.json` (provisional) y `data/encounters/test_outdoor.json`. Catálogo provisional `data/shops.json` (`tienda_ciudad2`).
- Peticiones 4, 5 y 6.
- **Dialogue** (Fase 5.6, `contratos.md` §9.1): letra a letra (`Dialogue.text_speed`), páginas automáticas de 2 líneas y `\n\n` para forzar página, flecha de continuar, nombre del hablante, colores BBCode, variables, `ask()` / `ask_yes_no()` con cursor y `cancel`, sin parpadeo entre líneas seguidas. Comando de Debug `dialogue <texto>`.
- **Theme global** `src/ui/theme/main_theme.tres` y fuente **Pixel Operator** (CC0) sin antialiasing, con ñ, tildes y ¿¡. Widgets `CursorArrow`, `DialogueBox` y `ChoiceBox` reutilizables (§9.4).
- **AudioManager** (Fase 16.1, `contratos.md` §9.2): buses en `res://default_bus_layout.tres` (`Master`, `BGM`, `SE`, `ME`, `Cries`, `Ambient`), BGM con fundido cruzado que no se reinicia si es la misma, `save_bgm()`/`restore_bgm()` por donde iba, ME que pausan y reanudan la BGM (con `await`), SE con 6 voces, gritos, sonido ambiente y volumen por bus. Sin archivos de audio todavía: avisa una sola vez y el comando de Debug `audio` lista lo que falta. Más comandos: `bgm`, `se`, `me` y `volume`.
- **BattleScene** (Fase 7.10) en `res://src/battle/scene/battle_scene.tscn` con `run(setup) -> StringName`: cortinilla (distinta para salvaje y entrenador), entrada de entrenadores, fondo y bases por entorno, cajas de datos con PS animados (verde → amarilla → roja), PS en número y barra de experiencia, menús Luchar/Mochila/Pokémon/Huir y de movimientos (PP y tipo), animaciones genéricas por categoría y color de tipo, parpadeo al recibir daño, debilitado, secuencia de captura, despedida del entrenador (`lose_text`/`win_text`) y BGM guardada y restaurada. Habla con un `BattleDriver` que sigue el flujo y los `BattleEvent` de §8.5 (`contratos.md` §9.3); de momento con **FakeBattle**, un combate de mentira: **el comando `battle` del Debug ya abre esta escena** en vez del sustituto. Sprites provisionales generados si faltan. En cuanto el `BattleEngine` esté en `main`, escribo el adaptador.
- `TrainerData` (`src/overworld/trainers/`): entrenador + clase combinados, leyendo de `DataDB`.
- **Adaptador del motor real** (`EngineDriver`): la BattleScene ya juega combates de verdad con `BattleSetup.wild()` / `BattleSetup.trainer()` (los comandos `wildbattle` y `trainerbattle` del Agente 2), con captura al equipo o al PC, objetos sobre un Pokémon, aprender movimientos y Forcejeo. El combate de prueba de `battle` (un `Dictionary`) sigue con FakeBattle.
- **Mochila** `Bag` (`src/items/bag.gd`, §9.5): GameState ya la crea y la guarda. Comandos de Debug `giveitem <id> [n]` y `bag`.
- Tests en `tests/ui/`: Dialogue (10), AudioManager (6), Bag (6) y BattleScene (8, tres con el motor real).
**Bloqueos:** para la muestra de combate necesito los recursos de la lista (fondos y bases) y los sprites reales de Pokémon del Agente 2. Mientras, preparo la maqueta a 512×384.

**Notas:**
- Equipos y encuentros usan especies **provisionales** (iniciales de Kanto para el rival, Swirlix y Milcery para Manolo, la tabla de ejemplo de la guía en la Ruta 1) hasta que Javier decida la Pokédex (pregunta 5).
- No subo audio (`.ogg`/`.wav`) hasta que esté Git LFS (pregunta 4). AudioManager funciona sin archivos: avisa una vez y no suena.

---

## Peticiones

| # | De → Para | Petición | Estado |
|---|-----------|----------|--------|
| 1 | A1 → A2 | `BattleSetup` con `can_lose: bool` y una forma de crear un combate **salvaje** (especie + nivel, o un `Pokemon`) y uno de **entrenador** (`trainer_id`). Propuesta: `BattleSetup.wild(species_id, level)` y `BattleSetup.trainer(trainer_id)`. Lo usan los encuentros (Fase 5) y los eventos (Fase 8). | hecha: `BattleSetup.wild(pokemon_or_species, level := 5, options := {})` y `BattleSetup.trainer(trainer_id, options := {})`, con `can_lose` y el equipo de `GameState.party` (`contratos.md` §8.5) |
| 2 | A1 → A2 | Clases `Party`, `PCStorage` y `Pokedex` con los requisitos de módulo de GameState (`contratos.md` §2). En `Party`, además: `heal_all()`, `is_all_fainted()` y el nivel del primer Pokémon no debilitado (para el Repelente). | hecha: `Party` con `heal_all()`, `is_all_fainted()` y `first_able_level()`; `PCStorage` y `Pokedex` (`contratos.md` §8.4) |
| 3 | A1 → A2 | `tests/` es tuyo: ¿me cedes `tests/mundo/` para los tests de GameState, SaveManager y SceneManager? (Y quizá `tests/ui/` al Agente 3.) | hecha: `tests/mundo/` es del Agente 1 |
| 4 | A1 → A3 | BattleScene en `res://src/battle/scene/battle_scene.tscn` con `run(setup) -> StringName`; título en `res://src/ui/title/title_screen.tscn`; menú de pausa en `res://src/ui/pause_menu/pause_menu.tscn` (`contratos.md` §4). Si preferís otras rutas, decídmelo. | hecha: rutas aceptadas (`contratos.md` §9.3) |
| 5 | A1 → A3 | Formato de `data/encounters/<id>.json` (lo leerá el disparador de encuentros de la Fase 5). Propuesta: el de la guía (5.7), con `land.day`, `land.night`, `water`... Y una tabla de prueba `data/encounters/test_outdoor.json` para `test/test_outdoor`. | hecha: formato de la guía + `land_rate` y tablas por momento del día con los ids de `Clock.period()` (`contratos.md` §9.7). `encounter_table = &"test_outdoor"` ya está puesto en el mapa |
| 6 | A1 → A3 | Si queréis un Theme o una fuente por defecto global, pedidme `gui/theme/custom` en `project.godot`. Los stubs de Dialogue y Debug usan tamaño de fuente 8. | hecha: la pido en la petición 8 cuando entregue el Theme |
| 7 | A3 → A2 | Para la BattleScene (`contratos.md` §8): (a) cómo se crea el motor a partir de un `BattleSetup` y qué devuelve al empezar; (b) cómo se le envía la acción del jugador y cómo se piden los reemplazos tras un debilitado; (c) la lista de tipos de `BattleEvent` con sus campos; (d) datos de presentación en `BattleSetup`: fondo, BGM, y clase, nombre y sprite de cada entrenador (yo los saco de `data/trainer_classes.json` si me pasas el `trainer_id`). **Propuesta** de lo que necesita la escena (eventos, resumen de Pokémon y reparto de textos): `contratos.md` §9.3 → `BattleDriver`. No hace falta que sea igual: yo escribo el adaptador; pero cuanto más se parezca, menos traducción. | hecha: motor entregado (`contratos.md` §8.5). Diferencias con tu propuesta del `BattleDriver`: la petición es `engine.request` (`BattleRequest`) y las acciones son `BattleAction`; los textos de presentación (aparición, desafío, "¡Adelante, X!", retirada y derrota) sí llegan como `message` pero con `tag`, para que los filtres; los Pokémon para los menús salen de `engine.active()` y `engine.party()` |
| 8 | A3 → A1 | `gui/theme/custom = "res://src/ui/theme/main_theme.tres"` en `project.godot` (ya está en `main`). Ojo: el Theme usa Pixel Operator a 16 px; el `Theme.new()` con tamaño 8 del Debug y del sustituto de combate la pondría a 8 px y se vería mal. Para texto pequeño, la variación `SmallLabel` (Pixel Operator 8). | hecha: `gui/theme/custom` puesto; el Debug y el combate provisional usan el Theme sin tocarlo y el globo de `show_emote()` usa `SmallLabel` |
| 9 | A3 → A2 | Datos de entrenadores (`contratos.md` §9.6): ¿los carga `DataDB` o los leo yo con `TrainerData` (`src/overworld/trainers/`)? Por mí, cualquiera de las dos; `BattleSetup.trainer(trainer_id)` (petición 1) necesitará el equipo. Y, como en la petición 3, ¿me cedes `tests/ui/` para mis tests? | hecha: los carga `DataDB` (`trainer()`, `trainer_class()`, `encounter_table()`, `shop()`, en bruto; `contratos.md` §8.2). Si quieres `TrainerData`, que lea de `DataDB`. `tests/ui/` es tuyo |
| 10 | A2 → A1 | Sección `"pokemon"` en `data/world.json` con las reglas configurables que lee `DataDB.rule()` (`contratos.md` §8.2): `{"shiny_odds": 4096, "wild_hidden_ability_chance": 0.0, "pc_boxes": 32, "pc_box_size": 30, "exp_share": true}`. Mientras no esté, se usan esos valores por defecto. | hecha, salvo `shiny_odds`: por la directriz §8 la probabilidad shiny va en `data/world.json` → `shiny` (petición 13) |
| 11 | A2 → A3 | Los mensajes de combate escriben el dinero como `"%d ₽"` (`BattleText.CURRENCY`, previsto). ¿La fuente Pixel Operator tiene `₽`? Si no, dime qué símbolo usar (o si lo dibujas como icono). | pendiente |
| 12 | A1 → A2 | Regla R.2 para los objetos del suelo: `DataDB.placed_item(placement_id: StringName, default_item: StringName) -> StringName`, que devuelva el objeto del parche de RandomLocke si lo hay y, si no, `default_item`. `placement_id` = `<map_id>/<nombre del nodo>` (`ItemBall.placement_id()`); `ItemBall` ya lo llama si existe. Para que el randomizer conozca todas las colocaciones, ¿te vale que yo genere `data/item_placements.json` (`{placement_id: item_id}`) con un script que recorra `maps/`? | hecha: `DataDB.placed_item(placement_id, default_item)` (devuelve el del parche si lo hay). Sí: genera tú `data/item_placements.json`; el randomizer lo leerá con `DataDB.item_placements()` |
| 13 | A1 → A2 | Probabilidad shiny: la directriz §8 la pone en `data/world.json` → `shiny`: `{"odds": 4096, "rolls": {"base": 1, "shiny_charm": 3, "masuda": 6, "masuda_shiny_charm": 8}}` (una tirada = 1/`odds`). La he puesto ahí y no en `pokemon.shiny_odds`: ¿puedes leerla de `shiny`? | hecha: `DataDB.shiny_odds()` y `DataDB.shiny_rolls(&"base" / &"shiny_charm" / &"masuda" / &"masuda_shiny_charm")` leen `data/world.json` → `shiny` |
| 14 | A1 → A3 | Aviso: con la resolución a 512×384 (ya en `main`), el cuadro de diálogo sigue colocado como en 320×180 y sale a media pantalla. | informativo |

---

## Preguntas para Javier

| # | Quién pregunta | Pregunta | Respuesta |
|---|----------------|----------|-----------|
| 1 | A1 | **Para el MVP (Fase 8):** ¿cuáles son los 3 iniciales? ¿Nombres del pueblo inicial, de la ciudad 2, del profesor y del rival por defecto? (La Fase 2 / GDD está sin hacer.) Mientras tanto uso nombres provisionales marcados "POR DEFINIR". | |
| 2 | A1 | **Reloj** (Fase 14.1): ¿hora real del sistema o reloj interno acelerado? Ahora mismo, real (`data/world.json` → `clock.mode`). | |
| 3 | A1 | **Dinero inicial**: 3000 provisional (`data/world.json` → `new_game.money`). ¿Vale? | |
| 4 | A1 | **Git LFS** no está instalado en el WSL: hace falta `sudo apt install git-lfs && git lfs install` antes de subir audio (`.ogg`, `.wav`...). | |
| 5 | A3 | **Decisiones del GDD** (`docs/GDD.md` §0): las que bloquean el MVP, además de las de la pregunta 1, son: ¿quién o qué es Panchito?, nombre de la región, tono (¿parodia total o aventura seria con chistes?), especies salvajes de la Ruta 1 y aspecto/nombres por defecto del chico y la chica. El resto del GDD puede esperar. | |
| 6 | A3 | **Entrenadores del MVP** (`docs/entrenadores.md`): ¿te valen las 20 clases de la tabla 10.2 tal cual? ¿Y los textos provisionales del Vendedor de Chupachups Manolo y del rival? | |
| 7 | A2 | **Habilidad oculta en Pokémon salvajes** (Fase 6.1, "con baja probabilidad"): ¿qué probabilidad? En los juegos actuales es 0 salvo casos especiales. Ahora: 0 (`wild_hidden_ability_chance`). | |
| 8 | A3 | **Prueba de nivel gráfico, paso 1: recursos para descargar** (`docs/arte/recursos.md`, con enlace, autores y licencia de cada uno): sprites de Pokémon, tilesets, personajes del mapa, Pokémon que te siguen, fondos y bases de combate y fuentes. (a) ¿Los descargas en `assets/_terceros/`? Para mi muestra de combate necesito, por orden: el **set de sprites de Pokémon** (propongo la opción A, *Animated Pokemon System*, el mismo linaje que Añil; la B es la de Showdown del Agente 2), los **fondos y bases** de *Elite Battle System* y, si quieres comparar, otra **fuente**. (b) Varios autores **prohíben redistribuir** sus packs y el repo es público: ¿ponemos `assets/_terceros/` en `.gitignore` y en el repo solo lo que el juego usa? (`.gitignore` lo cambiaría el Agente 1) | |
| 9 | A3 | **Biblia de arte y paleta** (`docs/arte/BIBLIA.md`, muestrario en `assets/arte/paleta.png`): ¿la apruebas o cambias algo? Decisiones abiertas en su §12: paleta, fuente, set de sprites, tono visual de lo nuestro (UI, clases Panchito, logo) y lienzo de 80×80 para los entrenadores en combate | |
| 10 | A1 | **GitHub**: el `main` local tiene el trabajo de los tres agentes y tus directrices, pero no está subido (no subimos sin permiso). ¿Lo subo (`git push origin main`) cada vez que se integre algo? Si sigues subiendo cosas a GitHub desde otra copia, las integro igual que esta vez. | |

---

## Avisos de cambios de contrato

| Fecha | Agente | Cambio |
|-------|--------|--------|
| 2026-10-04 | A1 | §2–§4: varias partidas. `SaveManager.save_game(slot := 0)` (0 = la ranura en curso; antes el valor por defecto era 1) y `load_game(slot)` (sin valor por defecto); nuevas `slot_count()`, `current_slot()`, `first_empty_slot()`, `last_used_slot()`, `list_slots()`, `thumbnail()`, `copy_slot()` y `apply_rom_patch()`; el resumen trae más campos. `GameState.mode`, `randomlocke`, `slot`, `rom_patch`, `is_randomlocke()` y `new_game(options)`. `SceneManager.start_new_game(map, spawn, options)`, `world_snapshot` y `capture_screen()`. Se quita `SaveManager.SLOT_COUNT` (ahora `slot_count()`). |
| 2026-10-04 | A1 | §0: resolución **512×384** con el mundo a ×2 (zoom de la cámara) y la UI sin zoom. §5 entregado (Fase 5): `MapEntity`, `Character`, `Player`, `NPC`, `ItemBall`, `MapSign`, `Warp`, `WildEncounters` y los métodos nuevos de `MapRoot`. `EventBus.repel_wore_off` nueva. `GameState.dir_name()`/`dir_from_name()` dejan de ser estáticas (también están en `Grid`). `ItemBall` resuelve el objeto con `DataDB.placed_item()` si existe (R.2). |
| 2026-10-04 | A3 | `contratos.md` §9 rellena. Dialogue y AudioManager mantienen las firmas del stub y **añaden**: `vars`, `cancel_choice`, `ask_yes_no()`, `format_text()`, `text_speed` y `NO_CANCEL` (Dialogue); `save_bgm()`, `restore_bgm()`, `play_ambient()`, `stop_ambient()`, `set_volume()` y `get_volume()` (AudioManager). Formatos de entrenadores, encuentros y tiendas. |
| 2026-10-04 | A3 | `EngineDriver` (§9.3): `run(setup)` con un `BattleSetup` usa el motor real. La escena salta los `message` con `tag` de presentación. `Bag` entregada (§9.5) y comandos `giveitem` y `bag`. |
| 2026-10-04 | A3 | BattleScene entregada (§9.3, `run(setup) -> StringName`), con `BattleDriver` y FakeBattle. `TrainerData.get_class()` pasa a llamarse `get_trainer_class()` (choca con `Object.get_class()`). Nuevo widget `GridMenu` (§9.4). |
| 2026-10-04 | A3 | AudioManager entregado (§9.2), sin cambios de firma. |
| 2026-10-04 | A3 | Dialogue entregado (§9.1). `{pokemon}` ya no tiene valor por defecto: se pasa en `vars`. Theme, fuentes, variaciones y widgets en §9.4. |
| 2026-10-04 | A2 | `contratos.md` §8 rellena. `DataDB` entregado (mantiene las firmas del stub y añade el resto de la API de §8.2). `Pokemon`, módulos de GameState y combate, **previstos** (§8.4 y §8.5). |
| 2026-10-04 | A2 | §8.4 entregado: `Pokemon`, `MoveSlot`, `EvolutionRules`, `Party`, `PCStorage` y `Pokedex`. Añadidos a lo previsto: `Party.move()`, `species_ids()`, `types()`, `PCStorage.find_uid()`, `Pokedex.caught_species()`, `EvolutionRules.level_up_evolution()`, `evolve()` y `shed_species()`. |
| 2026-10-04 | A2 | §8.5 entregado: `BattleEngine`, `BattleSetup`, `BattleRequest`, `BattleAction`, `BattleEvent`, `BattleResult` y `BattleAI`. Añadidos a lo previsto: `message.tag`, evento `turn`, `catch.blocked`, `use_item(..., move_index)`, `BattleSetup.trainer_info()`, `pending_evolutions[i].evolution`, validador y comandos de Debug. |
| 2026-10-04 | A2 | Shiny (Fase 6.7): `Pokemon.create(..., shiny_rolls := 1)`, `Pokemon.roll_shiny()`, `shiny_chance()`, `debug_force_shiny`, `DataDB.shiny_odds()` y `shiny_rolls()`; `from_spec()` ya no tira shiny. Se quita la regla `shiny_odds` de `"pokemon"` (pasa a `"shiny"`; se sigue leyendo si alguien la pone). |
| 2026-10-04 | A2 | §8.1–8.2: regla R.2 (`starter()`, `gift()`, `static_encounter()`, `trade()`, `placed_item()`, `item_placements()`, `resolve_markers()`) y parche de RandomLocke (`apply_patch()`, `clear_patch()`, `has_patch()`, `current_patch()`, señal `patch_changed`). |
| 2026-10-04 | A2 | §8.6 nuevo: `Randomizer`, `RandomizerSettings`, `RomPatch`, `RomValidator`, `SeedCode`; reglas Locke en el combate (`BattleSetup.locke_rules`, evento `pokemon_died`, `result.deaths`). `DataDB`: `encounter_ids()`, `shop_ids()`, `gift_ids()`, `static_ids()`, `trade_ids()`. |
