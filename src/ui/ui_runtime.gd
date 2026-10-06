class_name UiRuntime
extends Control
## Avisos y peticiones de UI que deben vivir también fuera del menú inicial.
var canvas: UiCanvas
var toast: Label
var _remaining := 0.0

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	theme = preload("res://src/ui/theme/main_theme.tres")
	canvas = UiCanvas.new()
	add_child(canvas)
	toast = Label.new()
	toast.position = Vector2(8, 8)
	toast.size = Vector2(240, 18)
	toast.add_theme_color_override(&"font_color", Color("fff4d8"))
	toast.add_theme_color_override(&"font_shadow_color", Color("382a38"))
	toast.add_theme_constant_override(&"shadow_offset_x", 1)
	toast.add_theme_constant_override(&"shadow_offset_y", 1)
	toast.mouse_filter = MOUSE_FILTER_IGNORE
	canvas.add_child(toast)
	toast.hide()
	EventBus.always_run_changed.connect(_run_changed)

func _run_changed(enabled: bool) -> void:
	toast.text = "Correr: %s" % ("activado" if enabled else "desactivado")
	toast.show()
	_remaining = 2.0
	# Los menús se añaden después: el aviso debe seguir siendo legible encima.
	get_parent().move_child(self, -1)

func _process(delta: float) -> void:
	_remaining -= delta
	if _remaining <= 0.0:
		toast.hide()
