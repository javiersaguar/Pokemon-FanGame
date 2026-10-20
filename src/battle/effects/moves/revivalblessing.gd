extends BattleEffect
## Plegaria Vital: revive con la mitad de sus PS al compañero debilitado que elija el entrenador (la
## IA, el de más nivel). Falla si no hay ninguno.


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	if not engine.request_revival(user):
		engine.message(tr("¡Pero falló!"))
	return HANDLED
