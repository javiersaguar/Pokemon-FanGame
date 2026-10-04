class_name BattleFx
extends Node2D
## Animaciones genéricas de movimientos (Fase 7.10), por categoría y con el
## color del tipo: golpe (físico), proyectil (especial) y destellos (estado).
## Cada función crea el efecto, lo anima, lo borra y se puede esperar.

enum Kind { BURST, ORB, SPARKLE }

var kind := Kind.BURST
var color := Color.WHITE
var progress := 0.0:
	set(value):
		progress = value
		queue_redraw()


## Estallido en `at` (impacto de un ataque).
static func burst(parent: Node, at: Vector2, tint: Color, duration: float) -> void:
	await _play(_spawn(parent, Kind.BURST, at, tint), duration)


## Bola de energía de `from` a `to` y estallido al llegar.
static func orb(parent: Node, from: Vector2, to: Vector2, tint: Color, duration: float) -> void:
	var fx := _spawn(parent, Kind.ORB, from, tint)
	if duration > 0.0:
		var tween := fx.create_tween().set_parallel()
		tween.tween_property(fx, ^"position", to, duration * 0.6).set_trans(Tween.TRANS_SINE)
		tween.tween_property(fx, ^"progress", 1.0, duration * 0.6)
		await tween.finished
	fx.queue_free()
	await burst(parent, to, tint, duration * 0.4)


## Destellos que suben alrededor de `at` (movimientos de estado y cambios de características).
static func sparkle(parent: Node, at: Vector2, tint: Color, duration: float) -> void:
	await _play(_spawn(parent, Kind.SPARKLE, at, tint), duration)


static func _spawn(parent: Node, fx_kind: Kind, at: Vector2, tint: Color) -> BattleFx:
	var fx := BattleFx.new()
	fx.kind = fx_kind
	fx.color = tint
	fx.position = at
	parent.add_child(fx)
	return fx


static func _play(fx: BattleFx, duration: float) -> void:
	if duration > 0.0:
		var tween := fx.create_tween()
		tween.tween_property(fx, ^"progress", 1.0, duration)
		await tween.finished
	fx.queue_free()


func _draw() -> void:
	var outline := color.darkened(0.5)
	match kind:
		Kind.BURST:
			var radius := 4.0 + progress * 16.0
			var alpha := 1.0 - progress
			for i: int in 8:
				var dir := Vector2.RIGHT.rotated(TAU * i / 8.0)
				var p := (dir * radius).round()
				draw_rect(Rect2(p - Vector2(2, 2), Vector2(4, 4)), Color(outline, alpha))
				draw_rect(Rect2(p - Vector2(1, 1), Vector2(2, 2)), Color(color.lightened(0.4), alpha))
		Kind.ORB:
			draw_circle(Vector2.ZERO, 5.0, outline)
			draw_circle(Vector2.ZERO, 4.0, color)
			draw_circle(Vector2(-1, -1), 1.5, color.lightened(0.6))
		Kind.SPARKLE:
			for i: int in 6:
				var phase := fmod(progress * 1.5 + i / 6.0, 1.0)
				var p := Vector2((i - 2.5) * 8.0, 8.0 - phase * 36.0).round()
				var alpha := sin(phase * PI)
				draw_rect(Rect2(p - Vector2(1, 2), Vector2(2, 4)), Color(color.lightened(0.5), alpha))
				draw_rect(Rect2(p - Vector2(2, 1), Vector2(4, 2)), Color(color.lightened(0.5), alpha))
