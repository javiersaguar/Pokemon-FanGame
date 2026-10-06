class_name QuantityPicker
extends MenuScreen
signal chosen(quantity: int)
var maximum := 1
var quantity := 1
var caption := "Cantidad"
var unit_price := 0
var _value: Label
var _active_frame := 0
var _done := false

static func pick(title: String, limit: int, price := 0) -> int:
	if limit < 1: return 0
	var screen := QuantityPicker.new()
	screen.caption = title
	screen.maximum = limit
	screen.unit_price = price
	SceneManager.push_menu(screen)
	var result: int = await screen.chosen
	SceneManager.pop_menu(screen)
	return result

func _ready() -> void:
	heading.text = caption
	panel(Rect2(24, 51, 208, 99))
	_value = label("", Rect2(34, 67, 188, 68), Color("382a38"))
	_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.text = "Izq/Der: 1 / Arriba/Abajo: 10 / A: elegir / B: volver"
	_update()
	_active_frame = Engine.get_process_frames()

func _update() -> void:
	_value.text = "%d / %d" % [quantity, maximum]
	if unit_price > 0: _value.text += "\nTotal: %d ₽" % (unit_price * quantity)

func _unhandled_input(event: InputEvent) -> void:
	if _done or Engine.get_process_frames() <= _active_frame + 1: return
	var delta := 0
	if event.is_action_pressed(&"move_right"): delta = 1
	elif event.is_action_pressed(&"move_left"): delta = -1
	elif event.is_action_pressed(&"move_up"): delta = 10
	elif event.is_action_pressed(&"move_down"): delta = -10
	elif event.is_action_pressed(&"accept") or event.is_action_pressed(&"cancel"):
		_done = true
		chosen.emit(quantity if event.is_action_pressed(&"accept") else 0)
	else: return
	if delta:
		quantity = clampi(quantity + delta, 1, maximum)
		_update()
		AudioManager.play_se(&"cursor")
	get_viewport().set_input_as_handled()
