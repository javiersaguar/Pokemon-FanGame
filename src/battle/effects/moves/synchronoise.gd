extends BattleEffect
## Sincroruido: solo afecta a los que comparten algún tipo con el usuario.


func on_try_move(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData) -> bool:
	for t: StringName in user.types():
		if target.has_type(t):
			return true
	engine.message(tr("No afecta %s...") % engine.to_name(target))
	return false
