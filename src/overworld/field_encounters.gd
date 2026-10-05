class_name FieldEncounters
extends RefCounted
## Cañas/Golpe Cabeza/Golpe Roca: tablas siempre por DataDB (R.2).
const FISHING: Array[StringName] = [&"old_rod", &"good_rod", &"super_rod"]
static func roll(map: MapRoot, kind: StringName, tile: Vector2i) -> Dictionary:
	if map == null or map.data == null or map.data.encounter_table == &"" or not FieldActions.available(kind, map):
		return {}
	if not (GameState.party is Party) or GameState.party.able_count() == 0:
		return {}
	if kind in FISHING and map.terrain_at(tile) != "water":
		return {}
	if kind == &"headbutt" and map.terrain_at(tile) not in ["tree", "headbutt"]:
		return {}
	var table := WildEncounters.load_table(map.data.encounter_table)
	if WildEncounters.rng.randf() >= WildEncounters.step_chance(map, table, kind):
		return {}
	return WildEncounters.pick_from(table, kind, Clock.period())
static func start(map: MapRoot, kind: StringName, tile: Vector2i) -> bool:
	var wild := roll(map, kind, tile)
	if wild.is_empty():
		if kind in FISHING:
			await Dialogue.say("No ha picado nada.")
		return false
	await SceneManager.start_battle(WildEncounters.make_setup(wild),
		{"source": "wild", "method": String(kind), "zone_id": String(map.get_zone_id())})
	return true
