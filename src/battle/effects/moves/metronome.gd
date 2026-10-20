extends BattleEffect
## Metrónomo: usa un movimiento al azar entre los que admite (9.ª generación, como Showdown: con la
## marca de Metrónomo y que existan en el juego actual; los «no disponibles» también valen).


static func pool() -> Array[StringName]:
	var options: Array[StringName] = []
	for id: StringName in DataDB.move_ids():
		var m := DataDB.move(id)
		if m != null and m.has_flag(&"metronome") and m.id != &"metronome" and m.nonstandard in [&"", &"unobtainable"]:
			options.append(m.id)
	options.sort_custom(func(a: StringName, b: StringName) -> bool: return String(a) < String(b))
	return options


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	var options := pool()
	if options.is_empty():
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	engine.use_move(user, DataDB.move(options[engine.rand_int(&"metronome", 0, options.size() - 1)]))
	return HANDLED
