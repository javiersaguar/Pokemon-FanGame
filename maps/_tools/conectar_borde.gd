extends SceneTree
## Añade una conexión de borde a un mapa ya pintado, sin repintarlo (repintar desde el script borraría las
## puertas e interiores enlazados después). Si ya existe la misma conexión, no hace nada.
## Uso: godot --headless --path . -s res://maps/_tools/conectar_borde.gd -- <mapa> <borde> <destino> <desfase> <desde> <hasta>
## Ejemplo: -- ruta_12/exterior east murcia/exterior 4 26 29


func _initialize() -> void:
	await process_frame
	var a := OS.get_cmdline_user_args()
	if a.size() < 6:
		push_error("conectar_borde: faltan argumentos (mapa, borde, destino, desfase, desde, hasta).")
		quit(2)
		return
	var path := "res://maps/%s.tscn" % a[0]
	var scene: PackedScene = load(path)
	var map: Node = scene.instantiate()
	var data: Resource = map.get(&"data")
	for c: Resource in data.connections:
		if c.edge == a[1] and String(c.target_map) == a[2]:
			print("%s: ya tenía el borde %s → %s." % [a[0], a[1], a[2]])
			map.free()
			quit()
			return
	var connection: Resource = (load("res://src/overworld/map_connection.gd") as GDScript).new()
	connection.edge = a[1]
	connection.target_map = StringName(a[2])
	connection.offset = int(a[3])
	connection.span = Vector2i(int(a[4]), int(a[5]))
	data.connections.append(connection)
	var packed := PackedScene.new()
	var err := packed.pack(map)
	if err == OK:
		err = ResourceSaver.save(packed, path)
	print("%s: borde %s → %s (%s)." % [a[0], a[1], a[2], error_string(err)])
	map.free()
	quit(0 if err == OK else 1)
