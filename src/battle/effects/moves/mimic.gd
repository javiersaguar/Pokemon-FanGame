extends BattleEffect
## Mimético: sustituye Mimético por el último movimiento del objetivo (con 5 PP) hasta el final del combate.

const NO_MIMIC: Array[StringName] = [&"mimic", &"struggle", &"transform", &"sketch", &"metronome", &"chatter"]


func on_hit(engine: BattleEngine, user: Battler, target: Battler, move: MoveData) -> int:
	var last := target.last_move
	var index := engine.move_index_of(user, move.id)
	if index < 0 or last == &"" or last in NO_MIMIC or engine.move_index_of(user, last) >= 0 or not DataDB.has_move(last):
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	var slot := MoveSlot.create(last)
	slot.pp = mini(5, slot.max_pp())
	engine.replace_move_slot(user, index, slot, true)
	engine.message(tr("¡%s ha aprendido %s!") % [engine.name_of(user), DataDB.move(last).name])
	return HANDLED
