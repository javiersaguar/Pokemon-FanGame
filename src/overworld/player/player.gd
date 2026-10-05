@tool
class_name Player
extends Character
## Jugador: movimiento por casillas, interacción, menú y cámara.
## Tras cada paso: warp → EventBus.player_stepped → disparador → encuentro salvaje.

## Pulsación más corta que esto en una dirección nueva = solo girar.
const TURN_DELAY := 0.1
## Capas en las que se buscan cosas que examinar: entidades y disparadores.
const INTERACT_MASK := 2 | 4
## Hojas del protagonista por sexo: [andar, correr] (provisionales: Ethan y Lyra
## del pack 05).
const SHEETS: Dictionary[StringName, Array] = {
	&"male": ["res://assets/sprites/characters/player_male.png",
		"res://assets/sprites/characters/player_male_run.png"],
	&"female": ["res://assets/sprites/characters/player_female.png",
		"res://assets/sprites/characters/player_female_run.png"],
}

var _walking := false
var _interacting := false
var _was_blocked := false
var _turn_pending := false
var _turn_time := 0.0

@onready var camera: Camera2D = $Camera2D


func _ready() -> void:
	super()
	if Engine.is_editor_hint():
		return
	refresh_appearance()
	EventBus.map_will_change.connect(_on_map_will_change)
	# También cuando lo mueve una cinemática: GameState siempre sabe dónde está.
	step_finished.connect(func(_tile: Vector2i) -> void: _sync_state())


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if _walking or _interacting or moving or GameState.input_locked or SceneManager.is_busy():
		_was_blocked = true
		_turn_pending = false
		return
	# Un frame de margen al quedar libre: la pulsación que cerró un diálogo o
	# un menú no debe volver a interactuar.
	if _was_blocked:
		_was_blocked = false
		return
	if Input.is_action_just_pressed(&"menu"):
		SceneManager.open_pause_menu()
		return
	if Input.is_action_just_pressed(&"accept"):
		_interact()
		return
	var dir := read_direction()
	if dir == Vector2i.ZERO:
		_turn_pending = false
		return
	if dir != facing:
		_turn(dir)
		return
	if _turn_pending:
		_turn_time += delta
		if _turn_time < TURN_DELAY:
			return
		_turn_pending = false
	_walk(dir)


func _unhandled_input(event: InputEvent) -> void:
	# Evento único: también durante un paso; la velocidad cambia en el siguiente.
	if Engine.is_editor_hint() or event.is_echo() or not event.is_action_pressed(&"run_toggle"):
		return
	if _interacting or GameState.input_locked or SceneManager.is_busy():
		return
	GameState.set_always_run(not GameState.always_run)
	get_viewport().set_input_as_handled()

## Sprite según el sexo elegido (GameState.player_gender).
func refresh_appearance() -> void:
	var paths: Array = SHEETS.get(GameState.player_gender, SHEETS[&"male"])
	var mode := FieldActions.transport()
	var transport_sheet := FieldActions.sheet_path(mode, GameState.player_gender)
	if mode != &"walk" and not transport_sheet.is_empty() and ResourceLoader.exists(transport_sheet):
		run_sprite_sheet = null
		sprite_sheet = load(transport_sheet)
	else:
		GameState.set_var(&"transport", "walk")
		run_sprite_sheet = load(paths[1])
		sprite_sheet = load(paths[0])
	if is_node_ready():
		ray.collision_mask = BLOCKING_MASK & ~8 if FieldActions.transport() == &"surf" else BLOCKING_MASK


func place_at(tile: Vector2i, dir: Vector2i = Vector2i.ZERO) -> void:
	super(tile, dir)
	_sync_state()


func face(dir: Vector2i) -> void:
	super(dir)
	if is_node_ready() and not Engine.is_editor_hint():
		GameState.player_facing = facing


