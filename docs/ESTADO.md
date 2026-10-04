# Estado del proyecto

**Hito actual:** `v0.1` (MVP, Fase 8 de la guía).

**Último aviso (2026-10-04, Javier):** 👋 **Se incorpora el Agente 4, dueño del motor del RandomLocke** (Fase R: generador de la ROM, `RomPatch`, códigos de semilla, validación y lógica pura de las reglas Locke). `src/randomizer/` y `tests/randomizer/` pasan del Agente 2 al Agente 4. El Agente 2 solo implementa `DataDB.apply_patch()` y `pokemon_died` según el contrato que publique el Agente 4 en `docs/contratos.md` §10. Reparto actualizado en `DIRECTRICES.md` §2 y §6 y en la Fase R.10. El Agente 4 trabaja con datos de prueba propios, así que **no bloquea a nadie** ni queda bloqueado.

**Aviso anterior (2026-10-04, Javier):** 📦 **Recursos gráficos descargados y listos** en `/mnt/c/Users/Javier/Pokemon-Panchito-recursos/` (fuera del repo). Índice en `docs/arte/recursos_terceros.md`; reglas de uso y escala en `docs/DIRECTRICES.md` §7.1. Set de Pokémon oficial: `06_generation9_pack` (generaciones 1–9, normales y shiny, con Pokémon que te siguen). **Se usan tal cual, sin reescalar.** Seguid con la prueba de nivel gráfico (§7).

**Aviso anterior (2026-10-04, Javier):** 🚨 **Los gráficos actuales no valen: el mínimo es el nivel de Pokémon Añil.** Leed `docs/DIRECTRICES.md` §0, §7 y §8 **antes de seguir**:
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
| 4 | Motor del RandomLocke | `src/randomizer/`, `tests/randomizer/`, `data/randomizer/`, `docs/randomlocke.md` y la sección 10 de `docs/contratos.md` |
| 3 | Presentación, UI y contenido Panchito | `src/ui/`, `src/battle/scene/`, `src/items/`, `src/overworld/trainers/`, `src/autoload/dialogue.gd`, `src/autoload/audio_manager.gd`, `data/trainer_classes.json`, `data/trainers/`, `data/items_panchito.json`, `data/shops.json`, `data/encounters/`, `assets/` (salvo `tilesets/` y `sprites/characters/`), `docs/entrenadores.md`, `docs/objetos_especiales.md` |

- `src/main/`, `src/util/`, `data/world.json`, `docs/flags.md` y `docs/mapas/` no estaban en el reparto: los ha tomado el Agente 1 (arquitectura). Si alguien no está de acuerdo, que lo diga en "Peticiones".
- **Compartidos**: `README.md` y `CREDITOS.md` (cada agente edita solo su sección), `docs/ESTADO.md` (cada uno su sección y sus filas), `.gitignore`, `.gitattributes`, `.gutconfig.json` y `addons/` (los cambios se piden al Agente 1).
- `res://default_bus_layout.tres` (buses de audio, ruta por defecto de Godot): Agente 3.

---

## Agente 1 — Mundo y arquitectura

**He leído `docs/DIRECTRICES.md`** §0, §7, §7.1 y §8 (versión del 2026-10-04 con los recursos descargados), las capturas de `docs/arte/referencias/` y `docs/arte/recursos_terceros.md`, y he reordenado mi plan. También las órdenes nuevas: petición 18 aceptada, sin Git LFS (todo `binary`) y **quien mergea a `main` lo sube a GitHub en el momento**.

**En qué estoy:** prueba de nivel gráfico (§7, paso 3), en este orden:
1. **512×384 con casillas de 32 px** y cámara del mundo con `zoom = 1` (los packs ya vienen al doble): `Grid`, movimiento (múltiplos de 2 px), cámara, colisiones y sala de pruebas. Se retiran el tileset y los personajes generados por código.
2. **TileSet real**: base `01_hgss_for_rmxp`; autotiles de hierba alta, camino, agua y flores de `02_public_gen4_tileset`; árboles de `03_big_tree_pack`; flora de `04_big_flora_pack`. Con colisiones, terrenos (hierba alta, agua, bordillos) y animaciones de agua y flores. **Escala** (decisión de Javier tras medirlo): 01, 03 y 04 vienen a ×1 (casillas de 16 px), así que al copiarlos se duplica cada píxel (×2 exacto, vecino más próximo); 02, 05 y 06 ya vienen a ×2 y se copian tal cual.
3. Protagonista provisional con un personaje de `05_ultimate_gen4_overworlds` (andar y correr).
4. `maps/test/muestra_ruta.tscn` (nivel de `anil_ruta.png`) y `maps/test/muestra_pueblo.tscn` (nivel de `anil_pueblo.png`: casas, cercas, NPCs del pack 05, flores animadas, sombras y el Pokémon que te sigue, con uno shiny, desde `assets/sprites/pokemon/followers/` y `followers_shiny/`).
5. Capturas a 512×384 junto a las referencias en `docs/arte/comparativas/` y aviso en "Preguntas para Javier".

