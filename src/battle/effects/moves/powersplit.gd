extends "res://src/battle/effects/moves/guardsplit.gd"
## Isofuerza: el usuario y el objetivo reparten a medias su Ataque y su Ataque Especial.


func _init() -> void:
	stats = [&"atk", &"spa"]
	text = "¡%s ha compartido su fuerza con %s!"
