# Contratos entre módulos

Interfaces públicas entre las partes del juego. Cada sección la define y mantiene **su dueño**.

- **Cambiar un contrato** = avisarlo en `docs/ESTADO.md` (sección "Avisos de cambios de contrato") y no romper a los demás: se **añade**; no se quita ni se renombra nada sin acuerdo.
- Lo marcado **(previsto)** puede cambiar hasta que su dueño lo entregue.
- Si necesitas algo de una sección que no es tuya, pídelo en `docs/ESTADO.md` → "Peticiones".

| Sección | Dueño |
|---------|-------|
| 0. Convenciones comunes | Agente 1 (todos pueden proponer) |
| 1. EventBus · 2. GameState · 3. SaveManager · 4. SceneManager · 5. Mapas · 6. Clock · 7. Debug · 7b. Cinemáticas y eventos | Agente 1 |
| 8. DataDB, clases de datos, Pokemon, BattleSetup, BattleAction, BattleEvent | Agente 2 |
| 9. Dialogue, AudioManager, BattleScene, UI, formato de entrenadores | Agente 3 |

---

## 0. Convenciones comunes

- **Godot 4.7.2-stable** (edición estándar). GDScript con **tabuladores**, **tipado estático siempre** (el proyecto avisa de las declaraciones sin tipo) y `class_name` en las clases reutilizables. Los autoloads **no** llevan `class_name`.
- **IDs** en minúsculas y sin espacios (`pikachu`, `thunderbolt`, `vendedorchupachups`), los mismos que Showdown cuando existan. En código, como `StringName` (`&"pikachu"`).
- **Textos visibles en español.** Los textos de la interfaz pasan por `tr()`.
- **Ningún dato de juego en un `.gd`**: potencias, niveles, precios y similares van en `data/`.
- **Leer JSON**: `JsonFile.read(path) -> Variant` y `JsonFile.read_dict(path) -> Dictionary` (`src/util/json_file.gd`). Dan errores claros con la ruta y la línea.
- **Resolución base 512×384** (decisión de Javier, Fase 3.2; ventana de 1024×768, escalado entero y filtro Nearest). **El mundo se ve a ×2 con casillas de 32 px de pantalla**: los packs ya vienen al doble (DIRECTRICES §7.1), así que la cámara del mundo tiene `zoom = 1` y hay 16×12 casillas en pantalla. **La UI no tiene zoom**: las `CanvasLayer` se diseñan a 512×384 nativo. Las posiciones del mundo van en múltiplos de 2 px (un píxel del arte: `Grid.ART_PIXEL`, `Grid.round_to_art_pixel()`). Fondo por defecto negro.
- **Casillas de 32 px** (`Grid.TILE`). Las entidades del mapa se colocan en el **centro** de su casilla: `Grid.to_world(tile) -> Vector2`, `Grid.to_tile(pos) -> Vector2i`, `Grid.path_between(from, to)` (`src/overworld/grid.gd`).
- **Direcciones**: `Vector2i.UP/DOWN/LEFT/RIGHT` en código; `"up"`, `"down"`, `"left"` y `"right"` en JSON y en el guardado (`Grid.dir_name()` / `Grid.dir_from_name()`, estáticas; `GameState` tiene las mismas como métodos).
- **Id de mapa** = ruta de la escena dentro de `maps/` sin `.tscn`: `maps/pueblo_inicial/exterior.tscn` → `&"pueblo_inicial/exterior"`.

### Capas

| CanvasLayer | `layer` | Contenido |
|-------------|---------|-----------|
| `Main/World` | 0 | Mapa actual y jugador (Node2D) |
| `Main/Battle` | 10 | Escena de combate |
| `Main/UI` | 20 | Menús (pila de `SceneManager`) |
| Dialogue | 30 | Cuadro de texto (Agente 3) |
| `Main/Transition` | 50 | Fundidos (`Transition/Fade`) y transiciones |
| Debug | 100 | Menú de depuración |

| Capa de física 2D | Bit | Uso |
|-------------------|-----|-----|
| `paredes` | 1 | Colisiones del TileSet (paredes, árboles, tejados...) |
| `entidades` | 2 | NPCs, objetos del suelo y carteles (bloquean el paso y se pueden examinar) |
| `disparadores` | 3 | Áreas que no bloquean: triggers, objetos ocultos |
| `agua` | 4 | Agua del TileSet (bloquea salvo con Surf) |

### Acciones de input (Input Map)

| Acción | Teclado | Mando |
|--------|---------|-------|
| `move_up/down/left/right` | Flechas / WASD | Cruceta / stick izquierdo |
| `accept` | Z / Enter / Espacio | A |
| `cancel` | X / Escape / Retroceso | B |
| `menu` | C / Enter | Start |
| `run` | Shift | B (mantener) |
| `speed_up` | Tab | — |
| `debug` | F9 | — |
| `ui_text_mode` | Tab (solo en el teclado A3; registrada al abrirlo) | — |

- Nunca se leen teclas directamente: siempre acciones.
- Enter está en `accept` y en `menu` (como en la tabla de la guía). En el mapa se comprueba `menu` antes que `accept`, así que Enter abre el menú y Z o Espacio interactúan. En los menús, Enter acepta.
- `ui_accept`, `ui_cancel` y `ui_up/down/left/right` (los que usan los `Control` de Godot) incluyen también Z, X/Retroceso y WASD.

### Bloqueo del control del jugador

`GameState.lock_input(reason)` / `GameState.unlock_input(reason)`. Cada `lock` necesita su `unlock` con el mismo `reason`. El jugador no se mueve mientras `GameState.input_locked` sea `true`.

| `reason` | Quién |
|----------|-------|
| `&"map_change"`, `&"battle"`, `&"menu"`, `&"debug"`, `&"interact"` | SceneManager / Debug / Player (Agente 1) |
| `&"cutscene"` | Cinemáticas (Agente 1, Fase 13) |
| `&"dialogue"` | Dialogue (Agente 3) |

### Tests

GUT 9.7.1 (`addons/gut`). Los tests van en `tests/`, con archivos `test_*.gd` que heredan de `GutTest`. **Un `push_error` durante un test lo hace fallar** (salvo que el test lo espere). Ejecutar: ver `README.md`.

---

## 1. EventBus (Agente 1)

Autoload `EventBus` (`src/autoload/event_bus.gd`). Solo declara señales; las emite el sistema indicado.

| Señal | La emite | Cuándo |
|-------|----------|--------|
| `player_stepped(tile: Vector2i)` | Player | Al terminar cada paso |
| `map_will_change(from_map: StringName, to_map: StringName)` | SceneManager | Pantalla en negro, antes de descargar el mapa |
| `map_loaded(map_id: StringName)` | SceneManager | Mapa cargado y jugador colocado, antes del fundido de entrada |
| `repel_wore_off` | WildEncounters | Se ha gastado el último paso de Repelente |
| `battle_started(setup: Variant)` | SceneManager | Al empezar `start_battle()` |
| `battle_ended(outcome: StringName)` | SceneManager | Al cerrar la escena de combate |
| `flag_changed(key: StringName, value: bool)` | GameState | Solo si el valor cambia |
| `var_changed(key: StringName, value: Variant)` | GameState | `null` si se borra |
| `money_changed(money: int)` | GameState | |
| `badge_obtained(badge_id: StringName)` | GameState | |
| `new_game_started` | GameState | En `new_game()` |
| `game_saved(slot: int)` / `game_loaded(slot: int)` | SaveManager / SceneManager | |
| `input_lock_changed(locked: bool)` | GameState | Al pasar de libre a bloqueado y al revés |
| `menu_opened(menu: Node)` / `menu_closed(menu: Node)` | SceneManager | |
| `dialogue_started` / `dialogue_finished` | Dialogue | |
| `time_period_changed(period: StringName)` | Clock | Al cambiar el momento del día |

Para añadir una señal, pídela al Agente 1.

---

## 2. GameState (Agente 1)

Autoload `GameState` (`src/autoload/game_state.gd`): estado de la partida.

### Campos

| Campo | Tipo | Notas |
|-------|------|-------|
| `mode` | `StringName` | `GameState.MODE_NORMAL` (`&"normal"`) o `MODE_RANDOMLOCKE` (`&"randomlocke"`). Se elige al crear la partida |
| `randomlocke` | `Dictionary` | Vacío en modo normal. En RandomLocke: `seed_code`, `settings`, `generator_version`, `rules`, `zones` (`{zone_id: estado}`), `deaths` y `status` (`"in_progress"`/`"finished"`) |
| `slot` | `int` | Ranura de la partida en curso (0 = ninguna). No va en el JSON |
| `rom_patch` | `Dictionary` | Parche de la ROM del RandomLocke. Se guarda aparte (`slot_<n>.rom.json`) |
| `player_name`, `rival_name` | `String` | |
| `player_gender` | `StringName` | `&"male"` / `&"female"` |
| `trainer_id`, `secret_id` | `int` | 0–65535, aleatorios en `new_game()` |
| `money` | `int` | Usa `add_money()` / `spend_money()` |
| `badges` | `Array[StringName]` | Ids de medalla |
| `play_time` | `float` | Segundos (solo corre con `in_game`) |
| `map_id` | `StringName` | Mapa actual |
| `player_tile`, `player_facing` | `Vector2i` | Los actualiza el jugador en cada paso o giro |
| `healing_map`, `healing_spawn` | `StringName` | Dónde reapareces al perder |
| `flags` | `Dictionary[StringName, bool]` | Solo se guardan las activas |
| `vars` | `Dictionary[StringName, Variant]` | Solo `int`, `float`, `bool` o `String` |
| `party`, `pc`, `pokedex` | `Variant` | Objetos `Party`, `PCStorage` y `Pokedex` (Agente 2) |
| `bag` | `Variant` | Objeto `Bag` (Agente 3) |
| `world_config` | `Dictionary` | Contenido de `data/world.json` (no se guarda) |
| `input_locked` | `bool` | Solo lectura |
| `in_game` | `bool` | `true` dentro de una partida (no en el título) |

### API

```gdscript
GameState.reset() -> void                # sin partida
GameState.new_game(options := {}) -> void   # data/world.json → new_game; options: slot, mode, randomlocke, rom_patch
GameState.is_randomlocke() -> bool
GameState.flag(key) -> bool
GameState.set_flag(key, value := true) -> void
GameState.clear_flag(key) -> void
GameState.has_var(key) -> bool
GameState.get_var(key, default = null) -> Variant
GameState.var_int(key, default := 0) -> int
GameState.var_str(key, default := "") -> String
GameState.set_var(key, value) -> void    # StringName se guarda como String
GameState.clear_var(key) -> void
GameState.add_money(amount) -> void      # limitado a 0..world.json → max_money
GameState.spend_money(amount) -> bool    # false si no llega
GameState.has_badge(id) -> bool
GameState.add_badge(id) -> void
GameState.set_healing_spot(map_id, spawn_id) -> void
GameState.lock_input(reason) / unlock_input(reason) / is_input_locked_by(reason) / clear_input_locks()
GameState.to_dict() -> Dictionary / from_dict(data) -> void
GameState.dir_name(dir: Vector2i) -> String / dir_from_name(text) -> Vector2i   # = Grid.dir_name() / Grid.dir_from_name()
```

### Módulos de otros agentes (`party`, `pc`, `pokedex`, `bag`)

GameState busca las clases **por su `class_name`**: `Party`, `PCStorage`, `Pokedex` y `Bag`. En cuanto existan, se crean y se guardan solas, sin tocar GameState. Requisitos:

- `new()` sin argumentos crea el módulo vacío (partida nueva).
- `to_dict() -> Dictionary` solo con tipos de JSON (nada de `Vector2i`, `StringName` ni objetos).
- `from_dict(data: Dictionary) -> void` restaura el estado. Ojo: JSON devuelve los números como `float`.

Mientras la clase no exista, el campo vale `null` (o el diccionario cargado, que se conserva al guardar). Si alguien prefiere otro nombre de clase, que lo pida.

### Convenciones de flags y variables

Todas las claves se registran en `docs/flags.md`. Patrones reservados:

| Patrón | Significado | Quién |
|--------|-------------|-------|
| `trainer_defeated:<trainer_id>` | Entrenador derrotado | TrainerNPC (Agente 3) |
| `item_taken:<map_id>:<nodo>` | Objeto del suelo recogido | ItemBall (Agente 1) |
| `story_progress` (var `int`) | Avance de la historia en pasos de 10 | Eventos (Agente 1) |
| `repel_steps` (var `int`) | Pasos de Repelente que quedan | La pone el objeto (Agente 3); la descuenta WildEncounters (Agente 1) |

---

## 3. SaveManager (Agente 1)

Autoload `SaveManager` (`src/autoload/save_manager.gd`). **Varias partidas a la vez** (Fase 8.7): ranuras `1..slot_count()` (`data/world.json` → `saves.slots`, 8 por defecto), cada una normal o RandomLocke.

```gdscript
SaveManager.slot_count() -> int
SaveManager.has_save(slot) -> bool
SaveManager.current_slot() -> int              # GameState.slot, o 1 si no hay
SaveManager.first_empty_slot() -> int          # 0 = todas ocupadas
SaveManager.last_used_slot() -> int            # la de "Continuar"; 0 = ninguna
SaveManager.save_game(slot := 0) -> Error      # 0 = la ranura de la partida en curso
SaveManager.load_game(slot) -> Error           # restaura GameState (y la ROM); para entrar: SceneManager.continue_game()
SaveManager.slot_summary(slot) -> Dictionary   # {} si está vacía
SaveManager.list_slots() -> Array[Dictionary]  # un resumen por ranura, en orden ({} = vacía)
SaveManager.thumbnail(slot) -> Texture2D       # null si no tiene
SaveManager.copy_slot(from, to) -> Error       # sobrescribe `to`
SaveManager.delete_save(slot) -> void          # borra todos sus archivos
SaveManager.apply_rom_patch() -> void          # aplica (o quita) en DataDB la ROM de la partida
```

- **Archivos** de la ranura `n` en `user://saves/`: `slot_<n>.json` (`{save_version, game_version, saved_at, summary, state}` con `state = GameState.to_dict()`), `slot_<n>.png` (miniatura: el mundo a 256×192, sin la interfaz) y, en RandomLocke, `slot_<n>.rom.json` (el parche de la ROM, `GameState.rom_patch`, Fase R.1). `index.json` guarda la última ranura usada.
- **`summary`**: `slot`, `mode` (`"normal"`/`"randomlocke"`), `player_name`, `player_gender`, `play_time`, `badges` (número), `money`, `map_id`, `map_name`, `dex_seen`, `dex_caught`, `party` (`[{species, shiny}]`, para los iconos), `saved_at`, `thumbnail` (ruta o `""`) y, en RandomLocke, `seed_code`, `deaths` y `status`. (Ojo: tras pasar por JSON, los números llegan como `float`.)
- La miniatura sale de `SceneManager.world_snapshot` (se toma al abrir el menú de pausa, antes de dibujarlo) o, si no hay, de la pantalla actual.
- **Al cargar** una partida RandomLocke se llama a `DataDB.apply_patch(rom_patch)` **antes** de cargar el mapa; al cargar una normal o volver al título, a `DataDB.clear_patch()` (si DataDB los tiene; Agente 2, Fase R).
- Las confirmaciones (sobrescribir, copiar, borrar dos veces) son cosa de la UI.
- **Escritura segura**: se escribe a `.tmp`, se comprueba, la versión anterior pasa a `.bak` y el `.tmp` se renombra. Si el principal está dañado, se carga el `.bak`.
- **Migraciones**: al cambiar el formato, se sube `GameState.SAVE_VERSION` y se añade el paso en `SaveManager._migrate()`.

---

## 4. SceneManager (Agente 1)

Autoload `SceneManager` (`src/autoload/scene_manager.gd`). La escena principal es `src/main/main.tscn`:

```
Main (Node)
├── World (Node2D)          # mapa actual + jugador
├── Battle (CanvasLayer 10) # escena de combate
├── UI (CanvasLayer 20)     # menús
└── Transition (CanvasLayer 50)
    └── Fade (ColorRect)
```

### Flujo de partida

```gdscript
SceneManager.boot()                                  # lo llama Main
SceneManager.go_to_title() -> void                   # corrutina
SceneManager.start_new_game(map := &"", spawn := &"", options := {}) -> void
SceneManager.continue_game(slot: int) -> Error       # carga y entra en el mapa guardado
SceneManager.world_snapshot: Image                   # el mundo sin interfaz (al abrir el menú de pausa)
SceneManager.capture_screen() -> Image               # null en headless
```

`start_new_game()`: `options` = las de `GameState.new_game()`. Sin `slot`, usa la primera ranura vacía (o la 1). Con RandomLocke y `rom_patch`, aplica el parche en DataDB antes de cargar el mapa. El flujo de pantallas (elegir modo y ranura, ajustes y generación de la ROM) es del Agente 3; al acabar llama a `start_new_game(&"", &"", {slot, mode, randomlocke, rom_patch})`.

Argumentos de arranque (después de `--`): `--map=<map_id> [--spawn=<id>]` empieza partida nueva en ese mapa y `--load=<slot>` carga una ranura. Sin argumentos: siempre título (escena A3 o sustituto que reutiliza Dialogue). `options.intro=true` inicia MvpStoryEvent tras entrar al mapa. `choose_slot(overwrite=false)` devuelve 1..8 o 0 al cancelar; antes de sobrescribir pregunta. Falta de pantallas de título/pausa activa flujo provisional en src/main, no se salta la selección de ranura. Entrada de nombres provisional cede a cualquier pantalla A3 conectada a Cutscene.name_requested.

### Mapas y fundidos

```gdscript
SceneManager.change_map(map_id, spawn_id := &"default", facing := Vector2i.ZERO, fade := true) -> void
SceneManager.change_map_at(map_id, tile: Vector2i, facing := Vector2i.ZERO, fade := true) -> void
SceneManager.map_exists(map_id) -> bool
SceneManager.list_maps() -> Array[StringName]
SceneManager.fade_out(duration := 0.25, color := Color.BLACK) -> void
SceneManager.fade_in(duration := 0.25) -> void
SceneManager.current_map: MapRoot
SceneManager.player: Player
SceneManager.is_busy() -> bool                       # cambiando de mapa o en combate
```

`facing = Vector2i.ZERO` mantiene la dirección del jugador. Si el mapa define `bgm`, se llama a `AudioManager.play_bgm()`.

