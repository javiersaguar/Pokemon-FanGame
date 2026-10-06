extends GutTest
const SOURCE := 97
const DEST := 98
var main: Node
var old_slots: int
var old_speed: int
var screen: SaveSlotsScreen

func before_each() -> void:
	SaveManager.delete_save(SOURCE)
	SaveManager.delete_save(DEST)
	GameState.reset()
	old_slots = SaveManager.slot_count()
	old_speed = Dialogue.text_speed
	Dialogue.text_speed = 0
	Dialogue._box.text_speed = 0
	main = load("res://src/main/main.tscn").instantiate()
	main.set_script(null)
	add_child(main)
	SceneManager.register_main(main)

func after_each() -> void:
	Dialogue.text_speed = old_speed
	Dialogue._box.text_speed = old_speed
	GameState.world_config["saves"]["slots"] = old_slots
	SceneManager._leave_game()
	main.queue_free()
	SaveManager.delete_save(SOURCE)
	SaveManager.delete_save(DEST)
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

func answer(index: int) -> void:
	for frame: int in 90:
		await wait_process_frames(1)
		if Dialogue._choice.is_choosing:
			await wait_process_frames(2)
			Dialogue._choice._select(index)
			press(&"accept")
			await wait_process_frames(2)
			return
		if Dialogue._box.is_waiting:
			await wait_process_frames(2)
			press(&"accept")
	fail_test("No apareció la confirmación")

func fixture() -> void:
	GameState.world_config["saves"]["slots"] = DEST
	GameState.new_game({"slot": SOURCE})
	GameState.player_name = "Original"
	assert_eq(SaveManager.save_game(SOURCE), OK)
	GameState.player_name = "Destino"
	assert_eq(SaveManager.save_game(DEST), OK)
	GameState.slot = SOURCE
	GameState.player_name = "En curso"
	screen = SaveSlotsScreen.new()
	screen.start_slot = SOURCE
	SceneManager.ui_layer.add_child(screen)
	await wait_process_frames(3)

func test_default_screen_lists_eight_slots() -> void:
	GameState.world_config["saves"]["slots"] = 8
	screen = SaveSlotsScreen.new()
	SceneManager.ui_layer.add_child(screen)
	await wait_process_frames(2)
	assert_eq(screen.menu.get_child_count(), 8)
	assert_eq(screen._slots, [1, 2, 3, 4, 5, 6, 7, 8])
	assert_false(GameState.in_game)
	for button: BattleButton in screen.menu.get_children():
		assert_lte(button._label.get_minimum_size().y, button.size.y, "las dos líneas caben en la tarjeta")

func test_copy_confirms_overwrite_and_preserves_current_game() -> void:
	await fixture()
	press(&"menu")
	await answer(0)
	assert_eq(screen._copy_from, SOURCE)
	screen.menu.select(1)
	await wait_process_frames(2)
	press(&"accept")
	await answer(1) # No: no cambia el destino.
	assert_eq(SaveManager.slot_summary(DEST).player_name, "Destino")
	await wait_process_frames(2)
	screen.menu.select(1)
	press(&"accept")
	await answer(0)
	for frame: int in 40:
		await wait_process_frames(1)
		if Dialogue._box.is_waiting: press(&"accept")
		if screen._copy_from == 0: break
	assert_eq(SaveManager.slot_summary(DEST).player_name, "Original")
	assert_eq(GameState.player_name, "En curso")
	assert_eq(GameState.slot, SOURCE)

func test_delete_requires_both_confirmations() -> void:
	await fixture()
	press(&"menu")
	await answer(1)
	await answer(0)
	await answer(1)
	assert_true(SaveManager.has_save(SOURCE))
	await wait_process_frames(3)
	press(&"menu")
	await answer(1)
	await answer(0)
	await answer(0)
	await wait_process_frames(2)
	assert_false(SaveManager.has_save(SOURCE))
	assert_true(SaveManager.has_save(DEST))
	assert_true(screen.menu._is_disabled(0))

func test_finished_locke_cannot_be_selected_for_loading() -> void:
	await fixture()
	var rom := Randomizer.generate(42, RandomizerSettings.from_preset("clasico"))
	GameState.new_game({"slot": DEST, "mode": "randomlocke", "rom_patch": rom.to_dict(),
		"randomlocke": {"status": "finished", "settings": rom.data.settings}})
	assert_eq(SaveManager.save_game(DEST), OK)
	var name_before := GameState.player_name
	screen.menu._finish(-2)
	await wait_process_frames(3)
	screen.menu.select(1)
	assert_true(screen.menu._is_disabled(1))
	press(&"accept")
	await wait_process_frames(2)
	assert_false(screen._done)
	assert_eq(GameState.player_name, name_before)
