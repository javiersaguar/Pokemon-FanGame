class_name HpBar
extends Control
## Relleno de la barra de PS (verde → amarillo → rojo) o de experiencia (azul).
## El marco es un NinePatchRect aparte. Con "barra fantasma": al perder PS, el trozo
## perdido se queda un momento en claro y luego se vacía (BIBLIA.md §8).
## La línea de luz de arriba es detalle a 1× (medio píxel de arte).

signal value_changed(ratio: float)

const GHOST_DELAY := 0.15

## Barra de experiencia: siempre azul y sin fantasma.
@export var exp_mode := false

var ratio := 1.0:
	set(value):
		ratio = clampf(value, 0.0, 1.0)
		queue_redraw()
		value_changed.emit(ratio)
var ghost := 1.0:
	set(value):
		ghost = clampf(value, 0.0, 1.0)
		queue_redraw()

var _tween: Tween


## Anima la barra hasta `target` en `duration` segundos (se puede esperar).
func animate_to(target: float, duration: float) -> void:
	if _tween:
		_tween.kill()
	if duration <= 0.0 or is_equal_approx(target, ratio):
		ratio = target
		ghost = target
		return
	var losing := target < ratio
	if not losing:
		ghost = target
	_tween = create_tween()
	_tween.tween_property(self, ^"ratio", target, duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	if losing and not exp_mode:
		_tween.tween_interval(GHOST_DELAY)
		_tween.tween_property(self, ^"ghost", target, 0.15)
	await _tween.finished
	ghost = ratio


func set_instant(value: float) -> void:
	if _tween:
		_tween.kill()
	ratio = value
	ghost = value


func _draw() -> void:
	var full := size.x
	if exp_mode:
		_fill(ratio, UiColors.EXP, UiColors.EXP_LIGHT)
		return
	if ghost > ratio:
		draw_rect(Rect2(0, 0, floorf(full * ghost), size.y), UiColors.HP_GHOST)
	var tones := UiColors.hp_tones(ratio)
	_fill(ratio, tones[0], tones[1])


func _fill(value: float, base: Color, light: Color) -> void:
	var width := floorf(size.x * value)
	if value > 0.0:
		width = maxf(width, 1.0)
	draw_rect(Rect2(0, 0, width, size.y), base)
	draw_rect(Rect2(0, 0, width, 0.5), light)