### Combate

```gdscript
var outcome: StringName = await SceneManager.start_battle(setup)
# outcome ∈ SceneManager.OUTCOME_WIN (&"win"), OUTCOME_LOSE (&"lose"),
#           OUTCOME_RUN (&"run"), OUTCOME_CAUGHT (&"caught")
```

1. Bloquea el input (`&"battle"`), emite `battle_started` y funde a negro.
2. Instancia `res://src/battle/scene/battle_scene.tscn` (Agente 3) en la capa Battle, oculta y congela el mundo, y funde de entrada.
3. `await scene.run(setup)` → **la BattleScene debe tener `func run(setup) -> StringName` (corrutina)** que devuelve un `OUTCOME_*` cuando el combate termina.
4. Funde a negro, libera la escena y emite `battle_ended(outcome)`.
5. Si `outcome == OUTCOME_LOSE` y `setup.can_lose` es `false`: el equipo se cura (`GameState.party.heal_all()` si existe) y el jugador aparece en `healing_map`/`healing_spawn`. La pérdida de dinero y los mensajes de derrota los decide el motor o la BattleScene.

Mientras no exista la BattleScene, se usa un sustituto (`src/main/battle_placeholder.gd`) con botones Ganar/Perder/Huir/Capturar. `setup` se pasa tal cual: lo que necesita SceneManager es que tenga `can_lose: bool` (también acepta un `Dictionary` con `"can_lose"`, útil en el Debug).

### Menús (pila en la capa UI)

```gdscript
SceneManager.push_menu(menu: Node) -> void    # lo añade a UI y bloquea el input (&"menu")
SceneManager.pop_menu(menu: Node = null) -> void   # cierra ese menú (por defecto, el de arriba)
SceneManager.top_menu() -> Node
SceneManager.is_menu_open() -> bool
SceneManager.close_all_menus() -> void
SceneManager.open_pause_menu() -> void        # instancia res://src/ui/pause_menu/pause_menu.tscn
```

- Un menú se cierra a sí mismo con `SceneManager.pop_menu(self)`; no hagas `queue_free()` directamente.
- Si el menú que queda arriba tiene `menu_resumed()`, se le llama (para recuperar el foco).
- Si un menú procesa input en `_unhandled_input`, debe comprobar `SceneManager.top_menu() == self`.

### Escenas de otros agentes que usa SceneManager

| Constante | Ruta | Dueño | Contrato |
|-----------|------|-------|----------|
| `TITLE_SCENE` | `res://src/ui/title/title_screen.tscn` | Agente 3 | Se añade a la capa UI. Llama a `SceneManager.start_new_game()` o `SceneManager.continue_game(slot)` |
| `PAUSE_MENU_SCENE` | `res://src/ui/pause_menu/pause_menu.tscn` | Agente 3 | Menú de la pila (ver arriba) |
| `BATTLE_SCENE` | `res://src/battle/scene/battle_scene.tscn` | Agente 3 | `run(setup) -> StringName` |
| `PLAYER_SCENE` | `res://src/overworld/player/player.tscn` | Agente 1 | Ver sección 5 |

Si preferís otras rutas, pedidlo y se cambian las constantes.

---

## 5. Mapas (Agente 1)

### Escena de mapa

Raíz `Node2D` con `src/overworld/map_root.gd` (`class_name MapRoot`) y `@export var data: MapData`:

```
<Mapa> (MapRoot)
├── Ground (TileMapLayer)     # suelo: hierba, caminos, hierba alta, agua, adoquines
├── Decor (TileMapLayer)      # lo plano encima del suelo: bosque, flores, bordillos, mesetas, carteles
├── Entities (Node2D, y_sort_enabled)   # jugador, NPCs, objetos
│   └── Objects (TileMapLayer, y_sort_enabled)   # casas y árboles grandes: se ordenan con los personajes
├── Above (TileMapLayer, z_index 10)    # lo que siempre tapa al jugador
├── Warps (Node2D)
├── Spawns (Node2D)           # un Marker2D por spawn_id; "default" obligatorio
└── Triggers (Node2D)
```

```gdscript
MapRoot.get_map_id() -> StringName
MapRoot.get_display_name() -> String
MapRoot.get_ground() -> TileMapLayer
MapRoot.get_entities() -> Node2D
MapRoot.get_spawn(spawn_id) -> Node2D
MapRoot.get_bounds() -> Rect2i                 # en píxeles, según Ground
MapRoot.id_from_path(path) / MapRoot.path_from_id(map_id)   # estáticas
```

`MapData` (`src/overworld/map_data.gd`): `id`, `display_name`, `bgm` (id para AudioManager), `outdoor`, `weather`, `encounter_table` (id de `data/encounters/<id>.json`), `encounter_rate` (0 = por defecto), `battle_background`, `region_map_position`, `can_fly_from`, `can_bike`, `healing_spot`, `fixed_camera` y `followers_allowed` (el Pokémon que te sigue sale en este mapa; `true`).

```gdscript
MapRoot.get_layer(name) -> TileMapLayer
MapRoot.tile_custom_data(tile, key, default = null) -> Variant   # Decor → Entities/Objects → Ground; el primer valor no vacío
MapRoot.terrain_at(tile) -> String
MapRoot.is_encounter_tile(tile) -> bool
MapRoot.get_warps() -> Array[Warp] / MapRoot.warp_at(tile) -> Warp
```

### TileSet

Todos los TileSets del juego tienen estas capas. El de exteriores es `assets/tilesets/exterior/exterior.tres` (casillas de 32 px; qué hay en cada atlas: `ExteriorTiles`, en `exterior_tiles.gd`; cómo se monta: README):

- Física 0 → capa `paredes`; física 1 → capa `agua`.
- Custom data: `terrain` (`String`: `grass`, `tall_grass`, `path`, `sand`, `stone`, `water`, `tree`, `house`, `fence`, `hedge`, `cliff`, `stairs`, `flowers`, `obstacle`, `ledge_down`/`ledge_left`/`ledge_right`, `counter`...), `encounter` (`bool`) y `footstep_sound` (`String`).
- Terrenos de Godot (conjunto 0, esquinas y lados, 47 casillas cada uno): 0 **hierba alta** y 1 **camino**. En el editor se pintan con la herramienta de terrenos; por código, `set_cells_terrain_connect()`.
- Animadas: flores rojas y blancas (4 cuadros) y brillos del agua (2 cuadros), en la fuente `animados`.
- **Objetos grandes** (fuentes `casas` y `arboles`; lista en `objetos.json`): una sola casilla grande que se pone en `Entities/Objects` en su casilla **de abajo a la izquierda**. Solo chocan en su base (`footprint`); la puerta de las casas se puede pisar (para el Warp).
- **Bordillos** (`ledge_<dirección>`): chocan, pero el jugador los salta 2 casillas en esa dirección si la de llegada está libre.

### Entidades del mapa

Van dentro de `Entities`. Jerarquía de clases (todas `@tool`: **las clases hijas también deben ser `@tool`** y llamar a `super()` en `_ready()`, y su lógica de juego debe ir protegida con `if Engine.is_editor_hint(): return`):

```
MapEntity (src/overworld/map_entity.gd)       # algo que se examina con accept
├── Character (src/overworld/character.gd)    # se mueve por casillas
│   ├── Player (src/overworld/player/player.tscn)
│   ├── NPC (src/overworld/npc/npc.tscn)      # base de TrainerNPC (Agente 3)
│   └── Follower (src/overworld/follower/follower.tscn)   # Pokémon que te sigue
├── ItemBall (src/overworld/item_ball/item_ball.tscn)
└── MapSign (src/overworld/sign/sign.tscn)
Warp (src/overworld/warp/warp.gd)             # va en Warps, no en Entities
```

**MapEntity**

```gdscript
@export var visible_if_flag: StringName   # solo está si la flag está activa
@export var hidden_if_flag: StringName    # desaparece si la flag está activa
func interact(player: Player) -> void     # virtual; puede ser corrutina (el jugador espera)
func tile_position() -> Vector2i
func is_present() -> bool
func get_map() -> MapRoot
```

- Se coloca sola en el centro de su casilla.
- Para bloquear el paso y que se pueda examinar, lleva un `StaticBody2D` en la capa `entidades` (2). Si no bloquea (objetos ocultos, disparadores), un `Area2D` en la capa `disparadores` (3).
- El jugador busca con `accept` en la casilla de delante. Si delante hay un tile con `terrain = "counter"`, busca en la siguiente (para hablar por encima de un mostrador).

**Character** (escena: `Sprite` con `CharacterSprite`, `Body` y `RayCast`)

```gdscript
@export var sprite_sheet: Texture2D          # 4 columnas × 4 filas (ver "Spritesheets")
@export var run_sprite_sheet: Texture2D      # opcional: hoja para correr
@export var initial_facing: Character.Direction   # DOWN, LEFT, RIGHT, UP
var facing: Vector2i
var moving: bool
signal step_finished(tile: Vector2i)
signal step_started(from: Vector2i, to: Vector2i, duration: float)   # al empezar un paso o un salto
func face(dir: Vector2i) -> void
func face_towards(target: Node2D) -> void
func can_step(dir: Vector2i) -> bool
func step(dir, duration := Character.WALK_TIME, ignore_collisions := false, running := false) -> bool   # corrutina
func jump(dir, tiles := 2) -> void                     # corrutina; salto de bordillo (con polvo al caer)
func is_tile_free(tile) -> bool                        # sin pared, agua ni entidad (física)
func walk(path: Array[Vector2i], duration := WALK_TIME, ignore_collisions := false) -> void   # corrutina
func bump(dir, duration := WALK_TIME) -> void          # andar en el sitio
func place_at(tile: Vector2i, dir := Vector2i.ZERO) -> void
func show_emote(text := "!", duration := 0.6) -> void  # corrutina; "!" con el sprite del pack 05
```

`WALK_TIME` = 0,25 s y `RUN_TIME` = 0,125 s por casilla. Al moverse, el cuerpo se adelanta a la casilla de destino para reservarla. En hierba alta (`terrain = "tall_grass"`) la hierba se mueve al pisarla y los pies se hunden (`CharacterSprite.bush_depth`, como Essentials).

**Follower** (`src/overworld/follower/follower.tscn`): `species`, `shiny` y `leader_path` (para los de los NPCs). Hoja: `assets/sprites/pokemon/followers/<species>.png` o `followers_shiny/` (Agente 2); si no hay, no se ve. `follow(character)`, `appear()` (brillo y SE `shiny` si es shiny). Va a la casilla que deja su líder, con su misma velocidad (también en los saltos), se mueve aunque esté quieto y no choca con nadie. El del jugador lo crea SceneManager al colocarlo (`SceneManager.player_follower`): el primer Pokémon del equipo que pueda luchar, si `data/world.json` → `followers.enabled` y el mapa lo permite.

**Player** (`SceneManager.player`)

- Toque corto en otra dirección = solo girar. Si se mantiene, anda y encadena casillas sin parones. Con `run`, corre. Contra una pared anda en el sitio y suena `bump`.
- Tras cada paso: warp (si lo hay) → `EventBus.player_stepped(tile)` → disparador → encuentro salvaje (si nadie ha bloqueado el input). Delante de un bordillo en su dirección, salta (SE `jump`).
- Con `run`, corre con la hoja de correr (`player_<sexo>_run.png`).
- `menu` → `SceneManager.open_pause_menu()`; `accept` → interacción. Durante la interacción el input está bloqueado con `&"interact"`.
- Tras cualquier bloqueo espera un frame antes de volver a leer `accept`, así la pulsación que cierra un diálogo o un menú no vuelve a interactuar.
- `refresh_appearance()` usa el spritesheet según `GameState.player_gender`. `setup_camera(map)` ajusta la cámara (la llama SceneManager).
- `find_entity_at(tile) -> MapEntity`.

**NPC**

```gdscript
@export var display_name: String          # nombre en el cuadro de diálogo
@export_multiline var lines: PackedStringArray
@export var turn_to_player := true
@export var wander := false / wander_radius := 2 / wander_interval := Vector2(1.5, 4.0)
var home_tile: Vector2i
var talking: bool
func _on_interact(player: Player) -> void   # virtual: por defecto dice `lines`
```

Para un NPC con comportamiento propio: script `@tool` que hereda de `NPC` y sobrescribe `_on_interact()` (ejemplo: `maps/test/test_battle_npc.gd`).

**ItemBall**: `item_id: StringName`, `quantity: int`, `hidden_item: bool`. Todas las colocaciones están en `data/item_placements.json` (`{placement_id: item_id}`, lo lee el randomizer con `DataDB.item_placements()`): se regenera con `godot --headless --path . -s res://maps/_tools/build_item_placements.gd` al tocar objetos del suelo (`ItemPlacements.scan()`; un test de `tests/mundo/` avisa si está desactualizado). Su **id de colocación** es `<map_id>/<nombre del nodo>` (`placement_id()`): por la regla R.2, el objeto que da es `DataDB.placed_item(placement_id, item_id)` si DataDB lo tiene (en RandomLocke puede ser otro) y, si no, `item_id`. Al cogerlo activa `item_taken:<map_id>:<nombre del nodo>`, llama a `GameState.bag.add(objeto, quantity)` si la mochila existe, suena el ME `item` y muestra "¡{player} ha encontrado {item}!" con el nombre (o el plural) de `DataDB.item()`.

**MapSign**: `lines`, `only_from_below := true` y `show_sprite` (la escena lo trae a `false`: el cartel se dibuja con el TileSet).

**Warp**: `target_map`, `target_spawn` (`&"default"`), `arrival_facing` (`KEEP`, `DOWN`, `LEFT`, `RIGHT` o `UP`), `size: Vector2i` (casillas desde la suya hacia la derecha y abajo) y `sound` (SE, por defecto `&"door"`). Se activa al pisarlo. En el editor se dibuja como un rectángulo azul.

### Corrutinas y cambios de mapa

Un nodo del mapa (NPC, cartel, Warp...) **se libera al cambiar de mapa** y sus corrutinas en marcha se cortan. Por eso:

- Lo que deba seguir tras un cambio de mapa no puede vivir en un nodo del mapa: los warps los ejecuta el jugador y las cinemáticas largas (Fase 13) irán en un nodo persistente.
- Si un NPC lanza un combate que el jugador pierde (y no se puede perder), el jugador aparece en el Centro Pokémon y la corrutina del NPC termina ahí: lo que hubiera después del combate no se ejecuta. El jugador recupera el control solo.

### Spritesheets de personajes

`assets/sprites/characters/<id>.png`: **4 columnas** (quieto, paso A, quieto, paso B) × **4 filas** (abajo, izquierda, derecha, arriba), cuadros de **64×64** (pack 05, tal cual) y los pies en el borde inferior de la casilla. Hay: `player_male`/`player_female` (+ `_run`; provisionales: Ethan y Lyra), `rival`, `professor`, `mom`, `nurse`, `clerk`, `trainer` y vecinos `npc_*` (`youngster`, `lass`, `fisherman`, `kimono_girl`, `old_man`, `old_woman`, `man`, `woman`, `boy`, `girl`). `objects.png` (4×4 cuadros de 32: la columna 0 es la Poké Ball del suelo) y `effects/` (`exclamation`, `grass_rustle`, `jump_dust`, `shiny_sparkles`). Se copian con `import_characters.gd`.

### Encuentros salvajes

- Solo en casillas con `encounter = true`, en mapas con `data.encounter_table` y si el equipo tiene algún Pokémon que pueda luchar.
- Probabilidad por paso: `data.encounter_rate` del mapa si es > 0; si no, `land_rate` (%) de la tabla; si no, `data/world.json` → `encounters.step_chance` (0,1).
- Tabla `DataDB.encounter_table(<encounter_table>)` (= `data/encounters/<id>.json`, formato del §9.7; en RandomLocke, la parcheada). Cada sección es una lista o un diccionario por momento del día; si falta el momento, se usa `day`.
- Repelente: la var `repel_steps` de GameState (pasos que quedan). Mientras dure, no salen Pokémon de nivel menor que `GameState.party.first_able_level()`. Al gastarse emite `EventBus.repel_wore_off`. El objeto que la activa es cosa del Agente 3.
- El combate se crea con `BattleSetup.wild(species, level)` si esa clase existe (Agente 2). Si no, con `{"kind": "wild", "species", "level", "can_lose": false}`.
- `Debug.encounters_disabled` los desactiva. API: `WildEncounters.roll(map, tile, kind := &"land")`, `pick(table_id, kind, period)`, `pick_from(table, kind, period)`, `slots(table, kind, period)`, `step_chance(map, table, kind)` y `make_setup(wild)`; `WildEncounters.rng` es su `RandomNumberGenerator`.

---

## 6. Clock (Agente 1)

Autoload `Clock` (`src/autoload/clock.gd`). De momento usa el reloj del sistema (modo `real` de `data/world.json`).

```gdscript
Clock.now() -> Dictionary      # {hour, minute, weekday}; weekday 0 = domingo
Clock.hour() -> int / Clock.minute() -> int / Clock.weekday() -> int
Clock.period() -> StringName   # &"morning", &"day", &"evening" o &"night" (data/world.json → clock.periods)
Clock.is_night() -> bool
```

---

## 7. Debug (Agente 1)

Autoload `Debug` (`src/autoload/debug.gd`). Solo hace algo en builds de debug (`OS.is_debug_build()`). F9 lo abre y lo cierra.

```gdscript
Debug.noclip: bool                 # el jugador atraviesa paredes
Debug.encounters_disabled: bool    # sin encuentros salvajes
Debug.register_command(command: String, callable: Callable, help := "", button_label := "") -> void
Debug.run_command(line: String) -> String
```

- `callable` recibe `args: PackedStringArray` y devuelve el texto a mostrar (`String`).
- Con `button_label`, además aparece como botón en la pestaña "Trucos".
- Se puede llamar desde el `_ready` de cualquier autoload o nodo. Cada agente registra **sus** comandos desde su código (por ejemplo, Agente 2: `givepkmn <especie> <nivel>` y `heal`; Agente 3: `giveitem <id> [n]`).
- Comandos de serie: `help`, `tp`, `flag`, `var`, `money`, `hour`, `noclip`, `encounters`, `save`, `load`, `slots`, `battle` y `title`.

---

## 7b. Cinemáticas y eventos (Agente 1)

Fase 13.1. Un evento es **un guion que se lee de arriba abajo con `await`**.

### StoryEvent (`src/events/story_event.gd`)

