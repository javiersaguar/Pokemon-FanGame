extends GmaxResidualCondition
## Durante 4 turnos, 1/6 de los PS a los que no son de tipo water.


func _init() -> void:
	immune_type = &"water"
