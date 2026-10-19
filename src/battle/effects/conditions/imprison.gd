extends BattleEffect
## Cerca: mientras esté en el campo, los rivales no pueden usar sus mismos movimientos.


func on_start(engine: BattleEngine, holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	engine.message(tr("¡%s ha sellado los movimientos que comparte con el rival!") % engine.name_of(holder))
	return true


func disables_foe_move(_holder: Battler, state: Dictionary, _battler: Battler, move: MoveData) -> bool:
	return String(move.id) in state.get("moves", []) and move.id != &"struggle"


func disabled_text(_state: Dictionary) -> String:
	return "¡%s no puede usar %s porque está sellado!"
