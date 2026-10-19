class_name RoomConditionEffect
extends BattleEffect
## Una zona (Espacio Raro...): el motor mira si está; al acabar avisa.


func residual_order() -> int:
	return 28


func on_end(engine: BattleEngine, _holder: Variant, state: Dictionary) -> void:
	engine.message(tr(str(state.get("end_text", ""))))
