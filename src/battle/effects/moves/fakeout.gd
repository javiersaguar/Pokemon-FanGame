extends BattleEffect
## Sorpresa: solo funciona en el primer turno que el usuario pasa en el campo.


func on_try_move(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> bool:
	if user.turns_active > 0:
		engine.message(tr("¡Pero falló!"))
		return false
	return true
