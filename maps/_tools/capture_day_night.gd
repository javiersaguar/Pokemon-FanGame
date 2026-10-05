extends SceneTree
func _initialize() -> void:
	await process_frame
	var manager = root.get_node("SceneManager")
	var clock = root.get_node("Clock")
	var main = load("res://src/main/main.tscn").instantiate()
	main.set_script(null)
	root.add_child(main)
	manager.register_main(main)
	await manager.start_new_game(&"muestras/ruta", &"default")
	manager.player.set_process(false)
	var original_offset: int = clock.debug_hour_offset
	clock.set_debug_hour_offset(12 - clock.hour())
	manager.atmosphere.apply_map(manager.current_map)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/arte/comparativas/entorno_dia.png")
	clock.set_debug_hour_offset(clock.debug_hour_offset + 22 - clock.hour())
	manager.atmosphere.apply_map(manager.current_map)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/arte/comparativas/entorno_noche.png")
	clock.set_debug_hour_offset(original_offset)
	manager._leave_game()
	main.queue_free()
	await process_frame
	quit.call_deferred()
