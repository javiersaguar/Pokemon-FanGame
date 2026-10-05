class_name WildEncounters
extends RefCounted
## Encuentros salvajes al andar (Fase 5.7). Las tablas son las de
## data/encounters/<id>.json (formato del Agente 3, contratos.md §9.7) y se piden a
## DataDB, que en RandomLocke devuelve las parcheadas.

## Variable de GameState con los pasos de Repelente que quedan.
const REPEL_VAR := &"repel_steps"
## land_rate (en %) si la tabla no lo indica (contratos.md §9.7).
const DEFAULT_RATE_PERCENT := 10.0

static var rng := RandomNumberGenerator.new()


static func _static_init() -> void:
	rng.randomize()


## Se llama tras cada paso del jugador. Devuelve {species, level} si salta un
## encuentro o {} si no.
static func roll(map: MapRoot, tile: Vector2i, kind: StringName = &"land") -> Dictionary:
	var repel_active := _tick_repel()
	if Debug.encounters_disabled or map.data == null or map.data.encounter_table == &"":
		return {}
	# Sin ningún Pokémon que pueda luchar no hay encuentros (como en los juegos oficiales).
	if _able_count() == 0:
		return {}
	if not map.is_encounter_tile(tile) and not (kind == &"water" and map.terrain_at(tile) in ["water", "waterfall"]):
		return {}
	var table := load_table(map.data.encounter_table)
	if table.is_empty() or rng.randf() >= step_chance(map, table, kind):
		return {}
	var wild := pick_from(table, kind, Clock.period())
	if wild.is_empty() or (repel_active and wild["level"] < _lead_level()):
		return {}
	return wild


## Probabilidad por paso: MapData.encounter_rate si es > 0; si no, <kind>_rate (%)
## de la tabla; si no, data/world.json → encounters.step_chance; si no, 10 %.
static func step_chance(map: MapRoot, table: Dictionary, kind: StringName = &"land") -> float:
	if map.data and map.data.encounter_rate > 0.0:
		return map.data.encounter_rate
	var key := String(kind) + "_rate"
	if table.has(key):
		return float(table[key]) / 100.0
	var cfg: Dictionary = GameState.world_config.get("encounters", {})
	return float(cfg.get("step_chance", DEFAULT_RATE_PERCENT / 100.0))


static func pick(table_id: StringName, kind: StringName, period: StringName) -> Dictionary:
	return pick_from(load_table(table_id), kind, period)


## Elige especie y nivel según los pesos.
static func pick_from(table: Dictionary, kind: StringName, period: StringName) -> Dictionary:
	var entries := slots(table, kind, period)
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
			var high := maxi(low, int(e.get("max", low)))
			return {"species": StringName(e["species"]), "level": rng.randi_range(low, high)}
	return {}


## Huecos de la tabla para ese tipo de encuentro y momento del día: una lista
## sirve a cualquier hora; un diccionario se busca por momento y, si falta, "day".
static func slots(table: Dictionary, kind: StringName, period: StringName) -> Array:
	var section: Variant = table.get(String(kind), [])
	if section is Array:
		return section
	if section is Dictionary:
		return section.get(String(period), section.get("day", []))
	return []


static func load_table(table_id: StringName) -> Dictionary:
	if not DataDB.has_encounter_table(table_id):
		push_warning("WildEncounters: no existe la tabla de encuentros '%s'." % table_id)
		return {}
	return DataDB.encounter_table(table_id)


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


static func _able_count() -> int:
	var party: Variant = GameState.party
	if party is Object and party.has_method(&"able_count"):
		return int(party.able_count())
	return 1


static func _lead_level() -> int:
	var party: Variant = GameState.party
	if party is Object and party.has_method(&"first_able_level"):
		return int(party.first_able_level())
	return 0
