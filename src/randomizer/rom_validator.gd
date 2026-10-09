class_name RomValidator
extends RefCounted
## Validación de una ROM generada (Fase R.4). Lee los datos base de DataDB y el parche, sin
## aplicarlo (para poder usarse desde otro hilo). Devuelve los problemas (vacío = válida).


static func validate(input_or_patch: Variant, with_patch: RomPatch = null) -> Array[String]:
	var patch: RomPatch = with_patch if with_patch != null else input_or_patch
	if with_patch != null:
		patch.input = input_or_patch
	elif patch.input == null:
		patch.input = RandomizerInput.from_datadb()
	var input: RandomizerInput = patch.input
	var preflight := _preflight(input, patch)
	if not preflight.is_empty():
		return preflight
	var problems: PackedStringArray = []
	_check_starters(patch, problems)
	for id: StringName in species_in_play(patch):
		if not input.has_species(id):
			problems.append("La especie '%s' no existe." % id)
			continue
		var level := _first_level_without_damage(patch, id)
		if level > 0:
			problems.append("%s no tiene ningún ataque de daño al nivel %d." % [id, level])
	_check_encounters(patch, problems)
	_check_trainers(patch, problems)
	_check_fixed(patch, problems)
	_check_extra(input, patch, problems)
	_check_structure(input, patch, problems)
	var result: Array[String] = []
	result.assign(problems)
	return result


# --- Datos efectivos ---

static func evolutions(patch: RomPatch, id: StringName) -> Array:
	var input: RandomizerInput = patch.input
	var patched: Variant = patch.section("species").get(String(id), {}).get("evolutions")
	if patched != null:
		return patched
	return input.species(id).evolutions if input.has_species(id) else []


static func level_moves(patch: RomPatch, id: StringName) -> Array:
	var input: RandomizerInput = patch.input
	var patched: Variant = patch.section("learnsets").get(String(id))
	if patched != null:
		return patched
	return input.learnset(id).get("level", []) if input.has_species(id) else []


## Los 4 últimos movimientos aprendidos por nivel hasta `level` (como input.default_moves).
static func default_moves(patch: RomPatch, id: StringName, level: int) -> Array[StringName]:
	var input: RandomizerInput = patch.input
	var out: Array[StringName] = []
	for entry: Array in level_moves(patch, id):
		var m := StringName(str(entry[1]))
		if int(entry[0]) < 1 or int(entry[0]) > level or not input.has_move(m):
			continue
		out.erase(m)
		out.append(m)
	return out.slice(maxi(0, out.size() - 4))


static func is_damaging(move_id: StringName, base: RandomizerInput = null) -> bool:
	var input: RandomizerInput = base
	if input == null:
		var db: Node = (Engine.get_main_loop() as SceneTree).root.get_node("DataDB")
		if not db.has_move(move_id):
			return false
		var move: MoveData = db.move(move_id)
		return move.is_damaging() and (move.power > 0 or move.fixed_damage > 0 or move.level_damage)
	if not input.has_move(move_id):
		return false
	var m := input.move(move_id)
	return m.is_damaging() and (m.power > 0 or m.fixed_damage > 0 or m.level_damage)


## Especies que se pueden ver en la partida con esta ROM (iniciales, salvajes, entrenadores,
## regalos, estáticos, intercambios y la Pokédex regional) y todas sus evoluciones, ordenadas.
static func species_in_play(patch: RomPatch) -> Array[StringName]:
	var input: RandomizerInput = patch.input
	var found := {}
	for id: StringName in input.starter_ids():
		found[StringName(str(patch.section("starters").get(String(id), input.starter(id))))] = true
	for id: StringName in wild_species(patch):
		found[id] = true
	for id: StringName in input.trainer_ids():
		for spec: Dictionary in _trainer_party(patch, id):
			found[StringName(str(spec.get("species", "")))] = true
	for id: StringName in input.gift_ids():
		found[StringName(str(patch.section("gifts").get(String(id), input.gift(id).get("species", ""))))] = true
	for id: StringName in input.static_ids():
		found[StringName(str(patch.section("statics").get(String(id), input.static_encounter(id).get("species", ""))))] = true
	for id: StringName in input.trade_ids():
		var t: Dictionary = input.trade(id).duplicate(true)
		t.merge(patch.section("trades").get(String(id), {}), true)
		var receive: Variant = t.get("receive", {})
		if receive is Dictionary and receive.has("species"):
			found[StringName(str(receive["species"]))] = true
	for id: StringName in input.regional_dex():
		found[id] = true
	found.erase(&"")
	var queue: Array = found.keys()
	while not queue.is_empty():
		var id: StringName = queue.pop_back()
		for evo: Dictionary in evolutions(patch, id):
			var to := StringName(str(evo.get("to", "")))
			if not evo.has("region") and input.has_species(to) and not found.has(to):
				found[to] = true
				queue.append(to)
	var out: Array[StringName] = []
	out.assign(found.keys())
	DataUtil.sort_names(out)
	return out


