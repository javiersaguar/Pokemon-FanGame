class_name CreditsScreen
extends MenuScreen
var body: RichTextLabel
var _scroll := 0.0
var _paused := false
var _active_frame := -1

func _ready() -> void:
	heading.text = "Juego realizado por Javier Saguar"
	heading.add_theme_font_size_override(&"font_size", 8)
	hint.text = "Arriba/Abajo: texto / A: pausar / B: volver"
	panel(Rect2(8, 32, 240, 136))
	body = RichTextLabel.new()
	body.position = Vector2(16, 39)
	body.size = Vector2(224, 112)
	body.add_theme_font_size_override(&"normal_font_size", 8)
	body.text = credits_text()
	canvas.add_child(body)
	_active_frame = Engine.get_process_frames()

static func credits_text() -> String:
	var lines := PackedStringArray()
	for line: String in FileAccess.get_file_as_string("res://CREDITOS.md").split("\n"):
		if line.begins_with(">") or line.begins_with("|---") or line == "# Créditos":
			continue
		lines.append(line.replace("—", "-").replace("#", "").replace("**", "").replace("`", "").replace("|", " / ").strip_edges())
	return "\n".join(lines)

func _process(delta: float) -> void:
	if not _paused and not UiPreferences.reduce_motion():
		_scroll += delta * 6.0
		body.get_v_scroll_bar().value = floor(_scroll)

func _unhandled_input(event: InputEvent) -> void:
	if Engine.get_process_frames() == _active_frame:
		return
	if event.is_action_pressed(&"cancel"):
		closed.emit()
	elif event.is_action_pressed(&"accept"):
		_paused = not _paused
	elif event.is_action_pressed(&"move_down", true) or event.is_action_pressed(&"move_up", true):
		_scroll = clampf(_scroll + (20 if event.is_action_pressed(&"move_down", true) else -20), 0, body.get_v_scroll_bar().max_value)
		body.get_v_scroll_bar().value = _scroll
	else:
		return
	get_viewport().set_input_as_handled()
