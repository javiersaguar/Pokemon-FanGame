class_name NormalStarters
extends RefCounted
## Selección por partida normal; nunca modifica tablas base ni una ROM.
static func pool() -> Array[StringName]:
	var out: Array[StringName] = []
	for id: StringName in DataDB.species_ids(false):
		var species := DataDB.species(id)
		if species.num > 0 and not species.is_mega and not species.is_gmax:
			out.append(id)
	return out

static func generate(seed_value: int) -> Dictionary:
	var candidates := pool()
	var slots := DataDB.starter_ids()
	if candidates.size() < slots.size(): return {}
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var selected: Dictionary = {}
	for slot: StringName in slots:
		var index := rng.randi_range(0, candidates.size() - 1)
		var spec := DataDB.base_starter_spec(slot).duplicate(true)
		spec["species"] = String(candidates[index])
		if not spec.has("level"):
			spec["level"] = int(GameState.world_config.get("new_game", {}).get("starter_level", 5))
		selected[String(slot)] = spec
		candidates.remove_at(index)
	return selected