static func wild_species(patch: RomPatch) -> Array[StringName]:
	var input: RandomizerInput = patch.input
	var found := {}
	var ids := input.encounter_ids()
	DataUtil.sort_names(ids)
	for table_id: StringName in ids:
		var table: Dictionary = patch.section("encounters").get(String(table_id), input.encounter_table(table_id))
		for entry: Dictionary in _entries(table):
			found[StringName(str(entry.get("species", "")))] = true
	found.erase(&"")
	var out: Array[StringName] = []
	out.assign(found.keys())
	DataUtil.sort_names(out)
	return out


static func _entries(table: Dictionary) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	_collect_entries(table, out)
	return out

static func _collect_entries(value: Variant, out: Array[Dictionary]) -> void:
	if value is Dictionary:
		if value.has("species"):
			out.append(value)
		else:
			var keys: Array = value.keys()
			DataUtil.sort_names(keys)
			for key: Variant in keys:
				_collect_entries(value[key], out)
	elif value is Array:
		for entry: Variant in value:
			_collect_entries(entry, out)


static func _trainer_party(patch: RomPatch, id: StringName) -> Array:
	var input: RandomizerInput = patch.input
	var patched: Variant = patch.section("trainers").get(String(id), {}).get("party")
	return patched if patched != null else input.trainer(id).get("party", [])


# --- Comprobaciones ---

static func _check_starters(patch: RomPatch, problems: PackedStringArray) -> void:
	var input: RandomizerInput = patch.input
	var seen := {}
	for id: StringName in input.starter_ids():
		var species := StringName(str(patch.section("starters").get(String(id), input.starter(id))))
		if seen.has(species):
			problems.append("Iniciales repetidos: %s." % species)
		seen[species] = true
		var level := int(input.starter_spec(id).get("level", 5))
		var has_damage := false
		for m: StringName in default_moves(patch, species, level):
			has_damage = has_damage or is_damaging(m, input)
		if not has_damage:
			problems.append("El inicial %s no tiene ningún ataque de daño al nivel %d." % [species, level])


## Primer nivel (1..100) en el que los 4 últimos movimientos aprendidos no incluyen ninguno de daño; 0 si nunca.
static func _first_level_without_damage(patch: RomPatch, id: StringName) -> int:
	var input: RandomizerInput = patch.input
	var window: Array[StringName] = []
	var levels: Array = level_moves(patch, id)
	if levels.is_empty():
		return 1
	for index: int in levels.size():
		var entry: Array = levels[index]
		if int(entry[0]) < 1:
			continue
		var m := StringName(str(entry[1]))
		window.erase(m)
		window.append(m)
		if window.size() > 4:
			window.pop_front()
		if index + 1 < levels.size() and int(levels[index + 1][0]) == int(entry[0]):
			continue
		var ok := false
		for w: StringName in window:
			ok = ok or is_damaging(w, input)
		if not ok:
			return int(entry[0])
	return 0


static func _check_encounters(patch: RomPatch, problems: PackedStringArray) -> void:
	var input: RandomizerInput = patch.input
	for table_id: StringName in input.encounter_ids():
		var before := _entries(input.encounter_table(table_id))
		var after := _entries(patch.section("encounters").get(String(table_id), input.encounter_table(table_id)))
		if not before.is_empty() and after.is_empty():
			problems.append("La zona %s se ha quedado sin Pokémon." % table_id)
		for entry: Dictionary in after:
			if not input.has_species(StringName(str(entry.get("species", "")))):
				problems.append("Zona %s: la especie '%s' no existe." % [table_id, entry.get("species", "")])


