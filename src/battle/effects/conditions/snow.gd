extends WeatherConditionEffect
## Nieve (9.ª generación): los de tipo Hielo tienen ×1,5 de Defensa. No hace daño.


func _init() -> void:
	start_text = "¡Ha empezado a nevar!"
	continue_text = "Sigue nevando."
	end_text = "Ha dejado de nevar."


func stat_modifier(_engine: BattleEngine, battler: Battler, stat: StringName) -> float:
	return 1.5 if stat == &"def" and battler.has_type(&"ice") else 1.0
