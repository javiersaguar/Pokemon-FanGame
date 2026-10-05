extends Node
## Estado de la partida: todo lo que se guarda y lo que consultan los eventos.
## Contrato: docs/contratos.md (sección GameState).

## Súbelo cada vez que cambie el formato de to_dict() y añade la migración
## correspondiente en SaveManager.
const SAVE_VERSION := 2
const WORLD_CONFIG_PATH := "res://data/world.json"

## Modos de partida (Fase R): normal o RandomLocke.
const MODE_NORMAL := &"normal"
const MODE_RANDOMLOCKE := &"randomlocke"

## Módulos de otros agentes que viven dentro de GameState. Cada clase se busca por
## su class_name; si todavía no existe, sus datos se conservan tal cual al guardar.
## Requisitos de cada clase: `new()` sin argumentos, `to_dict() -> Dictionary` y
## `from_dict(data: Dictionary) -> void`.
const MODULE_CLASSES: Dictionary[StringName, StringName] = {
	&"party": &"Party",
	&"pc": &"PCStorage",
	&"pokedex": &"Pokedex",
	&"bag": &"Bag",
}

# --- Partida ---
## MODE_NORMAL o MODE_RANDOMLOCKE. Se elige al crear la partida y no cambia.
var mode: StringName = MODE_NORMAL
## Datos del RandomLocke (vacío en modo normal): seed_code, settings,
## generator_version, rules, zones {zone_id: estado}, deaths y status.
var randomlocke: Dictionary = {}

# --- Jugador ---
var player_name: String = ""
var player_gender: StringName = &"male"
var rival_name: String = ""
var trainer_id: int = 0
var secret_id: int = 0
var money: int = 0
var badges: Array[StringName] = []
## Tiempo jugado en segundos.
var play_time: float = 0.0

# --- Posición ---
var map_id: StringName = &""
var player_tile: Vector2i = Vector2i.ZERO
var player_facing: Vector2i = Vector2i.DOWN
## Dónde reapareces al perder (lo fija la enfermera del Centro Pokémon).
var healing_map: StringName = &""
var healing_spawn: StringName = &""

# --- Historia (registro de claves en docs/flags.md) ---
var flags: Dictionary[StringName, bool] = {}
var vars: Dictionary[StringName, Variant] = {}

# --- Módulos (ver MODULE_CLASSES) ---
var party: Variant = null
var pc: Variant = null
var pokedex: Variant = null
var bag: Variant = null

# --- Solo en ejecución (no se guarda en el JSON de la partida) ---
## Contenido de data/world.json.
var world_config: Dictionary = {}
## Ranura de la partida en curso (0 = ninguna). La fijan SaveManager y SceneManager.
var slot: int = 0
## Parche de la ROM del RandomLocke (Fase R.1). SaveManager lo guarda aparte,
## en slot_<n>.rom.json.
var rom_patch: Dictionary = {}
## Adaptador del mundo; snapshot persistido dentro de randomlocke.
var locke: WorldLocke
## true cuando hay al menos un bloqueo activo (menú, diálogo, cinemática...).
var input_locked: bool:
	get:
		return not _input_locks.is_empty()
## Se activa al entrar en una partida; el tiempo jugado solo corre si es true.
var in_game: bool = false

var _input_locks: Dictionary[StringName, int] = {}


func _ready() -> void:
	world_config = JsonFile.read_dict(WORLD_CONFIG_PATH)
	reset()


func _process(delta: float) -> void:
	if in_game:
		play_time += delta


## Deja el estado vacío (sin partida).
func reset() -> void:
	locke = null
	unlock_input(&"locke_finished")
	unlock_input(&"locke_nickname")
	mode = MODE_NORMAL
	randomlocke = {}
	slot = 0
	rom_patch = {}
	player_name = ""
	player_gender = &"male"
	rival_name = ""
	trainer_id = 0
	secret_id = 0
	money = 0
	badges = []
	play_time = 0.0
	map_id = &""
	player_tile = Vector2i.ZERO
	player_facing = Vector2i.DOWN
	healing_map = &""
	healing_spawn = &""
	flags = {}
	vars = {}
	for key: StringName in MODULE_CLASSES:
		set(key, _new_module(key))
	in_game = false


