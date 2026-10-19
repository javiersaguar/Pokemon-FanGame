extends BattleEffect
## Otra Vez: durante 3 turnos el objetivo solo puede repetir el último movimiento que usó.

const NO_ENCORE: Array[StringName] = [&"encore", &"transform", &"mimic", &"mirrormove", &"sketch", &"struggle", &"sleeptalk", &"copycat"]


func on_hit(engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData) -> int:
	var last := target.last_move
	var index := engine.move_index_of(target, last)
	if last == &"" or last in NO_ENCORE or index < 0 or target.pokemon.moves[index].pp <= 0 or target.dynamax_turns > 0 \
			or not engine.add_volatile(target, &"encore", null, {"move": String(last)}):
		engine.message(tr("¡Pero falló!"))
	return HANDLED