Después: eventos de la historia del MVP (intro del profesor, laboratorio y rival) con la API de cinemáticas y la regla R.2.

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
- **Cinemáticas y eventos** (Fase 13.1, `contratos.md` §7b): autoload `Cutscene` (caminar, acercarse, mirar, globos, cámara, temblor, fundidos, música, dar objetos y Pokémon, combates...) donde se ejecutan los `StoryEvent`, que así sobreviven a los cambios de mapa. Disparadores (`Trigger`: al pisar o al entrar en el mapa, con flags de requisito y de "una sola vez"), NPCs con `event`, Poké Balls del inicial (`StarterBall`) y eventos comunes: enfermera (cura y fija el punto de reaparición), tienda y elegir inicial (con `DataDB.starter()`, regla R.2). En la sala de pruebas: enfermera, tres `StarterBall` y un disparador de prueba.
- `data/item_placements.json` (petición 12): `{placement_id: item_id}` de todos los objetos del suelo, generado con `maps/_tools/build_item_placements.gd`; un test avisa si está desactualizado. El evento del inicial usa ya `DataDB.starter_spec()` y `starter_ids()`.
- Sin Pokémon que puedan luchar no hay encuentros salvajes.
- Tests en `tests/mundo/`: GameState, SaveManager (también ranuras, copia y RandomLocke), mapas, encuentros, eventos y objetos colocados.
- Integración: he unido `origin/main` (las directrices de Javier) con el `main` local de los agentes. **El `main` local no está subido a GitHub** (pregunta 10).

**Bloqueos:** mapas de muestra → recursos en `assets/_terceros/` (Javier). Fase 8 → `BattleSetup` (petición 1), pantallas del Agente 3 y preguntas 1 y 2.

---

## Agente 2 — Datos y motor de combate

**He leído** (2026-10-04, órdenes nuevas de Javier) `docs/DIRECTRICES.md` §0, §7, §7.1 y §8, las 4 capturas de `docs/arte/referencias/` y `docs/arte/recursos_terceros.md`. Entendido: el listón es Añil; prohibido el arte generado por código; los packs de `/mnt/c/Users/Javier/Pokemon-Panchito-recursos/` no se tocan y se copia al repo **solo lo que se usa, sin reescalar** (frente 192 px, espalda 288 px, iconos 128×64 = 2 cuadros de 64, Pokémon que te siguen 256×256 = 4×4 cuadros de 64), con su crédito en `CREDITOS.md`; set oficial: `06_generation9_pack` (y `07_generation8_pack` solo si falta algo). **No descargo nada de internet.**

**Repo compartido (WSL):** `/home/javier/proyectos/pokemon-panchito` (tiene el `.git` y el `main` local; de él salen los worktrees `pokemon-panchito-agente1`, `-agente2` y `-agente3`, en `/home/javier/proyectos/`). Mi worktree: `/home/javier/proyectos/pokemon-panchito-agente2`. **Desde 2026-10-04, quien mergea en el `main` local hace `git push origin main` en ese momento**: GitHub es la referencia común.

**Plan (2026-10-04, órdenes de Javier):**
1. ✅ Subir el trabajo a GitHub (merge de `origin/main`: Agente 4 y tamaños de la Fase A.2).
2. ✅ Traspaso del randomizer al Agente 4 (abajo). Me quedo con `DataDB.apply_patch()` / `clear_patch()` según su contrato (§10) y con el evento `pokemon_died` del motor.
3. ✅ Sprites de **todas** las especies del pack 06 (`import_pokemon_assets.mjs --all`: ≈ 1.370 especies y formas, 8 vistas cada una, y 1.281 gritos, que ya van como archivos normales porque el Agente 1 quitó el audio de LFS).
4. Después: Fase 9 del motor de combate.

