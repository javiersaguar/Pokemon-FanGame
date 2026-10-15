extends SceneTree
## Abre un paso en la pared del fondo de un interior ya pintado, sin repintarlo: quita la pared de la casilla
## (y la de debajo si está en la fila 0), pone un Warp hacia otra sala y la aparición de vuelta dos casillas
## más abajo. Si ya hay un Warp con ese nombre, no hace nada.
## Uso: godot --headless --path . -s res://maps/_tools/abrir_paso.gd -- <mapa> <x> <y> <destino> <aparición del destino> <warp> <aparición de vuelta>
## Ejemplo: -- barcelona/sala_eixample_10_31 8 0 barcelona/casa_rufian default PisoRufian desde_casa_rufian


func _initialize() -> void:
	await process_frame
	var a := OS.get_cmdline_user_args()
	if a.size() < 7:
		push_error("abrir_paso: faltan argumentos (mapa, x, y, destino, aparición del destino, warp, aparición de vuelta).")
		quit(2)
		return
	var path := "res://maps/%s.tscn" % a[0]
	var map: Node = (load(path) as PackedScene).instantiate()
	if map.get_node(^"Warps").has_node(NodePath(a[5])):
		print("%s: ya tenía el paso %s." % [a[0], a[5]])
		map.free()
		quit()
		return
	var cell := Vector2i(int(a[1]), int(a[2]))
	var decor := map.get_node(^"Decor") as TileMapLayer
	decor.erase_cell(cell)
	if cell.y == 0:
		decor.erase_cell(cell + Vector2i.DOWN)
	var warp := Node2D.new()
	warp.set_script(load("res://src/overworld/warp/warp.gd"))
	warp.name = a[5]
	warp.position = Grid.to_world(cell)
	warp.set(&"target_map", StringName(a[3]))
	warp.set(&"target_spawn", StringName(a[4]))
	warp.set(&"sound", &"door")
	warp.set(&"arrival_facing", 4)   # Warp.Facing.UP
	map.get_node(^"Warps").add_child(warp)
	warp.owner = map
	var spawn := Marker2D.new()
	spawn.name = a[6]
	spawn.position = Grid.to_world(cell + Vector2i(0, 2))
	map.get_node(^"Spawns").add_child(spawn)
	spawn.owner = map
	var packed := PackedScene.new()
	var err := packed.pack(map)
	if err == OK:
		err = ResourceSaver.save(packed, path)
	print("%s: paso %s en %s → %s (%s)." % [a[0], a[5], cell, a[3], error_string(err)])
	map.free()
	quit(0 if err == OK else 1)