```gdscript
extends StoryEvent      # tu evento: src/events/<zona>/<nombre>.gd

func run() -> void:     # corrutina
	var rival := entity("Rival") as NPC
	await Cutscene.emote(rival, "!")
	await Cutscene.approach(rival, player)
	await Dialogue.say("¡{player}! ¡Espera!", rival)
	var outcome := await Cutscene.battle_trainer(&"rival_lab_%d" % GameState.var_int(&"starter"), {"can_lose": true})
	GameState.set_flag(&"rival_intro_done")
```

- Campos: `source` (quien lo lanzó; puede haberse liberado), `params` (los `event_params` de quien lo lanza), `map`, `player`.
- Métodos: `param(key, default)`, `entity(nombre_del_nodo) -> MapEntity` (en `Entities` del mapa actual) y `source_entity()`.
- **Se ejecuta dentro del autoload `Cutscene`**, así que sigue vivo aunque cambie de mapa (a diferencia de una corrutina de un nodo del mapa, §5).
- **Regla R.2**: nada de especies, objetos ni equipos escritos a mano. Se piden por id a `DataDB` o llegan en `params`.

### Cutscene (autoload)

```gdscript
await Cutscene.play(event: GDScript | StoryEvent, source: Node = null, params := {}, done_flag := &"")
Cutscene.current: StoryEvent / Cutscene.is_running() -> bool
signal event_started(event) / event_finished(event)
Cutscene.lock_player() / unlock_player()          # play() ya bloquea (&"cutscene") mientras dura
await Cutscene.wait(seconds)
await Cutscene.walk(entity: Character, path: Array[Vector2i], running := false, ignore_collisions := false)
await Cutscene.walk_to(entity, tile, running := false)
await Cutscene.approach(entity, target: Node2D, running := false)   # hasta quedarse delante y mirarle
Cutscene.face(entity, dir) / face_each_other(a, b)
await Cutscene.emote(entity, text := "!", duration := 0.6)
Cutscene.show_entity(entity) / hide_entity(entity)  # mientras dure el mapa; permanente = flags
Cutscene.path_between(from, to) -> Array[Vector2i]  # = Grid.path_between()
await Cutscene.fade_out() / fade_in()
Cutscene.music(id, fade := 0.5) / sfx(id) / await jingle(id)
await Cutscene.shake(strength := 3.0, duration := 0.3)
await Cutscene.camera_pan(tile, duration := 0.6) / camera_reset(duration := 0.4)
await Cutscene.teleport(map_id, spawn_id := &"default", facing := Vector2i.ZERO)
Cutscene.heal_party()
await Cutscene.give_item(item_id, quantity := 1, announce := true) -> bool      # a la mochila + mensaje
await Cutscene.give_pokemon(pokemon, announce := true) -> String              # "party", "pc" o ""
await Cutscene.battle_trainer(trainer_id, options := {}) -> StringName       # si ganas: trainer_defeated:<id>
await Cutscene.battle_wild(species_or_pokemon, level := 5, options := {}) -> StringName
```

`give_pokemon()` rellena los datos de captura (`original_trainer`, `trainer_id`, `met_*`) y lo apunta en la Pokédex.

### Quién lanza los eventos

| Quién | Cómo |
|-------|------|
| **NPC** | Exports `event: GDScript` y `event_params: Dictionary`. Si tiene evento, al hablarle se ejecuta en vez de sus `lines` |
| **Trigger** (`src/overworld/trigger/trigger.gd`, dentro de `Triggers`) | `event`, `event_params`, `mode` (`STEP` al pisarlo; `ON_ENTER` al terminar de entrar en el mapa), `size`, `required_flag`, `blocked_by_flag` y `once_flag` (se activa al terminar; así no se repite). En el editor se ve como un rectángulo naranja |
| **StarterBall** (`src/overworld/starter_ball/starter_ball.tscn`) | Poké Ball del inicial: `starter_slot` (`starter_1`..`3`) y `starter_index` (1–3). Ya trae `hidden_if_flag = starter_chosen` |
| Cualquier código | `await Cutscene.play(MiEvento, self, {...})` |

`MapRoot.get_triggers()`, `trigger_at(tile)` (solo `STEP` y que se puedan disparar) y `enter_triggers()`.

### Eventos comunes (`src/events/common/`)

| Evento | `params` | Qué hace |
|--------|----------|----------|
| `heal_party_event.gd` | `spawn` (spawn delante del mostrador; `"default"`) | Enfermera: pregunta, jingle `heal`, cura al equipo y fija `healing_map`/`healing_spawn` |
| `open_shop_event.gd` | `shop_id` | Dependiente: abre `ShopScreen.open(shop_id)` (Agente 3) |
| `choose_starter_event.gd` | `slot`, `index` | Pregunta "¿Eliges a X?" con la especie de `DataDB.starter_spec(slot)`, lo da (nivel del dato o `world.json` → `new_game.starter_level`), var `starter` = `index` y flag `starter_chosen` |

---

### Guion del MVP y teclado de identidad

`MvpStoryEvent` (`src/events/mvp/`) ejecuta las etapas `intro`, `bedroom`, `laboratory`, `rival`, `rewards` y el despachador `professor` mediante `event_params.stage`. Los destinos/equipos/recompensas proceden de `data/world.json.mvp_story` y DataDB. Flags idempotentes en docs/flags.md; montaje provisional y recorrido en docs/mapas/pruebas_mvp.md. Tutorial rival: `can_lose=true`, contexto `tutorial=true`, cura tras victoria/derrota y avanza sin muerte Locke.

Teclado A3: `Cutscene.request_name(kind: StringName, initial := "") -> String` emite `name_requested(kind, initial)`; UI responde con `Cutscene.submit_name(kind, value) -> bool`. `kind` = player/rival; valor vacío/campo ajeno no completa. La sala suministra explícitamente POR DEFINIR; el flujo definitivo espera nombres reales. `name_submitted` es señal interna de respuesta. Los disparadores ON_ENTER se ejecutan después de la cinemática que cambió de mapa para evitar espera circular.

---

## 7c. Integración Locke del mundo (Agente 1)

`GameState.locke: WorldLocke` existe solo en RandomLocke. Conserva `rules: LockeRules` y `pending` (capturas sin mote). `GameState.to_dict()` sincroniza `randomlocke.snapshot` y `pending_captures`; al cargar restaura familias, encuentros, muertes y estados sin regenerar. Los campos anteriores `zones`, `deaths` y `status` siguen actualizados. SAVE_VERSION 2 migra v1 conservando ROM, zonas y contadores antiguos (`legacy_death_count`), sin fabricar lápidas ni permisos para encuentros ya gastados.

- `MapData.zone_id` / `MapRoot.get_zone_id()`: ID común entre plantas; prioridad export → `encounter_table.zone_id` → ID del mapa. Los mapas reales deben declarar su zona común.
- `SceneManager.start_battle(setup, context := {})` / `prepare_battle(setup, context := {})`: `context` admite `zone_id`, `source` (`wild`/`static`), `tutorial`. Registra el encuentro antes de que BattleScene reciba acciones. Devuelve `LockeBattleDriver` cuando hay reglas. `can_lose` no excluye automáticamente las reglas: el combate de iniciación usa `tutorial: true` expresamente.
- `LockeBattleDriver` envuelve `EngineDriver`, implementa la API completa de BattleDriver y deniega Balls del encuentro no elegible antes de gastar objeto/turno. Observa `pokemon_died`, conserva el contexto y retira los muertos al terminar (sin desplazar los índices del motor durante el combate). `finish()` es idempotente.
- `WorldLocke.begin(pokemon, zone, source := "wild")`, `can_catch(encounter)`, `resolve(encounter, outcome)`, `receive(pokemon, encounter := {}, starter := false) -> String` (`party`/`pc`/`pending`/vacío), `complete_capture(token, nickname) -> String`, `death(pokemon, context)`, `remove_dead()`, `check_game_over()` y `sync()`.
- `Cutscene.give_pokemon(pokemon, announce := true, source := "gift")` registra regalos; `source = "starter"` registra la línea poseída sin gastar zona. Si se exige mote, la incorporación queda pendiente; un mote vacío no se acepta. No se inventa un nombre para pasar la regla.
- Nuevas señales EventBus: `locke_state_changed`, `locke_nickname_requested(token: String, pokemon: Dictionary)`, `locke_game_over(snapshot: Dictionary)`. UI A3 escucha/consulta pendientes restaurados y llama `GameState.locke.complete_capture(token, nombre)`; el control está bloqueado con `locke_nickname` hasta completar los pendientes. El inicial activa `starter_chosen` al incorporarse.
- Los muertos salen de party/PC utilizable y quedan completos en `snapshot.cemetery`; curar y derrota filtran muertos antes de operar. Un superviviente en PC evita game over y puede pasar al equipo al reaparecer. Al terminar, se bloquea el mundo (`locke_finished`) y SceneManager guarda la ranura si ya está asignada. `continue_game()` rechaza una ranura `finished` con `ERR_UNAUTHORIZED`; `SaveManager.load_game()` sigue permitiendo consultar su contenido para Cementerio/resumen.

Las reglas individuales de EXP, modo fijo y límites de objetos pertenecen al motor A2 (petición 23). Este adaptador no añade pantallas ni cambia las clases de combate/UI de otros agentes.

---

## 7d. Identidades de mundo (A1, 2026-10-05)

`world.names`: town, city_2, professor, rival, region, todos POR DEFINIR hasta decisión de Javier. `WorldNames.value(key)` y `WorldNames.resolve(text)`; marcadores `{world:clave}`. NPC, carteles, MvpStoryEvent y MapRoot.get_display_name los resuelven. `{player}` / `{rival}` siguen en Dialogue y se guardan por partida; no se sobrescriben al cambiar las identidades del diseño. Pedido a A3 aplicar resolución también en Dialogue.format_text (petición 34). Recompensa de profesor: world.mvp_story.reward.quantity=5. Reloj real y dinero inicial 3000 ya estaban correctos y se verifican sobre datos reales.


## 7e. Destinos portátiles del MVP (A1)

`world.mvp_locations.profile` y `profiles.{test,real}`: rol → `{map,spawn}`. `MvpLocations.target(role)` resuelve destino activo; `validate(profile)` comprueba escena MapRoot y aparición exacta; `activate(profile)` cambia solo si todo es válido. `new_game_config()` combina los parámetros generales con start/healing del perfil. MvpStoryEvent.travel usa roles bedroom/laboratory; ninguna ruta de mapa está en el guion. Entrega/IDs en docs/mapas/lista.md.

## 7f. Campo, conexiones y viaje (A1)

`MapData.connections: Array[MapConnection]`, `MapRoot.connection_at(tile)`, `SceneManager.cross_connection(conn,tile,facing)->Error`, sin fundido. Valida destino/coordenada antes de descargar origen. MapConnection.matches/arrival trabajan con Rect2i de Ground; offset suma a coordenada paralela.

`FieldActions.available(action,map)`, `FieldObstacle.action/cleared_flag`, `Player.set_transport_mode(walk/bike/surf)->bool`. Herramientas sin ID (world.field.actions) y transporte sin sprite no se activan. La casilla destino de Character queda reservada por el Body **fijo** mientras el sprite recorre el paso, también en salto.

`WorldTravel.destinations()->Array[Dictionary]`, `fly(id)->Error`; destinos configurados/visitados, objeto y can_fly_from. `visited_map:<id>` se guarda como flag. Contrato de pintura/datos pendientes en docs/mapas/mecanicas_campo.md.

## 7g. Correr sin mantener (A1, orden 1b)

`run_toggle` = R / Y; `run` = Shift / B. `GameState.always_run` se guarda como campo aditivo de v2; falta de campo toma world.new_game.always_run=false. `set_always_run(bool)` emite EventBus.always_run_changed solo al cambiar; cargar/reset no anuncian. UI A3: aviso breve, opción y controles (39). `Player.running_requested(held)` invierte temporalmente always_run si se mantiene run. No corre con MapData.can_run=false, interiores pequeños (outdoor=false y fixed_camera) o transporte bike/surf. Se puede alternar durante un paso; el siguiente usa el ajuste nuevo.

## 7h. Entorno y encuentros del mundo (A1)

`WorldAtmosphere` en World: CanvasModulate según world.clock.tints/Clock, interiores blancos; CPUParticles2D solo con textura explícita de world.weather.presets y ambiente por MapData.ambient/AudioManager. NightLight activa PointLight2D con textura de arte en sus active_periods. Sin recurso no genera dibujo. UI/combate están en otros CanvasLayer.

`FieldEncounters.roll/start(map,method,tile)` old_rod/good_rod/super_rod/headbutt/rock_smash por DataDB, herramienta y partido capaz; fishing requiere agua y headbutt árbol. Los rates vienen de tabla/World. FieldEncounterEvent y StaticEncounterEvent: datos por ID/R.2; static_done:<id> solo tras KO/captura, huida permite volver.

`WorldRoamers.release(id,static_id,maps)`: crea desde estático R.2, conserva Pokemon completo, ubicación y estado en GameState.roamers (campo aditivo v2). Cambiar mapa mueve; continuar no. Roll por chance configurada (0 hasta definir contenido); SceneManager resuelve salud/estado tras combate, captured/defeated lo retiran. No se inventan especies/ubicaciones/desbloqueos. Petición 41 para contenido A3.

### Integración posterior de arte (peticiones 38/40)

world.field.transport_sheets contiene bike/surf/fishing de Ethan/Lyra pack 05 entregadas por A4. Player desmonta bici al entrar en mapa prohibido y sale de Surf al tocar tierra; pesca cambia temporalmente de hoja y la restaura. Character genera polvo existente cada 2 pasos corriendo, y salpicadura existente al completar paso en terrain=puddle. El tile puddle espera A4; no se pinta un charco de prueba por código. Errantes respetan Repelente y la desactivación de encuentros; WildEncounters descuenta el paso antes de elegir errante.

### 7i. Arranque RandomLocke (A1, 2026-10-05)

- `RandomlockeJob` (Node): `start(settings: Dictionary, seed: int) -> Error`, señal `finished(rom: RomPatch)`. Copia entrada/configuración en el hilo principal y genera en Thread sin autoloads; al salir espera/join. No aplica la ROM ni inicia partida.
- `SceneManager.start_randomlocke(rom, slot, intro := true) -> Error`: familias, código y settings de la misma ROM, aplicación antes de mapa/intro. `start_new_game` ahora devuelve Error (compatible con consumidores que ignoran resultado). `SaveManager.apply_rom_patch() -> Error` valida DataDB atómicamente; load_game rechaza ROM ausente/errónea y conserva partida anterior. Mantiene ROM v1 válida y no regenera archivos guardados.
- `EventBus.locke_zone_entered(zone_id: String, status: String)` comunica estado actual al cargar mapa/cambiar reglas. Sustituto con Theme en A1 solo si A3 no escucha la señal. `resume_pending_nicknames()` tras continuar; teclado provisional cede a un listener A3 de locke_nickname_requested. Iniciales siguen sin consumir zona.
- `src/main/randomlocke_fallback.gd` usa presets y campos existentes completos, código con settings personalizados y revisión paginada sin spoilers de especies. A3 reemplaza con sus pantallas; no cambia el motor §10.


### 7j. Carga segura y smoke (A1, 2026-10-05)

- `MapLoader.prepare(map_id) -> {error, map, prepare_usec}` valida PackedScene/MapRoot/data.id/Ground antes de entrar al árbol; cache de 16 escenas, sin compartir instancias. El consumidor incorpora o libera map. `spawn_tile` exacto (null si falta), `valid_tile`, `check_spawn`, `check_position(state)`.
- `SceneManager.change_map` y `change_map_at` ahora devuelven Error. Destino inválido conserva mapa/partida/control; no usa fallback. `EventBus.map_load_failed(map_id, error)` para UI. Nueva partida valida destino y aplica ROM atómicamente antes de reset/new_game_started, conservando módulos y bloqueos si falla; continuar usa `SaveManager.peek_state` antes de cargar ROM/estado. Entrada directa con mapa explícito y spawn omitido usa default; entrada de historia usa datos.
- `last_map_load_usec` mide preparación, instanciación, incorporación y colocación, excluyendo fade_out/in intencionados. `maps/_tools/smoke_maps.gd` valida todos los mapas/apariciones/warps y mide ambos tramos; informe JSON en docs/mapas. Tests extended_game recorren guion y BattleScene/EngineDriver reales sin Debug en normal y RandomLocke sobre el perfil test; cierre real v0.1 sigue bloqueado por mapas/aceptación.


## 8. Datos y combate (Agente 2)

Lo marcado **(previsto)** aún no está entregado y puede cambiar hasta entonces (solo se añadirá, no se quitará).

### 8.1 Archivos de datos

| Archivo | Dueño | Qué es |
|---------|-------|--------|
| `data/generated/*.json` | Agente 2 | Datos oficiales generados por `tools/import_data` (ver `tools/README.md`). **No se editan a mano** |
| `data/species_overrides.json` | Agente 2 | Cambios propios sobre las especies. `{"species": {id: {campo: valor}}}`: cada campo sustituye al generado. Con `"base": "<id>"` se crea una especie nueva copiando otra (formas regionales Panchito) |
| `data/regional_dex.json` | Agente 2 | `{"name", "species": [ids en orden]}`. Vacío hasta que Javier decida la Pokédex |
| `data/items_panchito.json` | Agente 3 | Objetos Panchito: `{id: {...}}` con los mismos campos que los estándar (8.3). Se suman a los estándar con `is_panchito = true` |
| `data/trainer_classes.json`, `data/trainers/*.json`, `data/encounters/*.json`, `data/shops.json` | Agente 3 | Formatos en la sección 9. `DataDB` los carga y los devuelve tal cual |

- En todos los JSON, las claves que empiezan por `_` son comentarios y se ignoran.
- `starters.json`, `gifts.json`, `statics.json` y `trades.json` (Agente 3): `{id: especie}` o `{id: {species, level, ...}}` (los campos de una ficha de entrenador, sección 9.6), más `"randomize": false` si no se debe aleatorizar. En `trades.json`, lo que recibe el jugador va en `receive`.
- Parche (`DataDB.apply_patch`): `species` (`{id: {campo: valor}}`), `abilities`, `learnsets` (`{id: [[nivel, movimiento]...]}`), `tm_compat`, `trainers` (se mezcla con el original), `encounters`, `shops` (sustituyen la tabla), `starters`, `gifts`, `statics`, `trades` (especie o campos) e `items` (`{placement_id: objeto}`). Nunca modifica los datos base.
- Enumerados en `snake_case`: tipos (`fire`), objetivos (`all_adjacent_foes`), grupos de crecimiento (`medium_fast`), grupos huevo (`human_like`), estados (`par`, `brn`, `psn`, `tox`, `slp`, `frz`).

