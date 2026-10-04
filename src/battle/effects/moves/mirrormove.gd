extends BattleEffect
## Espejo: usa el último movimiento que ha usado el objetivo, si se puede copiar.


func on_hit(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData) -> int:
	var last := target.last_move
	if last == &"" or not DataDB.has_move(last) or not DataDB.move(last).has_flag(&"mirror"):
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	engine.use_move(user, DataDB.move(last))
	return HANDLED
