class_name RandomizerInput
extends RefCounted
## Snapshot JSON independiente. Preparar en el principal; generación no lee autoloads/archivos.

const MAX_LEVEL := 100
const TABLES: Array[String] = ["species", "moves", "items", "abilities", "types", "learnsets", "trainers", "trainer_classes", "encounters", "starters", "gifts", "statics", "trades", "placements", "shops", "tm_moves", "tm_compat", "tutor_moves", "tutor_compat"]
var data: Dictionary = {}
var fingerprint: String = ""
var _species: Dictionary = {}
var _moves: Dictionary = {}
var _items: Dictionary = {}
var _abilities: Dictionary = {}

static func from_dict(source: Dictionary) -> RandomizerInput:
	var result := RandomizerInput.new()
	result.data = source.duplicate(true)
	for table: String in TABLES:
		if not result.data.has(table):
			result.data[table] = {}
	for id: String in result.ids("species"):
		result._species[StringName(id)] = SpeciesData.from_dict(StringName(id), result.data.species[id])
	for id: String in result.ids("moves"):
		result._moves[StringName(id)] = MoveData.from_dict(StringName(id), result.data.moves[id])
	for id: String in result.ids("items"):
		result._items[StringName(id)] = ItemData.from_dict(StringName(id), result.data.items[id])
	for id: String in result.ids("abilities"):
		result._abilities[StringName(id)] = AbilityData.from_dict(StringName(id), result.data.abilities[id])
	result.fingerprint = JSON.stringify(result.data, "", true).sha256_text()
	return result

static func from_datadb() -> RandomizerInput:
	var db: Node = (Engine.get_main_loop() as SceneTree).root.get_node("DataDB")
	# Adaptador de compatibilidad. No llamarlo desde WorkerThreadPool.
	if db.has_method("randomizer_input"):
		return from_dict(db.randomizer_input())
	var source: Dictionary = {"regional": Array(db.regional_dex()), "config": JsonFile.read_dict(Randomizer.CONFIG_PATH)}
	for kind: String in ["species", "moves", "items", "abilities"]:
		source[kind] = {}
	for id: StringName in db.species_ids():
		source.species[String(id)] = db.species(id).raw.duplicate(true)
		source.get_or_add("learnsets", {})[String(id)] = db.learnset(id).duplicate(true)
	for id: StringName in db.move_ids():
		source.moves[String(id)] = db.move(id).raw.duplicate(true)
	for id: StringName in db.item_ids():
		source.items[String(id)] = db.item(id).raw.duplicate(true)
	for id: StringName in db._abilities:
		source.abilities[String(id)] = db.ability(id).raw.duplicate(true)
	source.config.merge(JsonFile.read_dict("res://data/randomizer/prohibidos.json"), true)
	source.types = db._types.duplicate(true)
	for entry: Array in [["trainers", db.trainer_ids(), db.trainer], ["trainer_classes", db._trainer_classes.keys(), db.trainer_class], ["encounters", db.encounter_ids(), db.encounter_table], ["starters", db.starter_ids(), db.starter_spec], ["gifts", db.gift_ids(), db.gift], ["statics", db.static_ids(), db.static_encounter], ["trades", db.trade_ids(), db.trade], ["shops", db.shop_ids(), db.shop]]:
		source[entry[0]] = {}
		for id: Variant in entry[1]:
			source[entry[0]][String(id)] = (entry[2] as Callable).call(StringName(id)).duplicate(true)
	source.placements = db.item_placements().duplicate(true)
	return from_dict(source)

func to_dict() -> Dictionary:
	return data.duplicate(true)

func ids(table: String) -> Array[String]:
	var result: Array[String] = []
	result.assign(data.get(table, {}).keys())
	result.sort()
	return result

func names(table: String) -> Array[StringName]:
	return DataUtil.names(ids(table))

func species_ids(include_forms: bool = true) -> Array[StringName]:
	var result := names("species")
	return result if include_forms else result.filter(func(id: StringName) -> bool: return not species(id).is_form())

func move_ids() -> Array[StringName]:
	return names("moves")
func item_ids() -> Array[StringName]:
	return names("items")
func type_ids() -> Array[StringName]:
	return names("types")
func trainer_ids() -> Array[StringName]:
	return names("trainers")
