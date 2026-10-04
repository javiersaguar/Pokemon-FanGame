extends BattleEffect
## Salpicadura: no hace nada.


func on_try_move(engine: BattleEngine, _user: Battler, _target: Battler, _move: MoveData) -> bool:
	engine.message(tr("¡Pero no ha pasado nada!"))
	return false