**En qué estoy:** Fase 9 del motor de combate (sistema de efectos con hooks).

### Traspaso del randomizer al Agente 4

`src/randomizer/` y `tests/randomizer/` son tuyos desde hoy (DIRECTRICES §2 y §6). He leído tu §10 v1 (rama `feat/agente4-randomlocke`): tu diseño (entrada `RandomizerInput` independiente de los autoloads, ajustes como diccionarios, 4 presets) sustituye al mío, así que lo que hay sirve de referencia y de banco de pruebas; reescríbelo o reutilízalo como prefieras.

**Archivos que te dejo** (todo en `main`):
- `src/randomizer/randomizer.gd` (generador), `randomizer_settings.gd` (ajustes y presets), `rom_patch.gd` (parche, JSON estable y spoilers), `rom_validator.gd` (validación R.4 y "especies en juego"), `seed_code.gd` (códigos).
- `tests/randomizer/test_randomizer.gd` (11 tests) y `tests/randomizer/golden_clasico.json` (parche dorado).
- `data/randomizer.json`: prohibidos (especies, movimientos y habilidades), topes de potencia por nivel, márgenes de nivel de las evoluciones, objetos garantizados en tiendas, etiquetas de legendario, intentos de validación y los presets `clasico`, `solo_aleatorio` y `caos`. Ahora es tuyo: muévelo a `data/randomizer/` si quieres (avísame para que el validador de datos no lo busque).

**API actual** (`contratos.md` §8.6, marcada como traspasada): `Randomizer.generate(seed, settings: RandomizerSettings) -> RomPatch` (lee `DataDB` sin modificarlo; devuelve `null` si hay un parche aplicado); `RandomizerSettings.from_preset(id)`, `apply_dict()`, `to_dict()`, `to_bits()` / `from_bits()` (21 campos, 30 bits), `matches_preset()`; `RomPatch.create()`, `from_dict()`, `to_dict()`, `section()`, `to_json()` (claves ordenadas), `apply()`, `spoiler_text()`; `RomValidator.validate(patch) -> PackedStringArray`, más `species_in_play()`, `wild_species()`, `level_moves()`, `default_moves()`, `evolutions()`; `SeedCode.encode(seed, settings, version)` / `decode(code)` / `random_seed()`: `PANCHITO-XXXX-XXXX-XX` = 5 bits de versión + 3 de preset + 32 de semilla + 10 de comprobación; con ajustes personalizados (preset 7) se añade `-XXXXXX` con los 30 bits de ajustes (la misma idea que tu `-C`).

**Tests:** códigos (preset, personalizado, no válidos y otra versión), misma semilla = misma ROM, parche dorado, robustez (100 semillas; 1000 con `PANCHITO_LONG_TESTS=1`, unos 170 s, todas válidas), reglas de equilibrio (triángulo de iniciales, primera etapa, sin legendarios tempranos, rival), STAB al nivel 1, aplicación a `DataDB` y vuelta atrás, spoilers y tiempo (< 3 s: ~0,2 s el clásico y ~0,9 s el caos). El test inyecta iniciales, regalos y estáticos de prueba en `DataDB` si no existen los JSON.

**Parche dorado:** semilla `20261004`, preset `clasico`. Guarda una huella SHA-256 de todo lo que lee el generador (versión, fuentes, `data/randomizer.json`, encuentros, entrenadores, iniciales, regalos, estáticos, intercambios, colocaciones y Pokédex regional): si cambian los datos, el test queda *pending* en vez de fallar, y se rehace con `PANCHITO_UPDATE_GOLDEN=1`. Rehecho hoy tras `item_placements.json` del Agente 1.

**Qué falta:** MT y tutores (aún no hay datos de MT), objetos equipados de los salvajes, `input_hash`, exportar los spoilers a `user://randomlocke/`, comprobar R.4 de objetos y movimientos necesarios para avanzar, temas de tipo por datos (`type_theme` / tu `leader_type`), `LockeRules` y la integración con el mundo y la UI.

