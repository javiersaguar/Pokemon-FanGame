extends BattleEffect
## Tormento: el objetivo no puede usar el mismo movimiento dos turnos seguidos mientras siga en el campo.


func on_hit(engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData) -> int:
	if target.dynamax_turns > 0 or not engine.add_volatile(target, &"torment"):
		engine.message(tr("¡Pero falló!"))
	return HANDLED
