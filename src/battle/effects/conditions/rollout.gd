extends BattleEffect
## Rodando: tiene que seguir con el mismo movimiento hasta que falle o lo use cinco veces.


func forced_action(engine: BattleEngine, battler: Battler, state: Dictionary) -> BattleAction:
	var index := engine.move_index_of(battler, StringName(str(state.get("move", ""))))
	return BattleAction.fight(index) if index >= 0 else null
