class_name BattleEntryTransition
extends Control
## Recursos EBDX nativos: movimiento redondeado, sin zoom ni giro del arte.
const DIR := "res://assets/sprites/ui/battle/transitions/"
var kind: StringName = &"wild"
var info: Dictionary
var progress := 0.0
var _back: Sprite2D
var _symbol: Sprite2D
var _portrait: Sprite2D
var _streaks: Array[Sprite2D] = []
var _title: Label

static func select_kind(details: Dictionary) -> StringName:
	if StringName(details.get("transition", "")) in [&"wild", &"trainer", &"leader"]: return StringName(details.transition)
	if StringName(details.get("kind", "wild")) == &"wild": return &"wild"
	for trainer: Dictionary in details.get("trainers", []):
		var id := StringName(trainer.get("id", ""))
		if DataDB.has_trainer(id) and str(DataDB.trainer(id).get("leader_type", "")) != "": return &"leader"
	return &"trainer"

static func play(parent: Node, details: Dictionary, quick := false) -> void:
	if quick: return
	var screen := BattleEntryTransition.new()
	screen.info = details
	screen.kind = select_kind(details)
	parent.add_child(screen)
	AudioManager.play_se(&"ball_throw" if screen.kind == &"wild" else &"party")
	var tween := screen.create_tween()
	tween.tween_method(screen.set_progress, 0.0, 1.0, 1.2 if screen.kind != &"leader" else 1.5)
	await tween.finished
	screen.queue_free()

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	size = Vector2(512, 384)
	clip_contents = true
	theme = preload("res://src/ui/theme/main_theme.tres")
	_back = image(kind, Vector2(256, 192))
	if kind == &"leader": image(&"leader_shine", Vector2(256, 192))
	for y: int in [84, 300]: _streaks.append(image(&"streak", Vector2(256, y)))
	_symbol = image(&"ball" if kind == &"wild" else &"vs", Vector2(256, 192))
	_portrait = Sprite2D.new()
	_portrait.position = Vector2(392, 231)
	add_child(_portrait)
	var trainers: Array = info.get("trainers", [])
	if not trainers.is_empty():
		var path := str(trainers[0].get("battle_sprite", ""))
		if not path.is_empty() and ResourceLoader.exists(path): _portrait.texture = load(path)
	var canvas := UiCanvas.new()
	add_child(canvas)
	_title = Label.new()
	_title.theme_type_variation = &"LightLabel"
	_title.position = Vector2(12, 164)
	_title.size = Vector2(232, 20)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.text = "¡Un Pokémon salvaje!" if kind == &"wild" else str(trainers[0].get("display_name", "Entrenador")) if not trainers.is_empty() else "Líder de gimnasio" if kind == &"leader" else "Entrenador"
	canvas.add_child(_title)
	set_progress(progress)

func image(id: StringName, at: Vector2) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = load(DIR + String(id) + ".png")
	sprite.position = at.round()
	add_child(sprite)
	return sprite

func set_progress(value: float) -> void:
	progress = clampf(value, 0.0, 1.0)
	var entry := clampf(progress / 0.3, 0.0, 1.0)
	var departure := clampf((progress - 0.75) / 0.25, 0.0, 1.0)
	var eased := 1.0 - pow(1.0 - entry, 3)
	modulate.a = 1.0 - departure
	_symbol.position.x = roundf(256 + (1.0 - eased) * -600)
	_portrait.position.x = roundf(392 + (1.0 - eased) * 300)
	_title.modulate.a = entry
	for i: int in _streaks.size():
		_streaks[i].position.x = roundf(256 + (1.0 - eased) * (512 if i == 0 else -512))
