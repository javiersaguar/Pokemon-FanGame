extends TwoTurnMoveEffect
## Excavar: se mete bajo tierra un turno (solo le alcanzan Terremoto, Magnitud y Fisura) y ataca al siguiente.


func _init() -> void:
	charge_text = "¡%s se ha ocultado bajo tierra!"
	invulnerable = &"underground"
