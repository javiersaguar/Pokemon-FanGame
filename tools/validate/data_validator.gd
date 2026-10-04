class_name DataValidator
extends RefCounted
## Validador de datos (Fase 4.6). Se ejecuta con el test tests/datos/test_validador.gd
## o desde la línea de comandos: godot --headless --path . -s res://tools/validate/validate.gd
## Errores = hay que arreglarlos antes de mergear. Avisos = pendientes conocidos (sprites, scripts...).

const SPRITE_ROOT := "res://assets/sprites/pokemon"
const CRIES_DIR := "res://assets/audio/cries"
const SPECIES_IN_USE_PATH := "res://data/species_in_use.json"
const WIKIDEX_CHECK := "res://data/generated/wikidex_check.json"
## Versiones que necesita cada especie que usa el juego (DIRECTRICES §7.2 y §8): todas, normal y shiny
## (los shiny son los oficiales del pack, nunca generados). Las copia tools/sprites/import_pokemon_assets.mjs.
const SPRITE_SETS: Array[String] = [
	"front", "front_shiny", "back", "back_shiny", "icons", "icons_shiny", "followers", "followers_shiny",
]
const ITEM_ICON_DIR := "res://assets/sprites/items"
const KNOWN_ITEM_EFFECTS: Array[StringName] = [
	&"heal_hp", &"cure_status", &"heal_and_cure", &"revive", &"restore_pp", &"boost_stat",
	&"crit_boost", &"ball", &"flee", &"repel", &"escape", &"evolution", &"add_evs", &"level_up",
	&"pp_up", &"exp_boost",
]
const SUPPORTED_EVOLUTION_METHODS: Array[String] = [
	"level", "friendship", "level_hold", "level_move", "level_extra", "item", "shed",
]

var errors: PackedStringArray = []
var warnings: PackedStringArray = []


static func run() -> DataValidator:
	var v := DataValidator.new()
	v._check_species()
	v._check_regional_dex()
	v._check_trainers()
	v._check_encounters()
	v._check_shops()
	v._check_panchito_items()
	v._check_moves_in_use()
	v._check_sprites()
	v._check_wikidex()
	return v


func report() -> String:
	var lines: PackedStringArray = ["Validador: %d errores, %d avisos." % [errors.size(), warnings.size()]]
	for e: String in errors:
		lines.append("  ERROR: " + e)
	for w: String in warnings:
		lines.append("  aviso: " + w)
	return "\n".join(lines)


func _error(text: String) -> void:
	errors.append(text)


func _warn(text: String) -> void:
	warnings.append(text)


# --- Especies y evoluciones ---

func _check_species() -> void:
	for id: StringName in DataDB.species_ids():
		var s := DataDB.species(id)
		for evo: Dictionary in s.evolutions:
			var method := str(evo.get("method", ""))
			if method == "trade":
				_error("%s → %s evoluciona por intercambio (sustitúyela en species_overrides.json)." % [id, evo.get("to", "?")])
			if not DataDB.has_species(StringName(evo.get("to", ""))):
				_error("%s evoluciona a '%s', que no existe." % [id, evo.get("to", "")])
			if evo.has("item") and not DataDB.has_item(StringName(evo["item"])):
				_error("%s → %s pide el objeto '%s', que no existe." % [id, evo.get("to", "?"), evo["item"]])


func _check_regional_dex() -> void:
	var dex := DataDB.regional_dex()
	if dex.is_empty():
		_warn("La Pokédex regional (data/regional_dex.json) está vacía: la decide Javier.")
		return
	var obtainable := _obtainable_species()
	for id: StringName in dex:
		if not DataDB.has_species(id):
			_error("regional_dex.json: la especie '%s' no existe." % id)
			continue
		var s := DataDB.species(id)
		if s.is_form():
			_error("regional_dex.json: '%s' es una forma; pon su especie (%s)." % [id, s.base_species])
		if not obtainable.has(id):
			_warn("%s no sale en ningún encuentro ni por evolución." % id)
		for evo: Dictionary in s.evolutions:
			var method := str(evo.get("method", ""))
			if not evo.has("region") and method not in SUPPORTED_EVOLUTION_METHODS:
				_warn("%s → %s: el método '%s' no está implementado (%s)." % [id, evo.get("to", "?"), method, evo.get("condition", "")])


