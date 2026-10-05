extends CanvasLayer
## Entrada provisional: UiCanvas, cuadro y Theme existentes, teclado real.
## Cede el paso automáticamente a cualquier pantalla A3 conectada a la señal.
var kind: StringName
var initial := ""
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
	panel.get_node("Frame/Text").text = "¿Cómo te llamas?" if kind == &"player" else "¿Cómo se llama tu rival?"
	entry = LineEdit.new()
	entry.position = Vector2(14, 165)
	entry.size = Vector2(224, 18)
	entry.text = initial
	entry.placeholder_text = "Escribe el nombre y pulsa Intro"
	entry.text_submitted.connect(_submit)
	canvas.add_child(entry)
	entry.grab_focus()
	entry.select_all()
	GameState.lock_input(&"name_entry")

func _submit(text: String) -> void:
	if Cutscene.submit_name(kind, text):
		GameState.unlock_input(&"name_entry")
		queue_free()
