extends "res://src/battle/effects/moves/doubleshock.gd"
## Llama Final: solo puede usarlo un Pokémon de tipo Fuego, que deja de serlo al usarlo.


func _init() -> void:
	gone_type = &"fire"
