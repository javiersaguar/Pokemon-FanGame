extends BattleEffect
## Campo de Niebla durante 5 turnos.


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	if not engine.set_terrain(&"mistyterrain", user):
		engine.message(tr("¡Pero falló!"))
	return HANDLED
