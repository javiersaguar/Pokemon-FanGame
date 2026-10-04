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

## 9. Presentación, UI y contenido (Agente 3) — POR DEFINIR

> Sección del Agente 3. Lo que hay ahora es el **stub provisional** que dejó el Agente 1 para que el proyecto arranque.

### Dialogue (stub actual en `src/autoload/dialogue.gd`)

```gdscript
await Dialogue.say(text: String, speaker: Variant = null) -> void
var i: int = await Dialogue.ask(text: String, options: PackedStringArray, speaker: Variant = null)
Dialogue.is_open: bool
```

- `speaker`: nombre (`String`) o un objeto con `display_name`.
- `ask()` devuelve el índice elegido; `cancel` elige la última opción (normalmente "No").
- Variables en el texto: `{player}` y `{rival}`.
- Bloquea el input con `&"dialogue"` y emite `EventBus.dialogue_started` y `dialogue_finished`.

### AudioManager (stub actual en `src/autoload/audio_manager.gd`, no suena nada)

```gdscript
AudioManager.play_bgm(id: StringName, fade_time := 0.5) -> void
AudioManager.stop_bgm(fade_time := 0.5) -> void
AudioManager.play_se(id: StringName) -> void
AudioManager.play_me(id: StringName) -> void    # en la versión real, que se pueda hacer await
AudioManager.play_cry(species_id: StringName) -> void
AudioManager.current_bgm: StringName
```

### Pendiente de definir por el Agente 3

- Formato de `data/trainer_classes.json`, `data/trainers/*.json` y `data/encounters/*.json`.
- BattleScene (`run(setup) -> StringName`, sección 4), título y menú de pausa.

---

## 10. RandomLocke (Agente 4)

Contrato v1 publicado el 2026-10-04. Motor puro (`RefCounted`, sin nodos ni corrutinas), independiente de los autoloads. Implementación en `src/randomizer/`; fixtures y adaptadores usan únicamente tipos JSON. La base de datos y los presets son parte de la versión del generador: cambiar resultados requiere subirla. Misma base + versión + semilla + ajustes normalizados produce los mismos bytes.

### Entrada normalizada: RandomizerInput

`RandomizerInput.from_dict(data) -> RandomizerInput`, `to_dict() -> Dictionary`, `errors() -> Array[String]`. Una copia profunda impide modificar los datos originales. DataDB deberá exportar este formato (también lo construyen los fixtures):

| Tabla (Dictionary indexado por ID) | Campos |
|---|---|
| `species` | `name`, `types: Array[String]`, `base_stats: {hp,atk,def,spa,spd,spe}`, `abilities: {0,1,H}`, `evolutions: [{to,method,level?,item?}]`, `stage: int`, `min_level: int`, `max_level: int`, `family_id: String`, `legendary: bool`, `mythical: bool`, `catch_rate: int`, `held_items: Array[String]`, `randomize: bool` |
| `moves` | `type`, `category: physical/special/status`, `power`, `damage?` (daño fijo), `implemented: bool`, `randomize: bool` |
| `learnsets` | Por especie: `[[nivel, move_id], ...]`, ordenados por nivel |
| `abilities`, `items` | Registros; objetos: `key_item`, `randomize`, `category` (ball/potion/other), `name` |
| `types` | Registro por tipo con `effectiveness: {tipo_defensor: multiplicador}` |
| `tm_moves`, `tutor_moves` | Por ID de máquina/tutor: `{move, randomize}` |
| `tm_compat`, `tutor_compat` | Por especie: Array de IDs de máquinas/tutores |
| `encounters` | Por ID de tabla: `{zone_id, early: bool, randomize, land:{day:[slots],night:[slots]}, water:[slots], ...}`. Cada slot: `{species,min_level,max_level,weight,randomize?}`. Cualquier array de slots anidado se conserva sin alterar pesos ni niveles |
| `trainers` | Modelo 10.1: `{party:[{species,level,moves?,item?,randomize?}], randomize, leader_type?, ace_index?, rival?, rival_starter_slot?, rival_slot?}`. Rival: el slot inicial es la elección alternativa que debe resolver el mundo según la elección del jugador |
| `starters`, `gifts`, `statics` | Por ID: `{species,level,zone_id?,randomize}`; iniciales exactamente tres, nivel 5 habitual |
| `trades` | Por ID: `{requested,received,level,zone_id?,randomize}` |
| `placements` | ID de colocación (suelo/oculto/regalo): `{item,randomize}` |
| `shops` | Por ID: `{items:Array[String],randomize}` |
| `required_items`, `required_moves` | Arrays de IDs necesarios para progresar: deben seguir siendo obtenibles |

