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
- **Resolución base 512×384** (decisión de Javier, Fase 3.2; escalado entero y filtro Nearest). **El mundo se ve a ×2**: el arte se dibuja con casillas de 16 px y la cámara del jugador tiene `zoom = 2` (16×12 casillas en pantalla). **La UI no tiene zoom**: las `CanvasLayer` se diseñan a 512×384 nativo. Las posiciones del mundo van en píxeles enteros del arte (`Character` redondea al moverse). Fondo por defecto negro.
- **Casillas de 16 px.** Las entidades del mapa se colocan en el **centro** de su casilla: `Grid.to_world(tile) -> Vector2`, `Grid.to_tile(pos) -> Vector2i`, `Grid.TILE` (`src/overworld/grid.gd`).
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

`MapData` (`src/overworld/map_data.gd`): `id`, `display_name`, `bgm` (id para AudioManager), `outdoor`, `weather`, `encounter_table` (id de `data/encounters/<id>.json`), `encounter_rate` (0 = por defecto), `battle_background`, `region_map_position`, `can_fly_from`, `can_bike`, `healing_spot` y `fixed_camera`.

```gdscript
MapRoot.get_layer(name) -> TileMapLayer
MapRoot.tile_custom_data(tile, key, default = null) -> Variant   # Decor antes que Ground
MapRoot.terrain_at(tile) -> String
MapRoot.is_encounter_tile(tile) -> bool
MapRoot.get_warps() -> Array[Warp] / MapRoot.warp_at(tile) -> Warp
```

### TileSet

Todos los TileSets del juego tienen estas capas (el provisional está en `assets/tilesets/placeholder/`):

- Física 0 → capa `paredes`; física 1 → capa `agua`.
- Custom data: `terrain` (`String`: `grass`, `tall_grass`, `path`, `floor`, `water`, `ledge_down`, `door`, `mat`...), `encounter` (`bool`) y `footstep_sound` (`String`).

### Entidades del mapa

Van dentro de `Entities`. Jerarquía de clases (todas `@tool`: **las clases hijas también deben ser `@tool`** y llamar a `super()` en `_ready()`, y su lógica de juego debe ir protegida con `if Engine.is_editor_hint(): return`):

```
MapEntity (src/overworld/map_entity.gd)       # algo que se examina con accept
├── Character (src/overworld/character.gd)    # se mueve por casillas
│   ├── Player (src/overworld/player/player.tscn)
│   └── NPC (src/overworld/npc/npc.tscn)      # base de TrainerNPC (Agente 3)
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
@export var initial_facing: Character.Direction   # DOWN, LEFT, RIGHT, UP
var facing: Vector2i
var moving: bool
signal step_finished(tile: Vector2i)
func face(dir: Vector2i) -> void
func face_towards(target: Node2D) -> void
func can_step(dir: Vector2i) -> bool
func step(dir, duration := Character.WALK_TIME, ignore_collisions := false) -> bool   # corrutina
func walk(path: Array[Vector2i], duration := WALK_TIME, ignore_collisions := false) -> void   # corrutina
func bump(dir, duration := WALK_TIME) -> void          # andar en el sitio
func place_at(tile: Vector2i, dir := Vector2i.ZERO) -> void
func show_emote(text := "!", duration := 0.6) -> void  # corrutina; globo sobre la cabeza
```

`WALK_TIME` = 0,25 s y `RUN_TIME` = 0,125 s por casilla. Al moverse, el cuerpo se adelanta a la casilla de destino para reservarla.

**Player** (`SceneManager.player`)

- Toque corto en otra dirección = solo girar. Si se mantiene, anda y encadena casillas sin parones. Con `run`, corre. Contra una pared anda en el sitio y suena `bump`.
- Tras cada paso: warp (si lo hay) → `EventBus.player_stepped(tile)` → encuentro salvaje (si nadie ha bloqueado el input).
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

**ItemBall**: `item_id: StringName`, `quantity: int`, `hidden_item: bool`. Su **id de colocación** es `<map_id>/<nombre del nodo>` (`placement_id()`): por la regla R.2, el objeto que da es `DataDB.placed_item(placement_id, item_id)` si DataDB lo tiene (en RandomLocke puede ser otro) y, si no, `item_id`. Al cogerlo activa `item_taken:<map_id>:<nombre del nodo>`, llama a `GameState.bag.add(objeto, quantity)` si la mochila existe, suena el ME `item` y muestra "¡{player} ha encontrado {item}!" con el nombre (o el plural) de `DataDB.item()`.

**MapSign**: `lines`, `only_from_below := true` y `show_sprite := true`.

