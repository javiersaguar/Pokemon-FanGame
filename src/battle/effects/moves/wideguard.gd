extends "res://src/battle/effects/moves/quickguard.gd"
## Vasta Guardia: este turno protege al equipo de los movimientos que alcanzan a varios.


func _init() -> void:
	condition_id = &"wideguard"
