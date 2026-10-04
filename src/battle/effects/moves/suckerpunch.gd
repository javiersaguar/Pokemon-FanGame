extends BattleEffect
## Golpe Bajo: solo funciona si el objetivo va a usar un movimiento de daño este turno y aún no lo ha hecho.


func on_try_move(engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData) -> bool:
	var action := engine.turn_action(target)
	var ok := action != null and action.kind == BattleAction.Kind.FIGHT and not target.moved_this_turn
	if ok:
		var index := action.move_index
		var move := target.pokemon.moves[index].data() if index >= 0 and index < target.pokemon.moves.size() else DataDB.move(&"struggle")
		ok = not move.is_status()
	if not ok:
		engine.message(tr("¡Pero falló!"))
	return ok
