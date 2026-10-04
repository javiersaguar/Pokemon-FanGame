# Contratos entre módulos

Interfaces públicas entre las partes del juego. Cada sección la define y mantiene **su dueño**.

- **Cambiar un contrato** = avisarlo en `docs/ESTADO.md` (sección "Avisos de cambios de contrato") y no romper a los demás: se **añade**; no se quita ni se renombra nada sin acuerdo.
- Lo marcado **(previsto)** puede cambiar hasta que su dueño lo entregue.
- Si necesitas algo de una sección que no es tuya, pídelo en `docs/ESTADO.md` → "Peticiones".

| Sección | Dueño |
|---------|-------|
| 0. Convenciones comunes | Agente 1 (todos pueden proponer) |
| 1. EventBus · 2. GameState · 3. SaveManager · 4. SceneManager · 5. Mapas · 6. Clock · 7. Debug | Agente 1 |
| 8. DataDB, clases de datos, Pokemon, BattleSetup, BattleAction, BattleEvent | Agente 2 |
| 9. Dialogue, AudioManager, BattleScene, UI, formato de entrenadores | Agente 3 |

---

## 0. Convenciones comunes

- **Godot 4.7.2-stable** (edición estándar). GDScript con **tabuladores**, **tipado estático siempre** (el proyecto avisa de las declaraciones sin tipo) y `class_name` en las clases reutilizables. Los autoloads **no** llevan `class_name`.
- **IDs** en minúsculas y sin espacios (`pikachu`, `thunderbolt`, `vendedorchupachups`), los mismos que Showdown cuando existan. En código, como `StringName` (`&"pikachu"`).
- **Textos visibles en español.** Los textos de la interfaz pasan por `tr()`.
- **Ningún dato de juego en un `.gd`**: potencias, niveles, precios y similares van en `data/`.
- **Leer JSON**: `JsonFile.read(path) -> Variant` y `JsonFile.read_dict(path) -> Dictionary` (`src/util/json_file.gd`). Dan errores claros con la ruta y la línea.
- **Resolución base 320×180** (escalado entero, filtro Nearest). Las interfaces se diseñan a esa resolución.
- **Casillas de 16 px.** Las entidades del mapa se colocan en el **centro** de su casilla: `Grid.to_world(tile) -> Vector2`, `Grid.to_tile(pos) -> Vector2i`, `Grid.TILE` (`src/overworld/grid.gd`).
- **Direcciones**: `Vector2i.UP/DOWN/LEFT/RIGHT` en código; `"up"`, `"down"`, `"left"` y `"right"` en JSON y en el guardado (`GameState.dir_name()` / `GameState.dir_from_name()`).
- **Id de mapa** = ruta de la escena dentro de `maps/` sin `.tscn`: `maps/pueblo_inicial/exterior.tscn` → `&"pueblo_inicial/exterior"`.

### Capas

| CanvasLayer | `layer` | Contenido |
|-------------|---------|-----------|
| `Main/World` | 0 | Mapa actual y jugador (Node2D) |
| `Main/Battle` | 10 | Escena de combate |
| `Main/UI` | 20 | Menús (pila de `SceneManager`) |
| Dialogue (propuesta) | 30 | Cuadro de texto |
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

- Nunca se leen teclas directamente: siempre acciones.
- Enter está en `accept` y en `menu` (como en la tabla de la guía). En el mapa se comprueba `menu` antes que `accept`, así que Enter abre el menú y Z o Espacio interactúan. En los menús, Enter acepta.
- `ui_accept`, `ui_cancel` y `ui_up/down/left/right` (los que usan los `Control` de Godot) incluyen también Z, X/Retroceso y WASD.

### Bloqueo del control del jugador

`GameState.lock_input(reason)` / `GameState.unlock_input(reason)`. Cada `lock` necesita su `unlock` con el mismo `reason`. El jugador no se mueve mientras `GameState.input_locked` sea `true`.

| `reason` | Quién |
|----------|-------|
| `&"map_change"`, `&"battle"`, `&"menu"`, `&"debug"` | SceneManager / Debug (Agente 1) |
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
GameState.new_game() -> void             # valores de data/world.json → new_game
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
GameState.dir_name(dir: Vector2i) -> String / dir_from_name(text) -> Vector2i   # estáticas
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

---

## 3. SaveManager (Agente 1)

Autoload `SaveManager` (`src/autoload/save_manager.gd`). Ranuras 1..`SLOT_COUNT` (3).

```gdscript
SaveManager.has_save(slot := 1) -> bool
SaveManager.save_game(slot := 1) -> Error
SaveManager.load_game(slot := 1) -> Error      # solo restaura GameState; para entrar: SceneManager.continue_game()
SaveManager.slot_summary(slot) -> Dictionary   # {} si está vacía
SaveManager.delete_save(slot) -> void
```

