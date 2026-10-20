extends BattleEffect
## Cede Paso: el objetivo, si aún no se ha movido este turno, actúa justo después (también en dobles).


func on_hit(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData) -> int:
	if target.moved_this_turn or target.is_fainted() or not engine.act_next(target):
		engine.message(tr("¡Pero falló!"))
	else:
		engine.message(tr("¡%s ha aceptado la cortesía %s!") % [engine.name_of(target), engine.of_name(user)])
	return HANDLED
