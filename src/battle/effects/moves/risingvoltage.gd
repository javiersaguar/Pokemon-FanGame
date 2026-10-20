extends BattleEffect
## Alto Voltaje: el doble con Campo Eléctrico si el objetivo toca el suelo.


func base_power(engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData, power: int) -> int:
	return power * 2 if engine.terrain() == &"electricterrain" and engine.is_grounded(target) else power
