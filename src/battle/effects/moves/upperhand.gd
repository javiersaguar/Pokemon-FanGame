extends BattleEffect
## Palma Rauda: solo si el objetivo va a usar un movimiento con prioridad este turno.


func on_try_move(engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData) -> bool:
	var action := engine.turn_action(target)
	var ok := action != null and action.kind == BattleAction.Kind.FIGHT and not target.moved_this_turn
	if ok:
		var index := action.move_index
		ok = index >= 0 and index < target.pokemon.moves.size() \
			and engine.move_priority(target, target.pokemon.moves[index].data()) > 0
	if not ok:
		engine.message(tr("¡Pero falló!"))
	return ok