static func _check_trainers(patch: RomPatch, problems: PackedStringArray) -> void:
	var input: RandomizerInput = patch.input
	for id: StringName in input.trainer_ids():
		var seen := {}
		for spec: Dictionary in _trainer_party(patch, id):
			var species := StringName(str(spec.get("species", "")))
			if not input.has_species(species):
				problems.append("Entrenador %s: la especie '%s' no existe." % [id, species])
			elif seen.has(species) and patch.section("trainers").has(String(id)) and not patch.settings().trainer_duplicates:
				problems.append("Entrenador %s: %s repetido en el equipo." % [id, species])
			seen[species] = true


static func _check_fixed(patch: RomPatch, problems: PackedStringArray) -> void:
	var input: RandomizerInput = patch.input
	for kind: String in ["gifts", "statics", "trades"]:
		var ids := input.gift_ids() if kind == "gifts" else (input.static_ids() if kind == "statics" else input.trade_ids())
		for id: StringName in ids:
			var base := input.gift(id) if kind == "gifts" else (input.static_encounter(id) if kind == "statics" else input.trade(id))
			if base.get("randomize", true) == false and patch.section(kind).has(String(id)):
				problems.append("%s '%s' no se debía aleatorizar." % [kind, id])
	for pid: Variant in patch.section("items"):
		var record: Variant = input.item_placements().get(pid, "")
		var original := StringName(str(record.get("item", ""))) if record is Dictionary else StringName(str(record))
		if input.has_item(original) and input.item(original).is_key_item():
			problems.append("El objeto clave de %s ha cambiado." % pid)

