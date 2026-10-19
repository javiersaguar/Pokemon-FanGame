extends RoomMoveEffect
## Espacio Raro: durante 5 turnos los más lentos se mueven antes.


func _init() -> void:
	room_id = &"trickroom"
	start_text = "¡Se han retorcido las dimensiones!"
	end_text = "Las dimensiones han vuelto a la normalidad."
