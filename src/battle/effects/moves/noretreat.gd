extends BattleEffect
## Bastión Final: sube todas las características (datos) y ya no puede cambiarse ni huir.


func on_try_move(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> bool:
	if user.has_volatile(&"noretreat"):
		engine.message(tr("¡Pero falló!"))
		return false
	return true


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	engine.add_volatile(user, &"noretreat", user)
	return CONTINUE
