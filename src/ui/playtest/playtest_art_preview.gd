class_name PlaytestArtPreview
extends PanelContainer
signal closed
var asset_path := ""
var caption := ""
func _ready() -> void:
	position = Vector2(8,8)
	size = Vector2(496,368)
	theme = PlaytestPicker.menu_theme()
	var box := VBoxContainer.new()
	add_child(box)
	var title := Label.new()
	title.text = caption+" · provisional"
	box.add_child(title)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(scroll)
	var art := TextureRect.new()
	art.texture_filter = Control.TEXTURE_FILTER_NEAREST
	art.texture = load(asset_path)
	scroll.add_child(art)
	var back := Button.new()
	back.text = "Volver / B"
	back.pressed.connect(func() -> void: closed.emit())
	box.add_child(back)
	back.grab_focus()
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"cancel"):
		get_viewport().set_input_as_handled()
		closed.emit()
