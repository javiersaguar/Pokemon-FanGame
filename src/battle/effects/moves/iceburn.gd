extends TwoTurnMoveEffect
## Movimiento de dos turnos.


func _init() -> void:
	charge_text = "¡%s está rodeado de un aire gélido!"


func charge_turn(engine: BattleEngine, user: Battler, move: MoveData) -> bool:
	var charging := super(engine, user, move)
	return charging
