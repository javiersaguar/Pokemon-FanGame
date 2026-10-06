extends GutTest
var screen: NameKeyboard
var result: Array[String]

func before_each() -> void:
	GameState.reset()
	result = []
	screen = NameKeyboard.new()
	screen.initial = "POR DEFINIR"
	add_child_autofree(screen)
	screen.completed.connect(func(value: String) -> void: result.append(value))

func press(action: StringName) -> void:
	for down: bool in [true, false]:
		var event := InputEventAction.new()
		event.action = action
		event.pressed = down
		Input.parse_input_event(event)

func choose(index: int) -> void:
	await wait_process_frames(2)
	screen.menu.select(index)
	press(&"accept")
	await wait_process_frames(2)

func test_onscreen_keyboard_replaces_initial_and_changes_case() -> void:
	assert_true(GameState.input_locked)
	await choose(1)
	assert_eq(screen.entry.text, "B")
	await choose(NameKeyboard.LETTERS.length() + NameKeyboard.ACTIONS.find("Aa"))
	await choose(0)
	assert_eq(screen.entry.text, "Ba")
	await choose(NameKeyboard.LETTERS.length() + NameKeyboard.ACTIONS.find("OK"))
	assert_eq(result, ["Ba"])
	assert_false(GameState.input_locked)

func test_required_name_rejects_empty_and_cancel_then_limits_length() -> void:
	await wait_process_frames(2)
	screen.submit_value("  ")
	press(&"cancel")
	await wait_process_frames(2)
	assert_true(result.is_empty())
	assert_true(GameState.input_locked)
	screen.submit_value("  ÁÑ1234567890123456  ")
	assert_eq(result, ["ÁÑ1234567890"])
	assert_false(GameState.input_locked)

func test_native_keyboard_can_type_action_letters_without_selecting_a_key() -> void:
	await wait_process_frames(2)
	for down: bool in [true, false]:
		var tab := InputEventKey.new()
		tab.keycode = KEY_TAB
		tab.pressed = down
		Input.parse_input_event(tab)
	await wait_process_frames(2)
	assert_true(screen.entry.has_focus())
	assert_false(screen.menu.is_choosing)
	for down: bool in [true, false]:
		var key := InputEventKey.new()
		key.keycode = KEY_Z
		key.unicode = 90
		key.pressed = down
		Input.parse_input_event(key)
	await wait_process_frames(2)
	assert_eq(screen.entry.text, "Z")
	assert_true(result.is_empty())
	screen.submit_value(screen.entry.text)
	assert_eq(result, ["Z"])