## Especies (base) que aparecen en encuentros y todas las que salen de ellas evolucionando.
func _obtainable_species() -> Dictionary:
	var found := {}
	for table_id: String in _encounter_ids():
		for entry: Dictionary in _encounter_entries(DataDB.encounter_table(StringName(table_id))):
			found[StringName(entry.get("species", ""))] = true
	var changed := true
	while changed:
		changed = false
		for id: StringName in found.keys():
			if not DataDB.has_species(id):
				continue
			for evo: Dictionary in DataDB.species(id).evolutions:
				var to := StringName(evo.get("to", ""))
				if not found.has(to):
					found[to] = true
					changed = true
	return found


# --- Sprites ---

## Especies que se pueden ver en el juego: Pokédex regional, encuentros, entrenadores y sus evoluciones.
## Especies que usa el juego: Pokédex regional, data/species_in_use.json, encuentros, entrenadores,
## iniciales, regalos, estáticos e intercambios, con sus familias evolutivas (igual que el importador).
func _species_in_game() -> Dictionary:
	var species := _obtainable_species()
	for id: StringName in DataDB.regional_dex():
		species[id] = true
	for id: Variant in JsonFile.read_dict(SPECIES_IN_USE_PATH).get("species", []) if FileAccess.file_exists(SPECIES_IN_USE_PATH) else []:
		species[StringName(str(id))] = true
	for trainer_id: StringName in DataDB.trainer_ids():
		for spec: Dictionary in DataDB.trainer(trainer_id).get("party", []):
			species[StringName(str(spec.get("species", "")))] = true
	for id: StringName in DataDB.starter_ids():
		species[DataDB.starter(id)] = true
	for id: StringName in DataDB.gift_ids():
		species[StringName(str(DataDB.gift(id).get("species", "")))] = true
	for id: StringName in DataDB.static_ids():
		species[StringName(str(DataDB.static_encounter(id).get("species", "")))] = true
	var queue: Array = species.keys()
	while not queue.is_empty():
		var id: StringName = queue.pop_back()
		if not DataDB.has_species(id):
			continue
		var s := DataDB.species(id)
		var next: Array[StringName] = [s.prevo]
		for evo: Dictionary in s.evolutions:
			if not evo.has("region"):
				next.append(StringName(str(evo.get("to", ""))))
		for n: StringName in next:
			if n != &"" and DataDB.has_species(n) and not species.has(n):
				species[n] = true
				queue.append(n)
	species.erase(&"")
	return species


func _check_sprites() -> void:
	var species: Array = _species_in_game().keys()
	DataUtil.sort_names(species)
	for set_name: String in SPRITE_SETS:
		var missing: PackedStringArray = []
		for id: StringName in species:
			if DataDB.has_species(id) and not FileAccess.file_exists("%s/%s/%s.png" % [SPRITE_ROOT, set_name, id]):
				missing.append(String(id))
		if not missing.is_empty():
			_error("Faltan %d versiones en %s/%s/ (node tools/sprites/import_pokemon_assets.mjs): %s" % [
				missing.size(), SPRITE_ROOT, set_name, ", ".join(missing)])
	var no_cry: PackedStringArray = []
	for id: StringName in species:
		if DataDB.has_species(id) and not FileAccess.file_exists("%s/%s.ogg" % [CRIES_DIR, id]):
			no_cry.append(String(id))
	if not no_cry.is_empty():
		_error("Faltan %d gritos en %s/ (node tools/sprites/import_pokemon_assets.mjs): %s" % [
			no_cry.size(), CRIES_DIR, ", ".join(no_cry)])


# --- Estadísticas comprobadas con WikiDex (DIRECTRICES §3) ---

