extends BattleEffect
## Respiro: pierde el tipo Volador hasta el final del turno.


func duration(_engine: BattleEngine) -> int:
	return 1


func residual_order() -> int:
	return 99


func removed_types(_state: Dictionary) -> Array[StringName]:
	return [&"flying"]
