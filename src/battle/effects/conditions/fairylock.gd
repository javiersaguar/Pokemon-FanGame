extends BattleEffect
## Cerrojo Feérico (hasta el final del turno siguiente): nadie puede cambiarse ni huir.


func residual_order() -> int:
	return 28


func traps(_engine: BattleEngine, _battler: Battler, _state: Dictionary) -> bool:
	return true