- Archivo `user://saves/slot_<n>.json`: `{save_version, game_version, saved_at, summary, state}` con `state = GameState.to_dict()`.
- `summary` = `{player_name, play_time, badges (número), money, map_id, map_name}` + `saved_at` en `slot_summary()`.
- **Escritura segura**: se escribe `slot_<n>.json.tmp`, se comprueba, la partida anterior pasa a `.bak` y el `.tmp` se renombra. Si el principal está dañado, se carga el `.bak`.
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
SceneManager.start_new_game(map := &"", spawn := &"") -> void
SceneManager.continue_game(slot: int) -> Error       # carga y entra en el mapa guardado
```

Argumentos de arranque (después de `--`): `--map=<map_id> [--spawn=<id>]` empieza partida nueva en ese mapa y `--load=<slot>` carga una ranura. Sin argumentos: título si existe; si no, partida nueva.

### Mapas y fundidos

```gdscript
SceneManager.change_map(map_id, spawn_id := &"default", facing := Vector2i.ZERO, fade := true) -> void
SceneManager.change_map_at(map_id, tile: Vector2i, facing := Vector2i.ZERO, fade := true) -> void
SceneManager.map_exists(map_id) -> bool
SceneManager.list_maps() -> Array[StringName]
SceneManager.fade_out(duration := 0.25, color := Color.BLACK) -> void
SceneManager.fade_in(duration := 0.25) -> void
SceneManager.current_map: MapRoot
SceneManager.player: Node2D                          # Player (Fase 5)
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
| `PLAYER_SCENE` | `res://src/overworld/player/player.tscn` | Agente 1 | Fase 5 |

Si preferís otras rutas, pedidlo y se cambian las constantes.

---

## 5. Mapas (Agente 1)

### Escena de mapa

Raíz `Node2D` con `src/overworld/map_root.gd` (`class_name MapRoot`) y `@export var data: MapData`:

```
<Mapa> (MapRoot)
├── Ground (TileMapLayer)     # suelo
├── Decor (TileMapLayer)      # objetos con colisión a la altura del jugador
├── Entities (Node2D, y_sort_enabled)   # jugador, NPCs, objetos
├── Above (TileMapLayer)      # lo que tapa al jugador (copas, tejados)
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

`MapData` (`src/overworld/map_data.gd`): `id`, `display_name`, `bgm` (id para AudioManager), `outdoor`, `weather`, `encounter_table` (id de `data/encounters/<id>.json`), `battle_background`, `region_map_position`, `can_fly_from`, `can_bike`, `healing_spot` y `fixed_camera`.

### TileSet

Todos los TileSets del juego tienen estas capas (el provisional está en `assets/tilesets/placeholder/`):

- Física 0 → capa `paredes`; física 1 → capa `agua`.
- Custom data: `terrain` (`String`: `grass`, `tall_grass`, `path`, `floor`, `water`, `ledge_down`, `door`, `mat`...), `encounter` (`bool`) y `footstep_sound` (`String`).

### Entidades del mapa (Fase 5, previsto)

- `Player` (`src/overworld/player/`): `facing: Vector2i`, `tile_position() -> Vector2i`, `place_at(tile, facing)`.
- `NPC` (`src/overworld/npc/npc.tscn`), base de `TrainerNPC` (Agente 3): exports de sprite y dirección, `interact()` virtual, `face(dir)`, `face_towards(node)`, `await walk(path)` y `show_emote(...)`.
- Interacción: con `accept`, el jugador busca en la casilla de delante un nodo con `interact()` y lo llama (`await`).

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
- Comandos de serie: `help`, `tp`, `flag`, `var`, `money`, `hour`, `noclip`, `encounters`, `save`, `load`, `battle` y `title`.

---

## 8. Datos y combate (Agente 2) — POR DEFINIR

> Sección del Agente 2. Lo que hay ahora es el **stub provisional** que dejó el Agente 1 para que el proyecto arranque.

### DataDB (stub actual en `src/autoload/data_db.gd`)

```gdscript
DataDB.is_loaded: bool
DataDB.species(id: StringName) -> Variant   # null en el stub
DataDB.move(id: StringName) -> Variant
DataDB.item(id: StringName) -> Variant
DataDB.type_effectiveness(atk_type: StringName, def_types: Array[StringName]) -> float   # 1.0 en el stub
```

### Pendiente de definir por el Agente 2

- Clases `SpeciesData`, `MoveData`, `ItemData`...
- `Pokemon` (instancia), `Party`, `PCStorage` y `Pokedex` (con los requisitos de módulo de GameState, sección 2).
- `BattleSetup`: lo que necesita el Agente 1 está en "Peticiones" de `docs/ESTADO.md`.
- `BattleAction` y la lista de tipos de `BattleEvent`.

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
- **Id → archivo**, sin tablas en el código: `assets/audio/bgm/<id>.ogg`, `assets/audio/se/<id>.(ogg|wav)`, `assets/audio/me/<id>.ogg`, `assets/audio/cries/<species_id>.ogg` y `assets/audio/ambient/<id>.ogg`. Si falta el archivo, avisa una vez y no suena nada (nunca rompe).
- Bucles: en la importación del `.ogg` (*loop* + *loop offset*).
- **SE estándar**: `menu_move`, `menu_accept`, `menu_cancel`, `menu_error`, `bump`, `door`, `stairs`, `ledge`, `grass`, `hit_normal`, `hit_weak`, `hit_super`, `low_hp`, `ball_throw`, `ball_shake`, `ball_caught`, `exp`, `save`.
- **ME estándar**: `heal`, `item`, `key_item`, `badge`, `evolution`, `caught`, `level_up`, `hatch`.

### 9.3 Escenas que usa SceneManager

Se aceptan las rutas de la sección 4:

| Escena | Contrato |
|--------|----------|
| `res://src/battle/scene/battle_scene.tscn` | `func run(setup) -> StringName` (corrutina). Reproduce la lista de `BattleEvent` del motor (sección 8). Guarda la BGM del mapa con `AudioManager.save_bgm()` y la restaura al acabar |
| `res://src/ui/title/title_screen.tscn` | Llama a `SceneManager.start_new_game()` o `SceneManager.continue_game(slot)` |
| `res://src/ui/pause_menu/pause_menu.tscn` | Menú de la pila de `SceneManager` |

