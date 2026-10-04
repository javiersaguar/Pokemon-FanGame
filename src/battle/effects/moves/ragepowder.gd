extends BattleEffect
## Polvo Ira: solo tiene sentido en combates dobles (Fase 9.4); en individuales falla.


func on_try_move(engine: BattleEngine, _user: Battler, _target: Battler, _move: MoveData) -> bool:
	engine.message(tr("¡Pero falló!"))
	return false
