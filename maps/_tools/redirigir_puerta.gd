extends SceneTree
## Cambia a dónde lleva una puerta (Warp) de un mapa ya pintado, sin repintarlo.
## Uso: godot --headless --path . -s res://maps/_tools/redirigir_puerta.gd -- <mapa> <warp> <destino> <aparición del destino>
## Ejemplo: -- madrid/centro Sala39_31 madrid/gimnasio_1 default


func _initialize() -> void:
	await process_frame
	var a := OS.get_cmdline_user_args()
	if a.size() < 4:
		push_error("redirigir_puerta: faltan argumentos (mapa, warp, destino, aparición).")
		quit(2)
		return
	var path := "res://maps/%s.tscn" % a[0]
	var map: Node = (load(path) as PackedScene).instantiate()
	var warp := map.get_node(^"Warps").get_node_or_null(NodePath(a[1]))
	if warp == null:
		push_error("redirigir_puerta: %s no tiene la puerta %s." % [a[0], a[1]])
		map.free()
		quit(1)
		return
	warp.set(&"target_map", StringName(a[2]))
	warp.set(&"target_spawn", StringName(a[3]))
	var packed := PackedScene.new()
	var err := packed.pack(map)
	if err == OK:
		err = ResourceSaver.save(packed, path)
	print("%s: %s → %s (%s)." % [a[0], a[1], a[2], error_string(err)])
	map.free()
	quit(0 if err == OK else 1)
