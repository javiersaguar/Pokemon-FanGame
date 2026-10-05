extends CanvasLayer
## Aviso provisional con el Theme existente, fuera del tinte del mundo.
var label: Label
func _ready() -> void:
	layer = 32
	var canvas := UiCanvas.new()
	canvas.theme = load("res://src/ui/theme/main_theme.tres")
	add_child(canvas)
	var panel := PanelContainer.new()
	panel.position = Vector2(6, 6)
	canvas.add_child(panel)
	label = Label.new()
	panel.add_child(label)
func show_text(text: String) -> void:
	label.text = text
	show()