### 8.2 DataDB (autoload)

Código: `src/autoload/data_db.gd`. Carga todo en su `_ready()` (es el primer autoload). Si se pide un id que no existe: `push_error` con el id y devuelve `null` (o `{}` en los datos en bruto).

```gdscript
DataDB.is_loaded: bool
DataDB.MAX_LEVEL                     # 100
DataDB.load_all() -> void            # recarga todo (Debug)

# Especies, movimientos, habilidades, naturalezas y objetos (clases tipadas, 8.3)
DataDB.species(id) -> SpeciesData            / has_species(id) / species_ids(include_forms := true)
DataDB.move(id) -> MoveData                  / has_move(id) / move_ids()
DataDB.ability(id) -> AbilityData            / has_ability(id)
DataDB.nature(id) -> NatureData              / nature_ids()
DataDB.item(id) -> ItemData                  / has_item(id) / item_ids()

# Tipos
DataDB.type_ids() -> Array[StringName]       # los 18 tipos
DataDB.type_name(type) -> String             # "Fuego"
DataDB.type_effectiveness(atk_type: StringName, def_types: Array[StringName]) -> float   # 0, 0.25 ... 4
DataDB.type_immune_to(type, condition) -> bool   # fire + brn, electric + par, steel + psn, grass + powder...

# Experiencia (grupos: slow, medium_fast, fast, medium_slow, erratic, fluctuating)
DataDB.exp_for_level(group, level) -> int    # experiencia total al empezar ese nivel
DataDB.level_for_exp(group, exp) -> int

# Learnsets (generación más reciente con datos)
DataDB.learnset(species_id) -> Dictionary    # {gen, level: [[nivel, id]...], machine, tutor, egg}
DataDB.level_up_moves(species_id) -> Array   # [[nivel: int, id: StringName], ...]; nivel 0 = al evolucionar
DataDB.moves_learned_at(species_id, level) -> Array[StringName]
DataDB.default_moves(species_id, level) -> Array[StringName]   # los 4 últimos aprendidos por nivel
DataDB.can_learn(species_id, move_id) -> bool

# Pokédex regional
DataDB.regional_dex() -> Array[StringName]
DataDB.regional_number(species_id) -> int    # 1, 2, 3...; 0 = no está. Las formas usan el de su especie

# Datos del Agente 3, en bruto (Dictionary tal cual está en el JSON)
DataDB.trainer_class(id) / has_trainer_class(id)
DataDB.trainer(id) / has_trainer(id) / trainer_ids()   # todos los data/trainers/*.json unidos (ids únicos)
DataDB.encounter_table(id) / has_encounter_table(id)   # data/encounters/<id>.json
DataDB.shop(id) / has_shop(id) / shop_sell_ratio()     # data/shops.json → shops[id] y sell_ratio

# Regla R.2 (RandomLocke): lo que da o coloca la historia, siempre por id
DataDB.starter(id) -> StringName / starter_spec(id) -> Dictionary / starter_ids()   # data/starters.json (starter_1/2/3)
DataDB.gift(id) -> Dictionary                # data/gifts.json   → ficha para Pokemon.from_spec()
DataDB.static_encounter(id) -> Dictionary    # data/statics.json → ficha para Pokemon.from_spec()
DataDB.trade(id) -> Dictionary               # data/trades.json (tal cual)
DataDB.placed_item(placement_id, default_item) -> StringName   # ItemBall: "<map_id>/<nodo>"
DataDB.item_placements() -> Dictionary       # data/item_placements.json (Agente 1)
DataDB.resolve_markers(text) -> String       # {starter:id} {gift:id} {static:id} {trade:id} {species:id} {item:id}

# Parche de RandomLocke (Fase R.1): todas las consultas de arriba devuelven lo parcheado
DataDB.randomizer_input() -> Dictionary   # snapshot base para RandomizerInput (stage, min_level, max_level, family_id)
DataDB.apply_patch(patch: Dictionary) -> Array[String]   # vacío si se aplicó; si no, errores y el parche activo no cambia
DataDB.clear_patch() / has_patch() / current_patch()
DataDB.tm_compat(species_id) -> Array / tutor_compat(species_id) -> Array
DataDB.tm_move(machine_id) -> StringName / tutor_move(tutor_id) -> StringName
# shiny_odds() usa settings.shiny_denominator del parche activo, si lo hay
signal patch_changed

# Otros
DataDB.meta() -> Dictionary                  # versiones de las fuentes (data/generated/meta.json)
DataDB.rule(key, default) -> Variant         # data/world.json → "pokemon" (ver abajo)
```

**Reglas configurables** (`data/world.json` → `"pokemon"`, del Agente 1). Si falta una, se usa el valor por defecto:

| Clave | Por defecto | Uso |
|-------|-------------|-----|
| `wild_hidden_ability_chance` | `0.0` | Probabilidad (0–1) de habilidad oculta en Pokémon nuevos. **POR DEFINIR (Javier)** |
| `pc_boxes`, `pc_box_size` | `32`, `30` | Cajas del PC |
| `exp_share` | `true` | Repartir Experiencia moderno activo por defecto |

**Shiny** (`data/world.json` → `"shiny"`, Fase 6.7 y DIRECTRICES §8): `{"odds": 4096, "rolls": {"base": 1, "shiny_charm": 3, "masuda": 6, "masuda_shiny_charm": 8}}`. Cada tirada es una comprobación independiente de 1/`odds`. `DataDB.shiny_odds() -> int` y `DataDB.shiny_rolls(kind := &"base") -> int` (con esos valores por defecto si falta la sección).

### 8.3 Clases de datos (`src/pokemon/data/`)

Todas son `RefCounted` de solo lectura y tienen `raw: Dictionary` (la entrada completa del JSON) para los campos sin propiedad propia.

**`SpeciesData`** — una especie **o una forma** (las formas son especies propias: `raichualola`, `charizardmegax`, `meowsticf`...).

| Campo | Tipo | Notas |
|-------|------|-------|
| `id`, `num` | `StringName`, `int` | `num` = número nacional (las formas comparten el de su especie) |
| `name`, `name_en` | `String` | Nombre en español. **Las formas se llaman como su especie** ("Raichu"), como en los juegos |
| `base_species`, `forme`, `form_name` | | Solo en formas: `raichu`, `alola`, "Forma de Alola" |
| `types` | `Array[StringName]` | |
| `base_stats` | `Dictionary[StringName, int]` | `hp`, `atk`, `def`, `spa`, `spd`, `spe` (`SpeciesData.STATS`) |
| `fixed_max_hp` | `int` | Shedinja = 1; 0 = fórmula normal |
| `abilities` | `Dictionary[String, StringName]` | Ranuras `"0"`, `"1"`, `"H"` (oculta), `"S"` |
| `gender_ratio` | `float` | Probabilidad de ser hembra; `-1` = sin sexo (`is_genderless()`) |
| `catch_rate`, `base_exp`, `exp_group`, `ev_yield` | | `ev_yield` solo con las estadísticas que dan EVs |
| `egg_groups`, `egg_cycles`, `hatch_steps`, `base_friendship` | | |
| `height`, `weight` (m, kg), `color`, `genus`, `generation`, `dex_entry` | | `genus` = "Pokémon Ratón" |
| `prevo`, `evolutions` | | Ver "Evoluciones" |
| `forms`, `is_mega`, `is_gmax`, `required_item` | | |
| `is_legendary`, `is_mythical`, `is_baby`, `tags`, `nonstandard` | | `nonstandard` = `past`, `future`, `lgpe`... (no está en los juegos actuales) |

Métodos: `base_stat(stat)`, `is_genderless()`, `is_form()`, `root_species()` (la especie sin forma), `has_type(t)`, `ability(slot)`, `has_hidden_ability()`.

**Evoluciones** (`SpeciesData.evolutions`, un `Dictionary` por entrada): `{to, method, ...condiciones}`.

| `method` | Condiciones | Cuándo se comprueba |
|----------|-------------|---------------------|
| `level` | `level` | Al subir de nivel |
| `friendship` | `min_friendship` (160) | Al subir de nivel |
| `level_hold` | `item` (equipado; se gasta al evolucionar) | Al subir de nivel |
| `level_move` | `move` (lo conoce) | Al subir de nivel |
| `level_extra` | Ver campos extra | Al subir de nivel |
| `item` | `item` (se usa sobre el Pokémon) | Al usar el objeto |
| `shed` | — | Shedinja: lo crea quien hace evolucionar a Nincada (hueco en el equipo + una Poké Ball) |
| `trade`, `other` | — | Nunca (las de intercambio están sustituidas en `species_overrides.json`) |

Campos extra opcionales en cualquier método: `time` (`day` = periodos `morning` y `day` de `Clock`; `night`; `dusk` = `evening`), `gender` (`male`/`female`), `stat_relation` (`atk_gt_def`, `atk_lt_def`, `atk_eq_def`), `party_species`, `party_type`, `known_move_type`, `weather` (`rain`), `location`, `region` (evolución regional de otro juego: **no se aplica**), `condition` (texto original de Showdown) y `replaces: "trade"` (sustituida).

**`MoveData`**: `id`, `num`, `name`, `type`, `category` (`MoveData.Category.PHYSICAL/SPECIAL/STATUS`), `power`, `accuracy` (**0 = no falla nunca**), `pp`, `priority`, `target`, `flags: Dictionary[StringName, bool]` (`contact`, `sound`, `punch`, `bite`, `bullet`, `powder`, `protect`...), `secondaries: Array[Dictionary]` (`{chance, status?, volatile_status?, boosts?, self_boosts?}`), `boosts`, `self_boosts`, `status`, `volatile_status`, `drain`/`recoil`/`heal` (`[numerador, denominador]` o vacío), `multihit_min`/`multihit_max`, `crit_ratio`, `ohko`, `fixed_damage`, `level_damage`, `selfdestruct`, `needs_script` (necesita código propio, Fase 9.2), `description`. Métodos: `has_flag(f)`, `is_status()`, `is_damaging()`, `max_pp(pp_ups)`, `targets_user()`.

**`ItemData`**: `id`, `name`, `name_plural` (= `name` si no se indica), `pocket` (`items`, `medicine`, `pokeballs`, `machines`, `berries`, `mail`, `battle`, `key`; el Agente 3 puede añadir `panchito`), `category`, `price`, `fling_power`, `flags`, `description`, `field_use` / `battle_use` (`""`, `on_pokemon`, `on_active`, `no_target`), `effect`, `effect_params`, `is_berry`, `is_pokeball`, `held_needs_script`, `is_panchito`. Métodos: `sell_price()` (mitad del precio), `is_ball()`, `is_key_item()`, `usable_in_field()`, `usable_in_battle()`, `param(key, default)`.

Efectos de uso (`effect` → `effect_params`), iguales para objetos estándar y Panchito:

| `effect` | `effect_params` | Ejemplos |
|----------|-----------------|----------|
| `heal_hp` | `amount` (PS) o `fraction` (de los PS máximos) | Poción (20), Hiperpoción (120), Poción Máxima (`fraction` 1.0), Baya Aranja |
| `cure_status` | `statuses: [...]`, `confusion: bool` | Antídoto (`psn`, `tox`), Cura Total |
| `heal_and_cure` | `fraction` | Restaurar Todo |
| `revive` | `fraction` | Revivir (0.5), Revivir Máximo (1.0) |
| `restore_pp` | `amount` o `full`, `all_moves` | Éter, Elixir |
| `boost_stat` | `stat`, `stages` | Ataque X (+2) |
| `crit_boost` | `stages` | Directo |
| `ball` | `multiplier` o `guaranteed` o `formula`, + condiciones (`if_types`, `if_first_turn`...) | Super Ball (1.5), Master Ball |
| `flee` | — | Muñeca Poké |
| `repel` | `steps` | Repelente (100) |
| `escape` | — | Cuerda Huida |
| `evolution` | — | Piedras evolutivas |
| `add_evs` | `stat`, `amount` | Proteína |
| `level_up` | `levels` | Caramelo Raro |
| `pp_up` | `max` | Más PP, PP Máximos |
| `exp_boost` | `multiplier` | Huevo Suerte (equipado) |

**`AbilityData`**: `id`, `name`, `description`, `rating`, `needs_script`. **`NatureData`**: `id`, `name`, `plus`, `minus` (vacíos si es neutra), `percent(stat) -> int` (110/100/90).

### 8.4 Pokemon y módulos de GameState (`src/pokemon/`)

**`Pokemon`** (`RefCounted`): un Pokémon concreto.

| Campo | Tipo | Notas |
|-------|------|-------|
| `uid` | `String` | Identificador único |
| `species_id` | `StringName` | Especie o forma (`raichualola`) |
| `nickname` | `String` | Vacío = nombre de la especie (`display_name()`) |
| `level`, `exp` | `int` | `exp` total |
| `ivs`, `evs` | `Dictionary[StringName, int]` | 0–31; 0–252 (510 en total) |
| `nature`, `ability_slot`, `gender`, `shiny` | | `ability_slot`: `"0"`, `"1"`, `"H"`; `gender`: `&"male"`, `&"female"`, `&""` |
| `moves` | `Array[MoveSlot]` | Máx. 4. `MoveSlot`: `id`, `pp`, `pp_ups`, `max_pp()` |
| `current_hp`, `status`, `status_turns` | | `status`: `""` o `par`/`brn`/`psn`/`tox`/`slp`/`frz` |
| `held_item`, `friendship`, `ball` | | |
| `original_trainer`, `trainer_id`, `met_level`, `met_location`, `met_date` | | Los rellena quien lo recibe (captura, regalo...) |
| `pokerus`, `tera_type`, `ribbons` | | |

```gdscript
Pokemon.create(species_id, level, rng: RandomNumberGenerator = null, shiny_rolls := 1) -> Pokemon   # salvaje o regalo
Pokemon.from_spec(spec: Dictionary, rng = null) -> Pokemon   # ficha de data/trainers (party[i]); no tira shiny: solo si "shiny": true
Pokemon.roll_shiny(rng, rolls := 1) -> bool / Pokemon.shiny_chance(rolls := 1) -> float
Pokemon.debug_force_shiny: bool                # Debug: forceshiny on|off
Pokemon.from_dict(d) -> Pokemon / p.to_dict() -> Dictionary / p.clone() -> Pokemon

p.species() -> SpeciesData / p.display_name() -> String / p.types() / p.ability_id()
p.stat(stat) -> int / p.max_hp() -> int / p.stats() -> Dictionary[StringName, int]
p.is_fainted() / p.heal(amount) -> int / p.take_damage(amount) -> int / p.revive(fraction)
p.set_status(status, turns) / p.cure_status() / p.heal_full()        # heal_full = Centro Pokémon
p.exp_at_level_start() / p.exp_at_next_level() / p.exp_to_next_level()
p.gain_exp(amount) -> Array[Dictionary]   # una entrada por nivel: {level, old_stats, new_stats, new_moves}
p.set_level(level) -> Array[Dictionary]
p.add_evs(stat, amount) -> int
p.move_ids() / p.has_move(id) / p.try_learn(id) -> bool / p.replace_move(index, id) / p.forget_move(index)
p.evolve_to(species_id) -> void           # conserva el daño recibido y el mote
```

**`Daycare`** (Fase 14.3, `src/pokemon/daycare.gd`): `deposit` / `withdraw` (dos plazas). `compatible(a, b)`, `egg_percent` (70/50/20) y `egg_species` (la base de la madre, o del que no es Ditto). `walk(pasos, cuerpo_llama)` cuenta doble con Cuerpo Llama y cada 256 pasos tira el porcentaje. `take_egg(masuda := false)` hereda 3 IVs (5 con Lazo Destino), la naturaleza si hay Piedra Eterna, la habilidad de la madre (80 %, u oculta al 60 % si ella la tiene), la Ball de la madre (50/50 si son la misma especie) y los movimientos huevo del padre. `shiny_rolls(masuda)` es 6 o 1: el idioma no está en el Pokémon, lo dice quien llama. `spread_pokerus(party, rng)` contagia al de al lado (1/3). Los bebés que dependen de un incienso quedan pendientes.

**`BalanceSim`** (Fase 20.2, `src/systems/balance_sim.gd`): `simulate(equipo, rival, partidas, semilla, ia_jugador := 4, ia_rival := 1) -> {games, wins, losses, other, win_percent}`. `simulate_trainer(equipo, trainer_id, partidas, semilla)` usa el equipo del entrenador. La herramienta `tools/balance/simulate.gd` lee `data/balance/leaders.json` (`leaders`, `team`): vacío = PENDIENTE JAVIER, no se inventan líderes.

**`MoveLessons`** (Fases 6.2 y 6.3): `relearnable(p)` son los movimientos de nivel que ya no tiene. `teach(p, move, replace_index := -1)` lo aprende (con 4 hace falta el índice a olvidar). `tutor_moves(species)`, `can_tutor`, `use_tutor`. `machine_move(item_id)` sale del texto de la MT cuando identifica un solo movimiento del conjunto (el de `learnset.machine`); `use_machine` lo enseña si la especie es compatible. Las MT 100+ llegaron sin texto: no se inventa su movimiento (**PENDIENTE JAVIER** el número de la 9.ª generación). Dónde se consiguen también es de Javier. `DataDB.tm_move` usa este catálogo y el parche lo sustituye.

**`EvolutionRules`** (estática): `level_up_target(p, context := {}) -> StringName` (al subir de nivel o al acabar un combate) e `item_target(p, item_id, context := {}) -> StringName` (`&""` = no evoluciona). `level_up_evolution(p, context)` devuelve la entrada completa y `evolve(p, evo)` la aplica (y gasta el objeto equipado si era `level_hold`). `special_target(p, context)` es Milcery: `spin: true` y un confite equipado (`strawberrysweet` y los otros seis). El sabor de Alcremie queda **PENDIENTE JAVIER** (los datos solo tienen una especie). `shed_species(from, to)` = Shedinja al evolucionar Nincada. `context`: `{time: Clock.period(), party_species: Array[StringName], party_types: Array[StringName], weather: StringName, location: StringName, spin: bool}`.

