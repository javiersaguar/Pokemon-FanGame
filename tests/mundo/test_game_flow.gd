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
	Dialogue._box.text_speed = 0
	main = load("res://src/main/main.tscn").instantiate()
	main.set_script(null)
	add_child(main)
	SceneManager.register_main(main)

func after_each() -> void:
	SaveManager.delete_save(SLOT)
	Dialogue.text_speed = speed
	Dialogue._box.text_speed = speed
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
	for frame: int in 30:
		await wait_physics_frames(1)
		if Dialogue._choice.is_choosing:
			break
	await wait_frames(2)
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

func test_hilo_rom_misma_semilla_y_arranque_randomlocke() -> void:
	var settings := RandomizerSettings.from_preset("clasico")
	var job := RandomlockeJob.new()
	add_child(job)
	assert_eq(job.start(settings.to_dict(), 42), OK)
	var rom: RomPatch = await job.finished
	job.queue_free()
	assert_true(rom.errors.is_empty())
	assert_false(GameState.in_game, "El hilo no inicia ni cambia la partida")
	var direct := Randomizer.generate(RandomizerInput.from_datadb(), settings, 42)
	assert_eq(rom.to_json(), direct.to_json())
	assert_eq(await SceneManager.start_randomlocke(rom, SLOT, false), OK)
	assert_true(GameState.is_randomlocke())
	assert_true(DataDB.has_patch())
	assert_eq(GameState.randomlocke.seed_code, rom.seed_code())
	assert_not_null(GameState.locke)
	assert_eq(GameState.locke.rules.zone_status(String(SceneManager.current_map.get_zone_id())), "available")
	assert_eq(SaveManager.save_game(SLOT), OK)
	SceneManager._leave_game()
	assert_eq(await SceneManager.continue_game(SLOT), OK)
	assert_eq(JSON.stringify(GameState.rom_patch, "", true), JSON.stringify(JSON.parse_string(rom.to_json()), "", true))

func test_rom_ausente_o_invalida_no_reemplaza_partida() -> void:
	await SceneManager.start_new_game(&"", &"", {"slot": SLOT})
	GameState.player_name = "Anterior"
	var map := SceneManager.current_map
	var party: Variant = GameState.party
	var events := [0]
	var listen := func() -> void: events[0] += 1
	EventBus.new_game_started.connect(listen)
	GameState.lock_input(&"test_previous")
	assert_eq(await SceneManager.start_new_game(&"", &"", {"mode": "randomlocke", "rom_patch": {}}), ERR_INVALID_DATA)
	assert_eq(events[0], 0)
	assert_eq(GameState.party, party, "Conserva los módulos, no solo sus datos serializados")
	assert_true(GameState.is_input_locked_by(&"test_previous"))
	GameState.unlock_input(&"test_previous")
	EventBus.new_game_started.disconnect(listen)
	assert_eq(GameState.player_name, "Anterior")
	assert_true(GameState.in_game)
	assert_eq(SceneManager.current_map, map)
	assert_eq(GameState.slot, SLOT)
	GameState.new_game({"slot": SLOT, "mode": "randomlocke", "rom_patch": {"generator_version": 1, "starters": {"starter_1": "litwick"}}})
	assert_eq(SaveManager.save_game(SLOT), OK)
	DirAccess.remove_absolute(SaveManager.rom_patch_path(SLOT))
	DirAccess.remove_absolute(SaveManager.rom_patch_path(SLOT) + ".bak")
	GameState.new_game({"slot": 1})
	GameState.player_name = "Normal"
	assert_eq(SaveManager.load_game(SLOT), ERR_FILE_CORRUPT)
	assert_eq(GameState.player_name, "Normal")
	assert_false(DataDB.has_patch())

func test_mote_pendiente_teclado_y_restauracion() -> void:
	var rom := Randomizer.generate(17, RandomizerSettings.from_preset("clasico"))
	await SceneManager.start_randomlocke(rom, SLOT, false)
	var pokemon := Pokemon.create(&"bulbasaur", 5)
	assert_eq(GameState.locke.receive(pokemon, {}, true), "pending")
	await wait_physics_frames(2)
	assert_true(is_instance_valid(SceneManager._nickname_entry))
	SceneManager._nickname_entry.entry.text_submitted.emit("  Panchito  ")
	await wait_physics_frames(2)
	assert_eq(GameState.party.get_at(0).nickname, "Panchito")
	assert_false(GameState.input_locked)
	assert_eq(GameState.locke.receive(Pokemon.create(&"squirtle", 5), {}, true), "pending")
	assert_eq(SaveManager.save_game(SLOT), OK)
	SceneManager._leave_game()
	await wait_physics_frames(2)
	await SceneManager.continue_game(SLOT)
	await wait_physics_frames(2)
	assert_true(is_instance_valid(SceneManager._nickname_entry))
	SceneManager._nickname_entry.entry.text_submitted.emit("Agua")
	await wait_physics_frames(2)
	assert_eq(GameState.party.get_at(1).nickname, "Agua")
	assert_false(GameState.input_locked)

func test_codigo_personalizado_y_cancelar_entrada() -> void:
	var settings := RandomizerSettings.from_preset("clasico")
	settings.nickname_required = false
	settings.types = true
	settings.preset = RandomizerSettings.CUSTOM
	var code := SeedCode.encode(123, settings)
	var decoded := SeedCode.decode(code)
	assert_true(decoded.ok)
	assert_eq(decoded.settings.to_dict(), settings.to_dict())
	var value := ["pending"]
	var ask := func() -> void: value[0] = await SceneManager.request_text("Código", "", "PANCHITO-…", true)
	ask.call()
	await wait_physics_frames(2)
	press(&"cancel")
	await wait_physics_frames(2)
	assert_eq(value[0], "")
	assert_false(GameState.input_locked)

func test_flujo_randomlocke_modo_ajustes_resumen_intro_sin_debug() -> void:
	var done := [false]
	var flow = load("res://src/main/randomlocke_fallback.gd").new()
	var start := func() -> void:
		await flow.run(SLOT)
		done[0] = true
	start.call()
	var chose_mode := false
	for frame: int in 420:
		await wait_physics_frames(1)
		for node: Node in SceneManager.ui_layer.get_children():
			if node.get_script() == load("res://src/main/identity_fallback.gd"):
				node.entry.text_submitted.emit("Javi" if node.kind == &"player" else "Azul")
		if Dialogue._choice.is_choosing:
			if not chose_mode:
				press(&"move_down")
				chose_mode = true
			press()
		elif Dialogue.is_open:
			press()
		if done[0]:
			break
	assert_true(done[0])
	assert_true(GameState.in_game)
	assert_true(GameState.is_randomlocke())
	assert_true(GameState.flag(&"story_intro_done"))
	assert_true(DataDB.has_patch())
	assert_false(GameState.input_locked)
