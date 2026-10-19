extends BattleEffect
## Cerrojo Feérico: en el turno siguiente nadie puede cambiarse ni huir.


func on_hit(engine: BattleEngine, _user: Battler, _target: Battler, _move: MoveData) -> int:
	if not engine.field_state(&"fairylock").is_empty():
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	engine.set_field_state(&"fairylock", {"turns": 2})
	engine.message(tr("¡Nadie podrá huir en el próximo turno!"))
	return HANDLED
