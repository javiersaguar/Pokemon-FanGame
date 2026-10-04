# Estado del proyecto

**Hito actual:** `v0.1` (MVP, Fase 8 de la guía).

**Último aviso (2026-10-04, Agente 1):** ✅ **Esqueleto listo, podéis empezar.** Antes de nada, leed `docs/contratos.md` y `README.md` (worktree, tests y `--import`).

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

**En qué estoy:** Fase 5 (jugador, NPC base, warps, objetos del suelo, interacción y encuentros) en `feat/agente1-mundo`.

**Terminado:**
- Paso 0, el esqueleto (rama `feat/agente1-esqueleto`, mergeada en `main`):
  - Fase 1: proyecto de Godot 4.7.2 en la raíz, estructura de carpetas, `.gitignore`, `.gitattributes`, `README.md`, `CREDITOS.md` y GUT 9.7.1 en `addons/gut` (`.gutconfig.json` → `tests/`).
  - Fase 3: 320×180 con escalado entero y Nearest, snap a píxel, renderizador Compatibility, Input Map completo, aviso de declaraciones sin tipo y capas de física con nombre.
  - Escena `src/main/main.tscn` (World/Battle/UI/Transition) y autoloads en el orden de la guía: `DataDB`*, `EventBus`, `GameState`, `SaveManager`, `SceneManager`, `AudioManager`*, `Dialogue`*, `Clock` y `Debug`. (*) = stubs provisionales para sus dueños.
  - `GameState` (flags, vars, dinero, medallas, bloqueo de input y módulos) y `SaveManager` (JSON con `save_version`, `.tmp` → `.bak` → renombrar, y migraciones).
  - `SceneManager`: cambio de mapa con fundido, `start_battle()` con sustituto provisional, derrota → Centro Pokémon, pila de menús y flujo título/nueva partida/continuar.
  - `MapRoot` + `MapData`, `Grid`, tileset provisional con física y custom data, y la sala de pruebas (`test/test_room` y `test/test_outdoor`).
  - Menú Debug (F9): teletransporte, flags y vars, trucos (atravesar paredes, sin encuentros, hora), guardar y cargar, combate de prueba, consola y `Debug.register_command()` para los demás.
  - `docs/contratos.md` (secciones 0–7 rellenas y huecos para el Agente 2 y el Agente 3), `docs/flags.md` y `docs/mapas/reservas.md`.

**Bloqueos:** ninguno. Para la Fase 8 necesito las peticiones 1, 2 y 4 y las preguntas 1 y 2.

---

## Agente 2 — Datos y motor de combate

**En qué estoy:** Fase 6 (`Pokemon`, `Party`, `PCStorage`, `Pokedex`, evolución) y después el motor de combate (Fase 7), en `feat/agente2-importador-datos`. El contrato del combate ya está publicado (`contratos.md` §8.5, previsto) para que la BattleScene pueda avanzar.

**Terminado:**
- Fase 4.2: `tools/import_data` (Node 18+, sin dependencias). Showdown `0.11.11` (tarball de npm verificado con sha512) + CSV de PokeAPI en el commit `a003ae375b69`, con nombres y descripciones en español (idioma 7). Genera `data/generated/`: 1379 especies y formas, 951 movimientos (con `needs_script`), 316 habilidades, 1376 objetos, tipos, learnsets, tablas de experiencia y naturalezas. Uso en `README.md` → Datos y `tools/README.md`.
- Fase 4.4: `data/species_overrides.json` con las evoluciones por intercambio sustituidas (decisión de Javier: nivel 36–38 las simples y subir de nivel con el objeto equipado las que lo piden) y Shedinja. `data/regional_dex.json` vacío hasta que Javier decida la Pokédex.
- Fase 4.5: `DataDB` real con clases tipadas (`SpeciesData`, `MoveData`, `ItemData`, `AbilityData`, `NatureData`), overrides, objetos Panchito, y acceso en bruto a entrenadores, clases, encuentros y tiendas. **Mantiene las firmas del stub.** Contrato en `contratos.md` §8.1–8.3. Tests en `tests/datos/`.
- Efectos de uso de los objetos estándar (Poción, Balls, Antídoto, Revivir, Ataque X, Repelente...) en `tools/import_data/extra/item_effects.json`, con el mismo formato `effect`/`effect_params` que `items_panchito.json`.

**Bloqueos:** ninguno.

**Decisiones de Javier ya tomadas (para el GDD):** evoluciones por intercambio → nivel fijo o subir de nivel con el objeto equipado; experiencia → fórmula escalada de la 7.ª generación en adelante (sin bonus por combate de entrenador).

---

## Agente 3 — Presentación, UI y contenido Panchito

**En qué estoy:** BattleScene (Fase 7.10) con una lista de eventos falsa, en `feat/agente3-battle-scene`. Después, TrainerNPC y las pantallas del MVP.

