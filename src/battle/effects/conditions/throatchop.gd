extends BattleEffect
## Golpe Mordaza: no puede usar movimientos de sonido.


func duration(_engine: BattleEngine) -> int:
	return 2


func residual_order() -> int:
	return 22


func disables_move(_battler: Battler, _state: Dictionary, move: MoveData) -> bool:
	return move.has_flag(&"sound")


func disabled_text(_state: Dictionary) -> String:
	return "¡%s no puede usar %s por el Golpe Mordaza!"
