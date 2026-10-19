extends BattleEffect
## Más Psique: copia los cambios de características del objetivo (y su Foco Energía).


func on_hit(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData) -> int:
	for stat: StringName in target.boosts:
		user.boosts[stat] = target.boosts[stat]
	user.crit_stage = target.crit_stage
	engine.message(tr("¡%s ha copiado los cambios en las características %s!") % [engine.name_of(user), engine.of_name(target)])
	return HANDLED
