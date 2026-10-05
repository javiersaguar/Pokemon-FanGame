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
const FOLLOWER_SCENE := "res://src/overworld/follower/follower.tscn"
const FLOW_FALLBACK_SCRIPT := "res://src/main/flow_fallback.gd"
const IDENTITY_FALLBACK_SCRIPT := "res://src/main/identity_fallback.gd"
const BattlePlaceholder := preload("res://src/main/battle_placeholder.gd")

const FADE_TIME := 0.25

var atmosphere: WorldAtmosphere
var world: Node2D
var battle_layer: CanvasLayer
var ui_layer: CanvasLayer
var transition_layer: CanvasLayer

var current_map: MapRoot
var player: Player
var is_changing_map := false
var in_battle := false
## Pokémon que sigue al jugador en el mapa actual (null si no hay).
var player_follower: Follower
## Última imagen del mundo sin interfaz (se toma al abrir el menú de pausa). La
## usa SaveManager para la miniatura de la ranura.
var world_snapshot: Image

var _fade: ColorRect
var _menus: Array[Node] = []
var _title: Node
var _flow_status: Node
var _nickname_entry: Node


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Cutscene.name_requested.connect(_on_name_requested)
	EventBus.locke_nickname_requested.connect(_on_locke_nickname)
	EventBus.locke_state_changed.connect(update_zone_indicator)
	EventBus.map_loaded.connect(func(_id: StringName) -> void: update_zone_indicator())


## La llama Main al arrancar. Main debe tener World, Battle, UI y Transition/Fade.
func register_main(main: Node) -> void:
	world = main.get_node(^"World")
	battle_layer = main.get_node(^"Battle")
	ui_layer = main.get_node(^"UI")
	transition_layer = main.get_node(^"Transition")
	_fade = transition_layer.get_node(^"Fade")
	atmosphere = WorldAtmosphere.new()
	world.add_child(atmosphere)


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
	else:
		await go_to_title()


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
		_title = load(FLOW_FALLBACK_SCRIPT).new()
		_title.kind = &"title"
		ui_layer.add_child(_title)
	await fade_in()


## Nueva partida. Sin argumentos usa data/world.json → new_game. `options`
## (todas opcionales, ver GameState.new_game()): slot (por defecto, la primera
## ranura vacía o la 1), mode, randomlocke y rom_patch. Con RandomLocke, el
## parche se aplica en DataDB antes de cargar el mapa (Fase R.9).
func start_new_game(map: StringName = &"", spawn: StringName = &"", options: Dictionary = {}) -> Error:
	if not options.has("slot"):
		options = options.duplicate()
		options["slot"] = maxi(SaveManager.first_empty_slot(), 1)
	var previous := GameState.to_dict()
	var old_slot := GameState.slot
	var was_in_game := GameState.in_game
	var old_rom := GameState.rom_patch.duplicate(true)
	GameState.new_game(options)
	var patch_error := SaveManager.apply_rom_patch()
	if patch_error != OK:
		GameState.rom_patch = old_rom
		GameState.from_dict(previous)
		GameState.slot = old_slot
		GameState.in_game = was_in_game
		return patch_error
	var cfg: Dictionary = MvpLocations.new_game_config()
	if map == &"":
		map = GameState.map_id
	if spawn == &"":
		spawn = StringName(cfg.get("spawn", MapRoot.DEFAULT_SPAWN))
	await fade_out()
	_enter_game()
	await change_map(map, spawn, GameState.player_facing)
	if bool(options.get("intro", false)):
		await Cutscene.play(load("res://src/events/mvp/mvp_story_event.gd"), null, {"stage": "intro"})
	return OK


## Carga la ranura y lleva al jugador a donde guardó.
func continue_game(slot: int) -> Error:
	if SaveManager.slot_summary(slot).get("status", "") == "finished":
		return ERR_UNAUTHORIZED
	var err := SaveManager.load_game(slot)
	if err != OK:
		return err
	await fade_out()
	_enter_game()
	await change_map_at(GameState.map_id, GameState.player_tile, GameState.player_facing)
	EventBus.game_loaded.emit(slot)
	resume_pending_nicknames()
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


