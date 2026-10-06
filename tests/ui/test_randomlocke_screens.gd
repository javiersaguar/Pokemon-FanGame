extends GutTest
var main: Node
func before_each() -> void:
	GameState.reset()
	main = load("res://src/main/main.tscn").instantiate()
	main.set_script(null)
	add_child(main)
	SceneManager.register_main(main)
func after_each() -> void:
	SceneManager._leave_game()
	main.queue_free()
	for child: Node in AudioManager.get_children():
		if child is AudioStreamPlayer:
			child.stop()
			child.stream = null
	await wait_process_frames(2)
	SceneManager.world = null
	SceneManager.ui_layer = null
	SceneManager.battle_layer = null
	SceneManager.transition_layer = null
	SceneManager._fade = null
func press(action: StringName) -> void:
	for down: bool in [true,false]:
		var event := InputEventAction.new()
		event.action = action
		event.pressed = down
		Input.parse_input_event(event)
func test_settings_paginates_every_field_and_cancel_keeps_source_unchanged() -> void:
	var initial := RandomizerSettings.from_preset("clasico")
	var original := initial.to_dict()
	var result: Array = []
	var run := func() -> void: result.append(await RandomlockeSettingsScreen.edit(initial))
	run.call()
	await wait_process_frames(3)
	var screen := SceneManager.ui_layer.get_child(SceneManager.ui_layer.get_child_count()-1) as RandomlockeSettingsScreen
	assert_eq(screen.choices.size(),RandomizerSettings.FIELDS.size()+RandomizerSettings.EXTRA_FIELDS.size()+2)
	screen.menu.select(4) # Entrenadores (bool).
	press(&"accept")
	await wait_process_frames(3)
	assert_eq(screen.settings.trainers,not initial.trainers)
	assert_eq(screen.settings.preset,RandomizerSettings.CUSTOM)
	press(&"move_right")
	await wait_process_frames(3)
	assert_eq(screen.page,1)
	press(&"cancel")
	await wait_process_frames(3)
	assert_eq(result.size(),1)
	assert_null(result[0])
	assert_eq(initial.to_dict(),original)
	assert_false(SceneManager.is_menu_open())
func test_generation_runs_in_job_and_summary_cancel_does_not_apply_rom() -> void:
	var original := GameState.to_dict()
	var patch := await RandomlockeGeneratingScreen.generate(RandomizerSettings.from_preset("solo_aleatorio").to_dict(),713)
	assert_not_null(patch)
	assert_true(patch.is_valid())
	assert_false(SceneManager.is_menu_open())
	assert_false(DataDB.has_patch())
	var result: Array = []
	var run := func() -> void: result.append(await RandomlockeSummaryScreen.confirm(patch))
	run.call()
	await wait_process_frames(3)
	var screen := SceneManager.ui_layer.get_child(SceneManager.ui_layer.get_child_count()-1) as RandomlockeSummaryScreen
	assert_true(screen.notes[0].contains(RandomlockeSummaryScreen.code_lines(patch.seed_code())))
	assert_false(screen.notes[0].contains("charmander"),"resumen sin spoilers de especies")
	press(&"cancel")
	await wait_process_frames(3)
	assert_eq(result,[false])
	assert_false(DataDB.has_patch())
	assert_eq(GameState.to_dict(),original)
func test_normal_and_random_mode_screen_is_cancelable_without_starting_a_game() -> void:
	var done: Array = []
	var run := func() -> void:
		await RandomlockeFlow.new().run(97)
		done.append(true)
	run.call()
	await wait_process_frames(3)
	var screen := SceneManager.ui_layer.get_child(SceneManager.ui_layer.get_child_count()-1) as ChoiceScreen
	assert_eq(screen.choices,["Normal","RandomLocke"] as PackedStringArray)
	press(&"cancel")
	await wait_process_frames(3)
	assert_eq(done,[true])
	assert_false(GameState.in_game)
	assert_false(SceneManager.is_menu_open())

func test_shared_code_keeps_seed_and_custom_settings_in_summary() -> void:
	var settings := RandomizerSettings.from_preset("solo_aleatorio")
	settings.abilities = true
	settings.preset = RandomizerSettings.CUSTOM
	var code := SeedCode.encode(12487,settings)
	var run := func() -> void: await RandomlockeFlow.new().run(97)
	run.call()
	await wait_process_frames(3)
	var mode := SceneManager.ui_layer.get_child(SceneManager.ui_layer.get_child_count()-1) as ChoiceScreen
	mode.menu.select(1)
	press(&"accept")
	await wait_process_frames(3)
	var preset := SceneManager.ui_layer.get_child(SceneManager.ui_layer.get_child_count()-1) as ChoiceScreen
	preset.menu.select(4)
	press(&"accept")
	await wait_process_frames(3)
	var keyboard := SceneManager.ui_layer.get_child(SceneManager.ui_layer.get_child_count()-1) as NameKeyboard
	keyboard._finish(code)
	var summary: RandomlockeSummaryScreen
	for frame: int in 2000:
		await wait_process_frames(1)
		var top := SceneManager.ui_layer.get_child(SceneManager.ui_layer.get_child_count()-1)
		if top is RandomlockeSummaryScreen:
			summary = top
			break
	assert_not_null(summary)
	if summary:
		assert_eq(summary.rom.seed_code(),code)
		assert_eq(summary.rom.data.seed,12487)
		assert_true(summary.settings.abilities)
		await wait_process_frames(3)
		press(&"cancel")
		await wait_process_frames(3)
		press(&"cancel")
		await wait_process_frames(3)
	assert_false(GameState.in_game)
	assert_false(DataDB.has_patch())
	assert_false(SceneManager.is_menu_open())

