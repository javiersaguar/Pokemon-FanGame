extends BattleEffect
## Desquite: el doble de potencia si el objetivo le ha hecho daño en este turno.


func base_power(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData, power: int) -> int:
	var hurt := user.hurt_by
	if not hurt.is_empty() and int(hurt["turn"]) == engine.turn and int(hurt["side"]) == target.side and int(hurt["slot"]) == target.slot:
		return power * 2
	return power
