class_name BattleFx
extends Node2D
## Gráficos originales de NikDie, con cuadros y posiciones enteras.
## No dibuja sprites, no rota ni cambia su escala durante la animación.
enum Kind { BURST, ORB, SPARKLE }
const DIR := "res://assets/sprites/ui/battle/moves/"
static var _types: Dictionary = {}
var kind := Kind.BURST
var color := Color.WHITE
var profile: Dictionary = {}
var origin := Vector2.ZERO
var destination := Vector2.ZERO
var particles: Array[Sprite2D] = []
var impact: Sprite2D
var progress := 0.0:
	set(value):
		progress = clampf(value, 0.0, 1.0)
		if is_node_ready(): _pose()

static func type_profile(type: StringName) -> Dictionary:
	if _types.is_empty():
		_types = JSON.parse_string(FileAccess.get_file_as_string("res://data/battle_motion_types.json"))
	return _types.get(String(type), _types.normal).duplicate(true)

static func move(parent: Node, from: Vector2, to: Vector2, details: Dictionary, duration: float) -> void:
	if duration <= 0.0: return
	var category := StringName(str(details.get("category", "physical")).to_lower())
	var style := Kind.SPARKLE if category == &"status" else (Kind.ORB if category == &"special" else Kind.BURST)
	var fx := create(parent, style, from, to, type_profile(StringName(details.get("type", "normal"))), UiColors.type_color(StringName(details.get("type", "normal"))))
	await _play(fx, duration)

static func burst(parent: Node, at: Vector2, tint: Color, duration: float) -> void:
	if duration <= 0.0: return
	await _play(create(parent, Kind.BURST, at, at, {"asset": "eb303", "frame": [64,64]}, tint), duration)

static func orb(parent: Node, from: Vector2, to: Vector2, tint: Color, duration: float) -> void:
	if duration <= 0.0: return
	await _play(create(parent, Kind.ORB, from, to, {"asset": "eb519_2", "frame": []}, tint), duration)

static func sparkle(parent: Node, at: Vector2, tint: Color, duration: float) -> void:
	if duration <= 0.0: return
	await _play(create(parent, Kind.SPARKLE, at, at, {"asset": "eb519_2", "frame": []}, tint), duration)

## Pública para capturas deterministas y comprobación de las hojas importadas.
static func create(parent: Node, style: Kind, from: Vector2, to: Vector2, spec: Dictionary, tint := Color.WHITE) -> BattleFx:
	var fx := BattleFx.new()
	fx.kind = style
	fx.origin = from
	fx.destination = to
	fx.profile = spec
	fx.color = tint
	parent.add_child(fx)
	return fx

static func _play(fx: BattleFx, duration: float) -> void:
	var tween := fx.create_tween()
	tween.tween_property(fx, ^"progress", 1.0, duration)
	await tween.finished
	fx.queue_free()

func _ready() -> void:
	for i: int in (6 if kind == Kind.SPARKLE else 4):
		var sprite := Sprite2D.new()
		sprite.texture = load(DIR + ("eb519_2" if kind == Kind.SPARKLE else str(profile.asset)) + ".png")
		var frame: Array = [] if kind == Kind.SPARKLE else profile.get("frame", [])
		if frame.size() == 2:
			sprite.hframes = int(sprite.texture.get_width() / int(frame[0]))
			sprite.vframes = int(sprite.texture.get_height() / int(frame[1]))
		sprite.flip_h = destination.x < origin.x
		if kind == Kind.SPARKLE: sprite.modulate = color
		add_child(sprite)
		particles.append(sprite)
	impact = Sprite2D.new()
	impact.texture = load(DIR + "eb303.png")
	impact.hframes = 2
	impact.position = destination.round()
	impact.modulate = color
	add_child(impact)
	_pose()

func _pose() -> void:
	for i: int in particles.size():
		var sprite := particles[i]
		var phase := clampf((progress - i * 0.07) / 0.64, 0.0, 1.0)
		sprite.frame = mini(sprite.hframes * sprite.vframes - 1, int(progress * 12.0) % (sprite.hframes * sprite.vframes))
		sprite.modulate.a = sin(phase * PI)
		match kind:
			Kind.ORB:
				sprite.position = origin.lerp(destination, phase).round() + Vector2(0, (i - 1.5) * 12).round()
			Kind.BURST:
				var offsets := [Vector2(-24,-24),Vector2(24,-16),Vector2(-16,16),Vector2(16,24)]
				sprite.position = (destination + offsets[i] * (1.0 + phase * 0.5)).round()
			Kind.SPARKLE:
				sprite.position = (destination + Vector2((i-2.5)*16, 20 - phase*80)).round()
	impact.visible = kind != Kind.SPARKLE
	impact.modulate.a = maxf(0.0, sin(clampf((progress - 0.65) / 0.35, 0, 1) * PI))
	impact.frame = 0 if progress < 0.85 else 1