**Decisiones que tomé** (por si las mantienes):
- Determinismo: siempre en orden de id con `DataUtil.sort_names()`. **Ojo: `Array.sort()` con `StringName` ordena por puntero, no por texto, y el orden cambia entre ejecuciones.** Subsemillas: `hash("%d:%d" % [seed, intento])`.
- Iniciales en triángulo: `starter_2` gana a `starter_1`, `starter_3` a `starter_2` y `starter_1` a `starter_3`. El rival no se resuelve aparte: cada especie de la línea del inicial original se cambia por la de la misma etapa de la línea nueva, así que el rival sigue llevando el que te gana y evolucionando.
- Al cambiar la especie de un entrenador se quitan `moves`, `ability` y `form`. No se repiten especies en un equipo.
- Movimientos por nivel: se conservan los niveles y el número; el ataque con STAB garantizado va el último de su primer nivel (para que entre en sus 4 iniciales); en cada momento de la curva, los 4 últimos aprendidos incluyen uno de daño. Solo movimientos implementados (`needs_script` falso) por defecto.
- Reservas: especies base con número > 0 y `nonstandard` vacío o `past` con learnset; legendario = etiquetas `restricted_legendary`, `sub_legendary` o `mythical`; sin legendarios por debajo del nivel 30 con `no_early_legendaries`.
- Evoluciones aleatorias: destino con más total de estadísticas que el origen y dentro de la tolerancia del original (evita ciclos).

**Lo que sigue siendo mío y respuesta a tus peticiones 7 y 8** (de tu rama): de acuerdo con la semántica de `apply_patch` del §10. Cuando tu contrato esté en `main`, adapto `DataDB`: `apply_patch(patch) -> Array[String]` atómico (valida referencias y hash antes; un error no toca el parche activo), consultas parcheadas también de tipos, estadísticas, evoluciones, objetos equipados, intercambios, colocaciones, tiendas y MT/tutores (cuando existan sus datos), sin volver a aplicar `species_map`, y `DataDB.randomizer_input() -> Dictionary` con el formato `RandomizerInput` (con `stage`, `min_level`, `max_level` y `family_id`). `pokemon_died` ya existe (`BattleSetup.locke_rules`, `result.deaths`, una vez por KO real); añadiré el tope de experiencia, el modo fijo y el límite de objetos en `BattleSetup` cuando `LockeRules` esté en `main`.

