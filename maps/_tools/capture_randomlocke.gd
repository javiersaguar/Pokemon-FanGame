extends SceneTree
func press(action: StringName = &"accept") -> void:
	for down: bool in [true, false]:
		var event := InputEventAction.new()
		event.action = action
		event.pressed = down
		Input.parse_input_event(event)
func capture(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/arte/comparativas/randomlocke_%s.png" % name)
func _initialize() -> void:
	await process_frame
	var manager = root.get_node("SceneManager")
	var state = root.get_node("GameState")
	var dialogue = root.get_node("Dialogue")
	dialogue._box.text_speed = 0
	var main = load("res://src/main/main.tscn").instantiate()
	main.set_script(null)
	root.add_child(main)
	manager.register_main(main)
	await manager.fade_in()
	var flow = load("res://src/main/randomlocke_fallback.gd").new()
	var done := [false]
	var run := func() -> void:
		await flow.run(96)
		done[0] = true
	run.call()
	var stage := 0
	var deadline := Time.get_ticks_msec() + 20000
	while Time.get_ticks_msec() < deadline:
		await process_frame
		if dialogue._choice.is_choosing:
			await process_frame
			if stage == 0:
				await capture("modo")
				press(&"move_down")
				stage = 1
			elif stage == 1:
				await capture("ajustes")
				stage = 2
			elif stage == 2:
				await capture("resumen")
				stage = 3
			press()
		elif dialogue.is_open:
			press()
		for node in manager.ui_layer.get_children():
			if node.get_script() == load("res://src/main/identity_fallback.gd"):
				node.entry.text_submitted.emit("Javi" if node.kind == &"player" else "Azul")
		if done[0]:
			break
	if not done[0] or not state.is_randomlocke():
		push_error("El flujo no terminó")
		quit(1)
		return
	await process_frame
	await capture("zona")
	var pokemon = load("res://src/pokemon/pokemon.gd").create(&"bulbasaur", 5)
	state.locke.receive(pokemon, {}, true)
	await process_frame
	await capture("mote")
	manager._nickname_entry.entry.text_submitted.emit("Panchito")
	await process_frame
	await manager.change_map(&"muestras/ruta", &"default")
	await capture("mapa_valido")
	await manager.change_map(&"no/existe")
	await capture("mapa_invalido_origen_preservado")
	flow = null
	run = Callable()
	manager._leave_game()
	main.queue_free()
	await process_frame
	quit.call_deferred()
