extends BattleEffect
## Recarga (Hiperrayo, Gigaimpacto...): el turno siguiente no se puede mover.


func before_move_priority() -> int:
	return 11


func on_before_move(engine: BattleEngine, battler: Battler, _state: Dictionary, _move: MoveData) -> bool:
	engine.message(tr("¡%s necesita recuperarse!") % engine.name_of(battler))
	engine.remove_volatile(battler, &"mustrecharge")
	return false


func forced_action(engine: BattleEngine, battler: Battler, state: Dictionary) -> BattleAction:
	return BattleAction.fight(maxi(0, engine.move_index_of(battler, StringName(str(state.get("move", ""))))))