## Estado inicial de una partida nueva según data/world.json → new_game.
## `options` (todas opcionales): slot (int), mode (MODE_*), randomlocke
## (Dictionary) y rom_patch (Dictionary, el parche de la ROM ya generado).
func new_game(options: Dictionary = {}) -> void:
	reset()
	slot = int(options.get("slot", 0))
	mode = StringName(options.get("mode", MODE_NORMAL))
	randomlocke = (options.get("randomlocke", {}) as Dictionary).duplicate(true)
	rom_patch = options.get("rom_patch", {})
	if is_randomlocke():
		randomlocke.merge({"zones": {}, "deaths": 0, "status": "in_progress"})
	var cfg: Dictionary = world_config.get("new_game", {})
	trainer_id = randi_range(0, 65535)
	secret_id = randi_range(0, 65535)
	money = int(cfg.get("money", 0))
	map_id = StringName(cfg.get("map", ""))
	player_facing = dir_from_name(cfg.get("facing", "down"))
	healing_map = StringName(cfg.get("healing_map", cfg.get("map", "")))
	healing_spawn = StringName(cfg.get("healing_spawn", cfg.get("spawn", "default")))
	if is_randomlocke():
		locke = WorldLocke.new(randomlocke)
	EventBus.new_game_started.emit()


# --- Flags y variables ---

func flag(key: StringName) -> bool:
	return flags.get(key, false)


func set_flag(key: StringName, value: bool = true) -> void:
	if flag(key) == value:
		return
	if value:
		flags[key] = true
	else:
		flags.erase(key)
	EventBus.flag_changed.emit(key, value)


func clear_flag(key: StringName) -> void:
	set_flag(key, false)


func has_var(key: StringName) -> bool:
	return vars.has(key)


func get_var(key: StringName, default: Variant = null) -> Variant:
	return vars.get(key, default)


func var_int(key: StringName, default: int = 0) -> int:
	return int(vars.get(key, default))


func var_str(key: StringName, default: String = "") -> String:
	return str(vars.get(key, default))


## Solo valores que se puedan guardar en JSON: int, float, bool o String.
func set_var(key: StringName, value: Variant) -> void:
	if value is StringName:
		value = String(value)
	assert(value is int or value is float or value is bool or value is String,
		"GameState.set_var(%s): tipo no guardable" % key)
	if vars.get(key) == value:
		return
	vars[key] = value
	EventBus.var_changed.emit(key, value)


func clear_var(key: StringName) -> void:
	if vars.erase(key):
		EventBus.var_changed.emit(key, null)


# --- Dinero y medallas ---

func max_money() -> int:
	return int(world_config.get("max_money", 999999))


func add_money(amount: int) -> void:
	money = clampi(money + amount, 0, max_money())
	EventBus.money_changed.emit(money)


## Resta `amount` si hay suficiente dinero. Devuelve false si no llega.
func spend_money(amount: int) -> bool:
	if amount > money:
		return false
	add_money(-amount)
	return true


func has_badge(badge_id: StringName) -> bool:
	return badge_id in badges


func add_badge(badge_id: StringName) -> void:
	if has_badge(badge_id):
		return
	badges.append(badge_id)
	EventBus.badge_obtained.emit(badge_id)


func set_healing_spot(map: StringName, spawn: StringName) -> void:
	healing_map = map
	healing_spawn = spawn


# --- Bloqueo de input ---

## Bloquea el control del jugador. `reason` identifica quién bloquea (&"menu",
## &"dialogue", &"cutscene"...). Cada lock_input necesita su unlock_input.
func lock_input(reason: StringName) -> void:
	var was_locked := input_locked
	_input_locks[reason] = _input_locks.get(reason, 0) + 1
	if not was_locked:
		EventBus.input_lock_changed.emit(true)


func unlock_input(reason: StringName) -> void:
	if not _input_locks.has(reason):
		return
	_input_locks[reason] -= 1
	if _input_locks[reason] <= 0:
		_input_locks.erase(reason)
	if not input_locked:
		EventBus.input_lock_changed.emit(false)


func is_input_locked_by(reason: StringName) -> bool:
	return _input_locks.has(reason)


func clear_input_locks() -> void:
	var was_locked := input_locked
	_input_locks.clear()
	if was_locked:
		EventBus.input_lock_changed.emit(false)


# --- Guardado ---

func is_randomlocke() -> bool:
	return mode == MODE_RANDOMLOCKE


