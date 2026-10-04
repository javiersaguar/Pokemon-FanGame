extends BattleEffect
## Buena Baza: doble de potencia si el objetivo ya ha recibido daño este turno.


func base_power(_engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData, power: int) -> int:
	return power * 2 if target.damaged_this_turn else power