`stage`, `min_level`, `max_level` y `family_id` son metadatos explícitos del adaptador de DataDB, no decisiones del generador. Etapas sin evolución por nivel (piedra/amistad) necesitan franjas de balance del contenido. Los IDs que no se pueden aleatorizar conservan registro y descendientes; no entran como reemplazos si están prohibidos. `randomize:false` de una especie también protege learnset, compatibilidad, objetos equipados y todos sus campos. Entradas bloqueadas del mundo tampoco se sustituyen mediante `species_map`.

### Ajustes y presets

`RandomizerSettings.defaults()`, `normalize(Dictionary)`, `errors(Dictionary)` y `preset(id)` devuelven diccionarios JSON. `data/randomizer/settings_schema.json` es la lista completa de campos, rangos, valores por defecto y opciones (R.3/R.7); `presets.json` contiene los cuatro presets: `clasico`, `solo_aleatorio`, `caos_panchito`, `personalizado`. `prohibidos.json` fija especies, movimientos y habilidades excluidos, como parte de la versión. La interfaz puede editar la configuración antes de crear la partida. Probabilidad shiny: denominador 4096, 1024, 512 o 100, sin modificar sprites.

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

Semilla sin signo de 32 bits. Fallo de generación: `RomPatch.errors` no vacío, `is_valid()` falso; no aplicar/guardar como partida. Reintentos limitados con subseed derivada; nunca cambian el código visible. `generator_version`, `seed_code`, `settings`, `input_hash` (SHA-256), `attempt` y tablas de reemplazos `starters`, `species_map`, `encounters`, `trainers`, `gifts`, `statics`, `trades`, `learnsets`, `tm_moves`, `tm_compat`, `tutor_moves`, `tutor_compat`, `abilities`, `types`, `base_stats`, `evolutions`, `held_items`, `items`, `shops` se guardan junto a la ranura. `starters/gifts/statics` contienen especie por ID; `items` objeto por ID de colocación; `trades`, encuentros, entrenadores y tiendas son registros completos. Reemplazos de especie por campo, sin sobrescribir el resto.

El formato corto `PANCHITO-XXXX-XXXX-XX` contiene 32 bits de semilla, versión, preset y checksum. **No cabe una configuración personalizada completa en diez caracteres base32**: se propone una extensión `-C<payload>` para ajustes personalizados, con checksum que cubre todo el código (PENDIENTE JAVIER, registrado en ESTADO). El payload empaqueta todos los ajustes según el esquema fijo de la versión. Un código de otra versión devuelve aviso explícito; no se regenera con el generador actual. Cargar partida antigua usa el parche guardado sin regenerarlo. Datos incompatibles se detectan por `input_hash`.

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

Mundo (A1): registrar **antes** del combate, consultar permiso con el mismo ID para cada lanzamiento, resolver al terminar; registrar iniciales/capturas/regalos; pasar muerte con `{zone_id,opponent,reason}` y Pokémon `{uid,species,nickname,level,hp,dead?}`. Muerte idempotente por uid, devuelve lápida con epitafio; sacar Pokémon de party/PC utilizable y marcar muerto, nunca curarlo o revivirlo. Combat engine (A2) debe emitir `pokemon_died` una sola vez por KO real cuando esté activa la regla, no en combates excluidos de tutorial. A1 guarda/restaura `snapshot`, preserva Cementerio, comprueba game over tras cada muerte y termina la ranura. PC de `is_game_over` es lista plana de Pokémon utilizables (sin Cementerio ni huevos); hp=0 no cuenta vivo mientras la regla de muerte está activa. Si esa regla está desactivada, un debilitado puede curarse y no termina la partida.

UI (A3): snapshot con zonas, contadores, reglas fijadas, lápidas (mote, especie, nivel, lugar, rival, motivo y epitafio) y estado final; shiny denominator para A2, modo fijo y límite de objetos para combate. La UI elige plantilla de epitafio al construir o deja la selección determinista por uid; plantillas en `data/randomizer/epitafios.json`. No hay I/O ni señales en LockeRules. A1/A3 leen JSON antes de ejecutar en hilo; RandomizerSettings carga sus archivos de configuración una vez y mantiene copias. La generación puede prepararse en principal y ejecutarse en WorkerThreadPool, sin nodos, progreso visual ni await en el motor.
