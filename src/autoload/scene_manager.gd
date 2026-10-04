extends Node
## Cambios de mapa con fundido, entrada y salida de combate, pila de menús y
## flujo de partida (título, nueva partida, continuar).
## Contrato: docs/contratos.md (sección SceneManager).

## Resultados de start_battle().
const OUTCOME_WIN := &"win"
const OUTCOME_LOSE := &"lose"
const OUTCOME_RUN := &"run"
const OUTCOME_CAUGHT := &"caught"

## Escenas de otros agentes. Mientras no existan, se usa un sustituto o se omiten.
const TITLE_SCENE := "res://src/ui/title/title_screen.tscn"
const PAUSE_MENU_SCENE := "res://src/ui/pause_menu/pause_menu.tscn"
const BATTLE_SCENE := "res://src/battle/scene/battle_scene.tscn"
const PLAYER_SCENE := "res://src/overworld/player/player.tscn"
const BattlePlaceholder := preload("res://src/main/battle_placeholder.gd")

const FADE_TIME := 0.25

var world: Node2D
var battle_layer: CanvasLayer
var ui_layer: CanvasLayer
var transition_layer: CanvasLayer

var current_map: MapRoot
var player: Player
var is_changing_map := false
var in_battle := false
## Última imagen del mundo sin interfaz (se toma al abrir el menú de pausa). La
## usa SaveManager para la miniatura de la ranura.
var world_snapshot: Image

var _fade: ColorRect
var _menus: Array[Node] = []
var _title: Node


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


## La llama Main al arrancar. Main debe tener World, Battle, UI y Transition/Fade.
func register_main(main: Node) -> void:
	world = main.get_node(^"World")
	battle_layer = main.get_node(^"Battle")
	ui_layer = main.get_node(^"UI")
	transition_layer = main.get_node(^"Transition")
	_fade = transition_layer.get_node(^"Fade")


## Primer flujo del juego. Argumentos de línea de comandos (tras `--`):
##   --map=<map_id> [--spawn=<spawn_id>]  nueva partida directamente en ese mapa
##   --load=<slot>                        carga esa ranura
func boot() -> void:
	var args := _parse_user_args()
	if args.has("load"):
		var err: Error = await continue_game(int(args["load"]))
		if err == OK:
			return
	if args.has("map"):
		await start_new_game(StringName(args["map"]), StringName(args.get("spawn", "")))
	elif ResourceLoader.exists(TITLE_SCENE):
		await go_to_title()
	else:
		await start_new_game()


func is_busy() -> bool:
	return is_changing_map or in_battle


# --- Flujo de partida ---

func go_to_title() -> void:
	await fade_out()
	_leave_game()
	if ResourceLoader.exists(TITLE_SCENE):
		_title = (load(TITLE_SCENE) as PackedScene).instantiate()
		ui_layer.add_child(_title)
	else:
		push_warning("SceneManager: falta la pantalla de título (%s)." % TITLE_SCENE)
	await fade_in()


## Nueva partida. Sin argumentos usa data/world.json → new_game. `options`
## (todas opcionales, ver GameState.new_game()): slot (por defecto, la primera
## ranura vacía o la 1), mode, randomlocke y rom_patch. Con RandomLocke, el
## parche se aplica en DataDB antes de cargar el mapa (Fase R.9).
func start_new_game(map: StringName = &"", spawn: StringName = &"", options: Dictionary = {}) -> void:
	if not options.has("slot"):
		options = options.duplicate()
		options["slot"] = maxi(SaveManager.first_empty_slot(), 1)
	GameState.new_game(options)
	SaveManager.apply_rom_patch()
	var cfg: Dictionary = GameState.world_config.get("new_game", {})
	if map == &"":
		map = GameState.map_id
	if spawn == &"":
		spawn = StringName(cfg.get("spawn", MapRoot.DEFAULT_SPAWN))
	await fade_out()
	_enter_game()
	await change_map(map, spawn, GameState.player_facing)


## Carga la ranura y lleva al jugador a donde guardó.
func continue_game(slot: int) -> Error:
	var err := SaveManager.load_game(slot)
	if err != OK:
		return err
	await fade_out()
	_enter_game()
	await change_map_at(GameState.map_id, GameState.player_tile, GameState.player_facing)
	EventBus.game_loaded.emit(slot)
	return OK


# --- Mapas ---

