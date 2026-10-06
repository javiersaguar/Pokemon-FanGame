class_name NameKeyboard
extends MenuScreen
## Teclado visible de nombres y entrada física opcional (Tab).
signal completed(value: String)
const LETTERS := "ABCDEFGHIJKLMNÑOPQRSTUVWXYZÁÉÍÓÚ0123456789-"
const ACTIONS := ["SP", "DEL", "CLR", "Aa", "OK", "X"]
var kind: StringName = &"text"
var initial := ""
var prompt := ""
var placeholder := "Escribe un nombre"
var allow_cancel := false
var max_length := 12
var entry: LineEdit
var _typing := false
var _upper := true
var _replace_initial := true
var _locked := false
var _done := false
var _active_frame := -1

static func ask(parent: Node, caption: String, value := "", can_cancel := false, limit := 12) -> String:
	var screen := NameKeyboard.new()
	screen.prompt = caption
	screen.initial = value
	screen.allow_cancel = can_cancel
	screen.max_length = limit
	parent.add_child(screen)
	var result: String = await screen.completed
	screen.queue_free()
	return result

func _ready() -> void:
	if not InputMap.has_action(&"ui_text_mode"):
		InputMap.add_action(&"ui_text_mode")
		var tab := InputEventKey.new()
		tab.keycode = KEY_TAB
		InputMap.action_add_event(&"ui_text_mode", tab)
	heading.text = prompt if not prompt.is_empty() else ("¿Cómo te llamas?" if kind == &"player" else "¿Cómo se llama tu rival?")
	heading.add_theme_font_size_override(&"font_size", 8)
	panel(Rect2(8, 32, 240, 27))
	entry = LineEdit.new()
	entry.position = Vector2(16, 35)
	entry.size = Vector2(224, 21)
	entry.max_length = max_length
	entry.text = initial.left(max_length)
	entry.placeholder_text = placeholder
	var empty := StyleBoxEmpty.new()
	entry.add_theme_stylebox_override(&"normal", empty)
	entry.add_theme_stylebox_override(&"focus", empty)
	entry.add_theme_color_override(&"font_color", Color("382a38"))
	entry.focus_mode = FOCUS_NONE
	entry.mouse_filter = MOUSE_FILTER_IGNORE
	entry.text_submitted.connect(submit_value)
	canvas.add_child(entry)
	var keys := PackedStringArray()
	for letter: String in LETTERS:
		keys.append(letter)
	keys.append_array(ACTIONS)
	menu = make_menu(keys, Rect2(12, 65, 236, 104), 10)
	for button: BattleButton in menu.get_children():
		button.custom_minimum_size.x = 20
		button.color = &"amarillo" if button.get_index() < 32 else (&"azul" if button.get_index() < LETTERS.length() else &"verde")
	menu.set_disabled(LETTERS.length() + ACTIONS.find("X"), not allow_cancel)
	hint.text = "SP: espacio  DEL: borrar  Tab: teclado  OK: listo"
	GameState.lock_input(&"name_entry")
	_locked = true
	_active_frame = Engine.get_process_frames()
	run.call_deferred()

func run() -> void:
	while is_inside_tree() and not _done:
		var choice := await menu.choose(-1, allow_cancel)
		if choice < 0 or choice == LETTERS.length() + ACTIONS.find("X"):
			if allow_cancel:
				_finish("")
				return
			continue
		var key: String = (menu.get_child(choice) as BattleButton).text
		match key:
			"OK": submit_value(entry.text)
			"DEL": entry.text = entry.text.left(maxi(entry.text.length() - 1, 0))
			"CLR": entry.text = ""
			"Aa":
				_upper = not _upper
				for i: int in LETTERS.length():
					(menu.get_child(i) as BattleButton).text = LETTERS[i] if _upper else LETTERS[i].to_lower()
			_:
				if _replace_initial:
					entry.text = ""
					_replace_initial = false
				entry.text = (entry.text + (" " if key == "SP" else key)).left(max_length)

func _input(event: InputEvent) -> void:
	if _done or Engine.get_process_frames() == _active_frame:
		return
	if event.is_action_pressed(&"ui_text_mode") and not event.is_echo():
		_typing = not _typing
		menu.is_choosing = not _typing
		menu._active_frame = Engine.get_process_frames()
		entry.focus_mode = FOCUS_ALL if _typing else FOCUS_NONE
		if _typing:
			entry.grab_focus()
			entry.select_all()
		else:
			entry.release_focus()
		get_viewport().set_input_as_handled()

func submit_value(text: String) -> void:
	var value := text.strip_edges().left(max_length)
	if value.is_empty():
		entry.placeholder_text = "El nombre no puede estar vacío"
		AudioManager.play_se(&"menu_error")
		return
	_finish(value)

func _finish(value: String) -> void:
	if _done:
		return
	_done = true
	if _locked:
		GameState.unlock_input(&"name_entry")
		_locked = false
	completed.emit(value)

func _exit_tree() -> void:
	if _locked:
		GameState.unlock_input(&"name_entry")