func cross_connection(connection: MapConnection, tile: Vector2i, facing: Vector2i) -> Error:
	if not map_exists(connection.target_map):
		return ERR_FILE_NOT_FOUND
	var preview := load(MapRoot.path_from_id(connection.target_map)).instantiate() as MapRoot
	if preview == null or preview.get_ground() == null:
		if preview:
			preview.free()
		return ERR_INVALID_DATA
	var bounds := preview.get_ground().get_used_rect()
	var arrival := connection.arrival(tile, bounds)
	preview.free()
	if not bounds.has_point(arrival):
		return ERR_INVALID_DATA
	await change_map_at(connection.target_map, arrival, facing, false)
	return OK

func map_exists(map_id: StringName) -> bool:
	return ResourceLoader.exists(MapRoot.path_from_id(map_id))


## Todos los mapas de maps/ (para el Debug y los tests de humo).
func list_maps() -> Array[StringName]:
	return MapRoot.list_all()


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
func start_battle(setup: Variant, context: Dictionary = {}) -> StringName:
	if in_battle:
		push_error("SceneManager.start_battle: ya hay un combate en curso.")
		return OUTCOME_LOSE
	if GameState.is_randomlocke() and GameState.randomlocke.get("status") == "finished":
		return OUTCOME_LOSE
	var playable: Variant = prepare_battle(setup, context)
	in_battle = true
	GameState.lock_input(&"battle")
	EventBus.battle_started.emit(setup)
	await fade_out()
	var scene := _instantiate_battle_scene()
	battle_layer.add_child(scene)
	world.visible = false
	world.process_mode = Node.PROCESS_MODE_DISABLED
	await fade_in()

	var outcome: StringName = await scene.call(&"run", playable)
	if context.has("roamer_id") and setup is BattleSetup and not setup.foe_party.is_empty():
		WorldRoamers.resolve(StringName(context.roamer_id), setup.foe_party[0], outcome)

	await fade_out()
	scene.queue_free()
	world.visible = true
	world.process_mode = Node.PROCESS_MODE_INHERIT
	in_battle = false
	EventBus.battle_ended.emit(outcome)
	if GameState.is_randomlocke() and GameState.randomlocke.get("status") == "finished":
		if GameState.slot > 0:
			SaveManager.save_game()
		await fade_in()
	elif outcome == OUTCOME_LOSE and not _setup_can_lose(setup):
		await _whiteout()
	else:
		await fade_in()
	GameState.unlock_input(&"battle")
	return outcome


## Preparar antes de BattleScene: registrar la primera aparición antes de cualquier acción.
## tutorial=true excluye expresamente muerte/reglas; can_lose por sí solo no las excluye.
func prepare_battle(setup: Variant, context: Dictionary = {}) -> Variant:
	if not (setup is BattleSetup) or GameState.locke == null:
		return setup
	if bool(context.get("tutorial", false)):
		setup.tutorial = true
		setup.locke = null
		setup.locke_rules = false
		return setup
	context = context.duplicate(true)
	if not context.has("zone_id"):
		context["zone_id"] = String(current_map.get_zone_id()) if current_map else String(GameState.map_id)
	return LockeBattleDriver.new(setup, context)

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
		var fallback: Node = load(FLOW_FALLBACK_SCRIPT).new()
		fallback.kind = &"pause"
		push_menu(fallback)
		return
	push_menu((load(PAUSE_MENU_SCENE) as PackedScene).instantiate())


## Imagen de la pantalla tal como se ve ahora (null sin pantalla, en headless).
func capture_screen() -> Image:
	if DisplayServer.get_name() == "headless":
		return null
	return get_viewport().get_texture().get_image()


# --- Sustitutos de flujo: reutilizan Dialogue, sin fijar diseño de A3 ---

func choose_slot(overwrite: bool = false) -> int:
	var labels := PackedStringArray()
	for slot: int in range(1, SaveManager.slot_count() + 1):
		var summary := SaveManager.slot_summary(slot)
		labels.append("%d: %s" % [slot, summary.get("player_name", "Vacía")])
	labels.append("Volver")
	var index := await Dialogue.ask("Elige una ranura", labels)
	if index == labels.size() - 1:
		return 0
	var slot := index + 1
	if overwrite and SaveManager.has_save(slot):
		if not await Dialogue.ask_yes_no("Esta ranura ya tiene una partida. ¿Sobrescribirla al guardar?"):
			return 0
	return slot

