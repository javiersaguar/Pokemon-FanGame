extends Node
## Proceso limpio: todos los mapas, destinos y colocación física; sin Debug.
func run() -> void:
	await get_tree().process_frame
	var manager = get_tree().root.get_node("SceneManager")
	var loader = load("res://src/util/map_loader.gd")
	var map_root = load("res://src/overworld/map_root.gd")
	var rows := []
	var failed := false
	await manager.start_new_game()
	loader.clear()
	for id in map_root.list_all():
		var prepared: Dictionary = loader.prepare(id)
		if prepared.error != OK:
			push_error("Mapa inválido: %s" % id)
			failed = true
			continue
		var map = prepared.map
		var spawns = map.get_node_or_null("Spawns")
		if spawns == null or spawns.get_child_count() == 0:
			map.free()
			failed = true
			continue
		for spawn in spawns.get_children():
			if not loader.valid_tile(map, loader.spawn_tile(map, spawn.name)):
				push_error("Spawn inválido: %s/%s" % [id, spawn.name])
				failed = true
		for warp in map.get_warps():
			if loader.check_spawn(warp.target_map, warp.target_spawn) != OK:
				push_error("Destino inválido: %s/%s" % [id, warp.name])
				failed = true
		var spawn_id = spawns.get_child(0).name
		var cold_usec: int = prepared.prepare_usec
		map.free()
		var error: int = await manager.change_map(id, spawn_id, Vector2i.DOWN, false)
		await get_tree().physics_frame
		await get_tree().physics_frame
		var load_usec: int = manager.last_map_load_usec
		var passed := error == OK and cold_usec < 500000 and load_usec < 500000
		failed = failed or not passed
		var row := {"map": String(id), "prepare_ms": cold_usec / 1000.0, "load_ms": load_usec / 1000.0, "ok": passed}
		rows.append(row)
		print(JSON.stringify(row))
	var output := "res://docs/mapas/smoke_2026-10-05.json"
	var file := FileAccess.open(output, FileAccess.WRITE)
	file.store_string(JSON.stringify({"godot": Engine.get_version_info().string, "headless": true, "maps": rows, "ok": not failed, "fade_excluded": true}, "\t"))
	file.close()
	loader.clear()
	manager._leave_game()
	await get_tree().process_frame
	get_tree().quit.call_deferred(1 if failed else 0)
