extends BattleEffect
## Eco Voz: 40 de potencia más 40 por cada turno seguido en que alguien la ha usado (hasta 200).


func base_power(engine: BattleEngine, _user: Battler, _target: Battler, _move: MoveData, power: int) -> int:
	var state := engine.field_state(&"echoedvoice")
	return power * mini(5, 1 + int(state.get("multiplier", 0)))


func on_after_move(engine: BattleEngine, _user: Battler, _move: MoveData, _hit: bool) -> void:
	var state := engine.field_state(&"echoedvoice")
	if state.is_empty():
		engine.set_field_state(&"echoedvoice", {"turns": 0, "multiplier": 1, "used_this_turn": true})
	elif not bool(state.get("used_this_turn", false)):
		state["multiplier"] = int(state.get("multiplier", 0)) + 1
		state["used_this_turn"] = true