static func _check_extra(input: RandomizerInput, patch: RomPatch, problems: PackedStringArray) -> void:
	if patch.data.get("input_hash", "") != input.fingerprint:
		problems.append("La ROM corresponde a otros datos base (input_hash).")
	var settings := patch.settings()
	for section_name: String in RomPatch.KEYS:
		var base_name := "placements" if section_name == "items" else section_name
		var base: Dictionary = input.data.get(base_name, {})
		for id: String in patch.section(section_name):
			if section_name == "species_map":
				continue
			if not base.has(id) and section_name not in ["abilities", "tm_compat", "tutor_compat"]:
				problems.append("ID desconocido en %s: %s." % [section_name, id])
			if base.get(id) is Dictionary and base[id].get("randomize", true) == false:
				problems.append("Registro protegido en %s: %s." % [section_name, id])
			if section_name in ["species", "abilities", "learnsets", "tm_compat", "tutor_compat"] and input.has_species(StringName(id)) and not input.mutable_species(StringName(id)):
				problems.append("Especie protegida: %s." % id)
	# Validación de cada aparición reemplazada: nivel, BST, prohibidos, duplicados y flags de slot.
	for table_id: String in input.ids("encounters"):
		var before: Array[Dictionary] = _entries(input.data.encounters[table_id])
		var after: Array[Dictionary] = _entries(patch.section("encounters").get(table_id, input.data.encounters[table_id]))
		var capturable := false
		for i: int in after.size():
			var row: Dictionary = after[i]
			var sid := StringName(str(row.get("species", "")))
			capturable = capturable or input.has_species(sid) and input.species(sid).catch_rate > 0
			if i < before.size() and patch.section("encounters").has(table_id):
				_check_replacement(input, patch, before[i], row, problems, "Zona " + table_id, bool(input.data.encounters[table_id].get("early", false)))
		if not before.is_empty() and not capturable:
			problems.append("Zona sin especie capturable: %s." % table_id)
	for id: String in patch.section("trainers"):
		var before: Array = input.data.trainers.get(id, {}).get("party", [])
		var after: Array = patch.section("trainers")[id].get("party", [])
		for i: int in mini(before.size(), after.size()):
			_check_replacement(input, patch, before[i], after[i], problems, "Entrenador " + id)
	# IDs de objetos y máquinas; objetos de progreso nunca se retiran.
	var obtainable: Dictionary = {}
	for pid: String in input.ids("placements"):
		var entry: Variant = input.data.placements[pid]
		var original := str(entry.get("item", "")) if entry is Dictionary else str(entry)
		var item_id := str(patch.section("items").get(pid, original))
		obtainable[item_id] = true
		if not input.has_item(StringName(item_id)):
			problems.append("Objeto inexistente: %s." % item_id)
		if patch.section("items").has(pid) and input.has_item(StringName(original)) and (input.item(StringName(original)).is_key_item() or input.item(StringName(original)).raw.get("randomize", true) == false):
			problems.append("Objeto protegido: %s." % pid)
	for shop_id: String in input.ids("shops"):
		var shop: Dictionary = patch.section("shops").get(shop_id, input.data.shops[shop_id])
		for tier: Dictionary in shop.get("stock", []):
			for item_id: Variant in tier.get("items", []):
				obtainable[str(item_id)] = true
				if not input.has_item(StringName(str(item_id))):
					problems.append("Objeto desconocido en tienda: %s." % item_id)
		if patch.section("shops").has(shop_id):
			var first: Array = shop.get("stock", [{}])[0].get("items", [])
			for guaranteed: Variant in input.data.config.get("shop_guaranteed", []):
				if guaranteed not in first:
					problems.append("Falta %s en %s." % [guaranteed, shop_id])
	for id: Variant in input.data.get("required_items", []):
		if not obtainable.has(str(id)):
			problems.append("Objeto necesario no obtenible: %s." % id)
	# Una sola vez: recorre entrenadores, encuentros y evoluciones, y aquí se consulta por cada MT y tutor.
	var in_play := species_in_play(patch)
	var obtained_moves: Dictionary = {}
	for id: StringName in in_play:
		for entry: Array in level_moves(patch, id):
			obtained_moves[str(entry[1])] = true
	for kind: String in ["tm", "tutor"]:
		var table: Dictionary = input.data.get(kind + "_moves", {}).duplicate(true)
		table.merge(patch.section(kind + "_moves"), true)
		for id: String in table:
			var move_id := str(table[id].get("move", ""))
			if not input.has_move(StringName(move_id)):
				problems.append("Movimiento desconocido en %s." % id)
			for species_id: StringName in in_play:
				var compat: Array = patch.section(kind + "_compat").get(String(species_id), input.data.get(kind + "_compat", {}).get(String(species_id), []))
				if id in compat:
					obtained_moves[move_id] = true
		for species_id: String in patch.section(kind + "_compat"):
			for machine_id: Variant in patch.section(kind + "_compat")[species_id]:
				if not table.has(str(machine_id)):
					problems.append("Compatibilidad desconocida: %s." % machine_id)
	for id: Variant in input.data.get("required_moves", []):
		if not obtained_moves.has(str(id)):
			problems.append("Movimiento necesario no obtenible: %s." % id)
	for id: String in patch.section("species"):
		var changes: Dictionary = patch.section("species")[id]
		if changes.has("base_stats") and _bst(input.species(StringName(id)).base_stats) != _bst(changes.base_stats):
			problems.append("Total de estadísticas alterado: %s." % id)
		for type_id: Variant in changes.get("types", []):
			if not input.data.types.has(str(type_id)):
				problems.append("Tipo desconocido: %s." % type_id)
		for evo: Dictionary in changes.get("evolutions", []):
			var target := StringName(str(evo.get("to", "")))
			if not input.has_species(target):
				problems.append("Evolución desconocida: %s." % target)
			elif not evo.has("region") and _bst(input.species(target).base_stats) <= _bst(input.species(StringName(id)).base_stats):
				problems.append("Evolución cíclica o sin crecimiento: %s." % id)
	for id: String in patch.section("abilities"):
		for ability: Variant in patch.section("abilities")[id].values():
			if not input.has_ability(StringName(str(ability))) or str(ability) in input.data.config.get("banned_abilities", []):
				problems.append("Habilidad prohibida o desconocida: %s." % ability)

static func _bst(stats: Dictionary) -> int:
	var result := 0
	for value: Variant in stats.values():
		result += int(value)
	return result

