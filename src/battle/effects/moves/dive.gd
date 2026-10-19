extends TwoTurnMoveEffect
## Buceo: se sumerge un turno (solo le alcanzan Surf y Torbellino) y ataca al siguiente.


func _init() -> void:
	charge_text = "¡%s se ha sumergido!"
	invulnerable = &"underwater"
