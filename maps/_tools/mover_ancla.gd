extends SceneTree
## Mueve el ancla de una pieza ya colocada y arrastra su puerta y la aparición de vuelta.
## Uso: godot --headless --path . -s res://maps/_tools/mover_ancla.gd -- <mapa> <id> <x> <y>


func _initialize() -> void:
	await process_frame
	var a := OS.get_cmdline_user_args()
	if a.size() < 4:
		push_error("mover_ancla: faltan argumentos.")
		quit(2)
		return
	var catalog: Dictionary = ExteriorTiles.objects()
	var piece: Dictionary = catalog[a[1]]
	var dest := Vector2i(int(a[2]), int(a[3]))
	var map: Node = (load("res://maps/%s.tscn" % a[0]) as PackedScene).instantiate()
	var layer := map.get_node(^"Entities/Objects") as TileMapLayer
	var from := Vector2i(-999, -999)
	for cell: Vector2i in layer.get_used_cells():
		if layer.get_cell_source_id(cell) == int(piece["source"]) and layer.get_cell_atlas_coords(cell) == (piece["coords"] as Vector2i):
			from = cell
			break
	if from.x < -100:
		push_error("mover_ancla: no está %s." % a[1])
		quit(1)
		return
	var old_door: Vector2i = from + (piece["door"] as Vector2i)
	var new_door: Vector2i = dest + (piece["door"] as Vector2i)
	layer.erase_cell(from)
	layer.set_cell(dest, int(piece["source"]), piece["coords"])
	for child: Node in map.get_node(^"Warps").get_children():
		if child is Warp and (child as Warp).contains_tile(old_door):
			child.position = Grid.to_world(new_door)
	for child: Node in map.get_node(^"Spawns").get_children():
		if child is Marker2D and Grid.to_tile((child as Node2D).position) == old_door + Vector2i.DOWN:
			child.position = Grid.to_world(new_door + Vector2i.DOWN)
	var packed := PackedScene.new()
	var err := packed.pack(map)
	if err == OK:
		err = ResourceSaver.save(packed, "res://maps/%s.tscn" % a[0])
	print("%s: %s %s → %s, puerta %s (%s)" % [a[0], a[1], from, dest, new_door, error_string(err)])
	map.free()
	quit(0 if err == OK else 1)
