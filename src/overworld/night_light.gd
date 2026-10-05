@tool
class_name NightLight
extends PointLight2D
## A4 aporta textura de luz y sitúa el foco; no genera una imagen por código.
@export var active_periods: PackedStringArray = ["evening", "night"]
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	EventBus.time_period_changed.connect(_period_changed)
	_period_changed(Clock.period())
func _period_changed(period: StringName) -> void:
	enabled = texture != null and String(period) in active_periods
