extends BattleEffect
## Relevo: el usuario se cambia y el que entra hereda sus cambios de características y algunos volátiles.


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	if not engine.request_switch(user, &"batonpass"):
		engine.message(tr("¡Pero falló!"))
	return HANDLED
