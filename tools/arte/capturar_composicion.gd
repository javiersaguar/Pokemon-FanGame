extends SceneTree
## Captura nativa de una pantalla del mapa: 512×384, 32 px por casilla.
## godot --path . --rendering-driver opengl3 -s res://tools/arte/capturar_composicion.gd -- <mapa> <x> <y> <salida.png>
func _initialize() -> void:
	await process_frame
	var args := OS.get_cmdline_user_args()
	if args.size() != 4:
		push_error("Se requiere mapa, x, y y ruta de salida")
		quit(2)
		return
	var main: Node = load("res://src/main/main.tscn").instantiate()
	main.set_script(null)
	root.add_child(main)
	var manager := root.get_node("SceneManager")
	manager.register_main(main)
	var map: Node2D = load("res://maps/%s.tscn" % args[0]).instantiate()
	var viewport := SubViewport.new()
	viewport.size = Vector2i(512,384)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	root.add_child(viewport)
	map.position = Vector2(256,192) - Grid.to_world(Vector2i(int(args[1]),int(args[2])))
	viewport.add_child(map)
	for i: int in 4:
		await process_frame
	await RenderingServer.frame_post_draw
	var image := viewport.get_texture().get_image()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(args[3]).get_base_dir())
	var error := image.save_png(args[3])
	print("%s: %s" % [args[3],error_string(error)])
	viewport.free()
	manager._leave_game()
	main.queue_free()
	await process_frame
	await process_frame
	quit.call_deferred(error)