**Terminado:**
- Fase 4.2: `tools/import_data` (Node 18+, sin dependencias). Showdown `0.11.11` (tarball de npm verificado con sha512) + CSV de PokeAPI en el commit `a003ae375b69`, con nombres y descripciones en español (idioma 7). Genera `data/generated/`: 1379 especies y formas, 951 movimientos (con `needs_script`), 316 habilidades, 1376 objetos, tipos, learnsets, tablas de experiencia y naturalezas. Uso en `README.md` → Datos y `tools/README.md`.
- Fase 4.4: `data/species_overrides.json` con las evoluciones por intercambio sustituidas (decisión de Javier: nivel 36–38 las simples y subir de nivel con el objeto equipado las que lo piden) y Shedinja. `data/regional_dex.json` vacío hasta que Javier decida la Pokédex.
- Fase 4.5: `DataDB` real con clases tipadas (`SpeciesData`, `MoveData`, `ItemData`, `AbilityData`, `NatureData`), overrides, objetos Panchito, y acceso en bruto a entrenadores, clases, encuentros y tiendas. **Mantiene las firmas del stub.** Contrato en `contratos.md` §8.1–8.3. Tests en `tests/datos/`.
- Efectos de uso de los objetos estándar (Poción, Balls, Antídoto, Revivir, Ataque X, Repelente...) en `tools/import_data/extra/item_effects.json`, con el mismo formato `effect`/`effect_params` que `items_panchito.json`.
- Fase 6: `Pokemon` (creación reproducible, fichas de entrenador, estadísticas, EVs, experiencia, movimientos, guardado), `EvolutionRules`, y `Party`, `PCStorage` y `Pokedex`, que GameState ya crea y guarda solo (`contratos.md` §8.4). Tests en `tests/pokemon/`.
- **Fase 7: `BattleEngine` entregado** (`contratos.md` §8.5, ya no es previsto): turnos, orden, daño **exacto** (comparado con el simulador real de Showdown), estados, efectos por datos, captura, huida, objetos, experiencia con Repartir Experiencia, dinero, evoluciones pendientes e IA 0/1. `BattleSetup.wild()` y `BattleSetup.trainer()`. **Agente 3:** ya puedes escribir el adaptador del `BattleDriver`; los textos de presentación llevan `tag` en `data` para que la escena los sustituya si quiere. Tests en `tests/combate/` (daño, flujo, captura, huida, IA, aprender movimientos, combate completo con semilla).
- Fase 4.6: validador (`tools/validate/`, también como test). Hoy: 0 errores; avisos de iconos y de los movimientos que necesitan script.
- Comandos de Debug: `givepkmn`, `heal`, `party`, `setlevel`, `wildbattle`, `trainerbattle` y `dex`.
- **DIRECTRICES §7.1–7.2: sprites y gritos del Generation 9 Pack** (sustituye a la descarga de Showdown, retirada con sus sprites). `tools/sprites/import_pokemon_assets.mjs` (uso en `tools/README.md`) copia sin reescalar las **32 especies del MVP** (lista inicial en `data/species_in_use.json`, archivo nuevo que tomo yo, + las que salen en los datos y sus familias): `assets/sprites/pokemon/{front,front_shiny,back,back_shiny,icons,icons_shiny,followers,followers_shiny}/<id>.png`, más `<id>_female.png` donde hay diferencias por sexo (Venusaur, Butterfree, Rattata, Raticate, Magikarp, Gyarados), todo con sus `.import`. Ningún archivo viene del pack 07. Resumen en `data/generated/pokemon_assets.json`. **Gritos** en `assets/audio/cries/<id>.ogg` (la ruta de `AudioManager`). **Ampliado a todas las especies del pack** (pregunta 11): lo que no deba salir en RandomLocke se excluye desde sus ajustes. Formas que no tienen equivalente en el pack (Gigamax, gorras de Pikachu, máscaras de Ogerpon, Silvally...) y Pokémon que te siguen que el pack no trae (megas y otras formas de combate): listados en `data/generated/pokemon_assets.json`.
- **Regla R.2 y parche R.1 en `DataDB`** (`contratos.md` §8.1–8.2): `starter()`, `gift()`, `static_encounter()`, `trade()`, `placed_item()` (petición 12), `item_placements()`, `resolve_markers()` y `apply_patch()` / `clear_patch()`. **Agente 3:** `Dialogue` puede resolver los marcadores llamando a `DataDB.resolve_markers(text)`; el formato que espero de `starters.json`, `gifts.json`, `statics.json` y `trades.json` está en §8.1 (si prefieres otro, dímelo). **Agente 1:** el evento del inicial puede usar `Pokemon.from_spec(DataDB.starter_spec(&"starter_1"))`.
- **Motor de RandomLocke (Fase R.1–R.6, mi parte de R.7)** en `src/randomizer/` (`contratos.md` §8.6): `Randomizer.generate(seed, settings)` puro y determinista (se puede llamar desde un hilo), `RomPatch` (`apply()`, `to_json()`, `spoiler_text()`), `RandomizerSettings` con presets (`clasico`, `solo_aleatorio`, `caos`), validación R.4 con subsemillas, códigos `PANCHITO-XXXX-XXXX-XX` y tests (determinismo, parche dorado, **1000 semillas sin fallos**, reglas, tiempo: ~0,2 s el clásico y ~0,9 s el caos). Reglas Locke en el combate: `BattleSetup.locke_rules`, evento `pokemon_died` y `result.deaths`. Configuración en `data/randomizer.json` (archivo nuevo, lo tomo yo como Agente 2). **Agente 1:** guarda `rom.to_json()` en `slot_<n>.rom.json` y aplica `RomPatch.from_dict(...).apply()` antes de cargar el mapa; el contador de muertes puede leer `result.deaths`. **Agente 3:** la pantalla de ajustes puede leer los presets de `data/randomizer.json` y los campos de `RandomizerSettings`; `SeedCode.decode()` da el error en español.
- **DIRECTRICES §3: verificación con WikiDex** (`tools/wikidex/verify_stats.mjs`, uso en `tools/README.md`): API de MediaWiki por lotes, con pausas y caché. Comprobadas **197 especies** (las del juego, sus familias y una muestra de toda la Pokédex nacional): estadísticas base iguales en todas; 2 EVs de PokeAPI corregidos con `"fuente": "WikiDex"` en `species_overrides.json` (Slowking y Nymble). El validador lee el resultado (`data/generated/wikidex_check.json`) y avisa si hay diferencias o especies del juego sin comprobar. Cuando Javier decida la Pokédex regional, se vuelve a pasar.
- **DIRECTRICES §8 (mi parte):** shiny por tiradas independientes de 1/`odds` (`data/world.json` → `shiny`, petición 13), Amuleto Iris (3), Masuda (6) y ambos (8); los entrenadores no tiran salvo `"shiny": true`; `forceshiny` y `givepkmn ... shiny` en el Debug; test estadístico con 1.000.000 de tiradas sembradas y test de que los shiny son los sprites oficiales.

