extends GutTest
## Pantallas provisionales + SceneManager, usando input y archivos reales.
const SLOT := 97
var main: Node
var speed: int

func before_each() -> void:
	SaveManager.delete_save(SLOT)
	GameState.reset()
	speed = Dialogue.text_speed
	Dialogue.text_speed = 0
	main = load("res://src/main/main.tscn").instantiate()
	main.set_script(null)
	add_child(main)
	SceneManager.register_main(main)

func after_each() -> void:
	SaveManager.delete_save(SLOT)
	Dialogue.text_speed = speed
	SceneManager._leave_game()
	main.queue_free()
	await wait_physics_frames(2)
	SceneManager.world = null
	SceneManager.ui_layer = null
	SceneManager.battle_layer = null
	SceneManager.transition_layer = null
	SceneManager._fade = null

func press(action: StringName = &"accept") -> void:
	for down: bool in [true, false]:
		var event := InputEventAction.new()
		event.action = action
		event.pressed = down
		Input.parse_input_event(event)

func test_ranura_cancelada_no_inicia_partida() -> void:
	var done := {"slot": -1}
	var choose := func() -> void:
		done.slot = await SceneManager.choose_slot(true)
	choose.call()
	await wait_physics_frames(2)
	press(&"cancel")
	await wait_physics_frames(2)
	assert_eq(done.slot, 0)
	assert_false(GameState.in_game)

func test_intro_nombres_teclado_y_mapa_sin_debug() -> void:
	var done := [false]
	var start := func() -> void:
		await SceneManager.start_new_game(&"", &"", {"slot": SLOT, "intro": true})
		done[0] = true
	start.call()
	for frame: int in 240:
		await wait_physics_frames(1)
		for node: Node in SceneManager.ui_layer.get_children():
			if node.get_script() == load("res://src/main/identity_fallback.gd"):
				node.entry.text_submitted.emit("Javi" if node.kind == &"player" else "Azul")
		if Dialogue.is_open:
			press()
		if done[0]:
			break
	assert_true(done[0])
	assert_true(GameState.in_game)
	assert_true(GameState.flag(&"story_intro_done"))
	assert_eq(GameState.slot, SLOT)
	assert_eq(GameState.player_name, "Javi")
	assert_eq(GameState.rival_name, "Azul")
	assert_false(GameState.input_locked)

func test_pausa_guarda_y_continuar_restaura() -> void:
	await SceneManager.start_new_game(&"", &"", {"slot": SLOT})
	GameState.player_name = "Javi"
	GameState.set_flag(&"story_intro_done")
	SceneManager.player.place_at(Vector2i(8, 5), Vector2i.LEFT)
	SceneManager.open_pause_menu()
	await wait_physics_frames(3)
	assert_true(SceneManager.is_menu_open())
	press(&"move_down")
	await wait_physics_frames(1)
	press()
	for frame: int in 30:
		await wait_physics_frames(1)
		if Dialogue.is_open:
			press()
		if not SceneManager.is_menu_open():
			break
	assert_true(SaveManager.has_save(SLOT))
	assert_false(SceneManager.is_menu_open())
	SceneManager._leave_game()
	assert_eq(await SceneManager.continue_game(SaveManager.last_used_slot()), OK)
	assert_eq(GameState.player_name, "Javi")
	assert_eq(GameState.player_tile, Vector2i(8, 5))
	assert_eq(SceneManager.player.facing, Vector2i.LEFT)
	assert_false(GameState.input_locked)

func test_pausa_cancelada_devuelve_control() -> void:
	await SceneManager.start_new_game(&"", &"", {"slot": SLOT})
	SceneManager.open_pause_menu()
	await wait_physics_frames(3)
	press(&"cancel")
	await wait_physics_frames(3)
	assert_false(SceneManager.is_menu_open())
	assert_false(GameState.input_locked)
