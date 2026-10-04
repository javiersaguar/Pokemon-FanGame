extends TwoTurnMoveEffect
## Vuelo: sube un turno (casi nada le alcanza) y ataca al siguiente.


func _init() -> void:
	charge_text = "¡%s ha volado muy alto!"
	invulnerable = &"air"
