class_name WeatherMoveEffect
extends BattleEffect
## Danza Lluvia, Día Soleado, Tormenta Arena, Paraneve: ponen su clima (5 turnos).

var weather_id: StringName = &""


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	if not engine.set_weather(weather_id, user):
		engine.message(tr("¡Pero falló!"))
	return HANDLED
