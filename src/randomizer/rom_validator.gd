class_name RomValidator
extends RefCounted
## Validación de una ROM generada (Fase R.4). Lee los datos base de DataDB y el parche, sin
## aplicarlo (para poder usarse desde otro hilo). Devuelve los problemas (vacío = válida).


static func validate(patch: RomPatch) -> PackedStringArray:
	var problems: PackedStringArray = []
	_check_starters(patch, problems)
	for id: StringName in species_in_play(patch):
		if not DataDB.has_species(id):
			problems.append("La especie '%s' no existe." % id)
			continue
		var level := _first_level_without_damage(patch, id)
		if level > 0:
			problems.append("%s no tiene ningún ataque de daño al nivel %d." % [id, level])
	_check_encounters(patch, problems)
	_check_trainers(patch, problems)
	_check_fixed(patch, problems)
	return problems


# --- Datos efectivos ---

static func evolutions(patch: RomPatch, id: StringName) -> Array:
	var patched: Variant = patch.section("species").get(String(id), {}).get("evolutions")
	if patched != null:
		return patched
	return DataDB.species(id).evolutions if DataDB.has_species(id) else []


static func level_moves(patch: RomPatch, id: StringName) -> Array:
	var patched: Variant = patch.section("learnsets").get(String(id))
	if patched != null:
		return patched
	return DataDB.learnset(id).get("level", []) if DataDB.has_species(id) else []


## Los 4 últimos movimientos aprendidos por nivel hasta `level` (como DataDB.default_moves).
static func default_moves(patch: RomPatch, id: StringName, level: int) -> Array[StringName]:
	var out: Array[StringName] = []
	for entry: Array in level_moves(patch, id):
		var m := StringName(str(entry[1]))
		if int(entry[0]) < 1 or int(entry[0]) > level or not DataDB.has_move(m):
			continue
		out.erase(m)
		out.append(m)
	return out.slice(maxi(0, out.size() - 4))


static func is_damaging(move_id: StringName) -> bool:
	if not DataDB.has_move(move_id):
		return false
	var m := DataDB.move(move_id)
	return m.is_damaging() and (m.power > 0 or m.fixed_damage > 0 or m.level_damage)


## Especies que se pueden ver en la partida con esta ROM (iniciales, salvajes, entrenadores,
## regalos, estáticos, intercambios y la Pokédex regional) y todas sus evoluciones, ordenadas.
static func species_in_play(patch: RomPatch) -> Array[StringName]:
	var found := {}
	for id: StringName in DataDB.starter_ids():
		found[StringName(str(patch.section("starters").get(String(id), DataDB.starter(id))))] = true
	for id: StringName in wild_species(patch):
		found[id] = true
	for id: StringName in DataDB.trainer_ids():
		for spec: Dictionary in _trainer_party(patch, id):
			found[StringName(str(spec.get("species", "")))] = true
	for id: StringName in DataDB.gift_ids():
		found[StringName(str(patch.section("gifts").get(String(id), DataDB.gift(id).get("species", ""))))] = true
	for id: StringName in DataDB.static_ids():
		found[StringName(str(patch.section("statics").get(String(id), DataDB.static_encounter(id).get("species", ""))))] = true
	for id: StringName in DataDB.trade_ids():
		var t: Dictionary = DataDB.trade(id).duplicate(true)
		t.merge(patch.section("trades").get(String(id), {}), true)
		var receive: Variant = t.get("receive", {})
		if receive is Dictionary and receive.has("species"):
			found[StringName(str(receive["species"]))] = true
	for id: StringName in DataDB.regional_dex():
		found[id] = true
	found.erase(&"")
	var queue: Array = found.keys()
	while not queue.is_empty():
		var id: StringName = queue.pop_back()
		for evo: Dictionary in evolutions(patch, id):
			var to := StringName(str(evo.get("to", "")))
			if not evo.has("region") and DataDB.has_species(to) and not found.has(to):
				found[to] = true
				queue.append(to)
	var out: Array[StringName] = []
	out.assign(found.keys())
	DataUtil.sort_names(out)
	return out


static func wild_species(patch: RomPatch) -> Array[StringName]:
	var found := {}
	var ids := DataDB.encounter_ids()
	DataUtil.sort_names(ids)
	for table_id: StringName in ids:
		var table: Dictionary = patch.section("encounters").get(String(table_id), DataDB.encounter_table(table_id))
		for entry: Dictionary in _entries(table):
			found[StringName(str(entry.get("species", "")))] = true
	found.erase(&"")
	var out: Array[StringName] = []
	out.assign(found.keys())
	DataUtil.sort_names(out)
	return out


