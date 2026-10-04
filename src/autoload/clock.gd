extends Node
## Hora del juego y momento del día (data/world.json → clock).
## Contrato: docs/contratos.md (sección Clock).
## De momento solo existe el modo "real" (reloj del sistema). El modo interno
## acelerado queda para la Fase 14 si el GDD lo elige.

## Desplazamiento en horas para pruebas (lo cambia el menú Debug).
var debug_hour_offset: int = 0

var _periods: Array[Dictionary] = []
var _current_period: StringName = &""
var _check_timer := 0.0


func _ready() -> void:
	var cfg: Dictionary = GameState.world_config.get("clock", {})
	for p: Dictionary in cfg.get("periods", []):
		_periods.append({"id": StringName(p["id"]), "from_hour": int(p["from_hour"])})
	_periods.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return a["from_hour"] < b["from_hour"])
	_current_period = period()


func _process(delta: float) -> void:
	_check_timer += delta
	if _check_timer < 1.0:
		return
	_check_timer = 0.0
	_refresh_period()


## {"hour", "minute", "weekday"} con weekday 0 = domingo ... 6 = sábado.
func now() -> Dictionary:
	var bias_minutes: int = Time.get_time_zone_from_system()["bias"]
	var unix := int(Time.get_unix_time_from_system()) + bias_minutes * 60 + debug_hour_offset * 3600
	var dt := Time.get_datetime_dict_from_unix_time(unix)
	return {"hour": dt["hour"], "minute": dt["minute"], "weekday": dt["weekday"]}


func hour() -> int:
	return now()["hour"]


func minute() -> int:
	return now()["minute"]


func weekday() -> int:
	return now()["weekday"]


## Momento del día: &"morning", &"day", &"evening" o &"night" (según world.json).
func period() -> StringName:
	if _periods.is_empty():
		return &"day"
	var h := hour()
	var result: StringName = _periods.back()["id"]
	for p: Dictionary in _periods:
		if h >= p["from_hour"]:
			result = p["id"]
	return result


func is_night() -> bool:
	return period() == &"night"


func set_debug_hour_offset(hours: int) -> void:
	debug_hour_offset = hours
	_refresh_period()


func _refresh_period() -> void:
	var p := period()
	if p != _current_period:
		_current_period = p
		EventBus.time_period_changed.emit(p)
