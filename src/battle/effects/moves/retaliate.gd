extends BattleEffect
## Represalia: el doble de potencia si un compañero se debilitó en el turno anterior.


func base_power(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData, power: int) -> int:
	return power * 2 if engine.side(user.side).last_faint_turn == engine.turn - 1 else power
