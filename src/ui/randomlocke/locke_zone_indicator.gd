class_name LockeZoneIndicator
extends Control
var title: Label
var status_label: Label
const STATUS := {"available":"Disponible", "caught":"Capturada", "lost":"Perdida", "pending":"Pendiente"}
func _ready() -> void:
	position = Vector2(8,8)
	size = Vector2(240,34)
	mouse_filter = MOUSE_FILTER_IGNORE
	var panel := Panel.new()
	panel.size = size
	add_child(panel)
	var icon := Sprite2D.new()
	icon.texture = UiTextures.item(&"pokeball")
	icon.position = Vector2(17,17)
	icon.scale = Vector2(0.5,0.5)
	add_child(icon)
	title = Label.new()
	title.position = Vector2(34,2)
	title.size = Vector2(199,14)
	title.clip_text = true
	title.theme_type_variation = &"SmallLabel"
	add_child(title)
	status_label = Label.new()
	status_label.position = Vector2(34,17)
	status_label.size = Vector2(199,14)
	status_label.clip_text = true
	status_label.theme_type_variation = &"SmallLabel"
	add_child(status_label)
	hide()
func set_zone(name_text: String, status: String, limit: bool) -> void:
	title.text = name_text
	status_label.text = "Captura: %s" % STATUS.get(status,status) if limit else "Sin límite de captura por zona"
	status_label.add_theme_color_override(&"font_color", Color("b53134") if status == "lost" and limit else Color("256242"))
