extends BattleEffect
## Cerco Dimensión: atraviesa y rompe las protecciones (la bajada de Defensa está en los datos).


func on_try_move(engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData) -> bool:
	BreakProtect.apply(engine, target)
	return true
