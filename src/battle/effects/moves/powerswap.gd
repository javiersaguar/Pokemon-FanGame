extends "res://src/battle/effects/moves/guardswap.gd"
## Cambiafuerza: intercambia con el objetivo los cambios de Ataque y Ataque Especial.


func _init() -> void:
	stats = [&"atk", &"spa"]
	text = "¡%s ha intercambiado los cambios de su fuerza con %s!"
