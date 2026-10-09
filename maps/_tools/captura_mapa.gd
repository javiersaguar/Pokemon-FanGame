extends SceneTree
## Captura un mapa entero a PNG (vista de pájaro, a escala real o reducida) para revisarlo y
## para las comparativas de docs/arte/comparativas/. Necesita ventana (no --headless).
##   godot --path . -s res://maps/_tools/captura_mapa.gd -- <id del mapa> <salida.png> [escala]
## Ejemplo: -- pueblo_inicial/exterior res://docs/arte/comparativas/san_miguel_mapa.png 0.5


func _initialize() -> void:
	await process_frame
	var args := OS.get_cmdline_user_args()
	if args.size() < 2:
		push_error("captura_mapa: faltan el id del mapa y la salida")
		quit(1)
		return
	var map_id := args[0]
	var out := args[1]
	var scale := float(args[2]) if args.size() > 2 else 1.0
	var scene: PackedScene = load("res://maps/%s.tscn" % map_id)
	if scene == null:
		push_error("captura_mapa: no existe el mapa %s" % map_id)
		quit(1)
		return
	var map: Node2D = scene.instantiate()
	var ground: TileMapLayer = map.get_node(^"Ground")
	var used := ground.get_used_rect()
	var size := Vector2i(used.size * Grid.TILE)
	var viewport := SubViewport.new()
	viewport.size = size
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
	if scale != 1.0:
		image.resize(int(image.get_width() * scale), int(image.get_height() * scale), Image.INTERPOLATE_LANCZOS)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out).get_base_dir())
	print("%s: %s (%dx%d)" % [out, error_string(image.save_png(out)), image.get_width(), image.get_height()])
	viewport.queue_free()
	await process_frame
	quit()
