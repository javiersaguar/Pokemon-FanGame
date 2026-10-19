extends BattleEffect
## Cede Paso: el objetivo se mueve justo después. En individuales solo funciona si aún no se ha movido.


func on_hit(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData) -> int:
	if target.moved_this_turn or target.is_fainted():
		engine.message(tr("¡Pero falló!"))
	else:
		engine.message(tr("¡%s ha aceptado la cortesía %s!") % [engine.name_of(target), engine.of_name(user)])
	return HANDLED
