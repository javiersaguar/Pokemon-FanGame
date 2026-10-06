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
	await wait_physics_frames(2)
	_press(&"accept")
	await wait_physics_frames(2)
	assert_true(GameState.always_run)
	assert_eq(runtime.toast.text, "Correr: activado")
	assert_true(runtime.toast.visible)
	assert_false(GameState.input_locked)
	_press(&"accept")
	await wait_physics_frames(2)
	assert_false(GameState.always_run)
	assert_eq(runtime.toast.text, "Correr: desactivado")
	_press(&"cancel")
	GameState.reset()
