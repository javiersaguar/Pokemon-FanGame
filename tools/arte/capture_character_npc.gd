extends SceneTree
## Captura el NPC colocado y su entorno real, con su identidad o con la hoja de respaldo.
func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	await process_frame
	var args := OS.get_cmdline_user_args()
	if args.size() < 3:
		push_error("Uso: -- mapa nodo nombre_salida [--sin-arte]")
		quit(1)
		return
	var map: Node2D = load("res://maps/%s.tscn" % args[0]).instantiate()
	var actor: Node2D = map.get_node(NodePath("Entities/" + args[1]))
	if "--sin-arte" in args: actor.set(&"art_id", &"")
	var viewport := SubViewport.new()
	viewport.size = Vector2i(512,384)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	root.add_child(viewport)
	map.position = Vector2(256,192) - actor.position
	viewport.add_child(map)
	for frame: int in 4: await process_frame
	await RenderingServer.frame_post_draw
	var path := "res://docs/arte/comparativas/%s.png" % args[2]
	var error := viewport.get_texture().get_image().save_png(ProjectSettings.globalize_path(path))
	if error != OK:
		push_error("No se puede guardar la captura: %s" % error_string(error))
		quit(1)
		return
	print("Captura: ",path)
	viewport.queue_free()
	await process_frame
	quit()
