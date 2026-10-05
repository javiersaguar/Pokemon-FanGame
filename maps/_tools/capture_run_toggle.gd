extends SceneTree
func _initialize() -> void:
	await process_frame
	var manager = root.get_node("SceneManager")
	var state = root.get_node("GameState")
	state.new_game()
	var map = load("res://maps/test/test_outdoor.tscn").instantiate()
	root.add_child(map)
	manager.current_map = map
	var player = load("res://src/overworld/player/player.tscn").instantiate()
	map.add_child(player)
	player.set_process(false)
	player.place_at(Vector2i(9, 7), Vector2i.RIGHT)
	player.setup_camera(map)
	player.step(Vector2i.RIGHT, 0.25, false, player.running_requested(false))
	await create_timer(0.05).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/arte/comparativas/correr_desactivado.png")
	await player.step_finished
	await process_frame
	player.place_at(Vector2i(9, 7), Vector2i.RIGHT)
	var toggle := InputEventAction.new()
	toggle.action = &"run_toggle"
	toggle.pressed = true
	Input.parse_input_event(toggle)
	await process_frame
	toggle.pressed = false
	Input.parse_input_event(toggle)
	player.step(Vector2i.RIGHT, 0.125, false, player.running_requested(false))
	await create_timer(0.025).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/arte/comparativas/correr_activado.png")
	await player.step_finished
	manager.current_map = null
	map.queue_free()
	await process_frame
	quit.call_deferred()