**Warp**: `target_map`, `target_spawn` (`&"default"`), `arrival_facing` (`KEEP`, `DOWN`, `LEFT`, `RIGHT` o `UP`), `size: Vector2i` (casillas desde la suya hacia la derecha y abajo) y `sound` (SE, por defecto `&"door"`). Se activa al pisarlo. En el editor se dibuja como un rectángulo azul.

### Corrutinas y cambios de mapa

Un nodo del mapa (NPC, cartel, Warp...) **se libera al cambiar de mapa** y sus corrutinas en marcha se cortan. Por eso:

- Lo que deba seguir tras un cambio de mapa no puede vivir en un nodo del mapa: los warps los ejecuta el jugador y las cinemáticas largas (Fase 13) irán en un nodo persistente.
- Si un NPC lanza un combate que el jugador pierde (y no se puede perder), el jugador aparece en el Centro Pokémon y la corrutina del NPC termina ahí: lo que hubiera después del combate no se ejecuta. El jugador recupera el control solo.

### Spritesheets de personajes

`assets/sprites/characters/<id>.png`: **4 columnas** (quieto, paso A, quieto, paso B) × **4 filas** (abajo, izquierda, derecha, arriba). El tamaño de frame es libre (ancho/4 × alto/4) y los pies tocan el borde inferior del frame. Los provisionales (`assets/sprites/characters/placeholder/`, frames de 32×32) se generan con `generate_characters.gd`: `player_male`, `player_female`, `rival`, `professor`, `mom`, `npc_man`, `npc_woman`, `npc_old`, `nurse`, `clerk` y `trainer`, más `item_ball` y `sign` (16×16).

### Encuentros salvajes

- Solo en casillas con `encounter = true` y en mapas con `data.encounter_table`.
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
- Comandos de serie: `help`, `tp`, `flag`, `var`, `money`, `hour`, `noclip`, `encounters`, `save`, `load`, `battle` y `title`.

---

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

# Otros
DataDB.meta() -> Dictionary                  # versiones de las fuentes (data/generated/meta.json)
DataDB.rule(key, default) -> Variant         # data/world.json → "pokemon" (ver abajo)
```

**Reglas configurables** (`data/world.json` → `"pokemon"`, del Agente 1). Si falta una, se usa el valor por defecto:

| Clave | Por defecto | Uso |
|-------|-------------|-----|
| `shiny_odds` | `4096` | Probabilidad de shiny = 1/`shiny_odds` (0 = nunca) |
| `wild_hidden_ability_chance` | `0.0` | Probabilidad (0–1) de habilidad oculta en Pokémon nuevos. **POR DEFINIR (Javier)** |
| `pc_boxes`, `pc_box_size` | `32`, `30` | Cajas del PC |
| `exp_share` | `true` | Repartir Experiencia moderno activo por defecto |

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
Pokemon.create(species_id, level, rng: RandomNumberGenerator = null) -> Pokemon   # salvaje o regalo
Pokemon.from_spec(spec: Dictionary, rng = null) -> Pokemon   # ficha de data/trainers (party[i])
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

**`EvolutionRules`** (estática): `level_up_target(p, context := {}) -> StringName` (al subir de nivel o al acabar un combate) e `item_target(p, item_id, context := {}) -> StringName` (`&""` = no evoluciona). `level_up_evolution(p, context)` devuelve la entrada completa y `evolve(p, evo)` la aplica (y gasta el objeto equipado si era `level_hold`). `shed_species(from, to)` = Shedinja al evolucionar Nincada. `context`: `{time: Clock.period(), party_species: Array[StringName], party_types: Array[StringName], weather: StringName, location: StringName}`.

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
# options: can_lose, can_run, allow_items, exp_enabled, exp_share, background, bgm, weather,
#          environment, time_period, seed, ai_level
BattleSetup.trainer_info(trainer_id, player_name := "") -> Dictionary   # entrenador + clase (lo de setup.trainers[i])
setup.fill_from_game_state() / setup.apply_options(options) / setup.is_wild()
```