**Bloqueos:** ninguno.

**Aviso para todos:** en Godot 4.7, `Array.sort()` con `StringName` **no** ordena por texto (compara punteros: `[&"zeta", &"alpha"]` puede quedar en cualquier orden y cambia entre ejecuciones). Si el orden importa (semillas, guardado, listas que ve el jugador), usad `DataUtil.sort_names(array)` o `sort_custom` con `String(a) < String(b)`.

**Decisiones de Javier ya tomadas (para el GDD):** evoluciones por intercambio → nivel fijo o subir de nivel con el objeto equipado; experiencia → fórmula escalada de la 7.ª generación en adelante (sin bonus por combate de entrenador).

---

## Agente 3 — Presentación, UI y contenido Panchito

**He leído `docs/DIRECTRICES.md` §0, §7, §7.1 y §8** (actualización de 2026-10-04 con los recursos descargados), las capturas de `docs/arte/referencias/` y `docs/arte/recursos_terceros.md`. `core.hooksPath .githooks` activo en mi copia. Plan nuevo, en este orden:

**En qué estoy:** prueba de nivel gráfico (§7, pasos 1 y 4), en `feat/agente3-muestra-combate`:
1. Revisar `recursos_terceros.md` y pedir lo que falta para igualar a Añil (preguntas para Javier).
2. Reescribir `docs/arte/BIBLIA.md` con la **escala real de los packs** (ya al doble para 512×384, espaldas al triple, sin reescalar) y poner al día `seguimiento.md` y `licencias.md`. Mi antigua lista `docs/arte/recursos.md` queda sustituida por la de Javier.
3. **Pantalla de combate de muestra** con los recursos reales: fondo de `10_fondos_combate`, Pokémon del `06_generation9_pack` (frente 192 y espalda 288, los importa el Agente 2), iconos de tipo de Loaky (`types_spanish.png`), fuente *Truth and Ideals*, cajas de datos con PS y experiencia animadas, botones Luchar/Mochila/Pokémon/Huir con color y animación, y entrada de un shiny con destellos y sonido.
4. **Pantalla de datos del Pokémon de muestra**, diseño propio.
5. Fuente *Truth and Ideals*: tiene ñ, tildes, ü, ¿¡, ♂, ♀ y ★; le faltan €, — y · (lo confirmo renderizándola).
6. Capturas a 512×384 al lado de las referencias en `docs/arte/comparativas/` y aviso a Javier.

**Después** (tras la aprobación de Javier): entrenadores Panchito con `11_character_customization_gen4`, menú inicial de la Fase 15.2 ("Realizado por Javier Saguar"), pantallas del MVP, TrainerNPC, marcadores R.2 en `Dialogue`, `starters.json`/`gifts.json`/`statics.json`/`trades.json` y las pantallas del RandomLocke (R.8).

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

## Agente 4 — Motor del RandomLocke

**En qué estoy:** (sin empezar)

**Terminado:**
- (nada todavía)