## Cambia al mapa `map_id` y coloca al jugador en el spawn `spawn_id`.
## `facing` = Vector2i.ZERO mantiene la dirección actual del jugador.
func change_map(map_id: StringName, spawn_id: StringName = MapRoot.DEFAULT_SPAWN,
		facing: Vector2i = Vector2i.ZERO, fade: bool = true) -> void:
	var resolve_tile := func(map: MapRoot) -> Vector2i:
		var spawn := map.get_spawn(spawn_id)
		return Grid.to_tile(map.to_local(spawn.global_position)) if spawn else Vector2i.ZERO
	await _change_map(map_id, resolve_tile, facing, fade)


## Como change_map(), pero en una casilla concreta (cargar partida, Debug...).
func change_map_at(map_id: StringName, tile: Vector2i, facing: Vector2i = Vector2i.ZERO,
		fade: bool = true) -> void:
	await _change_map(map_id, func(_map: MapRoot) -> Vector2i: return tile, facing, fade)


func map_exists(map_id: StringName) -> bool:
	return ResourceLoader.exists(MapRoot.path_from_id(map_id))


## Todos los mapas de maps/ (para el Debug y los tests de humo).
func list_maps() -> Array[StringName]:
	var out: Array[StringName] = []
	_collect_maps(MapRoot.MAPS_DIR, out)
	out.sort_custom(func(a: StringName, b: StringName) -> bool: return String(a) < String(b))
	return out


# --- Fundidos ---

func fade_out(duration: float = FADE_TIME, color: Color = Color.BLACK) -> void:
	_fade.visible = true
	_fade.color = Color(color, _fade.color.a)
	if is_equal_approx(_fade.color.a, 1.0):
		return
	var tween := create_tween()
	tween.tween_property(_fade, ^"color:a", 1.0, duration)
	await tween.finished


func fade_in(duration: float = FADE_TIME) -> void:
	if _fade.visible:
		var tween := create_tween()
		tween.tween_property(_fade, ^"color:a", 0.0, duration)
		await tween.finished
	_fade.visible = false


# --- Combate ---

## Abre la BattleScene con `setup` (BattleSetup del Agente 2) y espera a que
## termine. Devuelve uno de los OUTCOME_*. Si el jugador pierde y el combate no
## se puede perder (setup.can_lose == false), vuelve al último Centro Pokémon.
func start_battle(setup: Variant) -> StringName:
	if in_battle:
		push_error("SceneManager.start_battle: ya hay un combate en curso.")
		return OUTCOME_LOSE
	in_battle = true
	GameState.lock_input(&"battle")
	EventBus.battle_started.emit(setup)
	await fade_out()
	var scene := _instantiate_battle_scene()
	battle_layer.add_child(scene)
	world.visible = false
	world.process_mode = Node.PROCESS_MODE_DISABLED
	await fade_in()

	var outcome: StringName = await scene.call(&"run", setup)

	await fade_out()
	scene.queue_free()
	world.visible = true
	world.process_mode = Node.PROCESS_MODE_INHERIT
	in_battle = false
	EventBus.battle_ended.emit(outcome)
	if outcome == OUTCOME_LOSE and not _setup_can_lose(setup):
		await _whiteout()
	else:
		await fade_in()
	GameState.unlock_input(&"battle")
	return outcome


# --- Menús ---

## Abre `menu` encima de los demás (en la capa UI) y bloquea el control del jugador.
func push_menu(menu: Node) -> void:
	_menus.append(menu)
	ui_layer.add_child(menu)
	GameState.lock_input(&"menu")
	EventBus.menu_opened.emit(menu)


## Cierra `menu` (por defecto, el de arriba). Si el nuevo menú de arriba tiene
## el método menu_resumed(), se le llama para que recupere el foco.
func pop_menu(menu: Node = null) -> void:
	if _menus.is_empty():
		return
	if menu == null:
		menu = _menus.back()
	var index := _menus.find(menu)
	if index == -1:
		push_error("SceneManager.pop_menu: ese menú no está abierto.")
		return
	_menus.remove_at(index)
	menu.queue_free()
	GameState.unlock_input(&"menu")
	EventBus.menu_closed.emit(menu)
	var top := top_menu()
	if top and top.has_method(&"menu_resumed"):
		top.call(&"menu_resumed")


func top_menu() -> Node:
	return _menus.back() if not _menus.is_empty() else null


func is_menu_open() -> bool:
	return not _menus.is_empty()


func close_all_menus() -> void:
	while not _menus.is_empty():
		pop_menu()


