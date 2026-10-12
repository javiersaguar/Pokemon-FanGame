class_name BattleMoveAnimation
extends RefCounted
## Secuencias de ataque con fases explícitas y recursos originales.
static var _moves: Dictionary = {}
static func sequence(id: StringName) -> Dictionary:
	if _moves.is_empty(): _moves = JSON.parse_string(FileAccess.get_file_as_string("res://data/battle_motion_moves.json"))
	return _moves.get(String(id),{}).duplicate(true)
static func play(parent: Node, user: BattlePokemonSprite, target: BattlePokemonSprite, details: Dictionary, quick: bool) -> bool:
	var spec := sequence(StringName(details.get("move", "")))
	if spec.is_empty(): return false
	if quick: return true
	var duration := float(spec.duration)
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
		if not is_instance_valid(user) or not is_instance_valid(target) or not is_instance_valid(parent): return true
		var focus := user.center() if phase.get("focus","target") == "user" else target.center()
		var style := BattleFx.Kind.ORB if phase.kind == "orb" else (BattleFx.Kind.SPARKLE if phase.kind == "sparkle" else BattleFx.Kind.BURST)
		var fx := BattleFx.create(parent,style,user.center(),focus,phase,UiColors.type_color(StringName(details.get("type","normal"))))
		await BattleFx._play(fx,float(phase.get("duration",duration)))
	return true
