extends Node
## Base de datos del juego: carga los JSON de data/ al arrancar y da acceso tipado.
## Contrato: docs/contratos.md (sección DataDB).
##
## - data/generated/*.json: datos oficiales (tools/import_data). No se editan a mano.
## - data/species_overrides.json: cambios propios sobre las especies (se aplican encima).
## - data/items_panchito.json: objetos Panchito (se suman a los estándar).
## - data/trainer_classes.json, data/trainers/*.json, data/encounters/*.json, data/shops.json:
##   datos del Agente 3; DataDB solo los carga y los devuelve tal cual (Dictionary).
## - data/starters.json, gifts.json, statics.json y trades.json (Agente 3) e item_placements.json
##   (Agente 1): todo lo que la historia da o coloca, por id (regla R.2 de RandomLocke).
## Con un parche de RandomLocke aplicado (apply_patch, Fase R.1), las consultas devuelven lo parcheado.
## En todos los archivos, las claves que empiezan por "_" son comentarios y se ignoran.

signal loaded
signal patch_changed

const GENERATED_DIR := "res://data/generated"
const SPECIES_OVERRIDES_PATH := "res://data/species_overrides.json"
const REGIONAL_DEX_PATH := "res://data/regional_dex.json"
const ITEMS_PANCHITO_PATH := "res://data/items_panchito.json"
const TRAINER_CLASSES_PATH := "res://data/trainer_classes.json"
const TRAINERS_DIR := "res://data/trainers"
const ENCOUNTERS_DIR := "res://data/encounters"
const SHOPS_PATH := "res://data/shops.json"
const STARTERS_PATH := "res://data/starters.json"
const GIFTS_PATH := "res://data/gifts.json"
const STATICS_PATH := "res://data/statics.json"
const TRADES_PATH := "res://data/trades.json"
const ITEM_PLACEMENTS_PATH := "res://data/item_placements.json"
const MARKER_KINDS: Array[String] = ["starter", "gift", "static", "trade", "species", "item"]
## Reglas configurables de los Pokémon: sección "pokemon" de data/world.json (Agente 1).
const WORLD_PATH := "res://data/world.json"
const MAX_LEVEL := 100

var is_loaded := false

var _species: Dictionary[StringName, SpeciesData] = {}
var _moves: Dictionary[StringName, MoveData] = {}
var _items: Dictionary[StringName, ItemData] = {}
var _abilities: Dictionary[StringName, AbilityData] = {}
var _natures: Dictionary[StringName, NatureData] = {}
var _types: Dictionary = {}
var _type_ids: Array[StringName] = []
var _learnsets: Dictionary = {}
var _level_moves_cache: Dictionary[StringName, Array] = {}
var _exp_tables: Dictionary[StringName, PackedInt32Array] = {}
var _regional_dex: Array[StringName] = []
var _regional_index: Dictionary[StringName, int] = {}
var _trainer_classes: Dictionary = {}
var _trainers: Dictionary = {}
var _encounters: Dictionary = {}
var _shops: Dictionary = {}
var _shops_file: Dictionary = {}
var _meta: Dictionary = {}
var _rules: Dictionary = {}
var _shiny: Dictionary = {}
var _starters: Dictionary = {}
var _gifts: Dictionary = {}
var _statics: Dictionary = {}
var _trades: Dictionary = {}
var _item_placements: Dictionary = {}
var _patch: Dictionary = {}
var _patched_species: Dictionary[StringName, SpeciesData] = {}
var _marker_regex := RegEx.create_from_string("\\{(%s):([A-Za-z0-9_/\\-]+)\\}" % "|".join(PackedStringArray(MARKER_KINDS)))
var _debug_commands: PokemonDebugCommands


func _ready() -> void:
	load_all()
	if OS.is_debug_build():
		_debug_commands = PokemonDebugCommands.new()
		_debug_commands.register.call_deferred()


