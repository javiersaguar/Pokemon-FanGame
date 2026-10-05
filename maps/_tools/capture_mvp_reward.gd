extends SceneTree
func _initialize() -> void:
	await process_frame
	var manager = root.get_node("SceneManager")
	var state = root.get_node("GameState")
	var cutscene = root.get_node("Cutscene")
	var dialogue = root.get_node("Dialogue")
	var main = load("res://src/main/main.tscn").instantiate()
	main.set_script(null)
	root.add_child(main)
	manager.register_main(main)
	await manager.start_new_game()
	state.set_flag(&"story_intro_done")
	state.set_flag(&"story_bedroom_done")
	state.set_flag(&"story_lab_intro_done")
	state.set_flag(&"rival_intro_done")
	state.set_flag(&"got_pokedex")
	state.player_name = "POR DEFINIR"
	dialogue.text_speed = 0
	state.world_config.mvp_story.reward.quantity = null
	cutscene.play(load("res://src/events/mvp/mvp_story_event.gd"), null, {"stage": "rewards"})
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/arte/comparativas/recompensa_antes.png")
	var accept := InputEventAction.new()
	accept.action = &"accept"
	accept.pressed = true
	Input.parse_input_event(accept)
	await process_frame
	accept.pressed = false
	Input.parse_input_event(accept)
	await process_frame
	state.world_config.mvp_story.reward.quantity = 5
	cutscene.play(load("res://src/events/mvp/mvp_story_event.gd"), null, {"stage": "rewards"})
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/arte/comparativas/recompensa_5_balls.png")
	for i in 30:
		if not cutscene.is_running():
			break
		accept.pressed = true
		Input.parse_input_event(accept)
		await process_frame
		accept.pressed = false
		Input.parse_input_event(accept)
		await process_frame
	manager._leave_game()
	main.queue_free()
	await process_frame
	await process_frame
	quit()
