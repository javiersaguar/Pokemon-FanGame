class_name HpBar
extends Control
## Barra de PS (verde → amarilla → roja) o de experiencia (azul), dibujada a píxel.

signal value_changed(ratio: float)

## Barra de experiencia: siempre azul y sin borde.
@export var exp_mode := false

var ratio := 1.0:
	set(value):
		ratio = clampf(value, 0.0, 1.0)
		queue_redraw()
		value_changed.emit(ratio)

var _tween: Tween


## Anima la barra hasta `target` en `duration` segundos (se puede esperar).
func animate_to(target: float, duration: float) -> void:
	if _tween:
		_tween.kill()
	if duration <= 0.0 or is_equal_approx(target, ratio):
		ratio = target
		return
	_tween = create_tween()
	_tween.tween_property(self, ^"ratio", target, duration)
	await _tween.finished


func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	if exp_mode:
		draw_rect(rect, UiColors.BAR_BACK)
		draw_rect(Rect2(rect.position, Vector2(floorf(rect.size.x * ratio), rect.size.y)), UiColors.EXP_BLUE)
		return
	draw_rect(rect, UiColors.BAR_BACK)
	var inner := rect.grow(-1.0)
	draw_rect(inner, UiColors.BAR_EMPTY)
	var width := floorf(inner.size.x * ratio)
	if ratio > 0.0:
		width = maxf(width, 1.0)
	draw_rect(Rect2(inner.position, Vector2(width, inner.size.y)), UiColors.hp_color(ratio))
