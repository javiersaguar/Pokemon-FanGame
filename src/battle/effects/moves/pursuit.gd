extends BattleEffect
## Persecución: si el objetivo se va a cambiar, le golpea antes con el doble de potencia.


func runs_before_switch() -> bool:
	return true


func base_power(engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData, power: int) -> int:
	return power * 2 if engine.switching == target else power
