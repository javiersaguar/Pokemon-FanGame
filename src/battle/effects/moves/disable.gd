extends BattleEffect
## Anulación: el objetivo no puede usar durante 4 turnos el último movimiento que usó.


func on_hit(engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData) -> int:
	var last := target.last_move
	var index := engine.move_index_of(target, last)
	if last == &"" or last == &"struggle" or index < 0 or target.pokemon.moves[index].pp <= 0 \
			or not engine.add_volatile(target, &"disable", null, {"move": String(last)}):
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	engine.message(tr("¡Se ha anulado %s %s!") % [DataDB.move(last).name, engine.of_name(target)])
	return HANDLED
