extends BattleEffect
## Pataleta: el doble de potencia si el último movimiento del usuario falló.


func base_power(_engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData, power: int) -> int:
	return power * 2 if user.last_move_failed else power
