extends BattleEffect
## Come Sueños: solo afecta a un objetivo dormido (el drenaje de la mitad está en los datos).


func on_try_move(engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData) -> bool:
	if target.pokemon.status == &"slp":
		return true
	engine.message(tr("No afecta %s...") % engine.to_name(target))
	return false
