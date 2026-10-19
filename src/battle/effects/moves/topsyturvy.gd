extends BattleEffect
## Reversión: invierte los cambios de características del objetivo.


func on_hit(engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData) -> int:
	var any := false
	for stat: StringName in target.boosts:
		if target.boosts[stat] != 0:
			target.boosts[stat] = -target.boosts[stat]
			any = true
	if not any:
		engine.message(tr("¡Pero falló!"))
	else:
		engine.message(tr("¡Se han invertido los cambios en las características %s!") % engine.of_name(target))
	return HANDLED
