extends TwoTurnMoveEffect
## Movimiento de dos turnos que sube el Ataque Especial al cargar.


func _init() -> void:
	charge_text = "¡%s rebosa energía cósmica!"


func charge_turn(engine: BattleEngine, user: Battler, move: MoveData) -> bool:
	var charging := super(engine, user, move)
	if charging:
		engine.boost(user, {&"spa": 1}, true)
	return charging
