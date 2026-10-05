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
	if not FieldActions.available(kind, map):
		return false
	var player := SceneManager.player
	if kind in FISHING and is_instance_valid(player):
		var sheet := FieldActions.sheet_path(&"fishing", GameState.player_gender)
		if not sheet.is_empty() and ResourceLoader.exists(sheet):
			player.sprite.set_sheets(load(sheet))
			player.sprite.play_step(player.facing, 0.4)
			await player.get_tree().create_timer(0.4).timeout
	var wild := roll(map, kind, tile)
	if wild.is_empty():
		if kind in FISHING:
			await Dialogue.say("No ha picado nada.")
		if is_instance_valid(player):
			player.refresh_appearance()
		return false
	if is_instance_valid(player):
		player.refresh_appearance()
	await SceneManager.start_battle(WildEncounters.make_setup(wild),
		{"source": "wild", "method": String(kind), "zone_id": String(map.get_zone_id())})
	return true
