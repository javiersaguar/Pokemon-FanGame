extends SceneTree
## Ajusta únicamente los vecinos ambientales del paseado urbano.
func _initialize() -> void:
	await process_frame
	var report := JsonFile.read_dict("res://docs/arte/comparativas/tejido_urbano_2026-10-14/detalle.json")
	var catalog := ExteriorTiles.objects()
	var by_tile := {}
	for id: StringName in catalog:
		var o: Dictionary = catalog[id]
		by_tile[Vector3i(o.source, o.coords.x, o.coords.y)] = o.size
	for mid: String in report:
		var path := "res://maps/%s.tscn" % mid
		var map: Node2D = (load(path) as PackedScene).instantiate()
		root.add_child(map)
		await physics_frame
		await physics_frame
		var ground := map.get_node("Ground") as TileMapLayer
		var space := map.get_world_2d().direct_space_state
		var occupied := {}
		var objects := map.get_node("Entities/Objects") as TileMapLayer
		for at: Vector2i in objects.get_used_cells():
			var c := objects.get_cell_atlas_coords(at)
			var size: Vector2i = by_tile.get(Vector3i(objects.get_cell_source_id(at), c.x, c.y), Vector2i.ONE)
			for cell: Vector2i in Pintor.cells(Rect2i(at - Vector2i(0, size.y - 1), size)):
				occupied[cell] = true
		for entry: Dictionary in JsonFile.read_dict("res://data/personajes_en_el_mapa.json").get("colocados", []):
			if entry.get("mapa", "") == mid and entry.has("casilla"):
				var at := Vector2i(entry.casilla[0], entry.casilla[1])
				for cell: Vector2i in Pintor.cells(Rect2i(at - Vector2i(3, 3), Vector2i(7, 7))):
					occupied[cell] = true
		for section: String in ["Warps", "Spawns"]:
			for node: Node2D in map.get_node(section).get_children():
				var at := Grid.to_tile(node.position)
				for cell: Vector2i in Pintor.cells(Rect2i(at - Vector2i(2, 2), Vector2i(5, 5))):
					occupied[cell] = true
		var changed := false
		for npc: Node in map.get_node("Entities").get_children():
			if not str(npc.name).begins_with("VecinoPaseo"):
				continue
			var at := Grid.to_tile(npc.position)
			var tile := ground.get_cell_tile_data(at)
			if tile != null and str(tile.get_custom_data("terrain")) in ["grass", "stone", "path"]:
				continue
			var candidates := ground.get_used_cells()
			candidates.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
				var da := a.distance_squared_to(at)
				var db := b.distance_squared_to(at)
				return da < db or (da == db and (a.y < b.y or (a.y == b.y and a.x < b.x))))
			for cell: Vector2i in candidates:
				var data := ground.get_cell_tile_data(cell)
				if occupied.has(cell) or data == null or str(data.get_custom_data("terrain")) not in ["grass", "stone", "path"]:
					continue
				var safe := true
				for direction: Vector2i in [Vector2i.ZERO, Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
					var query := PhysicsPointQueryParameters2D.new()
					query.position = map.to_global(Grid.to_world(cell + direction))
					query.collision_mask = 1 | 2 | 8
					if not space.intersect_point(query, 1).is_empty():
						safe = false
						break
				if not safe:
					continue
				npc.position = Grid.to_world(cell)
				occupied[cell] = true
				changed = true
				print(mid, " ", npc.name, " ", at, " → ", cell)
				break
		root.remove_child(map)
		if changed:
			var packed := PackedScene.new()
			assert(packed.pack(map) == OK)
			assert(ResourceSaver.save(packed, path) == OK)
		map.free()
		await process_frame
	quit.call_deferred()