static func _check_replacement(input: RandomizerInput, patch: RomPatch, before: Dictionary, after: Dictionary, problems: PackedStringArray, label: String, early: bool = false) -> void:
	var original := StringName(str(before.get("species", "")))
	var chosen := StringName(str(after.get("species", "")))
	if before.get("randomize", true) == false or not input.mutable_species(original):
		if before != after:
			problems.append("Slot protegido alterado: %s." % label)
		return
	if not input.has_species(chosen):
		return
	if String(chosen) in input.data.config.get("banned_species", []):
		problems.append("Especie prohibida en %s." % label)
	var settings := patch.settings()
	var low := int(after.get("level", after.get("min", after.get("min_level", 1))))
	var high := int(after.get("level", after.get("max", after.get("max_level", low))))
	var legendary := input.species(chosen).is_legendary or input.species(chosen).is_mythical
	for tag: StringName in input.species(chosen).tags:
		legendary = legendary or String(tag) in input.data.config.get("legendary_tags", [])
	if legendary and (not settings.allow_legendaries or settings.no_early_legendaries and (early or low < int(input.data.config.get("early_legendary_level", 30)))):
		problems.append("Legendario excluido en %s." % label)
	if settings.similar_strength and input.has_species(original):
		var bst := _bst(input.species(original).base_stats)
		if absf(_bst(input.species(chosen).base_stats) - bst) > bst * settings.strength_tolerance / 100.0:
			problems.append("Fuera de tolerancia BST: %s." % label)
	if settings.level_appropriate:
		var r := Randomizer.new()
		r.input = input
		r.patch = patch
		r.settings = settings
		r.config = input.data.config
		r._index_prevos()
		if r._min_level(chosen) > low or high >= r._max_level(chosen):
			problems.append("Etapa no acorde al nivel: %s." % label)

static func _check_structure(input: RandomizerInput, patch: RomPatch, problems: PackedStringArray) -> void:
	var settings := patch.settings()
	for id: String in patch.section("learnsets"):
		var rows: Array = patch.section("learnsets")[id]
		var base_rows: Array = input.learnset(StringName(id)).get("level", [])
		if rows.size() != base_rows.size():
			problems.append("Cantidad de movimientos alterada: %s." % id)
		var previous := -1
		var stab_count := 0
		var types: Array = patch.section("species").get(id, {}).get("types", Array(input.species(StringName(id)).types))
		for index: int in rows.size():
			var row: Array = rows[index]
			var level := int(row[0])
			var move_id := StringName(str(row[1]))
			if level < previous:
				problems.append("Curva desordenada: %s." % id)
			previous = level
			if not input.has_move(move_id):
				problems.append("Movimiento inexistente: %s." % move_id)
				continue
			var move := input.move(move_id)
			if String(move_id) in input.data.config.get("banned_moves", []):
				problems.append("Movimiento prohibido: %s." % move_id)
			if settings.only_implemented_moves and move.needs_script:
				problems.append("Movimiento sin implementar: %s." % move_id)
			if move.type in DataUtil.names(types):
				stab_count += 1
			if settings.scaled_power:
				var cap := 9999
				for limit: Array in input.data.config.get("power_caps", []):
					if maxi(1, level) <= int(limit[0]):
						cap = int(limit[1])
						break
				if settings.guarantee_stab and move.type in DataUtil.names(types) and is_damaging(move_id, input):
					cap = maxi(cap, int(input.data.config.get("low_power_stab_cap_overrides", {}).get(String(move.type), cap)))
				if move.power > cap:
					problems.append("Potencia excesiva a nivel %d: %s." % [level, id])
		if settings.guarantee_stab:
			var has_stab := false
			for move_id: StringName in default_moves(patch, StringName(id), 1):
				has_stab = has_stab or is_damaging(move_id, input) and input.move(move_id).type in DataUtil.names(types)
			if not has_stab:
				problems.append("Sin STAB de daño al nivel 1: %s." % id)
		if settings.learnsets == "type_preference" and stab_count < ceili(rows.size() / 2.0):
			problems.append("Preferencia STAB menor del 50 %%: %s." % id)
		if _first_level_without_damage(patch, StringName(id)) > 0:
			problems.append("Curva sin ataque de daño: %s." % id)
	for id: String in patch.section("trainers"):
		var original: Dictionary = input.data.trainers.get(id, {})
		var party: Array = patch.section("trainers")[id].get("party", [])
		var before: Array = original.get("party", [])
		if before.size() != party.size():
			problems.append("Tamaño de equipo alterado: %s." % id)
		var theme := str(original.get("leader_type", original.get("type_theme", "")))
		for index: int in mini(before.size(), party.size()):
			if before[index].get("level") != party[index].get("level"):
				problems.append("Nivel del entrenador alterado: %s." % id)
			var sid := StringName(str(party[index].get("species", "")))
			if not input.has_species(sid):
				continue
			var types: Array = patch.section("species").get(String(sid), {}).get("types", Array(input.species(sid).types))
			if settings.keep_type_themes and not theme.is_empty() and theme not in types:
				problems.append("Tipo del líder alterado: %s." % id)
		if settings.leader_ace and original.has("ace_index"):
			var ace := int(original.ace_index)
			if ace >= 0 and ace < party.size() and input.has_species(StringName(str(party[ace].species))):
				var strength := _bst(input.species(StringName(str(party[ace].species))).base_stats)
				for pokemon: Dictionary in party:
					if input.has_species(StringName(str(pokemon.species))) and _bst(input.species(StringName(str(pokemon.species))).base_stats) > strength:
						problems.append("As no es el más fuerte: %s." % id)
	for table_id: String in patch.section("encounters"):
		var before: Array[Dictionary] = _entries(input.data.encounters.get(table_id, {}))
		var after: Array[Dictionary] = _entries(patch.section("encounters")[table_id])
		if before.size() != after.size():
			problems.append("Cantidad de slots alterada: %s." % table_id)
		for index: int in mini(before.size(), after.size()):
			for field: String in ["min", "max", "min_level", "max_level", "weight", "chance"]:
				if before[index].get(field) != after[index].get(field):
					problems.append("Slot de encuentro alterado: %s/%s." % [table_id, field])
	var mapped: Dictionary = {}
	for id: String in patch.section("species_map"):
		var chosen := str(patch.section("species_map")[id])
		if mapped.has(chosen):
			problems.append("Mapeo global no es 1:1: %s." % id)
		mapped[chosen] = true
	for id: String in patch.section("species"):
		var changed: Dictionary = patch.section("species")[id]
		var rows: Array = changed.get("held_items", [])
		for row: Variant in rows:
			var item_id := str(row.get("item", "")) if row is Dictionary else str(row)
			if not input.has_item(StringName(item_id)):
				problems.append("Objeto equipado desconocido: %s." % item_id)

