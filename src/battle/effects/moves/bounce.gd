extends TwoTurnMoveEffect
## Bote: salta un turno (casi nada le alcanza) y cae al siguiente.


func _init() -> void:
	charge_text = "¡%s ha dado un gran salto!"
	invulnerable = &"air"
