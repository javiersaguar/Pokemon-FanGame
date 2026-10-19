extends BattleEffect
## Copión: usa el último movimiento que se ha usado en el combate, si se puede copiar.


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	var last := engine.last_used_move
	if last == &"" or last == &"copycat" or not DataDB.has_move(last) or DataDB.move(last).has_flag(&"failcopycat"):
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	engine.use_move(user, DataDB.move(last))
	return HANDLED
