extends BattleEffect
## Anticipo: este turno protege al equipo de los movimientos con prioridad de los rivales.

var condition_id := &"quickguard"


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	var foe := engine.foe_of(user)
	if foe == null or foe.is_fainted() or foe.moved_this_turn or not engine.add_side_condition(user.side, condition_id, user):
		engine.message(tr("¡Pero falló!"))
	return HANDLED