**Bloqueos:**

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
| 15 | A1 → A2 | `DataDB.starter(slot: StringName)` para la regla R.2 (y parcheado en RandomLocke): que devuelva `{species, level}` (o solo el id de la especie) de `data/starters.json` del Agente 3. Lo usa `src/events/common/choose_starter_event.gd`; mientras no exista, la Poké Ball no hace nada. | hecha: ya estaba (`DataDB.starter(slot) -> StringName` y `DataDB.starter_spec(slot) -> {species, level?...}`, parcheados en RandomLocke); veo que el evento ya usa `starter_spec()` |
| 16 | A1 → A3 | Formato de `data/starters.json` (tuyo, DIRECTRICES §2). Propuesta: `{"starter_1": {"species": "…", "level": 5}, "starter_2": {…}, "starter_3": {…}}`, con 1 = Planta, 2 = Fuego y 3 = Agua (como `rival_lab_1/2/3`). Y cuando `Dialogue` resuelva los marcadores R.2, ¿uso `{starter:starter_1}` en vez de pasarle el nombre en `vars`? | pendiente |
| 17 | A1 → A2 | Aviso: al añadir `data/item_placements.json` y `new_game.starter_level` en `data/world.json`, el test del parche dorado del randomizer queda *pending* ("Los datos de entrada han cambiado"). Cuando puedas, rehaz el parche dorado (`PANCHITO_UPDATE_GOLDEN=1`). | hecho: parche dorado rehecho |
| 18 | A2 → A1 | Carpeta de los **Pokémon que te siguen** (DIRECTRICES §7.2, la acordamos tú y yo): propongo `assets/sprites/pokemon/followers/<id>.png` y `followers_shiny/<id>.png`, junto al resto de sprites de Pokémon, y ya los he copiado ahí. Son hojas de 256×256 = 4×4 cuadros de 64 px (filas: abajo, izquierda, derecha, arriba; columnas: los 4 pasos), a escala del pack, sin zoom. Si prefieres otra carpeta (por ejemplo `assets/sprites/characters/followers/`), dímelo y cambio una constante del importador. | aceptada por Javier: el Pokémon que te sigue usa `assets/sprites/pokemon/followers/` y `followers_shiny/` |
| 19 | A2 → A3 | Sprites de Pokémon nuevos (Generation 9 Pack, en `main`): **frente 192×192 y espalda 288×288** (se dibujan a 1×, sin zoom: ya vienen al doble), **iconos 128×64** (2 cuadros de 64) también en `icons_shiny/`, y `<id>_female.png` donde hay diferencias por sexo. Hace falta: (a) poner al día `tools/arte/reglas.json` (todavía pide cuadros de 96 y de 32, y trata `icons/` como placeholder); (b) apuntar el set en `docs/arte/seguimiento.md` y `docs/arte/licencias.md` (créditos ya en `CREDITOS.md`); (c) la BattleScene ya encuentra las rutas de siempre (`front[_shiny]/<id>.png`...). Ya están los de **todas** las especies (pregunta 11) y los gritos en `assets/audio/cries/<id>.ogg`. | pendiente |
| 20 | A1 → A2 | **Sin Git LFS** (orden de Javier): `.gitattributes` ya trata `.ogg`, `.wav`, `.mp3`, `.psd` y `.aseprite` como `binary` normal, y está en GitHub. **Ya puedes subir los gritos** (`assets/audio/cries/`). | pendiente |
| 21 | A1 → A3 | Lo mismo para el audio: sin Git LFS, los `.ogg`/`.wav` se suben como binarios normales. | informativo |

---

## Preguntas para Javier

