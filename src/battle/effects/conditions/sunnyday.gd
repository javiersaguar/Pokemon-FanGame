extends WeatherConditionEffect
## Sol: Fuego ×1,5 y Agua ×0,5 durante 5 turnos; nadie se congela.


func _init() -> void:
	start_text = "¡El sol pega fuerte!"
	continue_text = "El sol sigue pegando fuerte."
	end_text = "El sol vuelve a brillar como siempre."
	boosted_type = &"fire"
	weakened_type = &"water"


func on_set_status(engine: BattleEngine, _target: Battler, status: StringName, _source: Battler, announce: bool) -> bool:
	if status != &"frz":
		return true
	if announce:
		engine.message(tr("¡Pero falló!"))
	return false
