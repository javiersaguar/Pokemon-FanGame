extends BattleEffect
## Eco Voz (condición del campo): cada turno seguido en que alguien la usa suma 40 de potencia (hasta 200).


func residual_order() -> int:
	return 99


func on_residual(engine: BattleEngine, _holder: Variant, state: Dictionary) -> void:
	if bool(state.get("used_this_turn", false)):
		state["used_this_turn"] = false
	else:
		engine.field.erase("echoedvoice")
