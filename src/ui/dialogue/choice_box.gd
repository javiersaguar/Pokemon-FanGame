class_name ChoiceBox
extends PanelContainer
## Lista vertical de opciones con cursor (Sí/No y menús de Dialogue.ask()).
## Se coloca con su esquina inferior derecha en `anchor_point`.

signal _chosen(index: int)

const ROW_HEIGHT := 16

## Esquina inferior derecha del cuadro, en píxeles de la pantalla base.
@export var anchor_point := Vector2(316, 132)

var is_choosing := false
var selected := 0

var _cancel_choice := -1
var _active_frame := -1

@onready var _options_box: VBoxContainer = $Row/Options
@onready var _cursor: CursorArrow = $Row/CursorColumn/Cursor


func _ready() -> void:
	hide()


func _input(event: InputEvent) -> void:
	if not is_choosing or Engine.get_process_frames() == _active_frame:
		return
	var count := _options_box.get_child_count()
	if event.is_action_pressed(&"move_up", true):
		_select(wrapi(selected - 1, 0, count))
	elif event.is_action_pressed(&"move_down", true):
		_select(wrapi(selected + 1, 0, count))
	elif event.is_action_pressed(&"accept"):
		AudioManager.play_se(&"menu_accept")
		_finish(selected)
	elif event.is_action_pressed(&"cancel"):
		if _cancel_choice < 0:
			return
		AudioManager.play_se(&"menu_cancel")
		_finish(_cancel_choice)
	else:
		return
	get_viewport().set_input_as_handled()


## Muestra `options` y espera a que el jugador elija. Devuelve el índice.
## `cancel_choice` < 0 = `cancel` no hace nada.
func choose(options: PackedStringArray, cancel_choice: int = -1, start: int = 0) -> int:
	if options.is_empty():
		push_error("ChoiceBox.choose: no hay opciones.")
		return -1
	for child: Node in _options_box.get_children():
		_options_box.remove_child(child)
		child.queue_free()
	for option: String in options:
		var label := Label.new()
		label.text = option
		label.custom_minimum_size.y = ROW_HEIGHT
		_options_box.add_child(label)
	_cancel_choice = cancel_choice
	reset_size()
	position = (anchor_point - get_combined_minimum_size()).round()
	_select(clampi(start, 0, options.size() - 1), false)
	show()
	is_choosing = true
	_active_frame = Engine.get_process_frames()
	var index: int = await _chosen
	hide()
	return index


func _select(index: int, play_sound: bool = true) -> void:
	if play_sound and index != selected:
		AudioManager.play_se(&"menu_move")
	selected = index
	_cursor.position = Vector2(0, index * ROW_HEIGHT + (ROW_HEIGHT - _cursor.size.y) / 2.0).round()


func _finish(index: int) -> void:
	is_choosing = false
	_chosen.emit(index)
