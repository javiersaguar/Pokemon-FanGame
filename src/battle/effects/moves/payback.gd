extends BattleEffect
## Vendetta: el doble de potencia si el objetivo ya se ha movido en este turno.


func base_power(_engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData, power: int) -> int:
	return power * 2 if target.moved_this_turn else power
