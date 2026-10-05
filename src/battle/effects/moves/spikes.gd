extends BattleEffect
## Púas: hasta 3 capas en el campo rival.


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	_stack(engine, user, &"spikes", 3)
	return HANDLED


func _stack(engine: BattleEngine, user: Battler, id: StringName, max_layers: int) -> void:
	var side_index := 1 - user.side
	var state := engine.side_condition(side_index, id)
	if state.is_empty():
		engine.add_side_condition(side_index, id, user, {"layers": 1})
		return
	var layers := int(state.get("layers", 1))
	if layers >= max_layers:
		engine.message(tr("¡Pero falló!"))
		return
	state["layers"] = layers + 1
	if id == &"toxicspikes":
		engine.message(tr("¡El equipo %s ha sido rodeado de más púas tóxicas!") % engine.team_of_name(side_index))
	else:
		engine.message(tr("¡El equipo %s ha sido rodeado de más púas!") % engine.team_of_name(side_index))