| # | Quién pregunta | Pregunta | Respuesta |
|---|----------------|----------|-----------|
| 1 | A1 | **Para el MVP (Fase 8):** ¿cuáles son los 3 iniciales? ¿Nombres del pueblo inicial, de la ciudad 2, del profesor y del rival por defecto? (La Fase 2 / GDD está sin hacer.) Mientras tanto uso nombres provisionales marcados "POR DEFINIR". | |
| 2 | A1 | **Reloj** (Fase 14.1): ¿hora real del sistema o reloj interno acelerado? Ahora mismo, real (`data/world.json` → `clock.mode`). | |
| 3 | A1 | **Dinero inicial**: 3000 provisional (`data/world.json` → `new_game.money`). ¿Vale? | |
| 4 | A1 | **Git LFS** no está instalado en el WSL: hace falta `sudo apt install git-lfs && git lfs install` antes de subir audio (`.ogg`, `.wav`...). | Javier: sin LFS por ahora; todo como `binary` (hecho por A1) |
| 5 | A3 | **Decisiones del GDD** (`docs/GDD.md` §0): las que bloquean el MVP, además de las de la pregunta 1, son: ¿quién o qué es Panchito?, nombre de la región, tono (¿parodia total o aventura seria con chistes?), especies salvajes de la Ruta 1 y aspecto/nombres por defecto del chico y la chica. El resto del GDD puede esperar. | |
| 6 | A3 | **Entrenadores del MVP** (`docs/entrenadores.md`): ¿te valen las 20 clases de la tabla 10.2 tal cual? ¿Y los textos provisionales del Vendedor de Chupachups Manolo y del rival? | |
| 7 | A2 | **Habilidad oculta en Pokémon salvajes** (Fase 6.1, "con baja probabilidad"): ¿qué probabilidad? En los juegos actuales es 0 salvo casos especiales. Ahora: 0 (`wild_hidden_ability_chance`). | |
| 8 | A3 | **Prueba de nivel gráfico, paso 1: recursos para descargar** (`docs/arte/recursos.md`, con enlace, autores y licencia de cada uno): sprites de Pokémon, tilesets, personajes del mapa, Pokémon que te siguen, fondos y bases de combate y fuentes. (a) ¿Los descargas en `assets/_terceros/`? Para mi muestra de combate necesito, por orden: el **set de sprites de Pokémon** (propongo la opción A, *Animated Pokemon System*, el mismo linaje que Añil; la B es la de Showdown del Agente 2), los **fondos y bases** de *Elite Battle System* y, si quieres comparar, otra **fuente**. (b) Varios autores **prohíben redistribuir** sus packs y el repo es público: ¿ponemos `assets/_terceros/` en `.gitignore` y en el repo solo lo que el juego usa? (`.gitignore` lo cambiaría el Agente 1) | |
| 9 | A3 | **Biblia de arte y paleta** (`docs/arte/BIBLIA.md`, muestrario en `assets/arte/paleta.png`): ¿la apruebas o cambias algo? Decisiones abiertas en su §12: paleta, fuente, set de sprites, tono visual de lo nuestro (UI, clases Panchito, logo) y lienzo de 80×80 para los entrenadores en combate | |
| 10 | A1 | **GitHub**: el `main` local tiene el trabajo de los tres agentes y tus directrices, pero no está subido (no subimos sin permiso). ¿Lo subo (`git push origin main`) cada vez que se integre algo? Si sigues subiendo cosas a GitHub desde otra copia, las integro igual que esta vez. | |
| 11 | A2 | **Sprites para RandomLocke:** en RandomLocke puede salir cualquier especie, así que harían falta los sprites de todas. Copiarlas todas con `import_pokemon_assets.mjs --all` son unos 11.600 archivos (≈ 25–30 MB de PNG, más ≈ 15 MB de gritos). ¿Las copiamos todas cuando llegue el RandomLocke, o limito el randomizer a una lista de especies (por ejemplo, la Pokédex regional ampliada)? Y para los gritos: ¿instalas Git LFS (pregunta 4) o los subimos sin LFS? | Javier (2026-10-04): (a) se copian los de **todas** las especies del pack 06 y lo que no deba salir en RandomLocke se excluye desde sus ajustes; (b) sin Git LFS: los gritos van como archivos normales. **Hecho.** |
---

## Avisos de cambios de contrato

| Fecha | Agente | Cambio |
|-------|--------|--------|
| 2026-10-04 | A1 | Sin Git LFS: `.gitattributes` trata el audio, `.psd` y `.aseprite` como `binary`. Nueva norma de Javier: quien mergea a `main` local hace `git push origin main` en el momento. |
| 2026-10-04 | A1 | §7b nueva: autoload `Cutscene` (antes de `Debug`), `StoryEvent`, `Trigger`, `StarterBall` y eventos comunes. `NPC` añade `event` y `event_params`. `MapEntity.set_forced_hidden()`, `MapRoot.get_triggers()`/`trigger_at()`/`enter_triggers()`, `Grid.path_between()`. El jugador actualiza `GameState.player_tile`/`player_facing` también cuando lo mueve una cinemática. |
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
| 2026-10-04 | A2 | Sprites de Pokémon: nuevas carpetas `icons_shiny/`, `followers/` y `followers_shiny/` (petición 18) y variantes `<id>_female.png`; tamaños del Generation 9 Pack (192/288/128×64/256). `data/species_in_use.json` (nuevo) define, con la Pokédex regional, qué especies usa el juego. |
