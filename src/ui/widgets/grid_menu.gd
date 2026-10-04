class_name GridMenu
extends GridContainer
## Menú en rejilla navegable con teclado o mando (cruceta, accept, cancel).
## Sirve para listas de una columna (pausa) y rejillas 2×2 (combate). La
## flecha se dibuja a la izquierda de la opción elegida, fuera de la rejilla:
## deja unos píxeles de margen a la izquierda del nodo.

signal selection_changed(index: int)
signal _chosen(index: int)

const CANCELLED := -1
const CURSOR_GAP := 8

## false = sin flecha: la opción elegida se marca sola (los BattleButton cambian de aspecto).
@export var show_cursor := true
## Flecha clara (sobre paneles oscuros).
@export var light_cursor := false

var selected := 0
var is_choosing := false
## Opciones desactivadas: se pueden señalar, pero al aceptar suena error.
var disabled: Array[bool] = []

var _allow_cancel := true
var _active_frame := -1


func _ready() -> void:
	sort_children.connect(queue_redraw)


func _input(event: InputEvent) -> void:
	if not is_choosing or Engine.get_process_frames() == _active_frame:
		return
	var count := get_child_count()
	var cols := maxi(columns, 1)
	var target := selected
	if event.is_action_pressed(&"move_up", true):
		target = selected - cols
	elif event.is_action_pressed(&"move_down", true):
		target = selected + cols
	elif event.is_action_pressed(&"move_left", true) and cols > 1:
		target = selected - 1 if selected % cols > 0 else selected
	elif event.is_action_pressed(&"move_right", true) and cols > 1:
		target = selected + 1 if selected % cols < cols - 1 else selected
	elif event.is_action_pressed(&"accept"):
		get_viewport().set_input_as_handled()
		if _is_disabled(selected):
			AudioManager.play_se(&"menu_error")
			return
		AudioManager.play_se(&"menu_accept")
		_finish(selected)
		return
	elif event.is_action_pressed(&"cancel"):
		get_viewport().set_input_as_handled()
		if _allow_cancel:
			AudioManager.play_se(&"menu_cancel")
			_finish(CANCELLED)
		return
	else:
		return
	get_viewport().set_input_as_handled()
	if cols == 1:
		target = wrapi(target, 0, count)
	if target >= 0 and target < count and target != selected:
		select(target)
		AudioManager.play_se(&"menu_move")


## Sustituye las opciones por etiquetas con `texts`.
func set_items(texts: PackedStringArray, label_type: StringName = &"") -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	for text: String in texts:
		var label := Label.new()
		label.text = text
		if label_type != &"":
			label.theme_type_variation = label_type
		add_child(label)
	disabled.clear()
	disabled.resize(texts.size())
	disabled.fill(false)
	selected = clampi(selected, 0, maxi(texts.size() - 1, 0))
	queue_redraw()


func set_item_text(index: int, text: String) -> void:
	(get_child(index) as Label).text = text


func select(index: int) -> void:
	selected = clampi(index, 0, maxi(get_child_count() - 1, 0))
	for i: int in get_child_count():
		var child := get_child(i)
		if child.has_method(&"set_focused"):
			child.set_focused(i == selected)
	queue_redraw()
	selection_changed.emit(selected)


## Marca la opción `index` como desactivada (y lo muestra si es un BattleButton).
func set_disabled(index: int, value: bool) -> void:
	if disabled.size() < get_child_count():
		disabled.resize(get_child_count())
	disabled[index] = value
	var child := get_child(index)
	if child.has_method(&"set_disabled"):
		child.set_disabled(value)


func _is_disabled(index: int) -> bool:
	return index < disabled.size() and disabled[index]


## Espera a que el jugador elija. Devuelve el índice o CANCELLED (−1).
func choose(start: int = -1, allow_cancel: bool = true) -> int:
	if get_child_count() == 0:
		push_error("GridMenu.choose: el menú no tiene opciones.")
		return CANCELLED
	_allow_cancel = allow_cancel
	select(selected if start < 0 else start)
	is_choosing = true
	_active_frame = Engine.get_process_frames()
	queue_redraw()
	return await _chosen


func _finish(index: int) -> void:
	is_choosing = false
	_chosen.emit(index)


func _draw() -> void:
	if not show_cursor or get_child_count() == 0 or not visible:
		return
	var item := get_child(selected) as Control
	if item == null:
		return
	var origin := item.position + Vector2(-CURSOR_GAP, (item.size.y - 8.0) / 2.0)
	CursorArrow.draw_arrow(self, origin.round(), CursorArrow.Direction.RIGHT, light_cursor)