**Módulos de GameState** (`Party`, `PCStorage`, `Pokedex`): cumplen la sección 2 (`new()`, `to_dict()`, `from_dict()`).

```gdscript
# Party (máx. 6)
party.members: Array[Pokemon]
party.size() / is_full() / add(p) -> bool / remove_at(i) -> Pokemon / swap(i, j) / move(from, to) / get_at(i) / index_of(p)
party.has_species(id) / species_ids() / types()        # para el contexto de evolución
party.first_able() -> Pokemon / first_able_index() -> int / first_able_level() -> int   # Repelente
party.is_all_fainted() -> bool / able_count() -> int / heal_all() -> void

# PCStorage (cajas × huecos, de las reglas de 8.2)
pc.box_count() / box_size() / get_pokemon(box, slot) -> Pokemon / set_pokemon(box, slot, p)
pc.take(box, slot) -> Pokemon / deposit(p) -> Vector2i   # (-1, -1) si está lleno
pc.move(from_box, from_slot, to_box, to_slot)  # intercambia / release(box, slot) / is_full() / count() / find_uid(uid)
pc.box_name(box) / rename_box(box, name) / box_wallpaper(box) / set_box_wallpaper(box, id) / current_box

# Pokedex (por especie base; las formas se apuntan aparte)
dex.mark_seen(species_id, shiny := false) / mark_caught(species_id) / register(p: Pokemon)   # register = visto + capturado
dex.is_seen(id) / is_caught(id) / is_shiny_seen(id) / forms_seen(id) -> Array[StringName] / caught_species()
dex.seen_count(regional_only := false) / caught_count(regional_only := false)
```

### 8.5 Combate (`src/battle/engine/`, `src/battle/ai/`)

El motor es **lógica pura** (`RefCounted`, sin nodos ni `await`). La BattleScene le manda decisiones y reproduce los eventos que devuelve. Toda la aleatoriedad sale del RNG del combate (`setup.seed`): misma semilla + mismas decisiones = mismo combate.

```gdscript
# Dentro de BattleScene.run(setup) -> StringName
var engine := BattleEngine.new(setup)
var events: Array[BattleEvent] = engine.start()     # presentación hasta la primera decisión
await play(events)
while not engine.is_over():
	var request: BattleRequest = engine.request        # qué tiene que decidir el jugador
	var action: BattleAction = await ask_player(request)
	events = engine.submit(action)                    # resuelve hasta la siguiente decisión o el final
	await play(events)
var result: BattleResult = engine.result
result.apply_to_game_state()                          # dinero, captura (equipo o PC) y Pokédex
return result.outcome                                 # = SceneManager.OUTCOME_*
```

- El motor modifica directamente los `Pokemon` de `setup.player_party` (PS, PP, estado, experiencia, niveles y movimientos aprendidos). Para simular sin tocar el equipo, pasa clones (`Pokemon.clone()`).
- **La BattleScene quita el objeto de la mochila cuando envía una acción `ITEM`** (las Balls también). Antes, `engine.can_use_item(item_id, party_index) -> bool` dice si tiene efecto.
- Los eventos llevan **todo lo necesario para dibujar** (PS antes y después, nombres...), porque cuando se reproducen el motor ya ha resuelto el turno entero. Para los menús (movimientos, equipo) se puede leer el estado del motor durante una `request`: `engine.active(side, slot) -> Battler`, `engine.party(side) -> Array[Pokemon]`.
- Al terminar, las evoluciones pendientes están en `result.pending_evolutions`; la escena de evolución (Agente 3) las reproduce y llama a `Pokemon.evolve_to()`.

**`BattleSetup`**

```gdscript
BattleSetup.wild(pokemon_or_species: Variant, level := 5, options := {}) -> BattleSetup
BattleSetup.trainer(trainer_id: StringName, options := {}) -> BattleSetup
# options: can_lose, can_run, allow_items, exp_enabled, exp_share, locke_rules, tutorial,
#          background, bgm, weather, environment, time_period, battle_style, seed, ai_level, next_ace_level
BattleSetup.trainer_info(trainer_id, player_name := "") -> Dictionary   # entrenador + clase (lo de setup.trainers[i])
setup.fill_from_game_state() / setup.apply_options(options) / setup.is_wild()
```

| Campo | Tipo | Notas |
|-------|------|-------|
| `kind` | `BattleSetup.Kind.WILD` / `TRAINER` | |
| `format` | `BattleSetup.Format.SINGLE` / `DOUBLE` | `DOUBLE` con `options.double`, o si el entrenador trae `"double": true`. Salen los dos primeros que puedan luchar |
| `ally_ai` | `bool` | En dobles, el slot 1 del jugador lo juega la IA (compañero). El slot 0 sigue siendo el jugador |
| `player_party`, `foe_party` | `Array[Pokemon]` | Las fábricas toman el equipo de `GameState.party` |
| `player_name`, `player_trainer_id` | | De `GameState` |
| `trainers` | `Array[Dictionary]` | Rivales (vacío en salvajes): `{id, class, class_name, name, display_name, gender, base_money, ai_level, battle_sprite, battle_bgm, intro_bgm, intro_text, lose_text, win_text, items}`. `display_name` = "Vendedor de Chupachups Manolo", con `{rival}` y `{player}` ya sustituidos |
| `can_lose` | `bool` | `true` = perder no te manda al Centro Pokémon |
| `can_run`, `allow_items`, `exp_enabled`, `exp_share` | `bool` | `can_run` = `true` en salvajes |
| `locke` | `LockeRules` | Reglas de la partida. `null` si no se aplican. El tutorial lo deja en `null` |
| `next_ace_level` | `int` | Nivel del as del siguiente líder (`GameState.randomlocke.next_ace_level`). `0` = sin tope |
| `battle_style` | `StringName` | `&"fixed"` (por defecto, no avisa) o `&"shift"` (avisa y se puede rechazar). Si `locke.battle_mode()` es `"fixed"`, no hay aviso |
| `tutorial` | `bool` | No aplica muerte, tope, modo fijo ni límite de objetos |
| `background`, `bgm` | `StringName` | `bgm`: la del entrenador (`battle_bgm`) o `battle_wild` |
| `weather`, `environment`, `time_period` | `StringName` | `environment`: `grass`, `cave`, `water`... (para algunas Balls) |
| `caught_species`, `dex_caught_count` | | De `GameState.pokedex` (Ball Acopio y captura crítica) |
| `seed` | `int` | 0 = aleatoria (la usada queda en `result.seed`) |

**`BattleRequest`** (`engine.request`): `kind` (`BattleRequest.Kind.ACTION`, `SWITCH` o `LEARN_MOVE`), `side`, `slot`, `party_index`, `move_id` (en `LEARN_MOVE`), `can_run`, `can_switch`, `can_use_items`, `usable_moves: Array[int]` (índices con PP; vacío = solo puede usar Forcejeo), `reason` (en `SWITCH`: vacío = se ha debilitado; `&"uturn"` = Ida y Vuelta / Voltiocambio / Viraje; `&"batonpass"` = Relevo; `&"shift"` = el rival va a sacar otro y se puede rechazar con `switch_to(-1)`).

- **Movimientos Z** (Fase 9.6, opcional): `options.z` o la `zring` en la mochila (`BattleSetup.z_ring`, `info().z`). El Pokémon lleva un cristal (`ItemData.is_z_crystal`). Uno de tipo convierte un movimiento de ese tipo; uno de especie solo el `z_move_from` de su usuario. Una vez por bando y combate. `request().z_moves` son los índices que pueden ser Z y `submit` lee `z: true`. El de daño usa la tabla de potencia (55→100 … 131+→200) o la potencia fija del movimiento Z, no falla, y el evento `zmove` trae `{base, move, move_name}`. El de estado ejecuta el movimiento y, si el dato lo trae, sube características, cura del todo (`heal`) o quita las bajadas (`clearnegativeboost`). El resto de efectos Z de estado queda pendiente. El rival salvaje no los usa. **Agente 3:** botón cuando `z_moves` no está vacío.
- **Megaevolución** (Fase 9.6): el jugador megaevoluciona si `options.mega` es verdadero o si su mochila tiene `megabracelet` o `keystone` (`BattleSetup.mega_bracelet`, `EngineDriver.info().mega`). El Pokémon lleva la Megapiedra de su forma (`ItemData.mega_species`). Rayquaza no lleva piedra: le basta saber el movimiento de `required_move` (Ascenso Draco). Una vez por bando y combate, antes de ordenar el turno, así que la Velocidad nueva cuenta ese mismo turno. `BattleRequest.can_mega` y `EngineDriver.request().can_mega`. La acción de luchar lleva `mega = true` (`EngineDriver.submit` lee `mega` y `target_slot`). Evento `mega`: `{from, species, form_name, ability, hp, max_hp}` y un `message` con `tag = mega`. Al retirarse o al acabar el combate la especie vuelve a la de antes (el equipo no se guarda en forma mega). El rival salvaje no megaevoluciona; el entrenador sí, si su Pokémon lleva la piedra. **Agente 3:** botón de mega cuando `can_mega` y sprite nuevo al evento `mega`.
- **Teratipo** (Fase 9.6, opcional): solo si `options.tera` (`BattleSetup.tera`, `info().tera`): el orbe cargado lo decide quien monte el combate. Una vez por bando y dura todo el combate, también si se retira y vuelve. El tipo es `Pokemon.tera_type` o, si está vacío, su primer tipo. Pasa a ser de un solo tipo. STAB ×2 si ese tipo ya lo tenía; ×1,5 si es nuevo, y los golpes de sus tipos originales siguen a ×1,5. Estelar queda pendiente. `request().can_tera`, `submit` con `tera: true`, evento `tera` (`type`). **Agente 3:** botón y el efecto al evento.
- **Dinamax** (Fase 9.6, opcional): solo si `options.dynamax` (`BattleSetup.dynamax`, `info().dynamax`). La Maximuñequera sola no lo enciende: el combate tiene que permitirlo. Una vez por bando, tres turnos, los PS (actuales y máximos) se doblan y al terminar vuelven a la proporción. Los movimientos pasan a ser el Max del tipo (tabla 40→90 … 150+→150); los de estado son Maxibarrera, que protege como Protección. El efecto extra del Max (clima, campo o un cambio de característica) se aplica. No hay Gigamax. `request().can_dynamax` y `submit` con `dynamax: true`. Eventos `dynamax` (`hp`, `max_hp`, `turns`) y `dynamax_end`. **Agente 3:** botón y el sprite grande al evento.
- **Dobles** (Fase 9.4): `engine.is_double()` / `slot_count()` (1 o 2). `EngineDriver.info().format` es `&"single"` o `&"double"`, e `info().ally_ai`. Cada turno el motor pide **una acción por Pokémon del jugador** que siga en pie (`request.slot` 0 y luego 1); `EngineDriver.request()` incluye `slot`. `BattleAction.fight(move, target_slot)` elige al rival de ese puesto. Si ese rival ya no está, el golpe pasa al otro. `all_adjacent_foes` golpea a los dos rivales y `all_adjacent` también al aliado; con más de un objetivo el daño va ×0,75. `adjacent_ally` golpea al compañero. La IA elige el rival al que más daño hace. El modo Cambio no pregunta en dobles. Pareja de entrenadores: un solo `BattleSetup` con `format = DOUBLE`, los dos en `trainers` y el equipo rival ya junto. **Agente 3:** la escena tiene que dibujar dos Pokémon por bando (`switch_in.slot`) y repetir el menú de acciones por cada `request.slot`.
- Si el Pokémon está atrapado (Giro Fuego...), `can_switch` y `can_run` llegan a `false`.
- Cuando el movimiento del jugador es obligado (segundo turno de Rayo Solar, Golpe, Alboroto, recarga de Hiperrayo), el motor **no pide acción**: resuelve ese turno solo y los eventos llegan en el mismo `submit()`.

| `kind` | Cuándo | Respuestas válidas |
|--------|--------|--------------------|
| `ACTION` | Inicio de turno | `fight`, `switch_to`, `use_item`, `run` |
| `SWITCH` | Se ha debilitado el Pokémon del jugador, `reason` = `uturn` / `batonpass` (cambio a mitad de turno: el menú del equipo no se puede cancelar) o `reason` = `shift` (modo Cambio: se puede quedar) | `switch_to` (o `run` en salvajes, si `can_run`). En `shift`, `switch_to(-1)` no cambia |
| `LEARN_MOVE` | Quiere aprender `move_id` y ya sabe 4 | `learn_move(índice a olvidar)` o `learn_move(-1)` = no aprenderlo |

**`BattleAction`**

```gdscript
BattleAction.fight(move_index: int, target_slot := 0)   # move_index -1 = Forcejeo
BattleAction.switch_to(party_index: int)
BattleAction.use_item(item_id: StringName, party_index := -1, move_index := -1)   # -1 = sin objetivo (Balls); move_index = Éter
BattleAction.run()
BattleAction.learn_move(forget_index: int)              # -1 = no aprenderlo
```

**`BattleEvent`**: `type: StringName`, `side: int` (0 = jugador, 1 = rival; −1 = ninguno), `slot: int` (posición en el campo; 0 en individuales) y `data: Dictionary`. Se reproducen en orden. Los textos vienen ya en español en eventos `message`. Constantes: `BattleEvent.MESSAGE`, `SWITCH_IN`... Atajos: `e.value(key, default)` y `e.text()`.

| `type` | `side`/`slot` | `data` | Qué hace la escena |
|--------|---------------|--------|--------------------|
| `message` | — | `text`, `tag` (solo en los de presentación: `wild_appear`, `challenge`, `send_out`, `recall`, `defeat`) | Muestra el texto. Los que llevan `tag` la escena los puede sustituir por los suyos |
| `switch_in` | quien entra | `party_index, species, form_name, name, level, gender, shiny, hp, max_hp, status, wild` + en el jugador `exp, exp_level_start, exp_next_level` | Lanzar la Ball / aparecer y caja de datos |
| `switch_out` | quien sale | `party_index` | Retirar al Pokémon |
| `move` | usuario | `move, move_name, type, category, target_side, target_slot` | Animación del movimiento |
| `damage` | quien lo recibe | `amount, hp, max_hp, effectiveness, critical, source` | Barra de PS (y sonido según `effectiveness`) |
| `heal` | quien se cura | `amount, hp, max_hp, source` | Barra de PS |
| `miss` | objetivo | — | (opcional) |
| `faint` | debilitado | `party_index` | Grito y desaparición |
| `status` | afectado | `status` (`""` = curado) | Icono de estado en la caja |
| `cant_move` | quien no se mueve | `reason` (`par`, `slp`, `frz`, `flinch`, `confusion`) | Animación del estado |
| `volatile` | afectado | `volatile` (`confusion`), `active` | (opcional) |
| `boost` | afectado | `stat, amount, stage` | Animación de subida o bajada |
| `exp` | 0 / slot o −1 | `party_index, amount, exp, level, exp_level_start, exp_next_level` | Barra de experiencia |
| `level_up` | 0 / slot o −1 | `party_index, level, old_stats, new_stats, hp, max_hp` | Jingle y tabla de estadísticas |
| `move_learned` | 0 | `party_index, move, move_name, forgot` | — |
| `catch` | 1 / slot | `ball, shakes (0–3), caught, critical` (+ `blocked` contra entrenadores) | Lanzar la Ball y sacudidas |
| `item_used` | quien lo usa | `item, item_name, party_index` | — |
| `flee` | 0 | `success` | — |
| `trainer_speech` | 1 | `trainer_index, text` | Entra el entrenador y dice `lose_text` / `win_text` |
| `money` | — | `amount` | — |
| `turn` | — | `turn` | Empieza un turno (opcional) |
| `weather` | — | `weather` (`raindance`, `sunnyday`, `sandstorm`, `snow`; `""` = se acaba) | Clima en pantalla |
| `terrain` | — | `terrain` (`mistyterrain`...; `""` = se acaba) | Campo en pantalla |
| `side_condition` | bando | `condition` (`reflect`, `lightscreen`, `safeguard`, `tailwind`, `stickyweb`, `wish`...), `active` | Indicadores del bando (opcional) |
| `end` | — | `outcome` | Último evento |

- `source` de `damage`/`heal`: `move`, `recoil`, `drain`, `confusion`, `brn`, `psn`, `tox`, `struggle`, `selfdestruct`, `item`.
- `stat` de `boost`: `atk`, `def`, `spa`, `spd`, `spe`, `accuracy`, `evasion`.
- Se pueden añadir tipos nuevos (clima, Mega...) en la Fase 9: la escena debe **ignorar los que no conozca**.

**`BattleResult`** (`engine.result`): `outcome` (`&"win"`, `&"lose"`, `&"run"`, `&"caught"`; constantes `BattleResult.WIN`...), `turns`, `seed`, `money_won`, `caught_pokemon: Pokemon` (o `null`), `seen_species: Array[StringName]`, `items_used: Array[StringName]`, `pending_evolutions: Array[Dictionary]` (`{party_index, uid, to, evolution}`; `EvolutionRules.evolve(p, evolution)` la aplica y gasta el objeto si hace falta). `apply_to_game_state(location := &"")` suma el dinero, apunta la Pokédex, rellena los datos de captura (`original_trainer`, `trainer_id`, `met_*`) y mete el capturado en el equipo o, si está lleno, en el PC; devuelve `{caught_to: "party" | "pc" | "", box, slot}`. La pérdida de dinero al perder y la vuelta al Centro Pokémon son de SceneManager.

**Qué hace el motor (v0.1)** — mecánicas de la 7.ª generación en adelante, con el redondeo de Showdown:
- Daño exacto (los tests comparan las 16 tiradas con el simulador de Showdown 0.11.11), STAB, tabla de tipos, críticos (1/24, 1/8, 1/2, siempre), quemadura y niveles de característica.
- Precisión y evasión; sueño (1–3 turnos), congelación (20 %), parálisis (25 % y mitad de Velocidad), confusión (33 %), retroceso, veneno (1/8), Tóxico (n/16) y quemadura (1/16).
- Efectos "por datos" de la Fase 7.6. Los movimientos con `needs_script` hacen solo su parte de datos (daño, cambios de características, estado o curación) hasta la Fase 9; si no tienen ninguna, fallan ("¡Pero falló!"). El validador los lista.
- Captura (Balls de los datos, captura crítica según `setup.dex_caught_count`), huida, objetos de curación, Balls, Ataque X, Directo y Muñeca Poké, experiencia (también al capturar), EVs, dinero y evoluciones pendientes.
- IA (`BattleAI`): nivel 0 = movimiento al azar; nivel 1 = el que más daño hace (`engine.estimate_damage()`); nivel 2 = evita lo inútil y usa un estado con sentido; nivel 3 = cambia si no puede hacer daño; nivel 4 = puntúa el golpe menos el contraataque. Desde el nivel 3 el reemplazo es el que más daño haría.
- Más API: `engine.rng`, `engine.turn`, `engine.side(i)`, `engine.estimate_damage(user, target, move)`. Textos en `BattleText` (moneda: `BattleText.CURRENCY`).