## Carga (o recarga) todos los datos.
func load_all() -> void:
	var t0 := Time.get_ticks_msec()
	_load_species()
	_load_moves()
	_load_items()
	_abilities.clear()
	var abilities := _read_dict(GENERATED_DIR + "/abilities.json")
	for id: String in abilities:
		_abilities[StringName(id)] = AbilityData.from_dict(StringName(id), abilities[id])
	_natures.clear()
	var natures := _read_dict(GENERATED_DIR + "/natures.json")
	for id: String in natures:
		_natures[StringName(id)] = NatureData.from_dict(StringName(id), natures[id])
	_types = _read_dict(GENERATED_DIR + "/types.json")
	_type_ids.assign(_types.keys().map(func(t: String) -> StringName: return StringName(t)))
	_learnsets = _read_dict(GENERATED_DIR + "/learnsets.json")
	_level_moves_cache.clear()
	_exp_tables.clear()
	var exp_tables := _read_dict(GENERATED_DIR + "/exp_tables.json")
	for group: String in exp_tables:
		_exp_tables[StringName(group)] = PackedInt32Array(exp_tables[group])
	_meta = _read_dict(GENERATED_DIR + "/meta.json")
	var world := _read_dict(WORLD_PATH, true)
	_rules = world.get("pokemon", {})
	_shiny = world.get("shiny", {})
	_load_regional_dex()
	_trainer_classes = _without_comments(_read_dict(TRAINER_CLASSES_PATH, true))
	_shops_file = _read_dict(SHOPS_PATH, true)
	_shops = _without_comments(_shops_file.get("shops", {}))
	_trainers = _load_dir_merged(TRAINERS_DIR)
	_encounters = _load_dir_by_file(ENCOUNTERS_DIR)
	_starters = _without_comments(_read_dict(STARTERS_PATH, true))
	_gifts = _without_comments(_read_dict(GIFTS_PATH, true))
	_statics = _without_comments(_read_dict(STATICS_PATH, true))
	_trades = _without_comments(_read_dict(TRADES_PATH, true))
	_item_placements = _without_comments(_read_dict(ITEM_PLACEMENTS_PATH, true))
	if not _patch.is_empty():
		apply_patch(_patch)
	is_loaded = true
	print_verbose("DataDB: datos cargados en %d ms (%d especies, %d movimientos, %d objetos)." % [
		Time.get_ticks_msec() - t0, _species.size(), _moves.size(), _items.size()])
	loaded.emit()


# --- Especies ---

func species(id: StringName) -> SpeciesData:
	var s: SpeciesData = _patched_species.get(id, _species.get(id))
	if s == null:
		push_error("DataDB: no existe la especie '%s'." % id)
	return s


func has_species(id: StringName) -> bool:
	return _species.has(id)


## Ids de todas las especies; con `include_forms = false`, solo las especies base.
func species_ids(include_forms: bool = true) -> Array[StringName]:
	var out: Array[StringName] = []
	for id: StringName in _species:
		if include_forms or not _species[id].is_form():
			out.append(id)
	return out


# --- Movimientos, habilidades, naturalezas ---

func move(id: StringName) -> MoveData:
	var m: MoveData = _moves.get(id)
	if m == null:
		push_error("DataDB: no existe el movimiento '%s'." % id)
	return m


func has_move(id: StringName) -> bool:
	return _moves.has(id)


func move_ids() -> Array[StringName]:
	var out: Array[StringName] = []
	out.assign(_moves.keys())
	return out


func ability(id: StringName) -> AbilityData:
	var a: AbilityData = _abilities.get(id)
	if a == null:
		push_error("DataDB: no existe la habilidad '%s'." % id)
	return a


func has_ability(id: StringName) -> bool:
	return _abilities.has(id)


func nature(id: StringName) -> NatureData:
	var n: NatureData = _natures.get(id)
	if n == null:
		push_error("DataDB: no existe la naturaleza '%s'." % id)
	return n


func nature_ids() -> Array[StringName]:
	var out: Array[StringName] = []
	out.assign(_natures.keys())
	return out


# --- Objetos ---

func item(id: StringName) -> ItemData:
	var it: ItemData = _items.get(id)
	if it == null:
		push_error("DataDB: no existe el objeto '%s'." % id)
	return it


func has_item(id: StringName) -> bool:
	return _items.has(id)


func item_ids() -> Array[StringName]:
	var out: Array[StringName] = []
	out.assign(_items.keys())
	return out


# --- Tipos ---

func type_ids() -> Array[StringName]:
	return _type_ids.duplicate()


func has_type(type: StringName) -> bool:
	return _types.has(String(type))


func type_name(type: StringName) -> String:
	if not has_type(type):
		push_error("DataDB: no existe el tipo '%s'." % type)
		return String(type)
	return str(_types[String(type)].get("name", type))


