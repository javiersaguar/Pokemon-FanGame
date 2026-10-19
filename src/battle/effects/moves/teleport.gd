extends BattleEffect
## Teletransporte: en un combate contra un salvaje, huye. Contra un entrenador, el usuario se cambia
## por otro de su equipo (8.ª generación en adelante).


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	if engine.is_wild_battle():
		if engine.setup.can_run or user.side == BattleEngine.FOE:
			engine.message(tr("¡%s ha huido!") % engine.name_of(user))
			engine.end_battle(BattleResult.RUN)
		else:
			engine.message(tr("¡Pero falló!"))
		return HANDLED
	if not engine.request_switch(user, &"uturn"):
		engine.message(tr("¡Pero falló!"))
	return HANDLED