**Validador** (Fase 4.6): `godot --headless --path . -s res://tools/validate/validate.gd` (o el test `tests/datos/test_validador.gd`). Errores = especies, movimientos, objetos o clases que no existen, evoluciones por intercambio, niveles o pesos no válidos; avisos = sprites e iconos que faltan y movimientos en uso que necesitan script.

**Debug** (Agente 2): `givepkmn <especie> [nivel] [shiny]`, `forceshiny [on|off]`, `heal`, `party`, `setlevel <posición> <nivel>`, `wildbattle <especie> [nivel]`, `trainerbattle <id>` y `dex [all]`.

### 8.7 Efectos de combate (`src/battle/effects/`, Fase 9.1)

Los movimientos especiales, los volátiles, las condiciones de bando, los climas y los campos son **scripts con hooks**: cada uno hereda de `BattleEffect` y solo implementa los que necesita; el motor los llama en su momento. Un script por id:

| Carpeta | Qué | Ejemplos |
|---------|-----|----------|
| `src/battle/effects/moves/<id>.gd` | Movimientos con comportamiento propio | `protect`, `solarbeam`, `uturn`, `leechseed`, `superfang`... |
| `src/battle/effects/conditions/<id>.gd` | Volátiles, condiciones de bando, climas y campos | `protect`, `leechseed`, `partiallytrapped`, `reflect`, `tailwind`, `raindance`, `mistyterrain`... |
| `src/battle/effects/*.gd` | Bases compartidas | `TwoTurnMoveEffect`, `RechargeMoveEffect`, `LockedMoveEffect`, `PartialTrapMoveEffect`, `WeatherMoveEffect`, `SideConditionMoveEffect`, `WeatherConditionEffect`, `ScreenConditionEffect`... |

- `Effects.move(id)` / `Effects.condition(id)` devuelven el efecto (o `null`: entonces el movimiento usa solo sus datos, Fase 7.6). El validador avisa de los movimientos en uso con `needs_script` que aún no tienen script (hoy: ninguno de los del MVP).
- **Hooks** (documentados en `battle_effect.gd`): de movimiento `on_try_move`, `charge_turn`, `accuracy`, `base_power`, `fixed_damage`, `on_hit` (`CONTINUE` / `HANDLED`), `on_after_hit`, `on_after_move`, `runs_before_switch`, `is_stalling_move`; de condición `duration`, `residual_order`, `on_start`, `on_end`, `on_residual`, `before_move_priority`, `on_before_move`, `on_try_hit`, `weather_modifier`, `modify_base_power`, `stat_modifier`, `damage_modifier`, `modify_speed`, `on_set_status`, `on_try_confuse`, `on_switch_in`, `traps`, `forced_action`, `removed_types`.
- **API del motor para los efectos**: `message()`, `deal_damage()`, `heal()`, `boost()`, `set_status()`, `can_set_status()`, `force_status()`, `cure_status()`, `confuse()`, `add_volatile()` / `remove_volatile()`, `add_side_condition()` / `remove_side_condition()` / `has_side_condition()`, `set_weather()` / `clear_weather()` / `weather()`, `set_terrain()` / `clear_terrain()` / `terrain()`, `field_state()` / `set_field_state()`, `is_grounded()`, `speed_of()`, `foe_of()`, `turn_action()`, `move_index_of()`, `request_switch()`, `force_switch()`, `use_move()`, `end_battle()`, y para los textos `name_of()`, `inner_name_of()`, `to_name()`, `of_name()`, `team_name()`, `team_of_name()`, `team_to_name()`. Estado: `engine.field` (clima, campo...), `BattleSide.conditions`, `Battler.volatiles` (cada uno `{id, turns, ...}`), `Battler.ability` (habilidad en el combate), `damaged_this_turn`, `protect_count`.
- Al final del turno, cada condición descuenta su duración y se acaba al llegar a 0 (o hace su efecto), por `residual_order` (clima 1, Deseo 4, Drenadoras 8, veneno y quemadura 9, atrapado 13, bando 26, campo 27, Alboroto 28) y, a igualdad, el más rápido primero.
- `DamageCalc.calculate(..., opts)` admite `power`, `weather`, `final` (multiplicadores encadenados en base 4096 como `chainModify`), `atk_mod` y `def_mod`.
- Fase 9.5: habilidades de `species_in_use.json` (entrada, modificadores, inmunidades y final de turno) y objetos equipados (Restos, Banda Focus, Elección, Vidasfera, Chaleco Asalto, Casco Dentado y bayas de curación, estado y resistencia). Púas, Púas Tóxicas y Trampa Rocas son condiciones de bando; Giro Rápido y Despejar ya las quitan. Pendiente de la Fase 9: el resto de movimientos (9.2), dobles (9.4), gimmicks (9.6) e IA 2–4 (9.7).

#### Azar y ganchos de pruebas (Agente 5, 2026-10-07)

- **Todas las tiradas del combate** pasan por `engine.rand_int(tag: StringName, lo: int, hi: int) -> int` y `engine.rand_chance(tag: StringName, num: int, den: int) -> bool`. Sin oráculo consumen `engine.rng` exactamente igual que antes (`randi_range(lo, hi)` y `randi_range(0, den - 1) < num`): misma semilla = mismo combate. **Los efectos nuevos que pidan azar deben usar estas funciones, no `engine.rng`.** Etiquetas actuales: `accuracy`, `crit`, `damage_roll`, `secondary`, `multihit`, `par`, `frz_thaw`, `slp_turns`, `confusion_turns`, `confusion_hit`, `attract`, `partiallytrapped_turns`, `lockedmove_turns`, `protect`, `shedskin`, `force_switch` y `run`.
- **Ganchos solo para pruebas** en `BattleSetup` (vacíos = comportamiento normal): `rng_oracle: Callable` (`(tag, turno) -> u` en [0, 1); fija el azar), `foe_controller: Callable` (`(engine, bando, slot) -> BattleAction`, en vez de la IA), `foe_replacement: Callable` (`(engine) -> índice`) y `turn_observer: Callable` (`(engine, turno)`, al empezar cada turno). Los usa `tools/showdown_diff/`.
- `BattleEffect.move_stat_modifier(engine, user, move) -> float`: multiplicador del Ataque o Ataque Especial del usuario que depende del movimiento (Mar Llamas, Espesura, Torrente, Enjambre).
- Al empezar el combate, los efectos de entrada (trampas, habilidades como Intimidación) se aplican cuando ya han salido todos, por orden de Velocidad.

### 8.6 RandomLocke: motor de aleatorización (`src/randomizer/`)

> **Desde 2026-10-05 el motor vuelve a ser del Agente 2** (lo construyó el Agente 4). Manda la sección 10. La configuración vive solo en `data/randomizer/` (`policy.json`, `presets.json`, `prohibidos.json`, `settings_schema.json`, `epitafios.json`). `data/randomizer.json` está retirado.

Lógica **pura y determinista** (como el motor de combate): no toca `DataDB` ni nodos, así que se puede llamar desde `WorkerThreadPool` para la pantalla "Generando la ROM...". Misma semilla + mismos ajustes + misma versión = **la misma ROM**, byte a byte.

```gdscript
var settings := RandomizerSettings.from_preset("clasico")   # "clasico", "solo_aleatorio", "caos" (data/randomizer/presets.json)
settings.wild = "chaos"; settings.preset = RandomizerSettings.CUSTOM   # o tocar campos sueltos (tabla de abajo)
var rom: RomPatch = Randomizer.generate(seed, settings)     # seed: 0..2³²−1; null si DataDB ya tiene un parche
rom.apply()                     # = DataDB.apply_patch(rom.data); al volver al título: DataDB.clear_patch()
rom.to_json() -> String         # guardar en slot_<n>.rom.json (claves ordenadas)
RomPatch.from_dict(JSON.parse_string(texto)).apply()   # al cargar la ranura, ANTES de cargar el mapa
rom.seed_code() -> String       # "PANCHITO-XXXX-XXXX-XX" (+ "-XXXXXX" si los ajustes son personalizados)
rom.spoiler_text() -> String    # registro de spoilers (R.5)
rom.export_spoilers() -> String  # lo escribe en user://randomlocke/<código>_spoilers.txt
rom.settings() -> RandomizerSettings / rom.generator_version()

SeedCode.encode(seed, settings) -> String
SeedCode.decode(code) -> Dictionary   # {ok, seed, settings, version, error}; error en español ("Este código es de otra versión...")
SeedCode.random_seed() -> int
RomValidator.validate(rom) -> PackedStringArray   # R.4 (Randomizer.generate ya la pasa y prueba subsemillas)
```

| Ajuste (`RandomizerSettings`) | Valores | Qué hace |
|-------------------------------|---------|----------|
| `starters` | `off`, `random`, `triangle`, `three_stage` | `triangle`: tres primeras etapas en triángulo de tipos (`starter_2` gana a `starter_1`, `starter_3` a `starter_2` y `starter_1` a `starter_3`). La línea del rival se cambia con la misma etapa, así que el rival sigue llevando el que te gana y lo evoluciona |
| `wild` | `off`, `per_zone`, `global`, `chaos` | `global` = mapeo 1:1 en todo el juego (`species_map`) |
| `trainers`, `keep_type_themes` | bool | Los temas salen de `type_theme` del entrenador o de su clase, o del tipo que comparten todos sus Pokémon |
| `story_pokemon`, `allow_legendaries`, `no_early_legendaries` | bool | Regalos, estáticos e intercambios (los `"randomize": false` no se tocan) |
| `learnsets`, `guarantee_stab`, `scaled_power`, `only_implemented_moves` | `off`/`random`/`type_preference`; bool | Mismo número de movimientos y niveles; ataque de daño (con STAB) al nivel 1 y en cada momento de la curva |
| `abilities`, `types`, `base_stats`, `evolutions` | bool | Tipos y estadísticas, coherentes en la línea evolutiva |
| `items`, `shops` | bool | Colocaciones de `item_placements.json` (nunca objetos clave) y tiendas (siempre con Poké Balls y Pociones) |
| `similar_strength`, `strength_tolerance`, `level_appropriate` | bool, 0–100 | ±% del total de estadísticas; etapa evolutiva acorde al nivel |
| `locke_rules` | bool | Reglas Locke en el combate |

- **Reglas Locke en el combate** (Fase R.7): `fill_from_game_state()` copia `GameState.locke.rules` a `setup.locke`. `locke_rules` queda activo solo si hay muerte permanente (el tutorial lo apaga). Al caer un Pokémon del jugador, una sola vez por `uid`: evento `pokemon_died` (justo después de su `faint`) con `{party_index, uid, species, name, level, foe_species, foe_name, trainer, turn}`, mensaje con `tag = "death"` y la misma entrada en `result.deaths`. No se puede revivir. La experiencia se recorta para no pasar de `next_ace_level` cuando el tope está activo. Los objetos de combate siguen `can_use_item` (usos con efecto, sin contar Balls: la captura sigue posible). El modo fijo no pregunta al sacar el siguiente rival; `&"shift"` sí, y `EngineDriver.request()` incluye `reason`.
- `data/randomizer/` (Agente 2): prohibidos, reglas de equilibrio, presets, esquema y epitafios. `policy.json` es la copia que entra en la ROM y tiene que coincidir con `presets.json` y `prohibidos.json`. Cambiar algo que altere las ROM obliga a subir `Randomizer.GENERATOR_VERSION`.
- Tests (`tests/randomizer/`): códigos, determinismo, parche dorado (`golden_clasico.json`, se rehace con `PANCHITO_UPDATE_GOLDEN=1`), robustez (100 semillas; **1000 con `PANCHITO_LONG_TESTS=1`**), reglas, aplicación y tiempo (< 3 s).

---

## 9. Presentación, UI y contenido (Agente 3)

Lo marcado **(previsto)** aún no está entregado y puede cambiar hasta entonces.

### 9.1 Dialogue (autoload)

Código: `src/autoload/dialogue.gd` + `src/ui/dialogue/`. Mantiene las firmas del stub; solo añade parámetros opcionales al final.

```gdscript
Dialogue.is_open: bool                 # true mientras hay un say()/ask() en curso
Dialogue.text_speed: int               # caracteres por segundo (lo cambia Opciones); 0 = instantáneo
Dialogue.NO_CANCEL                     # constante para ask(): cancel no hace nada

await Dialogue.say(text: String, speaker: Variant = null, vars: Dictionary = {}) -> void
var i: int = await Dialogue.ask(text: String, options: PackedStringArray, speaker: Variant = null,
		cancel_choice: int = -1, vars: Dictionary = {})
var yes: bool = await Dialogue.ask_yes_no(text: String, speaker: Variant = null, vars: Dictionary = {})
Dialogue.format_text(text: String, vars: Dictionary = {}) -> String
```

- `speaker`: nombre (`String`) o un objeto con `display_name`. `null` = sin nombre.
- **Variables**: `{player}` y `{rival}` (de `GameState`) y las que se pasen en `vars` (`{"pokemon": "Pikachu"}` → `{pokemon}`, `{"item": "Poción"}` → `{item}`). El texto pasa antes por `tr()`.
- **Marcadores de la regla R.2** (Fase R.2): `{starter:starter_1}`, `{gift:<id>}`, `{static:<id>}`, `{trade:<id>}`, `{species:<id>}` e `{item:<id>}` se sustituyen por el nombre con `DataDB.resolve_markers()` (en RandomLocke, el de la ROM). Valen en `say()`, `ask()`, las opciones y el nombre del hablante. **Los eventos que nombran un Pokémon u objeto de la historia usan marcadores, no `vars` con el nombre escrito**: `"¿Eliges a {starter:starter_1}?"`.
- **Dinero**: el símbolo es `₽` (`BattleText.CURRENCY`). La fuente no lo trae: lo dibuja a mano una fuente de respaldo del Theme (`assets/fonts/pokedolar/`), así que basta con escribir `₽` en cualquier texto con el Theme.
- **Colores**: BBCode de `RichTextLabel` (`[color=#e05050]texto[/color]`).
- **Páginas**: el texto se divide solo en páginas de 2 líneas. Una línea en blanco (`\n\n`) fuerza página nueva.
- `ask()`: devuelve el índice elegido. `cancel` devuelve `cancel_choice` (−1 = la última opción, normalmente "No"; `Dialogue.NO_CANCEL` = no se puede cancelar).
- `accept` y `cancel` completan la página si se está escribiendo o pasan a la siguiente.
- Bloquea el input con `&"dialogue"` y emite `EventBus.dialogue_started` / `dialogue_finished`. Varios `say()` seguidos no parpadean.

### 9.2 AudioManager (autoload)

Código: `src/autoload/audio_manager.gd`. Mantiene las firmas del stub.

```gdscript
AudioManager.current_bgm: StringName
AudioManager.play_bgm(id: StringName, fade_time := 0.5) -> void   # crossfade; si ya suena, no reinicia
AudioManager.stop_bgm(fade_time := 0.5) -> void
AudioManager.save_bgm() -> void                 # recuerda la BGM actual (p. ej., antes de un combate)
AudioManager.restore_bgm(fade_time := 0.5) -> void
AudioManager.play_se(id: StringName) -> void
await AudioManager.play_me(id: StringName)      # pausa la BGM y la reanuda al acabar; await opcional
await AudioManager.play_cry(species_id: StringName)   # await opcional
AudioManager.play_ambient(id: StringName, fade_time := 1.0) -> void
AudioManager.stop_ambient(fade_time := 1.0) -> void
AudioManager.set_volume(bus: StringName, linear: float) -> void   # 0.0–1.0
AudioManager.get_volume(bus: StringName) -> float
```

- **Buses** (`res://default_bus_layout.tres`): `Master`, `BGM`, `SE`, `ME`, `Cries`, `Ambient`.
- **Id → archivo**, sin tablas en el código: `assets/audio/<bgm|se|me|cries|ambient>/<id>.<ogg|wav|mp3>` (los gritos, con el id de la especie). Si falta el archivo, no suena nada (nunca rompe): se avisa solo del primero que falte y el comando de Debug `audio` da la lista completa.
- Si el mapa nuevo no tiene archivo de BGM, la música anterior se apaga igualmente (silencio mejor que pista equivocada).
- Bucles: en la importación del `.ogg` (*loop* + *loop offset*).
- **SE estándar**: `menu_move`, `menu_accept`, `menu_cancel`, `menu_error`, `bump`, `door`, `stairs`, `ledge`, `grass`, `hit_normal`, `hit_weak`, `hit_super`, `low_hp`, `ball_throw`, `ball_shake`, `ball_caught`, `exp`, `save`.
- **ME estándar**: `heal`, `item`, `key_item`, `badge`, `evolution`, `caught`, `level_up`, `hatch`.

Audio entregado (2026-10-06): originales y hashes en `data/audio_assets.json`, copia reproducible con `tools/arte/import_audio.py`. `_find` pone las BGM/ambientes en bucle y SE/ME/gritos sin bucle; `cursor`/`cancel`/`bump` son alias de selección/cancelación/error. `save_bgm()` / `restore_bgm()` usan una pila para restaurar PS bajos y evolución dentro del combate sin perder la música del mapa. BattleScene activa `low_hp` al 20 % de PS del jugador, restaura al recuperarse/cambiar y da prioridad a victoria; `fast` omite las esperas de ME. La música general de rutas/título/combate espera la pregunta 29; la ausencia de una pista no bloquea el juego.

### 9.3 Escenas que usa SceneManager

Se aceptan las rutas de la sección 4.

| Escena | Contrato |
|--------|----------|
| `res://src/battle/scene/battle_scene.tscn` | `func run(setup) -> StringName` (corrutina). Reproduce la lista de `BattleEvent` del motor (sección 8). Guarda la BGM del mapa con `AudioManager.save_bgm()` y la restaura al acabar |
| `res://src/ui/title/title_screen.tscn` | Llama a `SceneManager.start_new_game()` o `SceneManager.continue_game(slot)` |
| `res://src/ui/pause_menu/pause_menu.tscn` | Menú de la pila de `SceneManager` |

