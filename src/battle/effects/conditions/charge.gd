extends BattleEffect
## Carga: dobla la potencia del siguiente movimiento de tipo Eléctrico y se gasta al final del turno
## en que lo usa.


func on_start(engine: BattleEngine, holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	engine.message(tr("¡%s ha empezado a cargar energía!") % engine.name_of(holder))
	return true


func modify_own_power(_engine: BattleEngine, _user: Battler, _state: Dictionary, move: MoveData, power: int) -> int:
	return power * 2 if move.type == &"electric" else power


func before_move_priority() -> int:
	return 3


func on_before_move(_engine: BattleEngine, _battler: Battler, state: Dictionary, move: MoveData) -> bool:
	if move.type == &"electric" and not move.is_status():
		state["spend"] = true
	return true


func residual_order() -> int:
	return 1


func on_residual(engine: BattleEngine, holder: Variant, state: Dictionary) -> void:
	if bool(state.get("spend", false)):
		engine.remove_volatile(holder, &"charge")
