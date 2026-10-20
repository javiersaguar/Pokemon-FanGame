extends BattleEffect
## Tajo Metralla: deja una capa de Púas en el campo del rival.


func on_after_hit(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData, _damage: int) -> void:
	if user.is_fainted():
		return
	if engine.has_side_condition(target.side, &"spikes"):
		var state := engine.side_condition(target.side, &"spikes")
		state["layers"] = mini(3, int(state.get("layers", 1)) + 1)
	else:
		engine.add_side_condition(target.side, &"spikes", user)
