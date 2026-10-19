extends BattleEffect
## Eructo: solo se puede usar después de comerse una baya en este combate.


func on_try_move(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> bool:
	if user.ate_berry:
		return true
	engine.message(tr("¡Pero falló!"))
	return false
