extends BattleEffect
## Ronquido: solo se puede usar dormido.


func on_try_move(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> bool:
	if user.pokemon.status == &"slp":
		return true
	engine.message(tr("¡Pero falló!"))
	return false