static func _entries(table: Dictionary) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for key: Variant in table:
		var lists: Array = []
		if table[key] is Array:
			lists.append(table[key])
		elif table[key] is Dictionary:
			lists.append_array((table[key] as Dictionary).values())
		for list: Variant in lists:
			if list is Array:
				for entry: Variant in list:
					if entry is Dictionary:
						out.append(entry)
	return out


static func _trainer_party(patch: RomPatch, id: StringName) -> Array:
	var patched: Variant = patch.section("trainers").get(String(id), {}).get("party")
	return patched if patched != null else DataDB.trainer(id).get("party", [])


# --- Comprobaciones ---

static func _check_starters(patch: RomPatch, problems: PackedStringArray) -> void:
	var seen := {}
	for id: StringName in DataDB.starter_ids():
		var species := StringName(str(patch.section("starters").get(String(id), DataDB.starter(id))))
		if seen.has(species):
			problems.append("Iniciales repetidos: %s." % species)
		seen[species] = true
		var level := int(DataDB.starter_spec(id).get("level", 5))
		var has_damage := false
		for m: StringName in default_moves(patch, species, level):
			has_damage = has_damage or is_damaging(m)
		if not has_damage:
			problems.append("El inicial %s no tiene ningún ataque de daño al nivel %d." % [species, level])


## Primer nivel (1..100) en el que los 4 últimos movimientos aprendidos no incluyen ninguno de daño; 0 si nunca.
static func _first_level_without_damage(patch: RomPatch, id: StringName) -> int:
	var window: Array[StringName] = []
	var levels: Array = level_moves(patch, id)
	if levels.is_empty():
		return 0
	for entry: Array in levels:
		if int(entry[0]) < 1:
			continue
		var m := StringName(str(entry[1]))
		window.erase(m)
		window.append(m)
		if window.size() > 4:
			window.pop_front()
		var ok := false
		for w: StringName in window:
			ok = ok or is_damaging(w)
		if not ok:
			return int(entry[0])
	return 0


static func _check_encounters(patch: RomPatch, problems: PackedStringArray) -> void:
	for table_id: StringName in DataDB.encounter_ids():
		var before := _entries(DataDB.encounter_table(table_id))
		var after := _entries(patch.section("encounters").get(String(table_id), DataDB.encounter_table(table_id)))
		if not before.is_empty() and after.is_empty():
			problems.append("La zona %s se ha quedado sin Pokémon." % table_id)
		for entry: Dictionary in after:
			if not DataDB.has_species(StringName(str(entry.get("species", "")))):
				problems.append("Zona %s: la especie '%s' no existe." % [table_id, entry.get("species", "")])


static func _check_trainers(patch: RomPatch, problems: PackedStringArray) -> void:
	for id: StringName in DataDB.trainer_ids():
		var seen := {}
		for spec: Dictionary in _trainer_party(patch, id):
			var species := StringName(str(spec.get("species", "")))
			if not DataDB.has_species(species):
				problems.append("Entrenador %s: la especie '%s' no existe." % [id, species])
			elif seen.has(species) and patch.section("trainers").has(String(id)):
				problems.append("Entrenador %s: %s repetido en el equipo." % [id, species])
			seen[species] = true


static func _check_fixed(patch: RomPatch, problems: PackedStringArray) -> void:
	for kind: String in ["gifts", "statics", "trades"]:
		var ids := DataDB.gift_ids() if kind == "gifts" else (DataDB.static_ids() if kind == "statics" else DataDB.trade_ids())
		for id: StringName in ids:
			var base := DataDB.gift(id) if kind == "gifts" else (DataDB.static_encounter(id) if kind == "statics" else DataDB.trade(id))
			if base.get("randomize", true) == false and patch.section(kind).has(String(id)):
				problems.append("%s '%s' no se debía aleatorizar." % [kind, id])
	for pid: Variant in patch.section("items"):
		var original := StringName(str(DataDB.item_placements().get(pid, "")))
		if DataDB.has_item(original) and DataDB.item(original).is_key_item():
			problems.append("El objeto clave de %s ha cambiado." % pid)
