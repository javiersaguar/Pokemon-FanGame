extends BattleEffect
## Aguzar: el siguiente movimiento del usuario en este turno o el siguiente es un golpe crítico.


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	engine.remove_volatile(user, &"laserfocus")
	engine.add_volatile(user, &"laserfocus", user)
	return HANDLED