## Multiplicador de un ataque de tipo `atk_type` contra un Pokémon de tipos `def_types`.
func type_effectiveness(atk_type: StringName, def_types: Array[StringName]) -> float:
	if not has_type(atk_type):
		push_error("DataDB: no existe el tipo '%s'." % atk_type)
		return 1.0
	var chart: Dictionary = _types[String(atk_type)]["effectiveness"]
	var mult := 1.0
	for def_type: StringName in def_types:
		mult *= float(chart.get(String(def_type), 1.0))
	return mult


## ¿Es inmune el tipo `type` a `condition`? ("brn", "par", "psn", "tox", "frz", "powder", "sandstorm"...).
func type_immune_to(type: StringName, condition: StringName) -> bool:
	if not has_type(type):
		return false
	return String(condition) in _types[String(type)].get("immunities", [])


# --- Experiencia ---

func exp_for_level(group: StringName, level: int) -> int:
	var table: PackedInt32Array = _exp_tables.get(group, PackedInt32Array())
	if table.is_empty():
		push_error("DataDB: no existe el grupo de crecimiento '%s'." % group)
		return 0
	return table[clampi(level, 1, MAX_LEVEL)]


func level_for_exp(group: StringName, total_exp: int) -> int:
	var table: PackedInt32Array = _exp_tables.get(group, PackedInt32Array())
	if table.is_empty():
		push_error("DataDB: no existe el grupo de crecimiento '%s'." % group)
		return 1
	var level := 1
	while level < MAX_LEVEL and table[level + 1] <= total_exp:
		level += 1
	return level


# --- Learnsets ---

## {gen, level: [[nivel, movimiento]...], machine: [...], tutor: [...], egg: [...]}.
func learnset(species_id: StringName) -> Dictionary:
	var s: SpeciesData = _species.get(species_id)
	if s == null:
		push_error("DataDB: no existe la especie '%s'." % species_id)
		return {}
	var key := s.learnset_id
	if key == &"" and s.is_form():
		key = _species[s.base_species].learnset_id if _species.has(s.base_species) else &""
	var ls: Dictionary = _learnsets.get(String(key), {})
	var patched_level: Variant = _patch.get("learnsets", {}).get(String(species_id))
	var patched_tms: Variant = _patch.get("tm_compat", {}).get(String(species_id))
	if patched_level != null or patched_tms != null:
		ls = ls.duplicate()
		if patched_level != null:
			ls["level"] = patched_level
		if patched_tms != null:
			ls["machine"] = patched_tms
	return ls


## Movimientos por nivel ordenados: [[nivel: int, movimiento: StringName], ...]. Nivel 0 = al evolucionar.
func level_up_moves(species_id: StringName) -> Array:
	if _level_moves_cache.has(species_id):
		return _level_moves_cache[species_id]
	var out: Array = []
	for entry: Array in learnset(species_id).get("level", []):
		out.append([int(entry[0]), StringName(entry[1])])
	_level_moves_cache[species_id] = out
	return out


func moves_learned_at(species_id: StringName, level: int) -> Array[StringName]:
	var out: Array[StringName] = []
	for entry: Array in level_up_moves(species_id):
		if entry[0] == level and entry[1] not in out:
			out.append(entry[1])
	return out


## Los últimos 4 movimientos aprendibles por nivel hasta `level` (movimientos de un Pokémon nuevo).
func default_moves(species_id: StringName, level: int) -> Array[StringName]:
	var out: Array[StringName] = []
	for entry: Array in level_up_moves(species_id):
		if entry[0] < 1 or entry[0] > level or not _moves.has(entry[1]):
			continue
		out.erase(entry[1])
		out.append(entry[1])
	return out.slice(maxi(0, out.size() - 4))


func can_learn(species_id: StringName, move_id: StringName) -> bool:
	var ls := learnset(species_id)
	for key: String in ["machine", "tutor", "egg"]:
		if String(move_id) in ls.get(key, []):
			return true
	for entry: Array in level_up_moves(species_id):
		if entry[1] == move_id:
			return true
	return false


# --- Pokédex regional ---

func regional_dex() -> Array[StringName]:
	return _regional_dex.duplicate()


