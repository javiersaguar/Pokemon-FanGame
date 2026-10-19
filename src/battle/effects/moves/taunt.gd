extends BattleEffect
## Mofa: durante 3 turnos el objetivo solo puede usar movimientos que hagan daño. Si ya se ha movido
## en este turno, dura uno más (como en Showdown).


func on_hit(engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData) -> int:
	var turns := 4 if target.moved_this_turn else 3
	if not engine.add_volatile(target, &"taunt", null, {"turns": turns}):
		engine.message(tr("¡Pero falló!"))
	return HANDLED
