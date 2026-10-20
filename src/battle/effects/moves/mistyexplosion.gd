extends BattleEffect
## Bruma Explosiva: el usuario se debilita (datos); ×1,5 con Campo de Niebla si toca el suelo.


func base_power(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData, power: int) -> int:
	return DamageCalc.modify(power, 6144, 4096) if engine.terrain() == &"mistyterrain" and engine.is_grounded(user) else power