## Ajusta la cámara al mapa: límites en sus bordes (centrada si el mapa es más
## pequeño que la pantalla) o fija en el centro si data.fixed_camera y el mapa
## cabe entero. El mundo se ve a ×2 (zoom de la cámara, Fase 3.2).
func setup_camera(map: MapRoot) -> void:
	var bounds := map.get_bounds()
	var view := Vector2i(get_viewport_rect().size / camera.zoom)
	var fits := bounds.size.x <= view.x and bounds.size.y <= view.y
	var fixed := map.data != null and map.data.fixed_camera and fits
	camera.top_level = fixed
	if fixed:
		camera.global_position = map.to_global(Vector2(bounds.get_center()))
		_set_camera_limits(Rect2i(-10000000, -10000000, 20000000, 20000000))
	else:
		camera.position = Vector2.ZERO
		_set_camera_limits(_fit_bounds(bounds, view))
	camera.make_current()
	camera.reset_smoothing()
	camera.force_update_scroll()


static func read_direction() -> Vector2i:
	if Input.is_action_pressed(&"move_up"):
		return Vector2i.UP
	if Input.is_action_pressed(&"move_down"):
		return Vector2i.DOWN
	if Input.is_action_pressed(&"move_left"):
		return Vector2i.LEFT
	if Input.is_action_pressed(&"move_right"):
		return Vector2i.RIGHT
	return Vector2i.ZERO


# --- Movimiento ---

func _turn(dir: Vector2i) -> void:
	face(dir)
	_sync_state()
	_turn_pending = true
	_turn_time = 0.0


## Encadena pasos mientras se mantenga una dirección (sin parones entre casillas).
func _walk(dir: Vector2i) -> void:
	_walking = true
	while dir != Vector2i.ZERO:
		var map := get_map_root()
		var connection := map.connection_at(tile_position() + dir) if map else null
		if connection:
			await SceneManager.cross_connection(connection, tile_position() + dir, dir)
			break
		var mode := FieldActions.transport()
		var running := running_requested(Input.is_action_pressed(&"run"))
		var duration := RUN_TIME if running or mode in [&"bike", &"surf"] else WALK_TIME
		if map and map.terrain_at(tile_position() + dir) == "waterfall" and not FieldActions.available(&"waterfall", map):
			break
		if _can_jump(dir):
			AudioManager.play_se(&"jump")
			await jump(dir)
		elif not await step(dir, duration, Debug.noclip, running):
			AudioManager.play_se(&"bump")
			await bump(dir)
			_sync_state()
			break
		if not await _after_step():
			break
		if GameState.input_locked or SceneManager.is_busy() or not is_inside_tree():
			break
		dir = read_direction()
	_walking = false


## Bordillo delante (terreno ledge_<dirección>) y casilla libre detrás: se salta.
func _can_jump(dir: Vector2i) -> bool:
	var map := get_map_root()
	if map == null or map.terrain_at(tile_position() + dir) != "ledge_" + Grid.dir_name(dir):
		return false
	var landing := tile_position() + dir * 2
	return map.terrain_at(landing) != "ledge_" + Grid.dir_name(dir) and is_tile_free(landing)


## Devuelve false si el paso ha llevado a otra cosa (warp, combate, evento) y
## hay que dejar de andar.
func _after_step() -> bool:
	_sync_state()
	var tile := tile_position()
	var map := get_map_root()
	if map == null:
		return false
	var warp := map.warp_at(tile)
	if warp and warp.is_valid():
		if warp.sound != &"":
			AudioManager.play_se(warp.sound)
		await SceneManager.change_map(warp.target_map, warp.target_spawn, warp.get_arrival_facing())
		return false
	if FieldActions.transport() == &"surf" and map.terrain_at(tile) not in ["water", "waterfall"]:
		set_transport_mode(&"walk")
	EventBus.player_stepped.emit(tile)
	if GameState.input_locked:
		return false
	var trigger := map.trigger_at(tile)
	if trigger:
		await Cutscene.play(trigger.event, trigger, trigger.event_params, trigger.once_flag)
		return false
	var repel_active := GameState.var_int(WildEncounters.REPEL_VAR) > 0
	var wild := WildEncounters.roll(map, tile, &"water" if FieldActions.transport() == &"surf" else &"land")
	if map.is_encounter_tile(tile) and not Debug.encounters_disabled:
		var roaming := WorldRoamers.roll(map, WildEncounters._lead_level() if repel_active else 0)
		if not roaming.is_empty():
			await SceneManager.start_battle(BattleSetup.wild(roaming.pokemon), {"roamer_id": roaming.id})
			return false
	if not wild.is_empty():
		await SceneManager.start_battle(WildEncounters.make_setup(wild))
		return false
	return true


