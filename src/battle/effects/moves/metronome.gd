extends BattleEffect
## Metrónomo: usa un movimiento cualquiera al azar de los que permite.


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	var options: Array[StringName] = []
	for id: StringName in DataDB.move_ids():
		var m := DataDB.move(id)
		if m != null and m.has_flag(&"metronome") and m.id != &"metronome" and m.nonstandard == &"":
			options.append(m.id)
	if options.is_empty():
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	options.sort()
	engine.use_move(user, DataDB.move(options[engine.rand_int(&"metronome", 0, options.size() - 1)]))
	return HANDLED
