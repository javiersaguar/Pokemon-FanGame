extends GutTest
const SLOT := 98
var main: Node

func before_each() -> void:
	GameState.reset()
	SaveManager.delete_save(SLOT)
	main = load("res://src/main/main.tscn").instantiate()
	main.set_script(null)
	add_child(main)
	SceneManager.register_main(main)

func after_each() -> void:
	SceneManager._leave_game()
	main.queue_free()
	SaveManager.delete_save(SLOT)
	await wait_physics_frames(2)
	SceneManager.world = null
	SceneManager.ui_layer = null
	SceneManager.battle_layer = null
	SceneManager.transition_layer = null
	SceneManager._fade = null

func press(action: StringName) -> void:
	for down: bool in [true, false]:
		var event := InputEventAction.new()
		event.action = action
		event.pressed = down
		Input.parse_input_event(event)

func test_first_splash_notice_intro_title_and_menu() -> void:
	var screen := TitleScreen.new()
	SceneManager.ui_layer.add_child(screen)
	screen._seen = false
	await wait_process_frames(2)
	press(&"accept")
	await wait_process_frames(2)
	assert_eq(screen.stage, &"splash", "el primer splash no se salta")
	screen._process(1.6)
	assert_eq(screen.stage, &"notice")
	await wait_process_frames(2)
	press(&"accept")
	await wait_process_frames(2)
	assert_eq(screen.stage, &"intro")
	press(&"accept")
	await wait_process_frames(2)
	assert_eq(screen.stage, &"title")
	assert_true(screen._seen)
	assert_true(screen.footer.text.begins_with("Realizado por Javier Saguar"))
	assert_string_contains(screen.footer.text, str(ProjectSettings.get_setting("application/config/version")))
	press(&"accept")
	await wait_process_frames(2)
	assert_eq(screen.stage, &"menu")
	assert_eq(screen.menu.get_child_count(), 6)
	press(&"cancel")
	await wait_process_frames(2)
	assert_eq(screen.stage, &"title")

func test_continue_releases_title_and_restores_game() -> void:
	await SceneManager.start_new_game(&"", &"", {"slot": SLOT})
	GameState.player_name = "Javi"
	GameState.set_flag(&"story_intro_done")
	assert_eq(SaveManager.save_game(SLOT), OK)
	await SceneManager.go_to_title()
	var title: TitleScreen = SceneManager._title
	title.set_stage(&"menu")
	await wait_physics_frames(2)
	title.menu.select(0)
	press(&"accept")
	for i: int in 60:
		await wait_physics_frames(1)
		if GameState.in_game and not SceneManager.is_busy():
			break
	assert_true(GameState.in_game)
	assert_eq(GameState.player_name, "Javi")
	assert_eq(GameState.slot, SLOT)
	assert_false(is_instance_valid(title))
	assert_false(GameState.input_locked)

func test_credits_include_authors_and_license_from_file() -> void:
	var credits := CreditsScreen.new()
	add_child_autofree(credits)
	assert_eq(credits.heading.text, "Juego realizado por Javier Saguar")
	assert_string_contains(credits.body.text, "bonzairob")
	assert_string_contains(credits.body.text, "MIT")
	assert_string_contains(credits.body.text, "Caruban")

func test_options_returns_to_title_menu_with_author_footer() -> void:
	await SceneManager.go_to_title()
	var title: TitleScreen = SceneManager._title
	title.set_stage(&"menu")
	await wait_physics_frames(2)
	title.menu.select(3)
	press(&"accept")
	await wait_physics_frames(2)
	assert_true(title._subscreen is OptionsScreen)
	var found_footer := false
	for node: Node in title._subscreen.canvas.get_children():
		if node is Label and node.text.begins_with("Realizado por Javier Saguar"):
			found_footer = true
	assert_true(found_footer)
	press(&"cancel")
	await wait_physics_frames(3)
	assert_null(title._subscreen)
	assert_true(title.menu.is_choosing)
