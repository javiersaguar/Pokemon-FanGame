extends SceneTree
## Dibuja un mapa en texto, casilla a casilla, para planear recetas: «.» se pisa, «~» agua, «#» choca,
## «g» hierba alta, «=» camino, «D» puerta, «W» pasarela, «S» aparición, «E» entidad, «C» corriente.
## Uso: godot --headless --path . -s res://maps/_tools/ascii_mapa.gd -- <id del mapa> [x0 y0 x1 y1]

func _initialize() -> void:
	await process_frame
	var args := Array(OS.get_cmdline_user_args())
	var map: Node2D = (load("res://maps/%s.tscn" % args[0]) as PackedScene).instantiate()
	root.add_child(map)
	await physics_frame
	await physics_frame
	var space := root.get_world_2d().direct_space_state
	var ground: TileMapLayer = map.get_node("Ground")
	var rect := ground.get_used_rect()
	if args.size() >= 5:
		rect = Rect2i(Vector2i(int(args[1]), int(args[2])), Vector2i(int(args[3]) - int(args[1]) + 1, int(args[4]) - int(args[2]) + 1))
	var marks := {}
	var catalog := ExteriorTiles.objects()
	var by_tile := {}
	for id: StringName in catalog:
		by_tile["%d:%s" % [catalog[id]["source"], catalog[id]["coords"]]] = id
	var objects: TileMapLayer = map.get_node("Entities/Objects")
	for cell: Vector2i in objects.get_used_cells():
		var key := "%d:%s" % [objects.get_cell_source_id(cell), objects.get_cell_atlas_coords(cell)]
		if by_tile.has(key) and (catalog[by_tile[key]]["door"] as Vector2i).x >= 0:
			marks[cell + (catalog[by_tile[key]]["door"] as Vector2i)] = "D"
	for node: Node in map.get_node("Entities").get_children():
		if node is Node2D and node != objects:
			marks[Grid.to_tile((node as Node2D).position)] = "E"
	for group: String in ["Warps", "Spawns"]:
		var parent := map.get_node_or_null(group)
		if parent != null:
			for node: Node in parent.get_children():
				marks[Grid.to_tile((node as Node2D).position)] = group[0]
	for node: Node in map.find_children("*", "SurfCurrent", true, false):
		for cell: Vector2i in Pintor.cells(node.call(&"rect")):
			if not marks.has(cell):
				marks[cell] = "C"
	var header := "    "
	for x: int in range(rect.position.x, rect.end.x):
		header += str(x % 10)
	print(header)
	for y: int in range(rect.position.y, rect.end.y):
		var line := "%3d " % y
		for x: int in range(rect.position.x, rect.end.x):
			var at := Vector2i(x, y)
			if marks.has(at):
				line += marks[at]
				continue
			var data := ground.get_cell_tile_data(at)
			var terrain := String(data.get_custom_data(&"terrain")) if data != null else ""
			var q := PhysicsPointQueryParameters2D.new()
			q.position = map.to_global(Grid.to_world(at))
			q.collision_mask = 1 | 2
			var blocked := not space.intersect_point(q, 1).is_empty()
			if terrain == "water" and not blocked:
				line += "~"
			elif blocked:
				line += "#"
			elif terrain == "tall_grass":
				line += "g"
			elif terrain == "path":
				line += "="
			else:
				line += "."
		print(line)
	map.queue_free()
	quit()
