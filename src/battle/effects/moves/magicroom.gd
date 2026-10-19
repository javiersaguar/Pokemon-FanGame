extends RoomMoveEffect
## Zona Mágica: durante 5 turnos los objetos equipados no hacen nada.


func _init() -> void:
	room_id = &"magicroom"
	start_text = "¡Se ha creado una zona mágica donde los objetos no tienen efecto!"
	end_text = "La zona mágica ha desaparecido."
