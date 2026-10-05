class_name WorldRoamers
extends RefCounted
## Identidad/PS/estado/mapa persisten; release consulta estático parcheado por R.2.
static var rng := RandomNumberGenerator.new()
static func _static_init() -> void:
	rng.randomize()
static func release(id: StringName, static_id: StringName, maps: PackedStringArray) -> bool:
	if GameState.roamers.has(String(id)) or maps.is_empty():
		return false
	var spec := DataDB.static_encounter(static_id)
	if spec.is_empty():
		return false
	var pokemon := Pokemon.from_spec(spec)
	if pokemon == null:
		return false
	GameState.roamers[String(id)] = {"static_id": String(static_id), "pokemon": pokemon.to_dict(),
		"maps": Array(maps), "map": maps[0], "state": "roaming"}
	return true
static func move_on_transition(from_map: StringName) -> void:
	if from_map == &"":
		return # Cargar/continuar no mueve un errante guardado.
	for id: String in GameState.roamers:
		var record: Dictionary = GameState.roamers[id]
		if record.state == "roaming" and not record.maps.is_empty():
			record.map = record.maps[rng.randi_range(0, record.maps.size() - 1)]
static func roll(map: MapRoot, minimum_level: int = 0) -> Dictionary:
	if not (GameState.party is Party) or GameState.party.able_count() == 0:
		return {}
	var chance := float(GameState.world_config.get("roamers", {}).get("encounter_chance", 0.0))
	if chance <= 0.0 or rng.randf() >= chance:
		return {}
	for id: String in GameState.roamers:
		var record: Dictionary = GameState.roamers[id]
		if record.state == "roaming" and record.map == String(map.get_map_id()):
			var pokemon := Pokemon.from_dict(record.pokemon)
			if pokemon.level >= minimum_level:
				return {"id": id, "pokemon": pokemon}
	return {}
static func resolve(id: StringName, pokemon: Pokemon, outcome: StringName) -> void:
	if not GameState.roamers.has(String(id)):
		return
	var record: Dictionary = GameState.roamers[String(id)]
	record.pokemon = pokemon.to_dict()
	if outcome == SceneManager.OUTCOME_CAUGHT:
		record.state = "captured"
	elif outcome == SceneManager.OUTCOME_WIN:
		record.state = "defeated"
