extends BattleEffect
## Movimiento bloqueado (Golpe, Danza Pétalo, Enfado): lo repite 2-3 turnos y después se queda confuso.
## El movimiento lleva la cuenta en on_after_move (state.uses_left).


func forced_action(engine: BattleEngine, battler: Battler, state: Dictionary) -> BattleAction:
	var index := engine.move_index_of(battler, StringName(str(state.get("move", ""))))
	return BattleAction.fight(index) if index >= 0 else null
