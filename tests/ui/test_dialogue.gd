extends GutTest
## Tests del autoload Dialogue y del DialogueBox (contratos.md §9.1).

const BOX_SCENE := preload("res://src/ui/dialogue/dialogue_box.tscn")
const MAIN_THEME := preload("res://src/ui/theme/main_theme.tres")

var _saved_speed: int


func before_each() -> void:
	_saved_speed = Dialogue.text_speed
	Dialogue.text_speed = 0
	GameState.reset()
	GameState.player_name = "Rojo"
	GameState.rival_name = "Azul"


func after_each() -> void:
	Dialogue.text_speed = _saved_speed
	GameState.clear_input_locks()


func _press(action: StringName) -> void:
	var down := InputEventAction.new()
	down.action = action
	down.pressed = true
	Input.parse_input_event(down)
	var up := InputEventAction.new()
	up.action = action
	up.pressed = false
	Input.parse_input_event(up)


func test_format_text_replaces_player_rival_and_vars() -> void:
	var text := Dialogue.format_text("{player} y {rival} miran la {item}.", {"item": "Poción"})
	assert_eq(text, "Rojo y Azul miran la Poción.")


func test_say_locks_input_until_player_advances() -> void:
	var state := {"done": false}
	var talk := func() -> void:
		await Dialogue.say("Hola, {player}.")
		state["done"] = true
	talk.call()
	await wait_physics_frames(2)
	assert_true(Dialogue.is_open, "is_open mientras se muestra")
	assert_true(GameState.is_input_locked_by(&"dialogue"), "bloquea el input")
	assert_false(state["done"], "espera al jugador")
	_press(&"accept")
	await wait_physics_frames(3)
	assert_true(state["done"], "accept pasa la línea")
	assert_false(Dialogue.is_open)
	assert_false(GameState.is_input_locked_by(&"dialogue"), "desbloquea al cerrar")


func test_say_emits_started_and_finished_once_for_consecutive_lines() -> void:
	watch_signals(EventBus)
	var talk := func() -> void:
		await Dialogue.say("Primera línea.")
		await Dialogue.say("Segunda línea.")
	talk.call()
	await wait_physics_frames(2)
	_press(&"accept")
	await wait_physics_frames(2)
	assert_true(Dialogue.is_open, "la segunda línea sigue en el cuadro")
	_press(&"cancel")
	await wait_physics_frames(3)
	assert_false(Dialogue.is_open)
	assert_signal_emit_count(EventBus, "dialogue_started", 1)
	assert_signal_emit_count(EventBus, "dialogue_finished", 1)


func test_ask_returns_selected_option() -> void:
	var state := {"choice": -99}
	var question := func() -> void:
		state["choice"] = await Dialogue.ask("¿Cuál?", PackedStringArray(["Uno", "Dos", "Tres"]))
	question.call()
	await wait_physics_frames(2)
	_press(&"move_down")
	await wait_physics_frames(1)
	_press(&"move_down")
	await wait_physics_frames(1)
	_press(&"accept")
	await wait_physics_frames(3)
	assert_eq(state["choice"], 2)


func test_ask_cancel_returns_last_option_by_default() -> void:
	var state := {"choice": -99}
	var question := func() -> void:
		state["choice"] = await Dialogue.ask("¿Seguro?", PackedStringArray(["Sí", "No"]))
	question.call()
	await wait_physics_frames(2)
	_press(&"cancel")
	await wait_physics_frames(3)
	assert_eq(state["choice"], 1)


func test_ask_with_no_cancel_ignores_cancel() -> void:
	var state := {"choice": -99}
	var question := func() -> void:
		state["choice"] = await Dialogue.ask("Elige.", PackedStringArray(["A", "B"]), null,
				Dialogue.NO_CANCEL)
	question.call()
	await wait_physics_frames(2)
	_press(&"cancel")
	await wait_physics_frames(2)
	assert_eq(state["choice"], -99, "cancel no hace nada")
	_press(&"accept")
	await wait_physics_frames(3)
	assert_eq(state["choice"], 0)


func test_ask_yes_no() -> void:
	var state := {"answer": null}
	var question := func() -> void:
		state["answer"] = await Dialogue.ask_yes_no("¿Eliges a Bulbasaur?")
	question.call()
	await wait_physics_frames(2)
	_press(&"accept")
	await wait_physics_frames(3)
	assert_eq(state["answer"], true)


func test_long_text_is_split_in_pages() -> void:
	var box: DialogueBox = BOX_SCENE.instantiate()
	var root := Control.new()
	root.theme = MAIN_THEME
	root.add_child(box)
	add_child_autofree(root)
	await wait_physics_frames(1)
	assert_eq(box.count_pages("Hola."), 1)
	var long_text := "Esto es un texto muy largo que no cabe en dos líneas del cuadro de diálogo, " \
			+ "así que tiene que repartirse en varias páginas para que se pueda leer entero."
	var pages := box.count_pages(long_text)
	assert_gt(pages, 1)
	var line_height := 16
	assert_true(box._label.get_content_height() >= pages * DialogueBox.LINES_PER_PAGE * line_height,
		"hay relleno para que la última página quede sola arriba")


func test_text_is_typed_letter_by_letter_and_accept_completes_it() -> void:
	Dialogue.text_speed = 10
	var talk := func() -> void:
		await Dialogue.say("Un texto que tarda un rato en escribirse.")
	talk.call()
	await wait_physics_frames(3)
	var label: RichTextLabel = Dialogue._box._label
	assert_true(Dialogue._box.is_typing, "está escribiendo")
	assert_lt(label.visible_characters, label.get_total_character_count())
	_press(&"accept")
	await wait_physics_frames(2)
	assert_false(Dialogue._box.is_typing, "accept completa la página")
	assert_true(Dialogue._box.is_waiting, "y espera a que se pase")
	_press(&"accept")
	await wait_physics_frames(3)
	assert_false(Dialogue.is_open)


class FakeSpeaker:
	var display_name := "Profesor {rival}"


func test_speaker_name_from_object_with_display_name() -> void:
	var talk := func() -> void:
		await Dialogue.say("Bienvenido.", FakeSpeaker.new())
	talk.call()
	await wait_physics_frames(2)
	var plate: Label = Dialogue._box.get_node(^"NamePlate/Name")
	assert_eq(plate.text, "Profesor Azul")
	assert_true(plate.get_parent().visible, "el nombre se ve")
	_press(&"accept")
	await wait_physics_frames(3)
