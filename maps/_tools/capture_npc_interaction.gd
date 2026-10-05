extends SceneTree
## Captura real antes/después del giro al hablar (renderer, sin redibujar assets).
func _initialize() -> void:
	await process_frame
	var state = root.get_node("GameState")
	var manager = root.get_node("SceneManager")
	state.new_game()
	state.lock_input(&"capture")
	var map = load("res://maps/test/test_outdoor.tscn").instantiate()
	root.add_child(map)
	manager.current_map = map
	var player = load("res://src/overworld/player/player.tscn").instantiate()
	map.add_child(player)
	player.place_at(Vector2i(10, 7), Vector2i.LEFT)
	player.set_process(false)
	player.setup_camera(map)
	var npc = load("res://src/overworld/npc/npc.tscn").instantiate()
	map.add_child(npc)
	npc.place_at(Vector2i(9, 7), Vector2i.UP)
	npc.set_process(false)
	await physics_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/arte/comparativas/npc_antes_hablar.png")
	await player._interact()
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/arte/comparativas/npc_despues_hablar.png")
	manager.current_map = null
	quit()