### 9.4 Interfaz común

- **Theme global**: `res://src/ui/theme/main_theme.tres` (fuente, colores y marcos). Se pide al Agente 1 en `project.godot` → `gui/theme/custom`.
- **Fuentes**: Pixel Operator (CC0) en `assets/fonts/`, sin antialiasing: tamaño **16** para el texto normal (es el del Theme) y `PixelOperator8.ttf` a tamaño **8** para textos pequeños. Tiene ñ, tildes, ü, ¿, ¡, «», € y …; **no** tiene º, ª, ♂ ni ♀ (se dibujan como iconos).
- **Variaciones del Theme**: `SmallLabel` (8 px), `LightLabel` y `SmallLightLabel` (texto claro sobre fondo oscuro), `SmallFrame` (marco con menos margen). `Panel` y `PanelContainer` usan el marco estándar.
- **Widgets**: `CursorArrow` (`src/ui/widgets/cursor_arrow.gd`, flecha de menú o de "continuar"), `DialogueBox` (`src/ui/dialogue/dialogue_box.tscn`, cuadro de texto reutilizable: `await play(text, speaker_name, wait_last)`) y `ChoiceBox` (`src/ui/dialogue/choice_box.tscn`, lista de opciones: `await choose(options, cancel_choice) -> int`).
- Pantallas de uso común **(previsto)**:

```gdscript
var name: String = await NameEntry.open(title: String, default_name := "", max_length := 10)
await ShopScreen.open(shop_id: StringName)     # data/shops.json
await PartyScreen.open(mode := PartyScreen.Mode.VIEW) -> int   # índice elegido o -1
await BagScreen.open(mode := BagScreen.Mode.FIELD) -> StringName  # id del objeto o &""
```

- Comandos de Debug del Agente 3 **(previsto)**: `giveitem <id> [n]`, `dialogue <texto>`, `bgm <id>`.

### 9.5 Mochila (`Bag`, módulo de GameState) (previsto)

`class_name Bag` en `src/items/bag.gd` (cumple los requisitos de módulo de la sección 2).

```gdscript
Bag.add(item_id: StringName, amount := 1) -> int     # devuelve cuántos se añadieron (máx. 999 por objeto)
Bag.remove(item_id: StringName, amount := 1) -> bool # false si no hay suficientes
Bag.count(item_id: StringName) -> int
Bag.has(item_id: StringName, amount := 1) -> bool
Bag.items_in_pocket(pocket: StringName) -> Array[StringName]   # bolsillos: campo `pocket` de los objetos
```

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
- Lectura **(previsto)**: `TrainerData.get_trainer(id) -> Dictionary` y `TrainerData.get_class(id) -> Dictionary` (`src/overworld/trainers/trainer_data.gd`), con el entrenador ya combinado con su clase. Si el Agente 2 prefiere cargarlos en `DataDB`, se cambia.

**TrainerNPC** **(previsto)**: `src/overworld/trainers/trainer_npc.tscn`, hereda de `NPC` (sección 5). Exports: `trainer_id: StringName`, `sight_range := 4`, `partner: NodePath` (pareja para combate doble).

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
