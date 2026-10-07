extends GutTest

func _press(action: StringName) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	Input.parse_input_event(event)
	var release := event.duplicate() as InputEventAction
	release.pressed = false
	Input.parse_input_event(release)

func test_run_option_updates_state_and_notice_without_locking() -> void:
	GameState.reset()
	var runtime := UiRuntime.new()
	add_child_autofree(runtime)
	var screen := OptionsScreen.new()
	add_child_autofree(screen)
	await wait_process_frames(3)
	_press(&"accept")
	await wait_process_frames(3)
	assert_true(GameState.always_run)
	assert_eq(runtime.toast.text, "Correr: activado")
	assert_true(runtime.toast.visible)
	assert_false(GameState.input_locked)
	_press(&"accept")
	await wait_process_frames(3)
	assert_false(GameState.always_run)
	assert_eq(runtime.toast.text, "Correr: desactivado")
	_press(&"cancel")
	await wait_process_frames(3)
	GameState.reset()

func test_preferences_apply_audio_text_frame_and_preserve_other_ui_config() -> void:
	UiPreferences.initialize()
	var before := UiPreferences.values.duplicate(true)
	var config := ConfigFile.new()
	config.load("user://ui.cfg")
	var seen: bool = config.get_value("title","seen",false)
	UiPreferences.set_value("text_speed",80)
	UiPreferences.set_value("SE",0.0)
	UiPreferences.set_value("frame",1)
	assert_eq(Dialogue.text_speed,80)
	assert_eq(AudioManager.get_volume(&"SE"),0.0)
	var style := (load("res://src/ui/theme/main_theme.tres") as Theme).get_stylebox(&"panel",&"Panel") as StyleBoxTexture
	assert_eq(style.texture.resource_path,"res://assets/sprites/ui/battle/button_amarillo.png")
	config.load("user://ui.cfg")
	assert_eq(config.get_value("options","text_speed"),80)
	assert_eq(config.get_value("title","seen",false),seen)
	for key: String in before: UiPreferences.set_value(key,before[key])
func test_battle_style_is_saved_with_game_and_prepared_before_locke_rules() -> void:
	GameState.reset()
	UiPreferences.initialize()
	var before: String = UiPreferences.values.battle_style
	GameState.in_game = true
	UiPreferences.set_value("battle_style","shift")
	assert_eq(GameState.var_str(&"battle_style"),"shift")
	var state := GameState.to_dict()
	GameState.party.add(Pokemon.create(&"charmander",5))
	var setup := BattleSetup.wild(Pokemon.create(&"pidgey",3))
	assert_eq(SceneManager.prepare_battle(setup),setup)
	assert_eq(setup.battle_style,&"shift")
	GameState.reset()
	GameState.from_dict(state)
	assert_eq(UiPreferences.battle_style(),&"shift")
	var config := RandomizerSettings.from_preset("clasico").to_dict()
	config.fixed_battle = true
	var rules := LockeRules.new(config,{},[])
	GameState.randomlocke = {"snapshot":rules.snapshot()}
	GameState.mode = GameState.MODE_RANDOMLOCKE
	GameState.locke = WorldLocke.new(GameState.randomlocke)
	var wrapped: Variant = SceneManager.prepare_battle(setup,{"zone_id":"fixture"})
	assert_true(wrapped is LockeBattleDriver)
	assert_eq(setup.battle_style,&"fixed","Locke fuerza Fijo tras aplicar preferencia")
	GameState.reset()
	UiPreferences.set_value("battle_style",before)

func test_reduced_animation_choice_keeps_text_speed_and_battle_time_zero() -> void:
	UiPreferences.initialize()
	var before := UiPreferences.values.duplicate(true)
	UiPreferences.set_value("reduce_animations", false)
	UiPreferences.set_value("text_speed", 40)
	var screen := OptionsScreen.new()
	add_child_autofree(screen)
	await wait_process_frames(3)
	_press(&"move_right")
	await wait_process_frames(3)
	assert_eq(screen.page, 1, "La flecha cambia la página")
	for i: int in 4:
		_press(&"move_down")
		await wait_process_frames(3)
	_press(&"accept")
	await wait_process_frames(3)
	assert_eq(screen.menu.selected, 4)
	assert_true(UiPreferences.reduce_motion())
	assert_eq(Dialogue.text_speed, 40)
	var config := ConfigFile.new()
	config.load("user://ui.cfg")
	assert_true(config.get_value("options", "reduce_animations", false))
	var battle := preload("res://src/battle/scene/battle_scene.tscn").instantiate()
	add_child_autofree(battle)
	assert_false(battle.fast)
	assert_eq(battle._t(0.65), 0.0)
	_press(&"cancel")
	await wait_process_frames(3)
	for key: String in before: UiPreferences.set_value(key, before[key])
