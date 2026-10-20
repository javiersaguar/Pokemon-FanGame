extends BattleEffect
## Fuerza G: ×1,5 con Gravedad (la bajada de Defensa está en los datos).


func base_power(engine: BattleEngine, _user: Battler, _target: Battler, _move: MoveData, power: int) -> int:
	return DamageCalc.modify(power, 6144, 4096) if engine.field.has("gravity") else power
