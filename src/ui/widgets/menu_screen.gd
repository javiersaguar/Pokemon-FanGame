class_name MenuScreen
extends Control
## Base de las pantallas: marco existente, controles por teclado/mando y UI ×2.
signal closed
var canvas: UiCanvas
var heading: Label
var hint: Label
var menu: GridMenu

func _init() -> void:
	theme = preload("res://src/ui/theme/main_theme.tres")
	mouse_filter = MOUSE_FILTER_IGNORE
	canvas = UiCanvas.new()
	add_child(canvas)
	fill(Rect2(0, 0, 256, 192), Color("4592ca"))
	fill(Rect2(0, 0, 256, 27), Color("f0b030"))
	fill(Rect2(0, 174, 256, 18), Color("80342e"))
	heading = label("", Rect2(12, 5, 232, 20), Color("382a38"))
	hint = label("Z / A: aceptar    X / B: volver", Rect2(8, 176, 240, 14), Color("fff4d8"), 8)

func fill(rect: Rect2, color: Color) -> ColorRect:
	var block := ColorRect.new()
	block.position = rect.position
	block.size = rect.size
	block.color = color
	block.mouse_filter = MOUSE_FILTER_IGNORE
	canvas.add_child(block)
	return block

func label(text: String, rect: Rect2, color := Color("fff4d8"), font_size := 10) -> Label:
	var out := Label.new()
	out.text = text
	out.position = rect.position
	out.size = rect.size
	out.add_theme_color_override(&"font_color", color)
	out.add_theme_font_size_override(&"font_size", font_size)
	out.mouse_filter = MOUSE_FILTER_IGNORE
	canvas.add_child(out)
	return out

func panel(rect: Rect2) -> PanelContainer:
	var out := PanelContainer.new()
	out.position = rect.position
	out.size = rect.size
	out.mouse_filter = MOUSE_FILTER_IGNORE
	canvas.add_child(out)
	return out

func make_menu(texts: PackedStringArray, rect: Rect2, columns := 1) -> GridMenu:
	var out := GridMenu.new()
	out.position = rect.position
	out.size = rect.size
	out.columns = columns
	out.show_cursor = false
	out.add_theme_constant_override(&"v_separation", 3)
	out.add_theme_constant_override(&"h_separation", 4)
	canvas.add_child(out)
	for i: int in texts.size():
		var button := BattleButton.new()
		button.text = texts[i]
		button.color = [&"amarillo", &"verde", &"azul", &"rojo"][i % 4]
		button.custom_minimum_size = Vector2(rect.size.x / columns - 4, 18)
		out.add_child(button)
	return out