func _check_wikidex() -> void:
	if not FileAccess.file_exists(WIKIDEX_CHECK):
		_warn("Las estadísticas no se han comprobado con WikiDex (node tools/wikidex/verify_stats.mjs).")
		return
	var report := JsonFile.read_dict(WIKIDEX_CHECK)
	for m: Dictionary in report.get("mismatches", []):
		_warn("WikiDex: %s tiene estadísticas distintas: %s" % [m.get("species", "?"), "; ".join(PackedStringArray(m.get("differences", [])))])
	var checked := {}
	for id: Variant in report.get("species", []):
		checked[StringName(str(id))] = true
	var pending: PackedStringArray = []
	var in_game: Array = _species_in_game().keys()
	DataUtil.sort_names(in_game)
	for id: StringName in in_game:
		if DataDB.has_species(id) and not DataDB.species(id).is_form() and not checked.has(id):
			pending.append(String(id))
	pending.sort()
	if not pending.is_empty():
		_warn("Sin comprobar con WikiDex (node tools/wikidex/verify_stats.mjs): %s" % ", ".join(pending))


# --- Entrenadores ---

func _check_trainers() -> void:
	for id: StringName in DataDB.trainer_ids():
		var t := DataDB.trainer(id)
		var class_id := StringName(t.get("class", ""))
		if not DataDB.has_trainer_class(class_id):
			_error("Entrenador %s: la clase '%s' no existe." % [id, class_id])
		if str(t.get("lose_text", "")) == "":
			_error("Entrenador %s: falta lose_text." % id)
		var team: Array = t.get("party", [])
		if team.is_empty() or team.size() > 6:
			_error("Entrenador %s: el equipo debe tener de 1 a 6 Pokémon." % id)
		for item_id: Variant in t.get("items", []):
			if not DataDB.has_item(StringName(str(item_id))):
				_error("Entrenador %s: el objeto '%s' no existe." % [id, item_id])
		for spec: Dictionary in team:
			_check_spec(spec, "Entrenador %s" % id)


func _check_spec(spec: Dictionary, where: String) -> void:
	var species := StringName(str(spec.get("species", "")))
	if not DataDB.has_species(species):
		_error("%s: la especie '%s' no existe." % [where, species])
		return
	var level := int(spec.get("level", 0))
	if level < 1 or level > DataDB.MAX_LEVEL:
		_error("%s: %s tiene un nivel no válido (%d)." % [where, species, level])
	for move_id: Variant in spec.get("moves", []):
		var m := StringName(str(move_id))
		if not DataDB.has_move(m):
			_error("%s: el movimiento '%s' de %s no existe." % [where, m, species])
		elif not DataDB.can_learn(species, m):
			_warn("%s: %s no puede aprender '%s' de forma normal." % [where, species, m])
	if spec.has("item") and not DataDB.has_item(StringName(str(spec["item"]))):
		_error("%s: el objeto '%s' no existe." % [where, spec["item"]])
	if spec.has("ability"):
		var s := DataDB.species(species)
		if StringName(str(spec["ability"])) not in s.abilities.values():
			_error("%s: %s no puede tener la habilidad '%s'." % [where, species, spec["ability"]])
	if spec.has("nature") and DataDB.nature(StringName(str(spec["nature"]))) == null:
		_error("%s: la naturaleza '%s' no existe." % [where, spec["nature"]])


# --- Encuentros ---

func _encounter_ids() -> Array[String]:
	var out: Array[String] = []
	var dir := DataDB.ENCOUNTERS_DIR
	for path: String in _json_files(dir):
		out.append(path.trim_prefix(dir + "/").trim_suffix(".json"))
	return out


func _encounter_entries(table: Dictionary) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for key: String in table:
		var value: Variant = table[key]
		var lists: Array = []
		if value is Array:
			lists.append(value)
		elif value is Dictionary:
			lists.append_array((value as Dictionary).values())
		for list: Variant in lists:
			if list is Array:
				for entry: Variant in list:
					if entry is Dictionary:
						out.append(entry)
	return out