## Número en la Pokédex regional (1, 2, 3...); 0 si no está. Las formas usan el de su especie.
func regional_number(species_id: StringName) -> int:
	var s: SpeciesData = _species.get(species_id)
	var key := s.root_species() if s else species_id
	return _regional_index.get(key, 0)


# --- Datos del Agente 3 (se devuelven tal cual) ---

func trainer_class(id: StringName) -> Dictionary:
	return _raw_get(_trainer_classes, id, "la clase de entrenador")


func has_trainer_class(id: StringName) -> bool:
	return _trainer_classes.has(String(id))


func trainer(id: StringName) -> Dictionary:
	var t := _raw_get(_trainers, id, "el entrenador")
	var patched: Variant = _patch.get("trainers", {}).get(String(id))
	if patched is Dictionary and not t.is_empty():
		t = t.duplicate(true)
		t.merge(patched, true)
	return t


func has_trainer(id: StringName) -> bool:
	return _trainers.has(String(id))


func trainer_ids() -> Array[StringName]:
	return DataUtil.names(_trainers.keys())


## Tabla de encuentros de data/encounters/<id>.json (id = ruta relativa sin ".json").
func encounter_table(id: StringName) -> Dictionary:
	var patched: Variant = _patch.get("encounters", {}).get(String(id))
	if patched is Dictionary:
		return patched
	return _raw_get(_encounters, id, "la tabla de encuentros")


func has_encounter_table(id: StringName) -> bool:
	return _encounters.has(String(id))


func encounter_ids() -> Array[StringName]:
	return DataUtil.names(_encounters.keys())


## Tienda de data/shops.json → shops[id].
func shop(id: StringName) -> Dictionary:
	var patched: Variant = _patch.get("shops", {}).get(String(id))
	if patched is Dictionary:
		return patched
	return _raw_get(_shops, id, "la tienda")


func has_shop(id: StringName) -> bool:
	return _shops.has(String(id))


func shop_ids() -> Array[StringName]:
	return DataUtil.names(_shops.keys())


## data/shops.json → sell_ratio (precio de venta = floor(precio × sell_ratio)).
func shop_sell_ratio() -> float:
	return float(_shops_file.get("sell_ratio", 0.5))


# --- Regla R.2: lo que da o coloca la historia, por id ---

## Especie del inicial `id` ("starter_1", "starter_2", "starter_3") de data/starters.json.
func starter(id: StringName) -> StringName:
	return StringName(str(starter_spec(id).get("species", "")))


## Ficha completa del inicial ({species, level?...}; acepta "starter_1": "bulbasaur" o un diccionario).
func starter_spec(id: StringName) -> Dictionary:
	return _story_entry(_starters, "starters", id, "el inicial")


func starter_ids() -> Array[StringName]:
	return DataUtil.names(_starters.keys())


## Regalo de data/gifts.json: ficha de Pokemon.from_spec() ({species, level, ...}).
func gift(id: StringName) -> Dictionary:
	return _story_entry(_gifts, "gifts", id, "el regalo")


func gift_ids() -> Array[StringName]:
	return DataUtil.names(_gifts.keys())


func static_ids() -> Array[StringName]:
	return DataUtil.names(_statics.keys())


func trade_ids() -> Array[StringName]:
	return DataUtil.names(_trades.keys())


## Encuentro estático de data/statics.json (legendarios, bloqueos): ficha de Pokemon.from_spec().
func static_encounter(id: StringName) -> Dictionary:
	return _story_entry(_statics, "statics", id, "el encuentro estático")


## Intercambio con un NPC de data/trades.json (tal cual, con el parche aplicado).
func trade(id: StringName) -> Dictionary:
	return _story_entry(_trades, "trades", id, "el intercambio")


## Objeto colocado en un mapa (ItemBall). `placement_id` = "<map_id>/<nodo>"; si el parche no lo
## cambia, devuelve `default_item` (el que tiene la escena).
func placed_item(placement_id: StringName, default_item: StringName) -> StringName:
	var patched: Variant = _patch.get("items", {}).get(String(placement_id))
	return StringName(str(patched)) if patched != null else default_item


## data/item_placements.json: {placement_id: item_id} de todos los mapas (lo genera el Agente 1).
func item_placements() -> Dictionary:
	return _item_placements


