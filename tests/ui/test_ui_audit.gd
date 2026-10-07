extends GutTest
var main: Node
var preferences: Dictionary
const SLOT := 96
func before_each() -> void:
	GameState.reset()
	UiPreferences.initialize()
	preferences = UiPreferences.values.duplicate(true)
	main = load("res://src/main/main.tscn").instantiate()
	main.set_script(null)
	add_child(main)
	SceneManager.register_main(main)
func after_each() -> void:
	SaveManager.delete_save(SLOT)
	SceneManager._leave_game()
	main.queue_free()
	await wait_process_frames(2)
	SceneManager.world = null
	SceneManager.ui_layer = null
	SceneManager.battle_layer = null
	SceneManager.transition_layer = null
	SceneManager._fade = null
	for key: String in preferences: UiPreferences.set_value(key,preferences[key])
	for node: Node in AudioManager.get_children():
		if node is AudioStreamPlayer: node.stop(); node.stream = null
	await wait_process_frames(2)
func key(code: Key) -> void:
	for pressed: bool in [true,false]:
		var event := InputEventKey.new()
		event.keycode = code; event.physical_keycode = code; event.pressed = pressed
		Input.parse_input_event(event)
	await wait_process_frames(3)
func joy(button: JoyButton) -> void:
	for pressed: bool in [true,false]:
		var event := InputEventJoypadButton.new()
		event.button_index = button; event.pressed = pressed
		Input.parse_input_event(event)
	await wait_process_frames(3)
func test_keyboard_and_controller_page_the_pc_and_return_without_mutation() -> void:
	var screen := PCScreen.new()
	SceneManager.push_menu(screen)
	await wait_process_frames(3)
	await key(KEY_RIGHT)
	assert_eq(screen.page,1)
	await joy(JOY_BUTTON_DPAD_RIGHT)
	assert_eq(screen.page,2)
	await joy(JOY_BUTTON_DPAD_DOWN)
	assert_eq(screen.menu.selected,1)
	watch_signals(screen)
	await joy(JOY_BUTTON_B)
	assert_signal_emitted(screen,&"closed")
	assert_null(GameState.pc.get_pokemon(0,13))
	SceneManager.pop_menu(screen)
func test_options_controls_nested_menu_returns_to_options_with_controller() -> void:
	var screen := OptionsScreen.new()
	SceneManager.push_menu(screen)
	await wait_process_frames(3)
	await joy(JOY_BUTTON_DPAD_RIGHT)
	for index: int in 5: await joy(JOY_BUTTON_DPAD_DOWN)
	await joy(JOY_BUTTON_A)
	var controls := SceneManager.top_menu() as ControlsScreen
	assert_not_null(controls)
	if controls == null: return
	assert_true(controls.notes[4].contains("A"))
	await key(KEY_RIGHT)
	assert_eq(controls.page,1)
	await joy(JOY_BUTTON_B)
	assert_eq(SceneManager.top_menu(),screen)
	await key(KEY_X)
	assert_true(screen._done)
	SceneManager.pop_menu(screen)
func test_optional_name_cancel_and_required_name_controller_input() -> void:
	var screen := NameKeyboard.new()
	screen.allow_cancel = true
	SceneManager.push_menu(screen)
	await wait_process_frames(3)
	watch_signals(screen)
	await key(KEY_X)
	assert_signal_emitted_with_parameters(screen,&"completed",[""])
	SceneManager.pop_menu(screen)
	assert_false(GameState.input_locked)
	var required := NameKeyboard.new()
	required.allow_cancel = false
	SceneManager.push_menu(required)
	await wait_process_frames(3)
	await joy(JOY_BUTTON_B)
	assert_false(required._done)
	await joy(JOY_BUTTON_A)
	assert_false(required.entry.text.is_empty())
	required.submit_value(required.entry.text)
	SceneManager.pop_menu(required)
	assert_false(GameState.input_locked)
func test_new_game_uses_title_run_default_and_continue_keeps_saved_value() -> void:
	UiPreferences.set_value("always_run",true)
	assert_eq(await SceneManager.start_new_game(&"",&"",{"slot":SLOT}),OK)
	assert_true(GameState.always_run)
	assert_eq(SaveManager.save_game(SLOT),OK)
	SceneManager._leave_game()
	UiPreferences.set_value("always_run",false)
	assert_eq(await SceneManager.continue_game(SLOT),OK)
	assert_true(GameState.always_run,"La preferencia del título no pisa el guardado")
	assert_false(GameState.input_locked)
	SceneManager._leave_game()
	UiPreferences.set_value("always_run",true)
	await SceneManager.start_new_game(&"",&"",{"always_run":false})
	assert_false(GameState.always_run,"Opciones explícitas del llamador tienen prioridad")
func test_long_name_bounds_and_full_details_include_moves_pp_and_ribbons() -> void:
	var p := Pokemon.create(&"charmander",16)
	p.nickname = "ABCDEFGHIJKL"; p.gender = &"female"; p.shiny = true
	p.original_trainer = "ABCDEFGHIJKL"
	p.ribbons.assign([&"cinta_prueba"])
	var screen := SummaryScreen.new()
	SceneManager.ui_layer.add_child(screen)
	screen.show_party([p])
	await wait_process_frames(3)
	assert_lte(screen._name.position.x + screen._name.size.x,106.0)
	var data := screen.detail_choices(p)
	assert_true(data.notes[0].contains(p.nickname))
	assert_true(data.notes[1].contains("PP"))
	assert_eq(data.notes[-1],"cinta_prueba")
	await joy(JOY_BUTTON_START)
	var details := SceneManager.top_menu() as ChoiceScreen
	assert_not_null(details)
	await joy(JOY_BUTTON_DPAD_DOWN)
	assert_eq(screen.index,0,"La ficha no navega por debajo del detalle")
	await joy(JOY_BUTTON_B)
	assert_false(screen._detail_open)
	var box := BattleDataBox.new()
	SceneManager.ui_layer.add_child(box)
	box.show_pokemon({"name":p.nickname,"gender":p.gender,"shiny":true,"level":100,"hp":100,"max_hp":100})
	assert_lte(box._star.position.x + 8,box._level.position.x)
	assert_lte(box._name.position.x + box._name.size.x,69.0)

