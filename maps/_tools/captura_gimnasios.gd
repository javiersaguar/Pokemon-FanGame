extends SceneTree
## Captura las salas de los gimnasios (vista de pájaro, a escala real) para las comparativas de
## docs/arte/comparativas/gimnasios_2026-10-15.md. Necesita ventana (no --headless).
##   godot --path . -s res://maps/_tools/captura_gimnasios.gd -- <carpeta de salida> [ciudad ...]
## Sin ciudades, todas las de maps/_pintura/gimnasios_salas.json. Con flags=... (separados por comas), los
## da por activos antes de abrir cada sala (por ejemplo, flags=quiron_superado).

const SPEC := "res://maps/_pintura/gimnasios_salas.json"
const EXTRA := {"madrid": ["madrid/atico_ayuso"]}


func _initialize() -> void:
	await process_frame
	var args := Array(OS.get_cmdline_user_args())
	if args.is_empty():
		push_error("captura_gimnasios: falta la carpeta de salida")
		quit(1)
		return
	var out_dir: String = args.pop_front()
	var state := root.get_node_or_null(^"GameState")
	for arg: String in args.duplicate():
		if arg.begins_with("flags="):
			args.erase(arg)
			for flag: String in arg.get_slice("=", 1).split(",", false):
				if state != null:
					state.call(&"set_flag", StringName(flag))
	var spec := JsonFile.read_dict(SPEC)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_dir))
	for city: String in spec:
		if city.begins_with("_") or (not args.is_empty() and city not in args):
			continue
		var maps: Array = []
		for i: int in (spec[city]["salas"] as Array).size():
			maps.append("%s/gimnasio_%d" % [city, i + 1])
		maps.append("%s/gimnasio_lider" % city)
		maps.append_array(EXTRA.get(city, []))
		for map_id: String in maps:
			await _capture(map_id, "%s/%s.png" % [out_dir, map_id.replace("/", "_")])
	quit()


func _capture(map_id: String, out: String) -> void:
	var map: Node2D = (load("res://maps/%s.tscn" % map_id) as PackedScene).instantiate()
	var used := (map.get_node(^"Ground") as TileMapLayer).get_used_rect()
	var viewport := SubViewport.new()
	viewport.size = Vector2i(used.size * Grid.TILE)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.transparent_bg = false
	viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	root.add_child(viewport)
	map.position = -Vector2(used.position * Grid.TILE)
	viewport.add_child(map)
	for i: int in 4:
		await process_frame
	await RenderingServer.frame_post_draw
	var image := viewport.get_texture().get_image()
	print("%s: %s (%dx%d)" % [out, error_string(image.save_png(out)), image.get_width(), image.get_height()])
	viewport.queue_free()
	await process_frame