#### BattleScene ↔ combate: `BattleDriver`

La BattleScene habla con un `BattleDriver` (`src/battle/scene/battle_driver.gd`, documentado en el propio archivo), que sigue el flujo de §8.5: `start()` → mientras no acabe, `request()` → acción del jugador → `submit(action)`. Los eventos son **los `BattleEvent` de §8.5 tal cual** (`type`, `side`, `slot`, `data`); la escena ignora los tipos que no conoce. Lo implementan **`EngineDriver`** (`src/battle/scene/engine_driver.gd`, el adaptador del `BattleEngine`: traduce `BattleRequest` / `BattleAction`, quita el objeto de la mochila al usarlo y llama a `result.apply_to_game_state()` en `finish()`) y **`FakeBattle`** (`src/battle/scene/dev/`, combate de mentira para pruebas, sin tocar la partida). `run(setup)` elige: `BattleSetup` → motor real; `Dictionary` (el combate de prueba del Debug) → FakeBattle; un `BattleDriver` → ese.

```gdscript
driver.info() -> Dictionary        # {kind: &"wild"/&"trainer", trainers (como BattleSetup.trainers), background, bgm, can_run, can_lose}
driver.start() -> Array            # BattleEvent hasta la primera decisión
driver.request() -> Dictionary     # {kind: &"action" | &"switch" | &"learn_move", party_index, move_id, move_name, can_run, reason}
driver.submit(action) -> Array     # {type: &"fight", move_slot} · {&"item", item} · {&"switch", party_index} · {&"run"} · {&"learn_move", forget_index}
driver.is_over() -> bool / outcome() -> StringName / finish()   # finish() = aplicar el resultado a la partida
driver.player_active() -> Dictionary / player_party() -> Array[Dictionary] / battle_items() -> Array[Dictionary]   # para los menús
driver.item_needs_target(item_id) -> bool / can_use_item(item_id, party_index) -> bool
```

**Quién pone cada texto**: el motor manda los de mecánicas en eventos `message` (`¡X usó Y!`, `¡Es muy eficaz!`, `¡Has derrotado a...!`...) y el `lose_text` / `win_text` en `trainer_speech`. Los `message` con `tag` `wild_appear`, `challenge`, `send_out` y `recall` **los salta la escena** porque los pone ella en el momento justo de la animación: `¡Un X salvaje apareció!`, `¡<Clase> <Nombre> te desafía!`, `¡<Entrenador> sacó a X!`, `¡Adelante, X!`, `¡X, vuelve!`, `¿Qué debería hacer X?` y `¡{player} está fuera de combate!` (derrota que no se puede perder).

- La escena comprueba antes de enviar: no deja huir de un entrenador (`request.can_run`), ni usar un objeto sin efecto (`can_use_item`), ni elegir un movimiento sin PP; sin PP en ninguno, envía Forcejeo.
- La música de victoria empieza al debilitarse el último Pokémon del rival (si en esa tanda llega `end` con `win`).
- `BattleScene.fast = true` quita animaciones y esperas (tests).
- `BattleMoveAnimation.play(parent, user, target, details, quick) -> bool` elige secuencia explícita por `details.move`; devuelve false para continuar con la genérica. Datos: `battle_motion_moves.json`; cobertura de los equipos/encuentros actuales: `battle_motion_mvp.json`, reproducible con `tools/arte/list_mvp_moves.gd`. No toca el resultado del motor ni PS.
- `BattleFx.move(parent, from, to, details, duration)` reproduce gráficos NikDie según `details.type`/`category`. Los 18 tipos están en `data/battle_motion_types.json`. `duration <= 0` omite nodos; coordenadas enteras y escala nativa, sin dibujar arte procedural.
- `BattleEntryTransition.play(parent, info, quick)` presenta originales EBDX (1,2 s; líder 1,5 s). `info.transition` puede elegir `wild`, `trainer` o `leader`; si no, lee `kind` y `leader_type` del entrenador configurado. No deduce un líder de su nombre. Escala nativa, posiciones enteras y sin rotación; `quick` no crea nodos. Manifiesto reproducible: `data/battle_motion_assets.json`.
- Sprites: `assets/sprites/pokemon/<front|back>[_shiny]/<especie>.png` del Generation 9 Pack, a 1:1 (frente 192, espalda 288; los pies se alinean solos con las filas vacías de abajo), `assets/sprites/trainers/player_back_<male|female>.png` y fondos `assets/sprites/ui/battle/backgrounds/<archivo>.png` según el entorno (`BattleBackground.FILES`). Sin sprite de entrenador no se enseña ninguno; sin sprite de Pokémon sale uno provisional.

`RandomlockeFlow.run(slot)` (A3, `src/ui/randomlocke/`) sustituye la presentación provisional de nueva partida: modo → presets/ajustes/código → `RandomlockeGeneratingScreen.generate(settings, seed)` → `RandomlockeSummaryScreen.confirm(rom)` → `SceneManager.start_randomlocke`. Usa §10 y RandomlockeJob; el trabajo en hilo nunca toca autoloads. La ROM solo se aplica al confirmar. `RandomlockeSettingsScreen.edit(settings, readonly)` retorna copia o null al cancelar; la vista de revisión no cambia ajustes. El resumen omite especies; código íntegro al portapapeles y SpoilerLog exportado solo por elección y confirmación.

`LockeZoneIndicator` (UiRuntime) atiende `locke_zone_entered`; omite el indicador provisional y se oculta durante menús/teclado/aviso de correr. `await CemeteryScreen.open(snapshot := {})` usa el snapshot recibido o LockeRules, sin mutarlo ni retirar muertos. UiRuntime atiende `locke_game_over(snapshot)`, espera a `SceneManager.in_battle == false` y abre `LockeGameOverScreen`; conserva el bloqueo de partida finalizada, guarda el estado y ofrece Cementerio/código/título. Error de guardado impide salir sin reintentar. La entrada de pausa solo se activa para RandomLocke.

### 9.4 Interfaz común

- **Theme global**: `res://src/ui/theme/main_theme.tres` (fuente, colores y marcos). Se pide al Agente 1 en `project.godot` → `gui/theme/custom`.
- **Fuente**: *Truth and Ideals* (`assets/fonts/truth_and_ideals/`), sin antialiasing, a tamaño **10** (Normal) y **10** (Small Truths, para `SmallLabel`). Pensada para pantallas dentro de un **`UiCanvas`** (`src/ui/widgets/ui_canvas.gd`: lienzo de 256×192 a ×2), donde se ve a 20 px. Tiene ñ, tildes, ü, ¿, ¡, ♂, ♀ y ★; le faltan €, — y ·.
- **Variaciones del Theme**: `SmallLabel`, `LightLabel` y `SmallLightLabel` (texto claro sobre fondo oscuro), `TagLabel` (etiqueta PS), `KeyLabel` (claves de las fichas), `TitleLabel` (cabeceras), `DarkPanel` y `LightRichText` (mensajes de combate) y `SmallFrame`. `Panel` y `PanelContainer` usan el marco de pixel art propio.
- **Widgets**: `GridMenu` (`src/ui/widgets/grid_menu.gd`, menú en rejilla o lista con cursor, opciones desactivadas y `await choose(start, allow_cancel) -> int`), `CursorArrow` (`src/ui/widgets/cursor_arrow.gd`, flecha de menú o de "continuar"), `DialogueBox` (`src/ui/dialogue/dialogue_box.tscn`, cuadro de texto reutilizable: `await play(text, speaker_name, wait_last)`) y `ChoiceBox` (`src/ui/dialogue/choice_box.tscn`, lista de opciones: `await choose(options, cancel_choice) -> int`).
- **Más widgets**: `UiCanvas`, `BattleButton` (botón de pixel art de color con foco animado), `TypeIcons.texture(type)` / `make_rect(type)` (iconos de tipo de Loaky) y `await SummaryScreen.open(parent, party: Array[Pokemon], index)` (ficha del Pokémon: Datos, Notas y Estadísticas).
- Pantallas de uso común **entregadas (2026-10-06)**:

```gdscript
await NameKeyboard.ask(parent, title, initial, allow_cancel, max_length) -> String
await SaveSlotsScreen.choose(mode := &"load", start := 1) -> int  # 0 al cancelar
await PartyScreen.open()               # equipo, datos, orden y objetos
await PartyScreen.pick_member(title) -> int  # -1 al cancelar
await BagScreen.open()                 # ocho bolsillos y operaciones de campo
await BagScreen.pick_item(include_keys := true, pocket := &"") -> StringName
await ShopScreen.open(shop_id: StringName)   # stock por medallas, compra y venta
await ChoiceScreen.pick(title, labels, notes, textures) -> int
await QuantityPicker.pick(title, maximum, unit_price) -> int  # 0 al cancelar
```

`PartyItems.equip(p, id)` / `take(p)` intercambian objetos con la mochila sin perder unidades si no hay capacidad. `ShopTransactions.buy(shop, id, amount)` / `sell(id, amount)` validan dinero, existencias y capacidad antes de mutar. `FieldItemUse.use(id, pokemon, move_index)` consume solo tras un efecto válido: PS, estado, revivir (respetando muerte permanente), PP y repelente. Evolución y aprendizaje usan sus pantallas específicas; MT/vitaminas/Caramelo Raro se incorporarán con el contrato del motor. Cuerda Huida no consume sin destino de salida configurado. Las acciones de campo usan `FieldActions`; los IDs/flags pendientes no se inventan.

`await PokedexScreen.open()` y `PokedexEntry.open(id)` muestran registros del módulo Pokedex; la lista usa el orden regional o el nacional si el regional está vacío. `await LearnMoveScreen.choose(request) -> int` devuelve el índice a olvidar o -1; solo el motor aplica el cambio. `await EvolutionScreen.open(p, evolution, item := &"", quick := false) -> bool` presenta/aplica la evolución y registra la nueva especie: B cancela solo si no es con objeto, la piedra se consume tras completarla. BattleScene lee las evoluciones pendientes de EngineDriver (o el inner de LockeBattleDriver) y busca por UID; no depende del índice tras retirar muertos. Movimientos de nivel 0 se presentan al completar una evolución. Shedinja extra requiere hueco y Poké Ball en Normal; recepción en Locke pendiente de la pregunta 28. `ProfessorIntro.begin()` / `finish(screen)` añaden/quitan una presentación debajo del diálogo del guion existente.

- Comandos de Debug del Agente 3: `dialogue <texto>`, `giveitem <id> [n]`, `bag`, `bgm [id]`, `se <id>`, `me <id>`, `volume <bus> <0-100>` y `audio` (audios que faltan).

### 9.5 Mochila (`Bag`, módulo de GameState)

`class_name Bag` en `src/items/bag.gd` (cumple los requisitos de módulo de la sección 2).

```gdscript
Bag.add(item_id: StringName, amount := 1) -> int     # devuelve cuántos se añadieron (máx. 999 por objeto)
Bag.remove(item_id: StringName, amount := 1) -> bool # false si no hay suficientes
Bag.count(item_id: StringName) -> int
Bag.has(item_id: StringName, amount := 1) -> bool
Bag.items_in_pocket(pocket: StringName) -> Array[StringName]   # bolsillos: campo `pocket` de los objetos
Bag.battle_items() -> Array[StringName]   # los que tienen battle_use
Bag.all_items() -> Array[StringName] / Bag.is_empty() -> bool
Bag.MAX_COUNT   # 999
```

El orden es el de obtención. `GameState.bag` la crea y la guarda sola.

### 9.6 Entrenadores (datos)

**Clases** — `data/trainer_classes.json`:

```json
"robasientos": {
  "name": "Robasientos del metro",
  "gender": "male",
  "base_money": 16,
  "ai_level": 1,
  "battle_sprite": "res://assets/sprites/trainers/robasientos.png",
  "overworld_sprite": "res://assets/sprites/characters/robasientos.png",
  "intro_bgm": "encounter_suspicious",
  "battle_bgm": "battle_trainer"
}
```

| Campo | Tipo | Notas |
|-------|------|-------|
| `name` | String | Va delante del nombre: "Robasientos del metro Paco". Vacío = solo el nombre (el rival) |
| `gender` | `"male"` / `"female"` / `"mixed"` | En las clases `mixed`, cada entrenador indica su `gender` |
| `base_money` | int | Dinero al ganar = `base_money × nivel del último Pokémon` |
| `ai_level` | int 0–4 | Fase 9.7. Cada entrenador lo puede sobrescribir |
| `battle_sprite`, `overworld_sprite` | ruta `res://` | Clases `mixed`: además `battle_sprite_female` y `overworld_sprite_female` |
| `intro_bgm`, `battle_bgm` | id de AudioManager | |

**Entrenadores** — `data/trainers/<zona>.json` (un archivo por zona):

```json
"ruta3_paco": {
  "class": "robasientos",
  "name": "Paco",
  "intro_text": "¡Eh, tú! Ese sitio del vagón es mío.",
  "lose_text": "Ese asiento estaba libre, te lo juro.",
  "win_text": "",
  "after_text": "Mañana vuelvo a pillarlo, que lo sepas.",
  "items": [],
  "party": [
    {"species": "ninjask", "level": 14},
    {"species": "pikachu", "level": 15,
     "moves": ["quickattack", "thundershock", "doubleteam", "thunderwave"],
     "item": "oranberry"}
  ],
  "rematches": ["ruta3_paco_2"]
}
```

| Campo | Obligatorio | Notas |
|-------|-------------|-------|
| `class` | Sí | Id de `trainer_classes.json` |
| `name` | Sí | Admite variables de Dialogue (`"{rival}"`) |
| `gender` | Solo si la clase es `mixed` | `"male"` / `"female"` |
| `intro_text` | No | Al verte, antes del combate. Vacío si lo dice una cinemática |
| `lose_text` | Sí | Lo dice en el combate cuando le ganas |
| `win_text` | No | Lo dice si te gana (combates que se pueden perder) |
| `after_text` | No | Al hablarle después de derrotarlo |
| `items` | No | Objetos que usa en combate |
| `ai_level`, `battle_bgm` | No | Sobrescriben los de la clase |
| `double` | No | `true` = combate doble con un solo entrenador |
| `party` | Sí | 1–6 Pokémon. Obligatorios `species` y `level`. Opcionales: `moves`, `ability`, `item`, `nature`, `ivs`, `evs`, `gender`, `shiny`, `form`, `nickname`, `tera_type`. Sin `moves` = los 4 últimos aprendidos por nivel |
| `rematches` | No | Ids de las revanchas, en orden |

- El id de un entrenador es **único en todo el juego**, no solo en su archivo.
- Al ganarle: flag `trainer_defeated:<id>` (lo pone `TrainerNPC` o el evento que lanza el combate).
- Rivales del laboratorio: `rival_lab_1` / `_2` / `_3` según la variable `starter` (1 Planta, 2 Fuego, 3 Agua).
- Lectura: `TrainerData.get_trainer(id) -> Dictionary` (el entrenador combinado con su clase: `display_name`, `class_name`, `gender`, `battle_sprite`, `overworld_sprite`, `intro_bgm`, `battle_bgm`, `ai_level`, `base_money`), `TrainerData.get_trainer_class(id)` y `TrainerData.exists(id)` (`src/overworld/trainers/trainer_data.gd`). `DataDB` también carga estos archivos tal cual.

**TrainerNPC** (`src/overworld/trainers/trainer_npc.tscn`, hereda de `NPC`):

```gdscript
@export var trainer_id: StringName
@export var sight_range := 4          # 0 = no te ve; solo lucha si le hablas
@export var partner: NodePath         # el otro de una pareja; basta con enlazarlo en uno
@export var battle_options: Dictionary = {}   # las de BattleSetup.trainer() (can_lose...)
@export var challenge_event: GDScript # vacío = trainer_challenge_event.gd
```

- Tras cada `player_stepped`, si estás en línea recta delante, a ≤ `sight_range` casillas y sin nada que bloquee el paso en medio: "!" (también el de la pareja), música `intro_bgm` de la clase, se acerca hasta quedarse delante, `intro_text` y combate (`Cutscene.battle_trainer`, que activa `trainer_defeated:<id>` al ganar).
- Hablarle antes de que te vea lanza el mismo combate, sin el "!" ni el acercamiento.
- Derrotado: ya no te ve; al hablarle dice `after_text` (o sus `lines` si no tiene).
- **Pareja**: si te ve cualquiera de los dos, os desafían los dos. Hasta que el motor juegue dobles (Fase 9.4) luchan **uno detrás de otro**.
- En la sala de pruebas: `Manolo` (`ruta1_manolo`) en `maps/test/test_room.tscn`, mirando a la derecha desde la casilla (2, 9), fuera del camino del guion del MVP.

### 9.7 Encuentros (`data/encounters/<id>.json`)

Formato de la guía (Fase 5.7) con dos añadidos:

```json
{
  "land_rate": 10,
  "land": {
    "day":   [{"species": "pidgey", "min": 2, "max": 4, "weight": 40}],
    "night": [{"species": "hoothoot", "min": 2, "max": 4, "weight": 40}]
  },
  "water": [], "old_rod": [], "good_rod": [], "super_rod": [], "rock_smash": [], "headbutt": []
}
```

- `land_rate`: probabilidad de encuentro por paso en hierba alta, en %. Si falta, 10.
- Cada tabla (`land`, `water`...) es **una lista** (igual a cualquier hora) **o un diccionario por momento del día** con los ids de `Clock.period()` (`morning`, `day`, `evening`, `night`). Si falta `morning` o `evening`, se usa `day`. Si falta el momento y no hay `day`, la tabla está vacía.
- `weight`: peso relativo (no tienen que sumar 100). Nivel aleatorio entre `min` y `max`, ambos incluidos.
- El id del archivo (sin `.json`) es el `MapData.encounter_table`. Tablas actuales: `ruta_1` (provisional) y `test_outdoor` (sala de pruebas).

### 9.8 Tiendas (`data/shops.json`)

```json
{
  "sell_ratio": 0.5,
  "shops": {
    "tienda_ciudad2": {
      "name": "Tienda",
      "stock": [
        {"badges": 0, "items": ["pokeball", "potion"]},
        {"badges": 1, "items": ["greatball", "superpotion"]}
      ],
      "prices": {}
    }
  }
}
```

