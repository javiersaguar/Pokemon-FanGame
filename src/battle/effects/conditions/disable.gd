extends BattleEffect
## Anulación (4 turnos): no puede usar ese movimiento.


func duration(_engine: BattleEngine) -> int:
	return 4


func residual_order() -> int:
	return 17


func on_end(engine: BattleEngine, holder: Variant, _state: Dictionary) -> void:
	if not (holder as Battler).is_fainted():
		engine.message(tr("¡%s ya no está anulado!") % engine.name_of(holder))


func disables_move(_battler: Battler, state: Dictionary, move: MoveData) -> bool:
	return String(move.id) == str(state.get("move", ""))


func disabled_text(_state: Dictionary) -> String:
	return "¡%s no puede usar %s porque está anulado!"