func _sync_state() -> void:
	GameState.player_tile = tile_position()
	GameState.player_facing = facing


# --- Interacción ---

func _interact() -> void:
	var front := tile_position() + facing
	var target := find_entity_at(front)
	var map := get_map_root()
	# Por encima de un mostrador se habla con quien está detrás.
	if target == null and map and map.terrain_at(front) == "counter":
		target = find_entity_at(front + facing)
	if target == null:
		if map and map.terrain_at(front) == "water" and FieldActions.transport() != &"surf" and FieldActions.available(&"surf", map):
			if await Dialogue.ask_yes_no("¿Quieres hacer Surf?"):
				set_transport_mode(&"surf")
		return
	_interacting = true
	GameState.lock_input(&"interact")
	# interact() es corrutina en casi todas las clases hijas, aunque la base no lo sea.
	@warning_ignore("redundant_await")
	await target.interact(self)
	_end_interaction()


## Si la interacción cambia de mapa (p. ej., derrota en un combate lanzado por un
## NPC), la corrutina del NPC muere con su mapa y no vuelve aquí: se cierra al
## cambiar de mapa.
func _end_interaction() -> void:
	if _interacting:
		_interacting = false
		GameState.unlock_input(&"interact")


func _on_map_will_change(_from_map: StringName, _to_map: StringName) -> void:
	_end_interaction()


## Primera entidad presente en la casilla `tile` (sin contar al jugador).
func find_entity_at(tile: Vector2i) -> MapEntity:
	var query := PhysicsPointQueryParameters2D.new()
	query.position = get_parent().to_global(Grid.to_world(tile))
	query.collision_mask = INTERACT_MASK
	query.collide_with_areas = true
	query.collide_with_bodies = true
	for hit: Dictionary in get_world_2d().direct_space_state.intersect_point(query, 8):
		var node := hit["collider"] as Node
		while node and not node is MapEntity:
			node = node.get_parent()
		if node and node != self and (node as MapEntity).is_present():
			return node as MapEntity
	return null


func get_map_root() -> MapRoot:
	return SceneManager.current_map


func running_requested(held: bool) -> bool:
	if FieldActions.transport() != &"walk":
		return false
	var map := get_map_root()
	if map and map.data and (not map.data.can_run or (not map.data.outdoor and map.data.fixed_camera)):
		return false
	return GameState.always_run != held

## A3 puede conectar el objeto de bicicleta/surf a esta API.
func set_transport_mode(mode: StringName) -> bool:
	var map := get_map_root()
	if mode == &"walk":
		if FieldActions.transport() == &"surf" and map and map.terrain_at(tile_position()) in ["water", "waterfall"]:
			return false
	elif mode not in [&"bike", &"surf"] or not FieldActions.available(mode, map):
		return false
	else:
		var sheet := FieldActions.sheet_path(mode, GameState.player_gender)
		if sheet.is_empty() or not ResourceLoader.exists(sheet):
			return false
	GameState.set_var(&"transport", String(mode))
	refresh_appearance()
	return true

# --- Cámara ---

func _set_camera_limits(rect: Rect2i) -> void:
	camera.limit_left = rect.position.x
	camera.limit_top = rect.position.y
	camera.limit_right = rect.end.x
	camera.limit_bottom = rect.end.y


## Si el mapa es más estrecho o más bajo que la pantalla, amplía los límites
## alrededor de su centro para que quede centrado.
static func _fit_bounds(bounds: Rect2i, view: Vector2i) -> Rect2i:
	var out := bounds
	if bounds.size.x < view.x:
		out.position.x = bounds.get_center().x - roundi(view.x / 2.0)
		out.size.x = view.x
	if bounds.size.y < view.y:
		out.position.y = bounds.get_center().y - roundi(view.y / 2.0)
		out.size.y = view.y
	return out