func encounter_ids() -> Array[StringName]:
	return names("encounters")
func starter_ids() -> Array[StringName]:
	return names("starters")
func gift_ids() -> Array[StringName]:
	return names("gifts")
func static_ids() -> Array[StringName]:
	return names("statics")
func trade_ids() -> Array[StringName]:
	return names("trades")
func shop_ids() -> Array[StringName]:
	return names("shops")
func species(id: StringName) -> SpeciesData:
	return _species.get(id)
func move(id: StringName) -> MoveData:
	return _moves.get(id)
func item(id: StringName) -> ItemData:
	return _items.get(id)
func ability(id: StringName) -> AbilityData:
	return _abilities.get(id)
func has_species(id: StringName) -> bool:
	return _species.has(id)
func has_move(id: StringName) -> bool:
	return _moves.has(id)
func has_item(id: StringName) -> bool:
	return _items.has(id)
func has_ability(id: StringName) -> bool:
	return _abilities.has(id)
func has_trainer_class(id: StringName) -> bool:
	return data.trainer_classes.has(String(id))
func learnset(id: StringName) -> Dictionary:
	var actual := String(species(id).learnset_id) if has_species(id) else ""
	return data.learnsets.get(String(id), data.learnsets.get(actual, {}))
func trainer(id: StringName) -> Dictionary:
	return data.trainers.get(String(id), {})
func trainer_class(id: StringName) -> Dictionary:
	return data.trainer_classes.get(String(id), {})
func encounter_table(id: StringName) -> Dictionary:
	return data.encounters.get(String(id), {})
func starter_spec(id: StringName) -> Dictionary:
	return data.starters.get(String(id), {})
func starter(id: StringName) -> StringName:
	return StringName(str(starter_spec(id).get("species", "")))
func gift(id: StringName) -> Dictionary:
	return data.gifts.get(String(id), {})
func static_encounter(id: StringName) -> Dictionary:
	return data.statics.get(String(id), {})
func trade(id: StringName) -> Dictionary:
	return data.trades.get(String(id), {})
func shop(id: StringName) -> Dictionary:
	return data.shops.get(String(id), {})
func item_placements() -> Dictionary:
	return data.placements
func regional_dex() -> Array[StringName]:
	return DataUtil.names(data.get("regional", []))
func type_effectiveness(atk: StringName, defenders: Array[StringName]) -> float:
	var result := 1.0
	for defender: StringName in defenders:
		result *= float(data.types.get(String(atk), {}).get("effectiveness", {}).get(String(defender), 1.0))
	return result
func mutable_species(id: StringName) -> bool:
	return has_species(id) and species(id).raw.get("randomize", true) != false

func errors() -> Array[String]:
	var result: Array[String] = []
	if _species.is_empty() or _moves.is_empty():
		result.append("La entrada necesita especies y movimientos.")
	for id: String in ids("species"):
		var s := species(StringName(id))
		if s.types.is_empty() or s.base_stats.size() != 6:
			result.append("Especie incompleta: %s." % id)
		for evo: Dictionary in s.evolutions:
			if not has_species(StringName(str(evo.get("to", "")))):
				result.append("Evolución desconocida: %s." % id)
	return result

func families(patch: RomPatch = null) -> Dictionary:
	var parents: Dictionary = {}
	for id: String in ids("species"):
		parents[id] = id
	for id: String in ids("species"):
		var s := species(StringName(id))
		var edges: Array = s.evolutions
		if patch != null:
			edges = patch.section("species").get(id, {}).get("evolutions", edges)
		for edge: Dictionary in edges:
			var target := str(edge.get("to", ""))
			if parents.has(target):
				_union_family(parents, id, target)
		if s.base_species != &"" and parents.has(String(s.base_species)):
			_union_family(parents, id, String(s.base_species))
	var result: Dictionary = {}
	for id: String in ids("species"):
		result[id] = _family_root(parents, id)
	return result

static func _family_root(parents: Dictionary, id: String) -> String:
	var current := id
	while parents[current] != current:
		current = parents[current]
	return current

static func _union_family(parents: Dictionary, first: String, second: String) -> void:
	var a := _family_root(parents, first)
	var b := _family_root(parents, second)
	parents[b if a < b else a] = a if a < b else b
