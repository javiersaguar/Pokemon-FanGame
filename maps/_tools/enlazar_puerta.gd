extends SceneTree
## Enlaza la puerta de un edificio de un mapa ya pintado con un interior, sin repintarlo (repintar desde
## su script borraría las puertas enlazadas antes): añade el Warp en la casilla de la puerta y la
## aparición de vuelta justo debajo. Si ya hay un Warp con ese nombre, no hace nada.
## Uso: godot --headless --path . -s res://maps/_tools/enlazar_puerta.gd -- <mapa> <x> <y> <interior> <warp> <aparición>
## Ejemplo: -- madrid/moncloa 5 8 madrid/laboratorio Laboratorio from_laboratorio


func _initialize() -> void:
	await process_frame
	var a := OS.get_cmdline_user_args()
	if a.size() < 6:
		push_error("enlazar_puerta: faltan argumentos (mapa, x, y, interior, warp, aparición).")
		quit(2)
		return
	var path := "res://maps/%s.tscn" % a[0]
	var map: Node = (load(path) as PackedScene).instantiate()
	if map.get_node(^"Warps").has_node(NodePath(a[4])):
		print("%s: ya tenía la puerta %s." % [a[0], a[4]])
		map.free()
		quit()
		return
	var door := Vector2i(int(a[1]), int(a[2]))
	var warp := Node2D.new()
	warp.set_script(load("res://src/overworld/warp/warp.gd"))
	warp.name = a[4]
	warp.position = Grid.to_world(door)
	warp.set(&"target_map", StringName(a[3]))
	warp.set(&"target_spawn", &"default")
	warp.set(&"sound", &"door")
	warp.set(&"arrival_facing", 4)   # Warp.Facing.UP
	map.get_node(^"Warps").add_child(warp)
	warp.owner = map
	var spawn := Marker2D.new()
	spawn.name = a[5]
	spawn.position = Grid.to_world(door + Vector2i.DOWN)
	map.get_node(^"Spawns").add_child(spawn)
	spawn.owner = map
	var packed := PackedScene.new()
	var err := packed.pack(map)
	if err == OK:
		err = ResourceSaver.save(packed, path)
	print("%s: puerta %s en %s → %s (%s)." % [a[0], a[4], door, a[3], error_string(err)])
	map.free()
	quit(0 if err == OK else 1)
