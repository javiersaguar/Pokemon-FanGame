extends SceneTree
func _initialize() -> void:
	await process_frame
	var manager = root.get_node("SceneManager")
	var state = root.get_node("GameState")
	var dialogue = root.get_node("Dialogue")
	var field = load("res://src/overworld/field_encounters.gd")
	var main = load("res://src/main/main.tscn").instantiate()
	main.set_script(null)
	root.add_child(main)
	manager.register_main(main)
	await manager.start_new_game(&"muestras/ruta", &"default")
	manager.player.set_process(false)
	state.bag.add(&"bicycle")
	state.bag.add(&"oldrod")
	state.party.add(load("res://src/pokemon/pokemon.gd").create(&"pidgey", 10))
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/arte/comparativas/transporte_andar.png")
	if not manager.player.set_transport_mode(&"bike"):
		push_error("No se activa la bici en la ruta de captura")
		quit(1)
		return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/arte/comparativas/transporte_bici.png")
	var water := Vector2i(-1, -1)
	var bank := Vector2i(-1, -1)
	var deep := Vector2i(-1, -1)
	var facing := Vector2i.ZERO
	var bounds: Rect2i = manager.current_map.get_ground().get_used_rect()
	for y in range(bounds.position.y, bounds.end.y):
		for x in range(bounds.position.x, bounds.end.x):
			var tile := Vector2i(x, y)
			if manager.current_map.terrain_at(tile) != "water":
				continue
			for side in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
				if manager.current_map.terrain_at(tile + side) not in ["water", "tree", ""] and manager.player.is_tile_free(tile + side):
					water = tile
					bank = tile + side
					facing = -side
					break
			if water.x >= 0:
				break
		if water.x >= 0:
			break
	# Fixture temporal: no inventa un objeto de Surf en los datos de historia.
	state.world_config.field.actions.surf.item = "bicycle"
	for y in range(bounds.position.y, bounds.end.y):
		for x in range(bounds.position.x, bounds.end.x):
			var tile := Vector2i(x, y)
			if manager.current_map.terrain_at(tile) == "water" and manager.current_map.terrain_at(tile + Vector2i.LEFT) == "water" and manager.current_map.terrain_at(tile + Vector2i.RIGHT) == "water" and manager.current_map.terrain_at(tile + Vector2i.UP) == "water" and manager.current_map.terrain_at(tile + Vector2i.DOWN) == "water":
				deep = tile
				break
		if deep.x >= 0:
			break
	manager.player.place_at(deep if deep.x >= 0 else water, facing)
	manager.player.set_transport_mode(&"surf")
	manager.player.setup_camera(manager.current_map)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/arte/comparativas/transporte_surf.png")
	manager.player.place_at(bank, facing)
	manager.player.set_transport_mode(&"walk")
	manager.player.setup_camera(manager.current_map)
	dialogue.text_speed = 0
	field.start(manager.current_map, &"old_rod", water)
	await create_timer(0.5).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/arte/comparativas/transporte_pesca.png")
	for i in 12:
		if not dialogue.is_open:
			break
		var accept := InputEventAction.new()
		accept.action = &"accept"
		accept.pressed = true
		Input.parse_input_event(accept)
		await process_frame
		accept.pressed = false
		Input.parse_input_event(accept)
		await process_frame
	manager._leave_game()
	main.queue_free()
	await process_frame
	quit.call_deferred()