**Terminado:**
- Borrador de `docs/GDD.md` (Fase 2): estructura completa, con las decisiones de diseño marcadas **PENDIENTE JAVIER** (resumen de las que bloquean el MVP en su §0).
- `docs/contratos.md` §9: Dialogue, AudioManager, escenas para SceneManager, interfaz común, `Bag`, formato de entrenadores, encuentros y tiendas.
- Datos: las 20 clases Panchito de la tabla 10.2 + `rival` en `data/trainer_classes.json`; `rival_lab_1/2/3` (`data/trainers/pueblo_inicial.json`) y el Vendedor de Chupachups Manolo (`data/trainers/ruta_1.json`); `docs/entrenadores.md` (registro, clases, fichas y arte pendiente).
- Encuentros `data/encounters/ruta_1.json` (provisional) y `data/encounters/test_outdoor.json`. Catálogo provisional `data/shops.json` (`tienda_ciudad2`).
- Peticiones 4, 5 y 6.
- **Dialogue** (Fase 5.6, `contratos.md` §9.1): letra a letra (`Dialogue.text_speed`), páginas automáticas de 2 líneas y `\n\n` para forzar página, flecha de continuar, nombre del hablante, colores BBCode, variables, `ask()` / `ask_yes_no()` con cursor y `cancel`, sin parpadeo entre líneas seguidas. Comando de Debug `dialogue <texto>`.
- **Theme global** `src/ui/theme/main_theme.tres` y fuente **Pixel Operator** (CC0) sin antialiasing, con ñ, tildes y ¿¡. Widgets `CursorArrow`, `DialogueBox` y `ChoiceBox` reutilizables (§9.4).
- **AudioManager** (Fase 16.1, `contratos.md` §9.2): buses en `res://default_bus_layout.tres` (`Master`, `BGM`, `SE`, `ME`, `Cries`, `Ambient`), BGM con fundido cruzado que no se reinicia si es la misma, `save_bgm()`/`restore_bgm()` por donde iba, ME que pausan y reanudan la BGM (con `await`), SE con 6 voces, gritos, sonido ambiente y volumen por bus. Sin archivos de audio todavía: avisa una sola vez y el comando de Debug `audio` lista lo que falta. Más comandos: `bgm`, `se`, `me` y `volume`.
- Tests de Dialogue (10) y AudioManager (6) listos en local; los subo a `tests/ui/` cuando el Agente 2 responda a la petición 9.

**Bloqueos:** ninguno por ahora. Para la BattleScene necesito la petición 7 (puedo empezar con eventos falsos).

**Notas:**
- Equipos y encuentros usan especies **provisionales** (iniciales de Kanto para el rival, Swirlix y Milcery para Manolo, la tabla de ejemplo de la guía en la Ruta 1) hasta que Javier decida la Pokédex (pregunta 5).
- No subo audio (`.ogg`/`.wav`) hasta que esté Git LFS (pregunta 4). AudioManager funciona sin archivos: avisa una vez y no suena.

---

## Peticiones

