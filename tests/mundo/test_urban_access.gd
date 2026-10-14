extends GutTest
const REPORT := "res://docs/arte/comparativas/tejido_urbano_2026-10-14/detalle.json"
const BASELINE := "res://docs/arte/comparativas/tejido_urbano_2026-10-14/conexiones_anteriores.json"
const DIRS: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]

func test_casas_completas_conservan_conexiones_y_apariciones_anteriores() -> void:
	var baseline := JsonFile.read_dict(BASELINE)
	var broken := JsonFile.read_dict(ExteriorTiles.OBJECTS_JSON)
	for mid: String in baseline:
		var expected: Dictionary = baseline[mid]
		var map: Node = (load("res://maps/%s.tscn" % mid) as PackedScene).instantiate()
		for section: String in ["warps", "spawns"]:
			var current := {}
			var parent: Node = map.get_node("Warps" if section == "warps" else "Spawns")
			for name: String in expected[section]:
				var node := parent.get_node_or_null(NodePath(name)) as Node2D
				if node == null:
					continue
				current[name] = {"position": [float(node.position.x), float(node.position.y)]}
				if section == "warps":
					current[name]["target_map"] = str(node.get("target_map"))
					current[name]["target_spawn"] = str(node.get("target_spawn"))
			assert_eq(current, expected[section], "%s/%s mantiene sus conexiones" % [mid, section])
		for layer: TileMapLayer in map.find_children("*", "TileMapLayer", true, false):
			if layer.tile_set != load(ExteriorTiles.TILESET):
				continue
			for id: StringName in ExteriorTiles.COMPLETE_HOUSES:
				var old: Dictionary = broken[str(id)]
				var cut := layer.get_used_cells_by_id(int(old.source), Vector2i(old.coords[0], old.coords[1]))
				assert_eq(cut.size(), 0, "%s ya no usa el módulo %s como casa" % [mid, id])
		map.free()

func test_viviendas_nuevas_tienen_puerta_alcanzable_y_regreso() -> void:
	GameState.reset()
	var report := JsonFile.read_dict(REPORT)
	for mid: String in report:
		var targets: Array = report[mid].get("interiores", [])
		if targets.is_empty():
			continue
		var map: Node2D = (load("res://maps/%s.tscn" % mid) as PackedScene).instantiate()
		add_child(map)
		await wait_physics_frames(2)
		var ground := map.get_node("Ground") as TileMapLayer
		var free := {}
		var space := map.get_world_2d().direct_space_state
		for cell: Vector2i in Pintor.cells(ground.get_used_rect()):
			if ground.get_cell_source_id(cell) < 0:
				continue
			var query := PhysicsPointQueryParameters2D.new()
			query.position = map.to_global(Grid.to_world(cell))
			query.collision_mask = 1 | 2 | 8
			if space.intersect_point(query, 1).is_empty():
				free[cell] = true
		var start := Grid.to_tile(map.get_node("Spawns/default").position)
		var reach := _reach(start, free)
		for warp: Node2D in map.get_node("Warps").get_children():
			if str(warp.get("target_map")) not in targets:
				continue
			var door := Grid.to_tile(warp.position)
			assert_true(reach.has(door), "%s: se entra andando en %s" % [mid, warp.get("target_map")])
			var room: Node2D = (load("res://maps/%s.tscn" % warp.get("target_map")) as PackedScene).instantiate()
			var exit: Node = room.get_node("Warps/Salida")
			assert_eq(str(exit.get("target_map")), mid, "La salida vuelve a la misma ciudad")
			var spawn := map.get_node_or_null(NodePath("Spawns/" + str(exit.get("target_spawn")))) as Node2D
			assert_not_null(spawn, "Existe el punto de regreso")
			if spawn != null:
				assert_true(reach.has(Grid.to_tile(spawn.position)), "Se vuelve a una casilla alcanzable")
			room.free()
		map.queue_free()
		await wait_physics_frames(2)

func test_vecinos_ambientales_no_ocupan_hierba_de_encuentros() -> void:
	for mid: String in JsonFile.read_dict(REPORT):
		var map: Node2D = (load("res://maps/%s.tscn" % mid) as PackedScene).instantiate()
		var ground := map.get_node("Ground") as TileMapLayer
		for node: Node in map.get_node("Entities").get_children():
			if not str(node.name).begins_with("VecinoPaseo"):
				continue
			var at := Grid.to_tile(node.position)
			var data := ground.get_cell_tile_data(at)
			assert_true(data != null and str(data.get_custom_data("terrain")) in ["grass", "stone", "path"], "%s/%s queda fuera de los encuentros" % [mid, node.name])
		map.free()

func _reach(start: Vector2i, free: Dictionary) -> Dictionary:
	var seen := {start: true}
	var queue: Array[Vector2i] = [start]
	var cursor := 0
	while cursor < queue.size():
		var cell := queue[cursor]
		cursor += 1
		for direction: Vector2i in DIRS:
			var next := cell + direction
			if free.has(next) and not seen.has(next):
				seen[next] = true
				queue.append(next)
	return seen

