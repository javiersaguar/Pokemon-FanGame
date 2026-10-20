extends TwoTurnMoveEffect
## Movimiento de dos turnos que sube el Ataque Especial al cargar (con lluvia, sin cargar).


func _init() -> void:
	charge_text = "¡%s acumula electricidad!"


func charge_turn(engine: BattleEngine, user: Battler, move: MoveData) -> bool:
	if engine.weather() == &"raindance" and not user.has_volatile(&"twoturnmove"):
		engine.boost(user, {&"spa": 1}, true)
		return false
	var charging := super(engine, user, move)
	if charging:
		engine.boost(user, {&"spa": 1}, true)
	return charging
