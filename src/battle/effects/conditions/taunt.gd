extends BattleEffect
## Mofa: no puede usar movimientos de estado.


func duration(_engine: BattleEngine) -> int:
	return 3


func residual_order() -> int:
	return 15


func on_start(engine: BattleEngine, holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	engine.message(tr("¡%s ha caído en la Mofa!") % engine.name_of(holder))
	return true


func on_end(engine: BattleEngine, holder: Variant, _state: Dictionary) -> void:
	if not (holder as Battler).is_fainted():
		engine.message(tr("¡%s ya no está bajo los efectos de la Mofa!") % engine.name_of(holder))


func disables_move(_battler: Battler, _state: Dictionary, move: MoveData) -> bool:
	return move.is_status()


func disabled_text(_state: Dictionary) -> String:
	return "¡%s no puede usar %s por la Mofa!"
