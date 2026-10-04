extends WeatherConditionEffect
## Lluvia: Agua ×1,5 y Fuego ×0,5 durante 5 turnos.


func _init() -> void:
	start_text = "¡Ha empezado a llover!"
	continue_text = "Sigue lloviendo."
	end_text = "Ha dejado de llover."
	boosted_type = &"water"
	weakened_type = &"fire"
