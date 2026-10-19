extends BattleEffect
## Capa Mágica (un turno): devuelve los movimientos de estado reflejables.


func duration(_engine: BattleEngine) -> int:
	return 1


func residual_order() -> int:
	return 99


func on_start(engine: BattleEngine, holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	engine.message(tr("¡%s se ha cubierto con una capa mágica!") % engine.name_of(holder))
	return true


func on_try_hit(engine: BattleEngine, target: Battler, state: Dictionary, user: Battler, move: MoveData) -> bool:
	if not move.has_flag(&"reflectable") or user == target or bool(state.get("bouncing", false)):
		return true
	state["bouncing"] = true
	engine.message(tr("¡%s ha devuelto %s!") % [engine.name_of(target), move.name])
	engine.use_move(target, move)
	state["bouncing"] = false
	return false