## Sustituye los marcadores de texto por nombres: {starter:starter_1}, {gift:<id>}, {static:<id>},
## {trade:<id>}, {species:<id>} e {item:<id>}. Así el texto coincide con la ROM de RandomLocke.
func resolve_markers(text: String) -> String:
	var out := text
	for m: RegExMatch in _marker_regex.search_all(text):
		var label := _marker_name(m.get_string(1), StringName(m.get_string(2)))
		if label != "":
			out = out.replace(m.get_string(0), label)
	return out


func _marker_name(kind: String, id: StringName) -> String:
	var species_id := &""
	match kind:
		"item":
			return item(id).name if has_item(id) else ""
		"species":
			species_id = id
		"starter":
			species_id = starter(id) if _starters.has(String(id)) else &""
		"gift":
			species_id = StringName(str(gift(id).get("species", ""))) if _gifts.has(String(id)) else &""
		"static":
			species_id = StringName(str(static_encounter(id).get("species", ""))) if _statics.has(String(id)) else &""
		"trade":
			var t := trade(id) if _trades.has(String(id)) else {}
			var receive: Variant = t.get("receive", t)
			species_id = StringName(str(receive.get("species", ""))) if receive is Dictionary else StringName(str(receive))
	if species_id == &"" or not has_species(species_id):
		push_warning("DataDB: no se puede resolver el marcador {%s:%s}." % [kind, id])
		return ""
	return species(species_id).name


func _story_entry(table: Dictionary, patch_key: String, id: StringName, what: String) -> Dictionary:
	if not table.has(String(id)):
		push_error("DataDB: no existe %s '%s'." % [what, id])
		return {}
	var base: Variant = table[String(id)]
	var entry: Dictionary = {"species": str(base)} if base is String else (base as Dictionary).duplicate(true)
	var patched: Variant = _patch.get(patch_key, {}).get(String(id))
	if patched is String:
		entry["species"] = patched
	elif patched is Dictionary:
		entry.merge(patched, true)
	return entry


# --- Parche de RandomLocke (Fase R.1) ---

## Aplica una ROM: todas las consultas devuelven lo parcheado (no toca los datos base).
## Claves que entiende: species ({id: {campo: valor}}), abilities, learnsets, tm_compat, trainers,
## encounters, shops, starters, gifts, statics, trades e items (colocaciones).
func apply_patch(patch: Dictionary) -> void:
	_patch = patch.duplicate(true)
	_patched_species.clear()
	_level_moves_cache.clear()
	var fields: Dictionary = _patch.get("species", {})
	var abilities: Dictionary = _patch.get("abilities", {})
	for id: String in _union_keys(fields, abilities):
		if not _species.has(StringName(id)):
			push_error("DataDB.apply_patch: la especie '%s' no existe." % id)
			continue
		var raw: Dictionary = _species[StringName(id)].raw.duplicate(true)
		raw.merge(fields.get(id, {}), true)
		if abilities.has(id):
			raw["abilities"] = abilities[id]
		_patched_species[StringName(id)] = SpeciesData.from_dict(StringName(id), raw)
	patch_changed.emit()


## Vuelve a los datos base (al salir al título).
func clear_patch() -> void:
	if _patch.is_empty():
		return
	_patch = {}
	_patched_species.clear()
	_level_moves_cache.clear()
	patch_changed.emit()


func has_patch() -> bool:
	return not _patch.is_empty()


func current_patch() -> Dictionary:
	return _patch.duplicate(true)


func _union_keys(a: Dictionary, b: Dictionary) -> Array[String]:
	var out: Array[String] = []
	for k: Variant in a.keys() + b.keys():
		if str(k) not in out:
			out.append(str(k))
	out.sort()
	return out


## Versiones de las fuentes de data/generated (meta.json).
func meta() -> Dictionary:
	return _meta


## Regla configurable de data/world.json → "pokemon" (pc_boxes, exp_share...). Ver contrato.
func rule(key: StringName, default: Variant) -> Variant:
	return _rules.get(String(key), default)


## Shiny (Fase 6.7): data/world.json → "shiny" → odds (4096 por defecto; 0 = nunca).
func shiny_odds() -> int:
	return int(_shiny.get("odds", _rules.get("shiny_odds", 4096)))


## Tiradas de shiny (data/world.json → shiny → rolls): base 1, shiny_charm 3, masuda 6, masuda_shiny_charm 8.
func shiny_rolls(kind: StringName = &"base") -> int:
	var defaults := {"base": 1, "shiny_charm": 3, "masuda": 6, "masuda_shiny_charm": 8}
	return int(_shiny.get("rolls", {}).get(String(kind), defaults.get(String(kind), 1)))


