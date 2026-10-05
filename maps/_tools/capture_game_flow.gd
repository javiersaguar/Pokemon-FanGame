extends SceneTree
func _initialize() -> void:
	await process_frame
	var manager = root.get_node("SceneManager")
	var dialogue = root.get_node("Dialogue")
	var cutscene = root.get_node("Cutscene")
	var state = root.get_node("GameState")
	var main = load("res://src/main/main.tscn").instantiate()
	main.set_script(null)
	root.add_child(main)
	manager.register_main(main)
	dialogue.text_speed = 0
	await manager.go_to_title()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/arte/comparativas/flujo_menu_inicial.png")
	manager._leave_game()
	dialogue._choice._finish(3)
	await process_frame
	await manager.start_new_game()
	state.set_flag(&"story_intro_done")
	manager.open_pause_menu()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/arte/comparativas/flujo_menu_pausa.png")
	dialogue._choice._finish(0)
	await process_frame
	cutscene.request_name(&"player", "POR DEFINIR")
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/arte/comparativas/flujo_nombre.png")
	for node in manager.ui_layer.get_children():
		if node.get_script() == load("res://src/main/identity_fallback.gd"):
			node._submit("POR DEFINIR")
	manager._leave_game()
	main.queue_free()
	await process_frame
	await process_frame
	quit.call_deferred()