| Campo | Tipo | Notas |
|-------|------|-------|
| `kind` | `BattleSetup.Kind.WILD` / `TRAINER` | |
| `format` | `BattleSetup.Format.SINGLE` / `DOUBLE` | v0.1: solo individual |
| `player_party`, `foe_party` | `Array[Pokemon]` | Las fábricas toman el equipo de `GameState.party` |
| `player_name`, `player_trainer_id` | | De `GameState` |
| `trainers` | `Array[Dictionary]` | Rivales (vacío en salvajes): `{id, class, class_name, name, display_name, gender, base_money, ai_level, battle_sprite, battle_bgm, intro_bgm, intro_text, lose_text, win_text, items}`. `display_name` = "Vendedor de Chupachups Manolo", con `{rival}` y `{player}` ya sustituidos |
| `can_lose` | `bool` | `true` = perder no te manda al Centro Pokémon |
| `can_run`, `allow_items`, `exp_enabled`, `exp_share` | `bool` | `can_run` = `true` en salvajes |
| `background`, `bgm` | `StringName` | `bgm`: la del entrenador (`battle_bgm`) o `battle_wild` |
| `weather`, `environment`, `time_period` | `StringName` | `environment`: `grass`, `cave`, `water`... (para algunas Balls) |
| `caught_species`, `dex_caught_count` | | De `GameState.pokedex` (Ball Acopio y captura crítica) |
| `seed` | `int` | 0 = aleatoria (la usada queda en `result.seed`) |

**`BattleRequest`** (`engine.request`): `kind` (`BattleRequest.Kind.ACTION`, `SWITCH` o `LEARN_MOVE`), `side`, `slot`, `party_index`, `move_id` (en `LEARN_MOVE`), `can_run`, `can_switch`, `can_use_items`, `usable_moves: Array[int]` (índices con PP; vacío = solo puede usar Forcejeo).

| `kind` | Cuándo | Respuestas válidas |
|--------|--------|--------------------|
| `ACTION` | Inicio de turno | `fight`, `switch_to`, `use_item`, `run` |
| `SWITCH` | Se ha debilitado el Pokémon del jugador | `switch_to` (o `run` en salvajes, si `can_run`) |
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
- IA (`BattleAI`): nivel 0 = movimiento al azar; nivel 1 = el que más daño hace (`engine.estimate_damage()`). Reemplazo: el siguiente del equipo.
- Más API: `engine.rng`, `engine.turn`, `engine.side(i)`, `engine.estimate_damage(user, target, move)`. Textos en `BattleText` (moneda: `BattleText.CURRENCY`).

**Validador** (Fase 4.6): `godot --headless --path . -s res://tools/validate/validate.gd` (o el test `tests/datos/test_validador.gd`). Errores = especies, movimientos, objetos o clases que no existen, evoluciones por intercambio, niveles o pesos no válidos; avisos = sprites e iconos que faltan y movimientos en uso que necesitan script.

**Debug** (Agente 2): `givepkmn <especie> [nivel]`, `heal`, `party`, `setlevel <posición> <nivel>`, `wildbattle <especie> [nivel]`, `trainerbattle <id>` y `dex [all]`.

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
- **Id → archivo**, sin tablas en el código: `assets/audio/<bgm|se|me|cries|ambient>/<id>.<ogg|wav|mp3>` (los gritos, con el id de la especie). Si falta el archivo, no suena nada (nunca rompe): se avisa solo del primero que falte y el comando de Debug `audio` da la lista completa.
- Si el mapa nuevo no tiene archivo de BGM, la música anterior se apaga igualmente (silencio mejor que pista equivocada).
- Bucles: en la importación del `.ogg` (*loop* + *loop offset*).
- **SE estándar**: `menu_move`, `menu_accept`, `menu_cancel`, `menu_error`, `bump`, `door`, `stairs`, `ledge`, `grass`, `hit_normal`, `hit_weak`, `hit_super`, `low_hp`, `ball_throw`, `ball_shake`, `ball_caught`, `exp`, `save`.
- **ME estándar**: `heal`, `item`, `key_item`, `badge`, `evolution`, `caught`, `level_up`, `hatch`.

### 9.3 Escenas que usa SceneManager

Se aceptan las rutas de la sección 4.

| Escena | Contrato |
|--------|----------|
| `res://src/battle/scene/battle_scene.tscn` | `func run(setup) -> StringName` (corrutina). Reproduce la lista de `BattleEvent` del motor (sección 8). Guarda la BGM del mapa con `AudioManager.save_bgm()` y la restaura al acabar |
| `res://src/ui/title/title_screen.tscn` | Llama a `SceneManager.start_new_game()` o `SceneManager.continue_game(slot)` |
| `res://src/ui/pause_menu/pause_menu.tscn` | Menú de la pila de `SceneManager` |

#### BattleScene ↔ combate: `BattleDriver`

La BattleScene habla con un `BattleDriver` (`src/battle/scene/battle_driver.gd`, documentado en el propio archivo), que sigue el flujo de §8.5: `start()` → mientras no acabe, `request()` → acción del jugador → `submit(action)`. Los eventos son **los `BattleEvent` de §8.5 tal cual** (`type`, `side`, `slot`, `data`); la escena ignora los tipos que no conoce. Hoy lo implementa `FakeBattle` (`src/battle/scene/dev/`, combate de mentira con eventos del mismo formato y sin tocar la partida); cuando llegue el `BattleEngine`, un adaptador fino (Agente 3) traducirá `BattleRequest` / `BattleAction` y llamará a `result.apply_to_game_state()` en `finish()`.

