extends SceneTree
## Cambia una pieza de un mapa ya pintado por otra, y mueve la puerta si el vano cambia.
## No repinta el mapa: así no se pierden el resto de warps.
## Uso: godot --headless --path . -s res://maps/_tools/sustituir_pieza.gd -- <mapa> <id viejo> <id nuevo> [interior] [nombre del warp] [aparición]


func _initialize() -> void:
	await process_frame
	var a := OS.get_cmdline_user_args()
	if a.size() < 3:
		push_error("sustituir_pieza: faltan argumentos (mapa, id viejo, id nuevo).")
		quit(2)
		return
	var catalog := ExteriorTiles.objects()
	if not catalog.has(a[1]) or not catalog.has(a[2]):
		push_error("sustituir_pieza: no está en el catálogo.")
		quit(2)
		return
	var old: Dictionary = catalog[a[1]]
	var new: Dictionary = catalog[a[2]]
	var path := "res://maps/%s.tscn" % a[0]
	var map: Node = (load(path) as PackedScene).instantiate()
	var layer := map.get_node(^"Entities/Objects") as TileMapLayer
	var found := 0
	for cell: Vector2i in layer.get_used_cells():
		if layer.get_cell_source_id(cell) != int(old["source"]):
			continue
		if layer.get_cell_atlas_coords(cell) != (old["coords"] as Vector2i):
			continue
		var old_door: Vector2i = cell + (old["door"] as Vector2i)
		var new_door: Vector2i = cell + (new["door"] as Vector2i)
		layer.set_cell(cell, int(new["source"]), new["coords"])
		if a.size() >= 6 and (old["door"] as Vector2i).x >= 0:
			_move_door(map, old_door, new_door, a[3], a[4], a[5])
		elif a.size() >= 6:
			_ensure_door(map, new_door, a[3], a[4], a[5])
		found += 1
		print("%s: %s en %s → %s, puerta %s" % [a[0], a[1], cell, a[2], new_door])
	if found == 0:
		push_error("sustituir_pieza: %s no tiene %s." % [a[0], a[1]])
		quit(1)
		return
	var packed := PackedScene.new()
	var err := packed.pack(map)
	if err == OK:
		err = ResourceSaver.save(packed, path)
	print(error_string(err))
	map.free()
	quit(0 if err == OK else 1)


func _move_door(map: Node, old_door: Vector2i, new_door: Vector2i, interior: String, warp_name: String, spawn_name: String) -> void:
	var moved := false
	for child: Node in map.get_node(^"Warps").get_children():
		if child is Warp and (child as Warp).contains_tile(old_door):
			child.position = Grid.to_world(new_door)
			child.set(&"target_map", StringName(interior))
			child.set(&"target_spawn", &"default")
			moved = true
	if not moved:
		_ensure_door(map, new_door, interior, warp_name, spawn_name)
		return
	for child: Node in map.get_node(^"Spawns").get_children():
		if child is Marker2D and Grid.to_tile((child as Node2D).position) == old_door + Vector2i.DOWN:
			child.position = Grid.to_world(new_door + Vector2i.DOWN)


func _ensure_door(map: Node, door: Vector2i, interior: String, warp_name: String, spawn_name: String) -> void:
	var warps := map.get_node(^"Warps")
	if not warps.has_node(NodePath(warp_name)):
		var warp := Node2D.new()
		warp.set_script(load("res://src/overworld/warp/warp.gd"))
		warp.name = warp_name
		warp.position = Grid.to_world(door)
		warp.set(&"target_map", StringName(interior))
		warp.set(&"target_spawn", &"default")
		warp.set(&"sound", &"door")
		warp.set(&"arrival_facing", 4)
		warps.add_child(warp)
		warp.owner = map
	var spawns := map.get_node(^"Spawns")
	if not spawns.has_node(NodePath(spawn_name)):
		var marker := Marker2D.new()
		marker.name = spawn_name
		marker.position = Grid.to_world(door + Vector2i.DOWN)
		spawns.add_child(marker)
		marker.owner = map
