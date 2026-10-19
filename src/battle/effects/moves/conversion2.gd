extends BattleEffect
## Conversión2: el usuario pasa a ser de un tipo que resiste el último movimiento del objetivo.


func on_hit(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData) -> int:
	var last := target.last_move
	if last == &"" or not DataDB.has_move(last) or user.tera_active != &"":
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	var attack := DataDB.move(last).type
	var options: Array[StringName] = []
	for type_id: StringName in DataDB.type_ids():
		if DataDB.type_effectiveness(attack, [type_id]) < 1.0 and not user.has_type(type_id):
			options.append(type_id)
	if options.is_empty():
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	user.type_override.assign([options[engine.rand_int(&"conversion2", 0, options.size() - 1)]])
	engine.message(tr("¡%s ha cambiado de tipo!") % engine.name_of(user))
	return HANDLED
