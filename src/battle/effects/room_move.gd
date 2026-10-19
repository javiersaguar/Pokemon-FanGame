class_name RoomMoveEffect
extends BattleEffect
## Espacio Raro, Zona Extraña, Zona Mágica: 5 turnos; si ya está, usarlo otra vez lo quita.

var room_id: StringName = &""
var start_text := ""
var end_text := ""


func on_hit(engine: BattleEngine, _user: Battler, _target: Battler, _move: MoveData) -> int:
	if not engine.field_state(room_id).is_empty():
		engine.field.erase(String(room_id))
		engine.message(tr(end_text))
		return HANDLED
	engine.set_field_state(room_id, {"turns": 5, "end_text": end_text})
	engine.message(tr(start_text))
	return HANDLED
