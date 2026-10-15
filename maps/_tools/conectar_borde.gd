extends SceneTree
## Añade una conexión de borde a un mapa ya pintado, sin repintarlo (repintar desde el script borraría las
## puertas e interiores enlazados después). Si ya existe la misma conexión, no hace nada.
## Con --reemplazar, quita las conexiones de ese borde hacia ese destino y pone una por cada tramo
## (pares <desde> <hasta>), todas con el mismo desfase: así se dejan solo los tramos del borde que llegan a
## una casilla libre del otro mapa (lo comprueba tests/mundo/test_acceso_mundo.gd). Con --anadir, añade
## los tramos aunque ya haya otra conexión a ese destino (para un segundo tramo con otro desfase).
## Uso: godot --headless --path . -s res://maps/_tools/conectar_borde.gd -- <mapa> <borde> <destino> <desfase> <desde> <hasta> [<desde> <hasta>...] [--reemplazar | --anadir]
## Ejemplos: -- ruta_12/exterior east murcia/exterior 4 26 29
##           -- madrid/centro west madrid/moncloa 38 0 6 7 14 --reemplazar


func _initialize() -> void:
	await process_frame
	var a := Array(OS.get_cmdline_user_args())
	var replace := "--reemplazar" in a
	var force := "--anadir" in a
	a = a.filter(func(arg: String) -> bool: return arg not in ["--reemplazar", "--anadir"])
	if a.size() < 6 or (a.size() - 4) % 2 != 0:
		push_error("conectar_borde: faltan argumentos (mapa, borde, destino, desfase y pares desde-hasta).")
		quit(2)
		return
	var path := "res://maps/%s.tscn" % a[0]
	var scene: PackedScene = load(path)
	var map: Node = scene.instantiate()
	var data: Resource = map.get(&"data")
	var kept: Array = []
	for c: Resource in data.connections:
		if c.edge == a[1] and String(c.target_map) == a[2] and not force:
			if not replace:
				print("%s: ya tenía el borde %s → %s." % [a[0], a[1], a[2]])
				map.free()
				quit()
				return
			continue
		kept.append(c)
	data.connections.clear()
	for c: Resource in kept:
		data.connections.append(c)
	var spans: Array[Vector2i] = []
	for i: int in range(4, a.size(), 2):
		spans.append(Vector2i(int(a[i]), int(a[i + 1])))
	for span: Vector2i in spans:
		var connection: Resource = (load("res://src/overworld/map_connection.gd") as GDScript).new()
		connection.edge = a[1]
		connection.target_map = StringName(a[2])
		connection.offset = int(a[3])
		connection.span = span
		data.connections.append(connection)
	var packed := PackedScene.new()
	var err := packed.pack(map)
	if err == OK:
		err = ResourceSaver.save(packed, path)
	print("%s: borde %s → %s, desfase %s, tramos %s (%s)." % [a[0], a[1], a[2], a[3], spans, error_string(err)])
	map.free()
	quit(0 if err == OK else 1)
