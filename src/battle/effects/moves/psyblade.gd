extends BattleEffect
## Psicohojas: ×1,5 con Campo Eléctrico.


func base_power(engine: BattleEngine, _user: Battler, _target: Battler, _move: MoveData, power: int) -> int:
	return DamageCalc.modify(power, 6144, 4096) if engine.terrain() == &"electricterrain" else power