func run_title_fallback() -> void:
	var screen := _title
	while not GameState.in_game and is_instance_valid(screen) and screen == _title:
		var option := await Dialogue.ask("Pokémon Panchito", ["Continuar", "Nueva partida", "Cargar partida", "Salir"])
		if not is_instance_valid(screen) or screen != _title:
			return
		match option:
			0:
				var slot := SaveManager.last_used_slot()
				var err: Error = await continue_game(slot) if slot > 0 else ERR_FILE_NOT_FOUND
				if err != OK:
					await Dialogue.say("No se puede continuar esta partida: %s." % error_string(err))
			1:
				var slot := await choose_slot(true)
				if slot > 0:
					await load("res://src/main/randomlocke_fallback.gd").new().run(slot)
			2:
				var slot := await choose_slot()
				if slot > 0:
					var err := await continue_game(slot)
					if err != OK:
						await Dialogue.say("No se puede cargar: %s." % error_string(err))
			3:
				get_tree().quit()
				return

func run_pause_fallback(menu: Node) -> void:
	var choice := await Dialogue.ask("Menú de pausa", ["Volver", "Guardar", "Cargar partida", "Menú inicial"], null, 0)
	match choice:
		1:
			var err := SaveManager.save_game()
			await Dialogue.say("Partida guardada." if err == OK else "No se pudo guardar: %s." % error_string(err))
		2:
			var slot := await choose_slot()
			if slot > 0:
				var err := await continue_game(slot)
				if err != OK:
					await Dialogue.say("No se puede cargar: %s." % error_string(err))
		3:
			if await Dialogue.ask_yes_no("¿Volver al menú inicial? El progreso sin guardar se perderá."):
				pop_menu(menu)
				await go_to_title()
				return
	pop_menu(menu)

func _on_name_requested(kind: StringName, initial: String) -> void:
	# Una pantalla A3 conectada toma precedencia sobre el sustituto.
	if not is_instance_valid(ui_layer) or Cutscene.name_requested.get_connections().size() > 1:
		return
	var entry: Node = load(IDENTITY_FALLBACK_SCRIPT).new()
	entry.kind = kind
	entry.initial = initial
	ui_layer.add_child(entry)


## API de A3: ROM ya generada, settings y familias de la misma entrada explícita.
func start_randomlocke(rom: RomPatch, slot: int, intro: bool = true) -> Error:
	if rom == null or not rom.errors.is_empty() or rom.generator_version() != Randomizer.GENERATOR_VERSION:
		return ERR_INVALID_DATA
	var input := rom.input if rom.input != null else RandomizerInput.from_datadb()
	return await start_new_game(&"", &"", {"slot": slot, "intro": intro, "mode": GameState.MODE_RANDOMLOCKE,
		"rom_patch": rom.to_dict(), "randomlocke": {"seed_code": rom.seed_code(), "settings": rom.data.settings,
		"families": input.families(rom)}})

func request_text(prompt: String, initial: String = "", placeholder: String = "", allow_cancel: bool = false) -> String:
	var entry: Node = load(IDENTITY_FALLBACK_SCRIPT).new()
	entry.prompt = prompt
	entry.initial = initial
	entry.placeholder = placeholder
	entry.allow_cancel = allow_cancel
	entry.submit = func(_value: String) -> bool: return true
	ui_layer.add_child(entry)
	return await entry.completed

func _on_locke_nickname(token: String, pokemon: Dictionary) -> void:
	if not is_instance_valid(ui_layer) or EventBus.locke_nickname_requested.get_connections().size() > 1 or is_instance_valid(_nickname_entry):
		return
	var entry: Node = load(IDENTITY_FALLBACK_SCRIPT).new()
	_nickname_entry = entry
	entry.kind = &"nickname"
	entry.prompt = "Elige un mote para %s" % DataDB.species(StringName(pokemon.species)).name
	entry.submit = func(value: String) -> bool:
		return GameState.locke != null and not GameState.locke.complete_capture(token, value).is_empty()
	entry.completed.connect(func(_value: String) -> void:
		_nickname_entry = null
		resume_pending_nicknames.call_deferred())
	ui_layer.add_child(entry)

func resume_pending_nicknames() -> void:
	if GameState.locke != null and not GameState.locke.pending.is_empty():
		var token: String = GameState.locke.pending.keys()[0]
		_on_locke_nickname(token, GameState.locke.pending[token].pokemon)

func show_flow_status(text: String) -> void:
	if not is_instance_valid(_flow_status):
		_flow_status = load("res://src/main/flow_status.gd").new()
		ui_layer.add_child(_flow_status)
	_flow_status.show_text(text)

