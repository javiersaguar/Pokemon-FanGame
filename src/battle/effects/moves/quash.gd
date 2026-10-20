extends BattleEffect
## Último Lugar: el objetivo, si aún no se ha movido este turno, actúa el último (también en dobles).


func on_hit(engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData) -> int:
	if target.moved_this_turn or target.is_fainted() or not engine.act_last(target):
		engine.message(tr("¡Pero falló!"))
	else:
		engine.message(tr("¡%s tendrá que moverse el último!") % engine.name_of(target))
	return HANDLED
