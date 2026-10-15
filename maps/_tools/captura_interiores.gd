extends SceneTree
## Captura varios interiores de una vez, a escala real, para las comparativas antes/después.
## Necesita ventana (no --headless). Fondo negro alrededor, como se ve en el juego.
##   godot --path . -s res://maps/_tools/captura_interiores.gd -- <carpeta res://...> <sufijo> <mapa> [mapa ...]
## Ejemplo: -- res://docs/arte/comparativas/interiores_2026-10-15 antes madrid/sala_centro_18_4


func _initialize() -> void:
	await process_frame
	var args := OS.get_cmdline_user_args()
	if args.size() < 3:
		push_error("captura_interiores: faltan la carpeta, el sufijo y algún mapa")
		quit(1)
		return
	var folder := args[0]
	var suffix := args[1]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	for i: int in range(2, args.size()):
		var map_id := args[i]
		var scene: PackedScene = load("res://maps/%s.tscn" % map_id)
		if scene == null:
			push_error("captura_interiores: no existe %s" % map_id)
			continue
		var map: Node2D = scene.instantiate()
		var ground: TileMapLayer = map.get_node(^"Ground")
		var used := ground.get_used_rect()
		var size := Vector2i(used.size * Grid.TILE) + Vector2i(32, 32)
		var viewport := SubViewport.new()
		viewport.size = size
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		viewport.transparent_bg = false
		viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
		var back := ColorRect.new()
		back.color = Color.BLACK
		back.size = Vector2(size)
		viewport.add_child(back)
		root.add_child(viewport)
		map.position = -Vector2(used.position * Grid.TILE) + Vector2(16, 16)
		viewport.add_child(map)
		for f: int in 4:
			await process_frame
		await RenderingServer.frame_post_draw
		var image := viewport.get_texture().get_image()
		var out := "%s/%s_%s.png" % [folder, map_id.replace("/", "__"), suffix]
		print("%s: %s" % [out, error_string(image.save_png(out))])
		viewport.queue_free()
		await process_frame
	quit()
