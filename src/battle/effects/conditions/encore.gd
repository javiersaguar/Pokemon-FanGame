extends BattleEffect
## Otra Vez: solo puede usar el movimiento que repite. Se acaba antes si se queda sin PP.


func duration(_engine: BattleEngine) -> int:
	return 3


func residual_order() -> int:
	return 16


func on_start(engine: BattleEngine, holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	engine.message(tr("¡%s sufre los efectos de Otra Vez!") % engine.name_of(holder))
	return true


func on_end(engine: BattleEngine, holder: Variant, _state: Dictionary) -> void:
	if not (holder as Battler).is_fainted():
		engine.message(tr("¡%s ya no sufre los efectos de Otra Vez!") % engine.name_of(holder))


func on_residual(engine: BattleEngine, holder: Variant, state: Dictionary) -> void:
	var b := holder as Battler
	var index := engine.move_index_of(b, StringName(str(state.get("move", ""))))
	if index < 0 or b.pokemon.moves[index].pp <= 0:
		engine.remove_volatile(b, &"encore")


func disables_move(_battler: Battler, state: Dictionary, move: MoveData) -> bool:
	return String(move.id) != str(state.get("move", ""))


func disabled_text(_state: Dictionary) -> String:
	return "¡%s solo puede repetir su movimiento y no puede usar %s!"