# --- Carga ---

func _load_species() -> void:
	var raw := _read_dict(GENERATED_DIR + "/species.json")
	var overrides: Dictionary = _read_dict(SPECIES_OVERRIDES_PATH, true).get("species", {})
	for id: String in overrides:
		if id.begins_with("_"):
			continue
		var ov: Dictionary = overrides[id]
		var base_id := str(ov.get("base", ""))
		var entry: Dictionary
		if raw.has(id):
			entry = raw[id].duplicate(true)
		elif raw.has(base_id):
			entry = raw[base_id].duplicate(true)
		else:
			push_error("DataDB: species_overrides.json cambia '%s', que no existe (usa \"base\" para crear una especie nueva)." % id)
			continue
		for key: String in ov:
			if key != "base" and not key.begins_with("_"):
				entry[key] = ov[key]
		raw[id] = entry
	_species.clear()
	for id: String in raw:
		_species[StringName(id)] = SpeciesData.from_dict(StringName(id), raw[id])


func _load_moves() -> void:
	_moves.clear()
	var raw := _read_dict(GENERATED_DIR + "/moves.json")
	for id: String in raw:
		_moves[StringName(id)] = MoveData.from_dict(StringName(id), raw[id])


func _load_items() -> void:
	_items.clear()
	var raw := _read_dict(GENERATED_DIR + "/items.json")
	for id: String in raw:
		_items[StringName(id)] = ItemData.from_dict(StringName(id), raw[id])
	var panchito := _without_comments(_read_dict(ITEMS_PANCHITO_PATH, true))
	for id: String in panchito:
		if _items.has(StringName(id)):
			push_error("DataDB: el objeto Panchito '%s' usa el id de un objeto estándar." % id)
			continue
		_items[StringName(id)] = ItemData.from_dict(StringName(id), panchito[id], true)


func _load_regional_dex() -> void:
	_regional_dex.clear()
	_regional_index.clear()
	var data := _read_dict(REGIONAL_DEX_PATH, true)
	for id: Variant in data.get("species", []):
		var sid := StringName(str(id))
		if _regional_index.has(sid):
			push_error("DataDB: '%s' aparece dos veces en regional_dex.json." % sid)
			continue
		_regional_dex.append(sid)
		_regional_index[sid] = _regional_dex.size()


## Une todos los JSON de `dir` (y subcarpetas) en un solo diccionario id -> datos.
func _load_dir_merged(dir: String) -> Dictionary:
	var out := {}
	for path: String in _json_files(dir):
		var data := _without_comments(_read_dict(path))
		for id: String in data:
			if out.has(id):
				push_error("DataDB: el id '%s' está repetido (%s)." % [id, path])
				continue
			out[id] = data[id]
	return out


## Un JSON por archivo: id = ruta relativa a `dir` sin ".json" ("ruta_1", "ciudad2/cueva").
func _load_dir_by_file(dir: String) -> Dictionary:
	var out := {}
	for path: String in _json_files(dir):
		out[path.trim_prefix(dir + "/").trim_suffix(".json")] = _without_comments(_read_dict(path))
	return out


func _json_files(dir: String) -> Array[String]:
	var out: Array[String] = []
	if not DirAccess.dir_exists_absolute(dir):
		return out
	for file: String in DirAccess.get_files_at(dir):
		if file.ends_with(".json"):
			out.append(dir.path_join(file))
	for sub: String in DirAccess.get_directories_at(dir):
		out.append_array(_json_files(dir.path_join(sub)))
	out.sort()
	return out


## Los archivos `optional` pueden no existir todavía (datos de otros agentes): sin error.
func _read_dict(path: String, optional: bool = false) -> Dictionary:
	if optional and not FileAccess.file_exists(path):
		return {}
	return JsonFile.read_dict(path)


func _without_comments(data: Dictionary) -> Dictionary:
	for key: String in data.keys():
		if key.begins_with("_"):
			data.erase(key)
	return data


func _raw_get(table: Dictionary, id: StringName, what: String) -> Dictionary:
	if not table.has(String(id)):
		push_error("DataDB: no existe %s '%s'." % [what, id])
		return {}
	return table[String(id)]
