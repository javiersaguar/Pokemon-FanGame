extends RoomMoveEffect
## Zona Extraña: durante 5 turnos se intercambian la Defensa y la Defensa Especial en el daño.


func _init() -> void:
	room_id = &"wonderroom"
	start_text = "¡Se ha creado una zona extraña donde se intercambian la Defensa y la Defensa Especial!"
	end_text = "La zona extraña ha desaparecido."
