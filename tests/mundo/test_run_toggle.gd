extends GutTest
const SLOT := 93
var player: Player
var map: MapRoot
func before_each() -> void:
	GameState.new_game()
	map = MapRoot.new()
	map.data = MapData.new()
	add_child_autofree(map)
	SceneManager.current_map = map
	player = load("res://src/overworld/player/player.tscn").instantiate()
	map.add_child(player)
func after_each() -> void:
	SaveManager.delete_save(SLOT)
	SceneManager.current_map = null
	GameState.reset()
func test_mantener_y_modo_activado_invierten_la_velocidad() -> void:
	assert_false(GameState.always_run)
	assert_false(player.running_requested(false))
	assert_true(player.running_requested(true))
	GameState.set_always_run(true)
	assert_true(player.running_requested(false))
	assert_false(player.running_requested(true))
func test_teclas_r_y_boton_y_asignados() -> void:
	var keys := []
	var buttons := []
	for event: InputEvent in InputMap.action_get_events(&"run_toggle"):
		if event is InputEventKey:
			keys.append(event.physical_keycode)
		elif event is InputEventJoypadButton:
			buttons.append(event.button_index)
	assert_has(keys, KEY_R)
	assert_has(buttons, JOY_BUTTON_Y)
func test_toggle_emite_aviso_y_respeta_bloqueo() -> void:
	watch_signals(EventBus)
	var event := InputEventAction.new()
	event.action = &"run_toggle"
	event.pressed = true
	Input.parse_input_event(event)
	await wait_physics_frames(2)
	event.pressed = false
	Input.parse_input_event(event)
	assert_true(GameState.always_run)
	assert_signal_emit_count(EventBus, "always_run_changed", 1)
	GameState.lock_input(&"test")
	await wait_physics_frames(1)
	event.pressed = true
	Input.parse_input_event(event)
	await wait_physics_frames(2)
	event.pressed = false
	Input.parse_input_event(event)
	assert_true(GameState.always_run)
	assert_signal_emit_count(EventBus, "always_run_changed", 1)
func test_interiores_zonas_prohibidas_y_transporte_no_corren() -> void:
	GameState.set_always_run(true)
	map.data.can_run = false
	assert_false(player.running_requested(false))
	map.data.can_run = true
	map.data.outdoor = false
	map.data.fixed_camera = true
	assert_false(player.running_requested(false))
	map.data.outdoor = true
	GameState.set_var(&"transport", "bike")
	assert_false(player.running_requested(false))
	GameState.set_var(&"transport", "surf")
	assert_false(player.running_requested(true))
func test_ajuste_guardado_y_partida_anterior() -> void:
	GameState.set_always_run(true)
	assert_eq(SaveManager.save_game(SLOT), OK)
	GameState.reset()
	assert_eq(SaveManager.load_game(SLOT), OK)
	assert_true(GameState.always_run)
	var old := GameState.to_dict()
	old.erase("always_run")
	GameState.from_dict(old)
	assert_false(GameState.always_run, "guardado anterior usa el valor de world.json")
