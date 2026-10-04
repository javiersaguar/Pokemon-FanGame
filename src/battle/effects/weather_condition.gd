class_name WeatherConditionEffect
extends BattleEffect
## Climas (Fase 9.3): 5 turnos, mensajes al empezar, seguir y acabar, y su efecto en el daño.

var start_text: String = ""
var continue_text: String = ""
var end_text: String = ""
## Tipo potenciado ×1,5 y tipo debilitado ×0,5 (lluvia: Agua y Fuego; sol: al revés).
var boosted_type: StringName = &""
var weakened_type: StringName = &""


func duration(_engine: BattleEngine) -> int:
	return 5


func residual_order() -> int:
	return 1


func on_start(engine: BattleEngine, _holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	engine.message(tr(start_text))
	return true


func on_residual(engine: BattleEngine, _holder: Variant, _state: Dictionary) -> void:
	engine.message(tr(continue_text))


func on_end(engine: BattleEngine, _holder: Variant, _state: Dictionary) -> void:
	engine.message(tr(end_text))


func weather_modifier(_engine: BattleEngine, move: MoveData) -> float:
	if boosted_type != &"" and move.type == boosted_type:
		return 1.5
	if weakened_type != &"" and move.type == weakened_type:
		return 0.5
	return 1.0