func test_machine_is_consumed_only_after_valid_learning_and_requires_replacement() -> void:
	var p := Pokemon.create(&"charmander",50)
	var item: StringName = &""
	var move: StringName = &""
	for candidate: StringName in MoveLessons.machine_ids():
		var id := MoveLessons.machine_move(candidate)
		if MoveLessons.can_learn_machine(p.species_id,id) and not p.has_move(id): item = candidate; move = id; break
	assert_ne(item,&"")
	GameState.bag.add(item,2)
	assert_eq(FieldItemUse.use(item,p),ERR_UNAVAILABLE)
	assert_eq(GameState.bag.count(item),2)
	assert_eq(FieldItemUse.use(item,p,0),OK)
	assert_true(p.has_move(move))
	assert_eq(GameState.bag.count(item),1)
	assert_eq(FieldItemUse.use(item,p,1),ERR_UNAVAILABLE)
	assert_eq(GameState.bag.count(item),1)
func test_recordador_cancel_with_controller_preserves_all_moves() -> void:
	var p := Pokemon.create(&"charmander",30)
	var before := p.to_dict()
	var done := [false,false]
	var open := func() -> void:
		done[1] = await MoveLessonScreen.open_recordador(p)
		done[0] = true
	open.call()
	await wait_process_frames(3)
	assert_true(SceneManager.top_menu() is MoveLessonScreen)
	await joy(JOY_BUTTON_B)
	assert_true(done[0])
	assert_false(done[1])
	assert_eq(p.to_dict(),before)

func test_title_card_and_subscreen_help_fit_above_permanent_author_footer() -> void:
	await SceneManager.start_new_game(&"",&"",{"slot":SLOT})
	GameState.player_name = "ABCDEFGHIJKL"
	SaveManager.save_game(SLOT)
	SceneManager._leave_game()
	var title := TitleScreen.new(); title.skip_sequence = true
	add_child_autofree(title)
	title.set_stage(&"menu")
	await wait_process_frames(3)
	assert_lte(title._card.position.y + title._card.size.y,169.0)
	assert_eq(title._card.text.split("\n").size(),4)
	var credits := CreditsScreen.new()
	title.show_subscreen(credits)
	await wait_process_frames(3)
	assert_eq(credits.hint.position.y,165.0)
	assert_lte(credits.hint.position.y + credits.hint.get_minimum_size().y,177.0)
	assert_true(title.footer.text.contains("Javier Saguar"))
	credits.closed.emit()
	await wait_process_frames(3)

func test_machine_replacement_cancel_does_not_consume_or_change_moves() -> void:
	var p := Pokemon.create(&"charmander",50)
	var item: StringName = &""
	for candidate: StringName in MoveLessons.machine_ids():
		var id := MoveLessons.machine_move(candidate)
		if MoveLessons.can_learn_machine(p.species_id,id) and not p.has_move(id): item = candidate; break
	GameState.bag.add(item)
	var before := p.to_dict()
	var outcome := [OK]
	var use := func() -> void: outcome[0] = await MoveLessonScreen.use_machine(p,item)
	use.call()
	await wait_process_frames(3)
	assert_true(SceneManager.top_menu() is LearnMoveScreen)
	await key(KEY_X)
	assert_eq(outcome[0],ERR_SKIP)
	assert_eq(GameState.bag.count(item),1)
	assert_eq(p.to_dict(),before)

func test_intro_and_game_over_wrapped_text_fit_their_panels() -> void:
	var intro := ProfessorIntro.new()
	SceneManager.push_menu(intro)
	await wait_process_frames(3)
	for node: Node in intro.canvas.get_children():
		if node is Label and node.text.begins_with("Un mundo"):
			assert_lte(node.position.x + node.size.x,233.0)
			assert_gt(node.size.y,float(node.get_theme_font_size(&"font_size")))
	SceneManager.pop_menu(intro)
	var over := LockeGameOverScreen.new()
	SceneManager.push_menu(over)
	await wait_process_frames(3)
	assert_lte(over.summary.position.x + over.summary.size.x,244.0)
	assert_lte(over.summary.position.y + over.summary.size.y,97.0)
	SceneManager.pop_menu(over)

func test_pokedex_help_and_generating_explanation_fit_screen_and_panel() -> void:
	var dex := PokedexEntry.new(); dex.species_id = &"charmander"
	SceneManager.push_menu(dex)
	await wait_process_frames(3)
	assert_lte(dex.hint.position.x + dex.hint.size.x,256.0)
	SceneManager.pop_menu(dex)
	var generator := RandomlockeGeneratingScreen.new()
	SceneManager.push_menu(generator)
	await wait_process_frames(3)
	for node: Node in generator.canvas.get_children():
		if node is Label and node.text.begins_with("Preparando"):
			assert_lte(node.position.x + node.size.x,228.0)
			assert_lte(node.position.y + node.size.y,151.0)
	SceneManager.pop_menu(generator)