func hide_flow_status() -> void:
	if is_instance_valid(_flow_status):
		_flow_status.hide()

func update_zone_indicator() -> void:
	if GameState.locke == null or not is_instance_valid(current_map) or not GameState.in_game:
		hide_flow_status()
		return
	var zone := String(current_map.get_zone_id())
	var status := GameState.locke.rules.zone_status(zone)
	EventBus.locke_zone_entered.emit(zone, status)
	# Una UI de A3 conectada toma la presentación.
	if EventBus.locke_zone_entered.get_connections().is_empty():
		var labels := {"available": "disponible", "caught": "capturada", "lost": "perdida", "pending": "pendiente"}
		var enabled := bool(GameState.locke.rules.rules().get("locke_rules", true)) and bool(GameState.locke.rules.rules().get("first_encounter", true))
		show_flow_status("%s / Captura: %s" % [current_map.get_display_name(), labels.get(status, status)] if enabled else "%s / Sin límite de zona" % current_map.get_display_name())


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
	WorldTravel.record_visit(map)
	WorldRoamers.move_on_transition(from_map)
	atmosphere.apply_map(map)
	EventBus.map_loaded.emit(map_id)

	await fade_in()
	is_changing_map = false
	GameState.unlock_input(&"map_change")
	# Evita esperar un evento nuevo dentro de la cinemática que teletransporta.
	_run_enter_triggers(map)

func _run_enter_triggers(map: MapRoot) -> void:
	if Cutscene.is_running():
		await Cutscene.event_finished
	if not is_instance_valid(map) or current_map != map:
		return
	for trigger: Trigger in map.enter_triggers():
		if is_instance_valid(trigger) and current_map == map and trigger.can_fire():
			await Cutscene.play(trigger.event, trigger, trigger.event_params, trigger.once_flag)


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
	var mode := FieldActions.transport()
	if (mode == &"bike" and not FieldActions.available(&"bike", current_map)) or (mode == &"surf" and current_map.terrain_at(tile) not in ["water", "waterfall"]):
		player.set_transport_mode(&"walk")
	player.refresh_appearance()
	player.setup_camera(current_map)
	_spawn_player_follower(parent)


## El Pokémon que te sigue: el primero del equipo que pueda luchar (Fase 14.5), si
## el mapa lo permite, está activado en data/world.json → followers.enabled y hay hoja.
func _spawn_player_follower(parent: Node) -> void:
	player_follower = null
	var cfg: Dictionary = GameState.world_config.get("followers", {})
	if not bool(cfg.get("enabled", true)) or (current_map.data and not current_map.data.followers_allowed):
		return
	var lead: Variant = _first_able_pokemon()
	if lead == null or not Follower.has_sheet(lead.species_id, lead.shiny):
		return
	var follower := (load(FOLLOWER_SCENE) as PackedScene).instantiate() as Follower
	follower.name = &"PlayerFollower"
	parent.add_child(follower)
	follower.species = lead.species_id
	follower.shiny = lead.shiny
	follower.follow(player)
	follower.appear()
	player_follower = follower


static func _first_able_pokemon() -> Variant:
	var party: Variant = GameState.party
	if not (party is Object and &"members" in party):
		return null
	for p: Variant in party.members:
		if p.current_hp > 0:
			return p
	return null


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
	if is_instance_valid(ui_layer):
		for node: Node in ui_layer.get_children():
			if node.get_script() in [load(IDENTITY_FALLBACK_SCRIPT), load("res://src/main/flow_status.gd")]:
				node.queue_free()
	_nickname_entry = null
	_flow_status = null
	if is_instance_valid(atmosphere):
		atmosphere.reset()
	if is_instance_valid(_title):
		_title.queue_free()
	_title = null
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
	if GameState.locke != null:
		GameState.locke.remove_dead()
		if GameState.locke.check_game_over():
			return
		# Recuperar un superviviente del PC si el equipo quedó vacío.
		if GameState.party.is_empty():
			for pokemon: Pokemon in WorldLocke.usable_pokemon():
				var where: Vector2i = GameState.pc.find_uid(pokemon.uid)
				if where != PCStorage.NO_SLOT and pokemon.current_hp > 0:
					GameState.party.add(GameState.pc.take(where.x, where.y))
					break
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


static func _parse_user_args() -> Dictionary:
	var out := {}
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--") and "=" in arg:
			var parts := arg.substr(2).split("=", true, 1)
			out[parts[0]] = parts[1]
	return out
