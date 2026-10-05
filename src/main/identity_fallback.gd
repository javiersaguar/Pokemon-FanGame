extends CanvasLayer
## Entrada provisional: UiCanvas, cuadro y Theme existentes, teclado real.
## Cede el paso automáticamente a cualquier pantalla A3 conectada a la señal.
var kind: StringName
var initial := ""
signal completed(value: String)
var prompt := ""
var placeholder := "Escribe el nombre y pulsa Intro"
var allow_cancel := false
var submit: Callable
var _locked := false
var entry: LineEdit

func _ready() -> void:
	layer = 35
	var canvas := UiCanvas.new()
	canvas.theme = load("res://src/ui/theme/main_theme.tres")
	add_child(canvas)
	var panel := preload("res://src/ui/dialogue/dialogue_box.tscn").instantiate()
	canvas.add_child(panel)
	panel.set_process_input(false)
	panel.get_node("Frame/Text").visible_characters = -1
	panel.get_node("Frame/Text").text = prompt if not prompt.is_empty() else ("¿Cómo te llamas?" if kind == &"player" else "¿Cómo se llama tu rival?")
	entry = LineEdit.new()
	entry.position = Vector2(14, 165)
	entry.size = Vector2(224, 18)
	entry.text = initial
	entry.placeholder_text = placeholder
	entry.text_submitted.connect(_submit)
	canvas.add_child(entry)
	entry.grab_focus()
	entry.select_all()
	GameState.lock_input(&"name_entry")
	_locked = true

func _submit(text: String) -> void:
	var value := text.strip_edges()
	if value.is_empty():
		return
	var accepted: bool = submit.call(value) if submit.is_valid() else Cutscene.submit_name(kind, value)
	if accepted:
		_finish(value)

func _unhandled_input(event: InputEvent) -> void:
	if allow_cancel and event.is_action_pressed(&"cancel"):
		get_viewport().set_input_as_handled()
		_finish("")

func _finish(value: String) -> void:
	if _locked:
		GameState.unlock_input(&"name_entry")
		_locked = false
	completed.emit(value)
	queue_free()

func _exit_tree() -> void:
	if _locked:
		GameState.unlock_input(&"name_entry")
