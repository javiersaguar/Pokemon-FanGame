extends Node
## STUB PROVISIONAL creado por el Agente 1 para que el proyecto arranque.
## Dueño: Agente 3, que lo sustituye por la versión real (Fase 5.6).
## API mínima prevista (docs/contratos.md, sección Dialogue): cuadro de texto
## básico sin letra a letra. `accept` o `cancel` pasan; en ask(), arriba/abajo
## eligen y `cancel` elige la última opción.

signal _advanced(choice: int)

var is_open := false

var _panel: PanelContainer
var _text: Label
var _options_label: Label
var _options := PackedStringArray()
var _selected := 0
var _accepting := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var layer := CanvasLayer.new()
	layer.layer = 30
	add_child(layer)
	_panel = PanelContainer.new()
	_panel.theme = Theme.new()
	_panel.theme.default_font_size = 8
	_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_panel.offset_left = 4
	_panel.offset_right = -4
	_panel.offset_top = -52
	_panel.offset_bottom = -4
	layer.add_child(_panel)
	var box := VBoxContainer.new()
	_panel.add_child(box)
	_text = Label.new()
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_text)
	_options_label = Label.new()
	box.add_child(_options_label)
	_panel.hide()


## Muestra `text` y espera a que el jugador pase. `speaker`: nombre (String) o
## un objeto con `display_name`. Variables: {player}, {rival}.
func say(text: String, speaker: Variant = null) -> void:
	await _show(text, speaker, PackedStringArray())


## Pregunta con opciones. Devuelve el índice elegido (cancel = la última opción).
func ask(text: String, options: PackedStringArray, speaker: Variant = null) -> int:
	return await _show(text, speaker, options)


func _show(text: String, speaker: Variant, options: PackedStringArray) -> int:
	is_open = true
	GameState.lock_input(&"dialogue")
	EventBus.dialogue_started.emit()
	var speaker_name := _speaker_name(speaker)
	_text.text = (speaker_name + ": " if speaker_name != "" else "") + text.format({
		"player": GameState.player_name,
		"rival": GameState.rival_name,
	})
	_options = options
	_selected = 0
	_refresh_options()
	_panel.show()
	# Un frame de margen para que la misma pulsación que abrió el cuadro no lo cierre.
	await get_tree().process_frame
	_accepting = true
	var choice: int = await _advanced
	_panel.hide()
	is_open = false
	GameState.unlock_input(&"dialogue")
	EventBus.dialogue_finished.emit()
	return choice


func _unhandled_input(event: InputEvent) -> void:
	if not _accepting:
		return
	var last := maxi(_options.size() - 1, 0)
	if event.is_action_pressed(&"accept"):
		_finish(_selected)
	elif event.is_action_pressed(&"cancel"):
		_finish(last)
	elif not _options.is_empty() and event.is_action_pressed(&"move_up"):
		_selected = wrapi(_selected - 1, 0, _options.size())
		_refresh_options()
	elif not _options.is_empty() and event.is_action_pressed(&"move_down"):
		_selected = wrapi(_selected + 1, 0, _options.size())
		_refresh_options()
	else:
		return
	get_viewport().set_input_as_handled()


func _finish(choice: int) -> void:
	_accepting = false
	_advanced.emit(choice)


func _refresh_options() -> void:
	var lines := PackedStringArray()
	for i: int in _options.size():
		lines.append(("> " if i == _selected else "   ") + _options[i])
	_options_label.text = "\n".join(lines)
	_options_label.visible = not _options.is_empty()


static func _speaker_name(speaker: Variant) -> String:
	if speaker is String or speaker is StringName:
		return str(speaker)
	if speaker is Object and &"display_name" in speaker:
		return str(speaker.display_name)
	return ""