static func _preflight(input: RandomizerInput, patch: RomPatch) -> Array[String]:
	var problems: Array[String] = []
	if patch.data.get("settings") is not Dictionary:
		problems.append("Faltan los ajustes de la ROM.")
		return problems
	problems.append_array(RandomizerSettings.errors(patch.data.settings))
	for section: String in RomPatch.KEYS:
		if patch.data.get(section, {}) is not Dictionary:
			problems.append("Tabla inválida: %s." % section)
			return problems
	for id: String in patch.section("species"):
		if not input.has_species(StringName(id)) or patch.section("species")[id] is not Dictionary:
			problems.append("Registro de especie inválido: %s." % id)
			continue
		var changes: Dictionary = patch.section("species")[id]
		if changes.get("evolutions", []) is not Array or changes.get("types", []) is not Array or changes.get("base_stats", {}) is not Dictionary:
			problems.append("Campos de especie inválidos: %s." % id)
			continue
		for edge: Variant in changes.get("evolutions", []):
			if edge is not Dictionary or not input.has_species(StringName(str(edge.get("to", "")))):
				problems.append("Destino de evolución inválido: %s." % id)
	for id: String in patch.section("learnsets"):
		if not input.has_species(StringName(id)) or patch.section("learnsets")[id] is not Array:
			problems.append("Learnset inválido: %s." % id)
			continue
		for entry: Variant in patch.section("learnsets")[id]:
			if entry is not Array or entry.size() != 2 or entry[0] is not int and entry[0] is not float:
				problems.append("Fila de aprendizaje inválida: %s." % id)
	for kind: String in ["trainers", "encounters", "shops", "trades", "abilities", "tm_moves", "tutor_moves"]:
		for id: String in patch.section(kind):
			if patch.section(kind)[id] is not Dictionary:
				problems.append("Registro inválido en %s: %s." % [kind, id])
	if not problems.is_empty():
		return problems
	var visited: Dictionary = {}
	var visiting: Dictionary = {}
	for id: String in input.ids("species"):
		if _cycle(input, patch, id, visited, visiting):
			problems.append("Hay un ciclo de evoluciones: %s." % id)
			break
	return problems

static func _cycle(input: RandomizerInput, patch: RomPatch, id: String, visited: Dictionary, visiting: Dictionary) -> bool:
	if visiting.has(id):
		return true
	if visited.has(id):
		return false
	visiting[id] = true
	for edge: Dictionary in evolutions(patch, StringName(id)):
		var target := str(edge.get("to", ""))
		if not edge.has("region") and input.has_species(StringName(target)) and _cycle(input, patch, target, visited, visiting):
			return true
	visiting.erase(id)
	visited[id] = true
	return false
