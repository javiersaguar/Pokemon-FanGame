extends BattleEffect
## Vasto Impacto: ×1,5 con Campo Psíquico si el usuario toca el suelo.


func base_power(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData, power: int) -> int:
	return DamageCalc.modify(power, 6144, 4096) if engine.terrain() == &"psychicterrain" and engine.is_grounded(user) else power