- Se venden los objetos de todos los tramos con `badges` ≤ medallas del jugador.
- Precio de compra: `prices[id]` si existe; si no, el `price` del objeto en DataDB. Precio de venta: `floor(precio × sell_ratio)`.
- Se abre con `await ShopScreen.open(&"tienda_ciudad2")` **(previsto)**.

---

## 10. RandomLocke (Agente 2; lo construyó el Agente 4)

Contrato v2 (continuación del traspaso A2) publicado el 2026-10-04. Motor puro (`RefCounted`, sin nodos ni corrutinas), independiente de los autoloads. Implementación en `src/randomizer/`; fixtures y adaptadores usan únicamente tipos JSON. La base de datos y los presets son parte de la versión del generador: cambiar resultados requiere subirla. Misma base + versión + semilla + ajustes normalizados produce los mismos bytes.

### Entrada normalizada: RandomizerInput

`RandomizerInput.from_dict(data) -> RandomizerInput`, `to_dict() -> Dictionary`, `errors() -> Array[String]`. Una copia profunda impide modificar los datos originales. DataDB deberá exportar este formato (también lo construyen los fixtures):

| Tabla (Dictionary indexado por ID) | Campos |
|---|---|
| `species` | `name`, `types: Array[String]`, `base_stats: {hp,atk,def,spa,spd,spe}`, `abilities: {0,1,H}`, `evolutions: [{to,method,level?,item?}]`, `stage: int`, `min_level: int`, `max_level: int`, `family_id: String`, `legendary: bool`, `mythical: bool`, `catch_rate: int`, `held_items: Array[String]`, `randomize: bool` |
| `moves` | `type`, `category: physical/special/status`, `power`, `damage?` (daño fijo), `implemented: bool`, `randomize: bool` |
| `learnsets` | Por especie: `{level:[[nivel,move_id],...],machine:[],tutor:[]}`, ordenados por nivel |
| `abilities`, `items` | Registros; objetos: `key_item`, `randomize`, `category` (ball/potion/other), `name` |
| `types` | Registro por tipo con `effectiveness: {tipo_defensor: multiplicador}` |
| `tm_moves`, `tutor_moves` | Por ID de máquina/tutor: `{move, randomize}` |
| `tm_compat`, `tutor_compat` | Por especie: Array de IDs de máquinas/tutores |
| `encounters` | Por ID de tabla: `{zone_id, early: bool, randomize, land:{day:[slots],night:[slots]}, water:[slots], ...}`. Cada slot: `{species,min_level,max_level,weight,randomize?}`. Cualquier array de slots anidado se conserva sin alterar pesos ni niveles |
| `trainers` | Modelo 10.1: `{party:[{species,level,moves?,item?,randomize?}], randomize, leader_type?, ace_index?, rival?, rival_starter_slot?, rival_slot?}`. Rival: el slot inicial es la elección alternativa que debe resolver el mundo según la elección del jugador |
| `starters`, `gifts`, `statics` | Por ID: `{species,level,zone_id?,randomize}`; iniciales exactamente tres, nivel 5 habitual |
| `trades` | Por ID: `{give:species_id,receive:{species,level},zone_id?,randomize}` |
| `placements` | ID de colocación (suelo/oculto/regalo): `item_id` o `{item,randomize}` |
| `shops` | Por ID: `{stock:[{items:Array[String]}],randomize}` |
| `required_items`, `required_moves` | Arrays de IDs necesarios para progresar: deben seguir siendo obtenibles |

`stage`, `min_level`, `max_level` y `family_id` son metadatos explícitos del adaptador de DataDB, no decisiones del generador. Etapas sin evolución por nivel (piedra/amistad) necesitan franjas de balance del contenido. Los IDs que no se pueden aleatorizar conservan registro y descendientes; no entran como reemplazos si están prohibidos. `randomize:false` de una especie también protege learnset, compatibilidad, objetos equipados y todos sus campos. Entradas bloqueadas del mundo tampoco se sustituyen mediante `species_map`.

### Ajustes y presets

`RandomizerSettings.defaults()`, `normalize(Dictionary)`, `errors(Dictionary)` y `preset_dict(id)` devuelven diccionarios JSON. `data/randomizer/settings_schema.json` es la lista completa de campos, rangos, valores por defecto y opciones (R.3/R.7); `presets.json` contiene los cuatro presets: `clasico`, `solo_aleatorio`, `caos` (alias `caos_panchito`), `personalizado`. `prohibidos.json` fija especies, movimientos y habilidades excluidos, como parte de la versión. La interfaz puede editar la configuración antes de crear la partida. Probabilidad shiny: denominador 4096, 1024, 512 o 100, sin modificar sprites.

### Parche y API

```gdscript
Randomizer.generate(input: RandomizerInput, settings: Dictionary, seed: int) -> RomPatch
RomValidator.validate(input: RandomizerInput, patch: RomPatch) -> Array[String]
SeedCode.encode(seed: int, settings: Dictionary, version: int) -> String
SeedCode.decode(code: String) -> Dictionary # {ok,seed,settings,version,error}
SpoilerLog.render(input: RandomizerInput, patch: RomPatch) -> String
RomPatch.to_dict() -> Dictionary
RomPatch.from_dict(data: Dictionary) -> RomPatch # estático
RomPatch.canonical_json() -> String
```

Semilla sin signo de 32 bits. Fallo de generación: `RomPatch.errors` no vacío, `is_valid()` falso; no aplicar/guardar como partida. Reintentos limitados con subseed derivada; nunca cambian el código visible. `generator_version`, `seed_code`, `settings`, `input_hash` (SHA-256), `subseed` (número de intento) y tablas de reemplazos `starters`, `species_map`, `encounters`, `trainers`, `gifts`, `statics`, `trades`, `learnsets`, `tm_moves`, `tm_compat`, `tutor_moves`, `tutor_compat`, `abilities`, `species`, `items`, `shops` se guardan junto a la ranura. `starters/gifts/statics` contienen especie por ID; `items` objeto por ID de colocación; encuentros y tiendas son registros completos; entrenadores e intercambios contienen campos reemplazados, fusionados sobre base. Reemplazos de especie por campo, sin sobrescribir el resto.

El formato corto `PANCHITO-XXXX-XXXX-XX` contiene 32 bits de semilla, 5 de versión, 3 de preset y 10 de checksum. **Se conserva la extensión base32 de A2 para personalizados**, ampliada en versión 2 (PENDIENTE JAVIER); no se añade marcador C. El checksum cubre todo el código. El payload empaqueta todos los ajustes según el esquema fijo de la versión. Un código de otra versión devuelve aviso explícito; no se regenera con el generador actual. Cargar partida antigua usa el parche guardado sin regenerarlo. Datos incompatibles se detectan por `input_hash`.

### Semántica solicitada a DataDB (Agente 2)

`apply_patch(patch) -> Array[String]`: validar referencias y hash antes de aplicar, de forma atómica, conservar base inmutable y copia profunda del parche. Error no cambia el parche activo. Consultas `species`, `learnset`, `tm_compat`, `tm_move`, `tutor_compat`, `tutor_move`, `trainer`, `encounters`, `starter`, `gift`, `static_encounter`, `trade`, `placement_item`, `shop` ven reemplazos y vuelven a base donde no haya reemplazo. `species()` combina tipos, estadísticas, habilidades, evoluciones y objetos equipados; no usa `species_map` para remapear el ID de la consulta. `species_map` describe la correspondencia global de salvajes, ya materializada en `encounters`: **no volver a aplicarla**. Hábitats y textos se calculan sobre esas consultas. `clear_patch()` elimina toda la capa y restaura la base, sin tocar instancias de Pokémon guardadas. Aplicar antes de cargar el mapa y limpiar al título/modo normal. Petición formal en ESTADO.

### LockeRules y llamadas del mundo

```gdscript
LockeRules.new(settings: Dictionary = {}, families: Dictionary = {}, epitaphs: Array = [])
can_catch(zone_id: String, species: String, shiny: bool = false, source: String = "wild", encounter_id: String = "") -> bool
register_encounter(zone_id, species, shiny = false, source = "wild", encounter_id = "") -> Dictionary
resolve_encounter(encounter_id: String, outcome: String, pokemon: Dictionary = {}) -> bool
register_owned(species: String) -> void
register_death(pokemon: Dictionary, context: Dictionary) -> Dictionary
level_cap(next_leader_ace_level: int) -> int # 0 = sin tope
can_gain_exp(level: int, next_leader_ace_level: int) -> bool
battle_mode() -> String # fixed/normal
can_use_item(used_this_battle: int) -> bool
is_game_over(party: Array, pc: Array) -> bool
zone_status(zone_id: String) -> String
snapshot() -> Dictionary
from_dict(data: Dictionary) -> LockeRules # estático
```

Reglas copiadas y fijadas en el constructor; ninguna API para cambiarlas, getters devuelven copias. Estado serializable: reglas, familias, zonas (available/pending/caught/lost), encuentro elegible activo por zona, encuentros y resultados, líneas ya poseídas (incluso muertas), muertes y Cementerio, capturas, estado running/finished. El primer encuentro consume la zona inmediatamente; capturar se autoriza solo para su `encounter_id`; huir, KO o fallo definitivo → lost. Shiny exento no consume ni restaura zonas. Duplicado por familia no cuenta. Regalos/estáticos tienen reglas propias (si cuentan, usan zona); intercambios siguen regalos. Mote obligatorio se verifica al resolver caught (no se da por capturado hasta recibirlo).

Mundo (A1): registrar **antes** del combate, consultar permiso con el mismo ID para cada lanzamiento, resolver al terminar; registrar iniciales/capturas/regalos; pasar muerte con `{zone_id,opponent,reason}` y Pokémon `{uid,species,nickname,level,hp,dead?}`. Muerte idempotente por uid, devuelve lápida con epitafio; sacar Pokémon de party/PC utilizable y marcar muerto, nunca curarlo o revivirlo. El motor emite `pokemon_died` una sola vez por uid en un KO real con muerte permanente, y no en tutoriales. También aplica el tope (`next_ace_level`), el modo fijo y el límite de objetos (las Balls no lo gastan). A1 guarda/restaura `snapshot`, preserva Cementerio, comprueba game over tras cada muerte y termina la ranura. PC de `is_game_over` es lista plana de Pokémon utilizables (sin Cementerio ni huevos); hp=0 no cuenta vivo mientras la regla de muerte está activa. Si esa regla está desactivada, un debilitado puede curarse y no termina la partida.

UI (A3): snapshot con zonas, contadores, reglas fijadas, lápidas (mote, especie, nivel, lugar, rival, motivo y epitafio) y estado final; shiny denominator para A2, modo fijo y límite de objetos para combate. La UI elige plantilla de epitafio al construir o deja la selección determinista por uid; plantillas en `data/randomizer/epitafios.json`. No hay I/O ni señales en LockeRules. A1/A3 leen JSON antes de ejecutar en hilo; RandomizerSettings carga sus archivos de configuración una vez y mantiene copias. La generación puede prepararse en principal y ejecutarse en WorkerThreadPool, sin nodos, progreso visual ni await en el motor.

### Compatibilidad y continuidad con A2 (§8.6)

Se conserva API de Settings (campos heredados, `from_preset/apply_dict/to_dict/to_bits/from_bits/matches_preset`), presets `clasico/solo_aleatorio/caos` (alias caos_panchito), modos `three_stage/per_zone/type_preference` y representación de tipos/estadísticas/evoluciones/held_items agrupada en `species:{id:{campo:valor}}`. Nuevos ajustes enumerados en settings_schema.json. Se mantienen valores de balance del traspaso (tolerancia 15 %, etc.) hasta decisión de Javier.

`Randomizer.generate(seed, RandomizerSettings)` se conserva como adaptador principal (snapshot de DataDB); `generate(input, Dictionary o Settings, seed)` es puro y no lee autoloads ni archivos. `RomValidator.validate(patch)` y helpers permanecen; `validate(input,patch)` es puro. Snapshot efímero en `patch.input` no serializado. `RomPatch.apply()` y `spoiler_text()` permanecen como adaptadores; `to_json()` es JSON estable y `canonical_json()` alias. `SpoilerLog.render(input,patch)` puro, exporta la UI. `SeedCode.decode().settings` conserva Settings y añade settings_dict.

Versión **2** por aislamiento de RNG y validación estricta. Se conserva formato A2: 5 bits versión, 3 preset, 32 semilla, 10 checksum; sufijo base32 personalizado ampliado según campos. Rechazar códigos v1 con aviso, conservar carga de parches antiguos sin regenerar. Dorado v1 conservado; dorado v2 de fixture inmutable.

Motivo de cambios: generación anterior leía DataDB/JSON desde hilo, compartía RNG (un ajuste cambiaba otros módulos), relajaba fuerza/nivel/repetidos silenciosamente y faltaba protección randomize:false en slots/tablas/campos. Se reutilizan triángulo, curva de movimientos, rival, representación de parches y tests válidos. Los metadatos evolutivos pueden derivarse con márgenes heredados si faltan, sin fijar nuevas decisiones de diseño.

La entrada incluye `config` con snapshot de policy/prohibidos/presets, y `regional` opcional. `RandomizerInput.from_datadb()` es adaptador del principal; `families(patch)` calcula duplicados sobre grafo efectivo. El nombre de helper de presets por diccionario es `preset_dict` porque `preset` ya es el campo público heredado. Preparar Settings.prepare antes de hilos. Excepción STAB Siniestro ≤60, propuesta PENDIENTE JAVIER en ESTADO; curvas sin nivel 1 normalizan primer registro a 1 sin aumentar cantidad. Configuración única en data/randomizer/ (`data/randomizer.json` retirado el 2026-10-05). `policy.json` es la copia que entra en la ROM y el validador exige que coincida con `presets.json` y `prohibidos.json`.


### §9.9 Opciones y preferencias de dispositivo

`UiPreferences.initialize()` carga `user://ui.cfg` sin sustituir otras secciones. `set_value(key, value)` guarda texto (20/40/80/0), marco (0 claro/1 amarillo/2 verde), pantalla completa, reducción de animaciones y los buses BGM/SE/ME/Cries/Ambient (0..1). `reduce_motion()` consulta la reducción sin cambiar la velocidad del diálogo. `battle_style()` usa la variable guardada de GameState durante una partida y el valor de dispositivo en el título; SceneManager lo aplica antes de las reglas Locke. Correr siempre conserva el contrato GameState y se guarda por partida. `OptionsScreen` emite `closed`; navegación por páginas y ayuda recorrible con C/Start. El acabado de los marcos queda pendiente de aprobación de Javier.

### §9.10 PC, Pokédex completa y datos de entrenador

`PCScreen.open()` usa PCStorage, seis huecos por página; C abre cajas/renombrar/cancelar movimiento. `deposit_member(index, box, slot)` y `withdraw_member(box, slot)` devuelven Error y solo mueven después de validar hueco/capacidad/último capaz. UID y objetos no se modifican. La ficha y liberación se abren sobre el registro real; liberar requiere doble confirmación.

`PokedexEntry`: izquierda/derecha recorre `Pokedex.forms_seen()`, R/Y alterna variocolor solo si `is_shiny_seen()`, C alterna áreas, arriba/abajo recorre texto y A reproduce el grito. `areas(id)` consulta las tablas de DataDB, incluyendo el parche activo; no conserva una copia del catálogo original. La marca variocolor es por especie base según API actual.

`TrainerCardScreen.open()` y estuche leen GameState (incluidas medallas guardadas). `RegionMapScreen.open()` presenta los destinos visitados de `WorldTravel.destinations()` y llama a `fly(id)` con confirmación; no sortea los requisitos de campo. Fondo regional, coordenadas y ocho gráficos/nombres de medallas pendientes de petición 59/pregunta 30; no se considera acabado el mapa gráfico.

### §9.11 Escena doble

`BattleScene` respeta `info.format == double`: cuatro sprites/cajas, `event.side/slot` independientes y `request.slot` para la acción. `target_slots(active, move_slot)` ofrece solo los rivales vivos de ataques individuales; destinos de área/usuario/aliado los decide el motor. `_sprite(side, slot)` / `_data_box(side, slot)` permiten seleccionar explícitamente la presentación. No se dibuja experiencia de miembros en el banquillo (`slot < 0`). EngineDriver.player_active() lee el puesto de la petición y player_party() marca ambos activos para impedir cambiarlos entre sí.

TrainerChallengeEvent.group_setup(group) combina ambos rivales en DOUBLE, con las opciones generales del iniciador y la IA máxima. battle_group guarda ambos IDs antes del combate y activa sus flags solo al ganar. El compañero con IA (`info.ally_ai`) no genera una petición extra en la escena. Petición 47 entregada.

### §9.12 Mecánicas de combate en la presentación

BattleMechanics.available(request, move_slot) devuelve Normal y capacidades anunciadas; Z solo para índices de z_moves. action(move_slot, target_slot, mechanic) añade exclusivamente la bandera elegida. Cancelar vuelve sin submit. BattleScene reproduce mega/zmove/dynamax/dynamax_end/tera por bando/puesto. Sprite de Mega del evento, tamaño Dinamax ×2 entero, PS actuales/máximos de eventos, Tera recordado por índice de miembro dentro de ese combate (nunca se altera GameState). Indicadores M/Z/MAX/T y nombre de la mecánica en botones/mensajes; Mega símbolo EBDX, Tera icono de tipo. Reducción omite efectos, conserva estado final. Sin Gigamax/Estelar; efectos Z pendientes del motor no se simulan en la UI.

### §9.13 Guardería y eclosión (presentación; integración persistente pendiente)

`await DaycareScreen.open(service: Daycare) -> bool` modifica las plazas del servicio recibido mediante `deposit_member(service, index)` / `withdraw_member(service, index)` (Error, operaciones atómicas, protección de último capaz/equipo lleno). Retorna true si se pide huevo; **no llama take_egg ni registra una cría**. El llamador persistente debe recoger/guardar el huevo según el futuro contrato de A2 (petición 61); por ahora no hay entrada de producción ni instancia global temporal.

`await HatchingScreen.open(p: Pokemon, quick := false)` presenta una eclosión que el sistema ya ha decidido. No modifica Pokemon/Party/Pokedex ni resuelve recepción Locke. A/B omiten animación; al terminar permiten volver. Reduce animaciones respeta UiPreferences; preview es solo para capturas. Huevo/grietas originales del pack 06, fondo EBDX y sonidos existentes de apertura/grito. Guardado de huevos y pasos pendientes de A2.
