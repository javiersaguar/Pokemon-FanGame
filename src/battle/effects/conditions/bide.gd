extends BattleEffect
## Venganza: cuenta el daño que recibe y le obliga a seguir con el movimiento.


func on_damage(_engine: BattleEngine, battler: Battler, state: Dictionary, amount: int, _source: StringName, _move: MoveData) -> int:
	state["stored"] = int(state.get("stored", 0)) + mini(amount, battler.pokemon.current_hp)
	return amount


func forced_action(engine: BattleEngine, battler: Battler, _state: Dictionary) -> BattleAction:
	var index := engine.move_index_of(battler, &"bide")
	return BattleAction.fight(index) if index >= 0 else null
