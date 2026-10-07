class_name MoveLessons
extends RefCounted
## Recordador, tutores y MT (Fases 6.2 y 6.3).
## Dónde se consigue cada MT es PENDIENTE JAVIER. Aquí solo está qué enseña y quién puede aprenderla.


static var _built := false
static var _item_to_move: Dictionary = {}


static func _ensure() -> void:
	if _built:
		return
	_built = true
	_item_to_move.clear()
	var taught := {}
	for species_id: StringName in DataDB.species_ids():
		for move_id: Variant in DataDB.learnset(species_id).get("machine", []):
			taught[String(move_id)] = true
	var by_text := {}
	for move_id: StringName in DataDB.move_ids():
		var text := DataDB.move(move_id).description.strip_edges()
		if text == "":
			continue
		if not by_text.has(text):
			by_text[text] = []
		(by_text[text] as Array).append(move_id)
	for item_id: StringName in DataDB.item_ids():
		var item := DataDB.item(item_id)
		if item.pocket != &"machines":
			continue
		var hits: Array = by_text.get(item.description.strip_edges(), [])
		var in_set: Array[StringName] = []
		for move_id: StringName in hits:
			if taught.has(String(move_id)):
				in_set.append(move_id)
		if in_set.size() == 1:
			_item_to_move[item_id] = in_set[0]


## Movimiento que enseña esa MT. Vacío si el objeto no tiene texto que lo identifique (MT 100+).
static func machine_move(item_id: StringName) -> StringName:
	_ensure()
	return _item_to_move.get(item_id, &"")


static func machine_ids() -> Array[StringName]:
	_ensure()
	var ids: Array[StringName] = []
	for item_id: StringName in _item_to_move:
		ids.append(item_id)
	DataUtil.sort_names(ids)
	return ids


static func can_learn_machine(species_id: StringName, move_id: StringName) -> bool:
	return String(move_id) in DataDB.learnset(species_id).get("machine", [])


static func tutor_moves(species_id: StringName) -> Array[StringName]:
	var out: Array[StringName] = []
	for move_id: Variant in DataDB.learnset(species_id).get("tutor", []):
		var id := StringName(str(move_id))
		if DataDB.has_move(id):
			out.append(id)
	return out


static func can_tutor(pokemon: Pokemon, move_id: StringName) -> bool:
	return move_id in tutor_moves(pokemon.species_id) and not pokemon.has_move(move_id)


## Movimientos de nivel (incluido el del nivel 0, al evolucionar) que ya no tiene.
static func relearnable(pokemon: Pokemon) -> Array[StringName]:
	var out: Array[StringName] = []
	for entry: Array in DataDB.level_up_moves(pokemon.species_id):
		if int(entry[0]) > pokemon.level:
			continue
		var move_id := StringName(str(entry[1]))
		if DataDB.has_move(move_id) and not pokemon.has_move(move_id):
			out.append(move_id)
	return out


## Aprende el movimiento. Con 4, hace falta `replace_index` (0-3).
static func teach(pokemon: Pokemon, move_id: StringName, replace_index: int = -1) -> bool:
	if pokemon.has_move(move_id) or not DataDB.has_move(move_id):
		return false
	if pokemon.moves.size() < Pokemon.MAX_MOVES:
		return pokemon.try_learn(move_id)
	if replace_index < 0 or replace_index >= pokemon.moves.size():
		return false
	pokemon.replace_move(replace_index, move_id)
	return true


static func use_machine(pokemon: Pokemon, item_id: StringName, replace_index: int = -1) -> bool:
	var move_id := machine_move(item_id)
	if move_id == &"" or not can_learn_machine(pokemon.species_id, move_id):
		return false
	return teach(pokemon, move_id, replace_index)


static func use_tutor(pokemon: Pokemon, move_id: StringName, replace_index: int = -1) -> bool:
	if not can_tutor(pokemon, move_id):
		return false
	return teach(pokemon, move_id, replace_index)
