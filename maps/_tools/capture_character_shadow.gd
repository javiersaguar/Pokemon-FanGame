extends SceneTree
func _initialize() -> void:
	await process_frame
	var manager = root.get_node("SceneManager")
	var state = root.get_node("GameState")
	state.new_game()
	state.lock_input(&"capture")
	var map = load("res://maps/test/test_outdoor.tscn").instantiate()
	root.add_child(map)
	manager.current_map = map
	var player = load("res://src/overworld/player/player.tscn").instantiate()
	map.add_child(player)
	player.place_at(Vector2i(9, 7), Vector2i.DOWN)
	player.set_process(false)
	player.setup_camera(map)
	var npc = load("res://src/overworld/npc/npc.tscn").instantiate()
	map.add_child(npc)
	npc.place_at(Vector2i(11, 7), Vector2i.DOWN)
	var follower = load("res://src/overworld/follower/follower.tscn").instantiate()
	follower.species = &"pikachu"
	map.add_child(follower)
	follower.place_at(Vector2i(8, 7), Vector2i.DOWN)
	var shadows := []
	for actor in map.find_children("*", "Node2D", true, false):
		if actor.has_node("GroundShadow"):
			shadows.append(actor.get_node("GroundShadow"))
	for shadow in shadows:
		shadow.visible = false
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/arte/comparativas/sombras_antes.png")
	for shadow in shadows:
		shadow.visible = true
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/arte/comparativas/sombras_integradas.png")
	manager.current_map = null
	map.queue_free()
	await process_frame
	quit.call_deferred()
