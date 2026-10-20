extends BattleEffect
## Desahogo: el doble si este turno le han bajado alguna característica.


func base_power(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData, power: int) -> int:
	return power * 2 if user.lowered_turn == engine.turn else power
