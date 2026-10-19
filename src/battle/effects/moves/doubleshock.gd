extends BattleEffect
## Electrochoque: solo puede usarlo un Pokémon de tipo Eléctrico, que deja de serlo al usarlo.

var gone_type := &"electric"


func on_try_move(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> bool:
	if user.has_type(gone_type):
		return true
	engine.message(tr("¡Pero falló!"))
	return false


func on_after_move(engine: BattleEngine, user: Battler, _move: MoveData, hit: bool) -> void:
	if hit and not user.is_fainted():
		engine.add_volatile(user, &"losttype", user, {"type": String(gone_type)})