func to_dict() -> Dictionary:
	if locke != null:
		locke.sync()
	var modules := {}
	for key: StringName in MODULE_CLASSES:
		modules[String(key)] = _module_to_dict(get(key))
	return {
		"mode": String(mode),
		"randomlocke": randomlocke.duplicate(true),
		"player": {
			"name": player_name,
			"gender": String(player_gender),
			"rival_name": rival_name,
			"trainer_id": trainer_id,
			"secret_id": secret_id,
			"money": money,
			"badges": badges.map(func(b: StringName) -> String: return String(b)),
			"play_time": play_time,
		},
		"position": {
			"map": String(map_id),
			"tile": [player_tile.x, player_tile.y],
			"facing": dir_name(player_facing),
			"healing_map": String(healing_map),
			"healing_spawn": String(healing_spawn),
		},
		"flags": flags.keys().map(func(k: StringName) -> String: return String(k)),
		"vars_int": _vars_to_dict(true),
		"vars": _vars_to_dict(false),
		"modules": modules,
	}


## Restaura la partida. No toca `slot` ni `rom_patch` (los pone SaveManager).
func from_dict(data: Dictionary) -> void:
	var keep_slot := slot
	var keep_patch := rom_patch
	reset()
	slot = keep_slot
	rom_patch = keep_patch
	mode = StringName(data.get("mode", String(MODE_NORMAL)))
	randomlocke = (data.get("randomlocke", {}) as Dictionary).duplicate(true)
	var p: Dictionary = data.get("player", {})
	player_name = p.get("name", "")
	player_gender = StringName(p.get("gender", "male"))
	rival_name = p.get("rival_name", "")
	trainer_id = int(p.get("trainer_id", 0))
	secret_id = int(p.get("secret_id", 0))
	money = int(p.get("money", 0))
	for b: Variant in p.get("badges", []):
		badges.append(StringName(b))
	play_time = float(p.get("play_time", 0.0))

	var pos: Dictionary = data.get("position", {})
	map_id = StringName(pos.get("map", ""))
	var tile: Array = pos.get("tile", [0, 0])
	player_tile = Vector2i(int(tile[0]), int(tile[1]))
	player_facing = dir_from_name(pos.get("facing", "down"))
	healing_map = StringName(pos.get("healing_map", ""))
	healing_spawn = StringName(pos.get("healing_spawn", ""))

	for k: Variant in data.get("flags", []):
		flags[StringName(k)] = true
	var saved_vars: Dictionary = data.get("vars", {})
	for k: Variant in saved_vars:
		vars[StringName(k)] = saved_vars[k]
	var saved_ints: Dictionary = data.get("vars_int", {})
	for k: Variant in saved_ints:
		vars[StringName(k)] = int(saved_ints[k])

	var modules: Dictionary = data.get("modules", {})
	for key: StringName in MODULE_CLASSES:
		if modules.has(String(key)):
			set(key, _module_from_dict(key, modules[String(key)]))
	if is_randomlocke():
		locke = WorldLocke.new(randomlocke)
		locke.remove_dead()
		if not locke.pending.is_empty():
			lock_input(&"locke_nickname")
		locke.check_game_over()


# --- Utilidades de dirección (las mismas que Grid; aquí por comodidad) ---

func dir_name(dir: Vector2i) -> String:
	return Grid.dir_name(dir)


func dir_from_name(dir_text: String) -> Vector2i:
	return Grid.dir_from_name(dir_text)


# --- Internos ---

## JSON no distingue int de float: los int se guardan aparte para recuperarlos igual.
func _vars_to_dict(ints: bool) -> Dictionary:
	var out := {}
	for k: StringName in vars:
		if (vars[k] is int) == ints:
			out[String(k)] = vars[k]
	return out


func _new_module(key: StringName) -> Variant:
	var script := GlobalClasses.find(MODULE_CLASSES[key])
	return script.new() if script else null


func _module_to_dict(module: Variant) -> Variant:
	if module is Object and module.has_method("to_dict"):
		return module.to_dict()
	# Módulo aún sin clase: se guardan los datos que se cargaron.
	return module


func _module_from_dict(key: StringName, data: Variant) -> Variant:
	var module: Variant = _new_module(key)
	if module == null or not (data is Dictionary):
		return data
	module.from_dict(data)
	return module
