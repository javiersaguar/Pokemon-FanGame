class_name WildEncounters
extends RefCounted
## Encuentros salvajes al andar (Fase 5.7). Tablas en data/encounters/<id>.json
## (formato del Agente 3; se lee el de la guía):
##   {"land": {"day": [{"species", "min", "max", "weight"}...], "night": [...]}, "water": [...]}
## Cada sección puede ser una lista directa o un diccionario por momento del día
## (morning/day/evening/night; si falta el momento exacto, se usa day o night).

const TABLES_DIR := "res://data/encounters/"
## Variable de GameState con los pasos de Repelente que quedan.
const REPEL_VAR := &"repel_steps"

static var rng := RandomNumberGenerator.new()
static var _cache: Dictionary[StringName, Dictionary] = {}


static func _static_init() -> void:
	rng.randomize()


## Se llama tras cada paso del jugador. Devuelve {species, level} si salta un
## encuentro o {} si no.
static func roll(map: MapRoot, tile: Vector2i, kind: StringName = &"land") -> Dictionary:
	var repel_active := _tick_repel()
	if Debug.encounters_disabled or map.data == null or map.data.encounter_table == &"":
		return {}
	if not map.is_encounter_tile(tile):
		return {}
	if rng.randf() >= step_chance(map):
		return {}
	var wild := pick(map.data.encounter_table, kind, Clock.period())
	if wild.is_empty() or (repel_active and wild["level"] < _lead_level()):
		return {}
	return wild


static func step_chance(map: MapRoot) -> float:
	if map.data and map.data.encounter_rate > 0.0:
		return map.data.encounter_rate
	var cfg: Dictionary = GameState.world_config.get("encounters", {})
	return float(cfg.get("step_chance", 0.1))


## Elige especie y nivel de la tabla `table_id` según los pesos.
static func pick(table_id: StringName, kind: StringName, period: StringName) -> Dictionary:
	var entries := slots(table_id, kind, period)
	var total := 0
	for e: Dictionary in entries:
		total += int(e.get("weight", 1))
	if total <= 0:
		return {}
	var roll_value := rng.randi_range(1, total)
	for e: Dictionary in entries:
		roll_value -= int(e.get("weight", 1))
		if roll_value <= 0:
			var low := int(e.get("min", e.get("level", 1)))
			var high := int(e.get("max", low))
			return {"species": StringName(e["species"]), "level": rng.randi_range(low, maxi(low, high))}
	return {}


## Lista de huecos de la tabla para ese tipo de encuentro y momento del día.
static func slots(table_id: StringName, kind: StringName, period: StringName) -> Array:
	var section: Variant = load_table(table_id).get(String(kind), [])
	if section is Array:
		return section
	if section is Dictionary:
		var fallback := "night" if period == &"night" else "day"
		return section.get(String(period), section.get(fallback, []))
	return []


static func load_table(table_id: StringName) -> Dictionary:
	if not _cache.has(table_id):
		_cache[table_id] = JsonFile.read_dict(TABLES_DIR + String(table_id) + ".json")
	return _cache[table_id]


static func clear_cache() -> void:
	_cache.clear()


## BattleSetup del Agente 2 si ya existe (BattleSetup.wild(species, level)); si no,
## un Dictionary que entiende el combate provisional.
static func make_setup(wild: Dictionary) -> Variant:
	var setup_class := GlobalClasses.find(&"BattleSetup")
	if setup_class and GlobalClasses.has_function(setup_class, &"wild"):
		return setup_class.call(&"wild", wild["species"], wild["level"])
	return {"kind": "wild", "species": wild["species"], "level": wild["level"], "can_lose": false}


## Descuenta un paso de Repelente. Devuelve si estaba activo en este paso.
static func _tick_repel() -> bool:
	var steps := GameState.var_int(REPEL_VAR)
	if steps <= 0:
		return false
	GameState.set_var(REPEL_VAR, steps - 1)
	if steps == 1:
		EventBus.repel_wore_off.emit()
	return true


static func _lead_level() -> int:
	var party: Variant = GameState.party
	if party is Object and party.has_method(&"lead_level"):
		return int(party.lead_level())
	return 0
