extends TwoTurnMoveEffect
## Cabezazo: el primer turno baja la cabeza (sube la Defensa) y el segundo ataca.


func _init() -> void:
	charge_text = "¡%s ha bajado la cabeza!"


func charge_turn(engine: BattleEngine, user: Battler, move: MoveData) -> bool:
	var charging := super.charge_turn(engine, user, move)
	if charging:
		engine.boost(user, {&"def": 1}, true)
	return charging