func setup_locke_fixture() -> void:
	GameState.mode = GameState.MODE_RANDOMLOCKE
	GameState.in_game = true
	var rules := LockeRules.new(RandomizerSettings.from_preset("clasico").to_dict(),{},["{nickname}: epitafio de prueba."])
	GameState.randomlocke = {"snapshot":rules.snapshot(),"seed_code":"fixture"}
	GameState.slot = 0
	GameState.locke = WorldLocke.new(GameState.randomlocke)
func runtime() -> UiRuntime:
	for child: Node in SceneManager.ui_layer.get_children():
		if child is UiRuntime: return child
	return null
func test_zone_hides_during_menus_and_shows_actual_capture_status() -> void:
	setup_locke_fixture()
	var ui := runtime()
	EventBus.locke_zone_entered.emit("ruta_1","available")
	assert_true(ui.zone.visible)
	assert_eq(ui.zone.status_label.text,"Captura: Disponible")
	var menu := MenuScreen.new()
	SceneManager.push_menu(menu)
	assert_false(ui.zone.visible)
	SceneManager.pop_menu(menu)
	await wait_process_frames(2)
	EventBus.locke_zone_entered.emit("ruta_1","caught")
	assert_eq(ui.zone.status_label.text,"Captura: Capturada")
	var state := GameState.locke.rules.snapshot()
	state.rules.first_encounter = false
	GameState.locke.rules = LockeRules.from_dict(state)
	EventBus.locke_zone_entered.emit("ruta_1","lost")
	assert_eq(ui.zone.status_label.text,"Sin límite de captura por zona")
	ui.clear_transient_ui()
	assert_false(ui.zone.visible)
func test_cemetery_displays_saved_epitaph_and_cancel_does_not_mutate_dead_pokemon() -> void:
	setup_locke_fixture()
	var pokemon := Pokemon.create(&"charmander",5)
	pokemon.nickname = "Chispa"
	GameState.locke.death(pokemon,{"zone_id":"ruta_1","opponent":"Manolo"})
	var before := GameState.locke.rules.snapshot()
	var run := func() -> void: await CemeteryScreen.open()
	run.call()
	await wait_process_frames(3)
	var screen := SceneManager.top_menu() as CemeteryScreen
	assert_eq(screen.choices.size(),1)
	assert_true(screen.choices[0].contains("Chispa"))
	assert_true(screen.notes[0].contains("ruta_1"))
	assert_true(screen.notes[0].contains("Manolo"))
	assert_true(screen.notes[0].contains("Chispa: epitafio de prueba."))
	assert_not_null(screen.images[0])
	press(&"cancel")
	await wait_process_frames(3)
	assert_eq(GameState.locke.rules.snapshot(),before)
	assert_false(SceneManager.is_menu_open())
func test_game_over_waits_for_battle_and_cannot_be_canceled_back_to_world() -> void:
	setup_locke_fixture()
	var pokemon := Pokemon.create(&"charmander",5)
	GameState.locke.rules.register_owned("charmander")
	GameState.locke.death(pokemon,{"zone_id":"ruta_1"})
	SceneManager.in_battle = true
	assert_true(GameState.locke.check_game_over())
	await wait_process_frames(3)
	assert_null(SceneManager.top_menu())
	SceneManager.in_battle = false
	await wait_process_frames(3)
	var screen := SceneManager.top_menu() as LockeGameOverScreen
	assert_not_null(screen)
	press(&"cancel")
	await wait_process_frames(3)
	assert_eq(SceneManager.top_menu(),screen)
	assert_true(GameState.is_input_locked_by(&"locke_finished"))
	assert_eq(GameState.randomlocke.status,"finished")
func test_game_over_saves_finished_slot_before_returning_to_title() -> void:
	SaveManager.delete_save(98)
	var patch := await RandomlockeGeneratingScreen.generate(RandomizerSettings.from_preset("clasico").to_dict(),713)
	assert_eq(await SceneManager.start_randomlocke(patch,98,false),OK)
	var pokemon := Pokemon.create(&"charmander",5)
	GameState.locke.rules.register_owned("charmander")
	GameState.locke.death(pokemon,{"zone_id":"ruta_1"})
	assert_true(GameState.locke.check_game_over())
	await wait_process_frames(3)
	var screen := SceneManager.top_menu() as LockeGameOverScreen
	assert_not_null(screen)
	assert_eq(screen.save_error,OK)
	assert_eq(SaveManager.slot_summary(98).status,"finished")
	screen.menu.select(2)
	press(&"accept")
	await wait_seconds(0.65)
	assert_false(GameState.in_game)
	assert_false(SceneManager.is_menu_open())
	assert_eq(SaveManager.slot_summary(98).status,"finished")
	SaveManager.delete_save(98)