func _check_encounters() -> void:
	for table_id: String in _encounter_ids():
		for entry: Dictionary in _encounter_entries(DataDB.encounter_table(StringName(table_id))):
			var species := StringName(str(entry.get("species", "")))
			var where := "Encuentros %s" % table_id
			if not DataDB.has_species(species):
				_error("%s: la especie '%s' no existe." % [where, species])
			var lo := int(entry.get("min", 0))
			var hi := int(entry.get("max", 0))
			if lo < 1 or hi > DataDB.MAX_LEVEL or lo > hi:
				_error("%s: niveles no válidos para %s (%d-%d)." % [where, species, lo, hi])
			if float(entry.get("weight", 0)) <= 0.0:
				_error("%s: %s tiene peso 0 o negativo." % [where, species])


# --- Tiendas y objetos ---

func _check_shops() -> void:
	var data := JsonFile.read_dict(DataDB.SHOPS_PATH) if FileAccess.file_exists(DataDB.SHOPS_PATH) else {}
	var shops: Dictionary = data.get("shops", {})
	for shop_id: String in shops:
		for tier: Dictionary in shops[shop_id].get("stock", []):
			for item_id: Variant in tier.get("items", []):
				var id := StringName(str(item_id))
				if not DataDB.has_item(id):
					_error("Tienda %s: el objeto '%s' no existe." % [shop_id, id])
					continue
				if DataDB.item(id).price <= 0 and not shops[shop_id].get("prices", {}).has(String(id)):
					_error("Tienda %s: '%s' no tiene precio." % [shop_id, id])
				_check_icon(id, "Tienda %s" % shop_id)


func _check_icon(item_id: StringName, where: String) -> void:
	if not ResourceLoader.exists("%s/%s.png" % [ITEM_ICON_DIR, item_id]):
		_warn("%s: '%s' no tiene icono en %s/." % [where, item_id, ITEM_ICON_DIR])


func _check_panchito_items() -> void:
	for id: StringName in DataDB.item_ids():
		var it := DataDB.item(id)
		if not it.is_panchito:
			continue
		for field: String in ["name", "pocket", "description"]:
			if str(it.raw.get(field, "")) == "":
				_error("Objeto Panchito %s: falta '%s'." % [id, field])
		if it.effect != &"" and it.effect not in KNOWN_ITEM_EFFECTS:
			_warn("Objeto Panchito %s: el efecto '%s' necesita script propio (src/items/effects/panchito/)." % [id, it.effect])
		_check_icon(id, "Objeto Panchito")


# --- Movimientos que se usan en el juego ---

## Movimientos de los entrenadores y los que aprenden por nivel las especies que se pueden conseguir
## (Pokédex regional, encuentros y entrenadores). Avisa de los que necesitan script (Fase 9.2).
func _check_moves_in_use() -> void:
	var species := _obtainable_species()
	for id: StringName in DataDB.regional_dex():
		species[id] = true
	var used := {}
	for trainer_id: StringName in DataDB.trainer_ids():
		for spec: Dictionary in DataDB.trainer(trainer_id).get("party", []):
			species[StringName(str(spec.get("species", "")))] = true
			for move_id: Variant in spec.get("moves", []):
				used[StringName(str(move_id))] = "entrenador %s" % trainer_id
	for id: StringName in species:
		if not DataDB.has_species(id):
			continue
		for entry: Array in DataDB.level_up_moves(id):
			if not used.has(entry[1]):
				used[entry[1]] = String(id)
	var missing: PackedStringArray = []
	for move_id: StringName in used:
		if DataDB.has_move(move_id) and DataDB.move(move_id).needs_script:
			missing.append("%s (%s)" % [move_id, used[move_id]])
	missing.sort()
	if not missing.is_empty():
		_warn("%d movimientos en uso necesitan script (Fase 9.2; de momento solo hacen la parte de datos): %s" % [
			missing.size(), ", ".join(missing)])


func _json_files(dir: String) -> Array[String]:
	var out: Array[String] = []
	if not DirAccess.dir_exists_absolute(dir):
		return out
	for file: String in DirAccess.get_files_at(dir):
		if file.ends_with(".json"):
			out.append(dir.path_join(file))
	for sub: String in DirAccess.get_directories_at(dir):
		out.append_array(_json_files(dir.path_join(sub)))
	return out