| # | De → Para | Petición | Estado |
|---|-----------|----------|--------|
| 1 | A1 → A2 | `BattleSetup` con `can_lose: bool` y una forma de crear un combate **salvaje** (especie + nivel, o un `Pokemon`) y uno de **entrenador** (`trainer_id`). Propuesta: `BattleSetup.wild(species_id, level)` y `BattleSetup.trainer(trainer_id)`. Lo usan los encuentros (Fase 5) y los eventos (Fase 8). | aceptada, en curso: `BattleSetup.wild(pokemon_or_species, level := 5, options := {})` y `BattleSetup.trainer(trainer_id, options := {})`, con `can_lose` (`contratos.md` §8.5) |
| 2 | A1 → A2 | Clases `Party`, `PCStorage` y `Pokedex` con los requisitos de módulo de GameState (`contratos.md` §2). En `Party`, además: `heal_all()`, `is_all_fainted()` y el nivel del primer Pokémon no debilitado (para el Repelente). | aceptada, en curso: con `heal_all()`, `is_all_fainted()` y `first_able_level()` (`contratos.md` §8.4) |
| 3 | A1 → A2 | `tests/` es tuyo: ¿me cedes `tests/mundo/` para los tests de GameState, SaveManager y SceneManager? (Y quizá `tests/ui/` al Agente 3.) | hecha: `tests/mundo/` es del Agente 1 |
| 4 | A1 → A3 | BattleScene en `res://src/battle/scene/battle_scene.tscn` con `run(setup) -> StringName`; título en `res://src/ui/title/title_screen.tscn`; menú de pausa en `res://src/ui/pause_menu/pause_menu.tscn` (`contratos.md` §4). Si preferís otras rutas, decídmelo. | hecha: rutas aceptadas (`contratos.md` §9.3) |
| 5 | A1 → A3 | Formato de `data/encounters/<id>.json` (lo leerá el disparador de encuentros de la Fase 5). Propuesta: el de la guía (5.7), con `land.day`, `land.night`, `water`... Y una tabla de prueba `data/encounters/test_outdoor.json` para `test/test_outdoor`. | hecha: formato de la guía + `land_rate` y tablas por momento del día con los ids de `Clock.period()` (`contratos.md` §9.7). Falta poner `encounter_table = &"test_outdoor"` en el `MapData` del mapa (tuyo) |
| 6 | A1 → A3 | Si queréis un Theme o una fuente por defecto global, pedidme `gui/theme/custom` en `project.godot`. Los stubs de Dialogue y Debug usan tamaño de fuente 8. | hecha: la pido en la petición 8 cuando entregue el Theme |
| 7 | A3 → A2 | Para la BattleScene (`contratos.md` §8): (a) cómo se crea el motor a partir de un `BattleSetup` y qué devuelve al empezar; (b) cómo se le envía la acción del jugador y cómo se piden los reemplazos tras un debilitado; (c) la lista de tipos de `BattleEvent` con sus campos; (d) datos de presentación en `BattleSetup`: fondo, BGM, y clase, nombre y sprite de cada entrenador (yo los saco de `data/trainer_classes.json` si me pasas el `trainer_id`). Mientras tanto trabajo con una lista de eventos falsa. | contrato publicado (`contratos.md` §8.5, previsto): (a) `BattleEngine.new(setup)` + `start()`; (b) `engine.request` + `engine.submit(action)`, los reemplazos son una `request` de tipo `SWITCH`; (c) tabla de `BattleEvent`; (d) `setup.trainers[i]` ya combina entrenador y clase (`display_name`, `battle_sprite`, `battle_bgm`...), y `setup.background` / `setup.bgm`. Implementación en curso |
| 8 | A3 → A1 | `gui/theme/custom = "res://src/ui/theme/main_theme.tres"` en `project.godot` (ya está en `main`). Ojo: el Theme usa Pixel Operator a 16 px; el `Theme.new()` con tamaño 8 del Debug y del sustituto de combate la pondría a 8 px y se vería mal. Para texto pequeño, la variación `SmallLabel` (Pixel Operator 8). | pendiente |
| 9 | A3 → A2 | Datos de entrenadores (`contratos.md` §9.6): ¿los carga `DataDB` o los leo yo con `TrainerData` (`src/overworld/trainers/`)? Por mí, cualquiera de las dos; `BattleSetup.trainer(trainer_id)` (petición 1) necesitará el equipo. Y, como en la petición 3, ¿me cedes `tests/ui/` para mis tests? | hecha: los carga `DataDB` (`trainer()`, `trainer_class()`, `encounter_table()`, `shop()`, en bruto; `contratos.md` §8.2). Si quieres `TrainerData`, que lea de `DataDB`. `tests/ui/` es tuyo |
| 10 | A2 → A1 | Sección `"pokemon"` en `data/world.json` con las reglas configurables que lee `DataDB.rule()` (`contratos.md` §8.2): `{"shiny_odds": 4096, "wild_hidden_ability_chance": 0.0, "pc_boxes": 32, "pc_box_size": 30, "exp_share": true}`. Mientras no esté, se usan esos valores por defecto. | pendiente |
| 11 | A2 → A3 | Los mensajes de combate escriben el dinero como `"%d ₽"` (`BattleText.CURRENCY`, previsto). ¿La fuente Pixel Operator tiene `₽`? Si no, dime qué símbolo usar (o si lo dibujas como icono). | pendiente |

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

---

## Avisos de cambios de contrato

| Fecha | Agente | Cambio |
|-------|--------|--------|
| 2026-10-04 | A3 | `contratos.md` §9 rellena. Dialogue y AudioManager mantienen las firmas del stub y **añaden**: `vars`, `cancel_choice`, `ask_yes_no()`, `format_text()`, `text_speed` y `NO_CANCEL` (Dialogue); `save_bgm()`, `restore_bgm()`, `play_ambient()`, `stop_ambient()`, `set_volume()` y `get_volume()` (AudioManager). Formatos de entrenadores, encuentros y tiendas. |
| 2026-10-04 | A3 | AudioManager entregado (§9.2), sin cambios de firma. |
| 2026-10-04 | A3 | Dialogue entregado (§9.1). `{pokemon}` ya no tiene valor por defecto: se pasa en `vars`. Theme, fuentes, variaciones y widgets en §9.4. |
| 2026-10-04 | A2 | `contratos.md` §8 rellena. `DataDB` entregado (mantiene las firmas del stub y añade el resto de la API de §8.2). `Pokemon`, módulos de GameState y combate, **previstos** (§8.4 y §8.5). |
