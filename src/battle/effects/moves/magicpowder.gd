extends "res://src/battle/effects/moves/soak.gd"
## Polvo Mágico: el objetivo pasa a ser solo de tipo Psíquico.


func _init() -> void:
	new_type = &"psychic"
	type_name = "Psíquico"
