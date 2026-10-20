extends BattleEffect
## Esquema: aprende para siempre el último movimiento del objetivo en lugar de Esquema.


const NO: Array[StringName] = [&"sketch", &"struggle", &"chatter"]


func on_hit(engine: BattleEngine, user: Battler, target: Battler, move: MoveData) -> int:
	var last := target.last_move
	var index := engine.move_index_of(user, move.id)
	if index < 0 or last == &"" or last in NO or engine.move_index_of(user, last) >= 0 or not DataDB.has_move(last):
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	user.pokemon.moves[index] = MoveSlot.create(last)
	engine.message(tr("¡%s ha esquematizado %s!") % [engine.name_of(user), DataDB.move(last).name])
	return HANDLED
