extends BattleEffect
## Campo Psíquico durante 5 turnos.


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	if not engine.set_terrain(&"psychicterrain", user):
		engine.message(tr("¡Pero falló!"))
	return HANDLED