## Menú de pausa del Agente 3 (lo abre el jugador con la acción `menu`).
func open_pause_menu() -> void:
	world_snapshot = capture_screen()
	if not ResourceLoader.exists(PAUSE_MENU_SCENE):
		push_warning("SceneManager: falta el menú de pausa (%s)." % PAUSE_MENU_SCENE)
		return
	push_menu((load(PAUSE_MENU_SCENE) as PackedScene).instantiate())


## Imagen de la pantalla tal como se ve ahora (null sin pantalla, en headless).
func capture_screen() -> Image:
	if DisplayServer.get_name() == "headless":
		return null
	return get_viewport().get_texture().get_image()


# --- Internos ---

func _change_map(map_id: StringName, resolve_tile: Callable, facing: Vector2i,
		fade: bool) -> void:
	var path := MapRoot.path_from_id(map_id)
	if not ResourceLoader.exists(path):
		push_error("SceneManager: no existe el mapa '%s' (%s)." % [map_id, path])
		await fade_in()
		return
	if is_changing_map:
		push_warning("SceneManager: ya se está cambiando de mapa; se ignora '%s'." % map_id)
		return
	is_changing_map = true
	GameState.lock_input(&"map_change")
	if fade:
		await fade_out()

	var from_map: StringName = current_map.get_map_id() if current_map else &""
	EventBus.map_will_change.emit(from_map, map_id)
	_unload_map()
	var instance := (load(path) as PackedScene).instantiate()
	var map := instance as MapRoot
	if map == null:
		push_error("SceneManager: la raíz de '%s' no usa map_root.gd." % path)
		instance.free()
		map = MapRoot.new()
	world.add_child(map)
	current_map = map
	if map.get_map_id() != map_id:
		push_warning("SceneManager: '%s' tiene data.id = '%s'." % [path, map.get_map_id()])
	GameState.map_id = map_id
	_place_player(resolve_tile.call(map), facing)
	if map.data and map.data.bgm != &"":
		AudioManager.play_bgm(map.data.bgm)
	EventBus.map_loaded.emit(map_id)

	await fade_in()
	is_changing_map = false
	GameState.unlock_input(&"map_change")


func _place_player(tile: Vector2i, facing: Vector2i) -> void:
	if facing == Vector2i.ZERO:
		facing = GameState.player_facing
	GameState.player_tile = tile
	GameState.player_facing = facing
	if player == null:
		return
	var parent: Node = current_map.get_entities()
	if parent == null:
		parent = current_map
	if player.get_parent():
		player.get_parent().remove_child(player)
	parent.add_child(player)
	player.place_at(tile, facing)
	player.setup_camera(current_map)


func _unload_map() -> void:
	if current_map == null:
		return
	if player and player.get_parent():
		player.get_parent().remove_child(player)
	world.remove_child(current_map)
	current_map.queue_free()
	current_map = null


func _enter_game() -> void:
	if _title:
		_title.queue_free()
		_title = null
	close_all_menus()
	if player == null:
		player = (load(PLAYER_SCENE) as PackedScene).instantiate()
	player.refresh_appearance()
	GameState.in_game = true


func _leave_game() -> void:
	close_all_menus()
	_unload_map()
	if player:
		player.queue_free()
		player = null
	GameState.clear_input_locks()
	GameState.reset()
	SaveManager.apply_rom_patch()
	world_snapshot = null


## Derrota: el equipo se cura y vuelves al último Centro Pokémon.
func _whiteout() -> void:
	if GameState.party is Object and GameState.party.has_method(&"heal_all"):
		GameState.party.heal_all()
	var target := GameState.healing_map
	if target == &"" or not map_exists(target):
		target = GameState.map_id
	await change_map(target, GameState.healing_spawn, Vector2i.DOWN, false)


func _instantiate_battle_scene() -> Node:
	if ResourceLoader.exists(BATTLE_SCENE):
		return (load(BATTLE_SCENE) as PackedScene).instantiate()
	return BattlePlaceholder.new()


static func _setup_can_lose(setup: Variant) -> bool:
	if setup is Object and &"can_lose" in setup:
		return setup.can_lose
	if setup is Dictionary:
		return setup.get("can_lose", false)
	return false


func _collect_maps(dir_path: String, out: Array[StringName]) -> void:
	for entry: String in ResourceLoader.list_directory(dir_path):
		if entry.ends_with("/"):
			_collect_maps(dir_path + entry, out)
		elif entry.ends_with(".tscn"):
			out.append(MapRoot.id_from_path(dir_path + entry))


static func _parse_user_args() -> Dictionary:
	var out := {}
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--") and "=" in arg:
			var parts := arg.substr(2).split("=", true, 1)
			out[parts[0]] = parts[1]
	return out
