extends BattleEffect
## Levitón: levita 5 turnos y los movimientos de tipo Tierra no le afectan.


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	if user.has_volatile(&"smackdown") or user.has_volatile(&"ingrain") or not engine.add_volatile(user, &"magnetrise", user):
		engine.message(tr("¡Pero falló!"))
	return HANDLED