```gdscript
driver.info() -> Dictionary        # {kind: &"wild"/&"trainer", trainers (como BattleSetup.trainers), background, bgm, can_run, can_lose}
driver.start() -> Array            # BattleEvent hasta la primera decisión
driver.request() -> Dictionary     # {kind: &"action" | &"switch" | &"learn_move", party_index, move_id, move_name, can_run}
driver.submit(action) -> Array     # {type: &"fight", move_slot} · {&"item", item} · {&"switch", party_index} · {&"run"} · {&"learn_move", forget_index}
driver.is_over() -> bool / outcome() -> StringName / finish()   # finish() = aplicar el resultado a la partida
driver.player_active() -> Dictionary / player_party() -> Array[Dictionary] / battle_items() -> Array[Dictionary]   # para los menús
```

**Quién pone cada texto**: el motor manda los de mecánicas en eventos `message` (`¡X usó Y!`, `¡Es muy eficaz!`, `¡Has derrotado a...!`...) y el `lose_text` / `win_text` en `trainer_speech`. La escena solo pone los de presentación: `¡Un X salvaje apareció!`, `¡<Clase> <Nombre> te desafía!`, `¡<Entrenador> sacó a X!`, `¡Adelante, X!`, `¡X, vuelve!`, `¿Qué debería hacer X?` y `¡{player} está fuera de combate!` (derrota que no se puede perder).

- La música de victoria empieza al debilitarse el último Pokémon del rival (si en esa tanda llega `end` con `win`).
- `BattleScene.fast = true` quita animaciones y esperas (tests).
- Sprites: `assets/sprites/pokemon/<front|back>[_shiny]/<especie>.png`, `assets/sprites/trainers/player_back_<male|female>.png` y fondos `assets/sprites/ui/battle/bg_<entorno>.png`. Si faltan, se generan provisionales (`PlaceholderArt`).

### 9.4 Interfaz común

- **Theme global**: `res://src/ui/theme/main_theme.tres` (fuente, colores y marcos). Se pide al Agente 1 en `project.godot` → `gui/theme/custom`.
- **Fuentes**: Pixel Operator (CC0) en `assets/fonts/`, sin antialiasing: tamaño **16** para el texto normal (es el del Theme) y `PixelOperator8.ttf` a tamaño **8** para textos pequeños. Tiene ñ, tildes, ü, ¿, ¡, «», € y …; **no** tiene º, ª, ♂ ni ♀ (se dibujan como iconos).
- **Variaciones del Theme**: `SmallLabel` (8 px), `LightLabel` y `SmallLightLabel` (texto claro sobre fondo oscuro), `SmallFrame` (marco con menos margen). `Panel` y `PanelContainer` usan el marco estándar.
- **Widgets**: `GridMenu` (`src/ui/widgets/grid_menu.gd`, menú en rejilla o lista con cursor, opciones desactivadas y `await choose(start, allow_cancel) -> int`), `CursorArrow` (`src/ui/widgets/cursor_arrow.gd`, flecha de menú o de "continuar"), `DialogueBox` (`src/ui/dialogue/dialogue_box.tscn`, cuadro de texto reutilizable: `await play(text, speaker_name, wait_last)`) y `ChoiceBox` (`src/ui/dialogue/choice_box.tscn`, lista de opciones: `await choose(options, cancel_choice) -> int`).
- Pantallas de uso común **(previsto)**:

```gdscript
var name: String = await NameEntry.open(title: String, default_name := "", max_length := 10)
await ShopScreen.open(shop_id: StringName)     # data/shops.json
await PartyScreen.open(mode := PartyScreen.Mode.VIEW) -> int   # índice elegido o -1
await BagScreen.open(mode := BagScreen.Mode.FIELD) -> StringName  # id del objeto o &""
```

- Comandos de Debug del Agente 3: `dialogue <texto>`, `bgm [id]`, `se <id>`, `me <id>`, `volume <bus> <0-100>` y `audio` (audios que faltan). **(Previsto)**: `giveitem <id> [n]`.

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
- Lectura: `TrainerData.get_trainer(id) -> Dictionary` (el entrenador combinado con su clase: `display_name`, `class_name`, `gender`, `battle_sprite`, `overworld_sprite`, `intro_bgm`, `battle_bgm`, `ai_level`, `base_money`), `TrainerData.get_trainer_class(id)` y `TrainerData.exists(id)` (`src/overworld/trainers/trainer_data.gd`). `DataDB` también carga estos archivos tal cual.

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
