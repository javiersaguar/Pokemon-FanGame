extends SceneTree
## Añade una aparición junto a una puerta que ya existe, si todavía no tiene ese nombre.
## Uso: godot --headless --path . -s res://maps/_tools/poner_aparicion.gd -- <mapa> <warp> <aparición>


func _initialize() -> void:
	await process_frame
	var a := OS.get_cmdline_user_args()
	if a.size() < 3:
		push_error("poner_aparicion: faltan argumentos.")
		quit(2)
		return
	var path := "res://maps/%s.tscn" % a[0]
	var map: Node = (load(path) as PackedScene).instantiate()
	var warp := map.get_node(^"Warps").get_node_or_null(NodePath(a[1])) as Node2D
	if warp == null:
		push_error("poner_aparicion: no está el warp %s." % a[1])
		quit(1)
		return
	var spawns := map.get_node(^"Spawns")
	if spawns.has_node(NodePath(a[2])):
		print("%s: ya está %s." % [a[0], a[2]])
		map.free()
		quit()
		return
	var door := Grid.to_tile(warp.position)
	var marker := Marker2D.new()
	marker.name = a[2]
	marker.position = Grid.to_world(door + Vector2i.DOWN)
	spawns.add_child(marker)
	marker.owner = map
	var packed := PackedScene.new()
	var err := packed.pack(map)
	if err == OK:
		err = ResourceSaver.save(packed, path)
	print("%s: %s en %s (%s)" % [a[0], a[2], door + Vector2i.DOWN, error_string(err)])
	map.free()
	quit(0 if err == OK else 1)
