class_name BattleMoveAnimation
extends RefCounted
## Secuencias de ataque con fases explícitas y recursos originales (data/battle_motion_moves.json,
## generado por tools/arte/animaciones_movimientos.py desde las animaciones de Elite Battle DX).
## Además de las fases, una secuencia puede llevar:
##   backdrop: [r, g, b]  fondo teñido detrás de los Pokémon mientras dura el ataque
##   backdrop_asset: id   imagen de fondo original de 512×384 (en su lugar)
##   target_tint: [r, g, b], shake: true  cómo reacciona el objetivo al golpe
const BACKDROP_ALPHA := 0.45
const BACKDROP_IMAGE_ALPHA := 0.7
static var _moves: Dictionary = {}
## Movimiento → sonidos de su animación (data/battle_motion_sounds.json, sacados de EBDX).
static var _sounds: Dictionary = {}


## Sonidos de la animación de `id` (ids de AudioManager.play_se, como "anim/bite").
static func sounds(id: StringName) -> Array:
	if _sounds.is_empty():
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/battle_motion_sounds.json"))
		_sounds = parsed.get("moves", {}) if parsed is Dictionary else {"_": []}
	return _sounds.get(String(id), [])


## El primero suena al empezar y los demás, repartidos a lo largo de la animación.
static func _play_sounds(parent: Node, id: StringName, duration: float) -> void:
	var list := sounds(id)
	if list.is_empty() or not is_instance_valid(parent) or not parent.is_inside_tree():
		return
	var audio: Node = parent.get_tree().root.get_node_or_null(^"AudioManager")
	if audio == null:
		return
	for i: int in list.size():
		var sound := StringName(str(list[i]))
		if i == 0:
			audio.play_se(sound)
		else:
			parent.get_tree().create_timer(duration * i / list.size()).timeout.connect(func() -> void: audio.play_se(sound))

static func sequence(id: StringName) -> Dictionary:
	if _moves.is_empty(): _moves = JSON.parse_string(FileAccess.get_file_as_string("res://data/battle_motion_moves.json"))
	return _moves.get(String(id),{}).duplicate(true)

static func play(parent: Node, user: BattlePokemonSprite, target: BattlePokemonSprite, details: Dictionary, quick: bool) -> bool:
	var spec := sequence(StringName(details.get("move", "")))
	if spec.is_empty(): return false
	if quick: return true
	var duration := float(spec.duration)
	_play_sounds(parent, StringName(details.get("move", "")), duration)
	var backdrop := _backdrop(parent, spec)
	if backdrop != null:
		await _fade(backdrop, BACKDROP_IMAGE_ALPHA if backdrop is Sprite2D else BACKDROP_ALPHA, 0.15)
	match str(spec.get("user_motion","")):
		"lunge", "quick": await user.lunge(target.home(), .12 if spec.user_motion == "quick" else .25)
		"flash": await user.flash(.25)
		"sway", "hop":
			var home := user.home()
			var tween := user.create_tween()
			tween.tween_method(func(t: float) -> void:
				var offset := Vector2(0,-absf(sin(t*TAU))*12) if spec.user_motion == "hop" else Vector2(sin(t*TAU*2)*8,0)
				user.position = (home+offset).round(), 0.0, 1.0, duration*.65)
			await tween.finished
			user.position = home
	var phases: Array = spec.get("phases",[spec])
	for phase: Dictionary in phases:
		if not is_instance_valid(user) or not is_instance_valid(target) or not is_instance_valid(parent): break
		var focus := user.center() if phase.get("focus","target") == "user" else target.center()
		var style := BattleFx.Kind.ORB if phase.kind == "orb" else (BattleFx.Kind.SPARKLE if phase.kind == "sparkle" else BattleFx.Kind.BURST)
		var fx := BattleFx.create(parent,style,user.center(),focus,phase,UiColors.type_color(StringName(details.get("type","normal"))))
		await BattleFx._play(fx,float(phase.get("duration",duration)))
	if is_instance_valid(target) and (spec.has("target_tint") or bool(spec.get("shake", false))):
		var tint := Color.WHITE
		if spec.has("target_tint"):
			var c: Array = spec.target_tint
			tint = Color8(int(c[0]), int(c[1]), int(c[2])).lerp(Color.WHITE, 0.35)
		await target.react(tint, bool(spec.get("shake", false)), 0.3)
	if is_instance_valid(backdrop):
		await _fade(backdrop, 0.0, 0.15)
		backdrop.free()
	return true

## Fondo del ataque: detrás de los Pokémon si la escena tiene fondo (World/Background), si no,
## debajo de todo lo demás del padre. Empieza transparente.
static func _backdrop(parent: Node, spec: Dictionary) -> CanvasItem:
	var node: CanvasItem = null
	if spec.has("backdrop_asset"):
		var path := BattleFx.DIR + str(spec.backdrop_asset) + ".png"
		if not ResourceLoader.exists(path): return null
		var image := Sprite2D.new()
		image.texture = load(path)
		image.centered = false
		image.region_enabled = true
		image.region_rect = Rect2(0, 0, 512, 384)
		node = image
	elif spec.has("backdrop"):
		var c: Array = spec.backdrop
		var rect := ColorRect.new()
		rect.color = Color8(int(c[0]), int(c[1]), int(c[2]))
		rect.size = Vector2(512, 384)
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		node = rect
	if node == null: return null
	node.name = "FondoAtaque"
	node.modulate.a = 0.0
	var world := parent.get_parent()
	if world != null and world.has_node(^"Background"):
		world.add_child(node)
		world.move_child(node, world.get_node(^"Background").get_index() + 1)
	else:
		parent.add_child(node)
		parent.move_child(node, 0)
	return node

static func _fade(node: CanvasItem, alpha: float, seconds: float) -> void:
	var tween := node.create_tween()
	tween.tween_property(node, ^"modulate:a", alpha, seconds)
	await tween.finished
