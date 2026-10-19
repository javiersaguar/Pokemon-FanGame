extends BattleEffect
## Acupresión: sube dos niveles una característica al azar de las que aún pueden subir.


func on_hit(engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData) -> int:
	var options: Array[StringName] = []
	for stat: StringName in Battler.BOOST_STATS:
		if target.boosts[stat] < 6:
			options.append(stat)
	if options.is_empty():
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	engine.boost(target, {options[engine.rand_int(&"acupressure", 0, options.size() - 1)]: 2})
	return HANDLED
